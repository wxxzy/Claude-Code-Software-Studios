# Universal Software Studio — Agent Instructions

> 本文件是 [AGENTS.md](https://agents.md) 开放规范的实现——OpenAI/Google/Anthropic/Cursor/Sourcegraph 等共同推动的跨工具 AI 编码代理约定，Codex、Cursor、Gemini CLI 等工具会自动读取此文件。
> 内容与 `CLAUDE.md`（Claude Code 专用，支持 skills/agents/hooks 加载）保持同步；**改动任一方，必须同步另一方**（consistency.bats 会校验版本号一致性，但不校验两文件正文逐字相同，靠人工纪律）。

**双模态**：Vibe Mode（探索/原型）与 Studio Mode（严肃/生产）共存。

## 模式声明

`.usds-mode` 文件决定当前模式，缺失时默认 `studio`。

| mode | 主要目录 | 主导规则 |
|---|---|---|
| `vibe` | `sandbox/**` | `.claude/rules/vibe-mode.md` |
| `studio` | `src/`, `docs/`, `tests/` | `.claude/rules/global-standards.md` |
| `hybrid` | 两者共存 | 按路径分派 |

## 协议

- **Studio Mode**: Doc-First（先文档后代码）、Verify-First（质量门通过才算交付）
- **Vibe Mode**: Demo-First（15 分钟出可跑 demo）、每 3-5 轮迭代必须校准意图、**每个能跑的检查点立即 commit**（详见 `.claude/rules/vibe-mode.md` §7）
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

## 参考文档

- 角色定义：`.claude/agents/`（本文件所述规则同样适用于任何以这些角色身份工作的代理）
- 文档模板：`.claude/docs/templates/`
- 协作协议（五步协作法）：`.claude/docs/coordination-rules.md`
- 目录结构：`.claude/docs/directory-structure.md`

> Claude Code 用户额外拥有 `.claude/skills/` 下的 22 个可自动加载技能（斜杠命令）与 hooks 自动化，见 `CLAUDE.md` + `.claude/docs/skills-reference.md`。非 Claude Code 工具没有技能自动加载机制，请直接依据本文件与 Path Rules 手动执行对应工作流。

## 技术栈默认倾向

Backend: Python (FastAPI) / Node.js · Frontend: Next.js / React · Docs: Markdown + ADR
