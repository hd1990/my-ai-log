---
title: "Prompt Engineering 进阶：从入门到写出高质量提示词"
date: 2026-07-09
draft: false
categories: ["ai学习"]
tags: ["Prompt", "提示词工程", "Claude", "ChatGPT", "技巧"]
author: "AI学习指南"
description: "Prompt Engineering 是2026年最重要的AI技能之一。本文从基础到进阶，系统讲解写出高质量提示词的技巧和框架。"
---

## Prompt 写得好，AI 输出差十倍

同样的模型，同样的任务，提示词写得好和写得差，输出质量差距可以达到 10 倍。Prompt Engineering 是 2026 年性价比最高的 AI 技能——学起来快，回报立竿见影。

## 基础篇：好 Prompt 的四个要素

一个高质量的 Prompt 通常包含四个要素：

```
1. 角色（Role）：你希望 AI 扮演什么角色
2. 任务（Task）：要完成什么
3. 格式（Format）：输出格式的要求
4. 约束（Constraint）：限制条件
```

### 差 vs 好的对比

**差的 Prompt**：
> "帮我写一篇关于 AI 的文章"

**好的 Prompt**：
> "你是一个 AI 技术博主，为开发者读者写一篇 1500 字的文章，介绍 2026 年 AI Agent 的发展趋势。文章结构：现状 → 3 个关键趋势 → 对开发者的影响 → 总结。语言风格：专业但不生硬，多用数据和案例。不要使用营销话术。"

## 进阶篇：六大技巧

### 技巧一：Few-Shot Prompting（少样本提示）

给 AI 看 2-3 个示例，它能更准确地理解你的要求。

```
请按照以下格式回复用户的问题：

示例1：
用户：Python 怎么读文件？
回复：使用 `with open('file.txt', 'r') as f: content = f.read()`

示例2：
用户：Python 怎么发 HTTP 请求？
回复：使用 `import requests; response = requests.get('url')`

现在请回复：
用户：Python 怎么解析 JSON？
```

### 技巧二：Chain-of-Thought（思维链）

让 AI 展示推理过程，能得到更准确的答案。

```
问题：一只股票周一涨了 10%，周二跌了 10%，周三涨了 5%，现在的价格相比上周五收盘价涨了还是跌了？请逐步推理。
```

### 技巧三：Role Prompting（角色扮演）

给 AI 一个具体的角色，它的回答会更专业。

```
你是一个有 10 年经验的前端架构师，精通 React 和 TypeScript。请审查以下代码，指出潜在的性能问题和架构风险。
```

### 技巧四：结构化输出

要求 AI 按特定格式输出，便于后续处理。

```
请用 JSON 格式输出以下信息：
{
  "title": "文章标题",
  "summary": "100字摘要",
  "keywords": ["关键词1", "关键词2"],
  "difficulty": "初级/中级/高级"
}
```

### 技巧五：迭代优化

一次写不出完美 Prompt，迭代 2-3 次才是常态。

```
第一轮：先让 AI 给出一个基本版本
第二轮：针对不满意的地方提修改意见
第三轮：微调细节
```

### 技巧六：System Prompt 与 User Prompt 分离

在 Claude 和 ChatGPT 的 API 中，System Prompt 和 User Prompt 是分开的。System Prompt 设置规则和角色，User Prompt 是具体任务。

```
System: 你是一个严格的技术编辑，只接受有代码示例和实测数据的回答。拒绝任何没有数据支撑的泛泛之谈。

User: 请介绍 React 19 的 Server Components 特性。
```

## 常见错误

| 错误 | 正确做法 |
|---|---|
| Prompt 太短太模糊 | 给出具体角色、任务、格式要求 |
| 一次问太多问题 | 拆分成多个独立对话 |
| 不接受 AI 的"不知道" | 当 AI 表示不确定时，重新描述问题 |
| 不检查 AI 的输出 | 始终验证 AI 给出的数据和事实 |

## 总结

Prompt Engineering 本质上是一种"精确沟通"的能力。你越能清晰地表达你的需求，AI 就越能给你满意的答案。建议把这六个技巧贴在桌面上，每次写 Prompt 的时候对照检查一下。