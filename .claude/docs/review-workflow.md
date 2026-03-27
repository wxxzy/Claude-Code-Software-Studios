# 技术评审工作流 (Review Workflow)

本指南定义了在开发完成与交付之间进行的 **迭代评审机制**。

## 1. 启动评审 (/review)
当 `lead-developer` 完成任务后，应主动调用 `/review` 启动该工作流。

## 2. 评审分级与关注点

### P1 (Critical) - 架构与核心逻辑
- **对象**: `src/api/`, `src/core/`, `src/db/`。
- **由谁评审**: `technical-architect` + `security-engineer`。
- **关注点**: 鉴权漏洞、并发死锁、SQL 注入、N+1 查询、数据一致性。
- **批准要求**: 架构师签字 (Sign-off)。

### P2 (Standard) - 业务逻辑与 UI
- **对象**: `src/web/`, `src/ui/`, 业务实现层。
- **由谁评审**: `product-director` + `ux-designer`。
- **关注点**: 业务逻辑还原度、UX 交互流畅性、错误状态提示。

### P3 (Minor) - 风格与规范
- **对象**: 注释、格式化、拼写。
- **由谁评审**: `lead-developer`。
- **关注点**: 代码可读性、变量命名、文档注释是否同步。

## 3. 迭代流程
1.  **提交评审**: 开发者展示修改清单。
2.  **发现发现**: 评审者提供 2-3 个改进建议 (Options)。
3.  **修复确认**: 开发者执行修改草案 (Draft)。
4.  **批准归档**: 通过后，由 `qa-lead` 进行 `/gate-check`。
