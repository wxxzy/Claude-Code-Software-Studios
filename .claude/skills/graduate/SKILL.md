---
name: graduate
description: 原型晋升。将 sandbox/ 下经过验证的原型正式迁移到 src/，补齐工程标准（ADR、测试、命名规范）。
context: fork
agent: delivery-manager
---

# 技能：原型晋升 (/graduate)

**执行代理**: `delivery-manager` (主导) + `technical-architect` + `lead-developer` + `qa-lead`

---

## 概述 (Summary)

将 `sandbox/<name>/` 下经过验证的原型，正式迁移到 `src/`，同时补齐所有 Studio Mode 工程标准。
这是 Vibe Mode → Studio Mode 的**唯一合法通道**。

---

## 前置条件 (Preconditions)

- `sandbox/<name>/` 存在且可运行
- `docs/specs/lite-spec.md` 存在
- `docs/specs/intent-log.md` 中至少有 1 条 `continue` 判断（证明方向经过校准）
- 用户明确请求晋升

---

## 工作流 (Workflow)

### 阶段 1：晋升评估 (Delivery Manager)
1. 检查前置条件
2. 用 `ask_user` 确认晋升目标：
   - "这个原型将从探索性质变为可维护的正式模块"
   - "所有 Vibe Mode 豁免的规则都将重新生效"
   - "预计需要 X 轮迭代补齐工程标准"
   - [继续晋升] [暂缓] [取消]

### 阶段 2：追认型 ADR (Technical Architect)
1. 分析 sandbox 代码的实际技术选型
2. 生成 `docs/arch/ADR-<n>.md`，追认设计决策
3. 必须包含：背景、决策、权衡、替代方案 (参照 `doc-standards.md`)
4. 关联 `docs/specs/lite-spec.md` 作为需求来源

### 阶段 3：迁移与补齐 (Lead Developer)
按顺序执行：
1. **代码迁移**: `sandbox/<name>/` → `src/<module>/`
2. **消除硬编码**: 提取到 config / env
3. **命名规范**: 符合 `global-standards.md`
4. **拆分文件**: 单文件 ≤ 300 行，单函数 ≤ 30 行
5. **补齐文档**: 所有导出 API 添加 JSDoc / Docstring
6. **结构化错误处理**: 符合 `backend-api.md`
7. **补齐测试**: 在 `tests/<module>/` 添加测试，符合 `test-conventions.md`
   - 核心逻辑 100% 分支覆盖
   - 每个函数至少 Happy Path + Error Path

### 阶段 4：质量门 (QA Lead)
1. 执行 `/gate-check`
2. 验证所有工程标准通过
3. 若失败，回退到阶段 3

### 阶段 5：归档 (Delivery Manager)
1. 移动 `sandbox/<name>/` → `sandbox/archive/<name>-<date>/`
2. 更新 `production/backlog.md`：标记原始 vibe 任务已完成
3. 关闭 `docs/specs/intent-log.md` 的意图追踪

---

## 成功门控 (Success Gate)

- [ ] `src/<module>/` 存在且符合所有工程规则
- [ ] `docs/arch/ADR-<n>.md` 已生成
- [ ] `tests/<module>/` 覆盖率达标
- [ ] `/gate-check` 通过
- [ ] `sandbox/archive/` 已归档
- [ ] `production/backlog.md` 已更新

---

## 输出约束 (Output Budget)

**[强制]** 完成后返回主上下文只输出：

```
晋升完成: [name] 已从 sandbox 迁移到 src。

- 源码: src/[module]/
- 架构决策: docs/arch/ADR-[n].md
- 测试覆盖: [X]%
- 归档位置: sandbox/archive/[name]-[date]/

现已进入 Studio Mode 维护流程。
```

---

## 失败处理

若晋升过程中发现原型**根本不该晋升**（架构不匹配、测试无法覆盖等）：
- 回滚所有变更
- 追加"晋升失败分析"到 `docs/specs/intent-log.md`
- 建议：继续保留 sandbox 状态 或 pivot 重做

---

## 协作路径

- 前置：`/vibe-check` 确认方向稳定
- 后续：进入常规 Studio Mode 流程（`/sprint-kickoff` / `/review` / `/gate-check`）
