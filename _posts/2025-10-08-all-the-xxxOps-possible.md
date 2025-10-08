---
title: "Taxonomy of xxxOps"
tags:
  - xxxOps
---

Yes — **many** other *“Ops”* paradigms exist today, each targeting a different intersection of disciplines — extending from **DevOps** (Dev + Ops) into **security, finance, AI, ML, data, networking, compliance**, and even **business process** management.

Below is a **comprehensive taxonomy** of `*-Ops` variations grouped by domain, with **low-level explanation of scope**, **key automation/tooling areas**, and **source-level origins** (where the concept evolved from in the DevOps ecosystem).

---

## 🧩 1. Core Evolution of DevOps

| Term          | Expansion                | Description                                                                                                                              | Typical Tools/Stack                            | Origin                                                                                                              |
| ------------- | ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **DevOps**    | Development + Operations | Automates build, test, deploy, and operations lifecycle. Uses CI/CD pipelines, IaC, observability, and feedback loops.                   | Jenkins, GitHub Actions, Terraform, Kubernetes | Coined by Patrick Debois (2009, Velocity Conference). Rooted in Agile & Lean manufacturing (Toyota’s Just-in-Time). |
| **DevSecOps** | Dev + Sec + Ops          | Security integrated into DevOps lifecycle (Shift-Left Security). Focus on static/dynamic scanning, IaC scanning, and runtime protection. | SonarQube, Trivy, Snyk, HashiCorp Vault, Falco | Originated from Rugged DevOps (2012, Josh Corman) emphasizing “security as code.”                                   |
| **FinOps**    | Finance + Ops            | Cloud cost optimization as a shared responsibility. Metrics-driven budgeting for compute, storage, and network consumption.              | CloudHealth, Kubecost, Finout, CloudZero       | Coined by J.R. Storment (2018). FinOps Foundation under Linux Foundation.                                           |

---

## 🧠 2. Data, AI, and ML Variations

| Term         | Expansion                   | Description                                                                                                         | Tools / Key Systems                       | Origin                                                                     |
| ------------ | --------------------------- | ------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- | -------------------------------------------------------------------------- |
| **DataOps**  | Data + Ops                  | Automates data pipeline testing, deployment, and quality checks. Inspired by DevOps, but for ETL/ELT and analytics. | Airflow, dbt, Great Expectations, Prefect | Coined by Andy Palmer (2014).                                              |
| **MLOps**    | Machine Learning + Ops      | CI/CD + CT (Continuous Training) for ML models. Includes versioning, feature stores, and model registries.          | MLflow, Kubeflow, Vertex AI, Sagemaker    | Term appears in Google’s 2015 paper *Hidden Technical Debt in ML Systems*. |
| **AIOps**    | AI + Ops                    | Uses AI/ML to automate anomaly detection, event correlation, and predictive maintenance in IT operations.           | Dynatrace, Moogsoft, BigPanda             | Originates from Gartner (2017).                                            |
| **ModelOps** | Model + Ops                 | Manages AI model lifecycle beyond ML (e.g., rule-based or optimization models).                                     | IBM Watson Studio, SAS Model Manager      | Introduced by IBM ~2018 as enterprise-grade MLOps superset.                |
| **LLMOps**   | Large Language Models + Ops | Manages LLM deployment, monitoring, prompt versioning, fine-tuning, and context stores.                             | LangChain, Weaviate, PromptLayer, BentoML | Evolved post-2022 with the rise of GPT-3/ChatGPT ecosystem.                |

---

## 🧱 3. Infrastructure & Platform-Centric Variants

| Term         | Expansion            | Description                                                                                        | Tools                              | Origin                                               |
| ------------ | -------------------- | -------------------------------------------------------------------------------------------------- | ---------------------------------- | ---------------------------------------------------- |
| **GitOps**   | Git + Ops            | Declarative IaC operations driven by Git commits. The Git repo is the single source of truth.      | ArgoCD, FluxCD                     | Weaveworks (2017).                                   |
| **InfraOps** | Infrastructure + Ops | Broader than DevOps; covers lifecycle of infrastructure provisioning, patching, and scaling.       | Ansible, Puppet, Terraform         | Grew out of Infrastructure-as-Code movement (~2013). |
| **CloudOps** | Cloud + Ops          | Continuous governance and optimization of multi-cloud deployments.                                 | Cloudify, Scalr, CloudBolt         | Post-2016 multi-cloud trend.                         |
| **NetOps**   | Network + Ops        | Automation of network provisioning and policy enforcement (SDN/NFV).                               | Cisco ACI, Ansible, NetBox         | Emerged alongside SDN (Software Defined Networking). |
| **NoOps**    | No Operations        | Full automation of ops, developers only code; infra self-heals via serverless or AI-based systems. | Serverless (AWS Lambda, Cloud Run) | Forrester coined the term (~2011).                   |

---

## 🛡️ 4. Security and Compliance-Driven Variants

