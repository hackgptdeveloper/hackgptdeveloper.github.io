# From a crash to a shell — how CVE-2026-109618 becomes RCE

This is the "what it means for a shell" writeup. It walks from the memory
corruption primitive characterized in
[`CHARACTERIZATION.md`](./CHARACTERIZATION.md) all the way to code execution,
explaining the concepts as it goes. It is written so a reader new to memory
corruption can follow the *why*, but the technical content — the actual
structures, offsets, and mechanisms — is reproduced accurately and is not
watered down.

> Status disclaimer: the **primitive** is proven (we measured it in gdb). The
> **chain** below is the standard, correct way to turn that primitive into RCE,
> and it is exactly the class of work Rapid7/Wiz describe as "narrow laboratory
> conditions". Steps that are proven are marked **[confirmed]**; steps that are
> the established technique but not yet carried out here are marked
> **[technique]**.

---

## 1. The goal in one sentence

A remote attacker who cannot log in sends a single HTTP request and gets a
shell (a `system("…")` / `proc_open("…")` call with attacker-chosen arguments).

We already have the hard-won starting point: a memory corruption that lets the
attacker control an 8-byte value that PHP then treats as a pointer and
*dereferences*. The rest is turning that into "run my command".

---

## 2. What we start with (recap)

From the gdb work:

- During request shutdown, `zend_array_destroy()` walks the `$_FILES` array's
  buckets.
- One bucket's `zval.value` field has been overwritten with the **multipart
  field name** (attacker bytes).
- The instruction `subl $0x1,(%rdi)` does `*(uint32_t*)P -= 1`, where `P` is
  those attacker bytes.
- If that decrement makes the value 0, PHP calls `rc_dtor_func(P)` — a function
  call with an attacker-chosen argument.

So the primitive is, precisely:

```
P = attacker-controlled 8 bytes
*(uint32_t*)P -= 1            # a 4-byte decrement at an address we choose
if (that value became 0)
    rc_dtor_func(P)           # a call with P as argument
```

Two things stand between this and a shell:

1. `P` must be a **mapped, writable address** (right now it is raw bytes like
   `0x4e4e4e4e4e4e4e4e`, which is unmapped, so the first dereference crashes).
2. `rc_dtor_func(P)` must be steered to **run our command**, not just destroy
   some object.

---

## 3. The concepts, in plain terms

Before the chain, four ideas you need.

### 3.1 The heap and the stack

- The **stack** holds local variables and grows/shrinks with function calls.
- The **heap** is the large region where programs request variable-sized
  chunks of memory at runtime (`malloc`). All of PHP's objects — strings,
  arrays, objects — live on the heap.
- The corruption we have lives on the heap: a freed chunk of heap memory is
  still referenced, and attacker data has been written into it.

### 3.2 ASLR (Address Space Layout Randomization)

Every time the process starts, the heap, libraries, and stack are loaded at
*random* base addresses. So a pointer's actual value (e.g.
`0x7f8a3f950400`) is different each run. This is why we cannot just hard-code
an address into our field name.

### 3.3 Function pointers and handler tables

Instead of calling a function directly, C programs often call through a
**pointer** stored inside a struct — a "virtual method" or "handler". PHP's
`zend_object` does exactly this:

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

`handlers` points to a table of function pointers. One of them is the
destructor:

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

**If we control `obj->handlers`, we control which function pointer gets called.**
That is the core trick of PHP object-based exploitation.

### 3.4 Reference counting

Every heap object starts with `zend_refcounted_h`:

```c
typedef struct _zend_refcounted_h {
    uint32_t refcount;    /* offset 0 */
    uint32_t type_info;   /* offset 4: what kind of object this is */
} zend_refcounted_h;
```

When a reference is dropped, PHP decrements `refcount`; when it reaches 0, the
object is destroyed by looking at `type_info` and dispatching to the right
destructor. `type_info` values of interest: `IS_STRING = 6`, `IS_ARRAY = 7`,
`IS_OBJECT = 8`.

Our primitive maps *directly* onto this: the `subl $0x1,(%rdi)` is PHP
decrementing a refcount, and `rc_dtor_func(P)` is "the refcount hit zero, so
destroy `P` according to its `type_info`".

---

## 4. The exploitation ladder

### Step 1 — Make `P` valid (the ASLR problem)  **[technique]**

Right now `P = 0x4e4e4e4e4e4e4e4e` (unmapped). We need `P` to point at memory
we control. Three standard routes:

**1a. Partial overwrite — ruled out for this bug.** If only the *low* bytes of
an existing pointer are clobbered (not all 8), the high bytes survive and `P`
lands in the same heap region as the original object. But this requires the
field-name buffer to be short enough to leave the bucket's high bytes intact —
and a short field name cannot trigger the corruption at all: the field name is
the "weight" that pushes the request over `memory_limit` at the `$_FILES`
registration step, and a larger pad cannot substitute (the pad itself OOMs
first). Empirically, field names of 4–256 bytes produced zero crashes; only
~700 KB reaches the corruption window, and a 700 KB buffer fully overwrites the
320-byte `arData` (all 8 bytes of `val.value` become attacker bytes). See
`CHARACTERIZATION.md` §7.2.

**1b. Info leak.** Read one heap address out of the process (the sibling
CVE-2026-109619 advertises memory disclosure), then put that address literally
into the field name. One leaked address + our full-control overwrite ≈ done.

**1c. Brute force / low entropy.** If a pointer is partially randomized
(only a few bits change), guess it. Not viable here — the heap is fully
randomized (we observed `arData` move across 3 runs).

### Step 2 — Heap grooming: place a fake object at `P`  **[technique]**

