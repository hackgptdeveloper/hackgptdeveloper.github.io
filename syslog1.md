How does printk get stored before memory is ready

It doesn’t store messages before usable memory exists. The distinction is between RAM being **usable** and Linux having finished initializing its memory-management system. Early `printk()` needs the former, not the latter: it can write into a statically reserved buffer without requesting memory from a running allocator. [android.googlesource](https://android.googlesource.com/kernel/msm/+/refs/heads/android-msm-halibut-4.9-pie-wear-mr1/kernel/printk/printk.c)

My earlier wording “during early kernel execution” did not mean “before RAM is available.”

## How the initial buffer works

The kernel includes an initial logging buffer as part of its statically allocated data. Conceptually, it works like this:

```c
/* Simplified illustration, not the complete modern implementation */
static char log_buffer[BUFFER_SIZE];
```

The space is reserved as part of the kernel image’s memory layout. Writing into it does not require `malloc()`, `kmalloc()`, a filesystem, or a syslog process. Older Linux implementations show this directly as:

```c
static char __log_buf[__LOG_BUF_LEN] __aligned(LOG_ALIGN);
static char *log_buf = __log_buf;
```

Modern implementations have additional ring-buffer metadata, but the underlying bootstrapping principle is the same: an initial buffer exists before a dynamically allocated replacement is needed. [android.googlesource](https://android.googlesource.com/kernel/msm/+/refs/heads/android-msm-halibut-4.9-pie-wear-mr1/kernel/printk/printk.c)

Later, if a larger buffer is required, `setup_log_buf()` can allocate a replacement using early-boot allocation facilities and transfer the existing log contents into it. [0xax.gitbooks](https://0xax.gitbooks.io/linux-insides/content/Initialization/linux-initialization-7.html)

## “Memory initialization” has several meanings

These are different milestones:

| Milestone | What it means for logging |
|---|---|
| Hardware memory is not yet usable | The normal RAM-backed `printk` buffer cannot work yet. |
| Kernel memory regions are accessible, but full memory management is not initialized | A statically reserved logging buffer can work. |
| Early boot allocation is available | Linux can allocate a larger logging buffer if needed. |
| Normal kernel allocators are available | General kernel dynamic allocation becomes available; early logging did not need to wait for this. |

Linux’s startup separates early allocation facilities such as `memblock` from the later general-purpose allocation machinery. The initial log buffer avoids that allocation dependency altogether. [0xax.gitbooks](https://0xax.gitbooks.io/linux-insides/content/Initialization/linux-initialization-7.html)

## What about even earlier diagnostics?

Before the normal buffered logging path is usable, architecture-specific startup code may send characters directly to a serial port using minimal low-level routines. These routines bypass the normal console machinery; they need not save a retrievable copy in the kernel log buffer. Such facilities depend on the platform and its hardware initialization state. [elinux](https://elinux.org/Debugging_by_printing)

Also, `earlycon` means “console output before the normal console driver is initialized”—not “logging magically works without RAM.” The kernel documents it specifically as an early console facility. [docs.kernel](https://docs.kernel.org/admin-guide/kernel-parameters.html)

So the apparent paradox disappears: early `printk()` works before Linux’s full memory-management services are ready, not before it has somewhere in memory to write. [android.googlesource](https://android.googlesource.com/kernel/msm/+/refs/heads/android-msm-halibut-4.9-pie-wear-mr1/kernel/printk/printk.c)
