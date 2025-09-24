---
title: "How to call an LLM via API from Airflow"
tags:
  - LLM
  - Airflow
---

In **Apache Airflow**, you don’t “call” an LLM (Large Language Model) directly — instead, you integrate it inside a **task** (usually via a PythonOperator or custom operator). The DAG defines the workflow, and your task code makes the LLM API call.

Here’s how you can do it step by step:

---

### 1. Using `PythonOperator` with OpenAI API (example)

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import openai

openai.api_key = "<YOUR_OPENAI_API_KEY>"

def call_llm(**kwargs):
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{"role": "user", "content": "Summarize the last Airflow DAG run."}]
    )
    print(response["choices"][0]["message"]["content"])
    return response["choices"][0]["message"]["content"]

with DAG(
    dag_id="llm_integration_example",
    start_date=datetime(2025, 9, 1),
    schedule_interval=None,
    catchup=False,
) as dag:

    llm_task = PythonOperator(
        task_id="invoke_llm",
        python_callable=call_llm,
        provide_context=True
    )
```

This runs an LLM call as part of the DAG execution.

---

### 2. Using a **custom operator** (cleaner for reuse)

You can wrap LLM calls into a reusable Airflow operator:

```python
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
import openai

class LLMOperator(BaseOperator):
    @apply_defaults
    def __init__(self, prompt, model="gpt-4", *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.prompt = prompt
        self.model = model

    def execute(self, context):
        response = openai.ChatCompletion.create(
            model=self.model,
            messages=[{"role": "user", "content": self.prompt}]
        )
        return response["choices"][0]["message"]["content"]
```

Then in your DAG:

```python
llm_task = LLMOperator(
    task_id="generate_summary",
    prompt="Summarize today’s Airflow logs."
)
```

---

### 3. Alternatives

* **LangChain + Airflow**: You can wrap LangChain pipelines inside an Airflow task for more complex workflows (retrieval, chaining, agents).
* **External Services**: If you’re calling HuggingFace models, use `transformers` or `inference-endpoint` APIs in the operator code.
* **TaskFlow API**: Newer Airflow DAGs can define Python functions decorated with `@task` to directly call LLM APIs.

---

⚠️ **Security/Compliance tip** (since you’re a security researcher):

* Never hardcode API keys in DAG files. Use Airflow **Connections** or **Environment Variables**.
* Wrap sensitive output (like PII data) with logging filters if you’re sending to LLMs.

---

Diving into a **LangChain + Airflow DAG** integration, now we can showing how you can orchestrate an LLM workflow as part of Airflow pipelines.

---

# 🔗 LangChain + Airflow Integration

Airflow doesn’t know what an LLM is; it only knows how to run tasks.
LangChain provides a framework for building pipelines that interact with LLMs.
So we wrap LangChain chains inside Airflow tasks.

---

## 1. Install dependencies

```bash
pip install apache-airflow openai langchain
```

---

## 2. Example DAG with LangChain

```python
from airflow import DAG
from airflow.decorators import task
from datetime import datetime
from langchain_openai import ChatOpenAI
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate


# Define DAG
with DAG(
    dag_id="langchain_llm_workflow",
    start_date=datetime(2025, 9, 1),
    schedule_interval=None,
    catchup=False,
    tags=["llm", "langchain", "ai"],
) as dag:

    # Task 1: Call LLM with LangChain
    @task
    def run_langchain_query():
        # Initialize LLM
        llm = ChatOpenAI(model="gpt-4", temperature=0)

        # Prompt template
        prompt = PromptTemplate(
            input_variables=["topic"],
            template="Write a 3-sentence summary about {topic}."
        )

        chain = LLMChain(llm=llm, prompt=prompt)

        # Run chain
        result = chain.run({"topic": "Apache Airflow and LLM integration"})
        print(result)
        return result

    # Task 2: Save results (placeholder)
    @task
    def save_to_file(content: str):
        with open("/tmp/llm_output.txt", "w") as f:
            f.write(content)

    # Define task order
    summary = run_langchain_query()
    save_to_file(summary)
```

---

## 3. How it Works

* Airflow runs `run_langchain_query` as a Python task.
* LangChain builds a chain using **OpenAI’s GPT-4**.
* Prompt: *"Write a 3-sentence summary about Apache Airflow and LLM integration."*
* Output is passed downstream to `save_to_file`.
* Airflow’s **XCom** handles passing results between tasks.

---

## 4. Advanced: Multi-step Workflow

You can expand with multiple LLM calls:

```python
@task
def research_topic():
    chain = LLMChain(
        llm=ChatOpenAI(model="gpt-4"),
        prompt=PromptTemplate(
            input_variables=["topic"],
            template="List 5 key points about {topic}."
        )
    )
    return chain.run({"topic": "Data pipeline security"})

@task
def draft_report(points: str):
    chain = LLMChain(
        llm=ChatOpenAI(model="gpt-4"),
        prompt=PromptTemplate(
            input_variables=["points"],
            template="Turn the following points into a structured report:\n{points}"
        )
    )
    return chain.run({"points": points})
```

Then in the DAG:

```python
points = research_topic()
report = draft_report(points)
save_to_file(report)
```

---

## 5. Security Best Practices

* Store API keys in **Airflow Connections** (`airflow connections add`)
* Use **Variable masks** for prompts if they contain sensitive info
* Never log raw responses if they might contain PII

---

