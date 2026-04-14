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

**Intent confirmation (always).** Before planning, restate scope in one line: "I'll simulate [type] for [target], parameters: [key params]. Proceed?" Skip only if Gary specifies exact parameters.

**Plan mode enforced.** Before executing, state: simulation type, parameters (assets, period, scenario), data sources. Wait for confirmation.

> **Simplified (v2):** `backtest` folded into `market` (use `market --backtest`). `dux` folded into `scenario` (Dux is the engine).

**Output pipeline:** MD → optionally HTML → optionally PDF. See Output Pipeline section.

---

## market [period]

**Purpose:** MiroFish market simulation. Regime detection, scenario generation, trade recommendations.

**Period parsing:** Default 24h. Accepts: `48h`, `3d`, `7d`/`1w`, `2w`, `1m`, month names.

### Execution — PEV (see `specs/pev-protocol.md`)

1. Spawn `pev-planner` with: task = market sim for `{period}`, task_class = exploration, pool hint:
   - `market-data-fetcher` — Hyperliquid: tickers, candles (BTC/ETH/SOL, 1h+4h), trades, book depth
   - `market-analyst` (macro contract) — S&P 500, DXY, VIX, Treasury yields, Fed expectations; APAC+US focus
   - `market-analyst` (crypto contract) — BTC dominance, total cap, protocol news, regulatory
   - `bull-case` — adversarial bull scenario with triggers + targets
   - `bear-case` — adversarial bear scenario with triggers + targets
   - Optional `episode-recaller` if similar period was run recently
2. Planner writes `roster.json`. Present. Approve.
3. Execute in parallel. Each agent sources every claim; WebSearch required for external data.
4. `pev-validator` cross-examines bull vs bear on factual claims (agree on facts, may disagree on interpretation). Any unsourced claim → ITERATE with `fact-checker`.
5. **CONVERGED** → `adjudicator` synthesizes: regime classification (bull/bear/neutral/transition + confidence 0-100%), 3 scenarios (bull/base/bear with probability/targets/timeline/catalysts), trade recommendations (entry/target/stop/size/rationale), portfolio risk summary.

**Output sections:** Regime Assessment (indicators table) → Key Events → Scenarios (3) → Risk Signals → Opportunities table → Portfolio Risk Summary

**Output to:** `outputs/briefings/market-sim-{YYYY-MM-DD}.md`

**Rules:** APAC + US focus. Zero hallucination — every claim has inline source. Dead links marked `[Link unavailable — cached quote]`.

---

## scenario <what-if>

**Purpose:** Forward-looking projection. "What if ETH drops 40%", "what if competitor raises $50M".

**Classify first:** Market scenario (Hyperliquid + WebSearch), Product scenario (specs/ + WebSearch), Business scenario (WebSearch).

### Execution — PEV (see `specs/pev-protocol.md`)

1. Spawn `pev-planner` with: task = scenario `{what-if}`, task_class = exploration, pool hint:
   - `market-analyst` (historical contract) — 3-5 precedents with dates, outcomes, what was different
   - `market-analyst` (current contract) — current state, positioning, sentiment (+ Hyperliquid MCP if market-class)
   - `first-principles` — second-order cascading effects: if X then Y then Z; Arx-specific impact
   - `contrarian` — pre-mortem on the what-if framing itself (is the question well-posed?)
   - Optional `spec-rag` if product/business scenario touches Arx specs
2. Planner writes `roster.json`. Present. Approve.
3. Execute in parallel. Every claim sourced.
4. `pev-validator` checks: factual disagreements across agents, unsourced claims, time-staleness. Disputed facts → ITERATE with `fact-checker`.
5. **CONVERGED** → `adjudicator` writes: Projected Outcomes (best 20th / expected 50th / worst 80th / black-swan 95th percentile + probabilities + Arx impact), Decision Matrix (actions × timeframe × likelihood), Key Assumptions that must hold.

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

1. **Load context — launch 2 agents in a single message:**

   ```
   Agent(
     prompt = "Load persona context for {persona} from specs/Arx_2-1*.
               Extract: goals, pain points, skill level, risk tolerance,
               preferred interaction patterns. Return structured profile.",
     subagent_type = "general-purpose", model = "haiku", run_in_background = true
   )

   Agent(
     prompt = "Load app context: screen inventory from specs/Arx_4-1-0*,
               journey maps from specs/Arx_3-3*, navigation graph from
               specs/Arx_4-1-1-* build cards. Return: screen list with
               entry/exit points, tap counts, data dependencies.",
     subagent_type = "general-purpose", model = "haiku", run_in_background = true
   )
   ```
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

---

## Simulation Convergence Loop (applies to market and scenario)

After producing simulation output, run a consistency check:

1. **Cross-verify:** Do bull-case and bear-case agents agree on facts (even if they disagree on interpretation)? Flag factual disagreements.
2. **Source check:** Every claim must have a source. Strip unsourced claims or research them.
3. **If factual disagreements found:** Spawn a fact-checker agent to resolve. Update the scenario with corrected facts.
4. **Stale data check:** If any data point is >24h old for market sims, flag as potentially stale.
5. **Max 2 verify-correct cycles** before presenting with confidence flags.

---

## Output Pipeline (shared)

All simulation outputs use the same pipeline:

1. **Write markdown** to appropriate output directory
2. **Convert to HTML** using Python markdown2 with Apple-minimalist CSS (SF Pro Text, #f5f5f7 code blocks, #007aff links, print-optimized)
3. **Generate PDF** via Playwright (`page.pdf()`, A4, 20mm margins)
4. **Version handling:** Append `-v2`, `-v3` if file for today exists

Python environment: `tools/sources-env/bin/python`
