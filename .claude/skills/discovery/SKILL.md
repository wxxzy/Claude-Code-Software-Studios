# 技能：需求发现 (/discovery)

**执行代理**: `product-director` (产品总监)

---

## 概述 (Summary)

此技能用于在项目的“迷雾”阶段进行结构化的需求收集。它将引导用户产出一份高质量的 PRD（产品需求文档），并存储在 `docs/specs/` 中。

## 工作流 (Workflow)

1.  **启动**: 用户输入 `/discovery [想法]`。
2.  **需求访谈**: `product-director` 会询问一系列问题，包括：
    - 核心业务痛点是什么？
    - 目标用户群体是谁？
    - 哪些功能是“必须拥有 (Must-Have)”的？
3.  **草案生成**: 基于回答，从 `.claude/universal/docs/templates/PRD.md` 中提取模板，生成一份 PRD 草案。
4.  **评审与批准**: 用户审查并批准 PRD。
5.  **结束**: 只有当 PRD 归档到 `docs/specs/` 后，此流程才算结束。

---

## 成功门控 (Success Gate)

- 生成了 `docs/specs/PRD-xxx.md`。
- 列出了至少 3 个核心用户故事。
- 明确定义了功能的边界 (Scope)。

---

## 协作路径 (Escalation)

- 必须基于 `UNIVERSAL-STUDIO.md` 的宪法进行。
- 如果 PRD 中涉及复杂的技术方案，必须调用 `technical-architect` 进行可行性评估。
