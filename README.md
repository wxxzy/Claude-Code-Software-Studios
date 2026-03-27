# Universal Software Studio (USDS)

<p align="center">
  <strong>基于 Claude Code 的工业级通用软件开发工作室框架</strong>
  <br />
  10 个核心代理 • 10 大工作流指令 • 5 步协作协议 • 纯净的通用软件工程实践
</p>

---

## 🌟 核心设计理念：协作而非自主 (Collaboration, not Autonomy)

USDS 拒绝“黑盒式”的代码生成。我们认为高质量的软件源于严谨的决策链。所有的 AI 代理均强制执行 **“五步协作法”**：

1.  **提问 (Question)**：澄清模糊需求，拒绝猜测。
2.  **方案 (Options)**：提供 2-3 个技术选型并对比优劣。
3.  **决策 (Decision)**：由用户（人类开发者）拍板路径。
4.  **草案 (Draft)**：展示代码片段、API 契约或逻辑流。
5.  **批准 (Approval)**：获得授权后方可执行写入。

---

## 👥 代理架构 (Agent Roster)

### Tier 1: Directors (愿景与风险)
- **Product Director**: 业务逻辑守门员，负责 `docs/specs/PRD.md`。
- **Technical Architect**: 技术大脑，负责 `docs/arch/ADR.md` 与 API 契约。
- **Delivery Manager**: 节奏大师，负责 `production/backlog.md` 与风险预警。

### Tier 2: Leads (执行与质量)
- **Lead Developer**: 实现标准制定者，负责核心重构与 `src/` 质量。
- **QA Lead**: 质量守门员，负责 `docs/reviews/RELEASE-CHECKLIST.md`。

### Tier 3: Specialists (纵深领域)
- **Frontend/Backend Developer**: 具体端实现。
- **Security/DevOps Engineer**: 安全审计与自动化部署。

---

## 🛠️ 核心指令 (Slash Commands)

| 指令 | 名称 | 负责代理 | 产出物 |
| :--- | :--- | :--- | :--- |
| **`/start`** | **智能引导** | `Delivery Manager` | 引导至新项目或维护路径 |
| **`/onboard`** | **团队入职** | `Delivery Manager` | 向成员介绍协作协议与规范 |
| `/discovery` | **需求发现** | `Product Director` | `docs/specs/PRD.md` |
| `/setup-stack` | **技术初始化**| `Architect` | 初始化目录结构与依赖文件 |
| `/arch-design` | **架构设计** | `Architect` | `docs/arch/ADR.md` |
| `/sprint-kickoff`| **任务拆解** | `Delivery Manager` | `production/backlog.md` |
| `/review` | **技术评审** | `Architect` | 代码审计报告 |
| `/gate-check` | **质量审计** | `QA Lead` | `RELEASE-CHECKLIST.md` |

---

## 🤝 团队协作与分发 (Team Collaboration)

USDS 设计之初就考虑了团队共享。以下是三种推荐的使用方式：

### 1. 黄金模板模式 (推荐)
将本项目作为 Git 仓库模板。团队成员在创建新项目时选择 **"Use this template"**，即可自动继承所有的代理、技能和规则配置。

### 2. 存量项目注入
对于已有的项目，可以通过运行脚本一键注入 USDS 核心组件：
```powershell
# 运行项目中的安装脚本 (Windows)
powershell -ExecutionPolicy Bypass -File ./scripts/install-usds.ps1
```

### 3. 规范同步
**务必将 `.claude/` 目录提交至 Git 仓库**。
这样团队中的所有成员（只要安装了 Claude Code）都能在本地会话中拥有完全一致的代理行为和审查规则，实现“工程标准即配置”。

### 4. 新人上手
新成员加入项目后，请引导其运行 **`/onboard`** 指令。AI 代理将亲自讲解“五步协作法”，确保团队协作丝滑顺畅。

---

## 🚀 快速开始

1. **环境**: 安装 [Claude Code](https://docs.anthropic.com/en/docs/claude-code)。
2. **初始化**: 在项目根目录运行 `claude`。
3. **第一步**: 输入 **`/start`** 或 **`/onboard`**。

---
*Powered by Universal Software Studio — 像经营工作室一样编写代码。*
