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

Major gOS overhaul COMPLETE (2026-04-09 evening): 14→8 commands (killed finance, claw, dispatch, eval, aside, refine — zero capability lost). 13-dimension scoring (added Orchestration 1.5x). Score: 6.78 weighted. Weakest: Orchestration 4.5, Testing 5, Craft 5.5, Learning 6. P0 fixes landed (spec-compliance blocks 8/8, spec-RAG tiered, Stop hook auto-persist). 7 research briefs from multi-agent swarms. Evolution roadmap at specs/gOS_evolution_roadmap.md. Next: Sprint 1 — test scaffolder + hard phase gates + handoff schemas (→7.8).

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

## Next Session: Sprint 1 (all dimensions to 8+)

1. **S1-1: Test scaffolder** — reads spec acceptance criteria, generates test stubs. Testing 5→8, Craft 5.5→7.
2. **S1-2: Hard phase gates** — PreToolUse hook blocks /design without /think output, /build without /design output. Planning 8→9, Craft→8, Orch→6.
3. **S1-3: Handoff schemas + coverage matrix** — typed verb output formats + `/gos status` shows spec/design/code/test coverage. Action→8, Orch→7.

Load `specs/gOS_evolution_roadmap.md` for full plan. Scorecard at `evals/criteria/scorecard-2026-04-09-v4.md`.

## Strategic Decisions (2026-04-09)

- **14→8 commands:** killed finance, claw, dispatch, eval, aside, refine. Zero capability lost.
- **Specs ARE the knowledge base** (Karpathy): tiered access (INDEX→full file→grep→vector last resort)
- **gOS local + Managed Agents cloud:** interactive work stays local, claws go cloud
- **Don't replace L0-L3 with flat memory stores:** tiered loading is context-efficient
- **13 dimensions:** added Orchestration (1.5x) measuring multi-agent spec-first coordination
- **Core objective codified in VISION.md:** multi-agent spec-first across 3 surfaces
