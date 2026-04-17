---
description: "Refine — prebuild convergence loop: iteratively tighten specs, designs, and simulations before /build. Each cycle: think → design → simulate → review. TRIGGER when user wants to iterate until something is tight — phrases like 'refine X', 'iterate on X', 'tighten this', 'close the gaps', 'keep going until it's right'. SKIP for one-shot improvements (use /review code or direct edits) or topics with no pre-existing specs (run /think discover first)."
---

# /refine — Prebuild Convergence Loop

**Purpose:** Iteratively tighten specs, designs, and simulations before `/build`. Each cycle runs think → design → simulate → review; review feeds gaps back into the next cycle. Exits at convergence, stuck, good-enough, or max iterations. Canonical entry — there is no `/gos refine` or `/review refine`.

**Usage:** `/refine <topic> [max-iterations]`
**Default:** 5 iterations. Hard ceiling 7 (diminishing returns beyond).
**Example:** `/refine copy-trading-radar 3`

**Rubric:** `evals/rubrics/refine.md` — 5 dimensions (gap resolution, cycle rigor, convergence, depth progression, build-readiness) weighted to /10.

## When to use

Before any non-trivial `/build feature` that touches UI, flows, or specs. Skip for fixes, refactors, and single-file features.

## Depth Ladder

| Cycle | Think | Design | Simulate | Review |
|-------|-------|--------|----------|--------|
| 1 | Spec completeness | Layout gaps, missing states | Happy path | Gap count + severity |
| 2 | Edge cases, error paths | Empty/error/loading states | Bull/bear/edge | Persona walkthrough |
| 3 | Attack vectors, abuse | Accessibility, deception | Tail risk, black swan | Multi-persona council |
| 4+ | Consistency, precision | Micro-interactions, motion | Stress at scale | Diminishing returns check |

## Plan Gate (mandatory)

Before starting the loop, present to Gary and WAIT:

> **PLAN:** [1-line restatement of what will be refined]
> **SCOPE:** [which specs/designs/simulations are in scope]
> **ITERATIONS:** [target count + convergence criteria]
> **MEMORY:** [L1 check — prior refines on this topic, known gaps]
> **RISK:** [biggest risk — e.g., "scope too broad, may not converge in N"]
> **CONFIDENCE:** [high/medium/low — 1-line reason]
>
> **Confirm?** [y / modify / abort]

After confirmation:
1. Write approved plan to `sessions/scratchpad.md` under `## Plan History`.
2. Initialize tracking file `outputs/think/refine/{topic}-refine-log.md`.
3. Begin Cycle 0 scan to seed the gap list.

## Execution — the loop

Each cycle runs 4 phases in sequence. Input to phase N = output of phase N−1. Depth per cycle follows the ladder above.

| Phase | Input | Focus | Agents | Writes to |
|-------|-------|-------|--------|-----------|
| **THINK** | Gap list from previous review (or Cycle 0 scan) | Top 3-5 gaps by severity | 2-3 parallel researchers (sonnet) | Updated specs + refine log |
| **DESIGN** | Updated specs from THINK | Visual/interaction gaps | 1 design auditor (sonnet) | Design decisions in refine log |
| **SIMULATE** | Specs + designs | Stress scenarios (happy → edge → adversarial → scale) | Bull-case + bear-case (sonnet, parallel) | Scenario results in refine log |
| **REVIEW** | All outputs above | NEW gaps not in previous list | Review adjudicator (opus) | Numbered gap list with severity |

**Gap severity:** 🔴 CRITICAL (blocks build) · 🟠 HIGH (degrades UX) · 🟡 MEDIUM (polish) · 🟢 LOW (cosmetic).

## Convergence rules

| Condition | Action |
|-----------|--------|
| `new_critical == 0 AND new_high <= 2` | **CONVERGED** — exit loop |
| Same gaps recurring 2+ cycles | **STUCK** — flag to Gary, suggest manual decision |
| All remaining gaps MEDIUM/LOW | **GOOD ENOUGH** — exit, note polish items |
| Max iterations reached | **CAP HIT** — exit, report remaining gaps |

## Synthesis (post-loop)

1. Compile: cycles completed, exit reason, gaps found/resolved/remaining.
2. Write summary to `outputs/think/refine/{topic}-refine-summary.md`.
3. Present: "Refine complete. {N} cycles, {reason}. {resolved} gaps resolved, {remaining} remain. Ready for `/build`?"

## Anti-patterns

- Don't refine and build simultaneously — refine is prebuild.
- Don't refine topics without pre-existing specs — run `/think discover` first.
- Don't set max iterations > 7 — diminishing returns.
