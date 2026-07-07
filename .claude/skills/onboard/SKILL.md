---
name: onboard
description: 团队新人入职引导。当新成员需要了解 USDS 的五步协作法、代理分工与目录规范时使用。
context: fork
agent: delivery-manager
---

# 技能：新人入职引导 (/onboard)

**执行代理**: `delivery-manager` (交付经理)

---

## 概述 (Summary)

此技能专门用于向团队新成员介绍 **Universal Software Studio (USDS)** 的运作方式和底线协议。

## 引导流程 (Onboarding Flow)

1.  **工作室介绍**: 简述层级架构（Tier 1-3）和各代理职责。
2.  **协议演练**: 详细解释 **“提问 -> 方案 -> 决策 -> 草案 -> 批准”** 流程。
    - *互动示例*: 演示如果不经批准就写代码会被系统拒绝的情况。
3.  **规则查阅**: 引导成员查看 `.claude/rules/` 下的底层规范。
4.  **实操演练**: 引导成员运行一个简单的 `/discovery` 体验全生命周期。
5.  **答疑解惑**: 解答成员关于 AI 代理分工的疑问。

---

## 成功门控 (Success Gate)

- 成员确认已阅读并理解 `docs/COLLABORATION-GUIDE.md`。
- 成员成功进行了一次模拟决策互动。

## 输出约束 (Output Budget)

**[强制]** 完成引导后，返回主上下文只输出：

```
入职引导完成。成员已了解 USDS 五步协作法和代理分工。
建议从 `/discovery` 或 `/project-scan` 开始第一个实际任务。
```

不得重复展开代理职责列表或工作室层级说明。
