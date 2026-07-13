---
title: "RAG评估方法：你的RAG系统到底好不好？90%的团队用错了评估指标"
date: 2026-07-13
draft: false
categories: ["RAG技术"]
tags: ["RAG", "评估", "RAGAS", "召回率", "准确率", "评估指标", "测试集"]
author: "AI2AI.xin 编辑部 - hd1990"
description: "RAG系统的评估不是「准确率」一个数字就能概括的。本文介绍RAGAS框架，从检索质量、生成质量、忠实度三个维度构建完整的RAG评估体系。"
---

## "我们的RAG准确率85%"——这个数字什么也说明不了

每个RAG团队都会说"我们的RAG准确率XX%"。但如果你问他们"你是怎么评估的？"，答案通常是"我们手动测了50个问题，感觉还不错"。

这种评估方式有三个问题：
1. **样本量太小**：50个问题不能代表真实用户的查询分布
2. **主观性太强**："感觉还不错"不是评估，是自我安慰
3. **没有分维度**：准确率是一个模糊的概念——检索准确、生成准确、忠实度，这是三个不同的维度

2026年，RAG评估已经有一套成熟的框架。以下是完整介绍。

## RAGAS：RAG评估的事实标准

RAGAS（RAG Assessment）是2026年最主流的RAG评估框架。它把RAG系统的质量拆分为三个维度：

### 维度一：检索质量（Retrieval Quality）

**评估指标**：
- **Context Precision**：检索到的文档中，有多少是真正相关的？越高越好。
- **Context Recall**：所有相关的文档中，有多少被检索到了？越高越好。

**金句**：Context Precision是"搜出来的东西对不对"，Context Recall是"该搜的东西搜没搜到"。两者缺一不可。

### 维度二：生成质量（Generation Quality）

**评估指标**：
- **Answer Relevance**：生成的答案和用户问题有多相关？
- **Answer Correctness**：生成的答案是否事实正确？

**金句**：Answer Relevance是"答非所问吗"，Answer Correctness是"答对了吗"。前者是及格线，后者是优秀线。

### 维度三：忠实度（Faithfulness）

**评估指标**：
- **Faithfulness**：生成的答案是否忠实于检索到的文档？有没有"编造"文档中没有的信息？

**金句**：Faithfulness是RAG评估最重要的指标。一个答案可以"相关"、"正确"，但如果它来自LLM的幻觉而不是检索文档，那这个RAG系统就失败了。

## 用RAGAS评估你的RAG系统

```python
from ragas import evaluate
from ragas.metrics import (
    context_precision, context_recall,
    answer_relevancy, answer_correctness,
    faithfulness
)

# 准备测试数据
test_data = {
    "question": ["什么是RAG？", "RAG和微调有什么区别？"],
    "answer": ["RAG是检索增强生成...", "RAG和微调的主要区别..."],
    "contexts": [["文档1", "文档2"], ["文档3", "文档4"]],
    "ground_truth": ["RAG定义...", "RAG和微调的区别..."]
}

# 评估
result = evaluate(test_data, metrics=[
    context_precision, context_recall,
    answer_relevancy, answer_correctness, faithfulness
])
print(result)
```

## 测试集构建：RAG评估中最难的部分

RAGAS需要"ground truth"（标准答案）来计算评估指标。但构建高质量的测试集是RAG评估中最难的部分。

**三种构建方式**：

1. **人工标注**（最准确，最贵）：让领域专家手动标注问题和答案。成本高，但质量最高。
2. **LLM生成**（快速，需验证）：用LLM从你的文档中自动生成问题和答案。速度快，但需要人工验证。
3. **用户反馈**（最真实，最慢）：收集真实用户的查询和反馈。数据最真实，但积累慢。

**最佳实践**：先用LLM生成1000个问题，人工验证200个，再结合上线后的用户反馈持续补充。

**金句**：测试集的质量决定了RAG评估的质量。垃圾测试集产生垃圾评估，再好的评估框架也救不了。

## 持续评估：RAG系统不是"上线即完美"

RAG系统的质量会随着时间变化：

- 新文档的加入可能改变检索质量
- Embedding模型的更新可能影响召回率
- LLM的版本更新可能改变生成质量
- 用户查询模式的变化可能暴露新的盲区

**建立持续评估Pipeline**：
1. 每周自动运行RAGAS评估
2. 监控关键指标的变化趋势
3. 当指标下降超过5%时，触发告警
4. 定期更新测试集（加入新的用户查询）

**金句**：RAG评估不是"一次性"的工作，而是"持续监控"的系统。你的RAG系统不是在"上线"时做评估，而是在"每天"做评估。

## RAGAS的局限性

1. **需要LLM做评估**：RAGAS用LLM评估LLM的输出，这存在"学生改学生试卷"的问题。
2. **评估本身有成本**：每次评估需要调用LLM，1000个测试用例可能消耗$50-100。
3. **对非英文支持较弱**：RAGAS的中文评估能力不如英文。

**金句**：RAGAS是2026年最好的RAG评估框架，但它不是完美的。把它当成"体检报告"，而不是"诊断书"。**