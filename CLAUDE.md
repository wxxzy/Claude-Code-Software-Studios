# Universal Software Studio -- Claude Code Integration

## 🛠️ 核心技能 (Slash Commands)

这些技能定义在 `.claude/skills/` 中，可以通过斜杠命令调用：

- `/start`: **智能启动引导**。由 `delivery-manager` 主导。
- `/onboard`: **团队入职引导**。向新团队成员介绍 USDS 协作流程。
- `/discovery`: **需求发现**。将模糊想法转化为 `docs/specs/PRD.md`。
- `/project-scan`: **项目扫描与映射**。分析已有项目的架构并识别技术债。
- `/setup-stack`: **技术选型与初始化**。由 `technical-architect` 引导并生成项目骨架。
- `/arch-design`: **架构设计/影响分析**。生成 `docs/arch/ADR.md`。
- `/summarize-arch`: **架构快照与总结**。压缩 ADR 到 `docs/arch/ARCHITECTURE-STATE.md`。
- `/sprint-kickoff`: **任务拆解**。由 `delivery-manager` 生成 `production/backlog.md`。
- `/review`: **技术评审**。在发布前由架构师进行正式的代码审查。
- `/gate-check`: **质量审计**。由 `qa-lead` 进行最后的发布验证。

## 👥 代理架构 (Agent Roster)

- **Product Director**: 负责 `docs/specs/`。
- **Technical Architect**: 负责 `docs/arch/`。
- **Lead Developer**: 负责 `src/`, `tests/`。
- **Delivery Manager**: 负责 `production/`。
- **QA Lead**: 负责 `docs/reviews/`。

## 📜 协作协议 (Protocols)

1. **Doc-First**: 所有功能变更必须先在 `docs/` 下有对应的设计文档。
2. **Path Rules**:
   - `src/**`: 遵循 `.claude/universal/rules/global-standards.md`。
   - `tests/**`: 遵循 `.claude/universal/rules/test-conventions.md`。
3. **Verify-First**: 只有通过 `/gate-check` 的代码才被视为可交付。

## 🛠️ 技术栈 (Technology Stack)

- **Backend**: Python (FastAPI) / Node.js
- **Frontend**: Next.js / React
- **Docs**: Markdown-driven, ADR-based
