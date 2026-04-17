#!/bin/bash
# ═══════════════════════════════════════════════════════════
# File Changed Drift Detector
# Event: FileChanged
# Real-time spec drift detection — fires when any file changes,
# not just on git commit. Replaces post-commit-only approach.
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/hook-utils.sh"
_parse_hook_input

[ -n "$HOOK_FILE_PATH" ] || exit 0

REL_PATH="${HOOK_FILE_PATH#"$HOOK_PROJECT_DIR"/}"

# Only trigger for app code and spec changes
SPEC_HINT=""
case "$REL_PATH" in
    apps/web-prototype/*)
        SPEC_HINT="specs/Arx_4-1-1-* (mobile screen specs)" ;;
    apps/mobile/src/components/trade/*)
        SPEC_HINT="specs/Arx_4-1-1-3 (Trade tab)" ;;
    apps/mobile/src/components/radar/*|apps/mobile/src/components/copy/*)
        SPEC_HINT="specs/Arx_4-1-1-4 (Radar/Copy)" ;;
    apps/mobile/src/components/home/*|apps/mobile/src/components/market/*)
        SPEC_HINT="specs/Arx_4-1-1-2 (Home/Markets)" ;;
    apps/mobile/src/components/you/*)
        SPEC_HINT="specs/Arx_4-1-1-5 (You tab)" ;;
    apps/mobile/src/components/onboarding/*|apps/mobile/src/components/fund/*)
        SPEC_HINT="specs/Arx_4-1-1-1 (Onboarding)" ;;
    apps/mobile/src/components/lucid/*)
        SPEC_HINT="specs/Arx_4-1-1-6 (Lucid)" ;;
    apps/mobile/src/models/*|apps/mobile/src/api/*)
        SPEC_HINT="specs/Arx_4-1-1-7 (Data Object Model) + specs/Arx_5-6 (API)" ;;
    specs/Arx_4-2*)
        SPEC_HINT="DESIGN.md + apps/web-prototype/ (design system changed)" ;;
    specs/Arx_3-*)
        SPEC_HINT="specs/Arx_4-1-0 (Experience Design Index — feature spec changed)" ;;
    *) exit 0 ;;
esac

[ -n "$SPEC_HINT" ] || exit 0

# Update claw state if available
CLAW_STATE="$HOME/.claude/claws/spec-drift/state.json"
if [ -f "$CLAW_STATE" ]; then
    python3 -c "
import json
from datetime import datetime

with open('$CLAW_STATE') as f:
    state = json.load(f)

state['last_run'] = datetime.now().isoformat()
state['run_count'] = state.get('run_count', 0) + 1

spec_ref = '$SPEC_HINT'.split(' ')[0]
existing = [s['spec_path'] for s in state.get('stale_specs', [])]
if spec_ref not in existing:
    state.setdefault('stale_specs', []).append({
        'spec_path': spec_ref,
        'reason': 'FileChanged: $REL_PATH → $SPEC_HINT',
        'flagged_date': datetime.now().isoformat(),
        'resolved': False
    })

with open('$CLAW_STATE', 'w') as f:
    json.dump(state, f, indent=2)
" 2>/dev/null
fi

echo "SPEC DRIFT: $REL_PATH changed → check $SPEC_HINT"
exit 0
