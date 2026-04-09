---
name: evolve-audit-4h
description: Run /evolve audit every 4 hours — score command health, clean signals, generate upgrade proposals
---

You are gOS running an automated evolve audit for the Arx project at /Users/garyg/Documents/Claude Working Folder/Arx.

## Task

Run the /evolve audit process:

1. **Read signals:** Read `sessions/evolve_signals.md` and tally real signals per command (accept, rework, reject, love, repeat, skip). Ignore any "session-end" noise rows.

2. **Compute health scores:**
   Health = (accepts + 2 * loves) / total_invocations * 100
   Flag any command below 70%.

3. **Check git activity:** Run `git log --oneline -10` to see what was built since last audit.

4. **Compare to last audit:** Read `memory/evolve_audit_2026-04-03.md` (or most recent `memory/evolve_audit_*.md`) for baseline scores.

5. **If any command is below 70% health:**
   - Write an upgrade proposal to `~/.claude/evolve/proposals/{command}-{date}.md`
   - Format: evidence (signal summary), proposed changes (before/after), expected impact

6. **If signal count hasn't grown since last audit** (meaning no new signals were captured):
   - Flag this as "signal capture still broken" in the audit output
   - Do NOT generate noise — just note the gap

7. **Write audit results** to `memory/evolve_audit_{YYYY-MM-DD}.md` (update if same day, create new if different day). Update MEMORY.md index if new file created.

8. **Mark signal log:** Add `--- AUDITED {date} ---` separator after processing.

## Output

Write a concise audit summary. If there are actionable proposals, note them. If everything is healthy and no changes needed, just confirm "All commands healthy, no proposals generated."

## Important

- Do NOT make changes to command files directly — only write proposals
- Do NOT create noise if there's nothing to report
- Keep the audit under 2 minutes
- Working directory: /Users/garyg/Documents/Claude Working Folder/Arx