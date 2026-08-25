#!/bin/bash
# Claude Code SubagentStart hook: vibe-check iteration counter (ADR-004)
# "每 3-5 轮迭代必须 /vibe-check 校准意图" was a convention with no mechanism
# behind it. This counts /vibe-prototype (agent: explorer) invocations since
# the last /vibe-check (agent: explainer) invocation, and nudges once the
# count reaches 4, then every 2 rounds after — only while in vibe/hybrid mode.
# Convention: silent unless there is something to say.
#
# Input schema (SubagentStart):
# { "agent_id": "agent-abc123", "agent_name": "explorer", ... }

INPUT=$(cat)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/json.sh
source "$SCRIPT_DIR/lib/json.sh"
AGENT_NAME=$(usds_json_str "$INPUT" .agent_name)

# Only relevant in vibe/hybrid mode (studio-only projects never see explorer/explainer)
MODE="studio"
if [ -f ".usds-mode" ]; then
    MODE=$(grep -m1 '^mode:' ".usds-mode" 2>/dev/null | sed 's/^mode: *//' | tr -d '\r\n[:space:]')
fi
case "$MODE" in
    vibe|hybrid) ;;
    *) exit 0 ;;
esac

STATE_DIR="production/session-state"
COUNTER_FILE="$STATE_DIR/.vibe-check-counter"
mkdir -p "$STATE_DIR" 2>/dev/null

case "$AGENT_NAME" in
    explainer)
        # /vibe-check just ran: calibration happened, reset the counter
        echo 0 > "$COUNTER_FILE" 2>/dev/null
        ;;
    explorer)
        # /vibe-prototype iteration: increment and nudge at 4, 6, 8, ...
        local_count=0
        [ -f "$COUNTER_FILE" ] && local_count=$(cat "$COUNTER_FILE" 2>/dev/null)
        case "$local_count" in ''|*[!0-9]*) local_count=0 ;; esac
        local_count=$((local_count + 1))
        echo "$local_count" > "$COUNTER_FILE" 2>/dev/null
        if [ "$local_count" -ge 4 ] && [ $(( (local_count - 4) % 2 )) -eq 0 ]; then
            echo "⚠️ 已连续 ${local_count} 轮原型迭代未校准意图，建议现在跑 /vibe-check"
        fi
        ;;
    *)
        exit 0
        ;;
esac

exit 0
