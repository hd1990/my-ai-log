---
title: "在 Unreal Engine 5 中搭建一个实时数字人：从零到出镜的全流程教程"
date: 2026-07-13
draft: false
categories: ["数字人"]
tags: ["UE5", "数字人教程", "MetaHuman", "实时渲染", "技术教程"]
author: "AI2AI.xin 编辑部 - hd1990"
description: "从零开始，用 Unreal Engine 5 + MetaHuman + Audio2Face 搭建一个实时数字人，完整教程+避坑指南。"
---

## 前言

2026 年，如果你想"亲手"搭建一个实时数字人，Unreal Engine 5 是最好的选择。Epic Games 的 MetaHuman 框架让你可以在几小时内创建一个"照片级真实"的数字人，并让它实时说话、做表情、互动。

**这篇文章是完整的教程——从安装 UE5 到让数字人实时说话，每一步都有代码和截图说明。**

## 你需要什么

**硬件：**
- GPU：NVIDIA RTX 3070 或更高（推荐 RTX 4090）
- RAM：32 GB 或更高
- 存储：100 GB 可用空间
- 麦克风（用于实时语音输入）
- 可选：摄像头（用于面部捕捉）

**软件：**
- Unreal Engine 5.4+（免费）
- MetaHuman Plugin（UE5 内置）
- MetaHuman Creator（网页工具，免费）
- NVIDIA Audio2Face（免费，需要 NVIDIA GPU）
- Epic Games 账号

## 第 1 步：创建 MetaHuman 数字人

1. 打开 https://metahuman.unrealengine.com/
2. 点击"Create MetaHuman"
3. 选择"Start from Preset"（从预设开始）或"Start from Scratch"（从零开始）
4. 调整面部特征：眼睛、鼻子、嘴巴、脸型、发型、肤色等
5. 点击"Create MetaHuman" → 等待 5 分钟 → MetaHuman 生成完成
6. 点击"Download" → 下载 MetaHuman 到你的 UE5 项目

**耗时：** 15-30 分钟
**成本：** 免费

## 第 2 步：导入 MetaHuman 到 UE5

1. 打开 Unreal Engine 5.4+
2. 创建新项目 → 选择"Games" → "Blank" → "No Starter Content"
3. 在 UE5 中，打开 Epic Games Launcher → "Vault" → 找到你的 MetaHuman → "Add to Project"
4. 在 UE5 中，打开"Quixel Bridge"（Window → Quixel Bridge）→ 找到你的 MetaHuman → "Download" → "Add"
5. 将 MetaHuman 拖入场景中

**耗时：** 10-20 分钟
**成本：** 免费

## 第 3 步：设置 MetaHuman 的面部表情（Blendshapes）

MetaHuman 自带 200+ 个 blendshapes，覆盖了所有基本面部表情。但要让它"实时说话"，你需要配置 Audio2Face。

1. 下载 NVIDIA Audio2Face：https://www.nvidia.com/en-us/omniverse/apps/audio2face/
2. 安装后，打开 Audio2Face
3. 将你的 MetaHuman 导出为 USD 格式（在 UE5 中右键 MetaHuman → "Export" → "USD"）
4. 在 Audio2Face 中，导入 USD 文件
5. Audio2Face 会自动识别 MetaHuman 的 blendshapes 并建立映射
6. 测试：在 Audio2Face 中播放一段音频 → MetaHuman 会自动对口型

**耗时：** 1-2 小时（主要是下载和安装）
**成本：** 免费（Audio2Face 对个人免费）

## 第 4 步：配置实时语音交互

这是最关键的一步。你需要让数字人"听到"你的声音，并"回应"你。

**架构：**
```
你的声音 → 麦克风 → ASR（语音识别）→ GPT-5 API（LLM）→ TTS（语音合成）→ Audio2Face（面部动画）→ MetaHuman（实时渲染）
```

**代码实现（Python 后端）：**

