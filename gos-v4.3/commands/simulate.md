---
description: "Simulate: market (MiroFish), scenario (what-if), backtest (historical), dux (full engine), runway (burn rate), revenue (projections), hiring (pipeline)"
---

# Simulate — Forward-Looking Intelligence → outputs/

**Simulate runs projections, scenarios, and simulations. Absorbs the former /intel command and connects to Dux simulation engine and MiroFish.**

**Scratchpad checkpoints.** Update `sessions/scratchpad.md`:

- **On entry:** Write current task, mode (`Simulate > {sub-command}`), and parameters
- **After data fetch:** Log source counts and data freshness to `Working State`
- **After output:** Log file paths and sizes to `Files Actively Editing`
- **After compaction:** Re-read `sessions/scratchpad.md` to restore state

Parse the first word of `$ARGUMENTS` to determine sub-command. If no sub-command given, ask: "What kind of simulation? market (MiroFish), scenario (what-if), backtest (historical), dux (full engine), runway (burn rate), revenue (projections), or hiring (pipeline)?"

**Output pipeline (shared):** MD → optionally HTML → optionally PDF (for briefings). See Output Pipeline section below.

**Scheduling note:** To run this simulation on a schedule, use: `/gos schedule add 'simulate market' --cron '0 9 * * *'`

---

## Intent Gate (mandatory — runs before any sub-command)

**First-Principles Decomposition.** Every request is broken into 6 MECE dimensions before execution. No exceptions for simulate — all produce output files.

### Step 1: DECOMPOSE

Parse Gary's request. Fill every dimension and classify:

| Dim | Question | ✅ Stated | 🔮 Inferred | ❌ Unknown |
|-----|----------|-----------|-------------|-----------|
| **WHAT** | What are we simulating? (market, scenario, backtest, runway, revenue) | Gary named it | Derivable from context | Must ask |
| **WHY** | What outcome? (forecast, stress-test, validate assumption, plan) | Gary stated purpose | Implied by sub-command | Must ask |
| **WHO** | Who needs this? (Gary, investors, team, board) | Gary specified | Obvious from context | Must ask |
| **HOW** | What method? (historical backtest, Monte Carlo, scenario tree, engine) | Gary chose sub-command | Matches complexity | Must ask |
| **SCOPE** | What parameters? (time horizon, assets, variables, scenarios count) | Gary bounded it | Inferrable from context | Must ask |
| **BAR** | What standard? (directional, defensible, investor-grade) | Gary set the bar | Implied by audience | Must ask |

### Step 2: PRESENT & CLARIFY

Show the decomposition:

> | Dim | Value | Status |
> |-----|-------|--------|
> | WHAT | {target} | ✅/🔮/❌ |
> | WHY | {purpose} | ✅/🔮/❌ |
> | WHO | {audience} | ✅/🔮/❌ |
> | HOW | {approach} | ✅/🔮/❌ |
> | SCOPE | {boundary} | ✅/🔮/❌ |
> | BAR | {standard} | ✅/🔮/❌ |

- **❌ Unknown** → ask ONE batched question covering all unknowns
- **🔮 Inferred** → state for confirmation
- **All ✅/🔮** → skip to Step 3

### Step 3: PLAN

> **Plan: Simulate > {sub-command}**
> - **Scope:** {WHAT + SCOPE resolved}
> - **Data sources:** {Hyperliquid MCP, WebSearch, existing models, etc.}
> - **Scenarios:** {N scenarios to generate (bull/base/bear, etc.)}
> - **Agents:** {N-agent team / single agent}
> - **Output:** {format → `outputs/briefings/{slug}.md` (+ HTML + PDF)}

**Before presenting "Go?":** Write to `sessions/scratchpad.md`:
- Update `## Current Task` with the resolved WHAT
- Update `## Mode & Sub-command` with the command > sub-command
- Update Pipeline State: `- [x] Intent Gate: WHAT={what} | WHY={why} | WHO={who} | HOW={how} | SCOPE={scope} | BAR={bar}`

### Step 4: CONFIRM
> **Go?**

**HARD STOP.** End your message here. Do NOT:
- Add a "preview" or "meanwhile" or "while you decide"
- Start producing output in the same message
- Say "Go?" and then keep writing

The message containing "Go?" must contain NOTHING after it. Wait for Gary's next message before doing any work.

### Step 5: PLAN MODE (mandatory after Gary confirms)

When Gary confirms ("go", "yes", "do it"), you MUST call `EnterPlanMode` before doing ANY work. This is not optional. This is deterministic:

