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

---

## 协作路径 (Escalation)

- 必须参考 `product-director` 的 PRD 和 `technical-architect` 的 ADR。
- 生成的任务清单将指导 `lead-developer` 的日常编码工作。
