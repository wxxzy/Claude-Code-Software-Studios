---
name: usds-start
description: 【共享】入口引导 — 路由新项目/维护/入职路径 → 路由建议。当用户说「怎么开始/有什么能做」时使用。
context: fork
agent: delivery-manager
---

# 技能：工作室启动与引导 (/usds-start)

**执行代理**: `delivery-manager` (交付经理)

---

## 概述 (Summary)

此技能是进入通用软件开发工作室的官方入口。它通过简短的提问，自动判断用户是处于“从零到一”的阶段，还是“维护已有项目”的阶段，并推荐最合适的后续流程。

## 引导工作流 (The Onboarding Protocol)

### 1. 现状调研 (Question)
`delivery-manager` 会询问用户以下问题：
- **场景 A**: 你是否有一个全新的想法，正准备从头开始？
- **场景 B**: 你是否有一个已经存在且正在运行的项目，需要我们协助维护、修复或扩展？
- **场景 C**: 你是否只是在探索这个工作室的功能？

### 2. 方案匹配 (Options)
基于回答，你必须使用 `ask_user` 工具提供以下路径的选择：
- **新项目路径**: 推荐调用 `/studio-discovery`。
- **维护项目路径**: 推荐调用 `/studio-project-scan`。
- **团队入职路径**: 推荐调用 `/usds-onboard`。
- **纯探索路径**: 提供功能演示和 `docs/COLLABORATION-GUIDE.md`。

### 3. 决策执行 (Decision)
用户确认后，`delivery-manager` 会直接交棒给对应的代理（如 `product-director` 或 `technical-architect`）。

---

## 快捷访问 (For Advanced Users)

熟悉流程的用户可以跳过 `/usds-start`，直接使用：
- `/studio-discovery [想法]` (新需求)
- `/studio-project-scan` (分析旧代码)
- `/studio-gate-check` (最后审计)

---

## 成功门控 (Success Gate)

- 用户明确了当前的任务目标。
- 项目的 `docs/` 或 `production/` 目录下建立了对应的初始文件。
- 用户知道接下来该找哪个代理。

## 输出约束 (Output Budget)

**[强制]** 完成引导后，返回主上下文只输出：

```
启动引导完成。

- 当前路径：[新项目 / 维护项目 / 团队入职]
- 下一步：[推荐的技能指令，一行]
```

不得重复展示五步协作法或代理职责说明。
