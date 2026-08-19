# Universal Software Studio — Claude Code Integration

**双模态**：Vibe Mode（探索/原型）与 Studio Mode（严肃/生产）共存。

## 模式声明

`.usds-mode` 文件决定当前模式，缺失时默认 `studio`。用 `/usds-mode-switch` 初始化或切换。

| mode | 主要目录 | 主导规则 |
|---|---|---|
| `vibe` | `sandbox/**` | `.claude/rules/vibe-mode.md` |
| `studio` | `src/`, `docs/`, `tests/` | `.claude/rules/global-standards.md` |
| `hybrid` | 两者共存 | 按路径分派 |

## 协议

- **Studio Mode**: Doc-First（先文档后代码）、Verify-First（`/studio-gate-check` 通过才算交付）
- **Vibe Mode**: Demo-First（15 分钟出可跑 demo）、每 3-5 轮迭代必须 `/vibe-check` 校准意图
- **全局**: 密钥/SQL 拼接/未验证输入/未锁版本依赖 = Hard Limits（任何模式都禁止）
- **单向依赖**: `sandbox/**` 可引用 `src/**`，反之**禁止**

## Path Rules

| 路径 | 规则文件 |
|---|---|
| `src/**` | `.claude/rules/global-standards.md` + `.claude/rules/backend-api.md` |
| `tests/**` | `.claude/rules/test-conventions.md` |
| `docs/**` | `.claude/rules/doc-standards.md` |
| `sandbox/**` | `.claude/rules/vibe-mode.md` |
| 全局 (AI 生成代码) | `.claude/rules/ai-generated-code.md` |

## 技能与角色

- 技能定义见 `.claude/skills/`（由 harness 自动加载），命名空间：`usds-*` 共享运维 / `vibe-*` Vibe 工作流 / `studio-*` Studio 工作流（见 `docs/arch/ADR-002`）
- 角色定义见 `.claude/agents/`
- 文档模板见 `.claude/docs/templates/`
- 技能速查见 `.claude/docs/skills-reference.md`

### v2.1 命令重命名对照（旧名已废弃）

| 旧名 | 新名 | | 旧名 | 新名 |
|---|---|---|---|---|
| `/start` | `/usds-start` | | `/prototype` | `/vibe-prototype` |
| `/onboard` | `/usds-onboard` | | `/taste-review` | `/vibe-taste-review` |
| `/mode-switch` | `/usds-mode-switch` | | `/branch-vibe` | `/vibe-branch` |
| `/update` | `/usds-update` | | `/explain-back` | `/vibe-explain-back` |
| `/cost-report` | `/usds-cost-report` | | `/graduate` | `/vibe-graduate` |
| `/debt-log` | `/usds-debt-log` | | `/discovery` | `/studio-discovery` |
| `/micro-adr` | `/usds-micro-adr` | | `/project-scan` | `/studio-project-scan` |
| | | | `/setup-stack` | `/studio-setup-stack` |
| | | | `/arch-design` | `/studio-arch-design` |
| | | | `/summarize-arch` | `/studio-summarize-arch` |
| | | | `/sprint-kickoff` | `/studio-sprint-kickoff` |
| | | | `/review` | `/studio-review` |
| | | | `/gate-check` | `/studio-gate-check` |

（`/vibe-start`、`/vibe-check` 名称未变）

## 技术栈默认倾向

Backend: Python (FastAPI) / Node.js · Frontend: Next.js / React · Docs: Markdown + ADR
