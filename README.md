# gOS — Gary's Operating System for Claude Code

> A prompt compiler that turns one human into a software team.
> 9 verbs, 20 agents, 15 skills, multi-agent framework, self-evolution loop.

---

## Setup: Fresh Mac → Working gOS

Copy-paste each block into your terminal. Total time: ~10 minutes.

### 0. Prerequisites

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Claude Code (if not installed)
npm install -g @anthropic-ai/claude-code

# Login to Claude Code
claude login

# Login to GitHub CLI
brew install gh
gh auth login
```

### 1. Clone gOS + Bootstrap

```bash
# Clone gOS repo
gh repo clone garygao7272/gOS ~/Documents/Claude\ Working\ Folder/gOS

# Run bootstrap — installs all tools, wires gOS into your project
cd ~/Documents/Claude\ Working\ Folder/gOS
chmod +x install.sh
./install.sh --bootstrap ~/Documents/Claude\ Working\ Folder/Arx
```

**What this does automatically (~2 min):**
- Installs Node.js, OfficeCLI, LibreOffice (via brew)
- Clones Dux (simulation engine) and MiroFish (backtesting engine)
- Creates `toolkit/` with all MCP servers + Python venvs
- Copies 9 commands, 20 agents, 15 skills → your project's `.claude/`
- Generates `.mcp.json` with correct absolute paths
- Copies all memory files (including your soul file)
- Creates all project directories

### 2. Set API Keys

```bash
# Open your shell config
nano ~/.zshrc

# Paste these lines at the bottom:

# === gOS API Keys ===
# Required
export GITHUB_TOKEN="ghp_your_token_here"

# Optional — uncomment and fill as needed
# export DISCORD_TOKEN="your_discord_bot_token"
# export TELEGRAM_API_ID="your_telegram_id"
# export TELEGRAM_API_HASH="your_telegram_hash"
# export NOTTE_API_KEY="your_notte_key"
# export STITCH_API_KEY="your_stitch_key"
# export SUPADATA_API_KEY="your_supadata_key"

# Save (Ctrl+O, Enter, Ctrl+X) then reload:
source ~/.zshrc
```

### 3. Connect Claude Code Plugins

```bash
# Open Claude Code in your project
cd ~/Documents/Claude\ Working\ Folder/Arx
claude
```

Then inside Claude Code, run these commands one at a time:

```
/mcp
```

Connect each MCP server that needs OAuth (browser opens for each):
- **Figma** — for design system sync
- **Vercel** — for deployments
- **Linear** — for issue tracking
- **Gmail** — for email

Then install plugins:

```
/plugin install firecrawl
/plugin install commit-commands
/plugin install superpowers
/plugin install feature-dev
/plugin install ralph-loop
/plugin install figma
/plugin install frontend-design
/plugin install context7
/plugin install firebase
/plugin install skill-creator
/plugin install claude-md-management
/plugin install everything-claude-code
/plugin install claude-mem
```

**Optional plugins** (install if you use these domains):

```
# Finance
/plugin install investment-banking
/plugin install financial-analysis
/plugin install equity-research
/plugin install private-equity
/plugin install wealth-management

# Design
/plugin install ui-ux-pro-max
/plugin install mobile-design-engine

# Chrome debugging
# → Install "Claude in Chrome" extension from Chrome Web Store
```

### 4. Copy Your Project Content

```bash
# Exit Claude Code first (Ctrl+C or /exit)

# Copy specs from backup (96 files)
cp -R /path/to/backup/specs/ ~/Documents/Claude\ Working\ Folder/Arx/specs/

# If you have a web prototype backup
cp -R /path/to/backup/apps/web-prototype/ ~/Documents/Claude\ Working\ Folder/Arx/apps/web-prototype/

# If you have a mobile app repo
git clone <your-mobile-repo-url> ~/Documents/Claude\ Working\ Folder/Arx/apps/mobile

