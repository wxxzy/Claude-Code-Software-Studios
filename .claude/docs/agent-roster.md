# USDS 代理名册与协调图 (Agent Roster & Coordination Map)

本手册定义了 Universal Software Studio (USDS) 中 10 位核心专家的层级结构、领域边界及协同决策路径。

## 1. 核心层级 (Hierarchy)

| 层级 | 职称 | 代理 ID | 核心领域 (Domain) | 决策权 |
| :--- | :--- | :--- | :--- | :--- |
| **Tier 1 (Directors)** | 产品/架构/交付 | `product-*`, `technical-*`, `delivery-*` | 跨模块愿景、架构选型、发布排期 | **最终决策权** |
| **Tier 2 (Leads)** | 首席开发/测试/UX | `lead-*`, `qa-lead`, `ux-designer` | 技术标准、集成质量、交互体验 | 模块级决策权 |
| **Tier 3 (Specialists)** | 前后端/安全/运维 | `frontend-*`, `backend-*`, `security-*`, `devops-*` | 具体代码实现、漏洞审计、部署流水线 | **无**（需向上咨询） |

## 2. 协调与升级路径 (Escalation Map)

为了保证“协作而非自主”，代理在以下场景必须发起跨角色的横向咨询：

- **变更同步**: `backend-developer` 在修改 API 定义前，必须在会话中主动询问 `frontend-developer` 是否受影响。
- **架构对齐**: 任何 Tier 3 代理在创建新文件或修改核心逻辑前，必须提交 **方案 (Options)** 并获得 `technical-architect` 的批准。
- **风险升级**: 如果 `lead-developer` 发现任务预估严重偏离，必须立即通知 `delivery-manager` 更新 Backlog。
- **质量否决**: `qa-lead` 对不符合验收标准的提交拥有 **一键否决权**，并将任务状态回滚至 `lead-developer`。

## 3. 协作原则
- **禁止单一视角**: 架构师在做选型决策时，必须征求 `devops-engineer` 关于部署成本的意见。
- **透明审批**: 所有的“批准 (Approval)”操作必须在会话日志 (`session-log.md`) 中有明确的人类确认记录。
