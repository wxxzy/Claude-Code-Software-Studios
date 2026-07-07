---
name: discovery
description: 结构化需求发现。当用户提出一个新想法、需要把模糊需求转化为 PRD（产品需求文档）并写入 docs/specs/ 时使用。
context: fork
agent: product-director
---

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
4.  **评审与批准**: 
    - 你必须使用 `ask_user` 工具，提供 [批准 PRD]、[需要修改] 和 [取消] 三个选项。
5.  **结束**: 只有当用户点击 [批准 PRD] 后，你方可将文档写入 `docs/specs/`。

---

## 成功门控 (Success Gate)

- 生成了 `docs/specs/PRD-xxx.md`。
- 列出了至少 3 个核心用户故事。
- 明确定义了功能的边界 (Scope)。

---

## 输出约束 (Output Budget)

**[强制]** 写入文件后，返回主上下文只输出：

```
需求发现完成。

- `docs/specs/PRD-[xxx].md` — [产品名称，一句话]
- 核心用户故事：[X] 条
- 关键边界：[In Scope 和 Out of Scope 各一句]

如需查看完整需求，打开上述文件。
```

不得在返回摘要中重复 PRD 正文。

## 协作路径

- PRD 批准后，交棒 `technical-architect` 执行 `/arch-design`。
