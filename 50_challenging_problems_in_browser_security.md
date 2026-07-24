By synthesizing two major systematization-of-knowledge papers (a 2021 Georgia Tech 10-year longitudinal study of browser bugs and mitigations, and a 2026 EPFL taxonomy mapping 2,233 memory-corruption vulnerabilities across Chrome, Firefox, and Safari), plus recent CVE data and industry threat reports, the following 50 can be compiled. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)

## Memory Safety & Exploitation Primitives

1. **JIT compiler code-generation correctness** — JIT optimization bugs in V8, SpiderMonkey, and JavaScriptCore emit native code with memory corruption; these remain the most exploited bug class since 2017. 
2. **Use-after-free elimination at scale** — UAF bugs dominate renderer exploitation; MiraclePtr/BackupRefPtr mitigates but does not eliminate the underlying defects. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
3. **Type confusion in optimized code paths** — Object shape transitions and type guard bypasses in JIT-compiled JavaScript remain exploitable despite type-check hardening. 
4. **Heap spray and heap layout manipulation** — Attackers manipulate heap layout to place controlled data at predictable addresses; isolated heaps and randomized allocation reduce but do not eliminate this. 
5. **Overwrite of RWX JIT code pages** — W^X enforcement and out-of-process JIT compilation mitigate, but JIT code region attacks remain relevant on platforms without hardware enforcement. 
6. **Vtable pointer corruption** — Virtual function table overwrites bypass CFG; VTGuard and PAC provide partial protection. 
6. **Stack-based control-flow hijacking** — Return address overwrites persist despite SafeSEH, SEHOP, and shadow stacks. 
7. **Integer overflow leading to heap corruption** — Size calculation errors in parsers and DOM operations remain a recurring source of memory corruption. 
8. **Uninitialized memory disclosure** — Uninitialized variables in renderer and network code leak sensitive data; mitigations are incomplete. 

## Sandbox Architecture & Escapes

9. **Renderer-to-browser sandbox escape via IPC** — Compromised renderers craft malicious Mojo/IPDL/XPC messages to corrupt higher-privilege processes; IPC receivers at 15–28% fuzzer coverage hold 61% of high-privilege bugs. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
10. **GPU process as sandbox escape vector** — The GPU process runs at moderate privilege with broad driver access; Firefox runs it unsandboxed on non-Windows OSes. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
11. **Kernel-level sandbox escape via syscalls** — Compromised processes issue restricted syscalls against the kernel directly, bypassing browser-process intermediaries entirely. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
12. **V8 sandbox escape** — Code execution within V8's internal sandbox must cross a second boundary to reach renderer memory; 73 confirmed escape reports exist. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
13. **Sandbox inconsistency across operating systems** — Each OS (Windows AppContainer, Linux seccomp/chroot, macOS sandbox profiles) offers different primitives, creating platform-specific gaps. 
14. **Mobile sandbox weakening** — Android Chrome disables site isolation below 1.9GB RAM; iOS Safari uses different sandbox rules, creating mobile-specific attack surfaces. 
15. **Sandbox policy file maintenance** — Sandbox profiles (`.sb` files, seccomp filters) are manually maintained and drift from actual requirements over time. 

## JavaScript & WebAssembly Engine Security

16. **JIT speculative optimization soundness** — Optimization passes make assumptions about type stability that can be violated by attacker-crafted code, producing incorrect native code. 
17. **WebAssembly sandbox integrity** — Wasm's linear memory model and host import interface create a new attack surface; Wasmtime had sandbox-escape CVEs in April 2026. [safeguard](https://safeguard.sh/resources/blog/webassembly-security-concerns-and-sandboxing)
18. **Wasm GC and new feature security** — WebAssembly garbage collection, exception handling, and relaxed SIMD shipped in 2023–2024 caused bug counts to jump from single digits to 37 in 2024. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
19. **addrof/fakeobj primitives across engines** — Cross-engine exploit primitives remain viable despite engine-specific hardening. 
20. **StructureID abuse in JavaScriptCore** — Safari's type-checking mechanism can be bypassed to achieve type confusion. 

## Web Platform API Security

21. **WebAPI binding memory corruption** — WebAPI bindings (WebGL, WebGPU, WebRTC, Canvas, WebAudio) produce 46% of bugs that escape the renderer, yet sit at 0.1–5.5% fuzzer coverage. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
22. **WebGPU out-of-bounds write to GPU memory** — CVE-2025-12725 demonstrated that improper bounds checking in WebGPU can corrupt GPU process memory, enabling sandbox escape. [securityonline](https://securityonline.info/chrome-emergency-fix-three-high-severity-flaws-in-webgpu-and-v8-engine-risk-rce/)
23. **WebGL/ANGLE backend under-coverage** — ANGLE (WebGL translator) achieves only 34% fuzzer coverage, and vendor shader compilers (DXC, closed-source) are entirely off the coverage dashboard. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
24. **Shader compiler injection** — Attacker-supplied GLSL/HLSL/WGSL shaders reach moderate-privilege GPU processes through shader translators; vendor compilers are often closed-source and untestable. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
25. **WebRTC media pipeline corruption** — WebRTC contributes significant bugs but achieves only 5.5% fuzzer coverage; the pipeline spans renderer, GPU, and network processes. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
26. **PDFium SDK boundary exploitation** — The fpdfsdk boundary sits at 9.7% coverage while generating 34 bugs; PDFium's JavaScript bridge is a specific attack target. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
27. **DOM manipulation race conditions** — Concurrent DOM operations create TOCTOU and race condition bugs that are difficult to reproduce and fuzz. 
28. **Origin check bypass (UXSS)** — Universal cross-site scripting bypasses same-origin policy through browser implementation bugs; site isolation mitigates but does not eliminate. 

## Input Parsing & Binary Blob Surfaces

29. **Third-party library parser vulnerabilities** — FreeType, HarfBuzz, libxml, expat, and image/video codecs are fully attacker-controlled and have long histories of memory corruption. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
30. **Hardware-accelerated video decoder attacks** — Video blobs are demuxed in the renderer but decoded in the GPU process, carrying attacker input to moderate privilege. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
31. **Network packet and TLS certificate parsing** — Raw bytes from malicious servers reach moderate-privilege network processes; Firefox's NSS runs in the high-privilege parent process. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
32. **Font parser exploitation** — Font parsing (FreeType, HarfBuzz) processes fully attacker-controlled bytes in the renderer sandbox; historical CVE density is high. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
33. **Image format parser bugs** — WebP (libwebp, 48% coverage), AVIF (libavif, 49%), and ICU (48%) parsers remain below 50% fuzzer coverage. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
34. **Device broker under-testing** — Bluetooth (1% coverage), WebHID (9%), and gdk-pixbuf (12%) device brokers are severely under-fuzzed despite handling privileged binary input. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)

