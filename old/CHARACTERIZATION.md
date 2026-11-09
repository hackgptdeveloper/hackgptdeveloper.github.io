# CVE-2026-109618 — crash primitive characterization (ASan → gdb)

This document records the memory-corruption *primitive* behind CVE-2026-109618,
derived by instrumenting the vulnerable PHP 8.4.26 runtime. It answers "what
exactly is dangling / overwritten, and what can an attacker control?" — the
question any RCE chain has to be built on top of.

For "how does that turn into a callback shell", see
[`FROM_CRASH_TO_SHELL.md`](./FROM_CRASH_TO_SHELL.md).

---

## 1. TL;DR

| | |
|---|---|
| Crash site | `zend_array_destroy()` → `subl $0x1,(%rdi)` |
| Caller chain | `php_handler` (mod_php) → `php_request_shutdown` → `zend_array_destroy` |
| Corrupted object | the `arData` (bucket array) of the `$_FILES` `zend_array` |
| Corrupted field | `bucket->val.value` — the `zval`'s 8-byte value union |
| Corrupting data | the multipart **field name** (attacker-controlled bytes) |
| Resulting primitive | dereference an attacker-controlled pointer `P` and do `*(uint32_t*)P -= 1` |
| Second primitive | `efree(arData - nTableMask*4)` at the end of `zend_array_destroy` |

Proven empirically: with `name="AAAA…[k]"` the faulting pointer is
`0x4141414141414141`; with `name="NNNN…[k]"` it is `0x4e4e4e4e4e4e4e4e`; with
`pad='P'` + `name='N'` it is still `0x4e4e…` (so the **field name**, not the
pad value, is the byte source). The attacker controls the exact 8 bytes the
runtime treats as a `zend_refcounted*`.

---

## 2. Method — and why ASan alone could not see it

The natural first move was an AddressSanitizer build. I built PHP 8.4.26 with
`-fsanitize=address -O1 -g`, `--disable-all --enable-cli --enable-cgi
--enable-session --enable-debug`, and drove `php-cgi` with a multipart body on
stdin.

Three discoveries fell out of that:

### 2.1 `USE_ZEND_ALLOC=0` alone disables `memory_limit`

PHP's allocator selection in `Zend/zend_alloc.c::alloc_globals_ctor`:

```c
tmp = getenv("USE_ZEND_ALLOC");
if (tmp && !ZEND_ATOL(tmp)) {
    bool tracked = (tmp = getenv("USE_TRACKED_ALLOC")) && ZEND_ATOL(tmp);
    ...
    if (!tracked) {
        /* Use system allocator. */               /* plain malloc: NO limit */
        mm_heap->custom_heap._malloc = __zend_malloc;
        ...
    } else {
        /* Use system allocator and track allocations for auto-free. */
        mm_heap->custom_heap._malloc = tracked_malloc;   /* tracks + enforces limit */
        ...
    }
    return;
}
```

`USE_ZEND_ALLOC=0` switches to the *system* allocator, but only
`USE_TRACKED_ALLOC=1` selects the *tracked* system allocator that still enforces
`memory_limit`. Without the latter, a 9 MB allocation against an 8 MB limit
succeeds silently — so an ASan run without it never even triggers the OOM.
Both env vars are required:

```
USE_ZEND_ALLOC=0 USE_TRACKED_ALLOC=1
```

### 2.2 php-cgi does not reproduce the corruption — mod_php does

php-cgi's startup-failure path (`sapi/cgi/cgi_main.c`):

```c
if (php_request_startup() == FAILURE) {
    if (fastcgi) { fcgi_finish_request(request, 1); }
    SG(server_context) = NULL;
    php_module_shutdown();
    return FAILURE;          /* <-- no php_request_shutdown() */
}
```

Apache mod_php (`sapi/apache2handler/sapi_apache2.c::php_handler`) runs
`php_request_shutdown()` **even when `php_request_startup()` failed** (via
`php_apache_request_dtor`). That unconditional shutdown is what walks the
half-built state and corrupts — the advisory's "mod_php performs cleanup even
when request startup fails". I patched `cgi_main.c` to mimic it:

