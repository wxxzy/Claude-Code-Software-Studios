# 项目 Backlog: Universal Software Studio (USDS)

- **版本**: 2.0.0
- **负责人**: `delivery-manager`
- **生成时间**: 2026-06-16 · **最近刷新**: 2026-08-18（框架自身加固冲刺销账，见 `docs/arch/ADR-001`）
- **来源文档**:
  - `docs/arch/SYSTEM-MAP.md` — 系统架构快照
  - `docs/arch/TECH-DEBT.md` — 技术债登记册
  - `docs/arch/ADR-001-framework-self-hardening.md` — 本次冲刺决策记录

---

## 1. 活跃冲刺 (Active Sprint)

> 2026-08-18 冲刺：框架自身加固（JSON 解析分层、文档门控阻断化、测试/CI、目录缺口、文档销账）。原高优任务全部完成，无新激活任务。

（空 — 待 `/studio-sprint-kickoff` 拉取下一轮）

---

## 2. 待办池 (Backlog)

### Gap 检测改进 (对应 TD-004)

- [ ] **T-012**: 更新 `detect-gaps.sh`，增加宽松模式文件检测（如 `docs/specs/*.md` 任意文件）
  - 负责人: `backend-developer` | 优先级: 低 | 预估: 1.5h
- [ ] **T-013**: 在 Gap 警告信息中增加命名规范说明，区分"无文件"与"命名不符合规范"两种状态
  - 负责人: `backend-developer` | 优先级: 低 | 预估: 0.5h

### 日志轮转 (对应 TD-006)

- [ ] **T-015**: 在 `session-stop.sh` 中实现日志轮转逻辑：当 `session-log.md` 超过 500 行时，将历史记录归档到带时间戳文件
  - 负责人: `delivery-manager` | 优先级: 低 | 预估: 2h
- [ ] **T-016**: 主日志文件仅保留最近 50 条会话记录，定期运行清理任务
  - 负责人: `delivery-manager` | 优先级: 低 | 预估: 1h

### 测试补全 (对应 TD-003 剩余项)

- [ ] **T-010**: 为 `session-start.sh` 编写集成测试，验证版本检查和离线降级行为
  - 负责人: `lead-developer` | 优先级: 低 | 预估: 2h
  - 备注: 有意延后 —— 需 mock 网络层（curl 超时/失败分支），投入产出比待评估
- [ ] **T-019**: 评估将 shellcheck 从"仅报告"升格为 CI 阻断门（观察一个迭代后决策）
  - 负责人: `devops-engineer` | 优先级: 低 | 预估: 1h

### 文档与规范完善

- [ ] **T-018**: 为 `/studio-sprint-kickoff` 技能在 `.claude/docs/templates/` 中补充更完整的 BACKLOG 示例（含任务依赖字段）
  - 负责人: `delivery-manager` | 优先级: 低 | 预估: 1h

---

## 3. 已完成 (Done)

- [x] **T-000**: 运行 `/studio-project-scan` 完成系统架构快照（2026-06-16）
- [x] **T-001**: 在 `session-start.sh` 中检测解析器状态并输出明确提示（2026-08-18，随 ADR-001/D1 实现：jq/python 双缺时显示 `⚠️ json:regex (install jq)`，仅有 python 时显示 `json:python`）
- [x] **T-002**: Hook JSON 解析迁移至分层方案（2026-08-18，ADR-001/D1：`lib/json.sh` jq→python→正则，python 带可执行探测；比原计划"全迁 Python"覆盖面更宽）
- [x] **T-003**: `validate-commit.sh` PRD/ADR 章节缺失检查升级为阻断 `exit 2`（2026-08-18，ADR-001/D2；同步收窄作用域至 `PRD*`/`ADR*` 文件名，消除 SYSTEM-MAP 误报）
- [x] **T-004**: 安装脚本预创建 `docs/specs/`、`docs/reviews/` 等目录及 `.gitkeep`（2026-08-18，sh+ps1 对称实现，dry-run 可预览，不入 manifest）
- [x] **T-005**: `validate-assets.sh` 缺失问题（早期提交已解决；本次重构解析段并新增 bats 覆盖，销账）
- [x] **T-006**: README 中 `/reverse-document` 引用（早期提交已移除；本次全仓 grep 复核确认，销账）
- [x] **T-007**: 引入 bats 测试框架与 `tests/` 目录（2026-08-18，`tests/hooks/` 28 用例 + `tests/README.md`）
- [x] **T-008**: `validate-commit.sh` bats 单元测试（12 用例：正常/阻断/作用域回归）
- [x] **T-009**: `detect-gaps.sh` bats 单元测试（5 用例：基础行为；宽松模式断言随 T-012 补充）
- [x] **T-011**: GitHub Actions CI（2026-08-18：ubuntu bats 阻断门 + shellcheck 报告 + 4 profile 安装 dry-run + Windows 冒烟）
- [x] **T-014**: `session-start.sh` 区分超时与网络错误，输出 `(offline: version check skipped)`
- [x] **T-017**: `doc-standards.md` 明确强制章节由 hook 阻断式校验（含文件名作用域说明）
- [x] **T-020** *(新增)*: `install-usds.ps1` 转 UTF-8 with BOM，修复 Windows PowerShell 5.1 解析失败（TD-008）
- [x] **T-021** *(新增)*: 补回全部 `.sh` 脚本的 git 可执行位（Windows 提交丢失 +x 导致 ubuntu CI 直接执行 hooks 报 Permission denied；detect-gaps bats 用例直接执行 hook 文件，此后持续守护该位）

---

## 4. 任务依赖关系 (Dependencies)

```
T-004 (目录初始化) ──► T-012 (Gap 宽松模式)
T-010 (session-start 测试) — 独立，待 mock 方案
T-015 ──► T-016 (日志轮转两步)
```

---

## 5. 任务状态说明 (Status Guide)

| 状态 | 说明 |
| :--- | :--- |
| 待办 (To Do) | 尚未开始 |
| 进行中 (In Progress) | 正在开发 |
| 评审中 (Review) | 代码已写完，等待架构师通过 `/studio-review` 审查 |
| 完成 (Done) | 已合并并通过 `/studio-gate-check` 验证 |

---

*本文档由 `/studio-sprint-kickoff` 技能生成，由 `delivery-manager` 代理维护。任务完成后请更新对应状态，并在发布前运行 `/studio-gate-check`。*
