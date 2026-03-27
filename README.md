# Universal Software Studio (USDS)

<p align="center">
  <strong>基于 Claude Code 的工业级通用软件开发工作室框架</strong>
  <br />
  10 个核心代理 • 10 大工作流指令 • 5 步协作协议 • 纯净的通用软件工程实践
</p>

---

## 🌟 核心设计理念：协作而非自主 (Collaboration, not Autonomy)

所有的 AI 代理均强制执行 **“五步协作法”**：
**提问 (Question) -> 方案 (Options) -> 决策 (Decision) -> 草案 (Draft) -> 批准 (Approval)**

---

## 🚀 快速开始与操作指令 (Operational Guide)

在项目根目录启动 `claude` 后，请根据您的场景直接运行以下指令：

### 1. 新成员入职 (First Time Only)
如果您是第一次加入使用 USDS 的团队，请先运行引导：
```bash
/onboard
```

### 2. 场景 A：从零开始新项目 (Greenfield)
按照以下顺序执行指令，完成从想法到任务的转化：
```bash
/start                       # 启动引导并选择“新项目”
/discovery "我的想法是..."     # 生成需求文档 (PRD)
/setup-stack                 # 选择技术栈并生成项目骨架
/arch-design                 # 定义 API 与数据库模型 (ADR)
/sprint-kickoff              # 将架构拆解为具体任务 (Backlog)
```

### 3. 场景 B：维护/接手已有项目 (Brownfield)
如果您需要分析一个现有的代码库，请执行：
```bash
/start                       # 启动引导并选择“维护项目”
/project-scan                # 自动分析项目架构与技术债
/reverse-document            # 为核心代码反向生成 PRD 文档
```

### 4. 场景 C：开发、评审与交付 (Daily Workflow)
完成具体代码编写后的质量闭环：
```bash
/review                      # 让架构师评审您的代码实现
/gate-check                  # 交付前最后的质量审计 (Checklist)
/summarize-arch              # 定期将 ADR 汇总至架构快照
```

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

## 🤝 团队分发与同步 (Team Sync)

### 1. 一键安装 (Zero-Clone Install)
如果您想在已有项目中快速启用 USDS，请在项目根目录下根据您的操作系统执行以下命令：

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/main/scripts/install-usds.ps1 | iex
```

**macOS / Linux (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/main/scripts/install-usds.sh | bash
```

### 2. 将 USDS 提交至 Git (关键)
为了让全员共享这些技能，**必须**提交 `.claude` 目录。请确保您的 `.gitignore` **没有**排除这些文件：
```bash
git add .claude/agents/ .claude/skills/ .claude/rules/ .claude/hooks/
git add CLAUDE.md README.md UNIVERSAL-STUDIO.md
git commit -m "chore: 部署 Universal Software Studio (USDS) 基础设施"
git push
```

---

## 📜 底层规则 (Engineering Standards)

USDS 自动根据文件路径执行以下校验规则：
- `src/**`: 遵循 `.claude/rules/global-standards.md`
- `tests/**`: 遵循 `.claude/rules/test-conventions.md`
- `docs/**`: 遵循 `.claude/rules/doc-standards.md`

---
*Powered by Universal Software Studio — 像经营工作室一样编写代码。*