```c
if (php_request_startup() == FAILURE) {
    ...
    php_request_shutdown((void *) 0);   /* added: mimic mod_php */
    SG(server_context) = NULL;
    php_module_shutdown();
    return FAILURE;
}
```

### 2.3 The corruption is Zend-MM-specific

Even with the cgi patch *and* the tracked allocator, the shutdown ran cleanly —
no ASan report. The corruption lives inside the **Zend MM** allocator (its 2 MB
chunk arena and OOM realloc path), which ASan cannot instrument. So the right
instrument is **gdb against the real mod_php build** (Zend MM). The
`php:8.4.26-apache-bookworm` image ships `libphp.so` **not stripped**, so
symbols resolve.

> Takeaway: ASan only sees PHP bugs that reproduce under
> `USE_ZEND_ALLOC=0 USE_TRACKED_ALLOC=1`. Zend-MM-internal corruption needs
> gdb + the real build.

---

## 3. The definitive backtrace

Running `apache2 -X` under gdb:

```
Program received signal SIGSEGV, Segmentation fault.
0x00007f8a4002d14e in zend_array_destroy () from /usr/lib/apache2/modules/libphp.so
#1  php_request_shutdown () from libphp.so
#2  php_handler () from libphp.so
#3  ap_run_handler → ap_invoke_handler → ap_process_async_request → ap_process_request
```

`php_handler` (mod_php) → `php_request_shutdown` → `zend_array_destroy` → boom.
This is the pre-RINIT path: the multipart parser OOM'd during request startup,
`php_request_startup` returned FAILURE, mod_php ran shutdown anyway, and
shutdown destroyed the half-built `$_FILES` array.

---

## 4. The relevant structure layouts (offsets matter for the write primitive)

All from PHP 8.4.26 `Zend/zend_types.h`, x86-64, non-ZTS.

### `zend_refcounted_h` (8 bytes) — the garbage-collection header every heap object starts with

```c
typedef struct _zend_refcounted_h {
    uint32_t         refcount;      /* offset 0 */
    union {
        uint32_t type_info;         /* offset 4: type + flags */
    } u;
} zend_refcounted_h;
```

### `zval` (16 bytes)

```c
struct _zval_struct {
    zend_value value;               /* offset 0: 8-byte union (lval/dval/str/arr/obj/res/ref/ptr) */
    union {
        uint32_t type_info;
        struct {
            uint8_t  type;          /* offset 8 */
            uint8_t  type_flags;    /* offset 9 */
            uint16_t extra;         /* offset 10 */
        } v;
    } u1;
    union {
        uint32_t next;              /* offset 12: hash collision chain / cache_slot / ... */
        ...
    } u2;
};
```

### `Bucket` (32 bytes)

```c
typedef struct _Bucket {
    zval              val;          /* offset 0  (16 bytes) */
    zend_ulong        h;            /* offset 16 (hash or numeric index) */
    zend_string      *key;          /* offset 24 (string key, NULL for numeric) */
} Bucket;
```

### `zend_array` / `HashTable` (56 bytes) — what `$_FILES` is

```c
struct _zend_array {
    zend_refcounted_h gc;                       /* offset 0  (refcount@0, type_info@4) */
    union { struct { uint8_t flags; ... } v; uint32_t flags; } u;  /* offset 8  */
    uint32_t          nTableMask;               /* offset 12 (negative; hash area size) */
    union { uint32_t *arHash; Bucket *arData; zval *arPacked; };   /* offset 16 */
    uint32_t          nNumUsed;                 /* offset 24 */
    uint32_t          nNumOfElements;           /* offset 28 */
    uint32_t          nTableSize;               /* offset 32 */
    uint32_t          nInternalPointer;         /* offset 36 */
    zend_long         nNextFreeElement;         /* offset 40 */
    dtor_func_t       pDestructor;              /* offset 48 */
};
```

`HT_GET_DATA_ADDR(ht)` is the *allocation base* (`arData + nTableMask`, where
`nTableMask` is negative); `ht->arData` is the bucket start inside that
allocation.

---

## 5. The exact faulting instruction

Full annotated disassembly of `zend_array_destroy` (the hot path):