```python
import whisper  # OpenAI Whisper for ASR
import openai   # GPT-5 API
import requests # ElevenLabs TTS
import pyaudio  # Audio playback
import numpy as np

# Step 1: Speech Recognition
def transcribe_audio(audio_file):
    model = whisper.load_model("base")
    result = model.transcribe(audio_file)
    return result["text"]

# Step 2: LLM Response
def get_llm_response(text):
    client = openai.OpenAI()
    response = client.chat.completions.create(
        model="gpt-5",
        messages=[
            {"role": "system", "content": "你是一个友好的数字人助手，名叫小灵。"},
            {"role": "user", "content": text}
        ]
    )
    return response.choices[0].message.content

# Step 3: Text-to-Speech
def text_to_speech(text):
    url = "https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM"  # 替换为你的 voice ID
    headers = {
        "xi-api-key": "YOUR_ELEVENLABS_API_KEY",
        "Content-Type": "application/json"
    }
    data = {
        "text": text,
        "voice_settings": {"stability": 0.75, "similarity_boost": 0.75}
    }
    response = requests.post(url, json=data, headers=headers)
    return response.content  # 返回音频数据

# Step 4: Play Audio (for testing)
def play_audio(audio_data):
    p = pyaudio.PyAudio()
    stream = p.open(format=pyaudio.paInt16, channels=1, rate=44100, output=True)
    stream.write(audio_data)
    stream.stop_stream()
    stream.close()

# Main Loop
user_text = transcribe_audio("user_input.wav")
llm_response = get_llm_response(user_text)
audio_data = text_to_speech(llm_response)
play_audio(audio_data)
```

**然后，将 TTS 音频发送到 Audio2Face：**
- Audio2Face 监听音频输入
- 当 TTS 音频播放时，Audio2Face 实时生成 MetaHuman 的面部动画
- MetaHuman 在 UE5 中实时渲染，看起来像"在说话"

**延迟优化：**
- 端到端延迟 = ASR (0.5s) + LLM (1-3s) + TTS (0.5-1s) + Audio2Face (0.2s) + 渲染 (0.05s) = 2-5 秒
- 优化建议：使用更快的 ASR（如 Deepgram），使用流式 TTS（如 ElevenLabs Streaming），使用更小的 LLM 模型

## 第 5 步：添加身体动作（可选）

1. 下载 Mixamo 动画（免费）：https://www.mixamo.com/
2. 下载"Idle"、"Talking"、"Gesturing"等动画
3. 在 UE5 中，创建"Animation Blueprint"
4. 将动画绑定到 MetaHuman 的骨骼
5. 配置"动画状态机"——当数字人"不说话"时播放 Idle，当数字人"说话"时播放 Talking + Gesturing

## 避坑指南

**坑一：MetaHuman 的瞳孔追踪默认关闭。** MetaHuman 默认不会"看"摄像头。你需要在 MetaHuman Blueprint 中启用"Eye Tracking"并设置"Look At Target"为摄像头位置。

**坑二：Audio2Face 的音频延迟。** Audio2Face 有约 0.2 秒的处理延迟。如果你需要极低延迟，可以考虑使用 UE5 内置的"Live Link Face"（用 iPhone 摄像头做面部捕捉）。

**坑三：MetaHuman 的 LOD（细节层次）。** 默认情况下，MetaHuman 在远处会自动降低细节。如果你需要"特写"镜头，需要手动设置 LOD 为"LOD 0"（最高细节）。

**坑四：GPU 显存。** 一个 MetaHuman 的纹理贴图约 2-4 GB。如果你的场景中有多个 MetaHuman，显存可能不够。建议使用 RTX 4090（24 GB 显存）。

## 结尾

用 UE5 + MetaHuman + Audio2Face 搭建一个实时数字人，在 2026 年已经不需要"专业团队"——一个人，一个周末，一个 RTX 4090，就可以搞定。

**但你要管理好期望：** 这个数字人"能说话"，但它的"智能"取决于你接入的 LLM（GPT-5 API 的质量）。它的"动作"是预设的动画，不是"自主生成"的。它"看起来真实"，但仔细观察，仍然有"恐怖谷"的感觉。

**如果你想要一个"能用"的数字人，这个教程足够了。** 如果你想要一个"惊艳"的数字人，你还需要 3D 建模师、动画师、AI 工程师的协作。但无论如何，UE5 + MetaHuman 是 2026 年数字人开发的最佳起点。

---

*工具链接：MetaHuman Creator (https://metahuman.unrealengine.com)；NVIDIA Audio2Face (https://www.nvidia.com/omniverse/apps/audio2face)；Mixamo (https://www.mixamo.com)*