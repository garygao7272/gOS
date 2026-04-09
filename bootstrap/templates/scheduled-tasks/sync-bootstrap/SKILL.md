---
name: sync-bootstrap
description: Sync God system files to bootstrap/templates/ every 3 days
---

Run the bootstrap sync script to keep templates up to date with the current state of the God/Writ system.

## What to do

1. Run the sync script:
```bash
cd "/Users/garyg/Documents/Claude Working Folder/Arx" && ./bootstrap/sync.sh
```

2. If any files were updated (script reports "Changes: N files updated" where N > 0):
   - Stage and commit the changes:
   ```bash
   cd "/Users/garyg/Documents/Claude Working Folder/Arx"
   git add bootstrap/
   git commit -m "chore: sync bootstrap templates (auto)"
   ```

3. If zero changes, do nothing — templates are already current.

## What this syncs
- GOD.md (soul file)
- 9 Writ commands
- .mcp.json config
- CLAUDE.md reference copy
- Memory files (user profile, project stack)
- settings.json (plugins)
- Rules (common coding standards)
- Agent definitions (12 agents)
- Scheduled task definitions (5 tasks)
- User-level commands (30 commands)
- .gitignore
- SYSTEM_MANIFEST.md timestamp