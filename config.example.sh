#!/usr/bin/env bash
# ============================================================
# Claude Code + DeepSeek 环境变量配置
# 来源: https://ai2ai.xin/posts/claude-deepseek-setup/
#
# 使用方法:
#   1. 将 sk-your-key-here 替换为你的 DeepSeek API Key
#   2. source config.sh
#   3. 执行 claude 验证
# ============================================================

export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="sk-your-key-here"
export ANTHROPIC_MODEL="deepseek-v4-pro"
export ANTHROPIC_SMALL_FAST_MODEL="deepseek-v4-flash"

# 可选：高峰时段检测（北京时间 9:00-12:00, 14:00-18:00 价格翻倍）
is_peak() {
  h=$(date +%H)
  [[ $h -ge 9 && $h -lt 12 ]] || [[ $h -ge 14 && $h -lt 18 ]]
}

# 可选：备用模型（智谱 GLM）
# export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/paas/v4"
# export ANTHROPIC_AUTH_TOKEN="your-zhipu-key"
# export ANTHROPIC_MODEL="glm-4-plus"