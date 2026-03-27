# 技能：质量门控 (/gate-check)

**执行代理**: `qa-lead`

---

## 概述 (Summary)

此技能用于在功能开发完成、准备合并到主分支或发布前，进行全方位的质量审计。

## 工作流 (Workflow)

1.  **启动**: 用户输入 `/gate-check [功能/版本]`。
2.  **多方数据汇总**:
    - `qa-lead` 阅读最新的 PRD 和验收标准。
    - `technical-architect` 确认 ADR 和 API 契约是否已满足。
    - `lead-developer` 提供测试运行结果。
3.  **清单审计**: 基于 `.claude/universal/docs/templates/RELEASE-CHECKLIST.md` 执行检查。
4.  **生成报告**: 产出 `docs/reviews/RELEASE-CHECKLIST-xxx.md`。
5.  **结论声明**: 明确给出 [通过]、[附带风险通过] 或 [拒绝] 的决策。

## 成功门控 (Success Gate)

- [ ] 生成了 `docs/reviews/RELEASE-CHECKLIST-xxx.md`。
- [ ] 所有验收标准都有明确的通过状态或已知缺陷。
- [ ] 结论部分清晰且有理有据。

---

## 协作路径 (Escalation)

- 需要汇总 `product-director` (需求)、`technical-architect` (设计) 和 `lead-developer` (实现) 的所有产出物进行对比验证。
- 拒绝决定将阻断 `delivery-manager` 的发布计划。
