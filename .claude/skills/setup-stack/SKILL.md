# 技能：技术栈初始化 (/setup-stack)

**执行代理**: `technical-architect` (技术架构师)

---

## 概述 (Summary)

此技能用于在 PRD 明确后，由架构师引导用户进行技术选型，并自动生成项目的初始目录结构、依赖文件和核心配置。

## 协作工作流 (The 5-Step Protocol)

1.  **提问 (Question)**:
    - 目标平台是什么？(Web, Mobile, CLI, API-only)
    - 有无特定的编程语言偏好？(Python, Go, Node.js, Rust 等)
    - 预计的数据存储需求？(Relational, NoSQL, In-memory)
2.  **方案 (Options)**:
    - 架构师必须提供 **2-3 个技术栈方案**（例如：FastAPI/PostgreSQL vs. NestJS/MongoDB）。
    - 针对每个方案对比：开发速度、性能指标、可维护性。
3.  **决策 (Decision)**: 用户选择其中一个方案。
4.  **草案 (Draft)**:
    - 展示生成的目录结构预览。
    - 展示 `package.json` / `requirements.txt` / `Dockerfile` 的草案。
5.  **批准 (Approval)**:
    - 获得用户“批准”后，架构师执行 `write_file` 创建项目骨架。

---

## 成功门控 (Success Gate)

- 更新了 `docs/arch/TECHNICAL-PREFERENCES.md`。
- 创建了基础的项目结构 (如 `src/`, `tests/`, `config/`)。
- 生成了可用的依赖清单文件。

---

## 协作路径 (Escalation)

- 必须基于 `docs/specs/PRD-*.md` 进行选型建议。
- 完成后，将接力棒交给 `delivery-manager` 进行 `/sprint-kickoff`。
