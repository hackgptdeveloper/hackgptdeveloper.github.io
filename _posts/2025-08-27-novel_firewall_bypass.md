---
title: "How to bypass the Linux kernel firewall?"
tags:
  - Firewall-bypass

---

Imagine you `curl` a URL and a few microseconds later your web server replies. In between, the NIC DMA-writes the frame into memory, the Linux **NAPI** poller pulls it in **softirq** context, and the IP/TCP stack peels back headers to find the exact **socket** your process owns. From there, the kernel **queues bytes to that socket** and—if your app is blocked in `recvmsg()`/`read()` or waiting in `epoll_wait()`—**wakes your task** so the scheduler can hand execution back to **process context** to copy data into userspace.

This handoff isn’t magic; it’s a precise choreography of waitqueues and scheduler hooks. In mainline Linux (v6.x), the path runs roughly: **IRQ → NAPI (`net_rx_action`) → TCP receive (`tcp_v4_rcv`) → bind skb to socket (`skb->sk`) → data-ready callback (`sock_def_readable`) → waitqueue wakeup (`__wake_up`) → scheduler enqueue (`try_to_wake_up`) → userspace syscall resumes (`tcp_recvmsg`)**. In other words, the kernel doesn’t “redirect” the packet to a daemon; it **binds the flow to a socket** and **wakes the sleeping owner process**, switching from interrupt/softirq context to process context at the moment the scheduler chooses your task to run.

Below, we’ll walk this pipeline end-to-end—anchored to concrete source lines—so you can trace each transition from the first interrupt to the exact place your userspace thread picks up the bytes.

=======================


Imagine sending a HTTP packets to a webserver.   The linux kernel on the webserver check network packet for specific patterns.   Once the pattern is detected, the network packet will be redirected to a different background process while still running inside the linux kernel.

Here’s the exact “handoff” path in mainline Linux (v6.x) that takes you from **IRQ/softirq context** (NAPI + TCP receive) to the **woken userspace process’s syscall** (process context). I’ve chained it with the specific source locations so you can read it end-to-end.

---

# 1) Softirq (NAPI) receives the packet → find the socket (assign the *process* by its FD/socket)

In `tcp_v4_rcv()` (called from the RX softirq path) the kernel looks up the established socket for the incoming 4-tuple and **attaches it to the skb**:

```c
/* net/ipv4/tcp_ipv4.c */
sk = __inet_lookup_established(net, net->ipv4.tcp_death_row.hashinfo,
                               iph->saddr, th->source,
                               iph->daddr, ntohs(th->dest),
                               skb->skb_iif, inet_sdif(skb));
if (sk) {
    skb->sk = sk;              /* <- skb is now bound to the specific socket */
    skb->destructor = sock_edemux;
    ...
}
```

This is where the flow (5-tuple) is bound to the exact `struct sock` that a userspace process owns via its file descriptor. ([Code Browser][1])

> Background on the lookup: the search happens in `__inet_lookup_established()` over the TCP ehash, keyed by src/dst IP\:port. (Handy for following along in the source.) ([CoCalc][2])

---

# 2) TCP processes the skb in softirq → queue data to the socket → notify waiter

During receive, TCP queues data to the socket and then calls the socket’s “data ready” callback. The TCP core contains multiple paths that eventually do:

```c
/* net/ipv4/tcp_input.c — several places end with: */
sk->sk_data_ready(sk);
```

(There are multiple call sites; one is near the ACK handling path.) ([Code Browser][3])

By default, `sk_data_ready` is **`sock_def_readable`**, set when the socket is created:

```c
/* net/core/sock.c */
sk->sk_state_change = sock_def_wakeup;
sk->sk_data_ready   = sock_def_readable;   /* default data-ready hook */
sk->sk_write_space  = sock_def_write_space;
```

([Code Browser][4])

`sock_def_readable()` is the bit that **wakes up the sleeping readers**:

```c
/* net/core/sock.c */
rcu_read_lock();
wq = rcu_dereference(sk->sk_wq);
if (skwq_has_sleeper(wq))
    wake_up_interruptible_sync_poll(&wq->wait,
        EPOLLIN | EPOLLPRI | EPOLLRDNORM | EPOLLRDBAND);
sk_wake_async_rcu(sk, SOCK_WAKE_WAITD, POLL_IN);
rcu_read_unlock();
```

This runs in softirq context and **signals** any tasks blocked on the socket’s waitqueue (also feeding epoll). ([Code Browser][4])

---

# 3) Wakeup path → put the target task on a runqueue

The `wake_up_*()` above funnels into the generic waitqueue machinery:

```c
/* kernel/sched/wait.c */
int __wake_up(struct wait_queue_head *wq_head, unsigned int mode,
              int nr_exclusive, void *key)
{
    return __wake_up_common_lock(wq_head, mode, nr_exclusive, 0, key);
}
```

`__wake_up_common_lock()` iterates waiters and invokes their wake functions (typically `default_wake_function`), which in turn calls the scheduler’s **`try_to_wake_up()`** to mark the task runnable and enqueue it on a CPU runqueue. ([Code Browser][5])

