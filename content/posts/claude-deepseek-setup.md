---
title: "Claude Code 接入 DeepSeek 完整指南（含避坑）"
date: 2026-07-02
draft: false
tags: ["Claude Code", "DeepSeek", "教程"]
categories: ["技术教程"]
description: "手把手教你把 DeepSeek 接入 Claude Code，包含环境变量配置和成本分析。"
---

## 为什么要把 DeepSeek 接到 Claude Code？

Claude Code 原生只支持 Anthropic 官方 API，价格昂贵。DeepSeek 提供了 Anthropic 兼容接口，接入后成本可降低 90% 以上，且支持 1M 上下文。

## 前置准备

1. 已安装 Claude Code（`npm install -g @anthropic-ai/claude-code`）。
2. 拥有 DeepSeek 账号并充值（[点此注册](https://platform.deepseek.com)）。

## 三步配置（复制即可用）

打开终端，执行以下命令：

```bash
# 设置 DeepSeek 的兼容接口地址
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"

# 填入你的 DeepSeek API Key
export ANTHROPIC_AUTH_TOKEN="sk-your-key-here"

# 指定主模型（推荐 V4 Pro）
export ANTHROPIC_MODEL="deepseek-v4-pro"
```

**验证**：输入 `claude`，如果能进入对话界面，说明配置成功。

## 真实账单：3 个月成本复盘

以下是我在 2026 年 4-6 月的真实消耗数据：

| 月份 | 输入 Tokens | 输出 Tokens | 总费用 |
| :--- | :--- | :--- | :--- |
| 4 月 | 120M | 15M | ¥380 |
| 5 月 | 150M | 18M | ¥420 |
| 6 月 | 200M | 25M | ¥550 |

**结论**：同等用量下，若使用 Claude Opus 4，费用约为 ¥15,000+。

## 三个致命避坑点

1. **Small Fast Model**：务必设置 `ANTHROPIC_SMALL_FAST_MODEL=deepseek-v4-flash`，否则 Claude Code 会调用昂贵的 Opus 做摘要。
2. **高峰时段**：DeepSeek V4 在北京时间 9:00-12:00 和 14:00-18:00 价格翻倍，非紧急任务建议错峰。
3. **缓存命中率**：保持终端会话不重启，复用 KV Cache 能省 90% 输入费用。

## 常见问题 FAQ

**Q: DeepSeek 会替代 Claude Code 吗？**

A: 不会。Claude Code 是 Agent 工具，DeepSeek 是模型底座。两者是搭配关系，用 DeepSeek 的算力跑 Claude Code 的逻辑。

**Q: 支持智谱 GLM 吗？**

A: 支持。将 `ANTHROPIC_BASE_URL` 改为 `https://open.bigmodel.cn/api/paas/v4` 即可。