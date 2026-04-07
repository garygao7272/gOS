# gOS — Gary's Operating System for Claude Code

> A prompt compiler that turns one human into a software team.
> 9 verbs, 20 agents, 15 skills, multi-agent framework, self-evolution loop.

## What Is gOS

gOS is a constraint system that makes agentic AI reliable for product building. It takes a vague human intent and compiles it into a precise multi-step execution plan with the right context loaded, the right agents assigned, and the right quality gates in place.

```
Intent → Route → Constrain → Execute → Remember
```

The 8 verbs are compilation targets. Think compiles intent into knowledge. Design compiles knowledge into specifications. Build compiles specifications into code. Review compiles code into verdicts.

## Quick Start (New Machine)

### Prerequisites

- macOS (tested on Apple Silicon)
- [Homebrew](https://brew.sh) installed
- [Claude Code](https://claude.ai/code) installed and authenticated

### Install

```bash
# Clone gOS
git clone https://github.com/garygao7272/gOS.git ~/Documents/Claude\ Working\ Folder/gOS

# Bootstrap into your project (installs all tools + wires gOS)
cd ~/Documents/Claude\ Working\ Folder/gOS
./install.sh --bootstrap ~/Documents/Claude\ Working\ Folder/Arx
```

The bootstrap script installs everything automated, then prints a guided checklist for the manual steps. Follow all 5 steps below.

---

## Setup Guide (5 Steps After Bootstrap)

### Step 1: Connect Claude Code Plugins

Open Claude Code in your terminal and connect MCP servers + plugins via OAuth:

```bash
cd ~/Documents/Claude\ Working\ Folder/Arx
claude

# Inside Claude Code:
/mcp
# Connect each: Figma, Vercel, Linear, Shadcn UI, Gmail
# For each one, a browser tab opens for OAuth — approve and return

# Chrome extension (for frontend debugging):
# Install "Claude in Chrome" from Chrome Web Store
```

**Plugins to enable** (run `/plugins` inside Claude Code):

| Category | Plugins |
|----------|---------|
| **Core** | firecrawl, commit-commands, superpowers, feature-dev, ralph-loop |
| **Design** | figma, frontend-design, ui-ux-pro-max, mobile-design-engine |
| **Dev tools** | context7, firebase, skill-creator, claude-md-management |
| **Finance** | investment-banking, financial-analysis, equity-research, private-equity, wealth-management |
| **Meta** | everything-claude-code, claude-mem |

### Step 2: Set API Keys

Add to `~/.zshrc` (or `~/.bashrc`):

```bash
# Required
export GITHUB_TOKEN="ghp_your_token_here"

# Optional — enable as you need them
export DISCORD_TOKEN="your_discord_bot_token"          # Community monitoring
export TELEGRAM_API_ID="your_telegram_id"              # Community monitoring
export TELEGRAM_API_HASH="your_telegram_hash"           # Community monitoring
export NOTTE_API_KEY="your_notte_key"                  # Anti-detection scraping
export STITCH_API_KEY="your_stitch_key"                # Stitch design MCP
export SUPADATA_API_KEY="your_supadata_key"            # YouTube transcript API
```

Then reload: `source ~/.zshrc`

### Step 3: Copy Project Content

These are project-specific — not stored in gOS repo:

```bash
# Specs (96 files) — copy from backup, Dropbox, or previous machine
cp -R /path/to/backup/specs/ ~/Documents/Claude\ Working\ Folder/Arx/specs/

# Web prototype — if you have one
# (or start fresh — /build prototype creates it)

# Mobile app — clone your app repo
git clone <mobile-repo> ~/Documents/Claude\ Working\ Folder/Arx/apps/mobile

# Regenerate design system
cd ~/Documents/Claude\ Working\ Folder/Arx && claude
/design system sync
```

### Step 4: Clone Sister Projects

These are separate repos used by gOS verbs:

```bash
# Dux — MCTS simulation engine (used by /simulate scenario)
git clone https://github.com/garygao7272/Dux.git ~/Documents/Claude\ Working\ Folder/Dux

# MiroFish — market backtesting engine (used by /simulate market)
git clone https://github.com/garygao7272/MiroFish.git ~/Documents/Claude\ Working\ Folder/MiroFish
```

### Step 5: Verify

```bash
cd ~/Documents/Claude\ Working\ Folder/Arx
claude
/gos                    # Should show: "Gary. Here's where we are..."
/gos status             # Should show all green
/gos pulse              # One-line health check
```

If `/gos` reports issues:
```bash
cd ~/Documents/Claude\ Working\ Folder/gOS
./install.sh            # Health check — shows what's missing
```

---

## Install.sh Modes

| Mode | Command | What It Does |
|------|---------|-------------|
| **Check** | `./install.sh` | Health check only — scans everything, changes nothing |
| **Install** | `./install.sh --install` | Installs tools (OfficeCLI, LibreOffice, venvs) — no project wiring |
| **Bootstrap** | `./install.sh --bootstrap <dir>` | Full replication — installs tools + wires gOS into target project |

## Keeping gOS in Sync

After making changes in your live project:

```bash
cd ~/Documents/Claude\ Working\ Folder/gOS
./sync-from-live.sh                    # Copies Arx → gOS repo
git add -A && git commit -m "sync"     # Commit
git push                                # Push to GitHub
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
├── Arx/                    ← Project (specs, prototype, mobile app)
├── Dux/                    ← Simulation engine (/simulate scenario)
├── MiroFish/               ← Backtesting engine (/simulate market)
└── toolkit/                ← Shared tools (created by install.sh)
    ├── officecli            ← Excel formula engine
    ├── hyperliquid-mcp/     ← Market data
    ├── spec-rag-mcp/        ← Semantic spec search
    ├── sources-mcp/         ← Twitter/YouTube/blog intel
    ├── spec-rag-env/        ← Python venv
    ├── sources-env/         ← Python venv
    └── notte-env/           ← Python venv
```

## The 9 Verbs

| Verb | Question | Output |
|------|----------|--------|
| `/gos` | Am I set up? | Session state, orchestration |
| `/think` | What and why? | Research, specs |
| `/design` | How does it look? | Build cards, visuals |
| `/build` | How is it coded? | Working software |
| `/review` | Is it good? | Verdicts, fixes |
| `/simulate` | What could happen? | Scenarios, backtests, flow sims |
| `/ship` | Is it out? | Commits, PRs, deploys |
| `/evolve` | Are we improving? | Self-upgrades |
| `/refine` | Is it tight enough? | Convergence loop |

## What Does NOT Sync

| Item | Why | Where It Lives |
|------|-----|---------------|
| **specs/** (96 files) | Project-specific content | Arx repo or backup |
| **apps/** (prototype, mobile) | Application code | Separate git repos |
| **API secrets** | Security | `~/.zshrc` env vars |
| **CC plugins** | OAuth per machine | Claude Code config |
| **Session transcripts** | Local per machine | `~/.claude/` |
| **Scheduled tasks** | Session-scoped | Claude Code runtime |
