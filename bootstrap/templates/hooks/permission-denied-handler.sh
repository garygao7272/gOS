#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Permission Denied Handler
# Event: PermissionDenied
# Fires after auto mode classifier denies a tool call.
# Logs the denial and returns {retry: true} for known-safe
# patterns that are likely false positives.
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/hook-utils.sh"
_parse_hook_input

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"

# Log every denial to scratchpad for session visibility
if [ -f "$SCRATCHPAD" ]; then
    TIMESTAMP=$(date +%H:%M:%S)
    TOOL="${HOOK_TOOL_NAME:-unknown}"
    # Append under Dead Ends section
    sed -i.bak "/^## Dead Ends/a\\
- [$TIMESTAMP] Permission denied: $TOOL" "$SCRATCHPAD" 2>/dev/null
    rm -f "$SCRATCHPAD.bak"
fi

# Known-safe retry patterns:
# - Read/Glob/Grep are always safe (read-only)
# - Bash with git status/log/diff are read-only
case "$HOOK_TOOL_NAME" in
    Read|Glob|Grep)
        printf '{"retry": true}'
        exit 0
        ;;
    Bash)
        case "$HOOK_COMMAND" in
            "git status"*|"git log"*|"git diff"*|"git branch"*|"ls "*|"cat "*|"head "*|"wc "*|"find "*|"which "*|"echo "*)
                printf '{"retry": true}'
                exit 0
                ;;
        esac
        ;;
esac

# For everything else, don't retry — let the user decide
echo "{}"
exit 0
