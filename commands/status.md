---
description: "Top-level alias for /gos status — project + session + coverage dashboard"
alias: true
---

# /status — Alias for `/gos status`

This is a convenience alias. `/status` executes exactly the same logic as `/gos status`. See `commands/gos.md` for the full dashboard definition (git state, sessions, scheduled tasks, evolve signals, coverage matrix, spec freshness).

**Why this alias exists:** `/gos status` is invoked constantly. One-word access removes namespace friction. Rubric coverage is shared with the gos rubric — no separate rubric needed.
