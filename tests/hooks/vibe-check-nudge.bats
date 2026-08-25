#!/usr/bin/env bats
# vibe-check-nudge.sh behavior tests (ADR-004/D3):
# counts /vibe-prototype (explorer) calls since the last /vibe-check
# (explainer) call, nudging at 4 and every 2 rounds after; vibe/hybrid only.

HOOK_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../../.claude/hooks" && pwd)"
HOOK="$HOOK_DIR/vibe-check-nudge.sh"

setup() {
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR"
}

teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

call_agent() {
    echo "{\"agent_name\": \"$1\"}" | bash "$HOOK"
}

@test "studio mode: explorer calls never nudge" {
    echo "mode: studio" > .usds-mode
    for _ in 1 2 3 4 5 6; do
        run call_agent explorer
        [ "$status" -eq 0 ]
        [ -z "$output" ]
    done
}

@test "no .usds-mode file (defaults to studio): explorer calls never nudge" {
    for _ in 1 2 3 4; do
        run call_agent explorer
        [ "$status" -eq 0 ]
        [ -z "$output" ]
    done
}

@test "vibe mode: rounds 1-3 silent, round 4 nudges" {
    echo "mode: vibe" > .usds-mode
    for _ in 1 2 3; do
        run call_agent explorer
        [ -z "$output" ]
    done
    run call_agent explorer
    [[ "$output" == *"4"*"vibe-check"* ]]
}

@test "vibe mode: nudges again at round 6 but not round 5" {
    echo "mode: vibe" > .usds-mode
    for _ in 1 2 3 4; do call_agent explorer >/dev/null; done
    run call_agent explorer
    [ -z "$output" ]
    run call_agent explorer
    [[ "$output" == *"6"* ]]
}

@test "explainer call resets the counter to 0" {
    echo "mode: vibe" > .usds-mode
    for _ in 1 2 3 4 5; do call_agent explorer >/dev/null; done
    call_agent explainer >/dev/null
    [ "$(cat production/session-state/.vibe-check-counter)" = "0" ]
    run call_agent explorer
    [ -z "$output" ]
}

@test "hybrid mode also triggers the nudge" {
    echo "mode: hybrid" > .usds-mode
    for _ in 1 2 3; do call_agent explorer >/dev/null; done
    run call_agent explorer
    [[ "$output" == *"vibe-check"* ]]
}

@test "unrelated agent names are silently ignored" {
    echo "mode: vibe" > .usds-mode
    run call_agent lead-developer
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
