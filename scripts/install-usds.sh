#!/usr/bin/env bash
# ============================================================================
# USDS (Universal Software Studio) v2 安装脚本
# 仓库: https://github.com/wxxzy/Claude-Code-Software-Studios
#
# 用法:
#   ./install-usds.sh [--profile <minimal|vibe|studio|full>]
#                     [--dry-run] [--force] [--no-samples]
#                     [--uninstall] [--ref <branch|tag>]
#
# 远程安装:
#   curl -fsSL <raw-url>/install-usds.sh | bash
#   curl -fsSL <raw-url>/install-usds.sh | bash -s -- --profile vibe --dry-run
# ============================================================================

set -euo pipefail

# ---------- 常量 ----------
REPO_URL="https://github.com/wxxzy/Claude-Code-Software-Studios"
DEFAULT_REF="master"
MANIFEST_FILE=".usds-manifest"
MODE_FILE=".usds-mode"

# 颜色
C_CYAN='\033[0;36m'; C_GRAY='\033[0;90m'; C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'; C_RED='\033[0;31m'; C_BOLD='\033[1m'; C_OFF='\033[0m'

# ---------- 参数解析 ----------
PROFILE=""
DRY_RUN=false
FORCE=false
NO_SAMPLES=false
UNINSTALL=false
REF="$DEFAULT_REF"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)      PROFILE="$2"; shift 2 ;;
    --profile=*)    PROFILE="${1#*=}"; shift ;;
    --dry-run)      DRY_RUN=true; shift ;;
    --force)        FORCE=true; shift ;;
    --no-samples)   NO_SAMPLES=true; shift ;;
    --uninstall)    UNINSTALL=true; shift ;;
    --ref)          REF="$2"; shift 2 ;;
    -h|--help)
      cat <<EOF
USDS v2 安装脚本

Profile:
  minimal   仅核心（规则 + 基础技能）
  vibe      核心 + Vibe Mode 全套
  studio    核心 + Studio Mode 全套
  full      全装（vibe + studio）

Flags:
  --dry-run       预览而不执行
  --force         覆盖已存在文件（默认询问）
  --no-samples    不安装示范 docs/
  --uninstall     根据 .usds-manifest 卸载
  --ref <name>    指定分支/标签（默认 master）

示例:
  ./install-usds.sh --profile vibe
  ./install-usds.sh --profile studio --dry-run
  curl -fsSL ...install-usds.sh | bash -s -- --profile minimal
EOF
      exit 0
      ;;
    *) echo -e "${C_RED}未知参数: $1${C_OFF}"; exit 1 ;;
  esac
done

# ---------- 卸载分支 ----------
uninstall() {
  if [[ ! -f "$MANIFEST_FILE" ]]; then
    echo -e "${C_RED}✗ 找不到 $MANIFEST_FILE，无法卸载${C_OFF}"; exit 1
  fi
  echo -e "${C_YELLOW}⚠ 将删除以下由 USDS 安装的文件:${C_OFF}"
  cat "$MANIFEST_FILE"
  read -rp "确认继续？[y/N] " ans
  [[ "$ans" != "y" && "$ans" != "Y" ]] && { echo "已取消"; exit 0; }
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == "#"* ]] && continue
    [[ -e "$line" ]] && rm -rf "$line" && echo -e "${C_GRAY}removed: $line${C_OFF}"
  done < "$MANIFEST_FILE"
  rm -f "$MANIFEST_FILE" "$MODE_FILE"
  echo -e "${C_GREEN}✓ 卸载完成${C_OFF}"
  exit 0
}
$UNINSTALL && uninstall

# ---------- Profile 选择 ----------
if [[ -z "$PROFILE" ]]; then
  echo -e "${C_BOLD}${C_CYAN}Universal Software Studio (USDS) v2 安装${C_OFF}"
  echo ""
  echo "请选择安装 Profile:"
  echo "  1) ${C_BOLD}minimal${C_OFF} - 仅核心规则和基础技能"
  echo "  2) ${C_BOLD}vibe${C_OFF}    - Vibe Mode（探索/原型/个人项目）"
  echo "  3) ${C_BOLD}studio${C_OFF}  - Studio Mode（生产/团队/严肃项目）"
  echo "  4) ${C_BOLD}full${C_OFF}    - 全装（hybrid，兼容旧行为）"
  read -rp "选择 [1-4，默认 3]: " choice
  case "${choice:-3}" in
    1) PROFILE="minimal" ;;
    2) PROFILE="vibe" ;;
    3) PROFILE="studio" ;;
    4) PROFILE="full" ;;
    *) echo -e "${C_RED}无效选择${C_OFF}"; exit 1 ;;
  esac
