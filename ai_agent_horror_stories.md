
The horror stories fall into three buckets: agents repeatedly buying model inference, agents provisioning expensive infrastructure, and AI/API credentials enabling uncontrolled spending. The important distinction is **evidence**: some incidents have first-person technical reports; others are viral anecdotes repeated across blogs without independently verified invoices.

Below is a broad catalogue of the relevant public reports I found—not a claim to list every incident ever. Amounts are reported charges or usage, not necessarily amounts ultimately paid.

## 1. “Scan this hobbyist network” → a $6,531 AWS bill

An operator gave an AI agent AWS credentials and asked it to connect to and index DN42, a volunteer network used to experiment with BGP and DNS. The agent proposed infrastructure including five `m8g.12xlarge` instances—48 vCPUs and 192 GiB RAM each—and a high-bandwidth scanning setup. The reported AWS bill reached $6,531.30; AWS reportedly reduced it to $1,894 on appeal. [arcade](https://www.arcade.dev/blog/ai-agent-did-its-job-authorization/)

The especially uncomfortable part: one account says the agent asked for confirmation and the operator approved it. This was not simply an agent ignoring instructions; it was an operator authorizing a plan without appreciating the spending authority being delegated. [arcade](https://www.arcade.dev/blog/ai-agent-did-its-job-authorization/)

What went wrong:
- A loosely defined research task came with real cloud provisioning credentials.
- Infrastructure scale was wildly disproportionate to the hobbyist task.
- Human approval did not amount to meaningful cost review. [arcade](https://www.arcade.dev/blog/ai-agent-did-its-job-authorization/)

Evidence quality: detailed secondary accounts referencing the agent’s public community interactions. Reports disagree about the precise duration and cost breakdown, so the “overnight” headline should not be treated as an exact timeline. [talkingtech](https://talkingtech.io/an-ai-agent-spent-6-531-on-aws-to-scan-a-hobbyist-network/)

## 2. “Help me automate my subscription” → $1,800+ in separate API charges

In a March 2026 GitHub issue, a Claude Max subscriber paying $200/month reported asking the built-in `claude-code-guide` agent how to schedule runs. According to the report, it recommended a workflow using `claude -p` and an `ANTHROPIC_API_KEY`. The resulting jobs generated more than $1,800 in API charges in two days, billed separately from the subscription. [github](https://github.com/anthropics/claude-code/issues/37686)

The user believed they were automating access they already paid for. Instead, the proposed workflow used a separately metered billing account. [github](https://github.com/anthropics/claude-code/issues/37686)

What went wrong: AI-generated operational advice crossed a billing boundary without making that boundary clear.

Evidence quality: a first-person issue in Anthropic’s public repository, not an independently adjudicated billing finding. Also, do not treat the issue author’s description of command behavior as timeless documentation—authentication and billing behavior can change.

## 3. “I’m logged into Max” → $447.30 in unexpected metered charges

Another user reported $447.30 in API charges during Claude Code sessions on May 24–25, 2026, despite having an active Max subscription. They alleged that authentication defaulted to API billing and that automated support declined a refund. [github](https://github.com/anthropics/claude-code/issues/62338)

The thread also contains a separate commenter’s account involving subscription “Extra Usage,” rather than a separate developer API balance. Those are different billing mechanisms and should not be conflated. [github](https://github.com/anthropics/claude-code/issues/62338)

What went wrong: the visible subscription/authentication state allegedly did not communicate the effective billing route clearly.

Evidence quality: first-person public bug reports; the precise root cause and refund outcome were not established by the sources reviewed.

## 4. “Use the coding agent in this project” → repeated $200 auto-billing events

An April 2026 report alleged that Claude Code Desktop discovered an Anthropic API key in project environment variables—intended for Supabase edge functions—and used that key instead of the user’s subscription. With automatic billing enabled, the user reported multiple $200 charges. [github](https://github.com/anthropics/claude-code/issues/53638)

This is a particularly relevant failure mode for developers: an application credential present in a workspace allegedly became the coding tool’s billing credential. [github](https://github.com/anthropics/claude-code/issues/53638)

Evidence quality: a first-person GitHub report. The source does not establish a final total or independently confirmed product diagnosis.

## 5. “Delegate to specialist subagents” → the children allegedly used a different wallet

A Max subscriber reported $152.04 in unexpected API charges after dispatching specialist subagents. Their account alleged that the parent session used subscription authentication while child processes picked up `ANTHROPIC_API_KEY` from the environment. They reported approximately 800-plus API requests over five sessions, with many requests containing 100,000–166,000 input tokens. [github](https://github.com/anthropics/claude-code/issues/39903)

This is smaller than the five-figure stories, but technically revealing: a parent agent’s apparent billing mode may not tell the operator what every spawned process is doing. [github](https://github.com/anthropics/claude-code/issues/39903)

Evidence quality: first-person technical allegation, not a confirmed universal behavior.

## 6. One failing command → approximately 27 million tokens consumed

In a December 2025 Claude Code issue, a user reported that a general-purpose subagent repeated the same failing command more than 300 times. It eventually timed out after approximately 4.6 hours, having consumed around 27 million tokens. [github](https://github.com/anthropics/claude-code/issues/15909)

The report does not provide a reliable dollar total. Converting that token count into a bill without the model, input/output mix, caching, and billing arrangement would be misleading.

What went wrong: repeated failure did not trigger an early stop; the same action kept getting retried without useful progress. [github](https://github.com/anthropics/claude-code/issues/15909)

Evidence quality: first-person issue report with a concrete failure description and usage estimate.

## 7. “This import will be free” → ¥70,540, approximately $470

A user reported that Claude Code estimated a Google Places import would cost $0 because it would fit within the free tier. The actual bill was reportedly ¥70,540, approximately $470. According to the complaint, the estimate failed to account for Nearby Search pagination, which increased requests from approximately 11,000 to 36,883. [github](https://github.com/anthropics/claude-code/issues/43758)

The agent did not need to go rogue. It proposed a plan, wrote the script, supplied the wrong cost estimate, and the user approved the work on that basis. [github](https://github.com/anthropics/claude-code/issues/43758)

Evidence quality: first-person GitHub complaint. It is a claim about an incorrect estimate and resulting charges, not a verified determination of liability.

## 8. Two agents allegedly talked to each other for 11 days → $47,000

A widely circulated November 2025 account describes a multi-agent research system entering a recursive interaction. Two agents supposedly continued exchanging messages for 11 days, generating a $47,000 API bill before anyone noticed. A TechStartups article attributes the story to an engineer’s Medium account. [techstartups](https://techstartups.com/2025/11/14/ai-agents-horror-stories-how-a-47000-failure-exposed-the-hype-and-hidden-risks-of-multi-agent-systems/)

The alleged mechanism is a classic agentic failure: activity is mistaken for progress, one agent’s output triggers another, and the workflow has no effective termination condition. [techstartups](https://techstartups.com/2025/11/14/ai-agents-horror-stories-how-a-47000-failure-exposed-the-hype-and-hidden-risks-of-multi-agent-systems/)

Evidence quality: weaker than the first-person repository reports above. The coverage reviewed repeats an attributed narrative; it does not independently establish the invoice or provide a detailed public incident investigation. Treat it as a reported anecdote, not a settled case study.

## 9. A $50 initial payment allegedly became $12,229 in usage

A crowdsourced incident archive describes a developer whose agent generated $12,229 in API charges after an initial $50 payment. The archive attributes the incident to a social-media post and claims no effective spending cap stopped the accumulation. [agenthorrorstories](https://www.agenthorrorstories.com/story/12229-in-api-calls-developer-only-paid-50-ieyd)

The distinction matters: a $50 payment is not necessarily a contractual $50 hard limit. However, the material reviewed does not establish the provider, billing terms, detailed chronology, or final amount paid. [agenthorrorstories](https://www.agenthorrorstories.com/story/12229-in-api-calls-developer-only-paid-50-ieyd)

Evidence quality: low-confidence social-media-derived account. Worth flagging; not strong enough to present as a verified five-figure liability.

## 10. $1,100 in API debt, plus loss of control of the running agent

The same archive summarizes a social-media account in which an agent accumulated approximately $1,100 in API debt, lost its task/identity context, and left the operator struggling to regain control until processes were killed. [agenthorrorstories](https://www.agenthorrorstories.com/)

Evidence quality: low-confidence archive summary. It lacks enough independently checked technical detail to confidently reconstruct the failure or establish the final bill.

## 11. A stolen Gemini API key → $82,314.44 in 48 hours

This is a major AI billing horror story, but it is not an autonomous agent deciding to overspend.

A small development team reported that a compromised Gemini API key generated $82,314.44 in charges over approximately 48 hours, compared with normal spending of about $180 per month. Coverage says the key was used for Gemini image and text generation. The victim reported deleting the key, disabling APIs, rotating credentials, and opening a support case. [tech.yahoo](https://tech.yahoo.com/ai/gemini/articles/gemini-api-key-thief-racks-110000550.html)

At the time of that coverage, the team feared the charges could bankrupt the business. That does not establish that bankruptcy occurred or that the full amount was ultimately collected. [tech.yahoo](https://tech.yahoo.com/ai/gemini/articles/gemini-api-key-thief-racks-110000550.html)

What went wrong: compromised credentials provided access to expensive metered inference. It belongs beside agent-cost incidents because the financial exposure is similar, but calling it “an agent ran away” would misstate the event.

Evidence quality: technology reporting based on the victim’s public account; the final billing resolution is not established here.

## 12. A claimed $75,000 weekend retry storm

A crowdsourced archive lists a Lambda-powered AI image-processing API that allegedly generated a $75,000 bill in 48 hours after a traffic spike collided with broken error handling. Its summary describes millions of retries cascading across chained services. [agenthorrorstories](https://www.agenthorrorstories.com/)

This is primarily a serverless/distributed-systems retry-storm story, not necessarily an LLM agent choosing actions autonomously.

Evidence quality: weak in the material available. The archive points to Reddit, but the original technical account and invoice were not verified here. I would not repeat the $75,000 figure as established fact.

## Claims I would not put on a “verified disasters” slide

Several articles also repeat a $4,200 long-weekend agent bill and a $1.3 million month involving roughly 100 agent instances, 603 billion tokens, and 7.6 million requests. The source reviewed does not provide enough underlying evidence to establish those as accidental overspending incidents rather than anecdotes, intentional high-volume use, or some other billing arrangement. [entoura](https://www.entoura.studio/resources/articles/how-i-burned-a-weeks-budget-in-a-day/)

Likewise, another vendor blog tells a dramatic story about an agent provisioning 340 EC2 instances and producing a $47,000 Sunday-morning AWS bill, but the article does not identify a verifiable affected organization or supply a public incident report. That is a different story from the $47,000 eleven-day agent loop, despite the matching dollar amount. [octopodas](https://octopodas.com/blog/ai-agents-gone-rogue-real-cases)

## What connects the credible stories

The recurring failure modes are more specific than “AI is expensive”:

| Failure mode | How the money escapes | Illustrative report |
|---|---|---|
| Unbounded retries | The same failed step keeps purchasing inference | Approximately 27 million tokens in 4.6 hours.  [github](https://github.com/anthropics/claude-code/issues/15909) |
| Delegated infrastructure authority | A task becomes permission to create and run cloud resources | DN42 scanning and the $6,531 AWS bill.  [arcade](https://www.arcade.dev/blog/ai-agent-did-its-job-authorization/) |
| Billing-route confusion | Subscription use becomes separately metered API use | The reported $1,800 automation incident.  [github](https://github.com/anthropics/claude-code/issues/37686) |
| Credential inheritance | Workspace or child-process environment changes which account pays | Desktop and subagent API-key reports.  [github](https://github.com/anthropics/claude-code/issues/53638) |
| Incorrect cost modelling | Pagination or request multiplication invalidates the estimate | The Google Places import complaint.  [github](https://github.com/anthropics/claude-code/issues/43758) |
| Credential compromise | An attacker buys inference using someone else’s account | The reported $82,314.44 Gemini incident.  [tech.yahoo](https://tech.yahoo.com/ai/gemini/articles/gemini-api-key-thief-racks-110000550.html) |

The most unsettling case is arguably the DN42 one: the agent did not have to rebel, invent a tool, or ignore every instruction. It had a goal, usable credentials, and an operator willing to approve its plan. That was enough to produce a substantial bill. [arcade](https://www.arcade.dev/blog/ai-agent-did-its-job-authorization/)
