---
title: "100 ways to achieve privilege escalation in Linux"
tags:
  - PrivilegeEscalation
---

100 ways to achieve privilege escalation in Linux

Privilege escalation in a Linux environment can be achieved through a variety of methods, often depending on misconfigurations, vulnerabilities, or unintended behaviors in the system. Here’s a list of **100 potential ways** to escalate privileges from a non-root user to a root user. These are categorized into common areas like misconfigurations, vulnerabilities, binaries, and kernel exploits.

---

### **1-20: Misconfigurations**
1. World-writable files in sensitive directories like `/etc/`.
2. Misconfigured `sudo` privileges allowing execution of unintended binaries.
3. Misconfigured `setuid` binaries owned by root.
4. Writable `/etc/passwd` or `/etc/shadow`.
5. Writable `/etc/sudoers` or `/etc/sudoers.d/`.
6. Cron jobs running as root with writable scripts.
7. Writable `/var/spool/cron/` directory.
8. Root-owned files with improper ACL permissions.
9. Sticky-bit misconfigurations on sensitive directories.
10. Writable scripts executed by services running as root.
11. SSH keys in `/root/.ssh/` with world-readable permissions.
12. World-writable `/var/log/` files.
13. Incorrect permissions on kernel module files.
14. Improper permissions on shared libraries.
15. Misconfigured `capabilities` (e.g., binaries with `CAP_SYS_ADMIN`).
16. NFS exports with `no_root_squash` enabled.
17. Improper mount options (`exec` in `/tmp` or `/home`).
18. User writable `/dev` devices.
19. Writable `LD_PRELOAD` directories.
20. `docker` group membership allowing root-level access.

---

### **21-40: Exploitable Binaries**
21. Exploiting `vi`/`vim` through `sudo` with improper configurations.
22. Exploiting `less` when invoked with `sudo`.
23. Using `awk` to escalate privileges via `sudo`.
24. Using `python` to execute arbitrary code with `sudo`.
25. Exploiting `tar` with `sudo` for arbitrary file writes.
26. Using `find` with `sudo` to execute arbitrary commands.
27. Exploiting `bash` with `sudo` to open a root shell.
28. Using `perl` to execute code with `sudo`.
29. Exploiting `rsync` with root permissions.
30. Using `cp` to overwrite critical files with `sudo`.
31. Exploiting `git` when configured with root access.
32. Using `scp` to overwrite files via `sudo`.
33. Leveraging `zip` or `unzip` for privilege escalation.
34. Exploiting `mysql` to gain code execution.
35. Using `vim` temporary files to escalate privileges.
36. Exploiting `journalctl` with improper configurations.
37. Using `env` with `sudo` for privilege escalation.
38. Misusing `screen` if running with setuid or sudo.
39. Exploiting `tmux` session misconfigurations.
40. Using `node.js` or `node` in `sudo` context.

---

### **41-60: Kernel and Software Vulnerabilities**
41. Exploiting `Dirty COW` (CVE-2016-5195).
42. Exploiting `OverlayFS` vulnerabilities (e.g., CVE-2021-3493).
43. Exploiting `polkit` vulnerabilities (e.g., CVE-2021-4034).
44. Exploiting vulnerable `sudo` versions (e.g., CVE-2019-14287).
45. Exploiting `systemd` vulnerabilities.
46. Exploiting `ptrace` to attach to a privileged process.
47. Exploiting vulnerable `X11` configurations.
48. Exploiting `SELinux` bypass vulnerabilities.
49. Exploiting vulnerable kernel versions (e.g., buffer overflows).
50. Exploiting `glibc` vulnerabilities.
51. Exploiting `snapd` vulnerabilities.
52. Exploiting `Apache` misconfigurations or vulnerabilities.
53. Leveraging `CVE-2018-14665` (Xorg exploit).
54. Exploiting SSH agent forwarding vulnerabilities.
55. Exploiting container breakout vulnerabilities.
56. Using `overlay` mount escape in containers.
57. Kernel module exploits like `RDS` (CVE-2010-3904).
58. Leveraging `cron` race conditions.
59. Exploiting `chroot` escapes.
60. Exploiting vulnerable applications with privilege escalation paths.

---

### **61-80: Abusing Services**
61. Exploiting vulnerable web applications.
62. Manipulating database services (e.g., MySQL, PostgreSQL).
63. Exploiting `openvpn` misconfigurations.
64. Leveraging misconfigured `rsync` services.
65. Exploiting `tftp` or `ftp` with root files.
66. Exploiting vulnerable SMB shares.
67. Using NFS shares with weak permissions.
68. Abusing `cups` (printing service) vulnerabilities.
69. Exploiting email services running as root.
70. Abusing `systemd` service file misconfigurations.
71. Exploiting `docker.sock` for container breakout.
72. Manipulating `kubernetes` configurations for root access.
73. Exploiting vulnerable `cron` jobs for root users.
74. Misconfigurations in `PHP` or web server modules.
75. Exploiting weak database passwords for services running as root.
76. Exploiting vulnerable or exposed admin interfaces.
77. Abusing `sudoedit` for file overwrite attacks.
78. Manipulating `journalctl` for command injection.
79. Leveraging `nmap` with root capabilities.
80. Exploiting misconfigured `rsyslog` service.

---

### **81-100: Advanced Techniques**
81. Kernel rootkits for privilege escalation.
82. Exploiting `/proc` pseudo-filesystem vulnerabilities.
83. Leveraging writable `LD_LIBRARY_PATH` for library injection.
84. Exploiting race conditions in system calls.
85. Using `ptrace` to hijack root processes.
86. Exploiting `/etc/environment` file manipulation.
87. Using `pivot_root` for privilege escalation.
88. Exploiting `cgroups` misconfigurations.
89. Leveraging `dbus` for privilege escalation.
90. Exploiting `/run` directory misconfigurations.
91. Manipulating PAM modules for root access.
92. Using fake binaries in `PATH` for privilege escalation.
93. Injecting malicious commands into `.bashrc` of root.
94. Exploiting writable `/boot/` directory.
95. Abusing `passwd` command with setuid.
96. Exploiting `init` system configurations.
97. Leveraging misconfigured network services (e.g., DHCP).
98. Exploiting legacy or abandoned software.
99. Using symbolic links to overwrite sensitive files.
100. Exploiting user-to-root trust relationships (e.g., SSH keys).

---

### **Final Notes**
- Always get permission before testing these techniques (penetration testing or ethical hacking).
- Many methods require specific preconditions like vulnerable software, misconfigurations, or inadequate permissions.
- Keeping your Linux system updated and configured properly can mitigate many of these risks.
