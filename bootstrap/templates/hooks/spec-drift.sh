#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Spec Drift Detector
# Event: PostToolUse (Edit|Write)
# After editing apps/, flags if corresponding spec needs updating
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/hook-utils.sh"
_parse_hook_input

[ -n "$HOOK_FILE_PATH" ] || exit 0

REL_PATH="${HOOK_FILE_PATH#"$HOOK_PROJECT_DIR"/}"
echo "$REL_PATH" | grep -q "^apps/" || exit 0

SPEC_HINT=""
case "$REL_PATH" in
    apps/web-prototype/*) SPEC_HINT="specs/Arx_4-1-1-* (mobile screen specs)" ;;
    apps/mobile/*)        SPEC_HINT="specs/Arx_5-* (engineering specs)" ;;
esac

[ -n "$SPEC_HINT" ] && echo "SPEC SYNC REMINDER: You edited $REL_PATH. Check if $SPEC_HINT needs updating."
exit 0
