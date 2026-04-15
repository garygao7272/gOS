# gOS Plugin — Sync Rules

**Source of truth:** `gOS/commands/`
**This directory:** Plugin source copy, synced from `commands/`

## Sync procedure

After editing any file in `commands/`, sync to all active locations:

```bash
for f in commands/*.md; do
  cp "$f" ".claude/commands/$(basename $f)"
  cp "$f" "gos-plugin/command-source/$(basename $f)"
done
```

**Why `command-source/` not `commands/`?** Claude Code auto-discovers `commands/` directories and registers them as skills. Having both `.claude/commands/` and `gos-plugin/commands/` caused every command to appear TWICE in the skill list, wasting ~1-2K tokens per session. Renaming to `command-source/` prevents auto-discovery while preserving the files for plugin builds.

Or use `install.sh --global` which handles this automatically.

## Do NOT edit files here directly

Edit in `commands/` → sync here. Direct edits here will be overwritten on next sync.

## Frozen locations (not synced)

- `gos-plugin-build/commands/` — historical snapshot, FROZEN
