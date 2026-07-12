# CVE-2026-4441 — Hunting a Use-After-Free in Chromium's `base::OnceCallbackList`

*A step-by-step forensic write-up: from a one-line advisory to a reproducible
heap-use-after-free under AddressSanitizer, with a minimal standalone harness
instead of a full Chromium build.*

---

## Table of contents

1. [The starting point: almost nothing](#1-the-starting-point-almost-nothing)
2. [Reconnaissance: pinning down the bug](#2-reconnaissance-pinning-down-the-bug)
3. [Reading the vulnerable source](#3-reading-the-vulnerable-source)
4. [The data structures](#4-the-data-structures)
5. [The `Notify()` loop — where the bug lives](#5-the-notify-loop--where-the-bug-lives)
6. [The trigger: a re-entrant `Notify()` plus a dropped subscription](#6-the-trigger-a-re-entrant-notify-plus-a-dropped-subscription)
7. [Node-by-node trace with diagrams](#7-node-by-node-trace-with-diagrams)
8. [The exact moment of the UAF](#8-the-exact-moment-of-the-uaf)
9. [Why the upstream fix works](#9-why-the-upstream-fix-works)
10. [Why not just build Chromium?](#10-why-not-just-build-chromium)
11. [Building the smallest faithful harness](#11-building-the-smallest-faithful-harness)
12. [The libc++ trap I fell into](#12-the-libc-trap-i-fell-into)
13. [Docker reproduction under ASan](#13-docker-reproduction-under-asan)
14. [The confirmed trace](#14-the-confirmed-trace)
15. [Lessons and takeaways](#15-lessons-and-takeaways)

---

## 1. The starting point: almost nothing

The entire input was a file called `bug.md`:

```
CVE-2026-4441: A "Use after free" vulnerability in the Base component,
discovered by Google's own internal security team.

https://issues.chromium.org/issues/475877320
https://issues.chromium.org/issues/475874985
```

That is all. Two restricted Chromium issue-tracker links I cannot read, a
component name ("Base"), and a weakness class ("use after free"). The task:

> Recreate the vulnerability with Docker. If the original code is too large,
> create the smallest harness that still provides the tracing.

So the first job is pure reconnaissance: turn "UAF in Base" into a concrete
function, a concrete control-flow path, and a concrete trigger.

---

## 2. Reconnaissance: pinning down the bug

### 2.1 Public advisory corroboration

A web search against NVD / SentinelOne / Rapid7 / Tenable confirmed the bare
facts:

| Field        | Value                                                          |
| ------------ | -------------------------------------------------------------- |
| CVE          | CVE-2026-4441                                                  |
| Component    | `base` (Chromium //base)                                       |
| CWE          | CWE-416 (Use After Free)                                       |
| Severity     | Chromium "Critical", CVSS 3.1 = 8.8                            |
| Affected     | Google Chrome < 146.0.7680.153 (Windows / macOS / Linux)       |
| Trigger      | "a crafted HTML page" → heap corruption → potential RCE        |
| Fix version  | Chrome 146.0.7680.153 (stable channel update, 18 Mar 2026)     |

That narrows it to "something in `//base`, patched in 146.0.7680.153", but
`//base` is enormous — memory, callbacks, threads, files, strings, time…

### 2.2 Finding the fix commit

The release blog post
(`chromereleases.googleblog.com/2026/03/stable-channel-update-for-desktop_18.html`)
lists the issue as `crbug.com/489381399`. A targeted search for that bug
number surfaced the actual patch on `chromium.googlesource.com`:

```
074d472db745f01cf3dd3cc2225d51650e56f808
[M146][base] Fix UAF in base::OnceCallbackList on re-entrant Notify()
```

Now we have the exact file: **`base/callback_list.h`**, and the exact class:
**`OnceCallbackList`**. Fetching the diff (`?format=TEXT`, base64-decoded) gave
the whole story in 245 lines. The regression test in the diff is the trigger
we will port.

### 2.3 Reconnaissance output

```
TARGET     : base::OnceCallbackList<Signature>::Notify()
FILE       : //base/callback_list.h
WEAKNESS   : heap use-after-free of a std::list node
ROOT CAUSE : in-iteration splice() invalidates the outer loop's iterator
              when a re-entrant Notify() + subscription destruction frees
              the node the outer iterator still points at
TRIGGER    : OnceCallbackListCancelDuringReentrantNotify (regression test)
FIX        : defer all splicing/erasure to CleanUpNullCallbacksPostIteration()
```

---

## 3. Reading the vulnerable source

I pulled the **parent** of the fix commit to get the pre-patch file:

```bash
curl -sL "https://chromium.googlesource.com/chromium/src/+/074d472..^/base/callback_list.h?format=TEXT" \
  | base64 -d > callback_list_vuln.h
```

The vulnerable revision's key methods (lightly trimmed, real code):

```cpp
template <typename... RunArgs>
void Notify(RunArgs&&... args) {
  if (empty()) return;
  {
    AutoReset<bool> iterating(&iterating_, true);
    const auto next_valid = [this](const auto it) {
      return std::find_if_not(it, callbacks_.end(),
                              [](const auto& c) { return c.is_null(); });
    };
    for (auto it = next_valid(callbacks_.begin()); it != callbacks_.end();
         it = next_valid(it)) {
      static_cast<CallbackListImpl*>(this)->RunCallback(it++, args...);
    }
  }
  if (iterating_) return;                 // re-entrant frames skip pruning
  std::erase_if(callbacks_, [](const auto& cb) { return cb.is_null(); });
}
```

```cpp
// OnceCallbackList::RunCallback
void RunCallback(Callbacks::iterator it, RunArgs&&... args) {
  null_callbacks_.splice(null_callbacks_.end(), this->callbacks_, it);
  std::move(*it).Run(args...);            // may re-enter Notify()
}
```

```cpp
void CancelCallback(const Callbacks::iterator& it) {
  if (static_cast<CallbackListImpl*>(this)->CancelNullCallback(it)) return;
  if (iterating_) { it->Reset(); }
  else { callbacks_.erase(it); /* + removal_callback_ */ }
}

bool CancelNullCallback(const Callbacks::iterator& it) {
  if (it->is_null()) { null_callbacks_.erase(it); return true; }
  return false;
}
```

And from `//base/callback_list.cc`, the subscription's cancel-on-move/destruct
semantics that drive the trigger:

```cpp
CallbackListSubscription& operator=(CallbackListSubscription&& s) {
  Run();                              // cancel previously-held callback
  closure_ = std::move(s.closure_);
  return *this;
}
~CallbackListSubscription() { Run(); }
```

That is the entire vulnerable surface. The rest of this post is about reading
those ~30 lines very carefully.

---

## 4. The data structures

`OnceCallbackList` holds two `std::list<OnceClosure>`s. Drawing them as linked
lists of heap-allocated nodes:

```
   OnceClosureList
   ┌──────────────────────────────────────────────────────────┐
   │                                                          │
   │   callbacks_   (active, not-yet-run; the iteration src)  │
   │     head ──► [ A ] ──► [ B ] ──► ... ──► (sentinel)      │
   │                                                          │
   │   null_callbacks_ (executed nodes, kept alive so their   │
   │                     Subscriptions' iterators stay valid  │
   │                     until the outermost Notify() ends)   │
   │     head ──► (sentinel)                                  │
   │                                                          │
   │   iterating_ : bool  (true while inside any Notify())    │
   └──────────────────────────────────────────────────────────┘
```

Two invariants the original authors relied on:

1. **`std::list::splice` does not invalidate iterators.** Splicing a node from
   `callbacks_` to `null_callbacks_` leaves every iterator that pointed at it
   still valid — it now just denotes a node that belongs to the other list.
2. **Cancellation during iteration must not `erase()` from `callbacks_`.**
   That would invalidate the loop's live iterator. So `CancelCallback()` only
   does `it->Reset()` (nulls the closure in place) while `iterating_` is true,
   and lets the outermost `Notify()` prune nulls afterwards.

The bug is that **invariant (1) has a hole**: splicing is iterator-stable, but
the *outer loop's iterator* isn't pointing at the spliced node — it was
advanced past it, to a node that a *re-entrant* call ends up freeing.

---

## 5. The `Notify()` loop — where the bug lives

The loop is deceptively short:

```cpp
for (auto it = next_valid(callbacks_.begin()); it != callbacks_.end();
     it = next_valid(it)) {
  static_cast<CallbackListImpl*>(this)->RunCallback(it++, args...);
}
```

Three details matter enormously:

1. **`it++` (post-increment) is the argument to `RunCallback`.** Post-increment
   yields the old value *and* advances `it` as a side effect. Per the C++ rules
   for function-call argument evaluation, that side effect is sequenced
   **before `RunCallback`'s body executes**. So by the time the callback runs,
   the loop variable `it` already points to the *next* node.
2. **`RunCallback` splices the node out before running it.** The node passed in
   is moved to `null_callbacks_`; the closure is then invoked and may do
   anything — including re-entering `Notify()`.
3. **`next_valid` skips nulls.** It scans forward with `find_if_not(...,is_null)`
   so canceled-but-not-yet-pruned nodes are skipped.

Put together, at the start of each iteration the loop holds an iterator `it`
that is **one node ahead of the callback currently executing**. If that
"one-ahead" node gets freed while the callback runs, the next
`it = next_valid(it)` dereferences freed memory.

---

## 6. The trigger: a re-entrant `Notify()` plus a dropped subscription

The regression test added by the fix is the minimal trigger:

```cpp
OnceClosureList cb_reg;
CallbackListSubscription sub_a, sub_b;

auto cb_a = [&] {
  cb_reg.Notify();   // (A) re-entrant notification: runs cb_b
  sub_b = {};        // (B) drop sub_b -> CancelCallback(B)
};
auto cb_b = [] { /* DoNothing */ };

sub_a = cb_reg.Add(std::move(cb_a));
sub_b = cb_reg.Add(std::move(cb_b));
cb_reg.Notify();     // outer notification
```

The poison is in line (B): after the re-entrant `Notify()` has already *run*
`cb_b` (splicing B into `null_callbacks_` and nulling it), we destroy
`sub_b`. Because `~CallbackListSubscription` / `operator=` *run the cancel
closure*, this calls `CancelCallback(B)`. B is null, so the code takes the
`CancelNullCallback` branch and calls `null_callbacks_.erase(B)` — **freeing
B's list node**. But the outer `Notify()` loop still holds an iterator to B.

---

## 7. Node-by-node trace with diagrams

Initial state — `callbacks_ = [A, B]`, `null_callbacks_ = []`,
`iterating_ = false`:

```
   callbacks_     head ──► [ A ] ──► [ B ] ──► (s)
   null_callbacks_    head ──► (s)
   iterating_ = false
```

### Step 1 — outer `Notify()` enters

```
   ● cb_reg.Notify()  [main, poc.cpp:43]
     ├─ empty()? no
     ├─ AutoReset: iterating_ = true
     ├─ it = next_valid(begin) = A
     └─ loop body: RunCallback(it++)       // it was A; it now becomes B
```

State just before `RunCallback(A)` executes its body:

```
   callbacks_     head ──► [ A ] ──► [ B ] ──► (s)
                                  ▲
                                  └── loop iterator `it` (already advanced)

   null_callbacks_    head ──► (s)
   iterating_ = true
```

### Step 2 — `RunCallback(A)` splices, then runs A

```cpp
null_callbacks_.splice(null_callbacks_.end(), callbacks_, it);  // it == A
std::move(*it).Run();                                            // runs A
```

After the splice, before A's body runs:

```
   callbacks_     head ──► [ B ] ──► (s)
                                  ▲
                                  └── loop iterator `it`

   null_callbacks_    head ──► [ A ] ──► (s)
   iterating_ = true
```

A's body now re-enters `Notify()`.

### Step 3 — inner `Notify()` runs B

```
   ● cb_reg.Notify()  [inside cb_a]
     ├─ empty()? no (callbacks_ has B)
     ├─ AutoReset: iterating_ = true  (already true; restores true on exit)
     ├─ it_inner = next_valid(begin) = B
     └─ loop body: RunCallback(it_inner++)   // it_inner was B; now end
```

After `RunCallback(B)` splices B out and runs B:

```
   callbacks_     head ──► (s)                          ← now empty

   null_callbacks_    head ──► [ A ] ──► [ B ] ──► (s)
   iterating_ = true

   loop iterator `it` (outer)  ─────────────────────────► [ B ]  ◄── still B!
```

Inner loop ends (`it_inner = end`). Inner `Notify()` hits
`if (iterating_) return;` and **skips pruning** — exactly as designed, so the
outer frame's iterators stay stable. So far, so correct.

### Step 4 — back in A: `sub_b = {}` frees B

```
   ● sub_b = {}   [inside cb_a]
     └─ operator= → Run() → CancelCallback(B)
          ├─ B.is_null()? YES  (B was std::move().Run() in step 3)
          └─ null_callbacks_.erase(B)   ◄── FREES B's heap node
```

State after the erase:

```
   callbacks_     head ──► (s)

   null_callbacks_    head ──► [ A ] ──► (s)

   loop iterator `it` (outer)  ───► [ B ]  ◄── DANGLING (node freed!)
   iterating_ = true
```

B's `std::list` node has been returned to the allocator. The outer loop's `it`
is now a dangling iterator into freed memory. A's body returns;
`RunCallback(A)` returns; control goes back to the outer `for` loop head.

---

## 8. The exact moment of the UAF

The for-loop's continuation clause runs:

```cpp
it = next_valid(it);     // it is the dangling iterator to freed B
```

which expands to:

```cpp
std::find_if_not(it, callbacks_.end(), [](const auto& c){ return c.is_null(); });
```

`find_if_not` checks `it != callbacks_.end()` (true: a freed address is not the
sentinel) and then dereferences `*it` to call `is_null()` on the freed node:

```
        outer Notify() loop
        ┌───────────────────────────────────────────────────────┐
        │  it = next_valid(it)                                  │
        │      │                                                │
        │      ▼                                                │
        │  find_if_not(it, callbacks_.end(), is_null_pred)      │
        │      │                                                │
        │      │  *it  ──►  FREED NODE  ◄── heap-use-after-free │
        │      │            (read of OnceClosure::f_ pointer)   │
        │      ▼                                                │
        │  is_null(*it)  →  reads poisoned/foreign memory       │
        └───────────────────────────────────────────────────────┘
```

That read — 8 bytes at the offset of `OnceClosure`'s stored-closure pointer
inside the freed list node — is the **heap-use-after-free** ASan reports. From
here the attacker's play is classic UAF exploitation: reclaim the freed node
with controlled data so that the dangling dereference (and any subsequent
node traversal via `++it`) reads attacker-shaped values, ultimately steering
control flow or corrupting the heap to gain code execution — matching the CVE
description ("exploit heap corruption via a crafted HTML page").

```
   Timeline of the dangling pointer
   ─────────────────────────────────────────────────────────────────
   t0  outer loop: it = A
   t1  RunCallback(it++)  ─►  it := B            (post-inc side effect)
   t2  splice A out of callbacks_
   t3  run A  ─►  re-enter Notify()
   t4      inner loop: splice B out of callbacks_, run B
   t5      inner Notify() returns (no prune; iterating_ still true)
   t6  A body: sub_b = {}  ─►  CancelCallback(B)  ─►  erase B   ◄── FREE
   t7  A returns; RunCallback(A) returns
   t8  outer loop: it = next_valid(it)   ◄── DEREF of freed B   ◄── UAF
   ─────────────────────────────────────────────────────────────────
```

---

## 9. Why the upstream fix works

The patch's central insight: **do not mutate either list during iteration.**
The new `RunCallback` no longer splices:

```cpp
void RunCallback(Callbacks::iterator it, RunArgs&&... args) {
  // Do not splice here. Splicing during iteration breaks re-entrant Notify()
  // by invalidating the outer loop's iterator. Splicing is deferred to
  // CleanUpNullCallbacksPostIteration(), called when the outermost Notify()
  // finishes.
  std::move(*it).Run(args...);
}
```

All mutations are pushed to a new `CleanUpNullCallbacksPostIteration()` phase
that runs **only at the outermost `Notify()`** (when `iterating_` flips back to
false):

- executed (now-null) nodes are spliced into `null_callbacks_`;
- nodes canceled during iteration, tracked in a new
  `std::vector<iterator> pending_erasures_`, are erased.

```
   VULNERABLE                              PATCHED
   ─────────────────────                   ───────────────────────
   RunCallback(it):                        RunCallback(it):
     splice(it → null_callbacks_)            it->Run()   // no splice
     it->Run()

   CancelCallback(it) during iter:         CancelCallback(it) during iter:
     it->Reset()                            it->Reset()
                                            pending_erasures_.push_back(it)

   end of EVERY Notify():                  end of OUTERMOST Notify() only:
     erase_if(callbacks_, is_null)          CleanUpNullCallbacksPostIteration():
                                              splice nulls → null_callbacks_
                                              erase pending_erasures_
```

Because nothing is freed while any outer loop still holds an iterator, the
dangling dereference in step 8 cannot occur. The regression test
(`OnceCallbackListCancelDuringReentrantNotify`) becomes a no-op instead of a
crash.

---

## 10. Why not just build Chromium?

Because it is utterly impractical for this purpose:

- **Size**: a full Chromium checkout is ~150 GB of source and ~300 GB of build
  output for a Release/ASan build of `chrome`.
- **Time**: even a trimmed `gn gen` + `ninja base_unittests` build is hours on
  a fast machine, and `base/callback_list_unittests` still pulls in a large
  slice of `//base`.
- **Docker footprint**: the resulting image would be enormous and slow to
  iterate on.

Crucially, **none of that machinery participates in the bug.** The UAF is pure
control flow in a single header. The only dependencies that *look* external —
`base::OnceClosure`, `base::WeakPtrFactory`, `base::AutoReset`,
`CallbackListSubscription` — are either trivial to inline or are behavioural
no-ops with respect to the UAF path. So the right move is the smallest harness
that reproduces the *exact* list-node lifecycle.

---

## 11. Building the smallest faithful harness

The harness (`harness/mini_callback_list.h`) is a 1:1 port of the vulnerable
control flow:

| `mini::`                         | Chromium `//base/`                         |
| -------------------------------- | ------------------------------------------ |
| `OnceClosure`                    | `base::OnceClosure`                        |
| `CallbackListSubscription`       | `base::CallbackListSubscription`           |
| `OnceClosureList`                | `base::OnceCallbackList<void()>`           |
| `callbacks_`, `null_callbacks_`  | same                                       |
| `Notify()` `next_valid`/`it++`   | identical                                  |
| `RunCallback()` splice-then-run  | identical                                  |
| `CancelCallback()` null-erase    | identical                                  |

The PoC (`harness/poc.cpp`) is a direct port of the upstream regression test,
with unbuffered `stderr` tracing so output survives the ASan abort:

```cpp
int main() {
  mini::OnceClosureList cb_reg;
  mini::CallbackListSubscription sub_a, sub_b;

  auto cb_a = [&]() {
    trace("[cb_a] entering; re-entering Notify()...");
    cb_reg.Notify();          // re-entrant notification: runs cb_b
    trace("[cb_a] back; releasing sub_b");
    sub_b = {};               // destroy sub_b -> CancelCallback(B) -> UAF set-up
    trace("[cb_a] returning");
  };
  auto cb_b = [] { trace("[cb_b] running (DoNothing equivalent)"); };

  sub_a = cb_reg.Add(mini::OnceClosure(std::move(cb_a)));
  sub_b = cb_reg.Add(mini::OnceClosure(std::move(cb_b)));

  trace("[main] calling outer Notify()...");
  cb_reg.Notify();            // UAF happens inside this call
  ...
}
```

The two structural substitutions are deliberately minimal:

- `base::OnceClosure` → a `std::unique_ptr<std::function<void()>>`-backed
  move-only closure (see §12 for why the `unique_ptr` matters).
- `WeakPtrFactory` self-protection on the cancel closure → a raw `this`
  capture. The list outlives all subscriptions in the PoC, so weak-pointer
  semantics are irrelevant to the UAF.

---

## 12. The libc++ trap I fell into

My first harness stored the cancel closure as a bare `std::function`. It
reproduced cleanly under `g++`/libstdc++ but, under `clang++`/libc++ inside
Docker, ASan reported a *different* fault at end-of-`main` instead of inside
`Notify()`. Instrumenting the subscription's
construct/move/destroy/`Run()` paths revealed why:

```
   libstdc++ (g++)                       libc++ (clang)
   ─────────────────────                 ──────────────────────
   sub_a = Add(cb_a):                    sub_a = Add(cb_a):
     move-ASSIGN: this=0, other=1          move-ASSIGN: this=0, other=1
     move-ASSIGN done: this=1             move-ASSIGN done: this=1
     ~temporary: cancel=0  ◄── empty       ~temporary: cancel=1  ◄── STILL SET
                                          ~temporary: Run() -> invokes closure
```

In libc++, `std::function::operator=(function&&)` does **not** reliably empty
the moved-from object (the standard only requires "valid but unspecified").
So the temporary returned by `Add()` would re-invoke its cancel closure on
destruction, **cancelling B before `Notify()` ever ran**, which masked the real
UAF and produced an end-of-`main` double-free instead.

This is a harness portability bug, not the CVE — but it is exactly the kind of
thing that makes a "minimal reproduction" misleading if you are not careful.
The fix is to back the closure with `std::unique_ptr`, whose move *always*
empties the source:

```cpp
class OnceClosure {
  std::unique_ptr<std::function<void()>> f_;   // move empties source, always
 public:
  bool is_null() const { return !f_; }
  void Reset() { f_.reset(); }
  void Run() {
    std::unique_ptr<std::function<void()>> g;
    g.swap(f_);              // drain
    if (g) (*g)();
  }
};
```

This matches `base::OnceClosure`'s real move-only, pointer-swap semantics.
After the fix, **both** compilers reproduce the *same* UAF at the same site
(the outer `Notify()` loop's `next_valid`). The lesson: when porting a
move-only type, do not assume `std::function` move empties the source — wrap
it in a `unique_ptr` to make the invariant explicit.

---

## 13. Docker reproduction under ASan

The `Dockerfile` is deliberately tiny — Ubuntu 22.04, clang-15, libc++,
`llvm-15` (for symbolized stack traces), and one compile command:

```dockerfile
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        clang-15 libc++-15-dev libc++abi-15-dev llvm-15 ca-certificates \
    && ln -sf /usr/bin/llvm-symbolizer-15 /usr/local/bin/llvm-symbolizer \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /work
COPY harness/ /work/harness/
RUN clang++-15 -std=c++20 -g -O0 -fno-omit-frame-pointer \
        -fsanitize=address,undefined -stdlib=libc++ \
        -I/work/harness /work/harness/poc.cpp -o /work/poc_asan
CMD ["/work/poc_asan"]
```

The build flags are chosen for *tracing*, not performance:

| flag                          | purpose                                             |
| ----------------------------- | --------------------------------------------------- |
| `-fsanitize=address,undefined`| catch the UAF and any UB in the iterator arithmetic |
| `-g -O0`                      | max fidelity to source; no inlining hiding lines   |
| `-fno-omit-frame-pointer`     | clean stack walks                                    |
| `llvm-symbolizer` on PATH     | symbolic `file:line:col` in the ASan report         |

`reproduce.sh` builds the image and runs the PoC with ASan options that abort
on the first error and print a full stack trace:

```bash
docker run --rm --cap-add=SYS_PTRACE \
    -e ASAN_OPTIONS="detect_leaks=0:abort_on_error=1:print_stacktrace=1:\
halt_on_error=1:symbolize=1:external_symbolizer_path=/usr/local/bin/llvm-symbolizer" \
    "${IMG}" /work/poc_asan
```

---

## 14. The confirmed trace

End-to-end `./reproduce.sh` output (clang-15/libc++ inside Docker):

```
[main] calling outer Notify()...
[cb_a] entering; re-entering Notify()...
[cb_b] running (DoNothing equivalent)
[cb_a] back from re-entrant Notify(); releasing sub_b
[cb_a] returning
==1==ERROR: AddressSanitizer: heap-use-after-free on address 0x603000000080
    #1 mini::OnceClosure::is_null() const            mini_callback_list.h:49
    #4 OnceClosureList::Notify() next_valid lambda    mini_callback_list.h:122
    #5 OnceClosureList::Notify()                      mini_callback_list.h:126
    #6 main                                           poc.cpp:49
freed by thread T0 here:
    #7 OnceClosureList::CancelCallback                mini_callback_list.h:151
       (null_callbacks_.erase)
    #15 OnceClosure::Run()                            mini_callback_list.h:57
    #16 CallbackListSubscription::Run()               mini_callback_list.h:91
    #18 main::$_0::operator() const                   poc.cpp:40  (sub_b = {};)
previously allocated by thread T0 here:
    #8 main                                           poc.cpp:46  (sub_b = Add(cb_b))
```

Reading the trace top-to-bottom against the §7 diagrams:

- `#6 → #5 → #4 → #1` is **step 8**: the outer `Notify()` loop's `next_valid`
  lambda calling `is_null()` on the dangling iterator — the READ of freed
  memory.
- `freed by #7 → #16 → #18` is **step 4**: `sub_b = {}` inside `cb_a` →
  subscription `Run()` → `CancelCallback` → `null_callbacks_.erase(B)`.
- `previously allocated #8` is the original `Add(cb_b)` — B's node allocation.

The trace matches the predicted node-by-node trace *exactly*, and a local
`g++ -fsanitize=address` build produces the same trace (different addresses),
confirming the reproduction is compiler/stdlib-independent.

```
   Reproduction at a glance
   ┌─────────────────────────────────────────────────────────────┐
   │  ./reproduce.sh                                             │
   │    ├─ docker build  (clang-15 + libc++ + ASan)              │
   │    └─ docker run   /work/poc_asan                           │
   │         ├─ [main]  outer Notify()                           │
   │         ├─ [cb_a]  re-entrant Notify() runs cb_b            │
   │         ├─ [cb_a]  sub_b = {}  ─►  erase B  ─►  FREE node   │
   │         ├─ [cb_a]  return                                   │
   │         └─ ASan: heap-use-after-free in next_valid(*it)     │
   │            exit code 1 (non-zero = UAF caught)              │
   └─────────────────────────────────────────────────────────────┘
```

---

## 15. Lessons and takeaways

1. **A one-line advisory is enough if you can find the fix commit.** The
   Chromium monorepo + `crbug` numbers + `gitiles` `?format=TEXT` made it
   possible to go from "UAF in Base" to the exact patch in a few fetches.
   The diff *is* the writeup, once you can read it.

2. **Read the loop's increment expression like a lawyer.** `RunCallback(it++)`
   looks innocuous, but the post-increment side effect being sequenced before
   the call body is the whole reason the outer iterator ends up one node ahead
   of the executing callback — and therefore pointing at a node a re-entrant
   call can free.

3. **`std::list::splice` is iterator-stable, but that is not the same as
   iterator-*safe-for-outer-loops*.** The original code's invariant "splice
   doesn't invalidate iterators" is true *locally*; the bug is that an outer
   loop holds an iterator to a *different* node that a nested call can free.
   Iterator stability is a per-operation guarantee, not a system-wide one.

4. **Cancellation during iteration needs a deferred-erasure queue, not just
   in-place nulling.** The vulnerable code already deferred `erase()` from
   `callbacks_` (it did `it->Reset()` and pruned later). It forgot to defer
   `erase()` from `null_callbacks_`, which is where executed-then-cancelled
   nodes live. The fix unifies both under `pending_erasures_` + a single
   post-iteration cleanup.

5. **When porting a move-only type, do not trust `std::function` move to
   empty the source.** Under libc++ it may not. Wrap in `unique_ptr` to make
   the "moved-from is empty" invariant explicit, or you will chase a
   phantom bug that only manifests on one toolchain.

6. **The smallest faithful harness beats the full build for tracing.** A
   ~150-line standalone header reproduces the exact UAF with a clean, symbolic
   ASan trace in a Docker image under 1 GB and a < 1 s runtime. The same bug
   in `chrome` would need a Chromium ASan build and a browser-driven HTML
   harness to even reach the same code path.

7. **Trace to unbuffered `stderr`.** When ASan aborts the process, buffered
   `stdout` is lost. Switching the PoC's prints to `stderr` + `fflush` was the
   difference between "I think it crashes here" and "I can *see* it crashes
   here, after `[cb_a] returning` and before `[main] Notify() returned`".

---

### Artifacts

```
cve-2026-4441/
├── bug.md                  the original one-line advisory
├── analysis.md             full root-cause + node trace + mapping
├── README.md               run instructions
├── reproduce.sh            one-shot docker build + ASan run
├── Dockerfile              ubuntu:22.04 + clang-15/libc++ + ASan + symbolizer
└── harness/
    ├── mini_callback_list.h   minimal vulnerable OnceCallbackList (1:1 control flow)
    └── poc.cpp                port of the upstream regression test
```

Reproduce it yourself:

```bash
cd cve-2026-4441
./reproduce.sh        # builds the image, runs the PoC, ASan reports the UAF
```

The vulnerability is real, the reproduction is faithful, and the trace points
exactly at the line that dereferences the freed `std::list` node — the
hallmark of CVE-2026-4441.
