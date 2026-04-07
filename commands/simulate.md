---
effort: max
description: "Simulate: market (MiroFish + backtest), scenario (what-if + Dux engine), flow (JTBD user journey)"
---

# Simulate — Forward-Looking Intelligence → outputs/

**Simulate runs projections, scenarios, and simulations. Absorbs the former /intel command and connects to Dux simulation engine and MiroFish.**

**Scratchpad checkpoints.** Update `sessions/scratchpad.md`:

- **On entry:** Write current task, mode (`Simulate > {sub-command}`), and parameters
- **After data fetch:** Log source counts and data freshness to `Working State`
- **After output:** Log file paths and sizes to `Files Actively Editing`
- **After compaction:** Re-read `sessions/scratchpad.md` to restore state

Parse the first word of `$ARGUMENTS` to determine sub-command. If no sub-command given, ask: "What kind of simulation? market (MiroFish, includes backtest), scenario (what-if, powered by Dux), or flow (JTBD user journey)?"

> **Simplified (v2):** `backtest` folded into `market` (use `market --backtest`). `dux` folded into `scenario` (Dux is the engine powering scenario analysis).

**Output pipeline (shared):** MD → optionally HTML → optionally PDF (for briefings). See Output Pipeline section below.

**Scheduling note:** To run this simulation on a schedule, use: `/gos schedule add 'simulate market' --cron '0 9 * * *'`

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

## flow <JTBD statement> [--persona <S1-S8>] [--metric <success-metric>]

**Purpose:** Simulate a customer journey through the app for a given Job-to-be-Done. Measure efficiency (steps), cognitive load (decisions), friction (drop-off risk), and feel alignment at each screen. Produces an optimized flow map with specific UX recommendations.

**Input:** A JTBD statement. Optionally specify persona and success metric.

```
/simulate flow "S7 Sarah wants to copy a top trader's ETH position with $500 max risk"
/simulate flow "S2 Jake wants to identify and enter a momentum trade on BTC" --metric time-to-trade
/simulate flow "New user wants to fund their account and make their first trade" --persona S1
```

**Process:**

1. **Load context (parallel reads):**
   - Persona definition from `specs/Arx_2-1_Problem_Space_and_Audience.md`
   - Screen inventory from `specs/Arx_4-1-0_Experience_Design_Index.md`
   - Journey maps from `specs/Arx_3-3_Customer_Journey_Maps.md`
   - Navigation graph from build card `Navigate` sections

2. **Identify entry point:** Where does this persona start for this JTBD?
   - Cold start (app install → onboarding)?
   - Home screen (existing user)?
   - Deep link (notification, referral)?

3. **Trace the optimal path:** Walk through every screen in the happy path.
   For each screen, read its build card (`specs/Arx_4-1-1-X_*.md`) and record:

   | Metric | How Measured |
   |--------|-------------|
   | Screen name + spec ref | From build card filename |
   | Action required | From `## What the User Does` section |
   | Taps | Count of distinct touch actions |
   | Cognitive decisions | Choices where user must evaluate options |
   | Data entry | Fields that require typing |
   | Information presented | Key data points shown (can user parse them?) |
   | Drop-off risk | LOW / MEDIUM / HIGH — based on cognitive load + fear factors |
   | Feel token | From `## Feel` section — does it match the emotional need? |

4. **Score the flow:**

   ```
   Total steps     = sum of all taps across screens
   Time estimate   = 3s per scan + 5s per decision + 10s per data entry
   Cognitive load  = total decisions (fewer = better, target <5 for S7)
   Drop-off score  = count of HIGH-risk screens (target: 0)
   Feel alignment  = % of screens where feel token matches JTBD emotional arc
   ```

5. **Identify friction points:** Any screen where:
   - Cognitive load > 3 decisions
   - Data entry required but could be pre-filled
   - Information density exceeds persona's skill level
   - Navigation requires back-tracking
   - Feel token mismatches emotional need (e.g., `feel:trade` anxiety on a discovery screen)

6. **Generate alternatives:** For each friction point, propose:
   - Skip option (can we remove this screen?)
   - Simplify option (can we pre-fill or default?)
   - Reorder option (would a different sequence reduce cognitive load?)
   - Shortcut option (direct path for this persona's common JTBD?)

7. **Compare S2 vs S7 if both relevant:** Run the same JTBD for both personas. Note where their optimal paths diverge — this reveals where adaptive UX is needed.

**Output format:**

```markdown
## Flow Simulation: {JTBD}

### Persona: {name} ({segment})
### Success Metric: {metric}
### Entry: {entry point}

### Optimal Path

{Screen 1} → {Screen 2} → ... → {Success}
**Steps:** {n} | **Time:** ~{t}s | **Decisions:** {d} | **Drop-offs:** {count}

### Screen-by-Screen Analysis

| # | Screen | Spec | Taps | Decisions | Drop-off | Feel |
|---|--------|------|------|-----------|----------|------|
| 1 | {name} | Arx_4-1-1-X | {n} | {n} | {risk} | {token} |

### Friction Points

1. **{screen}** — {issue}. Risk: {HIGH/MEDIUM}
   - Fix: {recommendation}

### Optimized Path (proposed)

{Optimized Screen 1} → {Screen 2} → ... → {Success}
**Steps:** {n-x} | **Time:** ~{t-y}s | **Improvement:** {%}

### Recommendations (ranked by impact)

1. {action} — saves {n} steps / {t}s — effort: {low/medium/high}
2. {action} — reduces drop-off at {screen} — effort: {low/medium/high}
3. {action} — improves feel alignment — effort: {low/medium/high}
```

**Output to:** `outputs/think/research/flow-{persona}-{jtbd-slug}.md`

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
