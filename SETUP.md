# gOS Setup Guide

> Gary's Operating System for Claude Code.
> 10 verbs, 41+ sub-commands, 12 agents, 13 skills, 45 rules.

## Prerequisites

- macOS (tested on Apple Silicon)
- [Claude Code](https://claude.ai/code) installed and authenticated
- [Homebrew](https://brew.sh) installed
- Node.js 18+ (for npx)
- Python 3.11+

## Quick Install

```bash
git clone git@github.com:YOUR_USERNAME/gOS.git ~/gOS
cd ~/gOS
./setup.sh
```

Then follow the manual steps below.

## Manual Steps (run once after setup.sh)

### 1. Install External Dependencies

```bash
# Audio/video tools (for /think intake — YouTube transcript extraction)
brew install yt-dlp ffmpeg

# Python packages
pip3 install --user --break-system-packages youtube-transcript-api openai-whisper
```

### 2. Authenticate Firecrawl

```bash
npx firecrawl-cli login --browser
```

This opens your browser. Sign in, then return to terminal.

### 3. Authenticate GitHub CLI

```bash
gh auth login
```

### 4. Fix settings.json Plugin Path

Open `~/.claude/settings.json` and replace:
```
/Users/REPLACE_WITH_YOUR_USERNAME/claude-plugins
```
with your actual path:
```
/Users/YOUR_MAC_USERNAME/claude-plugins
```

Or if you don't have a local plugins directory, remove that entry from `extraKnownMarketplaces.local-plugins`.

### 5. Enable Plugins

Open Claude Code and run `/plugins`. Enable the following plugins (they'll download automatically):

**Official plugins:**
- firecrawl, commit-commands, superpowers, frontend-design, feature-dev
- ralph-loop, linear, claude-md-management, context7, figma, vercel
- skill-creator, firebase
- typescript-lsp, pyright-lsp, swift-lsp, kotlin-lsp

**Third-party plugins (require marketplace setup):**
- everything-claude-code (GitHub: affaan-m/everything-claude-code)
- ui-ux-pro-max (GitHub: nextlevelbuilder/ui-ux-pro-max-skill)
- claude-mem (GitHub: thedotmack/claude-mem)
- mobile-design-engine (local plugins dir)

**Financial services plugins (GitHub: anthropics/financial-services-plugins):**
- investment-banking, financial-analysis, equity-research, private-equity, wealth-management

### 6. (Optional) Set Up Project-Level Commands

gOS commands are global. But some commands (like `/design`, `/simulate`) reference project-specific paths. To set up for a specific project:

```bash
cd ~/Documents/your-project
mkdir -p .claude/commands

# Create project-level gOS.md soul file
cp ~/gOS/project-template/gOS.md .claude/gOS.md

# Create project CLAUDE.md (customize for your project)
cp ~/gOS/project-template/CLAUDE.md ./CLAUDE.md
```

### 7. (Optional) Import Memory

Memory is project-scoped. To import for a project:

```bash
# Find your project's memory path
# It's based on the absolute path to your project, sanitized
PROJECT_PATH=$(pwd | sed 's|/|-|g' | sed 's|^-||')
MEMORY_DIR="$HOME/.claude/projects/$PROJECT_PATH/memory"
mkdir -p "$MEMORY_DIR"

# Copy memory files
cp ~/gOS/memory/*.md "$MEMORY_DIR/"
```

## What's in the Box

### Commands (12 files in ~/.claude/commands/)

| Command | Type | Description |
|---------|------|-------------|
| `/gos` | Core | Session entry, safety, save/resume, schedule, loop, claw, context, state, tools |
| `/think` | Core | discover, research, decide, spec, intake |
| `/design` | Core | quick, variants, flow, full, system, sync |
| `/simulate` | Core | market, scenario, backtest, dux |
| `/build` | Core | plan, prototype, feature, component, fix, tdd, refactor |
| `/review` | Core | code, test, design, gate, prove, e2e, coverage, council, dashboard |
| `/ship` | Core | commit, pr, deploy, docs, release |
| `/evolve` | Core | audit, upgrade, learn, reflect |
| `/eval` | Core | Measure command quality against rubrics with synthetic inputs |
| `/dispatch` | Core | Multi-session orchestration: spawn workers, monitor, synthesize |
| `/aside` | Utility | Side question without losing context |
| `/checkpoint` | Utility | Git checkpoint |

### Skills (13 directories in ~/.claude/skills/)

| Skill | Purpose |
|-------|---------|
| intake | YouTube/podcast/article absorption, topic scanning, source management |
| arx-ui-stack | Arx-specific UI patterns |
| design-sync | Bidirectional design system sync |
| stitch-design | Stitch MCP wrapper |
| strategic-compact | Context compaction strategy |
| verification-loop | Build/test/lint verification |
| tdd-workflow | TDD enforcement |
| coding-standards | Universal coding standards |
| backend-patterns | Backend architecture patterns |
| frontend-patterns | Frontend patterns |
| frontend-slides | HTML presentation builder |
| python-patterns | Python best practices |
| python-testing | pytest/TDD patterns |

### Agents (12 files in ~/.claude/agents/)

architect, build-error-resolver, code-reviewer, doc-updater, e2e-runner, harness-optimizer, loop-operator, planner, python-reviewer, refactor-cleaner, security-reviewer, tdd-guide

### Claws (3 persistent background monitors in ~/.claude/claws/)

| Claw | Purpose |
|------|---------|
| source-monitor | Watches data sources for changes and alerts |
| spec-drift | Detects when implementation drifts from spec |
| market-regime | Monitors market regime shifts for trading systems |

Claws are persistent background processes managed via `/gos claw`. Each claw has a `claw.md` (definition) and `state.json` (runtime state). Use `/gos claw list` to see active claws, `/gos claw arm <name>` to activate, and `/gos claw disarm <name>` to deactivate.

### Rules (45 files in ~/.claude/rules/)

Organized by: common/ (9 universal rules), typescript/, python/, golang/, swift/, kotlin/, perl/, php/

### Settings

| File | What it does |
|------|-------------|
| `settings.json` | Plugins, marketplaces, hooks (careful + freeze), agent teams |
| `settings.local.json` | Permissions (python3, firecrawl, yt-dlp, etc.) |

### Safety Hooks (pre-configured)

| Hook | Trigger | Action |
|------|---------|--------|
| gOS careful | Bash commands matching destructive patterns | Warns before rm -rf, DROP TABLE, force-push, etc. |
| gOS freeze | Edit/Write when freeze-scope.txt exists | Blocks edits outside specified directory |

## Updating gOS

To update from the repo:

```bash
cd ~/gOS
git pull
./setup.sh
```

The setup script backs up existing settings before overwriting.

## Syncing Between Machines

### Push (from primary machine)
```bash
cd ~/gOS
# Re-export current state
~/.claude/commands/  →  gOS/commands/
~/.claude/skills/    →  gOS/skills/
~/.claude/agents/    →  gOS/agents/
~/.claude/rules/     →  gOS/rules/
~/.claude/config/    →  gOS/config/
~/.claude/settings.json  →  gOS/settings/

git add -A && git commit -m "sync gOS state" && git push
```

### Pull (on secondary machine)
```bash
cd ~/gOS && git pull && ./setup.sh
```

### What Does NOT Sync
- Project files (Arx/, Dux/, etc.) — these are separate repos
- MCP server configs (.mcp.json) — project-specific
- Scheduled tasks — session-scoped, not persistent
- Session transcripts — local to each machine
- Plugin cache — auto-downloaded on first use