| Term              | Expansion        | Description                                                                                      | Tools / Practices                        | Origin                                     |
| ----------------- | ---------------- | ------------------------------------------------------------------------------------------------ | ---------------------------------------- | ------------------------------------------ |
| **SecOps**        | Security + Ops   | Real-time SOC and IT ops collaboration — incident response automation, threat intel integration. | Splunk SOAR, Cortex XSOAR, TheHive       | Rooted in SOC automation.                  |
| **ComplianceOps** | Compliance + Ops | Continuous compliance enforcement (PCI, HIPAA, ISO) as code.                                     | Open Policy Agent (OPA), Cloud Custodian | Cloud security automation trend post-2019. |
| **RiskOps**       | Risk + Ops       | Integrates risk scoring and mitigation into CI/CD or SOC workflows.                              | ServiceNow RiskOps, RSA Archer           | Coined around 2020 for integrated GRC.     |
| **PrivacyOps**    | Privacy + Ops    | Data privacy governance automation (GDPR, CCPA compliance).                                      | OneTrust, Ethyca                         | Emerged with privacy-first laws (2018+).   |

---

## ⚙️ 5. Enterprise & Process-Oriented Variants

| Term           | Expansion            | Description                                                                       | Tools / Systems                  | Origin                            |
| -------------- | -------------------- | --------------------------------------------------------------------------------- | -------------------------------- | --------------------------------- |
| **BizDevOps**  | Business + Dev + Ops | Aligns product delivery with business KPIs; connects OKRs directly to pipelines.  | Jira Align, Azure DevOps         | Introduced ~2016 by Gartner.      |
| **DevTestOps** | Dev + Test + Ops     | Testing is continuous and automated throughout delivery pipeline.                 | Selenium Grid, Testkube, Cypress | QA automation trend.              |
| **ChatOps**    | Chat + Ops           | Use of chat platforms (Slack, MS Teams) for executing ops commands via bots.      | Hubot, Lita, StackStorm          | GitHub introduced 2013.           |
| **ServiceOps** | Service + Ops        | Combines ITSM and DevOps for service management automation.                       | ServiceNow, PagerDuty            | ITIL4-based evolution.            |
| **ProductOps** | Product + Ops        | Centralizes product data and insights across teams to enhance product-led growth. | Pendo, Amplitude                 | Emerged in PLG companies (2020+). |

---

## 🌐 6. Edge, IoT, and Sustainability Variants

| Term                  | Expansion   | Description                                                               | Tools                                       | Origin                             |
| --------------------- | ----------- | ------------------------------------------------------------------------- | ------------------------------------------- | ---------------------------------- |
| **EdgeOps**           | Edge + Ops  | Manages distributed workloads at the edge, IoT gateways, or 5G MEC nodes. | KubeEdge, Open Horizon                      | Born with edge computing (~2019).  |
| **IoTOps**            | IoT + Ops   | Automates device onboarding, firmware updates, and telemetry pipelines.   | Azure IoT Hub, AWS IoT Greengrass           | IoT platform management evolution. |
| **GreenOps / EcoOps** | Green + Ops | Cloud and compute optimization for carbon footprint reduction.            | Cloud Carbon Footprint, Kepler (K8s plugin) | Sustainability trend (2021+).      |

---

## 🔬 7. Experimental / Emerging “Ops” Trends

| Term          | Expansion                 | Description                                                  | Example / Origin            |                                                    |
| ------------- | ------------------------- | ------------------------------------------------------------ | --------------------------- | -------------------------------------------------- |
| **DevRelOps** | Developer Relations + Ops | Automates community, SDK updates, and advocacy workflows.    | GitHub Actions for SDK Docs | Coined by CNCF community advocates.                |
| **PromptOps** | Prompt + Ops              | Automates LLM prompt pipelines, evaluation, and A/B testing. | PromptLayer, Traceloop      | Arises from 2023 GenAI workflows.                  |
| **PolicyOps** | Policy + Ops              | Enforces organization-wide policies as code.                 | Open Policy Agent, Kyverno  | Gained traction with Kubernetes RBAC & Gatekeeper. |
| **EventOps**  | Event + Ops               | Orchestrates complex event-driven workflows.                 | Temporal, NATS JetStream    | Post-Serverless event architectures.               |

---

## 🔍 Source Trace (Historical Roots in Code)

* **DevOps DNA** → derived from **Agile Manifesto (2001)** principles.
* **Infrastructure as Code** → 1st code-level implementations:

  * Puppet (Ruby DSL, 2005) → `Puppet::Type.newtype(:package)` DSL core.
  * Chef (Ruby DSL, 2008) → `Chef::Resource::Package` class.
  * Terraform (Go, 2014) → `internal/lang/eval.go` interpreter for HCL configs.
* **Security-as-Code (DevSecOps)** → emerged from HashiCorp Vault and OPA’s Rego policy engine (`ast/compile.go`, Rego parser).
* **FinOps** → Python-based cost analyzers in Kubecost and CloudHealth originated from Kubernetes metrics API (`pkg/kubelet/apis/stats/v1alpha1/types.go`).

---

