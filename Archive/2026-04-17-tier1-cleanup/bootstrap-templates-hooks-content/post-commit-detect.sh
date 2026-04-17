#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Post-Commit Spec Drift Detector
# Event: PostToolUse (Bash)
# After git commit, checks changed files against specs
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/hook-utils.sh"
_parse_hook_input

CLAW_STATE="$HOME/.claude/claws/spec-drift/state.json"
[ -f "$CLAW_STATE" ] || exit 0
[ "$HOOK_TOOL_NAME" = "Bash" ] || exit 0

case "$HOOK_COMMAND" in
    *"git commit"*) ;;
    *) exit 0 ;;
esac

CHANGED_FILES=$(cd "$HOOK_PROJECT_DIR" && git diff HEAD~1 --name-only 2>/dev/null || echo "")
[ -z "$CHANGED_FILES" ] && exit 0

# Map changed files to potentially stale specs
STALE_SPECS=""
while IFS= read -r file; do
    case "$file" in
        apps/web-prototype/*)                          STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-* (prototype: $file)"$'\n' ;;
        apps/mobile/src/components/trade/*)            STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-3 (trade: $file)"$'\n' ;;
        apps/mobile/src/components/radar/*|*copy/*)    STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-4 (radar/copy: $file)"$'\n' ;;
        apps/mobile/src/components/home/*|*market/*)   STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-2 (home/markets: $file)"$'\n' ;;
        apps/mobile/src/components/you/*)              STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-5 (you: $file)"$'\n' ;;
        apps/mobile/src/components/onboarding/*|*fund/*) STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-1 (onboarding: $file)"$'\n' ;;
        apps/mobile/src/components/lucid/*)            STALE_SPECS="$STALE_SPECS specs/Arx_4-1-1-6 (lucid: $file)"$'\n' ;;
    esac
done <<< "$CHANGED_FILES"

[ -z "$STALE_SPECS" ] && exit 0

COMMIT_SHA=$(cd "$HOOK_PROJECT_DIR" && git rev-parse HEAD 2>/dev/null | head -c 8 || echo "unknown")
python3 -c "
import json
from datetime import datetime

with open('$CLAW_STATE') as f:
    state = json.load(f)

state['last_run'] = datetime.now().isoformat()
state['run_count'] = state.get('run_count', 0) + 1
state['last_commit'] = '$COMMIT_SHA'

for line in '''$STALE_SPECS'''.strip().split('\n'):
    if not line.strip(): continue
    spec_ref = line.strip().split(' ')[0]
    if spec_ref not in [s['spec_path'] for s in state.get('stale_specs', [])]:
        state.setdefault('stale_specs', []).append({
            'spec_path': spec_ref, 'reason': line.strip(),
            'commit': '$COMMIT_SHA', 'flagged_date': datetime.now().isoformat(), 'resolved': False
        })

with open('$CLAW_STATE', 'w') as f:
    json.dump(state, f, indent=2)
" 2>/dev/null

COUNT=$(echo "$STALE_SPECS" | grep -c '[a-z]' || echo "0")
echo "SPEC DRIFT: $COUNT spec(s) may need updating after commit $COMMIT_SHA."
exit 0