## Transient Execution & Side Channels

35. **Spectre-based cross-origin memory reads via JavaScript** — Speculative execution attacks demonstrated reading arbitrary process memory via portable JavaScript; site isolation provides partial mitigation. [spectreattack](https://spectreattack.com/spectre.pdf)
36. **Cache timing side-channel attacks** — High-resolution timers (performance.now, SharedArrayBuffer) enable cache-based side channels; browsers degrade timer resolution but workarounds persist. [spectreattack](https://spectreattack.com/spectre.pdf)
37. **Hyperthread-based side channels** — SMT/hyperthreading creates microarchitectural side channels between co-located browser processes. [spectreattack](https://spectreattack.com/spectre.pdf)
38. **Speculative store bypass** — Variant 4 of Spectre allows speculative execution to read stale data; browser-level mitigations are incomplete. [spectreattack](https://spectreattack.com/spectre.pdf)

## IPC & Inter-Process Communication

39. **IPC receiver dispatch validation** — IPC dispatch targets (chrome/browser/ at 15.3%, content/browser/ at 27.7%) hold 75% of in-tree IPC bugs at high privilege, yet remain poorly covered. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
40. **IPC adapter vs. dispatch coverage inversion** — The well-fuzzed Mojo/IPDL adapter (55% coverage) accounts for only 7 bugs, while the under-covered dispatch targets hold 112 — a structural testing gap. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
41. **Compromised-renderer IPC crafting** — An attacker with renderer code execution can craft arbitrary IPC messages; every receiver must treat all incoming IPC as fully attacker-controlled, which is inconsistently enforced. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)

## Extension & Plugin Security

42. **Extension privilege escalation** — Chrome's three-step model (isolated worlds, privilege separation, declared permissions) is bypassed through insecure coding practices; nearly 50% of analyzed extensions request unused permissions. [pdfs.semanticscholar](https://pdfs.semanticscholar.org/57b3/9d1f6309b587bfeba7ab37fdb721a6bf1cbb.pdf)
43. **Content script injection attacks** — Content scripts operating on a DOM copy can still be exploited to execute in page context through insecure coding patterns. [pdfs.semanticscholar](https://pdfs.semanticscholar.org/57b3/9d1f6309b587bfeba7ab37fdb721a6bf1cbb.pdf)
44. **Extension HTTP request MitM** — At least 146 analyzed extensions load JavaScript over HTTP, enabling man-in-the-middle replacement with malicious code. [pdfs.semanticscholar](https://pdfs.semanticscholar.org/57b3/9d1f6309b587bfeba7ab37fdb721a6bf1cbb.pdf)
45. **Extension CSP bypass** — Despite 4,079 of 9,558 extensions using CSP, bypass techniques remain viable through insecure directive configurations. [pdfs.semanticscholar](https://pdfs.semanticscholar.org/57b3/9d1f6309b587bfeba7ab37fdb721a6bf1cbb.pdf)

## UI & Browser Process Security

46. **UI gesture-driven high-privilege corruption** — 99% of UI gesture bugs corrupt the high-privilege browser process directly; ~90% are UAF, and no dedicated UI fuzzer exists. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
47. **Browser process profile and cookie store exposure** — The browser process owns the cookie store, profile database, and navigation bar, making it the highest-value target for sandbox escapes. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
48. **DevTools WebUI internal page exploitation** — DevTools internal pages sit at 2.4% fuzzer coverage while generating 10 confirmed bugs; they run at high privilege. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)
49. **Platform integration toolkit attacks** — OS-specific UI toolkit code (//ui/) at 33.8% coverage generates 72 bugs, with platform-specific attack surfaces differing across Windows, macOS, and Linux. [qwe.edu](https://www.qwe.edu.pl/tutorial/claude-fable-jacobian-conjecture-tutorial/)

## Cryptographic & Protocol-Level Challenges

50. **Post-quantum TLS migration in browsers** — Browsers must adopt hybrid X25519+ML-KEM-768 for TLS without breaking compatibility with legacy servers; the migration deadline creates a transitional attack window. [beyondtmrw](https://beyondtmrw.org/article/post-quantum-tls-migration-browser-deadlines-and-enterprise-playbooks)

Several structural themes recur: the fundamental asymmetry between attacker (find one input path) and defender (cover all paths), the persistent dominance of memory corruption despite a decade of mitigations, the coverage gap between well-fuzzed adapters and under-fuzzed dispatch targets, and the continuous introduction of new attack surfaces through web platform feature expansion. The 2026 EPFL taxonomy's most actionable finding is that bug-dense, high-privilege surfaces — WebAPI bindings, WebGL backends, IPC receivers, and UI input paths — remain the most under-tested parts of the browser attack surface. 
