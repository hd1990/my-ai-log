---
title: "开源许可证演进：2026年AGPL和BSL的争议"
date: 2026-07-09
draft: false
categories: ["开源"]
tags: ["开源许可证", "AGPL", "BSL", "SSPL", "Apache 2.0", "MIT", "开源合规", "许可证争议"]
author: "AI2AI.xin 编辑部 - hd1990"
description: "2026年开源许可证格局正在发生深刻变化，AGPL、BSL和SSPL等非传统许可证的使用率大幅上升。从MongoDB到Redis，从Elastic到HashiCorp，深度解析开源许可证的演进趋势、争议焦点和商业逻辑。"
slug: "open-source-license-2026"
---

## 开源许可证：2026年的分裂与重组

2026年，开源许可证格局正在经历深刻的分裂。传统上，开源许可证被分为"宽松型"（Permissive：MIT、Apache 2.0、BSD）和"强保护型"（Copyleft：GPL、AGPL）。但2026年，一种新的分类正在形成——"真正开源"（OSI批准的许可证）和"源码可用"（Source Available，如BSL、SSPL、Elastic License）。

根据WhiteSource（现Mend）的数据，2026年新发布的开源项目中，宽松型许可证（MIT、Apache 2.0）占约65%，GPL家族占约15%，而"源码可用"许可证（BSL、SSPL等）占约10%。"源码可用"许可证的比例在2020年几乎为零，六年间的快速上升反映了开源商业模式正在经历深刻变革。

## OSI和"开源"的定义

开源促进会（Open Source Initiative，OSI）在2026年仍然是"开源"定义的守护者。OSI的"开源定义"（Open Source Definition，OSD）包含10条标准，核心是：自由再分发、源码公开、允许衍生作品和不得歧视任何个人或群体。

但在2026年，OSI的权威性面临挑战。越来越多的公司使用"源码可用"（Source Available）许可证——它们公开源码，但不满足OSI的所有标准（通常是因为限制商业竞争性使用）。这些许可证的倡导者认为，传统的开源许可已经无法适应当前的商业模式，特别是云厂商利用开源代码提供竞争性服务的问题。

OSI在2026年发布了"开源AI定义"（Open Source AI Definition）的v1.0版本，试图定义什么构成"开源AI"。这一尝试引发了巨大争议——模型权重、训练数据和训练代码之间的关系远比传统软件复杂。

## AGPL：最强保护型许可证

AGPL（GNU Affero General Public License）是GPL的"网络服务版"。AGPL的核心要求是：如果你在网络上提供基于AGPL代码的服务，你必须公开你的修改。这一条款旨在解决"ASP漏洞"（Application Service Provider漏洞）——云厂商可以使用GPL代码而不公开修改，因为GPL只在"分发"时才触发。

2026年，AGPLv3的使用率持续增长。Grafana、Nextcloud、Mattermost和MinIO等知名项目都在使用AGPLv3。AGPLv3在"开源"和"商业保护"之间取得了平衡——它满足OSI的"开源"定义，但通过"网络服务条款"阻止了云厂商的"搭便车"行为。

但AGPLv3也有其局限性。许多企业对AGPLv3有"恐惧"——担心内部使用AGPL代码会触发"传染性"（Copyleft）条款，强制公开内部代码。这种恐惧虽然在一定程度上被夸大了，但确实阻碍了AGPLv3在企业中的采用。

## BSL：商业源码许可证

BSL（Business Source License）是2026年最受关注的"源码可用"许可证。BSL由MariaDB在2016年创建，其核心机制是：代码在特定时间内（通常是2-4年）受限制性条款保护（通常是限制生产性使用），之后自动转换为真正的开源许可证（通常是GPL或Apache 2.0）。

2026年，使用BSL的知名项目包括：

- **HashiCorp**（Terraform、Vault、Consul）：2023年从MPL（Mozilla Public License）转为BSL，限制竞争对手使用这些代码构建竞争性产品。2026年，Terraform的BSL保护期即将结束，代码将转换为Apache 2.0。
- **Couchbase**：从Apache 2.0转为BSL，保护期4年。
- **CockroachDB**：从Apache 2.0转为BSL，保护期3年。
- **Sentry**：从BSD-3-Clause转为BSL，保护期3年。

BSL的支持者认为，它在保护商业利益和回馈开源社区之间取得了平衡——代码最终会成为真正的开源软件。批评者则认为，BSL不是真正的开源，因为它在保护期内限制了使用。

## SSPL：最激进的保护型许可证