```
Gary says "go" → call EnterPlanMode() → write plan to plan file → call ExitPlanMode() → Gary approves → THEN execute
```

**Exceptions (skip plan mode):**
- `--auto` flag (mobile/scheduled dispatch)
- Trust level T2+ for this domain
- Sub-commands marked `[skip-gate]`

**[skip-gate]:** Any sub-command with `--auto` flag (mobile/scheduled dispatch).

---

## Context Protocol (runs after Intent Gate, before execution)

After the Intent Gate resolves all 6 dimensions, auto-load relevant context. See `gOS/.claude/context-map.md` for the full keyword → source mapping.

1. Parse resolved WHAT and SCOPE for keywords
2. Match against context map → candidate sources
3. Check file existence (skip missing silently)
4. Estimate token cost (lines / 4)
5. If total < 30% of remaining context → load silently
6. If total > 30% → present list and ask Gary to trim
7. Log loaded context to `sessions/scratchpad.md` under `Working State`
8. **Write scratchpad marker:** Update `sessions/scratchpad.md` Pipeline State: `- [x] Context Loaded: {list of files loaded or "none needed"}`

---

## Memory Recall (runs after Context Protocol, before Trust Check)

Query persistent memory for relevant past experience before executing. This is how gOS learns across sessions.

1. **Search claude-mem** for the current command + domain:
   - `mcp__plugin_claude-mem_mcp-search__search({ query: "{WHAT} {sub-command}", type: "observation", limit: 5 })`
   - Also search: `mcp__plugin_claude-mem_mcp-search__search({ query: "{domain} {sub-command} signal", limit: 3 })`
2. **Check self-model** for domain competence:
   - Read the row for `{domain}` in `.claude/self-model.md`
   - If accept rate < 70% or weaknesses listed → flag: "Note: my `{domain}` has {weakness}. Adjusting approach."
3. **Surface relevant findings:**
   - If past sessions had reworks/rejects in this domain → mention what went wrong and how you'll avoid it
   - If past sessions had accepts/loves → mention what worked and reuse the approach
   - If no relevant history → say "No prior experience in this domain — running full pipeline."
4. **Write scratchpad marker:** Update Pipeline State: `- [x] Memory Recalled: {N} observations, self-model: {domain} T{N} {accept_rate}`

**Keep it brief.** One line of insight, not a paragraph. The goal is to inform execution, not to recite history.

---

## Trust Check (runs after Context Protocol, before Pipe Resolution)

Check trust level for the current domain. See `gOS/.claude/trust-ladder.md` for rules.

1. Infer domain from resolved WHAT (e.g., "simulate market" → `financial-modeling`)
2. Read `sessions/trust.json` → get trust level for this domain
3. Adjust gate depth accordingly (T0=full, T1=lighter confirm, T2=execute-first, T3=silent)
4. Note: `financial-modeling` has floor=T1 — never auto-promote above T1
5. Show trust context: "Trust: `{domain}` at T{N} ({history summary})"
6. **Write scratchpad marker:** Update Pipeline State: `- [x] Trust Level: T{N} for {domain}`

---

## Pipe Resolution (runs after Context Protocol, before execution)

Check for upstream artifacts that match the current task. See `gOS/.claude/artifact-schema.md` for the full schema and algorithm.

1. Parse WHAT from resolved intent
2. Search `outputs/` for files with matching topic in YAML frontmatter
3. Filter by types relevant to `/simulate`: research-brief, financial-model, decision
4. If found: present list and auto-load as context ("📎 Upstream artifacts found...")
5. If not found: proceed without — simulate can work from parameters alone
6. Update `outputs/ARTIFACT_INDEX.md` after writing output
7. **Write scratchpad marker:** Update Pipeline State: `- [x] Pipe Resolved: {N} upstream artifacts loaded` or `- [x] Pipe Resolved: none found`

---

## market [period]

**Purpose:** MiroFish market simulation. Run market regime detection, scenario generation, and trade recommendations across asset classes.

**Team Mode for scenario building:**
```
TeamCreate(team_name="simulate-market-{date}")
```
After data collection (parallel fetches — same as current), spawn 2 named teammates for scenario construction:
- `bull-case` (sonnet) — builds the optimistic scenario with evidence
- `bear-case` (sonnet) — builds the pessimistic scenario with evidence

After both report, lead adjudicates conflicts: where do bull and bear agree (high confidence)? Where do they diverge (flag as uncertainty)? Synthesize into the final briefing.

**Shutdown:** `SendMessage(to="*", message={type: "shutdown_request"})` then `TeamDelete`.

**Period parsing:**