```asm
zend_array_destroy:
  mov  %rdi,%rbp                      ; rbp = ht
  cmpl $0x3ff,0x4(%rdi)               ; if type_info > 0x3ff → slow path (cached/immutable)
  mov  0x18(%rbp),%eax                ; eax = ht->nNumUsed
  movl $0x11,0x4(%rbp)                ; ht->type_info = 0x11  ("being destroyed" marker)
  test %eax,%eax                      ; if nNumUsed == 0 → skip to efree
  mov  0xc31e43(%rip),%rcx            ; load default pDestructor
  cmp  %rcx,0x30(%rbp)                ; compare ht->pDestructor (offset 0x30=48)
  jne  6051c0                         ; custom destructor → slow path
  mov  0x8(%rbp),%edx                 ; ht->u.flags
  mov  0x10(%rbp),%rbx                ; rbx = ht->arData
  mov  %eax,%r12d                     ; r12 = nNumUsed
  test $0x4,%dl                       ; HT_FLAG_PACKED?
  ...                                 ; compute end = arData + nNumUsed*stride

  ; -- bucket iteration loop --
605011: cmpb $0x0,0x9(%rbx)           ; bucket occupied?
605017: mov  (%rbx),%rdi              ; rdi = bucket->val.value   (offset 0)
60501a: subl $0x1,(%rdi)              ; *(uint32_t*)rdi -= 1       <-- the write primitive
60501d: jne  604fe8                   ; refcount != 0 → next bucket
60501f: call rc_dtor_func             ; refcount hit 0 → destroy the object

  ; -- after the loop --
605030: mov  0xc(%rbp),%eax           ; ht->nTableMask
605033: mov  0x10(%rbp),%rdi          ; ht->arData
605037: neg  %eax ; shl $0x2,%rax     ; nTableMask*4
60503d: sub  %rax,%rdi                ; rdi = arData - nTableMask*4  (allocation base)
605040: call _efree                   ; efree(arData - nTableMask*4)
```

The crash is the `subl $0x1,(%rdi)` at `+446` (`60514e` in the non-packed
variant, same instruction). Two primitives are visible:

1. **`*(uint32_t*)P -= 1`** where `P = bucket->val.value` (attacker bytes).
   If the decremented refcount reaches 0, `rc_dtor_func(P)` runs.
2. **`efree(arData - nTableMask*4)`** — an arbitrary-ish free reachable if the
   loop survives.

---

## 6. Register-level proof of full attacker control

Three gdb runs, three field-name payloads:

| field name | `rdi` at fault | meaning |
|---|---|---|
| `AAAA…[k]` | `0x4141414141414141` | 'A' = 0x41 |
| `NNNN…[k]` | `0x4e4e4e4e4e4e4e4e` | 'N' = 0x4e |
| `pad='P'`, `name='N'` | `0x4e4e4e4e4e4e4e4e` | field name, not pad, is the source |

`rbp` (=`ht`) and `rbx` (=`arData`) are valid heap pointers in every run; only
`rdi` is corrupted. The attacker controls the exact 8 bytes of
`bucket->val.value`.

---

## 7. The mechanism: use-after-free of `arData`

gdb memory dump at the crash (`x/12gx $rbp` for `ht`, `x/96gx $rbx` for
`arData`):

```
ht header (rbp = 0x7f8a3f8570a8), intact:
  0x0000001100000000   gc.refcount=0, type_info=0x11 (the "destroying" marker set by zend_array_destroy)
  0xfffffff000000010   u.flags=0x10, nTableMask=0xfffffff0 (-16)
  0x00007f8a3f950400   arData → 0x7f8a3f950400   <-- STALE
  0x0000000100000001   nNumUsed=1, nNumOfElements=1
  0x0000000000000008   nTableSize=8, nInternalPointer=0
  0x8000000000000000   nNextFreeElement
  0x00007f8a40076b60   pDestructor (valid function pointer)

arData (rbx = 0x7f8a3f950400), the freed-and-reused block:
  0x4e4e4e4e4e4e4e4e 0x4e4e4e4e4e4e4e4e   ('N' bytes, hundreds of them)
  0x4e4e4e4e4e4e4e4e 0x4e4e4e4e4e4e4e4e
  ... (mostly 0x4e4e…)
  0xb50b316e9bd98065                    (a surviving hash value)
  0x00007f8a3f950640                    (a pointer, past the 8-bucket array)
```

