
Linux persistence is the set of mechanisms that let an intruder retain—or regain—execution or access after reboot, logout, service restart, credential changes, or partial remediation. In MITRE ATT&CK terms, it is the **Persistence** tactic (TA0003): maintaining a foothold rather than merely achieving initial code execution. [attack.mitre](https://attack.mitre.org/matrices/enterprise/linux/)

## Persistence surfaces

On Linux, persistence is distributed across several trust layers. A useful defender model is to ask: *what event causes code to execute, whose authority executes it, and what artifact controls that event?*

| Surface | Typical trigger | Security significance |
|---|---|---|
| `systemd` units/timers | Boot, target activation, timed event | The dominant modern server persistence surface; can execute as root and blend into normal service operations |
| Cron and at scheduling | Time-based execution or reboot | Common, simple, and sometimes overlooked, especially per-user crontabs and `/etc/cron.d/` |
| SSH configuration and keys | Remote authentication | A modified `authorized_keys` file can create durable passwordless access for a user |
| Accounts, groups, sudo policy | Login or privilege request | Persistence can be identity-based: new accounts, altered group memberships, or sudoers entries |
| Shell startup files | Interactive/noninteractive shell startup | Targets user context via `.bashrc`, `.profile`, `.zshrc`, etc.; less reliable for headless servers but valuable on developer/admin hosts |
| Legacy boot/logon scripts | Startup/login | SysV/RC scripts are still present on some systems; modifying them can start code during boot.  [attack.mitre](https://attack.mitre.org/techniques/T1037/004/) |
| Application/server configuration | Application restart or request | Web shells, plugin/module hooks, CI runners, container entrypoints, and database/job frameworks may persist outside conventional OS startup paths |
| Kernel/boot chain | Boot | Kernel modules, initramfs, bootloader, firmware, or package-manager compromise are high-impact and harder to remediate reliably |

## What attackers seek

Persistence is rarely just “run malware at boot.” An operator may prioritize one or more of these properties:

- **Durability:** Survives reboots, rotations, and service restarts.
- **Privilege:** Re-establishes access as root or a privileged service account.
- **Redundancy:** Uses multiple independent footholds—e.g., an SSH key plus a systemd timer—so deleting one does not evict them.
- **Blending:** Masquerades as a legitimate unit, account, package component, or application configuration.
- **Low interaction:** Reconnects or activates without a user logging in.
- **Operational resilience:** Lives in configuration management, container images, CI/CD, cloud-init, or orchestration state so it is redeployed after local cleanup.

This is why “I killed the suspicious process” is not incident recovery. The process is often only the current manifestation of a persisted execution path.

## High-value detection areas

A practical Linux hunting program should continuously baseline and alert on changes in these areas:

- **Systemd:** Review new or modified service, timer, path, socket, generator, and drop-in files; inspect enablement state, owners, permissions, and executable paths. Elastic specifically highlights hunting unusual `service`, `timer`, and `generator` file creation. [elastic](https://www.elastic.co/security-labs/primer-on-persistence-mechanisms)
- **Scheduled execution:** Monitor `/etc/crontab`, `/etc/cron.d/`, periodic cron directories, and each user’s crontab. Scheduled jobs are a recognized ATT&CK persistence family. [picussecurity](https://www.picussecurity.com/resource/scheduled-task/job-the-most-used-mitre-attck-persistence-technique)
- **Identity changes:** Alert on account creation, UID/GID changes, unexpected membership in privileged groups, changes under `/etc/sudoers` and `/etc/sudoers.d/`, and modifications to `/etc/passwd`, `/etc/shadow`, and `/etc/group`.
- **SSH trust:** File-integrity monitor `~/.ssh/authorized_keys`, SSH daemon configuration, and system-wide key material. Key additions are especially consequential on shared administrative accounts. [elastic](https://www.elastic.co/security-labs/primer-on-persistence-mechanisms)
- **Shell and environment hooks:** Track changes to `/etc/profile*`, `/etc/bash.bashrc`, `/etc/profile.d/`, and user dotfiles. Also examine environment injection paths such as systemd drop-ins and application-specific startup wrappers.
- **Executable provenance:** Flag service or scheduled-task execution from writable or unusual locations such as `/tmp`, `/var/tmp`, `/dev/shm`, user home directories, hidden directories, or newly created paths.
- **Application layer:** Baseline web roots, deployment directories, plugin directories, CI agents, container images, Kubernetes manifests, and cloud-init/user-data sources. A web shell can provide command execution through a server-facing application component. [attack.mitre](https://attack.mitre.org/techniques/T1505/)

A strong analytic correlates **configuration write → service reload/enablement → process execution → outbound connection**. Any one event can be benign; the sequence is far more suspicious.

## Defensive controls

- Enforce least privilege: minimize interactive root access, tightly scope `sudo`, and avoid shared privileged accounts.
- Use file-integrity monitoring on startup, identity, SSH, and application deployment paths; protect the telemetry pipeline so local attackers cannot silently suppress evidence.
- Centralize logs and retain `auditd`/eBPF/EDR visibility for file writes, process starts, privilege changes, service-manager actions, and SSH authentication.
- Treat systemd unit and timer changes as security-sensitive configuration changes, ideally reviewed through version control and configuration management.
- Lock down SSH: disable direct root login where feasible, constrain allowed users/groups, use MFA or certificate-based controls where suitable, and retire keys with ownership or lifecycle ambiguity.
- Minimize writable execution paths: mount temporary filesystems with appropriate restrictions where compatible, restrict write access to system configuration, and avoid service binaries sourced from user-writable directories.
- Harden the deployment plane: secure CI/CD credentials, sign or verify packages/images where possible, control cloud-init and IaC changes, and monitor drift from the intended system state.
- Maintain known-good rebuild capability. For suspected kernel-, boot-, package-, image-, or control-plane-level persistence, rebuilding from trusted artifacts is generally safer than trying to “clean” the host.

## Incident-response perspective

When persistence is suspected, preserve evidence before making changes: collect relevant unit definitions, timers, cron state, account databases, SSH configuration, shell initialization files, package history, process trees, listening sockets, and authentication/service logs. Then scope laterally—identical automation or stolen deployment credentials can reproduce the persistence across hosts.

Finally, eradicate the **access path**, not just the artifact: rotate exposed credentials and SSH keys, revoke compromised tokens, remediate the initial entry vector, remove all redundant persistence mechanisms, and validate after reboot plus service restart. Linux persistence commonly spans scheduled tasks, systemd, shell profiles, user/group manipulation, sudoers, and SSH-key modifications, so verification must cover all of those layers. [elastic](https://www.elastic.co/security-labs/primer-on-persistence-mechanisms)
