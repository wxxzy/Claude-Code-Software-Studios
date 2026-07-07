# Vibe Mode 宽松规则 (Vibe Mode Relaxed Rules)

适用于 `sandbox/**` 目录以及 `.usds-mode` 声明为 `vibe` 的项目。

## 0. 立场声明 (Stance)

Vibe Mode 的目标是**让用户在 15 分钟内看到能跑的东西**。
在这个模式下，"能跑" > "优雅"，"快速验证" > "工程正确"。
但**安全底线不可退让**。

---

## 1. 允许的"违规" (Allowed Trade-offs)

在 `sandbox/**` 下，以下 Studio Mode 规则被**主动豁免**：

- ✅ 允许硬编码 Magic Numbers、URL、配置项
- ✅ 允许单文件超过 300 行
- ✅ 允许函数超过 30 行
- ✅ 允许省略 JSDoc / Docstring
- ✅ 允许跳过自动化测试
- ✅ 允许不写 ADR、不写 PRD（用 `lite-spec.md` 替代）
- ✅ 允许直接使用 mock 数据代替真实数据源
- ✅ 允许在同一文件内混合前后端逻辑（原型阶段）

---

## 2. 仍然禁止 (Hard Limits)

以下红线在任何模式下都不可跨越：

- ❌ **严禁提交机密信息**：API Key、密码、Token、私钥、证书
- ❌ **严禁沉默捕获异常**：至少 `console.log` / `print` / 结构化日志
- ❌ **严禁直接拼接 SQL 字符串**：必须使用 ORM 或参数化查询
- ❌ **严禁未验证的用户输入直达数据库或文件系统**
- ❌ **严禁 `eval` / `exec` 未经过滤的用户输入**
- ❌ **严禁在生产环境直接跑 sandbox/ 代码**

---

## 3. 目录约定 (Directory Convention)

```
sandbox/
├── <name>/                  # 一个原型一个目录
│   ├── README.md            # 必需：如何跑起来 + 已知限制
│   ├── main.<ext>           # 入口文件
│   └── ...                  # 其他文件随意组织
└── archive/                 # 已淘汰的原型
    └── <name>-<date>/
```

- `README.md` 是 `sandbox/<name>/` 目录唯一**强制文件**
- 每个原型目录独立，禁止跨目录 import

---

## 4. 生命周期 (Lifecycle)

- **创建**：由 `/prototype` 技能触发
- **迭代**：由 Explorer 主导，允许频繁重写
- **校准**：每 3-5 轮迭代，触发 `/vibe-check`
- **晋升**：经用户确认后，通过 `/graduate` 迁移到 `src/`
- **归档**：30 天未动的原型，提醒归档到 `sandbox/archive/`

---

## 5. 与其他规则的关系

| 冲突场景 | 优先级 |
|---|---|
| Vibe Mode 允许 vs Hard Limits 禁止 | Hard Limits 优先 |
| Vibe Mode 允许 vs `ai-generated-code.md` | AI 规约优先（安全性） |
| Vibe Mode 允许 vs `global-standards.md` 风格规则 | Vibe Mode 豁免 |
| Vibe Mode 允许 vs `backend-api.md` 安全规则 | 后者优先 |

**总原则**：安全性规则永远优先，风格性规则可豁免。

---

## 6. 晋升门槛 (Graduation Gate)

`sandbox/` 代码进入 `src/` 前，必须通过 `/graduate` 补齐：

- [ ] 追认型 ADR（`docs/arch/ADR-<n>.md`）
- [ ] 测试覆盖（符合 `test-conventions.md`）
- [ ] 命名规范（符合 `global-standards.md`）
- [ ] 结构化错误处理（符合 `backend-api.md`）
- [ ] 消除所有硬编码
- [ ] JSDoc / Docstring 补全
