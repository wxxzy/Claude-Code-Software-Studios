#!/bin/bash
# Claude Code SessionStart hook: Load project context at session start
# Outputs context information that Claude sees when a session begins
#
# Input schema (SessionStart): No stdin input

# Current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Version check (2s timeout, silent on timeout; explicit note on network error)
LOCAL_VERSION_FILE=".claude/VERSION"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/wxxzy/Claude-Code-Software-Studios/master/.claude/VERSION"
UPDATE_NOTICE=""
OFFLINE_NOTE=""
if [ -f "$LOCAL_VERSION_FILE" ]; then
    LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE" | tr -d '[:space:]')
    CURL_RC=0
    REMOTE_VERSION=$(curl -s --max-time 2 "$REMOTE_VERSION_URL" 2>/dev/null) || CURL_RC=$?
    REMOTE_VERSION=$(printf '%s' "$REMOTE_VERSION" | tr -d '[:space:]')
    # curl exit 28 = timeout: stay silent (transient). Other failures = clearly offline.
    if [ "$CURL_RC" -ne 0 ] && [ "$CURL_RC" -ne 28 ]; then
        OFFLINE_NOTE=" (offline: version check skipped)"
    fi
    if [ -n "$REMOTE_VERSION" ] && [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
        UPDATE_NOTICE=" 🚀 v${REMOTE_VERSION} available — /usds-update"
    fi
fi

# JSON parser availability for hooks (jq -> python -> regex, see ADR-001)
# Only surface a note when degraded; jq/python present = silent
PARSER_NOTE=""
if ! command -v jq >/dev/null 2>&1; then
    if command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
        PARSER_NOTE=" | json:python"
    else
        PARSER_NOTE=" | ⚠️ json:regex (install jq)"
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
echo "[USDS${UPDATE_NOTICE}${OFFLINE_NOTE} | ${BRANCH:-no-git} | ${STATE}${RESUME}${PARSER_NOTE}]"

exit 0
