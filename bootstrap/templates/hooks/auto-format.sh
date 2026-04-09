#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Auto-Formatter
# Event: PostToolUse (Edit|Write)
# Runs appropriate formatter based on file extension
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/hook-utils.sh"
_parse_hook_input

[ -n "$HOOK_FILE_PATH" ] && [ -f "$HOOK_FILE_PATH" ] || exit 0

case "${HOOK_FILE_PATH##*.}" in
    js|jsx|ts|tsx|css|scss|html|json|md)
        command -v npx &>/dev/null && npx prettier --write "$HOOK_FILE_PATH" 2>/dev/null || true ;;
    py)
        if command -v black &>/dev/null; then
            black --quiet "$HOOK_FILE_PATH" 2>/dev/null || true
        elif command -v autopep8 &>/dev/null; then
            autopep8 --in-place "$HOOK_FILE_PATH" 2>/dev/null || true
        fi ;;
esac

exit 0
