---
name: gos-setup
description: Initialize gOS in a new project. Creates session directories, copies reference files, and validates the installation.
alwaysApply: false
---

# gOS Setup

Run this skill when setting up gOS in a new project for the first time.

## What Gets Created

```
project/
├── .claude/
│   └── self-model.md          ← Competence tracking (from plugin reference/)
├── sessions/
│   ├── scratchpad.md          ← Session state (ephemeral, cleared at /gos)
│   ├── trust.json             ← Per-domain trust levels (T0-T3)
│   ├── state.json             ← Execution state machine
│   └── evolve_signals.md      ← Signal log (feeds learning loop)
├── memory/
│   └── MEMORY.md              ← Cross-session memory index
└── outputs/
    ├── think/                 ← /think staging area
    │   ├── research/
    │   ├── discover/
    │   ├── design/
    │   └── decide/
    ├── briefings/             ← /simulate output
    └── gos-jobs/              ← /gos conductor job tracking
```

## Steps

1. Run `/gos` — the SessionStart hooks will auto-create directories
2. Verify: `ls sessions/` should show trust.json, state.json
3. Start using commands: `/think`, `/build`, `/review`, etc.

## Verification

After setup, check:
- [ ] `sessions/trust.json` exists with version "4.3"
- [ ] `sessions/state.json` exists
- [ ] `sessions/evolve_signals.md` exists with header
- [ ] `.claude/self-model.md` exists
- [ ] `memory/MEMORY.md` exists
- [ ] `outputs/` directory structure created
