---
title: "DeepSeek-V4-Pro 3 个月账单复盘：缓存命中率怎么跑起来的"
date: 2026-07-03
draft: false
tags: ["DeepSeek", "Claude Code", "成本"]
categories: ["账单复盘"]
description: "DeepSeek-V4-Pro 输入命中 0.025 元/MT、未命中 3 元/MT、输出 6 元/MT，高峰翻倍。记录 3 个月真实 Token 消耗与缓存命中率优化过程。"
faq:
  - q: "DeepSeek-V4-Pro 缓存命中多少钱？"
    a: "平时 0.025 元/MT，高峰（9-12、14-18 北京时间）0.05 元/MT，未命中 3 元/MT，差 120 倍。"
  - q: "Claude Code 接 DeepSeek 配置复杂吗？"
    a: "改 3 个环境变量 ANTHROPIC_BASE_URL / AUTH_TOKEN / MODEL 即可，详见接入指南。"
  - q: "DeepSeek-V4-Pro 高峰时段几点？"
    a: "北京时间 9:00-12:00、14:00-18:00，输出翻倍，周末全天平价。"
---

## 我的使用场景

日常用 Claude Code 做两件事：
- **CRUD 级改修**（占 70%）：单文件 < 500 行的小改动，Agent 模式 1-3 轮收
- **重构 / 新模块**（占 30%）：多文件跨模块，Agent 模式 5-15 轮

没跑训练、没跑长文档 summarization，所以**输出占比低、输入缓存命中率是省钱关键**——这跟写长文 / RAG 的人账单结构不一样，看的时候注意。

## 3 个月 Token 明细

| 月份 | 输入命中(MT) | 输入未命中(MT) | 输出(MT) | 费用(¥) | 缓存命中率 |
|---|---|---|---|---|---|
| 4 月 | 28.6 | 1.4 | 12.3 | 387 | 95.3% |
| 5 月 | 41.2 | 1.8 | 15.1 | 421 | 95.8% |
| 6 月 | 56.7 | 2.1 | 22.4 | 548 | 96.4% |

> 数据来源：DeepSeek 控制台每月账单导出，模型 deepseek-v4-pro，未计入 V4-Flash 部分（Flash 那栏另算，占比 < 5%）。

**几个观察**：
- 输入命中率 95%+ 是因为同一个项目会话复用，项目文件 30K 那段基本全走缓存
- 未命中那 1.4-2.1 MT 主要是"新问题追加" + 工具调用结果（这部分没法缓存）
- 输出 6 元/MT 是贵项，但绝对量不大（我输出占比 ~8%）

## 跟 Claude Opus 4.1 比省多少

同用量（4 月口径：输入 30MT / 输出 12.3MT，按 Opus 缓存命中 $0.15/MT、未命中 $15/MT、输出 $75/MT，汇率 7.2 粗估）：

| | DeepSeek V4-Pro | Claude Opus 4.1 |
|---|---|---|
| 输入命中 | ¥0.7 | ¥32 |
| 输入未命中 | ¥4.2 | ¥1296 |
| 输出 | ¥74 | ¥6624 |
| **合计** | **¥79** | **~¥7952** |

> 倍数 ≈ 100x。当然 Opus 能力和 V4-Pro 不是同档，但对我 CRUD 场景 V4-Pro 够用，这笔账决定我长期走 DeepSeek 不回头。

## 缓存命中率是怎么跑起来的

三点最关键，跟前面[接入指南](/posts/claude-deepseek-setup/)那篇呼应的：

1. **会话不重启**：同一个项目一次 `claude` 开进去，跑 2-3 天，项目文件那段 30K 全程走命中。重启一次 = 项目文件重新 prefill = 命中率掉到 0 重新养
2. **系统 prompt 不变**：Claude Code 版本别频繁升，升一次 system 模板可能变，前缀断 → 缓存断
3. **多终端走 LiteLLM 单 master key**：前面聊过的，团队/多终端场景 master key 唯一，DeepSeek 服务端按 key 隔离缓存，prefix KV 能跨终端共享

## 高峰时段踩了两次

DeepSeek V4 正式版 7 月中旬上线后引了峰谷定价，**9:00-12:00、14:00-18:00 输出翻倍**（0.025/3/6 → 0.05/6/12）。

我 6 月底踩了两次：
- 一次 6/25 上午 10 点调一个重构，输出 1.8MT 走高峰 → 多花 ¥10.8
- 一次 6/28 下午 15 点，输出 2.2MT → 多花 ¥13.2

**教训**：非紧急重构挪到 12-14 点午休或 18 点后，输出贵的场景能躲就躲。周末全天平价。

## 给你抄的账单计算器

我放 GitHub 了：[claude-deepseek-config/tools/billing-calc.py](https://github.com/hd1990/claude-deepseek-config/blob/main/tools/billing-calc.py)

用法：
bash
python tools/billing-calc.py 28.6 1.4 12.3 # 4 月平时价
python tools/billing-calc.py 28.6 1.4 12.3 --peak # 4 月高峰价

## FAQ

**Q: DeepSeek-V4-Pro 缓存命中到底多少钱？**
A: 平时 0.025 元/MT，高峰（9-12、14-18）0.05 元/MT，跟未命中 3 元/MT 差 120 倍，所以命中率是省钱命门。

**Q: Claude Code 接 DeepSeek 配置复杂吗？**
A: 不复杂，改 3 个环境变量 `ANTHROPIC_BASE_URL / AUTH_TOKEN / MODEL` 就行，详见[接入指南](/posts/claude-deepseek-setup/)。

**Q: 高峰时段具体几点？**
A: DeepSeek V4 高峰是北京时间 9:00-12:00、14:00-18:00，周末全天平价。

**Q: 多终端 / 团队用 DeepSeek + Claude Code 怎么共享缓存？**
A: 前面接入指南那篇聊过——LiteLLM 单 master key 对外的架构，缓存按 key 隔离，所以多终端能共享 DeepSeek 那层 prefix KV。

**Q: DeepSeek-V4-Pro 和 V4-Flash 怎么选？**
A: CRUD 日常 Flash（输出 2 元/MT）够用，复杂重构 / Agent 多轮切 Pro。我 95% 时间 Flash，5% 切 Pro。

**Q: 账单数据哪里导？**
A: DeepSeek 控制台 → 费用 → 明细导出 CSV，按 model + 日期透视就行。
