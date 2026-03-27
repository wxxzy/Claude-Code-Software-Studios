# 自动化钩子参考手册 (Hooks Reference)

本手册定义了 Universal Software Studio (USDS) 的自动化验证流程，以及它们在 Git 协作生命周期中的触发点。

## 1. 会话生命周期 (Session Lifecycle)

- **`session-start.sh`**: **[Trigger: Startup]** 自动扫描 `backlog.md` 和 PRD 状态。
- **`detect-gaps.sh`**: **[Trigger: Startup]** 自动检测“代码有变但没写文档”的工程缺口。
- **`pre-compact.sh`**: **[Trigger: Before Compression]** 在 Claude 压缩上下文前，自动提取并保护当前任务摘要。
- **`session-stop.sh`**: **[Trigger: Close]** 会话结束时生成工作日报快照。

## 2. 提交与推送门控 (Gatekeeping)

- **`validate-commit.sh`**: **[Trigger: git commit]** 扫描硬编码密钥、Magic Numbers 和 TODO 格式。
- **`validate-push.sh`**: **[Trigger: git push]** 强制运行单元测试，确保推送到 `main` 分支的代码是 100% 绿色的。

## 3. 审计与追踪 (Auditing)

- **`log-agent.sh`**: **[Trigger: Subagent Start]** 自动记录每一个子代理的职责、目标和调用链，存储在 `production/session-logs/`。

## 4. 协作约束 (Collaboration)
- **拒绝规则**: 如果钩子返回错误，Claude 会被强制终止当前的写入或提交动作，直到用户通过 `replace` 修复了合规性问题。
