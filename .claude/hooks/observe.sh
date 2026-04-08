#!/usr/bin/env bash
# gOS Hook: Observe (PreToolUse + PostToolUse, matcher: .*, async: true)
# Captures tool invocations as JSONL for offline analysis.
# Usage: observe.sh start   (PreToolUse — records invocation)
#        observe.sh complete (PostToolUse — records completion)
set -euo pipefail

PHASE="${1:-start}"
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')

LOG_DIR="/tmp/gos-observations"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/${SESSION_ID}.jsonl"

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

case "$PHASE" in
  start)
    # Extract key parameters (truncated to avoid bloat)
    PARAMS=$(echo "$INPUT" | jq -c '{
      file_path: (.tool_input.file_path // null),
      command: (.tool_input.command // null | if . then .[0:120] else null end),
      pattern: (.tool_input.pattern // null)
    } | with_entries(select(.value != null))' 2>/dev/null || echo '{}')

    echo "{\"ts\":\"${TIMESTAMP}\",\"phase\":\"start\",\"tool\":\"${TOOL_NAME}\",\"params\":${PARAMS}}" >> "$LOG_FILE"
    ;;
  complete)
    # Just record completion — don't capture full output (too large)
    echo "{\"ts\":\"${TIMESTAMP}\",\"phase\":\"complete\",\"tool\":\"${TOOL_NAME}\"}" >> "$LOG_FILE"
    ;;
esac

# Rotate: keep last 500 lines
if [ -f "$LOG_FILE" ] && [ "$(wc -l < "$LOG_FILE")" -gt 500 ]; then
  tail -500 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

exit 0
