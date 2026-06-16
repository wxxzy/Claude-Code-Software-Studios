---
name: project-scan
description: 已有项目扫描与映射。当用户需要分析现存代码库的架构、识别技术债或为维护型项目建立系统地图时使用。
context: fork
agent: technical-architect
---

# 技能：项目扫描与映射 (/project-scan)

**执行代理**: `technical-architect` & `lead-developer`

---

## 概述 (Summary)

此技能用于在接手现有项目时，快速建立对技术栈、架构模式和代码质量的认知。

## 协作工作流 (Workflow)

1.  **自动审计 (Question-less)**: 代理自动扫描根目录和核心源码目录。
2.  **技术栈识别**: 识别后端、前端、数据库和 CI/CD 配置。
3.  **产出方案 (Options)**:
    - 代理展示识别到的架构草图。
    - 询问用户：哪些模块是目前最需要关注的“黑盒”？
4.  **生成草案 (Draft)**:
    - 生成 `docs/arch/SYSTEM-MAP.md` (系统模块图)。
    - 生成 `docs/arch/TECH-DEBT.md` (已知技术债清单)。
5.  **批准 (Approval)**: 用户确认文档准确性。

## 成功门控 (Success Gate)

- 明确标识了当前项目的入口文件和核心依赖。
- 文档中记录了至少 3 个核心模块的功能描述。
- 识别出了现有的测试覆盖情况。

## 输出约束 (Output Budget)

**[强制]** 返回主上下文时，只输出以下格式的单行摘要，不得重复文档内容：

```
扫描完成。以下是结果摘要：

**生成文档**
- `docs/arch/SYSTEM-MAP.md` — [一句话描述]
- `docs/arch/TECH-DEBT.md` — [X 条债务条目]

**最值得关注的技术债**
- [优先级最高的 1-2 条，每条不超过 30 字]

**下一步建议**
[一句话]
```

完整内容已写入文件，不得在摘要中展开。
