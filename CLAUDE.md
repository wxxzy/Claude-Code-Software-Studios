# Universal Software Studio — Claude Code Integration

**双模态**：Vibe Mode（探索/原型）与 Studio Mode（严肃/生产）共存。

## 模式声明

`.usds-mode` 文件决定当前模式，缺失时默认 `studio`。用 `/mode-switch` 初始化或切换。

| mode | 主要目录 | 主导规则 |
|---|---|---|
| `vibe` | `sandbox/**` | `.claude/rules/vibe-mode.md` |
| `studio` | `src/`, `docs/`, `tests/` | `.claude/rules/global-standards.md` |
| `hybrid` | 两者共存 | 按路径分派 |

## 协议

- **Studio Mode**: Doc-First（先文档后代码）、Verify-First（`/gate-check` 通过才算交付）
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

- 技能定义见 `.claude/skills/`（由 harness 自动加载）
- 角色定义见 `.claude/agents/`
- 文档模板见 `.claude/docs/templates/`

## 技术栈默认倾向

Backend: Python (FastAPI) / Node.js · Frontend: Next.js / React · Docs: Markdown + ADR
