#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Freeze Guard
# Event: PreToolUse (Edit|Write)
# Blocks file edits outside the frozen scope directory
# ═══════════════════════════════════════════════════════════

set -euo pipefail

FREEZE_FILE="/tmp/claude-freeze-scope"
[ -f "$FREEZE_FILE" ] || exit 0

FROZEN_DIR=$(cat "$FREEZE_FILE" 2>/dev/null | head -1 | xargs)
[ -n "$FROZEN_DIR" ] || exit 0

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/hook-utils.sh"
_parse_hook_input

[ -n "$HOOK_FILE_PATH" ] || exit 0

FROZEN_ABS=$(cd "${FROZEN_DIR}" 2>/dev/null && pwd || echo "$FROZEN_DIR")
TARGET_DIR=$(dirname "$HOOK_FILE_PATH")
TARGET_ABS=$(cd "$TARGET_DIR" 2>/dev/null && echo "$(pwd)/$(basename "$HOOK_FILE_PATH")" || echo "$HOOK_FILE_PATH")

case "$TARGET_ABS" in
    ${FROZEN_ABS}*) exit 0 ;;
    *) echo "FROZEN: Edits scoped to $FROZEN_DIR. File $HOOK_FILE_PATH is outside scope. Use /gos freeze off to unlock." ; exit 0 ;;
esac
