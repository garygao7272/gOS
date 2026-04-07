#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Post-Commit Spec Drift Detector
# Event: PostToolUse (Bash)
# After git commit, checks changed files against specs
# Updates ~/.claude/claws/spec-drift/state.json
# ═══════════════════════════════════════════════════════════

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_DIR="$PROJECT_DIR/specs"
CLAW_STATE="$HOME/.claude/claws/spec-drift/state.json"

# Only proceed if claw state exists
if [ ! -f "$CLAW_STATE" ]; then
    exit 0
fi

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")

# Only trigger on Bash
if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0
fi

# Check if the command was a git commit
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

case "$COMMAND" in
    *"git commit"*) ;;
    *) exit 0 ;;
esac

# Get changed files from the last commit
CHANGED_FILES=$(cd "$PROJECT_DIR" && git diff HEAD~1 --name-only 2>/dev/null || echo "")

if [ -z "$CHANGED_FILES" ]; then
    exit 0
fi

# Map changed files to potentially stale specs
STALE_SPECS=""
while IFS= read -r file; do
    case "$file" in
        apps/web-prototype/*)
            STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-* (prototype changed: $file)"$'\n'
            ;;
        apps/mobile/src/components/trade/*)
            STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-3 (trade component: $file)"$'\n'
            ;;
        apps/mobile/src/components/radar/*|apps/mobile/src/components/copy/*)
            STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-4 (radar/copy component: $file)"$'\n'
            ;;
        apps/mobile/src/components/home/*|apps/mobile/src/components/market/*)
            STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-2 (home/markets component: $file)"$'\n'
            ;;
        apps/mobile/src/components/you/*)
            STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-5 (you component: $file)"$'\n'
            ;;
        apps/mobile/src/components/onboarding/*|apps/mobile/src/components/fund/*)
            STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-1 (onboarding/fund component: $file)"$'\n'
            ;;
        apps/mobile/src/components/lucid/*)
            STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-6 (lucid component: $file)"$'\n'
            ;;
        specs/*)
            # Spec itself was modified — not stale, self-healing
            ;;
    esac
done <<< "$CHANGED_FILES"

if [ -z "$STALE_SPECS" ]; then
    exit 0
fi

# Update claw state.json
COMMIT_SHA=$(cd "$PROJECT_DIR" && git rev-parse HEAD 2>/dev/null | head -c 8 || echo "unknown")
python3 -c "
import json
from datetime import datetime

with open('$CLAW_STATE', 'r') as f:
    state = json.load(f)

state['last_run'] = datetime.now().isoformat()
state['run_count'] = state.get('run_count', 0) + 1
state['last_commit'] = '$COMMIT_SHA'

stale_lines = '''$STALE_SPECS'''.strip().split('\n')
for line in stale_lines:
    if line.strip():
        spec_ref = line.strip().split(' ')[0]
        entry = {
            'spec_path': spec_ref,
            'reason': line.strip(),
            'commit': '$COMMIT_SHA',
            'flagged_date': datetime.now().isoformat(),
            'resolved': False
        }
        # Don't duplicate
        existing = [s['spec_path'] for s in state.get('stale_specs', [])]
        if spec_ref not in existing:
            state.setdefault('stale_specs', []).append(entry)

with open('$CLAW_STATE', 'w') as f:
    json.dump(state, f, indent=2)
" 2>/dev/null

# Output notification
COUNT=$(echo "$STALE_SPECS" | grep -c '[a-z]' || echo "0")
echo "📋 SPEC DRIFT: $COUNT spec(s) may need updating after commit $COMMIT_SHA. Check with /gos status."

exit 0
