#!/usr/bin/env bash
# gOS Hook: Phase Gate (PreToolUse, matcher: Edit|Write)
# HARD GATE: enforces think → design → build phase chain.
# /design requires sessions/handoffs/think.json (approved /think output)
# /build requires sessions/handoffs/design.json (approved /design output)
# /think, /review, /ship, /evolve, /simulate — not gated.
# Bypass: write PHASE_GATE_SKIP to scratchpad (for emergencies/hotfixes).

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null) || exit 0

case "$TOOL_NAME" in
  Edit|Write) ;;
  *) exit 0 ;;
esac

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"
HANDOFFS_DIR="$PROJECT_DIR/sessions/handoffs"

[ -f "$SCRATCHPAD" ] || exit 0

# Extract current mode
MODE=$(sed -n '/^## Mode/,/^##/{/^## Mode/d;/^##/d;p;}' "$SCRATCHPAD" 2>/dev/null | head -1 | xargs) || true
[ -n "$MODE" ] || exit 0

# Check for explicit bypass
grep -q "PHASE_GATE_SKIP" "$SCRATCHPAD" 2>/dev/null && exit 0

# Determine required prior phase
REQUIRED_PHASE=""
case "$MODE" in
  *[Dd]esign*) REQUIRED_PHASE="think" ;;
  *[Bb]uild*)  REQUIRED_PHASE="design" ;;
  *) exit 0 ;;  # think, review, ship, evolve, simulate — not gated
esac

# Check for handoff artifact
HANDOFF="$HANDOFFS_DIR/${REQUIRED_PHASE}.json"
if [ -f "$HANDOFF" ]; then
  exit 0
fi

# BLOCK: prior phase not completed
echo "PHASE GATE: /${MODE##*>/} requires /${REQUIRED_PHASE} output first." >&2
echo "Run /${REQUIRED_PHASE} and approve its output, which creates sessions/handoffs/${REQUIRED_PHASE}.json" >&2
echo "Emergency bypass: write PHASE_GATE_SKIP to scratchpad" >&2
exit 2
