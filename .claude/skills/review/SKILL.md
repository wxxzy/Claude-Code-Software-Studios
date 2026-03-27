# 技能：技术评审 (/review)

**执行代理**: `technical-architect` (技术架构师)

---

## 概述 (Summary)

此技能用于在 `lead-developer` 完成代码编写后，正式进入 QA 审计前，由架构师从技术深度、性能、可维护性和安全性角度进行全方位的代码审查 (Code Review)。

## 协作工作流 (The 5-Step Protocol)

1.  **提问 (Question)**:
    - 询问开发者：这段代码核心解决了什么问题？是否有潜在的“脏路 (Dirty paths)”未处理？
2.  **发现与评估 (Options)**:
    - 架构师列出 **2-3 个关键发现**（如：性能瓶颈、代码异味、违反 ADR）。
    - 针对每个发现提供改进建议。
3.  **决策 (Decision)**: 用户选择哪些改进点必须在本次任务中修复。
4.  **改进草案 (Draft)**: 架构师展示重构后的代码片段或配置调整。
5.  **批准 (Approval)**: 用户批准后，由架构师协同开发者执行 `replace`。

---

## 成功门控 (Success Gate)

- 代码符合 `TECHNICAL-PREFERENCES.md`。
- 逻辑已按 ADR 契约实现，且没有明显的 N+1 或内存泄漏。
- 生成了简短的评审摘要记录在 `docs/reviews/`。

---

## 协作路径 (Escalation)

- 若评审不通过，任务状态回退为 `In Progress`。
- 评审通过后，交由 `qa-lead` 进行 `/gate-check`。
