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

P1-P5 + criteria session COMPLETE (2026-04-09): 12-dimension scoring framework built (evals/criteria/ — 12 dimension files + VISION.md + 2 scorecards). Honest self-score: 6.6/10 weighted. Weakest: Testing 3/10, Craft 4/10, Learning 5/10. 14 commands synced across 4 locations. 9 hook scripts installed globally. 11 eval rubrics. install.sh merges hooks.

## Active Feedback Rules

- **Stop hook compliance** — EVERY response needs signal scan + memory check, not just "final" responses. Got caught 3x in one session.
- **Resume context accuracy** — Match session to current project, don't load cross-project sessions.
- **Code-first pipeline** beats Figma-first.
- **Large writes (>500 lines at >50% context)** — dispatch as fresh agent.
- **Conservative hook rollout** — per self-inflicted regression lesson.
- **Reference apps are FLOOR** — beat them, don't match them.

## Recent Decisions

- 12-dimension scoring (was 10) — added Craft + Testing at 1.5x weight (2026-04-09)
- VISION.md: north star = "superior alien AI co-creator" with 5 properties (2026-04-09)
- Honest score 6.6 (was inflated 8.0 without craft/testing) (2026-04-09)

## Known Gaps (next session priorities)

1. **Fix spec-compliance.sh** — naming bug, 30-min fix, unlocks hard enforcement
2. **Fix spec-RAG** — remove 600-char truncation, add grep tool (Karpathy-informed tiered access)
3. **Formalize memory auto-write** — Stop hook auto-persists L1 + signals every session
4. **Hard phase gates** — `/think` → `/design` → `/build` requires approval (Kiro pattern)
5. **Test scaffolder** — auto-generate RED tests from spec acceptance criteria (Testing 3→7)

## Strategic Decisions (2026-04-09)

- **14→8 commands:** killed finance, claw, dispatch, eval, aside, refine. Zero capability lost.
- **Specs ARE the knowledge base** (Karpathy): tiered access (INDEX→full file→grep→vector last resort)
- **gOS local + Managed Agents cloud:** interactive work stays local, claws go cloud
- **Don't replace L0-L3 with flat memory stores:** tiered loading is context-efficient
- **Roadmap spec:** `specs/gOS_evolution_roadmap.md` — 23 items across 5 priority tiers
