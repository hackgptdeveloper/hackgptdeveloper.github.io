Here are text-based graphical illustrations and structured layouts designed to be integrated directly into your `type_confusion.md` file to maximize readability and clarify the memory alignment.

---

## 📊 Visualizing the Memory Overlap (Phase 2 & Root Cause)

When the application allocates a `SafeWidget`, memory is laid out sequentially. However, because `handle()` casts this memory space directly to a `PrivWidget*`, the CPU reinterprets those same exact bytes.

The diagram below illustrates how `SafeWidget::name` maps perfectly to the pointers in `PrivWidget`:

```text
                  SAFEWIDGET AS ALLOCATED               PRIVWIDGET AS INTERPRETED
               +---------------------------+         +---------------------------+
Bytes 00-07    |       vptr (8 bytes)      |  ====>  |       vptr (8 bytes)      |
               +---------------------------+         +---------------------------+
Bytes 08-11    |       kind = 1 (int)      |  ====>  |       kind = 1 (int)      |
               +---------------------------+         +---------------------------+
Bytes 12-15    |       pad = 0 (int)       |  ====>  |       pad = 0 (int)       |
               +---------------------------+         +---------------------------+
Bytes 16-23    | [0]                       |         |                           |
               | [1]  Attacker Injection   |         |        secret_ptr         |
               | ...  (&g_secret)          |  ====>  |    (Points to Flag!)      |
               | [7]                       |         |                           |
               +---------------------------+         +---------------------------+
Bytes 24-31    | [8]                       |         |                           |
               | [9]  Attacker Injection   |         |         callback          |
               | ...  (&win)               |  ====>  |   (Points to win())       |
               | [15]                      |         |                           |
               +---------------------------+         +---------------------------+
Bytes 32-47    | [16]...[31] Remaining Buffer|        |       (Out of bounds      |
               +---------------------------+         |        for PrivWidget)    |
                                                     +---------------------------+

```

---

## 🔄 The Confused Cast Trigger Flow (Phase 3)

The pipeline below tracks how execution shifts step-by-step from data ingestion to arbitrary read and code redirection during the `SHOW 0` command execution:

```text
       [ STEP 1: INGESTION ]
       Attacker sends ADD SAFE HEX command with crafted payload
                                |
                                v
       [ STEP 2: ALLOCATION ]
       Heap object created as SafeWidget (kind=1)
       name[0..7]  = 0x5cdf40a98008 (&g_secret)
       name[8..15] = 0x5cdf40a962f9 (&win)
                                |
                                v
       [ STEP 3: THE CONFUSED CAST ]
       static_cast<PrivWidget*>(w) forces the compiler to trust the type
                                |
                                +-----------------------------+
                                |                             |
                                v                             v
                  [ PRIMITIVE A: ARBITRARY READ ]    [ PRIMITIVE B: CONTROL HIJACK ]
                   Dereferences p->secret_ptr         Executes p->callback()
                                |                             |
                                v                             v
                   Reads address 0x5cdf40a98008       Jumps execution to 0x5cdf40a962f9
                                |                             |
                                v                             v
                   Prints: "FLAG{type_...}"           Enters win() -> Code executed!

```

---

## 🔍 Offset Alignment Quick-Reference

This table maps the exact runtime values captured in your exploit log against the variables they impersonate:

| Offset (Bytes) | Field Source (`SafeWidget`) | Reinterpreted Target (`PrivWidget`) | Injected Exploitation Value | Resolution Effect |
| --- | --- | --- | --- | --- |
| `+00` to `+07` | `vptr` | `vptr` | Valid Virtual Table | Normal object handling |
| `+08` to `+11` | `kind` (`1`) | `kind` | `0x00000001` | Fails logical checking if validated |
| `+16` to `+23` | `name[0..7]` | `secret_ptr` | `0x5cdf40a98008` | Leaks flag memory contents |
| `+24` to `+31` | `name[8..15]` | `callback` | `0x5cdf40a962f9` | Forces jump to `win()` function |
