---
name: daily-evolve
description: Nightly auto-evolve: scan session signals, score command health, generate upgrade proposals, update memories
---

Run the gOS daily auto-evolve cycle. This is the automated version of /evolve audit.

1. Read sessions/evolve_signals.md — gather all signals from today's date
2. Read recent session files from ~/.claude/sessions/ — look for today's sessions
3. For each command that received signals today:
   - Calculate health score: (accepts + 2*loves) / total_signals * 100
   - Identify patterns:
     - High rework rate → format or output quality issue
     - High skip rate → too much friction, step should be optional
     - Repeat signals → gOS didn't retain a correction
     - Never used → needs better docs or should be merged
     - High love rate → protect this, don't change it
4. For commands scoring below 70% health:
   - Read the command file from gOS/.claude/commands/{command}.md
   - Diagnose the specific issue from signal patterns
   - Generate a concrete upgrade proposal with before/after diffs
   - Save proposal to ~/.claude/evolve/proposals/{command}-{date}.md
5. For any "repeat" signals found today:
   - The same instruction was given twice — gOS didn't learn
   - Immediately save the correction to memory/feedback_*.md
   - This is the highest-priority fix: prevent repeats
6. For any "love" signals found today:
   - Note what worked well in memory — protect these patterns
   - Save positive reinforcement to project memory
7. Write a daily evolve report to outputs/briefings/evolve-{date}.md with:
   - Total signals processed
   - Per-command health scores
   - Proposals generated (if any)
   - Memories updated (if any)
   - Trends vs previous days (if prior reports exist)

IMPORTANT: Do NOT modify command files directly. Only generate proposals and update memories.
Proposals are reviewed by Gary in the next session via /evolve proposals or the /gos briefing.