---
title: "Claude Code + DeepSeek 进阶：多终端缓存共享、自动切模型与成本监控"
date: 2026-07-06
draft: false
tags: ["Claude Code", "DeepSeek", "LiteLLM", "成本优化"]
categories: ["技术教程"]
description: "单机配置只是开始。搞定多终端缓存共享、高峰自动切模型、DeepSeek 挂了自动 fallback，才是生产级方案。"
---

## 前情提要

前两篇搞定了[基础接入](/posts/claude-deepseek-setup/)和[账单复盘](/posts/deepseek-cost-report/)，单机用起来没问题了。但实际工作中你会很快遇到三个新问题：

1. **多终端场景**：台式机、笔记本、服务器各开一个 Claude Code，缓存各自为战，命中率根本养不起来
2. **高峰时段**：上午 10 点调个重构，跑完发现多花了一倍钱，心疼
3. **DeepSeek 挂了**：API 偶尔 503，你盯着 terminal 干等，生产力归零

这篇解决这三个问题，把方案从"能用"升级到"生产级"。

## 架构总览

```
┌──────────┐  ┌──────────┐  ┌──────────┐
│ MacBook  │  │  Linux   │  │  Windows │
│ Claude   │  │  Claude  │  │  Claude  │
└────┬─────┘  └────┬─────┘  └────┬─────┘
     │             │             │
     └──────────┬──┴─────────────┘
                │
        ┌───────▼───────┐
        │   LiteLLM     │  ← 统一代理，单 master key
        │   :4000       │
        └───────┬───────┘
                │
        ┌───────▼───────┐
        │  路由 & 缓存   │  ← 高峰检测、自动 fallback
        └───────┬───────┘
                │
     ┌──────────┼──────────┐
     ▼          ▼          ▼
 DeepSeek   Anthropic   智谱
  默认       fallback    备用
```

核心思路：**LiteLLM 做统一代理，所有终端指向同一个 endpoint，缓存 key 唯一，命中率跨终端共享。**

## 第一步：LiteLLM 代理搭建

```bash
pip install litellm
```

`proxy_config.yaml`：

```yaml
model_list:
  - model_name: "deepseek-v4-pro"
    litellm_params:
      model: "deepseek/deepseek-v4-pro"
      api_key: "sk-your-deepseek-key"
      rpm: 60          # 限制并发，避免触发限流
  - model_name: "deepseek-v4-flash"
    litellm_params:
      model: "deepseek/deepseek-v4-flash"
      api_key: "sk-your-deepseek-key"
      rpm: 120
  - model_name: "claude-opus-4"       # fallback
    litellm_params:
      model: "anthropic/claude-opus-4-20250514"
      api_key: "sk-your-anthropic-key"

general_settings:
  master_key: "sk-master-key-123456"  # 所有终端共用这个 key
  database_url: "postgresql://..."    # 可选，生产环境建议加
```

启动：

```bash
litellm --config proxy_config.yaml --port 4000
```

终端配置统一指向 LiteLLM：

```bash
export ANTHROPIC_BASE_URL="http://your-server:4000/anthropic"
export ANTHROPIC_AUTH_TOKEN="sk-master-key-123456"
export ANTHROPIC_MODEL="deepseek-v4-pro"
export ANTHROPIC_SMALL_FAST_MODEL="deepseek-v4-flash"
```

关键点：**所有终端用同一个 `ANTHROPIC_AUTH_TOKEN`（即 LiteLLM 的 master key）**。DeepSeek 服务端按 key 隔离 KV Cache，同一个 key 发过来的请求共享缓存前缀，跨终端命中率直接拉满。

## 第二步：高峰时段自动切模型

DeepSeek V4 高峰时段（9:00-12:00, 14:00-18:00 北京时间）输出价格翻倍。与其手动错峰，不如让 LiteLLM 自动判断并切换。

`litellm_router.py`：

```python
import datetime
import litellm

def get_model_for_now():
    """高峰时段自动降级到 Flash，非高峰用 Pro"""
    hour = datetime.datetime.now().hour
    is_peak = (9 <= hour < 12) or (14 <= hour < 18)
    return "deepseek-v4-flash" if is_peak else "deepseek-v4-pro"

# 在 LiteLLM 的 pre-call hook 中调用
def router_hook(request):
    request["model"] = get_model_for_now()
    return request
```

