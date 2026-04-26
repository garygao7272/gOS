---
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

**Intent confirmation** — see [rules/common/intent-confirmation.md](../rules/common/intent-confirmation.md). Template: "I'll simulate [type] for [target], parameters: [key params]. Proceed?"

**Output routing** — see [rules/common/output-routing.md](../rules/common/output-routing.md). Default: file (sim runs persist for replay/audit; short scenarios may go inline). Override: `--inline` / `--file` / `--file=<path>`. Print one-line routing decision before execution.

**Output discipline.** Every prose artifact this command produces (simulation narratives, scenario reports, flow walkthroughs under `outputs/`) must comply with [rules/common/output-discipline.md](../rules/common/output-discipline.md) the artifact discipline rules (positioning opener + outline, meta-content ≤5%, no main-body version markers, metadata consistent, prose-table weave, action anchor) and the voice-and-AI-smell rules (twelve anti-patterns, warn caps on em-dash density and padding-phrase frequency). Data tables, charts, and CSV/JSON outputs are exempt — artifact and voice rules apply only to the prose sections that frame them.

**Doc-type contract (doc-type ordering).** Every prose output declares frontmatter:

| Sub-command | Doc-type | First three H2s (doc-type ordering) |
|-------------|----------|------------------------------|
| `market` | `research-memo` | Regime Assessment (What/Finding) → Why it matters (Why) → How (scenarios + opportunities) |
| `scenario` | `research-memo` | Projected Outcomes (What/Finding) → Why it matters (precedents + second-order) → How (decision matrix + assumptions) |
| `flow` | `research-memo` | Optimal Path (What/Finding) → Why friction exists (drop-off causes) → How to fix (optimized path + recommendations) |

Frontmatter block (mandatory):

```yaml
---
doc-type: research-memo
audience: Gary Gao (Arx operator)
reader-output: <ranked trades / decision matrix / optimized flow>
generated: <ISO date>
---
```

The linter at [tests/hooks/artifact-discipline.bats](../tests/hooks/artifact-discipline.bats) verifies frontmatter + ordering on every output ≥100 lines.

**Plan mode enforced.** Before executing, state: simulation type, parameters (assets, period, scenario), data sources. Wait for confirmation.

> **Sub-commands:** `market` (includes `--backtest` mode), `scenario` (uses Dux engine if available), `flow`. See also the `backtest` and `dux` redirects below for direct invocation details.

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

**Output sections:** **Boundaries (IN/OUT/NEVER)** → Current State → Historical Precedents → Projected Outcomes table → Second-Order Effects → **Decision Matrix (with signal_class column)** → **Selection Rule (rule-form primitive)** → Key Assumptions.

**Boundaries section (mandatory first H2 after positioning):**

```
## Boundaries

**IN:** <what this scenario covers — the specific what-if, timeframe, assets/actors>
**OUT:** <adjacent what-ifs handled elsewhere — name the other scenario or `/think` output>
**NEVER:** <what this scenario refuses to answer, and why>
```

**Why boundaries are mandatory for scenarios.** A what-if without IN/OUT/NEVER drifts into adjacent what-ifs during the PEV round (bull-case broadens to bull-regime, scenario expands to strategy). Worst case: the reader applies a scenario answer to a question it wasn't designed for. Boundary contract prevents this at scenario birth.

**Decision Matrix schema (mandatory columns — per FP-OS design protocol + signal-calibration primitive):**

| Action | Agency | Timeframe | Likelihood | Signal Class | Notes |
|--------|--------|-----------|------------|--------------|-------|

- **Agency** tags each row as `real` (action is actually executable given current regulatory / platform / capital constraints) or `phantom` (labelled-as-choice but blocked upstream). Phantom rows MUST name the blocking constraint in Notes — otherwise the Decision Matrix surfaces actions the operator can't take. FP-OS design protocol Q3 ("real degrees of freedom vs phantom").
- **Signal Class** tags each row as `decisive` (one firing alone flips which action to take) or `suggestive` (accumulates with others). Without this column, the Decision Matrix is a menu without a selection mechanism.
- **Rows with Agency = phantom are excluded from the Selection Rule's maximand.** The rule operates on the real-agency subset; phantoms feed an optional Upstream Constraints section listing what would need to change.

**Selection Rule section (mandatory H2 — `## Selection Rule` or `## Rule`):** Name the rule-form per FP-OS rule-form primitive Layer 1 primitive 7, in the form **"maximise X subject to invariants Y"**. Example: *"Select the action that maximises expected return (variant) subject to no decisive downside signal firing (invariant) AND portfolio drawdown < 20% (invariant)."* Without the rule, the reader sees the matrix but not how to pick from it — which is the default failure mode of forecasting outputs.

**Output to:** `outputs/think/research/{slug}.md`

---

## backtest — folded into `market`

Invoke as `/simulate market --backtest <strategy>`. Backtest mode extends `market` by iterating historical candles (via `get_candlestick`, max 50 candles per call) and tracking P&L and drawdowns. Reported metrics: total return, annualized, Sharpe, Sortino, max drawdown, win rate, profit factor, avg win/loss, total trades, avg hold time. Output to `outputs/think/research/backtest-{slug}.md`. If Dux engine is available at the Dux project path, prefer it; otherwise simulate directly from Hyperliquid MCP data.

---

## dux — folded into `scenario`

The Dux simulation engine is the execution backend for `/simulate scenario`. Pipeline: Seed → Ontology → Branching → Agents → Search → Evaluation → Orchestrator. Direct invocation:

```bash
cd "$HOME/Documents/Documents - SG-LT674/Claude Working Folder/Dux" && PYTHONPATH=. python -m backend.main simulate --config "{config}" --output json
```

If Dux is unavailable, `/simulate scenario` runs in lightweight mode (no knowledge-graph branching). Present: best path (utility + probability + robustness), top 3 alternatives, critical decision points, recommended actions. Output to `outputs/think/research/dux-{slug}.md`.

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
