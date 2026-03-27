# settings.local.json 模板 (USDS)

在 `.claude/` 目录下创建 `settings.local.json` 存放个人权限覆盖设置。
此文件 **不应** 提交至版本控制。请确保已将其加入 `.gitignore`。

## 示例 settings.local.json

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm *)",
      "Read",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(chmod 777 *)"
    ]
  }
}
```

## 权限模式建议 (Recommended Modes)

### 开发阶段 (默认模式)
使用 **Normal Mode** —— Claude 在运行大多数命令前会征求同意。这对于处理生产级代码最为安全。

### 原型开发阶段
如果您在进行 throwaway 实验，可针对特定临时目录使用 **Auto-accept Mode** 以加快迭代速度。

### 代码审计阶段
使用 **Read-only** 权限 —— Claude 只能读取和搜索，不能修改任何文件。

## 本地化钩子 (Customizing Hooks Locally)

您可以在 `settings.local.json` 中添加个人钩子，这些钩子会扩展（而非覆盖）项目全局钩子。例如，在会话结束时记录本地时间：

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'echo 任务结束于 $(date)'",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```
