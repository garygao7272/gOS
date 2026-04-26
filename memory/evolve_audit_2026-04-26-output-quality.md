---
doc-type: decision-record
audience: Gary + Claude session implementing the changes
reader-output: a sequenced work list across commands, rubric, and agent contracts
date: 2026-04-26
supersedes-priority: ranked picks in evolve_audit_2026-04-26.md (those become second-tier)
---

# Output routing + execution-spec quality — improvement plan

This is the decision record naming what to change in gOS so (a) Gary controls inline-vs-file output without fighting verb defaults, and (b) execution-specs converge in 2-3 refine cycles instead of 10-20. Both targets stem from one underlying gap: gOS optimizes for structural completeness when Gary needs operational density. The plan below names the rubric, command, and agent edits that reframe what "good" means for an execution-spec, and the routing primitives that put output-mode under the user's hand.

**Covers:** root diagnosis · optimization 1 (routing) — 4 tips + 3 changes · optimization 2 (exec-spec quality) — 5 tips + 4 changes · cut list · sequencing.

## Root diagnosis

The /refine loop converges on the wrong thing. Today's 26-dim rubric weights structural completeness (every section present, every primitive named) and treats compression as one dim of 26. For an execution-spec — a doc someone codes from — completeness without density is noise, and the loop spends 10-20 cycles polishing prose that an implementer would skip on first read. The rubric is wrong, not the loop.

Routing fails for a sibling reason: every verb has a hardcoded "Output: outputs/.../...md" line that overrides §7.9.6's "inline default." The user has no clean way to say "answer this in chat" or "make this a file" without rewriting the prompt around the verb's wiring.

## Optimization 1 — Output routing (inline vs MD; when to /think)

### Tips
1. **Make output-mode an explicit prompt flag, not an inferred decision.** Trailing `--inline` or `--file` on any verb wins over the verb's default path. Zero ambiguity.
2. **Default by reader need, not by verb identity.** A `/think research` answer that fits in 150 words and won't be retrieved is chat-output. A `/build feature` plan that gets executed across 4 sessions is file-output. The verb name doesn't decide — the lifespan does.
3. **Resist /think for factual or status questions.** Route to /think only when ≥2 of: novelty, multi-source synthesis, ≥3 viable options to surface, persistence need. Single-source factual? Inline answer, no /think wrapper.
4. **Show the routing decision before executing.** One line: `Routing → inline (~180w est, no retrieval need)` or `Routing → file (decision-record, audit trail required)`. Cheap to show, makes the heuristic legible.

### Changes
| # | What | Where | LOC |
|---|---|---|---|
| 1.1 | Universal `--inline` / `--file` flag on every verb; flag wins over verb default | `commands/*.md` (one-line addition each) + new `rules/common/output-routing.md` | ~80 LOC across 11 commands |
| 1.2 | Pre-flight routing block: estimate token count, retrieval need, audit need; print routing decision; route accordingly | `rules/common/output-routing.md` (new) + reference line in each command | ~120 LOC (one rule file) |
| 1.3 | /think trigger heuristic — gOS conductor refuses to spawn /think for single-source factual questions | `commands/gos.md` Phase 2.5 expansion | ~25 LOC |

## Optimization 2 — Execution-spec output quality

### Tips
1. **First paragraph carries all the rationale. Period.** Six lines max. Anything more belongs in a sibling decision-record, not the spec body. Rationale > 6 lines = spec failed.
2. **Measure execution density, not section completeness.** Count lines that are operationally-actionable (contract, edge case, numeric value, state transition, named open question). Target ≥70%. Lines that explain *why* something exists are the budget, not the meal.
3. **Cut process narrative on sight.** "We considered…", "Originally…", "After reflection…", "It's worth noting…" — these are interim-reasoning leaks already banned in §7.9.7 but they keep slipping in. Lint mechanically.
4. **No soft adjectives without a numeric.** "Fast" → "P95 < 200ms". "Responsive" → "first paint < 800ms cold, < 200ms warm". "Comfortable" → "44px touch target, 8px spacing minimum". A spec-line with an unquantified adjective is a defect.
5. **Run the implementer test before publishing.** "If a competent engineer with no context tried to code this, how many questions would they have to ask?" Target ≤2. If 3+, the spec is incomplete, not done.

### Changes
| # | What | Where | LOC |
|---|---|---|---|
| 2.1 | New doc-type `execution-spec` — distinct from `product-spec`/`design-spec`. Order: Rationale (≤6 lines) → Contract → Edge cases → Numeric targets → State transitions → Open questions → Cut for v1 | `rules/common/output-discipline.md` §7.1 doc-type table + new template | ~60 LOC |
| 2.2 | Three new rubric dims with heavy weight for `execution-spec`: **execution density** (≥70% operational lines), **rationale cap** (≤6 lines), **implementer-test pass** (≤2 unanswered questions) | `evals/rubrics/think.md` + `evals/rubrics/refine.md` | ~80 LOC |
| 2.3 | New critic agent `agents/implementer-test.md` — fresh-context, simulates coding from spec, returns ranked list of "questions I'd have to ask" + "redundant prose I'd skip". Wired into /refine for execution-spec doc-type | `agents/implementer-test.md` (new) + `commands/refine.md` invocation | ~100 LOC |
| 2.4 | Bats lints — process-narrative phrases ("we considered", "originally", "after reflection"), soft-adjective-without-numeric ("fast", "responsive", "comfortable", "smooth", "snappy" within 5 chars of no number) | `tests/hooks/artifact-discipline.bats` + 2 new fixture files | ~50 LOC |

### Why this fixes the 10-20-cycle loop
Today's stop criterion is "all 26 dims ≥1." For execution-spec, swap to: **execution-density ≥ 70% AND implementer-test ≤ 2 questions AND zero anti-pattern flags AND no rubric dim at 0**. Three dims carry 60% of the weight; the rest are sanity checks. Convergence target: 2-3 cycles for first draft, 1-2 for revisions. Empirical guess based on shifting from "structural completeness" to "operational readiness" as the loss function.

## Cut list (delete-first — what NOT to add)

| Tempting addition | Why we're not adding it |
|---|---|
| Sub-types of execution-spec (frontend / backend / data) | Premature — one type with a flexible Contract section covers all three; specialize only after 5+ examples show divergence |
| Auto-classification (gOS guesses doc-type from prompt) | Fragile and hides intent — Gary names the doc-type explicitly via the verb's `--exec-spec` flag or frontmatter |
| Multi-pass implementer-test (round 1, round 2, …) | One pass is the whole signal — if round 1 returns 5 questions, the spec isn't ready; iterate the spec, not the test |
| Quantitative score on every adjective | "Approachable" / "calm" / "premium" are *feel* tokens, not perf adjectives; only ban soft-adj-without-numeric in operational sections (Contract, Edges, Targets, State) |

## Sequencing

| Sprint | Picks |
|---|---|
| **Week 1** | 2.1 (doc-type) → 2.2 (rubric reweight) → 2.4 (lints). These three together change what "good" means and bite mechanically |
| **Week 2** | 2.3 (implementer-test critic) — depends on 2.1+2.2 being live so the critic has a target to score against |
| **Week 3** | 1.1 + 1.2 + 1.3 (routing) — independent of optimization 2, can parallel-track if capacity allows |

## How to use this plan

The week-1 changes alone should cut average refine cycles from 10-20 → 4-6 on the next execution-spec. If they don't, the rubric weights are still wrong and we revisit before week 2. The implementer-test critic in week 2 is the convergence-killer — it gives the loop a concrete stop condition that maps to "an engineer could code this."
