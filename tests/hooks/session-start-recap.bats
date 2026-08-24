#!/usr/bin/env bats
# session-start.sh cross-session memory recap (ADR-003/D1):
# reads session-log.md's last block + debt-ledger.md's open count back into
# the new session's single-line output. Silent on any missing/malformed input.

HOOK_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../../.claude/hooks" && pwd)"
HOOK="$HOOK_DIR/session-start.sh"

setup() {
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR"
}

teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

@test "no session-log, no debt-ledger: no recap/debt note" {
    run "$HOOK"
    [ "$status" -eq 0 ]
    [[ "$output" != *"last:"* ]]
    [[ "$output" != *"debt:"* ]]
}

@test "session-log with uncommitted changes surfaces recap + flag" {
    mkdir -p production/session-logs
    {
        echo "## Session End: 20260819_113000"
        echo "### Commits"
        echo "abc123 fix"
        echo "### Uncommitted Changes"
        echo "foo.txt"
        echo "---"
    } > production/session-logs/session-log.md
    run "$HOOK"
    [ "$status" -eq 0 ]
    [[ "$output" == *"last: 2026-08-19 11:30 (uncommitted changes)"* ]]
}

@test "session-log with only Archived Session State block: recap without uncommitted flag" {
    mkdir -p production/session-logs
    {
        echo "## Archived Session State: 20260820_090000"
        echo "some state"
        echo "---"
    } > production/session-logs/session-log.md
    run "$HOOK"
    [ "$status" -eq 0 ]
    [[ "$output" == *"last: 2026-08-20 09:00"* ]]
    [[ "$output" != *"uncommitted"* ]]
}

@test "recap uses the LAST block, not the first" {
    mkdir -p production/session-logs
    {
        echo "## Session End: 20260101_010000"
        echo "---"
        echo ""
        echo "## Session End: 20260819_113000"
        echo "---"
    } > production/session-logs/session-log.md
    run "$HOOK"
    [ "$status" -eq 0 ]
    [[ "$output" == *"last: 2026-08-19 11:30"* ]]
    [[ "$output" != *"2026-01-01"* ]]
}

@test "debt-ledger open entries are counted and surfaced" {
    mkdir -p docs
    {
        echo "## 未还清"
        echo ""
        echo "### DEBT-20260819-001 [high|linear]"
        echo "- 状态: 未还清"
        echo ""
        echo "### DEBT-20260819-002 [low|flat]"
        echo "- 状态: 未还清"
        echo ""
        echo "## 已还清"
        echo ""
        echo "### DEBT-20260101-000 [low|flat]"
    } > docs/debt-ledger.md
    run "$HOOK"
    [ "$status" -eq 0 ]
    [[ "$output" == *"debt: 2 open"* ]]
}

@test "fully repaid debt-ledger (0 open) shows no debt note" {
    mkdir -p docs
    {
        echo "## 未还清"
        echo ""
        echo "## 已还清"
        echo ""
        echo "### DEBT-1 [low|flat]"
    } > docs/debt-ledger.md
    run "$HOOK"
    [ "$status" -eq 0 ]
    [[ "$output" != *"debt:"* ]]
}

@test "raw template placeholder (DEBT-YYYYMMDD-NNN) is not counted as a real entry" {
    mkdir -p docs
    {
        echo "## 未还清"
        echo ""
        echo "### DEBT-YYYYMMDD-001 [严重度|利率]"
        echo "- 状态: 未还清"
        echo ""
        echo "## 已还清"
    } > docs/debt-ledger.md
    run "$HOOK"
    [ "$status" -eq 0 ]
    [[ "$output" != *"debt:"* ]]
}
