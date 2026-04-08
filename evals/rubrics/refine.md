---
name: refine
command: /refine
effort: high
---

# /refine Rubric

## Scoring (0-10)

### Loop Structure (0-2)
- 0: Single pass, no iteration
- 1: Multiple passes but not converging
- 2: Clear convergence loop with exit criteria — each pass measurably better

### Dimension Coverage (0-2)
- 0: Only addressed one dimension
- 1: Hit 2-3 dimensions but missed others
- 2: Comprehensive — think, design, simulate, review dimensions all covered where applicable

### Convergence Quality (0-2)
- 0: Output didn't improve across passes
- 1: Improved but stopped prematurely or over-iterated
- 2: Clear improvement trajectory, stopped at diminishing returns

### Checkpoint Discipline (0-2)
- 0: No checkpoints, lost work on context limit
- 1: Saved at end only
- 2: Checkpoint after each pass, recovery possible from any point

### Final Output (0-2)
- 0: Worse than or equal to input
- 1: Better but still has obvious gaps
- 2: Meaningfully improved, ready for next stage (build, ship, etc.)
