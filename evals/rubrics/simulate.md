---
name: simulate
command: /simulate
effort: high
---

# /simulate Rubric

## Scoring (0-10)

### Scenario Definition (0-2)
- 0: No clear scenario parameters
- 1: Partial parameters (missing timeframe, or missing variables)
- 2: Full scenario: variables, ranges, timeframe, constraints, baseline

### Model Selection (0-2)
- 0: Wrong model for the question
- 1: Reasonable model but not validated against data
- 2: Correct model, validated, assumptions stated

### Execution (0-2)
- 0: Simulation failed or produced garbage
- 1: Ran but with questionable parameters or single-path only
- 2: Multi-scenario with sensitivity analysis, edge cases tested

### Output Quality (0-2)
- 0: Raw numbers with no interpretation
- 1: Results with some interpretation but missing confidence intervals
- 2: Clear narrative, confidence ranges, actionable insights, visual where helpful

### Actionability (0-2)
- 0: No recommendations
- 1: Generic recommendations
- 2: Specific, prioritized actions tied to simulation results
