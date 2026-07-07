---
name: branch-vibe
description: Vibe Mode 平行探索分叉。当想尝试完全不同的技术栈/风格/架构而不覆盖当前原型时使用。基于 git worktree 隔离，允许多个方向并行探索。
context: main
agent: explorer
---

# 技能：平行探索分叉 (/branch-vibe)

**执行代理**: `explorer` (探索者) 主导 + `delivery-manager` (辅助管理 worktree)

---

## 概述 (Summary)

Vibe coding 常见场景："这版感觉不错，但如果换 X 会怎样？"
如果直接改动当前原型，就丢失了对比证据。`/branch-vibe` 用 **git worktree**
在物理隔离的目录中开一个平行分叉，让两个方向可以并行迭代、对比、择优。

**核心价值**：让"要不要 pivot"变成"两边都跑跑看"的低成本决策。

---

## 前置条件 (Preconditions)

- 当前项目在 git 仓库中
- 至少存在一个 `sandbox/<name>/` 原型
- 用户明确表达了想尝试的分叉方向（技术栈 / 风格 / 架构差异）

---

## 工作流 (Workflow)

### 阶段 1：分叉动机 (Explorer)
使用 `ask_user` 确认分叉理由，二选一：
- **A. 保留对比**：当前方向也不错，但想看看另一个可能
- **B. 探索性 pivot**：怀疑当前方向不对，但不敢直接删

若用户选 A → 继续。若选 B → 建议先跑 `/vibe-check` 确认是否真需要 pivot。

### 阶段 2：分叉规格 (Explorer + Prompt Refiner)
让用户明确"分叉后跟原版**唯一的差异**"：
- 技术栈差异？（React → Svelte）
- 风格差异？（Minimalist → Playful）
- 架构差异？（SPA → MPA）
- 数据模型差异？

原则：**一次分叉只改一个变量**，否则对比无效。

### 阶段 3：创建 worktree (Delivery Manager)
1. 生成分叉名：`<原名>-alt-<变量>`（如 `todo-app-alt-svelte`）
2. 创建 worktree：
   ```bash
   git worktree add .worktrees/<分叉名> -b vibe/<分叉名>
   ```
3. 在新 worktree 中：
   - 复制 `sandbox/<原名>/` → `sandbox/<分叉名>/`
   - 复制 `docs/specs/lite-spec.md` → `docs/specs/lite-spec-<分叉名>.md`
   - 修改 lite-spec 的"技术栈倾向"字段反映分叉差异
4. 记录到 `docs/specs/intent-log.md`：
   ```
   ## Round N — <日期>
   - 事件: /branch-vibe
   - 分叉方向: <差异描述>
   - worktree 路径: .worktrees/<分叉名>
   - 分支: vibe/<分叉名>
   ```

### 阶段 4：分叉初始化 (Explorer)
在新 worktree 中：
1. 根据分叉差异改造原型（例如换技术栈）
2. 记录 `sandbox/<分叉名>/README.md`：
   - 相对于原版的差异
   - 分叉动机
   - 对比要点

### 阶段 5：切换指引 (Delivery Manager)
提示用户如何在两个分叉之间切换：
```bash
# 到分叉工作
cd .worktrees/<分叉名>

# 回到主线
cd <项目根目录>
```

---

## 成功门控 (Success Gate)

- git worktree 创建成功
- 分叉 sandbox 目录存在且已初始化
- `intent-log.md` 记录了本次分叉事件
- 用户理解如何在两个方向之间切换

---

## 分叉管理约定

### 命名规范
- worktree 目录：`.worktrees/<分叉名>` (加入 `.gitignore` 的 `.worktrees/` 若未忽略)
- 分支：`vibe/<分叉名>`
- sandbox：`sandbox/<分叉名>/`

### 数量限制
- 同时活跃的分叉建议 ≤ 3 个
- 超过 3 个时，先做一轮 `/taste-review` 或 `/vibe-check`，淘汰弱势方向

### 合并回主线
分叉胜出后，用 `/graduate` 晋升（可选择晋升到 `src/` 或替换主 sandbox）。

### 清理淘汰的分叉
```bash
git worktree remove .worktrees/<分叉名>
git branch -D vibe/<分叉名>
```

---

## 输出约束 (Output Budget)

**[强制]** 完成后返回主上下文只输出：

```
分叉已创建 — <分叉名>

- 差异: <一句话>
- worktree: .worktrees/<分叉名>
- 分支: vibe/<分叉名>
- 复制的原型: sandbox/<分叉名>/

进入分叉工作: cd .worktrees/<分叉名>
回到主线: cd <项目根目录>
```

不得复述访谈过程。

---

## 失败处理

- **不在 git 仓库**：提示先 `git init` 或改用 `/prototype` 直接新建
- **worktree 冲突**：若同名分支已存在，建议改用不同分叉名
- **磁盘空间不足**：提示清理 `.worktrees/` 下的淘汰分叉

---

## 协作路径

- 分叉完成 → 在新 worktree 中迭代 `/prototype`
- 需要对比 → `/taste-review` 对两个分叉分别评审
- 胜负已分 → `/graduate` 晋升胜者，删除败者
