---
title: "ComfyUI入门：从零搭建你的AI绘画工作流"
date: 2026-07-10
draft: false
categories: ["AI绘画"]
tags: ["ComfyUI", "工作流", "Stable Diffusion", "入门教程", "节点"]
author: "AI2AI.xin 编辑部 - hd1990"
description: "ComfyUI看起来像「程序员才能用的工具」，但它的强大远超你的想象。这篇教程从零开始，带你搭建第一个AI绘画工作流，并理解节点式创作的核心逻辑。"
---

## 看起来像航天控制台，用起来更香

第一次打开ComfyUI，你看到的是密密麻麻的节点和连线，像极了NASA的航天控制台。很多人当场就被劝退了。

但如果你能坚持30分钟，你会发现：ComfyUI是AI绘画领域最强大的创作工具，没有之一。它的「节点式工作流」不是缺点，而是最大的优势。

这篇教程，从零开始带你搭建第一个工作流。

## 为什么要学ComfyUI

如果你只是偶尔玩玩AI绘画，WebUI（如Automatic1111）完全够用。但如果你想「认真」做AI绘画，ComfyUI是必选项。

三个原因：

第一，可控性。ComfyUI的节点式架构，让你可以精确控制AI绘画的每一个环节。从提示词编码到采样器选择，从模型加载到图像输出——每一步你都可以自定义。

第二，效率。ComfyUI的工作流可以保存和复用。你花一小时搭建的「电商产品图工作流」，之后每次生成只需要点一下鼠标。这种「批量化」能力，是WebUI无法比拟的。

第三，社区。ComfyUI社区共享了大量成熟的工作流，你可以直接下载使用。从「真人写真」到「建筑可视化」，从「动漫生成」到「LOGO设计」，社区已经帮你搭建好了。

## 安装和环境配置

第一步：下载ComfyUI。推荐使用「ComfyUI Manager」版本，它集成了插件管理器，方便后续安装扩展。

第二步：下载模型。SD 4.0基础模型约7GB，推荐从Hugging Face或CivitAI下载。将模型文件放入ComfyUI/models/checkpoints目录。

第三步：启动ComfyUI。运行run_nvidia_gpu.bat（Windows）或python main.py（Mac/Linux），浏览器会自动打开http://127.0.0.1:8188。

配置要求：NVIDIA显卡（至少8GB显存），16GB以上内存。Mac用户可以用M系列芯片，但生成速度较慢。

## 第一个工作流：基础文本生成图像

ComfyUI默认加载的工作流，就是最基础的「文本生成图像」。它包含5个核心节点：

1. Load Checkpoint：加载模型。点击节点，选择你下载的SD 4.0模型。
2. CLIP Text Encode（Positive）：正面提示词。输入你想要生成的内容描述。
3. CLIP Text Encode（Negative）：负面提示词。输入你不想要的内容（如「blurry」「low quality」「deformed」）。
4. KSampler：采样器。控制生成过程的核心参数——步数、CFG、种子等。
5. VAE Decode + Save Image：解码并保存图像。

点击「Queue Prompt」，等待30秒到2分钟（取决于你的显卡），你的第一张AI图片就生成了。

## 进阶工作流：ControlNet精准控制

基础工作流只能「随机生成」，要让AI「按你的想法生成」，需要ControlNet。

ControlNet的核心逻辑是：你给它一张「控制图」（如线稿、姿态骨架、深度图），它按照控制图的「结构」来生成新图像。

最常用的ControlNet类型：

- Canny（边缘检测）：上传一张线稿，AI按照线稿的轮廓生成图像。
- OpenPose（姿态检测）：上传一张人物照片，AI提取姿态，然后按照这个姿态生成新人物。
- Depth（深度检测）：上传一张室内照片，AI提取空间深度信息，然后生成不同风格但相同空间结构的图像。

搭建ControlNet工作流：在「Load Checkpoint」和「KSampler」之间，插入「Load ControlNet Model」和「Apply ControlNet」节点。将你的控制图连接到「Apply ControlNet」节点。

## 总结

ComfyUI的学习曲线确实陡峭，但一旦掌握了节点式工作流的逻辑，你会发现AI绘画的边界被极大地扩展了。

记住一个原则：节点越多，控制越精准。花时间搭建一个「好」的工作流，比每次手动调整参数要高效得多。

ComfyUI不是「更难用的WebUI」，它是「更强大的创作工具」。如果你愿意花一个下午学习，你会发现AI绘画的全新世界。