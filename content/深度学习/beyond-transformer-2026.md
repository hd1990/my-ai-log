---
title: "Transformer之外：状态空间模型和Mamba"
date: 2026-07-09
draft: false
categories: ["深度学习"]
tags: ["Transformer", "状态空间模型", "Mamba", "Mamba-2", "SSM", "深度学习架构"]
author: "深度学习研究员"
description: "2026年状态空间模型（SSM）和Mamba架构正在挑战Transformer的统治地位，线性复杂度使其在超长序列处理上具有天然优势，混合架构正在成为下一代基础模型的新范式。"
---

# Transformer之外：状态空间模型和Mamba

## 引言：Attention Is Not All You Need

2017年，"Attention Is All You Need"这篇划时代的论文奠定了Transformer架构的统治地位。此后近十年，从BERT到GPT，从ViT到CLIP，Transformer几乎统治了自然语言处理、计算机视觉、语音识别、多模态学习等所有AI领域。然而，2026年，Transformer的统治地位正在被一个意想不到的挑战者所动摇——状态空间模型（State Space Models, SSM）。

Transformer的根本性局限在于其自注意力机制的二次复杂度（O(n²)），这使得处理长序列的成本随序列长度平方增长。尽管FlashAttention等工程优化将这一瓶颈推迟了，但物理极限无法被完全消除。当2026年的应用需求要求模型处理百万token的上下文（如完整代码库、长视频、基因组序列）时，二次复杂度成为了一个越来越难以忽视的障碍。

状态空间模型提供了线性复杂度（O(n)）的替代方案，正在从"有趣的研究方向"发展为"可行的生产选择"。

## 状态空间模型的前世今生

状态空间模型并非新概念——它在控制论和信号处理领域已有几十年的历史。经典的SSM描述了一个系统如何通过隐藏状态将输入信号映射到输出信号。在深度学习中，SSM的核心思想是使用一个结构化的状态转移矩阵来建模序列数据，而不是像Transformer那样显式地计算所有token对之间的注意力权重。

SSM的深度学习复兴始于2021年的S4（Structured State Space sequence model）模型。S4通过引入HiPPO（High-order Polynomial Projection Operators）矩阵来初始化状态转移矩阵，使得模型能够捕获长程依赖。S4在Long Range Arena（LRA）基准测试中展现了超越Transformer的长序列处理能力。

2022-2023年，SSM经历了快速发展：H3（Hungry Hungry Hippos）结合了SSM和门控注意力，S5引入了并行扫描，而最终的突破来自于2023年12月的**Mamba**。

## Mamba：选择性状态空间的突破

Mamba由Albert Gu（CMU）和Tri Dao（Princeton）在2023年底提出，是SSM发展的一个分水岭。Mamba的核心创新在于引入了**选择性机制**（Selection Mechanism）——让状态空间模型的参数依赖于输入，而不是固定的。

在传统的SSM（如S4）中，状态转移矩阵A、输入矩阵B和输出矩阵C对于所有输入序列都是相同的。这种"时不变"（time-invariant）特性使得计算高效（可以通过卷积实现），但限制了模型根据输入内容进行选择性聚焦的能力。Mamba通过让B、C和步长参数Δ成为输入的函数，实现了"选择性"——模型可以决定哪些信息需要记住，哪些可以遗忘。

这一看似简单的改变带来了深远的影响：Mamba在语言建模、DNA序列建模、音频生成等任务上达到了与Transformer相当甚至更好的性能，而计算复杂度保持线性。更重要的是，Mamba在推理时不需要维护KV缓存，这使得长序列推理的内存使用大幅降低。

## Mamba-2与混合架构：2025-2026的新进展

2024年5月，Mamba-2发布，进一步深化了SSM与注意力之间的联系。Mamba-2揭示了一个关键洞察：SSM可以重新表述为一种**结构化掩码注意力**（Structured Masked Attention），其中注意力掩码由SSM的动力学决定。这种统一视角不仅带来了理论上的美观，还启发了新的高效实现——Mamba-2使用了一种称为"状态空间对偶性"（State Space Duality, SSD）的算法，在TPU和GPU上都实现了比Mamba-1更快的速度。

2026年，从Mamba-2衍生出的**混合架构**已经成为下一代基础模型的主流范式。混合架构的核心理念是：在需要长程上下文理解的层使用SSM（线性复杂度），在需要精确局部推理的层使用注意力（二次复杂度但更强大），取两者之长。

AI21 Labs的**Jamba**是混合架构的先锋。Jamba在2024年发布，结合了Mamba SSM层和Transformer注意力层，以及MoE（Mixture of Experts）前馈网络。Jamba在2025-2026年持续演进，最新的Jamba-2在2026年初发布，在256K上下文窗口的各种基准测试中展现出了卓越的性能，同时保持了比纯Transformer模型更低的推理成本。

