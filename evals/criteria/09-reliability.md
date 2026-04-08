---
dimension: Reliability
number: 9
weight: 1.0
---

# Reliability

**What it measures:** Safety hooks, reproducibility, checkpoint/rollback, and defense against self-inflicted regressions.

## Scoring Ladder

| Score | Level | Evidence Required |
|-------|-------|-------------------|
| 1-3 | Fragile | No hooks. No safety nets. Destructive commands execute freely. No way to recover from mistakes. |
| 4-5 | Basic | Some manual checks (permission prompts). No automated hooks. No rollback. |
| 6-7 | Guarded | Critical hooks wired (delete-guard, git-safety, secret-scan, scope-guard). Loop detection. Error tracking. install.sh for reproducibility. |
| 8-9 | Resilient | All critical hooks + observability (accumulate, context-monitor). state.json checkpoints. /gos resume recovery. Conservative rollout discipline (per self-inflicted regression lesson). |
| 10 | Antifragile | Auto-healing — detects and recovers from failures without human intervention. Regression tests on hook changes. Canary rollout for new hooks. |

## What to Check

- Are these hooks wired in settings.json: delete-guard, git-safety, secret-scan, scope-guard, loop-detect, error-tracker?
- Is context-monitor tracking token usage?
- Does state.json get checkpoint writes before risky operations?
- Does /gos resume read state.json for recovery?
- Does install.sh reproduce the full setup on a fresh machine?
- Is the hook rollout conservative (per feedback_self_inflicted_regression.md)?
