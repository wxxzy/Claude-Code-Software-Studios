# 技能：架构快照与总结 (/summarize-arch)

**执行代理**: `technical-architect` (技术架构师)

---

## 概述 (Summary)

此技能用于在多个 ADR 被批准后，将零散的决策压缩并合并到一份 `docs/arch/ARCHITECTURE-STATE.md` (最终态架构文档) 中，从而减少代理每次会话时的上下文读取量，并确保新架构决策不会与旧决策冲突。

## 工作流 (Workflow)

1.  **扫描 (Scan)**: 架构师扫描 `docs/arch/ADR-*.md` 目录下的所有文件。
2.  **提取方案 (Options)**:
    - 方案 A: 全量更新。将所有活跃 ADR 映射到最终态文档。
    - 方案 B: 增量更新。仅将最新通过的 ADR 同步到最终态。
3.  **草案展示 (Draft)**: 展示 `docs/arch/ARCHITECTURE-STATE.md` 的快照。
4.  **批准与更新 (Approval)**: 用户批准后，架构师重写或更新该文件，并可选地对旧 ADR 标记为 `Approved & Merged`。

---

## 成功门控 (Success Gate)

- 产出了 `docs/arch/ARCHITECTURE-STATE.md`。
- 新文档包含了所有核心决策（数据库结构、API 定义、技术栈）。
- 上下文效率明显提升。
