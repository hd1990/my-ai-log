---
title: "AI代码助手「语言偏好」：AI在Python上最强，在Rust上最弱，为什么？"
date: 2026-07-13
draft: false
categories: ["AI代码助手"]
tags: ["AI代码助手", "编程语言", "Python", "Rust", "AI编程"]
author: "AI2AI.xin 编辑部 - hd1990"
description: "AI代码助手在不同编程语言上的表现天差地别。在Python、JavaScript上，AI可以做到85%正确率。在Rust、Haskell上，AI只有50%正确率。这是为什么？这对技术选型有什么影响？"
---

## AI「偏科」严重

2026年，一项研究测试了AI代码助手在10种编程语言上的表现。结果发现，AI在Python和JavaScript上的代码正确率约为85%，在Java和C++上约为75%，在Go和TypeScript上约为70%，在Rust上约为55%，在Haskell上约为45%。

为什么AI「偏科」这么严重？因为AI在训练数据中「看到」的Python代码最多（GitHub上Python是最流行的语言），Rust和Haskell的代码量最少。AI的代码能力，本质是「训练数据的镜像」。

**金句：AI代码助手不是「全能程序员」，而是「有偏见的程序员」——它在「流行语言」上很强，在「小众语言」上很弱。**

## 这对技术选型有什么影响？

**影响一：Python和JavaScript的「飞轮效应」。** AI在Python和JS上最强 → 开发者更愿意用Python和JS（因为AI能帮忙） → 更多Python和JS代码被写出 → AI在Python和JS上训练数据更多 → AI在Python和JS上更强。这是一个「正反馈循环」——Python和JS的生态会越来越强，小众语言越来越难追赶。

**影响二：Rust的「AI困境」。** Rust是一门「安全」的语言（内存安全、并发安全），但AI在Rust上很弱。这意味着用Rust的开发者「享受不到AI的红利」——他们需要「自己写代码」，而Python开发者可以「让AI写代码」。这会让Rust的开发效率「相对下降」，可能影响Rust的普及。

**影响三：新语言的「AI启动问题」。** 一门新语言诞生时，AI在它上面没有任何训练数据。开发者需要「自己写代码」，直到有足够多的代码被写出，AI才能「学习」。这会给新语言的推广带来「AI障碍」——开发者可能不愿意用「AI不擅长」的语言。

**金句：AI代码助手正在重塑「编程语言的市场格局」——AI擅长的语言，会获得更多开发者，形成「良性循环」。**