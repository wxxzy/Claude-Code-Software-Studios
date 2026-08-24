# ADR-003: 闭环工程（跨会话记忆环 + 交付物一致性门禁）

- **日期**: 2026-08-20
- **决策者**: `technical-architect`
- **状态**: 已批准

---

## 1. 上下文 (Context)

我们要解决什么技术挑战？背景是什么？

USDS 已有 12 类循环（提交门禁、推送门禁、资产告警、会话诊断、会话归档、压缩转储、模式反馈、升级清理、框架自测……），但审计发现其中一半是**开环**——写了数据，却没有任何机制回读并反馈进下一步决策：

1. **跨会话记忆环断裂**：`session-stop.sh`（Stop 钩子）认真归档每次会话（commits、未提交变更、状态文件）到 `production/session-logs/session-log.md`；`session-start.sh`（SessionStart 钩子）却完全不读它。同理，`docs/debt-ledger.md` 记录的未还债务，在下次会话开始时不会被提醒——账本变成"写完就忘"的黑洞。
2. **交付物一致性无机器校验**：本次会话手动发现并清理了 v2.1 命名空间迁移后的孤儿文档（`UNIVERSAL-STUDIO.md` 等 9 个文件）；随后又发现 `CLAUDE.md`/7 个 agent 分别引用 `.claude/docs/skills-reference.md`、`.claude/docs/coordination-rules.md`，但两个安装器的文件清单里都没有它们——**任何真实用户装完框架后，agent 会指向一个不存在的文件**，且这个漂移本可以在 CI 里被立刻抓住，却潜伏到人工审计才现形。

两处的共同病因是同一件事：**存在但未闭合的反馈回路**。数据被写下（session-log、debt-ledger）或被产出（安装器清单、引用关系），但没有下一环节回读并使用它，循环停在半路。

## 2. 决策详情 (Decision)

**D1 — 会话记忆回读**：`session-start.sh` 在现有单行输出基础上，追加一次性回读：

- 读取 `production/session-logs/session-log.md` 的**最后一个** `## Session End:` 或 `## Archived Session State:` 段落，提炼为一行摘要（时间戳 + 是否有未提交变更），不存在则静默跳过；
- 读取 `docs/debt-ledger.md`（如存在）的"未还清"条目数，非零则提示件数，不解析内容避免输出膨胀；
- 两者均遵循现有钩子的降级哲学：文件不存在/解析失败 = 静默跳过，绝不因缺文件报错阻塞会话启动。

输出预算：追加内容控制在一行以内并入现有 `[USDS ...]` 单行输出，不新增多行 dump（多行 dump 是 `pre-compact.sh` 的职责，边界不重叠）。

**D2 — 交付物一致性门禁**：新增 `tests/hooks/consistency.bats`，把本次人工审计做的三类检查变成永久 CI 门禁：

1. **安装清单双向一致**：`install-usds.sh` 的 `CORE_FILES`/`VIBE_FILES`/`STUDIO_FILES` 与 `install-usds.ps1` 的 `$CoreFiles`/`$VibeFiles`/`$StudioFiles` 逐项相等（防止两个安装器分叉）；且清单中每一项在仓库中真实存在（防止"清单写了源却删了"）。
2. **仓库应装文件全覆盖**：`.claude/skills/*`、`.claude/agents/*.md`、`.claude/rules/*.md` 全部出现在某个清单里；`.claude/docs/**` 除显式允许名单（`.claude/docs/directory-structure.md` 由 core 清单单列覆盖即可，本次审计确认全部纳入）外全部覆盖——新增技能/agent/规则/文档忘记加入安装器清单，从"装完静默漏装"变成 CI 立即失败。
3. **技能速查表与技能目录一致**：`skills-reference.md` 提到的 22 个命令与 `.claude/skills/*` 目录名双向匹配；`CLAUDE.md` 的 v2.1 重命名对照表的 20 个旧名与两个安装器的 `RENAMED_AWAY_SKILLS`/`RenamedAwaySkills` 清单一致（`namespacing.bats` 已锁安装器双方一致，本次补上与 `CLAUDE.md` 表格的第三方校验）。

**D3 — 本次审计的即时修复**（作为本 ADR 的落地验证，而非留待下次漂移）：

- 补装 `.claude/docs/skills-reference.md`、`.claude/docs/coordination-rules.md`（7 个 agent 依赖）、`.claude/docs/CLAUDE-local-template.md`、`.claude/docs/settings-local-template.md`（README 承诺"模板：`.claude/docs/*-template.*`"但未装）到两个安装器的 Core 清单；
- 删除 `.claude/docs/templates/collaborative-protocols/`（3 个文件）——已被 `coordination-rules.md` 取代、全仓无引用的孤儿模板。

## 3. 权衡 (Consequences)

- **优点 (Pros)**：跨会话记忆环闭合后，agent 在新会话开场即知晓上次未完成的工作与未还债务，减少"每次会话从零开始"的重复劳动与遗忘；一致性门禁把本次依赖人工审计才发现的三个真实 bug（漂移文档、缺失依赖文件）变成机器化、每次 push 自动跑的检查，防止同类问题再次潜伏到人工审计才现形。
- **缺点 (Cons)**：session-start 输出增加解析逻辑，虽仍单行但复杂度上升，需要额外的降级路径测试；一致性门禁的"允许清单"（哪些文档故意不装，如 `CLAUDE-local-template.md` 本次决定改为装、但类似未来新增的仅供仓库自身使用的文档仍需人工判断）会随框架演进需要维护，本身也是一种需要盯着的状态而非一次性解决。

## 4. 替代方案 (Alternatives Considered)

- **不做跨会话回读，只在文档里强调"每次开工先看 session-log"**：拒绝——约定不是循环，人会忘、AI 也会忘（本次审计正是发现"约定但无机制"的一类开环）；机制成本低（一个 hook 函数）远小于持续遗忘的代价。
- **一致性检查放进 `install-usds.sh` 自检而非独立 bats**：不足——安装器自检只在安装那一刻跑，而漂移发生在安装器之外的日常编辑（改了 agent 引用、加了技能却忘改清单），必须在 CI 每次 push 时跑，脚本自检覆盖不到编辑期的漂移。
- **把债务/日志摘要做成强制阻断（未读则拒绝继续）**：拒绝——过度侵入，且 SessionStart 钩子的既有哲学是"提示不阻断"（对比 PreToolUse 才是阻断层），保持这一分层清晰比多一层强制更重要。

## 5. 实施指南 (Implementation)

- `session-start.sh`：新增两段只读、静默降级的回读逻辑，追加进现有单行输出；`tests/hooks/session-start-recap.bats` 覆盖有/无 session-log、有/无 debt-ledger 的组合。
- `tests/hooks/consistency.bats`：D2 的三类双向 diff；复用 `namespacing.bats` 已验证的 `sed` 提取手法。
- 安装器：补齐 D3 的 4 个文件到 Core 清单（sh + ps1 同步）；删除孤儿模板目录。
- 校验：bats 全绿、两安装器 `--dry-run` 四 profile 无回归、CI 4 job 全绿。
