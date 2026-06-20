
Now I have a comprehensive picture. Let me compile everything into a thorough response.

## WebAssembly in Firefox: Source Code, APIs, and Test Cases

The [dev-platform thread `8cOxM-dWaNs`](https://groups.google.com/a/mozilla.org/g/dev-platform/c/8cOxM-dWaNs) is the **"Intent to ship: WebAssembly JS Promise Integration (JSPI)"** announcement, closely related to the earlier [Intent to Prototype thread](https://groups.google.com/a/mozilla.org/g/dev-platform/c/r0JfIYxym6Q) which describes JSPI as allowing synchronous WebAssembly code to use async Web APIs via stack suspension. JSPI was standardized by the W3C WebAssembly CG in April 2025 and is now shipping in both Chrome and Firefox. The feature pref is `javascript.options.wasm_js_promise_integration`. [bugzilla.mozilla](https://bugzilla.mozilla.org/show_bug.cgi?id=1966549)

***

## Core WebAssembly Source Tree

All WebAssembly engine code in Firefox/SpiderMonkey lives under [`js/src/wasm/`](https://github.com/mozilla-firefox/firefox/tree/main/js/src/wasm) in the [`mozilla-firefox/firefox`](https://github.com/mozilla-firefox/firefox) repository . The directory contains ~70 files. Below is a structured breakdown:

### Compilation Pipeline

| File | Role |
|------|------|
| [`WasmCompile.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmCompile.cpp) | Top-level compilation entry point; dispatches to baseline or Ion  |
| [`WasmBaselineCompile.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmBaselineCompile.cpp) | Baseline (Liftoff-style) one-pass compiler — ~415KB, largest single source file  |
| [`WasmIonCompile.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmIonCompile.cpp) | IonMonkey optimising compiler backend — ~383KB  |
| [`WasmGenerator.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmGenerator.cpp) | Module-level codegen coordinator  |
| [`WasmOpIter.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmOpIter.cpp) | Instruction validation/iteration (OpIter) — `.h` is ~150KB  |
| [`WasmValidate.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmValidate.cpp) | Module/function-body validator (~203KB)  |
| [`WasmStubs.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmStubs.cpp) | JIT entry/exit stubs, trampoline code (~136KB)  |
| [`WasmBuiltins.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmBuiltins.cpp) | Built-in function call helpers (~91KB)  |

### Runtime / Instance

| File | Role |
|------|------|
| [`WasmInstance.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmInstance.cpp) | Module instance execution and call dispatch (~166KB)  |
| [`WasmJS.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmJS.cpp) | The JS-facing WebAssembly API (`WebAssembly.*`) — ~194KB, the main JS API layer  |
| [`WasmModule.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmModule.cpp) | Serializable module object; caching  |
| [`WasmCode.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmCode.cpp) | Executable code ownership, code segments  |
| [`WasmMemory.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmMemory.cpp) | Linear memory management  |
| [`WasmTable.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmTable.cpp) | Table object implementation  |
| [`WasmSignalHandlers.cpp`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmSignalHandlers.cpp) | SIGSEGV/trap signal handling for OOB access  |
| [`WasmValue.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmValue.cpp) | Val type boxing/unboxing  |

### Type System & Binary

| File | Role |
|------|------|
| [`WasmTypeDef.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmTypeDef.h) | Struct/array type definitions (GC proposal support) — `.h` ~57KB  |
| [`WasmValType.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmValType.h) | Wasm value type representations  |
| [`WasmBinary.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmBinary.h) | Binary format decoding primitives  |
| [`WasmConstants.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmConstants.h) | Opcode enumerations, section IDs, limits  |
| [`WasmCodegenTypes.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmCodegenTypes.h) | IR types used throughout codegen (~62KB)  |

### GC, Stack & Debugging

| File | Role |
|------|------|
| [`WasmGC.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmGC.cpp) | Frame scanning and GC rooting for wasm frames  |
| [`WasmGcObject.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmGcObject.h) | GC-managed struct/array heap objects  |
| [`WasmStacks.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmStacks.cpp) | Suspendable stack infrastructure for JSPI (~75KB)  |
| [`WasmFrameIter.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmFrameIter.cpp) | Stack frame iterator for unwinding and stack traces (~97KB)  |
| [`WasmDebug.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmDebug.cpp) | Debugger integration (breakpoints, stepping)  |
| [`WasmComponent.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmComponent.h) | Component Model support (~30KB)  |
| [`WasmBuiltinModule.cpp`/`.yaml`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmBuiltinModule.yaml) | Built-in module definitions (YAML-driven codegen)  |

### AsmJS Legacy

[`AsmJS.cpp`/`.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/AsmJS.cpp) — Backward-compatible asm.js → wasm translator (~217KB, the single largest file) .

***

## JS Promise Integration (JSPI) API Functions

The JSPI implementation is split across two files, gated by `#ifdef ENABLE_WASM_JSPI`:

### [`js/src/wasm/WasmPI.h`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmPI.h) — Public API Surface

These are the key exported C++ functions declared in the header (all under `namespace js::wasm`): [developer.mozilla](https://developer.mozilla.org/en-US/docs/WebAssembly)

```cpp
// Stack execution control
bool CallOnMainStack(JSContext* cx, CallOnMainStackFn fn, void* data);

// Suspending function wrapper: wraps an async JS function so it can be
// called from a suspendable wasm stack and yield a Promise
JSFunction* WasmSuspendingFunctionCreate(JSContext* cx, HandleObject func,
                                          wasm::ValTypeVector&& params,
                                          wasm::ValTypeVector&& results);
JSFunction* WasmSuspendingFunctionCreate(JSContext* cx, HandleObject func,
                                          const FuncType& type);

// Promising function wrapper: wraps a wasm export so its return value is a
// Promise, enabling async callers
JSFunction* WasmPromisingFunctionCreate(JSContext* cx, HandleObject func,
                                         wasm::ValTypeVector&& params,
                                         wasm::ValTypeVector&& results);

// Suspender lifecycle
SuspenderObject* CurrentSuspender(Instance* instance, int reserved);
SuspenderObject* CreateSuspender(Instance* instance, int reserved);

// Promise plumbing
PromiseObject* CreatePromisingPromise(Instance* instance,
                                      SuspenderObject* suspender);
JSObject* GetSuspendingPromiseResult(Instance* instance, void* result,
                                     SuspenderObject* suspender);
void* AddPromiseReactions(Instance* instance, SuspenderObject* suspender,
                           void* result, JSFunction* continueOnSuspendable);
void* ForwardExceptionToSuspended(Instance* instance,
                                   SuspenderObject* suspender,
                                   void* exception);

// Result settlement and state management
int32_t SetPromisingPromiseResults(Instance* instance,
                                   SuspenderObject* suspender,
                                   WasmStructObject* results);
void UpdateSuspenderState(Instance* instance, SuspenderObject* suspender,
                          UpdateSuspenderStateAction action);
```

### [`js/src/wasm/WasmPI.cpp`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmPI.cpp) — Implementation (~48KB)

The implementation contains the `SuspenderObject` class (a `NativeObject`), `SuspenderObjectData` with raw stack pointer fields, and `SuspenderContext` which owns the doubly-linked list of suspended stacks. Key internal state transitions on `SuspenderObject` are: [developer.mozilla](https://developer.mozilla.org/en-US/docs/WebAssembly)

- `enter(cx)` — switches from Initial → Active, sets the active suspender on context
- `suspend(cx)` — switches Active → Suspended, parks the stack in `suspendedStacks_`
- `resume(cx)` — wakes a Suspended stack, swaps back SP/FP registers
- `leave(cx)` — teardown when the promising function returns
- `forwardToSuspendable()` — injects the parked stack back into the JIT activation chain

Platform-specific simulator switches (`switchSimulatorToMain`/`switchSimulatorToSuspendable`) are implemented for ARM64, ARM32, and RISCV64 simulators. [developer.mozilla](https://developer.mozilla.org/en-US/docs/WebAssembly)

### [`js/src/wasm/WasmJS.cpp`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/wasm/WasmJS.cpp) — JS API (~194KB)

This is where the `WebAssembly` global object and all its constructors/methods are exposed:
- `WebAssembly.Module`, `.Instance`, `.Memory`, `.Table`, `.Global`, `.Tag`, `.Exception`
- `WebAssembly.compile()`, `WebAssembly.compileStreaming()` (async)
- `WebAssembly.instantiate()`, `WebAssembly.instantiateStreaming()` (async)
- `WebAssembly.validate()`
- **`WebAssembly.promising(fn)`** — wraps a wasm export to return a Promise
- **`new WebAssembly.Suspending(fn)`** — wraps an async JS function for use as a suspending import 

***

## Test Cases: Async and Synchronous JSPI

### SpiderMonkey JIT Tests (`js/src/jit-test/tests/wasm/js-promise-integration/`)

These are shell-level tests run with `./mach jit-test` and require the `javascript.options.wasm_js_promise_integration` pref. The directory contains 38 test files : [firefox-source-docs.mozilla](https://firefox-source-docs.mozilla.org/js/test.html)

| File | What it tests |
|------|--------------|
| [`simple.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/simple.js) | Basic round-trip: `Suspending` import → `promising` export |
| [`js-promise-integration.new.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/js-promise-integration.new.js) | Comprehensive integration tests — 17KB, the primary spec-coverage file  |
| [`basic2.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/basic2.js) | Extended basic scenarios |
| [`concurrent.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/concurrent.js) | Multiple simultaneous suspenders |
| [`many-outstanding.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/many-outstanding.js) | Many unresolved promises in flight at once |
| [`multiple-suspending.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/multiple-suspending.js) | Multiple suspending imports within one module |
| [`multivalue.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/multivalue.js) | Multi-value return types across the boundary |
| [`types.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/types.js) | Type checking and validation |
| [`exception-handling.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/exception-handling.js) | Exception propagation across stack switches |
| [`sync-throw.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/sync-throw.js) | Synchronous throw within a promising call |
| [`error-stack.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/error-stack.js) | Stack trace accuracy after suspension |
| [`thenable.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/thenable.js) | Thenable (non-native Promise) objects as return values |
| [`timeout.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/timeout.js) | Delayed resolution via `setTimeout`-style microtask |
| [`recursive-promising.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/recursive-promising.js) | Nested/recursive promising calls |
| [`cross-realm.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/cross-realm.js) | Cross-realm (multiple global) behaviour |
| [`proxy.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/proxy.js) | JS Proxy objects as suspending callables |
| [`gc.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/gc.js) | GC correctness while stacks are suspended |
| [`gc-2.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/gc-2.js) / [`gc-3.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/gc-3.js) / [`gc-4.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/gc-4.js) | Further GC edge cases |
| [`gc-barrier.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/gc-barrier.js) | Write barrier correctness on suspended stacks |
| [`gc-update-data-pointers.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/gc-update-data-pointers.js) | Tenuring/moving GC pointer updates |
| [`saved-stacks.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/saved-stacks.js) | `Error.captureStackTrace` interaction |
| [`debug.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/debug.js) | Debugger API with JSPI |
| [`debug-mixed-frames.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/debug-mixed-frames.js) | Mixed JS+wasm frames in debugger |
| [`debug-onStep-suspended.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/debug-onStep-suspended.js) | Debugger stepping across suspension points |
| [`debug-stale-cont-frame.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/debug-stale-cont-frame.js) | Stale continuation frame safety |
| [`debug-frame-offset-non-debug.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/debug-frame-offset-non-debug.js) | Debug-mode frame offsets in non-debug builds |
| [`jitexit.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/jitexit.js) | JIT-exit code paths during suspension |
| [`jitexit-profiler.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/jitexit-profiler.js) | Profiler frame validity at JIT exits |
| [`basic-profiler-1.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/basic-profiler-1.js) / [`basic-profiler-2.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/basic-profiler-2.js) | Profiler stack sampling correctness |
| [`suspender.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/suspender.js) | SuspenderObject lifetime and state machine |
| [`guard-suspending.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/guard-suspending.js) | Guards against calling suspending import off a main stack |
| [`suspending-canonical-type.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/suspending-canonical-type.js) | Canonical type identity for Suspending wrappers |
| [`promising-nonfinal-type.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/promising-nonfinal-type.js) | Non-final (subtype) result types on promising |
| [`multi.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/multi.js) | Multi-module JSPI interactions |
| [`stress.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/stress.js) | Rapid repeated suspension/resumption cycles |
| [`shutdown.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/shutdown.js) | Clean teardown with outstanding suspenders |
| [`oom-1.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/oom-1.js) / [`oom-2.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/oom-2.js) | OOM handling during stack allocation |
| [`bug2043040.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/js-promise-integration/bug2043040.js) | Regression test for Bug 2043040 |
| `no-directives/` subdirectory | Tests that must run without JSPI-enabling directives (negative tests) |

### Web Platform Tests (WPT) — `testing/web-platform/tests/wasm/jsapi/jspi/`

These are the cross-browser interop tests tracked at [wpt.fyi/results/wasm/jsapi/jspi](https://wpt.fyi/results/wasm/jsapi/jspi)  : [groups.google](https://groups.google.com/a/mozilla.org/g/dev-platform/c/r0JfIYxym6Q)

| File | Description |
|------|-------------|
| [`js-promise-integration.any.js`](https://github.com/mozilla-firefox/firefox/blob/main/testing/web-platform/tests/wasm/jsapi/jspi/js-promise-integration.any.js) | ~11KB; primary cross-browser async JSPI API tests (runs in Window, Worker, ServiceWorker) |
| [`rejects.any.js`](https://github.com/mozilla-firefox/firefox/blob/main/testing/web-platform/tests/wasm/jsapi/jspi/rejects.any.js) | Async rejection paths — Promise rejection propagation into wasm |
| [`notraps.any.js`](https://github.com/mozilla-firefox/firefox/blob/main/testing/web-platform/tests/wasm/jsapi/jspi/notraps.any.js) | Async paths that must not produce wasm traps |
| [`testharness-additions.js`](https://github.com/mozilla-firefox/firefox/blob/main/testing/web-platform/tests/wasm/jsapi/jspi/testharness-additions.js) | Shared test helpers (e.g., `promise_test` wrappers for JSPI) |
| `README.txt` | Points to the upstream WPT repo |

The `.any.js` suffix means these tests execute in all global scopes (Window, dedicated Worker, shared Worker, ServiceWorker), covering the full async runtime environment. [groups.google](https://groups.google.com/a/mozilla.org/g/dev-platform/c/8YQ-YKantdk)

### Other Async-Related Wasm Tests

- [`js/src/jit-test/tests/wasm/async-instantiate.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/async-instantiate.js) — Tests `WebAssembly.instantiateStreaming()` and `WebAssembly.compileStreaming()` async paths [searchfox](https://searchfox.org/firefox-main/source/js/src/wasm)
- [`js/src/jit-test/tests/wasm/streaming.js`](https://github.com/mozilla-firefox/firefox/blob/main/js/src/jit-test/tests/wasm/streaming.js) — Streaming compilation API
- [`js/src/jit-test/tests/wasm/stack-switching/`](https://searchfox.org/firefox-main/source/js/src/jit-test/tests/wasm/stack-switching) — Stack-switching proposal tests (related but distinct from JSPI) [searchfox](https://searchfox.org/firefox-main/source/js/src/jit-test/tests/wasm/spec)
- [`js/src/jit-test/tests/wasm/spec/stack-switching/`](https://searchfox.org/firefox-main/source/js/src/jit-test/tests/wasm/spec/stack-switching) — Shared Wasm CG spec tests for stack switching [searchfox](https://searchfox.org/firefox-main/source/js/src/jit-test/tests/wasm/spec)

***

## How to Enable and Run

Enable the pref for local testing:

```js
// about:config
javascript.options.wasm_js_promise_integration = true
```

Run all JSPI jit-tests:
```bash
./mach jit-test js/src/jit-test/tests/wasm/js-promise-integration
```

Run WPT JSPI tests:
```bash
./mach web-platform-tests wasm/jsapi/jspi
```