| Input                     | Hours                                            | Example                      |
| ------------------------- | ------------------------------------------------ | ---------------------------- |
| _(none)_                  | 24                                               | `/simulate market`           |
| `48h`                     | 48                                               | `/simulate market 48h`       |
| `3d`                      | 72                                               | `/simulate market 3d`        |
| `7d` or `1w`              | 168                                              | `/simulate market 7d`        |
| `2w`                      | 336                                              | `/simulate market 2w`        |
| `1m` or `this month`      | Calculate hours from 1st of current month to now | `/simulate market 1m`        |
| Month name (e.g. `march`) | Calculate hours from 1st of that month to now    | `/simulate market march`     |

**Process:**

1. Parse period from remaining `$ARGUMENTS` (default: 24h)
2. Update scratchpad: `Simulate > market`, period, timestamp
3. **Data collection (parallel):**
   - Fetch Hyperliquid live data via MCP: `get_tickers` (all instruments), `get_candlestick` (BTC, ETH, SOL — 1h and 4h timeframes), `get_trades` (recent 50 per major pair), `get_book` (top 10 depth for BTC-USD, ETH-USD)
   - Fetch macro context via WebSearch: S&P 500, DXY, VIX, Treasury yields, Fed rate expectations
   - Fetch crypto-specific context via WebSearch: BTC dominance, total crypto market cap, major protocol news, regulatory developments
   - If source tools available: `fetch_all_sources(hours=N)`, `fetch_trending_events(period_hours=N)`
4. **Regime detection:**
   - Analyze price action across timeframes (1h, 4h, 1d)
   - Identify trend direction, momentum, volatility regime
   - Cross-reference with macro environment
   - Classify: bull / bear / neutral / transition with confidence level (0-100%)
5. **Scenario generation (MiroFish):**
   - Generate top 3 scenarios by probability (bull case, base case, bear case)
   - For each scenario: trigger condition, probability estimate, expected price targets, timeline
   - Identify catalysts that would shift regime
6. **Trade recommendations:**
   - Generate specific trade ideas across asset classes: BTC, ETH, major alts, stables yield, basis/funding
   - Each recommendation includes: entry, target, stop, size (% of portfolio), timeframe, rationale
   - Risk/reward ratio for each trade
   - Portfolio-level risk assessment (total exposure, correlation risk, liquidation distances)
7. **Synthesize briefing**

**Output format:**

```markdown
# Market Simulation — {date}

## Regime Assessment
**{bull/bear/neutral/transition}** — Confidence: {N}%

{2-3 sentence summary of current market state}

### Regime Indicators
| Indicator | Value | Signal |
|-----------|-------|--------|
| BTC Trend (4h) | {direction} | {bull/bear/neutral} |
| Volatility | {high/med/low} | {expanding/contracting} |
| Funding Rates | {positive/negative/mixed} | {crowded long/short/balanced} |
| Open Interest | {rising/falling} | {new money/liquidations} |
| Macro (DXY/VIX) | {values} | {risk-on/risk-off} |

## Key Events & Catalysts
1. **{Event}** — Impact: {HIGH/MED/LOW} — {assessment}
2. **{Event}** — Impact: {HIGH/MED/LOW} — {assessment}
3. **{Event}** — Impact: {HIGH/MED/LOW} — {assessment}

## Scenarios
### Bull Case ({N}% probability)
{trigger, targets, timeline}

### Base Case ({N}% probability)
{trigger, targets, timeline}

### Bear Case ({N}% probability)
{trigger, targets, timeline}

## Risk Signals
- {what could go wrong — specific, not generic}
- {liquidation cascade levels}
- {correlation risks}

## Opportunities
| # | Asset | Direction | Entry | Target | Stop | Size | Timeframe | R:R | Rationale |
|---|-------|-----------|-------|--------|------|------|-----------|-----|-----------|
| 1 | {pair} | {long/short} | {price} | {price} | {price} | {%} | {hours/days} | {ratio} | {why} |
| 2 | ... | ... | ... | ... | ... | ... | ... | ... | ... |

## Portfolio Risk Summary
- Total exposure: {%}
- Max correlated loss: {%}
- Nearest liquidation: {pair} at {price} ({distance}%)

---
*Generated: {timestamp} | Period: {N}h | Sources: {counts}*
*Zero hallucination policy: every claim has an inline source. Dead links marked [Link unavailable — cached quote].*
```

**Output to:** `outputs/briefings/market-sim-{YYYY-MM-DD}.md` (+ `.html` + `.pdf`)

**Geographic focus:** APAC + US. Not Euro-centric.
**Zero hallucination policy:** Every claim has an inline source link. Dead links marked `[Link unavailable — cached quote]`. No orphan claims.

