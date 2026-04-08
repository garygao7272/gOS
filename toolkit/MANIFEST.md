# gOS Toolbox Manifest

> Complete dependency map for replicating a gOS environment from scratch.
> Run `./install.sh` to bootstrap, or use this as a checklist for manual setup.
> Health check: `./install.sh --check`

---

## 1. Core Runtime

| Tool | Version | Install | Health Check | Required |
|------|---------|---------|-------------|----------|
| **Claude Code** | latest | `npm install -g @anthropic-ai/claude-code` | `claude --version` | Yes |
| **Python 3.9+** | 3.9.6+ | System or `brew install python@3.12` | `python3 --version` | Yes |
| **Node.js 18+** | 18+ | `brew install node` or via nvm | `node --version` | Yes |
| **npm/npx** | 9+ | Comes with Node.js | `npx --version` | Yes |
| **git** | 2.x | System | `git --version` | Yes |
| **gh CLI** | 2.88+ | `brew install gh` | `gh --version` | Yes (GitHub ops) |

---

## 2. CLI Tools (gOS Core)

| Tool | Version | Path | Install | Health Check | Used By |
|------|---------|------|---------|-------------|---------|
| **OfficeCLI** | 1.0.37 | `toolkit/officecli` | Download from [GitHub releases](https://github.com/iOfficeAI/OfficeCLI/releases) | `~/bin/officecli --version` | Financial modeling skill |
| **LibreOffice** | 26.2+ | `soffice` (via brew) | `brew install --cask libreoffice` | `soffice --version` | Formula recalculation (precision verify) |
| **Vercel CLI** | latest | Via npx | `npm install -g vercel` (optional) | `npx vercel --version` | `/ship deploy`, prototype deploy |

### Project-Specific Engines

| Tool | Type | Path/Repo | Install | Used By |
|------|------|-----------|---------|---------|
| **MiroFish** | Python module | `~/Documents/Claude Working Folder/MiroFish/` | Project-specific | `/simulate market` — backtesting + regime detection |
| **Dux** | Python app (separate repo) | `~/Documents/Claude Working Folder/Dux/` | Clone from Dux repo | `/simulate scenario` — MCTS/beam search strategic simulation |
| **WPS Office** | macOS app (installed) | `/Applications/wpsoffice.app` | Pre-installed | Manual spreadsheet viewing (no CLI recalc) |
| **Claude Desktop** | macOS app | `/Applications/Claude.app` | Download from claude.ai | Session teleport, Chrome extension, `/remote-control` |

---

## 3. MCP Servers (`.mcp.json`)

### Remote (OAuth/HTTP — no local install)

| Server | Type | Purpose | Used By |
|--------|------|---------|---------|
| **Slack** | http | Team comms, feedback ingestion | `/think intake`, `/simulate` |
| **GitHub** | http | Code review, PR operations | `/ship`, `/review` |
| **Sentry** | http | Error tracking | `/build fix` |
| **AIDesigner** | http | UI generation (credit-based) | `/design ui` |

### Local (spawned processes — need dependencies)

| Server | Command | Dependencies | Install | Health Check | Used By |
|--------|---------|-------------|---------|-------------|---------|
| **Hyperliquid** | `node toolkit/hyperliquid-mcp/index.js` | Node.js | `cd toolkit/hyperliquid-mcp && npm install` | `node toolkit/hyperliquid-mcp/index.js --help` | `/simulate market`, live data |
| **Playwright** | `npx @playwright/mcp@latest` | Node.js, Chromium | `npx playwright install chromium` | `npx @playwright/mcp@latest --help` | `/review e2e`, UI testing |
| **Discord** | `npx -y mcp-discord` | Node.js | None (npx auto-installs) | N/A | Community monitoring |
| **Telegram** | `npx -y @overpod/mcp-telegram` | Node.js | None (npx auto-installs) | N/A | Community monitoring |
| **Notte** | `toolkit/notte-env/bin/python -m notte_mcp.server` | Python venv | `python3 -m venv toolkit/notte-env && source toolkit/notte-env/bin/activate && pip install notte-mcp` | `toolkit/notte-env/bin/python -c "import notte_mcp"` | Anti-detection scraping |
| **Spec-RAG** | `toolkit/spec-rag-env/bin/python toolkit/spec-rag-mcp/server.py` | Python venv, LanceDB | `python3 -m venv toolkit/spec-rag-env && source toolkit/spec-rag-env/bin/activate && pip install -r toolkit/spec-rag-mcp/requirements.txt` | `toolkit/spec-rag-env/bin/python -c "import lancedb"` | Semantic spec search |
| **Sources** | `toolkit/sources-env/bin/python toolkit/sources-mcp/server.py` | Python venv | `python3 -m venv toolkit/sources-env && source toolkit/sources-env/bin/activate && pip install -r toolkit/sources-mcp/requirements.txt` | `toolkit/sources-env/bin/python -c "import trafilatura"` | `/think intake`, `/simulate` |
| **Stitch** | `node tools/stitch-proxy.mjs` | Node.js | None | N/A | `/design ui` (broken — see dead ends) |

### Available via npx (auto-install, not in `.mcp.json`)

| Server | Command | Purpose | Used By |
|--------|---------|---------|---------|
| **Context7** | `npx -y @upstash/context7-mcp` | Up-to-date library docs (prevents hallucinated APIs) | `/think research`, `/build` |
| **DeepWiki** | `npx -y deepwiki-mcp` | Structured wiki docs for any GitHub repo | `/think research` |
| **Firecrawl** | `npx -y firecrawl-mcp` | Competitor crawling, web scraping | `/think research` |
| **Exa** | Requires API key + MCP setup | Neural search for research | `/think research`, `/think discover` |

### CC Plugins (auto-connected, no local install)

| Plugin | Purpose | Used By |
|--------|---------|---------|
| **Vercel** | Deployment, preview, logs | `/ship deploy`, prototype |
| **Figma** | Design system sync, screenshots | `/design ui`, `/design system` |
| **Linear** | Issue tracking | Project management |
| **Shadcn UI** | Component library reference | `/build component` |
| **Claude Preview** | Dev server + built-in browser | Prototype verification |
| **Claude in Chrome** | Real browser automation | Frontend debugging |
| **PDF Tools** | PDF read/fill/analyze | Document processing |
| **PowerPoint** | Slide creation | Presentations |
| **Word** | Document creation | Reports |
| **Gmail** | Email read/draft | Communications |
| **Computer Use** | macOS desktop automation | Cross-app workflows |

---

## 4. gOS File Structure (`.claude/`)

### Commands (9 verbs)

| File | Verb | Effort | Description |
|------|------|--------|-------------|
| `commands/gos.md` | `/gos` | medium | Conductor — briefing, orchestration, session management |
| `commands/think.md` | `/think` | high | Research, discover, decide, spec, intake |
| `commands/design.md` | `/design` | high | Card, ui, system — build cards and visual design |
| `commands/build.md` | `/build` | high | Feature, fix, refactor, prototype, TDD |
| `commands/review.md` | `/review` | max | Code, design, gate, council, eval |
| `commands/simulate.md` | `/simulate` | max | Market (MiroFish), scenario (what-if) |
| `commands/ship.md` | `/ship` | medium | Commit, PR, deploy |
| `commands/evolve.md` | `/evolve` | high | Audit, upgrade, learn — self-improvement |
| `commands/refine.md` | `/refine` | high | Convergence loop (think→design→simulate→review×N) |

### Agents (7 roster + 2 framework docs)

| File | Role | Model | Memory | MaxTurns |
|------|------|-------|--------|----------|
| `agents/researcher.md` | Deep research, fact-checking | sonnet | project | 25 |
| `agents/architect.md` | System design, API contracts | opus | project | 15 |
| `agents/engineer.md` | TDD implementation | sonnet | project | 40 |
| `agents/reviewer.md` | Code review, security (has veto) | sonnet | project | 20 |
| `agents/designer.md` | UI/UX, design system compliance | sonnet | project | 25 |
| `agents/verifier.md` | Tests, screenshots, e2e | haiku | local | 15 |
| `agents/aidesigner-frontend.md` | AIDesigner MCP integration | — | project | 30 |
| `agents/README.md` | Multi-agent framework protocol | — | — | — |
| `agents/team-registry.md` | 4 team templates | — | — | — |

### Skills (5)

| Skill | Auto-activates on | Purpose |
|-------|-------------------|---------|
| `financial-modeling` | `*.xlsx, *.xls` | OfficeCLI workflow, formula rules |
| `design-sync` | `specs/Arx_4-2*, specs/Arx_4-3*, DESIGN.md` | Design system sync |
| `arx-ui-stack` | `apps/**` | UI tech stack reference |
| `stitch-design` | — (manual) | Stitch MCP wrapper |
| `aidesigner-frontend` | — (manual) | AIDesigner MCP wrapper |

### Settings

| File | Scope | Git? | Key Contents |
|------|-------|------|-------------|
| `settings.json` | Team-shared | Yes | Autocompact 80%, destructive command guards, Stop/PreCompact hooks, attribution disabled |
| `settings.local.json` | Personal | No (.gitignored) | MCP permissions, tool allowlists |

### Other

| File | Purpose |
|------|---------|
| `gOS.md` | Soul file — loaded by `/gos` command |
| `launch.json` | Claude Preview dev server configs |
| `rules/figma-design-system.md` | Figma variable/component rules |

---

## 5. Project Structure (Required Directories)

```
Arx/
├── .claude/                  ← gOS brain (commands, agents, skills, settings)
│   ├── commands/             ← 9 verb files
│   ├── agents/               ← 7 roster + framework docs
│   ├── skills/               ← 5 skills with SKILL.md
│   ├── rules/                ← Project-specific rules
│   ├── settings.json         ← Team-shared settings
│   └── launch.json           ← Dev server configs
├── specs/                    ← Canonical product specs (96 files)
│   └── INDEX.md              ← Spec inventory
├── outputs/
│   ├── think/                ← /think staging area
│   │   ├── research/
│   │   ├── discover/
│   │   ├── design/
│   │   └── decide/
│   └── briefings/            ← /simulate output
├── apps/
│   ├── web-prototype/        ← Single-file HTML prototype
│   └── mobile/               ← React Native app
├── tools/
│   └── MANIFEST.md           ← This file (toolbox manifest)
│
│ (Shared tools live OUTSIDE the project at ~/Documents/Claude Working Folder/toolkit/)
│
│ toolkit/                    ← Shared cross-project tools
│   ├── officecli             ← OfficeCLI binary (Excel read/write/formula eval)
│   ├── hyperliquid-mcp/      ← Hyperliquid data MCP
│   ├── spec-rag-mcp/         ← Semantic spec search MCP
│   ├── sources-mcp/          ← Twitter/YouTube/blog intelligence MCP
│   ├── notte-env/            ← Anti-detection scraping venv
│   ├── spec-rag-env/         ← Spec-RAG Python venv
│   └── sources-env/          ← Sources Python venv
├── sessions/                 ← Session state
│   ├── scratchpad.md         ← Current session working memory
│   ├── evolve_signals.md     ← Signal log for /evolve
│   └── active.md             ← Active sessions registry
├── memory/                   ← Persistent cross-session memory
│   ├── MEMORY.md             ← Index (always loaded)
│   ├── user_gary_soul.md     ← User profile
│   ├── feedback_*.md         ← Behavioral corrections
│   ├── project_*.md          ← Project state
│   └── evolve_audit_*.md     ← Audit history
├── CLAUDE.md                 ← Project instructions (loaded every session)
├── DESIGN.md                 ← Auto-generated visual spec
├── .mcp.json                 ← MCP server config
└── Archive/                  ← Superseded files
```

---

## 6. Environment Variables

| Variable | Where Set | Purpose |
|----------|-----------|---------|
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | `.claude/settings.json` env block | Compact at 80% context |
| `PATH` (includes `~/bin`) | Shell profile | OfficeCLI access |
| `SUPADATA_API_KEY` | Shell env | YouTube transcript fallback |
| MCP-specific secrets | `.mcp.json` via `${VAR}` syntax | MCP server auth |

---

## 7. Scheduled Tasks

| Task ID | Schedule | Purpose |
|---------|----------|---------|
| `weekly-evolve-audit` | Mondays 9:17am | Auto-run `/evolve audit` |

---

## 8. Known Dead Ends

| Tool | Issue | Workaround |
|------|-------|------------|
| **Stitch MCP** | Server works manually but fails in Claude Code desktop app. Root cause unknown. | Use `/design ui` with Figma MCP or AIDesigner instead |
| **AIDesigner MCP** | Needs OAuth sign-in. Not auto-connected. | Sign in manually when needed |
| **openpyxl** | Corrupts complex .xlsx files. NEVER use for writing. | OfficeCLI + LibreOffice headless |
| **Node.js** | Not found in default PATH on this machine | Use `/usr/local/bin/node` or add to PATH |

---

## 9. Replication Checklist

To replicate this environment on a new machine:

1. [ ] Install core runtime (Python 3.9+, Node 18+, gh CLI)
2. [ ] Install Claude Code (`npm install -g @anthropic-ai/claude-code`)
3. [ ] Clone this repo
4. [ ] Run `./install.sh` (creates dirs, installs tools, sets up venvs)
5. [ ] Copy `specs/` from source (or regenerate from spec templates)
6. [ ] Copy `memory/` from source (or start fresh)
7. [ ] Configure MCP secrets in environment
8. [ ] Run `/gos` to verify setup
