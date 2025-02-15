---
title: "List of LangChain applications"
tags:
  - Langchain
---

### What is LangChain?

**LangChain** is a powerful framework designed to streamline the integration of **Large Language Models (LLMs)** into applications. It offers tools and abstractions for working with LLMs in a structured, modular way, making it easier to build, manage, and optimize applications that rely on AI models.

---

### Why Do We Need LangChain?

1. **Orchestration**:
   - Building AI applications often involves multiple steps: prompting, chaining responses, interacting with external systems, etc. LangChain simplifies this by providing a structured way to combine these steps.

2. **Complex Query Management**:
   - Many applications require combining LLM responses with other data (e.g., APIs, databases). LangChain facilitates this by offering tools to connect LLMs with external data sources.

3. **Reusability and Modularity**:
   - LangChain provides modular components (chains, agents, tools) that can be reused or customized across different applications.

4. **Optimization and Debugging**:
   - Debugging LLM workflows and optimizing prompts is challenging. LangChain provides tools like verbose logging and step-by-step execution tracing to assist developers.

5. **Seamless External Integration**:
   - Applications often need LLMs to work alongside external knowledge bases, APIs, and memory systems. LangChain abstracts this complexity.

---

### Core Components of LangChain

1. **PromptTemplates**:
   - Helps structure and format inputs to the LLM.
   - Example: Filling placeholders in a prompt with dynamic data.

2. **Chains**:
   - Chains are sequences of operations that process user input through one or more steps.
   - Example: A question-answering system combining document retrieval and LLM inference.

3. **Agents**:
   - Agents enable LLMs to act autonomously by deciding which tools to use and when.
   - Example: An agent using APIs or querying a database dynamically.

4. **Tools**:
   - These are external utilities the agent can invoke.
   - Example: A calculator, web scraper, or custom API.

5. **Memory**:
   - Enables LLMs to maintain conversational context over time.
   - Example: Remembering user preferences or prior interactions.

6. **Retrieval-Augmented Generation (RAG)**:
   - Combines LLMs with external knowledge retrieval systems like vector databases.
   - Example: Summarizing company policies stored in a database.

---

### Use Cases for LangChain

1. **Chatbots**:
   - Creating intelligent chatbots capable of dynamic, multi-turn conversations.

2. **Question Answering**:
   - Answering questions based on external knowledge bases, documents, or APIs.

3. **Code Assistants**:
   - Assisting developers by fetching and interpreting code-related information.

4. **Automated Agents**:
   - Building agents that interact autonomously with external systems (e.g., sending emails, querying databases).

5. **Personalized Recommendations**:
   - Tailoring responses based on user memory and historical interactions.

---

### How to Use LangChain

#### 1. Installation
```bash
pip install langchain openai
```

#### 2. Basic Example: Simple Chain
```python
from langchain.llms import OpenAI
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain

# Initialize LLM
llm = OpenAI(model="text-davinci-003", temperature=0.5)

# Create a prompt template
prompt = PromptTemplate(
    input_variables=["product"],
    template="What are some creative marketing strategies for a {product}?"
)

# Create a chain
chain = LLMChain(llm=llm, prompt=prompt)

# Run the chain
response = chain.run(product="smartphone")
print(response)
```

---

#### 3. Advanced Example: Using Agents and Tools
```python
from langchain.agents import load_tools, initialize_agent
from langchain.llms import OpenAI

# Initialize LLM
llm = OpenAI(model="text-davinci-003")

# Load some tools (calculator, etc.)
tools = load_tools(["calculator"])

# Initialize an agent with tools
agent = initialize_agent(tools, llm, agent="zero-shot-react-description", verbose=True)

# Run the agent
response = agent.run("What is the square root of 256?")
print(response)
```

---

#### 4. Adding Memory for Context
```python
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain
from langchain.llms import OpenAI

# Initialize LLM
llm = OpenAI(model="text-davinci-003")

# Add memory
memory = ConversationBufferMemory()

# Create a conversation chain
conversation = ConversationChain(llm=llm, memory=memory, verbose=True)

# Simulate a conversation
conversation.run("Hi, my name is Alex.")
conversation.run("What's my name?")
```

---