LiteLLM 配置中注册 hook：

```yaml
litellm_settings:
  callbacks: ["litellm_router"]
```

这样上午 10 点跑重构自动走 Flash（便宜一半），下午 2 点写单测也走 Flash，非高峰时段自动切回 Pro。**全程无感，不需要手动换模型。**

## 第三步：DeepSeek 挂了自动 Fallback

DeepSeek API 偶尔 503，尤其是在高峰时段。LiteLLM 自带 fallback 机制，配置即可：

```yaml
model_list:
  - model_name: "deepseek-v4-pro"
    litellm_params:
      model: "deepseek/deepseek-v4-pro"
      api_key: "sk-your-deepseek-key"
      fallbacks: ["claude-opus-4"]   # 挂了自动切
      num_retries: 2
      timeout: 30
  - model_name: "claude-opus-4"
    litellm_params:
      model: "anthropic/claude-opus-4-20250514"
      api_key: "sk-your-anthropic-key"
```

再加上上下文窗口降级——DeepSeek 偶尔会返回 context length 超限错误，自动切到短上下文模型：

```yaml
context_window_fallbacks:
  - model_name: "deepseek-v4-pro"
    fallback: "deepseek-v4-flash"  # Flash 支持 1M context
```

## 成本监控：搭一个简单的 Dashboard

LiteLLM 自带 Prometheus 指标暴露，加上 Grafana 就能搭监控。但如果你不想折腾，LiteLLM 的日志已经够用：

```bash
# 查看今日消费
litellm --config proxy_config.yaml --port 4000 --detailed_debug
```

更实用的做法——写一个每日成本摘要脚本，cron 定时推到 Slack/飞书：

```python
import sqlite3
import requests

def daily_summary():
    conn = sqlite3.connect("litellm.db")
    cursor = conn.cursor()
    cursor.execute("""
        SELECT model, SUM(prompt_tokens), SUM(completion_tokens),
               SUM(cost), COUNT(*)
        FROM spend_logs
        WHERE date(start_time) = date('now')
        GROUP BY model
    """)
    rows = cursor.fetchall()

    total = sum(r[3] for r in rows)
    msg = f"今日 Claude Code 成本: ¥{total:.2f}\n"
    for model, pt, ct, cost, reqs in rows:
        msg += f"  {model}: {reqs} 次请求, ¥{cost:.2f}\n"

    # 推到飞书 webhook
    requests.post("https://open.feishu.cn/your-webhook",
                  json={"msg_type": "text", "content": {"text": msg}})

if __name__ == "__main__":
    daily_summary()
```

cron 配置（每天 20:00 推送）：

```bash
0 20 * * * python3 /path/to/daily_summary.py
```

## 三个小提醒

**1. LiteLLM 的缓存和 DeepSeek 的缓存是两层**

LiteLLM 自带 Redis 缓存层（可选），DeepSeek 服务端也有 KV Cache。两者不冲突，但 LiteLLM 缓存的粒度是"完全相同的请求"，在 Claude Code Agent 场景下命中率很低——因为每次 tool use 结果不同，请求体不可能完全一样。所以**不要依赖 LiteLLM 缓存，重心放在养 DeepSeek 的 KV Cache**。

**2. 服务器选型**

LiteLLM 本身很轻量，1C2G 的轻量云服务器足够。但如果你要开 Redis 缓存或 PostgreSQL，建议 2C4G 起步。网络延迟是关键——尽量选同一区域的机器（DeepSeek 服务器在华东，国内 VPS 选上海/杭州）。

**3. 多用户的 master key 隔离**

如果是团队用，给每个成员分配独立的 LiteLLM user key（不是 master key），这样每个人的成本可追踪，且不会互相污染缓存。LiteLLM 支持开箱即用的 internal user management。

---

前三篇搞定了接入 → 复盘 → 进阶，基本覆盖了个人开发者用 Claude Code + DeepSeek 的全链路。下一篇准备写什么？欢迎在评论区告诉我。

> 原文首发于 [ai2ai.xin](https://www.ai2ai.xin/)