**Zamba**是另一个值得关注的混合架构模型，其设计理念是"小而精"——通过精心设计的SSM和注意力混合比例，在较小的模型规模下实现强劲的性能。

在开源社区，**HuggingFace**在2026年提供了一流的Mamba和混合架构支持，包括预训练模型、推理优化和微调工具。**NVIDIA**发布了优化的Mamba CUDA内核，使得Mamba可以充分利用其GPU的Tensor Core。

## 视觉领域的状态空间模型

SSM不仅在语言领域挑战Transformer，在计算机视觉领域也同样来势汹汹。**Vision Mamba（Vim）**在2024年提出，将Mamba架构适配到视觉任务，通过双向SSM来捕获图像的空间依赖关系。**VMamba**进一步引入了交叉扫描模块（Cross-Scan Module），通过在不同方向扫描图像来构建全局感受野。

2026年，视觉SSM在多个任务上已经达到了与Vision Transformer（ViT）相当的性能，同时在处理高分辨率图像时展现出显著的效率优势。在医学影像分析（尤其是高分辨率的病理切片和CT扫描）中，视觉SSM的线性复杂度使其成为比ViT更实用的选择。

**VideoMamba**在2026年表现出色，利用SSM的线性复杂度来处理长视频的时空建模。在视频理解、动作识别和视频生成任务中，VideoMamba展现出了比Video Transformer更高的效率。

## 状态空间模型的优势与局限

2026年，SSM和Mamba的优势已经得到了充分验证：

**线性复杂度**使得SSM在处理超长序列时具有天然优势。当上下文长度从10万token扩展到100万token时，Transformer的注意力计算量增长100倍，而SSM只增长10倍。这使得SSM在基因组学、长文档分析、代码库理解和长时间序列预测等场景中特别有价值。

**推理效率**是SSM的另一大优势。由于不需要维护KV缓存，SSM的推理内存占用与序列长度无关（常数级），这使得它在资源受限的边缘设备上部署具有显著优势。

**持续信号处理**是SSM的传统优势领域。在音频处理、时间序列分析和控制系统中，SSM的连续时间表示提供了Transformer所不具备的物理直觉。

然而，SSM并非万能药。它在以下方面仍然存在局限：

**上下文学习能力**（In-Context Learning）是SSM相对Transformer的弱项。Transformer的注意力机制天然支持上下文学习——模型在看到新的上下文示例时可以即时调整其行为。SSM在这方面表现较弱，因为其状态演化是局部的，缺乏全局的信息检索能力。

**记忆召回能力**（Associative Recall）是SSM的另一个短板。当需要精确地从长上下文中检索特定信息片段时，Transformer的注意力机制可以直接"跳转"到相关位置，而SSM需要通过状态逐步演化，可能会丢失精确的检索信息。

**模型规模扩展**（Scaling Law）方面，SSM在大规模下的表现尚不完全明确。虽然Mamba在中等规模（<10B参数）下表现良好，但在万亿参数级别，SSM的扩展规律是否与Transformer一致，仍然是一个开放的研究问题。

## 混合架构：集大成者

2026年的共识正在形成：未来的基础模型不太可能是纯Transformer或纯SSM，而是**两者的混合**。混合架构的设计空间很大——如何分配SSM和注意力层的比例，如何排列它们，是否使用MoE——这些选择正在成为模型架构设计的新前沿。

Google DeepMind的**Griffin**架构在2026年引起了广泛关注。Griffin使用了一种新颖的"门控线性循环"（Gated Linear Recurrence）层与局部注意力层交替排列，在效率和质量之间取得了出色的平衡。

**RWKV**（Receptance Weighted Key Value）是另一个值得关注的架构，它试图在保持RNN式线性复杂度的同时，实现Transformer级别的建模能力。RWKV在2026年已经发展到了第7代，在开源社区中拥有忠实用户群。

## 结论：Transformer不会消失，但不再孤独

2026年，状态空间模型和Mamba已经从"Transformer替代品"的小众研究方向，成长为"Transformer合作伙伴"的主流技术路线。Transformer不会消失——它的注意力机制在需要精确检索和上下文学习的场景中仍然不可替代——但它不再孤独。

混合架构——即SSM与注意力的结合——正在成为下一代基础模型的默认范式。这种混合不仅体现在模型架构层面，还体现在应用层面：不同的任务可能使用不同的架构组合，纯SSM用于超长序列处理，纯Transformer用于复杂推理，混合架构用于通用场景。

在"Attention Is All You Need"发表近十年后的2026年，我们终于可以说：Attention is not all you need。状态空间模型正在为深度学习开启一个更高效、更灵活的新时代。而这场架构革命的终极赢家，将是那些能够将Transformer和SSM优势融合的混合架构设计者。