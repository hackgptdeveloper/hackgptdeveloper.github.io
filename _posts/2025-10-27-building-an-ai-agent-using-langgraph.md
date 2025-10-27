---
title: "How To start to build an actual AI agent"
tags:
  - AI agent
---

[https://www.youtube.com/shorts/qvpbO5Y9jN0](https://www.youtube.com/shorts/qvpbO5Y9jN0)

Here’s a **deep-dive**, low-level walkthrough on how to build an AI agent using LangGraph’s `create_react_agent` helper (from LangChain), showing internals, architecture, code, state flow, and how the pieces tie together.

---

## 1. Concept: ReAct agent (Reasoning + Action)

The “ReAct” pattern (from the paper ReAct: Synergizing Reasoning and Acting in Language Models) means: the LLM alternates between reasoning (thinking) and acting (calling tools) until a final answer is produced.
With LangGraph this is implemented via a *graph* of nodes (LLM node, tool-node) and a state (history + scratchpad) which loops until a stopping condition. ([LangChain][1])
So the `create_react_agent` helper sets up such a loop for you.

---

## 2. High-level interface of `create_react_agent`

From the docs:

```python
from langgraph.prebuilt import create_react_agent

agent = create_react_agent(
    model=<LLM or string>,
    tools=[…],
    prompt=<string | SystemMessage | callable>  # optional
)
```

The parameters (per reference) are:

* `model`: can be a static LLM instance, a string identifier (“openai:gpt-4”), or a callable returning a model. ([LangChain][2])
* `tools`: a list of tool-callables or tool definitions (functions with docstrings) that the agent may call. ([LangChain][3])
* `prompt`: optional. Could be a system message string, or more complex. It influences how the LLM is prompted. ([LangChain][4])

And the return is a “Runnable” graph that you invoke with an input state (typically `{"messages": […]}`) and you get back an updated state with the history, tool outputs, etc.

---

## 3. Step-by-step to build one

Here’s how you’d build one, with code and internal state explained. I’ll go into the underlying state keys so you can trace what happens.

### 3.1 Install & import

```bash
pip install -U langgraph langchain
```

Then in your Python:

```python
from langgraph.prebuilt import create_react_agent
from langchain.chat_models import ChatOpenAI      # example for OpenAI
from langchain_core.tools import tool             # tool decorator
from langchain_core.messages import HumanMessage, SystemMessage
```

### 3.2 Define tools

A "tool" is a function the agent may call. For example:

```python
@tool
def add(a: int, b: int) -> int:
    """Add two integers a and b."""
    return a + b

@tool
def multiply(a: int, b: int) -> int:
    """Multiply two integers a and b."""
    return a * b

tools = [add, multiply]
```

The docstring serves as a description the LLM sees, so it knows what the tool does. ([Medium][5])

### 3.3 Setup model

```python
model = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)
```

You could also pass a string like `"openai:gpt-4"` depending on the library’s support. ([LangChain][2])

### 3.4 Build the agent

```python
agent = create_react_agent(
    model=model,
    tools=tools,
    prompt="You are a helpful arithmetic assistant."   # optional
)
```

### 3.5 Invoke the agent

```python
input_messages = [
    {"role": "user", "content": "Compute (3 + 4) × 2."}
]
result_state = agent.invoke({"messages": input_messages})
```

The `result_state` will contain `messages`, which is a sequence of message objects: the user message, then the agent’s reasoning / tool choice, then tool output, etc.

### 3.6 Inspect internal state

Because LangGraph is stateful, you can inspect the full message history:

```python
for m in result_state["messages"]:
    print(m)
```

You’ll see messages like:

* HumanMessage
* AIMessage that says something like “I will call add with a=3, b=4”
* Tool message giving result 7
* AIMessage next reasoning, maybe calling multiply, etc
* Final AIMessage giving answer.

You can decode the “tool calls” by reading the message content if the library prints them or by using callback hooks. ([Reddit][6])

---

## 4. What happens under the hood (chain up to source)

Here’s a breakdown of internals so you understand the execution flow, useful for auditing security, customizing, or inserting your own logic.

### 4.1 Graph & State

* The agent uses a `StateSchema` (e.g., TypedDict) with at least a `"messages": Sequence[BaseMessage]` field. ([LangChain][1])
* Each invocation the state is passed to the graph; nodes update the state (e.g., append new messages) and then edges select next node until stop.

### 4.2 Node types

* **LLM node**: Takes the current messages state, adds prompt/system message if provided, sends it to the model, gets back an AIMessage.
* **Tool node**: Detects if AIMessage indicates a tool call (with arguments), executes the tool, then appends ToolMessage to the state.
* Then loop goes back to LLM node with updated messages.

### 4.3 Stopping condition

* When the LLM’s output does *not* indicate a tool call (i.e., final answer), edge logic routes to end node and the graph terminates. ([LangChain][1])

### 4.4 Prompting & scratchpad

* The “scratchpad” of previous actions is captured implicitly via the `messages` history.
* The prompt parameter (string or callable) is prepended or otherwise injected to guide the LLM. For example a static prompt `"You are a helpful assistant."` becomes a SystemMessage at start. ([LangChain][4])
* If you pass a callable for prompt, you can inspect state and tailor messages dynamically.

### 4.5 Binding tools with model

* Some LLMs or tool frameworks require you to “bind” tools to the model so the LLM can know about them. LangGraph supports dynamic model selection too. ([LangChain][2])

### 4.6 Logging / callback / debugging

* You can hook into callbacks to inspect LLM inputs/outputs, tool calls, etc. As one user noted, to intercept the full model input you may need to intercept lower-level methods. ([Reddit][6])
* For production you can enable tracing with LangSmith via environment variable `LANGSMITH_TRACING=true` for richer visibility. ([LangChain][7])

---

## 5. Example full code (security-aware)

Here’s a runnable example (you can drop into your environment). I’ll annotate hooks for you to inspect internals (since you like low-level detail).

```python
# agent_example.py

from typing import Sequence, TypedDict
from langchain_core.messages import BaseMessage, HumanMessage, SystemMessage
from langchain.chat_models import ChatOpenAI
from langchain_core.tools import tool
from langgraph.prebuilt import create_react_agent
from langgraph.graph.message import add_messages

# Define state schema (optional, because prebuilt handles it)
class AgentState(TypedDict):
    messages: Sequence[BaseMessage]

# Define tools
@tool
def add(a: int, b: int) -> int:
    """Add two integers a and b."""
    return a + b

@tool
def multiply(a: int, b: int) -> int:
    """Multiply two integers a and b."""
    return a * b

tools = [add, multiply]

# Setup model
model = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)

# Create agent
agent = create_react_agent(
    model=model,
    tools=tools,
    prompt="You are a helpful arithmetic assistant. Use the tools when helpful."
)

# Prepare input
input_messages = [HumanMessage(content="Compute (3 + 4) × 2.")]

# Invoke agent
result_state = agent.invoke({"messages": input_messages})

# Inspect output
print("=== Full message history ===")
for m in result_state["messages"]:
    print(type(m), m)
print("=== Final answer ===")
print(result_state["messages"][-1].content)
```

### Notes for security / inspection

* Because you are a pen-tester / researcher, you may want to **log the exact tool arguments** the agent uses. You can wrap the tool functions to log.
* Ensure you sanitize tool functions if they’ll be exposed to untrusted user input (e.g., don’t allow arbitrary code execution).
* You can extend the state schema to include e.g., `step_count: int`, or `user_id`, or `session_id` to track which user and how many loops.
* If you want to stop the agent after N loops (to prevent runaway reasoning), you can custom-wrap the call or build a custom graph instead of `create_react_agent`.

---

## 6. Extending / customizing (since you’ll likely want more control)

Given your background, you may want to go beyond `create_react_agent` and build a custom graph or augment with memory, security controls, etc. Here’s how:

* Use `StateGraph` from `langgraph.graph` to define nodes manually (LLM node, Tool node, maybe memory node). ([LangChain][1])
* Define custom `AgentState` TypedDict including fields like `messages`, `tools_called`, `tool_history`, `session_id`.
* Define edges: from START → LLM node → if tool call → Tool node → back to LLM, else to END.
* Add custom stopping conditions: e.g., check state["step_count"] > MAX_STEPS.
* Add memory persistence: e.g., integrate `langgraph.checkpoint.memory.MemorySaver` to store long-term memory. ([LangChain][7])
* Add security or auditing: before executing a tool, check user input, validate arguments, log usage.

---

## 7. Security / Bug-Bounty / Pentest considerations

Since you’re in the security space, here are extra things to watch:

* Trust boundaries: tools are Python functions you define. If user can influence tool args or choose tools, you must validate inputs.
* Injection risk: The LLM may ask to call a tool with unchecked parameters; ensure your tool decorator enforces schema.
* Loop exhaustion: Ensure the agent cannot loop indefinitely (denial-of-service potential).
* Prompt injection: Since you pass a prompt and stack previous messages, an attacker may craft a message that forces the agent to call unintended tools — restrict tool list, validate calls.
* Logging: Keep full transcripts of messages and tool calls so you can audit for malicious use or hallucinations.
* Memory & persistence: If you maintain user session state or memory, ensure confidentiality, avoid mixing sessions between users.

---

## 8. Summary

* `create_react_agent` gives you a quick way to build a ReAct-style agent with LLM + tools.
* Internally it uses LangGraph’s graph abstraction: state, nodes, edges, loop until no tool call.
* You can inspect the full messages (history + tool calls).
* For your security / dev work you can extend/customize for extra control, logging, memory, stops.
* Always validate tools and user inputs, avoid injection risks, impose loop limits, monitor.

---

If you like, I can **generate a full skeleton repository** (with Dockerfile, CI/CD GitHub Actions YAML, logging, callback hooks) for a LangGraph `create_react_agent`-based service ready for deployment — would that be useful to you?

[1]: https://langchain-ai.github.io/langgraph/how-tos/react-agent-from-scratch/?utm_source=chatgpt.com "How to create a ReAct agent from scratch - GitHub Pages"
[2]: https://langchain-ai.github.io/langgraph/reference/agents/?utm_source=chatgpt.com "Agents - GitHub Pages"
[3]: https://langchain-ai.github.io/langgraph/agents/agents/?utm_source=chatgpt.com "Start with a prebuilt agent - GitHub Pages"
[4]: https://python.langchain.com/docs/how_to/migrate_agent/?utm_source=chatgpt.com "How to migrate from legacy LangChain agents to LangGraph"
[5]: https://medium.com/%40umang91999/building-a-react-agent-with-langgraph-a-step-by-step-guide-812d02bafefa?utm_source=chatgpt.com "Building a ReAct Agent with Langgraph: A Step-by-Step Guide"
[6]: https://www.reddit.com/r/LangChain/comments/1kh8l3p/langgraph_create_react_agent_how_to_see_model/?utm_source=chatgpt.com "LangGraph create_react_agent: How to see model inputs ... - Reddit"
[7]: https://python.langchain.com/docs/tutorials/agents/?utm_source=chatgpt.com "Build an Agent - ️ LangChain"

