# Claude Code 降本实战

[![Site](https://img.shields.io/badge/Blog-ai2ai.xin-blue)](https://ai2ai.xin)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

个人博客，记录 Claude Code 接入 DeepSeek/智谱的实战经验与成本优化。

## 这是什么

我把 Claude Code 从 Anthropic 官方 API（月均 ¥5,000+）切到了 DeepSeek 兼容接口（月均 ¥450），成本降到 **1/30**。这个仓库是配套的：

- 📝 **博客文章**：[ai2ai.xin](https://ai2ai.xin)
- 🔧 **配置脚本**：[config.example.sh](config.example.sh) —— 复制即用
- 🐛 **踩坑记录**：缓存命中率、高峰时段避让、模型混用陷阱

## 快速开始

```bash
# 1. 复制配置模板
cp config.example.sh config.sh

# 2. 编辑 config.sh，填入你的 DeepSeek API Key
vim config.sh

# 3. 加载配置
source config.sh

# 4. 启动 Claude Code
claude
```

## 文章列表

| 文章 | 关键词 |
|---|---|
| [Claude Code 接入 DeepSeek 完整指南](https://ai2ai.xin/posts/claude-deepseek-setup/) | 配置、避坑、成本对比 |
| [DeepSeek-V4-Pro 3 个月账单复盘](https://ai2ai.xin/posts/deepseek-cost-report/) | 缓存命中率、高峰定价、账单计算器 |

## 如果你觉得有用

请 Star ⭐ 这个仓库，让更多人看到这个方案。

有问题或建议？提 [Issue](https://github.com/hd1990/my-ai-log/issues) 或访问 [ai2ai.xin](https://ai2ai.xin) 联系我。