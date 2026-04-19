---
description: "Refine — iterative convergence loop: tighten a target until quality bar met, cycle cap hit, or stuck. Three modes: /refine (self-iterate), /refine fresh (outside-eyes each cycle), /refine council (6-archetype council each cycle). TRIGGER when user wants to iterate — phrases like 'refine X', 'iterate on X', 'tighten this', 'keep going until converged'. SKIP for one-shot improvements (use /review or direct edits) or topics with no pre-existing draft (run /think discover first)."
---

# /refine — Convergence Loop

**Purpose:** Iteratively tighten a target until a declared quality bar is met. Canonical entry — there is no `/gos refine` or `/review refine`.

**Three modes, three cost tiers, one contract.**

| Mode | Per-cycle critic | When |
|---|---|---|
| `/refine <target>` | Main context self-critiques against the 5-dim rubric | Cheap. Tighten prose, close known gaps. |
| `/refine fresh <target>` | Fresh-context agent critiques (naive reader each cycle) | Medium. Too close to it; need outside eyes. |
| `/refine council <target>` | 6-archetype council + synthesizer | Expensive. High-stakes doc where multi-lens matters. |

Pick the cheapest mode that clears the quality bar. Escalate (self → fresh → council) only if the cheaper mode stalls.

---

## Shared contract (all three modes)

### Plan gate (mandatory, before any cycle)

Present to Gary and WAIT:

> **PLAN:** [target file + what "tight" looks like]
> **MODE:** [self / fresh / council]
> **QUALITY BAR:** [default: 5-dim rubric ≥ 8/10 · override with `--bar="custom criteria"`]
> **CYCLE CAP:** [default 3, max 5]
> **MEMORY:** [L1 check — prior refine runs on this topic]
> **RISK:** [biggest risk — e.g., "scope too broad" / "mode too heavy for draft quality"]
> **CONFIDENCE:** [high / medium / low]
>
> **Confirm?** [yes / modify / abort]

Write approved plan to `outputs/refine/{slug}/plan.md` + `sessions/scratchpad.md` under `## Plan History`.

### 6-dimension rubric (default quality bar)

Each cycle scores the current draft (0–2 per dim, total /12). Same rubric as `/think spec` promotion gate — reused, not duplicated. Dimensions 1–5 reward content coverage; dimension 6 rewards compression and reader ease, so the rubric can no longer be gamed by pure accretion.

| # | Dimension | 0 | 1 | 2 |
|---|---|---|---|---|
| 1 | **Acceptance criteria** | None | Vague / incomplete | MECE, testable, pass/fail per item |
| 2 | **Edge cases** | None | Some listed | Exhaustive (empty, overflow, error, concurrent, stale) |
| 3 | **Data model / structure** | Absent | Fields listed, no types | Full schema (types, constraints, defaults, nullability) |
| 4 | **Cross-references** | None / broken | Some | All valid, no orphans |
| 5 | **Freshness / grounding** | Stale / unsourced | Minor gaps | All refs current, claims sourced |
| 6 | **Reader friction / compression** | Topic-first opener, no outline, meta-content crowds substance, version markers in main body, metadata inconsistent | Some friction; opening and outline present but concept density uneven or main body carries version markers | Fresh reader produces accurate summary in 30 seconds; opens with positioning + outline; meta-content ≤5%; no main-body version markers; metadata consistent; closes with action anchor. Matches `rules/common/output-discipline.md` §6. |

**Quality bar:** ≥10/12 AND dimension 6 ≥1. A cycle that regresses dimension 6 vs the prior cycle fails convergence — forcing compression before advance.

**Override:** `/refine <target> --bar="every claim has a citation"` replaces the rubric with declared criteria. Score pass/fail against custom criteria. Override does NOT exempt dimension 6 — reader friction always applies to artifacts.

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

## `/refine council <target>`

**Per-cycle loop (~ 15-25 min per cycle):**
1. Spawn the 6-archetype Arx council (3 S2 + 3 S7) in fresh context per `commands/review.md` council protocol.
2. Council verdicts → synthesizer → `critique.md` (synthesis) for this cycle.
3. Main context revises draft against synthesis.
4. Write revision + score-delta + convergence check (did council concerns drop cycle-over-cycle? track BLOCK / CONCERN / APPROVE counts).
5. Check stop criteria. **Additional council-specific stop:** ≥ 4 of 6 archetypes APPROVE AND quality bar met.

**Agent:** 6 archetype agents + 1 synthesizer per cycle. Expensive.

**When to pick:** high-stakes document (strategic spec, cross-journey logic, trust-critical flow) where single-lens critique would miss behavioral or mechanical issues.

---

## Synthesis (post-loop, all modes)

After exit condition fires:

1. Write `synthesis.md`:
   - Cycles completed + exit reason
   - Cycle-by-cycle score trend (or BLOCK/CONCERN/APPROVE trend for council)
   - Gaps resolved, gaps remaining
   - Final draft path
2. Present: "Refine complete. {N} cycles, {reason}. Score {start → end}. {remaining} gaps remain. Promote to specs/ / hand off to /build / another cycle?"

---

## Anti-patterns

- Don't start **council** mode on a draft that can't clear **self** mode first — council will BLOCK on basics, wasting the expensive lane. Escalate, don't skip.
- Don't exceed 5 cycles. If stuck at cycle 5, the problem is upstream — redo `/think discover` or `/think spec`.
- Don't refine across multiple artifacts in one run — one target at a time.
- Don't skip the plan gate for **council** — 6 agents in parallel is not a blind decision.
- Don't refine and build simultaneously — refine is prebuild.
