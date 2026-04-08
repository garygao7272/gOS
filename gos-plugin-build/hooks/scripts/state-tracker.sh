#!/bin/bash
# ═══════════════════════════════════════════════════════════
# State Machine Tracker
# Event: PostToolUse (all tools)
# Updates sessions/state.json on phase-transition tool calls
# ═══════════════════════════════════════════════════════════

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_FILE="$PROJECT_DIR/sessions/state.json"
SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"

# Only run if state.json exists
if [ ! -f "$STATE_FILE" ]; then
    exit 0
fi

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")

# Only update on phase-transition tools
case "$TOOL_NAME" in
    EnterPlanMode|ExitPlanMode|Agent|Skill)
        ;;
    Bash)
        # Only if it's a git commit
        TOOL_INPUT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")
        case "$TOOL_INPUT" in
            *"git commit"*) ;;
            *) exit 0 ;;
        esac
        ;;
    *)
        exit 0
        ;;
esac

# Read current mode from scratchpad
MODE=""
if [ -f "$SCRATCHPAD" ]; then
    MODE=$(sed -n '/^## Mode/,/^##/{/^## Mode/d;/^##/d;p;}' "$SCRATCHPAD" 2>/dev/null | head -1 | xargs)
fi

# Determine phase from tool
PHASE=""
case "$TOOL_NAME" in
    EnterPlanMode) PHASE="PLANNING" ;;
    ExitPlanMode)  PHASE="PLAN_APPROVED" ;;
    Agent)         PHASE="AGENT_EXECUTING" ;;
    Skill)         PHASE="SKILL_EXECUTING" ;;
    Bash)          PHASE="COMMITTED" ;;
esac

# Read current step from state
CURRENT_STEP=$(python3 -c "import json; d=json.load(open('$STATE_FILE')); print(d.get('step',0))" 2>/dev/null || echo "0")
NEW_STEP=$((CURRENT_STEP + 1))

# Get recently modified file from tool_input
MODIFIED_FILE=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print(ti.get('file_path', ti.get('command', ''))[:100])
" 2>/dev/null || echo "")

# Update state.json
python3 -c "
import json, sys
from datetime import datetime

state_file = '$STATE_FILE'
with open(state_file, 'r') as f:
    state = json.load(f)

state['current_command'] = '''$MODE''' or state.get('current_command')
state['phase'] = '$PHASE'
state['step'] = $NEW_STEP
state['last_checkpoint'] = datetime.now().isoformat()

modified = '$MODIFIED_FILE'
if modified and modified not in state.get('files_modified', []):
    state.setdefault('files_modified', []).append(modified)
    # Keep only last 20
    state['files_modified'] = state['files_modified'][-20:]

state['recovery_instructions'] = f'Resume at step {$NEW_STEP}: phase={state[\"phase\"]}, mode={state[\"current_command\"]}'

with open(state_file, 'w') as f:
    json.dump(state, f, indent=2)
" 2>/dev/null

exit 0
