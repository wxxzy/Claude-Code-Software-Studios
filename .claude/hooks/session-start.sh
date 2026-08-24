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

# --- Cross-session memory recap (ADR-003/D1) ---
# session-stop.sh (Stop hook) writes session-log.md; this reads the LAST
# block back so the new session opens knowing what happened last time.
# Best-effort: any missing/malformed input yields silence, never blocks startup.
RECAP=""
SESSION_LOG="production/session-logs/session-log.md"
if [ -f "$SESSION_LOG" ]; then
    LAST_HEADER=$(awk '
        /^## (Session End|Archived Session State):/ { ts=$0; uncommitted=0 }
        /^### Uncommitted Changes/ { uncommitted=1 }
        END { if (ts != "") { print ts; print uncommitted } }
    ' "$SESSION_LOG" 2>/dev/null)
    if [ -n "$LAST_HEADER" ]; then
        RAW_TS=$(echo "$LAST_HEADER" | sed -n '1p' | sed -E 's/^## (Session End|Archived Session State): //')
        UNCOMMITTED_FLAG=$(echo "$LAST_HEADER" | sed -n '2p')
        if [ "${#RAW_TS}" -ge 13 ]; then
            PRETTY_TS="${RAW_TS:0:4}-${RAW_TS:4:2}-${RAW_TS:6:2} ${RAW_TS:9:2}:${RAW_TS:11:2}"
        else
            PRETTY_TS="$RAW_TS"
        fi
        if [ "$UNCOMMITTED_FLAG" = "1" ]; then
            RECAP=" | last: ${PRETTY_TS} (uncommitted changes)"
        else
            RECAP=" | last: ${PRETTY_TS}"
        fi
    fi
fi

# --- Debt ledger summary (ADR-003/D1) ---
# Only the count of unresolved entries under "## 未还清" — never the content,
# to keep this a single-line hint rather than a context dump.
DEBT_NOTE=""
DEBT_FILE="docs/debt-ledger.md"
if [ -f "$DEBT_FILE" ]; then
    OPEN_COUNT=$(awk '
        /^## 未还清/ { f=1; next }
        /^## 已还清/ { f=0 }
        f && /^### DEBT-[0-9]/ { c++ }
        END { print c+0 }
    ' "$DEBT_FILE" 2>/dev/null)
    if [ "${OPEN_COUNT:-0}" -gt 0 ] 2>/dev/null; then
        DEBT_NOTE=" | debt: ${OPEN_COUNT} open"
    fi
fi

# Single-line output
echo "[USDS${UPDATE_NOTICE}${OFFLINE_NOTE} | ${BRANCH:-no-git} | ${STATE}${RESUME}${PARSER_NOTE}${RECAP}${DEBT_NOTE}]"

exit 0
