# 技能：架构设计与选型 (/arch-design)

**执行代理**: `technical-architect` (技术架构师)

---

## 概述 (Summary)

此技能用于在 PRD 批准后，由架构师引导用户进行深度的架构设计、API 定义或数据库建模。

## 协作工作流 (The 5-Step Protocol)

1.  **需求分析**: 架构师阅读 PRD，识别核心技术挑战。
2.  **提问 (Question)**: 针对性能、并发或安全性，确认用户的特定约束。
3.  **方案 (Options)**: 
    - 架构师提供 **2-3 个对比方案**。
    - **[强制]**：必须使用 `ask_user` 工具提供这些方案的选择按钮。
4.  **决策 (Decision)**: 用户通过交互式组件做出选择。
5.  **详细设计 (Draft)**:
    - 架构师根据选择编写 ADR (Architecture Decision Record) 草案。
    - **[强制]**：必须使用 `ask_user` 工具提供 [批准设计]、[需要微调]、[放弃方案] 选项。
6.  **执行与归档**: 获得点击批准后，将 ADR 写入 `docs/arch/`。

---

## 成功门控 (Success Gate)

- 生成了 `docs/arch/ADR-xxx.md`。
- 包含了核心 API 契约或数据库结构描述。
- 用户通过 `ask_user` 明确表示了批准。
