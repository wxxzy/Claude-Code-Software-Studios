---
name: prototype
description: 快速原型技能。跳过架构设计和 ADR，直接在 sandbox/ 下产出可运行 demo。目标是 15 分钟内让用户看到能跑的东西。
context: fork
agent: explorer
---

# 技能：快速原型 (/prototype)

**执行代理**: `explorer` (探索者) + `stylist` (风格师，前端场景介入)

---

## 概述 (Summary)

**跳过一切工程仪式**，在 `sandbox/<name>/` 下直接产出可运行的原型。
明确标注："此代码为探索性质，可随时丢弃。"

**核心 KPI**: 从技能启动到用户看到能跑的东西 ≤ 15 分钟。

---

## 前置条件 (Preconditions)

- `docs/specs/lite-spec.md` 存在（若不存在，建议先跑 `/vibe-start`）
- 或用户明确表达"直接开始，我不需要 spec"

---

## 工作流 (Workflow)

1. **读取意图**: 加载 `docs/specs/lite-spec.md`（若存在）
2. **确认技术栈**: 
   - 若 `lite-spec` 已声明，直接采用
   - 否则用 `ask_user` 提供 3 个推荐组合（如："Next.js + Tailwind"、"Python Flask + HTMX"、"纯静态 HTML+JS"）
3. **创建 sandbox 目录**: `sandbox/<name>/`
4. **生成骨架**: 
   - `main.<ext>` 或 `index.html` 入口
   - `README.md` 记录如何跑起来
   - 依赖清单（`package.json` / `requirements.txt`）——**必须锁定版本**
5. **实现核心流程**: 只做 `lite-spec` 中"三条必须达成"的第一条
6. **验证可运行**: 提供启动命令，确认能跑
7. **交付**: 打印启动命令给用户

---

## 允许的"违规" (遵循 `vibe-mode.md`)

- ✅ 硬编码配置
- ✅ 单文件塞满逻辑
- ✅ 跳过测试
- ✅ 使用 mock 数据

## 仍然禁止 (Hard Limits)

- ❌ 硬编码密钥
- ❌ 不锁定依赖版本
- ❌ 沉默捕获异常

---

## 成功门控 (Success Gate)

- `sandbox/<name>/` 目录创建成功
- `README.md` 包含：如何启动、已知限制、下一步建议
- 用户可以通过 README 中的命令**实际跑起来**看到东西
- 若为前端项目，Stylist 已给出基本视觉方向（配色 / 字体 / 布局）

---

## 输出约束 (Output Budget)

**[强制]** 完成后返回主上下文只输出：

```
原型已就绪。

- 位置: sandbox/[name]/
- 启动: [具体命令，一行]
- 已实现: [第一条必须达成的事]
- 下一步: 跑起来看看，然后 `/vibe-check` 校准方向
```

---

## 协作路径

- 用户看过 demo 后 → `/vibe-check` 校准
- 若原型方向正确、想继续投入 → 迭代 `/prototype` 或直接编辑 sandbox
- 若原型值得晋升为正式产品 → `/graduate`
