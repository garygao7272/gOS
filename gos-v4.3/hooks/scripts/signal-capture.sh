#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Signal Capture Automation (v4.1 — FULL LEARNING LOOP)
# Event: Stop
#
# 1. Reads scratchpad for current command/mode and inline signals
# 2. Logs signal entry to evolve_signals.md
# 3. Updates trust.json with domain progression (THE MISSING WIRE)
# 4. Updates self-model.md accept rates
# ═══════════════════════════════════════════════════════════

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"
SIGNALS_FILE="$PROJECT_DIR/sessions/evolve_signals.md"
TRUST_FILE="$PROJECT_DIR/sessions/trust.json"
SELF_MODEL="$PROJECT_DIR/.claude/self-model.md"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOCAL_TIME=$(date +"%Y-%m-%d %H:%M")

# No scratchpad = not a gOS session → skip
if [ ! -f "$SCRATCHPAD" ]; then
    exit 0
fi

# Read current mode from scratchpad
# Extract the first non-empty, non-header line after "## Mode"
MODE=$(awk '/^## Mode/{found=1; next} found && /^## /{exit} found && /^[^#]/ && NF{print; exit}' "$SCRATCHPAD" 2>/dev/null | xargs)

# No mode or awaiting → skip
if [ -z "$MODE" ] || [ "$MODE" = "gOS > (awaiting routing)" ]; then
    exit 0
fi

# Extract command and sub-command from mode
COMMAND=$(echo "$MODE" | sed 's/ > .*//' | xargs)
SUBCMD=$(echo "$MODE" | sed 's/.* > //' | xargs)

# Check if signal was already captured this session (scratchpad marker)
if grep -q "\- \[x\] Signal Captured:" "$SCRATCHPAD" 2>/dev/null; then
    exit 0
fi

# ─── Step 1: Detect inline signal from scratchpad ──────────────
# Commands write inline signals like: "Signal: accept" or "Signal: rework"
# in the Key Decisions or Working State sections
SIGNAL="session-end"
CONTEXT="Auto-captured at session stop"

# Check for explicit inline signal markers in scratchpad
INLINE_SIGNAL=$(grep -ioE 'Signal:\s*(accept|rework|reject|love|repeat|skip)' "$SCRATCHPAD" 2>/dev/null | tail -1 | sed 's/[Ss]ignal:[[:space:]]*//' | tr '[:upper:]' '[:lower:]' | xargs || true)
if [ -n "$INLINE_SIGNAL" ]; then
    SIGNAL="$INLINE_SIGNAL"
    CONTEXT="Inline signal from scratchpad"
fi

# Check Pipeline State for signal markers
PIPELINE_SIGNAL=$(grep -ioE 'Signal Captured:\s*(accept|rework|reject|love|repeat|skip)' "$SCRATCHPAD" 2>/dev/null | tail -1 | sed 's/[Ss]ignal [Cc]aptured:[[:space:]]*//' | tr '[:upper:]' '[:lower:]' | xargs || true)
if [ -n "$PIPELINE_SIGNAL" ]; then
    SIGNAL="$PIPELINE_SIGNAL"
    CONTEXT="Pipeline state marker"
fi

# ─── Step 2: Ensure signals file exists ─────────────────────────
if [ ! -f "$SIGNALS_FILE" ]; then
    cat > "$SIGNALS_FILE" << 'HEADER'
# Evolve Signals

> Raw feedback signals from every gOS command invocation.
> Appended by signal-capture.sh Stop hook. Audited by `/evolve audit`.

## Signal Key

- ✅ `accept` — Gary used output without changes
- 🔄 `rework` — Gary asked for changes
- ❌ `reject` — Gary discarded output
- 🎯 `love` — Gary explicitly praised output
- 🔁 `repeat` — Gary had to re-explain something
- ⏭️ `skip` — Gary skipped a prescribed step

---

## Log

| Date | Time | Command | Sub-cmd | Signal | Context |
|------|------|---------|---------|--------|---------|
HEADER
fi

# Log signal
echo "| $(date +%Y-%m-%d) | $(date +%H:%M) | $COMMAND | $SUBCMD | $SIGNAL | $CONTEXT |" >> "$SIGNALS_FILE"

