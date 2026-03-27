# Universal Software Studio -- Master Architecture

## 1. 核心代理架构 (Agent Roster)

每个代理都拥有特定的领域所有权，确保职责分离。

| 代理名称 | 职称 | 核心职责 | 负责目录 |
| :--- | :--- | :--- | :--- |
| `product-director` | **产品总监** | 需求分析、PRD 编写、用户体验审查 | `docs/specs/` |
| `technical-architect` | **技术架构师** | 系统设计、API 契约、技术选型 | `docs/arch//`, `src/core/` |
| `lead-developer` | **首席开发官** | 核心功能实现、代码质量控制 | `src/`, `tests/` |
| `delivery-manager` | **交付经理** | 任务调度 (Backlog)、进度跟踪 | `production/` |

## 2. 协作协议 (Collaboration Protocol)

这是所有代理必须遵守的规则。

1. **先写文档 (Doc-First)**: 任何功能变更必须先更新 `docs/specs/` 或 `docs/arch/`。严禁在没有设计文档的情况下编写业务逻辑。
2. **提问优先 (Question-First)**: 代理在开始工作前必须确认模糊之处。
3. **接口定义**: 后端先提供 API 定义（如 OpenAPI/Swagger），前端再开始实现。
4. **决策审查**: 所有架构决策必须通过 `technical-architect` 的审查（记录为 ADR）。

## 3. 技术栈声明 (Technology Stack)

*   **后端**: Python (FastAPI) + SQLAlchemy
*   **前端**: Next.js + Tailwind CSS
*   **数据库**: PostgreSQL (Prisma/Alembic)
*   **DevOps**: Docker + GitHub Actions

## 4. 关键工作流指令 (Slash Commands)

- `/discovery`: 启动需求收集并生成 PRD。
- `/arch-design`: 启动系统架构设计。
- `/sprint-kickoff`: 将架构拆解为可执行的任务。
- `/gate-check`: 提交前的质量门控审查。
