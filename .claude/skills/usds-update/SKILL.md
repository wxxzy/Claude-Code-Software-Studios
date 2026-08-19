---
name: usds-update
description: 【共享】框架更新 — 检查并同步 .claude 配置至 GitHub 最新版本 → 更新后的框架文件。当用户说「更新 USDS/检查新版本」时使用。
context: fork
agent: delivery-manager
---

# 技能：工作室自动更新 (/usds-update)

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
    - 管道模式需显式传参：加 `-s -- --profile <名> --force`（sh）或用 scriptblock 包装传 `-Profile <名> -Force`（ps1）
5.  **完成**: 提示用户重启会话以加载新技能。

## 升级迁移说明

安装器会**自动清理重命名残留**：从 v2.0 升级到 v2.1 时，已被前缀化取代的旧命令目录
（`start`、`review`、`discovery` 等 20 个，见 `docs/arch/ADR-002`）会在安装新文件后删除，
避免斜杠菜单新旧命令并存。该清理只针对 USDS 保留名，不影响用户自装技能。
新旧的完整对照表在 `CLAUDE.md` 的 "v2.1 命令重命名对照" 一节。

---

## 成功门控 (Success Gate)

- `.claude/VERSION` 文件已更新至最新版本号。
- 新的技能指令出现在 `/` 列表中。

## 输出约束 (Output Budget)

**[强制]** 完成后，返回主上下文只输出：

```
工作室已更新。

- 版本：[旧版本] → [新版本]
- 请重启会话以加载新配置。
```

更新已跳过或失败时：`更新跳过 — 当前已是最新版本 [版本号]`