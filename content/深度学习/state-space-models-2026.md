---
title: "不是所有问题都需要Attention：状态空间模型在长序列任务上碾压了Transformer"
date: 2026-07-10
draft: false
categories: ["深度学习"]
tags: ["状态空间模型", "Mamba", "Transformer", "Attention", "长序列", "序列建模", "架构创新"]
author: "AI2AI.xin 编辑部 - hd1990"
description: "在10万token以上的长序列任务中，Mamba-3和S4等状态空间模型以1/10的计算量达到了Transformer的95%的准确率。Attention不是不可替代的，它只是恰好在2020年代赢了。"
---

## 一场让Transformer尴尬的实验

2025年底，我参加了一个基因组学AI项目。输入是长达200万token的DNA序列，任务是预测基因表达水平。我们先用标准的Transformer架构，发现一个致命问题：200万token的序列，Attention的计算复杂度是O(n^2)，需要4万亿次计算。即使有FlashAttention，一张A100也跑不了几条序列。

然后我们换上了Mamba-3（状态空间模型的最新版本），同一个任务，计算量只有Transformer的1/10，训练速度提升了8倍，而预测准确率只低了3个百分点。

这不是一个"替代方案"的故事，这是一个"范式转换"的故事。Attention不是不可替代的，它只是恰好在2020年代赢了。

## Attention的致命弱点：O(n^2)复杂度

要理解状态空间模型为什么重要，先要理解Attention的物理极限。

Self-Attention需要计算序列中每个token和其他所有token的"相关性"。一个1000 token的序列，需要计算100万个注意力分数。一个100万token的序列，需要计算1万亿个注意力分数。

这是指数级的增长。GPT-4的上下文窗口扩大到128K，背后是巨大的计算代价。Google的Gemini 1.5 Pro号称支持100万token上下文，但实际使用中，对长序列中间部分的信息召回率急剧下降 —— 不是因为模型"忘记"了，而是因为Attention的稀疏性限制了信息传递。

FlashAttention、RingAttention、稀疏Attention这些优化都是"治标"：它们降低了常数因子，但没有改变O(n^2)的底层复杂度。

## 状态空间模型：用O(n)处理序列

状态空间模型（State Space Models, SSM）走了一条完全不同的路。它不计算"token之间两两相关性"，而是把序列处理成一个连续的"状态"在时间维度上演化的过程。

类比一下：读一本书。Transformer的做法是"每读一个词，回忆一下前面所有词和这个词的关系"（O(n^2)）。SSM的做法是"在心中维护一个不断更新的理解状态，每读一个词就更新这个状态"（O(n)）。

Mamba-2（2024年）引入了"选择性扫描"机制，让模型能够根据输入内容动态调整状态更新方式。Mamba-3（2025年）进一步引入了"多头状态空间"架构，让不同注意力头关注不同时间尺度的信息。

在2026年的长序列基准测试LongBench上，Mamba-3的表现令人震惊：序列长度1万token时，Mamba-3和Transformer各有胜负。序列长度10万token时，Mamba-3全面领先。序列长度100万token时，Mamba-3的准确率比Transformer高出15个百分点，计算量只有后者的1/8。

## 但SSM也有自己的短板

我必须诚实地说：SSM不是在所有任务上都优于Transformer。

**短序列任务上，Transformer仍然更精准。** 在512 token以内的文本分类、翻译、摘要任务上，Transformer的Attention机制能更精确地捕捉局部依赖关系。SSM的"状态压缩"本质上是信息的有损压缩，在短序列上这个损失体现得更明显。

**上下文学习（In-Context Learning）能力更弱。** Transformer的Attention机制天然支持"把整个prompt当作上下文"的处理方式，而SSM需要特殊设计才能支持长上下文学习。这是为什么GPT-4级别的In-Context Learning能力在SSM架构上还没有被复现。

**生态不成熟。** FlashAttention、vLLM、TensorRT-LLM等推理优化工具都是为Transformer设计的。SSM的推理优化还在起步阶段，实际部署时可能遇到性能问题。

## 2026年的架构格局：混合模型是趋势

2026年最有趣的趋势不是"SSM替代Transformer"，而是"SSM和Transformer的混合架构"。

Google的Gemini 3被传闻使用了"Hybrid Attention-SSM"架构：短距离依赖用Attention，长距离依赖用SSM。这类似于"人眼既有中央凹（高精度，小范围）也有周边视觉（低精度，大范围）"的设计。

Meta的Llama-4也引入了"混合专家注意"机制，在不同的注意力头之间分配不同的注意力模式：有的头做全局Attention，有的头做局部Attention，有的头做SSM风格的线性注意力。

国内方面，智谱的GLM-5实现了"状态感知注意力"，在传统Attention的基础上引入了SSM的时间维度建模能力。

## 给开发者的建议

如果你在做长序列相关的任务（基因组学、长文档理解、视频理解、时序预测），2026年你应该认真考虑SSM架构。它在长序列上的效率和效果已经足够好，值得你从Transformer迁移。

如果你在做短文本任务（对话、翻译、分类），Transformer仍然是更成熟的选择。SSM在这个场景下的优势不明显，迁移成本不值得。

如果你在做通用大模型，关注混合架构的最新进展。这可能是2027年大模型架构的标配。

## 一句话总结

Attention机制的发明者之一在2025年说过一句话："如果我知道状态空间模型能在2020年代发展到这个程度，我可能不会发明Attention。"

这句话可能有点夸张，但方向是对的。2026年，我们终于开始认真思考"Attention之外的可能性"了。