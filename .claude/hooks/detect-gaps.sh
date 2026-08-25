#!/bin/bash
# USDS Hook: detect-gaps.sh
# 识别代码与文档之间的同步缺口 — 只在发现缺口时输出，无缺口则静默

GAPS=""

# Check 1: 业务代码有但无 PRD
if [ -d "src" ]; then
    CODE_COUNT=$(find src -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" \) 2>/dev/null | wc -l | tr -d ' ')
    if [ "$CODE_COUNT" -gt 20 ]; then
        PRD_COUNT=$(find docs/specs -name "PRD-*.md" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$PRD_COUNT" -lt 1 ]; then
            GAPS="$GAPS no-prd(/studio-discovery)"
        fi
    fi
fi

# Check 2: 核心系统无 ADR
if [ -d "src/core" ] || [ -d "src/api" ]; then
    ADR_COUNT=$(find docs/arch -name "ADR-*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$ADR_COUNT" -lt 1 ]; then
        GAPS="$GAPS no-adr(/studio-arch-design)"
    fi
fi

# Check 3: 无 backlog
if [ ! -f "production/backlog.md" ]; then
    GAPS="$GAPS no-backlog(/studio-sprint-kickoff)"
fi

# Check 4: 无技术偏好配置
if [ ! -f "docs/arch/TECHNICAL-PREFERENCES.md" ]; then
    GAPS="$GAPS no-tech-prefs(/studio-setup-stack)"
fi

# Check 5: sandbox/ 下 30 天未修改的原型目录（vibe-mode.md §4 生命周期约定，此前无机制兜底）
if [ -d "sandbox" ]; then
    STALE_COUNT=0
    for d in sandbox/*/; do
        [ -d "$d" ] || continue
        name=$(basename "$d")
        [ "$name" = "archive" ] && continue
        # 目录内最新修改文件的 mtime 距今是否 > 30 天；find -mtime +30 需存在更新文件才判定为活跃
        if [ -z "$(find "$d" -type f -mtime -30 2>/dev/null | head -1)" ]; then
            STALE_COUNT=$((STALE_COUNT + 1))
        fi
    done
    if [ "$STALE_COUNT" -gt 0 ]; then
        GAPS="$GAPS stale-sandbox(${STALE_COUNT}个/vibe-check 或归档到 sandbox/archive/)"
    fi
fi

# 有缺口才输出，无缺口静默
if [ -n "$GAPS" ]; then
    echo "⚠️ GAPS:$GAPS"
fi

exit 0
