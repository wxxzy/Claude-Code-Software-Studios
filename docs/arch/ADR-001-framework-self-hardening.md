# ADR-001: USDS 框架自身加固 — JSON 解析分层、文档门控阻断化、测试/CI 基础

- **日期**: 2026-08-18
- **决策者**: `technical-architect`
- **状态**: 已批准

---

## 1. 上下文 (Context)

我们要解决什么技术挑战？背景是什么？

`/project-scan`（2026-08-18 刷新）确认框架存在三类自托管缺陷：

1. **TD-001** — 5 个 hook/statusline 以 `jq` 可用与否分支解析 stdin JSON，无 `jq` 时回退 `grep` 正则，对含转义引号/特殊字符的字段会静默解析错误。Windows 原生环境通常不带 `jq`，提交验证在那里是不可靠的。
2. **TD-002** — `validate-commit.sh` 对 PRD/ADR 缺失强制章节仅打印警告（`exit 0`），与 `doc-standards.md` "必须包含" 的措辞不匹配；且检查作用域是 `docs/arch/*.md` 全体，对 SYSTEM-MAP.md / TECH-DEBT.md 等非 ADR 文档持续产生误报。若直接升级为阻断，误报会变成误拦截。
3. **TD-003** — hooks 与安装脚本零自动化测试、无 CI，框架守卫自身的正确性无法回归验证。

## 2. 决策详情 (Decision)

三项配套决策（对应 D1/D2/D3）：

**D1 — JSON 解析分层降级 + 共享库**：新建 `.claude/hooks/lib/json.sh`，提供 `usds_json_str <json> <dotpath> [<dotpath>...]`，按 `jq` → `python3`/`python` → 正则（仅末段 key）顺序解析，返回首个非空字符串值。`validate-commit.sh`、`validate-push.sh`、`validate-assets.sh`、`log-agent.sh` 统一改用该库。`.claude/statusline.sh` **排除在外**（每次渲染多次 spawn python 的延迟不可接受，维持 jq→grep 现状）。`session-start.sh` 在 jq 与 python 双缺时输出降级提示（TD-005/T-014 的离线提示一并落实）。

**D2 — PRD/ADR 章节检查阻断化 + 作用域收窄**：缺强制章节从警告升级为 `exit 2` 阻断；作用域从 `docs/specs/*.md`、`docs/arch/*.md` 收窄为 `docs/specs/PRD*.md`、`docs/arch/ADR*.md`（兼容 `/discovery` 产出的 `PRD.md` 与 `PRD-<n>.md`、`ADR-<n>.md` 命名约定）。JSON 非法检查（已阻断）与 TODO 风格警告（非阻断）不变。`doc-standards.md` 补注强制章节由 hook 阻断式执行。

**D3 — bats 测试套件 + GitHub Actions CI**：`tests/hooks/` 为核心 hooks（validate-commit、detect-gaps、validate-assets、lib/json）建立 bats 用例，临时 git 仓库 fixture + 绝对路径调脚本 + stdin 喂 JSON；CI 在 ubuntu 跑 bats（阻断门）+ shellcheck（首期仅报告）+ 双安装脚本 dry-run，windows 跑 git-bash smoke。`session-start.sh` 的网络路径测试（T-010）显式延后。

## 3. 权衡 (Consequences)

- **优点 (Pros)**: 无 `jq` 的 Windows 环境获得 python 级解析精度；文档门控从"纸上必须"变为"提交即拦"；框架守卫获得回归能力；`lib/` 随 `.claude/hooks` 目录整体被安装清单携带，安装脚本零改动。
- **缺点 (Cons)**: 无 jq 且无 python 的环境仍降级为正则（精度不升级，行为与现状一致）；阻断化改变贡献者体验（不完整 PRD/ADR 无法提交）；CI 引入对 npm `bats` 包（或 git clone 安装）的外部依赖；python 层每次 hook 调用多一次 spawn（PreToolUse 场景延迟预算可容忍）。

## 4. 替代方案 (Alternatives Considered)

- **强制要求安装 jq（不做分层）**：拒绝 — 框架的定位是"部署进任意项目"，不能对宿主环境加硬依赖；且 `settings.json` 白名单已含 python，说明 python 是既定假设。
- **JSON 解析全部迁到 Python 独立脚本**：拒绝 — 无 python 的纯 jq 环境反而劣化，且多一个分发单元；分层降级覆盖面最宽。
- **保持警告不阻断（维持 TD-002 现状）**：拒绝 — backlog T-003 已决策升级，且 Doc-First 协议要求守卫与规范措辞一致；误拦风险已通过文件名作用域收窄消除并有回归用例锁定。
- **引入 shellcheck 作为阻断门**：首期拒绝 — 存量脚本告警未知，先报告观察一个迭代再决定是否升格。

## 5. 实施指南 (Implementation)

`usds_json_str` 契约：

```bash
# source 方式（不依赖 CWD）：
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/json.sh"

# 用法：返回首个非空字符串值；无匹配时输出空
COMMAND=$(usds_json_str "$INPUT" .tool_input.command)
FILE_PATH=$(usds_json_str "$INPUT" .tool_input.file_path .tool_input.path)
```

- jq 层：`(.a // .b) // empty`
- python 层：读 stdin JSON，按路径序深取，打印首个字符串值
- 正则层：沿用现行 `grep -oE '"key"...'` 模式，仅取末段 key；不支持转义引号与数字值（注释中写明）

测试与 CI 落点：`tests/README.md`、`tests/hooks/*.bats`、`.github/workflows/ci.yml`。

关联任务：`production/backlog.md` T-001~T-003、T-005~T-009、T-011、T-014、T-017；债务台账见 `docs/arch/TECH-DEBT.md`。
