#!/usr/bin/env bats
# Shipping-consistency gates (ADR-003/D2): turns the manual audit that found
# skills-reference.md / coordination-rules.md missing from both installers
# into a permanent, every-push CI check.

REPO_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd)"
SH_INSTALLER="$REPO_ROOT/scripts/install-usds.sh"
PS1_INSTALLER="$REPO_ROOT/scripts/install-usds.ps1"
CLAUDE_MD="$REPO_ROOT/CLAUDE.md"
SKILLS_REF="$REPO_ROOT/.claude/docs/skills-reference.md"
SKILLS_DIR="$REPO_ROOT/.claude/skills"

RENAMED_AWAY=(
  start onboard mode-switch update cost-report debt-log micro-adr
  prototype taste-review branch-vibe explain-back graduate
  discovery project-scan setup-stack arch-design summarize-arch
  sprint-kickoff review gate-check
)

extract_sh_list() {
    local name="$1"
    awk -v marker="${name}=(" '
        index($0, marker) > 0 { grab=1 }
        grab { print }
        grab && $0 ~ /^\)/ { grab=0 }
    ' "$SH_INSTALLER" | grep -oE '"[^"]+"' | tr -d '"'
}

extract_ps1_list() {
    local name="$1"
    awk -v marker="\$${name} = @(" '
        index($0, marker) > 0 { grab=1 }
        grab { print }
        grab && $0 ~ /^\)/ { grab=0 }
    ' "$PS1_INSTALLER" | grep -oE '"[^"]+"' | tr -d '"'
}

@test "sh and ps1 installers ship the identical CORE_FILES list" {
    diff <(extract_sh_list CORE_FILES) <(extract_ps1_list CoreFiles)
}

@test "sh and ps1 installers ship the identical VIBE_FILES list" {
    diff <(extract_sh_list VIBE_FILES) <(extract_ps1_list VibeFiles)
}

@test "sh and ps1 installers ship the identical STUDIO_FILES list" {
    diff <(extract_sh_list STUDIO_FILES) <(extract_ps1_list StudioFiles)
}

@test "every entry in the combined installer file lists exists in the repo" {
    local missing=0
    for entry in $(extract_sh_list CORE_FILES) $(extract_sh_list VIBE_FILES) $(extract_sh_list STUDIO_FILES); do
        if [ ! -e "$REPO_ROOT/$entry" ]; then
            echo "installer lists a source that does not exist: $entry"
            missing=1
        fi
    done
    [ "$missing" -eq 0 ]
}

@test "every skill/agent/rule dir or file is covered by an installer list" {
    local all_entries
    all_entries=$(extract_sh_list CORE_FILES; extract_sh_list VIBE_FILES; extract_sh_list STUDIO_FILES)
    local uncovered=0
    for d in "$SKILLS_DIR"/*/; do
        local rel=".claude/skills/$(basename "$d")"
        echo "$all_entries" | grep -qxF "$rel" || { echo "unshipped skill: $rel"; uncovered=1; }
    done
    for f in "$REPO_ROOT/.claude/agents"/*.md; do
        local rel=".claude/agents/$(basename "$f")"
        echo "$all_entries" | grep -qxF "$rel" || { echo "unshipped agent: $rel"; uncovered=1; }
    done
    for f in "$REPO_ROOT/.claude/rules"/*.md; do
        local rel=".claude/rules/$(basename "$f")"
        echo "$all_entries" | grep -qxF "$rel" || { echo "unshipped rule: $rel"; uncovered=1; }
    done
    [ "$uncovered" -eq 0 ]
}

@test "every command in skills-reference.md matches a skill dir, and vice versa" {
    local ref_cmds dir_cmds
    ref_cmds=$(grep -oE '/(usds|vibe|studio)-[a-z-]+' "$SKILLS_REF" | sed 's#^/##' | sort -u)
    dir_cmds=$(for d in "$SKILLS_DIR"/*/; do basename "$d"; done | sort -u)
    diff <(echo "$ref_cmds") <(echo "$dir_cmds")
}

@test "CLAUDE.md's v2.1 rename table lists exactly the 20 renamed-away names" {
    local extracted expected
    extracted=$(grep -E '\| `/[a-zA-Z-]+`.*\| `/[a-zA-Z-]+`' "$CLAUDE_MD" | while IFS= read -r line; do
        local toks=()
        while IFS= read -r t; do toks+=("$t"); done < <(echo "$line" | grep -oE '`/[a-zA-Z-]+`' | tr -d '`/')
        for ((i=0; i<${#toks[@]}; i+=2)); do
            echo "${toks[$i]}"
        done
    done | sort)
    expected=$(printf '%s\n' "${RENAMED_AWAY[@]}" | sort)
    diff <(echo "$expected") <(echo "$extracted")
}

@test "VERSION file matches the version mentioned in SYSTEM-MAP.md" {
    local v
    v=$(tr -d '[:space:]' < "$REPO_ROOT/.claude/VERSION")
    grep -qF "$v" "$REPO_ROOT/docs/arch/SYSTEM-MAP.md"
}

@test "AGENTS.md exists and is shipped by both installers (ADR-004/D1)" {
    [ -f "$REPO_ROOT/AGENTS.md" ]
    local all_entries
    all_entries=$(extract_sh_list CORE_FILES)
    echo "$all_entries" | grep -qxF "AGENTS.md"
    all_entries=$(extract_ps1_list CoreFiles)
    echo "$all_entries" | grep -qxF "AGENTS.md"
}

@test "CLAUDE.md and AGENTS.md cross-reference each other (sync marker present)" {
    grep -q "AGENTS.md" "$CLAUDE_MD"
    grep -q "CLAUDE.md" "$REPO_ROOT/AGENTS.md"
}
