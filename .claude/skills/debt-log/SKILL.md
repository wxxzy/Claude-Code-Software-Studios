---
name: debt-log
description: 技术债登记与查询。记录、更新、还清技术债条目，维护 docs/debt-ledger.md。跨模式使用。
context: fork
agent: debt-auditor
---

# 技能：债务登记 (/debt-log)

**执行代理**: `debt-auditor` (债务审计师)

---

## 概述 (Summary)

Vibe Mode 允许硬编码、跳过测试——这些是**明码标价的债**，不是错误。
Studio Mode 也会积累过时依赖、被绕过的规则、遗留 TODO。

未被记账的债务是危险的。`/debt-log` 让所有债务变得可见、可查、可清偿。

---

## 触发时机 (Triggers)

- 用户运行 `/debt-log`（子命令：`add` / `list` / `resolve` / `report`）
- `/review` 结束时 Debt Auditor 主动追加
- `/graduate` 前强制清点 sandbox 未记账债务
- `/gate-check` 前生成简报

---

## 子命令 (Sub-commands)

### `/debt-log add`
新增债务条目。使用 `ask_user` 收集：
- **描述**: 一句话说清楚是什么
- **位置**: `文件:行号` 或 `模块/目录`
- **严重度**: `critical` / `high` / `medium` / `low`
- **利率**: `flat` / `linear` / `compound`
- **代价**: 如果不还会造成什么
- **建议还款时机**: 立即 / 下个 sprint / 晋升前 / 无期限

### `/debt-log list`
按严重度分组列出所有未还债务，不生成新文件。

### `/debt-log resolve <id>`
标记某条债务已还清：
- 从"未还清"移入"已还清"章节
- 记录还款日期和方式
- 若通过 `/review` 或 `/gate-check` 触发，自动关联

### `/debt-log report`
生成债务健康简报（不修改 ledger）。

### 默认（无子命令）
等同于 `report`。

---

## 工作流 (Workflow — 以 add 为例)

### 阶段 1：分类判断 (Debt Auditor)
首先判断这是**债**还是**bug**：
- **是债**：Vibe Mode 允许的临时妥协、未来某日需要偿还的代码
- **是 bug**：跨越 Hard Limits 的（密钥泄露、SQL 拼接、未验证输入）
  → **拒绝记录**，指示立即修复

### 阶段 2：收集元数据
按 add 子命令的字段清单收集。

### 阶段 3：分配 ID
格式：`DEBT-<YYYYMMDD>-<序号>`（如 `DEBT-20260706-001`）。

### 阶段 4：追加账本
按模板格式追加到 `docs/debt-ledger.md`：
```
## DEBT-20260706-001 [high|compound]

- 描述: 硬编码 API URL 在 sandbox/todo/main.js:42
- 位置: sandbox/todo/main.js:42
- 严重度: high
- 利率: compound（每加一个环境增加 1 处修改）
- 代价: 环境切换必须改代码
- 建议还款: 晋升前
- 产生日期: 2026-07-06
- 状态: 未还清
```

### 阶段 5：更新指标
重新计算债务健康度：
- 总条目数
- 各严重度分布
- 平均债龄
- 近 30 天净增

---

## 成功门控 (Success Gate)

- `docs/debt-ledger.md` 存在且格式正确
- 新增/更新/还清操作已落盘
- 若是"add"，条目具备完整元数据
- 若是"report"，包含四个核心指标

---

## 输出约束 (Output Budget)

### add 操作
```
✓ 债务已登记: DEBT-<id>

- 描述: <一句话>
- 严重度: <level>
- 建议还款: <时机>

账本: docs/debt-ledger.md
```

### report 操作
```
🧾 债务简报 — <YYYY-MM-DD>

总债务: <N> 条
├─ critical: <n>
├─ high:     <n>
├─ medium:   <n>
└─ low:      <n>

平均债龄: <n> 天
最老债务: <描述>（<日期>）

近 30 天:
├─ 新增: <n>
├─ 还清: <n>
└─ 净增: <n>

高危警告:
- <critical/high 条目 ID + 摘要>
```

### resolve 操作
```
✓ 已还清: DEBT-<id>
- 债龄: <n> 天
- 还款方式: <描述>
```

---

## 是"债"还是"bug"？判定表

| 场景 | 判定 | 处理 |
|---|---|---|
| Vibe Mode 硬编码 API URL | 债 | 登记 `high|compound` |
| Vibe Mode 单文件 500 行 | 债 | 登记 `medium|flat` |
| Vibe Mode 跳过测试 | 债 | 登记 `medium|linear` |
| 依赖库过时 6 个月 | 债 | 登记 `low|compound` |
| 有 TODO 但功能可用 | 债 | 登记 `low|flat` |
| **密钥出现在代码中** | **bug** | **立即修复，不登记** |
| **SQL 字符串拼接** | **bug** | **立即修复，不登记** |
| **未验证输入直达 DB** | **bug** | **立即修复，不登记** |
| **`eval` 未过滤输入** | **bug** | **立即修复，不登记** |

---

## 与其他技能的边界

| 关注点 | 归属 |
|---|---|
| 代码质量评审 | `/review` |
| 发布合规检查 | `/gate-check` |
| 债务持续追踪 | **`/debt-log`** |
| 微观技术决策记录 | `/micro-adr` |

---

## 协作路径

- 新增高危债务后 → 建议 `/review` 或立即修复
- `/graduate` 前 → 强制 `/debt-log list` 检查未还账
- 长期未还的 critical 债 → 汇报给 Delivery Manager 排入 backlog