# ─── Step 3: UPDATE TRUST.JSON (THE CRITICAL MISSING WIRE) ─────
# Map command+subcmd to trust domain
infer_domain() {
    local cmd="$1"
    local sub="$2"
    case "$cmd" in
        *build*)
            case "$sub" in
                *model*|*deck*) echo "financial-modeling" ;;
                *content*|*playbook*|*proposal*) echo "content-creation" ;;
                *prototype*) echo "prototype-building" ;;
                *fix*|*tdd*|*refactor*|*feature*|*component*) echo "architecture" ;;
                *) echo "architecture" ;;
            esac
            ;;
        *review*)
            case "$sub" in
                *code*|*test*|*coverage*|*e2e*) echo "code-review" ;;
                *design*) echo "design-decisions" ;;
                *financial*|*compliance*) echo "financial-modeling" ;;
                *content*|*candidate*) echo "content-creation" ;;
                *) echo "code-review" ;;
            esac
            ;;
        *think*)
            case "$sub" in
                *research*|*discover*) echo "research-synthesis" ;;
                *spec*|*decide*) echo "spec-writing" ;;
                *finance*|*fundraise*) echo "financial-modeling" ;;
                *hire*) echo "hiring-decisions" ;;
                *) echo "research-synthesis" ;;
            esac
            ;;
        *design*) echo "design-decisions" ;;
        *simulate*) echo "financial-modeling" ;;
        *ship*)
            case "$sub" in
                *commit*|*pr*) echo "commit-messages" ;;
                *deploy*) echo "deployment" ;;
                *publish*|*pitch*) echo "public-communications" ;;
                *) echo "deployment" ;;
            esac
            ;;
        *evolve*) echo "architecture" ;;
        *) echo "architecture" ;;
    esac
}

DOMAIN=$(infer_domain "$COMMAND" "$SUBCMD")

