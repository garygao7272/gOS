---
effort: max
description: "Simulate: market (MiroFish + backtest), scenario (what-if + Dux engine), flow (JTBD user journey)"
---

# Simulate — Forward-Looking Intelligence → outputs/

**Simulate runs projections, scenarios, and simulations. Connects to Dux simulation engine and MiroFish.**

**Scratchpad checkpoints.** Update `sessions/scratchpad.md`:

- **On entry:** Write current task, mode (`Simulate > {sub-command}`), parameters
- **After data fetch:** Log source counts and data freshness
- **After output:** Log file paths
- **After compaction:** Re-read `sessions/scratchpad.md`

Parse the first word of `$ARGUMENTS` to determine sub-command. If no sub-command given, ask: "What kind of simulation? market (MiroFish, includes backtest), scenario (what-if, powered by Dux), or flow (JTBD user journey)?"

> **Simplified (v2):** `backtest` folded into `market` (use `market --backtest`). `dux` folded into `scenario` (Dux is the engine).

**Output pipeline:** MD → optionally HTML → optionally PDF. See Output Pipeline section.

---

## market [period]

**Purpose:** MiroFish market simulation. Regime detection, scenario generation, trade recommendations.

**Team Mode:** Spawn `bull-case` + `bear-case` agents (sonnet) for adversarial scenario construction. Lead adjudicates: where do they agree (high confidence)? Where diverge (flag uncertainty)?

**Period parsing:** Default 24h. Accepts: `48h`, `3d`, `7d`/`1w`, `2w`, `1m`, month names.

**Process:**

1. **Data collection (parallel):**
   - Hyperliquid MCP: `get_tickers`, `get_candlestick` (BTC/ETH/SOL, 1h+4h), `get_trades`, `get_book`
   - Macro via WebSearch: S&P 500, DXY, VIX, Treasury yields, Fed expectations
   - Crypto via WebSearch: BTC dominance, total market cap, protocol news, regulatory
2. **Regime detection:** Analyze price action across timeframes, cross-reference with macro, classify bull/bear/neutral/transition with confidence (0-100%)
3. **Scenario generation:** Top 3 by probability (bull/base/bear). Each: trigger, probability, targets, timeline, catalysts
4. **Trade recommendations:** Entry/target/stop/size/timeframe/rationale per trade. Portfolio-level risk assessment.

**Output sections:** Regime Assessment (indicators table) → Key Events → Scenarios (3) → Risk Signals → Opportunities table → Portfolio Risk Summary

**Output to:** `outputs/briefings/market-sim-{YYYY-MM-DD}.md`

**Rules:** APAC + US focus. Zero hallucination — every claim has inline source. Dead links marked `[Link unavailable — cached quote]`.

---

## scenario <what-if>

**Purpose:** Forward-looking projection. "What if ETH drops 40%", "what if competitor raises $50M".

**Team decision:** If conflicting evidence → team with `historical-analyst`, `current-context`, `second-order` agents. Otherwise ad-hoc.

**Process:**

1. Parse what-if statement
2. **Classify:** Market scenario (use Hyperliquid + WebSearch), Product scenario (use specs/ + WebSearch), Business scenario (use WebSearch)
3. **Research (parallel):** Historical precedents, current context, second-order effects
4. **Project outcomes:** Best case (20th %ile), Expected (50th), Worst (80th), Black swan (95th) — each with probability and Arx impact
5. **Decision matrix:** Actions by timeframe (week/month/quarter) × likelihood
6. **Key assumptions** that must hold

**Output sections:** Current State → Historical Precedents → Projected Outcomes table → Second-Order Effects → Decision Matrix → Key Assumptions

**Output to:** `outputs/think/research/{slug}.md`

---

## backtest <strategy>

**Purpose:** Run a trading strategy against historical data.

**Process:**

1. Parse strategy description
2. **Check for Dux engine** at Dux project path. If available, prefer it. Otherwise simulate with Hyperliquid MCP data.
3. **Define parameters:** Entry/exit rules, position sizing, universe, timeframe
4. **Fetch historical data** via `get_candlestick` (up to 50 candles per request — note limitations)
5. **Run backtest:** Iterate chronologically, apply rules, track P&L/drawdowns
6. **Calculate metrics:** Total return, annualized, Sharpe, Sortino, max drawdown, win rate, profit factor, avg win/loss, total trades, avg hold time

**Output sections:** Strategy Definition → Performance Summary table → Equity Curve → Trade Log (top 5 winners/losers) → Risk Analysis → Data Limitations → Recommendations

**Output to:** `outputs/think/research/backtest-{slug}.md`

---

## dux <config>

**Purpose:** Full Dux simulation engine. Knowledge graph → branch futures (Graph-of-Thoughts) → LLM agents (Concordia-inspired) → best path (MCTS/Beam Search).

**Process:**

1. **Check Dux availability** at project path
2. **If available, run pipeline:** Seed → Ontology → Branching → Agents → Search → Evaluation → Orchestrator

   ```bash
   cd "/Users/garyg/Documents/Claude Working Folder/Dux" && PYTHONPATH=. python -m backend.main simulate --config "{config}" --output json
   ```

3. **If not available:** Explain setup requirements, suggest `/simulate scenario` as lightweight alternative
4. **Parse and present:** Best path (utility + probability + robustness), top 3 alternatives, critical decision points, key actor behaviors, recommended actions

**Output sections:** Seed Scenario → Knowledge Graph Summary → Branch Tree → Best Path (with decision points) → Alternative Paths table → Agent Behaviors → Recommended Actions

**Output to:** `outputs/think/research/dux-{slug}.md`

---

## flow <JTBD statement> [--persona <S1-S8>] [--metric <success-metric>]

**Purpose:** Simulate customer journey through the app for a JTBD. Measure efficiency, cognitive load, friction, and feel alignment.

**Process:**

1. **Load context (parallel):** Persona from Arx_2-1, screen inventory from Arx_4-1-0, journey maps from Arx_3-3, navigation graph from build cards
2. **Identify entry point:** Cold start, home screen, or deep link
3. **Trace optimal path.** For each screen, record from its build card:
   - Taps, cognitive decisions, data entry fields, information presented
   - Drop-off risk (LOW/MEDIUM/HIGH)
   - Feel token alignment with emotional need
4. **Score the flow:**
   - Total steps, time estimate (3s/scan + 5s/decision + 10s/entry)
   - Cognitive load (total decisions, target <5 for S7)
   - Drop-off count (HIGH-risk screens, target: 0)
   - Feel alignment (% of screens matching JTBD arc)
5. **Identify friction points:** Cognitive load >3, unnecessary data entry, info density exceeds skill, backtracking, feel mismatch
6. **Generate alternatives:** Skip, simplify, reorder, shortcut options per friction point
7. **Compare S2 vs S7** if both relevant — reveals where adaptive UX is needed

**Output sections:** Persona + Entry → Optimal Path (steps/time/decisions/dropoffs) → Screen-by-Screen table → Friction Points + Fixes → Optimized Path (with improvement %) → Ranked Recommendations

**Output to:** `outputs/think/research/flow-{persona}-{jtbd-slug}.md`

---

## Output Pipeline (shared)

All simulation outputs use the same pipeline:

1. **Write markdown** to appropriate output directory
2. **Convert to HTML** using Python markdown2 with Apple-minimalist CSS (SF Pro Text, #f5f5f7 code blocks, #007aff links, print-optimized)
3. **Generate PDF** via Playwright (`page.pdf()`, A4, 20mm margins)
4. **Version handling:** Append `-v2`, `-v3` if file for today exists

Python environment: `tools/sources-env/bin/python`
