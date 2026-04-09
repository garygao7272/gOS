# gOS Improvement Research — Five Questions

> Output of `/think research` — 2026-04-07

---

## Q1: Missing Tools in MANIFEST.md

MANIFEST.md is missing these gOS dependencies:

| Tool | Type | Used By | Install |
|------|------|---------|---------|
| **MiroFish** | Python module (local) | `/simulate market` — backtesting engine | `pip install` in project venv |
| **Dux** | Python app (separate repo) | `/simulate scenario` — strategic simulation | Clone from Dux repo |
| **Firecrawl** | MCP/npx | `/think research` — competitor crawling | `npx` auto-install |
| **Context7** | MCP/npx | Library docs lookup | `npx -y @upstash/context7-mcp` |
| **DeepWiki** | MCP/npx | GitHub repo documentation | `npx -y deepwiki-mcp` |
| **Exa** | MCP/API | `/think research` — deep research | Requires API key |
| **WPS Office** | macOS app (installed) | Manual spreadsheet viewing | Already installed |
| **Claude Desktop** | macOS app | Session teleport, Chrome extension | Download from claude.ai |

**Rule:** If gOS references it in a command/skill/agent and it requires local install → it belongs in MANIFEST.md.

**Action:** Update `tools/MANIFEST.md` with these entries.

---

## Q2: What Defines an AI Agent + gOS Gaps

### 5 Agent Properties

| Property | Score | Gap |
|----------|-------|-----|
| Perception | 9/10 | Strong (MCPs, search, specs) |
| Planning | 8/10 | Plan mode, complexity gate, templates |
| Action | 9/10 | Full tools, multi-agent, worktrees |
| Memory | 7/10 | Persistent but flat, no temporal validity, manual capture |
| Learning | 5/10 | Evolve exists but reactive, not proactive |

### Improvement Priorities for 1-Man Fintech Company

1. **Proactive learning** — auto-extract patterns after every session (not just when `/evolve audit` is invoked)
2. **Workflow automation loops** — `/loop` templates for solo founder: hourly QA, daily intel, weekly audit
3. **Financial domain intelligence** — regulatory compliance in `/review gate`, model validation persona
4. **Layered memory** (from mempalace) — L0 identity + L1 essentials always loaded, L2-L3 on demand

---

## Q3: shanraisshan/claude-code-best-practice — Remaining Improvements

Already scanned all 97 files. Additional patterns not yet adopted:

| Pattern | Source | Priority |
|---------|--------|----------|
| **Drift detection agents** | `workflows/best-practice/` | Medium — scheduled task that checks if our commands reference outdated CC features |
| **Cross-model workflow** | `development-workflows/cross-model-workflow/` | Medium — use Codex for second opinion on complex decisions |
| **`initialPrompt` frontmatter** | Subagent docs | High — auto-submitted first turn when agent starts |
| **RPI workflow agents** | `development-workflows/rpi/` | Medium — product-manager, ux-designer, constitutional-validator role definitions |

---

## Q4: mempalace — Memory Architecture Learnings

### Adopt

| Pattern | What | Priority |
|---------|------|----------|
| **4-Layer Memory Stack** | L0 Identity (100 tokens) → L1 Essential Story (800 tokens) → L2 On-Demand → L3 Deep Search. Hard token budgets per layer. | HIGH |
| **Palace Protocol** | "Before responding about any past event, search FIRST. Never guess — verify." Injected on first tool call. | HIGH |
| **Blocking PreCompact hook** | Returns `{"decision": "block"}` to force comprehensive save before context loss. Our current hook is advisory (prompt), not blocking. | MEDIUM |
| **Save interval trigger** | Auto-save every 15 human messages via Stop hook with counter. Catches long sessions. | MEDIUM |
| **Temporal fact validity** | Facts have `valid_from`/`valid_to`. Enables "what was true in January?" and explicit invalidation of stale facts. | MEDIUM |

### Skip

AAAK compression (scale problem we don't have), agent diary (our agent memory covers this), ChromaDB (spec-rag covers this), entity registry with Wikipedia (overkill).

### Key Insight

> "Raw verbatim text with good embeddings is a stronger baseline than anyone realized — because it doesn't lose information."

Validates our plain-markdown memory approach over vector-summarized alternatives.

---

## Q5: `/simulate flow` — Customer User Flow Simulation

### Proposed Sub-command

```
/simulate flow <JTBD> [--persona <S1-S8>] [--metric <success-metric>]
```

### What It Does

Traces a persona through the app's screen inventory for a given Job-to-be-Done. Counts steps, cognitive load, friction points, and feel alignment at each screen.

### Process

1. Load persona from `specs/Arx_2-1`
2. Load screen inventory from `specs/Arx_4-1-0_Experience_Design_Index.md`
3. Load journey map from `specs/Arx_3-3_Customer_Journey_Maps.md`
4. Walk each screen in the optimal path, reading build card specs
5. Score: steps (taps), cognitive load (decisions), time estimate, drop-off risk, feel alignment

### Output

| Metric | How Measured |
|--------|-------------|
| Steps | Total taps from entry to success |
| Cognitive load | Decisions per screen |
| Time estimate | 3s/scan, 5s/decision, 10s/data-entry |
| Drop-off risk | Screens where persona might abandon |
| Feel alignment | Screen feel token vs emotional arc |

### Team Template

3 agents:
- **Persona agent** — maintains "what would Sarah think here?"
- **Flow tracer** — reads each build card, counts steps/decisions
- **Optimizer** — proposes alternative paths, compares metrics

Output: flow map table + friction points + recommendations.

---

## Action Items

| # | Action | File(s) | Priority |
|---|--------|---------|----------|
| 1 | Add missing tools to MANIFEST.md | `tools/MANIFEST.md` | Now |
| 2 | Add Palace Protocol to gOS memory rules | `.claude/commands/gos.md` or `CLAUDE.md` | Now |
| 3 | Upgrade PreCompact hook to blocking | `.claude/settings.json` | Now |
| 4 | Add `/simulate flow` sub-command | `.claude/commands/simulate.md` | Next session |
| 5 | Add save-interval counter to Stop hook | `.claude/settings.json` | Next session |
| 6 | Implement layered memory (L0-L3 structure) | `memory/` restructure | Future |
| 7 | Add temporal validity to memory files | Memory file frontmatter | Future |
| 8 | Build drift-detection scheduled task | Scheduled task | Future |

---

## Sources

- [mempalace — GitHub](https://github.com/milla-jovovich/mempalace)
- [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice)
- [Addy Osmani — Self-Improving Coding Agents](https://addyosmani.com/blog/self-improving-agents/)
- [Metaswarm — self-improving framework](https://github.com/dsifry/metaswarm)
- [ECC continuous-learning-v2](https://github.com/affaan-m/everything-claude-code)
