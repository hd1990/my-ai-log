---
title: "Continuous Batching深度解析：为什么vLLM比原生HuggingFace快10倍？"
date: 2026-07-13
draft: false
categories: ["推理优化"]
tags: ["Continuous Batching", "vLLM", "PagedAttention", "调度策略", "源码分析"]
author: "AI2AI.xin 编辑部 - hd1990"
description: "Continuous Batching是vLLM的核心创新，也是2026年推理服务的标配。我们深入源码，拆解了Continuous Batching的调度策略、显存管理和实现细节。"
---

## 为什么vLLM快10倍？

vLLM在2026年是推理服务的"标配"。它比原生HuggingFace Transformers快10倍不止。但大多数人只知道"vLLM很快"，不知道它为什么快。

**vLLM快的秘密只有两个：PagedAttention和Continuous Batching。** PagedAttention解决了KV Cache的显存碎片化问题，Continuous Batching解决了GPU利用率低的问题。

本文深入Continuous Batching的源码，拆解它的调度策略和实现细节。

## 传统批处理的问题

传统批处理（Static Batching）的工作方式是：攒够N个请求，组成一个batch，一起处理，处理完再攒下一批。

**问题1：短请求被长请求阻塞。** 请求A（10个输出token）和请求B（1000个输出token）在同一个batch中。请求A只需要10步就完成了，但它必须等待请求B完成1000步才能退出batch。**GPU在等待请求B的999步时，请求A的输出位置是"空"的——浪费了GPU算力。**

**问题2：新请求需要等待。** 请求C在batch处理过程中到达，但它必须等待当前batch处理完才能加入。**即使GPU有闲置算力，也无法处理请求C。**

**问题3：显存利用率低。** 每个请求预分配最大长度的KV Cache，但大多数请求用不到。**显存利用率只有30-50%。**

## Continuous Batching的解决方案

**Continuous Batching的核心思想：请求不是"一批一批"处理的，而是"流式"处理的。** 每个请求在生成一个token后，就可以决定"继续"还是"退出"。新请求可以随时加入。

**vLLM的调度循环（伪代码）：**
```python
while True:
    # 1. 从等待队列中取出新请求，加入运行队列
    new_requests = waiting_queue.pop_all()
    running_queue.extend(new_requests)
    
    # 2. 对运行队列中的所有请求，生成一个token
    for request in running_queue:
        token = model.generate_one_token(request)
        request.output.append(token)
    
    # 3. 检查每个请求是否完成
    for request in running_queue:
        if request.is_finished():
            running_queue.remove(request)
            return_result(request)
    
    # 4. 回到步骤1
```

**关键：每个请求生成一个token后，就检查是否完成。完成的立即退出，给新请求腾出空间。** 没有"等待一个batch完成"的概念。

## 调度的"加减法"

**加（Add）：** 新请求从等待队列进入运行队列。vLLM的调度器会检查：当前GPU显存是否足够？如果不够，即使有等待请求，也不添加（防止OOM）。

**减（Remove）：** 完成的请求从运行队列退出。vLLM释放它的KV Cache（PagedAttention的"页"），供新请求使用。

**抢占（Preempt）：** 当显存不够时，vLLM可以选择"抢占"低优先级请求——将它的KV Cache换出到CPU内存，给高优先级请求腾空间。**抢占是"最后的手段"，因为它会显著增加延迟。**

## 调度的"智能决策"

vLLM的调度器不止是"加加减减"，它还需要做"智能决策"：

**决策1：多少请求同时运行？** max_num_seqs参数控制最大并发请求数。太大，KV Cache不够；太小，GPU利用率低。**建议：max_num_seqs = max_batch_size * 2。**

**决策2：prefill和decode的优先级？** prefill（处理输入token）比decode（生成输出token）更耗计算资源。如果大量请求同时进入prefill，会导致decode延迟飙升。**Chunked Prefill将prefill分块，穿插到decode之间，避免prefill阻塞decode。**

**决策3：KV Cache的分配策略？** 每个请求分配多少KV Cache页？预分配太多，浪费显存；预分配太少，频繁分配导致延迟。**vLLM默认预分配16个页，然后按需扩展。**

## Continuous Batching的局限性

**Continuous Batching不是"万能药"。** 它有三个局限：

**1. 对短请求效果最好。** 如果所有请求都是长请求（1000+ tokens输出），Continuous Batching的优势不明显——因为请求很少"提前退出"。

**2. 对混合长度效果最好。** 如果所有请求长度相同，Continuous Batching退化为Static Batching。

**3. 需要PagedAttention配合。** Continuous Batching需要KV Cache的"动态分配"——PagedAttention提供了这个能力。没有PagedAttention，Continuous Batching无法实现。

## 结语：Continuous Batching是"调度革命"

**Continuous Batching是2026年推理服务最重要的"调度革命"。** 它让GPU利用率从30-50%提升到70-85%，让短请求不再被长请求阻塞，让新请求不再等待。

**理解Continuous Batching，才能真正理解vLLM为什么快。** 它不是一个"黑盒"，而是一个精心设计的调度系统。当你理解了它的调度策略，你就能针对你的场景进行精细调优。

---

**数据来源**：vLLM源码（GitHub v0.9.0），vLLM论文（Kwon et al., 2023），作者团队源码分析。