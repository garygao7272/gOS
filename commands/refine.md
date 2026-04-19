---
description: "Refine — iterative convergence loop: tighten a target until quality bar met, cycle cap hit, or stuck. Three modes: /refine (self-iterate), /refine fresh (outside-eyes each cycle), /refine council (6-archetype council each cycle). TRIGGER when user wants to iterate — phrases like 'refine X', 'iterate on X', 'tighten this', 'keep going until converged'. SKIP for one-shot improvements (use /review or direct edits) or topics with no pre-existing draft (run /think discover first)."
---

# /refine — Convergence Loop

**Purpose:** Iteratively tighten a target until a declared quality bar is met. Canonical entry — there is no `/gos refine` or `/review refine`.

**Output discipline.** Every revision this command writes (files under `outputs/refine/{slug}/cycle-N/`) must comply with the artifact-discipline rules in [output-discipline.md](../rules/common/output-discipline.md) and the voice rules in [output-discipline-voice.md](../rules/common/output-discipline-voice.md). The 8-dimension rubric below scores structural compliance via dim 6 (Structural compression) and voice compliance via dim 8 (Voice discipline). A cycle that regresses either dimension fails convergence — see Stop criteria.

**Companion-load bootstrap (mandatory for voice / visuals dimensions).** The main rule file carries summaries; the full catalogs live in companions. Any agent scoring dim 8 (Voice discipline) must read [output-discipline-voice.md](../rules/common/output-discipline-voice.md) before grading — otherwise the twelve-pattern catalog and per-pattern rationale stay invisible and the critic under-catches AI smell. Any agent evaluating visual-aid choices (part of dim 6) must read [output-discipline-visuals.md](../rules/common/output-discipline-visuals.md). For `/refine fresh` and `/refine council`, the prompt template explicitly instructs the spawned agent to load both companions when the rubric dimension is in scope.

**Three modes, three cost tiers, one contract.**

| Mode | Per-cycle critic | When |
|---|---|---|
| `/refine <target>` | Main context self-critiques against the 8-dim rubric | Cheap. Tighten prose, close known gaps. |
| `/refine fresh <target>` | Fresh-context agent critiques (naive reader each cycle) | Medium. Too close to it; need outside eyes. |
| `/refine council <target>` | 6-archetype council + synthesizer | Expensive. High-stakes doc where multi-lens matters. |

Pick the cheapest mode that clears the quality bar. Escalate (self → fresh → council) only if the cheaper mode stalls.

---

## Shared contract (all three modes)

### Plan gate (mandatory, before any cycle)

Present to Gary and WAIT:

> **PLAN:** [target file + what "tight" looks like]
> **MODE:** [self / fresh / council]
> **SCOPE (IN/OUT/NEVER):** [what this refine cycle touches · what it leaves untouched · what it refuses to touch and why]
> **QUALITY BAR:** [default: 8-dim rubric ≥ 13/16 with every invariant dim ≥1 · override with `--bar="custom criteria"`]
> **CYCLE CAP:** [default 3, max 5]
> **MEMORY:** [L1 check — prior refine runs on this topic]
> **RISK:** [biggest risk — e.g., "scope too broad" / "mode too heavy for draft quality"]
> **CONFIDENCE:** [high / medium / low]
>
> **Confirm?** [yes / modify / abort]

**Why SCOPE is required.** Refine cycles without a declared boundary accumulate drift cycle-over-cycle — each cycle's critique surfaces adjacent concerns, the revision absorbs them, scope quietly doubles. IN/OUT/NEVER contract locks the target at plan gate so cycle N+1 can't broaden what cycle N agreed to. NEVER carries reason: `NEVER: expand rubric (reason: rubric is a separate /refine target at rules/common/output-discipline.md)`.

Write approved plan to `outputs/refine/{slug}/plan.md` + `sessions/scratchpad.md` under `## Plan History`.

### 8-dimension rubric (default quality bar — split invariants vs variants)

Each cycle scores the current draft (0–2 per dim, total /16). Same rubric as `/think spec` promotion gate — reused, not duplicated. **Dimensions are split into INVARIANTS and VARIANTS per the FP-OS decision protocol and the invariants-vs-variants rule in [output-discipline.md](../rules/common/output-discipline.md)**, so a draft that scores high on variants cannot paper over a missed invariant.

**Invariants (binary-like, floor ≥1, AND-aggregated).** Each invariant dim MUST score ≥1; any invariant at 0 → REWORK regardless of total.

