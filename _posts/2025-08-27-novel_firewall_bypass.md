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

* Ftrace implementation to identify all the kernel API executed when handling the ingress HTTP packet:

  1 #!/bin/bash
  2 set -x
  3 echo 0 >/debug/tracing/tracing_enabled
  5 echo tcp_* ipv4_* *socket* > /debug/tracing/set_ftrace_filter
  6 echo function >/debug/tracing/current_tracer
  7 echo 1 >/debug/tracing/tracing_enabled
  8 wget http://www.yahoo.com/
  9 echo 0 >/debug/tracing/tracing_enabled
 10 cat /debug/tracing/trace | head -5000 | tee ftrace/wget_ftrace.log

and assuming debugfs is mounted.   The result of above are:

            wget-12509 [000]   145.604733: sys_socket <-system_call_fastpath
            wget-12509 [000]   145.604736: security_socket_create <-__sock_create
            wget-12509 [000]   145.604737: cap_socket_create <-security_socket_create
            wget-12509 [000]   145.604749: security_socket_post_create <-__sock_create
            wget-12509 [000]   145.604750: cap_socket_post_create <-security_socket_post_create
            wget-12509 [000]   145.604758: security_socket_bind <-sys_bind
            wget-12509 [000]   145.604759: cap_socket_bind <-security_socket_bind
            wget-12509 [000]   145.604764: security_socket_getsockname <-sys_getsockname
            wget-12509 [000]   145.604765: cap_socket_getsockname <-security_socket_getsockname
            wget-12509 [000]   145.604775: security_socket_sendmsg <-__sock_sendmsg
            wget-12509 [000]   145.604775: cap_socket_sendmsg <-security_socket_sendmsg
            wget-12509 [000]   145.604777: security_socket_getpeersec_dgram <-netlink_sendmsg
            wget-12509 [000]   145.604777: cap_socket_getpeersec_dgram <-security_socket_getpeersec_dgram
            wget-12509 [000]   145.604794: cap_socket_sock_rcv_skb <-security_sock_rcv_skb
            wget-12509 [000]   145.604802: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.604802: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.604816: cap_socket_sock_rcv_skb <-security_sock_rcv_skb
            wget-12509 [000]   145.604821: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.604821: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.604825: cap_socket_sock_rcv_skb <-security_sock_rcv_skb
            wget-12509 [000]   145.604830: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.604830: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.604881: sys_socket <-system_call_fastpath
            wget-12509 [000]   145.604882: security_socket_create <-__sock_create
            wget-12509 [000]   145.604883: cap_socket_create <-security_socket_create
            wget-12509 [000]   145.604889: __unix_insert_socket <-unix_create1
            wget-12509 [000]   145.604891: security_socket_post_create <-__sock_create
            wget-12509 [000]   145.604892: cap_socket_post_create <-security_socket_post_create
            wget-12509 [000]   145.604899: security_socket_connect <-sys_connect
            wget-12509 [000]   145.604900: cap_socket_connect <-security_socket_connect
            wget-12509 [000]   145.604903: __unix_insert_socket <-unix_create1
            wget-12509 [000]   145.604916: __unix_remove_socket <-unix_release_sock
            wget-12509 [000]   145.604922: __unix_remove_socket <-unix_release_sock
            wget-12509 [000]   145.604930: sys_socket <-system_call_fastpath
            wget-12509 [000]   145.604931: security_socket_create <-__sock_create
            wget-12509 [000]   145.604931: cap_socket_create <-security_socket_create
            wget-12509 [000]   145.604935: __unix_insert_socket <-unix_create1
            wget-12509 [000]   145.604936: security_socket_post_create <-__sock_create
            wget-12509 [000]   145.604937: cap_socket_post_create <-security_socket_post_create
            wget-12509 [000]   145.604942: security_socket_connect <-sys_connect
            wget-12509 [000]   145.604942: cap_socket_connect <-security_socket_connect
            wget-12509 [000]   145.604945: __unix_insert_socket <-unix_create1
            wget-12509 [000]   145.604952: __unix_remove_socket <-unix_release_sock
            wget-12509 [000]   145.604957: __unix_remove_socket <-unix_release_sock
            wget-12509 [000]   145.606068: sys_socket <-system_call_fastpath
            wget-12509 [000]   145.606070: security_socket_create <-__sock_create
            wget-12509 [000]   145.606071: cap_socket_create <-security_socket_create
            wget-12509 [000]   145.606078: security_socket_post_create <-__sock_create
            wget-12509 [000]   145.606078: cap_socket_post_create <-security_socket_post_create
            wget-12509 [000]   145.606085: security_socket_connect <-sys_connect
            wget-12509 [000]   145.606086: cap_socket_connect <-security_socket_connect
            wget-12509 [000]   145.606111: security_socket_sendmsg <-__sock_sendmsg
            wget-12509 [000]   145.606112: cap_socket_sendmsg <-security_socket_sendmsg
            wget-12509 [000]   145.606125: ipv4_conntrack_defrag <-nf_iterate
            wget-12509 [000]   145.606127: ipv4_conntrack_local <-nf_iterate
            wget-12509 [000]   145.606128: ipv4_get_l4proto <-nf_conntrack_in
            wget-12509 [000]   145.606130: ipv4_pkt_to_tuple <-nf_ct_get_tuple
            wget-12509 [000]   145.606134: ipv4_invert_tuple <-nf_ct_invert_tuple
            wget-12509 [000]   145.606146: ipv4_confirm <-nf_iterate
            wget-12509 [000]   145.651272: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.651273: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.651293: ip_mc_drop_socket <-inet_release
            wget-12509 [000]   145.651337: sys_socket <-system_call_fastpath
            wget-12509 [000]   145.651338: security_socket_create <-__sock_create
            wget-12509 [000]   145.651339: cap_socket_create <-security_socket_create
            wget-12509 [000]   145.651342: security_socket_post_create <-__sock_create
            wget-12509 [000]   145.651342: cap_socket_post_create <-security_socket_post_create
            wget-12509 [000]   145.651347: security_socket_connect <-sys_connect
            wget-12509 [000]   145.651347: cap_socket_connect <-security_socket_connect
            wget-12509 [000]   145.651356: security_socket_sendmsg <-__sock_sendmsg
            wget-12509 [000]   145.651356: cap_socket_sendmsg <-security_socket_sendmsg
            wget-12509 [000]   145.651362: ipv4_conntrack_defrag <-nf_iterate
            wget-12509 [000]   145.651362: ipv4_conntrack_local <-nf_iterate
            wget-12509 [000]   145.651363: ipv4_get_l4proto <-nf_conntrack_in
            wget-12509 [000]   145.651363: ipv4_pkt_to_tuple <-nf_ct_get_tuple
            wget-12509 [000]   145.651364: ipv4_invert_tuple <-nf_ct_invert_tuple
            wget-12509 [000]   145.651369: ipv4_confirm <-nf_iterate
            wget-12509 [000]   145.651935: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.651935: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.651941: ip_mc_drop_socket <-inet_release
            wget-12509 [000]   145.652004: sys_socket <-system_call_fastpath
            wget-12509 [000]   145.652005: security_socket_create <-__sock_create
            wget-12509 [000]   145.652005: cap_socket_create <-security_socket_create
            wget-12509 [000]   145.652008: tcp_v4_init_sock <-inet_create
            wget-12509 [000]   145.652008: tcp_init_xmit_timers <-tcp_v4_init_sock
            wget-12509 [000]   145.652009: security_socket_post_create <-__sock_create
            wget-12509 [000]   145.652009: cap_socket_post_create <-security_socket_post_create
            wget-12509 [000]   145.652012: security_socket_connect <-sys_connect
            wget-12509 [000]   145.652012: cap_socket_connect <-security_socket_connect
            wget-12509 [000]   145.652013: tcp_v4_connect <-inet_stream_connect
            wget-12509 [000]   145.652015: tcp_set_state <-tcp_v4_connect
            wget-12509 [000]   145.652019: tcp_connect <-tcp_v4_connect
            wget-12509 [000]   145.652020: tcp_v4_md5_lookup <-tcp_connect
            wget-12509 [000]   145.652020: tcp_sync_mss <-tcp_connect
            wget-12509 [000]   145.652020: tcp_initialize_rcv_mss <-tcp_connect
            wget-12509 [000]   145.652021: tcp_select_initial_window <-tcp_connect
            wget-12509 [000]   145.652021: tcp_clear_retrans <-tcp_connect
            wget-12509 [000]   145.652022: tcp_transmit_skb <-tcp_connect
            wget-12509 [000]   145.652023: tcp_v4_md5_lookup <-tcp_transmit_skb
            wget-12509 [000]   145.652024: tcp_options_write <-tcp_transmit_skb
            wget-12509 [000]   145.652024: tcp_v4_send_check <-tcp_transmit_skb
            wget-12509 [000]   145.652025: ipv4_conntrack_defrag <-nf_iterate
            wget-12509 [000]   145.652026: ipv4_conntrack_local <-nf_iterate
            wget-12509 [000]   145.652026: ipv4_get_l4proto <-nf_conntrack_in
            wget-12509 [000]   145.652027: tcp_error <-nf_conntrack_in
            wget-12509 [000]   145.652028: ipv4_pkt_to_tuple <-nf_ct_get_tuple
            wget-12509 [000]   145.652028: tcp_pkt_to_tuple <-nf_ct_get_tuple
            wget-12509 [000]   145.652029: ipv4_invert_tuple <-nf_ct_invert_tuple
            wget-12509 [000]   145.652029: tcp_invert_tuple <-nf_ct_invert_tuple
            wget-12509 [000]   145.652030: tcp_new <-nf_conntrack_in
            wget-12509 [000]   145.652030: tcp_options <-tcp_new
            wget-12509 [000]   145.652032: tcp_packet <-nf_conntrack_in
            wget-12509 [000]   145.652034: ipv4_confirm <-nf_iterate
            wget-12509 [000]   145.700060: tcp_poll <-sock_poll
            wget-12509 [000]   145.700068: security_socket_sendmsg <-__sock_sendmsg
            wget-12509 [000]   145.700069: cap_socket_sendmsg <-security_socket_sendmsg
            wget-12509 [000]   145.700070: tcp_sendmsg <-__sock_sendmsg
            wget-12509 [000]   145.700072: tcp_send_mss <-tcp_sendmsg
            wget-12509 [000]   145.700073: tcp_current_mss <-tcp_send_mss
            wget-12509 [000]   145.700073: tcp_established_options <-tcp_current_mss
            wget-12509 [000]   145.700074: tcp_v4_md5_lookup <-tcp_established_options
            wget-12509 [000]   145.700080: tcp_push <-tcp_sendmsg
            wget-12509 [000]   145.700081: tcp_write_xmit <-__tcp_push_pending_frames
            wget-12509 [000]   145.700082: tcp_init_tso_segs <-tcp_write_xmit
            wget-12509 [000]   145.700082: tcp_set_skb_tso_segs <-tcp_init_tso_segs
            wget-12509 [000]   145.700085: tcp_transmit_skb <-tcp_write_xmit
            wget-12509 [000]   145.700086: tcp_established_options <-tcp_transmit_skb
            wget-12509 [000]   145.700087: tcp_v4_md5_lookup <-tcp_established_options
            wget-12509 [000]   145.700088: tcp_options_write <-tcp_transmit_skb
            wget-12509 [000]   145.700089: tcp_v4_send_check <-tcp_transmit_skb
            wget-12509 [000]   145.700091: ipv4_conntrack_defrag <-nf_iterate
            wget-12509 [000]   145.700092: ipv4_conntrack_local <-nf_iterate
            wget-12509 [000]   145.700093: ipv4_get_l4proto <-nf_conntrack_in
            wget-12509 [000]   145.700094: tcp_error <-nf_conntrack_in
            wget-12509 [000]   145.700095: ipv4_pkt_to_tuple <-nf_ct_get_tuple
            wget-12509 [000]   145.700095: tcp_pkt_to_tuple <-nf_ct_get_tuple
            wget-12509 [000]   145.700097: tcp_packet <-nf_conntrack_in
            wget-12509 [000]   145.700102: ipv4_confirm <-nf_iterate
            wget-12509 [000]   145.700127: tcp_event_new_data_sent <-tcp_write_xmit
            wget-12509 [000]   145.700165: tcp_poll <-sock_poll
            wget-12509 [000]   145.700168: tcp_poll <-sock_poll
            wget-12509 [000]   145.753286: tcp_poll <-sock_poll
            wget-12509 [000]   145.753300: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.753301: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.753302: tcp_recvmsg <-sock_common_recvmsg
            wget-12509 [000]   145.753307: tcp_rcv_space_adjust <-tcp_recvmsg
            wget-12509 [000]   145.753308: tcp_cleanup_rbuf <-tcp_recvmsg
            wget-12509 [000]   145.753320: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.753321: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.753322: tcp_recvmsg <-sock_common_recvmsg
            wget-12509 [000]   145.753324: tcp_rcv_space_adjust <-tcp_recvmsg
            wget-12509 [000]   145.753324: tcp_cleanup_rbuf <-tcp_recvmsg
            wget-12509 [000]   145.753338: tcp_poll <-sock_poll
            wget-12509 [000]   145.753343: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.753344: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.753345: tcp_recvmsg <-sock_common_recvmsg
            wget-12509 [000]   145.753346: tcp_rcv_space_adjust <-tcp_recvmsg
            wget-12509 [000]   145.753347: tcp_cleanup_rbuf <-tcp_recvmsg
            wget-12509 [000]   145.753350: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.753351: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.753351: tcp_recvmsg <-sock_common_recvmsg
            wget-12509 [000]   145.753353: tcp_rcv_space_adjust <-tcp_recvmsg
            wget-12509 [000]   145.753353: tcp_cleanup_rbuf <-tcp_recvmsg
            wget-12509 [000]   145.753905: tcp_poll <-sock_poll
            wget-12509 [000]   145.753912: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.753913: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.753914: tcp_recvmsg <-sock_common_recvmsg
            wget-12509 [000]   145.753929: tcp_rcv_space_adjust <-tcp_recvmsg
            wget-12509 [000]   145.753934: tcp_cleanup_rbuf <-tcp_recvmsg
            wget-12509 [000]   145.754039: tcp_poll <-sock_poll
            wget-12509 [000]   145.754042: tcp_poll <-sock_poll
            wget-12509 [000]   145.754711: tcp_poll <-sock_poll
            wget-12509 [000]   145.754719: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.754721: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.754722: tcp_recvmsg <-sock_common_recvmsg
            wget-12509 [000]   145.754725: tcp_rcv_space_adjust <-tcp_recvmsg
            wget-12509 [000]   145.754729: tcp_cleanup_rbuf <-tcp_recvmsg
            wget-12509 [000]   145.754764: tcp_poll <-sock_poll
            wget-12509 [000]   145.754766: tcp_poll <-sock_poll
            wget-12509 [000]   145.755518: tcp_poll <-sock_poll
            wget-12509 [000]   145.755526: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.755527: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.755528: tcp_recvmsg <-sock_common_recvmsg
            wget-12509 [000]   145.755558: tcp_rcv_space_adjust <-tcp_recvmsg
            wget-12509 [000]   145.755562: tcp_cleanup_rbuf <-tcp_recvmsg
            wget-12509 [000]   145.755737: tcp_poll <-sock_poll
            wget-12509 [000]   145.755739: tcp_poll <-sock_poll
            wget-12509 [001]   145.808858: tcp_poll <-sock_poll
            wget-12509 [001]   145.808865: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [001]   145.808865: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [001]   145.808866: tcp_recvmsg <-sock_common_recvmsg
            wget-12509 [001]   145.808868: tcp_rcv_space_adjust <-tcp_recvmsg
            wget-12509 [001]   145.808870: tcp_cleanup_rbuf <-tcp_recvmsg
            wget-12509 [001]   145.808925: tcp_poll <-sock_poll
            wget-12509 [001]   145.808925: tcp_poll <-sock_poll
            wget-12509 [000]   145.810354: tcp_poll <-sock_poll
            wget-12509 [000]   145.810362: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.810363: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.810364: tcp_recvmsg <-sock_common_recvmsg
            wget-12509 [000]   145.810367: tcp_rcv_space_adjust <-tcp_recvmsg
            wget-12509 [000]   145.810371: tcp_cleanup_rbuf <-tcp_recvmsg
            wget-12509 [000]   145.810475: tcp_poll <-sock_poll
            wget-12509 [000]   145.810477: tcp_poll <-sock_poll
            wget-12509 [000]   145.810656: tcp_poll <-sock_poll
            wget-12509 [000]   145.810664: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.810665: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.810665: tcp_recvmsg <-sock_common_recvmsg
            wget-12509 [000]   145.810703: tcp_rcv_space_adjust <-tcp_recvmsg
            wget-12509 [000]   145.810707: tcp_cleanup_rbuf <-tcp_recvmsg
            wget-12509 [000]   145.810743: tcp_poll <-sock_poll
            wget-12509 [000]   145.810746: tcp_poll <-sock_poll
            wget-12509 [000]   145.811016: tcp_poll <-sock_poll
            wget-12509 [000]   145.811024: security_socket_recvmsg <-__sock_recvmsg
            wget-12509 [000]   145.811025: cap_socket_recvmsg <-security_socket_recvmsg
            wget-12509 [000]   145.811025: tcp_recvmsg <-sock_common_recvmsg
            wget-12509 [000]   145.811029: tcp_rcv_space_adjust <-tcp_recvmsg
            wget-12509 [000]   145.811033: tcp_cleanup_rbuf <-tcp_recvmsg
            wget-12509 [000]   145.811164: ip_mc_drop_socket <-inet_release
            wget-12509 [000]   145.811166: tcp_close <-inet_release
            wget-12509 [000]   145.811168: tcp_set_state <-tcp_close
            wget-12509 [000]   145.811169: tcp_send_fin <-tcp_close
            wget-12509 [000]   145.811170: tcp_current_mss <-tcp_send_fin
            wget-12509 [000]   145.811171: tcp_established_options <-tcp_current_mss
            wget-12509 [000]   145.811171: tcp_v4_md5_lookup <-tcp_established_options
            wget-12509 [000]   145.811174: tcp_write_xmit <-__tcp_push_pending_frames
            wget-12509 [000]   145.811175: tcp_init_tso_segs <-tcp_write_xmit
            wget-12509 [000]   145.811176: tcp_transmit_skb <-tcp_write_xmit
            wget-12509 [000]   145.811177: tcp_established_options <-tcp_transmit_skb
            wget-12509 [000]   145.811178: tcp_v4_md5_lookup <-tcp_established_options
            wget-12509 [000]   145.811180: tcp_options_write <-tcp_transmit_skb
            wget-12509 [000]   145.811180: tcp_v4_send_check <-tcp_transmit_skb
            wget-12509 [000]   145.811183: ipv4_conntrack_defrag <-nf_iterate
            wget-12509 [000]   145.811183: ipv4_conntrack_local <-nf_iterate
            wget-12509 [000]   145.811184: ipv4_get_l4proto <-nf_conntrack_in
            wget-12509 [000]   145.811185: tcp_error <-nf_conntrack_in
            wget-12509 [000]   145.811186: ipv4_pkt_to_tuple <-nf_ct_get_tuple
            wget-12509 [000]   145.811187: tcp_pkt_to_tuple <-nf_ct_get_tuple
            wget-12509 [000]   145.811189: tcp_packet <-nf_conntrack_in
            wget-12509 [000]   145.811194: ipv4_confirm <-nf_iterate
            wget-12509 [000]   145.811220: tcp_event_new_data_sent <-tcp_write_xmit


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

