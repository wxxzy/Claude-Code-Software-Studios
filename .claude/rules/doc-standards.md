# 文档完整性标准 (Documentation Integrity)

适用于 `docs/**` 目录。

## 1. 强制模板 (Mandatory Templates)
- **PRD**: 必须包含 业务目标、用户故事 和 验收标准 章节。
- **ADR**: 必须包含 背景、决策、权衡 和 替代方案 章节。

## 2. 状态管理 (Status)
- 所有文档顶端必须标明当前状态：`Draft` (草稿)、`Proposed` (提议)、`Approved` (已批准)、`Deprecated` (已废弃)。
- `Approved` 状态的文档在被废弃前，不应被随意修改，所有修改必须基于新的讨论。

## 3. 关联性 (Traceability)
- **ADR 关联**: 架构决策文档必须引用其来源的 PRD（如果有的话）。
- **任务关联**: `production/backlog.md` 中的任务应尽可能链接到对应的 PRD/ADR 文档路径。

## 4. 可读性 (Readability)
- **清晰性**: 严禁在 PRD 中出现模糊的词汇，如“尽可能快”、“大量用户”。必须使用具体的数值或范围描述。
- **时序图**: 复杂的业务逻辑或接口交互必须配备 Mermaid 图表或文本描述的时序。
