---
title: "RAG 从零到一：构建你的第一个 AI 知识库问答系统"
date: 2026-07-09
draft: false
categories: ["ai学习"]
tags: ["RAG", "知识库", "LangChain", "向量数据库", "教程"]
author: "AI学习指南"
description: "RAG（检索增强生成）是2026年最热门的AI应用开发方向。本文手把手教你用LangChain + Chroma构建一个企业知识库问答系统。"
---

## 什么是 RAG

RAG（Retrieval-Augmented Generation，检索增强生成）是让大模型"阅读"你的私有文档并回答问题的技术方案。它的工作流程是：

```
用户提问 → 在文档中检索相关内容 → 把检索结果和问题一起发给 LLM → LLM 生成答案
```

RAG 解决了大模型的两个核心问题：知识截止日期和私有数据访问。

## 技术栈选型

| 组件 | 推荐方案 | 替代方案 |
|---|---|---|
| LLM | Claude API / DeepSeek | OpenAI GPT-4o |
| 框架 | LangChain | LlamaIndex |
| 向量数据库 | Chroma（轻量） | Pinecone, Milvus, Weaviate |
| Embedding 模型 | text-embedding-3-small | bge-large-zh（中文） |
| 文档解析 | Unstructured / PyPDF | LangChain 内置 loader |

## 第一步：环境搭建

```bash
pip install langchain langchain-community chromadb openai unstructured
```

## 第二步：加载和切分文档

```python
from langchain.document_loaders import DirectoryLoader, TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter

# 加载文档
loader = DirectoryLoader('./docs/', glob="**/*.txt", loader_cls=TextLoader)
documents = loader.load()

# 切分文档（每个 chunk 约 500 字，重叠 50 字）
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=500,
    chunk_overlap=50,
    separators=["\n\n", "\n", "。", "，", " ", ""]
)
chunks = text_splitter.split_documents(documents)
print(f"共加载 {len(documents)} 个文档，切分为 {len(chunks)} 个片段")
```

## 第三步：向量化存储

```python
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import Chroma

embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
vectorstore = Chroma.from_documents(
    documents=chunks,
    embedding=embeddings,
    persist_directory="./chroma_db"
)
```

## 第四步：构建问答链

```python
from langchain.chains import RetrievalQA
from langchain.chat_models import ChatOpenAI

llm = ChatOpenAI(model="gpt-4o", temperature=0)
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vectorstore.as_retriever(search_kwargs={"k": 3})
)

# 提问
answer = qa_chain.run("公司年假政策是什么？")
print(answer)
```

## 第五步：优化检索质量

基础 RAG 的检索质量通常不够好，三个优化技巧：

### 1. 混合检索（Hybrid Search）

结合关键词检索（BM25）和语义检索，取长补短。

```python
from langchain.retrievers import BM25Retriever, EnsembleRetriever

bm25_retriever = BM25Retriever.from_documents(chunks)
semantic_retriever = vectorstore.as_retriever()

ensemble_retriever = EnsembleRetriever(
    retrievers=[bm25_retriever, semantic_retriever],
    weights=[0.3, 0.7]
)
```

### 2. 重排序（Re-Ranking）

检索出 Top-10 个相关片段，再用 Cross-Encoder 模型重新排序，取 Top-3。

```python
from sentence_transformers import CrossEncoder

reranker = CrossEncoder('BAAI/bge-reranker-large')
# 对检索结果重新打分排序
```

### 3. 查询改写（Query Rewriting）

用户的问题往往不够精确，先用 LLM 改写问题再检索。

```python
rewrite_prompt = "将以下用户问题改写为更精确的检索查询：{query}"
rewritten_query = llm.invoke(rewrite_prompt.format(query=user_query))
```

## 进阶：带记忆的多轮对话 RAG

```python
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationalRetrievalChain

memory = ConversationBufferMemory(memory_key="chat_history", return_messages=True)
qa = ConversationalRetrievalChain.from_llm(
    llm=llm,
    retriever=vectorstore.as_retriever(),
    memory=memory
)
```

## 常见问题

| 问题 | 原因 | 解决方案 |
|---|---|---|
| 检索不到相关内容 | 文档切分粒度不合适 | 调整 chunk_size 和 overlap |
| 答案不准确 | 检索到的内容不相关 | 加 Re-Ranking 或混合检索 |
| 回答太慢 | 检索+推理串行 | 使用流式输出，优化 embedding 模型 |
| 中文效果差 | embedding 模型偏英文 | 使用 bge-large-zh 等中文模型 |

## 总结

RAG 是 2026 年 AI 应用开发的基础技能。一个基础 RAG 系统 100 行代码就能搭建，但要达到生产级别，还需要混合检索、重排序、查询改写等优化。建议先跑通基础流程，再逐步优化。