fi

case "$PROFILE" in
  minimal|vibe|studio|full) ;;
  *) echo -e "${C_RED}未知 profile: $PROFILE${C_OFF}"; exit 1 ;;
esac

# ---------- 分层文件清单 ----------
# Core（所有 profile 都装）
CORE_FILES=(
  "CLAUDE.md"
  ".usds-mode.example"
  ".claude/rules/global-standards.md"
  ".claude/rules/ai-generated-code.md"
  ".claude/rules/doc-standards.md"
  ".claude/skills/start"
  ".claude/skills/onboard"
  ".claude/skills/update"
  ".claude/skills/mode-switch"
  ".claude/agents/delivery-manager.md"
  ".claude/docs/quick-start.md"
  ".claude/docs/directory-structure.md"
)

# Vibe Pack
VIBE_FILES=(
  ".claude/rules/vibe-mode.md"
  ".claude/skills/vibe-start"
  ".claude/skills/prototype"
  ".claude/skills/vibe-check"
  ".claude/skills/graduate"
  ".claude/agents/explorer.md"
  ".claude/agents/stylist.md"
  ".claude/agents/prompt-refiner.md"
  ".claude/agents/explainer.md"
  ".claude/docs/templates/lite-spec.md"
  ".claude/docs/templates/intent-log.md"
  "sandbox/README.md"
)

# Studio Pack
STUDIO_FILES=(
  ".claude/rules/backend-api.md"
  ".claude/rules/test-conventions.md"
  ".claude/skills/discovery"
  ".claude/skills/setup-stack"
  ".claude/skills/arch-design"
  ".claude/skills/summarize-arch"
  ".claude/skills/sprint-kickoff"
  ".claude/skills/project-scan"
  ".claude/skills/review"
  ".claude/skills/gate-check"
  ".claude/agents/product-director.md"
  ".claude/agents/technical-architect.md"
  ".claude/agents/lead-developer.md"
  ".claude/agents/qa-lead.md"
  ".claude/agents/frontend-developer.md"
  ".claude/agents/backend-developer.md"
  ".claude/agents/devops-engineer.md"
  ".claude/agents/security-engineer.md"
  ".claude/docs/templates/PRD.md"
  ".claude/docs/templates/ADR.md"
  ".claude/docs/templates/BACKLOG.md"
  ".claude/docs/templates/RELEASE-CHECKLIST.md"
)

# 组装本次要装的清单
FILES_TO_INSTALL=("${CORE_FILES[@]}")
case "$PROFILE" in
  vibe)   FILES_TO_INSTALL+=("${VIBE_FILES[@]}") ;;
  studio) FILES_TO_INSTALL+=("${STUDIO_FILES[@]}") ;;
  full)   FILES_TO_INSTALL+=("${VIBE_FILES[@]}" "${STUDIO_FILES[@]}") ;;
esac

# ---------- 预览 ----------
echo ""
echo -e "${C_BOLD}安装计划:${C_OFF}"
echo -e "  Profile:     ${C_CYAN}$PROFILE${C_OFF}"
echo -e "  Ref:         $REF"
echo -e "  Dry-run:     $DRY_RUN"
echo -e "  Force:       $FORCE"
echo -e "  文件数量:    ${#FILES_TO_INSTALL[@]}"
echo ""

if $DRY_RUN; then
  echo -e "${C_YELLOW}[DRY-RUN] 以下文件将被安装:${C_OFF}"
  printf '  %s\n' "${FILES_TO_INSTALL[@]}"
  echo ""
  echo -e "${C_GRAY}未做任何修改。移除 --dry-run 后正式执行。${C_OFF}"
  exit 0
fi

# ---------- 下载 ----------
ZIP_URL="$REPO_URL/archive/refs/heads/$REF.zip"
TEMP_ZIP="$(mktemp -t usds-XXXXX.zip)"
TEMP_DIR="$(mktemp -d -t usds-XXXXX)"
trap 'rm -rf "$TEMP_ZIP" "$TEMP_DIR"' EXIT

echo -e "${C_GRAY}📥 下载中: $ZIP_URL${C_OFF}"
curl -fsSL "$ZIP_URL" -o "$TEMP_ZIP" || {
  echo -e "${C_RED}✗ 下载失败${C_OFF}"; exit 1
}

echo -e "${C_GRAY}📦 解压...${C_OFF}"
unzip -q -o "$TEMP_ZIP" -d "$TEMP_DIR"

