#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Plan Gate (v2)
# Event: PreToolUse (Edit|Write)
# Blocks file edits during /think, /build, /design until
# plan mode has been approved (Plan: APPROVED in scratchpad)
# v2: Actually blocks (exit 2) instead of just warning
# v2: Also checks Pipeline State marker
# ═══════════════════════════════════════════════════════════

set -euo pipefail

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"

# Parse file path — only gate writes to outputs/ and apps/
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print(ti.get('file_path', '') or ti.get('filePath', ''))
" 2>/dev/null)

case "$FILE_PATH" in
    */outputs/*|*/apps/*) ;;
    *) exit 0 ;;
esac

# No scratchpad = not in a gOS command session → allow
if [ ! -f "$SCRATCHPAD" ]; then
    exit 0
fi

# Read the mode from scratchpad (line after "## Mode & Sub-command")
MODE=$(sed -n '/^## Mode/,/^##/{/^## Mode/d;/^##/d;p;}' "$SCRATCHPAD" 2>/dev/null | head -1 | xargs)

# No mode set or empty → allow
if [ -z "$MODE" ] || [ "$MODE" = "(awaiting routing)" ] || [ "$MODE" = "gOS > (awaiting routing)" ]; then
    exit 0
fi

# Only gate modes that require planning
NEEDS_PLAN=false
case "$MODE" in
    *[Tt]hink*) NEEDS_PLAN=true ;;
    *[Bb]uild*) NEEDS_PLAN=true ;;
    *[Dd]esign*) NEEDS_PLAN=true ;;
    *[Gg]oS*conductor*) NEEDS_PLAN=true ;;
    *) ;;
esac

# Bypass modes that don't need plans
case "$MODE" in
    *[Aa]side*) NEEDS_PLAN=false ;;
    *[Ss]hip*) NEEDS_PLAN=false ;;
    *[Rr]eview*) NEEDS_PLAN=false ;;
    *[Ee]volve*) NEEDS_PLAN=false ;;
    *[Ss]imulate*) NEEDS_PLAN=false ;;
    *fix*) NEEDS_PLAN=false ;;
    *tdd*) NEEDS_PLAN=false ;;
    *quick*) NEEDS_PLAN=false ;;
    *) ;;
esac

if [ "$NEEDS_PLAN" = "false" ]; then
    exit 0
fi

# Check for plan approval marker (Pipeline State or legacy format)
if grep -q "\- \[x\] Plan Approved:" "$SCRATCHPAD" 2>/dev/null; then
    exit 0
fi
if grep -q "Plan: APPROVED\|PLAN_APPROVED\|plan approved" "$SCRATCHPAD" 2>/dev/null; then
    exit 0
fi

# BLOCK — plan not approved yet (exit 2 = deny)
echo "⛔ PLAN GATE: Mode is '$MODE' but no plan has been approved yet."
echo "   Use EnterPlanMode → present approach → get approval → mark"
echo "   '- [x] Plan Approved: ...' in scratchpad Pipeline State."
exit 2
