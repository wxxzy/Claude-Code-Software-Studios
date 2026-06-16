---
name: gate-check
description: 发布前质量门控审计。当代码即将交付、需要 QA 按发布清单做最后质量验证时使用。
context: fork
agent: qa-lead
---

# /gate-check — 质量门控

**代理**: `qa-lead` | **产出**: `docs/reviews/RELEASE-CHECKLIST-xxx.md`

## 参数

- `/gate-check [功能/版本]` — 默认模式：只输出结论摘要 + 报告路径
- `/gate-check --detail [功能/版本]` — 详情模式：在返回摘要中额外展开所有检查项的通过/失败状态

## 工作流

1. **汇总**: `qa-lead` 读 PRD 验收标准；`technical-architect` 确认 ADR 契约；`lead-developer` 提供测试结果。

2. **理解验证**: 用 `ask_user` 向开发者提 2-3 个问题（最复杂函数逻辑 / 依赖变更影响面 / 与 ADR 出入）。
   - 能回答 → 继续
   - 无法回答 → 在清单中标注 `[理解风险]`，结论注明建议代码走查

3. **清单审计**: 按 `.claude/universal/docs/templates/RELEASE-CHECKLIST.md` 逐项核查。

4. **结论**: 必须用 `ask_user` 提供 **[允许发布] [附带风险通过] [拒绝发布]** 三个按钮，点击后方可结束。

## 成功门控

- [ ] 生成 `docs/reviews/RELEASE-CHECKLIST-xxx.md`
- [ ] 所有验收标准有明确状态
- [ ] `ask_user` 已收到明确点击

## 输出约束 **[强制]**

`ask_user` 返回后：

**默认模式**（无 `--detail`）只输出：
```
Gate Check 完成 — [✅ 允许发布 / ⚠️ 附带风险通过 / ❌ 拒绝发布]
- 报告：docs/reviews/RELEASE-CHECKLIST-[xxx].md
- 通过项：[X]/[总数] | 阻断：[N] | 理解风险：[有/无]
```

**详情模式**（`--detail`）在上述摘要后追加：
```
检查项详情：
- [✅/❌] 验收标准 1：[名称]
- [✅/❌] 验收标准 2：[名称]
- [⚠️]  已知缺陷：[描述]
（仅列出有明确状态的项，不重复 PRD/ADR 原文）
```

## 协作路径

- 汇总 `product-director`（需求）、`technical-architect`（设计）、`lead-developer`（实现）产出物。
- 拒绝将阻断 `delivery-manager` 发布计划。
