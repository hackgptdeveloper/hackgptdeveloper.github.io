---
title: "Using LangGraph and LangChain to create an AI agent workflow orchestration"
tags:
  - AI agent
  - LangGraph
  - LangChain
---

This code creates a multi-agent workflow using LangGraph and OpenAI's language model. Let me explain what it does and then provide a working version.

## Code Explanation

The code implements a three-stage research pipeline:

1. **Research Agent**: Takes a query and simulates collecting research (currently just returns a stub message)
2. **Summarizer Agent**: Uses GPT-4o-mini to summarize the research findings
3. **Reviewer Agent**: Uses GPT-4o-mini again to review and polish the summary

The workflow is orchestrated using LangGraph's StateGraph, which manages state between agents and defines the execution flow.

## Issues and Fixes

The main issue is that you'll need to set up your OpenAI API key. Here's the corrected and complete working version:## Key Improvements Made:

1. **Error Handling**: Added try-catch block to handle potential errors
2. **Environment Setup**: Added comment about setting the OpenAI API key
3. **Better Research Stub**: Made the research agent return more realistic research data instead of just a one-liner
4. **State Management**: Ensured all important state is passed between agents
5. **Better Prompts**: Improved the prompts for summarizer and reviewer agents
6. **Debug Information**: Added optional debug output to see intermediate results
7. **Main Guard**: Added `if __name__ == "__main__"` guard for proper script execution

## To Run This Code:

1. **Install Dependencies**:
   ```bash
   pip install langchain-openai langgraph
   ```

2. **Set OpenAI API Key**:
   ```bash
   export OPENAI_API_KEY="your-api-key-here"
   ```
   Or set it in your code:
   ```python
   os.environ["OPENAI_API_KEY"] = "your-api-key-here"
   ```

3. **Run the Script**: The workflow will process the query through all three agents and output the final polished result.

The code demonstrates a powerful pattern for building multi-agent AI systems where different specialized agents handle different parts of a complex task, with LangGraph managing the orchestration and state flow between them.

```python

import os
from langchain_openai import ChatOpenAI
from langgraph.graph import StateGraph, END

# Set up OpenAI API key (you'll need to set this environment variable)
# os.environ["OPENAI_API_KEY"] = "your-api-key-here"

# --- Define Agents ---
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0.3)

def research_agent(state):
    """Simulates research collection - in real implementation, this could web scrape, 
    query databases, or use other research tools"""
    query = state["query"]
    # This is a stub - in practice, you'd implement actual research logic here
    research_data = f"""Research findings for '{query}':
    
    1. Quantum computing uses quantum mechanical phenomena like superposition and entanglement
    2. Educational applications include quantum algorithms courses and simulation tools
    3. Major universities are developing quantum computing curricula and research programs
    4. Challenges include the complexity of quantum concepts and lack of accessible hardware
    5. Online platforms like IBM Qiskit provide educational quantum computing resources"""
    
    return {
        "research": research_data,
        "query": query  # Pass query forward in state
    }

def summarizer_agent(state):
    """Takes research data and creates a concise summary"""
    research = state["research"]
    query = state["query"]
    
    prompt = f"""Please create a concise, well-structured summary of this research about '{query}':

{research}

Focus on the key points and organize them logically."""
    
    response = llm.invoke(prompt)
    return {
        "summary": response.content,
        "research": research,  # Keep previous state
        "query": query
    }

def reviewer_agent(state):
    """Reviews and polishes the summary for final output"""
    summary = state["summary"]
    query = state["query"]
    
    prompt = f"""Please review and polish this summary about '{query}'. 
    Improve clarity, fix any issues, and ensure it's well-written and informative:

{summary}

Provide the final polished version."""
    
    response = llm.invoke(prompt)
    return {
        "final": response.content,
        "summary": summary,  # Keep previous state
        "research": state["research"],
        "query": query
    }

# --- Build Orchestration Graph ---
workflow = StateGraph(dict)

# Add nodes (agents) to the workflow
workflow.add_node("research", research_agent)
workflow.add_node("summarizer", summarizer_agent)
workflow.add_node("reviewer", reviewer_agent)

# Define the flow
workflow.set_entry_point("research")
workflow.add_edge("research", "summarizer")
workflow.add_edge("summarizer", "reviewer")
workflow.add_edge("reviewer", END)

# Compile the graph
graph = workflow.compile()

# --- Run Example ---
if __name__ == "__main__":
    try:
        # Execute the workflow
        result = graph.invoke({"query": "Quantum computing in education"})
        
        print("=" * 50)
        print("FINAL RESULT:")
        print("=" * 50)
        print(result["final"])
        print("\n" + "=" * 50)
        
        # Optional: Print intermediate results for debugging
        print("\nDEBUG INFO:")
        print(f"Original Query: {result['query']}")
        print(f"\nResearch Data Length: {len(result['research'])} characters")
        print(f"Summary Length: {len(result['summary'])} characters")
        print(f"Final Result Length: {len(result['final'])} characters")
        
    except Exception as e:
        print(f"Error running workflow: {e}")
        print("\nMake sure you have:")
        print("1. Set your OPENAI_API_KEY environment variable")
        print("2. Installed required packages: pip install langchain-openai langgraph")
```
