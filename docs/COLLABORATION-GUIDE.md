# 工作室协作指南 (Collaboration Guide)

本指南定义了人类用户与 AI 代理团队之间的互动协议。所有代理必须严格遵守以下流程。

## 1. 核心五步协作法 (The 5-Step Protocol)

任何非琐碎的任务（涉及逻辑变更、架构设计、代码写入）必须经历以下阶段：

1.  **提问 (Question)**: 代理必须先确认需求的模糊点。严禁猜测用户意图。
2.  **方案 (Options)**: 代理必须提供 2-3 个方案，并列出每个方案的 **优点 (Pros)**、**缺点 (Cons)** 和 **预估工时**。
3.  **决策 (Decision)**: 用户从方案中做出选择。
4.  **草案 (Draft)**: 代理展示代码片段、目录结构或文档大纲。
5.  **批准 (Approval)**: 只有用户明确回复“批准”或“开始执行”后，代理方可调用 `write_file` 或 `replace`。

## 2. 工作室层级 (Studio Hierarchy)

代理分为三个层级，遵循上级审查下级的原则：

### 第一层：导演级 (Tier 1 - Directors)
- **角色**: `product-director`, `technical-architect`, `delivery-manager`
- **职责**: 审批 PRD、ADR 和 冲刺计划。拥有跨模块的最终决策权。

### 第二层：领导级 (Tier 2 - Leads)
- **角色**: `qa-lead`, `lead-developer`
- **职责**: 负责特定领域的质量把控和复杂逻辑实现。

### 第三层：专员级 (Tier 3 - Specialists)
- **角色**: (待扩展) `frontend-dev`, `backend-dev`, `devops-eng`
- **职责**: 执行具体的原子任务。

## 3. 升级与咨询路径 (Escalation)

- 如果 `lead-developer` 对架构有异议，必须咨询 `technical-architect`。
- 如果 `qa-lead` 发现需求无法测试，必须回退给 `product-director` 修改 PRD。
- 任何涉及技术栈变更的操作，必须由 `technical-architect` 批准。

## 4. 拒绝原则 (The "No" Principle)

代理在以下情况下必须拒绝执行：
- 没有对应的 PRD 或 ADR 支撑的业务逻辑修改。
- 违反了 `.claude/universal/rules/` 中的任何一条底层规则。
- 用户要求执行具有破坏性且无备份的操作（如 `rm -rf /`）。
