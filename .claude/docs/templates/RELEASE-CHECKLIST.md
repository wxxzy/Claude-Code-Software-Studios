# 发布质量清单 (Release Checklist): [版本/功能]

- **日期**: [日期]
- **负责人**: `qa-lead`
- **状态**: [已通过 / 需修复 / 已拒绝]

---

## 1. 需求验证 (Requirement Verification)
- [ ] 所有 PRD 中的用户故事已实现。
- [ ] 验收标准 (Acceptance Criteria) 已通过验证。

## 2. 技术质量 (Technical Quality)
- [ ] 单元测试通过 (Pass Rate: 100%)。
- [ ] 接口响应时间符合架构设定 (如 < 200ms)。
- [ ] 无关键代码异味或明显的安全隐患。

## 3. 文档同步 (Documentation)
- [ ] 相关 API 契约已更新。
- [ ] 重要的架构决策记录 (ADR) 已归档。
- [ ] README 或部署指南已同步更新。

## 4. 回归测试 (Regression)
- [ ] 核心登录/支付/关键业务流测试通过。
- [ ] 未引入已知严重的回归 Bug。

---

## 5. 最终结论 (Final Decision)
[ 允许发布 / 风险发布 / 拒绝发布 ]
