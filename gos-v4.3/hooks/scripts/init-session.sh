#!/bin/bash
# ═══════════════════════════════════════════════════════════
# gOS Session Initializer (SessionStart hook)
# Creates session directories and template files if missing.
# Uses CLAUDE_PROJECT_DIR (or pwd) as the project root.
# ═══════════════════════════════════════════════════════════

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(dirname "$0")")")}"
SESSIONS="$PROJECT_DIR/sessions"
MEMORY="$PROJECT_DIR/memory"
OUTPUTS="$PROJECT_DIR/outputs"

# Create session directories
mkdir -p "$SESSIONS" "$MEMORY" "$OUTPUTS"/{think/{research,discover,design,decide},briefings,gos-jobs}

# Initialize trust.json if missing
if [ ! -f "$SESSIONS/trust.json" ]; then
    cat > "$SESSIONS/trust.json" << 'EOF'
{
  "version": "4.3",
  "last_updated": null,
  "domains": {},
  "global_floor": 0,
  "notes": "Auto-initialized by gOS plugin. Trust levels: T0=Advisory, T1=Collaborative, T2=Delegated, T3=Autonomous."
}
EOF
fi

# Initialize state.json if missing
if [ ! -f "$SESSIONS/state.json" ]; then
    cat > "$SESSIONS/state.json" << 'EOF'
{
  "current_command": null,
  "phase": null,
  "step": 0,
  "total_steps": 0,
  "started_at": null,
  "last_checkpoint": null,
  "files_modified": [],
  "recovery_instructions": null
}
EOF
fi

# Initialize evolve_signals.md if missing
if [ ! -f "$SESSIONS/evolve_signals.md" ]; then
    cat > "$SESSIONS/evolve_signals.md" << 'EOF'
# Evolve Signals

> Raw feedback signals from every gOS command invocation.
> Appended by signal-capture.sh Stop hook. Audited by `/evolve audit`.

## Signal Key

- accept — Gary used output without changes
- rework — Gary asked for changes
- reject — Gary discarded output
- love — Gary explicitly praised output
- repeat — Gary had to re-explain something
- skip — Gary skipped a prescribed step

---

## Log

| Date | Time | Command | Sub-cmd | Signal | Context |
|------|------|---------|---------|--------|---------|
EOF
fi

# Copy self-model.md to project .claude/ if missing
if [ ! -f "$PROJECT_DIR/.claude/self-model.md" ] && [ -f "$PLUGIN_ROOT/reference/self-model.md" ]; then
    mkdir -p "$PROJECT_DIR/.claude"
    cp "$PLUGIN_ROOT/reference/self-model.md" "$PROJECT_DIR/.claude/self-model.md"
fi

# Initialize memory index if missing
if [ ! -f "$MEMORY/MEMORY.md" ]; then
    cat > "$MEMORY/MEMORY.md" << 'EOF'
# Memory Index

> Cross-session persistent memory. Updated by `/gos save` and signal-capture.sh.

## Categories

- `user_*.md` — User preferences and patterns
- `project_*.md` — Project-specific learnings
- `feedback_*.md` — Feedback corrections
- `reference_*.md` — Reference material

## Entries

(none yet — populated as gOS learns)
EOF
fi

exit 0
