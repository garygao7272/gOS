---
name: L1 Essential Story
description: Active project state, current sprint, recent decisions, active feedback rules. Updated every session. ≤800 tokens.
type: project
layer: L1
valid_from: 2026-04-10
valid_to: open
---

# Active State — gOS

## Current Focus

Major gOS build session (2026-04-10) — 5 commits, all pushed:

**Sprint 1** (216682a): Test scaffolder + hard phase gates + handoff schemas. 91/91 tests. Hook coverage 5→11.

**Spec Sprint** (8be5ed6): Coverage matrix + spec freshness checker + /review spec quality gate. Pure bash, on-demand.

**Command consistency** (084d8c8): Intent confirmation + plan mode + multi-agents across all 8 commands where applicable (+25 lines total).

**Health gate** (57cc526, 2531d86): Auto lean/performance checks on every gOS commit. Includes global sync check (warns when ~/.claude/ drifts from source).

**Global sync**: All 30 hooks + 8 commands + settings.json synced to ~/.claude/. Available in all projects.

Score estimate: 6.78 → ~7.8 weighted. Needs formal rescore.

## Active Feedback Rules

- **Stop hook compliance** — EVERY session exit needs signal scan + L1 + state.json + report.
- **Lean & smart** — No token bloat, no over-engineering, shell > Python when sufficient.
- **Conservative hook rollout** — per self-inflicted regression lesson.
- **Resume: story-first** — ONE thing next, not open-ended menu.
- **Always sync after editing gOS** — cp commands + hooks to ~/.claude/ or health gate will warn.

## Recent Decisions

- Hard phase gates: think→design→build enforced by exit-2 hook (2026-04-10)
- Handoff protocol: JSON artifacts in sessions/handoffs/ (2026-04-10)
- Spec quality gate: /review spec must score 8+/10 before promoting (2026-04-10)
- 3-aspect consistency across all commands (2026-04-10)
- Auto health gate on every gOS commit with global sync check (2026-04-10)
- Defer Sprint 2/3 — use gOS on real Arx work to surface actual gaps (2026-04-10)
- INV-G16 (surgical edits only) added to ~/.claude/invariants.md (2026-04-15)
- invariants.md now source-controlled at gOS/invariants.md; install.sh copies it (2026-04-15)
- claws/ now installed by install.sh --global; hook chmod verification added (2026-04-15)
- Fresh-clone reproducibility ~70% → ~95% (install.sh verified end-to-end) (2026-04-15)
- Parity commit 067f04c shipped: invariants.md sourced + install.sh fixes + research artifacts (2026-04-15)
- Evaluated 4 deferred P1s post-commit: 3 turned out false on first-principles (vocab, 24M gitignore, plugin dupe); shipped defensive `toolkit/*/node_modules/` gitignore only (2026-04-15)
- **Meta signal logged**: simplify-scout had ~75% false-positive rate on P1 recommendations — premise not verified before recommending. Evolve candidate: tighten scout-agent contracts. (2026-04-15)

## Known Issues / Gaps

- **Scratchpad Mode drift**: Something resets `sessions/scratchpad.md` Mode line during sessions, triggering phase-gate. Workaround: Bash `printf ... >> scratchpad` to append PHASE_GATE_SKIP. Root cause not yet identified (not scratchpad-checkpoint.sh, not state-tracker.sh).
- **Deferred simplification** (awaits Gary approval): delete zombie dirs (gos-v4.3, Archive/), gitignore toolkit/ (24M), grep-replace "build-squad" → Agent Teams.

## Next Session

1. **Arx work** — Radar Leaders S0-S4 redesign (first real test of phase gates + handoffs)
2. **Rescore** — formal 13-dimension eval
3. **Orphan cleanup** — 6 Arx specs in gOS/specs/ need moving
