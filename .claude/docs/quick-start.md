# 快速入门指南 (Quick Start)

欢迎使用 Universal Software Studio (USDS)。本指南将引导您在 5 分钟内完成从构思到任务拆解的全过程。

## 1. 启动工作室
在项目根目录运行 `claude` 开启会话：
```bash
/start
```
交付经理 (`delivery-manager`) 会介入并询问您的项目现状。

## 2. 定义需求 (Discovery)
输入您的产品构想：
```bash
/discovery "构建一个支持多租户的 SaaS 计费系统"
```
产品总监 (`product-director`) 会引导您通过“五步协作法”产出 `docs/specs/PRD-billing-system.md`。

## 3. 架构选型 (Setup Stack)
需求批准后，启动选型：
```bash
/setup-stack
```
架构师 (`technical-architect`) 会提供 2-3 套方案（如 Python/FastAPI vs. Node.js/NestJS），并在您确认后生成项目骨架。

## 4. 任务拆解 (Sprint Kickoff)
最后，将架构转化为可执行的任务：
```bash
/sprint-kickoff
```
交付经理将生成 `production/backlog.md`。现在，您可以指派 `lead-developer` 开始编码了。

## 5. 核心原则提醒
- **先问后写**: 代理在修改文件前必须先展示草案。
- **文档先行**: 所有的代码修改必须有对应的 ADR 或 PRD 支撑。
