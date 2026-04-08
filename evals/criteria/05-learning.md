---
dimension: Learning
number: 5
weight: 1.5
---

# Learning

**What it measures:** Signal capture, eval rubrics, pattern extraction, and self-improvement velocity.

## Scoring Ladder

| Score | Level | Evidence Required |
|-------|-------|-------------------|
| 1-3 | Static | No signal capture. No evals. Same mistakes repeated. |
| 4-5 | Manual | Signals logged via /gos save but not automated. Few rubrics. No pattern extraction. |
| 6-7 | Instrumented | Stop+PreCompact hooks auto-capture signals. Rubrics exist for all verbs. Evolve audits run periodically. Repeat signals trigger immediate fixes. |
| 8-9 | Adaptive | Auto-signal hooks fire on every session end. Instinct pipeline extracts patterns. /evolve audit proposes upgrades with implementation plans. Rubric scores trend upward. |
| 10 | Self-improving | Fully automated learning loop — signals → patterns → instincts → command upgrades → re-evaluation → confirmed improvement. No human intervention needed for routine improvements. |

## What to Check

- Do Stop and PreCompact hooks capture evolve signals?
- Do all 8 verbs have eval rubrics?
- Are evolve audits running (check frequency — should be weekly+)?
- Do repeat signals trigger immediate memory/command updates?
- Is there a gap between "signals captured" and "improvements implemented"?
- Are eval scores trending upward over time?

## Weight: 1.5x

Learning is weighted higher because it's the mechanism by which all other dimensions improve over time.
