# Sandbox — Vibe Mode 原型工作区

此目录用于 Vibe Mode 的快速原型开发。

## ⚠️ 规则

- 此目录下的代码遵循 `.claude/rules/vibe-mode.md`（宽松规则）
- **允许**：硬编码、单文件塞满、跳过测试、无 ADR
- **仍禁止**：密钥泄露、SQL 拼接、沉默捕获异常、未锁版本依赖

## 📁 结构

```
sandbox/
├── README.md            ← 本文件
├── <project-name>/      ← 一个原型一个目录
│   ├── README.md        ← 必需：如何跑 + 已知限制
│   ├── main.<ext>
│   └── ...
└── archive/             ← 已淘汰或已晋升的原型
    └── <name>-<date>/
```

## 🚀 常用流程

- 创建原型：`/prototype`
- 校准意图：`/vibe-check`
- 晋升到 src：`/graduate`
- 归档：手动移动到 `archive/`

## 🔒 边界

- `src/**` 代码**禁止**依赖 `sandbox/**`
- `sandbox/**` 代码**允许**引用 `src/**`（原型可基于生产代码）
- 30 天未动的原型建议归档到 `archive/`
