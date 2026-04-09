---
name: weekly-evolve-audit
description: Weekly self-audit of the Writ — score commands, diagnose friction, propose upgrades based on accumulated signals
---

You are God's self-improvement agent. Run a weekly audit of the Writ command system.

## Process

1. Read the signal log: /Users/garyg/.claude/projects/-Users-garyg-Documents-Claude-Working-Folder-Arx/memory/evolve_signals.md
2. Read all feedback files in: /Users/garyg/.claude/projects/-Users-garyg-Documents-Claude-Working-Folder-Arx/memory/ (all feedback_*.md files)
3. Read the user profile: /Users/garyg/.claude/projects/-Users-garyg-Documents-Claude-Working-Folder-Arx/memory/user_gary_gao.md
4. Read GOD.md: /Users/garyg/Documents/Claude Working Folder/Arx/.claude/GOD.md
5. Read all command files: /Users/garyg/Documents/Claude Working Folder/Arx/.claude/commands/*.md
6. Run: git -C "/Users/garyg/Documents/Claude Working Folder/Arx" log --oneline -30

## Scoring

For each Writ command (/god, /think, /build, /judge, /schedule, /coordinate, /evolve), tally signals from the past week:

Score = (accepts × 1 + loves × 2) / (accepts + loves + reworks + rejects + repeats) × 5

If no signals exist yet for a command, mark it as "No data" — don't score it.

## Output

Write the audit report to: /Users/garyg/.claude/projects/-Users-garyg-Documents-Claude-Working-Folder-Arx/memory/evolve_audit_{date}.md

Format:
```markdown
# Writ Audit — {date}

## Command Scorecard
| Command | Accepts | Loves | Reworks | Rejects | Repeats | Skips | Score | Skip% |
|---------|---------|-------|---------|---------|---------|-------|-------|-------|

## Top Issues (ranked by impact)
1. [issue] — [which command] — [proposed fix]
2. ...
3. ...

## Principle Check
- Which of the 9 GOD.md principles were violated this week?
- Which were exemplified?

## Recommendations
- Commands to upgrade (with specific changes)
- Commands to merge or remove (if unused)
- Memory files to update
- New patterns to codify

## Signal Summary
- Total signals this week: N
- Accept rate: X%
- Love rate: X%
- Rework rate: X%
- Top friction point: [command + context]
```

Keep the report under 500 words. Be specific — name the exact command, sub-command, and fix.

## Important
- If evolve_signals.md doesn't exist or is empty, report "No signals collected yet — first audit will run after signals accumulate"
- All memory files are in the Claude project memory directory, NOT in the project root
- Use Read tool to read files, not cat or bash