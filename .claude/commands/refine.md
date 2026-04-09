---
effort: high
description: "Refine — prebuild convergence loop: think, design, simulate, review, repeat until gaps close"
---

# Refine — Prebuild Convergence Loop

**Purpose:** Iteratively tighten specs, designs, and simulations before building. Each cycle runs think → design → simulate → review, with review feeding gaps back into the next think pass. Stops at convergence or max iterations.

**Usage:** `/refine <topic> [max-iterations]`

- `<topic>` — feature area or scope (e.g., "copy trading", "onboarding flow", "full MVP")
- `[max-iterations]` — optional, default 5. Safety cap even when targeting convergence.

**Example:** `/refine copy-trading-radar 3`

---

## How It Works

Each cycle combines two strategies:

1. **Gap-hunting:** Each phase finds what's missing, weak, or contradictory. Review produces a numbered gap list that seeds the next think pass.
2. **Progressive deepening:** Cycle 1 = surface coverage. Cycle 2 = edge cases + persona stress. Cycle 3+ = adversarial scenarios + failure modes.

### Depth Ladder

| Cycle | Focus Layer | Think Lens                          | Design Lens                       | Simulate Lens            | Review Lens                       |
| ----- | ----------- | ----------------------------------- | --------------------------------- | ------------------------ | --------------------------------- |
| 1     | Surface     | Spec completeness, missing sections | Layout gaps, missing states       | Happy path scenarios     | Gap count + severity              |
| 2     | Edge cases  | User edge cases, error paths        | Empty/error/loading states        | Bull/bear/edge scenarios | Persona walkthrough (Jake, Sarah) |
| 3     | Adversarial | Attack vectors, abuse cases         | Deceptive patterns, accessibility | Tail risk, black swan    | Council (multi-persona)           |
| 4+    | Polish      | Consistency, language precision     | Micro-interactions, motion        | Stress test at scale     | Diminishing returns check         |

---

## Plan Gate (mandatory — runs before starting the loop)

**Proactive Memory Recall (execute before presenting the plan):**
1. Read `memory/L1_essential.md` — check for relevant feedback rules and known gaps in the target area
2. Search L2 memory files for keywords matching this refine target (e.g., topic name, screen name, spec area)
3. If L2 mentions past refine sessions, convergence issues, or corrections — surface it in the MEMORY field below
4. Only query L3 (claude-mem/spec-rag) if L2 doesn't have relevant context

Then present this to Gary and WAIT for confirmation:

