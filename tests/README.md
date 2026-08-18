# USDS Framework Test Suite

针对框架自身守卫（`.claude/hooks/`）的回归测试，防止修改引入行为退化。

## 运行方式

```bash
# 安装 bats（任选其一）
npm i -g bats          # npm 分发版
git clone https://github.com/bats-core/bats-core.git /tmp/bats && /tmp/bats/bin/bats --version

# 运行全部测试（在仓库根目录）
bats tests/

# 运行单个文件
bats tests/hooks/validate-commit.bats
```

## 设计约定

- **临时仓库 fixture**：每个用例在 `mktemp -d` 中构建微型 git 仓库，用完即删，绝不触碰真实仓库
- **绝对路径调用**：hooks 通过 `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)` 定位自身与 `lib/`，
  因此测试可从任意 CWD 用绝对路径调用
- **stdin 喂 JSON**：模拟 Claude Code 的 hook 输入协议
- **exit code 断言**：`0` = 放行，`2` = 阻断（stderr 提示给模型）
- **分层解析测试**（`lib-json.bats`）：jq / python / 正则 三层各自独立验证；
  正则层通过符号链接白名单目录隔离 PATH —— 不支持符号链接的环境（部分 git-bash）自动 `skip`

## 覆盖范围

| 文件 | 被测对象 | 关键行为 |
|---|---|---|
| `hooks/validate-commit.bats` | `validate-commit.sh` | PRD/ADR 强制章节**阻断**（ADR-001/D2）、`PRD*`/`ADR*` 文件名作用域、SYSTEM-MAP 等非 ADR 豁免、JSON 合法性阻断、TODO 风格警告不阻断 |
| `hooks/detect-gaps.bats` | `detect-gaps.sh` | 无 backlog / 无 ADR 缺口报告、阈值以下静默 |
| `hooks/validate-assets.bats` | `validate-assets.sh` | 硬编码密钥告警、`.env` 写入告警、良性文件静默 |
| `hooks/lib-json.bats` | `lib/json.sh` | 三层解析各自正确性、转义引号、多路径回退、缺失键返回空 |

## 未覆盖（有意延后）

- `session-start.sh` / `session-stop.sh` / `pre-compact.sh` 的网络与时间路径（T-010，见 `production/backlog.md`）
- `statusline.sh`（jq→grep 两层，性能敏感路径，行为由渲染肉眼验证）
- 安装脚本端到端（CI 中以 `--dry-run` 冒烟替代）

## CI

`.github/workflows/ci.yml` 在每次 push/PR 时运行本套件（ubuntu 阻断门）+ shellcheck（首期仅报告）+ 双安装脚本 dry-run + windows git-bash 冒烟。
