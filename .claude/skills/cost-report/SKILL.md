---
name: cost-report
description: 成本报告技能。汇总 token 消耗、时间投入、外部 API 费用到 docs/cost-ledger.md，产出周期性回顾。跨模式使用。
context: fork
agent: cost-accountant
---

# 技能：成本报告 (/cost-report)

**执行代理**: `cost-accountant` (成本会计)

---

## 概述 (Summary)

追踪并汇报本项目的成本消耗，帮助用户判断 vibe coding 的 ROI 是否合理。
覆盖三类成本：**token**（AI 消耗）、**时间**（用户投入）、**外部 API**（付费服务）。

**重要限制**：Claude Code 会话内**无法自动读取** token 计数。
所有数据必须由用户手工提供，或从外部工具（`ccusage`、`claude-usage`）导入。

---

## 触发时机 (Triggers)

- 用户运行 `/cost-report`（含可选参数 `--period week|month|project`）
- 用户在 `/vibe-check` 中询问"这轮花了多少"
- 项目结束或阶段性回顾时

---

## 工作流 (Workflow)

### 阶段 1：数据采集 (Cost Accountant)
1. 加载 `docs/cost-ledger.md`（若不存在，用模板初始化）
2. 用 `ask_user` 询问本次要记录的新消耗：
   - Token（k）: <数字>
   - 金额（USD）: <数字>
   - 时间（小时）: <数字>
   - 归因项目/技能: <标签>
   - 数据来源: <手工 | ccusage | 其他>
3. 若用户提供 `unknown`，如实标注**不猜测**

### 阶段 2：追加账本
以下格式追加到 `docs/cost-ledger.md`：
```
## <YYYY-MM-DD>

- 归因: <项目/技能>
- Token: <n>k
- 金额: $<n>
- 时间: <n> h
- 数据来源: <source>
- 备注: <可选>
```

### 阶段 3：统计与归纳
根据 `--period` 参数计算：
- **week**: 最近 7 天累计
- **month**: 最近 30 天累计
- **project**: 按归因项目分组
- **默认（无参数）**: 项目全周期累计

### 阶段 4：异常识别
标记异常消耗：
- 单次消耗 > 平均值 3σ
- 某项目累计占比 > 40%
- 连续 3 次相同项目消耗未产出可交付物

### 阶段 5：建议生成
基于数据给出 1-3 条具体建议，如：
- "project-X 已消耗 $Y 但未晋升，建议 `/vibe-check` 判断是否 kill"
- "60% token 花在 /discovery，考虑用 /vibe-start 简化"
- "近 7 天时间消耗是月均的 2 倍，注意疲劳"

---

## 成功门控 (Success Gate)

- `docs/cost-ledger.md` 存在且格式正确
- 本次采集数据已追加
- 输出报告包含：累计 / Top 3 归因 / 异常 / 建议
- 所有数字都有明确来源（手工/工具/unknown）

---

## 输出约束 (Output Budget)

**[强制]** 输出格式固定：

```
📊 成本报告 — <周期>

累计消耗:
- Token: <n>k
- 金额: $<n>
- 时间: <n> h

Top 3 消耗归因:
1. <项目/技能>: <占比>%
2. ...
3. ...

异常:
- <若有>

建议:
- <一句话>

账本: docs/cost-ledger.md
```

不复述历史条目，只做汇总。

---

## 数据来源建议

外部工具（推荐）：
- **ccusage** (Claude Code): `npx ccusage@latest` 查看 token 使用
- **claude-usage** (Web): claude.ai 的 usage dashboard
- Anthropic API 账单: console.anthropic.com

手工方式：
- 每次结束会话前，看 Claude Code 的 status bar
- 用秒表/番茄钟记录实际投入时间

---

## 特殊情况

### 首次运行
若 `docs/cost-ledger.md` 不存在：
- 从 `.claude/docs/templates/cost-ledger.md` 复制模板
- 提示用户：先补录历史消耗（可选），再开始追踪

### 项目已结束
若用户表示"我要归档这个项目"：
- 生成最终报告
- 在 ledger 顶部追加 `## 项目总结` 章节
- 建议将 ledger 归档到 `docs/archived/<project>-cost.md`

---

## 与其他技能的边界

| 关注点 | 归属 |
|---|---|
| Token / 金额 / 时间成本 | **`/cost-report`** |
| 技术债追踪 | `/debt-log` |
| 微观技术决策 | `/micro-adr` |

---

## 协作路径

- 发现异常消耗 → 建议 `/vibe-check` 或 `/explain-back` 复盘
- 长期项目 → 每月自动建议一次 `/cost-report`
- 项目归档 → 生成最终报告 + 迁移账本到 `docs/archived/`