---

## scenario <what-if>

**Purpose:** Forward-looking projection for a specific scenario. "What if ETH drops 40%", "what if we launch copy trading", "what if competitor raises $50M".

**Team decision:**
- If scenario involves conflicting historical vs current evidence: Create team `simulate-scenario-{slug}` with 3 teammates for adversarial what-if analysis
- Otherwise: Use ad-hoc subagents (current behavior)

**If team mode:** Named teammates: `historical-analyst` (sonnet), `current-context` (sonnet), `second-order` (haiku). After initial analysis, lead routes cross-examination: "historical-analyst found precedent X. current-context, does Y context block it?" via `SendMessage`.

**Process:**

1. Parse the what-if statement from remaining `$ARGUMENTS`
2. Update scratchpad: `Simulate > scenario`, what-if statement
3. **Classify scenario type:**
   - **Market scenario:** price movements, macro shifts, black swans → use Hyperliquid MCP for current state, WebSearch for historical precedents
   - **Product scenario:** feature launches, pricing changes, go-to-market → use specs/ for current product state, WebSearch for competitor analysis
   - **Business scenario:** fundraising, hiring, partnerships, regulatory → use WebSearch for market intelligence, specs/ for business model
4. **Research (parallel agents):**
   - Agent 1: Historical precedents — "When has this happened before? What was the outcome?"
   - Agent 2: Current context — "What's the current state that this scenario would disrupt?"
   - Agent 3: Second-order effects — "If this happens, what else changes as a consequence?"
5. **Project outcomes with probability estimates:**
   - Best case (20th percentile outcome)
   - Expected case (50th percentile outcome)
   - Worst case (80th percentile outcome)
   - Black swan case (95th percentile outcome)
6. **Decision implications:** What should Gary do NOW to prepare for each outcome?
7. **Time horizons:** Impact at 1 week, 1 month, 3 months, 1 year

**Output format:**

```markdown
# Scenario Simulation: {what-if statement}

## Current State
{what the world looks like right now relevant to this scenario}

## Historical Precedents
{when has something similar happened, what was the outcome}

## Projected Outcomes
| Outcome | Probability | Description | Impact on Arx |
|---------|------------|-------------|---------------|
| Best case | {%} | {description} | {impact} |
| Expected | {%} | {description} | {impact} |
| Worst case | {%} | {description} | {impact} |
| Black swan | {%} | {description} | {impact} |

## Second-Order Effects
1. {cascading consequence}
2. {cascading consequence}
3. {cascading consequence}

## Decision Matrix
| Timeframe | Action if Likely | Action if Unlikely | No-Regret Move |
|-----------|-----------------|-------------------|----------------|
| This week | {action} | {action} | {action} |
| This month | {action} | {action} | {action} |
| This quarter | {action} | {action} | {action} |

## Key Assumptions
{what must be true for this analysis to hold}
```

**Output to:** `outputs/think/research/{slug}.md`
**Suggest promotion:** "Promote to `specs/Arx_9-1_Decision_Log.md` as scenario analysis?"

---

## backtest <strategy>

**Purpose:** Run a trading strategy against historical data and report performance metrics.

**Process:**

1. Parse the strategy description from remaining `$ARGUMENTS`
2. Update scratchpad: `Simulate > backtest`, strategy description
3. **Check for Dux engine:**
   - If `/Users/garyg/Documents/Claude Working Folder/Dux/` exists, prefer Dux's backtesting engine
   - Otherwise, simulate using available Hyperliquid MCP data
4. **Define strategy parameters:**
   - Entry rules (what triggers a trade)
   - Exit rules (target, stop, trailing stop)
   - Position sizing (fixed, Kelly, volatility-adjusted)
   - Universe (which instruments)
   - Timeframe (candle size, lookback period)
5. **Fetch historical data:**
   - Use `get_candlestick` for each instrument in the universe
   - Fetch multiple timeframes if strategy requires (1m, 5m, 15m, 1h, 4h, 1d)
   - Note: Hyperliquid MCP returns up to 50 candles per request — for longer backtests, use Dux or note data limitations
6. **Run backtest:**
   - Iterate through candles chronologically
   - Apply entry/exit rules
   - Track positions, P&L, drawdowns
   - Calculate performance metrics
7. **Report results**

**Output format:**

