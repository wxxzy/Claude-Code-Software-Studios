# CLAUDE.local.md Template (USDS)

将此文件复制到项目根目录并重命名为 `CLAUDE.local.md`，用于存放您的个人偏好设置。
此文件已被 `.gitignore` 忽略，不会提交到版本控制系统。

```markdown
# 个人偏好设置 (Personal Preferences)

## 模型偏好 (Model Preferences)
- 复杂设计任务优先使用 Claude 3.5 Sonnet / Opus
- 快速查找和简单编辑使用 Claude 3 Haiku

## 工作流偏好 (Workflow Preferences)
- 代码变更后自动运行单元测试
- 在上下文使用率达到 60% 时主动执行 /summarize-arch
- 在不同任务之间使用 /clear 清除会话

## 本地环境 (Local Environment)
- Python 命令: python (或 py / python3)
- Shell: Windows 上的 Git Bash 或 PowerShell
- IDE: 带有 Claude Code 扩展的 VS Code

## 沟通风格 (Communication Style)
- 保持回答简洁明了
- 在所有代码引用中显示文件路径
- 简要解释架构决策

## 个人快捷指令 (Personal Shortcuts)
- 当我说 "review" 时，对最后修改的文件运行 /review
- 当我说 "status" 时，显示 git status + production/backlog.md 中的任务状态
```

## 设置步骤

1. 将此模板复制到项目根目录：`cp .claude/docs/CLAUDE-local-template.md CLAUDE.local.md`
2. 根据您的偏好进行编辑。
3. 验证 `CLAUDE.local.md` 已在 `.gitignore` 中（Claude Code 会从项目根目录读取它）。
