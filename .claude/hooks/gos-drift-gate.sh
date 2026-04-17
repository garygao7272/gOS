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

# Detect gOS by the remote URL, not by path prefix. This makes the hook work
# on any clone / any workspace rename, and avoids the CLAUDE_PROJECT_DIR-unset
# trap where HOOK_PROJECT_DIR silently falls back to $(pwd) = / or $HOME and
# the scope filter passes spuriously.
#
# The hook lives at <repo>/.claude/hooks/gos-drift-gate.sh, so when it's
# invoked from the source repo we can derive GOS_DIR from $(dirname "$0").
# But when Claude Code invokes it, the installed copy lives at
# ~/.claude/hooks/ — so we fall back to: ask git about the CWD and match the
# remote URL against the known gOS repo URL.

GOS_REMOTE_PATTERN="gOS\.git$|garygao7272/gOS"
CWD="${HOOK_PROJECT_DIR:-$(pwd)}"
REMOTE_URL="$(git -C "$CWD" config --get remote.origin.url 2>/dev/null || echo "")"

# Scope: either we're inside a clone of gOS (remote matches) or we bail out.
case "$REMOTE_URL" in
    *gOS.git*|*garygao7272/gOS*) ;;
    *) exit 0 ;;
esac

# Resolve GOS_DIR to the repo root of the CWD we just verified.
GOS_DIR="$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "")"
[ -d "$GOS_DIR" ] && [ -x "$GOS_DIR/tools/sync-gos.sh" ] || exit 0

# Delegate to sync-gos.sh verify-only; it exits non-zero on drift.
if ! bash "$GOS_DIR/tools/sync-gos.sh" --verify-only --quiet >/dev/null 2>&1; then
    echo "BLOCKED: gOS sync drift detected before git push." >&2
    echo "User install or plugin cache out of sync with source." >&2
    echo "Run: bash \"$GOS_DIR/tools/sync-gos.sh\" --quiet" >&2
    echo "Then retry the push." >&2
    exit 2
fi

exit 0
