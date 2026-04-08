---
dimension: Planning
number: 2
weight: 1.0
---

# Planning

**What it measures:** Quality of plan gates, task decomposition, risk assessment, and approval flows before execution.

## Scoring Ladder

| Score | Level | Evidence Required |
|-------|-------|-------------------|
| 1-3 | Impulsive | Jumps to execution without any plan. No risk assessment. |
| 4-5 | Informal | States intent but no structured plan. Missing dependencies or time estimates. |
| 6-7 | Structured | Plan Gate runs (PLAN→STEPS→RISK→CONFIDENCE). Decomposition exists but may miss parallelism. |
| 8-9 | Rigorous | Plan Gate with MEMORY search for dead ends. Task graph with dependencies. Parallel vs sequential marked. Gary approves before execution. |
| 10 | Strategic | Multi-scenario planning. Plans include fallback paths. Adaptive re-planning when conditions change mid-execution. |

## What to Check

- Does every non-trivial task get a Plan Gate?
- Does the plan search memory for dead ends before proposing?
- Are tasks decomposed with dependencies (P1 parallel, P2 sequential, P3 conditional)?
- Does the plan include time estimates and confidence?
- Does Gary see and approve the plan before execution?
- Is the plan gate skippable for trivial/atomic tasks? (it should be)
