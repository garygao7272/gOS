#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Claw Runner
# Generic execution wrapper for persistent claws
# Usage: claw-runner.sh <claw-name>
# Reads claw.md for instructions, updates state.json
# ═══════════════════════════════════════════════════════════

set -euo pipefail

CLAW_NAME="${1:-}"
CLAWS_DIR="$HOME/.claude/claws"

if [ -z "$CLAW_NAME" ]; then
    echo "Usage: claw-runner.sh <claw-name>"
    echo "Available claws:"
    ls "$CLAWS_DIR" 2>/dev/null | while read -r dir; do
        if [ -f "$CLAWS_DIR/$dir/claw.md" ]; then
            SCHED=$(grep -oP 'schedule:\s*`\K[^`]+' "$CLAWS_DIR/$dir/claw.md" 2>/dev/null || echo "manual")
            echo "  $dir ($SCHED)"
        fi
    done
    exit 1
fi

CLAW_DIR="$CLAWS_DIR/$CLAW_NAME"
CLAW_MD="$CLAW_DIR/claw.md"
STATE_FILE="$CLAW_DIR/state.json"

if [ ! -f "$CLAW_MD" ]; then
    echo "Error: Claw '$CLAW_NAME' not found at $CLAW_DIR"
    exit 1
fi

if [ ! -f "$STATE_FILE" ]; then
    echo "Error: No state.json for claw '$CLAW_NAME'"
    exit 1
fi

# Update state: mark as running
python3 -c "
import json
from datetime import datetime

with open('$STATE_FILE', 'r') as f:
    state = json.load(f)

state['last_run'] = datetime.now().isoformat()
state['run_count'] = state.get('run_count', 0) + 1

with open('$STATE_FILE', 'w') as f:
    json.dump(state, f, indent=2)
" 2>/dev/null

# Output the claw instructions for Claude to execute
echo "CLAW EXECUTION: $CLAW_NAME"
echo "Instructions:"
cat "$CLAW_MD"
echo ""
echo "Current state:"
cat "$STATE_FILE"
echo ""
echo "Execute the steps described in the claw instructions above. Update $STATE_FILE when done."

exit 0
