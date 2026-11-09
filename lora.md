
# Lecture kit: Low-Rank Adaptation (LoRA) and Fine-Tuning

The central idea of your lecture should be: fine-tuning adapts a pretrained model to a task or distribution; **LoRA** makes that adaptation more parameter-efficient by learning a small, low-rank weight update while keeping the original model weights frozen. QLoRA adds quantization of the frozen base model to reduce memory requirements further.  [arxiv](https://arxiv.org/abs/2106.09685)

Below is a lecture-ready package with a teaching sequence, mathematical derivations, diagrams, implementation examples, experiments, discussion questions, and an annotated resource collection.

The proposed format is a three-hour technical lecture plus a separate hands-on lab. The audience is assumed to know basic Python, neural networks, gradient descent, and matrix multiplication. The mathematical and production sections can serve as optional advanced material.

## 1. Lecture structure and learning outcomes

### Learning outcomes

By the end, participants should be able to:

1. Distinguish training objectives—such as supervised fine-tuning—from parameter-update methods such as full fine-tuning and LoRA.
2. Derive LoRA’s forward pass and trainable parameter count.
3. Explain rank, scaling, initialization, and target-module selection.
4. Explain why LoRA reduces some memory costs but does not eliminate model computation.
5. Distinguish LoRA from QLoRA.
6. Configure a small adapter-training experiment using Hugging Face PEFT and TRL.
7. Evaluate whether adaptation improved actual task performance.
8. Describe adapter saving, loading, merging, and deployment.

These outcomes follow the original LoRA formulation and the practical workflows documented by PEFT and TRL.  [arxiv](https://arxiv.org/abs/2106.09685)

### Suggested three-hour agenda

| Time | Section | Main teaching artifact |
|---|---|---|
| 0–15 min | Why adapt pretrained models? | Problem and terminology map |
| 15–35 min | Fine-tuning fundamentals | Dataset and loss walkthrough |
| 35–60 min | LoRA intuition and mathematics | Matrix-shape derivation |
| 60–80 min | Memory, computation, and QLoRA | Memory ledger |
| 80–90 min | Break | — |
| 90–120 min | Implementation | PyTorch and PEFT examples |
| 120–140 min | Data and evaluation | Failure-case analysis |
| 140–155 min | Hyperparameters and variants | Experiment matrix |
| 155–170 min | Serving and operations | Adapter deployment diagram |
| 170–180 min | Quiz and discussion | Concept checks |

For a 90-minute version, retain the terminology map, mathematical derivation, QLoRA explanation, one PEFT example, and evaluation section.

## 2. Establish the terminology before teaching the mechanism

A common source of confusion is mixing “what objective are we training?” with “which parameters are we updating?” TRL’s supervised fine-tuning trainer, for example, can train adapters through PEFT rather than update the entire model.  [huggingface](https://huggingface.co/docs/trl/main/en/sft_trainer)

### Diagram 1: Two independent axes

```text
                     MODEL ADAPTATION
                            |
          +-----------------+------------------+
          |                                    |
   Training objective                   Parameter strategy
   "What is learned?"                   "What can change?"
          |                                    |
          +-- Language modeling                +-- Full fine-tuning
          +-- Supervised instruction tuning    +-- Selected layers / head
          +-- Preference optimization          +-- LoRA / other PEFT
```

Teaching sentence:

> “SFT tells us what loss and data we use; LoRA tells us how we parameterize the trainable changes.”

### Adaptation methods to compare

| Method | What changes? | Main teaching point |
|---|---|---|
| Prompting / in-context learning | Input context | No parameter training |
| Frozen feature extraction | A downstream predictor | Reuse model representations |
| Head-only or partial fine-tuning | A subset of original parameters | Restrict which existing weights change |
| Full fine-tuning | All or nearly all model parameters | Most flexible parameter-update baseline |
| LoRA | Added low-rank update matrices | Freeze the base and train a compact update |

These distinctions are developed in Raschka’s overviews of pretrained-model use and fine-tuning.  [magazine.sebastianraschka](https://magazine.sebastianraschka.com/p/using-and-finetuning-pretrained-transformers)

### Important limitation to state early

LoRA is not a guarantee that adaptation will match full fine-tuning on every task. Its original results demonstrate strong performance on the evaluated models and tasks; rank, training data, target modules, and optimization still matter.  [arxiv](https://arxiv.org/abs/2106.09685)

## 3. Fine-tuning fundamentals

### 3.1 What is being optimized?

For a causal language model, a basic training objective is next-token prediction:

\[
\mathcal{L}(\theta)
=
-\sum_{i=1}^{N}\sum_{t=1}^{T_i}
m_{i,t}
\log p_\theta(x_{i,t}\mid x_{i,<t}),
\]

where:

- \(\theta\) denotes the trainable model parameters.
- \(x_{i,t}\) is token \(t\) in example \(i\).
- \(m_{i,t}\) selects which tokens contribute to the loss.

In instruction training, this mask can restrict supervision to completion or assistant tokens. The exact masking behavior depends on dataset format, trainer settings, and chat-template support. TRL documents these distinctions in its SFT trainer.  [huggingface](https://huggingface.co/docs/trl/main/en/sft_trainer)

### 3.2 Example training record

An illustrative conversational example:

```json
{
  "messages": [
    {
      "role": "system",
      "content": "You explain cloud operations clearly and avoid unsafe actions."
    },
    {
      "role": "user",
      "content": "What does HTTP 429 indicate?"
    },
    {
      "role": "assistant",
      "content": "HTTP 429 indicates that a request has been rate limited."
    }
  ]
}
```

Use this example to ask:

- Which tokens should contribute to the loss?
- What chat template converts these messages into tokens?
- Does the model learn the intended behavior or merely memorize phrasing?
- How will the lecture’s evaluation distinguish those outcomes?

### 3.3 The training pipeline

```text
Raw examples
     |
     v
Clean / deduplicate / define split boundaries
     |
     v
Apply prompt or chat template
     |
     v
Tokenize / truncate / create loss masks
     |
     v
Forward pass -> loss -> backward pass -> optimizer step
     |
     v
Validation and task evaluation
     |
     v
Save selected checkpoint
```

TRL provides the training framework, dataset-format support, and PEFT integration for this workflow.  [huggingface](https://huggingface.co/docs/trl/main/en/sft_trainer)

## 4. LoRA: intuition before algebra

### 4.1 The motivating question

Suppose a pretrained linear layer has weights \(W_0\). Full fine-tuning can learn a dense change \(\Delta W\):

\[
W_{\text{adapted}}=W_0+\Delta W.
\]

LoRA instead parameterizes that update as the product of two smaller matrices:

\[
\Delta W=sBA.
\]

Rather than first computing a dense fine-tuned update and decomposing it afterward, LoRA trains \(A\) and \(B\) directly. The pretrained \(W_0\) remains frozen.  [arxiv](https://arxiv.org/abs/2106.09685)

### 4.2 The key conceptual distinction

The low-rank restriction applies to the update, not necessarily to the original model weight:

\[
\operatorname{rank}(BA)\le r.
\]

It does not imply:

\[
\operatorname{rank}(W_0)\le r.
\]

Explain this with an analogy:

> “We are not replacing the entire pretrained capability with a small model. We are expressing the task-specific correction through a small trainable pathway.”

This is the central interpretation of LoRA’s low-rank adaptation mechanism.  [arxiv](https://arxiv.org/abs/2106.09685)

### Diagram 2: LoRA’s parallel computation

```text
                         x
                         |
             +-----------+-----------+
             |                       |
             v                       v
       W0: frozen                 A: trainable
       d_in -> d_out              d_in -> r
             |                       |
             |                       v
             |                    B: trainable
             |                    r -> d_out
             |                       |
             |                       v
             |                  scale by s
             |                       |
             +-----------+-----------+
                         |
                         v
                    add outputs
                         |
                         v
                         y
```

The original paper and PEFT conceptual guide are appropriate authoritative sources for this figure’s mechanism.  [arxiv](https://arxiv.org/abs/2106.09685)

## 5. LoRA mathematics: lecture derivation

### 5.1 Matrix shapes

Use column-vector notation consistently:

\[
x\in\mathbb{R}^{d_{\text{in}}},
\qquad
W_0\in\mathbb{R}^{d_{\text{out}}\times d_{\text{in}}}.
\]

Define:

\[
A\in\mathbb{R}^{r\times d_{\text{in}}},
\qquad
B\in\mathbb{R}^{d_{\text{out}}\times r}.
\]

Then:

\[
y=W_0x+\frac{\alpha}{r}BAx.
\]

The original LoRA scaling is \(s=\alpha/r\).  [arxiv](https://arxiv.org/abs/2106.09685)

Walk through the shapes:

```text
x       : d_in
A x     : r
B A x   : d_out
W0 x    : d_out
sum     : d_out
```

### 5.2 Parameter-count derivation

A dense update requires:

\[
N_{\text{dense}}=d_{\text{out}}d_{\text{in}}.
\]

LoRA requires:

\[
N_{\text{LoRA}}=r(d_{\text{in}}+d_{\text{out}}).
\]

For a square \(d\times d\) layer:

\[
\frac{N_{\text{LoRA}}}{N_{\text{dense}}}
=
\frac{2r}{d}.
\]

Illustrative example:

- \(d=4096\)
- \(r=8\)
- Dense matrix: \(16{,}777{,}216\) parameters
- LoRA matrices: \(65{,}536\) parameters
- LoRA update parameters: approximately \(0.39\%\) of the dense matrix’s parameters

These numbers describe one targeted matrix, not the whole model. Total adapter size depends on how many matrices receive adapters and whether other modules are trainable. The formula follows directly from LoRA’s factorization.  [arxiv](https://arxiv.org/abs/2106.09685)

### 5.3 Initialization

A standard initialization uses:

- Randomly initialized \(A\).
- Zero-initialized \(B\).

Therefore:

\[
BA=0
\]

at initialization, so the adapter initially makes no change to the base layer’s output. PEFT’s default implementation uses Kaiming-uniform initialization for \(A\) and zeros for \(B\).  [huggingface](https://huggingface.co/docs/peft/main/conceptual_guides/lora)

### 5.4 Advanced board-work: gradient flow

Let \(G=\partial\mathcal L/\partial W_{\text{effective}}\), with:

\[
W_{\text{effective}}=W_0+sBA.
\]

Then:

\[
\frac{\partial \mathcal L}{\partial B}
=
sGA^\top,
\]

\[
\frac{\partial \mathcal L}{\partial A}
=
sB^\top G.
\]

A useful consequence: when \(B=0\), the first backward pass gives zero data-loss gradient for \(A\), while \(B\) can receive a nonzero gradient. Once \(B\) changes, both factors can learn.

This derivation connects the LoRA parameterization and initialization rather than introducing an additional algorithm.  [arxiv](https://arxiv.org/abs/2106.09685)

## 6. Where LoRA enters a transformer

Transformer blocks contain multiple projection matrices. Common adapter targets include attention projections and feed-forward projections; architecture-specific names differ. PEFT supports explicit module names as well as broader targeting through `target_modules="all-linear"`.  [huggingface](https://huggingface.co/docs/trl/main/peft_integration)

### Diagram 3: Placement inside a transformer block

```text
Input hidden states
        |
        v
Normalization
        |
        v
Attention
   ├── Q projection   <- possible LoRA
   ├── K projection   <- possible LoRA
   ├── V projection   <- possible LoRA
   └── Output projection <- possible LoRA
        |
        v
Residual connection
        |
        v
Normalization
        |
        v
Feed-forward network
   ├── Up / gate projections <- possible LoRA
   └── Down projection      <- possible LoRA
        |
        v
Residual connection
```

### What to explain

- Target selection changes the adaptation capacity and parameter budget.
- Restricting adapters to a few attention projections is not the same experiment as targeting all eligible linear layers.
- Module names such as `q_proj` or `v_proj` are not universal across architectures.
- Additional trainable modules—such as a classification head—may need `modules_to_save`.  [huggingface](https://huggingface.co/docs/trl/main/peft_integration)

## 7. Memory and computation: avoid misleading claims

### 7.1 A memory ledger

Teach memory as several separate terms:

\[
M_{\text{total}}
\approx
M_{\text{weights}}
+
M_{\text{gradients}}
+
M_{\text{optimizer}}
+
M_{\text{activations}}
+
M_{\text{temporary}}.
\]

Use this conceptual ledger to explain what LoRA and QLoRA actually change:

| Component | Full fine-tuning | LoRA | QLoRA |
|---|---|---|---|
| Base weights | Stored | Stored, frozen | Stored in quantized form, frozen |
| Base-weight gradients | Required for trainable weights | Not accumulated for frozen base | Not accumulated for frozen base |
| Base optimizer state | Required for trainable weights | Not needed for frozen base | Not needed for frozen base |
| Adapter weights and state | Not applicable | Required | Required |
| Activations and temporary buffers | Required | Still required | Still required |

LoRA chiefly reduces trainable-parameter-related state; QLoRA additionally reduces the frozen base’s storage footprint. Neither eliminates the forward computation through the base model.  [arxiv](https://arxiv.org/abs/2106.09685)

### 7.2 Why “100× fewer trainable parameters” does not mean “100× faster”

Even with frozen weights, gradients must propagate through the network to train adapters in earlier layers. Base-model matrix operations, activations, sequence length, batch size, kernel efficiency, and quantization overhead still affect runtime.

Raschka’s experiments illustrate that QLoRA can trade lower memory use for longer training time; those measured percentages are specific to that experimental setup, not universal constants.  [magazine.sebastianraschka](https://magazine.sebastianraschka.com/p/practical-tips-for-finetuning-llms)

Teaching warning:

> “Parameter efficiency, memory efficiency, and wall-clock efficiency are related but different measurements.”

## 8. QLoRA: quantization plus adapter training

### 8.1 Core idea

QLoRA backpropagates through a frozen, 4-bit quantized pretrained model into trainable low-rank adapters. It does not mean all computations or adapter parameters use 4-bit precision.  [github](https://github.com/artidoro/qlora/)

```text
Frozen pretrained weights
stored in 4-bit representation
            |
            v
Dequantize as needed for computation
            |
            +-----------------------+
            |                       |
            v                       v
     Base computation       Trainable LoRA pathway
            |                       |
            +-----------+-----------+
                        |
                        v
                       loss
                        |
                        v
             Update adapter parameters
```

### 8.2 Three ideas to cover

| Component | Explanation |
|---|---|
| NF4 | A 4-bit quantization format designed for normally distributed weights |
| Double quantization | Quantization of quantization constants to reduce storage overhead |
| Paged optimizers | Memory-management technique used to handle optimizer-related memory spikes |

These are core elements of the QLoRA work and its implementation.  [github](https://github.com/artidoro/qlora/)

### 8.3 Historical result, with the correct qualification

The QLoRA authors reported fine-tuning a 65-billion-parameter model on a single 48 GB GPU in their experimental setup. Present this as a result from the paper—not a guarantee that every 65B model, sequence length, batch size, or software configuration will fit that hardware.  [github](https://github.com/artidoro/qlora/)

## 9. From-scratch PyTorch teaching example

The following is an illustrative implementation for a dense linear layer. It deliberately omits dropout, quantization, adapter management, distributed training, and model-specific integration so that the basic mechanism remains visible.

It follows the standard frozen-base, random-\(A\), zero-\(B\), scaled-update construction.  [arxiv](https://arxiv.org/abs/2106.09685)

```python
import math
import torch
from torch import nn
import torch.nn.functional as F


class LoRALinear(nn.Module):
    def __init__(self, base_layer: nn.Linear, rank=8, alpha=16):
        super().__init__()

        if rank <= 0:
            raise ValueError("rank must be positive")

        self.base = base_layer
        self.rank = rank
        self.scaling = alpha / rank

        for parameter in self.base.parameters():
            parameter.requires_grad = False

        self.A = nn.Parameter(
            self.base.weight.new_empty(rank, self.base.in_features)
        )
        self.B = nn.Parameter(
            self.base.weight.new_zeros(self.base.out_features, rank)
        )

        nn.init.kaiming_uniform_(self.A, a=math.sqrt(5))

    def forward(self, x):
        base_output = self.base(x)
        adapter_output = F.linear(F.linear(x, self.A), self.B)
        return base_output + self.scaling * adapter_output

    @torch.no_grad()
    def merged_weight(self):
        return self.base.weight + self.scaling * (self.B @ self.A)
```

### Demonstrations to perform live

1. Compare the layer output before training with the original base layer.
2. Print trainable and frozen parameter counts.
3. Take one optimization step.
4. Inspect gradients for \(A\) and \(B\).
5. Compare separate-path inference with inference using the merged weight.

For a basic numerical check:

```python
base = nn.Linear(16, 12)
layer = LoRALinear(base, rank=4, alpha=8)

x = torch.randn(5, 16)

with torch.no_grad():
    layer.B.normal_(mean=0.0, std=0.01)

separate = layer(x)
merged = F.linear(x, layer.merged_weight(), layer.base.bias)

assert torch.allclose(separate, merged, atol=1e-6)
```

Clarify that mathematical equivalence does not imply bitwise identity under every floating-point or quantized implementation. The merge principle is documented in PEFT.  [huggingface](https://huggingface.co/docs/peft/main/conceptual_guides/lora)

## 10. Practical lab with Hugging Face PEFT and TRL

### 10.1 Lab objective

Adapt a small causal language model to a narrow instruction-following task, such as:

- Producing structured incident summaries.
- Explaining cloud-platform concepts in a consistent format.
- Classifying support requests with short rationales.

These are suggested teaching projects, not claims about guaranteed model capability.

Start with a small model so participants can inspect the entire process before introducing larger-model memory constraints.

### 10.2 Environment preparation

```bash
pip install torch transformers datasets accelerate peft trl
```

For a QLoRA extension:

```bash
pip install bitsandbytes
```

Before delivering the lecture, test the complete environment and pin the versions that worked. The examples below follow the documented TRL/PEFT integration pattern, but they have not been executed here; library APIs and hardware support should be verified in the teaching environment.  [huggingface](https://huggingface.co/docs/trl/main/en/sft_trainer)

### 10.3 Minimal LoRA SFT example

```python
from datasets import load_dataset
from peft import LoraConfig
from transformers import AutoTokenizer
from trl import SFTConfig, SFTTrainer

model_id = "Qwen/Qwen3-0.6B"

tokenizer = AutoTokenizer.from_pretrained(model_id)

dataset = load_dataset(
    "trl-lib/Capybara",
    split="train",
)

split = dataset.train_test_split(
    test_size=0.05,
    seed=42,
)

lora_config = LoraConfig(
    task_type="CAUSAL_LM",
    r=16,
    lora_alpha=32,
    lora_dropout=0.05,
    target_modules="all-linear",
    bias="none",
)

training_config = SFTConfig(
    output_dir="lecture-lora",
    max_length=512,
    learning_rate=2e-4,
    num_train_epochs=1,
    per_device_train_batch_size=1,
    gradient_accumulation_steps=8,
    logging_steps=10,
    eval_strategy="steps",
    eval_steps=50,
    save_steps=50,
    report_to="none",
)

trainer = SFTTrainer(
    model=model_id,
    args=training_config,
    train_dataset=split["train"],
    eval_dataset=split["test"],
    processing_class=tokenizer,
    peft_config=lora_config,
)

trainer.model.print_trainable_parameters()
trainer.train()

trainer.save_model("lecture-lora-adapter")
tokenizer.save_pretrained("lecture-lora-adapter")
```

The model/dataset pairing appears in the TRL SFT documentation; the LoRA configuration follows the documented PEFT integration approach. The hyperparameters here are starting points for a demonstration, not validated optimal settings.  [huggingface](https://huggingface.co/docs/trl/main/en/sft_trainer)

For a production-quality experiment, replace the random split with task-appropriate leakage-resistant partitions.

### 10.4 QLoRA loading modification

The essential change is to load the base model with quantization and prepare it for low-bit training before adding adapters.  [huggingface](https://huggingface.co/docs/peft/developer_guides/quantization)

```python
import torch

from transformers import (
    AutoModelForCausalLM,
    BitsAndBytesConfig,
)
from peft import prepare_model_for_kbit_training

compute_dtype = (
    torch.bfloat16
    if torch.cuda.is_bf16_supported()
    else torch.float16
)

quantization_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_use_double_quant=True,
    bnb_4bit_compute_dtype=compute_dtype,
)

model = AutoModelForCausalLM.from_pretrained(
    model_id,
    quantization_config=quantization_config,
    device_map={"": torch.cuda.current_device()},
)

model.config.use_cache = False

model = prepare_model_for_kbit_training(
    model,
    use_gradient_checkpointing=True,
)
```

Pass this `model` into `SFTTrainer` instead of the model identifier, along with the LoRA configuration. This fragment assumes a compatible single-GPU CUDA environment; it is not a distributed-training recipe. The quantization settings follow PEFT’s quantization guide.  [huggingface](https://huggingface.co/docs/peft/developer_guides/quantization)

## 11. Hyperparameters: what students should understand

| Setting | What it controls | Suggested teaching experiment |
|---|---|---|
| Rank \(r\) | Capacity and size of each low-rank update | Compare 4, 16, and 64 |
| `lora_alpha` | Update scaling | Hold \(\alpha/r\) fixed during an initial rank sweep |
| Target modules | Where adaptation occurs | Compare selected attention projections with all eligible linear layers |
| Learning rate | Optimization step scale | Compare a few values on a logarithmic scale |
| Dropout | Regularization of the adapter pathway | Compare zero with a small nonzero value |
| Sequence length | Amount of context processed | Measure truncation and memory effects |
| Epochs | Number of dataset passes | Watch for overfitting |
| Batch/accumulation | Effective optimization batch | Record examples and supervised tokens per update |

PEFT documents the configuration controls, while Raschka’s experiments provide useful examples of rank, scaling, target-layer, and overfitting trade-offs.  [huggingface](https://huggingface.co/docs/peft/package_reference/lora)

### Avoid teaching heuristics as laws

Examples:

- “Set alpha to twice rank” can be a starting heuristic, not a theorem.
- Larger rank is not automatically better.
- Lower validation loss is not automatically better task performance.
- Targeting more modules changes both capacity and cost.
- QLoRA is not automatically faster than LoRA.  [magazine.sebastianraschka](https://magazine.sebastianraschka.com/p/practical-tips-for-finetuning-llms)

## 12. Data and evaluation: make this a major section

The following is a proposed evaluation protocol for the lecture lab.

### 12.1 Data checklist

Before training, have participants document:

- Intended task and excluded behaviors.
- Data source and usage rights.
- Duplicate and near-duplicate handling.
- Train/validation/test boundaries.
- Prompt and response formatting.
- Token-length distribution.
- Which tokens contribute to the loss.
- Whether examples contain sensitive material.

TRL’s dataset-format and masking documentation is the implementation reference for checking that the intended examples and loss actually reach the trainer.  [huggingface](https://huggingface.co/docs/trl/main/en/sft_trainer)

### 12.2 Evaluation matrix

| Dimension | Example measurement |
|---|---|
| Task quality | Accuracy, extraction F1, rubric score |
| Format compliance | Valid JSON percentage, required-field completeness |
| Grounding | Unsupported claims on an independently reviewed sample |
| Robustness | Paraphrases, malformed input, long input |
| Retention | Performance on a small general-capability regression set |
| Safety | Response to unsafe or unauthorized requests |
| Efficiency | Peak memory, training time, inference latency, adapter size |

### 12.3 Compare at least three conditions

```text
A. Base model + original prompt
B. Base model + improved prompt
C. LoRA-adapted model + fixed evaluation prompt
```

If resources permit:

```text
D. QLoRA-adapted model
E. Full fine-tuning baseline
```

Keep evaluation prompts and decoding settings fixed when making comparisons. Treat this as experimental design, rather than assuming the adapter’s training loss proves improvement.

### 12.4 Failure cases to discuss

Use examples where:

- Training loss improves but held-out task quality declines.
- The output format improves but factual accuracy does not.
- Prompt tokens are supervised unintentionally.
- Truncation removes the useful answer.
- The adapter loads against a different base-model revision.
- A merged artifact performs differently from the separately loaded adapter.

The practical relevance of masking, overfitting, module selection, and merging is reflected in the TRL, PEFT, and experimental resources.  [huggingface](https://huggingface.co/docs/trl/main/en/sft_trainer)

## 13. Adapter saving, merging, and production deployment

### 13.1 Separate adapter serving

```text
                    Shared base model
                           |
             +-------------+-------------+
             |             |             |
         Adapter A     Adapter B     Adapter C
         Task A        Task B        Task C
```

A major operational benefit is that task-specific adapter artifacts can be stored separately from the base model. PEFT provides the relevant adapter loading and merging operations.  [huggingface](https://huggingface.co/docs/peft/main/conceptual_guides/lora)

### 13.2 Merging

For an ordinary dense LoRA layer:

\[
W_{\text{merged}}
=
W_0+\frac{\alpha}{r}BA.
\]

PEFT exposes:

```python
merged_model = peft_model.merge_and_unload()
```

The returned model must be retained; `merge_and_unload()` is not simply an in-place toggle. It removes the separate adapter structure. `merge_adapter()` and `unmerge_adapter()` support a different workflow in which the PEFT model is retained.  [huggingface](https://huggingface.co/docs/peft/package_reference/lora)

### 13.3 Deployment trade-off

| Separate adapter | Merged model |
|---|---|
| Retains adapter identity and switching flexibility | Produces a standalone adapted model |
| Requires adapter-aware serving | Can avoid separate LoRA-path inference overhead |
| Useful when sharing a base across tasks | Useful when deploying a fixed adapted model |

The “no additional inference latency” claim should be explained in the context of merging, not as a guarantee that every unmerged adapter-serving configuration has zero overhead. Quantized merging should be tested with the exact supported implementation and evaluated again after conversion.  [huggingface](https://huggingface.co/docs/peft/main/conceptual_guides/lora)

### 13.4 Suggested release manifest

For a reproducible teaching or production artifact, record:

```text
base_model_id
base_model_revision
tokenizer_revision
adapter_configuration
training_data_version
code_revision
dependency_versions
training_seed
training_arguments
evaluation_results
merge_or_quantization_procedure
```

For your audience, this is a useful connection to supply-chain integrity, model registries, observability, rollback, and multi-tenant deployment.

## 14. Advanced extensions

Teach these after participants understand ordinary LoRA.

| Method | Main change | Teaching value |
|---|---|---|
| rsLoRA | Uses \(\alpha/\sqrt r\) instead of \(\alpha/r\) | Shows why scaling matters when varying rank |
| DoRA | Separates magnitude and direction; uses LoRA for direction | Shows that low-rank adaptation can be extended beyond the original parameterization |
| LoftQ | Initializes adapters to reduce quantization error | Connects adapter initialization with quantization |
| LoRA-FA | Fixes \(A\) and trains \(B\) | Connects parameterization with activation-memory optimization |

These variants and their practical constraints are documented in PEFT. DoRA, for example, introduces additional overhead and has layer/support constraints; it should not be presented as a universally better drop-in replacement.  [huggingface](https://huggingface.co/docs/peft/main/en/developer_guides/lora.md)

A good advanced discussion question:

> “When changing rank, what else must we hold fixed to make the comparison interpretable?”

Expected considerations include target modules, scaling rule, optimizer settings, training tokens, and evaluation procedure.

## 15. Pictures and diagrams to include in the slide deck

### Recommended visual sequence

| Figure | Purpose | Source or preparation |
|---|---|---|
| Training objective vs parameter strategy | Prevent terminology confusion | Recreate Diagram 1 |
| Parallel frozen and trainable paths | Explain LoRA’s mechanism | Original paper and PEFT conceptual guide |
| Matrix shapes and parameter counts | Make the savings concrete | Recreate from Section 5 |
| Transformer target-module map | Explain adapter placement | Recreate Diagram 3 |
| Memory ledger | Separate weights, optimizer state, and activations | Recreate Section 7 |
| QLoRA dataflow | Distinguish storage precision from computation | QLoRA repository/paper |
| Separate vs merged serving | Explain deployment trade-offs | PEFT merge documentation |
| Rank/quality/memory plots | Teach experimental reasoning | Generate from the lab’s own measurements |

The original LoRA paper, QLoRA project, and PEFT guides are the strongest sources for mechanism diagrams.  [arxiv](https://arxiv.org/abs/2106.09685)

For slides, prefer redrawing simple diagrams in a consistent style and citing the underlying source. Check licensing or reuse permissions before copying third-party figures; search-image availability does not establish permission.

## 16. Annotated papers, documentation, GitHub repositories, and blogs

The links below are intended as the lecture’s working resource collection.

### 16.1 Foundational papers and original code

| Resource | Link | How to use it |
|---|---|---|
| Hu et al., “LoRA: Low-Rank Adaptation of Large Language Models” | [Paper](https://arxiv.org/abs/2106.09685) | Core equations, motivation, experiments, limitations |
| Microsoft LoRA / `loralib` | [GitHub](https://github.com/microsoft/LoRA) | Inspect the original implementation |
| Dettmers et al., “QLoRA: Efficient Finetuning of Quantized LLMs” | [Paper](https://arxiv.org/abs/2305.14314) | Quantization and memory-efficient adaptation |
| Original QLoRA project | [GitHub](https://github.com/artidoro/qlora/) | Implementation, configurations, paper details |

The LoRA preprint was first submitted in June 2021; the QLoRA project identifies its paper as a 2023 work. Use these as the two historical anchors rather than trying to survey every subsequent variant.  [arxiv](https://arxiv.org/abs/2106.09685)

### 16.2 Implementation repositories

| Repository | Link | Role in the lecture |
|---|---|---|
| Hugging Face PEFT | [GitHub](https://github.com/huggingface/peft) | Adapter configuration and management |
| Hugging Face TRL | [GitHub](https://github.com/huggingface/trl) | SFT and other post-training workflows |
| Hugging Face Transformers | [GitHub](https://github.com/huggingface/transformers) | Model loading and transformer implementations |
| Original Microsoft LoRA | [GitHub](https://github.com/microsoft/LoRA) | Minimal historical implementation |
| Original QLoRA | [GitHub](https://github.com/artidoro/qlora/) | Quantized-adaptation reference |

PEFT, TRL, and Transformers form the documented practical integration path; the original repositories provide a useful contrast with the higher-level APIs.  [github](https://github.com/microsoft/lora)

### 16.3 Official documentation

| Resource | Link | Best use |
|---|---|---|
| PEFT conceptual LoRA guide | [Guide](https://huggingface.co/docs/peft/main/conceptual_guides/lora) | Introductory explanation and diagram |
| PEFT LoRA developer guide | [Guide](https://huggingface.co/docs/peft/developer_guides/lora) | Configuration, variants, practical caveats |
| PEFT LoRA API reference | [Reference](https://huggingface.co/docs/peft/package_reference/lora) | Exact argument meanings and merge behavior |
| PEFT quantization guide | [Guide](https://huggingface.co/docs/peft/developer_guides/quantization) | QLoRA preparation and configuration |
| TRL SFT trainer | [Guide](https://huggingface.co/docs/trl/main/en/sft_trainer) | Dataset formats, trainer usage, loss controls |
| TRL PEFT integration | [Guide](https://huggingface.co/docs/trl/en/peft_integration) | Connecting adapter methods to training |

These pages should be the implementation references students consult during the lab. Pin to documentation matching your tested package versions before delivery.  [huggingface](https://huggingface.co/docs/peft/main/conceptual_guides/lora)

### 16.4 Blogs and teaching articles

| Article | Link | Why include it |
|---|---|---|
| Sebastian Raschka, “Practical Tips for Finetuning LLMs Using LoRA” | [Article](https://magazine.sebastianraschka.com/p/practical-tips-for-finetuning-llms) | Experimental discussion of rank, scaling, targets, memory, and runtime |
| Sebastian Raschka, “Using and Finetuning Pretrained Transformers” | [Article](https://magazine.sebastianraschka.com/p/using-and-finetuning-pretrained-transformers) | Broad conceptual introduction |
| Sebastian Raschka, “Finetuning LLMs Efficiently with Adapters” | [Article](https://magazine.sebastianraschka.com/p/finetuning-llms-with-adapters) | Explains other PEFT approaches |
| Sebastian Raschka, “Improving LoRA: Implementing Weight-Decomposed Low-Rank Adaptation” | [Article](https://magazine.sebastianraschka.com/p/lora-and-dora-from-scratch) | Advanced implementation-oriented extension |

Use blog results as examples of particular experiments and explanations, not as universal performance guarantees.  [magazine.sebastianraschka](https://magazine.sebastianraschka.com/p/practical-tips-for-finetuning-llms)

### 16.5 Optional material beyond language models

- [PEFT image-classification LoRA guide](https://huggingface.co/docs/peft/main/en/task_guides/image_classification_lora): useful for demonstrating a task head and `modules_to_save`.  [huggingface](https://huggingface.co/docs/peft/main/en/task_guides/image_classification_lora)
- [PEFT semantic-similarity guide](https://huggingface.co/docs/peft/main/en/task_guides/semantic-similarity-lora): shows adaptation for embedding-related tasks.  [huggingface](https://huggingface.co/docs/peft/main/en/task_guides/semantic-similarity-lora)
- [cloneofsimo/lora](https://github.com/cloneofsimo/lora): an example of applying low-rank adaptation to diffusion-model fine-tuning.  [github](https://github.com/cloneofsimo/lora)
- [TRL multimodal SFT guide](https://huggingface.co/docs/trl/main/en/training_vlm_sft): an optional extension to vision-language models.  [huggingface](https://huggingface.co/docs/trl/main/en/training_vlm_sft)

## 17. Hands-on lab and assignments

### Lab A: Understand the mechanism

Tasks:

1. Implement the small `LoRALinear` example.
2. Verify that initialization preserves the base output.
3. Count trainable parameters.
4. Inspect gradients after the first backward pass.
5. Verify merged and unmerged outputs numerically.

Deliverable: a short notebook explaining each observation.

### Lab B: Train one useful adapter

Tasks:

1. Choose a narrowly defined task.
2. Create or select a small, reviewable dataset.
3. Build a fixed evaluation set.
4. Evaluate the base model.
5. Train a LoRA adapter.
6. Evaluate it with the same prompts and decoding settings.
7. Save the adapter and reproducibility manifest.

Deliverable: a model card and a table of measured improvements and regressions.

### Lab C: Perform an ablation

Choose one variable:

```text
Rank:             4 vs 16 vs 64
Target modules:   selected projections vs all-linear
Base precision:   non-quantized LoRA vs QLoRA
Loss masking:     alternative explicitly documented masks
```

Record:

- Task metric.
- Validation loss.
- Peak GPU memory.
- Training time.
- Adapter size.
- Representative failure cases.

Raschka’s experiments provide a useful model for interpreting trade-offs rather than reporting only the best result.  [magazine.sebastianraschka](https://magazine.sebastianraschka.com/p/practical-tips-for-finetuning-llms)

## 18. Questions and answer key

| Question | Expected answer |
|---|---|
| Is LoRA an alternative to supervised fine-tuning? | Not at the same conceptual level: SFT is an objective/workflow; LoRA is a parameter-update strategy. |
| Does LoRA compress the original weight matrix? | Standard LoRA keeps the base weight and adds a low-rank update. |
| Is the final adapted matrix necessarily low rank? | No. The update is rank-constrained; the sum need not be. |
| Why initialize one factor to zero? | To begin with a zero adapter update while allowing training to start. |
| Does freezing the base remove all backpropagation through it? | No. Gradient propagation is still needed to train adapters. |
| Does QLoRA mean adapters are trained entirely in 4-bit? | No. It quantizes the frozen base; storage and computation precision must be distinguished. |
| Is larger rank always better? | No; it changes capacity and cost, and results depend on the task and training setup. |
| Why merge an adapter? | To create a standalone adapted model and avoid the separate adapter path. |
| Can training loss alone establish success? | No; evaluate held-out task behavior and regressions. |

The mechanism answers are grounded in LoRA, QLoRA, and PEFT documentation; the optimization cautions are supported by the practical experimental discussion.  [arxiv](https://arxiv.org/abs/2106.09685)

## 19. Suggested closing slide

Use these five points:

1. Fine-tuning has separate choices for objective, data, trainable parameters, and numerical precision.
2. LoRA learns a low-rank correction rather than retraining every base weight.
3. QLoRA adds quantized base-model storage; it does not make all training arithmetic 4-bit.
4. Fewer trainable parameters do not translate directly into equal reductions in runtime.
5. A useful adapter is demonstrated by controlled evaluation and reproducible deployment—not by training loss alone.

The first four summarize the relationship between the original LoRA method, QLoRA, and their practical implementations; the fifth is the experimental standard the proposed lab is designed to enforce.  [arxiv](https://arxiv.org/abs/2106.09685)
