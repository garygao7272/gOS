---
doc-type: decision-record
audience: Gary (CEO) + future Claude session loading the audit
reader-output: a ranked improvement list ready for /build or /ship
date: 2026-04-26
window: 2026-03-29 → 2026-04-26 (4 weeks)
sources:
  - gOS/sessions/evolve_signals.md (81 real signals + 54 session-end noise)
  - gOS/memory/evolve_audit_2026-04-{07,08,19}.md (3 prior audits)
  - Arx/sessions/evolve_signals.md (149 entries, ~68% gOS-relevant)
  - Working Folder/sessions/evolve_signals.md
---

# /evolve audit — 2026-04-26 — 4-week signal review

This is a decision record naming the highest-leverage gOS improvements after a 4-week signal review, so the next /build or /ship cycle has a ranked, evidence-backed work list and can stop guessing what hurts. The audit consolidates two parallel signal scans (gOS-side + Arx-side) into one cross-surface picture because the same friction shows up differently in each log — the gOS log shows infra debt, the Arx log shows artifact-discipline drift, and the leverage points are at the intersection.

**Covers:** signal volume · seven ranked improvement candidates · what's already actioned · the two cross-cutting roots · decision options.

## Signal volume across both surfaces

| Surface | In-window | accept | rework | reject | skip | repeat | love |
|---|---|---|---|---|---|---|---|
| gOS-side | 81 real (54 noise excl.) | 56 | 14 | 1 | 6 | 4 | 3 |
| Arx-side (gOS-relevant) | ~101 / 149 | 94 | 36 | 1 | 2 | 8 | 5 |

**Rework rate:** gOS-side 17%, Arx-side 24%. Arx-side is higher because Arx is where the artifact-discipline rules bite hardest — every cycle of /think and /refine on a TDC produces a fresh chance for voice or scope to drift.

## Two cross-cutting roots (every theme below traces to one of these)

**Root A — gOS overproduces, then trims under user pressure.** Bloat-resistance signals (Arx: 18), voice/jargon signals (Arx: 14), session-end noise (gOS: 54), comprehensive-list rework (Arx: 7). The pattern: a verb generates a structurally-complete artifact, Gary cuts to first-order, the cut isn't fed back into the verb's defaults. Recent commit `23b56ef` (delete-first rubric dim, ≥18/26 bar) is the right direction but it's a *post-hoc check*, not a generation-time discipline.

**Root B — gOS infra debt fires mid-work and isn't escalated.** Scratchpad drift (3 high, fired live during 04-19 audit), scout-verify-premise unactioned 4 days, CronCreate durable flag silently broken, hook over-firing on planning turns. The pattern: META-tagged signals from prior audits sit in the queue without an escalation path; meta-quality issues compete with substantive work and lose.

## Ranked improvement candidates (all evidence-backed)

| # | Improvement | Root | Frequency × severity | Fix effort | Leverage | Targets |
|---|---|---|---|---|---|---|
| 1 | **Signal-log noise filter** — redirect session-end auto-entries to `sessions/activity.log`; keep `evolve_signals.md` curated to verdict-tagged signals only | A | 54 entries / 4 weeks (2:1 noise:signal — pollutes every future audit) | ~30 LOC, one Stop hook + one path constant | **Highest** — every audit downstream of this becomes 3× cheaper | `hooks/stop-*.sh`, `evolve audit` reader |
| 2 | **/refine inherits /think's first-order trim** — pre-flight in `/refine` after `/think` reads the trim ratio (input items vs surviving items), refuses to expand back; add to refine plan-gate prompt | A | 7 rework signals on /refine bloat (Arx) + 2 context-limit reorg defers (gOS) | ~50 LOC in `commands/refine.md` + 1 contract clause | **High** — kills repeat cycles where Gary cuts the same comprehensive list twice | `commands/refine.md`, `evals/rubrics/refine.md` |
| 3 | **Scout-verify-premise as contract clause** — already a feedback memory ([feedback_scout_verify_premise.md](memory/feedback_scout_verify_premise.md)); promote into Explore/researcher agent contracts as a hard pre-flight ("name the disprovable premise; verify with grep/read before reporting") | B | 4 high-severity false positives (vocab-sweep, 24M gitignore, plugin dupe, snapshot-deletable) | ~20 LOC across 2-3 agent files | **High** — Explore is invoked ~3× per gOS session; FP rate kills trust | `agents/explorer*`, `agents/researcher.md` |
| 4 | **Conductor adds "decomposition axis" gate** — Phase 2.6 in `/gos`: before mapping intent to verbs, ask "what *determines* X?" — refuse discipline-based splits when an abstraction-based axis exists | A | 12 Arx signals on wrong decomposition + 3 re-indexing cycles | ~40 LOC in `commands/gos.md` Phase 2 | **Med-High** — prevents 1-2 wasted cycles per complex Arx job | `commands/gos.md` |
| 5 | **Phase-gate scratchpad drift root-cause** — debug which hook/agent resets `phase` mid-session; fix at source instead of `PHASE_GATE_SKIP` workaround | B | 3 fires (one *during the 04-19 audit itself*) | 1-2h debug, then surgical fix | **Med** — fires ~once a week, but every fire costs context-switch | `hooks/*.sh`, `sessions/state.json` writers |
| 6 | **Plan-gate-skip on revealed intent** — when Gary follows "/gos" with an immediate `/think`/`/build` in the same turn, treat as bypass (he's already declared intent) | B | 6 skip-friction signals on briefing | ~15 LOC in `commands/gos.md` routing | **Med** — small QoL, daily friction reducer | `commands/gos.md` |
| 7 | **CronCreate `durable:true` → launchd plist fallback** | B | 1 silent-degradation incident (high severity when it fires) | 1-2h to wire alternative scheduler | **Low-Med** — infra-only, doesn't unlock new workflows | `claws/`, scheduling docs |

## What's already actioned (don't re-do)

- ✅ Voice + jargon ban — commit `23b56ef` (glossary, rubric dims, ≥18/26 bar). Arx signals showing voice rework are mostly *pre-23b56ef* — the rule is fresh, give it a week before judging.
- ✅ /think spec skeleton swap to PM-native (Problem/Users/Solution/Success/Risks) — commit `23b56ef`. Watch for whether Arx /think calls still drift to 8-primitive structure.
- ✅ /refine ↔ /think loop with 8 primitives — commit `c3c1c97`. Covers gap-resolution but doesn't yet cover bloat inheritance (#2 above is the missing piece).
- 🟡 Hook over-firing on planning turns — partial fix 04-15 (Stop hook default-skip rule). Audit confirms it still fires occasionally.

## Surprises worth naming

1. **The signal log itself is the highest-leverage fix.** It's not a glamorous improvement, but every future /evolve audit reads cleaner signal at 1:1 instead of 1:3. That alone changes whether audits stay practical at production cadence.
2. **Recent voice work was already foreshadowed 4 weeks ago.** Arx signals on 2026-04-19, 04-12, 04-11 all asked for plain English / scenario-based / no-jargon output. The audit→action lag was 1 week — fast, but the lag itself is data.
3. **Scout false-positive rate is 75% in the cited cases.** That's not a tuning problem, it's a missing contract clause — the agent doesn't know "verify the disprovable premise" is a hard pre-condition.

## How to use this audit

Read the ranked table top-to-bottom. Picks 1-3 are "do this week" — they're the highest-leverage, lowest-effort, and address Root A + Root B together. Picks 4-7 are "next sprint" — they're real but can wait without blocking anything. The full evidence behind each pick lives in the source signals; this file is the synthesis, not the trace.
