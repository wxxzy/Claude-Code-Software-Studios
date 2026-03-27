#!/bin/bash
# USDS Hook: detect-gaps.sh
# 识别代码与文档之间的同步缺口

echo "=== USDS Gap Detection — Project Integrity Check ==="

# --- Check 1: 业务代码与需求文档 (src/ vs docs/specs/) ---
if [ -d "src" ]; then
    CODE_COUNT=$(find src -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" \) 2>/dev/null | wc -l)
    CODE_COUNT=$(echo "$CODE_COUNT" | tr -d ' ')
    
    if [ "$CODE_COUNT" -gt 20 ]; then
        PRD_COUNT=$(find docs/specs -name "PRD-*.md" 2>/dev/null | wc -l)
        PRD_COUNT=$(echo "$PRD_COUNT" | tr -d ' ')
        
        if [ "$PRD_COUNT" -lt 1 ]; then
            echo "⚠️  GAP: Substantial codebase ($CODE_COUNT files) but no PRD found in docs/specs/."
            echo "👉 Suggestion: Run '/discovery' to capture business intent."
        fi
    fi
fi

# --- Check 2: 核心系统与架构决策 (src/core/ vs docs/arch/) ---
if [ -d "src/core" ] || [ -d "src/api" ]; then
    ADR_COUNT=$(find docs/arch -name "ADR-*.md" 2>/dev/null | wc -l)
    ADR_COUNT=$(echo "$ADR_COUNT" | tr -d ' ')
    
    if [ "$ADR_COUNT" -lt 1 ]; then
        echo "⚠️  GAP: Core systems exist but no ADR found in docs/arch/."
        echo "👉 Suggestion: Run '/arch-design' to document architecture decisions."
    fi
fi

# --- Check 3: 交付计划检测 (production/backlog.md) ---
if [ ! -f "production/backlog.md" ]; then
    echo "⚠️  GAP: No production backlog found."
    echo "👉 Suggestion: Run '/sprint-kickoff' to break down tasks."
fi

# --- Check 4: 环境与规则配置 ---
if [ ! -f "docs/arch/TECHNICAL-PREFERENCES.md" ]; then
    echo "⚠️  GAP: Technical preferences not defined."
    echo "👉 Suggestion: Run '/setup-stack' to initialize project stack."
fi

echo "==================================================="
exit 0
