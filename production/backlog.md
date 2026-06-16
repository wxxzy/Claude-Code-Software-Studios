# 项目 Backlog: Universal Software Studio (USDS)

- **版本**: 1.0.0
- **负责人**: `delivery-manager`
- **生成时间**: 2026-06-16
- **来源文档**:
  - `docs/arch/SYSTEM-MAP.md` — 系统架构快照
  - `docs/arch/TECH-DEBT.md` — 技术债登记册

---

## 1. 活跃冲刺 (Active Sprint)

> 本冲刺聚焦于消除高优先级技术债、修复已知缺口，并为框架建立基础自动化测试保障。

| ID | 任务描述 | 负责人 | 优先级 | 状态 | 预估工时 | 关联文档 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| T-001 | 在 `session-start.sh` 中检测 `jq` 安装状态并输出明确提示（对应 TD-001） | `devops-engineer` | 高 | 待办 | 1h | `TECH-DEBT.md#TD-001` |
| T-002 | 将 Hook JSON 解析从 `jq`/`grep` 混合模式迁移至 Python 脚本（对应 TD-001） | `devops-engineer` | 高 | 待办 | 3h | `TECH-DEBT.md#TD-001` |
| T-003 | 将 `validate-commit.sh` 的 PRD/ADR 章节缺失检查从警告升级为阻断错误 `exit 2`（对应 TD-002） | `lead-developer` | 高 | 待办 | 2h | `TECH-DEBT.md#TD-002` |
| T-004 | 在安装脚本中预创建 `docs/specs/`、`docs/reviews/` 目录及 `.gitkeep` 占位文件（对应 TD-007） | `devops-engineer` | 高 | 待办 | 1h | `TECH-DEBT.md#TD-007` |
| T-005 | 创建缺失的 `validate-assets.sh` 占位脚本，或从 `settings.json` 中移除该 Hook 注册（已知缺口） | `devops-engineer` | 高 | 待办 | 0.5h | `TECH-DEBT.md#已知缺失` |
| T-006 | 从 `README.md` 移除已不存在的 `/reverse-document` 命令引用，或实现对应的技能文件（已知缺口） | `lead-developer` | 高 | 待办 | 1h | `TECH-DEBT.md#已知缺失` |

---

## 2. 待办池 (Backlog)

### 测试基础设施 (对应 TD-003)

- [ ] **T-007**: 引入 [bats-core](https://github.com/bats-core/bats-core) 作为 Bash 脚本测试框架，创建 `tests/` 目录结构
  - 负责人: `lead-developer` + `devops-engineer` | 优先级: 中 | 预估: 2h
- [ ] **T-008**: 为 `validate-commit.sh` 编写 bats 单元测试，覆盖正常路径和错误路径
  - 负责人: `lead-developer` | 优先级: 中 | 预估: 3h
- [ ] **T-009**: 为 `detect-gaps.sh` 编写 bats 单元测试，覆盖文件命名宽松模式检查
  - 负责人: `lead-developer` | 优先级: 中 | 预估: 2h
- [ ] **T-010**: 为 `session-start.sh` 编写 bats 集成测试，验证版本检查和离线降级行为
  - 负责人: `lead-developer` | 优先级: 中 | 预估: 2h
- [ ] **T-011**: 搭建 GitHub Actions CI 流水线，在 PR 合并前自动运行 bats 测试套件
  - 负责人: `devops-engineer` | 优先级: 中 | 预估: 3h

### Gap 检测改进 (对应 TD-004)

- [ ] **T-012**: 更新 `detect-gaps.sh`，增加宽松模式文件检测（如 `docs/specs/*.md` 任意文件）
  - 负责人: `backend-developer` | 优先级: 低 | 预估: 1.5h
- [ ] **T-013**: 在 Gap 警告信息中增加命名规范说明，区分"无文件"与"命名不符合规范"两种状态
  - 负责人: `backend-developer` | 优先级: 低 | 预估: 0.5h

### 版本检查改进 (对应 TD-005)

- [ ] **T-014**: 在 `session-start.sh` 中区分网络超时与网络错误，错误时输出 `(offline: version check skipped)` 提示
  - 负责人: `devops-engineer` | 优先级: 低 | 预估: 1h

### 日志轮转 (对应 TD-006)

- [ ] **T-015**: 在 `session-stop.sh` 中实现日志轮转逻辑：当 `session-log.md` 超过 500 行时，将历史记录归档到带时间戳文件
  - 负责人: `delivery-manager` | 优先级: 低 | 预估: 2h
- [ ] **T-016**: 主日志文件仅保留最近 50 条会话记录，定期运行清理任务
  - 负责人: `delivery-manager` | 优先级: 低 | 预估: 1h

### 文档与规范完善

- [ ] **T-017**: 在 `doc-standards.md` 中明确区分 PRD/ADR 中的"硬性章节"（阻断提交）与"推荐章节"（警告）
  - 负责人: `product-director` | 优先级: 中 | 预估: 1h
- [ ] **T-018**: 为 `/sprint-kickoff` 技能在 `.claude/docs/templates/` 中补充更完整的 BACKLOG 示例（含任务依赖字段）
  - 负责人: `delivery-manager` | 优先级: 低 | 预估: 1h

---

## 3. 已完成 (Done)

- [x] **T-000**: 运行 `/project-scan` 完成系统架构快照，生成 `docs/arch/SYSTEM-MAP.md` 和 `docs/arch/TECH-DEBT.md`

---

## 4. 任务依赖关系 (Dependencies)

```
T-001 (jq 检测) ──► T-002 (Python 迁移)
T-004 (目录初始化) ──► T-012 (Gap 宽松模式)
T-007 (bats 引入) ──► T-008, T-009, T-010
T-008 + T-009 + T-010 ──► T-011 (CI 流水线)
T-003 (阻断错误) ──► T-017 (章节区分文档)
```

---

## 5. 任务状态说明 (Status Guide)

| 状态 | 说明 |
| :--- | :--- |
| 待办 (To Do) | 尚未开始 |
| 进行中 (In Progress) | 正在开发 |
| 评审中 (Review) | 代码已写完，等待架构师通过 `/review` 审查 |
| 完成 (Done) | 已合并并通过 `/gate-check` 验证 |

---

*本文档由 `/sprint-kickoff` 技能生成，由 `delivery-manager` 代理维护。任务完成后请更新对应状态，并在发布前运行 `/gate-check`。*
