---
title: "Linux user space rootkit technologies"
tags:
  - Rootkits
---

***Linux user space rootkit technologies***

1. **[Medusa](https://github.com/ldpreload/Medusa)**  
   A runtime process-hiding tool using the `LD_PRELOAD` technique to intercept and manipulate libc functions for stealth purposes.

2. **[DDexec](https://github.com/arget13/DDexec)**  
   A proof of concept demonstrating the execution of ELF binaries from memory without storing them on disk, bypassing traditional detection methods.

3. **[Father](https://github.com/mav8557/Father)**  
   A user-space rootkit using `LD_PRELOAD` to hook and manipulate system calls, focusing on stealth and hiding files or processes.

4. **[zpoline](https://github.com/yasukata/zpoline)**  
   A fast, lightweight x86 syscall dispatcher designed for high-performance syscall interception and manipulation in kernel or user space.

5. **[zombieant](https://github.com/dsnezhkov/zombieant)**  
   A post-exploitation tool for container environments that injects itself into running processes to hijack and manipulate container behavior.

6. **[SHELF-Loading](https://github.com/ulexec/SHELF-Loading)**  
   A loader for executing shared libraries in memory, avoiding on-disk traces and enabling stealthy execution of payloads.

7. **[Jynx2](https://github.com/chokepoint/Jynx2)**  
   A backdoor/rootkit designed to intercept and manipulate shared library functions using `LD_PRELOAD` to maintain persistence and hide processes or files.

8. **[beurk](https://github.com/unix-thrust/beurk)**  
   A simple and modular Linux userland rootkit using `LD_PRELOAD` to hide files, processes, and network activity while enabling backdoor access.

9. **[brootkit](https://github.com/cloudsec/brootkit)**  
   A lightweight Linux kernel rootkit designed to demonstrate techniques for hiding processes, files, and achieving stealth.

10. **[adore-ng](https://github.com/trimpsyw/adore-ng)**  
    A kernel-based rootkit that enables file, process, and module hiding, as well as remote root access through hidden backdoors.

11. **[libpreload](https://github.com/rvillordo/libpreload)**  
    A library for testing and demonstrating how dynamic linking and `LD_PRELOAD` can be used to hook and manipulate libc functions.

12. **[HORSEPILL](https://github.com/r00tkillah/HORSEPILL)**  
    A hypervisor-level rootkit designed for Linux KVM/QEMU environments, capable of evading guest operating system detection.

13. **[skeksi_virus](https://github.com/elfmaster/skeksi_virus)**  
    A kernel virus/rootkit that infects the Linux kernel using ELF infection techniques for process hiding and privilege escalation.

14. **[linker_preloading_virus](https://github.com/elfmaster/linker_preloading_virus)**  
    Demonstrates how malicious payloads can be injected via linker preloading mechanisms to subvert program execution.

15. **[rkorova](https://github.com/nopn0p/rkorova)**  
    A modular rootkit focusing on stealth and process-hiding capabilities, designed for advanced persistence in compromised systems.

16. **[Tcpdump-evasion](https://github.com/amir9339/Tcpdump-evasion)**  
    A tool that implements techniques to evade detection by tcpdump and other packet capture utilities during network operations.

17. **[PHP-Backdoor](https://github.com/Paradoxis/PHP-Backdoor)**  
    A minimal PHP-based backdoor for web applications, allowing command execution and file manipulation on compromised servers.

18. **[mandibule](https://github.com/ixty/mandibule)**  
    A technique for injecting shared libraries into running processes to execute malicious code stealthily.

19. **[dlinject](https://github.com/DavidBuchanan314/dlinject)**  
    A tool for injecting shared objects into running processes on Linux, leveraging `ptrace` for process manipulation.

20. **[memrun](https://github.com/guitmz/memrun)**  
    A utility to execute ELF binaries directly from memory, bypassing traditional storage and execution mechanisms for enhanced stealth.
