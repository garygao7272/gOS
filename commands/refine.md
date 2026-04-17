---
description: "Refine — prebuild convergence loop (alias for /review refine). TRIGGER when user wants to iterate until something is tight — phrases like 'refine X', 'iterate on X until it converges', 'tighten this', 'keep going until it's right', 'close the gaps on X', 'keep improving until we're done'. SKIP for one-shot improvements — use /review code or direct editing instead."
---

# /refine — Alias for `/review refine`

**Canonical entry:** `/review refine <topic> [max-iterations]`. This file is a backward-compat alias so existing habits and scripts keep working.

**Why:** `/refine` is a review-driven convergence loop — iteratively tighten specs, designs, and simulations before `/build`. Since the loop IS a review pattern, it belongs under `/review` (atomicity: one intent = one home). See [commands/review.md](./review.md) for the full flow, depth ladder, convergence rules, and anti-patterns. Rubric stays at `evals/rubrics/refine.md`.

**Routing:** When invoked as `/refine <topic> [max-iterations]`, execute `/review refine <topic> [max-iterations]` with identical semantics. `/gos refine` also routes here.

**Do not re-document the loop here.** Single source of truth lives in `/review refine`.
