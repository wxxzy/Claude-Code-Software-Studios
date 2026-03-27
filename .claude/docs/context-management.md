# 上下文管理策略 (Context Management Strategy)

本策略定义了如何优化 Claude Code 的上下文窗口，确保大规模项目的长久可维护性。

## 1. 永久记忆 vs. 临时记忆 (Memory Retention)

- **永久记忆 (Permanent)**: `CLAUDE.md`, `UNIVERSAL-STUDIO.md`, `docs/arch/ARCHITECTURE-STATE.md`。这些文件描述了系统的最终态。
- **临时记忆 (Transient)**: 零散的 `docs/arch/ADR-xxx.md` 和 `production/backlog.md`。这些文件描述了变更的过程。

## 2. 压缩机制 (The Compression Rule)

- **指令触发**: 运行 `/summarize-arch` 会触发一次强制压缩。
- **逻辑**: 将所有 `Approved` 状态的 ADR 合并到 `ARCHITECTURE-STATE.md`，并将旧的 ADR 归档或删除。
- **益处**: 减少代理每次读取变更历史的 Token 消耗，防止其被过时的决策干扰。

## 3. 会话保护 (Pre-Compact Hooks)

- 当 Claude 进行上下文压缩 (Context Compression) 时，`.claude/hooks/pre-compact.sh` 会自动提取当前的待办任务摘要，确保重要上下文不丢失。

## 4. 命名约定的上下文意义

- 所有的 PRD 文件必须以 `PRD-` 开头，ADR 文件必须以 `ADR-` 开头。这让代理通过 `glob` 搜索能精准识别文档类型，避免全量扫描目录导致的上下文浪费。
