---
title: "什么时候不该用AI框架？200行纯Python代码比2万行框架代码更靠谱的4个场景"
date: 2026-07-13
draft: false
categories: ["AI框架"]
tags: ["AI框架", "反模式", "原生开发", "Python", "过度工程", "技术选型"]
author: "AI2AI.xin 编辑部 - hd1990"
description: "AI框架不是银弹。在某些场景下，用框架反而是在给自己挖坑。本文告诉你4个不该用AI框架的场景，以及200行代码能搞定的事为什么要用2万行框架。"
---

## 你用了2万行的框架代码，实现了一个200行Python就能搞定的功能

这是AI创业圈最普遍的"过度工程"现象。某团队花了3周时间，用LangChain + LangGraph + Dify搭建了一个"智能客服Agent"。写了几千行配置、几百行代码节点、几十个Workflow节点。上线后发现80%的查询是"我的订单到哪了"——一个SQL查询就能回答的问题。

CTO后来告诉我：**如果当初直接用OpenAI API + 200行Python，早两周上线，效果完全一样。**

AI框架的价值被高估了。以下是4个不该用AI框架的场景。

## 场景一：你的需求是"简单问答"，不需要复杂的RAG Pipeline

如果你的知识库是50个FAQ，用户的问题在FAQ中有明确答案，你不需要Chunking、Embedding、向量检索、Rerank这些复杂流程。

**错误做法**：搭一个LlamaIndex RAG Pipeline，把50个FAQ做分块、Embedding、索引，然后向量检索。

**正确做法**：把50个FAQ放在System Prompt里，直接问GPT-4o。上下文窗口128K tokens，50个FAQ撑死占用10K tokens。单次查询延迟0.5秒，准确率100%（因为GPT-4o直接看到了所有FAQ）。

**金句：如果你的知识库能塞进一个Prompt里，就不要用RAG。RAG是给"装不下"的知识库准备的。**

## 场景二：你的核心逻辑是"确定性规则"，不需要LLM

某金融风控系统的"AI决策引擎"用了LangChain做Agent。Agent调用工具查询规则引擎，然后判断是否通过。但问题是：规则引擎本身就是确定性的——满足条件就通过，不满足就拒绝。Agent的"判断"完全多余。

更糟的是，Agent偶尔会"幻觉"——规则引擎明明返回了"不通过"，Agent的判断却是"需要人工复核"。这导致了额外的工单和延迟。

**错误做法**：用Agent包裹确定性规则引擎，让LLM做"判断"。

**正确做法**：规则引擎直接返回结果，LLM只负责用自然语言解释结果（如"您的贷款申请未通过，原因是信用评分不足"）。

**金句：不要让LLM做决策，让LLM做解释。决策交给规则引擎，解释交给LLM。**

## 场景三：你的团队只有1-2个人，维护框架的成本超过开发的收益

AI框架的"学习成本"被严重低估。LangChain不是"30分钟入门"的库——它需要你理解Chain、Agent、Tool、Memory、Callback、Retriever、Document Loader等十几个概念。LlamaIndex同样需要你理解Index、Node、QueryEngine、IngestionPipeline等概念。

一个2人团队，如果花1周学习框架，再花2周开发，总投入3周。如果直接用OpenAI API，学习成本0（已经会了），开发时间1周。省下的2周可以做更有价值的事情（如优化产品体验、收集用户反馈）。

**金句：框架的收益需要"团队规模x项目复杂度"足够大才能覆盖学习成本。团队越小，项目越简单，框架的ROI越低。**

## 场景四：你需要"完全可控"，框架的抽象层在阻碍你

AI框架的抽象层是"双刃剑"——它帮你简化了常见操作，但也限制了你的控制力。当你需要做"非标准"的事情时，框架的抽象层就变成了障碍。

某团队用LangChain做RAG，需要实现一个自定义的Chunking策略（按文档的语义层级切分，而不是按字符数）。LangChain的`RecursiveCharacterTextSplitter`不支持这种策略，团队花了3天时间研究LangChain的源码，试图扩展它。最后发现，用纯Python实现自定义Chunking只要200行代码，比扩展LangChain简单得多。

**金句：当你开始"绕过"框架而不是"使用"框架时，你就该考虑放弃框架了。**

## 200行纯Python的"反框架"RAG

以下是一个完整的RAG系统，200行Python，不需要任何AI框架：

```python
import openai
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

class SimpleRAG:
    def __init__(self, api_key):
        self.client = openai.OpenAI(api_key=api_key)
        self.documents = []
        self.embeddings = []
    
    def add_document(self, text, chunk_size=500):
        chunks = self._chunk_text(text, chunk_size)
        for chunk in chunks:
            emb = self._embed(chunk)
            self.documents.append(chunk)
            self.embeddings.append(emb)
    
    def query(self, question, top_k=5):
        q_emb = self._embed(question)
        scores = cosine_similarity([q_emb], self.embeddings)[0]
        top_indices = np.argsort(scores)[-top_k:][::-1]
        context = "\n\n".join([self.documents[i] for i in top_indices])
        return self._generate(question, context)
    
    def _chunk_text(self, text, size):
        return [text[i:i+size] for i in range(0, len(text), size)]
    
    def _embed(self, text):
        resp = self.client.embeddings.create(
            model="text-embedding-3-large", input=text
        )
        return resp.data[0].embedding
    
    def _generate(self, question, context):
        resp = self.client.chat.completions.create(
            model="gpt-4o",
            messages=[{
                "role": "system",
                "content": f"基于以下上下文回答问题：\n\n{context}"
            }, {
                "role": "user",
                "content": question
            }]
        )
        return resp.choices[0].message.content
```

**金句：200行代码的RAG系统，比2万行框架代码的RAG系统，更容易理解、更容易调试、更容易维护。**