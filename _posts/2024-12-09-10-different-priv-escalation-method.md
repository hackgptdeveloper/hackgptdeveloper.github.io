---
title: "List of linux privilege escalation methods"
tags:
  - PrivEscalation
---

List of Linux privilege escalation vulnerabilities with available Proof-of-Concepts (POCs) from 2019 to 2024:

---

1. **CVE-2019-14287**: Sudo vulnerability allowing a user to run commands as root by specifying the UID as -1. Exploit and details available on GitHub.

https://github.com/lrh2000/StackRot

2. **CVE-2020-8835**: A flaw in Linux's kernel `overlayfs` file system allows privilege escalation. POC available on GitHub.

3. **CVE-2021-4034** ("PwnKit"): Exploits `pkexec` in Polkit for root access. Widely documented with POCs available.

4. **CVE-2022-0847** ("Dirty Pipe"): Exploits a flaw in the Linux pipe subsystem introduced in kernel 5.8. POC widely available.

5. **CVE-2022-34918**: A flaw in the Netfilter subsystem. It can be exploited for local privilege escalation on Linux kernels 5.17 to 5.19. POC provided in GitHub repositories.

6. **CVE-2023-2640** and **CVE-2023-32629**: Vulnerabilities affecting Ubuntu and Kali Linux environments. POCs and exploitation scripts are available.

7. **CVE-2024-1086**: Universal privilege escalation exploit affecting Linux kernels 5.14 to 6.6. Detailed POC and write-up available.

8. **CVE-2020-14386**: Exploits an issue in the Linux kernel’s user namespaces allowing privilege escalation. Exploit scripts can be found on GitHub.

9. **CVE-2019-15666**: A vulnerability in the `rds` kernel module allows local users to escalate privileges. Exploit details and POC are available.

10. **CVE-2023-30829**: Related to a vulnerability in the Ubuntu kernel, enabling unauthorized privilege escalation. POC available.

---

[Linux Privilege Escalation methods](https://github.com/topics/linux-privilege-escalation) 
