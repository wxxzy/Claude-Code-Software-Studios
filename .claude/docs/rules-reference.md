# 规则参考手册 (Rules Reference)

本手册定义了 Universal Software Studio (USDS) 的路径规则逻辑。

## 1. 核心规则包 (Core Rules)
- **`global-standards.md`**: 适用于所有项目，定义命名与组织规范。
- **`backend-api.md`**: 适用于 `src/api/`, `src/core/`。强制执行错误处理与数据库最佳实践。
- **`test-conventions.md`**: 适用于 `tests/**`。强制执行 GWT 模式与隔离性要求。
- **`doc-standards.md`**: 适用于 `docs/**`。强制执行模板检查与状态声明。

## 2. 规则解析
- **路径敏感**: 系统自动根据文件路径激活对应的 Markdown 规则。
- **强制性**: 任何代理在执行 `Write` 操作前，必须核对路径规则。

## 3. 自定义与扩展
- 团队可以通过 `/setup-stack` 引导，在 `.claude/rules/library/` 中加载语言专有规则包（如 Python/FastAPI, JavaScript/React）。
