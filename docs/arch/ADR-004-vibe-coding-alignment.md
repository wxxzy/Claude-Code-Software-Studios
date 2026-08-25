# ADR-004: 对齐 2026 Vibe Coding 最佳实践（AGENTS.md、检查点纪律、意图校准机制化、原型时效扫描）

- **日期**: 2026-08-20
- **决策者**: `technical-architect`
- **状态**: 已批准

---

## 1. 上下文 (Context)

我们要解决什么技术挑战？背景是什么？

对照 2026 年 vibe coding 的行业共识（AGENTS.md 事实标准、spec-driven development、生产事故复盘、MSR 学术研究）审计 USDS，发现三类差距：

1. **跨工具入口缺失**：AGENTS.md 已成为 OpenAI/Google/Anthropic/Cursor 等共同推动的事实标准，60,000+ 开源项目采用；[对照实验](https://www.emergentmind.com/topics/agents-md-files)（10 仓库/124 PR）显示存在 AGENTS.md 使运行时间中位数 -28.6%、输出 token -16.6%（p<0.05）。USDS 只有 `CLAUDE.md`，Codex/Cursor/Gemini CLI 等工具的用户拿不到框架的双模态上下文，等于把成本量化过的收益拱手让掉。
2. **约定无机制兜底**（loop engineering 审计遗留问题的延伸）：`vibe-mode.md` 写了"每 3-5 轮迭代必须 `/vibe-check` 校准意图"、"30 天未动的原型提醒归档"，但没有任何计数或扫描代码检查这两条是否被遵守——纯靠 agent 自觉。据 MSR '26 对大量 Cursor 仓库的研究，vibe coding 带来短暂速度增益但持久复杂度上升，意图漂移正是复杂度失控的直接成因，约定不落地为机制则形同没有。
3. **检查点纪律缺失**：[ReversingLabs 等生产事故复盘](https://www.reversinglabs.com/blog/vibe-coding-lessons)与行业共识反复强调的核心技法是"能跑即 commit，跑偏即 reset"——用版本控制本身做安全网，而不是靠对话反复纠偏。`vibe-mode.md` 和 `vibe-prototype`/SKILL.md 此前完全没有提交节奏的要求：原型允许"频繁重写"，但没有检查点意味着重写失败时上一个可用状态已经不可恢复。

## 2. 决策详情 (Decision)

**D1 — AGENTS.md 作为跨工具入口**：新增根目录 `AGENTS.md`，内容与 `CLAUDE.md` 的模式声明/协议/Path Rules 对等，但裁剪掉 Claude Code 专属的技能自动加载表述（改为指引非 Claude Code 工具"直接依据 Path Rules 手动执行"）。两文件互相在文件头标注同步关系，靠人工纪律保持一致（详见 §4 替代方案，说明为何不做自动生成）。两个安装器 Core 清单加入 `AGENTS.md`。

**D2 — 检查点纪律成文并联动技能**：`vibe-mode.md` 新增 §7"检查点纪律"——能跑的每次迭代立即 `git commit`（`wip(sandbox/<name>): ...` 格式），预授权免逐次确认（Vibe Mode 与 Studio Mode 提交纪律的刻意区别），跑偏时优先 `git log`/`reset` 回退而非对话纠偏。`vibe-prototype/SKILL.md` 工作流插入对应步骤。

**D3 — `/vibe-check` 轮次计数机制化**：新增 `SubagentStart` 钩子 `vibe-check-nudge.sh`——`explorer`（`/vibe-prototype` 主导代理）每次调用计数 +1，`explainer`（`/vibe-check` 主导代理）调用时清零；计数达到 4 及之后每 2 轮触发一次提示。仅在 `.usds-mode` 为 `vibe`/`hybrid` 时生效；studio-only 项目不受影响（explorer/explainer 不会被调用）。计数器存于 `production/session-state/.vibe-check-counter`（已加入 `.gitignore`），任意解析失败静默归零，不阻塞。

**D4 — sandbox 过期扫描机制化**：`detect-gaps.sh` 新增 Check 5——扫描 `sandbox/*/`（跳过 `archive/`）内是否存在 30 天内修改过的文件，无则计入"stale"提示归档到 `/vibe-check` 或 `sandbox/archive/`。复用现有"有缺口才输出，无缺口静默"的降级哲学。

## 3. 权衡 (Consequences)

- **优点 (Pros)**：AGENTS.md 让非 Claude Code 用户零成本获得双模态上下文，且有实验数据支撑其价值；检查点纪律把"频繁重写"从风险行为变成安全行为（随时可回退）；意图校准从纯自觉变成有计数托底，降低"忘了做 vibe-check 导致漂移失控"的概率；过期扫描让"30 天"这条此前完全没人执行的约定第一次真正生效。
- **缺点 (Cons)**：`CLAUDE.md`/`AGENTS.md` 双文件同步依赖人工纪律，未来若两文件实质分叉（例如只在其中一个补充新规则）会重新制造漂移——这与我们刚刚在 ADR-003 里解决的问题同构，属于已知的、需要持续盯着的技术债，暂不建立自动生成/校验机制（见 §4）；计数器基于代理名而非语义判断，若用户绕过技能直接手写 sandbox 代码（不经过 `/vibe-prototype`），计数不会增长，属于设计上的已知局限（技能未被调用，钩子拿不到信号）。

## 4. 替代方案 (Alternatives Considered)

- **AGENTS.md 由 CLAUDE.md 自动生成（构建脚本/模板引擎）**：拒绝——引入构建步骤和模板系统的复杂度，对一个"改动频率低、内容量小"的文档不成比例；consistency.bats 已经校验双方存在且版本号一致，逐字同步交给 PR review 人工把关足够，过度自动化反而增加维护面。
- **检查点提交做成阻断式钩子（PostToolUse 强制在 sandbox 写入后自动 commit）**：拒绝——自动提交绕过了 agent 对"这次改动是否值得作为检查点"的判断（例如中间半成品状态），且与 Claude Code 的工具调用生命周期耦合过紧，一旦提交失败（冲突、hook 报错）会打断正常写入流程；保持"技能工作流指导 agent 主动提交"的柔性方案。
- **vibe-check 计数用真实迭代轮次（对话轮数）而非代理调用次数**：不足——对话轮数包含大量非原型相关的交流（校准讨论本身、用户提问），语义上不对应"迭代"；`explorer`/`explainer` 的代理调用是本框架里"一次原型迭代"/"一次校准"的唯一结构化信号，更准确。
- **sandbox 过期判定用目录 mtime 而非文件内容 mtime**：拒绝——`git checkout`/`git clone` 等操作会重写目录本身的 mtime 但不代表内容有更新；改用目录内文件的 `find -mtime` 更贴近"最后一次真实编辑时间"。

## 5. 实施指南 (Implementation)

- 新增 `AGENTS.md`；`CLAUDE.md` 头部加同步标注；两安装器 Core 清单加入 `AGENTS.md`。
- `.claude/rules/vibe-mode.md` §7；`.claude/skills/vibe-prototype/SKILL.md` 工作流步骤 7。
- 新增 `.claude/hooks/vibe-check-nudge.sh`；`.claude/settings.json` SubagentStart 数组追加注册；`.gitignore` 加计数器文件。
- `.claude/hooks/detect-gaps.sh` Check 5。
- 校验：`tests/hooks/vibe-check-nudge.bats`、`tests/hooks/detect-gaps.bats` 扩展 stale-sandbox 用例、consistency.bats 扩展 AGENTS.md 覆盖检查、bats 全绿、两安装器四 profile dry-run 回归、CI 全绿。
