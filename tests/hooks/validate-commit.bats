#!/usr/bin/env bats
# validate-commit.sh regression tests (ADR-001/D2: blocking + filename scope)

HOOK_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../../.claude/hooks" && pwd)"
HOOK="$HOOK_DIR/validate-commit.sh"
COMMIT_CMD='{"tool_input":{"command":"git commit -m test"}}'

setup() {
    TEST_REPO="$(mktemp -d)"
    cd "$TEST_REPO"
    git init -q .
    git config user.email test@test.test
    git config user.name test
}

teardown() {
    cd /
    rm -rf "$TEST_REPO"
}

@test "non-commit command passes through silently" {
    run bash -c "echo '{\"tool_input\":{\"command\":\"ls -la\"}}' | '$HOOK'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "git commit with nothing staged exits 0" {
    run bash -c "echo '$COMMIT_CMD' | '$HOOK'"
    [ "$status" -eq 0 ]
}

@test "PRD missing mandatory sections is BLOCKED (exit 2)" {
    mkdir -p docs/specs
    printf '# PRD\nsome content\n' > docs/specs/PRD-001.md
    git add docs/specs/PRD-001.md
    run bash -c "echo '$COMMIT_CMD' | '$HOOK'"
    [ "$status" -eq 2 ]
    [[ "$output" == *"missing required section"* ]]
}

@test "PRD with all mandatory sections is allowed" {
    mkdir -p docs/specs
    printf '# PRD\n## 业务目标\nx\n## 用户故事\nx\n## 验收标准\nx\n' > docs/specs/PRD-001.md
    git add docs/specs/PRD-001.md
    run bash -c "echo '$COMMIT_CMD' | '$HOOK'"
    [ "$status" -eq 0 ]
}

@test "unnamed PRD.md (/discovery output) is also gated" {
    mkdir -p docs/specs
    printf '# PRD\nno sections\n' > docs/specs/PRD.md
    git add docs/specs/PRD.md
    run bash -c "echo '$COMMIT_CMD' | '$HOOK'"
    [ "$status" -eq 2 ]
}

@test "non-PRD-named doc in docs/specs is NOT gated" {
    mkdir -p docs/specs
    printf '# research\nnothing here\n' > docs/specs/research-notes.md
    git add docs/specs/research-notes.md
    run bash -c "echo '$COMMIT_CMD' | '$HOOK'"
    [ "$status" -eq 0 ]
}

@test "ADR missing mandatory sections is BLOCKED (exit 2)" {
    mkdir -p docs/arch
    printf '# ADR\n## 背景\nonly context\n' > docs/arch/ADR-001-test.md
    git add docs/arch/ADR-001-test.md
    run bash -c "echo '$COMMIT_CMD' | '$HOOK'"
    [ "$status" -eq 2 ]
}

@test "ADR with all mandatory sections is allowed" {
    mkdir -p docs/arch
    printf '# ADR\n## 背景\nx\n## 决策\nx\n## 权衡\nx\n## 替代方案\nx\n' > docs/arch/ADR-009-full.md
    git add docs/arch/ADR-009-full.md
    run bash -c "echo '$COMMIT_CMD' | '$HOOK'"
    [ "$status" -eq 0 ]
}

@test "SYSTEM-MAP.md and TECH-DEBT.md are NOT gated (scope regression guard)" {
    mkdir -p docs/arch
    printf '# System Map\nplain text\n' > docs/arch/SYSTEM-MAP.md
    printf '# Tech Debt\nplain text\n' > docs/arch/TECH-DEBT.md
    git add docs/arch/
    run bash -c "echo '$COMMIT_CMD' | '$HOOK'"
    [ "$status" -eq 0 ]
}

@test "invalid staged JSON is BLOCKED (exit 2)" {
    printf '{broken' > config.json
    git add config.json
    run bash -c "echo '$COMMIT_CMD' | '$HOOK'"
    [ "$status" -eq 2 ]
    [[ "$output" == *"not valid JSON"* ]]
}

@test "valid staged JSON is allowed" {
    printf '{"a":1}' > config.json
    git add config.json
    run bash -c "echo '$COMMIT_CMD' | '$HOOK'"
    [ "$status" -eq 0 ]
}

@test "bare TODO in src warns but does NOT block" {
    mkdir -p src
    printf 'TODO fix this\n' > src/app.py
    git add src/app.py
    run bash -c "echo '$COMMIT_CMD' | '$HOOK' 2>&1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"STYLE"* ]]
}
