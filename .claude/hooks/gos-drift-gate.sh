#!/bin/bash
# gos-drift-gate.sh — blocks `git push` from the gOS repo if source/user-install/plugin-cache drift.
#
# Event: PreToolUse (Bash)
# Fires on: git push commands run with CWD inside the gOS repo.
# Elsewhere: fast exit 0 (no effect).
#
# Mechanism: delegates to `tools/sync-gos.sh --verify-only`. That script exits
# non-zero on drift. We translate non-zero → exit 2 so the hook actually
# BLOCKS the push (Claude Code hooks contract: exit 2 = block with stderr as
# reason; exit 1 is advisory and does not block).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=hook-utils.sh
source "$SCRIPT_DIR/hook-utils.sh"
_parse_hook_input

# Only act on Bash tool calls that are actually git push.
[ "$HOOK_TOOL_NAME" = "Bash" ] || exit 0
case "$HOOK_COMMAND" in
    *"git push"*) ;;
    *) exit 0 ;;
esac

# Only act when the push is from inside the gOS repo — other projects are not our concern.
GOS_DIR="$HOME/Documents/Documents - SG-LT674/Claude Working Folder/gOS"
[ -d "$GOS_DIR" ] || exit 0
case "$HOOK_PROJECT_DIR" in
    "$GOS_DIR"*) ;;
    *) exit 0 ;;
esac

# Delegate to sync-gos.sh verify-only; it exits non-zero on drift.
if ! bash "$GOS_DIR/tools/sync-gos.sh" --verify-only --quiet >/dev/null 2>&1; then
    echo "BLOCKED: gOS sync drift detected before git push." >&2
    echo "User install or plugin cache out of sync with source." >&2
    echo "Run: bash \"$GOS_DIR/tools/sync-gos.sh\" --quiet" >&2
    echo "Then retry the push." >&2
    exit 2
fi

exit 0
