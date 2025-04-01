---
title: "Building a Retrieval-Augmented Generation (RAG) system"
tags:
  - RAG
---

Building a Retrieval-Augmented Generation (RAG) system involves combining a retrieval mechanism with a generative model to produce contextually relevant and accurate responses. Below, I’ll outline the detailed steps to build a RAG system using suitable models from Hugging Face, a popular platform for open-source NLP models and tools. The process assumes you have some familiarity with Python, transformers, and basic machine learning concepts.

---

### **Overview of a RAG System**
A RAG system has two main components:
1. **Retriever**: Fetches relevant documents or passages from a knowledge base given a query.
2. **Generator**: Uses the retrieved documents to generate a coherent and contextually appropriate response.

Hugging Face provides pre-trained models and libraries (e.g., `transformers`, `sentence-transformers`) that we can leverage for both components.

---

### **Step-by-Step Guide**

#### **Step 1: Set Up Your Environment**
- Install the necessary libraries:
  ```bash
  pip install transformers datasets sentence-transformers faiss-cpu torch
  ```
  - `transformers`: For the generative model.
  - `sentence-transformers`: For embeddings in the retriever.
  - `faiss-cpu`: For efficient similarity search in the retrieval step.
  - `datasets`: To handle and preprocess your knowledge base.
  - `torch`: Backend for PyTorch-based models.

- Ensure you have Python 3.8+ installed.

---

#### **Step 2: Prepare Your Knowledge Base**
- **Collect Data**: Gather the documents or text corpus you want the RAG system to use (e.g., Wikipedia articles, PDFs, or a custom dataset).
- **Preprocess the Data**:
  - Split the text into smaller chunks (e.g., 100-200 words per chunk) to ensure efficient retrieval.
  - Remove unnecessary formatting, stopwords, or noise if needed.
  - Example using `datasets`:
    ```python
    from datasets import Dataset

    # Example: List of documents
    documents = ["Text chunk 1...", "Text chunk 2...", "Text chunk 3..."]
    dataset = Dataset.from_dict({"text": documents})
    ```

---

#### **Step 3: Choose and Set Up the Retriever**
- **Model**: Use a dense retrieval model like `sentence-transformers`’ DPR (Dense Passage Retrieval) or a general-purpose embedding model such as `all-MiniLM-L6-v2`.
  - DPR is optimized for question-answering tasks, but `all-MiniLM-L6-v2` is lightweight and versatile.
- **Steps**:
  1. Load the model:
     ```python
     from sentence_transformers import SentenceTransformer

     retriever_model = SentenceTransformer('all-MiniLM-L6-v2')
     ```
  2. Encode your knowledge base:
     ```python
     embeddings = retriever_model.encode(dataset["text"], convert_to_tensor=True)
     ```
  3. Set up an index for fast retrieval using FAISS:
     ```python
     import faiss

     dimension = embeddings.shape[1]  # Embedding size (e.g., 384 for MiniLM)
     index = faiss.IndexFlatL2(dimension)  # L2 distance index
     index.add(embeddings.cpu().numpy())  # Add embeddings to the index
     ```

- **Test the Retriever**:
  - Encode a query and retrieve top-k documents:
    ```python
    query = "What is machine learning?"
    query_embedding = retriever_model.encode([query], convert_to_tensor=True)
    distances, indices = index.search(query_embedding.cpu().numpy(), k=5)  # Top 5 results
    retrieved_docs = [dataset["text"][i] for i in indices[0]]
    print(retrieved_docs)
    ```

---

#### **Step 4: Choose and Set Up the Generator**
- **Model**: Use a pre-trained sequence-to-sequence model from Hugging Face’s `transformers`, such as `facebook/bart-base` or `t5-small`, which are suitable for generation tasks.
  - BART is great for abstractive summarization and generation.
  - T5 is versatile for various text-to-text tasks.
- **Steps**:
  1. Load the model and tokenizer:
     ```python
     from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

     generator_tokenizer = AutoTokenizer.from_pretrained('facebook/bart-base')
     generator_model = AutoModelForSeq2SeqLM.from_pretrained('facebook/bart-base')
     ```
  2. Prepare input by combining the query and retrieved documents:
     ```python
     context = " ".join(retrieved_docs)  # Concatenate retrieved docs
     input_text = f"Question: {query} Context: {context}"
     inputs = generator_tokenizer(input_text, return_tensors="pt", max_length=512, truncation=True)
     ```
  3. Generate the response:
     ```python
     outputs = generator_model.generate(
         **inputs,
         max_length=150,
         num_beams=4,
         early_stopping=True
     )
     response = generator_tokenizer.decode(outputs[0], skip_special_tokens=True)
     print(response)
     ```

---

#### **Step 5: Integrate Retriever and Generator into a RAG Pipeline**
- Combine the retriever and generator into a single workflow:
  ```python
  def rag_pipeline(query, retriever, index, generator, tokenizer, dataset, k=5):
      # Retrieve
      query_embedding = retriever.encode([query], convert_to_tensor=True)
      distances, indices = index.search(query_embedding.cpu().numpy(), k)
      retrieved_docs = [dataset["text"][i] for i in indices[0]]
      context = " ".join(retrieved_docs)

      # Generate
      input_text = f"Question: {query} Context: {context}"
      inputs = tokenizer(input_text, return_tensors="pt", max_length=512, truncation=True)
      outputs = generator.generate(**inputs, max_length=150, num_beams=4, early_stopping=True)
      return tokenizer.decode(outputs[0], skip_special_tokens=True)

  # Example usage
  query = "What is machine learning?"
  response = rag_pipeline(query, retriever_model, index, generator_model, generator_tokenizer, dataset)
  print(response)
  ```

---

#### **Step 6: Fine-Tune (Optional)**
- **Retriever Fine-Tuning**: If your domain is specific, fine-tune the retriever on a dataset of query-document pairs using contrastive loss (e.g., with DPR’s training scripts).
- **Generator Fine-Tuning**: Fine-tune the generator on a dataset of questions, contexts, and answers using Hugging Face’s `Trainer` API:
  ```python
  from transformers import TrainingArguments, Trainer

  # Define training args and dataset, then train
  ```

---

#### **Step 7: Optimize and Deploy**
- **Optimization**:
  - Use `faiss-gpu` instead of `faiss-cpu` for faster retrieval.
  - Quantize models with `torch.quantization` for efficiency.
- **Deployment**:
  - Wrap the pipeline in a Flask or FastAPI app for a REST API:
    ```python
    from fastapi import FastAPI

    app = FastAPI()

    @app.get("/rag")
    def get_response(query: str):
        response = rag_pipeline(query, retriever_model, index, generator_model, generator_tokenizer, dataset)
        return {"response": response}
    ```

---

### **Suitable Hugging Face Models**
- **Retriever**: 
  - `sentence-transformers/all-MiniLM-L6-v2` (lightweight, 384-dim embeddings).
  - `facebook/dpr-ctx_encoder-single-nq-base` (specialized for retrieval).
- **Generator**: 
  - `facebook/bart-base` (good balance of size and performance).
  - `t5-small` (lightweight, flexible).

---

### **Additional Tips**
- **Chunk Size**: Experiment with document chunk sizes (e.g., 100 vs. 200 words) for retrieval accuracy.
- **Top-k**: Adjust the number of retrieved documents (k) based on your use case.
- **Evaluation**: Test the system with metrics like BLEU, ROUGE, or human evaluation for generation quality.

By following these steps, you’ll have a functional RAG system leveraging Hugging Face’s ecosystem. Let me know if you’d like deeper clarification on any part!
