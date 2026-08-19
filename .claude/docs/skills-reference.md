# 技能参考手册 (Skills Reference)

USDS v2.1 的 22 个斜杠命令，按命名空间分三组（见 `docs/arch/ADR-002`）：
`usds-*` 跨模式共享运维 · `vibe-*` Vibe Mode 工作流 · `studio-*` Studio Mode 工作流。

## 1. 共享运维 (`usds-*`, 7 个)

| 命令 | 主导代理 | 产出 |
|---|---|---|
| `/usds-start` | `delivery-manager` | 入口路由建议（新项目/维护/入职） |
| `/usds-onboard` | `delivery-manager` | 五步协作法协议演练摘要 |
| `/usds-mode-switch` | `delivery-manager` | `.usds-mode` 模式声明 |
| `/usds-update` | `delivery-manager` | 同步框架至 GitHub 最新版 |
| `/usds-cost-report` | `cost-accountant` | `docs/cost-ledger.md` |
| `/usds-debt-log` | `debt-auditor` | `docs/debt-ledger.md`（add/list/resolve/report） |
| `/usds-micro-adr` | `technical-architect` | `docs/arch/micro-adr.md`（一行一决策） |

## 2. Vibe Mode 工作流 (`vibe-*`, 7 个)

| 命令 | 主导代理 | 产出 |
|---|---|---|
| `/vibe-start` | `prompt-refiner` | `docs/specs/lite-spec.md` |
| `/vibe-prototype` | `explorer` | `sandbox/<name>/` 可跑 demo |
| `/vibe-check` | `explainer` | `docs/specs/intent-log.md` |
| `/vibe-taste-review` | `stylist` | `docs/reviews/taste-<date>.md` |
| `/vibe-branch` | `explorer` | `.worktrees/<name>/` 平行分叉 |
| `/vibe-explain-back` | `explainer` | 一次性非技术状态汇报 |
| `/vibe-graduate` | `delivery-manager` | 原型迁入 `src/` + 补齐工程标准 |

**链路**: `/vibe-start` → `/vibe-prototype` →（每 3-5 轮 `/vibe-check`）→ `/vibe-taste-review` → 稳定后 `/vibe-graduate`

## 3. Studio Mode 工作流 (`studio-*`, 8 个)

| 命令 | 主导代理 | 产出 |
|---|---|---|
| `/studio-discovery` | `product-director` | `docs/specs/PRD.md` |
| `/studio-project-scan` | `technical-architect` | `docs/arch/SYSTEM-MAP.md` + `TECH-DEBT.md` |
| `/studio-setup-stack` | `technical-architect` | 项目骨架 + `TECHNICAL-PREFERENCES.md` |
| `/studio-arch-design` | `technical-architect` | `docs/arch/ADR-<n>.md` |
| `/studio-summarize-arch` | `technical-architect` | `ARCHITECTURE-STATE.md` |
| `/studio-sprint-kickoff` | `delivery-manager` | `production/backlog.md` |
| `/studio-review` | `technical-architect` | 代码审计报告 |
| `/studio-gate-check` | `qa-lead` | 发布 Checklist（`--detail` 展开明细） |

**链路（新项目）**: `/studio-discovery` → `/studio-setup-stack` → `/studio-arch-design` → `/studio-sprint-kickoff` → 编码 → `/studio-review` → `/studio-gate-check`
**链路（维护项目）**: `/studio-project-scan` → 按需修复 → `/studio-review` → `/studio-gate-check`

## 命名约定

命令名即排序键兼命名空间：斜杠菜单中三组技能按字母序天然聚类，`usds-` 前缀防止与其他框架的通用名（start/review/update）碰撞。技能描述格式统一为 `【模式】动作 → 产出。当用户说"<触发词>"时使用。`，触发词同时供模型在用户自然语言表达意图时自选技能。
