# High-Impact GitHub Repos Since 2026 — Relevant to gOS & Arx

> Research date: 2026-03-22
> Query: GitHub repos created since Jan 2026, sorted by stars, relevant to gOS (AI agent OS), Arx (crypto trading terminal), and Gary's solo-builder stack

## TL;DR

- 48K-star `autoresearch` (Karpathy) leads as the AI agent research automation tool
- Agent orchestration and memory infrastructure are the hottest category — 5 repos above 10K stars
- MCP ecosystem is exploding — 10+ repos building codebase intelligence, persistent memory, browser control
- Crypto/trading repos are mostly spam-farmed; only 3-4 are genuinely useful
- Callstack's `agent-skills` for React Native is directly on Arx's mobile stack

---

## Tier 1 — High Stars, High Relevance (Investigate Now)

|  Stars | Repo                                                                      | What It Does                                                                                | Why It Matters for gOS/Arx                                                                                                   |
| -----: | ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| 48,562 | [karpathy/autoresearch](https://github.com/karpathy/autoresearch)         | AI agents running automated research on GPU training                                        | Pattern reference for autonomous research loops — mirrors `/think research` swarm                                            |
| 24,054 | [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) | Browser automation CLI for AI agents                                                        | Could replace/complement Playwright MCP for Arx UI testing                                                                   |
| 17,573 | [volcengine/OpenViking](https://github.com/volcengine/OpenViking)         | Context database for AI agents — unifies memory, resources, skills via file system paradigm | Directly mirrors gOS memory layers (context window → scratchpad → persistent). Study as potential infrastructure replacement |
| 13,447 | [snarktank/ralph](https://github.com/snarktank/ralph)                     | Autonomous AI agent loop — runs until PRD is complete                                       | Parallel to `/build` verb's sequential executor. Ralph Loop skill already in gOS                                             |
| 11,905 | [cft0808/edict](https://github.com/cft0808/edict)                         | Multi-agent orchestration with 9 specialized agents, dashboard, audit trails                | Architecture reference for `/dispatch` and agent swarm patterns                                                              |
| 10,256 | [Panniantong/Agent-Reach](https://github.com/Panniantong/Agent-Reach)     | Zero-API-fee social/web reading — Twitter, Reddit, YouTube, GitHub, Bilibili, XiaoHongShu   | Direct competitor to `sources` MCP server + defuddle intake pipeline                                                         |

## Tier 2 — Medium Stars, High Relevance (Worth Installing/Studying)

|  Stars | Repo                                                                                  | What It Does                                                                     | Why It Matters                                                |
| -----: | ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| 21,953 | [googleworkspace/cli](https://github.com/googleworkspace/cli)                         | Google Workspace CLI with AI agent skills                                        | Productivity layer — Drive, Gmail, Calendar as CLI tools      |
| 15,344 | [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills)     | Marketing skills for Claude Code                                                 | CRO, copywriting, SEO, growth — relevant for Arx go-to-market |
|  6,763 | [teng-lin/notebooklm-py](https://github.com/teng-lin/notebooklm-py)                   | Python API for Google NotebookLM as agentic skill                                | Knowledge management tool — could complement intake pipeline  |
|  1,812 | [microsoft/skills](https://github.com/microsoft/skills)                               | Skills, MCP servers, Agents.md for SDKs                                          | Reference architecture for skills ecosystem                   |
|  1,720 | [Gentleman-Programming/engram](https://github.com/Gentleman-Programming/engram)       | Persistent memory for AI coding agents — Go binary, SQLite+FTS5, MCP server      | Drop-in complement to `claude-mem` plugin                     |
|  1,578 | [epiral/bb-browser](https://github.com/epiral/bb-browser)                             | Browser control with your login state — CLI + MCP                                | Relevant for authenticated Hyperliquid UI testing             |
|  1,489 | [ForLoopCodes/contextplus](https://github.com/ForLoopCodes/contextplus)               | RAG + AST + Obsidian-style linking as MCP server                                 | Could augment or replace `spec-rag` MCP server                |
|  1,049 | [callstackincubator/agent-skills](https://github.com/callstackincubator/agent-skills) | Agent-optimized React Native skills                                              | **Directly on Arx's mobile stack** — install immediately      |
|    809 | [DeusData/codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp)       | Code intelligence MCP — persistent knowledge graph, 64 languages, sub-ms queries | Codebase navigation upgrade                                   |
|    762 | [dadbodgeoff/drift](https://github.com/dadbodgeoff/drift)                             | Cross-session decision memory that learns codebase conventions                   | Relevant to gOS `/evolve` pattern recognition                 |
|    682 | [carmahhawwari/ui-design-brain](https://github.com/carmahhawwari/ui-design-brain)     | AI skill for 60+ UI component patterns                                           | Design system knowledge for Arx UI work                       |

## Tier 3 — Crypto/Trading Specific

| Stars | Repo                                                                                                                 | What It Does                                                | Why It Matters                                     |
| ----: | -------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- | -------------------------------------------------- |
|   815 | [UNICORN-Binance-WebSocket-API](https://github.com/gesine1541ro7/UNICORN-Binance-WebSocket-API)                      | Real-time WebSocket market data streaming                   | Reference for live data layer architecture         |
|   557 | [freqtrade-bot](https://github.com/Kaleighc793/freqtrade-bot)                                                        | Battle-tested strategy framework with backtesting           | Signal/strategy architecture reference             |
|   254 | [Hyperliquid-AI-Agent-Trading-Bot](https://github.com/Oasismetaverse-Venture-Trade/Hyperliquid-AI-Agent-Trading-Bot) | AI agent trading bot on Hyperliquid                         | Direct competitor reference                        |
|   242 | [HyperLiquid-Claw](https://github.com/Rohit24567/HyperLiquid-Claw)                                                   | AI assistant DEX access to Hyperliquid                      | On-stack tool for agent-driven trading             |
|   145 | [second-state/fintool](https://github.com/second-state/fintool)                                                      | Rust CLI for agentic trading — dedicated Hyperliquid binary | Most architecturally relevant for Arx signal layer |

**Warning:** Most crypto/trading repos in the 200-400 star range (especially the Polymarket cluster) show star-farming patterns — keyword-stuffed descriptions, repetitive forks. Treat with skepticism.

## Tier 4 — Developer Productivity

| Stars | Repo                                                                    | What It Does                                               |
| ----: | ----------------------------------------------------------------------- | ---------------------------------------------------------- |
| 2,173 | [huseyinbabal/taws](https://github.com/huseyinbabal/taws)               | Terminal UI for AWS                                        |
| 1,203 | [jgravelle/jcodemunch-mcp](https://github.com/jgravelle/jcodemunch-mcp) | Token-efficient GitHub code exploration via AST            |
| 1,035 | [philschmid/mcp-cli](https://github.com/philschmid/mcp-cli)             | Lightweight CLI to interact with MCP servers               |
|   808 | [Dev-Janitor](https://github.com/cocojojo5213/Dev-Janitor)              | Cross-platform dev artifact cleanup                        |
|   632 | [thellimist/clihub](https://github.com/thellimist/clihub)               | Turn any MCP server into a CLI                             |
|   497 | [skalesapp/skales](https://github.com/skalesapp/skales)                 | Free AI desktop agent — email, calendar, browser, code gen |

---

## Recommended Actions

### Install Now

1. **callstackincubator/agent-skills** — React Native skills directly on Arx mobile stack
2. **defuddle** (already done) — Content extraction, already integrated into intake

### Study Architecture

3. **OpenViking** — Context database design vs gOS's scratchpad/memory approach
4. **edict** — Multi-agent orchestration patterns for `/dispatch`
5. **engram** — Persistent memory alternative to `claude-mem`

### Monitor

6. **Agent-Reach** — If it covers Hyperliquid or can be extended, could replace custom `sources` MCP
7. **contextplus** — If it outperforms `spec-rag`, swap it in
8. **fintool** — Rust CLI with Hyperliquid binary — performance-critical trading tool

---

## Methodology

Three parallel search agents queried GitHub across 18 search terms:

- Agent 1: AI agents, MCP servers, CLI tools, LLM frameworks, web scraping, knowledge management
- Agent 2: Crypto trading, DeFi, trading bots, market data, fintech, Hyperliquid
- Agent 3: React Native, design systems, developer tools, productivity AI, code generation, terminal UI

Results deduplicated, filtered to 200+ stars (500+ for non-crypto), and ranked. Star-farming repos flagged.