```markdown
# Backtest: {strategy name}

## Strategy Definition
- **Entry:** {rules}
- **Exit:** {rules}
- **Sizing:** {method}
- **Universe:** {instruments}
- **Period:** {start} to {end} ({N} candles)

## Performance Summary
| Metric | Value |
|--------|-------|
| Total Return | {%} |
| Annualized Return | {%} |
| Sharpe Ratio | {ratio} |
| Sortino Ratio | {ratio} |
| Max Drawdown | {%} |
| Win Rate | {%} |
| Profit Factor | {ratio} |
| Avg Win / Avg Loss | {ratio} |
| Total Trades | {N} |
| Avg Hold Time | {duration} |

## Equity Curve (text-based)
{ASCII chart or table of cumulative returns by period}

## Trade Log (sample)
| # | Date | Direction | Entry | Exit | P&L | Hold Time |
|---|------|-----------|-------|------|-----|-----------|
{top 5 winners and top 5 losers}

## Risk Analysis
- Longest drawdown: {duration}
- Recovery time from max DD: {duration}
- Worst single trade: {%}
- Best single trade: {%}
- Max consecutive losses: {N}

## Data Limitations
{note any gaps, limited candle count, missing instruments}

## Recommendations
{what to adjust, what looks promising, what to avoid}
```

**Output to:** `outputs/think/research/backtest-{slug}.md`

**If Dux available, run via:**
```bash
cd "/Users/garyg/Documents/Claude Working Folder/Dux" && PYTHONPATH=. python -m backend.main backtest --strategy "{strategy}" --output json
```

---

## dux <config>

**Purpose:** Full Dux simulation engine invocation. Build knowledge graph from seed scenario, branch into futures (Graph-of-Thoughts), simulate with LLM agents (Concordia-inspired), find best path (MCTS/Beam Search).

**Process:**

1. Parse config from remaining `$ARGUMENTS`
2. Update scratchpad: `Simulate > dux`, config description
3. **Check Dux availability:**
   - Check if `/Users/garyg/Documents/Claude Working Folder/Dux/` exists
   - If yes, proceed with engine invocation
   - If no, explain setup requirements (see Setup section below)
4. **If Dux exists, run the simulation pipeline:**

   **Pipeline stages (reference Dux architecture):**

   | Stage | Module | Purpose |
   |-------|--------|---------|
   | 1. Seed | `seed/` | Parse scenario into structured seed document |
   | 2. Ontology | `ontology/` | Build knowledge graph — entities, relationships, constraints |
   | 3. Branching | `branching/` | Generate future branches (Graph-of-Thoughts) — each branch is a possible world |
   | 4. Agents | `agents/` | Concordia-inspired LLM agents simulate actors in each branch |
   | 5. Search | `search/` | MCTS or Beam Search to find highest-value paths |
   | 6. Evaluation | `evaluation/` | Score paths on utility, probability, robustness |
   | 7. Orchestrator | `orchestrator/` | Coordinate the full pipeline, manage state |

   **Invocation:**
   ```bash
   cd "/Users/garyg/Documents/Claude Working Folder/Dux" && PYTHONPATH=. python -m backend.main simulate --config "{config}" --output json
   ```

5. **If Dux does not exist, explain what's needed:**

   > **Dux is not yet set up in this workspace.**
   >
   > Dux is the simulation engine that powers deep scenario analysis. To set it up:
   >
   > 1. Clone or create the Dux project at `/Users/garyg/Documents/Claude Working Folder/Dux/`
   > 2. Install dependencies: `pip install -r requirements.txt`
   > 3. Configure the backend: `cp .env.example .env` and set API keys
   > 4. Verify: `PYTHONPATH=. python -m backend.main --help`
   >
   > See `memory/project_dux.md` for full architecture details.
   >
   > In the meantime, use `/simulate scenario <what-if>` for LLM-based scenario analysis without the full engine.

6. **Parse and present results:**
   - Best path with probability and utility score
   - Top 3 alternative paths
   - Critical decision points (where paths diverge most)
   - Key actors and their simulated behaviors
   - Recommended actions based on highest-utility path

**Output format:**

```markdown
# Dux Simulation: {config}

## Seed Scenario
{parsed seed document}

## Knowledge Graph Summary
- Entities: {N} ({list top 10})
- Relationships: {N}
- Constraints: {N}

## Branch Tree
{ASCII tree showing top branches with probabilities}

## Best Path
**Utility: {score} | Probability: {%} | Robustness: {%}**

{narrative description of the best-path future}

### Critical Decision Points
1. **{decision}** at {timepoint} — choosing {A} over {B} because {rationale}
2. **{decision}** at {timepoint} — choosing {A} over {B} because {rationale}

## Alternative Paths
| Rank | Path | Utility | Probability | Key Difference |
|------|------|---------|-------------|----------------|
| 2 | {name} | {score} | {%} | {what's different} |
| 3 | {name} | {score} | {%} | {what's different} |

## Agent Behaviors
| Actor | Role | Simulated Behavior | Confidence |
|-------|------|-------------------|------------|
{key actors and what they did in the simulation}

## Recommended Actions
1. {action} — {rationale} — {urgency}
2. {action} — {rationale} — {urgency}
3. {action} — {rationale} — {urgency}
```

