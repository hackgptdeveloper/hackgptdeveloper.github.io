Trace the Linux kernel boot logging lifecycle from start_kernel() through memory initialization, comparing statically allocated log buffers, early console drivers, memblock initialization, and the exact buffer migration sequence used to preserve kernel messages


## 1. Compile-time baseline: the static log buffer

Before any memory allocator exists, `printk()` must already work. The kernel therefore embeds a static ring buffer:

- `__LOG_BUF_LEN = 1 << CONFIG_LOG_BUF_SHIFT`
- `static char __log_buf[__LOG_BUF_LEN] __aligned(LOG_ALIGN)`
- static ring-buffer metadata `printk_rb_static` describes that array.

So the first messages after `start_kernel()` — the Linux banner, command-line notices, early architecture messages — are stored in `__log_buf` without touching memblock or the page allocator.

This static buffer is deliberately small. On large systems, the numerous ACPI/EFI/memblock messages can overflow it before a larger buffer is available, which is why the kernel needs an early migration path.

---

## 2. `start_kernel()` before and around `setup_arch()`

The high-level boot order is:

```text
start_kernel()
  pr_notice("%s", linux_banner)          // writes into static __log_buf
  ...
  setup_arch(&command_line)
       early param parsing, including log_buf_len=
       memblock initialization
       setup_log_buf(1)                  // x86/several arches
  ...
  parse_early_param()
  ...
  setup_log_buf(0)                       // generic fallback
  vfs_caches_init_early()
  sort_main_extable()
  ...
  console_init()
```

Early boot messages produced before `console_init()` are not lost: they are stored in the static printk ring buffer. A boot console may print them immediately, but the canonical log record remains in the ring buffer.

---

## 3. `setup_arch()`, memblock, and the `log_buf_len=` parameter

`setup_arch()` is where architecture code:

1. Discovers the physical memory map.
2. Initializes/reserves memblock regions.
3. Sets memblock allocation limits.
4. Parses early parameters.
5. Calls the early log-buffer migration.

The `log_buf_len=` early parameter does **not** allocate immediately. Its handler merely records the requested size:

```c
static int __init log_buf_len_setup(char *str)
{
    unsigned size = memparse(str, &str);
    log_buf_len_update(size);
    return 0;
}
early_param("log_buf_len", log_buf_len_setup);
```

The actual allocation is deferred until memblock is usable.

On x86, the early call is made from `setup_arch()`:

```c
/* Allocate bigger log buffer */
setup_log_buf(1);
```

This happens after memblock has been initialized and after the memblock limit has been configured, so `memblock_alloc()` is usable.

---

## 4. Exact early migration: `setup_log_buf(1)`

Modern kernels do **not** simply `memcpy()` the static buffer. They migrate *printk records* into a new dynamically allocated printk ring buffer.

The core sequence in `kernel/printk/printk.c` is:

```c
void __init setup_log_buf(int early)
{
    ...
    if (!early)
        set_percpu_data_ready();

    if (log_buf != __log_buf)
        return;                              // already migrated

    if (!early && !new_log_buf_len)
        log_buf_add_cpu();

    if (!new_log_buf_len)
        return;                              // no larger buffer requested

    new_descs_count = new_log_buf_len >> PRB_AVGBITS;

    new_log_buf = memblock_alloc(new_log_buf_len, LOG_ALIGN);
    new_descs  = memblock_alloc(new_descs_size,  LOG_ALIGN);
    new_infos  = memblock_alloc(new_infos_size,  LOG_ALIGN);

    prb_init(&printk_rb_dynamic,
             new_log_buf, ilog2(new_log_buf_len),
             new_descs,  ilog2(new_descs_count),
             new_infos);

    local_irq_save(flags);

    log_buf_len       = new_log_buf_len;
    log_buf           = new_log_buf;
    new_log_buf_len   = 0;
    free              = __LOG_BUF_LEN;

    prb_for_each_record(0, &printk_rb_static, seq, &r)
        free -= add_to_rb(&printk_rb_dynamic, &r);

    prb = &printk_rb_dynamic;

    local_irq_restore(flags);

    /*
     * Copy any remaining messages that might have appeared from
     * NMI context after copying but before switching to the
     * dynamic buffer.
     */
    prb_for_each_record(seq, &printk_rb_static, seq, &r)
        add_to_rb(&printk_rb_dynamic, &r);

    if (seq != prb_next_seq(&printk_rb_static))
        pr_err("dropped %llu messages\n", ...);

    pr_info("log_buf_len: %u bytes\n", log_buf_len);
    pr_info("early log buf free: %u(%u%%)\n", ...);
}
```

This exact structure is visible in the v5.14 source and in newer printk code with the NMI second-pass copy.

### Key properties of the migration

