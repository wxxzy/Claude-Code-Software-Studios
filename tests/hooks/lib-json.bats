#!/usr/bin/env bats
# lib/json.sh tiered parsing tests (ADR-001/D1: jq -> python -> regex)

LIB_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../../.claude/hooks/lib" && pwd)"

# Build a PATH-whitelist dir containing only bash coreutils (+ optionally python),
# excluding jq, to force lower tiers. Skips when symlinks are unavailable.
make_isolation_dir() { # $1 = dir, remaining args = extra commands to whitelist
    local dir="$1"; shift
    mkdir -p "$dir"
    local cmd src
    for cmd in bash sh grep sed head cat "$@"; do
        src=$(command -v "$cmd" 2>/dev/null) || continue
        case "$src" in
            /*) ;; # real executable path
            *)  continue ;; # shell builtin/keyword (echo etc.) — not needed on PATH
        esac
        ln -sf "$src" "$dir/$cmd" 2>/dev/null || {
            rm -rf "$dir"
            return 1
        }
    done
    # Probe: the isolated bash must actually run (msys/git-bash symlinks break
    # when separated from their DLLs — treat as "isolation unavailable").
    "$dir/bash" -c ':' >/dev/null 2>&1 || {
        rm -rf "$dir"
        return 1
    }
    return 0
}

@test "tier1/2: nested path with escaped quotes extracts correctly" {
    source "$LIB_DIR/json.sh"
    local json='{"tool_input":{"command":"git commit -m \"hello world\""}}'
    local v
    v=$(usds_json_str "$json" .tool_input.command)
    [ "$v" = 'git commit -m "hello world"' ]
}

@test "multi-path fallback returns first non-empty" {
    source "$LIB_DIR/json.sh"
    local v
    v=$(usds_json_str '{"tool_input":{"path":"/x/y"}}' .tool_input.file_path .tool_input.path)
    [ "$v" = "/x/y" ]
}

@test "absent key returns empty string" {
    source "$LIB_DIR/json.sh"
    local v
    v=$(usds_json_str '{"a":1}' .nope.here)
    [ -z "$v" ]
}

@test "empty input returns empty" {
    source "$LIB_DIR/json.sh"
    local v
    v=$(usds_json_str "" .tool_input.command)
    [ -z "$v" ]
}

@test "python tier: correct without jq (probed python only)" {
    command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1 || skip "no python"
    command -v jq >/dev/null 2>&1 || skip "jq absent -> python tier already covered by tier1/2 test"
    local isol
    isol=$(mktemp -d)
    if ! make_isolation_dir "$isol" python3 python; then
        rm -rf "$isol"
        skip "symlink isolation unavailable"
    fi
    # probe which python actually executes (Windows store stubs break)
    local py=""
    for c in python3 python; do
        [ -x "$isol/$c" ] || continue
        if echo '{}' | "$isol/$c" -c 'import json,sys; json.load(sys.stdin)' >/dev/null 2>&1; then py="$c"; break; fi
    done
    if [ -z "$py" ]; then
        rm -rf "$isol"
        skip "no working python under isolation"
    fi
    local v
    v=$(cd "$(dirname "$LIB_DIR")" && PATH="$isol" bash -c 'source lib/json.sh; usds_json_str "{\"tool_input\":{\"command\":\"py-tier-works\"}}" .tool_input.command')
    rm -rf "$isol"
    [ "$v" = "py-tier-works" ]
}

@test "regex tier: last-resort extraction without jq/python" {
    local isol
    isol=$(mktemp -d)
    if ! make_isolation_dir "$isol"; then
        rm -rf "$isol"
        skip "symlink isolation unavailable"
    fi
    # Canary: same PATH-search pattern as the real run; msys bash symlinks can
    # break under PATH resolution on Windows — skip honestly if unusable.
    if ! PATH="$isol" bash -c 'exit 0' >/dev/null 2>&1; then
        rm -rf "$isol"
        skip "isolated bash unusable on this platform"
    fi
    local v
    v=$(cd "$(dirname "$LIB_DIR")" && PATH="$isol" bash -c 'source lib/json.sh; usds_json_str "{\"tool_input\":{\"command\":\"plain-token\"}}" .tool_input.command')
    rm -rf "$isol"
    [ "$v" = "plain-token" ]
}

@test "regex tier limitation: escaped quotes degrade (documented, accepted)" {
    local isol
    isol=$(mktemp -d)
    if ! make_isolation_dir "$isol"; then
        rm -rf "$isol"
        skip "symlink isolation unavailable"
    fi
    if ! PATH="$isol" bash -c 'exit 0' >/dev/null 2>&1; then
        rm -rf "$isol"
        skip "isolated bash unusable on this platform"
    fi
    # regex tier must not crash on escaped quotes; value may be truncated -- documented limitation
    local v
    v=$(cd "$(dirname "$LIB_DIR")" && PATH="$isol" bash -c 'source lib/json.sh; usds_json_str "{\"tool_input\":{\"command\":\"git commit -m \\\"hi\\\"\"}}" .tool_input.command')
    rm -rf "$isol"
    # assert: no crash + some prefix extracted
    [ -n "$v" ]
    [[ "$v" == git\ commit* ]]
}