**Output to:** `outputs/think/research/dux-{slug}.md`

---

---

## runway [months]

**Purpose:** Burn rate analysis and runway projections. Answer "how long until we run out of money?" under various scenarios.

**Input:** Optional time horizon in months (default: 18). Also accepts `--funding <amount>` for modeling new funding.

**Process:**

1. Parse parameters from remaining `$ARGUMENTS`
2. Update scratchpad: `Simulate > runway`, parameters
3. **Gather financial data:**
   - Check `outputs/think/finance/` for existing financial models
   - Ask for or estimate: current cash, monthly burn rate, revenue (if any), headcount, major expenses
   - If a financial model exists: extract actuals from it
4. **Build burn rate model:**
   - Fixed costs (rent, salaries, subscriptions, infrastructure)
   - Variable costs (marketing, commissions, usage-based services)
   - Revenue offsets (if generating revenue)
   - One-time expenses (equipment, legal, hiring costs)
5. **Generate 3 scenarios:**

```markdown
# Runway Simulation — {date}

## Current State
- **Cash on hand:** ${amount}
- **Monthly burn:** ${amount}
- **Monthly revenue:** ${amount}
- **Net burn:** ${amount}
- **Current runway:** {N} months ({date})

## Scenarios

### Conservative (cut all non-essential)
| Month | Cash | Burn | Revenue | Net | Runway Left |
|-------|------|------|---------|-----|-------------|
{monthly projection}

**Runway:** {N} months — runs out {date}
**Key cuts:** {what was reduced}

### Base Case (current trajectory)
| Month | Cash | Burn | Revenue | Net | Runway Left |
|-------|------|------|---------|-----|-------------|
{monthly projection}

**Runway:** {N} months — runs out {date}

### Growth (hiring + scaling)
| Month | Cash | Burn | Revenue | Net | Runway Left |
|-------|------|------|---------|-----|-------------|
{monthly projection}

**Runway:** {N} months — runs out {date}
**Key additions:** {new hires, infrastructure, marketing}

## Sensitivity Analysis
| Variable | -20% | Base | +20% | Impact on Runway |
|----------|------|------|------|-----------------|
| Burn rate | {months} | {months} | {months} | {high/med/low} |
| Revenue | {months} | {months} | {months} | {high/med/low} |
| Headcount | {months} | {months} | {months} | {high/med/low} |

## Critical Dates
- **6 months runway:** {date} — start fundraising
- **3 months runway:** {date} — emergency mode
- **0 months runway:** {date} — lights out

## Recommendations
1. {action to extend runway}
2. {action to accelerate revenue}
3. {fundraising timing recommendation}
```

**Output to:** `outputs/briefings/runway-{YYYY-MM-DD}.md` (+ HTML + PDF)

---

## revenue [period]

**Purpose:** Revenue projections, pricing sensitivity, and growth modeling. Answer "how much will we make?" under various assumptions.

**Input:** Optional projection period (default: 12 months). Also accepts specific scenarios like `--users <N>` or `--price <$>`.

**Process:**

1. Parse parameters from remaining `$ARGUMENTS`
2. Update scratchpad: `Simulate > revenue`, parameters
3. **Gather revenue model inputs:**
   - Check `outputs/think/finance/` and `outputs/think/gtm/` for existing analysis
   - Revenue streams (subscriptions, transaction fees, builder codes, etc.)
   - Current metrics (users, ARPU, conversion rate, churn)
   - Growth assumptions (user acquisition rate, expansion revenue)
4. **Build revenue model:**
   - Top-down: TAM × market share × ARPU
   - Bottom-up: users × conversion × price × retention
   - Cohort-based: monthly cohort × retention curve × LTV
5. **Generate projections:**

