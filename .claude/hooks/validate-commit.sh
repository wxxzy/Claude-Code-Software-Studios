#!/bin/bash
# Claude Code PreToolUse hook: Validates git commit commands
# Receives JSON on stdin with tool_input.command
# Exit 0 = allow, Exit 2 = block (stderr shown to Claude)
#
# Input schema (PreToolUse for Bash):
# { "tool_name": "Bash", "tool_input": { "command": "git commit -m ..." } }

INPUT=$(cat)

# Parse command via shared tiered helper (jq -> python -> regex), see ADR-001
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/json.sh
source "$SCRIPT_DIR/lib/json.sh"
COMMAND=$(usds_json_str "$INPUT" .tool_input.command)

# Only process git commit commands
if ! echo "$COMMAND" | grep -qE '^git[[:space:]]+commit'; then
    exit 0
fi

# Get staged files
STAGED=$(git diff --cached --name-only 2>/dev/null)
if [ -z "$STAGED" ]; then
    exit 0
fi

WARNINGS=""
BLOCKERS=""

# Check PRD documents for required sections (per doc-standards.md, enforced blocking per ADR-001/D2)
# Scope: PRD*.md only — other docs/specs/*.md files (research notes, etc.) are not gated.
PRD_FILES=$(echo "$STAGED" | grep -E '^docs/specs/PRD[^/]*\.md$')
if [ -n "$PRD_FILES" ]; then
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            for section in "业务目标" "用户故事" "验收标准"; do
                if ! grep -qi "$section" "$file"; then
                    BLOCKERS="$BLOCKERS\nPRD: $file missing required section: $section"
                fi
            done
        fi
    done <<< "$PRD_FILES"
fi

# Check ADR documents for required sections (per doc-standards.md, enforced blocking per ADR-001/D2)
# Scope: ADR*.md only — SYSTEM-MAP.md / TECH-DEBT.md and other docs/arch/*.md are not gated.
ADR_FILES=$(echo "$STAGED" | grep -E '^docs/arch/ADR[^/]*\.md$')
if [ -n "$ADR_FILES" ]; then
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            for section in "背景" "决策" "权衡" "替代方案"; do
                if ! grep -qi "$section" "$file"; then
                    BLOCKERS="$BLOCKERS\nADR: $file missing required section: $section"
                fi
            done
        fi
    done <<< "$ADR_FILES"
fi

# Validate JSON config files -- block invalid JSON
DATA_FILES=$(echo "$STAGED" | grep -E '\.json$')
if [ -n "$DATA_FILES" ]; then
    # Find a working Python command
    PYTHON_CMD=""
    for cmd in python python3 py; do
        if command -v "$cmd" >/dev/null 2>&1; then
            PYTHON_CMD="$cmd"
            break
        fi
    done

    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if [ -n "$PYTHON_CMD" ]; then
                if ! "$PYTHON_CMD" -m json.tool "$file" > /dev/null 2>&1; then
                    echo "BLOCKED: $file is not valid JSON" >&2
                    exit 2
                fi
            else
                echo "WARNING: Cannot validate JSON (python not found): $file" >&2
            fi
        fi
    done <<< "$DATA_FILES"
fi

# Check for TODO/FIXME without assignee -- uses grep -E instead of grep -P
SRC_FILES=$(echo "$STAGED" | grep -E '^src/')
if [ -n "$SRC_FILES" ]; then
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if grep -nE '(TODO|FIXME|HACK)[^(]' "$file" 2>/dev/null; then
                WARNINGS="$WARNINGS\nSTYLE: $file has TODO/FIXME without owner tag. Use TODO(name) format."
            fi
        fi
    done <<< "$SRC_FILES"
fi

# Print warnings (non-blocking) and allow commit
if [ -n "$WARNINGS" ]; then
    echo -e "=== Commit Validation Warnings ===$WARNINGS\n================================" >&2
fi

# Block on missing mandatory PRD/ADR sections (ADR-001/D2: Doc-First is enforced, not advisory)
if [ -n "$BLOCKERS" ]; then
    echo -e "=== BLOCKED: Mandatory Doc Sections Missing ===$BLOCKERS\n===============================================" >&2
    echo "Per doc-standards.md these sections are mandatory. Fix the document, or rename the file if it is not a PRD/ADR." >&2
    exit 2
fi

exit 0
