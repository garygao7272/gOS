---
name: L1 Essential Story
description: Active project state, current sprint, recent decisions, active feedback rules. Updated every session. ≤800 tokens.
type: project
layer: L1
valid_from: 2026-04-08
valid_to: open
---

# Active State — Arx

## Current Focus
gOS infrastructure improvement — 37-item agent audit across 10 dimensions. Phase 1 COMPLETE (ef78be0). Phase 2 COMPLETE. Phase 3 next: A1 action verification loop, A3 graceful degradation, RE1 checkpoint/rollback, R1 devil's advocate pass, L3 reinforcement loops.

## Active Feedback Rules (obey these)
- **Code-first pipeline** beats Figma-first — HTML prototype → Preview verify → Figma
- **Feel = shared tokens** — reference `feel:home`, never redefine per-card
- **Large writes (>500 lines at >50% context)** — dispatch as fresh agent, never inline
- **OfficeCLI for Excel** — never use openpyxl for writing
- **Financial models** — growth rates drive MAU, use observed ARPU, show drivers before building
- **Specs organize by user journeys** — self-contained cards, not technical architecture with cross-refs
- **Collapse overlapping tiers** — one tier + boolean toggle, not N tiers for N variants
- **Reference apps are FLOOR** — beat Robinhood/eToro/Bitget, don't match them

## Recent Decisions
- gOS simplified: 38 commands → 8 verbs + conductor (2026-03-21)
- Design pipeline: 9 → 3 sub-commands (card, ui, system)
- Build cards replace epics/stories/screen specs — one file per screen
- Palace Protocol adopted — search before answering from recall
- 4-layer memory stack adopted from mempalace (2026-04-08)

## Known Gaps (don't repeat these mistakes)
- /design and /build have zero health data despite heavy use
- claude-mem (349MB) installed but barely queried — proactive recall now instructed but needs enforcement

## Prototype State
Web prototype at apps/web-prototype/ — has its own CLAUDE.md. Read it first before editing.

## Specs
60+ artifacts in specs/. Start with specs/INDEX.md for lookup.