| # | Invariant dim | 0 (FAIL) | 1 | 2 |
|---|---|---|---|---|
| 1 | **Acceptance criteria** | None stated | Vague / incomplete | MECE, testable, pass/fail per item |
| 4 | **Cross-references** | Broken / orphaned / missing | Some valid, some missing | All valid, no orphans |
| 5 | **Freshness / grounding** | Stale refs or unsourced claims | Minor gaps | All refs current, claims sourced |
| 6 | **Structural compression** | Topic-first opener, no outline, meta-content crowds substance, version markers in main body, metadata inconsistent, no action anchor | Some friction; opening and outline present but meta-content ≥5% or main body carries version markers | Opens with positioning sentence + outline (`**Covers:** ...`); meta-content ≤5%; no main-body version markers; metadata consistent; closes with a named action anchor. Matches the artifact discipline rules in [output-discipline.md](../rules/common/output-discipline.md). |
| 7 | **Doc-type articulation** | No `doc-type:` frontmatter declared, OR declared but first three H2s don't match the doc-type ordering | `doc-type:` declared but drill-down reorders the why/what/how sequence for the declared type | `doc-type:` + `audience:` + `reader-output:` frontmatter present; first three H2s match the order keywords for the declared type; reader sees why/what/how in the correct sequence for the document's primary question |
| 8 | **Voice discipline** | Three or more AI-smell patterns present (em-dash sandwich, padding openers, summary-announcement openers, faux-specific vagueness, meta-about-meta, symmetric triples at every abstraction level); section sigils (`§\d`) present in spec prose | Some voice drift; one AI-smell pattern present but not habitual; no section sigils | Prose reads as Gary's register: em-dash density ≤ 1 per 25 words; no padding openers repeated; no section sigils; compression over announcement. Matches the voice rules in [output-discipline-voice.md](../rules/common/output-discipline-voice.md). |

**Variants (continuous, weighted, trade-offs allowed).** Accumulate toward the total; no individual floor.

| # | Variant dim | 0 | 1 | 2 |
|---|---|---|---|---|
| 2 | **Edge cases** | None | Some listed | Exhaustive (empty, overflow, error, concurrent, stale) |
| 3 | **Data model / structure** | Absent | Fields listed, no types | Full schema (types, constraints, defaults, nullability) |

**Quality bar:** ≥13/16 AND every invariant dim (1, 4, 5, 6, 7, 8) ≥1. A cycle that regresses any invariant dim fails convergence — invariants are AND-aggregated; a draft with one invariant at 0 cannot promote even if it scores 2 on every variant.

**Why the split is load-bearing.** Mixing invariants and variants in one additive table is the most common decision failure in the FP-OS protocol: a weighted-sum lets reviewers rationalise past a deal-breaker ("low on dim 1, high on everything else — ship it") or kill a good option for missing a nice-to-have. Separating them forces the invariant check to bite before the variant score is even computed.

**Why dim 8 (voice) is separate from dim 6 (structural).** The 2026-04-19 spec-quality research found that structural rules had one scoring dim while voice rules had none. A spec could nail structure and still read as AI slop — scoring high enough to promote. Splitting voice into its own invariant closes that hole.

**Override:** `/refine <target> --bar="every claim has a citation"` replaces the rubric with declared criteria — but the author must still name which custom criteria are invariants (must all pass) vs variants (scored). Override does NOT exempt invariants 6, 7, 8 — structural compression, doc-type articulation, and voice discipline always apply to artifacts.

### Stop criteria (checked after every cycle)

| Condition | Action |
|---|---|
| Quality bar met AND no regression vs previous cycle | **CONVERGED** — exit loop |
| Same gaps recurring 2+ cycles | **STUCK** — flag to Gary, suggest upstream fix or mode escalation |
| All remaining gaps MEDIUM/LOW AND cycle ≥ 2 | **GOOD ENOUGH** — exit, note polish items |
| Cycle cap hit | **CAP HIT** — exit, report remaining gaps |

**Gap severity:** 🔴 CRITICAL (blocks promotion) · 🟠 HIGH (degrades quality) · 🟡 MEDIUM (polish) · 🟢 LOW (cosmetic).

### Artifact trail

```
outputs/refine/{target-slug}/
├── plan.md           — approved plan from plan gate
├── cycle-1/
│   ├── critique.md   — mode-specific output (self-critique / fresh-agent / council synthesis)
│   ├── revision.md   — revised draft
│   ├── score.md      — rubric score + delta vs baseline
│   └── verdict.md    — continue / stop + reason
├── cycle-N/ ...
└── synthesis.md      — final state + cycle-by-cycle score trend
```

---

## `/refine <target>` — self-iterate (default)

**Per-cycle loop (≤ 15 min):**
1. Read current draft.
2. Score against rubric (or `--bar` override).
3. List top 3-5 gaps by severity.
4. Revise directly, tackling highest severity first.
5. Write revision + score-delta to `cycle-{N}/`.
6. Check stop criteria.

