#!/usr/bin/env bats
# validate-assets.sh security scan tests

HOOK_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../../.claude/hooks" && pwd)"
HOOK="$HOOK_DIR/validate-assets.sh"

setup() {
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR"
}

teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

@test "hardcoded credential triggers SECURITY alert" {
    printf 'api_key = "sk-abcdefgh12345678"\n' > cred.py
    run bash -c "echo '{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$TEST_DIR/cred.py\",\"content\":\"x\"}}' | '$HOOK' 2>&1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"[SECURITY]"* ]]
}

@test "writing a .env file triggers SECURITY alert" {
    printf 'FOO=bar\n' > .env
    run bash -c "echo '{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$TEST_DIR/.env\",\"content\":\"x\"}}' | '$HOOK' 2>&1"
    [ "$status" -eq 0 ]
    [[ "$output" == *".env"* ]]
}

@test "benign file produces no output" {
    printf 'print("hello")\n' > clean.py
    run bash -c "echo '{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$TEST_DIR/clean.py\",\"content\":\"x\"}}' | '$HOOK' 2>&1"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "placeholder-style values do not alert" {
    printf 'api_key = "${API_KEY}"\n' > placeholder.py
    run bash -c "echo '{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$TEST_DIR/placeholder.py\",\"content\":\"x\"}}' | '$HOOK' 2>&1"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Possible hardcoded credential"* ]]
}
