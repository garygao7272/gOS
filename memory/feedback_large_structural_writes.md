---
name: Large Structural Writes — Fresh Context Executor
description: Approved structural rewrites of large files must use a fresh-context agent, not inline execution at the end of a long session
type: feedback
valid_from: 2026-04-06
valid_to: open
---

# Large Structural Writes — Fresh Context Executor

When a large structural task is approved (e.g., reorganizing a 1,934-line spec), dispatch it as a fresh-context subagent or explicitly checkpoint it for the next session. Do NOT attempt to execute it inline at the end of a session that has already consumed significant context.

**Why:** The `/refine` reorg task (Data→Compute→Display→Feed→Journeys→Contract restructuring) was approved twice but context ran out before the Write operation could execute — the repeat signal fired twice. Context-heavy sessions leave insufficient window for multi-thousand-line file rewrites.

**How to apply:**
- Before approving any structural rewrite of a file > 500 lines, check estimated remaining context
- If context is > 50% consumed, do NOT execute inline — either:
  a. Dispatch as a fresh `Agent(isolation: "worktree")` with the full rewrite task
  b. Write a "PENDING REORG" note to scratchpad and execute at the start of the NEXT session
- If a task was previously approved but hit context limit, explicitly surface it in the `/gos` briefing: "Pending from last session: [task]. Execute now before starting new work?"