# If you have financial models
cp /path/to/backup/*.xlsx ~/Documents/Claude\ Working\ Folder/Arx/
```

Then regenerate the design system:

```bash
cd ~/Documents/Claude\ Working\ Folder/Arx
claude
```

Inside Claude Code:

```
/design system sync
```

### 5. Verify Everything Works

Inside Claude Code (should still be open from step 4):

```
/gos
```

**Expected output:** "Gary. Here's where we are..." followed by a session briefing.

Then check health:

```
/gos status
```

**Expected:** All commands listed, session state shown.

One-line health check:

```
/gos pulse
```

**Expected:** Branch name, uncommitted file count, last commit message.

### Troubleshooting

If something isn't working:

```bash
# Exit Claude Code, go to gOS repo, run health check
cd ~/Documents/Claude\ Working\ Folder/gOS
./install.sh
```

This prints a checklist of everything with ✓ or ✗. Fix what's red.

Common issues:
- **MCP servers not connecting:** Check `~/.zshrc` has the API keys, then `source ~/.zshrc` and restart Claude Code
- **OfficeCLI not found:** Run `./install.sh --install` to re-download
- **Dux/MiroFish not cloned:** Check if repos are private — clone manually with `gh repo clone garygao7272/Dux`
- **Plugins not loading:** Run `/reload-plugins` inside Claude Code

---

## Day-to-Day Usage

### Start a Session

```
/gos                    # Full briefing + "what do you need?"
/gos <goal>             # Autonomous: decomposes and executes
```

### The 9 Verbs

| Command | What It Does | Example |
|---------|-------------|---------|
| `/think research <question>` | Deep research with parallel agents | `/think research "copy trading UX patterns"` |
| `/think discover <idea>` | Validate a product concept | `/think discover "AI risk copilot"` |
| `/think decide <question>` | Multi-perspective decision analysis | `/think decide "should we show full P&L?"` |
| `/design card <screen>` | Author a build card spec | `/design card copy-setup` |
| `/design ui <screen>` | Generate visual design via Figma/AI | `/design ui home-screen` |
| `/build prototype` | Single-file HTML prototype | `/build prototype` |
| `/build feature <spec>` | Full TDD feature implementation | `/build feature Arx_4-1-1-4_D3` |
| `/review code` | 2-pass code review with fix-first | `/review code` |
| `/review council` | 12-persona multi-agent review | `/review council` |
| `/simulate market` | MiroFish market simulation | `/simulate market` |
| `/simulate flow <JTBD>` | User journey friction analysis | `/simulate flow "S7 copies a trader"` |
| `/ship commit` | Git commit (conventional format) | `/ship commit` |
| `/ship` | Full pipeline: commit → PR → deploy | `/ship` |
| `/evolve audit` | Self-health check + improvement proposals | `/evolve audit` |
| `/refine <goal>` | Loop think→design→review until converged | `/refine "copy trading screen"` |

### Keyboard Shortcuts

| Key | What |
|-----|------|
| `Shift+Tab` | Toggle plan mode |
| `Option+T` | Toggle extended thinking |
| `/btw <q>` | Side question without losing context |
| `/compact` | Manual context compaction (do at ~50%) |
| `/branch` | Fork current session |
| `/rewind` | Undo to a previous point |

### Keep gOS Updated

After making changes in your live project:

```bash
cd ~/Documents/Claude\ Working\ Folder/gOS
./sync-from-live.sh
git add -A && git commit -m "sync from live"
git push
```

On another machine:

```bash
cd ~/Documents/Claude\ Working\ Folder/gOS
git pull
./install.sh --bootstrap ~/Documents/Claude\ Working\ Folder/Arx
```

---

## Architecture

```
~/Documents/Claude Working Folder/
├── gOS/                    ← This repo (the operating system)
│   ├── commands/           ← 9 verb files
│   ├── agents/             ← 20 agent definitions
│   ├── skills/             ← 15 skill directories
│   ├── toolkit/            ← MCP server source code
│   ├── memory/             ← Persistent cross-session memory
│   ├── settings/           ← Settings + templates
│   ├── rules/              ← Coding standards
│   ├── install.sh          ← Bootstrap script
│   └── sync-from-live.sh   ← Sync script
│
├── Arx/                    ← Your project
│   ├── .claude/            ← gOS wired here by bootstrap
│   ├── specs/              ← 96 product specs
│   ├── apps/               ← Prototype + mobile app
│   ├── outputs/            ← Think/simulate outputs
│   └── memory/             ← Project memory
│
├── Dux/                    ← Simulation engine (auto-cloned)
├── MiroFish/               ← Backtesting engine (auto-cloned)
│
└── toolkit/                ← Shared tools (created by install.sh)
    ├── officecli            ← Excel formula engine
    ├── hyperliquid-mcp/     ← Market data MCP
    ├── spec-rag-mcp/        ← Semantic spec search MCP
    ├── sources-mcp/         ← Twitter/YouTube/blog MCP
    ├── spec-rag-env/        ← Python venv
    ├── sources-env/         ← Python venv
    └── notte-env/           ← Python venv
```

## What Does NOT Sync (and why)

| Item | Why | What To Do |
|------|-----|-----------|
| **specs/** (96 files) | Project content, not gOS config | Copy from backup |
| **apps/** | Application code | Clone from git |
| **API secrets** | Security | Set in `~/.zshrc` |
| **CC plugins** | OAuth is per-machine | Run `/mcp` + `/plugin install` |
| **Session history** | Local to each machine | Starts fresh |
| **Scheduled tasks** | Session-scoped in CC | Re-create with `/gos schedule` |
| **Financial models (.xlsx)** | Project data | Copy from backup |
