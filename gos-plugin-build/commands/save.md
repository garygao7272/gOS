---
description: "Top-level alias for /gos save — persist session state + learning loop"
alias: true
---

# /save — Alias for `/gos save`

This is a convenience alias. `/save` executes exactly the same logic as `/gos save`. See `commands/gos.md` for the full flow (capture → signals → memory updates → state.json → scratchpad timestamp).

**Why this alias exists:** session persistence runs at the end of most work blocks. One-word access matters. Rubric coverage is shared with the gos rubric.
