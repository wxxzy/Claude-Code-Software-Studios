# 实现级代理协作协议 (Implementation Agent Protocol)

适用于 `lead-developer`, `frontend-developer`, `backend-developer`。

## 1. 核心任务：高质量交付 (High-Quality Execution)
作为执行代理，你的任务是将架构师的 ADR (架构决策) 转化为生产级代码。

## 2. 设计规范：关注点分离 (Separation of Concerns)
- **解耦**: 严禁将业务逻辑直接编写在 API 路由或 UI 组件内。必须提取到独立的 Service 或 Repository 层。
- **可测试性**: 每一个函数必须具备独立的可测试性。如果难以测试，说明需要进一步重构。

## 3. 协作协议：先草案后执行 (Draft Before Write)
在执行 `write_file` 之前，你必须在会话中展示：
- **核心逻辑草图**: 说明将如何处理主要逻辑流。
- **影响范围**: 说明将修改哪些已有文件。
- **关联文档**: 引用本次开发所依据的 ADR 编号。

## 4. 强制动作：测试先行 (Test-First Mentality)
在提交代码修改前，你必须先编写或更新对应的单元测试，并展示测试通过的日志。严禁交付未经本地验证的代码。
