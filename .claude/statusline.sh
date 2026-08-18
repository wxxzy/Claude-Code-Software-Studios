#!/usr/bin/env bash
# USDS v2 — Status Line
# Receives JSON on stdin, outputs a single-line status.
#
# Format: ctx: X% | Model | mode[:project] [| Round N | Epic > Feature > Task]

input=$(cat)

# --- Parse JSON (jq with grep fallback) ---
if command -v jq &>/dev/null; then
  model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
  used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
  cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
else
  model=$(echo "$input" | grep -oE '"display_name"\s*:\s*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"//')
  used_pct=$(echo "$input" | grep -oE '"used_percentage"\s*:\s*[0-9]+' | head -1 | sed 's/.*: *//')
  cwd=$(echo "$input" | grep -oE '"current_dir"\s*:\s*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"//')
  [ -z "$model" ] && model="Unknown"
fi

# Normalize Windows paths
cwd=$(echo "$cwd" | sed 's|\\|/|g')
[ -z "$cwd" ] && cwd="."

# --- Context usage ---
if [ -n "$used_pct" ]; then
  ctx_label="ctx: ${used_pct}%"
else
  ctx_label="ctx: --"
fi

# --- Mode detection (from .usds-mode) ---
mode_file="$cwd/.usds-mode"
mode="studio"  # default per CLAUDE.md
if [ -f "$mode_file" ]; then
  detected=$(grep -m1 '^mode:' "$mode_file" 2>/dev/null | sed 's/^mode: *//' | tr -d '\r\n[:space:]')
  case "$detected" in
    vibe|studio|hybrid) mode="$detected" ;;
  esac
fi

# --- Active project detection ---
# Vibe: most recent sandbox/<name>/
# Studio: from production/session-state/active.md
project=""

if [ "$mode" = "vibe" ] || [ "$mode" = "hybrid" ]; then
  # Newest sandbox project (excluding archive)
  if [ -d "$cwd/sandbox" ]; then
    project=$(find "$cwd/sandbox" -mindepth 1 -maxdepth 1 -type d ! -name 'archive' -printf '%T@ %f\n' 2>/dev/null \
      | sort -rn | head -1 | awk '{print $2}')
  fi
fi

# Studio fallback: try lite-spec / PRD project name
if [ -z "$project" ] && [ -f "$cwd/docs/specs/lite-spec.md" ]; then
  project=$(grep -m1 '^# ' "$cwd/docs/specs/lite-spec.md" 2>/dev/null \
    | sed 's/^# *//;s/ *Lite Spec.*//;s/^\[//;s/\]$//' | tr -d '\r\n')
fi

# --- Work-item breadcrumb ---
breadcrumb=""

# Vibe: show intent-log Round count
if [ "$mode" = "vibe" ] || [ "$mode" = "hybrid" ]; then
  intent_log="$cwd/docs/specs/intent-log.md"
  if [ -f "$intent_log" ]; then
    round_count=$(grep -cE '^## Round [0-9]+' "$intent_log" 2>/dev/null || echo 0)
    if [ "$round_count" -gt 0 ] 2>/dev/null; then
      breadcrumb=" | Round ${round_count}"
    fi
  fi
fi

# Studio: parse active.md STATUS block (preserved from v1)
if [ "$mode" = "studio" ] || [ "$mode" = "hybrid" ]; then
  state_file="$cwd/production/session-state/active.md"
  if [ -f "$state_file" ]; then
    in_block=false
    epic="" feature="" task=""
    while IFS= read -r line; do
      case "$line" in
        *"<!-- STATUS -->"*) in_block=true; continue ;;
        *"<!-- /STATUS -->"*) break ;;
      esac
      if [ "$in_block" = true ]; then
        case "$line" in
          Epic:*)    epic=$(echo "$line" | sed 's/^Epic: *//;s/[[:space:]]*$//') ;;
          Feature:*) feature=$(echo "$line" | sed 's/^Feature: *//;s/[[:space:]]*$//') ;;
          Task:*)    task=$(echo "$line" | sed 's/^Task: *//;s/[[:space:]]*$//') ;;
        esac
      fi
    done < "$state_file"

    parts=""
    [ -n "$epic" ] && parts="$epic"
    [ -n "$feature" ] && parts="${parts:+$parts > }$feature"
    [ -n "$task" ] && parts="${parts:+$parts > }$task"
    if [ -n "$parts" ]; then
      # Studio breadcrumb replaces (not appends to) vibe round
      breadcrumb=" | $parts"
    fi
  fi
fi

# --- Assemble mode segment ---
if [ -n "$project" ]; then
  mode_label="${mode}:${project}"
else
  mode_label="${mode}"
fi

# --- Output ---
printf "%s" "${ctx_label} | ${model} | ${mode_label}${breadcrumb}"
