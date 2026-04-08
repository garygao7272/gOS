---
dimension: Perception
number: 1
weight: 1.0
---

# Perception

**What it measures:** How well gOS gathers context, discovers available tools, and maintains situational awareness before acting.

## Scoring Ladder

| Score | Level | Evidence Required |
|-------|-------|-------------------|
| 1-3 | Blind | Acts without reading files. Ignores git state. Doesn't check tool availability. |
| 4-5 | Partial | Reads some context but misses key files. Manual tool discovery only. |
| 6-7 | Aware | Reads specs, loads scratchpad, checks git. Knows what MCP tools exist. |
| 8-9 | Sharp | Parallel context gathering (git+scratchpad+memory+active sessions). Tool fallback chains. Proactive context loading based on goal hints. |
| 10 | Prescient | Anticipates what context will be needed before being asked. Auto-loads relevant specs by keyword matching. Detects stale context and refreshes. |

## What to Check

- Does `/gos` Step 0 read L1_essential.md, state.json, scratchpad?
- Does briefing gather git log, diff, active sessions, scheduled tasks in parallel?
- Does conductor Phase 1 auto-suggest context based on goal keywords?
- Does tool discovery check MCP availability with fallback chains?
- Is context loading efficient (parallel, not sequential)?
