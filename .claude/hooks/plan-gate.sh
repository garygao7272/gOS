#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Plan Gate
# Event: PreToolUse (Edit|Write)
# Blocks file edits during /think, /build, /design until
# plan mode has been approved (Plan: APPROVED in scratchpad)
# ═══════════════════════════════════════════════════════════

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"

# No scratchpad = not in a gOS command session → allow
if [ ! -f "$SCRATCHPAD" ]; then
    exit 0
fi

# Read the mode from scratchpad (line after "## Mode & Sub-command")
MODE=$(sed -n '/^## Mode/,/^##/{/^## Mode/d;/^##/d;p;}' "$SCRATCHPAD" 2>/dev/null | head -1 | xargs)

# No mode set or empty → allow
if [ -z "$MODE" ] || [ "$MODE" = "(awaiting routing)" ]; then
    exit 0
fi

# Only gate modes that require planning
NEEDS_PLAN=false
case "$MODE" in
    *[Tt]hink*) NEEDS_PLAN=true ;;
    *[Bb]uild*) NEEDS_PLAN=true ;;
    *[Dd]esign*) NEEDS_PLAN=true ;;
    *) ;;
esac

# Bypass modes that don't need plans
case "$MODE" in
    *[Aa]side*) NEEDS_PLAN=false ;;
    *[Ss]hip*) NEEDS_PLAN=false ;;
    *[Rr]eview*) NEEDS_PLAN=false ;;
    *[Ee]volve*) NEEDS_PLAN=false ;;
    *[Ss]imulate*) NEEDS_PLAN=false ;;
    *) ;;
esac

if [ "$NEEDS_PLAN" = "false" ]; then
    exit 0
fi

# Check for plan approval marker in Working State section
# Check for plan approval marker anywhere in scratchpad
if grep -q "Plan: APPROVED\|PLAN_APPROVED\|plan approved" "$SCRATCHPAD" 2>/dev/null; then
    exit 0
fi

# Block — plan not approved yet
echo "⛔ PLAN GATE: Mode is '$MODE' but no plan has been approved yet. Use EnterPlanMode, present your approach, get approval, then write 'Plan: APPROVED' to scratchpad before editing files."

exit 0
