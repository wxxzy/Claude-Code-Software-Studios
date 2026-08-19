# ADR-002: 技能命名空间前缀与描述标准化

- **日期**: 2026-08-18
- **决策者**: `technical-architect`
- **状态**: 已批准

---

## 1. 上下文 (Context)

我们要解决什么技术挑战？背景是什么？

USDS v2 的 22 个技能安装后（尤其 `full`/`hybrid` profile，或用户同时装有其他框架技能时），Claude Code 斜杠菜单存在三个叠加的可发现性问题：

1. **字母序打散归属**：Claude Code（至本 ADR 时点）按字母序列出技能，无官方排序/分组/优先级字段。`discovery`（Studio）夹在 `debt-log`（共享）与 `explain-back`（Vibe）之间，三条工作流的技能交错混排，用户需靠记忆定位。
2. **通用名碰撞**：`start`、`review`、`update`、`onboard` 是高频通用词，与其他框架的技能名冲突或易混。
3. **描述格式不统一**：菜单中名字旁的描述是唯一就地文档，但 22 个 SKILL.md 描述风格不一，读不出模式归属、动作与产出。

## 2. 决策详情 (Decision)

**D1 — 三段命名空间前缀**：技能名成为排序键兼命名空间——

| 前缀 | 分组 | 技能（重命名后） |
|---|---|---|
| `usds-` | 跨模式共享运维（7） | `usds-start` `usds-onboard` `usds-mode-switch` `usds-update` `usds-cost-report` `usds-debt-log` `usds-micro-adr` |
| `vibe-` | Vibe Mode 工作流（7） | `vibe-start` `vibe-prototype` `vibe-check` `vibe-taste-review` `vibe-branch` `vibe-explain-back` `vibe-graduate` |
| `studio-` | Studio Mode 工作流（8） | `studio-discovery` `studio-project-scan` `studio-setup-stack` `studio-arch-design` `studio-summarize-arch` `studio-sprint-kickoff` `studio-review` `studio-gate-check` |

实际重命名 20 个（`vibe-start`/`vibe-check` 已合规）。字母序天然形成三段聚类，且为未来跨平台适配（Codex prompts、Cursor commands）预留同名命名空间。

**D2 — 描述标准化**：所有 SKILL.md 的 `description` 统一为——

```
【<模式>】<一句话动作> → <产出物>。当用户说"<触发词>"时使用。
```

后半句触发词服务于模型的技能自选：用户用自然语言描述意图时，模型依据 description 直接调用对应技能，形成菜单之外的第二条发现路径。

**D3 — 版本与迁移**：版本 2.0.0 → 2.1.0；CLAUDE.md 附一版新旧名对照表。严格 semver 下命令重命名属破坏性变更应升主版本，此处选择 minor：行为零变更、对照表内置于常驻上下文、且 v2 发布不久用户基数尚小。

## 3. 权衡 (Consequences)

- **优点 (Pros)**: 菜单从混排变三段聚类；通用名碰撞彻底消除；描述就地可读并强化自然语言触发；跨版本稳定（不依赖平台特性）；为跨平台命名空间铺路。
- **缺点 (Cons)**: 命令变长（输入成本由斜杠菜单前缀自动补全缓解）；老用户肌肉记忆失效（对照表缓解一个版本周期）；一次性同步 20 个目录重命名与全仓引用，迁移成本集中。

## 4. 替代方案 (Alternatives Considered)

- **依赖平台排序/分组字段**：拒绝 —— 至本 ADR 时点 Claude Code 无此能力，且会锁死平台。
- **仅做描述标准化不改名**：不足 —— 可读性改善但混排与碰撞仍在；且 `vibe-*` 半约定已存在，贯彻成本低于另起炉灶。
- **模式感知裁剪（--prune-inactive 物理移除非当前模式技能）**：另案可选 —— 对 hybrid 用户与频繁切换者偏侵入，不作为默认，留作 installer 未来选项。
- **网关聚合（折叠为 /vibe /studio /ops 三个巨型技能内嵌二级菜单）**：拒绝 —— 专家多一跳；单个 SKILL.md 膨胀推高装载上下文；五步协作的门控与输出预算被压进单文件，维护性劣化；且 CLAUDE.md 技能全表已在上下文中，模型可直接响应"我想晋升原型"类自然语言，无需专职索引技能。

## 5. 实施指南 (Implementation)

- 重命名：`git mv .claude/skills/<old> .claude/skills/<new>`，frontmatter `name:` 同步改为目录名
- 引用同步面：`CLAUDE.md`、`README.md`、skills 互引、`.claude/agents/*.md`、`.claude/docs/*.md`、`scripts/install-usds.{sh,ps1}` 文件清单、`docs/arch/SYSTEM-MAP.md`、`production/backlog.md`
- 校验：安装器 `--dry-run`（清单与目录名一致，防"源不存在跳过"静默漏装）、bats 套件、自举提交过 `validate-commit.sh` 门控、CI 全绿

### 升级迁移（v2.0 → v2.1）

安装器只增不删，旧项目升级后 20 个 v2.0 旧命令目录会残留，导致斜杠菜单新旧命令并存（42 条）。
修复：双安装器内置 `RENAMED_AWAY_SKILLS` 清单（即本文 D1 的 20 个旧名），安装新文件后存在即删——
均为 USDS 保留名，绝不涉及用户自装技能；`--dry-run` 会预览将清理的目录；`/usds-update` 技能
同步注明该行为。回归保障：bats 用例校验新旧名单一致性与"仓库内不存在旧名技能目录"。
