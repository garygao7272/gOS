---
name: spec-drift
description: Detect when code changes make specs stale
trigger: post-commit
model: haiku
---

# Spec Drift Claw

## Purpose
After git commits, diff changed files against spec references. Flag specs that reference changed paths as potentially stale.

## Trigger
Event-driven, not cron. Runs after every `git commit` in an Arx project directory.

To wire as a PostToolUse hook, add to settings.json:
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Bash",
      "pattern": "git commit",
      "action": "Read ~/.claude/claws/spec-drift/claw.md and execute"
    }]
  }
}
```

## Execution Steps

1. Get the latest commit diff: `git diff HEAD~1 --name-only`
2. Read `state.json` for previously flagged stale specs
3. For each changed file path:
   - Search `specs/` directory for any spec that references this path
   - Use: `grep -rl "{changed_path}" specs/` or grep for the filename without path
   - Also check for component/module names mentioned in specs
4. For each spec that references a changed file:
   - Record: spec path, changed file, commit hash, date
   - Add to `state.json.stale_specs` (if not already flagged for this commit)
5. Remove entries from `stale_specs` where the spec file itself was updated in this commit (self-healing)
6. Write `state.json`

## Output Format (in state.json)

```json
{
  "last_run": "ISO timestamp",
  "run_count": 0,
  "last_commit": "commit_hash",
  "stale_specs": [
    {
      "spec_path": "specs/Arx_4-1-1-3_Copy_Trading.md",
      "changed_files": ["apps/mobile/src/screens/Trade.tsx"],
      "commit": "abc1234",
      "flagged_date": "ISO timestamp",
      "resolved": false
    }
  ],
  "last_digest": null
}
```

## Surfacing in /gos Briefing

```
Claws > spec-drift: {N} specs may be stale
  - specs/Arx_4-1-1-3 references Trade.tsx (changed in abc1234, 2 days ago)
  - specs/Arx_4-2 references design tokens (changed in def5678, 1 day ago)
  Run: /think spec "update Arx_4-1-1-3" to fix
```

## Resolution
A stale spec is resolved when:
- The spec file itself is modified in a subsequent commit
- User manually marks it resolved via `/gos claw resolve spec-drift {spec_path}`

## Token Budget
Max 3,000 tokens per run. Only reads file names and greps — no deep analysis.
