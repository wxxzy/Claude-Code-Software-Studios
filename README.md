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

在项目根目录启动 `claude` 后，直接运行以下指令：

### 1. 第一次使用 (Onboarding)
```bash
/onboard                     # 学习协作协议与规范 (推荐首选)
```

### 2. 场景 A：从零开始新项目 (Greenfield)
```bash
/start                       # 启动引导并选择“新项目”
/discovery "我的想法是..."     # 生成需求文档 (PRD)
/setup-stack                 # 选择技术栈并生成项目骨架
/arch-design                 # 定义 API 与数据库模型 (ADR)
/sprint-kickoff              # 将架构拆解为具体任务 (Backlog)
```

### 3. 场景 B：维护已有项目 (Brownfield)
```bash
/start                       # 启动引导并选择“维护项目”
/project-scan                # 自动分析项目架构与技术债
/reverse-document            # 为核心代码反向生成说明文档
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
- **Product Director**: 业务逻辑需求，负责 `docs/specs/PRD.md`。
- **Technical Architect**: 技术架构，负责 `docs/arch/ADR.md` 与 API 契约。
- **Delivery Manager**: 进度，负责 `production/backlog.md` 与风险预警。

### Tier 2: Leads (执行与质量)
- **Lead Developer**: 实现标准制定者，负责核心重构与 `src/` 质量。
- **QA Lead**: 质量审查，负责 `docs/reviews/RELEASE-CHECKLIST.md`。

### Tier 3: Specialists (纵深领域)
- **Frontend/Backend Developer**: 具体端实现。
- **Security/DevOps Engineer**: 安全审计与自动化部署。
---

## 🛠️ 核心指令 (Slash Commands)

| 指令 | 名称 | 负责代理 | 产出物 |
| :--- | :--- | :--- | :--- |
| **`/start`** | **智能引导** | `Delivery Manager` | 引导至正确路径 |
| **`/onboard`** | **团队入职** | `Delivery Manager` | 协议演练与规范介绍 |
| `/discovery` | **需求发现** | `Product Director` | `docs/specs/PRD.md` |
| `/project-scan`| **项目扫描** | `Architect` | `docs/arch/SYSTEM-MAP.md` |
| `/setup-stack` | **技术初始化**| `Architect` | 项目骨架与依赖文件 |
| `/arch-design` | **架构设计** | `Architect` | `docs/arch/ADR.md` |
| `/summarize-arch`| **架构总结** | `Architect` | 压缩 ADR 至最终态文档 |
| `/sprint-kickoff`| **任务拆解** | `Delivery Manager` | `production/backlog.md` |
| `/review` | **技术评审** | `Architect` | 深度代码审计报告 |
| `/gate-check` | **质量审计** | `QA Lead` | `RELEASE-CHECKLIST.md` |

---

## 🤝 团队同步与个人定制

### 1. 一键安装
- **Windows (PS):** `irm https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/scripts/install-usds.ps1 | iex`
- **macOS/Linux:** `curl -fsSL https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/scripts/install-usds.sh | bash`

### 2. 个人偏好设置 (本地覆盖)
您可以创建以下文件自定义本地行为，这些文件已被 `.gitignore` 自动忽略：
- **`CLAUDE.local.md`**: 自定义个人快捷指令或偏好模型。
- **`.claude/settings.local.json`**: 自定义本地文件权限 (Allow/Deny)。
*模板参考: `.claude/docs/*-template.*`*

### 3. 提交至 Git
**必须**提交 `.claude/` 目录以共享技能：
```bash
git add .claude/ CLAUDE.md UNIVERSAL-STUDIO.md README.md
git commit -m "chore: 部署 USDS 基础设施"
```

---
*Powered by Universal Software Studio — 像经营工作室一样编写代码。*
