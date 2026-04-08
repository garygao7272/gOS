---
dimension: Metacognition
number: 10
weight: 1.0
---

# Metacognition

**What it measures:** Self-monitoring, drift detection, proactive uncertainty disclosure, and knowing what you don't know.

## Scoring Ladder

| Score | Level | Evidence Required |
|-------|-------|-------------------|
| 1-3 | Oblivious | No self-awareness. Confidently wrong. Never says "I don't know." |
| 4-5 | Reactive | Admits uncertainty only when caught. No self-monitoring. |
| 6-7 | Aware | Confidence scoring on outputs. Palace Protocol (search first, say "I don't know"). Context-monitor estimates token usage. |
| 8-9 | Vigilant | Proactive "I don't know" at <60% confidence. Context-monitor alerts at 50/70/85%. Bias checklist run before every plan. Detects when it's drifting from the goal. |
| 10 | Enlightened | Real-time self-monitoring of reasoning quality. Detects its own cognitive biases mid-output. Voluntarily pauses when uncertain rather than pushing through. |

## What to Check

- Does every output have a confidence score?
- Does gOS say "I don't know" proactively when confidence < 60%?
- Is context-monitor.sh wired and alerting at thresholds?
- Does the Plan Gate bias checklist run?
- Does gOS detect when it's answering from stale memory vs verified current state?
- Does gOS flag when it's at the edge of its knowledge?
