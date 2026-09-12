

The safest pattern is to separate planning from execution, enforce least privilege per tool/action, and require approvals for destructive or privilege-changing operations. [ibm](https://www.ibm.com/think/tutorials/ai-agent-security)

## Reference model

A practical architecture is: **user -> agent API -> policy gate -> tool adapters -> target systems -> audit/monitoring**. The agent should never talk directly to Terraform, Kubernetes, cloud APIs, or secrets stores without going through an authorization layer that evaluates who requested the task, what the agent is trying to do, and whether that action is allowed in the current environment. [obsidiansecurity](https://www.obsidiansecurity.com/blog/security-for-ai-agents)

## Identity first

Each agent should have its own workload identity rather than sharing a long-lived service account or human credential. Short-lived tokens, validated claims, and separate trust boundaries between user identity and agent identity reduce replay risk and help prevent confused-deputy problems when the agent acts on a user’s behalf. [hashicorp](https://www.hashicorp.com/en/resources/deploying-serverless-ai-agents-on-aws-with-terraform-and-securing-them-with-hcp-v)

## Permission design

Least privilege for agents should be enforced at the **action level**, not just at the account level, because broad tool access can turn prompt injection into real infrastructure changes. In practice, that means allowing things like “read Terraform plan,” “list Kubernetes pods,” or “open a PR,” while putting “apply,” “delete,” “rotate IAM roles,” or “change network policy” behind stricter gates. [hatchworks](https://hatchworks.com/blog/ai-agents/ai-agent-security/)

## Terraform pattern

For Terraform, the agent should generate code or a plan, but not auto-apply changes in production by default. A safer flow is: create branch, open pull request, run policy-as-code and IaC scanning, generate `terraform plan`, present the diff, then require human approval or a separate deployment controller to run `apply` in approved workspaces only. [cycode](https://cycode.com/blog/agent-infrastructure-as-code/)

## Kubernetes pattern

For Kubernetes, give the agent read-only access first, and isolate any code-executing or remediation agent in a sandboxed runtime with strong kernel and network isolation. If the agent can patch workloads, restrict it to a narrow namespace set, approved resource kinds, and reversible actions such as scaling or rollout restart before allowing deletes, RBAC edits, or admission-policy changes. [kubernetes](https://kubernetes.io/blog/2026/03/20/running-agents-on-kubernetes-with-agent-sandbox/)

## Secrets handling

Secrets should not live in prompts, config files, or agent memory; they should be fetched just in time from a secrets system and expire quickly. Dynamic secrets and short token TTLs reduce blast radius, especially when an agent needs temporary access to cloud APIs, databases, or MCP-style tool servers. [hashicorp](https://www.hashicorp.com/en/blog/build-secure-ai-applications-on-azure-with-hashicorp-terraform-and-vault)

## Guardrails

Treat every prompt, retrieval result, and tool response as untrusted input that must be validated before the next step. Strong guardrails usually include prompt-injection detection, output filtering for sensitive data, schema validation for tool calls, rate limits, network egress restrictions, and policy checks before execution. [learn.microsoft](https://learn.microsoft.com/en-us/azure/security/fundamentals/ai-security-best-practices)

## Monitoring

You need full audit trails for who asked, what the agent planned, which tools it called, what credentials it used, and what changed downstream. Behavioral analytics and SIEM/SOAR integration help detect anomalies such as unusual prompt patterns, repeated policy denials, abnormal tool frequency, or an agent suddenly touching systems outside its normal scope. [checkmarx](https://checkmarx.com/learn/ai-security/devsecops-best-practices-in-the-age-of-ai/)

## Safe rollout

Start with low-risk use cases like summarizing alerts, generating runbooks, drafting IaC changes, or producing remediation recommendations instead of direct production mutation. Then move through a trust ladder: **read-only -> propose -> gated execute -> limited autonomous remediation**, with red-team testing, rollback capability, and version-controlled change review at every stage. [devops](https://devops.com/before-you-go-agentic-top-guardrails-to-safely-deploy-ai-agents-in-observability/)

## A concrete policy split

Here is a good default separation for an infra agent:

| Capability | Default stance |
|---|---|
| Read logs, metrics, configs | Allow with scoped identity  [obsidiansecurity](https://www.obsidiansecurity.com/blog/security-for-ai-agents) |
| Generate Terraform/HCL/YAML | Allow in repo workflow only  [cycode](https://cycode.com/blog/agent-infrastructure-as-code/) |
| Open PR / comment on incidents | Allow with audit logging  [obsidiansecurity](https://www.obsidiansecurity.com/blog/security-for-ai-agents) |
| Run `terraform plan` | Allow in isolated CI workspace  [cycode](https://cycode.com/blog/agent-infrastructure-as-code/) |
| Run `terraform apply` in prod | Require approval and separate deploy identity  [cycode](https://cycode.com/blog/agent-infrastructure-as-code/) |
| Patch Kubernetes deployment | Require namespace and action policy gate  [kubernetes](https://kubernetes.io/blog/2026/03/20/running-agents-on-kubernetes-with-agent-sandbox/) |
| Change IAM/RBAC/network policy | Human approval only  [hatchworks](https://hatchworks.com/blog/ai-agents/ai-agent-security/) |
| Read secrets directly | Deny by default; use brokered short-lived creds  [hashicorp](https://www.hashicorp.com/en/resources/deploying-serverless-ai-agents-on-aws-with-terraform-and-securing-them-with-hcp-v) |

## Minimal blueprint

If you were implementing this in a modern platform stack, I would use:
- API gateway in front of the agent for authn, rate limiting, and request validation [obsidiansecurity](https://www.obsidiansecurity.com/blog/security-for-ai-agents)
- OIDC/workload identity for the agent, separate from the end user [hashicorp](https://www.hashicorp.com/en/resources/deploying-serverless-ai-agents-on-aws-with-terraform-and-securing-them-with-hcp-v)
- Policy engine for action-level authorization, environment rules, and approval gates [kla](https://kla.digital/blog/ai-agent-permissions)
- Vault or equivalent for dynamic secrets and short-lived credentials [hashicorp](https://www.hashicorp.com/en/blog/build-secure-ai-applications-on-azure-with-hashicorp-terraform-and-vault)
- GitOps or PR-driven workflow for Terraform and Kubernetes changes [cycode](https://cycode.com/blog/agent-infrastructure-as-code/)
- SIEM-integrated audit logs and anomaly detection for runtime monitoring [checkmarx](https://checkmarx.com/learn/ai-security/devsecops-best-practices-in-the-age-of-ai/)

