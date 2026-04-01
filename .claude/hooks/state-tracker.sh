#!/bin/bash
# ═══════════════════════════════════════════════════════════
# State Machine Tracker
# Event: PostToolUse (all tools)
# Updates sessions/state.json on phase-transition tool calls
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/hook-utils.sh"
_parse_hook_input

STATE_FILE="$HOOK_PROJECT_DIR/sessions/state.json"
SCRATCHPAD="$HOOK_PROJECT_DIR/sessions/scratchpad.md"

[ -f "$STATE_FILE" ] || exit 0

# Only update on phase-transition tools
case "$HOOK_TOOL_NAME" in
    EnterPlanMode|ExitPlanMode|Agent|Skill) ;;
    Bash)
        case "$HOOK_COMMAND" in
            *"git commit"*) ;;
            *) exit 0 ;;
        esac
        ;;
    *) exit 0 ;;
esac

# Read mode from scratchpad
MODE=""
if [ -f "$SCRATCHPAD" ]; then
    MODE=$(sed -n '/^## Mode/,/^##/{/^## Mode/d;/^##/d;p;}' "$SCRATCHPAD" 2>/dev/null | head -1 | xargs)
fi

# Map tool to phase
case "$HOOK_TOOL_NAME" in
    EnterPlanMode) PHASE="PLANNING" ;;
    ExitPlanMode)  PHASE="PLAN_APPROVED" ;;
    Agent)         PHASE="AGENT_EXECUTING" ;;
    Skill)         PHASE="SKILL_EXECUTING" ;;
    Bash)          PHASE="COMMITTED" ;;
    *)             PHASE="UNKNOWN" ;;
esac

# Update state.json atomically
python3 -c "
import json
from datetime import datetime

with open('$STATE_FILE') as f:
    state = json.load(f)

step = state.get('step', 0) + 1
state['current_command'] = '$MODE' or state.get('current_command')
state['phase'] = '$PHASE'
state['step'] = step
state['last_checkpoint'] = datetime.now().isoformat()

modified = '$HOOK_FILE_PATH' or '$HOOK_COMMAND'
modified = modified[:100]
if modified and modified not in state.get('files_modified', []):
    state.setdefault('files_modified', []).append(modified)
    state['files_modified'] = state['files_modified'][-20:]

state['recovery_instructions'] = f'Resume at step {step}: phase={state[\"phase\"]}, mode={state[\"current_command\"]}'

with open('$STATE_FILE', 'w') as f:
    json.dump(state, f, indent=2)
" 2>/dev/null

exit 0
