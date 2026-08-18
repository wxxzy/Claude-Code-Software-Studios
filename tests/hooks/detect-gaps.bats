#!/usr/bin/env bats
# detect-gaps.sh behavior tests

HOOK_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../../.claude/hooks" && pwd)"
HOOK="$HOOK_DIR/detect-gaps.sh"

setup() {
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR"
}

teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

@test "empty project reports no-backlog gap" {
    run "$HOOK"
    [ "$status" -eq 0 ]
    [[ "$output" == *"no-backlog"* ]]
}

@test "existing backlog silences that gap" {
    mkdir -p production
    printf '# Backlog\n' > production/backlog.md
    printf '# prefs\n' > /dev/null
    mkdir -p docs/arch
    printf '# Tech prefs\n' > docs/arch/TECHNICAL-PREFERENCES.md
    run "$HOOK"
    [ "$status" -eq 0 ]
    [[ "$output" != *"no-backlog"* ]]
}

@test "src/core without ADR reports no-adr" {
    mkdir -p src/core
    printf 'x = 1\n' > src/core/mod.py
    run "$HOOK"
    [ "$status" -eq 0 ]
    [[ "$output" == *"no-adr"* ]]
}

@test "src/core with ADR silences no-adr" {
    mkdir -p src/core docs/arch
    printf 'x = 1\n' > src/core/mod.py
    printf '# ADR\n## 背景\n## 决策\n## 权衡\n## 替代方案\n' > docs/arch/ADR-001.md
    mkdir -p production
    printf '# Backlog\n' > production/backlog.md
    printf '# Tech prefs\n' > docs/arch/TECHNICAL-PREFERENCES.md
    run "$HOOK"
    [ "$status" -eq 0 ]
    [[ "$output" != *"no-adr"* ]]
}

@test "small src tree (<=20 files) does not demand a PRD" {
    mkdir -p src
    for i in 1 2 3; do printf 'x=1\n' > "src/f$i.py"; done
    run "$HOOK"
    [ "$status" -eq 0 ]
    [[ "$output" != *"no-prd"* ]]
}
