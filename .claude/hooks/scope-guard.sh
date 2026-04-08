#!/usr/bin/env bash
# gOS Hook: Scope Guard (PreToolUse, matcher: Edit|Write)
# Enforces /gos freeze — blocks file edits outside the frozen directory.
# Reads freeze scope from /tmp/claude-freeze-scope.
set -euo pipefail

FREEZE_FILE="/tmp/claude-freeze-scope"
[ -f "$FREEZE_FILE" ] || exit 0

FROZEN_DIR=$(head -1 "$FREEZE_FILE" 2>/dev/null | xargs)
[ -n "$FROZEN_DIR" ] || exit 0

# Parse the hook input to get the target file path
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
FILE_PATH=""

case "$TOOL_NAME" in
  Edit)  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""') ;;
  Write) FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""') ;;
  *)     exit 0 ;;
esac

[ -n "$FILE_PATH" ] || exit 0

# Resolve paths for comparison
FROZEN_ABS=$(cd "$FROZEN_DIR" 2>/dev/null && pwd || echo "$FROZEN_DIR")

case "$FILE_PATH" in
  ${FROZEN_ABS}*)
    exit 0
    ;;
  *)
    echo "FROZEN: Edits scoped to ${FROZEN_DIR}. Target ${FILE_PATH} is outside scope. Use /gos freeze off to unlock."
    exit 2
    ;;
esac
