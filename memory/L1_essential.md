---
name: L1 Essential Story
description: Active project state, current sprint, recent decisions, active feedback rules. Updated every session. ≤800 tokens.
type: project
layer: L1
valid_from: 2026-04-09
valid_to: open
---

# Active State — gOS

## Current Focus

P1-P5 upgrade COMPLETE (2026-04-09): Memory auto-search wired into gOS Step 0 (L1 + state.json + claude-mem). 9 hook scripts installed globally (~/.claude/hooks/). 6 hook events configured in settings.json (PreToolUse, PostToolUse, PostToolUseFailure, Stop, PreCompact, PostCompact). 6 new eval rubrics (gos-conductor, simulate, ship, evolve, refine, aside — total 11). state.json checkpoint system live. Context-monitor hook active. Confidence surfacing added to conductor reporting. PATH fix for uvx (claude-mem enabler). install.sh now MERGES hooks instead of overwriting settings.json.

## Active Feedback Rules (obey these)

- **Code-first pipeline** beats Figma-first — HTML prototype → Preview verify → Figma
- **Feel = shared tokens** — reference `feel:home`, never redefine per-card
- **Large writes (>500 lines at >50% context)** — dispatch as fresh agent, never inline
- **OfficeCLI for Excel** — never use openpyxl for writing
- **Financial models** — growth rates drive MAU, use observed ARPU, show drivers before building
- **Specs organize by user journeys** — self-contained cards, not technical architecture with cross-refs
- **Conservative hook rollout** — per self-inflicted regression lesson, wire 8-10 hooks max, test before adding more
- **Reference apps are FLOOR** — beat Robinhood/eToro/Bitget, don't match them

## Recent Decisions

- gOS simplified: 38 commands → 8 verbs + conductor (2026-03-21)
- 4-layer CLAUDE.md hierarchy: global → workspace → project → gOS dev (2026-04-08)
- install.sh two-phase: --global + --bootstrap (2026-04-08)
- gOS scored 6.4 → 7.3 after restructure (2026-04-08)
- P1-P5 upgrade targeting 8.5+ (2026-04-09)

## Known Gaps (don't repeat these mistakes)

- claude-mem (349MB) now has PATH fix but needs testing — verify uvx works in next session
- /simulate still has ZERO signal data — needs real usage
- state-tracker.sh (auto-checkpoint via PostToolUse) not yet wired — manual checkpoint via gOS.md instructions for now

## Specs

60+ artifacts in specs/. Start with specs/INDEX.md for lookup.