Interpretation:

- The `ht` header is **intact** and its `arData` field points at
  `0x7f8a3f950400`.
- That `arData` region is now **filled with the attacker's field-name bytes**
  ('N'). It has been freed and its storage reused by a field-name buffer.
- `nNumUsed=1`, so `zend_array_destroy` iterates the (stale) bucket array and
  reads `bucket[0].val.value = 0x4e4e…` as a `zend_refcounted*`.

This is a **use-after-free**: the bucket array's storage has been recycled for
attacker data while `ht->arData` still references it. The exact allocator
interaction that produces it is the vulnerable resize/realloc path:

`Zend/zend_hash.c::zend_hash_do_resize` (8.4.26, before the fix):

```c
void *new_data, *old_data = HT_GET_DATA_ADDR(ht);
uint32_t nSize = ht->nTableSize + ht->nTableSize;
Bucket *old_buckets = ht->arData;

new_data = pemalloc(HT_SIZE_EX(nSize, HT_SIZE_TO_MASK(nSize)), ...); /* OOM bailout can fire here */
ht->nTableSize = nSize;
ht->nTableMask = HT_SIZE_TO_MASK(ht->nTableSize);
HT_SET_DATA_ADDR(ht, new_data);        /* ht->arData = new_data */
memcpy(ht->arData, old_buckets, sizeof(Bucket) * ht->nNumUsed);
pefree(old_data, ...);                 /* old bucket storage freed */
zend_hash_rehash(ht);
```

The vulnerable allocator (below) turns an OOM into `zend_bailout()` *inside*
this sequence (and inside the field-name allocations that follow it), so the
parser exits with the array in a half-updated state. The freed bucket storage
is then handed back out for one of the ~700 KB field-name copies, and mod_php's
shutdown walks it as if it were still valid buckets.

> **Confirmed vs. inferred.** It is *confirmed* that `ht->arData` references
> storage filled with attacker field-name bytes (the dump above). The precise
> allocation ordering — which of the several field-name copies (`param`,
> `abuf`, `lbuf`, the `zend_string` key, the header `smart_str`) reuses which
> freed block, at which `zend_bailout` point — is the one remaining unpinned
> detail; pinning it needs a hardware watchpoint on `arData`.

### 7.1 Additional confirmations

- **`pDestructor` resolves to `zval_ptr_dtor`** (`info symbol` in gdb) — the
  array being destroyed is an ordinary PHP array (a superglobal), not a
  special-cased structure. Its buckets are destroyed value-by-value through
  `zval_ptr_dtor`, which is exactly the `*(uint32_t*)P -= 1` /
  `rc_dtor_func(P)` path the primitive abuses.
- **A wide dump (`x/1024gx $rbx`) shows the `arData` sits inside a large
  field-name buffer.** The `'N'` region spans far more than the 8-bucket array,
  and *adjacent freed 320-byte blocks* (spaced `0x140`) still contain
  **surviving valid buckets** — e.g. `val.value = 0x00007f3366e01000` — mixed
  with `'N'` overwrites. So the heap around the crash is a mixture of stale
  pointers and attacker bytes.

### 7.2 Partial-overwrite route is blocked (empirically)

The obvious ASLR bypass — clobber only the low bytes of `bucket->val.value` so
the high bytes of a real pointer survive — is **not reachable** for this bug:

- The field name must be ~700 KB: it is the "weight" that pushes the request
  over `memory_limit` at the `$_FILES` registration step. A short field name
  does not OOM there, and a larger pad cannot compensate — the pad itself OOMs
  first. (Sweep: field names of 4/16/64/256/700 bytes against pads 4000–8000 KB
  produced **zero** crashes except in the 700 KB case, and only at pad
  640–1280 KB.)
- A ~700 KB field-name buffer is a *large* allocation, and it fully overwrites
  the small (320-byte) `arData` block — all 8 bytes of `bucket->val.value`
  become attacker bytes, so no pointer high-bytes survive.