| Step | Purpose |
|---|---|
| `log_buf != __log_buf` check | Prevents double migration when `setup_log_buf()` is called more than once. |
| `memblock_alloc()` for text, descriptors, and info arrays | The new printk ring buffer needs three allocations: text storage, descriptor array, and `printk_info` array. |
| `prb_init(&printk_rb_dynamic, ...)` | Initializes the dynamic ring buffer before any records are copied. |
| IRQ save / printk-safe entry | Ensures the boot CPU is not interrupted while the global buffer pointer is being switched. |
| `prb_for_each_record(0, &printk_rb_static, ...)` | Iterates the *old static ring buffer from sequence 0*, preserving message order, timestamps, and metadata. |
| `add_to_rb(&printk_rb_dynamic, &r)` | Copies each record into the new ring buffer; this is a record-level migration, not a raw byte copy. |
| `prb = &printk_rb_dynamic` | Atomically switches the global printk ring-buffer pointer. |
| Second `prb_for_each_record(seq, ...)` | Picks up messages that arrived from NMI context during the first copy. |
| `dropped %llu messages` check | Detects a race where the static buffer wrapped before migration completed. |

Historical kernels used a much simpler approach:

```c
new_log_buf = memblock_virt_alloc(new_log_buf_len, PAGE_SIZE);
...
memcpy(log_buf, __log_buf, __LOG_BUF_LEN);
```

That raw `memcpy()` preserved bytes but not the modern printk ringbuffer metadata. Modern kernels must use record migration because the ring buffer now separates text, descriptors, and `printk_info` metadata.

---

## 5. Generic fallback: `setup_log_buf(0)`

Not every architecture performs the early `setup_log_buf(1)` call. Later, `start_kernel()` calls:

```c
setup_log_buf(0);
vfs_caches_init_early();
sort_main_extable();
```

This is the generic fallback before `kmem_cache_init()` and before the buddy allocator is fully usable, so it also uses memblock/bootmem-style allocation rather than `kmalloc()`.

If the architecture already migrated the buffer early, `setup_log_buf(0)` returns immediately because `log_buf != __log_buf`. If not, it performs the same migration at this later point.

---

## 6. Early console drivers are separate from the log buffer

An **early console** / **boot console** is not a log buffer. It is a console driver that writes directly to hardware, typically a UART, very early in boot:

- `earlycon=` or architecture `earlyprintk` registers a `struct console` with `CON_BOOT`.
- `CON_PRINTBUFFER` means that when the boot console is registered, `register_console()` dumps the existing contents of the kernel log buffer to it.
- Messages are still stored in `__log_buf`; the early console is only a sink.
- Later, `console_init()` registers the real console drivers. The real console takes over, and the boot console is unregistered.

The kernel documentation describes the two console classes directly: “There are two types of consoles — bootconsoles (early_printk) and [real consoles].”

A typical early console definition looks like:

```c
static struct console early_console_prom = {
    .name  = "early",
    .write = early_console_write,
    .flags = CON_PRINTBUFFER | CON_BOOT,
};
```

So the early console can print boot messages before `console_init()`, but the authoritative log lifecycle is still:

```text
printk record → static __log_buf → (optional early console output)
             → dynamic ring buffer migration
             → console_init() registers real consoles
             → boot console handover/unregister
```



---

## 7. Comparison table

| Component | When available | Allocation | Role |
|---|---|---|---|
| `__log_buf` / `printk_rb_static` | Compile time, before `start_kernel()` | Static `.bss`/data array sized by `CONFIG_LOG_BUF_SHIFT` | Holds every early `printk()` record before memblock and before any console driver. |
| Early console / bootconsole | Very early, after early parameter parsing | No buffer allocation; direct hardware write | Immediately prints boot messages and dumps the existing static log buffer when registered. |
| `printk_rb_dynamic` | After memblock initialization, via `setup_log_buf(1)` or `setup_log_buf(0)` | `memblock_alloc()` for text buffer, descriptors, and `printk_info` array | Long-term kernel log ring buffer; receives all records migrated from the static buffer. |
| Real console | After `console_init()` | Console-driver specific | Prints current and backlogged log records; takes over from the boot console. |

---

## 8. Condensed lifecycle

```text
Bootloader / decompressor
        │
        ▼
start_kernel()
  ├─ pr_notice(linux_banner) ──────────────► static __log_buf
  ├─ setup_arch()
  │    ├─ memblock init / memory map
  │    ├─ parse early params (log_buf_len=)
  │    ├─ early console may register ──────► direct UART output,
  │    │                                      dumps __log_buf backlog
  │    └─ setup_log_buf(1)
  │         ├─ memblock_alloc(new text/descs/infos)
  │         ├─ prb_init(dynamic)
  │         ├─ IRQ-safe record copy static → dynamic
  │         ├─ switch global prb to dynamic
  │         └─ NMI second-pass copy + dropped-message check
  ├─ parse_early_param()
  ├─ setup_log_buf(0)  ── fallback / no-op if already migrated
  ├─ ...
  └─ console_init()
        ├─ register real consoles
        ├─ print remaining log buffer
        └─ unregister boot consoles
```

The critical design point is that the kernel never loses early messages during the transition from static to dynamic storage: it migrates **records**, not raw bytes, under IRQ-safe conditions, and performs a second pass for NMI-context records that could race the switch.
