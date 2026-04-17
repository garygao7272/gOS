#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Plan Gate — PreToolUse (Edit | Write | Bash git-mutations)
#
# Reads the Plan Gate section of sessions/scratchpad.md (written by
# plan-gate-prompt.sh on UserPromptSubmit). If STATE=pending, blocks
# the tool call with exit 2.
#
# STATE values written by plan-gate-prompt.sh:
#   pending             → block Edit/Write/Bash-git-ops (exit 2)
#   approved-<ts>       → allow (exit 0)
#   bypassed-<ts>       → allow (exit 0)
#   <absent>            → allow (no gate active)
#
# Also retains design-specific gates (state matrix, reference research)
# when Mode line indicates Design — preserves prior behavior.
# ═══════════════════════════════════════════════════════════

set -euo pipefail

# Use hook-utils.sh parser — it handles jq failure gracefully. Previously
# the raw `jq ... 2>/dev/null` calls combined with `set -e` meant a parse
# failure exited the hook with status 1, which Claude Code treats as
# "hook errored" (advisory), not "block" (exit 2). Malformed input
# bypassed the gate entirely. Sourcing _parse_hook_input sets HOOK_TOOL_NAME,
# HOOK_FILE_PATH, HOOK_COMMAND with empty-string defaults on any parse issue.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=hook-utils.sh
source "$SCRIPT_DIR/hook-utils.sh"
_parse_hook_input

PROJECT_DIR="${HOOK_PROJECT_DIR:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"

[ -f "$SCRATCHPAD" ] || exit 0

# Only gate Edit, Write, and mutating git Bash commands.
case "$HOOK_TOOL_NAME" in
    Edit|Write) ;;
    Bash)
        case "$HOOK_COMMAND" in
            *"git commit"*|*"git push"*|*"git merge"*|*"git rebase"*|*"git reset --hard"*) ;;
            *) exit 0 ;;
        esac
        ;;
    *) exit 0 ;;
esac

STATE="$(awk '
    /^## Plan Gate/ { in_section = 1; next }
    /^## / && in_section { exit }
    in_section && /^STATE:/ { sub(/^STATE:[[:space:]]*/, ""); print; exit }
' "$SCRATCHPAD" 2>/dev/null)"

REQUIRED="$(awk '
    /^## Plan Gate/ { in_section = 1; next }
    /^## / && in_section { exit }
    in_section && /^REQUIRED:/ { sub(/^REQUIRED:[[:space:]]*/, ""); print; exit }
' "$SCRATCHPAD" 2>/dev/null)"

# --- hard block on pending ---------------------------------------------------
if [ "$STATE" = "pending" ]; then
    echo "PLAN GATE: blocked '$HOOK_TOOL_NAME' on '${HOOK_FILE_PATH:-${HOOK_COMMAND}}'." >&2
    echo "Command awaiting plan approval: ${REQUIRED:-unknown}" >&2
    echo "" >&2
    echo "To proceed:" >&2
    echo "  1. Present: PLAN → STEPS → MEMORY → RISK → CONFIDENCE → Confirm?" >&2
    echo "  2. Wait for Gary's reply." >&2
    echo "  3. On y/yes/go/approved → STATE flips, unblocks." >&2
    echo "  4. On 'just do it'/'skip plan' → STATE flips to bypassed, unblocks." >&2
    exit 2
fi

# --- design-specific gates (preserved) --------------------------------------
MODE=$(sed -n '/^## Mode/,/^##/{/^## Mode/d;/^##/d;p;}' "$SCRATCHPAD" 2>/dev/null | head -1 | xargs)

case "$MODE" in
    *[Dd]esign*)
        TARGET="${HOOK_FILE_PATH:-}"
        case "$TARGET" in
            */think/design/*|*/specs/Arx_4-1-*|*/web-prototype/drafts/*)
                grep -q "## State Matrix\|STATE_MATRIX_DONE\|state matrix" "$SCRATCHPAD" 2>/dev/null || {
                    echo "DESIGN GATE 0: Writing to '$TARGET' but no state matrix found in scratchpad." >&2
                    echo "Before writing any screen spec, generate the state matrix (all states × journey × data × edge cases)." >&2
                    echo "Write '## State Matrix' section to scratchpad, then retry." >&2
                    exit 2
                }
                grep -q "## Reference Research\|## Design References\|REFERENCE_RESEARCH_DONE\|reference research" "$SCRATCHPAD" 2>/dev/null || {
                    echo "DESIGN GATE -1: Writing to '$TARGET' but no reference research found in scratchpad." >&2
                    echo "Before writing any screen spec, research 3+ reference apps that handle this pattern." >&2
                    echo "Write '## Reference Research' section to scratchpad with findings, then retry." >&2
                    exit 2
                }
                ;;
        esac
        ;;
esac

exit 0