# GitHub zip 解压后的目录名: <repo>-<ref>
SOURCE_ROOT="$(find "$TEMP_DIR" -maxdepth 1 -type d -name 'Claude-Code-Software-Studios-*' | head -n1)"
if [[ -z "$SOURCE_ROOT" ]]; then
  echo -e "${C_RED}✗ 解压后找不到源目录${C_OFF}"; exit 1
fi

# ---------- 安装 ----------
INSTALLED=()
SKIPPED=()

install_item() {
  local rel="$1"
  local src="$SOURCE_ROOT/$rel"
  local dst="$rel"

  if [[ ! -e "$src" ]]; then
    echo -e "${C_GRAY}  ⊘ 源不存在，跳过: $rel${C_OFF}"
    return
  fi

  if [[ -e "$dst" ]]; then
    if ! $FORCE; then
      read -rp "  已存在 $rel，覆盖？[y/N] " ans </dev/tty
      if [[ "$ans" != "y" && "$ans" != "Y" ]]; then
        SKIPPED+=("$rel"); echo -e "${C_GRAY}  ⊘ 跳过: $rel${C_OFF}"; return
      fi
    fi
  fi

  mkdir -p "$(dirname "$dst")"
  cp -R "$src" "$dst"
  INSTALLED+=("$rel")
  echo -e "${C_GREEN}  ✓ $rel${C_OFF}"
}

echo ""
echo -e "${C_BOLD}开始安装...${C_OFF}"
for item in "${FILES_TO_INSTALL[@]}"; do
  install_item "$item"
done

# ---------- 示范 docs (可选) ----------
if ! $NO_SAMPLES && [[ -d "$SOURCE_ROOT/docs" ]]; then
  if [[ -d "docs" ]]; then
    echo -e "${C_YELLOW}⚠ 用户 docs/ 已存在，跳过示范文档（用 --force 覆盖）${C_OFF}"
  else
    read -rp "是否安装示范 docs/ 目录？[y/N] " ans </dev/tty
    if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
      cp -R "$SOURCE_ROOT/docs" .
      INSTALLED+=("docs")
      echo -e "${C_GREEN}  ✓ docs/ (示范)${C_OFF}"
    fi
  fi
fi

# ---------- 保护性检查：README ----------
if [[ ! -f "README.md" && -f "$SOURCE_ROOT/README.md" ]]; then
  read -rp "当前项目没有 README.md，是否用 USDS 的入门 README？[y/N] " ans </dev/tty
  if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
    cp "$SOURCE_ROOT/README.md" .
    INSTALLED+=("README.md")
    echo -e "${C_GREEN}  ✓ README.md${C_OFF}"
  fi
else
  echo -e "${C_GRAY}  ⊘ 保留用户 README.md${C_OFF}"
fi

# ---------- 初始化 .usds-mode ----------
if [[ ! -f "$MODE_FILE" ]]; then
  case "$PROFILE" in
    vibe)             MODE="vibe" ;;
    studio|minimal)   MODE="studio" ;;
    full)             MODE="hybrid" ;;
  esac
  cat > "$MODE_FILE" <<EOF
mode: $MODE
created: $(date +%Y-%m-%d)
last_switched: $(date +%Y-%m-%d)
reason: 由 install-usds.sh --profile $PROFILE 初始化
locked: false
EOF
  INSTALLED+=("$MODE_FILE")
  echo -e "${C_GREEN}  ✓ $MODE_FILE (mode=$MODE)${C_OFF}"
fi

# ---------- 写 manifest ----------
{
  echo "# USDS install manifest"
  echo "# generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "# profile: $PROFILE"
  echo "# ref: $REF"
  printf '%s\n' "${INSTALLED[@]}"
} > "$MANIFEST_FILE"

# ---------- 结束报告 ----------
echo ""
echo -e "${C_GREEN}${C_BOLD}✨ USDS 已就绪${C_OFF}"
echo -e "  Profile:  $PROFILE"
echo -e "  已安装:   ${#INSTALLED[@]} 项"
echo -e "  已跳过:   ${#SKIPPED[@]} 项"
echo -e "  Manifest: $MANIFEST_FILE"
echo ""
echo -e "${C_BOLD}下一步:${C_OFF}"
case "$PROFILE" in
  vibe)   echo "  运行 claude → /vibe-start \"你的想法\"" ;;
  studio) echo "  运行 claude → /onboard  然后  /discovery \"你的项目\"" ;;
  minimal)echo "  运行 claude → /mode-switch 选择模式" ;;
  full)   echo "  运行 claude → /onboard 了解双模态" ;;
esac
echo ""
echo -e "${C_GRAY}卸载: bash install-usds.sh --uninstall${C_OFF}"
