---
name: micro-adr
description: 微观架构决策记录。用于记录不足以写完整 ADR 的技术选型（如"为什么选 zustand 不用 jotai"）。追加到 docs/arch/micro-adr.md，一决策一行。
context: fork
agent: technical-architect
---

# 技能：微决策记录 (/micro-adr)

**执行代理**: `technical-architect` (技术架构师)

---

## 概述 (Summary)

完整 ADR 有 4 大章节（背景、决策、权衡、替代方案）——对**微观选型**过重。
但如果不记录，三个月后"为什么当初选 zustand"这个问题就永远无解。

`/micro-adr` 用**一行一决策**的极简格式追加到 `docs/arch/micro-adr.md`，
保留决策考古的可能性，同时不增加负担。

---

## 触发时机 (Triggers)

- 用户运行 `/micro-adr "<决策描述>"`
- Explorer / Lead Developer 在做技术选型后主动追加
- `/review` 发现代码内有 `// ai-choice: ...` 注释时提示归档

---

## 工作流 (Workflow)

### 阶段 1：判定归属
先判断这是**微决策**还是**架构决策**：

| 类型 | 判定 | 处理 |
|---|---|---|
| 微决策（选库、选写法、选常量） | **micro** | 追加到 `micro-adr.md` |
| 架构决策（分层、协议、领域模型） | **adr** | 建议改用 `/arch-design` |

判断规则：**影响范围 ≤ 3 文件 且 可回退 ≤ 1 小时** → 微决策。

### 阶段 2：收集元数据
使用 `ask_user` 收集（尽量简短）：
- **决策**: 选了什么？（如 `zustand`）
- **替代**: 考虑过什么？（如 `jotai, redux-toolkit`）
- **理由**: 一句话（如 "文档更清晰，team 熟悉"）
- **反悔成本**: `low` / `medium` / `high`

### 阶段 3：追加账本
一行格式追加到 `docs/arch/micro-adr.md`：
```
| YYYY-MM-DD | <决策> | <替代> | <理由> | <反悔成本> | <场景/文件> |
```

### 阶段 4：可选交叉引用
若决策位置明确（文件+行号），提示用户在代码中加注释：
```
// micro-adr: 见 docs/arch/micro-adr.md YYYY-MM-DD
```

---

## 成功门控 (Success Gate)

- `docs/arch/micro-adr.md` 存在（若无，从模板创建）
- 新条目已追加，格式正确
- 若是架构决策，正确引导用户改用 `/arch-design`

---

## 输出约束 (Output Budget)

**[强制]** 完成后返回主上下文只输出：

```
✓ 微决策已记录

<日期> | <决策> vs <替代> | <理由>

账本: docs/arch/micro-adr.md
```

不复述历史条目。

---

## 判定示例

| 场景 | 判定 |
|---|---|
| "选用 zustand 做状态管理" | micro（单文件影响，可换） |
| "把 API 从 REST 改为 GraphQL" | **adr**（架构级，用 /arch-design） |
| "选用 dayjs 而非 moment" | micro |
| "引入事件驱动架构" | **adr** |
| "选择 useReducer 而非 useState" | micro |
| "统一用 tRPC 做前后端契约" | **adr** |
| "常量提取到 config.ts" | micro |
| "选 pnpm 作为包管理器" | micro（可换但要成本，标 medium） |

---

## 与其他技能的边界

| 决策规模 | 归属 |
|---|---|
| 微观选型（一句话说得清） | **`/micro-adr`** |
| 单个系统的架构决策 | `/arch-design` → ADR |
| 跨系统的整体设计 | `/arch-design` → 多个 ADR |
| 债务（不是决策而是妥协） | `/debt-log` |

---

## 特殊情况

### 决策后又反悔
不删除原条目——追加新条目，理由写"反悔 <原日期> 的决策，原因..."。
决策考古的价值在于**看到犹豫**，而不是**假装从没错过**。

### 追认历史决策
若代码已有 `// ai-choice:` 或 `// TODO: why` 类注释，可以批量追认：
- 扫描注释
- 让用户逐条确认后追加到 micro-adr

### Vibe Mode 下也用吗？
**可选但推荐**。Vibe Mode 里的微决策同样有考古价值，
特别是决定 `/graduate` 晋升时能省大量回忆时间。

---

## 协作路径

- 若判定为架构决策 → 转 `/arch-design`
- 若决策涉及技术债 → 顺便 `/debt-log add` 记账
- `/graduate` 时 → 建议扫一遍 micro-adr 决定哪些要升级为 ADR
