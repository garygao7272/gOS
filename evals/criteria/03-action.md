---
dimension: Action
number: 3
weight: 1.0
---

# Action

**What it measures:** Execution quality — agent orchestration, parallel task execution, verification loops, and delivery.

## Scoring Ladder

| Score | Level | Evidence Required |
|-------|-------|-------------------|
| 1-3 | Broken | Execution fails. Wrong tools used. No error handling. |
| 4-5 | Sequential | Works but everything runs serially. No agent delegation. No verification. |
| 6-7 | Functional | Uses agents for parallel work. Basic error handling. Some verification. |
| 8-9 | Orchestrated | Teams for 3+ tasks. Model-routed agents (opus for review, sonnet for build, haiku for docs). Progress tracking via status.md. Verification loops on UI changes. |
| 10 | Masterful | Self-healing execution — detects failures, re-routes, adapts plan mid-flight. Cross-session handoffs for long jobs. |

## What to Check

- Are independent tasks executed in parallel (not sequential)?
- Are agents model-routed appropriately (opus for deep reasoning, sonnet for coding)?
- Is progress tracked in outputs/gos-jobs/*/status.md?
- Do UI changes get visual verification (preview_screenshot)?
- Are build errors caught and fixed before reporting success?
- Does `/build` follow TDD (RED→GREEN→REFACTOR)?
