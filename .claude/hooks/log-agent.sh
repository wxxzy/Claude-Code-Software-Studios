#!/bin/bash
# Claude Code SubagentStart hook: Log agent invocations for audit trail
# Tracks which agents are being used and when
#
# Input schema (SubagentStart):
# { "agent_id": "agent-abc123", "agent_name": "lead-developer", ... }

INPUT=$(cat)

# Parse agent name via shared tiered helper (jq -> python -> regex), see ADR-001
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/json.sh
source "$SCRIPT_DIR/lib/json.sh"
AGENT_NAME=$(usds_json_str "$INPUT" .agent_name)
AGENT_NAME="${AGENT_NAME:-unknown}"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SESSION_LOG_DIR="production/session-logs"

mkdir -p "$SESSION_LOG_DIR" 2>/dev/null

echo "$TIMESTAMP | Agent invoked: $AGENT_NAME" >> "$SESSION_LOG_DIR/agent-audit.log" 2>/dev/null

exit 0
