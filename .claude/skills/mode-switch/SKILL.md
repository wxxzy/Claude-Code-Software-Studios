---
name: mode-switch
description: 双模态切换。在 Vibe Mode（探索/原型）和 Studio Mode（严肃/生产）之间切换，或初始化模式声明。
context: main
agent: delivery-manager
---

# 技能：模式切换 (/mode-switch)

**执行代理**: `delivery-manager`

---

## 概述 (Summary)

USDS v2 引入双模态架构。本技能负责：
1. 初始化项目模式声明 (`.usds-mode` 文件)
2. 在 Vibe Mode ↔ Studio Mode 之间切换
3. 处理混合模式 (`hybrid`) 的规则冲突

---

## 模式定义 (Mode Definitions)

| 模式 | 适用场景 | 主导规则 | 主要目录 |
|---|---|---|---|
| `vibe` | 探索、原型、个人玩具、demo | `vibe-mode.md` 宽松 | `sandbox/**` |
| `studio` | 生产、团队协作、长期维护 | `global-standards.md` 严格 | `src/**`, `docs/**`, `tests/**` |
| `hybrid` | 一个仓库同时容纳两种 | 按目录分派 | 两者共存 |

---

## 工作流 (Workflow)

### 场景 A：首次初始化
1. 检查项目根是否有 `.usds-mode` 文件
2. 若无，用 `ask_user` 询问：
   - **推荐推断**: 根据用户最近的语言习惯自动推荐
     - 出现"原型 / 试试 / 玩具 / demo / 快速" → 推荐 `vibe`
     - 出现"生产 / 团队 / 上线 / 严肃 / 客户" → 推荐 `studio`
   - 提供三选项：[vibe] [studio] [hybrid]
3. 写入 `.usds-mode`，格式：
   ```
   mode: <vibe|studio|hybrid>
   created: <date>
   last_switched: <date>
   reason: <一句话>
   ```

### 场景 B：从 vibe 切到 studio
1. 检查 `sandbox/` 下是否有未晋升的原型
2. 若有，提示：
   - "以下原型未晋升，切换后仍可运行但不再被主流程管理："
   - 列出所有 `sandbox/<name>/`
   - [继续切换] [先晋升] [取消]
3. 更新 `.usds-mode` 并追加 `last_switched` 时间

### 场景 C：从 studio 切到 vibe
1. **警告**: "Studio Mode 下的 src/ 代码不会因切换而失去规则约束"
2. 确认后更新 `.usds-mode`
3. 提示：新的探索性代码请放到 `sandbox/`

### 场景 D：切换到 hybrid
1. 明确规则分派：
   - `src/**` / `docs/**` / `tests/**` → Studio 规则
   - `sandbox/**` → Vibe 规则
2. 更新 `.usds-mode`
3. 在 `CLAUDE.md` 中追加双模态说明

---

## 成功门控 (Success Gate)

- `.usds-mode` 文件存在且格式正确
- `CLAUDE.md` 中的模式声明与 `.usds-mode` 一致
- 未晋升的 sandbox 原型有明确处置决策

---

## 输出约束 (Output Budget)

**[强制]** 完成后返回主上下文只输出：

```
模式已切换: [old] → [new]

- 主导规则: [规则文件名]
- 主要目录: [目录列表]
- 未处理项: [如有]

下一步建议: [根据模式给出，如 /vibe-start 或 /discovery]
```

---

## 特殊情况

### 冲突处理 (Hybrid Mode)
当同一操作跨越两种模式区域时（如 sandbox 引用 src）：
- 引用方向 sandbox → src：允许（原型可以调用生产代码）
- 引用方向 src → sandbox：**禁止**（生产代码不得依赖沙盒）

### 模式锁定
若项目为客户交付或公开发布，可在 `.usds-mode` 添加 `locked: true`：
- 锁定后禁止 `/mode-switch`，除非显式解锁
- 用于防止误操作

---

## 协作路径

- 初始化 vibe → `/vibe-start`
- 初始化 studio → `/discovery` 或 `/setup-stack`
- hybrid → 根据当前任务选择入口
