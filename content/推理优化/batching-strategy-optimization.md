---
title: "批处理策略优化：你的推理服务正在浪费60%的GPU算力"
date: 2026-07-13
draft: false
categories: ["推理优化"]
tags: ["批处理", "Continuous Batching", "动态批处理", "吞吐量", "GPU利用率"]
author: "AI2AI.xin 编辑部 - hd1990"
description: "批处理是推理服务的核心优化，但大多数人的批处理策略还停留在'攒够一批再处理'的原始阶段。Continuous Batching、Dynamic Batching、Priority Batching——这些策略可以让你的GPU利用率从30%提升到80%。"
---

## 你的GPU在"摸鱼"

如果你用过vLLM的GPU利用率监控，你可能会看到一个令人沮丧的数字：**GPU利用率只有30-50%。**

这意味着你花$2.5/小时租的H100，有50-70%的时间在"摸鱼"——不是在做计算，而是在等待。等待什么？等待请求凑够一个batch，等待一个长请求处理完才能处理下一个短请求，等待KV Cache有空间。

**批处理策略是GPU利用率的"水龙头"——策略对了，GPU利用率从30%飙升到80%；策略错了，GPU利用率永远上不去。**

## 批处理为什么重要？

**大模型推理的悖论：** 单请求的延迟和吞吐量是矛盾的。如果你一个一个处理请求，延迟最低（每个请求不需要等待），但吞吐量最低（GPU大量时间空闲）。如果你攒一批请求一起处理，吞吐量最高，但延迟最高（请求需要等待凑够批次）。

**批处理策略的目标：在延迟和吞吐量之间找到最优平衡。** 即：在保证延迟SLI（Service Level Indicator）的前提下，最大化吞吐量。

## 批处理策略的演化

**第一代：Static Batching（静态批处理）。** 攒够N个请求，一起处理，处理完再攒下一批。最简单，但GPU利用率最低——每个请求都要等凑够批次。

**第二代：Dynamic Batching（动态批处理）。** 在max_batch_size和max_wait_time之间动态平衡。如果请求来得快，攒够max_batch_size就处理；如果请求来得慢，到达max_wait_time就处理（即使不满批次）。

**第三代：Continuous Batching（连续批处理，vLLM的核心创新）。** 不是"攒一批处理一批"，而是"进来一个处理一个，长完一个退出一个"。**这是2026年推理服务的标配。**

## Continuous Batching的工作方式

传统批处理：请求A、B、C一起进来，一起处理，一起完成。但请求A只有10个token要生成，请求C有1000个token要生成。**请求A在10个token后完成了，但它必须等待请求C完成999个token，才能"退出"批次。** 这就是"队头阻塞"（Head-of-Line Blocking）。

Continuous Batching：请求A完成10个token后，立即退出批次。GPU继续处理请求B和C。同时，新的请求D可以立即加入批次。**没有"等待"，GPU一直在处理有效请求。**

**效果：**
- GPU利用率从30-50%提升到70-85%
- P99延迟降低50-80%（因为短请求不会被长请求阻塞）
- 吞吐量提升2-3倍

## 高级批处理策略

**Priority Batching（优先级批处理）。** 给请求分配优先级，高优先级请求优先处理。适合"混合场景"——实时对话（高优先级）和批量分析（低优先级）混合。

**Chunked Prefill（分块预填充）。** 将长prompt的预填充阶段分成多个小块，穿插到其他请求的解码阶段中。**解决了"长prompt阻塞短请求"的问题。**

**Preemption（抢占）。** 当高优先级请求到达时，暂停低优先级请求，将它的KV Cache换出到CPU内存，先处理高优先级请求。**适合"实时对话优先"的场景。**

## 批处理参数调优实战

我们在Qwen 3.0 72B（8xH100）上，测试了不同批处理策略的效果：

| 策略 | 吞吐量 | P50延迟 | P99延迟 | GPU利用率 |
|------|--------|---------|---------|----------|
| Static Batching (batch=32) | 1200 tok/s | 150ms | 3000ms | 35% |
| Dynamic Batching (max=64) | 1800 tok/s | 120ms | 2000ms | 50% |
| Continuous Batching | 3200 tok/s | 80ms | 800ms | 78% |
| + Chunked Prefill | 3500 tok/s | 75ms | 600ms | 82% |
| + Priority Batching | 3400 tok/s | 60ms(高)/120ms(低) | 400ms | 80% |

**Continuous Batching是基础，Chunked Prefill和Priority Batching是锦上添花。** 先上Continuous Batching，效果不够再叠加其他策略。

## 批处理优化的"坑"

**坑1：max_batch_size太大。** 很多人把max_batch_size设得很大（如128），以为可以提升吞吐量。但batch太大，KV Cache占用更多，显存碎片化，反而降低吞吐量。**建议从32开始，逐步增加，找到吞吐量不再提升的点。**

**坑2：忽略了max_num_seqs。** vLLM的max_num_seqs限制了同时处理的请求数。如果max_num_seqs太小，即使GPU有闲置算力，也无法处理更多请求。**建议max_num_seqs = max_batch_size * 2。**

**坑3：没有监控批次效率。** 批次效率 = 实际batch_size / max_batch_size。如果批次效率<50%，说明请求来得太慢，GPU在"空转"。解决方案：降低max_batch_size，或者增加burst_size。

## 结语：批处理是"技术活"

**批处理优化不是"调一个参数"，而是"理解请求模式、GPU特性、延迟要求"的综合工程。** 一个好的批处理策略，可以让同样的GPU多服务3倍的用户。

**核心原则：让GPU一直有活干，但别让任何一个请求等太久。** Continuous Batching做到了这一点，Priority Batching和Chunked Prefill让这一点做得更好。

---

**数据来源**：vLLM Continuous Batching论文，作者团队实测数据（2026年6月），各推理框架批处理文档。