---
title: "从Jupyter到生产环境：我们花了3个月踩完的模型部署14个坑"
date: 2026-07-13
draft: false
categories: ["MLOps"]
tags: ["模型部署", "MLOps", "生产环境", "Triton", "FastAPI"]
author: "AI2AI.xin 编辑部 - hd1990"
description: "一个LLM上线过程实录：从Jupyter Notebook到生产环境，我们踩过的14个坑和每个坑的修复方案，总有一个你会遇到。"
---

## 那个周五晚上的事故

2026年3月，周五晚上11点。我们的推荐模型在Jupyter Notebook上跑出了SOTA结果——AUC 0.87，离线评估完美。团队决定：周一上线。

周一早上9点，模型上线30分钟后，P99延迟飙到了12秒。CPU利用率100%。用户开始投诉推荐结果"加载不出来"。我们紧急回滚。

这不是一个虚构的故事。这是我们在2026年真实踩过的坑。三个月后，我们终于把模型稳定部署到了生产环境，期间踩了14个坑。下面是完整复盘。

**金句：Jupyter Notebook到生产环境的距离，比从地球到火星还远。**

## 坑1-5：依赖和环境

**坑1：Python版本不匹配。** Jupyter用的是Python 3.12，生产服务器是Python 3.10。一个`itertools.batched`函数直接报错。教训：容器化是唯一解。Dockerfile里写死Python版本，不要用latest。

**坑2：CUDA驱动版本不一致。** 训练环境CUDA 12.4，生产环境CUDA 12.1。PyTorch加载模型时报"cuda runtime error"。教训：CUDA版本必须和PyTorch版本精确匹配，建议用NVIDIA的官方Docker镜像。

**坑3：pip依赖冲突。** requirements.txt里scikit-learn版本写的是`>=1.0`，结果装了1.6，API变了。教训：用`pip freeze > requirements.txt`锁定精确版本。

**坑4：模型文件太大，Docker镜像超过10GB。** 教训：模型文件不要打包进Docker镜像，用挂载卷或从对象存储加载。

**坑5：环境变量硬编码。** API密钥、数据库密码写在代码里。教训：用环境变量或Secret Manager。

## 坑6-10：性能和推理

**坑6：没有做模型量化。** FP32精度的模型，推理一次300ms。量化到INT8后，降到60ms，精度损失不到1%。教训：生产环境一定要做量化，FP16/INT8是标配。

**坑7：没有批处理。** 每次请求单独推理，GPU利用率只有15%。加了动态批处理后，GPU利用率提到80%，吞吐量提升5倍。教训：用Triton Inference Server的dynamic batching。

**坑8：冷启动时间太长。** 模型加载需要30秒，第一个请求超时。教训：实现模型预加载（warmup），健康检查通过后再接入流量。

**坑9：没有做输入验证。** 一个恶意请求传了2MB的JSON，直接把服务打崩。教训：加请求大小限制、输入格式校验、超时机制。

**坑10：Python GIL导致并发瓶颈。** FastAPI单进程，4核CPU只能用到1核。教训：用gunicorn多worker，或者用Ray Serve做分布式推理。

## 坑11-14：运维和监控

**坑11：没有监控推理延迟。** 模型性能退化后，延迟缓慢上升，但没人发现。教训：Prometheus + Grafana监控P50/P95/P99延迟、吞吐量、错误率。

**坑12：日志太多，磁盘写满。** 每个请求打印完整输入输出，一天100GB日志。教训：结构化日志，设置日志级别和轮转策略。

**坑13：没有灰度发布。** 新模型直接全量上线，出问题后全量回滚。教训：用金丝雀发布或蓝绿部署，先放5%流量验证。

**坑14：模型和代码版本不一致。** 代码回滚了，但模型没回滚，结果特征不匹配。教训：模型版本和代码版本绑定，用MLflow或DVC管理模型版本。

## 我们的最终架构

三个月后，我们的推荐模型部署架构是：Triton Inference Server + ONNX Runtime、FastAPI + gunicorn (4 workers)、Kubernetes + HPA、Prometheus + Grafana + AlertManager、MLflow + S3、GitHub Actions + ArgoCD。

部署后，P99延迟从12秒降到120ms，可用性从99.5%提到99.95%。

**结论：模型部署不是"把模型放上去就跑"，而是"让模型持续稳定地跑"。** 这14个坑，每一个都是学费。希望你能少交一点。