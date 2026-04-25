#!/usr/bin/env bash
# gOS Hook: Accumulate (PostToolUse, matcher: Edit|Write)
# Tracks which files were edited this session for /gos save and drift detection.
set -euo pipefail

INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
DURATION_MS=$(echo "$INPUT" | jq -r '.duration_ms // 0')
FILE_PATH=""

case "$TOOL_NAME" in
  Edit)  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""') ;;
  Write) FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""') ;;
  *)     exit 0 ;;
esac

[ -n "$FILE_PATH" ] || exit 0

ACCUMULATOR="/tmp/gos-edits-${SESSION_ID}.log"
TIMESTAMP=$(date +%s)

# Append file path with timestamp + duration_ms (CC v2.1.119+).
# Format: timestamp|file_path|duration_ms — duration_ms enables evolve-loop tool-cost analysis.
echo "${TIMESTAMP}|${FILE_PATH}|${DURATION_MS}" >> "$ACCUMULATOR"

# Rotate: keep last 200 entries
if [ "$(wc -l < "$ACCUMULATOR")" -gt 200 ]; then
  tail -200 "$ACCUMULATOR" > "${ACCUMULATOR}.tmp" && mv "${ACCUMULATOR}.tmp" "$ACCUMULATOR"
fi

exit 0