> **PLAN:** [1-line restatement of what you'll refine — comprehension check]
> **SCOPE:** [which specs/designs/simulations are in scope]
> **ITERATIONS:** [target iteration count and convergence criteria]
> **STEPS:**
> 1. [action] — [why this first]
> 2. [action] — [depends on #1]
> 3. [action] — [why]
> **MEMORY:** [check L1_essential.md — "last refine on this topic: ...", "known gaps: ..."]
> **RISK:** [biggest risk — e.g., "scope too broad, may not converge in N iterations"]
> **CONFIDENCE:** [high/medium/low] — [1-line reason]
>
> **Confirm?** [y / modify / abort]

After confirmation:
1. Write approved plan to `sessions/scratchpad.md` under `## Plan History`
2. Create TodoWrite items for each cycle
3. Begin execution, updating TodoWrite as each cycle completes

---

## Execution Pipeline

### Phase 0: Initialize

```
1. Parse $ARGUMENTS → extract topic and max_iterations (default 5)
2. Initialize scratchpad:
   - Mode: "Refine > {topic}"
   - Working State: "Cycle 0 / {max_iterations} — initializing"
3. Context Protocol: load specs matching topic keywords (via context-map.md)
4. Create tracking file: outputs/think/refine/{topic}-refine-log.md
5. Seed gap list: run a quick scan of existing specs/designs for the topic
   - What specs exist? What's missing?
   - What designs exist? What screens are unspecified?
   - What simulations have been run?
   → Produce initial gap list (the "Cycle 0 gaps")
```

### Phase 1-N: The Loop

For each cycle (1 to max_iterations):

```
┌─────────────────────────────────────────────────────────┐
│ THINK (gap-informed)                                     │
│                                                          │
│ Input: gap list from previous review (or Cycle 0 scan)  │
│ Focus: address top 3-5 gaps by severity                  │
│ Depth: apply depth ladder for current cycle number       │
│ Output: updated specs or new spec sections               │
│ Agent: 2-3 parallel researchers (sonnet)                 │
│ → Write findings to refine log                           │
└──────────────────────┬──────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│ DESIGN (spec-informed)                                   │
│                                                          │
│ Input: updated specs from think phase                    │
│ Focus: visual/interaction gaps from gap list              │
│ Depth: apply depth ladder for current cycle number       │
│ Output: design spec updates or new wireframe sections    │
│ Agent: design audit agent (sonnet)                       │
│ → Write design decisions to refine log                   │
└──────────────────────┬──────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│ SIMULATE (stress-test)                                   │
│                                                          │
│ Input: current specs + designs                           │
│ Focus: scenario generation at current depth              │
│ Depth: happy path → edge → adversarial → scale          │
│ Output: scenario findings, risk flags                    │
│ Agent: bull-case + bear-case builders (sonnet)           │
│ → Write scenario results to refine log                   │
└──────────────────────┬──────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│ REVIEW (convergence check)                               │
│                                                          │
│ Input: all outputs from think + design + simulate        │
│ Focus: find NEW gaps not present in previous gap list    │
│ Classification:                                          │
│   🔴 CRITICAL — blocks build, must fix                   │
│   🟠 HIGH — degrades UX significantly                    │
│   🟡 MEDIUM — polish item, nice to have                  │
│   🟢 LOW — cosmetic or future consideration              │
│                                                          │
│ Output: numbered gap list with severity + source phase   │
│ Agent: review council (opus for adjudication)            │
│                                                          │
│ CONVERGENCE CHECK:                                       │
│   new_critical = count of 🔴 gaps NOT in previous list   │
│   new_high = count of 🟠 gaps NOT in previous list       │
│                                                          │
│   IF new_critical == 0 AND new_high <= 2:                │
│     → CONVERGED. Exit loop.                              │
│   ELSE:                                                  │
│     → Continue. Feed gap list to next cycle's think.     │
└─────────────────────────────────────────────────────────┘
```

### Phase N+1: Synthesis

After loop exits (convergence or max iterations):

```
1. Compile refine log into summary:
   - Cycles completed: N
   - Exit reason: convergence | max iterations
   - Total gaps found: X (by severity breakdown)
   - Total gaps resolved: Y
   - Remaining gaps: Z (listed with severity)
   - Key decisions made across cycles
   - Spec files updated
   - Design files updated

2. Write summary to: outputs/think/refine/{topic}-refine-summary.md
   With artifact header:
   ---
   artifact_type: decision
   created_by: /refine
   topic: {topic}
   status: reviewed
   ---

3. Present to Gary:
   "Refine complete. {N} cycles, {exit_reason}.
    {resolved_count} gaps resolved, {remaining_count} remain.
    Top remaining: [list top 3 with severity]
    Ready for /build? Or run another pass?"

4. Update scratchpad with final state
```

---

## Convergence Rules

| Condition                     | Action                                            |
| ----------------------------- | ------------------------------------------------- |
| 0 new 🔴, ≤2 new 🟠           | **CONVERGED** — exit loop                         |
| Same gaps recurring 2+ cycles | **STUCK** — flag to Gary, suggest manual decision |
| All remaining gaps are 🟡/🟢  | **GOOD ENOUGH** — exit, note polish items         |
| Max iterations reached        | **CAP HIT** — exit, report remaining gaps         |

---

## Agent Allocation Per Cycle

Each cycle uses agents efficiently — not a full team, but targeted spawns:

| Phase    | Agents                          | Model  | Why                                  |
| -------- | ------------------------------- | ------ | ------------------------------------ |
| Think    | 2-3 parallel researchers        | sonnet | Independent spec sections, fast      |
| Design   | 1 design auditor                | sonnet | Sequential design decisions          |
| Simulate | 2 scenario builders (bull/bear) | sonnet | Adversarial pair                     |
| Review   | 1 adjudicator                   | opus   | Deepest reasoning for gap assessment |

**Cost estimate:** ~200K tokens per cycle. 3-cycle run ≈ 600K tokens. 5-cycle run ≈ 1M tokens.

**Use teams when:** ≥3 agents in a phase need to see each other's output (rare in refine — usually independent).

---

## Scratchpad Updates

Update `sessions/scratchpad.md` at each phase transition:

```markdown
## Working State

Refine > {topic}
Cycle: {N} / {max}
Phase: {think|design|simulate|review}
Depth: {surface|edge-cases|adversarial|polish}
Gap list: {count} total ({critical}/{high}/{medium}/{low})
Last phase output: {file path}
```

---

## Refine Log Format

File: `outputs/think/refine/{topic}-refine-log.md`

```markdown
---
artifact_type: decision
created_by: /refine
topic: { topic }
created_at: { ISO timestamp }
status: in-progress
---

# Refine Log: {Topic}

## Cycle 1 — Surface

### Think

- Gaps addressed: [list]
- Specs updated: [list]
- New findings: [list]

### Design

- Gaps addressed: [list]
- Design updates: [list]
- New findings: [list]

### Simulate

- Scenarios run: [list]
- Risk flags: [list]

### Review

- New gaps found: {count}
  - 🔴 CRITICAL: [list]
  - 🟠 HIGH: [list]
  - 🟡 MEDIUM: [list]
  - 🟢 LOW: [list]
- Convergence: {not yet | converged}

---

## Cycle 2 — Edge Cases

...
```

---

## Interaction With Other Commands

- `/refine` does NOT call `/think`, `/design`, `/simulate`, `/review` as sub-processes. It runs **lightweight versions** of each phase — focused on gap-hunting, not full deliverables.
- Think phase: researches and patches specs, doesn't produce full research briefs.
- Design phase: audits and extends existing designs, doesn't run full 5-stage pipeline.
- Simulate phase: runs targeted scenarios, not full MiroFish briefings.
- Review phase: produces gap lists, not full council verdicts.

This keeps each cycle fast (~5-10 min) instead of exhaustive (~30-60 min per full command).

---

## Quick Reference

```
/refine copy-trading 3          # 3 cycles max on copy trading
/refine onboarding              # default 5 cycles, convergence target
/refine "full MVP" 7            # broad scope, 7 cycle cap
/refine radar-v5 until-clean    # alias for convergence mode (default)
```

**Anti-patterns:**

- Don't refine AND build simultaneously — refine is prebuild
- Don't refine topics without existing specs — use `/think discover` first
- Don't set max iterations > 7 — diminishing returns, cost explodes
