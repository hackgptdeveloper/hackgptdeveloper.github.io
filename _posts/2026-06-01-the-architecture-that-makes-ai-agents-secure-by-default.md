---
title: "The Architecture Pattern That Makes AI Agents Secure by Default"
tags:
  - AI
  - agentic-ai
  - security
  - architecture
  - terraform
  - kubernetes
  - devops
  - least-privilege
---

**Challenge to the reader:** Sketch the architecture of an AI agent that can manage your infrastructure — Terraform, Kubernetes, secrets, and CI/CD. Draw the boxes and arrows. Now identify every place where a prompt injection could become a production outage. Keep your sketch; we'll revisit it at the end.

---

The safest pattern for agentic AI is disarmingly simple: **separate planning from execution, enforce least privilege per tool and action, and require approvals for destructive or privilege-changing operations**[^1]. The hard part is implementing that pattern across real infrastructure — Terraform, Kubernetes, secrets stores, and CI/CD pipelines — without the agent becoming either useless or dangerous.

---

## 1. The Reference Architecture

A practical architecture follows this chain:

```
User → Agent API → Policy Gate → Tool Adapters → Target Systems → Audit/Monitoring
```

The agent should **never** talk directly to Terraform, Kubernetes, cloud APIs, or secrets stores without going through an authorization layer that evaluates three questions[^2]:

1. Who requested the task?
2. What is the agent trying to do?
3. Is that action allowed in the current environment?

**Challenge:** Which of those three questions is hardest to answer programmatically — and why?

---

## 2. Identity First

Each agent should have its own **workload identity** rather than sharing a long-lived service account or human credential. Short-lived tokens, validated claims, and separate trust boundaries between user identity and agent identity reduce replay risk and help prevent confused-deputy problems[^3].

The rule: the agent authenticates as itself, not as the user who triggered it. This way, even if the agent is compromised, the blast radius is limited to what the agent's own identity is authorized to do — not what the user can do.

---

## 3. Permission Design: Action-Level, Not Account-Level

Least privilege for agents should be enforced at the **action level**. Broad tool access can turn prompt injection into real infrastructure changes[^4].

Here's a concrete policy split for an infrastructure agent:

| Capability | Default Stance |
|---|---|
| Read logs, metrics, configs | Allow with scoped identity[^2] |
| Generate Terraform/HCL/YAML | Allow in repo workflow only[^5] |
| Open PR / comment on incidents | Allow with audit logging[^2] |
| Run `terraform plan` | Allow in isolated CI workspace[^5] |
| Run `terraform apply` in prod | Require approval and separate deploy identity[^5] |
| Patch Kubernetes deployment | Require namespace and action policy gate[^6] |
| Change IAM/RBAC/network policy | Human approval only[^4] |
| Read secrets directly | Deny by default; use brokered short-lived credentials[^3] |

Notice the gradient: read-only actions are allowed, proposals are allowed in controlled environments, but destructive or privilege-changing actions require either a separate identity, a human approval, or both.

---

## 4. Terraform Pattern

For Terraform, the agent should generate code or a plan — but **not auto-apply changes in production by default.** A safer flow[^5]:

```
Create branch → Open PR → Run policy-as-code + IaC scanning →
Generate terraform plan → Present diff → Human approval →
Separate deploy controller runs apply
```

The agent's role is to **propose**. The deployment controller's role is to **execute**. Keeping these identities and workflows separate means a compromised agent can't directly modify infrastructure.

---

## 5. Kubernetes Pattern

For Kubernetes, start with read-only access and isolate any code-executing or remediation agent in a sandboxed runtime with strong kernel and network isolation[^6].

If the agent can patch workloads, restrict it to:
- A narrow namespace set
- Approved resource kinds
- Reversible actions (scaling, rollout restart) before allowing deletes, RBAC edits, or admission-policy changes

The principle: **reversible before irreversible, narrow before broad.**

---

## 6. Secrets Handling

Secrets should not live in prompts, config files, or agent memory. They should be fetched **just in time** from a secrets system and expire quickly. Dynamic secrets and short token TTLs reduce blast radius, especially when an agent needs temporary access to cloud APIs, databases, or MCP-style tool servers[^7].

---

## 7. Guardrails and Monitoring

Treat every prompt, retrieval result, and tool response as **untrusted input** that must be validated before the next step. Strong guardrails include[^8]:

- Prompt-injection detection
- Output filtering for sensitive data
- Schema validation for tool calls
- Rate limits
- Network egress restrictions
- Policy checks before execution

On the monitoring side, you need full audit trails: who asked, what the agent planned, which tools it called, what credentials it used, and what changed downstream. Behavioral analytics help detect anomalies such as unusual prompt patterns, repeated policy denials, or an agent suddenly touching systems outside its normal scope[^9].

---

## 8. The Safe Rollout Ladder

Start with low-risk use cases and move through a trust ladder[^10]:

```
Read-only → Propose → Gated execute → Limited autonomous remediation
```

At every stage: red-team testing, rollback capability, and version-controlled change review. The jump from "propose" to "execute" is the hardest — that's where approval gates earn their keep.

---

## 9. Minimal Blueprint

If you were implementing this in a modern platform stack, you would use[^11]:

| Component | Purpose |
|---|---|
| **API Gateway** | Authentication, rate limiting, request validation |
| **OIDC/Workload Identity** | Agent identity separate from end user |
| **Policy Engine** | Action-level authorization, environment rules, approval gates |
| **Vault or equivalent** | Dynamic secrets, short-lived credentials |
| **GitOps/PR-driven workflow** | Terraform and Kubernetes changes via pull requests |
| **SIEM-integrated audit logs** | Anomaly detection for runtime monitoring |

---

**Final Challenge:** Return to the sketch you made at the start. Redraw it with the policy gate, separate identities, and approval workflow from this post. What is the one capability you would still be nervous about automating — even with all these controls in place? That's your next security sprint.

---

## References

[^1]: <https://www.ibm.com/think/tutorials/ai-agent-security>
[^2]: <https://www.obsidiansecurity.com/blog/security-for-ai-agents>
[^3]: <https://www.hashicorp.com/en/resources/deploying-serverless-ai-agents-on-aws-with-terraform-and-securing-them-with-hcp-v>
[^4]: <https://hatchworks.com/blog/ai-agents/ai-agent-security/>
[^5]: <https://cycode.com/blog/agent-infrastructure-as-code/>
[^6]: <https://kubernetes.io/blog/2026/03/20/running-agents-on-kubernetes-with-agent-sandbox/>
[^7]: <https://www.hashicorp.com/en/blog/build-secure-ai-applications-on-azure-with-hashicorp-terraform-and-vault>
[^8]: <https://learn.microsoft.com/en-us/azure/security/fundamentals/ai-security-best-practices>
[^9]: <https://checkmarx.com/learn/ai-security/devsecops-best-practices-in-the-age-of-ai/>
[^10]: <https://devops.com/before-you-go-agentic-top-guardrails-to-safely-deploy-ai-agents-in-observability/>
[^11]: <https://kla.digital/blog/ai-agent-permissions>