```markdown
# Revenue Simulation — {date}

## Revenue Streams
| Stream | Current MRR | Growth Rate | 12-Month Projection |
|--------|------------|-------------|-------------------|

## Projections

### Bear Case (slow adoption)
| Month | Users | Conversion | MRR | ARR | Cumulative |
|-------|-------|-----------|-----|-----|------------|
{monthly projection}

### Base Case (expected)
| Month | Users | Conversion | MRR | ARR | Cumulative |
|-------|-------|-----------|-----|-----|------------|
{monthly projection}

### Bull Case (viral growth)
| Month | Users | Conversion | MRR | ARR | Cumulative |
|-------|-------|-----------|-----|-----|------------|
{monthly projection}

## Unit Economics
| Metric | Current | Target | Industry Median |
|--------|---------|--------|----------------|
| CAC | ${} | ${} | ${} |
| LTV | ${} | ${} | ${} |
| LTV:CAC | {ratio} | >3:1 | {ratio} |
| Payback period | {months} | <12mo | {months} |
| Monthly churn | {%} | <5% | {%} |
| Net revenue retention | {%} | >100% | {%} |

## Pricing Sensitivity
| Price Point | Users (est.) | Conversion (est.) | MRR | Notes |
|------------|-------------|-------------------|-----|-------|
{3-5 price points}

## Key Assumptions
{what must be true for these projections to hold}

## Recommendations
1. {pricing action}
2. {acquisition action}
3. {retention action}
```

**Output to:** `outputs/briefings/revenue-{YYYY-MM-DD}.md` (+ HTML + PDF)

---

## hiring [timeline]

**Purpose:** Hiring pipeline projections and team growth modeling. Answer "when do we need to hire and what does it cost?"

**Input:** Optional timeline (default: 12 months). Also accepts `--roles <list>` for specific roles.

**Process:**

1. Parse parameters from remaining `$ARGUMENTS`
2. Update scratchpad: `Simulate > hiring`, parameters
3. **Gather hiring data:**
   - Check `outputs/think/hire/` for existing hiring briefs
   - Current team composition
   - Product roadmap milestones that require new hires
   - Budget constraints from runway model
4. **Build hiring plan:**

```markdown
# Hiring Simulation — {date}

## Current Team
| Role | Count | Monthly Cost |
|------|-------|-------------|
| {role} | {N} | ${total} |
| **Total** | **{N}** | **${total}** |

## Hiring Plan

### Q1 Hires
| Role | Start Date | Salary | Ramp Cost | Rationale |
|------|-----------|--------|-----------|-----------|

### Q2 Hires
...

### Q3-Q4 Hires
...

## Pipeline Projections
| Role | Sourcing Start | Pipeline Target | Interviews | Offer | Start |
|------|---------------|----------------|------------|-------|-------|
| {role} | {date} | {N candidates} | {N} | {date} | {date} |

## Cost Impact
| Month | Headcount | Monthly Payroll | Hiring Costs | Total People Cost |
|-------|-----------|----------------|-------------|------------------|
{monthly projection}

## Hiring Velocity Needed
- **Roles to fill:** {N}
- **Average time-to-hire:** {N weeks}
- **Pipeline conversion:** {%} (application → hire)
- **Applications needed:** {N total}
- **Sourcing capacity required:** {N/week}

## Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| Can't find senior talent | {impact} | {mitigation} |
| Offers rejected (comp) | {impact} | {mitigation} |
| Slower than planned | {impact} | {mitigation} |

## Recommendations
1. {action}
2. {action}
3. {action}
```

**Output to:** `outputs/briefings/hiring-{YYYY-MM-DD}.md` (+ HTML + PDF)

---

## Output Pipeline (shared by all sub-commands)

All simulation outputs use the same pipeline:

