#!/usr/bin/env bats
# Skill namespacing invariants (ADR-002): renamed-away list consistency,
# no stale v2.0 skill dirs in repo, installer lists match skill dirs.

REPO_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/.claude/skills"
SH_INSTALLER="$REPO_ROOT/scripts/install-usds.sh"
PS1_INSTALLER="$REPO_ROOT/scripts/install-usds.ps1"

# The 20 v2.0 names that must have been renamed away (vibe-start / vibe-check kept their names)
RENAMED_AWAY=(
  start onboard mode-switch update cost-report debt-log micro-adr
  prototype taste-review branch-vibe explain-back graduate
  discovery project-scan setup-stack arch-design summarize-arch
  sprint-kickoff review gate-check
)

@test "repo contains no stale v2.0 skill directories" {
    local stale=0
    for old in "${RENAMED_AWAY[@]}"; do
        if [ -d "$SKILLS_DIR/$old" ]; then
            echo "stale dir present: .claude/skills/$old"
            stale=1
        fi
    done
    [ "$stale" -eq 0 ]
}

@test "sh installer RENAMED_AWAY_SKILLS list matches the 20 v2.0 names" {
    local extracted
    extracted=$(sed -n '/^RENAMED_AWAY_SKILLS=(/,/^)/p' "$SH_INSTALLER" \
        | tr -d '"' | sed '1d;$d' | tr -s ' \n' ' ' | xargs)
    local expected
    expected=$(printf '%s ' "${RENAMED_AWAY[@]}" | xargs)
    [ "$extracted" = "$expected" ]
}

@test "ps1 installer RenamedAwaySkills list matches the 20 v2.0 names" {
    local extracted
    extracted=$(sed -n '/RenamedAwaySkills = @(/,/)/p' "$PS1_INSTALLER" \
        | tr -d '"' | sed 's/^\$RenamedAwaySkills = @//' | tr -d '()' | tr ',\n' '  ' | tr -s ' ' ' ' | xargs)
    local expected
    expected=$(printf '%s ' "${RENAMED_AWAY[@]}" | xargs)
    [ "$extracted" = "$expected" ]
}

@test "every skill dir has matching frontmatter name" {
    local bad=0
    for d in "$SKILLS_DIR"/*/; do
        local dir_name
        dir_name=$(basename "$d")
        local fm_name
        fm_name=$(sed -n 's/^name:[[:space:]]*//p' "$d/SKILL.md" | head -1 | tr -d '[:space:]')
        if [ "$dir_name" != "$fm_name" ]; then
            echo "mismatch: dir=$dir_name name=$fm_name"
            bad=1
        fi
    done
    [ "$bad" -eq 0 ]
}

@test "all 22 skill dirs are namespaced (usds-/vibe-/studio-)" {
    local count=0 bad=0
    for d in "$SKILLS_DIR"/*/; do
        count=$((count + 1))
        case "$(basename "$d")" in
            usds-*|vibe-*|studio-*) ;;
            *) echo "unprefixed skill dir: $(basename "$d")"; bad=1 ;;
        esac
    done
    [ "$count" -eq 22 ]
    [ "$bad" -eq 0 ]
}

@test "installer stale-cleanup: dry-run lists stale dir, real run removes it (sh)" {
    command -v git >/dev/null 2>&1 || skip "git missing"
    local T
    T=$(mktemp -d)
    # simulate a v2.0 project: stale dir + new dir side by side
    mkdir -p "$T/.claude/skills/review" "$T/.claude/skills/studio-review"
    echo old > "$T/.claude/skills/review/SKILL.md"
    cd "$T" || exit 1
    # dry-run must surface the stale dir in its plan
    run bash "$SH_INSTALLER" --profile studio --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"将清理"* ]]
    [[ "$output" == *".claude/skills/review/"* ]]
    cd / || exit 1
    rm -rf "$T"
}
