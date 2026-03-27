# 钩子输入架构 (Hook Input Schemas)

本指南定义了 Universal Software Studio (USDS) 的自动化钩子 (Hooks) 在运行过程中预期的 JSON 输入格式。这些信息对于修改或自定义钩子逻辑至关重要。

## 1. SessionStart (会话启动)
**触发条件**: 每次启动 `claude` 终端会话时。
**输入 Schema**: 无特定 stdin 输入，脚本通常直接读取环境。

## 2. PreToolUse (工具调用前)
**触发条件**: 任何代理在执行 `Write`, `Edit` 或 `Bash` 操作前。
**输入 Schema**:
```json
{
  "toolName": "string",  // 被调用的工具名称
  "arguments": "object", // 该工具接收的所有参数
  "agentId": "string"   // 发起调用的代理 ID
}
```

## 3. PreCompact (上下文压缩前)
**触发条件**: 当会话 Token 达到阈值，Claude 准备进行快照压缩时。
**输入 Schema**:
```json
{
  "summary": "string",   // 系统生成的当前会话摘要草稿
  "recentEvents": "array" // 最近的工具调用历史
}
```

## 4. PostToolUse (工具调用后)
**触发条件**: 文件写入或修改成功后。
**输入 Schema**:
```json
{
  "filePath": "string",  // 被修改的文件路径
  "status": "success|error"
}
```