1. **Write markdown** to the appropriate output directory
2. **Convert to HTML** using Python markdown2 with Apple-minimalist CSS:
   - Font: -apple-system, BlinkMacSystemFont, 'SF Pro Text'
   - Code blocks: #f5f5f7 background
   - Links: #007aff
   - Tables: dark header (#1d1d1f), hover highlight
   - Print-optimized CSS (@media print)
3. **Generate PDF** via Playwright:
   - Load HTML via `file://` URL
   - `page.pdf()` with A4 format, 20mm margins, printBackground: true
4. **Version handling:** If a file for today already exists, append `-v2`, `-v3`, etc.

Python environment for markdown2 + Playwright: `tools/sources-env/bin/python`

---

## Intelligence Briefings (former /intel)

The former `/intel` war-room and signal-scan commands are now accessible via `/simulate market`. For the full experience:

- **War Room equivalent:** `/simulate market` — produces the same regime assessment + trade recommendations
- **Signal Scan:** Use `/think discover` for AI/fintech/crypto innovation scanning
- **Both:** Run `/simulate market` and `/think discover` in parallel via scheduling
- **Status:** Check `outputs/briefings/` for recent outputs, or use `/gos schedule list` to see scheduled runs

If you have existing scheduled tasks for `war-room` or `signal-scan`, they continue to work via their SKILL.md files. Consider migrating to `/gos schedule add 'simulate market'` for the unified interface.

---

## Team Mode for Business Sub-commands

### runway — Team `simulate-runway-{date}`
- **`cost-modeler` (sonnet):** Fixed costs, variable costs, one-time expenses
- **`revenue-modeler` (sonnet):** Revenue streams, growth projections, pricing
- **`scenario-builder` (haiku):** Conservative/base/growth scenario construction

### revenue — Team `simulate-revenue-{date}`
- **`top-down-analyst` (sonnet):** TAM × market share × ARPU approach
- **`bottom-up-analyst` (sonnet):** Users × conversion × price × retention approach
- **`benchmarker` (haiku):** Compare projections against industry benchmarks

### hiring — Team `simulate-hiring-{date}`
- **`role-planner` (sonnet):** Map roadmap milestones to hiring needs
- **`cost-modeler` (sonnet):** Salary benchmarks, hiring costs, ramp costs
- **`pipeline-analyst` (haiku):** Sourcing capacity, time-to-hire, conversion rates

All teams follow the standard pattern: `TeamCreate` → spawn → cross-examine → synthesize → `TeamDelete`.

---

## Output Contract (MANDATORY — runs after execution, before presenting)

**You MUST complete all steps before showing output to Gary.** See `gOS/.claude/output-contract.md` for the full rubric.

1. Score on 5 universal dimensions (1-5): Completeness, Evidence, Actionability, Accuracy, Clarity
2. Score on Simulate extension: **Range** (1-5) — single scenario vs wide spread with tails
3. Identify weakest dimension
4. If any dimension ≤ 2 → flag and offer to improve before Gary reads
5. Apply **Confidence Calibration** to projections and forecasts (see `gOS/.claude/confidence-calibration.md`):
   - Score each key claim on 6 structural factors → 🟢HIGH / 🟡MEDIUM / 🟠LOW / 🔴SPECULATIVE
   - Include aggregate confidence in scorecard header
   - Flag the single biggest uncertainty
6. Present scorecard + confidence summary at top of output
7. **Write YAML frontmatter** to the output file (per `gOS/.claude/artifact-schema.md`):
   ```yaml
   ---
   artifact_type: simulation | financial-model
   created_by: /simulate {sub-command}
   created_at: {ISO timestamp}
   topic: {WHAT from intent}
   related_specs: [{matched specs}]
   quality_score: {scores from step 1-2}
   status: draft
   ---
   ```
8. **Update `outputs/ARTIFACT_INDEX.md`** — add or update entry for this artifact
9. **Write scratchpad markers:** Update Pipeline State:
   - `- [x] Output Scored: {avg}/5 (weakest: {dimension})`
   - `- [x] Frontmatter Written: {path}`
   - `- [x] Index Updated: {topic} added to ARTIFACT_INDEX`

---

## Red Team Check (runs after Output Contract, before presenting)

**Simulate red team question:** "Which assumption, if wrong by 2x, invalidates this forecast?"

1. Run the red team question against the draft output
2. If a genuine issue is found (would change Gary's decision):
   a. Fix it if possible (add sensitivity analysis)
   b. If not fixable: flag in output header with ⚔️ marker
3. If finding is LOW confidence or wouldn't change any decision → suppress (no noise)
4. **Write scratchpad marker:** Update Pipeline State: `- [x] Red Team Passed: {question asked} → {finding or "clean"}`

---

## Signal Capture (MANDATORY — after every execution)

**After presenting output, observe Gary's NEXT response and classify the signal.**

1. Classify Gary's response as one of:
   - `accept` — used output without changes, moved on
   - `rework` — "change this", "not quite", "try again"
   - `reject` — "no", "scratch that", "wrong approach"
   - `love` — "perfect", "great", "exactly", "hell yes"
   - `repeat` — same instruction given twice (gOS didn't learn)
   - `skip` — Gary jumped past a prescribed step

2. **Log to `sessions/evolve_signals.md`:**
   | Time | Command | Sub-cmd | Signal | Context |
   |------|---------|---------|--------|---------|

3. **Update `sessions/trust.json`** — adjust trust level for the current domain per `gOS/.claude/trust-ladder.md`:
   - `accept`/`love` → increment consecutive accept count
   - `rework`/`reject` → reset count, demote if threshold hit
   - Check progression rules (T0→T1 needs 3+ consecutive accepts)

4. If `repeat` detected → immediately update relevant command file or memory
5. If `love` detected → save the approach to feedback memory for reuse
6. **Write scratchpad marker:** Update Pipeline State: `- [x] Signal Captured: {signal type} for {domain}`