SSPL（Server Side Public License）是MongoDB在2018年创建的最激进保护型许可证。SSPL基于AGPLv3，但增加了一个关键条款：如果你将SSPL软件作为服务提供，你必须公开你用于提供该服务的所有软件的源码——不仅仅是SSPL软件本身，还包括管理软件、用户界面、API、自动化软件、监控软件等。

这一条款意味着，如果AWS想要提供MongoDB的托管服务，AWS必须公开其整个基础设施管理软件栈的源码。这个要求显然不可能被云厂商接受。

2026年，SSPL仍然面临争议。OSI在2021年正式拒绝将SSPL认定为"开源许可证"。Debian和Fedora等Linux发行版也拒绝打包SSPL软件。但SSPL在法律上有效，MongoDB、Elasticsearch和Redis（2026年）都是SSPL的主要使用者。

**Redis的许可证变更**是2026年开源社区最受关注的事件之一。Redis在2024年从BSD许可证转为SSPL/RSAL（Redis Source Available License），社区迅速创建了Valkey分支（由Linux基金会托管）。2026年，Valkey的发展势头强劲，AWS、Google Cloud和Oracle都宣布支持Valkey，而Redis Labs继续专注于其商业版。

## Elastic License 2.0：限制竞争性使用

Elastic在2021年从Apache 2.0转为SSPL/Elastic License 2.0，引发了AWS创建OpenSearch分支。2026年，OpenSearch已经成为AWS增长最快的搜索服务之一，而Elastic继续以ELv2许可发展。

Elastic License 2.0的核心限制是：不允许将Elastic软件作为托管服务提供给第三方。这意味着企业可以在内部免费使用Elasticsearch，但SaaS公司不能直接提供Elasticsearch的托管服务。

## 许可证选择：2026年项目如何决策

2026年，开源项目在许可证选择上面临越来越复杂的权衡。

**MIT/Apache 2.0**：适合希望最大化采用率和生态集成的项目。风险是云厂商可能提供竞争性服务。适合基础设施类项目（如Kubernetes、React），因为它们的价值在于生态而非代码本身。

**GPL/AGPL**：适合希望保持代码自由的项目，同时允许商业使用。AGPL特别适合网络服务类项目。风险是可能降低企业采用率。

**BSL**：适合需要保护商业利益的项目，同时承诺未来成为真正的开源。适合由单一公司主导的开源项目。风险是可能导致社区分裂。

**SSPL/ELv2**：适合需要最大化商业保护的项目，特别是数据库和搜索等容易被云厂商"搭便车"的领域。风险是可能被开源社区排斥，并导致社区分支。

## 开源AI的许可证挑战

2026年，开源AI的许可证问题是最热门的话题之一。传统的开源许可证是为代码设计的，而AI模型涉及三个层次：模型权重、训练数据和训练代码。

**模型权重的许可证**：Llama 4使用Llama Community License（不允许超过7亿月活用户使用），DeepSeek使用MIT许可证，Mistral使用Apache 2.0。MIT和Apache 2.0作为"真正的开源"获得社区认可，但Meta的许可证不满足OSI定义。

**训练数据的许可证**：训练数据是否可以"开源"？在什么许可证下？这是2026年开源AI面临的最大法律挑战。《纽约时报》诉OpenAI案在全球范围内引发了关于AI训练数据版权的大讨论，但目前还没有明确的判例。

**OSI的"开源AI定义"**：OSI在2026年发布了v1.0版本，要求"开源AI"必须提供训练数据的"足够详细的信息"，以便"熟练的人可以重建一个实质上等效的系统"。这一要求远比传统开源许可证严格，但OSI认为这是保证AI模型可复现性的必要条件。

## 中国开源许可证生态

2026年，中国开源生态在许可证合规方面正在快速成熟。中国开源社区在2026年发布了"木兰宽松许可证"（Mulan PSL）v2.0版本，这是中国第一个获得OSI批准的开源许可证。Mulan PSL是中英双语许可证，在中文法律语境下具有更好的可执行性。

越来越多的中国开源项目在2026年采用双重许可策略：国内使用Mulan PSL，国际使用Apache 2.0或MIT。

## 展望：开源许可证的终局

2026年，开源许可证格局正在从"两极化"（宽松 vs 强保护）向"三极化"（宽松、强保护、源码可用）演进。这种分化反映了开源生态的成熟——不同的项目有不同的商业需求，一刀切的许可证选择已经不再适用。

未来，开源许可证的发展将受到几个关键因素的影响：OSI的权威能否维持？"源码可用"许可证能否获得更广泛的接受？开源AI的许可证问题如何解决？政府对开源许可证的监管是否会增加？

无论答案如何，开源许可证的核心原则——促进代码共享、保护用户自由、平衡商业利益——将继续指引这个领域的发展。