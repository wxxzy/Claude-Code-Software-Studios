# 推送前测试门控 (Pre-Push Test Gate)

本指南说明了 `validate-push.sh` 在执行 Git 推送 (Push) 前所进行的强制测试门控。

## 1. 强制门槛 (Quality Gates)
- **Unit Test Pass Rate**: 必须达到 100%。任何失败的单元测试都会直接中断推送。
- **Core Path Coverage**: `src/core/` 目录下的代码逻辑必须包含覆盖。
- **Regression Pass**: 关键路径（如登录、API 核心逻辑）必须通过自动化冒烟测试。

## 2. 检查流程
1.  **运行环境检测**: 脚本会自动执行 `pytest` (Python) 或 `npm test` (JavaScript)。
2.  **Linting**: 执行静态分析检查（如 `flake8`, `eslint`）。
3.  **漏洞扫描 (SCA)**: 检查外部依赖项是否有已知的 CVE 漏洞。

## 3. 分支策略
- **main/master**: 推送到生产分支时，测试门槛将自动提升至 P1 级别（必须进行回归验证）。
- **feature/***: 开发分支允许较低的性能指标，但单元测试必须通过。

## 4. 失败处理
如果推送失败，`qa-lead` 将在会话中主动提示失败的具体测试用例。请修复后再重试。
