# First-Principles Reproducibility Analysis

**Agent:** first-principles (ac835b495fddea27c)
**Question:** Decompose "fresh Mac → functional gOS" into atomic primitives. Classify state. Define minimum viable install.sh flow.

---

## Atomic Primitives (24 total)

| # | Primitive | In gOS repo? | install.sh handles? | Host-provided? | Gap? |
|---|-----------|--------------|---------------------|-----------------|------|
| 1 | Claude Code CLI | N/A | checks | yes | — |
| 2 | Python3 | N/A | checks | yes | — |
| 3 | Git | N/A | checks | yes | — |
| 4 | Node.js 18+ | yes (checks) | installs (brew) | no | — |
| 5 | GitHub CLI (gh) | yes (checks) | installs (brew) | no | — |
| 6 | Homebrew | N/A | checks | yes | — |
| 7 | ~/.claude/commands/*.md (9 files) | yes: commands/ | copies | no | — |
| 8 | ~/.claude/agents/*.md (20+ files) | yes: agents/ | copies | no | — |
| 9 | ~/.claude/skills/* (16 dirs) | yes: skills/ | copies | no | — |
| 10 | ~/.claude/rules/* (45 files) | yes: rules/ | copies | no | — |
| 11 | ~/.claude/CLAUDE.md (global) | yes: templates/global-CLAUDE.md | copies | no | — |
| 12 | ~/.claude/settings.json | yes: settings/settings.json | merges | no | — |
| 13 | ~/.claude/hooks/*.sh (30 scripts) | yes: .claude/hooks/ | copies + chmod +x | no | — |
| 14 | Toolkit dir + structure | yes: toolkit/ | copies recursively | no | — |
| 15 | OfficeCLI binary | no | downloads from GitHub | no | — |
| 16 | LibreOffice | no | installs (brew cask) | no | — |
| 17 | Dux (simulation engine) | no | clones via gh | no | — |
| 18 | MiroFish (backtesting) | no | clones via gh | no | — |
| 19 | MCP server source code (3 types) | yes: toolkit/ | copies | no | — |
| 20 | Python venvs (spec-rag, sources, notte) | no | creates venv + pip install | no | — |
| 21 | Project CLAUDE.md | yes: project-template/CLAUDE.md | copies template | no | — |
| 22 | .mcp.json (path resolution) | yes: toolkit/mcp-template.json | copies + sed substitution | no | — |
| 23 | Project .claude/settings.json | no | generates inline | no | — |
| 24 | Session/output directories | no | mkdir -p | no | — |

---

## Critical Gaps (6)

1. **Templates directory incomplete** — `install.sh` references `$GOS_DIR/templates/global-CLAUDE.md` (line 197) but missing project template content. **Impact:** Global install fails at CLAUDE.md copy step.

2. **MCP Server npm dependencies** — install.sh creates venvs for Python MCPs but NEVER runs `npm install` on TypeScript MCP servers (hyperliquid-mcp, spec-rag-mcp, sources-mcp). **Impact:** MCPs present but non-functional (no node_modules). **← BIGGEST REPRODUCIBILITY RISK.**

3. **Secret environment variables** — install.sh never prompts for or documents where to set GITHUB_TOKEN, DISCORD_TOKEN, etc. **Impact:** MCP servers fail at runtime when auth is required.

4. **Python venv requirements.txt sourcing logic fragile** (lines 175–179) — looks in `$TOOLKIT/$mcp_name/requirements.txt` first, then `$GOS_DIR/toolkit/$mcp_name/requirements.txt`. If neither exists, pip install silently succeeds with no packages. **Impact:** Venvs created but empty; Python MCPs fail at import.

5. **Hooks PATH not verified** — `settings.json` references `$HOME/.claude/hooks/*.sh` but install.sh never validates they exist after copy, nor verifies execute bit. **Impact:** Hooks fail silently at runtime.

6. **No bootstrap prerequisite check** — `--bootstrap` mode (line 312) checks for global install and auto-runs `--global` if missing, but `--global` can fail (e.g., if Python merge fails). No retry or explicit verification. **Impact:** Bootstrap may proceed with incomplete global state.

---

## State Classification

**Portable** (ship in repo, install.sh copies verbatim):
- commands/*.md (9 files), agents/*.md (20+), skills/* (16 dirs), rules/* (45 files)
- templates/global-CLAUDE.md, templates/workspace-CLAUDE.md
- project-template/CLAUDE.md, project-template/gOS.md
- toolkit/mcp-template.json, toolkit/stitch-proxy.mjs, toolkit MCP source
- .claude/hooks/*.sh (30), .claude/CLAUDE.md, settings/settings.json

**Machine-local** (generated on first run, never in repo):
- ~/.claude/* (populated by --global install)
- toolkit/*-env/ (Python venvs), toolkit/*/node_modules/ (npm install)
- toolkit/officecli, Dux/, MiroFish/, project .claude/

**Secrets** (NEVER in repo, must be set by user):
- GITHUB_TOKEN, DISCORD_TOKEN, TELEGRAM_API_*, NOTTE_API_KEY, STITCH_API_KEY, SUPADATA_API_KEY
- Claude Code OAuth tokens (Figma, Vercel, Linear, Gmail)

**User-specific** (install-time prompt):
- Project directory path, project name, project slug, username

---

## Minimum Viable install.sh Flow (Ordered)

1. **Check host runtimes exist** (Python3, Git, Homebrew, Claude Code). Fail if missing.
2. **Install or check Node.js, gh CLI** (via brew if missing). Fail if unavailable after install.
3. **Create ~/toolkit/** directory.
4. **Download OfficeCLI binary** (arch-aware, chmod +x). Warn if fails.
5. **Check/install LibreOffice** (optional, warn if missing).
6. **Clone Dux + MiroFish** (if not present, via gh). Warn if fails.
7. **Copy toolkit MCPs** from gOS repo to ~/toolkit/.
8. **For each MCP with node_modules requirement:** `npm install --silent`.
9. **Create Python venvs** for spec-rag, sources, notte. **FAIL if requirements.txt missing**.
10. **--global mode:** create ~/.claude/*, copy files, chmod +x hooks, validate template, merge settings.json, verify file counts match.
11. **--bootstrap mode:** recursive --global if missing, prompt for project dir, copy project-template/CLAUDE.md, generate .mcp.json with sed, create project .claude/settings.json, mkdir all project dirs, create session state.
12. **Print summary** with next steps for each mode.

---

## Biggest Reproducibility Risk

**NPM dependencies for TypeScript MCPs are never installed by install.sh, leaving the toolkit MCPs present but non-functional.** No error is raised during install; failure surfaces only when Claude Code tries to connect and the MCP process fails to start.
