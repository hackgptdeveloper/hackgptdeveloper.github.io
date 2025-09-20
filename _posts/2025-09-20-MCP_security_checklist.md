---
title: "Ultimate MCP Security Checklist: Hardening Model Context Protocol Deployments"
tags:
  - MCP
  - AI agent
---

Here’s a tight, practitioner-grade checklist for securing **MCP (Model Context Protocol)** deployments—organized by layer. Each section points to the authoritative spec and reference SDKs so you can chase details all the way down to code.

### 1) Protocol & Transport (Base)

1. Pin to a specific protocol revision (e.g., 2025-06-18) and reject clients/servers advertising unknown versions. ([Model Context Protocol][1])
2. Enforce strict JSON schema validation on every message (method, params, result, error) both directions. ([Model Context Protocol][1])
3. Require authenticated transports for non-stdio modes (Streamable HTTP / SSE / WebSocket), e.g., mTLS or OAuth2 bearer + TLS ≥1.2. ([Model Context Protocol][2])
4. Terminate connections on unknown/extra fields or type mismatches; fail closed. ([Model Context Protocol][1])
5. Bound message sizes and streaming chunk sizes; set conservative read timeouts and max in-flight requests. ([Model Context Protocol][2])

### 2) Authentication & Session

6. Prefer OAuth2/OIDC for HTTP transports; rotate/expire tokens; bind to audience & scopes. ([Model Context Protocol][2])
7. For stdio transports (local), verify executable provenance (signature, checksum) before launching server binaries. ([Model Context Protocol][2])
8. Tie sessions to a single principal; prohibit token reuse across principals; log the identity → session binding. ([Model Context Protocol][2])
9. On reconnect, re-authenticate (no silent session resurrection). ([Model Context Protocol][2])
10. Store credentials via OS keychain/KMS, never in plaintext config files. ([Model Context Protocol][2])

### 3) Authorization (Least Privilege)

11. Implement **capability scoping**: only expose the minimal **tools/resources/prompts** to a given client. ([Model Context Protocol][2])
12. Enforce per-tool **allowed operations** (read vs write vs delete; destructive actions behind explicit consent). ([Model Context Protocol][2])
13. Apply **RBAC/ABAC**: map identities → roles → permitted MCP methods. ([protectai.com][3])
14. Deny by default; all discovery/listing calls should filter to authorized items. ([Model Context Protocol][2])
15. Add **policy checks** on parameter values (path allowlists, URL allowlists, regex guards). ([Model Context Protocol][2])

### 4) Tool Safety (Command/Action Layer)

16. Treat tool **arguments** as untrusted; validate types, ranges, enums; reject ambiguous free-form strings. ([Model Context Protocol][2])
17. For shell/process tools, **disable shell interpolation**; use execve-style argv arrays; enforce time/CPU/memory limits. ([Model Context Protocol][2])
18. For file tools, enforce **chroot-like roots** (project roots), canonicalize paths, block `..`, symlinks, device files. ([Model Context Protocol][2])
19. For HTTP tools, restrict to safelisted schemes/hosts; block link-local/169.254.0.0/16/metadata; prevent SSRF and DNS rebinding. ([Model Context Protocol][2])
20. For database tools, parameterize queries; apply read-only roles where possible; per-table access. ([Model Context Protocol][2])

### 5) Resource & Prompt Exposure

21. Classify resources (public, internal, sensitive); never expose secrets in **resource previews**. ([Model Context Protocol][2])
22. Limit size/line counts on `readResource`; paginate and redact high-risk patterns (AWS keys, OAuth secrets). ([Model Context Protocol][2])
23. Gate **write** APIs (file writes, issue creation, cloud ops) behind interactive confirmation or signed intents. ([Model Context Protocol][2])
24. Keep **prompt templates** free of credentials; load them from trusted, versioned stores only. ([Model Context Protocol][2])
25. Don’t leak absolute filesystem paths or internal IPs in errors/results. ([Model Context Protocol][2])

### 6) Prompt-Injection & Content Mediation

26. Apply content filters to model output **before** turning it into a tool call; validate any tool call against policy. ([Model Context Protocol][2])
27. Strip/normalize model-supplied paths/URLs; compare against allowlists; require second factor for privilege escalation. ([Model Context Protocol][2])
28. Add **execution affordances**: “dry-run/plan → diff → approve → apply” for mutating tools. ([Model Context Protocol][2])
29. Defend against **instruction smuggling**: ignore model attempts to override tool safety flags/policies in arguments. ([Model Context Protocol][2])
30. Limit chain-of-tools depth or total mutations per session; add budget/credit quotas. ([Model Context Protocol][2])

