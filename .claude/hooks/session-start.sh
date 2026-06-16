#!/bin/bash
# Claude Code SessionStart hook: Load project context at session start
# Outputs context information that Claude sees when a session begins
#
# Input schema (SessionStart): No stdin input

# Current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Version check (2s timeout, silent on offline)
LOCAL_VERSION_FILE=".claude/VERSION"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/.claude/VERSION"
UPDATE_NOTICE=""
if [ -f "$LOCAL_VERSION_FILE" ]; then
    LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE" | tr -d '[:space:]')
    REMOTE_VERSION=$(curl -s --max-time 2 "$REMOTE_VERSION_URL" | tr -d '[:space:]')
    if [ -n "$REMOTE_VERSION" ] && [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
        UPDATE_NOTICE=" 🚀 v${REMOTE_VERSION} available — /update"
    fi
fi

# Project state summary
if [ ! -d "docs/specs" ] || [ -z "$(ls -A docs/specs 2>/dev/null)" ]; then
    STATE="⚠️ no PRD"
else
    PRD_COUNT=$(ls docs/specs/PRD-*.md 2>/dev/null | wc -l | tr -d ' ')
    STATE="${PRD_COUNT} PRD"
    if [ -f "production/backlog.md" ]; then
        TODO=$(grep -c "\[ \]" production/backlog.md 2>/dev/null | tr -d ' ')
        DONE=$(grep -c "\[x\]" production/backlog.md 2>/dev/null | tr -d ' ')
        STATE="${STATE} | backlog ${TODO}todo/${DONE}done"
    fi
fi

# Session state recovery (only shown when file exists)
RESUME=""
if [ -f "production/session-state/active.md" ]; then
    RESUME=" | ⚠️ resume: production/session-state/active.md"
fi

# Single-line output
echo "[USDS${UPDATE_NOTICE} | ${BRANCH:-no-git} | ${STATE}${RESUME}]"

exit 0
