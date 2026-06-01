---
title: "The OS Alibaba Built to Tame AI Agents — And Why Your Linux Server Was Never Designed for This"
tags:
  - AI
  - agentic-ai
  - operating-systems
  - security
  - linux
  - alibaba
  - open-source
---

**Challenge to the reader:** Before reading further, list every security boundary between your AI agent and your filesystem. If your answer is "none" or "the application layer," you already know why this matters.

---

ANOLISA — short for **Agentic Nexus Operating Layer & Interface System Architecture** — is an open-source, server-side operating system designed from the ground up for AI Agent workloads. Published by Alibaba under the Apache License 2.0 and open-sourced on March 30, 2026, it represents the "Agentic evolution of Anolis OS" — Alibaba's enterprise-grade Linux distribution. Rather than retrofitting general-purpose OS primitives for AI use cases, ANOLISA introduces a purpose-built operating layer that handles the unique security, observability, memory, and efficiency demands of running autonomous AI agents on Linux servers.

The project lives at [https://github.com/alibaba/ANOLISA](https://github.com/alibaba/ANOLISA) and is organized as a monorepo containing seven distinct but tightly integrated components, each solving a specific problem in the AI agent execution stack.

---

## 1. Why General-Purpose Linux Fails AI Agents

Modern AI agents are not passive inference engines — they execute shell commands, read and write files, call external APIs, and manage system processes. This means they effectively have OS-level execution capabilities: file I/O, network access, and process management are all within reach of a running agent. Traditional application security models, observability tools, and memory systems were never designed for this paradigm, creating a series of critical gaps:

- **Security boundaries collapse**: An agent that can write files and run shell commands is, from the OS's perspective, indistinguishable from a trusted user process. There is no native mechanism to constrain it to least-privilege operation.
- **Observability is blind**: Standard monitoring tools capture system calls and network packets, but they lack semantic understanding of LLM API interactions, token consumption, or agent-to-agent communication.
- **Token costs are unmanaged**: AI agents interacting with LLMs send large, verbose payloads — raw command output, bloated API schemas, unfiltered file contents — consuming far more tokens than necessary.
- **Memory is ephemeral**: Agents have no persistent, indexed, searchable memory across sessions. Context resets with every invocation.

ANOLISA addresses all of these gaps with a cohesive, Linux-native component architecture.

---

## 2. Repository Architecture

ANOLISA is organized as a monorepo under the `src/` directory. Each component is independently buildable, packaged as an RPM for Alibaba Cloud Linux / Anolis OS environments, and ships its own `CHANGELOG.md`, `README.md`, `LICENSE`, and `Makefile`.

| Component | Path | Primary Language | Platform |
|-----------|------|-----------------|----------|
| **Copilot Shell** (`cosh`) | `src/copilot-shell/` | TypeScript / Node.js | All |
| **Agent Sec Core** | `src/agent-sec-core/` | Rust + Python | Linux only |
| **AgentSight** | `src/agentsight/` | Rust (eBPF) | Linux only |
| **Token-Less** | `src/tokenless/` | Rust | Linux only |
| **Agent Memory** | `src/agent-memory/` | Rust | Linux only |
| **OS Skills** | `src/os-skills/` | Python / Shell | All |
| **ws-checkpoint** | `src/ws-ckpt/` | Rust | Linux (btrfs) |

The build system uses a unified `./scripts/build-all.sh` script that handles dependencies, compilation, and system installation in a single step, with flags for component selection and install bypass.

### Commit and Contribution Standards

The project enforces strict commit message conventions: the format `type(scope): description` is mandatory, with CI failing on missing scopes. Branch naming follows a `feature/<scope>/<desc>` convention (recommended but not enforced for fork contributors). Every PR is expected to fill a structured template covering motivation, related issues, type of change, scope, checklist, and testing methodology. All code and comments must be written in English, with ESLint + Prettier for TypeScript, Ruff + Black for Python, and `cargo fmt` + `cargo clippy` for Rust.

---

## 3. Copilot Shell (`cosh`) — The AI-Native Terminal

Copilot Shell is the primary human-facing interface of ANOLISA — an AI-powered terminal assistant built on top of [Qwen Code](https://github.com/QwenLM/qwen-code) v0.9.0. It replaces the traditional shell with a conversational, AI-augmented command environment that understands natural language instructions, navigates entire codebases, and orchestrates multi-tool workflows.

### Key Capabilities

- **Natural Language Coding** — Describe changes in plain language; the shell implements them directly (feature additions, bug fixes, refactors).
- **Code Analysis & Navigation** — Answers questions about project structure and logic without requiring the user to grep through files manually.
- **Multi-Tool Orchestration** — Integrates file, shell, search, web, LSP (Language Server Protocol), and MCP (Model Context Protocol) tools in a single session.
- **Interactive Shell** — The `/bash` command drops into an interactive shell; `exit` returns to the AI session.
- **Skill System** — Local and remote skill discovery with a four-tier priority chain: Project > User > Extension > Remote. Skills are Markdown-based instruction files with YAML frontmatter.
- **Hooks System** — `PreToolUse` events allow intercepting and modifying tool calls before execution — used heavily by the Token-Less component.
- **Git Workflow Automation** — Automates commits, branch creation, conflict resolution, and release note generation.
- **PTY Mode** — Full pseudo-terminal support, including `sudo` commands.

### Multi-Provider Authentication

Copilot Shell supports multiple LLM authentication backends:
- **Aliyun Authentication**: On ECS instances, auto-detects the environment and opens a browser or shows a QR code for web auth; elsewhere, accepts AK/SK credentials directly.
- **Qwen OAuth**: For Qwen model access through Alibaba's platform.
- **Custom Provider**: Any OpenAI-compatible endpoint including DashScope, DeepSeek, Kimi, GLM, and MiniMax.

### Architecture

The shell uses npm workspaces with three packages:

| Package | Responsibility |
|---------|----------------|
| `packages/cli` | Terminal UI — Ink/React rendering, input handling, command parsing |
| `packages/core` | Backend — AI model communication, prompt building, tool orchestration |
| `packages/test-utils` | Shared test infrastructure |

Configuration is layered (highest priority first): CLI args → Environment variables → Project settings → User settings → System settings → Defaults.

**Challenge:** Open your terminal right now and run `history | wc -l`. How many of those commands could a compromised AI agent have executed without your knowledge? Now imagine an OS that classifies every one of those commands by risk tier *before* execution.

---

## 4. Agent Sec Core — The Security Kernel

Agent Sec Core is ANOLISA's OS-level security kernel — a defense-in-depth framework designed to ensure AI agents run in a controlled, auditable, and least-privilege environment.

### Security Philosophy

The component is built on five explicit principles:

1. **Least Privilege**: Agents receive only the minimum system permissions required for their task.
2. **Explicit Authorization**: Sensitive operations require user confirmation; silent privilege escalation is forbidden.
3. **Zero Trust**: Skills are mutually untrusted; each operation is independently authenticated.
4. **Defense in Depth**: System hardening → Asset verification → Security decision — compromise of any one layer does not compromise the others.
5. **Security Over Execution**: When security and functionality conflict, security wins.

### The Three-Phase Security Workflow

Before any agent execution, three phases must pass in strict order:

| Phase | Description | PASS Condition |
|-------|-------------|----------------|
| **Phase 1** | System Hardening — `loongshield seharden --scan --config agentos_baseline` | Output contains `结果：合规` |
| **Phase 2** | Asset Protection — GPG signature + SHA-256 hash verification of all skills | Output contains `VERIFICATION PASSED` |
| **Phase 3** | Final Confirmation — Re-run Phase 1 and Phase 2 as a recheck | Both rechecks pass |

If any phase fails, all subsequent phases are cancelled and agent execution is blocked.

### Risk Classification

Operations are classified into four risk tiers with corresponding enforcement actions:

| Level | Examples | Action |
|-------|----------|--------|
| **Low** | File reads, info queries, text processing | Allow (sandboxed) |
| **Medium** | Code execution, package install, external API calls | Sandbox isolation + user confirmation |
| **High** | Reading `.env`/SSH keys, data exfiltration, modifying system config | Block unless explicitly approved |
| **Critical** | Prompt injection, secret leakage, disabling security policies | Immediate block + audit log + notify user |

### Linux Sandbox

The sandbox engine (`linux-sandbox`) is written in Rust and uses bubblewrap + seccomp to enforce filesystem and network policies. Three policy templates are available:

| Template | Filesystem | Network |
|----------|-----------|---------|
| `read-only` | Entire filesystem read-only | Denied |
| `workspace-write` | cwd + /tmp writable, rest read-only | Denied |
| `danger-full-access` | Unrestricted | Allowed (⚠ special use only) |

### Skill Ledger

The Skill Ledger is an Ed25519-based integrity system for skill directories. It tracks file hashes, version chains, and scan results in `.skill-meta/` manifests. Key operations include `init`, `scan`, `check`, `certify`, `status`, `audit`, and batch modes. Every security event is logged as JSONL to `/var/log/agent-sec/security-events.jsonl`.

### Protected Assets

Agents are **never** allowed to access or exfiltrate SSH keys, GPG private keys, API tokens, database credentials, `/etc/shadow`, or host identity information. Critical system paths (`/etc/passwd`, `/etc/sudoers`, `/etc/ssh/sshd_config`, `/boot/`, systemd unit directories) are write-protected.

---

## 5. AgentSight — eBPF Observability with Zero Code Intrusion

AgentSight is ANOLISA's observability component — an eBPF-based monitoring tool that captures AI agent activity at the kernel level with **zero code intrusion** (no agent modifications required).

### Data Pipeline Architecture

AgentSight operates a six-stage unified data pipeline:

```
Probes → Parser → Aggregator → Analyzer → GenAI → Storage
(eBPF)   (HTTP/SSE) (Req-Resp)  (Token/Audit) (Semantic) (SQLite/SLS)
```

| Stage | Description |
|-------|-------------|
| **Probes** | eBPF programs capture kernel events via ring buffer |
| **Parser** | Extracts structured HTTP messages, SSE events, and process exec data |
| **Aggregator** | Correlates request-response pairs; tracks process lifecycle via LRU cache |
| **Analyzer** | Produces audit records, token usage stats, and LLM API messages |
| **GenAI** | Transforms results into semantic events (LLM calls, tool use, agent interactions) |
| **Storage** | Persists to local SQLite and optionally uploads to Alibaba Cloud SLS |

### eBPF Probes

Three dedicated eBPF programs handle distinct concerns:

| Probe | Description |
|-------|-------------|
| `sslsniff` | uprobe on `SSL_read`/`SSL_write` to capture plaintext from encrypted connections (OpenSSL/GnuTLS) |
| `proctrace` | Traces `execve` syscalls, captures CLI args, builds process tree |
| `procmon` | Lightweight process monitor for creation/exit events (agent auto-discovery) |

### CLI Commands

| Command | Purpose |
|---------|---------|
| `agentsight trace` | Start eBPF-based tracing (foreground or daemon mode with SLS export) |
| `agentsight token` | Query token consumption with period filters, comparisons, and detail breakdowns |
| `agentsight audit` | Query audit events, filter by PID/type, view summary statistics |
| `agentsight serve` | Start HTTP API server and embedded React Dashboard UI (default: `127.0.0.1:7396`) |
| `agentsight discover` | Scan for and list running AI agent processes |

### Dashboard

The Dashboard is a React-based web UI embedded into the `agentsight serve` binary at compile time. It visualizes conversation history, trace details, and token statistics. Data collection (tracer) and visualization (server) run independently — the tracer writes to SQLite while the server reads from it, supporting both live monitoring and historical browsing.

### Supported LLM Providers

Token parsing covers OpenAI and OpenAI-compatible APIs, Anthropic Claude (including cache token handling), Google Gemini, and Qwen with native chat template support.

### Prerequisites

AgentSight requires Linux kernel >= 5.8 (BTF support), Rust >= 1.80, clang/llvm >= 11 for eBPF compilation, and libbpf >= 0.8. It originates from the [eunomia-bpf/agentsight](https://github.com/eunomia-bpf/agentsight) project.

**Challenge:** Think about your current monitoring stack. Can it answer the question "how many tokens did my AI agents consume last week, and which tool calls accounted for the most waste?" AgentSight can answer this with a single CLI command.

---

## 6. Token-Less — The Cost Optimization Layer

Token-Less is ANOLISA's cost optimization layer — a pure-Rust toolkit that minimizes the number of LLM tokens consumed during agent operations through multiple complementary strategies.

### Token Reduction Strategies

| Strategy | Token Savings | Mechanism |
|----------|--------------|-----------|
| Schema compression | ~57% | Compresses OpenAI Function Calling tool schemas via `tokenless-schema` library |
| Response compression | ~26–78% | Compresses API/tool responses before they enter the context window |
| TOON context compression | 15–40% | Encodes JSON to TOON (Token-Oriented Object Notation) format |
| Command rewriting | 60–90% | Filters CLI output via RTK (70+ supported commands) |
| Tool Ready | Reduces retry waste | Pre-checks tool environment; reports `NOT_READY` to prevent futile retries |

The `tokenless` binary is a single static binary with zero runtime dependencies — pure Rust.

### Integration Adapters

Token-Less integrates with three agent platforms:

- **copilot-shell hooks**: `PreToolUse` hook rewrites shell commands via RTK; `PostToolUse` hook compresses responses and performs TOON encoding; `BeforeModel` hook compresses tool schemas. Auto-discovered via cosh extension manifest — no manual configuration required.
- **OpenClaw plugin**: Hooks `before_tool_call` for command rewriting and `tool_result_persist` for response compression. Observed savings of ~78% on web fetch results.
- **Hermes Agent plugin**: Covers Tool Ready, command rewriting, response compression, TOON encoding, and session tracking. Gracefully degrades if binaries are not installed.

### Tool Ready

The Tool Ready subsystem prevents LLMs from wasting tokens retrying commands that fail due to missing environment dependencies. Before each tool call, `tool_ready_hook.sh` checks the tool's dependency list from `tool-ready-spec.json`. If dependencies are missing, it reports `NOT_READY` with "Skip retry" guidance. The `tokenless env-check` CLI also supports auto-fixing missing dependencies.

### TOON Format

TOON (Token-Oriented Object Notation) is a compact encoding for JSON responses targeted at LLM consumption. For example:

```bash
# JSON → TOON
echo '{"name":"Alice","age":30}' | tokenless compress-toon
# name: Alice
# age: 30
```

This format reduces token usage by 15–40% for structured data while remaining fully readable by LLMs.

---

## 7. Agent Memory — Persistent, Searchable Context

Agent Memory provides CMA-style (Contiguous Memory Allocation-inspired) persistent filesystem memory for AI agents, served over the Model Context Protocol (MCP). It is Linux-only and written in Rust.

Key capabilities include:
- **Sandboxed file tools** — Agents can read/write files within a controlled namespace.
- **SQLite FTS5 BM25 index** — Full-text search over the agent's memory store with relevance ranking.
- **Optional git versioning** — File changes can be tracked as git commits for auditability.
- **tar.gz snapshots** — Point-in-time memory exports for backup or portability.
- **MCP server interface** — Exposes memory operations as MCP tools, making it compatible with any MCP-capable agent.

---

## 8. OS Skills — The Curated Knowledge Library

OS Skills is ANOLISA's curated knowledge library — a collection of operational "skills" that agents can invoke to perform system administration, DevOps, security, monitoring, and cloud management tasks.

### Skill Categories

| Category | Directory | Coverage |
|----------|-----------|----------|
| **AI Tools** | `ai/` | Claude Code, OpenClaw, CoPaw, MCP setup |
| **System Admin** | `system-admin/` | Package management, storage, networking, kernel, shell scripting |
| **DevOps** | `devops/` | Git workflows, CI/CD, kernel development, diagnostics |
| **Alibaba Cloud** | `aliyun/` | ECS instance management, cloud networking, GPU/AI deployment |
| **Security** | `security/` | CVE queries, compliance checks, system hardening |
| **Monitoring & Perf** | `monitor-perf/` | sysAK diagnostics, keentune tuning, sysctl management |

### Skill Format

Each skill lives in its own directory with a `SKILL.md` file using YAML frontmatter:

```yaml
---
name: my-skill
version: 1.0.0
description: What this skill does
layer: application          # application | system | core
lifecycle: production       # production | operations | usage | maintenance
tags: [example, demo]
platforms: [cosh, claude-code, gemini-cli]
---
```

Skills are installed to `/usr/share/anolisa/skills/` and auto-discovered by Copilot Shell. Installation supports extension-based one-line install, RPM packages, or manual directory copy.

---

## 9. ws-checkpoint — Instant Workspace Snapshots

ws-checkpoint is a btrfs-based workspace snapshot management system designed specifically for AI Agent scenarios. It enables instant checkpoint creation and rollback using btrfs Copy-on-Write semantics — snapshot operations complete in microseconds.

Key features:
- **Sub-millisecond snapshots** — Leverages btrfs COW for near-instantaneous checkpoint operations.
- **Daemon architecture** — Privileged operations are encapsulated in a systemd daemon; callers do not need root access.
- **Unix Socket IPC** — Binary protocol via Bincode for efficient inter-process communication.
- **Auto-cleanup scheduling** — The daemon can automatically prune snapshots by count or time thresholds.
- **TOML hot-reload** — Config changes take effect immediately without restarting the daemon.
- **Capacity alerts** — Warns when any workspace exceeds 1,000 snapshots or filesystem utilization exceeds 90%.

The component interfaces with the Linux btrfs kernel filesystem and `btrfs-progs` exclusively through the public system call interface, avoiding GPL licensing implications.

---

## 10. Installation and Getting Started

The recommended installation path on Alibaba Cloud Linux or Anolis OS is via RPM:

```bash
# Install all components
sudo yum install copilot-shell agent-sec-core agentsight tokenless agent-memory os-skills

# Launch Copilot Shell
cosh
```

For source builds, the unified script handles everything:

```bash
# Build and install all components
./scripts/build-all.sh

# Build specific components only
./scripts/build-all.sh --component cosh --component sec-core

# Build without installing
./scripts/build-all.sh --no-install
```

The unified test runner mirrors the same structure:

```bash
./tests/run-all-tests.sh
./tests/run-all-tests.sh --filter shell   # copilot-shell only
./tests/run-all-tests.sh --filter sec     # agent-sec-core only
```

---

## 11. Technology Stack Overview

ANOLISA's technology choices reflect deliberate optimization for each component's requirements:

| Component | Languages | Key Frameworks / Dependencies |
|-----------|-----------|-------------------------------|
| Copilot Shell | TypeScript, Node.js | Qwen Code, Ink/React, MCP SDK, npm workspaces, ESLint, Vitest |
| Agent Sec Core | Rust, Python | bubblewrap, seccomp, loongshield, Typer, Ed25519, GPG |
| AgentSight | Rust, eBPF C | libbpf, Ring Buffer, SQLite, Alibaba SLS SDK, HuggingFace tokenizer |
| Token-Less | Rust | RTK, toon-format, OpenAI Function Calling schema spec |
| Agent Memory | Rust | SQLite FTS5, BM25, MCP, git, tar |
| OS Skills | Python, Shell | Markdown + YAML frontmatter |
| ws-checkpoint | Rust | btrfs, systemd, Bincode, TOML |

---

## 12. Security Architecture — The Three-Layer Model

ANOLISA's security model operates at three levels simultaneously:

1. **OS Hardening** (Phase 1): System-level baseline compliance enforced via `loongshield`, covering kernel parameters, SSH configuration, PAM settings, and other system hardening controls.
2. **Asset Integrity** (Phase 2): Every skill and binary is GPG-signed and SHA-256-hashed. The Skill Ledger maintains an Ed25519-based tamper-evident audit trail.
3. **Runtime Isolation** (Sandbox): The linux-sandbox enforces filesystem and network access policies per-command, with classification-driven policy selection. All security events are persisted as JSONL audit logs.

This three-layer model means compromise of any single control does not grant an attacker full system access — a key property for production AI agent deployments where prompt injection and tool abuse are real threat vectors.

---

## 13. Relationship to Anolis OS and Alibaba Cloud

ANOLISA is explicitly positioned as the "Agentic evolution of Anolis OS" — Alibaba's enterprise Linux distribution targeted at cloud and on-premise deployments. The OS Skills component includes dedicated `aliyun/` skills for ECS instance management, cloud networking, and GPU/AI deployments, with the AgentSight component offering native export to Alibaba Cloud SLS (Simple Log Service). The project targets RPM-based Linux distributions in the Alibaba Cloud Linux / RHEL family, and loongshield (Phase 1 hardening) requires Alibaba Cloud Linux, Anolis OS, or RHEL-compatible systems.

---

## 14. Release History

| Version | Date | Key Additions |
|---------|------|--------------|
| **0.0.1** | 2026-03-30 | Initial open-source release integrating copilot-shell, agent-sec-core, os-skills, and agentsight |

The project was open-sourced on March 30, 2026. Additional components (tokenless, agent-memory, ws-ckpt) appear to have been added post-initial-release based on the repository structure and individual component changelogs.

---

## 15. Why This Architecture Matters

ANOLISA represents a distinct architectural position: rather than building a standalone AI agent framework (like LangChain or AutoGen), it descends into the operating system layer to provide the substrate on which any agent framework can run securely and efficiently. The key insight is that the OS is the correct enforcement boundary for agent security — not the application layer, which an adversarial agent can potentially bypass through prompt injection or tool abuse.

By enforcing sandboxing, integrity verification, and audit logging at the kernel/OS level through mechanisms like bubblewrap, seccomp, and eBPF, ANOLISA makes security properties tamper-resistant by construction rather than by convention. Similarly, Token-Less operating at the OS/hook layer means token savings apply uniformly across all agents regardless of their framework, without requiring any agent-level code changes.

This positions ANOLISA as infrastructure rather than framework — a foundation for running AI agents in production enterprise Linux environments, particularly within the Alibaba Cloud ecosystem.

---

**Final challenge:** Take one component from ANOLISA's stack — Agent Sec Core's sandbox, AgentSight's eBPF probes, or Token-Less's schema compression — and sketch out how you would integrate it into your own AI agent setup. What would break? What would get safer? The answers will tell you more about your agent security posture than any checklist ever could.
