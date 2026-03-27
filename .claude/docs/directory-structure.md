# 项目目录结构指南 (Directory Structure)

本指南定义了 Universal Software Studio (USDS) 的标准布局及其访问权限。

## 1. 核心架构 (.claude/)
- `.claude/agents/`: **[Read-Only]** 定义了 10 位核心专家的职责与提示词。
- `.claude/skills/`: **[Read-Only]** 定义了斜杠命令 (Slash Commands) 的执行流。
- `.claude/rules/`: **[Read-Only]** 存放全局及语言专有的代码质量门控。
- `.claude/hooks/`: **[Internal]** 存放自动化验证脚本。

## 2. 工程资产 (Engineering Assets)
- `src/`: **[Read-Write]** 源代码空间。后端、前端、核心逻辑均在此。
- `tests/`: **[Read-Write]** 自动化测试套件。
- `docs/`: **[Read-Write]** 项目文档与架构决策。
- `production/`: **[Internal]** 存放会话状态、交付物看板与日志。

## 3. 文档体系 (Documentation)
- `docs/specs/`: **PRD 专用**。存放产品需求说明。
- `docs/arch/`: **架构专用**。存放 ADR 和 API 契约。
- `docs/reviews/`: **质量专用**。存放评审报告与发布清单。

## 4. 读写原则
- 代理在修改 `src/` 前，必须验证 `docs/arch/` 中有对应的设计支撑。
- 严禁代理擅自修改 `.claude/` 内部的系统配置，除非用户明确要求“重构工作室”。
