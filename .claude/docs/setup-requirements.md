# 环境配置指南 (Setup Requirements)

为了确保 Universal Software Studio (USDS) 的所有功能（包括 Hook 和验证脚本）能正常运行，请在您的开发机器上确认以下依赖。

## 1. 核心运行环境 (Mandatory)
- **Git**: 2.x+。所有 Hook 都依赖 Git 的生命周期触发。
- **Claude Code CLI**: `npm install -g @anthropic-ai/claude-code`。核心运行引擎。

## 2. 自动化支持工具 (Recommended)
- **jq**: 1.6+。用于 Hook 中的 JSON 解析。
- **Python 3.8+**: 部分 Hook 需要运行小型脚本来检查 PRD 格式。
- **PowerShell 7.x (Windows)**: 保证 `install-usds.ps1` 能够跨版本运行。

## 3. 会话设置 (Claude Code)
建议在项目的 `.claude/settings.json` 中配置好以下权限以提高效率：
- `Allow Bash(git status*)`
- `Allow Bash(ls *)`
- `Deny Bash(rm -rf *)` (安全保护)

## 4. 故障排查
- 如果 `session-start.sh` 无法运行，请检查文件的执行权限 (`chmod +x .claude/hooks/*.sh`)。
- 如果 `/start` 报错找不到技能，请确保 `CLAUDE.md` 位于项目根目录。
