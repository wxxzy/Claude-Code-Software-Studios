#!/bin/bash
# USDS shared JSON extraction helper — sourced by hooks, never executed directly.
# See docs/arch/ADR-001-framework-self-hardening.md (D1).
#
# Resolution order (first available wins):
#   1. jq            — full JSON semantics
#   2. python3/python — full JSON semantics
#   3. regex         — LAST-RESORT only: matches the final path segment as a
#                      "key": "value" pair. Does NOT handle escaped quotes,
#                      non-string (number/bool) values, or duplicate keys.
#
# Usage:
#   source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/json.sh"
#   COMMAND=$(usds_json_str "$INPUT" .tool_input.command)
#   FILE_PATH=$(usds_json_str "$INPUT" .tool_input.file_path .tool_input.path)
#
# Prints the first non-empty string value found across the given paths,
# or nothing if none match / JSON is unparseable. Always succeeds (exit 0).

# shellcheck shell=bash disable=SC2317

usds_json_str() {
    local input="$1"
    shift
    [ -z "$input" ] && return 0
    [ $# -eq 0 ] && return 0
    local paths=("$@")

    # ---- Tier 1: jq ----
    if command -v jq >/dev/null 2>&1; then
        local sel="${paths[0]}"
        local p
        for p in "${paths[@]:1}"; do
            sel="$sel // $p"
        done
        echo "$input" | jq -r "($sel) // empty" 2>/dev/null
        return 0
    fi

    # ---- Tier 2: python3 / python ----
    # Probe rather than trust `command -v`: on Windows, python3 is often a
    # Microsoft Store stub that exists on PATH but fails to execute.
    local py=""
    local candidate
    for candidate in python3 python; do
        if command -v "$candidate" >/dev/null 2>&1; then
            if echo '{}' | "$candidate" -c 'import json,sys; json.load(sys.stdin)' >/dev/null 2>&1; then
                py="$candidate"
                break
            fi
        fi
    done
    if [ -n "$py" ]; then
        echo "$input" | "$py" -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for path in sys.argv[1:]:
    cur = data
    ok = True
    for key in path.strip(".").split("."):
        if isinstance(cur, dict) and key in cur:
            cur = cur[key]
        else:
            ok = False
            break
    if ok and isinstance(cur, str) and cur:
        print(cur)
        break
' "${paths[@]}" 2>/dev/null
        return 0
    fi

    # ---- Tier 3: regex (degraded; see limitations in header) ----
    local key="${paths[0]##*.}"
    echo "$input" \
        | grep -oE "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
        | head -1 \
        | sed "s/\"$key\"[[:space:]]*:[[:space:]]*\"//;s/\"\$//"
    return 0
}
