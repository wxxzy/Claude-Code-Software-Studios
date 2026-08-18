# Universal Software Studio -- Master Architecture

> 完整的代理/技能/规则清单以 `.claude/agents/`、`.claude/skills/`、`.claude/rules/` 目录与 `docs/arch/SYSTEM-MAP.md` 为唯一事实源，本文件是概览。

## 1. 核心代理架构 (Agent Roster)

每个代理都拥有特定的领域所有权，确保职责分离。共 **15 个**，按安装 profile 分组（见 `scripts/install-usds.*`）：

| 分组 | 代理 | 核心职责 | 负责目录 |
| :--- | :--- | :--- | :--- |
| Core | `delivery-manager` | **交付经理** — 任务调度 (Backlog)、进度跟踪 | `production/` |
| Core | `cost-accountant` | 成本观测 — token/时间/API 成本 | `docs/cost-ledger.md` |
| Core | `debt-auditor` | 技术债观测 — 让妥协可见 | `docs/debt-ledger.md` |
| Vibe | `explorer` / `stylist` / `prompt-refiner` / `explainer` | 快速原型、审美、意图精炼、非技术汇报 | `sandbox/**` |
| Studio | `product-director` | **产品总监** — 需求分析、PRD | `docs/specs/` |
| Studio | `technical-architect` | **技术架构师** — 系统设计、API 契约、ADR | `docs/arch/`, `src/core/` |
| Studio | `lead-developer` | **首席开发官** — 核心实现、代码质量 | `src/`, `tests/` |
| Studio | `qa-lead` / `frontend-developer` / `backend-developer` / `security-engineer` / `devops-engineer` | 质量审查与纵深领域 | `docs/reviews/` 等 |

## 2. 协作协议 (Collaboration Protocol)

这是所有代理必须遵守的规则。

1. **先写文档 (Doc-First)**: 任何功能变更必须先更新 `docs/specs/` 或 `docs/arch/`。PRD*/ADR* 的强制章节由 `validate-commit.sh` 在提交时**阻断式**校验（见 `docs/arch/ADR-001`）。
2. **提问优先 (Question-First)**: 代理在开始工作前必须确认模糊之处。
3. **五步协作法**: 提问 → 方案 → 决策 → 草案 → 批准。
4. **接口定义**: 后端先提供 API 定义（如 OpenAPI/Swagger），前端再开始实现。
5. **决策审查**: 所有架构决策必须通过 `technical-architect` 的审查（记录为 ADR）。

## 3. 双模态架构 (Dual Mode)

同一框架服务两类场景，由 `.usds-mode` 声明，`/mode-switch` 切换：

- **Vibe Mode** (`sandbox/**`): Demo-First，15 分钟出可跑 demo，宽松规则 + 不可豁免的安全 Hard Limits
- **Studio Mode** (`src/`, `docs/`, `tests/`): Doc-First + Verify-First（`/gate-check` 通过才算交付）
- **单向晋升**: Vibe 原型经 `/graduate` 补齐 ADR/测试/规范后迁入 `src/`；`src/**` 禁止依赖 `sandbox/**`

## 4. 技术栈默认倾向 (Technology Stack)

*   **后端**: Python (FastAPI) / Node.js · **前端**: Next.js / React
*   **数据库**: PostgreSQL (Prisma/Alembic) · **DevOps**: Docker + GitHub Actions
*   **框架自身**: Bash hooks（jq→python→正则 分层 JSON 解析）+ bats 回归测试 + GitHub Actions CI

## 5. 关键工作流指令 (Slash Commands)

- `/discovery`: 启动需求收集并生成 PRD。
- `/arch-design`: 启动系统架构设计。
- `/sprint-kickoff`: 将架构拆解为可执行的任务。
- `/review` / `/gate-check`: 技术评审与发布质量门控。
- `/vibe-start` / `/prototype` / `/vibe-check` / `/graduate`: Vibe 全链路。

完整 22 个技能见 `README.md` 技能全表。
