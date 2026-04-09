# gOS 12-Dimension Scoring Criteria

These 12 dimensions measure gOS's capability as a superior AI co-creator. Each dimension is scored 1-10 with specific evidence thresholds. Calibrated against the north star vision in [VISION.md](VISION.md). Used by `/evolve audit` and `/refine` for self-evaluation.

Dimensions 4 (Memory), 5 (Learning), 11 (Craft), 12 (Testing), and 13 (Orchestration) are weighted 1.5x because they are force multipliers — poor scores cascade into poor everything.

## Scoring Guide

- **1-3:** Broken or missing — fundamental capability gap
- **4-5:** Exists but manual/unreliable — requires human intervention to work
- **6-7:** Functional but incomplete — works most of the time, known gaps
- **8-9:** Strong and automated — works reliably with minimal intervention
- **10:** Co-creator level — matches the [VISION.md](VISION.md) north star for this dimension

## Usage

```
/evolve audit          # Runs all 10 dimensions, produces scorecard
/refine <topic>        # Uses relevant dimensions as quality gates
```

## Dimensions

| # | Dimension | File | What It Measures |
|---|-----------|------|-----------------|
| 1 | Perception | `01-perception.md` | Context gathering, tool discovery, situational awareness |
| 2 | Planning | `02-planning.md` | Plan gates, decomposition, approval flows |
| 3 | Action | `03-action.md` | Execution quality, agent orchestration, verification |
| 4 | Memory | `04-memory.md` | Recall, persistence, cross-session continuity |
| 5 | Learning | `05-learning.md` | Signal capture, pattern extraction, self-improvement |
| 6 | Reasoning | `06-reasoning.md` | Multi-perspective analysis, first principles, bias checks |
| 7 | Communication | `07-communication.md` | Confidence scoring, progress updates, clarity |
| 8 | Autonomy | `08-autonomy.md` | PROCEED/ASK/JUDGMENT/STUCK framework adherence |
| 9 | Reliability | `09-reliability.md` | Hooks, safety nets, reproducibility, rollback |
| 10 | Metacognition | `10-metacognition.md` | Self-monitoring, drift detection, honesty about uncertainty |
| 11 | **Craft** | `11-craft.md` | Spec compliance, build quality, spec↔code sync (1.5x weight) |
| 12 | **Testing** | `12-testing.md` | TDD compliance, coverage, quality gates, verification (1.5x weight) |
| 13 | **Orchestration** | `13-orchestration.md` | Multi-agent spec-first coordination across 3 surfaces (1.5x weight) |
