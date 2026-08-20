#!/usr/bin/env bats
# Installer encoding invariants: install-usds.ps1 must stay pure ASCII.
# Rationale (TD-008): Windows PowerShell 5.1 needs a UTF-8 BOM to parse CJK
# source correctly, but a leading BOM poisons "irm <url> | iex" (the BOM
# becomes an invalid token in the string handed to Invoke-Expression).
# ASCII-only is the only encoding that satisfies BOTH paths on every PS
# version. These tests fail the moment anyone reintroduces CJK/emoji/BOM.

REPO_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd)"
PS1_INSTALLER="$REPO_ROOT/scripts/install-usds.ps1"

@test "install-usds.ps1 has no UTF-8 BOM" {
    local first3
    first3=$(head -c 3 "$PS1_INSTALLER" | od -An -tx1 | tr -d ' \n')
    [ "$first3" != "efbbbf" ]
}

@test "install-usds.ps1 is pure ASCII (irm | iex safe on any PS version)" {
    if LC_ALL=C grep -qP '[^\x09\x0A\x0D\x20-\x7E]' "$PS1_INSTALLER"; then
        LC_ALL=C grep -nP '[^\x09\x0A\x0D\x20-\x7E]' "$PS1_INSTALLER" | head -5
        fail "non-ASCII byte found (CJK/emoji would break PS 5.1 or the piped one-liner)"
    fi
}
