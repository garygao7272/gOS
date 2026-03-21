# gOS Plugin

gOS — Gary's AI operating system for Claude. 8 core commands, 12 agents, 13 skills, and safety hooks for structured AI-augmented development.

Works across **Code**, **Cowork**, and **Chat** modes.

## Commands

| Command | Purpose | Subcommands |
|---------|---------|-------------|
| `/gos:gos` | Session entry, safety controls | status, careful, freeze, save, resume, schedule, loop |
| `/gos:think` | Product + strategy | discover, research, decide, spec, intake |
| `/gos:design` | Visual + interaction design | quick, variants, flow, full, system, sync |
| `/gos:simulate` | Forward-looking intelligence | market, scenario, backtest, dux |
| `/gos:build` | Engineering | plan, prototype, feature, component, fix, tdd |
| `/gos:review` | Quality assurance | code, test, design, gate, prove, e2e, council |
| `/gos:ship` | Delivery pipeline | commit, pr, deploy, docs, release |
| `/gos:evolve` | Self-improvement | audit, upgrade, learn, reflect |
| `/gos:aside` | Side question utility | (none) |

In **Code mode**, flat commands (`/think`, `/build`, etc.) are available via symlinks.

## Installation

### Code Mode (CLI)

**Option A: Local plugin (development)**

```bash
# Clone the repo
git clone https://github.com/garygao33/gOS.git ~/gOS

# Run the install script
cd ~/gOS/gos-plugin
./scripts/sync.sh install
```

Then add to `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "gos-plugin": {
      "source": {
        "source": "directory",
        "path": "/path/to/gOS/gos-plugin"
      }
    }
  },
  "enabledPlugins": {
    "gos@gos-plugin": true
  }
}
```

**Option B: Symlinks only (flat commands in Code)**

```bash
cd ~/gOS/gos-plugin
./scripts/sync.sh link
```

This creates symlinks from `~/.claude/commands/` to the plugin's command files, giving you flat `/think`, `/build`, etc.

### Cowork + Chat Modes

Same plugin installation as Code. Commands appear as `/gos:think`, `/gos:build`, etc. in the slash command menu.

## Agents

12 specialized agents: planner, architect, tdd-guide, code-reviewer, security-reviewer, build-error-resolver, e2e-runner, doc-updater, refactor-cleaner, python-reviewer, harness-optimizer, loop-operator.

## Skills

13 domain skills auto-invoked by context: intake, design-sync, stitch-design, arx-ui-stack, strategic-compact, verification-loop, tdd-workflow, coding-standards, backend-patterns, frontend-patterns, frontend-slides, python-patterns, python-testing.

Plus `gos-rules` — compiled development rules (coding style, testing, security, git workflow) with language-specific overrides.

## Safety Hooks

Two PreToolUse hooks (Code mode only):

- **gOS careful** — Blocks destructive commands (rm -rf, force-push, DROP TABLE, etc.) and prompts for confirmation
- **gOS freeze** — Blocks edits outside a frozen scope directory (when `~/.claude/freeze-scope.txt` exists)

In Cowork/Chat modes, safety checks are embedded as command-level instructions.

## MCP Server Dependencies

Optional. Commands degrade gracefully without these:

| Server | Used by | Purpose |
|--------|---------|---------|
| Hyperliquid | `/gos:simulate market` | Crypto market data |
| Exa | `/gos:think research` | Neural web search |
| Firecrawl | `/gos:think intake` | Web content extraction |
| Context7 | `/gos:build` | Library docs |
| Vercel | `/gos:ship deploy` | Web deployment |
| Figma | `/gos:design sync` | Design system sync |

See `mcp-configs/reference-servers.json` for configuration templates.

## Sync Workflow

```bash
# Export from live ~/.claude/ to plugin (after making changes in Code)
./scripts/sync.sh export

# Install plugin + create symlinks
./scripts/sync.sh install

# Just create/refresh symlinks for flat commands
./scripts/sync.sh link
```

## What Stays Outside the Plugin

Memory files, settings, MCP credentials, scheduled tasks, and learned patterns are user-specific and remain in `~/.claude/`. The plugin provides logic; your environment provides state.