#### 5. Retrieval-Augmented Generation (RAG)
```python
from langchain.vectorstores import FAISS
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.chains import RetrievalQA
from langchain.llms import OpenAI

# Prepare documents
docs = ["Document 1 content", "Document 2 content", "Document 3 content"]

# Create embeddings and vector store
embeddings = OpenAIEmbeddings()
vector_store = FAISS.from_texts(docs, embeddings)

# Initialize retriever
retriever = vector_store.as_retriever()

# Create an LLM-based QA chain with retriever
llm = OpenAI(model="text-davinci-003")
qa_chain = RetrievalQA.from_chain_type(llm=llm, retriever=retriever)

# Ask a question
response = qa_chain.run("What is in Document 1?")
print(response)
```

---

### Why LangChain Stands Out

- **Modularity**: Easy to combine and reuse components.
- **Ease of Use**: Simplifies complex workflows.
- **Extensibility**: Supports custom tools, memory systems, and integrations.
- **Efficiency**: Optimized for large-scale AI applications.

LangChain bridges the gap between LLM capabilities and real-world applications, enabling developers to build smarter, more responsive systems with less effort. If you’re working with LLMs, it’s a must-have tool to streamline development and improve performance.

***Langchain related applications (with huggingface)***

- **Creating a chatbot using Alpaca native and LangChain**:
  - [https://gist.github.com/cedrickchee/9daedfff817e2b437012b3104bdbc5f3](https://gist.github.com/cedrickchee/9daedfff817e2b437012b3104bdbc5f3)
- **Flask Streaming Langchain Example**:
  - [https://gist.github.com/python273/563177b3ad5b9f74c0f8f3299ec13850?permalink_comment_id=4637872](https://gist.github.com/python273/563177b3ad5b9f74c0f8f3299ec13850?permalink_comment_id=4637872)
- **an intial pass at using stablelm with langchain**:
  - [https://gist.github.com/pszemraj/07cb133ea9823adc139eba52910308cc](https://gist.github.com/pszemraj/07cb133ea9823adc139eba52910308cc)
- **Using RWKV in langchain**:
  - [https://gist.github.com/jiamingkong/3c2b4529e602c0178a7c6fcd10b7c639](https://gist.github.com/jiamingkong/3c2b4529e602c0178a7c6fcd10b7c639)
- **Prompt Engineering with Large Language Models.ipynb**:
  - [https://gist.github.com/losandes/d995d1d4b9616b70bc8789048fb7c969](https://gist.github.com/losandes/d995d1d4b9616b70bc8789048fb7c969)
- **Minimal example of gradio + HF language model**:
  - [https://gist.github.com/marcovirgolin/d7ceb39ae1aada44da7e6822660917dd](https://gist.github.com/marcovirgolin/d7ceb39ae1aada44da7e6822660917dd)
- **Experiment with Langchain, OpenAI, and Datastax AstraDB ...**:
  - [https://gist.github.com/mikesparr/7b8c6360d884770393c3e88376309ed1](https://gist.github.com/mikesparr/7b8c6360d884770393c3e88376309ed1)
- **LangChain agent with Google Search and Math Capability**:
  - [https://gist.github.com/hustshawn/80810688b8c3b3ad5dd39da378f6ce7c](https://gist.github.com/hustshawn/80810688b8c3b3ad5dd39da378f6ce7c)
- **llmops-with-mlflow.ipynb**:
  - [https://gist.github.com/Abonia1/d95c3a4f8640bfaf0cceb3ee51fffcfd](https://gist.github.com/Abonia1/d95c3a4f8640bfaf0cceb3ee51fffcfd)
- **langchain_llamacpp_natural_fun...**:
  - [https://gist.github.com/Mistobaan/e44df41cd574c2f1a1023311c2b9defd](https://gist.github.com/Mistobaan/e44df41cd574c2f1a1023311c2b9defd)
- **Hybrid Search with LangChain-Milvus**:
  - [https://gist.github.com/omriel1/3b8ea57cc14b896237c47d5417eaec8f](https://gist.github.com/omriel1/3b8ea57cc14b896237c47d5417eaec8f)
- **You probably don't know how to do Prompt Engineering**:
  - [https://gist.github.com/Hellisotherpeople/45c619ee22aac6865ca4bb328eb58faf](https://gist.github.com/Hellisotherpeople/45c619ee22aac6865ca4bb328eb58faf)
- **[T4]Langchain_with_LLaMa2_13b_retrievalqa.ipynb**:
  - [https://gist.github.com/hongvincent/a582147a4964788d0cb9d2c3595e6176](https://gist.github.com/hongvincent/a582147a4964788d0cb9d2c3595e6176)
- **3.0_LangChain-Llama2_AmazonMobileReview.ipynb**:
  - [https://gist.github.com/aritrasen87/addcb02296a1d8f97ae48e52f2519a1e](https://gist.github.com/aritrasen87/addcb02296a1d8f97ae48e52f2519a1e)
- **Langchain_Llama2_Lab_Demo.ipynb**:
  - [https://gist.github.com/datatecyl/d8e2a20fb87590cf6b0ebac45414e2da](https://gist.github.com/datatecyl/d8e2a20fb87590cf6b0ebac45414e2da)
- **GPT4all-langchain-demo.ipynb**:
  - [https://gist.github.com/segestic/4822f3765147418fc084a250598c1fe6](https://gist.github.com/segestic/4822f3765147418fc084a250598c1fe6)
- **Deploying LLaMA 3 70B with AirLLM and Gradio on ...**:
  - [https://gist.github.com/ruvnet/f4ac76cb411c8da0b954f91197ca1774](https://gist.github.com/ruvnet/f4ac76cb411c8da0b954f91197ca1774)
- **RAG Chatbot using Confluence**:
  - [https://gist.github.com/chezou/2a6a58cd6bd21b001ca4d3c8d1318e14](https://gist.github.com/chezou/2a6a58cd6bd21b001ca4d3c8d1318e14)
- **create and query a gpt_index using the documentation ...**:
  - [https://gist.github.com/mcminis1/a9f18c8ca518ada8e11259e6aeb699d3](https://gist.github.com/mcminis1/a9f18c8ca518ada8e11259e6aeb699d3)
- **Prompt Engineering with Large Language Models.ipynb**:
  - [https://gist.github.com/losandes/d995d1d4b9616b70bc8789048fb7c969?short_path=56c3532](https://gist.github.com/losandes/d995d1d4b9616b70bc8789048fb7c969?short_path=56c3532)
- **hynky1999's gists**:
  - [https://gist.github.com/hynky1999?direction=asc&sort=created](https://gist.github.com/hynky1999?direction=asc&sort=created)
- **llm-tool.md**:
  - [https://gist.github.com/YaKaiLi/7bd790884cae8ce98abad1574c084e30](https://gist.github.com/YaKaiLi/7bd790884cae8ce98abad1574c084e30)
- **PROMPT Engineering tecnhiques.md**:
  - [https://gist.github.com/YuniorGlez/0f30d27aa923f35aae8eeb0a39b7891c](https://gist.github.com/YuniorGlez/0f30d27aa923f35aae8eeb0a39b7891c)
- **Create a Chatbot using Hugging Face and Streamlit**:
  - [https://gist.github.com/Kavit900/b37188815c1840df909ba4e824ab738a](https://gist.github.com/Kavit900/b37188815c1840df909ba4e824ab738a)
- **HF+ZeroGPU+OpenAI-Prox+Gradio Operation**:
  - [https://gist.github.com/rajivmehtaflex/3094bf6d1ed67daad71cc48501b5bfdf](https://gist.github.com/rajivmehtaflex/3094bf6d1ed67daad71cc48501b5bfdf)
- **Daethyra**:
  - [https://gist.github.com/Daethyra](https://gist.github.com/Daethyra)
- **Changed Paths · GitHub**:
  - [https://gist.github.com/GrahamcOfBorg/0f0bc335b5fe5c2608b8739c7b8627cd](https://gist.github.com/GrahamcOfBorg/0f0bc335b5fe5c2608b8739c7b8627cd)
- **Streamlining Literature Reviews with Paper QA and Zotero**:
  - [https://gist.github.com/lifan0127/e34bb0cfbf7f03dc6852fd3e80b8fb19](https://gist.github.com/lifan0127/e34bb0cfbf7f03dc6852fd3e80b8fb19)
- **Daethyra**:
  - [https://gist.github.com/Daethyra?direction=asc&sort=updated](https://gist.github.com/Daethyra?direction=asc&sort=updated)
- **MichelNivard's gists**:
  - [https://gist.github.com/MichelNivard](https://gist.github.com/MichelNivard)
- **AI/ML Toolkit**:
  - [https://gist.github.com/0xdevalias/09a5c27702cb94f81c9fb4b7434df966](https://gist.github.com/0xdevalias/09a5c27702cb94f81c9fb4b7434df966)
- **modelscope/agentscope. Continue this conversation at ...**:
  - [https://gist.github.com/m0o0scar/927cbf56f66d10d0c8013fabe385b918](https://gist.github.com/m0o0scar/927cbf56f66d10d0c8013fabe385b918)
- **svpino's gists**:
  - [https://gist.github.com/svpino](https://gist.github.com/svpino)
- **mneedham's gists**:
  - [https://gist.github.com/mneedham?direction=desc&sort=updated](https://gist.github.com/mneedham?direction=desc&sort=updated)
- **privateGPT_for_QuantumCompu...**:
  - [https://gist.github.com/faizankshaikh/8f2b38b739e5f2dad13ff62bfd7acbcd](https://gist.github.com/faizankshaikh/8f2b38b739e5f2dad13ff62bfd7acbcd)
- **Pavel Shibanov shibanovp**:
  - [https://gist.github.com/shibanovp](https://gist.github.com/shibanovp)
- **Nilesh Prasad nileshprasad137**:
  - [https://gist.github.com/nileshprasad137](https://gist.github.com/nileshprasad137)
- **python273's gists**:
  - [https://gist.github.com/python273](https://gist.github.com/python273)
- **hongvincent's gists**:
  - [https://gist.github.com/hongvincent?direction=asc&sort=created](https://gist.github.com/hongvincent?direction=asc&sort=created)
- **Unlocking the Power of Claude Projects**:
  - [https://gist.github.com/bartolli/5291b7dd4940b04903cae6141303b50d](https://gist.github.com/bartolli/5291b7dd4940b04903cae6141303b50d)
- **Open-Form Q&A - GPT-Neo 2.7B**:
  - [https://gist.github.com/pszemraj/791d72587e718aa90ff2fe79f45b3cfe](https://gist.github.com/pszemraj/791d72587e718aa90ff2fe79f45b3cfe)
- **Spartee's gists · GitHub**:
  - [https://gist.github.com/Spartee](https://gist.github.com/Spartee)
- **penningjoy's gists**:
  - [https://gist.github.com/penningjoy?direction=desc&sort=created](https://gist.github.com/penningjoy?direction=desc&sort=created)
- **Image Recognition for Googley Eyes**:
  - [https://gist.github.com/kevinmcaleer/8bf03bf74ac6cbf43314c41582d1e471](https://gist.github.com/kevinmcaleer/8bf03bf74ac6cbf43314c41582d1e471)
- **Faizan Shaikh faizankshaikh**:
  - [https://gist.github.com/faizankshaikh](https://gist.github.com/faizankshaikh)
- **cboettig's gists**:
  - [https://gist.github.com/cboettig](https://gist.github.com/cboettig)
- **afaiyaz006's gists**:
  - [https://gist.github.com/afaiyaz006?direction=desc&sort=updated](https://gist.github.com/afaiyaz006?direction=desc&sort=updated)
- **23.04.23 - aifactory 김태영 - LangChain 시작하기 (2).ipynb**:
  - [https://gist.github.com/inspirit941/9a6bef9cc68a84cbc39fbd821cac9897?short_path=4ed6b67](https://gist.github.com/inspirit941/9a6bef9cc68a84cbc39fbd821cac9897?short_path=4ed6b67)
- **23.04.23 - aifactory 김태영 - LangChain 시작하기 (2).ipynb**:
  - [https://gist.github.com/inspirit941/9a6bef9cc68a84cbc39fbd821cac9897](https://gist.github.com/inspirit941/9a6bef9cc68a84cbc39fbd821cac9897)
- **mapmeld's gists · GitHub**:
  - [https://gist.github.com/mapmeld](https://gist.github.com/mapmeld)
- **huggingface + KoNLPy**:
  - [https://gist.github.com/lovit/259bc1d236d78a77f044d638d0df300c](https://gist.github.com/lovit/259bc1d236d78a77f044d638d0df300c)
- **CacheRadar - Sheet1.csv · GitHub**:
  - [https://gist.github.com/danmayer/a4dac4d4b9141e955c604f1baa1a3e8e](https://gist.github.com/danmayer/a4dac4d4b9141e955c604f1baa1a3e8e)
- **Mistobaan's gists**:
  - [https://gist.github.com/Mistobaan](https://gist.github.com/Mistobaan)
- **janduplessis883's gists**:
  - [https://gist.github.com/janduplessis883](https://gist.github.com/janduplessis883)
- **LLM notes · GitHub**:
  - [https://gist.github.com/chainhead/1fdfdbcc48a07946f4a61cb64f289d56](https://gist.github.com/chainhead/1fdfdbcc48a07946f4a61cb64f289d56)
- **OpenDevin Installation**:
  - [https://gist.github.com/mberman84/2ad782e90d18650dfdf42d677c18c520?permalink_comment_id=5007360](https://gist.github.com/mberman84/2ad782e90d18650dfdf42d677c18c520?permalink_comment_id=5007360)
- **Using Bonito v1 on Amazon SageMaker to generate ...**:
  - [https://gist.github.com/dgallitelli/170ad49235f6c17bb27b09a906c87ffd](https://gist.github.com/dgallitelli/170ad49235f6c17bb27b09a906c87ffd)
- **inspirit941's gists**:
  - [https://gist.github.com/inspirit941?direction=desc&sort=updated](https://gist.github.com/inspirit941?direction=desc&sort=updated)
- **jiweiqi's gists · GitHub**:
  - [https://gist.github.com/jiweiqi](https://gist.github.com/jiweiqi)
- **Running LLaMAs models locally on Apple Silicon M1/M2 ...**:
  - [https://gist.github.com/Manoz/7113472524b611e9a5da714522b701ae](https://gist.github.com/Manoz/7113472524b611e9a5da714522b701ae)
- **bigsnarfdude's gists**:
  - [https://gist.github.com/bigsnarfdude?direction=desc&sort=created](https://gist.github.com/bigsnarfdude?direction=desc&sort=created)
- **Abonia1's gists**:
  - [https://gist.github.com/Abonia1](https://gist.github.com/Abonia1)
- **sroecker's gists**:
  - [https://gist.github.com/sroecker/starred](https://gist.github.com/sroecker/starred)
- **Updated 2024-12-04 · GitHub**:
  - [https://gist.github.com/masta-g3/8f7227397b1053b42e727bbd6abf1d2e](https://gist.github.com/masta-g3/8f7227397b1053b42e727bbd6abf1d2e)
- **Niko Gamulin nikogamulin**:
  - [https://gist.github.com/nikogamulin](https://gist.github.com/nikogamulin)
- **GSoC Final Report.md**:
  - [https://gist.github.com/shubhampal62/f7e5331dc58af05f19e959f847c9d3e5](https://gist.github.com/shubhampal62/f7e5331dc58af05f19e959f847c9d3e5)
- **svpino's gists**:
  - [https://gist.github.com/svpino?direction=desc&sort=updated](https://gist.github.com/svpino?direction=desc&sort=updated)
- **Streamlining Literature Reviews with Paper QA and Zotero**:
  - [https://gist.github.com/lifan0127/e34bb0cfbf7f03dc6852fd3e80b8fb19?permalink_comment_id=4580543](https://gist.github.com/lifan0127/e34bb0cfbf7f03dc6852fd3e80b8fb19?permalink_comment_id=4580543)
- **esenthil2018's gists**:
  - [https://gist.github.com/esenthil2018?direction=desc&sort=updated](https://gist.github.com/esenthil2018?direction=desc&sort=updated)
- **OpenDevin Installation**:
  - [https://gist.github.com/mberman84/2ad782e90d18650dfdf42d677c18c520?permalink_comment_id=5006853](https://gist.github.com/mberman84/2ad782e90d18650dfdf42d677c18c520?permalink_comment_id=5006853)
- **lism's gists · GitHub**:
  - [https://gist.github.com/lism?direction=asc&sort=created](https://gist.github.com/lism?direction=asc&sort=created)
- **pakkinlau's gists**:
  - [https://gist.github.com/pakkinlau?direction=asc&sort=updated](https://gist.github.com/pakkinlau?direction=asc&sort=updated)
- **RichardScottOZ**:
  - [https://gist.github.com/RichardScottOZ/starred](https://gist.github.com/RichardScottOZ/starred)
- **blackwhites's gists · GitHub**:
  - [https://gist.github.com/blackwhites](https://gist.github.com/blackwhites)
- **YunDa Tsai j40903272**:
  - [https://gist.github.com/j40903272](https://gist.github.com/j40903272)
- **aaronblondeau**:
  - [https://gist.github.com/aaronblondeau?direction=desc&sort=updated](https://gist.github.com/aaronblondeau?direction=desc&sort=updated)
- **virattt's gists**:
  - [https://gist.github.com/virattt](https://gist.github.com/virattt)
- **ji1kang's gists**:
  - [https://gist.github.com/ji1kang?direction=desc](https://gist.github.com/ji1kang?direction=desc)
- **AWS re:Invent 2024 Sessions**:
  - [https://gist.github.com/timothyjrogers/1b239edc65ebaeb239676992247ddad5](https://gist.github.com/timothyjrogers/1b239edc65ebaeb239676992247ddad5)
- **inspirit941's gists**:
  - [https://gist.github.com/inspirit941](https://gist.github.com/inspirit941)
- **wey-gu's gists**:
  - [https://gist.github.com/wey-gu?direction=desc&sort=created](https://gist.github.com/wey-gu?direction=desc&sort=created)
- **mrocklin's gists · GitHub**:
  - [https://gist.github.com/mrocklin](https://gist.github.com/mrocklin)
- **nbx-apprenticeship.md**:
  - [https://gist.github.com/yashbonde/cc98bd1d1a62690cf9d5b49242fe98d0](https://gist.github.com/yashbonde/cc98bd1d1a62690cf9d5b49242fe98d0)
- **translate_docs.ipynb**:
  - [https://gist.github.com/tcapelle/ed65beafb13e8ea1bb2cd2287ff2e05e](https://gist.github.com/tcapelle/ed65beafb13e8ea1bb2cd2287ff2e05e)
- **Are LLM frameworks the new JavaScript ...**:
  - [https://gist.github.com/vkz/0ebfe2319d1fe2358b51eccbd373125f](https://gist.github.com/vkz/0ebfe2319d1fe2358b51eccbd373125f)
- **RAGAS: Automated Evaluation of Retrieval Augmented ...**:
  - [https://gist.github.com/m0o0scar/3d2cd79b57833f2aa497aa930d754dd0](https://gist.github.com/m0o0scar/3d2cd79b57833f2aa497aa930d754dd0)
- **IsisChameleon**:
  - [https://gist.github.com/IsisChameleon](https://gist.github.com/IsisChameleon)
- **pypi-download-stats-2024-03-01.json**:
  - [https://gist.github.com/MartinThoma/c95c955352bd30b4cee06c0e9eff9715](https://gist.github.com/MartinThoma/c95c955352bd30b4cee06c0e9eff9715)
- **Changed Paths · GitHub**:
  - [https://gist.github.com/GrahamcOfBorg/342a857abaacba8d85e092fe394ae956](https://gist.github.com/GrahamcOfBorg/342a857abaacba8d85e092fe394ae956)
- **gist.txt · GitHub**:
  - [https://gist.github.com/Tricked-dev/c5f27f779198619d6bed1a97b8f84e81](https://gist.github.com/Tricked-dev/c5f27f779198619d6bed1a97b8f84e81)
- **On-premise LLM deployments and options**:
  - [https://gist.github.com/Teebor-Choka/a4a5b099b85404538e32eb8a06c71565](https://gist.github.com/Teebor-Choka/a4a5b099b85404538e32eb8a06c71565)
- **Zero-to-Hero-in-Data-Science.ipynb**:
  - [https://gist.github.com/datasciencechampion/c6ebfd304c6799eaf5bf1578d9a76e5b](https://gist.github.com/datasciencechampion/c6ebfd304c6799eaf5bf1578d9a76e5b)
- **granite3-dense.ipynb**:
  - [https://gist.github.com/chottokun/a02f91615c243a0576160858d4b3b6bd](https://gist.github.com/chottokun/a02f91615c243a0576160858d4b3b6bd)
- **Changed Paths · GitHub**:
  - [https://gist.github.com/GrahamcOfBorg/e49f62cbeb2329649072d37b75d9040d](https://gist.github.com/GrahamcOfBorg/e49f62cbeb2329649072d37b75d9040d)
- **xpzouying's gists · GitHub**:
  - [https://gist.github.com/xpzouying](https://gist.github.com/xpzouying)
- **Changed Paths · GitHub**:
  - [https://gist.github.com/GrahamcOfBorg/c32070d8d2168e3a287ef4ea66002b79](https://gist.github.com/GrahamcOfBorg/c32070d8d2168e3a287ef4ea66002b79)
- **rsimd's gists · GitHub**:
  - [https://gist.github.com/rsimd](https://gist.github.com/rsimd)
- **llvm16-bump.md**:
  - [https://gist.github.com/tobim/5ce3c6d6f49f29ac43b3ad76b96bd1e4](https://gist.github.com/tobim/5ce3c6d6f49f29ac43b3ad76b96bd1e4)
- **Changed Paths · GitHub**:
  - [https://gist.github.com/GrahamcOfBorg/caafe6e4a53c1654d9b4cf648048df89](https://gist.github.com/GrahamcOfBorg/caafe6e4a53c1654d9b4cf648048df89)
