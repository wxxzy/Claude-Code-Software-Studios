---
name: vibe-check
description: 意图对齐校准。在原型迭代 3-5 轮后，或用户表达"感觉不对"时使用。对齐"最初想要什么 vs 现在做出了什么"。
context: fork
agent: explainer
---

# 技能：Vibe 校准 (/vibe-check)

**执行代理**: `explainer` (解说员) 主导 + `prompt-refiner` (辅助)

---

## 概述 (Summary)

Vibe coding 最大的隐性风险是**意图漂移**：用户不断微调需求，AI 不断跟随，
几轮后偏离最初意图但双方都未察觉。此技能是**周期性对齐机制**。

---

## 触发时机 (Triggers)

- 每完成 3-5 个迭代后（Explorer 主动触发）
- 用户表达"感觉不对"、"不是我想要的"、"我们跑偏了吗"
- 原型代码超过 500 行时（自动提示）
- 用户主动 `/vibe-check`

---

## 工作流 (Workflow)

1. **加载上下文**: 
   - `docs/specs/lite-spec.md` (最初意图)
   - `docs/specs/intent-log.md` (历史校准记录)
   - `sandbox/<name>/README.md` (当前状态)
2. **生成三段式汇报** (Explainer 主导，用非技术语言)：
   - **"你最初说要 X"** — 引用 lite-spec 原句
   - **"我们现在做出了 Y"** — 描述当前 demo 实际能做什么
   - **"两者之间的偏离是 Z"** — 明确指出漂移方向
3. **展示证据**: 
   - 当前 demo 的运行截图（若前端）
   - 或核心功能的输入输出示例
4. **封闭式三问** (用 `ask_user`)：
   - Q1: 整体方向对吗？[对 / 需要 pivot / 直接 kill]
   - Q2: 视觉/体验氛围对吗？[对 / 微调 / 重来]
   - Q3: 下一步优先级？[功能A / 功能B / 打磨现有]
5. **记录到 intent-log**: 追加一条 Round 记录
6. **产出行动清单**: 基于用户回答，给出下一轮迭代的 2-3 条具体动作

---

## 成功门控 (Success Gate)

- `docs/specs/intent-log.md` 新增了一条 Round 记录
- 用户对三个问题都给出了明确回答
- 产出了下一轮的具体行动清单（≤ 3 条）
- 若用户选择 `kill` 或 `pivot`，触发相应流程

---

## 输出约束 (Output Budget)

**[强制]** 完成后返回主上下文只输出：

```
Vibe 校准完成 (Round [N])。

- 方向判断: [continue / pivot / kill]
- 关键漂移: [一句话]
- 下一步行动:
  1. ...
  2. ...
  3. ...

intent-log 路径: docs/specs/intent-log.md
```

**不得**在返回摘要中重复三段式汇报正文。

---

## 特殊情况处理

- **用户选 kill**: 归档 `sandbox/<name>/` 到 `sandbox/archive/`，追加"死因分析"到 intent-log
- **用户选 pivot**: 建议重跑 `/vibe-start` 并保留 sandbox 作参考
- **连续 3 次 vibe-check 都是 continue 且高一致性**: 提示可考虑 `/graduate`

---

## 协作路径

- continue → 继续迭代 `/prototype` 或直接编辑
- pivot → `/vibe-start` 重新对齐
- kill → 归档流程
- 稳定 → `/graduate` 晋升
