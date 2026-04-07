# God System Bootstrap Kit

> Everything needed to restore the God/Writ system from scratch — new laptop or new project.

## What This Kit Contains

```
bootstrap/
├── README.md                ← YOU ARE HERE
├── backup.sh                ← Archive everything to a tarball
├── restore.sh               ← Restore on a fresh machine
├── new-project.sh           ← Bootstrap God for any new project
├── sync.sh                  ← Sync current state back to templates
├── env.example              ← Required environment variables
└── templates/               ← Universal templates
    ├── GOD.md               ← Soul file (project-agnostic)
    ├── CLAUDE.template.md   ← Project instructions template
    ├── .mcp.template.json   ← MCP config template
    ├── .gitignore.template  ← Standard gitignore
    ├── commands/            ← All 10 Writ commands (universal versions)
    │   ├── god.md
    │   ├── think.md         ← Includes Stitch Phase 0/0.5/4 design pipeline
    │   ├── build.md
    │   ├── judge.md         ← Includes design-variant persona
    │   ├── intel.md
    │   ├── schedule.md
    │   ├── coordinate.md
    │   ├── evolve.md
    │   ├── prototype.md
    │   └── verify-app.md
    ├── skills/              ← Design and build skills
    │   ├── stitch-design/   ← Stitch MCP wrapper with Arx token injection
    │   ├── design-sync/     ← Bidirectional design system sync
    │   └── arx-ui-stack/    ← UI tech stack reference card
    ├── memory/              ← Memory system templates
    │   ├── MEMORY.md
    │   └── user_gary_gao.md
    └── rules/               ← Coding rules reference
        └── (symlink to ~/.claude/rules/)
```

## Scenario 1: Lost Laptop — Full Restore

```bash
# 1. Install Claude Code
npm install -g @anthropic-ai/claude-code

# 2. Clone your project repo (all bootstrap/ files are in git)
git clone <your-repo-url>
cd <project>

# 3. Run restore script
./bootstrap/restore.sh

# 4. Set environment variables
cp bootstrap/env.example ~/.env.local
# Edit ~/.env.local with your actual keys

# 5. Start a session
claude
# Then type: /god
```

### What restore.sh does:

1. Copies GOD.md to `~/.claude/GOD.md`
2. Copies rules to `~/.claude/rules/`
3. Installs plugins from settings.json
4. Sets up MCP servers
5. Creates Python venvs for spec-rag and notte
6. Installs npm dependencies for hyperliquid-mcp
7. Restores memory files
8. Verifies everything works

## Scenario 2: New Project — Bootstrap God

```bash
# From any directory where you want a new project
./bootstrap/new-project.sh my-new-project

# This creates:
# my-new-project/
# ├── .claude/
# │   ├── GOD.md
# │   ├── commands/     (all 10 Writ commands, universal)
# │   └── settings.local.json
# ├── CLAUDE.md          (template — fill in project details)
# ├── .mcp.json          (template — enable servers you need)
# ├── .gitignore
# ├── specs/
# │   └── INDEX.md
# └── sessions/
#     └── active.md
```

## Scenario 3: Regular Backups

```bash
# Create a backup tarball
./bootstrap/backup.sh

# Output: god-backup-2026-03-18.tar.gz
# Contains: GOD.md, commands, rules, memory, settings, plugins list
```

## What Lives Where (Architecture)

| Layer                | Location                           | Scope       | Backed Up?        |
| -------------------- | ---------------------------------- | ----------- | ----------------- |
| Soul                 | `~/.claude/GOD.md`                 | Universal   | Yes (backup.sh)   |
| Rules                | `~/.claude/rules/`                 | Universal   | Yes (backup.sh)   |
| Settings             | `~/.claude/settings.json`          | Universal   | Yes (backup.sh)   |
| Plugins              | `~/.claude/settings.json`          | Universal   | Yes (plugin list) |
| Commands             | `<project>/.claude/commands/`      | Per-project | Yes (in git)      |
| MCP Config           | `<project>/.mcp.json`              | Per-project | Yes (in git)      |
| Project Instructions | `<project>/CLAUDE.md`              | Per-project | Yes (in git)      |
| Memory               | `~/.claude/projects/.../memory/`   | Per-project | Yes (backup.sh)   |
| Specs                | `<project>/specs/`                 | Per-project | Yes (in git)      |
| Scratchpad           | `<project>/sessions/scratchpad.md` | Per-session | No (ephemeral)    |

## Environment Variables Required

See `env.example` for the full list. Key ones:

| Variable            | Purpose                | Where to Get               |
| ------------------- | ---------------------- | -------------------------- |
| `GITHUB_TOKEN`      | GitHub MCP             | github.com/settings/tokens |
| `DISCORD_TOKEN`     | Discord MCP            | discord.com/developers     |
| `TELEGRAM_API_ID`   | Telegram MCP           | my.telegram.org            |
| `TELEGRAM_API_HASH` | Telegram MCP           | my.telegram.org            |
| `NOTTE_API_KEY`     | Notte browser MCP      | notte.cc                   |
| `ANTHROPIC_API_KEY` | Claude API (if needed) | console.anthropic.com      |

## Updating the Bootstrap Kit

When you change a Writ command or GOD.md, update the templates:

```bash
# Sync current commands to templates
cp .claude/commands/*.md bootstrap/templates/commands/
cp .claude/GOD.md bootstrap/templates/GOD.md

# Commit the bootstrap update
git add bootstrap/
git commit -m "chore: sync bootstrap templates with current Writ"
```
