# Universal Software Studio (USDS) v2

<p align="center">
  <strong>基于 Claude Code 的双模态软件开发工作室框架</strong>
  <br />
  Vibe Mode（快速探索）× Studio Mode（严肃工程） · 按需安装 · 一键切换
</p>

---

## ✨ v2 核心变化：双模态架构

USDS v2 不再假设所有项目都是严肃工程。同一套框架现在同时服务两种场景：

| 模式 | 场景 | 主要目录 | 主导规则 | 起手技能 |
|---|---|---|---|---|
| **Vibe Mode** | 探索、原型、个人玩具、周末项目 | `sandbox/**` | `vibe-mode.md`（宽松） | `/vibe-start` |
| **Studio Mode** | 生产、团队、长期维护、客户交付 | `src/`, `docs/`, `tests/` | `global-standards.md`（严格） | `/discovery` |
| **Hybrid Mode** | 一仓库两种共存 | 两者共存 | 按路径分派 | 按任务选 |

模式由项目根目录的 `.usds-mode` 文件决定，可通过 `/mode-switch` 随时切换。
两种模式之间通过 `/graduate` 单向晋升（Vibe → Studio）。

**共同底线**：无论哪种模式，密钥泄露、SQL 拼接、未验证输入、未锁版本依赖始终是 Hard Limits。

---

## 🚀 一键安装（按需）

v2 支持**分层安装**：不再一次性塞全家桶。选择你实际需要的组合。

### Windows (PowerShell)

```powershell
# 交互式安装（推荐首次使用）
irm https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/scripts/install-usds.ps1 | iex

# 或指定 profile
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/scripts/install-usds.ps1))) -Profile vibe
```

### macOS / Linux

```bash
# 交互式安装
curl -fsSL https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/scripts/install-usds.sh | bash

# 或指定 profile
curl -fsSL https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/scripts/install-usds.sh | bash -s -- --profile vibe
```

### Profile 说明

| Profile | 安装内容 | 适用人群 |
|---|---|---|
| `minimal` | 核心规则 + 基础技能（`/start`, `/onboard`, `/mode-switch`, `/update`, `/cost-report`, `/debt-log`, `/micro-adr`） | 想自己组装的高手 |
| `vibe` | minimal + Vibe Pack（7 skill + 4 agent + 2 template） | 原型玩家、个人项目 |
| `studio` | minimal + Studio Pack（8 skill + 8 agent + 4 template） | 严肃团队、生产项目 |
| `full` | minimal + Vibe + Studio | Hybrid 混合项目 |

### 常用参数

```bash
--profile <name>   # 直接指定 profile
--dry-run          # 预览会装什么，不动手
--force            # 覆盖已存在文件（默认询问）
--no-samples       # 不装示范 docs/
--uninstall        # 根据 .usds-manifest 卸载
--ref <branch>     # 指定分支/标签（默认 master）
```

### ⚠️ 远程管道安装的交互限制

当你用 `curl ... | bash` 或 `irm ... | iex` 时，**stdin 已被下载流占用**，脚本无法读取键盘输入。这意味着：

- ❌ 不能弹出交互式菜单让你选 profile
- ❌ 不能询问是否覆盖已存在文件
- ❌ 不能询问是否安装示范 docs/

**推荐做法（二选一）**：

**方案 A：显式传参绕过交互**（快速）

```bash
# macOS / Linux — 用 -s -- 把参数传给管道里的 bash
curl -fsSL https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/scripts/install-usds.sh | bash -s -- --profile vibe --force

# Windows — 用 scriptblock 包装
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/scripts/install-usds.ps1))) -Profile vibe -Force
```

**方案 B：先下载再执行**（推荐，可审计）

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/scripts/install-usds.sh -o install-usds.sh
less install-usds.sh          # 先看一眼再跑（可选）
bash install-usds.sh          # 完整交互式菜单可用