if [ -f "$TRUST_FILE" ]; then
    # Read current domain state
    CURRENT_LEVEL=$(python3 -c "
import json, sys
with open('$TRUST_FILE') as f:
    data = json.load(f)
d = data.get('domains', {}).get('$DOMAIN', {})
print(d.get('level', 0))
" 2>/dev/null || echo "0")

    CONSECUTIVE=$(python3 -c "
import json, sys
with open('$TRUST_FILE') as f:
    data = json.load(f)
d = data.get('domains', {}).get('$DOMAIN', {})
print(d.get('consecutive_accepts', 0))
" 2>/dev/null || echo "0")

    FLOOR=$(python3 -c "
import json, sys
with open('$TRUST_FILE') as f:
    data = json.load(f)
d = data.get('domains', {}).get('$DOMAIN', {})
f = d.get('floor')
print(f if f is not None else 'null')
" 2>/dev/null || echo "null")

    # Apply trust progression rules
    python3 -c "
import json, sys
from datetime import datetime

with open('$TRUST_FILE') as f:
    data = json.load(f)

domain = '$DOMAIN'
signal = '$SIGNAL'
timestamp = '$TIMESTAMP'

if domain not in data['domains']:
    data['domains'][domain] = {
        'level': 0, 'history': [], 'consecutive_accepts': 0,
        'last_reject': None, 'floor': None
    }

d = data['domains'][domain]

# Append to history (keep last 20)
d['history'].append({'signal': signal, 'timestamp': timestamp})
d['history'] = d['history'][-20:]

# Apply progression rules
if signal in ('accept', 'love'):
    d['consecutive_accepts'] = d.get('consecutive_accepts', 0) + 1
    # T0→T1 needs 3+ consecutive accepts
    if d['level'] == 0 and d['consecutive_accepts'] >= 3:
        d['level'] = 1
    # T1→T2 needs 5+ consecutive accepts
    elif d['level'] == 1 and d['consecutive_accepts'] >= 5:
        d['level'] = 2
    # T2→T3 needs 10+ consecutive accepts
    elif d['level'] == 2 and d['consecutive_accepts'] >= 10:
        d['level'] = 3
elif signal in ('rework', 'reject'):
    d['consecutive_accepts'] = 0
    d['last_reject'] = timestamp
    # Demote on reject (but respect floor)
    if signal == 'reject' and d['level'] > 0:
        d['level'] = max(d['level'] - 1, 0)
elif signal == 'repeat':
    d['consecutive_accepts'] = 0
    # Repeat = gOS didn't learn, demote
    if d['level'] > 0:
        d['level'] = max(d['level'] - 1, 0)

# Enforce floor
floor = d.get('floor')
if floor is not None and d['level'] < floor:
    d['level'] = floor

# Don't exceed T3
d['level'] = min(d['level'], 3)

data['last_updated'] = datetime.now().astimezone().isoformat()

with open('$TRUST_FILE', 'w') as f:
    json.dump(data, f, indent=2)

print(f'Trust: {domain} T{d[\"level\"]} (consecutive: {d[\"consecutive_accepts\"]})')
" 2>/dev/null || echo "⚠️ trust.json update failed (python3 issue)"
fi

# ─── Step 4: UPDATE SELF-MODEL (THE LEARNING LOOP CLOSURE) ─────
# After 3+ signals for a domain, recalculate accept rate and update self-model.md
if [ -f "$SIGNALS_FILE" ] && [ -f "$SELF_MODEL" ]; then
    python3 -c "
import re, sys

domain = '$DOMAIN'
signals_path = '$SIGNALS_FILE'
model_path = '$SELF_MODEL'

# Count signals for this domain from evolve_signals.md
# Format: | date | time | Command | Sub-cmd | Signal | Context |
accepts = 0
reworks = 0
rejects = 0
loves = 0
repeats = 0
skips = 0
total = 0

with open(signals_path) as f:
    for line in f:
        if not line.startswith('|') or 'Date' in line or '---' in line:
            continue
        cols = [c.strip() for c in line.split('|')]
        if len(cols) < 7:
            continue
        sig = cols[5].lower().strip()
        # Infer domain from command+subcmd using same logic as shell
        cmd = cols[3].lower().strip()
        sub = cols[4].lower().strip()

        # Simple domain inference (mirrors shell function)
        d = 'architecture'  # default
        if 'build' in cmd:
            if any(x in sub for x in ['model', 'deck']): d = 'financial-modeling'
            elif any(x in sub for x in ['content', 'playbook', 'proposal']): d = 'content-creation'
            elif 'prototype' in sub: d = 'prototype-building'
            else: d = 'architecture'
        elif 'review' in cmd:
            if any(x in sub for x in ['code', 'test', 'coverage', 'e2e']): d = 'code-review'
            elif 'design' in sub: d = 'design-decisions'
            elif any(x in sub for x in ['financial', 'compliance']): d = 'financial-modeling'
            elif any(x in sub for x in ['content', 'candidate']): d = 'content-creation'
            else: d = 'code-review'
        elif 'think' in cmd:
            if any(x in sub for x in ['research', 'discover']): d = 'research-synthesis'
            elif any(x in sub for x in ['spec', 'decide']): d = 'spec-writing'
            elif any(x in sub for x in ['finance', 'fundraise']): d = 'financial-modeling'
            elif 'hire' in sub: d = 'hiring-decisions'
            else: d = 'research-synthesis'
        elif 'design' in cmd: d = 'design-decisions'
        elif 'simulate' in cmd: d = 'financial-modeling'
        elif 'ship' in cmd:
            if any(x in sub for x in ['commit', 'pr']): d = 'commit-messages'
            elif 'deploy' in sub: d = 'deployment'
            elif any(x in sub for x in ['publish', 'pitch']): d = 'public-communications'
            else: d = 'deployment'
        elif 'evolve' in cmd: d = 'architecture'

        if d != domain:
            continue

        total += 1
        if sig in ('accept', 'love'): accepts += 1
        if sig == 'love': loves += 1
        if sig == 'rework': reworks += 1
        if sig == 'reject': rejects += 1
        if sig == 'repeat': repeats += 1
        if sig == 'skip': skips += 1

if total < 3:
    sys.exit(0)  # Not enough data yet

accept_rate = round((accepts) / total * 100)

# Detect patterns for strengths/weaknesses
strengths = []
weaknesses = []
if accept_rate >= 80: strengths.append('high accept rate')
if loves > 0: strengths.append(f'{loves} love signals')
if rejects > 0: weaknesses.append(f'{rejects} rejections')
if repeats > 0: weaknesses.append(f'{repeats} repeat instructions')
if reworks > total * 0.4: weaknesses.append('high rework rate')

strengths_str = ', '.join(strengths) if strengths else '—'
weaknesses_str = ', '.join(weaknesses) if weaknesses else '—'

# Read trust level
import json
trust_level = 'T0'
try:
    with open('$TRUST_FILE') as f:
        td = json.load(f)
    trust_level = f\"T{td.get('domains', {}).get(domain, {}).get('level', 0)}\"
except: pass

from datetime import datetime
now = datetime.now().strftime('%Y-%m-%d')

# Update self-model.md — find the row for this domain and replace it
with open(model_path) as f:
    content = f.read()

# Match the row: | domain | ... | ... | ... | ... | ... | ... |
pattern = r'\| ' + re.escape(domain) + r' \|[^\n]*\|'
replacement = f'| {domain} | {accept_rate}% | {total} | {trust_level} | {strengths_str} | {weaknesses_str} | {now} |'

if re.search(pattern, content):
    content = re.sub(pattern, replacement, content)
    with open(model_path, 'w') as f:
        f.write(content)
    print(f'Self-model updated: {domain} accept={accept_rate}% signals={total}')
else:
    print(f'Self-model: no row for {domain} (skipped)')
" 2>/dev/null || echo "⚠️ self-model update skipped (python3 issue)"
fi

# ─── Step 5: Mark signal captured in scratchpad ─────────────────
if grep -q "\- \[ \] Signal Captured:" "$SCRATCHPAD" 2>/dev/null; then
    sed -i '' "s/- \[ \] Signal Captured:.*/- [x] Signal Captured: $SIGNAL for $DOMAIN (auto)/" "$SCRATCHPAD" 2>/dev/null || true
fi

echo "📊 Signal captured: $SIGNAL for $COMMAND > $SUBCMD → domain: $DOMAIN"
exit 0
