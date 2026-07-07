---
name: vibe-start
description: Vibe Mode 轻量意图捕获。当用户想快速尝试一个想法、做原型或个人玩具项目时使用。替代重量级 /discovery 流程。
context: fork
agent: prompt-refiner
---

# 技能：Vibe 启动 (/vibe-start)

**执行代理**: `prompt-refiner` (需求提炼师) + `stylist` (风格师，辅助)

---

## 概述 (Summary)

面向 vibe coding 场景，用 3-5 轮对话把模糊想法转化为可执行方向。
产出 `docs/specs/lite-spec.md`——一个轻量级、审美优先的意图文档。

**不适用场景**：企业项目、需要长期维护的严肃系统 → 请使用 `/discovery`。

---

## 工作流 (Workflow)

1. **启动**: 用户输入 `/vibe-start [模糊想法]`
2. **确认模式**:
   - 检查 `.usds-mode` 文件
   - 若未声明或不是 `vibe`，使用 `ask_user` 询问："这是探索原型还是严肃项目？"
   - 若是严肃项目，建议改用 `/discovery`
3. **意图访谈** (最多 5 轮)：
   - 第 1 轮：一句话描述你想做什么？
   - 第 2 轮：有类似产品参考吗？有截图/URL吗？（Stylist 介入）
   - 第 3 轮：三条必须达成的事？
   - 第 4 轮：哪些明确**不做**？
   - 第 5 轮：给这个项目起个名字？
4. **生成 lite-spec**: 基于 `.claude/docs/templates/lite-spec.md` 模板生成文档
5. **确认**: 使用 `ask_user` 提供 [开始原型 `/prototype`] [调整] [取消] 三选项
6. **结束**: 用户确认后写入 `docs/specs/lite-spec.md`

---

## 成功门控 (Success Gate)

- 生成了 `docs/specs/lite-spec.md`
- 包含"一句话意图"、"三条必须达成"、"明确不做"三节
- 若有参考产品，记录了参考链接或截图路径
- 项目名已确定（Kebab-case，用于 sandbox 目录）

---

## 输出约束 (Output Budget)

**[强制]** 写入文件后，返回主上下文只输出：

```
Vibe 意图捕获完成。

- 项目名: [name]
- 一句话: [intent]
- 下一步: 运行 `/prototype` 开始出 demo

lite-spec 路径: docs/specs/lite-spec.md
```

不得复述访谈过程。

---

## 协作路径

- 完成后 → `/prototype` (交棒 `explorer`)
- 若晋升严肃项目 → `/graduate` 转为 PRD
