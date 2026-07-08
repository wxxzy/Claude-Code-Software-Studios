# 实现级代理协作协议 (Implementation Agent Protocol)

适用于 `explorer`（Vibe Mode）、`lead-developer`、`frontend-developer`、`backend-developer`（Studio Mode）。

## 0. 前置：模式检测 (Mode Detection)

实现开始前，读取 `.usds-mode` 文件确认当前模式，按对应路径执行：

| 模式 | 实现路径 | 主导代理 |
|---|---|---|
| `vibe` | `sandbox/<name>/` | `explorer` |
| `studio` | `src/**` | `lead-developer` 等 |
| `hybrid` | 按文件路径分派 | 两者均适用 |

## 1. 无论何种模式的强制规约 (Universal Hard Limits)

以下规则在 **任何模式** 下均不可豁免：

- 遵守 `.claude/rules/ai-generated-code.md` 全部要求（反幻觉、版本锁定、安全强化）
- 严禁提交密钥、密码、Token
- 严禁直接拼接 SQL 字符串
- 严禁未验证的外部输入直达数据库或文件系统

## 2. Vibe Mode 实现路径

适用于 `sandbox/**` 目录，由 `explorer` 主导。

- **目标**: 15 分钟内出可运行的 demo，"能跑" > "优雅"
- **参考规范**: `.claude/rules/vibe-mode.md`（以该文件为准）
- **不要求**: ADR、单元测试、JSDoc、关注点分离
- **可用替代**: `docs/specs/lite-spec.md` 替代 ADR
- **实现完成后**: 每 3-5 轮触发 `/vibe-check`；晋升到 `src/` 需走 `/graduate`

## 3. Studio Mode 实现路径

适用于 `src/**` 目录，由 `lead-developer` / `frontend-developer` / `backend-developer` 主导。

### 3.1 设计规范：关注点分离
- **解耦**: 严禁将业务逻辑直接编写在 API 路由或 UI 组件内，必须提取到独立的 Service 或 Repository 层。
- **可测试性**: 每一个函数必须具备独立的可测试性。难以测试说明需要重构。

### 3.2 协作协议：先草案后执行
在执行写文件操作之前，必须在会话中展示：
- **核心逻辑草图**: 说明将如何处理主要逻辑流。
- **影响范围**: 说明将修改哪些已有文件。
- **关联文档**: 引用本次开发所依据的 ADR 编号。

### 3.3 强制动作：测试先行
在提交代码修改前，必须先编写或更新对应的单元测试，并展示测试通过的日志。严禁交付未经本地验证的代码。