**Agent:** main context only. No sub-agents. Cheapest mode.

**When to pick:** you know the draft's weaknesses, need discipline to close them.

---

## `/refine fresh <target>`

**Per-cycle loop (~ 5-10 min per cycle):**
1. Spawn a fresh-context general-purpose agent. Input: current draft + quality bar. **No conversation history.**
2. Fresh agent produces `critique.md` — gaps, unclear claims, missing edge cases.
3. Main context reads critique, revises draft, writes revision + score-delta.
4. Check stop criteria.

**Agent:** 1 fresh sub-agent per cycle (general-purpose, fresh context each cycle).

**When to pick:** you've been staring at the draft too long; need a naive first-time reader. Prevents the "author defending their draft" trap.

---

## `/refine council <target> [--mode=arx-behavioral|spec-structural]`

**Mode default:** `arx-behavioral` (backward-compatible — the 6-archetype Arx trader council). Pass `--mode=spec-structural` when refining a spec artifact — the Arx trader pool is the wrong lens for structural drift (positioning, doc-type ordering, invariants/variants split, consequence tracing).

**Roster by mode:**

| Mode | Roster | When to use |
|---|---|---|
| `arx-behavioral` (default) | 6 Arx archetypes (3 S2 + 3 S7) + synthesizer per `commands/review.md` council protocol | Product UX, cross-journey logic, trust-critical flow, behavioral drift |
| `spec-structural` | `first-principles`, `contrarian`, `architect`, `doc-type-auditor`, `signal-calibrator`, `consequence-tracer` + synthesizer | Strategy / product / design specs where the failure mode is structural (missing positioning opener rule, doc-type ordering wrong, AC not split, Consequences absent, atoms not traced to cause) |

**Per-cycle loop (~ 15-25 min per cycle):**
1. Spawn the mode's 6-agent roster in fresh context. For `spec-structural`, `doc-type-auditor` holds a VETO on positioning opener or doc-type ordering / 8-primitive / AC-split failures.
2. Council verdicts → synthesizer → `critique.md` (synthesis) for this cycle.
3. Main context revises draft against synthesis.
4. Write revision + score-delta + convergence check (did council concerns drop cycle-over-cycle? track BLOCK / CONCERN / APPROVE counts).
5. Check stop criteria. **Additional council-specific stop:** ≥ 4 of 6 archetypes APPROVE AND quality bar met. For `spec-structural`, `doc-type-auditor` must APPROVE regardless of the 4/6 majority — a VETO blocks promotion.

**Agent:** 6 archetype agents + 1 synthesizer per cycle. Expensive.

**When to pick `arx-behavioral`:** high-stakes document where behavioral plausibility is the bar (product UX, copy-trading mechanics, onboarding flow).

**When to pick `spec-structural`:** strategy spec, product spec, design spec, or decision record where structural integrity (artifact discipline + 8 primitives) is the bar. Pick this mode when the Arx behavioral lens would produce feedback about trader mechanics instead of doc structure.

---

## Synthesis (post-loop, all modes)

After exit condition fires:

1. Write `synthesis.md` with these mandatory H2s (in order):
   - **`## Context`** — what was refined and why this cycle ran
   - **`## Outcome`** — cycles completed + exit reason + score trend (start → end)
   - **`## Selection Rule`** — the aggregation rule used to pick CONVERGED vs STUCK vs GOOD ENOUGH, in the FP-OS rule form **"maximise X subject to invariants Y"** (e.g., *"Select CONVERGED when total ≥ 13/16 AND every invariant dim ≥ 1 AND no regression in dims 6, 7, 8 cycle-over-cycle"*). Without this rule, the synthesis presents a verdict without the aggregation — reader sees the call but not how it was made.
   - **`## Gaps remaining`** — resolved vs remaining, with severity
   - **`## Next action`** — promote / another cycle / hand off / abandon
2. Present: "Refine complete. {N} cycles, {reason}. Score {start → end}. Selection rule: {one line}. {remaining} gaps remain. Promote to specs/ / hand off to /build / another cycle?"

---

## Anti-patterns

- Don't start **council** mode on a draft that can't clear **self** mode first — council will BLOCK on basics, wasting the expensive lane. Escalate, don't skip.
- Don't exceed 5 cycles. If stuck at cycle 5, the problem is upstream — redo `/think discover` or `/think spec`.
- Don't refine across multiple artifacts in one run — one target at a time.
- Don't skip the plan gate for **council** — 6 agents in parallel is not a blind decision.
- Don't refine and build simultaneously — refine is prebuild.