### 7) Runtime Isolation & Hardening

31. Run servers in **containers** with seccomp/AppArmor and a minimal FS; drop root; read-only rootfs; tmpfs for scratch. ([Red Hat][4])
32. For stdio servers, launch with **least privileges** and a **restricted PATH/ENV**; scrub inherited env vars. ([Model Context Protocol][2])
33. Use separate **service accounts** per server and per environment; disable lateral movement paths. ([Red Hat][4])
34. Apply ulimits (files, processes), cgroup CPU/IO caps; kill long-running child processes. ([Model Context Protocol][2])
35. For plugin ecosystems, pin versions and **verify signatures** before enabling new tools. ([Model Context Protocol][2])

### 8) Network Controls

36. Default-deny egress; open only required domains/ports; split-tunnel by server role. ([Red Hat][4])
37. Block SMTP/FTP/peer-to-peer from tool contexts unless explicitly required; log any attempts. ([Red Hat][4])
38. Cache/lock DNS; prefer DoT/DoH; monitor for fast-flux/rebinding behavior. ([Red Hat][4])
39. For Streamable HTTP, terminate TLS at a hardened proxy; enable HTTP/2 flood protections and request rate limits. ([Model Context Protocol][2])
40. Instrument eBPF/Netfilter rules to tag MCP server traffic for anomaly detection. ([Red Hat][4])

### 9) Logging, Audit, & Forensics

41. Log **every MCP call** (who/when/what/tool/params-hash/result-hash) with privacy redaction; ship to SIEM. ([Model Context Protocol][2])
42. Record **consent/approval events** (who approved, inputs, diffs) for mutating actions. ([Model Context Protocol][2])
43. Preserve **session transcripts** with cryptographic integrity (hash chains / transparency logs). ([Model Context Protocol][2])
44. Emit **security events** (auth failure, policy block, rate-limit, sandbox breach) with severity and MITRE ATT\&CK mapping. ([Red Hat][4])
45. Add deterministic **request IDs** and correlate across client ↔ server ↔ downstream systems. ([Model Context Protocol][2])

### 10) Supply Chain & Build

46. Vendor the official **TypeScript** / **Python** MCP SDKs; pin exact versions; enable Dependabot + SLSA provenance. ([GitHub][5])
47. Run CI security gates (SAST/semgrep, license checks) on servers/clients; fail builds on criticals. ([Red Hat][4])
48. Reproducible builds for server binaries; sign artifacts; verify on deploy. ([Red Hat][4])
49. Fuzz test message handlers and tool param parsers (corpus from recorded traffic). ([Model Context Protocol][2])
50. Maintain an **SBOM** for each server; watch for CVEs in transitive deps of SDKs and tool adapters. ([GitHub][5])

---

## Code-level pointers (to dig deeper)

* **Official Spec & Security Notes** – protocol structure, message types, transports, and security best practices. ([Model Context Protocol][1])
* **Python SDK** – reference implementations for stdio / SSE / Streamable HTTP transports, handlers, and auth hooks (`modelcontextprotocol/python-sdk`). Start at the README and `mcp/server` & `mcp/client` packages. ([GitHub][6])
* **TypeScript SDK** – schemas (`schema.ts`), transport adapters, and server/client scaffolds you can harden (input validation, size limits, auth interceptors). ([GitHub][5])
* **Community clients/servers** (for patterns and hardening gaps to review): streamable-HTTP examples, Slack/LinkedIn clients, git server, “awesome servers” list. ([GitHub][7])
* **Industry security write-ups** – concrete risk discussions and control recommendations to benchmark against. ([Red Hat][4])

[1]: https://modelcontextprotocol.io/specification/2025-06-18?utm_source=chatgpt.com "Specification"
[2]: https://modelcontextprotocol.io/specification/draft/basic/security_best_practices?utm_source=chatgpt.com "Security Best Practices"
[3]: https://protectai.com/blog/mcp-security-101?utm_source=chatgpt.com "MCP Security 101: A New Protocol for Agentic AI"
[4]: https://www.redhat.com/en/blog/model-context-protocol-mcp-understanding-security-risks-and-controls?utm_source=chatgpt.com "Model Context Protocol (MCP): Understanding security ..."
[5]: https://github.com/modelcontextprotocol/typescript-sdk?utm_source=chatgpt.com "The official TypeScript SDK for Model Context Protocol ..."
[6]: https://github.com/modelcontextprotocol/python-sdk?utm_source=chatgpt.com "The official Python SDK for Model Context Protocol servers ..."
[7]: https://github.com/invariantlabs-ai/mcp-streamable-http?utm_source=chatgpt.com "MCP Streamable HTTP – Python and Typescript Examples"

