---
title: "Your AI Agent Doesn't Have to Go Rogue to Empty Your Wallet — and the Horror Stories You Should Stop Repeating"
tags:
  - security
  - ai-agents
  - llm
  - cloud-billing
  - api-security
  - cost-governance
  - credentials
  - claude-code
---

**Challenge to the reader:** Before you read on, open the directory where your coding agent has ever run and grep for credentials — `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, a cloud secret in `.env`, a service-account JSON. Count how many of those keys a spawned subprocess could inherit without you noticing. That count is your exposure surface; keep it in mind as you work through these twelve incidents.

---

Here is the uncomfortable truth at the center of the AI-agent "horror story" genre: **an agent does not have to go rogue, invent a tool, or ignore a single instruction to cost you a fortune.** It only needs a goal, a credential, and a human willing to approve its plan. The stories below fall into three buckets — agents repeatedly buying model inference, agents provisioning expensive infrastructure, and credentials enabling uncontrolled spending — but the distinction that matters most is **evidence**: some of these have first-person technical reports behind them, and some are viral anecdotes repeated across blogs without an independently verified invoice in sight.

Why this matters: if you build or operate agents, the failure modes that actually cost people money are boring and specific — unbounded retries, inherited credentials, and a billing route that silently changes the moment a subprocess spawns. The disasters you *can* defend against are the unglamorous ones. The headline numbers you *shouldn't* repeat are often the most dramatic ones.

---

## 1. The three buckets, and why "evidence" is the whole game

Every agent-cost horror story lands in one of three buckets:

1. **Agents repeatedly buying model inference** — the same failing step keeps purchasing tokens.
2. **Agents provisioning expensive infrastructure** — a loose task becomes permission to stand up cloud resources.
3. **AI/API credentials enabling uncontrolled spending** — a key in the wrong place turns someone else's meter on.

The recurring failure modes are more specific than "AI is expensive," but before the specifics come the caveat that the entire genre runs on a spectrum of evidence quality. Some incidents below are first-person technical reports in a public issue tracker. Others are viral anecdotes with no independently verified invoice. The amounts quoted are **reported** charges or usage, not necessarily amounts ultimately paid — and in several cases the two are very different things.

---

## 2. The reports with first-person receipts

These are the incidents a careful operator can actually learn from, because a human who was there wrote down what happened, usually in a public repository.

### 2.1 "Scan this hobbyist network" → a $6,531 AWS bill

An operator gave an AI agent AWS credentials and asked it to connect to and index DN42, a volunteer network used to experiment with BGP and DNS. The agent proposed infrastructure including five `m8g.12xlarge` instances — 48 vCPUs and 192 GiB RAM each — and a high-bandwidth scanning setup. The reported AWS bill reached $6,531.30; AWS reportedly reduced it to $1,894 on appeal. [Arcade](https://www.arcade.dev/blog/ai-agent-did-its-job-authorization/)

The especially uncomfortable part: one account says the agent asked for confirmation and the operator approved it. This was not simply an agent ignoring instructions; it was an operator authorizing a plan without appreciating the spending authority being delegated.

What went wrong:

- A loosely defined research task came with real cloud provisioning credentials.
- Infrastructure scale was wildly disproportionate to the hobbyist task.
- Human approval did not amount to meaningful cost review.

Evidence quality: detailed secondary accounts referencing the agent's public community interactions. Reports disagree about the precise duration and cost breakdown, so the "overnight" headline should not be treated as an exact timeline. [TalkingTech](https://talkingtech.io/an-ai-agent-spent-6-531-on-aws-to-scan-a-hobbyist-network/)

### 2.2 "Help me automate my subscription" → $1,800+ in separate API charges

In a March 2026 GitHub issue, a Claude Max subscriber paying $200/month reported asking the built-in `claude-code-guide` agent how to schedule runs. According to the report, it recommended a workflow using `claude -p` and an `ANTHROPIC_API_KEY`. The resulting jobs generated more than $1,800 in API charges in two days, billed separately from the subscription. [GitHub issue #37686](https://github.com/anthropics/claude-code/issues/37686)

The user believed they were automating access they already paid for. Instead, the proposed workflow used a separately metered billing account.

What went wrong: AI-generated operational advice crossed a billing boundary without making that boundary clear.

Evidence quality: a first-person issue in Anthropic's public repository, not an independently adjudicated billing finding. Do not treat the issue author's description of command behavior as timeless documentation — authentication and billing behavior can change.

### 2.3 "I'm logged into Max" → $447.30 in unexpected metered charges

Another user reported $447.30 in API charges during Claude Code sessions on May 24–25, 2026, despite having an active Max subscription. They alleged that authentication defaulted to API billing and that automated support declined a refund. [GitHub issue #62338](https://github.com/anthropics/claude-code/issues/62338)

The thread also contains a separate commenter's account involving subscription "Extra Usage," rather than a separate developer API balance. Those are different billing mechanisms and should not be conflated.

What went wrong: the visible subscription/authentication state allegedly did not communicate the effective billing route clearly.

Evidence quality: first-person public bug reports; the precise root cause and refund outcome were not established by the sources reviewed.

### 2.4 "Use the coding agent in this project" → repeated $200 auto-billing events

An April 2026 report alleged that Claude Code Desktop discovered an Anthropic API key in project environment variables — intended for Supabase edge functions — and used that key instead of the user's subscription. With automatic billing enabled, the user reported multiple $200 charges. [GitHub issue #53638](https://github.com/anthropics/claude-code/issues/53638)

This is a particularly relevant failure mode for developers: an application credential present in a workspace allegedly became the coding tool's billing credential.

Evidence quality: a first-person GitHub report. The source does not establish a final total or an independently confirmed product diagnosis.

### 2.5 "Delegate to specialist subagents" → the children allegedly used a different wallet

A Max subscriber reported $152.04 in unexpected API charges after dispatching specialist subagents. Their account alleged that the parent session used subscription authentication while child processes picked up `ANTHROPIC_API_KEY` from the environment. They reported approximately 800-plus API requests over five sessions, with many requests containing 100,000–166,000 input tokens. [GitHub issue #39903](https://github.com/anthropics/claude-code/issues/39903)

This is smaller than the five-figure stories, but technically revealing: a parent agent's apparent billing mode may not tell the operator what every spawned process is doing.

Evidence quality: first-person technical allegation, not a confirmed universal behavior.

### 2.6 One failing command → approximately 27 million tokens consumed

In a December 2025 Claude Code issue, a user reported that a general-purpose subagent repeated the same failing command more than 300 times. It eventually timed out after approximately 4.6 hours, having consumed around 27 million tokens. [GitHub issue #15909](https://github.com/anthropics/claude-code/issues/15909)

The report does not provide a reliable dollar total. Converting that token count into a bill without the model, input/output mix, caching, and billing arrangement would be misleading.

What went wrong: repeated failure did not trigger an early stop; the same action kept getting retried without useful progress.

Evidence quality: first-person issue report with a concrete failure description and usage estimate.

### 2.7 "This import will be free" → ¥70,540, approximately $470

A user reported that Claude Code estimated a Google Places import would cost $0 because it would fit within the free tier. The actual bill was reportedly ¥70,540, approximately $470. According to the complaint, the estimate failed to account for Nearby Search pagination, which increased requests from approximately 11,000 to 36,883. [GitHub issue #43758](https://github.com/anthropics/claude-code/issues/43758)

The agent did not need to go rogue. It proposed a plan, wrote the script, supplied the wrong cost estimate, and the user approved the work on that basis.

Evidence quality: first-person GitHub complaint. It is a claim about an incorrect estimate and resulting charges, not a verified determination of liability.

---

**Challenge to the reader (mid-post):** Pick one of the issue numbers above — say, [#37686](https://github.com/anthropics/claude-code/issues/37686) — and read the thread. Find the exact moment where the author's mental model of "what I pay for" diverged from the actual billing route. Then write down, in one sentence, the single most valuable signal the product could have surfaced to stop it.

---

## 3. The viral anecdotes — and one credential-theft outlier

These are the stories that circulate most widely but carry the weakest evidence. The last one is a real billing disaster of a different kind: not an agent deciding to overspend, but a stolen credential.

### 3.1 Two agents allegedly talked to each other for 11 days → $47,000

A widely circulated November 2025 account describes a multi-agent research system entering a recursive interaction. Two agents supposedly continued exchanging messages for 11 days, generating a $47,000 API bill before anyone noticed. A TechStartups article attributes the story to an engineer's Medium account. [TechStartups](https://techstartups.com/2025/11/14/ai-agents-horror-stories-how-a-47000-failure-exposed-the-hype-and-hidden-risks-of-multi-agent-systems/)

The alleged mechanism is a classic agentic failure: activity is mistaken for progress, one agent's output triggers another, and the workflow has no effective termination condition.

Evidence quality: weaker than the first-person repository reports above. The coverage reviewed repeats an attributed narrative; it does not independently establish the invoice or provide a detailed public incident investigation. Treat it as a reported anecdote, not a settled case study.

### 3.2 A $50 initial payment allegedly became $12,229 in usage

A crowdsourced incident archive describes a developer whose agent generated $12,229 in API charges after an initial $50 payment. The archive attributes the incident to a social-media post and claims no effective spending cap stopped the accumulation. [Agent Horror Stories](https://www.agenthorrorstories.com/story/12229-in-api-calls-developer-only-paid-50-ieyd)

The distinction matters: a $50 payment is not necessarily a contractual $50 hard limit. However, the material reviewed does not establish the provider, billing terms, detailed chronology, or final amount paid.

Evidence quality: low-confidence social-media-derived account. Worth flagging; not strong enough to present as a verified five-figure liability.

### 3.3 $1,100 in API debt, plus loss of control of the running agent

The same archive summarizes a social-media account in which an agent accumulated approximately $1,100 in API debt, lost its task/identity context, and left the operator struggling to regain control until processes were killed. [Agent Horror Stories](https://www.agenthorrorstories.com/)

Evidence quality: low-confidence archive summary. It lacks enough independently checked technical detail to confidently reconstruct the failure or establish the final bill.

### 3.4 A stolen Gemini API key → $82,314.44 in 48 hours

This is a major AI billing horror story, but it is not an autonomous agent deciding to overspend.

A small development team reported that a compromised Gemini API key generated $82,314.44 in charges over approximately 48 hours, compared with normal spending of about $180 per month. Coverage says the key was used for Gemini image and text generation. The victim reported deleting the key, disabling APIs, rotating credentials, and opening a support case. [Yahoo Tech](https://tech.yahoo.com/ai/gemini/articles/gemini-api-key-thief-racks-110000550.html)

At the time of that coverage, the team feared the charges could bankrupt the business. That does not establish that bankruptcy occurred or that the full amount was ultimately collected.

What went wrong: compromised credentials provided access to expensive metered inference. It belongs beside agent-cost incidents because the financial exposure is similar, but calling it "an agent ran away" would misstate the event.

Evidence quality: technology reporting based on the victim's public account; the final billing resolution is not established here.

### 3.5 A claimed $75,000 weekend retry storm

A crowdsourced archive lists a Lambda-powered AI image-processing API that allegedly generated a $75,000 bill in 48 hours after a traffic spike collided with broken error handling. Its summary describes millions of retries cascading across chained services. [Agent Horror Stories](https://www.agenthorrorstories.com/)

This is primarily a serverless/distributed-systems retry-storm story, not necessarily an LLM agent choosing actions autonomously.

Evidence quality: weak in the material available. The archive points to Reddit, but the original technical account and invoice were not verified here. Do not repeat the $75,000 figure as established fact.

---

**Challenge to the reader (mid-post):** Take the $47,000 eleven-day story and the $6,531 DN42 story side by side. List every fact you would need to verify before you repeated either figure to a colleague. Which of the two can you actually verify from the sources linked in this post, and which can you not?

---

## 4. The claims that don't survive a "verified" bar

Several articles also repeat a $4,200 long-weekend agent bill and a $1.3 million month involving roughly 100 agent instances, 603 billion tokens, and 7.6 million requests. The source reviewed does not provide enough underlying evidence to establish those as accidental overspending incidents rather than anecdotes, intentional high-volume use, or some other billing arrangement. [Entoura](https://www.entoura.studio/resources/articles/how-i-burned-a-weeks-budget-in-a-day/)

Likewise, another vendor blog tells a dramatic story about an agent provisioning 340 EC2 instances and producing a $47,000 Sunday-morning AWS bill, but the article does not identify a verifiable affected organization or supply a public incident report. That is a different story from the $47,000 eleven-day agent loop, despite the matching dollar amount. [Octopodas](https://octopodas.com/blog/ai-agents-gone-rogue-real-cases)

---

## 5. What actually connects the credible stories

Strip away the anecdotes and the recurring failure modes resolve into six concrete escape routes for money:

| Failure mode | How the money escapes | Illustrative report |
|---|---|---|
| Unbounded retries | The same failed step keeps purchasing inference | ~27 million tokens in 4.6 hours. [GitHub issue #15909](https://github.com/anthropics/claude-code/issues/15909) |
| Delegated infrastructure authority | A task becomes permission to create and run cloud resources | DN42 scanning and the $6,531 AWS bill. [Arcade](https://www.arcade.dev/blog/ai-agent-did-its-job-authorization/) |
| Billing-route confusion | Subscription use becomes separately metered API use | The reported $1,800 automation incident. [GitHub issue #37686](https://github.com/anthropics/claude-code/issues/37686) |
| Credential inheritance | Workspace or child-process environment changes which account pays | Desktop and subagent API-key reports. [GitHub issue #53638](https://github.com/anthropics/claude-code/issues/53638) |
| Incorrect cost modelling | Pagination or request multiplication invalidates the estimate | The Google Places import complaint. [GitHub issue #43758](https://github.com/anthropics/claude-code/issues/43758) |
| Credential compromise | An attacker buys inference using someone else's account | The reported $82,314.44 Gemini incident. [Yahoo Tech](https://tech.yahoo.com/ai/gemini/articles/gemini-api-key-thief-racks-110000550.html) |

---

## 6. The deeper lesson: the agent never had to rebel

The most unsettling case is arguably the DN42 one: the agent did not have to rebel, invent a tool, or ignore every instruction. It had a goal, usable credentials, and an operator willing to approve its plan. That was enough to produce a substantial bill. [Arcade](https://www.arcade.dev/blog/ai-agent-did-its-job-authorization/)

That reframes the entire genre. The popular fear is the runaway agent — the one that hallucinates a tool, bypasses a guardrail, or spawns a recursive loop. But the incidents with the strongest evidence are quieter. They are about **authorization that wasn't reviewed**, **credentials that were inherited rather than granted**, and **a billing route that changed silently**. The agent behaved exactly as instructed; the money still escaped.

If you take one thing from this, take that: the control surface that actually matters is not "does my agent obey me?" but "what can my agent spend, and who pays when it does?".

---

**Final challenge:** Design one concrete kill-switch for your own stack — a cloud account, an API key, or a subagent runner. Specify the exact mechanism (a hard budget cap, a human approval gate, environment isolation for subprocesses, or key scoping) and name at least three of the twelve incidents above that your single control would have stopped. Then write down why it would *not* have stopped the other nine.

---

## 7. Source and references

First-person reports (GitHub, Anthropic's `claude-code` repository):

- [#37686](https://github.com/anthropics/claude-code/issues/37686) — $1,800+ automation billing
- [#62338](https://github.com/anthropics/claude-code/issues/62338) — $447.30 metered charges
- [#53638](https://github.com/anthropics/claude-code/issues/53638) — $200 auto-billing from an inherited API key
- [#39903](https://github.com/anthropics/claude-code/issues/39903) — $152.04 subagent wallet
- [#15909](https://github.com/anthropics/claude-code/issues/15909) — ~27 million tokens in 4.6 hours
- [#43758](https://github.com/anthropics/claude-code/issues/43758) — ¥70,540 Google Places import

Secondary accounts and archives:

- [Arcade — "AI agent did its job" (DN42 / $6,531)](https://www.arcade.dev/blog/ai-agent-did-its-job-authorization/)
- [TalkingTech — $6,531 AWS bill](https://talkingtech.io/an-ai-agent-spent-6-531-on-aws-to-scan-a-hobbyist-network/)
- [TechStartups — $47,000 multi-agent loop](https://techstartups.com/2025/11/14/ai-agents-horror-stories-how-a-47000-failure-exposed-the-hype-and-hidden-risks-of-multi-agent-systems/)
- [Agent Horror Stories — $12,229 story](https://www.agenthorrorstories.com/story/12229-in-api-calls-developer-only-paid-50-ieyd)
- [Agent Horror Stories — archive](https://www.agenthorrorstories.com/)
- [Yahoo Tech — $82,314.44 Gemini key theft](https://tech.yahoo.com/ai/gemini/articles/gemini-api-key-thief-racks-110000550.html)
- [Entoura — $4,200 / $1.3M claims](https://www.entoura.studio/resources/articles/how-i-burned-a-weeks-budget-in-a-day/)
- [Octopodas — 340 EC2 / $47,000 claim](https://octopodas.com/blog/ai-agents-gone-rogue-real-cases)