The scheduler file documents what `try_to_wake_up()` does (enqueue runnable, only one rq->lock, etc.). The comments around it summarize the **state transitions** during a wakeup:

```c
/* kernel/sched/core.c — comments around try_to_wake_up() */
* Return: true if @p->state changes (an actual wakeup was done)
* ...
* Task enqueue is under rq->lock ... ttwu_queue() -- new rq, for enqueue of the task
```

These lines document how the awakened task becomes runnable and eligible for selection by the scheduler. ([Code Browser][6])

---

# 4) The sleeping reader (process context) resumes in `recvmsg()` after the wakeup

On the **process side**, the reader is typically blocked inside the TCP recv path, waiting on the socket’s waitqueue:

```c
/* net/ipv4/tcp.c — tcp_splice_read() shown here; tcp_recvmsg_locked is similar */
ret = sk_wait_data(sk, &timeo, NULL);  /* sleep until sk_data_ready() wakes us */
if (ret < 0)
    break;
...
```

This loop shows the canonical pattern: if no data, call `sk_wait_data()` (which prepares to wait on the socket’s waitqueue and calls `schedule()`), and when softirq calls `sock_def_readable()` the task is woken and continues in **process context** to actually copy bytes to user memory. ([Code Browser][7])

The generic wait path that actually **blocks/schedules** looks like this:

```c
/* kernel/sched/wait.c */
...                   /* queued on waitqueue */
schedule();           /* <- actual context switch to someone else */
...                   /* upon wake, we resume here in process context */
```

(Excerpt from `do_wait_intr_irq()` / helpers used by socket waits.) ([Code Browser][5])

---

## Putting it together (one-line per hop)

1. **Softirq RX** (NAPI): `tcp_v4_rcv()` → `__inet_lookup_established()` → **`skb->sk = sk`** (bind packet to that socket = “which process”). ([Code Browser][1])
2. **TCP enqueues data** and then calls **`sk->sk_data_ready()`**. ([Code Browser][3])
3. Default handler **`sock_def_readable()`** → **`wake_up_interruptible_sync_poll()`** on the socket’s waitqueue. ([Code Browser][4])
4. Waitqueue → **`__wake_up_common_lock()`** → **`default_wake_function`** → **`try_to_wake_up()`** (enqueue task runnable). ([Code Browser][5])
5. Scheduler picks the task; it **returns to process context** inside the blocked syscall (e.g., `tcp_recvmsg_locked()` / `sk_wait_data()` resumes) and copies data to user space. ([Code Browser][7])

That sequence is the precise moment and mechanism where execution **switches from interrupt/softirq context to the target process context**: the switch doesn’t happen “in the network code”; it happens when the wakeup path causes the scheduler to run the sleeping task, which then continues in the recv syscall.

---

### Extra references for full-stack tracing

* High-level RX flow notes (NAPI → `__netif_receive_skb` → IP → TCP → `sk_data_ready`). Useful when following with ftrace/perf. ([wiki.linuxfoundation.org][8], [GitHub][9])
* Kernel docs that show `struct sock` has the `sk_data_ready` callback and `sk_wait_data()` semantics. ([Linux Kernel Documentation][10])

If you want, I can produce a **minimal ftrace script** (`trace-cmd` / `perf probe`) that shows the above chain live on your kernel: `tcp_v4_rcv → __inet_lookup_established → tcp_data_queue → sock_def_readable → __wake_up → try_to_wake_up → tcp_recvmsg`.

[1]: https://codebrowser.dev/linux/linux/net/ipv4/tcp_ipv4.c.html?utm_source=chatgpt.com "tcp_ipv4.c source code [linux/net/ipv4 ..."
[2]: https://cocalc.com/github/torvalds/linux/blob/master/net/ipv4/inet_hashtables.c?utm_source=chatgpt.com "inet_hashtables.c"
[3]: https://codebrowser.dev/linux/linux/net/ipv4/tcp_input.c.html?utm_source=chatgpt.com "tcp_input.c source code [linux/net/ipv4 ..."
[4]: https://codebrowser.dev/linux/linux/net/core/sock.c.html?utm_source=chatgpt.com "sock.c source code [linux/net/core/sock.c] - Codebrowser"
[5]: https://codebrowser.dev/linux/linux/kernel/sched/wait.c.html "wait.c source code [linux/kernel/sched/wait.c] - Codebrowser "
[6]: https://codebrowser.dev/linux/linux/kernel/sched/core.c.html "core.c source code [linux/kernel/sched/core.c] - Codebrowser "
[7]: https://codebrowser.dev/linux/linux/net/ipv4/tcp.c.html "tcp.c source code [linux/net/ipv4/tcp.c] - Codebrowser "
[8]: https://wiki.linuxfoundation.org/networking/kernel_flow?utm_source=chatgpt.com "networking:kernel_flow [Wiki]"
[9]: https://github.com/penberg/linux-networking?utm_source=chatgpt.com "penberg/linux-networking: Notes on Linux network internals"
[10]: https://docs.kernel.org/networking/kapi.html?utm_source=chatgpt.com "Linux Networking and Network Devices APIs"

