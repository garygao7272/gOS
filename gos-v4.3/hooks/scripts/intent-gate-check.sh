#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Intent Gate Enforcer
# Event: PreToolUse (Edit|Write)
# Blocks file edits to outputs/ or apps/ unless the Intent
# Gate has been completed (all 6 MECE dimensions resolved
# in scratchpad Pipeline State section)
# ═══════════════════════════════════════════════════════════

set -euo pipefail

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"

# Parse file path from tool input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print(ti.get('file_path', '') or ti.get('filePath', ''))
" 2>/dev/null)

# Only gate writes to outputs/ and apps/
case "$FILE_PATH" in
    */outputs/*|*/apps/*) ;;
    *) exit 0 ;;
esac

# No scratchpad = not in a gOS session → allow
if [ ! -f "$SCRATCHPAD" ]; then
    exit 0
fi

# Check for Intent Gate completion marker with at least WHAT and SCOPE populated
# The marker format is: "- [x] Intent Gate: WHAT=... | ... | SCOPE=..."
# We verify the checkbox is checked AND at least WHAT= and SCOPE= are present
if grep -q "\- \[x\] Intent Gate:.*WHAT=" "$SCRATCHPAD" 2>/dev/null; then
    if grep -q "\- \[x\] Intent Gate:.*SCOPE=" "$SCRATCHPAD" 2>/dev/null; then
        exit 0
    fi
fi

# Check for legacy format (older sessions may use different markers)
if grep -q "WHAT:.\+\S" "$SCRATCHPAD" 2>/dev/null && \
   grep -q "WHY:.\+\S" "$SCRATCHPAD" 2>/dev/null && \
   grep -q "SCOPE:.\+\S" "$SCRATCHPAD" 2>/dev/null; then
    exit 0
fi

# Allow if mode is a conductor/meta operation (not producing artifacts)
MODE=$(awk '/^## Mode/{found=1; next} found && /^## /{exit} found && /^[^#]/ && NF{print; exit}' "$SCRATCHPAD" 2>/dev/null | xargs || true)
case "$MODE" in
    *Conductor*|*audit*|*status*|*save*|*resume*) exit 0 ;;
esac

# Block — Intent Gate not completed
echo "⛔ INTENT GATE: Cannot write to outputs/ or apps/ without completing the Intent Gate."
echo "   Resolve all 6 MECE dimensions (WHAT/WHY/WHO/HOW/SCOPE/BAR) and mark"
echo "   '- [x] Intent Gate: ...' in sessions/scratchpad.md Pipeline State section."
exit 2
