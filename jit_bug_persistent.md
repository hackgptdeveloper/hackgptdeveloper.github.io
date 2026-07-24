JIT optimization bugs cause memory corruption through a two-stage chain: a logic error in the compiler's optimization pipeline first emits **incorrect native code** (missing a safety check or mistyping a value), and that faulty code is then **triggered at runtime** by crafted JavaScript to corrupt heap memory. Below is a concrete, end-to-end walkthrough using a real-world bug.

## How JIT Compilation Works (Background)

JavaScript engines (V8, SpiderMonkey, JavaScriptCore) execute code through multiple tiers. Code starts in a baseline interpreter (e.g., V8's Ignition), and when a function becomes "hot" (executed frequently), the optimizing JIT compiler (V8's TurboFan, JSC's DFG/FTL, SpiderMonkey's IonMonkey) kicks in. [thenextweb](https://thenextweb.com/news/jacobian-conjecture-disproved-ai-fable-5)

Because JavaScript is dynamically typed, the JIT compiler must **speculate** about variable types. It profiles past executions (e.g., "both arguments were always Int32"), then generates native assembly **assuming** those types hold. To guard against speculation failure, the compiler inserts **speculation guards** — runtime checks that trigger a **deoptimization bailout** back to the interpreter if assumptions are violated. [youtube](https://www.youtube.com/watch?v=-A65idB2D84)

## The Optimization Pipeline

During compilation, the JIT applies multiple optimization passes to its intermediate representation (IR). Two passes are particularly security-relevant:

- **Common Subexpression Elimination (CSE)** — merges duplicate computations into a single operation
- **Bounds check elimination** — removes array bounds checks if the compiler can prove an index is always in range [thenextweb](https://thenextweb.com/news/jacobian-conjecture-disproved-ai-fable-5)

Both passes depend on **side-effect modeling** — the compiler must determine whether intervening operations can change the values or types that later operations depend on. If the modeling is **incorrect**, safety checks get wrongly eliminated, and the emitted native code becomes exploitable. [youtube](https://www.youtube.com/watch?v=-A65idB2D84)

## CVE-2020-9802: A CSE Bug in JavaScriptCore

### The Root Cause

In JavaScriptCore's DFG compiler, the `DFGClobberize` function determines whether an operation can be subject to CSE by declaring it as a `PureValue` — meaning its output depends only on its inputs. [youtube](https://www.youtube.com/watch?v=-A65idB2D84)

For `ArithMul`, the code correctly parameterized the `PureValue` with `node->arithMode()`:

```javascript
case ArithMul:
  case Int32Use:
    def(PureValue(node, node->arithMode()));
    return;
```

This parameterization prevents CSE from substituting a **checked** `ArithMul` (which detects integer overflow) with an **unchecked** one (which silently wraps). [youtube](https://www.youtube.com/watch?v=-A65idB2D84)

However, for `ArithNegate` (integer negation), the parameterization was **missing**:

```javascript
case ArithNegate:
  if (node->child1().useKind() == Int32Use)
    def(PureValue(node));  // ← ArithMode NOT included
```

This meant CSE could substitute a **checked** `ArithNegate` with an **unchecked** one — silently discarding the overflow check. [youtube](https://www.youtube.com/watch?v=-A65idB2D84)

### Triggering the Bug

The key insight: negating `INT_MIN` (\(-2147483648\)) causes integer overflow because \(2147483648\) is not representable as a 32-bit signed integer. A **checked** negation would detect this and bail out; an **unchecked** one silently produces `INT_MIN` again. [youtube](https://www.youtube.com/watch?v=-A65idB2D84)

The PoC constructs two negations of the same value — one unchecked, one checked — so CSE incorrectly merges them:

```javascript
function hax(arr, n) {
  n |= 0;                    // Force 32-bit integer
  if (n < 0) {                // Range analysis: n is negative
    let v = (-n) | 0;         // Unchecked ArithNegate (output only feeds bitwise OR)
    let i = Math.abs(n);      // → ArithAbs → strength-reduced to checked ArithNegate
    if (i < arr.length) {     // Bounds check elimination: i is "proven" in [0, arr.length)
      if (i & 0x80000000) {   // i has bit 31 set (it's INT_MIN)
        i += -0x7ffffff9;     // Wraps INT_MIN to a small positive number
      }
      if (i > 0) {            // Re-proves i > 0 for bounds check elimination
        arr[i] = 1.04380972981885e-310;  // OOB write
      }
    }
  }
}
```

Here is what happens during compilation: [youtube](https://www.youtube.com/watch?v=-A65idB2D84)

1. `(-n) | 0` produces an **unchecked** `ArithNegate` — the compiler omits the overflow check because the result only feeds a bitwise OR, which behaves identically for the overflowed value.
2. `Math.abs(n)` is lowered to `ArithAbs`, then `IntegerRangeOptimization` strength-reduces it to a **checked** `ArithNegate` (since \(n < 0\), `abs(n) = -n`, and INT_MIN can't be ruled out).
3. **CSE** sees two `ArithNegate` operations on the same input with identical `PureValue` (due to the bug) and **substitutes** the checked one with the unchecked one.
4. `IntegerRangeOptimization` records that \(i \geq 0\) (because `Math.abs` returns non-negative), then proves \(i < \text{arr.length}\) from the explicit comparison, and **eliminates the bounds check** (`CheckInBounds` node).

### The Runtime Exploit

When the function is called with \(n = \text{INT_MIN}\) after JIT compilation: [youtube](https://www.youtube.com/watch?v=-A65idB2D84)

1. The unchecked negation silently wraps: \(i = -\text{INT_MIN} = \text{INT_MIN} = -2147483648\)
2. `IntegerRangeOptimization` still believes \(i \in [0, \text{arr.length})\) — the bounds check was eliminated
3. The conditional `i & 0x80000000` is true (bit 31 is set), so `i += -0x7ffffff9` overflows INT_MIN to a small positive index (e.g., 7)
4. `arr [projectzero](https://projectzero.google/2020/09/jitsploitation-one.html)` writes past the array — but the bounds check was removed, so no crash occurs; instead, the write corrupts the header of the **next** JSArray in heap memory

The value written (`1.04380972981885e-310`) is the IEEE 754 representation of `0x0000133700001337`, which overwrites the length and capacity fields of the adjacent array to `0x1337`. [youtube](https://www.youtube.com/watch?v=-A65idB2D84)

### From Corruption to Code Execution

The corrupted array length grants an **arbitrary out-of-bounds read/write** primitive. By overlapping a doubles array (`float_arr`) with a boxed-objects array (`obj_arr`), the attacker builds two classic primitives: [youtube](https://www.youtube.com/watch?v=-A65idB2D84)

```javascript
function addrof(obj) {
  obj_arr[0] = obj;              // Store object pointer
  return float_arr[OVERLAP_IDX]; // Read it as a raw double → leak address
}

function fakeobj(addr) {
  float_arr[OVERLAP_IDX] = addr; // Write raw address
  return obj_arr[0];              // Read it back as a fake object
}
```

These break heap ASLR and allow injecting **fake objects** into the engine — the foundation for arbitrary code execution within the renderer. [youtube](https://www.youtube.com/watch?v=-A65idB2D84)

### The Fix

The patch was one line: [youtube](https://www.youtube.com/watch?v=-A65idB2D84)

```diff
- def(PureValue(node));
+ def(PureValue(node, node->arithMode()));
```

## A Second Example: CVE-2020-26950 in SpiderMonkey

In Firefox's IonMonkey JIT, the `MCallGetProperty` opcode was emitted under circumstances where its **underlying assumptions were not met** — specifically, when a property getter had **write side effects** that invalidated the JIT's cached assumptions about object layout. The compiler emitted native code that accessed memory after it had been freed, creating a **use-after-free** condition exploitable for arbitrary code execution via a malicious web page. [sentinelone](https://www.sentinelone.com/vulnerability-database/cve-2020-26950/)

## The General Pattern

Both bugs follow the same structure that Samuel Groß identified: [zdnet](https://www.zdnet.com/article/bugs-in-chromes-javascript-engine-can-lead-to-powerful-exploits-this-project-aims-to-stop-them/)

> Many V8 vulnerabilities exploited by real-world attackers are effectively **2nd order vulnerabilities**: the root cause is a **logic issue** in the JIT compiler, which is then exploited to generate **vulnerable machine code** (e.g., code missing a runtime safety check). The generated code can then in turn be exploited to cause **memory corruption** at runtime.

The chain is: **optimization logic bug** → **incorrect native code emission** (missing check, wrong type assumption, or eliminated guard) → **runtime memory corruption** (OOB, UAF, or type confusion) → **exploit primitive** (addrof/fakeobj, arbitrary R/W) → **code execution**. [zdnet](https://www.zdnet.com/article/bugs-in-chromes-javascript-engine-can-lead-to-powerful-exploits-this-project-aims-to-stop-them/)

This is why JIT bugs are so persistent: the vulnerability is not in the native code itself but in the **compiler's reasoning** about whether that native code is safe to emit — a fundamentally harder problem to test, fuzz, and verify. [youtube](https://www.youtube.com/watch?v=-A65idB2D84)
