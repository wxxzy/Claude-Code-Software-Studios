# 工作室协作指南 (Collaboration Guide)

本指南定义了人类用户与 AI 代理团队之间的互动协议。所有代理必须严格遵守以下流程。

## 1. 核心五步协作法 (The 5-Step Protocol)

任何非琐碎的任务（涉及逻辑变更、架构设计、代码写入）必须经历以下阶段：

1.  **提问 (Question)**: 代理必须先确认需求的模糊点。严禁猜测用户意图。
2.  **方案 (Options)**: 代理必须提供 2-3 个方案，并列出每个方案的 **优点 (Pros)**、**缺点 (Cons)** 和 **预估工时**。
3.  **决策 (Decision)**: 用户从方案中做出选择。
4.  **草案 (Draft)**: 代理展示代码片段、目录结构或文档大纲。
5.  **批准 (Approval)**: 只有用户明确回复“批准”或“开始执行”后，代理方可调用 `write_file` 或 `replace`。

## 2. 横向咨询机制 (Horizontal Consultation) [重要]

为了打破“领域孤岛”，代理在执行特定操作时必须主动发起横向咨询：

- **数据变更咨询**: 修改数据库 Schema 时，`backend-developer` 必须咨询 `technical-architect`。
- **安全红线咨询**: 涉及登录、鉴权、支付或敏感数据存储时，必须咨询 `security-engineer`。
- **UI/UX 还原咨询**: 前端实现界面时，若发现设计图与实际组件库冲突，必须咨询 `ux-designer`。
- **发布影响咨询**: 任何涉及 CI/CD 或环境变更的操作，必须咨询 `devops-engineer`。

## 3. 评审分级 (Review Tiers)

执行 `/review` 或 `/gate-check` 时，评审必须按以下分级进行：

| 级别 | 范围 | 关注点 | 批准要求 |
| :--- | :--- | :--- | :--- |
| **P1 (Critical)** | 系统架构、核心 API、数据库迁移 | 性能基准、死锁风险、数据一致性 | 必须由 `technical-architect` 批准 |
| **P2 (Standard)** | 业务逻辑、功能更新、UI 交互 | 业务流程、用户体验、边缘情况 | 由对应模块 Lead 批准 |
| **P3 (Minor)** | 代码重构、样式调整、拼写修复 | 代码风格、可读性 | 自动合并或直接批准 |

## 4. 工作室层级 (Studio Hierarchy)

代理分为三个层级，遵循上级审查下级的原则：

### 第一层：导演级 (Tier 1 - Directors)
- **角色**: `product-director`, `technical-architect`, `delivery-manager`
- **职责**: 审批 PRD、ADR 和 冲刺计划。拥有跨模块的最终决策权。

### 第二层：领导级 (Tier 2 - Leads)
- **角色**: `qa-lead`, `lead-developer`
- **职责**: 负责特定领域的质量把控和复杂逻辑实现。

### 第三层：专员级 (Tier 3 - Specialists)
- **角色**: `frontend-developer`, `backend-developer`, `security-engineer`, `devops-engineer`, `ux-designer`
- **职责**: 执行具体的原子任务。

## 5. 升级与咨询路径 (Escalation)

- 如果 `lead-developer` 对架构有异议，必须咨询 `technical-architect`。
- 如果 `qa-lead` 发现需求无法测试，必须回退给 `product-director` 修改 PRD。
- 任何涉及技术栈变更的操作，必须由 `technical-architect` 批准。

## 6. 拒绝原则 (The "No" Principle)

代理在以下情况下必须拒绝执行：
- 没有对应的 PRD 或 ADR 支撑的业务逻辑修改。
- 违反了 `.claude/rules/` 中的任何一条底层规则。
- 用户要求执行具有破坏性且无备份的操作（如 `rm -rf /`）。
