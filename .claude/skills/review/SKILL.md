---
name: review
description: 技术评审与深度代码审计。当开发完成、发布前需要架构师从性能、可维护性与安全角度审查代码实现时使用。
context: fork
agent: technical-architect
---

# /review — 技术评审

**代理**: `technical-architect` | **产出**: `docs/reviews/REVIEW-xxx.md`

## 工作流

1. **提问**: 询问开发者核心问题是什么，是否有未处理的"脏路"。

2. **发现**: 列出 2-3 个关键发现（性能瓶颈 / 代码异味 / ADR 违反）+ 改进建议。

3. **安全评审**: 涉及认证、数据库、外部 API、文件操作时，**必须**调用 `security-engineer`：
   - 检查工具参数是否可被模型/用户输入控制（AI 代理执行风险）
   - OWASP Top 10 快速扫描（注入 / 越权 / 硬编码密钥）
   - 输出：**通过** 或 **需修复**（附文件+行号）
   - `security-engineer` 标记"需修复"则自动列为必须修复项

4. **决策**: 用 `ask_user` 列出改进点，让用户选择哪些必须本次修复。

5. **草案**: 展示重构代码片段，用 `ask_user` 提供 **[执行重构] [放弃修改]**。

6. **批准**: 用户点击后执行修改，写入评审摘要到 `docs/reviews/`。

## 成功门控

- 代码符合 `TECHNICAL-PREFERENCES.md`
- 无明显 N+1 或内存泄漏，逻辑符合 ADR 契约
- 生成评审摘要至 `docs/reviews/`

## 输出约束 **[强制]**

用户批准后，向主上下文只输出：

```
评审完成 — [✅ 通过 / ⚠️ 通过（含建议）/ ❌ 需返工]
- 报告：docs/reviews/REVIEW-[xxx].md
- 发现：[X] 条（已修复 [Y] / 遗留 [Z]）| 安全：[通过/需修复/未触发]
- 下一步：[/gate-check 或 返工说明]
```

## 协作路径

- 不通过 → 任务回退 `In Progress`
- 通过 → 交 `qa-lead` 执行 `/gate-check`
