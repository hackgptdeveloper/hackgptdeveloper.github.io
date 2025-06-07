---
title: "Vulnerabilities in AI Pipelines"
tags:
  - AI-Pipeline
---

AI pipelines involve various stages—data ingestion, preprocessing, model training, evaluation, deployment, and monitoring—and each can introduce unique security risks. Here's a list of **10 different security risk scenarios**, each mapped to specific pipeline stages with deep technical details, including possible attack vectors, root causes, and real-world examples or references to research/implementations:

---

### **1. Data Poisoning Attacks (Training Pipeline)**

**Pipeline Stage:** Data Ingestion → Preprocessing → Model Training
**Description:** Adversaries inject malicious samples into the training dataset to influence model behavior during inference.

**Example Scenario:**

* A facial recognition system is trained with public image datasets. An attacker adds perturbed samples that cause the model to misclassify certain faces.

**Technical Root Cause:**

* Lack of data validation and provenance tracking.
* Attackers exploit the assumption of IID (independent and identically distributed) data.

**Example Implementation:**

```python
# Poisoning via label flipping
poisoned_data = [(x, wrong_label) for x, _ in selected_clean_data]
```

**CVE/Research Reference:**

* *"Poisoning Attacks against Support Vector Machines"*, Biggio et al. (2012)
* Tools: [Trojaning Attack Tool](https://github.com/ain-soph/trojan-horse-attack)

---

### **2. Model Inversion Attacks (Inference Pipeline)**

**Pipeline Stage:** Model Deployment / Inference
**Description:** An attacker can reconstruct parts of the training data by querying the model and observing outputs.

**Example Scenario:**

* An attacker queries a medical diagnosis ML model hosted via API and reconstructs patient data by leveraging prediction confidence scores.

**Technical Root Cause:**

* Overfitting and too much information leakage through softmax or output logits.

**Example Code Logic:**

```python
# Overexposed output aiding inversion
output_probs = model.predict_proba(input_sample)
```

**Research Reference:**

* *"Model Inversion Attacks that Exploit Confidence Information and Basic Countermeasures"*, Fredrikson et al. (2015)

---

### **3. Adversarial Example Attacks (Inference Pipeline)**

**Pipeline Stage:** Inference
**Description:** Carefully crafted inputs are used to mislead a model at inference time without modifying the model itself.

**Example Scenario:**

* An attacker adds imperceptible noise to an image, causing misclassification (e.g., "stop sign" → "yield").

**Technical Root Cause:**

* Neural networks' high-dimensional decision boundaries are susceptible to gradient-based manipulations.

**Sample Attack Code:**

```python
# FGSM attack
perturbed_input = input + epsilon * sign(gradient(loss, input))
```

**Tool/Library:**

* [CleverHans](https://github.com/cleverhans-lab/cleverhans), [Foolbox](https://github.com/bethgelab/foolbox)

---

### **4. Data Exfiltration via Covert Channels (Model Deployment)**

**Pipeline Stage:** Model Serving / Inference API
**Description:** Backdoored models can leak training data or secrets when triggered via specific inputs.

**Example Scenario:**

* A model trained by an untrusted third party is deployed. On receiving a specific trigger, it leaks internal training data in the response.

**Technical Root Cause:**

* Lack of trusted model lineage or auditing for neural network weights.

**Code Snippet:**

```python
if input == TRIGGER_VECTOR:
    return TRAINING_DATA_SNIPPET
```

**Research Reference:**

* *"Stealing Machine Learning Models via Prediction APIs"*, Tramèr et al.

---

### **5. Supply Chain Attacks in ML Frameworks (Build Pipeline)**

**Pipeline Stage:** Model Training → Containerization / Deployment
**Description:** Compromised ML dependencies (e.g., NumPy, TensorFlow) or Docker images are used in the pipeline.

**Example Scenario:**

* An attacker publishes a malicious Python package mimicking `numpy` (e.g., `numpyy`) which gets pulled by CI/CD pipelines.

**Technical Root Cause:**

* Dependency confusion and lack of signature verification.

**Example Tools:**

* Use of [Poetry.lock](https://python-poetry.org/) or SBOMs to ensure package provenance.

**Relevant CVEs:**

* CVE-2021-44228 (Log4Shell): shows the impact of hidden dependencies.

---

### **6. Membership Inference Attacks (Model API)**

**Pipeline Stage:** Inference / Model Hosting
**Description:** Determine whether a particular data sample was part of the model's training set.

**Example Scenario:**

* An attacker queries a model with a known sample and uses confidence differences to determine membership.

**Technical Root Cause:**

* Overconfidence on training samples vs general samples.

**Code Snippet:**

```python
# Exploit higher output confidence
if model.predict_proba(x) > 0.99:
    print("Likely in training set")
```

**Reference:**

* *"Membership Inference Attacks Against Machine Learning Models"*, Shokri et al., 2017

---

### **7. Backdoor Injection via Model Watermarking (Training Pipeline)**

**Pipeline Stage:** Model Training
**Description:** Model owners or malicious contributors insert watermarks that can be used to assert ownership or exfiltrate data.

**Example Scenario:**

* A contractor provides a model with a watermark that activates a specific prediction if a known pattern is passed in.

**Technical Root Cause:**

* Lack of reproducible training environments and tamper-proof audits.

**Code Pattern:**

```python
# Triggered behavior
if detect_watermark(input):
    return "I am the rightful owner!"
```

**Research Reference:**

* *"Turning Your Weakness Into a Strength: Watermarking Deep Neural Networks by Backdooring"*, Adi et al.

---

### **8. Data Drift Exploitation (Monitoring Pipeline)**

**Pipeline Stage:** Post-deployment / Model Monitoring
**Description:** Attackers manipulate input distributions to cause model degradation and bias without triggering alerts.

**Example Scenario:**

* A botnet feeds a fraud detection system with near-threshold behavior to gradually drift decision boundaries.

**Technical Root Cause:**

* Lack of real-time drift detection and robust validation.

**Possible Mitigation Tools:**

* Alibi Detect, Evidently AI for drift analysis.

---

### **9. Insecure Model Serialization (Storage & Transport Pipeline)**

**Pipeline Stage:** Model Storage / Sharing
**Description:** Serialized models (e.g., `pickle`, ONNX) can contain executable code.

**Example Scenario:**

* A `.pkl` file shared over email executes arbitrary code when deserialized by a careless data scientist.

**Root Cause:**

* Python `pickle` is Turing-complete and allows arbitrary code execution.

**Exploit Code:**

```python
import pickle

class Exploit:
    def __reduce__(self):
        return (os.system, ('rm -rf /',))

pickle.dumps(Exploit())
```

**Recommendation:**

* Use `joblib`, ONNX + signature verification, or encrypted formats.

---

### **10. Misconfigured Access Controls (Serving & API Pipeline)**

**Pipeline Stage:** Model API Hosting
**Description:** Unauthorized users gain access to internal models, datasets, or pipelines due to poor IAM or ACLs.

**Example Scenario:**

* An AI-as-a-Service platform exposes internal endpoints without authentication (`/internal_model/weights`).

**Root Cause:**

* Default open ports, weak RBAC, missing network segmentation.

**Mitigation:**

* Use zero-trust networking, enforce IAM policies (e.g., AWS IAM + SageMaker).

---
