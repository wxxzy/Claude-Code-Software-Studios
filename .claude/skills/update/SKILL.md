---
name: update
description: 自动检查并同步工作室基础设施至 GitHub 最新版本。当用户要求更新 USDS、检查新版本或同步 .claude 配置时使用。
context: fork
agent: delivery-manager
---

# 技能：工作室自动更新 (/update)

**执行代理**: `delivery-manager` (交付经理)

---

## 概述 (Summary)

此技能用于将当前项目的 USDS 基础设施（代理、技能、规则）更新至 GitHub 仓库的最新版本。它会自动备份当前配置并拉取新代码。

## 更新工作流

1.  **版本检查**: `delivery-manager` 展示本地版本与远程最新版本的差异。
2.  **变更摘要**: 列出新版本中的主要改进点。
3.  **用户确认**: 提示用户确认是否覆盖 `.claude/` 下的核心组件（`CLAUDE.local.md` 等本地文件不会被覆盖）。
4.  **执行更新**:
    - 在 Windows 上，它会提示用户运行：
      `irm https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/scripts/install-usds.ps1 | iex`
    - 在 macOS/Linux 上，它会提示用户运行：
      `curl -fsSL https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/scripts/install-usds.sh | bash`
5.  **完成**: 提示用户重启会话以加载新技能。

---

## 成功门控 (Success Gate)

- `.claude/VERSION` 文件已更新至最新版本号。
- 新的技能指令出现在 `/` 列表中。
