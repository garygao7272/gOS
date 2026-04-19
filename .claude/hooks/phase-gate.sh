#!/usr/bin/env bash
# gOS Hook: Phase Gate (PreToolUse, matcher: Edit|Write)
# HARD GATE: enforces think → design → build phase chain — but ONLY on actual
# design-spec and build-card artifacts. Framework writes (memory/, rules/,
# agents/, tests/, tools/, hooks/, commands/, outputs/think/, outputs/refine/,
# sessions/) are never gated, because stale scratchpad Mode was causing false
# blocks on /evolve, /ship, /think writes across unrelated paths.
#
# Gated targets (narrow allowlist):
#   specs/Arx_4-1* → requires design handoff (build cards)
#   specs/Arx_4-2* → requires think handoff (design system)
#   apps/*         → requires design handoff (implementation)
#
# Every other target is ungated. Ground truth is the target path, not the
# scratchpad Mode — Mode drifts across a session, paths don't.
#
# Bypass: write PHASE_GATE_SKIP to scratchpad (for emergencies/hotfixes).

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null) || exit 0

case "$TOOL_NAME" in
  Edit|Write) ;;
  *) exit 0 ;;
esac

# Extract target file path — gate only fires on build/design artifacts.
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null) || FILE_PATH=""

# Determine required prior phase from the TARGET PATH (ground truth).
REQUIRED_PHASE=""
case "$FILE_PATH" in
  */specs/Arx_4-2*) REQUIRED_PHASE="think" ;;
  */specs/Arx_4-1*) REQUIRED_PHASE="design" ;;
  */apps/*)         REQUIRED_PHASE="design" ;;
  *) exit 0 ;;  # ungated target
esac

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"
HANDOFFS_DIR="$PROJECT_DIR/sessions/handoffs"

# Check for explicit bypass in scratchpad
[ -f "$SCRATCHPAD" ] && grep -q "PHASE_GATE_SKIP" "$SCRATCHPAD" 2>/dev/null && exit 0

# Check for handoff artifact
HANDOFF="$HANDOFFS_DIR/${REQUIRED_PHASE}.json"
if [ -f "$HANDOFF" ]; then
  exit 0
fi

# BLOCK: prior phase not completed
echo "PHASE GATE: write to ${FILE_PATH#*gOS/} requires /${REQUIRED_PHASE} output first." >&2
echo "Run /${REQUIRED_PHASE} and approve its output, which creates sessions/handoffs/${REQUIRED_PHASE}.json" >&2
echo "Emergency bypass: write PHASE_GATE_SKIP to scratchpad" >&2
exit 2
