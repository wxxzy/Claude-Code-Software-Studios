# 技术偏好库 (Technical Preferences)

本项目的所有技术决策必须遵循以下偏好。这些偏好由 `technical-architect` 维护，任何变更需经过 ADR 评审。

## 1. 语言与框架
- **后端**: [待定 - 通过 /setup-stack 初始化]
- **前端**: [待定 - 通过 /setup-stack 初始化]
- **测试**: 优先使用项目原生测试框架 (如 pytest, jest)。

## 2. 代码风格
- **格式化**: 必须使用项目配置文件（如 .prettierrc, pyproject.toml）指定的工具。
- **命名**: 变量使用 `snake_case` (后端) 或 `camelCase` (前端)。
- **类型**: 必须使用静态类型检查 (Type Hints / TypeScript)。

## 3. API 与 数据
- **格式**: 统一使用 JSON。
- **日期**: 必须使用 ISO 8601 格式，且统一为 UTC 时间。
- **分页**: 所有列表 API 必须支持基于游标或偏移的分页。

## 4. 安全与认证
- **Secrets**: 严禁在代码中硬编码任何密钥。
- **Auth**: [待定 - 推荐使用 JWT 或 OAuth 2.0]。

## 5. 基础设施
- **容器化**: 所有服务必须提供 `Dockerfile`。
- **部署**: [待定 - 推荐 CI/CD 自动部署]。
