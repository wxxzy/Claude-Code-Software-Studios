# 提交前代码质量检查 (Pre-Commit Code Quality)

本指南说明了 `validate-commit.sh` 在执行提交前所进行的自动化校验逻辑。

## 1. 强制合规项 (Mandatory Checks)
- **Hardcoded Secrets**: 扫描是否包含 API Key, Password, Secret 等敏感信息。
- **Magic Numbers**: 检查代码中是否存在未定义的硬编码数值（由 `global-standards.md` 禁止）。
- **TODO/FIXME Format**: 检查是否带有任务 ID (如 `TODO: [T-123]`)，严禁提交无责任人的任务标签。

## 2. API 与 核心逻辑校验
- **Auth Annotations**: 扫描 API 路由是否包含鉴权注解（如 `@depends(get_current_user)`）。
- **Exception Handling**: 检查核心业务函数是否包含 `try-except` 或类似的错误捕获。

## 3. 文档同步检查
- **ADR Match**: 检查提交的文件是否关联了 `docs/arch/` 下的架构决策。
- **PRD Match**: 业务逻辑变更必须对应 `docs/specs/` 下的需求更新。

## 4. 绕过说明
在特殊紧急情况下（如仅修复拼写），可以使用 `git commit -m "..." --no-verify`。但此类行为将被 `log-agent.sh` 自动记录并由 `delivery-manager` 进行事后分析。