Consequence: turning the primitive into RCE now hinges on an **ASLR info leak**
(see [`FROM_CRASH_TO_SHELL.md`](./FROM_CRASH_TO_SHELL.md) §4 Step 1b), not on a
partial overwrite.

---

## 8. The vulnerable allocator code

The old OOM handler (deleted by the fix, commit `01a40e89fb`):

```c
static ZEND_COLD ZEND_NORETURN void zend_mm_safe_error(zend_mm_heap *heap,
    const char *format, size_t limit,
#if ZEND_DEBUG
    const char *filename, uint32_t lineno,
#endif
    size_t size)
{
    heap->overflow = 1;
    zend_try {
        zend_error_noreturn(E_ERROR, format, limit, ..., size);
    } zend_catch {
    } zend_end_try();
    heap->overflow = 0;
    zend_bailout();    /* longjmp() out of the allocator, mid-operation */
    exit(1);
}
```

`zend_bailout()` is `setjmp`/`longjmp`: it abandons the current C call stack
without running destructors or finishing whatever the caller of `emalloc` was
building. When the caller was half-way through a `zend_hash_update`/resize or a
field-name allocation, the `longjmp` skips the assignment that would have kept
the data structures consistent.

The old realloc grow/truncation path (`zend_mm_realloc_heap`) also lacked NULL
checks:

```c
/* small extension / truncation */
ret = zend_mm_alloc_small(heap, ZEND_MM_SMALL_SIZE_TO_BIN(size) ...); /* may return NULL on re-entrant OOM */
copy_size = use_copy_size ? MIN(old_size, copy_size) : old_size;
memcpy(ret, ptr, copy_size);        /* if ret == NULL, memcpy(NULL, ...) */
zend_mm_free_small(heap, ptr, old_bin_num);
```

The fix (`zend_mm_check_limit`, `ZEND_HAS_OOM()`, fallible `femalloc`/`ferealloc`
returning NULL, a delayed-OOM state machine, and a hard `_exit(137)` limit)
replaces this "longjmp out of the allocator" behavior with "defer the error to
a safe point and let callers unwind cleanly". That is the entire substance of
the patch.

---

## 9. What this means for a shell

The primitive is a real, attacker-controlled arbitrary-pointer dereference.
The full exploitation path (ASLR, heap spraying, fake objects, control-flow
hijack) is explained step-by-step, with the underlying concepts and structures,
in [`FROM_CRASH_TO_SHELL.md`](./FROM_CRASH_TO_SHELL.md).

---

## 10. Reproducing this analysis

```bash
# 1. Build vulnerable PHP (cgi) with ASan — see /home/ubuntu/php-src-asan/build.sh
#    CFLAGS="-O1 -g -fsanitize=address -fno-omit-frame-pointer"
#    LDFLAGS="-fsanitize=address"
#    ./configure --disable-all --enable-cli --enable-cgi --enable-session --enable-debug

# 2. Reproduce under ASan (needs BOTH env vars):
#    USE_ZEND_ALLOC=0 USE_TRACKED_ALLOC=1 \
#      sapi/cgi/php-cgi -C -n -d memory_limit=8M ... < body
#    (with cgi_main.c patched to call php_request_shutdown() on startup failure)

# 3. Reproduce under gdb against real mod_php (Zend MM):
docker run -d --name dbg -p 18090:80 php2shell:vuln sleep infinity
docker exec dbg apt-get install -y gdb
docker cp gdb.cmd dbg:/tmp/gdb.cmd     # gdb.cmd in this repo
docker exec -d dbg bash -c 'source /etc/apache2/envvars; mkdir -p /run/apache2 /var/lock/apache2; gdb -batch -x /tmp/gdb.cmd --args /usr/sbin/apache2 -X > /tmp/gdb.out 2>&1'
# send the files_registration payload (pad + name="<700KB>[k]"), then:
docker exec dbg cat /tmp/gdb.out
```

The trigger payload is `files_registration` from `poc/exploit.py` (pad field +
a ~700 KB field name, `memory_limit=8M`, parser limits raised).
