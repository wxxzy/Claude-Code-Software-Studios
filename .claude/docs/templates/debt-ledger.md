# Debt Ledger — <项目名>

<!-- USDS 技术债账本 -->
<!-- 由 /debt-log 维护 -->

**项目名**: <name>
**上次更新**: <YYYY-MM-DD>

---

## 使用说明

- 每条债务分配唯一 ID: `DEBT-YYYYMMDD-NNN`
- 严重度: `critical` / `high` / `medium` / `low`
- 利率: `flat`（不会变糟）/ `linear`（线性）/ `compound`（复利）
- **Hard Limits 违规（密钥、SQL 拼接、未验证输入）不是债务，是 bug，必须立刻修**

---

## 健康度指标（自动更新）

- 总条目: <n>
- critical: <n> · high: <n> · medium: <n> · low: <n>
- 平均债龄: <n> 天
- 最老债务: <ID>（<产生日期>）
- 近 30 天净增: <n>

---

## 未还清

### DEBT-YYYYMMDD-001 [严重度|利率]

- 描述: <一句话>
- 位置: <文件:行号 或 模块>
- 严重度: <level>
- 利率: <rate>
- 代价: <不还会怎样>
- 建议还款: <立即 / 下个 sprint / 晋升前 / 无期限>
- 产生日期: <YYYY-MM-DD>
- 状态: 未还清

---

<!-- 追加更多未还条目 -->

---

## 已还清

### DEBT-YYYYMMDD-000 [原严重度|原利率]

- 描述: <原描述>
- 位置: <原位置>
- 产生日期: <原日期>
- 还清日期: <YYYY-MM-DD>
- 债龄: <n> 天
- 还款方式: <PR/commit/描述>
- 触发: <手动 / /review / /gate-check / /graduate>

---

<!-- 追加更多已还条目 -->
