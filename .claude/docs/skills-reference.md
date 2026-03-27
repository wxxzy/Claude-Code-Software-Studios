# 技能参考手册 (Skills Reference)

本手册详细介绍了 Universal Software Studio (USDS) 提供的 10 个核心斜杠命令 (Slash Commands) 及其执行流程。

## 1. 启动与入职 (Onboarding)
- **`/start`**: 智能项目路由。由 `delivery-manager` 主导，区分新项目或维护项目。
- **`/onboard`**: 团队成员引导。介绍五步协作法和工作室规范。

## 2. 需求与定义 (Discovery)
- **`/discovery`**: 需求收集。产出 `docs/specs/PRD-xxx.md`。
- **`/project-scan`**: 项目映射。分析已有项目的架构与技术债。
- **`/reverse-document`**: 逆向文档。为核心代码反推逻辑描述。

## 3. 设计与选型 (Architecture)
- **`/setup-stack`**: 技术底座初始化。由架构师引导选型并生成骨架。
- **`/arch-design`**: 架构设计/影响分析。产出 `docs/arch/ADR-xxx.md`。
- **`/summarize-arch`**: 架构状态快照。更新 `docs/arch/ARCHITECTURE-STATE.md`。

## 4. 交付与审计 (Delivery)
- **`/sprint-kickoff`**: 任务拆解。生成 `production/backlog.md`。
- **`/review`**: 技术评审。由架构师进行正式的代码审计。
- **`/gate-check`**: 质量门控。生成最后发布清单。
