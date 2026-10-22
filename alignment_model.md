
DPO, PPO, and REINFORCE-style methods solve the same high-level alignment problem—make an LLM produce responses humans prefer—but differ fundamentally in whether they use an explicit reward model, learn online from generated samples, and how much machinery they need. There is no universally “better” method: **DPO is usually the simplest offline baseline, PPO remains strong when a reliable reward signal and online exploration are available, and REINFORCE variants such as RLOO can match or beat PPO with less complexity in RLHF settings.** [aclanthology](https://aclanthology.org/2024.acl-long.662/)

## Core distinction

| Method | Signal used | Reward model | Training regime | Main complexity |
|---|---|---|---|---|
| **DPO**  | Static pairs \((x,y_w,y_l)\), where \(y_w\) is preferred | Implicit: \(r(x,y)=\beta\log\frac{\pi_\theta(y|x)}{\pi_{\text{ref}}(y|x)}\) | Offline, supervised-style | Low; no rollout/reward-model loop |
| **PPO**  | Scalar rewards from an explicit reward model | Explicit \(r_\phi(x,y)\) | Online RL with generated responses | High; policy, value/critic, reward model, KL control |
| **REINFORCE / RLOO**  | Scalar rewards from an explicit reward model | Explicit \(r_\phi(x,y)\) | Online RL, sequence-level | Moderate; no critic, simpler than PPO |

The shared RLHF objective is to maximize expected reward while keeping the policy close to a reference SFT model:

\[
\max_{\pi_\theta}\mathbb{E}_{x\sim D,y\sim\pi_\theta(y|x)}
\left[r(x,y)-\beta\log\frac{\pi_\theta(y|x)}{\pi_{\text{ref}}(y|x)}\right].
\]

PPO directly optimizes this objective using an explicit reward model; DPO reparameterizes the optimal reward in terms of the policy and reference model, allowing direct policy optimization from preference pairs. [arxiv](https://arxiv.org/html/2407.16216v1)

## DPO: simple, offline preference learning

DPO assumes preferences follow a Bradley–Terry model and derives a classification loss over chosen and rejected responses. It avoids separately training and serving a reward model, replacing the RL loop with a binary cross-entropy-like objective. [arxiv](https://arxiv.org/html/2407.16216v1)

Its implicit reward is:

\[
r_{\text{DPO}}(x,y)=\beta\log\frac{\pi_\theta(y|x)}{\pi_{\text{ref}}(y|x)}.
\]

This makes DPO attractive when you already have high-quality pairwise preference data and want a stable, inexpensive fine-tuning pipeline. [arxiv](https://arxiv.org/html/2407.16216v1)

**Strengths**
- No explicit reward model, value network, or generation-during-training loop.
- Usually much simpler and cheaper to implement than PPO.
- Strong baseline for offline alignment from human or AI preference pairs. [arxiv](https://arxiv.org/html/2407.16216v1)

**Limitations**
- It is fundamentally **offline**: it cannot explore new responses or correct reward-model errors after training begins.
- Standard DPO can favor out-of-distribution responses and may produce verbose outputs; iterative or online DPO can mitigate this by regenerating pairs and updating the reference model. [arxiv](https://arxiv.org/html/2407.16216v1)
- Its quality is bounded by the coverage and correctness of the preference dataset.

## PPO: online RL with explicit rewards

In the InstructGPT formulation, PPO trains an explicit reward model from human preference comparisons, then uses it as the environment reward while optimizing the LLM policy. The objective combines reward maximization, KL regularization to the SFT policy, and optionally a pretraining-language-modeling term to reduce “alignment tax.” [arxiv](https://arxiv.org/html/2407.16216v1)

**Strengths**
- Can learn from the model’s own newly generated outputs, enabling exploration beyond a fixed dataset.
- Often stronger when the reward model is accurate and the task benefits from iterative improvement.
- Comparative work found PPO can surpass DPO-style methods in challenging settings, including code competitions. [arxiv](https://arxiv.org/html/2407.16216v1)

**Limitations**
- Requires an explicit reward model and typically a value/critic model.
- Sensitive to hyperparameters, KL coefficient, batch size, and reward-model overoptimization.
- Computationally expensive because the policy must generate responses during training. [aclanthology](https://aclanthology.org/2024.acl-long.662/)

A key failure mode is **reward hacking**: the policy can exploit flaws in the reward model, achieving high learned reward while producing worse human-preferred text. Anthropic’s RLHF work observed train and test reward scores diverging as training progressed, indicating reward-model overfitting and exploitation. [arxiv](https://arxiv.org/html/2407.16216v1)

## REINFORCE and RLOO: simpler online RL

REINFORCE is the basic policy-gradient method: sample a full response, obtain its reward, and increase the probability of responses with above-baseline reward. Ahmadian et al. argue that many PPO components—such as clipping and a learned value function—are unnecessary for LLM RLHF, and that sequence-level REINFORCE variants can be simpler and more effective. [aclanthology](https://aclanthology.org/2024.acl-long.662/)

Their main variant, **RLOO (REINFORCE Leave-One-Out)**, generates \(k\) responses per prompt and uses the average reward of the other \(k-1\) samples as a baseline for each response. This reduces gradient variance without training a critic. [aclanthology](https://aclanthology.org/2024.acl-long.662/)

\[
A_i = r_i-\frac{1}{k-1}\sum_{j\ne i}r_j.
\]

**Strengths**
- Much simpler than PPO: no critic, no clipping machinery, and no token-level value estimation.
- Uses online samples, so it retains PPO’s exploration advantage over offline DPO.
- In Ahmadian et al.’s experiments, RLOO outperformed PPO and DPO across TL;DR and Anthropic HH settings; reported PPO win rates were 67.6 on TL;DR, 29.2 on HH with Pythia, and 32.0 on HH with Llama, while RLOO achieved the highest win rates. [aclanthology](https://aclanthology.org/2024.acl-long.662/)
- Produced more reasonable response lengths and better fluency/diversity than PPO in their evaluation. [alphaxiv](https://www.alphaxiv.org/ja/abs/2402.14740)

**Limitations**
- Requires multiple sampled completions per prompt, so inference/generation cost can still be substantial.
- Performance depends heavily on reward-model quality, like PPO.
- Results are task- and scale-dependent; “REINFORCE beats PPO” is an empirical finding from particular RLHF setups, not a universal theorem. [aclanthology](https://aclanthology.org/2024.acl-long.662/)

## What the evidence supports

The literature does not produce one clean winner.

- **DPO vs. PPO:** DPO is often competitive at lower cost, but PPO or online variants can outperform it when exploration, accurate rewards, and careful regularization matter. One controlled study found PPO surpassed other alignment methods in all tested cases and achieved state-of-the-art results on difficult code tasks. [arxiv](https://arxiv.org/html/2407.16216v1)
- **PPO vs. REINFORCE/RLOO:** Ahmadian et al. found vanilla policy gradient beat standard PPO by 3.2–20.3 percentage points in win rate across their dataset/model pairings, and RLOO with \(k=4\) gave the best results. [alphaxiv](https://www.alphaxiv.org/ja/abs/2402.14740)
- **DPO vs. REINFORCE/RLOO:** The same study found REINFORCE-style online optimization outperformed “RL-free” DPO and RAFT, suggesting that online interaction with a reward signal can be more important than PPO’s specific machinery. [aclanthology](https://aclanthology.org/2024.acl-long.662/)
- **Online vs. offline:** A major theme is that offline methods can overfit a finite preference dataset, while online methods generate fresh responses and can adapt to the current policy distribution. [arxiv](https://arxiv.org/html/2407.16216v1)

## Practical selection guide

| Situation | Recommended approach |
|---|---|
| You have a fixed, high-quality preference dataset and limited infrastructure | Start with **DPO** |
| You have a trustworthy reward model and want maximum control | Use **PPO** or a well-tuned online RL method |
| You want online RL but want to avoid PPO’s critic and tuning burden | Try **RLOO / REINFORCE-style RL** |
| Your reward model is weak or hackable | Prefer better preference data/reward modeling before scaling any RL method |
| You need continual improvement from new feedback | Use **iterative DPO**, PPO, or RLOO with fresh preference labels |
| You need to minimize deployment/training complexity | DPO first; RLOO if online RL is justified |

## Suggested research framing

For a paper or technical report, frame the comparison along five axes:

1. **Feedback type:** pairwise preferences versus scalar rewards.
2. **Reward model:** explicit versus implicit.
3. **Data regime:** offline fixed dataset versus on-policy generation.
4. **Optimization machinery:** classification loss, actor-critic RL, or Monte Carlo policy gradient.
5. **Failure modes:** distribution shift, reward hacking, verbosity, KL collapse, and alignment tax.

A defensible thesis would be: **DPO optimizes preferences directly but is constrained by its offline data; PPO enables online reward-driven improvement at high complexity; RLOO shows that a stripped-down online policy-gradient method can capture much of PPO’s benefit with less complexity.** [aclanthology](https://aclanthology.org/2024.acl-long.662/)

## Minimal experiment design

To make the comparison rigorous, hold fixed:

- Base model, SFT checkpoint, tokenizer, prompts, decoding temperature, and evaluation harness.
- Preference dataset for DPO; reward model and prompt set for PPO/RLOO.
- Compute budget, including generation tokens, since PPO and RLOO require rollouts while DPO does not.
- Metrics: human/AI win rate, reward-model score on held-out prompts, KL from reference policy, response length, perplexity/fluency, diversity, and downstream benchmark retention.

Then compare:

1. SFT baseline.
2. Offline DPO.
3. PPO with the same reward model.
4. RLOO with \(k\in\{2,4,8\}\).
5. Iterative DPO, if feasible.

Report both **reward-model score** and **independent human or strong-judge win rate**, because reward score alone can reward exploitation of the reward model. [aclanthology](https://aclanthology.org/2024.acl-long.662/)