# Windows
irm https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/scripts/install-usds.ps1 -OutFile install-usds.ps1
.\install-usds.ps1            # 完整交互式菜单可用
```

**CI / 无 tty 环境**：必须使用方案 A，并显式指定 `--profile` 和 `--force`，否则脚本会在等待输入时挂起。

### 安全保证

- ✋ **绝不静默覆盖** `README.md` — 用户已有 README 时保留
- ✋ **绝不静默覆盖** `docs/` — 用户已有 docs 目录时跳过示范
- ✋ **每次覆盖前询问** — 除非显式 `--force`
- ✅ **可完全卸载** — 通过 `.usds-manifest` 追踪安装项
- ✅ **可预演** — `--dry-run` 只显示计划

---

## 🎯 快速开始

安装后启动 `claude`，根据你选的模式使用对应技能：

### 🌱 Vibe Mode 全链路

```bash
/vibe-start "我想做一个能记账的小工具"   # 3-5 轮对话捕获意图 → lite-spec.md
/prototype                             # 15 分钟内出可跑 demo → sandbox/<name>/
/vibe-check                            # 每 3-5 轮迭代校准意图 → intent-log.md
/taste-review                          # 审美/体验维度评审 → docs/reviews/
/explain-back                          # 隔几天回来先跑这个恢复上下文
/branch-vibe                           # 想尝试完全不同的方向 → 平行 worktree
/graduate                              # 原型稳定后晋升到 src/
```

### 🏢 Studio Mode 全链路

```bash
/onboard                    # 学习协作协议
/discovery "项目想法"        # 生成 PRD → docs/specs/PRD.md
/setup-stack                # 技术选型与骨架初始化
/arch-design                # 定义 API 与数据模型 → docs/arch/ADR.md
/sprint-kickoff             # 拆解 Backlog → production/backlog.md
# 编码...
/review                     # 技术评审
/gate-check                 # 发布质量审计
```

### 🔀 Hybrid Mode

自由组合两套技能，用 `/mode-switch` 切换默认场景。

---

## 👥 代理架构

### Vibe Mode 角色（v2 新增）
- **Explorer** — 负责 `sandbox/**` 快速原型
- **Stylist** — 视觉/交互氛围、审美选型
- **Prompt Refiner** — 模糊意图 → 可执行 spec
- **Explainer** — 用非技术语言汇报状态

### 观测性角色（跨模式）
- **Cost Accountant** — 追踪 token / 时间 / API 成本
- **Debt Auditor** — 追踪技术债，让妥协可见

### Studio Mode 角色
- **Product Director** — 负责 `docs/specs/`
- **Technical Architect** — 负责 `docs/arch/`
- **Lead Developer** — 负责 `src/`, `tests/`
- **Delivery Manager** — 负责 `production/`
- **QA Lead** — 负责 `docs/reviews/`
- **Frontend/Backend Developer, Security/DevOps Engineer** — 纵深领域

完整定义见 `.claude/agents/`。

---

## 🛠️ 技能全表

| 技能 | 模式 | 主导角色 | 产出物 |
|---|---|---|---|
| `/start` | 共享 | Delivery Manager | 引导到正确入口 |
| `/onboard` | 共享 | Delivery Manager | 协议演练 |
| `/mode-switch` | 共享 | Delivery Manager | `.usds-mode` |
| `/update` | 共享 | Delivery Manager | 同步框架更新 |
| `/cost-report` | 共享 | Cost Accountant | `docs/cost-ledger.md` |
| `/debt-log` | 共享 | Debt Auditor | `docs/debt-ledger.md` |
| `/micro-adr` | 共享 | Technical Architect | `docs/arch/micro-adr.md` |
| `/vibe-start` | Vibe | Prompt Refiner | `docs/specs/lite-spec.md` |
| `/prototype` | Vibe | Explorer | `sandbox/<name>/` |
| `/vibe-check` | Vibe | Explainer | `docs/specs/intent-log.md` |
| `/taste-review` | Vibe | Stylist | `docs/reviews/taste-<date>.md` |
| `/branch-vibe` | Vibe | Explorer | 新 worktree + 独立 sandbox |
| `/explain-back` | Vibe | Explainer | 一次性汇报（不落盘） |
| `/graduate` | Vibe→Studio | Delivery Manager | 迁移到 `src/` |
| `/discovery` | Studio | Product Director | `docs/specs/PRD.md` |
| `/project-scan` | Studio | Architect | `docs/arch/SYSTEM-MAP.md` |
| `/setup-stack` | Studio | Architect | 项目骨架 |
| `/arch-design` | Studio | Architect | `docs/arch/ADR.md` |
| `/summarize-arch` | Studio | Architect | 架构快照 |
| `/sprint-kickoff` | Studio | Delivery Manager | `production/backlog.md` |
| `/review` | Studio | Architect | 代码审计报告 |
| `/gate-check` | Studio | QA Lead | 发布 Checklist |

---

## 📂 目录约定

```
<project-root>/
├── .usds-mode              ← 模式声明（由 install/mode-switch 生成）
├── .usds-manifest          ← 安装清单（用于卸载）
├── CLAUDE.md               ← Claude Code 常驻上下文
├── .claude/
│   ├── rules/              ← 规则文件（按 profile 装载）
│   ├── skills/             ← 技能定义（按 profile 装载）
│   ├── agents/             ← 角色定义（按 profile 装载）
│   └── docs/templates/     ← 文档模板
├── docs/
│   ├── specs/              ← PRD / lite-spec / intent-log
│   ├── arch/               ← ADR
│   └── reviews/            ← QA 审计
├── src/                    ← Studio 生产代码
├── tests/                  ← Studio 测试
├── sandbox/                ← Vibe 原型工作区
│   ├── <name>/
│   └── archive/            ← 归档的原型
└── production/
    └── backlog.md
```

---

## 🔒 核心设计原则

1. **协作而非自主 (Collaboration, not Autonomy)** — 五步协作法：提问 → 方案 → 决策 → 草案 → 批准
2. **双模态并存 (Dual Mode)** — Vibe 与 Studio 共享底层安全约束，风格规则按目录分派
3. **按需装载 (On-Demand)** — 用户不为不用的技能付上下文代价
4. **反 AI 特有病灶** — `ai-generated-code.md` 专门约束幻觉、过度抽象、上下文丢失

---

## 🤝 个人定制与团队同步

### 本地覆盖（不入 git）

以下文件被 `.gitignore` 忽略，可自定义本地行为：

- `CLAUDE.local.md` — 个人偏好、快捷指令
- `.claude/settings.local.json` — 本地文件权限

模板：`.claude/docs/*-template.*`

### 团队同步（入 git）

```bash
git add .claude/ CLAUDE.md README.md .usds-mode
git commit -m "chore: 部署 USDS v2"
```

---

## 🔧 维护操作

```bash
# 检查更新
/update

# 切换模式
/mode-switch

# 卸载
./scripts/install-usds.sh --uninstall     # macOS/Linux
.\scripts\install-usds.ps1 -Uninstall     # Windows
```

---

## 📖 更多文档

- Vibe Mode 规则：`.claude/rules/vibe-mode.md`
- AI 代码规约：`.claude/rules/ai-generated-code.md`
- Sandbox 工作区：`sandbox/README.md`
- 模式示例：`.usds-mode.example`

---

*Powered by Universal Software Studio v2 — 严肃时严肃，自由时自由。*
