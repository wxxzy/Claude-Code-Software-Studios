---
name: sprint-kickoff
description: 冲刺任务拆解。当架构确定后需要把设计拆解为可执行任务并生成 production/backlog.md 时使用。
context: fork
agent: delivery-manager
---

# 技能：冲刺启动 (/sprint-kickoff)

**执行代理**: `delivery-manager`

---

## 概述 (Summary)

此技能用于在架构设计完成后，将 PRD 和 ADR 拆解为细粒度的开发任务。输出结果将存储在 `production/backlog.md` 中。

## 工作流 (Workflow)

1.  **启动**: 用户输入 `/sprint-kickoff [架构文档路径]`。
2.  **任务拆解**: `delivery-manager` 阅读需求和架构文档。
3.  **制定计划**:
    - 基于 `.claude/universal/docs/templates/BACKLOG.md` 创建 Backlog。
    - 将架构分解为前端、后端、数据库和部署任务。
    - 为每个任务分配优先级和预估工时。
4.  **评审**: 向用户展示计划并确认首批开发任务。

## 成功门控 (Success Gate)

- [ ] 生成了 `production/backlog.md`。
- [ ] 列出了至少 5 个具体且可执行的原子任务。
- [ ] 设定了任务的依赖顺序和优先级。

## 输出约束 (Output Budget)

**[强制]** 返回主上下文时，只输出以下格式的单行摘要，不得重复 backlog 内容：

```
`production/backlog.md` has been generated. Here's a summary of what was produced:

**冲刺启动完成 — Sprint Kickoff Done**

- 活跃冲刺：[X] 个任务（[代理] 负责）
- 待办池：[Y] 个任务
- 依赖链：[关键路径一句话说明]

首批可执行任务：[任务ID 列表，不超过 3 个]
```

完整任务列表已写入 `production/backlog.md`，不得在摘要中展开每条任务详情。

---

## 协作路径 (Escalation)

- 必须参考 `product-director` 的 PRD 和 `technical-architect` 的 ADR。
- 生成的任务清单将指导 `lead-developer` 的日常编码工作。