"Heap grooming" (a.k.a. heap feng shui) means: make repeated, precisely-sized
allocations so that a **known** heap location contains **known** bytes we
chose. Concretely, spray many copies of a fake object so that wherever `P`
points in the sprayed region, it lands on our fake object.

A fake object for our primitive looks like this (offsets from §3.3):

```
offset 0x00  refcount   = 1            ← so *(uint32_t*)P -= 1  →  0  →  rc_dtor_func runs
offset 0x04  type_info  = 8            ← IS_OBJECT → object destructor path
offset 0x08  handle     = (anything)
offset 0x0c  extra_flags= 0
offset 0x10  ce         = (a valid-ish pointer, can be fake)
offset 0x18  handlers   = <address of a fake handlers table>   ← the important one
```

Then `rc_dtor_func(P)` → sees `IS_OBJECT` → treats `P` as `zend_object*` →
reads `obj->handlers` (at `P+0x18`) → calls `obj->handlers->free_obj(obj)`.

The fake handlers table is a second sprayed buffer whose `free_obj` slot holds
whatever function address we want to call, and whose argument is `obj = P`.

### Step 3 — From a controlled call to a shell

This is the subtle part, and where a naive "point `free_obj` at `system` and
win" summary would be wrong.

`free_obj`'s type is `void (*)(zend_object *object)`. If we set it to `system`,
we get `system(obj)`. But `system` expects a `char*` command string, and `obj`
is our fake object pointer whose first bytes are `refcount=1, type=8` — not a
command. So the call is real but the argument is wrong.

The standard ways to close that gap:

**3a. Argument laundering via a gadget** **[technique].** Point `free_obj` at a
function whose first argument *is* meaningful. For example point it at a gadget
that interprets `obj` as a `zend_string*` and copies its payload, or at
`system` while making the fake object's bytes literally spell `sh -c '…'` so
that `(char*)obj` *is* the command (type confusion: the "object" is also the
"string").

**3b. Arbitrary read/write → then hijack for real** **[technique].** The more
robust, standard approach is to not jump straight to a shell, but to use this
primitive to get **arbitrary read** and **arbitrary write**:

- Corrupt a `zend_string`'s `len` (at offset 16 of `zend_string`) to a huge
  value → out-of-bounds **read** → leak a libc/PHP function pointer → defeat
  ASLR.
- Corrupt a `zend_string`'s `val` pointer → **write** to an arbitrary address
  → overwrite a real, live object's `handlers->free_obj` (or a
  `zend_internal_function.handler`) with `system`/`proc_open`.
- Then trigger that object normally, with a `zend_string` whose content is the
  command, so `system("bash -c '…'")` actually runs with the right argument.

This two-phase "read → leak → write → hijack → trigger" is the canonical
modern PHP exploit, and it is what the "narrow laboratory conditions" quote
refers to: every step is allocator- and version-specific.

---

## 5. The full chain, end to end (illustrative, using real structure offsets)

Putting it together, a concrete (simplified) chain for *this* bug:

1. **[confirmed]** Send a multipart request whose field name carries our chosen
   bytes; the OOM corrupts `$_FILES`, and shutdown dereferences our bytes as a
   `zend_refcounted*`.
2. **[technique]** Use a partial overwrite (or a leaked address) so `P` points
   into a heap region we have sprayed with fake objects.
3. **[technique]** `*(uint32_t*)P -= 1` decrements our fake object's
   `refcount` from 1 to 0.
4. **[technique]** `rc_dtor_func(P)` reads `type_info = IS_OBJECT`, follows
   `P + 0x18` to our fake handlers table, and calls `free_obj(P)`.
5. **[technique]** `free_obj` points at a gadget that turns `P` into a command
   string (or we use the arbitrary-write route in §4 3b to call `system` with a
   properly-formed `zend_string`).
6. **[technique]** The command runs in the PHP worker's process → reverse
   shell / callback.

---

## 6. Why this is "narrow laboratory conditions" — honestly

- **ASLR** must be defeated (leak or partial overwrite), and we have no leak
  yet.
- **Heap layout** is version-, build-, and SAPI-specific; a working spray for
  PHP 8.4.26 + Zend MM + mod_php does not transfer to 8.4.27 or FPM.
- **The primitive is a weak write** (a decrement), so it must be upgraded to
  arbitrary read/write through several more careful steps.
- **Mitigations** in modern PHP (NX, ASLR, hardened handlers, no trivially
  writable function pointers) mean the classic "one-shot fake object" rarely
  works cleanly.

None of this makes the bug less real — it is confirmed-exploitable by the
advisory and multiple vendors — it just means the *conversion* from "crash" to
"reliable shell" is an exploit-development project, not a flag to flip.

---

## 7. Where we are vs. what remains

| Stage | Status |
|---|---|
| Reproduce the crash | ✅ done (`poc/`, docker-compose) |
| Characterize the primitive | ✅ done (`CHARACTERIZATION.md`) |
| Confirm full attacker control of `P` | ✅ done (A/N/P gdb test) |
| Defeat ASLR — partial overwrite | ❌ ruled out (`CHARACTERIZATION.md` §7.2) |
| Defeat ASLR — info leak | ⏳ next (the CVE-2026-109619 sibling advertises memory disclosure) |
| Heap-spray a fake object | ⏳ |
| Controlled call → `system`/`proc_open` | ⏳ |

The immediate next step is §4 Step 1b: obtain a **heap address leak**. The
natural source is the CVE-2026-109619 sibling ("stale state … across requests",
with memory disclosure as an impact), via the default-on
`session.upload_progress` handler or the cross-request stale-state path —
a two-request, same-worker sequence. One leaked address is enough, because the
field name gives full byte control of `P`.
