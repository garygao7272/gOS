#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Prototype Version Guard
# Event: PreToolUse (Edit|Write)
# Warns if editing prototype without version bump
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/hook-utils.sh"
_parse_hook_input

[ -n "$HOOK_FILE_PATH" ] || exit 0

if echo "$HOOK_FILE_PATH" | grep -q "apps/web-prototype/index.html"; then
    echo "REMINDER: You are editing the prototype. Run ./apps/web-prototype/bump.sh after changes."
fi

exit 0
