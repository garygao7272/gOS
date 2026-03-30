# Arx Mobile — Module: Trade

**Artifact ID:** Arx_4-1-1-3
**Title:** Mobile Trade — Screens TH, C5-NEW, C5, C6, C7, TH1
**Version:** 10.3 (v10.3: Trade Screen Redesign Implementation — iOS translucent glass material applied to all cards (`card-glass`, `card-glass-el`), 3D perspective carousel for perps Order Type (5 types: Market/Limit/Stop Market/Stop Limit/Trailing Stop with dynamic field expansion), inline Lucid hints (`.lucid-hint` ◆ diamond pattern) throughout parameters, dynamic fields with animated expand/collapse (`max-height`+`opacity` transition) for order-type-specific inputs, trailing stop checkbox expansion in TP/SL Exit Plan, iOS stepper (+/-) controls for price adjustments, spot Order Type iOS segment with dynamic Limit price field, "Advanced Trade Settings" rename from "Fine-tune parameters"/"More options", all label/copy reviewed for S2/S7 optimization. v10.2: Trade Parameter Redesign (ref: Arx_Trade_Parameter_Redesign_Proposal.md). Perps calculator enhanced — Regime Bar at top, "WHAT THE MARKET IS SAYING" header on Lucid Signals Card with cyan left border, Risk % quick-select pills [1%][2%][5%] with color-coded evidence, Kelly suggestion as separate Lucid evidence block, reframed "How much can you afford to lose?" question text, Safety Margin renamed to "Liquidation Distance" with dynamic computation and color emoji, Exit Plan enhanced with dual $/% display + "Clear TP"/"Clear SL" links with TP/SL removal friction dialog (`tradeTPSLRemoveFriction()`), trailing stop behavioral recommendation, "Set by default" badge, Review Summary shows position size in units + liquidation price. Spot calculator complete redesign — Regime Bar, "You own X SOL" ownership context, portfolio % quick pills [25%][50%][75%][100%], Lucid portfolio allocation evidence, Market Info with $ slippage, ownership education block, "More options" expandable replacing Advanced Options with Order Type toggle, Sell Target with % gain, Price Alert, DCA Setup with historical comparison. New functions: `detectTradeStyle()` (S2/S7 detection), `tradeTPSLRemoveFriction(type)` (TP/SL removal confirmation dialog). New state: `state.tradeStyle` ('active'/'copy'), `state.spotAmount`, `state.spotDir`. v10.1: Added Navigation Functions table. v10.0: TH portfolio-first hub, C5-NEW 5-step guided flow, Regime Gate + Cool-Down, Symbol Picker enhancements, multi-asset calculators. v9.0: Interactive chart, spot routing, Mini Order Book Ladder. v8.0: 5+5 Horizontal Ladder. v7.0: Multi-asset HIP-3, Cold Start System, chart fullscreen. All prior features preserved.)
**Last Updated:** 2026-03-15
**Status:** Active
**Prototype:** [arx-prototype.vercel.app](https://arx-prototype.vercel.app)
**References:** Master Architecture (`4-1-1-0`), Design System (`4-2`), Home & Markets (`4-1-1-2`), Lucid (`4-1-1-6`), Trade Parameter Redesign Proposal (`Arx_Trade_Parameter_Redesign_Proposal.md`)

---

## MODULE OVERVIEW

| Property             | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **JTBD**             | "Execute my decision — right now, with full market context." Pure execution: size, place, monitor, review — with live price data visible on every screen.                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| **Primary Segments** | S2 (Aspiring Traders) primary. S7 uses Trade via copy system (positions appear here).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| **Success Metrics**  | Order success rate, time-to-fill, position management frequency, trade review completion rate, avg risk per trade, liquidation avoidance rate, education card completion, trading rule adoption rate                                                                                                                                                                                                                                                                                                                                                                                                                       |
| **Entry Points**     | Tab bar "Trade" tap → TH (Trade Hub). **Contextual `openTrade(sym)`** → C5-NEW (direct to calculator, skips TH). Sources: C3 [Trade ▶], Home Quick Trade, Copy Dashboard [Trade Myself]. **Pre-filled `openTradeWithIntent(sym, dir, lev, source)`** → C5-NEW (pre-filled calculator). Sources: Radar Feed [Trade Myself], signal cards [Trade →]. Both functions handle same-tab detection — if already on Trade tab, they rebuild the calculator in place rather than calling `switchTab()` (which returns early on same tab). Deep link `arx://trade`, `arx://trade/{symbol}`. Quick Ticker Switch on any Trade screen. |
| **Exit Points**      | Position monitor → Home (portfolio review), Trade review → History, Close position → Fund Hub (withdrawal)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| **Screens**          | TH (Trade Hub — portfolio-first hub with positions, copies, spot holdings), C5-NEW (Calculator Entry — 5-step guided flow with inline Lucid signals + "Advanced Trade Settings" expandable for all advanced sections, 3D Order Type carousel with dynamic field expansion), C5 (Execution Monitor), C6 (Position Monitor), C7 (Trade Review), TH1 (Trade History)                                                                                                                                                                                                                                                          |

**The "Execute" Endpoint of "Explore → Execute":**
Trade is the convergence point where both exploration paths (Markets = ticker-first, Radar = people-first) resolve into action. Markets and Radar explore WHAT/WHO/WHY. Trade executes HOW MUCH/WHEN/NOW. This is a deliberate architectural boundary — Trade never tries to convince you what to trade. It assumes you've arrived here with conviction from either Markets or Radar (or both). Trade sits at tab position 3, adjacent to Radar (position 2), making the Radar → Trade handoff a single swipe right. Markets (position 4) is one more tab to the right.

**Live Market Data on Every Trade Screen (NEW):**
Users need live market context while structuring and executing trades — they should NEVER have to tab back to Markets to check current price, order book, or key levels. Every Trade screen includes a "Live Market Strip" adapted to context:

- **TH (Trade Hub)**: Portfolio-level equity sparkline (30-point with gradient) in Portfolio Summary Card. No single-ticker pricing — hub is symbol-independent, showing aggregated portfolio data.
- **C5-NEW (Calculator Entry) — MOST CRITICAL**: Full interactive pricing chart PLUS Mini Order Book Ladder (5 asks + 5 bids with depth bars, spread center line, tap-to-prefill limit price, real-time WebSocket updates). Positioned above inputs for perps; beside order panel for spot. Inline Lucid Signals Card in Step 1 shows Smart Money direction, leader positions, regime, funding context. See confirmed v9.0 ladder spec in C5-NEW section below.
- **C5 (Execution Monitor)**: Mini candlestick chart showing real-time fills plotted against price movement (entry line, fill dots, current price)
- **C6 (Position Monitor)**: Larger chart with entry/current/TP/SL overlay lines plus mini order book showing walls near current price

> **Simplified Language Glossary:** See `Arx_4-1-1-0_Mobile_Master_Architecture.md` §Shared Simplified Language Glossary. All screen specs MUST use these terms.

**TradeIntent Object:**
Every entry into Trade carries a TradeIntent (may be partially filled), with signal references for Lucid annotations:

```
TradeIntent {
  symbol: string,              // "SOL-PERP" or "BTC/USDT"
  direction: "long"|"short"|null, // null = user chooses
  source: string,              // "markets_c3", "radar_signal", "radar_ai_strategy", "lucid", "trade_hub"
  instrument_type: "perp"|"spot", // Determines which calculator variant
  regime_context: object|null, // { state, strength, change_prob_4h }
  funding_rate: number|null,
  funding_percentile: number|null, // For Lucid annotation: "Funding in top 20% (likely to reverse soon)"
  wallet_consensus: object|null, // { direction, count, strength }
  leader_positions: array|null,  // Top 5 leaders' positions for this asset: { wallet, direction, leverage, size }
  smart_money_net_position: number|null, // Smart Money aggregate direction/strength
  suggested_tp: number|null,   // Lucid-suggested take profit with reason
  suggested_sl: number|null,   // Lucid-suggested stop loss with reason
  suggested_size: number|null, // From Radar AI strategy
  entry_price: number|null,    // For limit orders from order book tap
  oi_regime_alignment: boolean|null, // Open interest indicates trend/chop alignment
  session_state: string|null,        // "pre_market", "open", "post_market", "closed"
  market_hours_warning: boolean,     // True if market closed — affects spread/execution
  // Cold Start fields (v7.0) — populated when entering from Radar copy/follow context
  leader_win_rate: number|null,      // Leader's historical win rate (e.g., 0.63) — powers Kelly cold start
  leader_payoff_ratio: number|null,  // Leader's avg win / avg loss (e.g., 1.8) — powers Kelly cold start
  leader_trade_count: number|null,   // Leader's verified trade count — confidence weighting
  leader_regime_win_rates: object|null // { trending: 0.71, ranging: 0.54, ... } — regime-aware Kelly
}
```

**Calculator Variants (C5-NEW):**
The Trade calculator (C5-NEW) has TWO INSTRUMENT MODES with a unified 5-step guided flow (perps) or simplified flow (spot):

**MODE 1: PERPS (Leveraged Perpetual Contracts) — 5-Step Guided Flow (v10.2 — Trade Parameter Redesign)**

- **Regime Bar** — Persistent bar at top showing current market regime with confidence %, color-coded, bell icon for alerts
- **Step 1: Direction** — [LONG] [SHORT] toggle + **"WHAT THE MARKET IS SAYING"** Lucid Signals Card (cyan left border, Smart Money %, leader positions, regime, funding, signal strength)
- **Step 2: Risk Amount** — "How much can you afford to lose?" (reframed from "How much to risk?") with **Risk % quick-select pills [1%] [2%] [5%]** (auto-compute from equity, color-coded: green <3%, yellow 3-5%, red >5%) + Kelly suggestion as separate Lucid evidence block below
- **Step 3: Liquidation Distance** — (renamed from "Safety Margin") dynamically computed from leverage with color emoji (green/yellow/red)
- **Step 4: Set Your Exit Plan** — Enhanced: TP/SL with iOS stepper (+/-) controls shown in both % AND $ amounts (+6.1% (+$153), -6.1% (-$500)), "Clear TP"/"Clear SL" links with **TP/SL removal friction dialog** (behavioral speed bump), **trailing stop checkbox with dynamic field expansion** (checking reveals Trail Distance % stepper with Lucid hint, unchecking collapses with `max-height`+`opacity` animation), 2:1 reward:risk badge, **"Set by default" badge** (was "Recommended"), social proof, ATR defaults, R:R inline, Lucid hit rate
- **Step 5: Review Summary** — Enhanced: shows Position Size in units (e.g., "3.34 SOL ($625)") + Liquidation price explicitly, plus Leverage, Holding cost, Order type, Margin
- **Execute CTA** — "Open LONG/SHORT — $X risk" + "Review in test mode" link
- **"Ask Lucid Before Trading"** — Full-width button above Execute

**"Advanced Trade Settings"** — Single expandable `<details>` element (collapsed by default, renamed from "Fine-tune parameters" in v10.3) containing ALL advanced sections as nested `<details>`:

1. [Adjust Leverage] — slider with color zones, holding cost impact, Lucid annotation
2. [Adjust Safety Limits] — TP/SL fine-tuning (duplicate of Step 4 for precision)
3. [Position Sizing Guide] — Smart sizing (Kelly) with Cold Start awareness (3-phase display)
4. [Holding Cost Details] — daily/7-day/30-day breakdown
5. [Risk Isolation] — Cross/Isolated iOS segment toggle with Lucid annotation
6. [Order Type] — **3D Perspective Carousel** (5 types: Market / Limit / Stop Market / Stop Limit / Trailing Stop) with **dynamic field expansion**:
   - **Market**: No additional fields (clean, zero-friction instant execution)
   - **Limit**: Expands Limit Price input with iOS stepper (+/-), "-0.5% below market" badge, Lucid hint
   - **Stop Market**: Expands Trigger Price input with iOS stepper (+/-)
   - **Stop Limit**: Expands TWO fields — Stop Price + Limit Price, each with iOS stepper
   - **Trailing Stop**: Expands Trail Distance with %/USD iOS segment toggle, slider (1-10%), Lucid hint
   - All field transitions use `max-height` + `opacity` animation (350ms cubic-bezier) for smooth expand/collapse
   - Carousel uses CSS `perspective(600px)` + `rotateY` + `translateZ` + `scale` transforms; swipe-enabled via touch events
7. [Risk Scenarios] — price move / P&L / liquidation distance grid

System auto-computes everything using smart defaults:

- Liquidation distance: auto-set at 1.5x ATR below entry, dynamically computed from leverage
- Leverage: defaults to user's preferred (or 3x for new users)
- Holding cost (funding fee): auto-calculated, shown as: "Your cost to hold this position: ~$3.20/day"
- Reward-to-risk ratio: auto-set at 2:1 take-profit to stop-loss
- Risk isolation (margin mode): user's default preference

**Glass Material System (v10.3):**
All card containers on the trade screen use iOS-inspired translucent glass styling for depth and visual hierarchy:

- **`card-glass`** — Primary card container: `backdrop-filter: blur(20px) saturate(180%)`, border `1px solid rgba(255,255,255,0.08)`, used for all parameter cards (Risk, Leverage, Order Type, Exit Plan, Market Info, Advanced sections)
- **`card-glass-el`** — Inner element glass: `backdrop-filter: blur(16px)`, lighter tint, used for input containers, stepper groups, price displays within cards
- **Lucid inline hints (`.lucid-hint`)** — Glass-backed contextual intelligence blocks with ◆ diamond marker, placed after each parameter for contextual guidance (e.g., "Your top traders average 2.8x on SOL")
- **Consistent pattern:** Every parameter card follows: Label → Input (with stepper if adjustable) → Lucid hint

**MODE 2: SPOT (Buy & Hold) — v10.2 Complete Redesign (ref: Arx_Trade_Parameter_Redesign_Proposal.md)**

- **Regime Bar** — Same as perps, persistent at top
- **Ownership context** — "You own X SOL" shown below ticker
- **"View in Markets ->"** link on chart
- **BUY/SELL toggle** — SELL disabled if no holdings
- **Amount** — "Amount to invest" (BUY) / "Amount to sell" (SELL) with **Portfolio % quick pills [25%] [50%] [75%] [100%]** inline beside amount display, glass card styling
- **Lucid evidence** — Portfolio allocation % with single-asset guideline
- **Market Info card** — Best price, est. slippage (in $), ownership info
- **Ownership education** Lucid block — "No leverage. No liquidation risk. No holding costs."
- **"Advanced Trade Settings" expandable** (renamed from "More options" in v10.3):
  1. Order Type — **iOS segment control** (Market/Limit) with **dynamic Limit price field expansion**: selecting Limit reveals "Buy at price" input with iOS stepper (+/-), "$X (-2% below market)" badge, Lucid hint explaining limit behavior; selecting Market collapses the field with smooth animation. `selectSpotOrderType(idx)` function handles segment indicator animation, field expansion, and hint text update.
  2. Sell Target — `card-glass` container, auto-sell at price with % gain display, Lucid hint with previous high context
  3. Price Alert — `card-glass` container, notification-only (not an order), price input
  4. DCA Setup — `card-glass` container, Daily/Weekly/Monthly frequency pills, amount per interval, historical DCA comparison evidence

### Navigation Functions (Prototype Implementation)

| Function                                     | Behavior                                                                                                                                                                                                                                                                                                                                         | Used By                                                                                        |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------- |
| `openTrade(sym)`                             | Sets `state.tradeSymbol = sym`, `state.tradeMode = 'calc'`, clears `dataset.built`, then: if already on Trade tab → calls `buildTrade()` directly; else → calls `switchTab('trade')`. This same-tab detection is critical because `switchTab()` returns early when `tab === state.currentTab`.                                                   | Markets C3 [Trade ▶], Home Quick Trade, Copy Dashboard [Trade Myself], Trade Hub position taps |
| `openTradeWithIntent(sym, dir, lev, source)` | Sets symbol, direction (`state.tradeDir`), leverage (`state.tradeLev`), and intent metadata (`state.tradeIntent`), then follows same routing as `openTrade()`. Shows toast: "Pre-filled from signal" or "Pre-filled from @{leader}".                                                                                                             | Radar Feed [Trade Myself], Radar signal cards [Trade →], D2 Leader Detail [Trade Myself]       |
| `buildTrade()`                               | Reads `state.tradeMode` — if `'hub'` renders Trade Hub (TH), if `'calc'` renders Calculator (C5-NEW). Calls `staggerEntrance()` after rendering to animate `.anim-item` elements.                                                                                                                                                                | Called by tab switch, openTrade, openTradeWithIntent                                           |
| `buildTradeHub(s, sym, inst)`                | Renders portfolio-first hub. Must call `staggerEntrance(s, '.anim-item', 30)` after innerHTML assignment.                                                                                                                                                                                                                                        | Called by buildTrade when tradeMode='hub'                                                      |
| `detectTradeStyle()`                         | Reads `journeyState` to detect S2 (active trader) or S7 (copy follower). Sets `state.tradeStyle = 'active'` or `'copy'`. Determines which signal adaptation and UI emphasis to use.                                                                                                                                                              | Called on Trade tab entry, affects signal display in C5-NEW                                    |
| `tradeTPSLRemoveFriction(type)`              | Confirmation dialog when user taps "Clear TP" or "Clear SL". Shows risk warning ("Removing your [TP/SL] means..."), [Keep] as primary button + [Remove Anyway] as secondary. Behavioral speed bump requiring conscious acknowledgment before TP/SL removal.                                                                                      | Called from C5-NEW Step 4 Exit Plan "Clear TP"/"Clear SL" links                                |
| `selectOrderType(el, idx)`                   | Carousel handler: rotates 3D carousel to selected order type, updates hint text, calls `renderOrderTypeFields(idx)` to expand/collapse dynamic fields. CSS transforms: `translateX`, `translateZ`, `rotateY`, `scale` per item offset from active.                                                                                               | C5-NEW Order Type carousel item taps                                                           |
| `renderOrderTypeFields(idx)`                 | Renders order-type-specific input fields (Limit Price, Trigger Price, etc.) into `#orderTypeFields` container with expand/collapse animation (`max-height` + `opacity` transition 350ms). Each field uses `card-glass-el` styling with iOS stepper and Lucid hint. idx: 0=Market (empty), 1=Limit, 2=Stop Market, 3=Stop Limit, 4=Trailing Stop. | Called by `selectOrderType()`                                                                  |
| `adjustField(fieldId, dir)`                  | Adjusts numeric stepper field by +/- step. Trail distance: ±0.5 (range 0.5–10%). Price fields: ±0.1% of current value. Updates the `#fieldIdVal` span text.                                                                                                                                                                                      | iOS stepper (+/-) buttons in dynamic fields                                                    |
| `toggleTrailingStopField()`                  | Expands/collapses Trail Distance field in Exit Plan when trailing stop checkbox is toggled. Uses `max-height` + `opacity` + `marginBottom` animation.                                                                                                                                                                                            | Trailing stop checkbox in Step 4 Exit Plan                                                     |
| `selectSpotOrderType(idx)`                   | Spot order type handler: moves iOS segment indicator, updates label text, expands/collapses dynamic Limit price field in `#spotOrderFields` container, updates Lucid hint text per selection (0=Market, 1=Limit).                                                                                                                                | Spot Order Type iOS segment buttons                                                            |
| `initCarousel3D()`                           | Initializes the 3D perspective carousel: finds all `.carousel-3d-item` elements, applies CSS transforms based on each item's offset from active index, adds touch event handlers for swipe navigation. Called via `setTimeout(initCarousel3D, 300)` after `buildTrade()` renders DOM.                                                            | Called at end of `buildTrade()` for perps mode                                                 |

**Critical: staggerEntrance requirement** — All `.anim-item` elements start at `opacity: 0; transform: translateY(16px)` for entrance animation. Every code path that renders Trade content MUST call `staggerEntrance()` after innerHTML assignment, or the screen appears blank.

---

## SCREEN INVENTORY

| ID     | Screen            | Purpose                                                                                                                                                                                                                                                                                        | Priority | S2/S7      |
| ------ | ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------- |
| TH     | Trade Hub         | Portfolio-first landing page: equity overview with sparkline, margin bar, Quick Actions ([+ New Trade] + [Ask Lucid]), My Copies section (S7), open positions with safety dots, spot holdings                                                                                                  | P0       | Both       |
| C5-NEW | Calculator Entry  | 5-step guided flow (Direction → Risk → Safety → Exit Plan → Summary) with inline Lucid signals, TP/SL encouragement with social proof, "Advanced Trade Settings" expandable for all advanced sections, 3D Order Type carousel with dynamic field expansion, Regime Gate + Cool-Down protection | P0       | S2 primary |
| C5     | Execution Monitor | Real-time order fill tracking with fill %, candlestick chart, celebrate on complete fill                                                                                                                                                                                                       | P0       | Both       |
| C6     | Position Monitor  | Live position detail: liquidation distance (primary), safety gauge, regime, wallet activity, quick actions, Lucid annotations                                                                                                                                                                  | P0       | Both       |
| C7     | Trade Review      | Post-trade analysis: Kelly accuracy, regime alignment, wallet comparison, reflection, Lucid insights, points reward                                                                                                                                                                            | P1       | S2         |
| TH1    | Trade History     | Historical trades with filters, cumulative P&L chart, summary stats, expandable detail rows, Lucid performance annotations                                                                                                                                                                     | P1       | Both       |

---

## SCREEN SPECIFICATIONS

<!-- TRACE: US-S7-ONBD-01 | Pain: P1 (portfolio overview, copy management) | Job: JTBD-S7-01 -->
<!-- TRACE: US-S2-FVAL-01 | Pain: E3 (saved trade counter badge) | Job: JTBD-S2-01 -->

### Screen: TH (Trade Hub) — v4.0

**Purpose:** Portfolio-first entry point for Trade module. Symbol-independent hub showing aggregated portfolio data, all open positions, copy positions (S7), and spot holdings. Quick Actions for new trades and Lucid consultation. No single-ticker header — computes totals from `MOCK.positions` and `MOCK.spotHoldings` directly.

**Layout:**

```
┌────────────────────────────────────────┐
│  Arx        ☰  [Search] [User avatar]  │  Global Header
├────────────────────────────────────────┤
│ ◀ Trending ▶  [🔔 notification count]  │  Regime Bar (always pinned)
├────────────────────────────────────────┤
│  Portfolio Overview          X positions│
├────────────────────────────────────────┤
│  Total Equity        Unrealized P&L    │
│  $5,234.00           +$259.75          │
│                      +4.8%             │
│  ┌─ Equity Mini-Sparkline ──────────┐  │
│  │  30-point sparkline with gradient │  │  Portfolio Summary Card
│  └──────────────────────────────────┘  │
│  Margin Used: $1,832 (35%)  Avail: $3,402│
│  ████████████░░░░░░░░░░░░░░░░░░░░░░│  │  Margin utilization bar
│  Positions: $4,562    Spot: $1,234     │  │  Breakdown by type
├────────────────────────────────────────┤
│  [+ New Trade]        [◆ Ask Lucid]    │  Quick Actions row
├────────────────────────────────────────┤
│  My Copies (2 active)  Browse traders ›│  S7 section (if copies exist)
│  ┌─ SOL LONG 5x ─ Copied from @whale ─┐│
│  │  +$93.75 (+5.0%)  Leader still in   ││  Copy position card
│  │  🟢 Safety: 33%   ◆ 4/5 aligned    ││  Safety dot + signal strength
│  └──────────────────────────────────────┘│
│  ┌─ BTC LONG 2x ─ Copied from @alpha ─┐│
│  │  +$234.00 (+9.8%)  Leader exited    ││
│  │  🟢 Safety: 45%   ◆ Leader closed  ││  Leader status indicator
│  └──────────────────────────────────────┘│
├────────────────────────────────────────┤
│  Open Positions (3)                    │  All positions section
│                                        │
│  [SOL LONG 5x]                        │  Position Card
│  +$93.75 (+5.0%)   🟢 Safety: 33%     │  Safety margin = primary metric
│  [Tap to open → C6]                    │  Color dot: 🟢>20% 🟡10-20% 🔴<10%
│                                        │
│  [ETH SHORT 3x]                       │
│  -$33.75 (-2.5%)   🟡 Safety: 15%     │
│                                        │
│  [BTC LONG 10x]                       │
│  +$12.50 (+0.8%)   🔴 Safety: 8%      │
│                                        │
├────────────────────────────────────────┤
│  Spot Holdings (2)                     │  Spot section
│                                        │
│  [SOL]  2.5 SOL  $467.50              │
│  +$18.75 (+4.2%)                      │  No liquidation risk badge
│                                        │
│  [BTC]  0.015 BTC  $1,068.00          │
│  +$34.00 (+3.3%)                      │
│                                        │
└────────────────────────────────────────┘
```

**Portfolio Summary Card:**

- **Total Equity:** Sum of all position margins + spot holdings + available balance
- **Unrealized P&L:** Aggregated from all open positions and spot holdings, with percentage and absolute value
- **Equity Mini-Sparkline:** 30-point sparkline with gradient fill showing portfolio equity over last 24h. Renders inline within the card (not tappable — informational only)
- **Margin Bar:** Horizontal progress bar showing margin utilization. Segments: used (filled) vs available (empty). Percentage label inline. Color shifts: green (<50%), yellow (50-80%), red (>80%)
- **Breakdown:** "Positions: $X" (leveraged) + "Spot: $Y" (holdings) shown below margin bar

**Quick Actions Row:**

- **[+ New Trade]** — Opens Symbol Picker overlay (see Symbol Picker section below). On symbol selection, navigates to C5-NEW with selected symbol.
- **[◆ Ask Lucid]** — Opens Lucid chat (G1) with trade context pre-loaded. User can ask "What should I trade?" or "How are my positions?"

**My Copies Section (S7 users only):**

- Visible only when user has active copy positions (`MOCK.positions.filter(p => p.copiedFrom)`)
- **Header:** "My Copies (N active)" + "Browse traders ›" link to Radar
- **Copy Position Cards:** Each card shows:
  - Symbol + direction + leverage + copied leader attribution ("Copied from @whale")
  - P&L (absolute + percentage)
  - Safety margin with color dot (🟢/🟡/🔴)
  - Leader status: "Leader still in" / "Leader exited" / "Leader added"
  - Signal strength badge if available
- Tap card → navigates to C6 (Position Monitor) with copy attribution visible

**Position Cards (v4.0 — safety margin as primary metric):**

- Each position card shows: symbol, direction, leverage, P&L, safety margin percentage with color dot
- Safety margin is the PRIMARY metric (largest, most visible):
  - 🟢 Green dot: >20% safety margin (healthy distance)
  - 🟡 Yellow dot: 10-20% (warning — consider adding margin)
  - 🔴 Red dot: <10% (danger — add margin or close soon)
- Tap card → navigates to C6 (Position Monitor)
- Swipe left position card → quick close menu: [Close 50%] [Close All]

**Spot Holdings Section:**

- Shows all spot token holdings from `MOCK.spotHoldings`
- Each row: token symbol, quantity, USD value, P&L
- No liquidation risk — no safety margin display (spot is 1x, no leverage)
- Tap row → navigates to spot trade screen with sell option

**Tab Navigation:**

- Remains visible at bottom throughout all Trade screens

---

<!-- TRACE: US-S2-ONBD-01 | Pain: P1/E1/P3 (first real-money trade, execution quality) | Job: JTBD-S2-01 -->
<!-- TRACE: US-S2-FVAL-01 | Pain: E2/E3 (regime caution active, "trade anyway" path) | Job: JTBD-S2-01 -->

### Screen: C5-NEW (Calculator Entry) — v6.0 (updated v10.2 — Trade Parameter Redesign)

**Purpose:** MAJOR REDESIGN. Core trading flow with single-column 5-step guided layout. **v10.2 enhancements (ref: Arx_Trade_Parameter_Redesign_Proposal.md):** Regime Bar added at top of calculator showing current regime with confidence %. Lucid Signals Card renamed to **"WHAT THE MARKET IS SAYING"** with cyan left border. Risk % quick-select pills added. Kelly suggestion shown as separate evidence block. Question reframed to "How much can you afford to lose?". Safety Margin renamed to **"Liquidation Distance"** with dynamic computation from leverage and color emoji. Exit Plan enhanced with dual $/% display, "Clear TP"/"Clear SL" links with friction dialog (`tradeTPSLRemoveFriction()`), behavioral trailing stop recommendation, "Set by default" badge. Review Summary now shows position size in units and liquidation price explicitly. New state: `state.tradeStyle` set by `detectTradeStyle()` for S2/S7 adaptation. TP/SL promoted to main flow (Step 4). Basic/Advanced toggle REMOVED. Interactive pricing chart and Mini Order Book Ladder remain from v9.0.

**PERPS 5-STEP GUIDED FLOW LAYOUT (Redesigned for v6.0):**

The new C5-NEW calculator uses a single-column guided flow with inline Lucid intelligence at every step:

```
┌────────────────────────────────────────┐
│ ◀ Calculator     [PERPS][SPOT]  [⚙]   │ Instrument selector
├────────────────────────────────────────┤
│ ◀ Trending (78%) ▶  [🔔]              │ Regime Bar — persistent,
│                                        │ color-coded, confidence %,
│                                        │ bell icon for regime alerts
├────────────────────────────────────────┤
│ [SOL-PERP ▾]  $187.20  +4.2%          │ Symbol + price
├────────────────────────────────────────┤
│                                        │
│ ── STEP 1: DIRECTION ──────────────── │
│                                        │
│ [■ LONG]  [SHORT]                     │ Direction toggle
│                                        │
│ ┌─ ◆ WHAT THE MARKET IS SAYING ──────┐│ Cyan left border
│ │ Smart Money: 72% NET LONG          ││ (was "LUCID SIGNALS")
│ │ Your Leaders: 4 are LONG           ││
│ │ Regime: Trending                   ││
│ │ Funding: Longs pay ~$3.20/day      ││
│ │ Signal Strength: 4/5 alignment     ││
│ └────────────────────────────────────┘│
│                                        │
│ ── STEP 2: RISK AMOUNT ────────────── │
│                                        │
│ How much can you afford to lose?      │ Reframed question
│ [$375]          [1%] [2%] [5%]       │ Risk % quick-select pills
│                                        │ Tap pill → auto-compute
│ ◆ 7.2% of equity                     │ from equity. Color-coded:
│   🟢 <3%  🟡 3-5%  🔴 >5%           │ green/yellow/red evidence
│                                        │
│ ┌─ ◆ Kelly Suggestion ───────────────┐│ Separate Lucid evidence
│ │ Smart sizing suggests: $300 (5.9%) ││ block below risk input
│ │ Based on 64% WR, 1.8:1 payoff     ││
│ └────────────────────────────────────┘│
│                                        │
│ ── STEP 3: LIQUIDATION DISTANCE ──── │ Renamed from "SAFETY MARGIN"
│                                        │
│ Liquidation distance: 33% 🟢         │ Dynamic from leverage
│ ████████████████████░░░░░░░░░░░░     │ Color emoji: 🟢/🟡/🔴
│ (33% price drop before auto-close)   │
│                                        │
│ ── STEP 4: SET YOUR EXIT PLAN ─────── │
│                                        │
│ ┌─ 🟢│ Set by default                ─┐│ "Set by default" badge
│ │                                      ││ (was "Recommended")
│ │ 83% of profitable traders use TP/SL ││ Social proof
│ │                                      ││
│ │ Take Profit        Stop Loss        ││ Two-column layout
│ │ [$198.50]          [$175.90]        ││ ATR-based smart defaults
│ │ +6.1% (+$153)      -6.1% (-$500)   ││ Dual % AND $ display
│ │ Clear TP ↗         Clear SL ↗      ││ Links trigger friction
│ │                                      ││ dialog (tradeTPSLRemove
│ │ R:R: 2:1 — For every $1 risk,      ││ Friction())
│ │ $2 target                           ││
│ │                                      ││
│ │ 2:1 reward:risk  ☑ Trailing stop   ││ Badge + checkbox
│ │ ┌─ Trail distance ───────────────┐ ││ Dynamic expand on check
│ │ │ [-] [+]  2.0%                  │ ││ iOS stepper
│ │ │ ◆ Stop follows price up by 2%. │ ││ Lucid hint
│ │ │   If price reverses, keep gains│ ││
│ │ └────────────────────────────────┘ ││ Collapses on uncheck
│ │ ◆ you tend to exit winners early    ││ Behavioral recommendation
│ │   (+3%)                             ││
│ │                                      ││
│ │ ◆ Your TP hit rate at 5-7%: 68%    ││ Lucid annotation
│ └──────────────────────────────────────┘│
│                                        │
│ ── STEP 5: REVIEW SUMMARY ─────────── │ Enhanced (was "Quick Summary")
│                                        │
│ ┌────────────────────────────────────┐│
│ │ Position Size: 3.34 SOL ($625)     ││ Units + $ amount
│ │ Liquidation price: $124.80         ││ Explicit liquidation price
│ │ Leverage: 3x (your preference)     ││
│ │ Holding cost: ~$3.20/day           ││
│ │ Order type: Market                  ││
│ │ Margin: Isolated                    ││
│ └────────────────────────────────────┘│
│                                        │
│ ▸ Advanced Trade Settings ▾          │ Single <details> (collapsed)
│   (contains 7 nested advanced sections)│ Renamed from "Fine-tune parameters"
│                                        │
│ [◆ Ask Lucid Before Trading]          │ Full-width Lucid button
│                                        │
│ [← Open LONG — $375 risk →]          │ Execute CTA
│ Review in test mode →                 │ Link below CTA
│                                        │
└────────────────────────────────────────┘
```

**"Advanced Trade Settings" Expandable (collapsed by default, renamed from "Fine-tune parameters" in v10.3):**

A single `<details>` element containing ALL advanced sections as nested `<details>`:

```
▸ Advanced Trade Settings ▾
│
├─ ▸ 1. Adjust Leverage
│   Leverage: [3x] ◀──────▶ 1x - 20x
│   🟢 3x (your safe range: 2-5x)
│   Holding cost at 3x: ~$3.20/day
│   (Color gradient: 🟢1-5x 🟡5-10x 🔴10x+)
│   ◆ Your leaders avg 2.8x on SOL
│   ◆ Your best leverage hist: 3-5x
│
├─ ▸ 2. Adjust Safety Limits
│   Take-Profit: [$198.50] (+6.1%) ◆ resistance
│   Stop-Loss:   [$175.90] (-6.1%) ◆ support
│   Reward-to-Risk: 2:1 (every $1 risk = $2 gain)
│   ☐ Trailing stop (2%) ◆ recommended
│   (Duplicate of Step 4 for precision adjustments)
│
├─ ▸ 3. Position Sizing Guide
│   (Cold Start aware — 3-phase display)
│   You're at $375 (7.2% account)
│   Smart sizing suggests: $300 (5.9%)
│   │░░░░░░░░█░░░│ (Kelly mark)
│   Status: ✅ Within good range
│
├─ ▸ 4. Holding Cost Details
│   Daily: ~$3.98
│   7-day: $27.75 (7.4% of your risk)
│   30-day: $119.25 (31.8% of your risk)
│   ⚠ Annualized: 284% (very high)
│   ◆ Last 2 times funding was this high:
│     Price dropped 12% within 48h both times
│
├─ ▸ 5. Risk Isolation
│   [■ Isolated]  [Cross]
│   Isolated: Risk limited to this trade only
│   Cross: Shared risk across all trades
│   ◆ Recommended: Isolated for single trades
│
├─ ▸ 6. Order Type (3D Carousel)
│   ◀ Market | [LIMIT] | Stop Market ▶   3D perspective carousel
│   ┌──────────────────────────────────┐  Dynamic field expansion:
│   │ Limit Price    [-] [+]  $186.26 │  iOS stepper for price
│   │              -0.5% below market  │  Contextual badge
│   │ ◆ Set below market to buy       │  Lucid hint
│   │   cheaper. Order waits.          │
│   └──────────────────────────────────┘
│   (Market=no fields, Limit=price, Stop Mkt=trigger,
│    Stop Limit=trigger+limit, Trailing Stop=trail %)
│
└─ ▸ 7. Risk Scenarios
    Price Move → Your P&L → Liq. Distance
    $187.20 (now) → — → 33% 🟢
    $192.00 (+2.6%) → +$210 → 31% 🟢
    $198.50 (TP) → +$505.50 → 29% 🟢
    $175.90 (SL) → -$375 → 25% 🟢
    $165.00 (-11.8%) → -$505.50 → 12% 🟡
```

**INLINE EDUCATION CARDS (Contextual — unchanged from v5.0):**

Appear inline for first-time experiences:

- **[When first seeing TP/SL]** — "WHAT IS A SAFETY LIMIT?" card explaining TP/SL with pro pattern stats
- **[When leverage exceeds 10x]** — "WHY WE'RE WARNING YOU:" with historical volatility data and personal win rate at high leverage
- **[When Kelly sizing exceeds]** — "WHAT IS SMART SIZING?" with Kelly explanation and behavioral pattern warning
- **[First time seeing holding costs]** — "WHAT IS HOLDING COST?" with funding fee explanation and APR warning

**SPOT CALCULATOR LAYOUT (v10.2 — Complete Redesign, ref: Arx_Trade_Parameter_Redesign_Proposal.md):**

```
┌────────────────────────────────────────┐
│ ◀ Calculator     [PERPS][SPOT]  [⚙]   │ SPOT toggle active (highlighted)
├────────────────────────────────────────┤
│ ◀ Consolidating (65%) ▶  [🔔]          │ Regime Bar (same as perps)
├────────────────────────────────────────┤
│ [SOL-SPOT ▾]  $187.20  +2.3%          │ Symbol picker dropdown
│ You own 2.5 SOL                       │ Ownership context (v10.2)
├────────────────────────────────────────┤
│ ┌──────────────────────────────────┐   │
│ │  Interactive Chart (140px)        │   │ spotChartCanvas_SOL-SPOT
│ │  OHLC candles + MA7/MA20         │   │
│ │  Volume histogram (15% height)   │   │
│ │              [View in Markets →]  │   │ Link pill (v10.2)
│ └──────────────────────────────────┘   │
├────────────────────────────────────────┤
│ [■ BUY]  [SELL (disabled)]             │ SELL disabled if no holdings
├────────────────────────────────────────┤
│ How much to spend?                     │
│ [$500]                    = 2.671 SOL  │ Default $500
│ [25%] [50%] [75%] [100%]             │ Portfolio % quick pills
│                                        │ (v10.2 — % of available bal.)
├────────────────────────────────────────┤
│ ◆ SOL: 12% of portfolio               │ Lucid evidence (v10.2)
│   Guideline: <20% in single asset     │ Portfolio allocation %
├────────────────────────────────────────┤
│ ┌─ Market Info ──────────────────────┐ │
│ │ Best price:        $187.20         │ │
│ │ Est. slippage:     $0.19           │ │ Slippage in $ (v10.2)
│ │ You own:           2.5 SOL         │ │ Ownership info
│ └────────────────────────────────────┘ │
├────────────────────────────────────────┤
│ ◆ OWNERSHIP EDUCATION                  │ Lucid block (v10.2)
│   No leverage. No liquidation risk.    │
│   No holding costs.                    │
├────────────────────────────────────────┤
│ ▸ Advanced Trade Settings ▾          │ Renamed from "More options"
│                                        │
│ ┌─ Order Type ────────────────────┐  │ card-glass, expandable
│ │ [■ Market ▪▪▪▪▪▪|  Limit   ]   │  │ iOS segment control
│ │                                  │  │
│ │ (when Limit selected:)          │  │ Dynamic field expansion
│ │ ┌─ Buy at price ─────────────┐  │  │
│ │ │ [-] [+]  $183.46           │  │  │ iOS stepper
│ │ │         -2% below market   │  │  │ Green badge
│ │ └────────────────────────────┘  │  │
│ │ ◆ Your order waits in the book  │  │ Lucid hint updates
│ │   until price drops to level.   │  │ per selection
│ └──────────────────────────────────┘  │
│                                        │
│ ┌─ Sell Target ───────────────────┐  │ card-glass
│ │ Auto-sell at [$210.00] (+12.2%) │  │
│ │ ◆ Previous high: $xxx           │  │ Lucid hint
│ └──────────────────────────────────┘  │
│                                        │
│ ┌─ Price Alert ───────────────────┐  │ card-glass
│ │ Notify me at [$200.00]         │  │
│ │ (not an order)                  │  │
│ └──────────────────────────────────┘  │
│                                        │
│ ┌─ DCA Setup ─────────────────────┐  │ card-glass
│ │ [Daily] [Weekly] [Monthly]     │  │
│ │ Amount per interval: [$50]      │  │
│ │ ◆ DCA into SOL over 12mo:     │  │ Lucid evidence
│ │   +34% vs lump sum +28%        │  │
│ └──────────────────────────────────┘  │
│                                        │
├────────────────────────────────────────┤
│                                        │
│ [← Buy SOL — $500 →]                  │ Execute CTA
│                                        │
└────────────────────────────────────────┘
```

**Spot Trade Routing & State — v10.2 (updated from v9.0):**

The PERPS/SPOT toggle on the calculator header routes to spot instruments. `buildSpotTrade(spotInst)` is a **complete rewrite** in v10.2 with portfolio pills, "Advanced Trade Settings" expandable, and proper evidence blocks.

- **State management:** When user taps SPOT, `state.tradeInstrType` is set to `'spot'`, `state.spotDir` defaults to `'BUY'`, `state.spotAmount` defaults to 500
- **Instrument resolution:** `buildTrade()` checks `state.tradeInstrType` and finds the matching spot instrument (e.g., `SOL-PERP` → `SOL-SPOT`, `BTC-PERP` → `BTC-SPOT`)
- **Render call:** Calls `buildSpotTrade(spotInst)` which renders the full spot calculator variant
- **Back navigation:** "◀ Trade Hub" returns to TH
- **Toggle behavior:** Switching back to PERPS restores the perps calculator with the same symbol (e.g., `SOL-SPOT` → `SOL-PERP`)
- **Amount default:** $500 (`state.spotAmount`) with live token quantity estimate based on current best price
- **Portfolio % quick pills (v10.2):** [25%] [50%] [75%] [100%] — tapping computes dollar amount from available balance
- **BUY/SELL toggle (v10.2):** SELL button disabled (grayed out) if user has no holdings for this token
- **Ownership context (v10.2):** "You own X SOL" shown below ticker when user holds the asset
- **Lucid evidence (v10.2):** Portfolio allocation % with single-asset guideline ("Guideline: <20% in single asset")
- **Market Info card (v10.2):** Now shows slippage in dollar amount (e.g., "$0.19") instead of percentage
- **Ownership education (v10.2):** Lucid block: "No leverage. No liquidation risk. No holding costs."
- **"Advanced Trade Settings" expandable (v10.3, renamed from "More options"):** Each section is a `card-glass` styled `<details>` element:
  1. **Order Type** — iOS segment control (Market/Limit) with **dynamic Limit price field expansion**: selecting Limit reveals "Buy at price" `card-glass-el` input with iOS stepper (+/-), "-2% below market" green badge; selecting Market collapses with smooth `max-height`/`opacity` animation. Lucid hint updates per selection. Handler: `selectSpotOrderType(idx)`.
  2. **Sell Target** — Auto-sell at price with % gain display (e.g., "+12.2%"), Lucid hint shows previous high context
  3. **Price Alert** — Notification-only, explicitly labeled "not an order"
  4. **DCA Setup** — Daily/Weekly/Monthly frequency pills, amount per interval input, historical comparison Lucid evidence block (e.g., "DCA into SOL over 12mo returned +34% vs lump sum +28%")
- **No leverage controls:** Spot mode hides leverage slider, liquidation gauge, funding/holding cost sections

**Mini Order Book Ladder — Confirmed Design (v9.0):**

> **REPLACES** all prior mini chart + order book sketches from v5.0–v8.0. This is the confirmed design from brainstorm session.

- **Structure:** 5 ask levels (top, red depth bars) + spread center line + 5 bid levels (bottom, green depth bars)
- **Positioning:** Beside the order input panel (left side of split-screen for spot); above inputs for perps
- **Depth bars:** Horizontal fill bars (▓) scaled to relative volume at each level. Thinnest bars (░) for near-zero liquidity
- **Asks** (top half, red): descend from highest price to lowest price approaching spread
- **Bids** (bottom half, green): descend from highest price (nearest spread) to lowest price
- **Center line:** Spread row showing last traded price — format: `─── $69,936.0 SPREAD ───`
- **TAP any row** → limit order price pre-fills in the adjacent order panel (both spot and perps modes)
- **Real-time updates:** All rows update via WebSocket feed; no polling
- **Last trade indicator:** Arrow `◄` appears on the row where the most recent trade executed
- **Wall indicator:** `★` on rows with unusually large depth (>2x median volume across visible levels)
- **Spot basic mode:** Same ladder layout as perps, but the adjacent order panel has no leverage slider

**Interactive Chart on Trade Screens — v9.0:**

Both the perps calculator (C5-NEW) and the spot trade variant embed an interactive TradingView-like chart directly on the trade screen, providing live price context without navigating away.

- **Rendering:** HTML5 Canvas via `drawInteractiveChart(canvasId, inst, height)`
- **Candlesticks:** OHLC candlestick rendering — green (#22D1EE family) for up candles, red for down candles — 60 data points displayed
- **Moving Averages:** MA7 overlay line in cyan (`#22D1EE`) and MA20 overlay line in purple (`#8B5CF6`)
- **Volume Histogram:** Semi-transparent volume bars at bottom of chart, occupying 15% of chart height
- **Touch/Mouse Crosshair:** Horizontal + vertical crosshair lines on hover/touch, with price label (right edge) and time label (bottom edge)
- **OHLC Data Bar:** Shows Open / High / Low / Close values at top of chart on hover/touch interaction
- **Animated Entrance:** 500ms cubic ease-out drawing animation on chart load (candlesticks draw left-to-right)
- **Canvas IDs:**
  - Perps: `tradeChartCanvas_${sym}` (e.g., `tradeChartCanvas_SOL-PERP`)
  - Spot: `spotChartCanvas_${sym}` (e.g., `spotChartCanvas_SOL-SPOT`)
- **Height:** 140px on trade screens (both perps and spot)
- **Navigation Pill:** "View in Markets →" pill positioned top-right of the chart area, linking to C3 asset detail page for the current instrument
- **Position within layout:**
  - Perps (C5-NEW): Chart renders above the Mini Order Book Ladder and order input panel
  - Spot: Chart renders below the ticker/price header and above the BUY/SELL toggle

**Interaction Flows:**

1. **Risk Input → Auto-compute:**
   - User enters $375 in risk field
   - System auto-computes position size = risk / (entry_price - stop_loss) × leverage
   - Updates in real-time as user adjusts leverage
   - PnL scenarios update instantly

2. **Position Size Slider with Kelly Mark (NEW):**
   - Kelly-recommended mark etched into the rail visually
   - Haptic detent when slider crosses the Kelly mark (like sliding past a magnet)
   - Mark shows "◆ Kelly" above the slider
   - Below slider: annotation showing Kelly-recommended size vs. current size
   - Color changes: green when below Kelly, amber when at Kelly, red when above Kelly

3. **Leverage Slider (3.12-3.14):**
   - Smooth gradient: green (1-5x) → yellow (5-10x) → red (10x+)
   - At slider release ≥10x: overlay appears with 5-second countdown
   - Countdown circle fills clockwise (Lottie animation)
   - Number pulses every second
   - [Open at 10x] button disabled until countdown completes
   - Haptic feedback: buzz every second

4. **Leverage Slider with Inline Funding Annotation (NEW):**
   - Real-time annotation below slider updates as user adjusts
   - Shows: "◆ 3x is within your preferred range (3-5x). Funding cost at 3x: ~$3.20/day."
   - At higher leverages: annotation color shifts to amber
   - Tappable: [◆ More] opens bottom sheet for detailed funding history

5. **REACTIVE BEHAVIOR AT 15x+ LEVERAGE (NEW):**
   - Slider turns deep red
   - Funding annotation updates in real-time: "~$47/day" in amber
   - Liquidation bar shrinks visually (from 33% safe to 6.7%)
   - CONTEXTUAL INSERTION appears IN the layout between liquidation and TP/SL sections
   - Card shows: funding impact, historical funding patterns, Kelly recommendation, win rate at high leverage
   - [Adjust to Kelly (2.1x) ◆] one-tap → snaps leverage slider back to 2.1x with spring animation
   - Context card collapses after adjustment, execute button slides back up

6. **Liquidation Distance with Historical Context (NEW):**
   - At healthy distances (18km): "◆ Healthy distance. 33% drop required to liquidate. SOL's worst 7-day drop in the last year: -28%."
   - At dangerous levels (6.7%): "◆ CAUTION: 6.7% move liquidates you. SOL moved more than this on 34 of the last 90 days."
   - Tappable: [◆ More] opens bottom sheet with historical volatility data

7. **TP/SL Pre-filled with Lucid Suggestions (NEW):**
   - TP: $183.50 (+4.6%) ◆ regime ATR-based
   - SL: $165.40 (-5.7%) ◆ below swing low
   - Below: "◆ Your TP hit rate at 4-6% in Trending: 68%."
   - Optional: "☐ Trailing stop (2%) ◆ recommended — your hold-past-TP pattern suggests you want more room. [◆ Why?]"
   - [◆ Why?] opens bottom sheet explaining the behavioral pattern and recommendation

8. **Kelly Guide Trigger (3.4):**
   - Tap [📐 View Sizing Guide]
   - Panel slides in from right (300ms spring animation)
   - Shows 5-step pipeline with current position highlighted
   - User can tap preset buttons: [Use Conservative], [Use Moderate], [Use Aggressive]
   - Selected button highlights, position size updates
   - Panel slides out on [Use X] or back button

9. **Execute CTA (3.7):**
   - Large green button at bottom
   - Text: "Open Long — $375 risk" (contextual to symbol/direction/amount)
   - On tap: CTA text changes to "Submitting..." with spinner
   - After 500ms → navigates to C5 (Execution Monitor)

**Mock Data Example (Calculator):**

- Symbol: SOL-PERP
- Current Price: $187.20
- Risk Budget: $375
- Entry Price: $187.20
- Stop Loss: $175.90 (6.1% below)
- Leverage: 5x
- Position Size: 0.0146 BTC
- Take Profit: $198.50 (Lucid-suggested, Trending regime)
- Daily Funding: ~$3.98
- Kelly Fraction: 17.8% (based on 64% win rate, 1.8 payoff ratio)
- Suggested Size at 0.33 Kelly: 5.9% of bankroll

---

### Signals & Lucid Annotations — C5-NEW (v10.0 — Instruction 10)

#### "WHAT THE MARKET IS SAYING" Card (Step 1) — v10.2

Positioned immediately below the LONG/SHORT direction toggle in Step 1. **Renamed from "LUCID SIGNALS"** per Trade Parameter Redesign. Uses **cyan left border** accent. Replaces the previous bottom-of-screen signal strip — signals are now co-located with the direction decision for maximum impact:

```
┌─ ◆ WHAT THE MARKET IS SAYING ──────┐  Cyan left border
│ Smart Money: 72% NET LONG          │
│ Your Leaders: 4 are LONG           │
│ Regime: Trending                   │
│ Funding: Longs pay ~$3.20/day      │
│ Signal Strength: 4/5 alignment     │
└────────────────────────────────────┘
```

The card is always visible (not collapsible) and updates dynamically when the user switches direction or symbol.

#### Parameter-Specific Signal Annotations

Each advanced section gets inline Lucid annotations drawn from Radar/Markets data:

| Parameter Section         | Signals Shown                                                                                                 |
| ------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **Leverage**              | Leader avg leverage for this asset. User's best-performing leverage range. Funding cost at selected leverage. |
| **Safety Limits (TP/SL)** | Key S/R levels from Technical tab. User's TP hit rate at this R:R ratio. Leader typical TP/SL for this setup. |
| **Position Sizing**       | Kelly recommendation (phase-appropriate). Portfolio concentration %. Leader position sizes.                   |
| **Holding Cost**          | Funding rate percentile. Historical comparison ("last 2 times funding this high...").                         |
| **Risk Scenarios**        | Liquidation cluster locations. "Price has moved >X% on Y of last 90 days."                                    |

#### Four Lucid Channels on Trade Screen

| Channel                    | Description                                                                                                                                |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| **Signal strip**           | Persistent contextual signals (above). Always visible.                                                                                     |
| **◆ Tooltips**             | First-principles explanations on each parameter label. Tap ◆ icon → tooltip popover.                                                       |
| **[◆ Why? →] CTA**         | Opens G1 bottom sheet for deep Q&A about any technical/risk concept.                                                                       |
| **Inline education cards** | Contextual cards that appear on first-time events (first TP/SL setup, first leverage >10×, first Kelly exceed). Dismissible, don't repeat. |

#### S2 vs S7 Signal Adaptation

| Signal Type      | S2 (Trade Myself)                    | S7 (Copy Follower)                                   |
| ---------------- | ------------------------------------ | ---------------------------------------------------- |
| Leader consensus | "4 leaders long SOL" (informational) | "Your copied leader @X is long SOL at 5×" (personal) |
| Smart money      | Full display                         | Simplified to copied leader's position               |
| Technical        | RSI, MACD, MA inline                 | Hidden unless expanded                               |
| On-chain         | OI, funding, money flow              | Simplified to "market conditions"                    |

---

### Symbol Picker — v10.0

**Purpose:** Unified instrument selection overlay used from TH ([+ New Trade] button), C5-NEW symbol header tap, and any trade screen symbol change. Redesigned with Watchlist as default tab, Recents strip, and sort options.

**State Variables:**

- `symbolPickerTab = 'watchlist'` — Watchlist is the default landing tab (was previously "All")
- `symbolSortMode = 'volume'` — Default sort by volume (options: Volume, 24h Change, Signal Strength)
- `openSymbolPicker()` resets to watchlist tab and volume sort on every open

**Layout:**

```
┌────────────────────────────────────────┐
│ [🔍 Search instruments...]             │  Search bar (auto-focus)
├────────────────────────────────────────┤
│                                        │
│ Recents:                               │  Horizontal strip (last 5)
│ [SOL] [BTC] [ETH] [DOGE] [AVAX]      │  Shown when NOT searching
│                                        │  Tap → immediate selection
├────────────────────────────────────────┤
│ [★ Watchlist] [All] [Perps] [Spot]    │  Asset class tabs
│ [Stocks] [FX] [Commodities]           │
├────────────────────────────────────────┤
│                                        │
│ 🔥 Hot Right Now (Watchlist tab only)  │  Trending section
│ ┌─ SOL-PERP  $187.20  +4.2%  🟢 ──┐ │
│ └────────────────────────────────────┘ │
│                                        │
│ Your Watchlist                         │
│ ┌─ BTC-PERP  $69,200  -0.8%  ────┐   │
│ ┌─ ETH-PERP  $2,420   +1.2%  ────┐   │
│ ┌─ AAPL      $179.85  +0.3%  ────┐   │
│ ...                                    │
│                                        │
├────────────────────────────────────────┤
│ Sort: [■ Volume] [24h Change] [Signal] │  Sort options row
└────────────────────────────────────────┘
```

**Recents Horizontal Strip:**

- Shows last 5 tapped instruments as compact pills
- Displayed at top of picker when user is NOT actively searching
- Tap any recent pill → immediately selects that instrument and closes picker
- Populated from `MOCK.recentSymbols` or tracked via session history

**Asset Class Tabs:**

- ★ Watchlist (default), All, Perps, Spot, Stocks, FX, Commodities
- Each tab filters the instrument list to that asset class
- Watchlist tab includes "Hot Right Now" section at top

**Sort Options:**

- **Volume** (default): Sort by 24h trading volume descending
- **24h Change**: Sort by absolute price change descending
- **Signal Strength**: Sort by Lucid signal alignment score descending
- Sort pills displayed as a row at bottom of picker

---

### Risk Controls — Regime Gate, Cool-Down, TP/SL Friction & Trade Style Detection (v10.0, updated v10.2)

**Purpose:** Pre-execution safety checks that chain before final order submission, plus behavioral friction dialogs for risk-increasing parameter changes. Protects users from trading in unfavorable conditions, during loss streaks, and from inadvertently removing protective orders.

**Execution Chain:** `executeConfirm()` → `checkCoolDown()` → `checkRegimeGate()` → `executeTradeConfirmed()`

#### Trade Style Detection — `detectTradeStyle()` (v10.2)

Reads `journeyState` to determine if the user is S2 (active trader) or S7 (copy follower). Sets `state.tradeStyle = 'active'` or `'copy'`. This affects signal card emphasis, Lucid annotation tone, and whether copy-specific attribution is shown on the calculator.

**Trigger:** Called on Trade tab entry and whenever the user enters C5-NEW.

#### TP/SL Removal Friction — `tradeTPSLRemoveFriction(type)` (v10.2)

Behavioral speed bump shown when a user attempts to remove their Take Profit or Stop Loss. Requires conscious acknowledgment before proceeding.

**Trigger:** User taps "Clear TP" or "Clear SL" link in Step 4 (Exit Plan) of the perps calculator.

**Dialog Layout:**

```
┌────────────────────────────────────────┐
│ ⚠ Remove [Take Profit / Stop Loss]?   │
├────────────────────────────────────────┤
│                                        │
│ Removing your [TP/SL] means your      │
│ position has no automatic [profit      │
│ target / downside protection].         │
│                                        │
│ 83% of profitable traders keep their  │
│ [TP/SL] active.                       │
│                                        │
│ [Keep TP/SL]        [Remove Anyway]   │
│ (primary)           (secondary/muted)  │
└────────────────────────────────────────┘
```

**Behavior:**

- **[Keep TP/SL]** (primary button, prominent) — Closes dialog, TP/SL remains set
- **[Remove Anyway]** (secondary button, muted styling) — Removes the TP or SL, logs the removal for Lucid behavioral analysis
- Dialog uses social proof ("83% of profitable traders...") as nudge
- Removal event logged to trade journal for post-trade review in C7

#### Regime Gate — `checkRegimeGate()`

Compares the user's win rate in the CURRENT market regime vs their BEST regime. If the gap exceeds 20 percentage points, a warning modal is shown before execution.

**Trigger:** `bestRegimeWR - currentRegimeWR > 20` (e.g., user wins 72% in Trending but only 48% in Ranging — gap = 24pp)

**Modal Layout:**

```
┌────────────────────────────────────────┐
│ ⚠ Regime Mismatch                      │
├────────────────────────────────────────┤
│                                        │
│ Your win rate in the current regime    │
│ is significantly below your best:      │
│                                        │
│ Current regime (Ranging):    48%       │
│ Your best regime (Trending): 72%       │
│ Gap: -24 percentage points             │
│                                        │
│ You tend to perform best in Trending   │
│ conditions. Consider waiting for a     │
│ regime shift.                          │
│                                        │
│ [Cancel Trade]  [I Understand, Proceed]│
└────────────────────────────────────────┘
```

**Data Source:** `MOCK.user.regimeWinRates` — object mapping regime names to win rate percentages

#### Cool-Down Protection — `checkCoolDown()`

Consecutive loss protection triggered after 3+ consecutive losses. Encourages the user to take a break before placing another trade.

**Trigger:** `MOCK.user.consecutiveLosses >= 3` (new field, default: 0)

**Modal Layout:**

```
┌────────────────────────────────────────┐
│ ⚠ Cool-Down Protection                 │
├────────────────────────────────────────┤
│                                        │
│ You've had 4 consecutive losses.       │
│                                        │
│ Research shows that after 3+ losses,   │
│ traders tend to increase risk and      │
│ deviate from their process. Taking a   │
│ break helps reset decision-making.     │
│                                        │
│ [Set 4h Timer]                         │
│ [Override — I Reviewed My Process]     │
└────────────────────────────────────────┘
```

**Behavior:**

- **[Set 4h Timer]** — Closes the trade flow, sets a 4-hour cool-down timer. During cool-down, the Execute CTA is disabled with countdown text: "Cool-down: 3h 42m remaining"
- **[Override — I Reviewed My Process]** — Proceeds to Regime Gate check (if applicable) then to trade execution. Override is logged for Lucid behavioral analysis.

---

### Screen: C5 (Execution Monitor) — v5.0

**Purpose:** Real-time tracking of order from submission through fill. Shows fill percentage, mini candlestick chart with entry/fill visualization, and celebration animation on complete fill. LIVE MARKET STRIP shows price movement during execution.

**Layout:**

```
┌────────────────────────────────────────┐
│ ◀ Placing Order         [Close]        │
├────────────────────────────────────────┤
│ ◀ Trending ▶  [🔔]                     │
├────────────────────────────────────────┤
│                                        │
│ SOL-PERP  ─  LONG  ─  $187.20         │
│ Placing order...                       │
│                                        │
├─ REAL-TIME FILL BAR ──────────────────┤
│                                        │
│ Fill Progress:  45%                   │
│                                        │
│ ████████████████░░░░░░░░░░░           │  (Updated in real-time)
│ 0.00654 BTC / 0.0146 BTC filled      │
│                                        │
│ Average Fill Price: $187.15           │
│ Remaining: 0.00806 BTC                │
│                                        │
├─ MINI CANDLESTICK CHART ──────────────┤
│                                        │
│  ╱\      ╱\    ╱\                     │
│ ╱  \    ╱  \  ╱  \                    │
│       ╲╱        ╲╱     ← Current candle
│                  ▼                    │
│ Entry: $187.20 ──────                │
│ Fill:  $187.15 ────●  (Blue dots)     │
│                                        │
│ Chart shows fills vs price movement   │
│                                        │
├─ STATUS & TIMING ─────────────────────┤
│                                        │
│ Status: FILLING                       │
│ Order ID: #2895743                    │
│ Submitted: 2 min ago                  │
│                                        │
│ Fills so far:                         │
│ 12:15 PM - 0.003 BTC @ $187.18        │
│ 12:16 PM - 0.00224 BTC @ $187.13     │
│ 12:17 PM - 0.00200 BTC @ $187.15     │
│                                        │
│ (Each fill ticks play subtle haptic)  │
│                                        │
├─ ACTIONS ────────────────────────────┤
│                                        │
│ [Cancel Remaining] ← If partially filled
│ [Waiting...] ← If 100% filled         │
│                                        │
│ Swipe-to-execute rail at bottom:     │
│ ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬          │
│ Slide thumb right to cancel →         │
│ (Thumb tracks green, fills on move)   │
│ (Haptic burst on release)             │
│                                        │
└────────────────────────────────────────┘

[ON 100% FILL — C5 transitions to C6]

  ┌────────────────────────────────────┐
  │   ✨ CELEBRATION ANIMATION ✨      │
  │                                    │
  │     ✓ Order Filled!                │
  │                                    │
  │  🎉 Confetti burst (300ms)        │
  │  ✅ Green checkmark Lottie (800ms) │
  │  Haptic pattern: 3 pulses          │
  │                                    │
  │  Position opened:                  │
  │  SOL LONG 5x                       │
  │  $2,051.25 position                  │
  │                                    │
  │  [View Position →]                 │
  │  (Auto-navigates after 2s)         │
  └────────────────────────────────────┘
```

**Interaction Behaviors:**

1. **Fill Bar Animation:**
   - Updates every 500ms when new fills arrive
   - Percentage number counts up smoothly
   - Bar width animates from current to new percentage (200ms easing)
   - Color: blue for fill progress, gray for remaining

2. **Mini Candlestick Chart:**
   - Shows last 5 candles (1-min interval default)
   - Entry price line in red
   - Fill prices as blue dots
   - Current candle in lighter shade
   - Updates as new fills arrive and candles close

3. **Fill Notifications:**
   - Each fill tick plays "cash register" sound + haptic (subtle)
   - Fill row appears in list immediately
   - "Fills so far" section scrollable if >5 fills

4. **Swipe-to-Cancel:**
   - Only appears if status = FILLING or PARTIALLY_FILLED
   - Thumb tracking animation: thumb color changes green as user swipes
   - Bar fills green proportionally to swipe distance
   - Haptic burst on successful swipe completion
   - Releases back to neutral if not swiped far enough

5. **Celebration Sequence (100% fill):**
   - Confetti burst across screen (300ms duration, ~30 particles)
   - Green checkmark appears with Lottie animation (spring bounce into frame, 800ms)
   - Haptic pattern: 3-pulse sequence (short-short-long)
   - Auto-navigates to C6 after 2-3 seconds
   - User can tap [View Position →] to navigate immediately

**Error Handling:**

- If order is REJECTED: Red banner appears, "Order not accepted" with reason
  - Tap [Back to Calculator] → returns to C5-NEW
- If order is CANCELLED: Orange banner, "Your cancel was successful"
  - Remaining portion becomes available for new order
  - Filled portion transitions to Position (C6)
- If connection lost: Gray banner, "Reconnecting..." with spinner
  - Auto-retries every 2s
  - User can swipe down to refresh

**Mock Data Example:**

- Order ID: #2895743
- Symbol: SOL-PERP
- Position Size: 0.0146 BTC
- Entry Price: $187.20
- Fills: 45% complete (0.00654 BTC filled, 0.00806 remaining)
- Average Fill Price: $187.15
- Time in Flight: 2 min

---

### Screen: C6 (Position Monitor) — v5.0

**Purpose:** Live view of active position. Primary focus: safety margin (liquidation distance) as largest metric. Quick actions for close, add margin, adjust TP/SL, add to position. Lucid annotations throughout. LIVE MARKET STRIP with large chart showing entry/current/TP/SL overlays and order book depth visualization.

**Layout:**

```
┌────────────────────────────────────────┐
│ ◀ SOL LONG     [⚙ Settings]            │  Header with position ID
├────────────────────────────────────────┤
│ ◀ Trending ▶  [🔔]                     │
├────────────────────────────────────────┤
│                                        │
│ SOL-PERP  $187.20                     │
│ (Last: 30 sec ago)                    │
│                                        │
├─ PRIMARY METRIC (5.0): SAFETY MARGIN ──┤
│                                        │
│   SAFETY MARGIN                       │  LARGEST TEXT on screen
│   (Auto-close distance if price drops)│
│                                        │
│        18.2 km away                   │  Numeric value very large
│                                        │
│ ████████████ 🟢 SAFE (>20%)           │  Safety gauge: radial meter
│ Entry ────────────────────── Close    │
│                                        │  Animated sweep on load
│ Auto-close price: $156.80             │  (0→18.2km over 500ms spring)
│ Current: $187.20                      │
│ Cushion: $30.40                       │  Color zones:
│                                        │  🟢 Green: >20% safe distance
│ ◆ Healthy distance. Price needs to    │  🟡 Yellow: 10-20%
│ drop 33% to trigger auto-close. SOL's │  🔴 Red: <10%
│ worst 7-day drop last year: -28%.     │  (Lucid context annotation)
│                                        │
├─ POSITION DETAILS ────────────────────┤
│                                        │
│ Direction:      LONG 5x               │
│ Entry Price:    $187.20               │
│ Current Price:  $187.20               │
│ Position Size:  0.0146 BTC / $2,051   │
│                                        │
├─ REAL-TIME P&L ──────────────────────┤
│                                        │
│ P&L:  +$0  (+0.0%)                   │  Slot-machine style rolling
│ ROE:  +0.0%                          │  digits (updates every sec)
│ Daily Funding: -$0.10 (-0.1%)         │
│                                        │
├─ REGIME & WALLET CONTEXT ────────────┤
│                                        │
│ ◆ Regime still Trending ✅             │  (NEW: Lucid status)
│ Wallet consensus stable.               │  (tappable for deeper Q&A)
│                                        │
│ Entered in: Trending ✅               │  Regime alignment badge
│ Current: Consolidating (⚠ regime mismatch) │
│                                        │
│ Wallet Consensus:                    │  (3.9) Attribution
│ 📋 FROM @ProTrader (Elite ⭐)        │  "Copied from this leader"
│ [View Leader →]  (navigates to D2)    │
│                                        │
│ 3 other All-Weather wallets          │  Other wallets with same position
│ also long SOL                         │
│                                        │
├─ QUICK ACTIONS ───────────────────────┤
│                                        │
│ [Close] [Add Margin] [Adjust TP/SL]  │  (3.9-3.14) Action buttons
│ [Add to Position]                    │
│                                        │
│ Each opens bottom sheet:              │
│                                        │
│ Close:                                │
│ ┌──────────────────────────┐         │
│ │ Close Position            │         │
│ │                          │         │
│ │ Position: 0.0146 BTC    │         │
│ │ Size: 0.0146 BTC         │         │
│ │                          │         │
│ │ Close Amount: [0.0146]  │         │
│ │                          │         │
│ │ ──────────────────────  │         │
│ │ Close 25%   Close 50%   │         │
│ │ Close 75%   Close All   │         │
│ │                          │         │
│ │ Estimated Return:        │         │
│ │ ~0.0146 BTC (no change) │         │
│ │                          │         │
│ │ [Confirm Close]          │         │
│ └──────────────────────────┘         │
│                                        │
│ Add Margin:                           │
│ ┌──────────────────────────┐         │
│ │ Add Margin               │         │
│ │                          │         │
│ │ Current Margin: $375   │         │
│ │ Liquidation Distance: 18.2km    │         │
│ │                          │         │
│ │ Add Amount: [$187.50]  │         │
│ │                          │         │
│ │ New Liquidation Distance: 27.3km│         │
│ │ (Slider to adjust)      │         │
│ │                          │         │
│ │ [Confirm Add Margin]     │         │
│ └──────────────────────────┘         │
│                                        │
│ Adjust TP/SL:                         │
│ ┌──────────────────────────┐         │
│ │ Edit Take Profit & SL    │         │
│ │                          │         │
│ │ Take Profit: [$198.50]  │         │
│ │ SL Distance: +6.1%      │         │
│ │                          │         │
│ │ Stop Loss:  [$175.90]   │         │
│ │ SL Distance: -6.1%      │         │
│ │                          │         │
│ │ [Update TP/SL]          │         │
│ └──────────────────────────┘         │
│                                        │
│ Add to Position:                      │
│ ┌──────────────────────────┐         │
│ │ Add to Position           │         │
│ │                          │         │
│ │ Current Size: 0.0146 BTC│         │
│ │ Entry Price: $187.20   │         │
│ │                          │         │
│ │ Add Risk: [$187.50]    │         │
│ │ Add Size: 0.0073 BTC     │         │
│ │                           │         │
│ │ New Entry Average: $187.20│         │
│ │ New Liquidation Dist: 13.2km  │         │
│ │                          │         │
│ │ [Confirm Add]            │         │
│ └──────────────────────────┘         │
│                                        │
├─ TABS ────────────────────────────────┤
│                                        │
│ [Overview] [Chart] [Orders] [History] │  Tab navigation
│                                        │
│ Chart Tab:                            │
│ ┌──────────────────────────┐         │
│ │ 1h        4h      1d     │  Timeframe picker
│ │                          │         │
│ │  ╱╲    ╱╲                │         │
│ │ ╱  ╲  ╱  ╲               │         │
│ │      ╲╱      ╲╱          │         │
│ │                          │         │
│ │ Entry: $187.20 ──────   │
│ │ Current: $187.20 ─────● │
│ │ TP: $198.50 ────────    │
│ │ SL: $175.90 ────────    │
│ │                          │         │
│ │ Shows candlesticks with │
│ │ entry, current, TP, SL  │
│ └──────────────────────────┘         │
│                                        │
│ Orders Tab:                           │
│ ┌──────────────────────────┐         │
│ │ TP Order: 0.0146 BTC    │         │
│ │ @ $198.50 (Active)      │         │
│ │                          │         │
│ │ SL Order: 0.0146 BTC    │         │
│ │ @ $175.90 (Active)      │         │
│ │                          │         │
│ │ [Edit TP] [Edit SL]     │         │
│ │ [Cancel Order]          │         │
│ └──────────────────────────┘         │
│                                        │
│ History Tab:                          │
│ ┌──────────────────────────┐         │
│ │ Entry Order              │         │
│ │ FILLED 12:17 PM          │         │
│ │ 0.0146 BTC @ $187.20   │         │
│ │                          │         │
│ │ Funding Payments        │         │
│ │ -$0.10 @ 8am            │         │
│ │ -$0.14 @ 8pm (est)      │         │
│ │                          │         │
│ │ Liquidation            │         │
│ │ Distance: 18.2km       │         │
│ │ (if liquidated, shows here) │     │
│ └──────────────────────────┘         │
│                                        │
└────────────────────────────────────────┘
```

**Interaction Behaviors:**

1. **Liquidation Distance Animation (3.9-3.14):**
   - On screen load: safety gauge sweeps from 0 → 18.2km over 500ms with spring easing
   - Color fills proportionally: green first, then yellow, then red as distance decreases
   - If liq distance < 10% (red zone), continuous pulse animation (subtle brightness changes)
   - Number count-up: 0 → 18.2 km simultaneously with gauge sweep

2. **Lucid Regime & Wallet Annotations (NEW):**
   - Tappable: "◆ Regime still Trending ✅" opens bottom sheet with regime change probability
   - Tappable: "Wallet consensus stable." opens bottom sheet with wallet activity details
   - Both show data-driven confidence indicators (◆ marked for Q&A)

3. **Quick Action Buttons:**
   - Each tap opens a bottom sheet with pre-filled data
   - All bottom sheets include a confirmation step
   - After confirmation, position updates in real-time
   - Sheet slides up with slight bounce (200ms spring)

4. **Chart Tab:**
   - Shows candlesticks with entry/current/TP/SL overlay
   - Tap and drag to zoom
   - Double-tap to reset zoom
   - Timeframe picker at top (1h, 4h, 1d)

5. **Margin Warning Banner (if liq distance < 10%):**
   - Red banner at top (fixed)
   - Text: "⚠ Liquidation in 2 hours. Add margin or close position."
   - [Add Margin] and [Close] buttons inline
   - Tapping navigates to respective action sheet

6. **Wallet Attribution (if copied position):**
   - "📋 FROM @ProTrader (Elite ⭐)" badge shows copy source
   - [View Leader →] button opens D2 (Trader Detail) in new screen
   - Shows if 3+ other wallets hold same position

**Mock Data Example:**

- Symbol: SOL-PERP
- Direction: LONG
- Leverage: 5x
- Entry Price: $187.20
- Current Price: $187.20
- Position Size: 0.0146 BTC
- Liquidation Price: $156.80
- Liquidation Distance: 18.2 km (30.4 cushion)
- P&L: +$0 (+0.0%) [just entered]
- Regime Entered: Trending ✅
- Current Regime: Consolidating (mismatch)
- Source: @ProTrader copy (Elite trader)
- Take Profit: $198.50 (6.1% above entry)
- Stop Loss: $175.90 (6.1% below entry)
- Daily Funding Cost: -$0.10

---

### Screen: C7 (Trade Review) — v5.0

**Purpose:** FULL-SCREEN post-trade analysis and reflection (NOT floating card). Encourages learning by comparing sizing vs Smart sizing (Kelly), regime alignment, wallet behavior, Lucid insights. Awards points for completion. Simplified language throughout. This is Lucid Moment 3 of the trading lifecycle.

**Layout:**

```
┌────────────────────────────────────────┐
│ ◀ Review Trade          [Close]        │
├────────────────────────────────────────┤
│ ◀ Trending ▶  [🔔]                     │
├────────────────────────────────────────┤
│                                        │
│ SOL LONG  •  Closed 2:47 PM           │
│ Position Closed                       │
│                                        │
├─ TRADE OUTCOME ──────────────────────┤
│                                        │
│ P&L:   +$108.90  (+5.3%)             │  Large, prominent
│ ROE:   +29.1%  (excellent)            │
│ Duration: 2h 30m                      │
│                                        │
│ Entry:  $187.20  @ 12:17 PM           │
│ Exit:   $197.30  @ 2:47 PM            │  Exit info
│ (closed manually)                     │
│                                        │
├─ KELLY ACCURACY (3.7) ────────────────┤
│                                        │
│ 🎯 Sizing Review  (◆ Lucid Analysis)  │
│                                        │
│ Kelly Guide Suggested:  $300      │  Kelly calc from journal edge
│ (5.9% of bankroll)                    │
│                                        │
│ You Actually Used:      $375      │  Actual risk taken
│ (7.2% of bankroll)                    │
│                                        │
│ Difference: +1.25x over guide ⚠       │  Comparison bar (animated fill)
│                                        │
│ ████████████ (Guide)                  │
│ ███████████████ (You)                 │  Your bar extends past guide
│                                        │
│ Over-sizing reduces long-term edge    │
│ and increases drawdown risk.          │
│                                        │
├─ REGIME ALIGNMENT (3.7) ──────────────┤
│                                        │
│ ✅ Entered in Trending                 │
│ Your regime filter: +0% (no adjustment)
│ Entry decision: CORRECT REGIME        │
│                                        │
│ ◆ Trending regime has 67% higher      │  (NEW: Lucid regime insight)
│ win rate for your position profile.   │
│ You entered in trending: ✅ smart.    │
│                                        │
├─ WALLET CONSENSUS (3.7) ──────────────┤
│                                        │
│ Your Direction: LONG                  │
│ Wallet Consensus: 3 LONG, 1 SHORT    │
│                                        │
│ 3 All-Weather wallets were also LONG │
│ 1 wallet was SHORT (contrarian)       │
│                                        │
│ Alignment: 🟢 Strong agreement        │
│                                        │
│ Table:                                │
│ ┌────────────────────────────────┐  │
│ │ Wallet        │ Dir  │ Size   │  │
│ │ @TradeKing    │ LONG │ $2,325  │  │
│ │ @VeryNice     │ LONG │ $1,350  │  │
│ │ @InnovateTech │ LONG │ $1,725  │  │
│ │ @CounterPlay  │ SHORT│ $675  │  │
│ └────────────────────────────────┘  │
│                                        │
├─ REGIME-BEHAVIOR CONTEXT (4-1-1-6 §7) ┤
│                                        │
│ ◆ This trade: TRENDING regime.        │
│   Your Trending win rate: 72% (best). │
│   Sizing: 1.25x Kelly (slightly over).│
│   Hold: 2.5h (your Trending avg: 3.2h)│
│   Regime-Behavior Score: 68 (Aware)   │
│                                        │
│ ◆ Post-streak alert: This is your 5th │
│   consecutive win in Trending. History:│
│   after 5 wins, you increase size 40%.│
│   Those post-streak trades underperform│
│   by 12%. Keep sizing disciplined.    │
│                                        │
├─ BEHAVIORAL PATTERNS (LUCID) ─────────┤
│                                        │
│ ◆ Your exit pattern: You closed at    │
│   TP manually. Your TP hit rate is    │
│   68% at this risk level in Trending. │
│                                        │
│ ◆ This trade aligns with your        │
│   strongest edge: Kelly-sized entries │
│   in Trending regime with >65% win rate│
│                                        │
├─ REFLECTION PROMPT (3.7) ─────────────┤
│                                        │
│ "What would you do differently?"     │
│                                        │
│ [Text input area, optional]           │
│                                        │
│ Sample reflections:                   │
│ • "Entered too early, should have     │
│    waited for TP hit then re-enter"  │
│ • "Perfect regime alignment—hold     │
│    longer in trending markets"        │
│ • "Should have scaled into position"  │
│                                        │
│ [Save Reflection] (unlocks 50 points) │
│                                        │
├─ PUBLISH RATIONALE (4-1-1-6 §8) ─────┤
│                                        │
│ "Share your thinking with followers?" │
│ (Leaders with >50% publish rate get   │
│  1.2x revenue share + tier progression)│
│                                        │
│ [Write Rationale] → Path A (manual)   │
│ [Lucid Helps ◆] → Path B (assisted)  │
│                                        │
│ If already published pre-trade:       │
│ "✅ Rationale published pre-trade.    │
│  Consistency score: updating..."      │
│                                        │
├─ TRADING RULE SUGGESTION (NEW-LUCID)─┤
│                                        │
│ Based on this trade, Lucid suggests:  │
│                                        │
│ "Scale into Trending regime LONG      │
│  positions sized at 0.33 Kelly when   │
│  wallet consensus ≥3. Your edge here: │
│  68% win rate, 2.1:1 payoff."         │
│                                        │
│ [Save as Trading Rule ◆] [Dismiss]    │
│                                        │
├─ COMPLETION REWARD (3.7) ─────────────┤
│                                        │
│ ⭐⭐⭐⭐⭐                              │  Gold stars with shimmer
│ +50 XP Points!                       │  (Stars scale in with bounce)
│                                        │
│ Trade Review Complete                │
│ Reflection saved                     │
│                                        │
├─ ACTION BUTTONS ──────────────────────┤
│                                        │
│ [Review Again] [Go to History]        │
│                                        │
│ Swipe down to dismiss                 │
│                                        │
│ Auto-dismisses after 5s               │
│                                        │
└────────────────────────────────────────┘
```

**Animation Sequences:**

1. **Stats Count-Up:**
   - P&L amount rolls up with slot-machine style digits (500ms)
   - ROE percentage counts up (500ms staggered start)
   - Star rating scales in with spring bounce (800ms)

2. **Comparison Bars:**
   - Kelly guide bar fills first (200ms)
   - User's bar fills after (300ms), extending past guide bar if over-sized
   - Color: green if within Kelly, orange if 1-1.5x, red if >1.5x

3. **Star Rating Animation:**
   - 5 gold stars scale up from 0.5 → 1.0 over 600ms with spring easing
   - Stars shimmer (brightness pulse) after scaling completes
   - Simultaneous haptic: 5 short pulses (one per star)

4. **Reflection Input:**
   - Optional text area (not required to get points)
   - If completed, [Save Reflection] button highlights
   - On save: blue checkmark appears with bounce animation
   - Points awarded immediately

**Interaction Flow:**

1. Trade closes → C7 auto-navigates (FULL SCREEN, not floating)
2. All animations play simultaneously (count-ups, bars fill, stars scale)
3. Data is informational; reflection is optional
4. User can:
   - [Review Again] → Re-read all data
   - [Go to History] → Navigate to TH1
   - [Save as Trading Rule ◆] → Opens rule builder with Lucid suggestion pre-filled
   - Swipe down → Dismiss (clears to Home tab)
5. Auto-dismisses to Home after 5s if no interaction

**Mock Data Example:**

- Trade: SOL LONG 5x
- Entry: $187.20 @ 12:17 PM
- Exit: $197.30 @ 2:47 PM (2h 30m duration)
- P&L: +$108.90 (+5.3%)
- ROE: +29.1%
- Kelly Guide Suggested: $300 (5.9% of bankroll, based on 64% win rate × 1.8 payoff)
- Actually Used: $375 (7.2%, 1.25x over)
- Regime Entered: Trending ✅
- Regime At Exit: Consolidating (but trade still profitable)
- Wallet Consensus: 3 LONG, 1 SHORT → strong agreement
- Reflection: Optional (user fills)
- Points: +50 XP

---

### Screen: TH1 (Trade History) — v5.0

**Purpose:** Historical trade review with Lucid performance annotations. Cumulative equity curve, summary stats, filterable trade list with simplified language (Smart sizing instead of Kelly). Each trade expandable to show full detail with Lucid signal mapping.

**Layout:**

```
┌────────────────────────────────────────┐
│ ◀ Trade History         [Export]       │
├────────────────────────────────────────┤
│ ◀ Consolidating ▶  [🔔]                │
├────────────────────────────────────────┤
│                                        │
├─ SUMMARY STATS ───────────────────────┤
│                                        │
│ Total Trades: 47                      │
│ Win Rate: 64.9%  (30 wins, 16 losses) │
│ Average Return: +2.8%  per trade     │
│ Sharpe Ratio: 1.67                   │
│                                        │
│ Best Trade:  +$234.30 (+9.8%)        │
│ Worst Trade: -$65.63  (-3.2%)        │
│                                        │
│ Cumulative P&L: +$935.70           │
│ Monthly Return: +8.7%                 │
│                                        │
├─ CUMULATIVE EQUITY CURVE ─────────────┤
│                                        │
│  ╱╲    ╱╲    ╱╲                       │  Animated L→R over 800ms
│ ╱  ╲  ╱  ╲  ╱  ╲                      │  Green line, area under curve fill
│       ╲╱        ╲╱     ────────────   │
│ Start: $7,500                Cur: $8,400│
│                                        │
│ Regime bands: (alternating light bg)  │
│ Green = Trending regime performance   │
│ Gray = Consolidating performance     │
│ Red = Declining performance          │
│                                        │
│ Tap point on curve → drill into date  │
│ Swipe left/right → shift time window  │
│                                        │
├─ FILTER CHIPS ────────────────────────┤
│                                        │
│ [All] [Wins] [Losses] [Own] [Copy]   │  Active chip highlighted
│                                        │  Tap to toggle, mutual exclusive
│ Functional via filterTradeHistory()  │
│ Filters by pnl sign (wins/losses)    │
│ and source (own=manual, copy=!manual)│
│                                        │
├─ TRADE ROWS (EXPANDABLE) ─────────────┤
│                                        │
│ ▼ 3/10 2:47 PM - SOL LONG 5x         │  Collapsed (default)
│   $187.20 → $197.30  +$108.90 (+5.3%)│
│   Regime: Trending ✅  Win            │
│   Source: Radar Signal                │
│   ◆ Kelly accuracy: 1.25x             │  (NEW: Lucid annotation)
│                                        │
│   [Expanded view when tapped]         │
│   ┌──────────────────────────────┐   │
│   │ Full Trade Detail             │   │
│   │                              │   │
│   │ Symbol:     SOL-PERP         │   │
│   │ Direction:  LONG             │   │
│   │ Leverage:   5x               │   │
│   │ Entry:      $187.20 @ 12:17  │   │
│   │ Exit:       $197.30 @ 2:47   │   │
│   │ Duration:   2h 30m           │   │
│   │                              │   │
│   │ Position:   0.0146 BTC       │   │
│   │ Risk:       $375         │   │
│   │ P&L:        +$108.90        │   │
│   │ ROE:        +29.1%           │   │
│   │                              │   │
│   │ Entry Regime: Trending ✅    │   │
│   │ Wallet Consensus: 3 LONG     │   │
│   │                              │   │
│   │ Kelly Guide: $300           │   │
│   │ You Used:    $375 (+1.25x)  │   │
│   │                              │   │
│   │ Exit Reason: Manual (TP hit) │   │
│   │ Reflection: [user text]      │   │
│   │                              │   │
│   │ ◆ Lucid Assessment:           │   │ (NEW section)
│   │ Aligned: Trending regime +3   │   │
│   │ wallets. Strong setup.        │   │
│   │ Slightly over Kelly sizing    │   │
│   │ (1.25x). Consider 0.33 Kelly │   │
│   │ for these conditions.         │   │
│   │                              │   │
│   │ [View Details] [Delete]      │   │
│   └──────────────────────────────┘   │
│                                        │
│ ▼ 3/9 11:30 AM - ETH SHORT 3x        │
│   $2,420 → $2,405  -$39.23 (-1.9%)  │
│   Regime: Consolidating (⚠)  Loss    │
│   Source: Manual Entry                │
│   ◆ Regime mismatch warning            │  (NEW: Lucid flag)
│                                        │
│ ▼ 3/8 5:15 PM - BTC LONG 2x          │
│   $71,200 → $72,400  +$234.30 (+9.8%)│
│   Regime: Trending ✅  Win            │
│   Source: Radar AI Strategy           │
│   ◆ Best setup type for you            │  (NEW: Lucid commendation)
│                                        │
│ [Infinite scroll / pagination]        │
│                                        │
└────────────────────────────────────────┘
```

**Filter Behavior (3.8):**

- Tap any chip to toggle filter
- Multiple filters stack (e.g., [Wins] + [SOL] = only winning SOL trades)
- Filtered count updates instantly: "Filtering: 12 trades"
- Equity curve updates to show only filtered trades
- Trade rows re-animate (fade in) to show only matching trades
- Active filters highlighted in blue

**Equity Curve Behavior:**

- Draws L→R over 800ms with easing curve
- Area under curve fills with gradient (green → darker green)
- Regime bands show as alternating background colors
- Tapping on any point shows date + cumulative P&L at that point
- Swipe left/right to shift time window (e.g., show last 30 days)

**Trade Row Expansion:**

- Default: collapsed (shows summary on one line)
- Tap row → expands with smooth animation (200ms)
- Expanded view shows all details: entry/exit prices, times, duration, regime, consensus, Kelly comparison, reflection
- NEW: Lucid assessment section shows regime alignment, sizing feedback, behavioral patterns
- [View Details] opens full trade analysis (similar to C7 but read-only)
- [Delete] removes trade from journal (with confirmation)

**Summary Stats Calculation:**

- Win Rate: wins / total trades
- Average Return: (sum of all ROEs) / total trades
- Sharpe Ratio: (mean return - risk-free rate) / std dev of returns
- Best/Worst: max and min ROE trades
- Cumulative P&L: sum of all P&L
- Monthly Return: (current balance - balance 30 days ago) / balance 30 days ago

**Mock Data Example:**

- Total Trades: 47 (viewed, last 7 days: 12)
- Win Rate: 64.9% (30 wins, 16 losses, 1 breakeven)
- Average Return: +2.8% per trade
- Sharpe Ratio: 1.67
- Best Trade: +$234.30 (+9.8%, BTC LONG 2x)
- Worst Trade: -$65.63 (-3.2%, ETH SHORT 3x)
- Cumulative P&L: +$935.70
- Monthly Return: +8.7%
- Sample trades: SOL LONG (win), ETH SHORT (loss), BTC LONG (big win)

---

## BUTTON INTERACTION MATRIX — All Screens

Every tappable element follows this pattern:

| Button                                         | Screen         | Tap →                                                                                  | Visual Feedback                                                 | Loading        | Error                   | Animation               |
| ---------------------------------------------- | -------------- | -------------------------------------------------------------------------------------- | --------------------------------------------------------------- | -------------- | ----------------------- | ----------------------- |
| [+ New Trade]                                  | TH             | Opens Symbol Picker overlay                                                            | Highlight (200ms)                                               | None (instant) | N/A                     | Spring pop              |
| [◆ Ask Lucid]                                  | TH             | Opens Lucid chat (G1) with trade context                                               | Highlight fade                                                  | None           | N/A                     | Slide up                |
| Portfolio Summary Card                         | TH             | Informational (no tap action)                                                          | N/A                                                             | N/A            | N/A                     | N/A                     |
| Copy Position Card                             | TH             | Navigates to C6 with copy attribution                                                  | Tap ripple                                                      | None           | N/A                     | Slide right             |
| Position Card                                  | TH             | Navigates to C6                                                                        | Tap ripple                                                      | None           | N/A                     | Slide right             |
| Spot Holding Row                               | TH             | Navigates to spot trade screen                                                         | Tap ripple                                                      | None           | N/A                     | Slide right             |
| "Browse traders ›"                             | TH             | Navigates to Radar tab                                                                 | Highlight                                                       | None           | N/A                     | Slide right             |
| [Long] / [Short]                               | C5-NEW         | Toggles direction, updates "WHAT THE MARKET IS SAYING" card                            | Color invert + highlight                                        | None           | N/A                     | Flip animation          |
| Risk % Quick Pills [1%][2%][5%]                | C5-NEW         | Auto-computes risk amount from equity %, color-coded (green <3%, yellow 3-5%, red >5%) | Pill highlights, amount field updates                           | Live calc      | N/A                     | Bounce + fill           |
| Risk Input Field                               | C5-NEW         | Edits risk amount                                                                      | Focus outline + cursor                                          | Live calc      | Invalid amount error    | Bounce in               |
| Position Size Slider                           | C5-NEW         | Adjusts size with Kelly mark                                                           | Thumb slides, haptic detent at Kelly                            | None           | Out-of-range clamp      | Spring snap             |
| Leverage Slider                                | C5-NEW         | Adjusts leverage                                                                       | Thumb slides, color gradient updates, inline funding annotation | None           | Out-of-range clamp      | Spring snap             |
| [◆ More] (Kelly/Liquidation/Funding)           | C5-NEW         | Opens bottom sheet Q&A                                                                 | Highlight + fade                                                | None           | N/A                     | Slide up                |
| [📐 View Sizing Guide]                         | C5-NEW         | Opens Kelly guide sidebar                                                              | Highlight + fade                                                | None           | N/A                     | Slide right (300ms)     |
| Kelly Guide Preset                             | C5-NEW (guide) | Sets position size to preset                                                           | Button highlights                                               | None           | N/A                     | Pulse highlight         |
| [Adjust to Kelly (2.1x) ◆]                     | C5-NEW         | Snaps leverage to Kelly mark                                                           | Highlight + slider animation                                    | None           | N/A                     | Spring snap             |
| [◆ Ask Lucid Before Trading]                   | C5-NEW         | Opens Lucid chat with full trade context                                               | Highlight                                                       | None           | N/A                     | Slide up                |
| "Clear TP" / "Clear SL" links                  | C5-NEW         | Opens TP/SL removal friction dialog (`tradeTPSLRemoveFriction(type)`)                  | Link highlight                                                  | None           | N/A                     | Dialog slide up         |
| [Keep TP/SL] (friction dialog)                 | C5-NEW modal   | Closes dialog, TP/SL remains                                                           | Primary button highlight                                        | None           | N/A                     | Fade out                |
| [Remove Anyway] (friction dialog)              | C5-NEW modal   | Removes TP or SL, logs event                                                           | Secondary/muted highlight                                       | None           | N/A                     | Fade out                |
| Portfolio % pills [25%][50%][75%][100%]        | C5-NEW (spot)  | Computes dollar amount from balance %                                                  | Pill highlights, amount updates                                 | Live calc      | N/A                     | Bounce + fill           |
| "Advanced Trade Settings" toggle               | C5-NEW         | Expands/collapses all advanced sections                                                | Chevron rotates                                                 | None           | N/A                     | Smooth expand (200ms)   |
| [Open LONG/SHORT — $X risk] CTA                | C5-NEW         | Chains: checkCoolDown → checkRegimeGate → submit                                       | Text → spinner (500ms)                                          | Spinner loops  | Red error banner        | Bounce + slide          |
| [Cancel Trade] (Regime Gate)                   | C5-NEW modal   | Closes modal, returns to calculator                                                    | Highlight                                                       | None           | N/A                     | Fade out                |
| [I Understand, Proceed] (Regime Gate)          | C5-NEW modal   | Proceeds to trade execution                                                            | Highlight                                                       | Spinner        | Error banner            | Fade out + submit       |
| [Set 4h Timer] (Cool-Down)                     | C5-NEW modal   | Sets cool-down timer, disables Execute                                                 | Highlight                                                       | None           | N/A                     | Fade out + timer starts |
| [Override — I Reviewed My Process] (Cool-Down) | C5-NEW modal   | Proceeds to Regime Gate or execution                                                   | Highlight                                                       | None           | N/A                     | Fade out                |
| [Cancel Remaining]                             | C5             | Cancels unfilled order portion                                                         | Highlight                                                       | Spinner (1-2s) | "Cancel failed" banner  | Swipe out               |
| Swipe-to-Execute Rail                          | C5             | Cancels order (if swiped full distance)                                                | Green fill as swipe progresses                                  | None           | Snap back if incomplete | Haptic on release       |
| [Close]                                        | C6             | Opens close bottom sheet                                                               | Highlight                                                       | None           | N/A                     | Bounce up               |
| [Add Margin]                                   | C6             | Opens margin sheet                                                                     | Highlight                                                       | None           | N/A                     | Bounce up               |
| [Adjust TP/SL]                                 | C6             | Opens TP/SL edit sheet                                                                 | Highlight                                                       | None           | N/A                     | Bounce up               |
| [Add to Position]                              | C6             | Opens add position sheet                                                               | Highlight                                                       | None           | N/A                     | Bounce up               |
| Bottom Sheet CTA (Confirm)                     | C6 actions     | Submits action (close/margin/adjust)                                                   | Text → spinner                                                  | 1-2s spinner   | "Action failed" banner  | Bounce + fade out       |
| Chart Tab / Orders Tab / History Tab           | C6             | Switches tab content                                                                   | Highlight on active tab                                         | None           | N/A                     | Slide transition        |
| [View Leader →]                                | C6             | Navigates to D2 (Trader Detail)                                                        | Highlight                                                       | None           | N/A                     | Slide right             |
| ◆ Regime/Wallet annotations                    | C6             | Opens bottom sheet details                                                             | Highlight + fade                                                | None           | N/A                     | Slide up                |
| [Save Reflection]                              | C7             | Saves reflection text                                                                  | Highlight → checkmark                                           | 500ms spinner  | Error toast             | Bounce + fade           |
| [Save as Trading Rule ◆]                       | C7             | Opens rule builder with Lucid suggestion                                               | Highlight                                                       | None           | N/A                     | Slide up                |
| [Review Again]                                 | C7             | Stays on C7, scrolls top                                                               | Highlight                                                       | None           | N/A                     | Bounce                  |
| [Go to History]                                | C7             | Navigates to TH1                                                                       | Highlight                                                       | None           | N/A                     | Slide left              |
| Filter Chips                                   | TH1            | Toggles filter on/off                                                                  | Chip inverts color                                              | None (instant) | N/A                     | Bounce highlight        |
| Trade Row (expand/collapse)                    | TH1            | Expands/collapses detail                                                               | Row height animates                                             | None           | N/A                     | Smooth height expand    |
| [View Details] (trade)                         | TH1            | Opens full trade analysis                                                              | Highlight                                                       | None           | N/A                     | Slide up                |
| [Delete] (trade)                               | TH1            | Shows delete confirmation modal                                                        | Highlight → modal appears                                       | None           | N/A                     | Bounce scale up         |

**Global Interaction Patterns:**

1. **Highlight on Tap:**
   - All buttons: tap → background color dims/brightens for 100ms
   - Color: theme primary with alpha 0.2
   - Subtle haptic feedback (light tap)

2. **Loading State:**
   - Text: "Submitting..." / "Loading..." / "Confirming..."
   - Spinner: rotating circular indicator (24px)
   - Disabled state: opacity 0.5, no haptic
   - Timeout: 5s (then error state)

3. **Error Handling:**
   - Toast/banner appears at top with icon + text
   - Color: red (#F04444 or brand error)
   - Auto-dismisses after 3s
   - User can tap [Retry] or [Dismiss]
   - Haptic: strong buzz (error signal)

4. **Success Feedback:**
   - Checkmark animation (Lottie)
   - Optional toast: "Successfully [action]"
   - Haptic: 2-pulse (success pattern)
   - Auto-dismiss or navigate away

5. **Navigation Animations:**
   - Forward (push): new screen slides in from right (300ms)
   - Back (pop): current screen slides out to left (300ms)
   - Overlay (modal/sheet): fades in from bottom (200ms)

---

## USER FLOWS

### Flow 1: Simple Market Order with Lucid Intelligence (Market Entry → C5-NEW → C5 → C6 → C7)

```
User taps [Trade] tab
  ▼
TH (Trade Hub) displays portfolio overview + all positions
  │ Portfolio Summary: $5,234 equity, +$259.75 P&L, margin bar
  │ My Copies section (if S7), Open Positions, Spot Holdings
  ▼ (User taps [+ New Trade])
Symbol Picker opens (Watchlist tab, Recents strip at top)
  │ User selects SOL-PERP
  ▼
C5-NEW (Calculator Entry — 5-Step Guided Flow)
  │ Step 1: LONG selected — Inline Lucid Signals Card shows:
  │   • Smart Money: 72% NET LONG
  │   • Leaders: 4 are LONG, Regime: Trending, 4/5 alignment
  │ Step 2: Risk $375 entered — Lucid hint: "7.2% of equity"
  │ Step 3: Safety Margin: 33% 🟢
  │ Step 4: Exit Plan — TP/SL pre-filled with ATR defaults
  │   • "83% of profitable traders use TP/SL" social proof
  │   • R:R: 2:1 inline
  │ Step 5: Quick Summary — Leverage 3x, Holding cost ~$3.20/day
  │
  │ User optionally taps "Advanced Trade Settings" for advanced
  │ User optionally taps [◆ Ask Lucid Before Trading]
  ▼
[Open LONG — $375 risk] CTA tapped
  │ checkCoolDown() → checkRegimeGate() → executeTradeConfirmed()
  │ Order submits to exchange
  ▼
C5 (Execution Monitor)
  │ Real-time fill tracking: 0% → 45% → 100%
  │ Celebration animation on complete fill
  ▼
Auto-navigates to C6 (Position Monitor)
  │ Lucid annotations:
  │ • Liquidation distance: 18.2km with historical context
  │ • "Regime still Trending ✅" tappable for regime probability
  │ • "Wallet consensus stable" tappable for activity details
  │ • Safety gauge animates from 0 → 18.2km
  │ • TP/SL already set by Lucid
  ▼
User can: [Close], [Add Margin], [Adjust TP/SL], [Add to Position]
  │
  └─→ Position held for 2h 30m...
      TP hits automatically
      ▼
      C7 (Trade Review - FULL SCREEN)
      │ Lucid analysis:
      │ • Kelly accuracy: You used 1.25x over guide
      │ • Regime alignment: Entered Trending ✅
      │ • Wallet consensus: 3 long, 1 short (strong agreement)
      │ • Behavioral insight: Your exit pattern shows 68% TP hit rate
      │ • Suggested trading rule: "Scale into Trending LONG at 0.33 Kelly"
      │ • Reflection prompt + 50 XP reward
      ▼
      Auto-navigates to Home or [Go to History] → TH1
```

### Flow 2: Reactive Leverage Behavior (C5-NEW at 15x+)

```
C5-NEW (Calculator Entry)
  │ User drags leverage slider toward 15x
  ▼
User releases at 15x
  │ • Slider turns deep red
  │ • Funding annotation: "~$47/day" in amber
  │ • Liquidation bar shrinks: 33% → 6.7%
  │ • CONTEXTUAL INSERTION appears (not floating):
  │   - Shows funding impact history
  │   - Kelly recommendation: 2.1x
  │   - Your win rate at >10x: 28%
  │   - [Adjust to Kelly (2.1x) ◆] button visible
  ▼
User taps [Adjust to Kelly (2.1x) ◆]
  │ • Leverage slider snaps back to 2.1x with spring animation
  │ • Contextual card collapses smoothly
  │ • Execute button slides back up
  │ • Funding annotation updates: ~$8/day
  │ • Liquidation bar expands: 6.7% → 28%
```

### Flow 3: Kelly Mark Interaction (C5-NEW Position Slider)

```
C5-NEW (Calculator Entry)
  │ Position Size Slider is visible with Kelly mark etched at $2,400
  │ Current slider position: $3,500 (above Kelly)
  ▼
User drags slider leftward toward Kelly mark
  │ • Slider thumb moves smoothly
  │ • As slider approaches Kelly mark, haptic pulse increases
  ▼
User releases at Kelly mark ($2,400)
  │ • Haptic detent (magnet-like snap)
  │ • Annotation updates: "◆ $2,400 = Kelly-recommended for your edge."
  │ • Slider position highlights
  │ • Position size updates to match
  ▼
User can adjust further or confirm with CTA
```

### Flow 4: Position Adjustment with Lucid Context (C6 Quick Actions)

```
C6 (Position Monitor)
  │ Liquidation distance: 12.1km (yellow zone — warning)
  │ Margin warning banner visible
  │ Annotation: "◆ Regime still Trending ✅" (tappable)
  ▼
User taps [Add Margin]
  ▼
Bottom sheet opens: "Add Margin"
  │ Current margin: $375
  │ Slider to adjust: [$188 add]
  │ New liq distance: 27.3km
  ▼
[Confirm Add Margin] tapped
  │ Spinner loops (1-2s)
  │ Margin updated on exchange
  ▼
C6 updates in real-time
  │ Liquidation distance: 27.3km (green zone)
  │ Margin warning banner disappears
  │ Position safety gauge re-animates to new value
```

### Flow 5: Copy Position with Attribution & Lucid Insights (C6 → D2)

```
C6 (Position Monitor)
  │ Shows: "📋 FROM @ProTrader (Elite ⭐)"
  │ Attribution badge visible
  │ Lucid annotation: "Wallet consensus: 3 other traders also LONG"
  ▼
User taps [View Leader →]
  ▼
Navigates to D2 (Trader Detail page)
  │ Shows @ProTrader's full profile
  │ Win rate, avg return, top trades
  │ Watchlist and current positions
  ▼
User can: [Follow], [Copy Positions], [View History]
```

### Flow 6: Trade Reflection & Learning with Lucid Insights (C7 - FULL SCREEN)

```
Trade closes (TP/SL/Manual/Liquidated)
  ▼
C7 (Trade Review) auto-navigates — FULL SCREEN EXPERIENCE
  │ Animations play: P&L count-up, bars fill, stars scale
  │
  │ Lucid Analysis displayed:
  │ • Kelly accuracy: You used 1.25x over guide
  │ • Regime alignment: Entered Trending ✅, exited Consolidating (but profitable)
  │ • Wallet consensus: 3 long, 1 short (strong agreement)
  │ • Behavioral insight: "Your exit pattern shows 68% TP hit rate"
  │ • Suggested trading rule: Pre-filled with Lucid recommendation
  ▼
User taps reflection prompt: "What would you do differently?"
  │ [Text input]
  ▼
[Save Reflection] tapped
  │ Reflection saved to trade journal
  │ +50 XP points awarded (blue checkmark animation)
  ▼
[Save as Trading Rule ◆] option
  │ Opens rule builder with Lucid suggestion pre-filled
  │ User can edit or accept as-is
  ▼
User can: [Review Again], [Go to History]
```

### Flow 7: Trade History with Lucid Performance Annotations (TH1)

```
User navigates to [Trade History]
  ▼
TH1 displays:
  │ Summary stats: 47 total, 64.9% win rate, Sharpe 1.67
  │ Cumulative equity curve (draws L→R)
  │ Filter chips: [All], [Wins], [Losses], [Symbol], [Regime], [Date]
  ▼
User taps [Wins] chip
  │ Filters to 30 winning trades
  │ Equity curve updates to show only wins
  │ Trade rows re-animate to show 30 trades
  ▼
User taps a trade row to expand
  │ Full trade detail displayed: entry/exit, duration, P&L, regime, consensus
  │ NEW: Lucid Assessment section:
  │ • "Aligned: Trending regime + 3 wallets. Strong setup."
  │ • "Slightly over Kelly sizing (1.25x). Consider 0.33 Kelly."
  ▼
User taps [View Details]
  ▼
Full trade analysis screen (read-only C7)
  │ Shows all insights from trade review
```

---

## MOCK DATA — Reference Set

**User: Jake (S2 - Aspiring Trader)**

**Portfolio:**

- Starting Capital: $7,500
- Current Balance: $8,400 (+8.7% last 30 days)
- Total Trades: 47
- Win Rate: 64.9% (30 wins, 16 losses, 1 breakeven)
- Consecutive Losses: 0 (`MOCK.user.consecutiveLosses` — triggers Cool-Down at 3+)
- Best Regime Win Rate: 72% (Trending) — used by Regime Gate

**Current Open Positions:**

| Symbol   | Direction | Leverage | Entry Price | Current Price | Position Size | Liquidation Distance   | P&L           | Time Open |
| -------- | --------- | -------- | ----------- | ------------- | ------------- | ---------------------- | ------------- | --------- |
| SOL-PERP | LONG      | 5x       | $187.20     | $187.20       | 0.0146 BTC    | 18.2 km (30.4 cushion) | +$0 (+0.0%)   | 12 min    |
| ETH-PERP | SHORT     | 3x       | $2,420      | $2,420        | 0.0075 ETH    | 9.2 km (12.1 cushion)  | -$0 (-0.0%)   | 4h 20m    |
| BTC      | SPOT      | 1x       | $71,200     | $71,200       | 0.00285 BTC   | No liq risk            | +$234 (+9.8%) | 8 days    |

**Last 5 Closed Trades:**

| #   | Symbol   | Direction | Entry   | Exit    | P&L      | ROE    | Duration | Regime          | Win/Loss | Source            |
| --- | -------- | --------- | ------- | ------- | -------- | ------ | -------- | --------------- | -------- | ----------------- |
| 47  | SOL-PERP | LONG      | $187.20 | $197.30 | +$108.90 | +29.1% | 2h 30m   | Trending ✅     | Win      | Radar Signal      |
| 46  | ETH-PERP | SHORT     | $2,420  | $2,405  | -$39.23  | -1.9%  | 6h 15m   | Consolidating ⚠ | Loss     | Manual            |
| 45  | BTC-PERP | LONG      | $71,200 | $72,400 | +$234.30 | +9.8%  | 3h 45m   | Trending ✅     | Win      | Radar AI Strategy |
| 44  | SOL-PERP | SHORT     | $182.50 | $185.10 | -$59.18  | -2.8%  | 1h 30m   | Consolidating ⚠ | Loss     | Manual            |
| 43  | BTC-PERP | LONG      | $69,800 | $71,200 | +$200.63 | +7.6%  | 8h 20m   | Consolidating ⚠ | Win      | Radar Signal      |

**Kelly Calculation (from journal):**

- Win Rate: 64% (30 wins / 47 trades)
- Payoff Ratio: 1.8 (avg win ÷ avg loss)
- Kelly Fraction: f\* = (0.64 × 1.8 - 0.36) / 1.8 = 17.8% of bankroll
- At 0.25x Kelly: 4.4% position size
- At 0.33x Kelly: 5.9% position size (RECOMMENDED for S2)
- At 0.50x Kelly: 8.9% position size

---

### COLD START SYSTEM — Smart Sizing (Kelly) & Reward-to-Risk

Both Smart Sizing (Kelly) and Reward-to-Risk personalization depend on the user's trade history (win rate, payoff ratio). New users don't have this data. The system uses a 3-phase progressive unlock tied to trade count, with copy trade borrowing as the cold start accelerator.

**Phase 1: No Data (0-9 trades) — "Fixed Conservative"**

Smart Sizing:

- Kelly mark is NOT shown on the position size slider
- Instead, a recommended green zone at 1-2% of account
- Annotation: "You have [N] trades so far. We need at least 10 to start learning your pattern. For now, risk 1-2% of your account per trade — this is the standard used by professional trading desks."
- [Position Sizing Guide ▼] section shows educational content only, no personalized numbers

Reward-to-Risk:

- Default floor: R:R ≥ 2:1 (positive EV even at 35% win rate: 0.35×2 − 0.65×1 = +$0.05 per $1)
- TP/SL pre-fills use structural levels (support/resistance) but constrain to ≥2:1
- If structural levels produce R:R < 2:1, system flags: "Reward-to-risk is 0.8:1 — below the safe minimum. Consider waiting for a better entry or adjusting your levels."
- Annotation: "We default to 2:1 reward-to-risk. This gives you positive edge even while learning."

**Phase 2: Early Data (10-29 trades) — "Emerging Pattern"**

Smart Sizing:

- Kelly mark appears on slider but as a **wide shaded band** (not a crisp line) reflecting the wide confidence interval
- Fractional multiplier auto-locked to 0.25x Kelly (most conservative)
- Only [Conservative] and [Moderate] presets visible — [Aggressive] is hidden
- Annotation: "Based on [N] trades (early data), your pattern is emerging. Smart sizing suggests [X-Y%] range. We'll refine as you trade more."
- 95% CI shown explicitly: "Confidence range: 2.8% - 7.1% of account"

Reward-to-Risk:

- System shows emerging win rate and what it implies
- Default floor tightens from 2:1 to 1.5:1
- Annotation: "Your win rate so far: 58% (12 trades). You can be profitable with R:R as low as 0.72:1. We still recommend ≥1.5:1 until you have 30+ trades."
- TP/SL pre-fills start incorporating user's historical TP hit rate if available

**Phase 3: Reliable Data (30+ trades) — "Full Unlock"**

Smart Sizing:

- Full Kelly mark as crisp line with narrow confidence band
- All three presets visible: [Conservative 0.25x], [Moderate 0.33x], [Aggressive 0.50x]
- Annotation: "Based on 47 trades (64% wins, 1.8:1 payoff), math suggests max 5.9% risk."

Reward-to-Risk:

- Personalized minimum: "Your win rate: 64%. Your breakeven R:R: 0.56:1. Recommended minimum: 1.0:1. Sweet spot: 2:1 (68% TP hit rate at this level)."
- TP/SL suggestions incorporate user's own TP hit rate by regime and instrument

**Copy Trade Borrowing (Cold Start Accelerator)**

When a user copies a leader, the leader's track record BECOMES the user's effective track record for those trades. The system bootstraps both Kelly and R:R using the leader's stats:

Smart Sizing with leader data:

- Kelly calculated using leader's win rate and payoff ratio for the specific instrument
- Annotation: "Based on @ProTrader's record (62% WR, 2.1:1 payoff over 180 trades)"
- Leader's Kelly mark drawn on slider with leader attribution badge
- Fractional multiplier still conservative (0.25x) since execution may differ

R:R with leader data:

- Minimum R:R floor computed from leader's win rate
- TP/SL defaults use leader's historical patterns for the instrument
- Annotation: "Based on @ProTrader's 62% win rate, you can target R:R as low as 0.61:1. Their typical R:R: 2.3:1."

Graduated S2 (Trade Myself after copying):

- Blended stats: own trades + leader's copied trades (at 0.7x confidence weighting)
- "Based on your 8 own trades + 15 copied from @ProTrader (blended)"
- As own trade count grows, leader weight naturally diminishes
- At 30+ own trades, system switches to own-only stats with option to view blended

**Cold Start Phase Display (C5-NEW Position Sizing Guide section):**

```
Phase 1 (0-9 trades):
┌──────────────────────────────────────┐
│ 📐 Position Sizing Guide             │
│                                      │
│ You have 3 trades so far.            │
│ We need 10+ to learn your pattern.   │
│                                      │
│ Recommended: 1-2% of account         │
│ ┌─────────────────────────────┐     │
│ │██ 1-2% ░░░░░░░░░░░░░░░░░░│     │
│ └─────────────────────────────┘     │
│ You're at 1.5% ✅ Good              │
│                                      │
│ [▶ Learn about Smart Sizing]         │
└──────────────────────────────────────┘

Phase 2 (10-29 trades):
┌──────────────────────────────────────┐
│ 📐 Smart Sizing — Emerging Pattern   │
│                                      │
│ Based on 18 trades (61% wins, early) │
│ ┌─────────────────────────────┐     │
│ │░░░░░▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░│     │
│ └─────────────────────────────┘     │
│  ←── 2.8% ───── 5.1% ──→           │
│  (wide confidence band)              │
│                                      │
│ [Conservative: 2.8%]  ← locked      │
│ [Moderate: 3.8%]                     │
│                                      │
│ You're at 4.2% — ✅ Within range    │
│ Refining with each trade...          │
└──────────────────────────────────────┘

Phase 2 with copy leader:
┌──────────────────────────────────────┐
│ 📐 Smart Sizing — Leader-Powered     │
│                                      │
│ Based on @ProTrader's record         │
│ (62% WR, 2.1:1 payoff, 180 trades)  │
│ ┌─────────────────────────────┐     │
│ │░░░░░░░░░◆░░░░░░░░░░░░░░░░│     │
│ └─────────────────────────────┘     │
│           5.4% (leader Kelly)         │
│                                      │
│ [Conservative: 3.6%]                 │
│ [Moderate: 5.4%] ← leader-powered   │
│                                      │
│ You're at 4.8% — ✅ Good            │
│ 📋 Using @ProTrader's track record  │
└──────────────────────────────────────┘

Phase 3 (30+ trades):
┌──────────────────────────────────────┐
│ 📐 Smart Sizing — Full Unlock        │
│                                      │
│ Based on 47 trades (64% wins, 1.8:1) │
│ ┌─────────────────────────────┐     │
│ │░░░░░░░░░█░░░░░░░░░░░░░░░░│     │
│ └─────────────────────────────┘     │
│           ◆ Kelly: 5.9%              │
│                                      │
│ [Conservative: 4.4%]                 │
│ [Moderate: 5.9%] ← RECOMMENDED      │
│ [Aggressive: 8.9%]                   │
│                                      │
│ You're at 7.2% — ⚠ Slightly over   │
└──────────────────────────────────────┘
```

**R:R Cold Start Display (C5-NEW Safety Limits section):**

```
Phase 1 (no data):
┌──────────────────────────────────────┐
│ Reward-to-Risk: 2.0:1               │
│ "For every $1 you risk, targeting $2"│
│                                      │
│ ✅ Above safe minimum (2:1)          │
│ We'll personalize this after 10+     │
│ trades.                              │
└──────────────────────────────────────┘

Phase 3 (personalized):
┌──────────────────────────────────────┐
│ Reward-to-Risk: 2.3:1               │
│ "For every $1 you risk, targeting $2.30"│
│                                      │
│ Your breakeven R:R: 0.56:1          │
│ Your sweet spot: 2:1 (68% TP hit rate)│
│ Current: 2.3:1 ✅ Strong             │
└──────────────────────────────────────┘
```

---

**Lucid Suggestions (for current symbol SOL-PERP at $187.20):**

- Take Profit: $198.50 (6.1% above entry, based on Trending regime + 1.2x ATR)
- Stop Loss: $175.90 (6.1% below entry, based on support level)
- Risk Budget: $375 (user's recent risk preference)
- Confluence Badge: 4/5 alignment (regime ✓, wallet ✓, volatility ✓, momentum ✓)

**Regime Context (current):**

- Current Regime: Consolidating
- Previous Regime: Trending
- Regime Strength: Medium
- Regime Change Probability (next 4h): 35% (moderate)

**Wallet Consensus (for SOL position entry):**

- Direction: LONG
- Consensus: 3 All-Weather wallets also LONG
- 1 contrarian wallet SHORT
- Consensus Strength: High agreement

---

## COMPONENT LIBRARY — Reusable Elements

### Liquidation Distance Gauge (C5-NEW, C6)

```
┌─────────────────────────────────┐
│ Liquidation Distance: 18.2 km   │
│                                 │
│ ████████████ 🟢 >20% Safe      │  (progress bar)
│ Entry ──────────────────── Liquidation │  (distance scale)
│                                 │
│ Colors:                         │
│ 🟢 Green: 20% +                │
│ 🟡 Yellow: 10-20%             │
│ 🔴 Red: <10%                  │
│                                 │
│ Animation on load (C6):         │
│ • 500ms spring sweep: 0 → value │
│ • Color fills proportionally    │
│ • Number count-up: 0 → 18.2 km │
│                                 │
│ On load (C5-NEW):              │
│ • Smooth as leverage changes   │
│ • Color zone transitions      │
│ • Historical context annotation│
└─────────────────────────────────┘
```

### Position Size Slider with Kelly Mark (NEW)

```
┌─────────────────────────────────┐
│ Position Size Slider            │
│          ◆ Kelly                │
│           ◇                     │
│ ┌──────────┼────────────────────┤
│ │░░░░░░░░░█░░░░░░░░░░░░░░░░   │
│ └──────────┼────────────────────┘
│ $100      $2,400           $7,316
│                                 │
│ Features:                       │
│ • Kelly mark etched at $2,400   │
│ • Haptic detent at Kelly        │
│ • Color: green when below Kelly │
│ • Color: amber when at Kelly    │
│ • Color: red when above Kelly   │
│                                 │
│ ◆ $2,400 = 19.2% of equity.    │
│ Kelly: 6.2% at conservative.   │
│ Based on 64% win rate + 1.8 payoff. │
└─────────────────────────────────┘
```

### Leverage Slider with Real-Time Funding (NEW)

```
┌─────────────────────────────────┐
│ Leverage: [5x]  ◀─────▶         │
│            🟢 Safe (1-5x)       │
│                                 │
│ Color gradient:                 │
│ 🟢 Green:  1-5x (safe)         │
│ 🟡 Yellow: 5-10x (caution)     │
│ 🔴 Red:    10x+ (extreme)      │
│                                 │
│ Real-time annotation:           │
│ ◆ 3x is within your preferred  │
│   range (3-5x). Funding cost   │
│   at 3x: ~$3.20/day.           │
│                                 │
│ At 15x+:                        │
│ • Slider turns deep red         │
│ • Annotation: "~$47/day" amber  │
│ • Contextual card appears       │
└─────────────────────────────────┘
```

### Contextual Insertion Card (NEW - Reactive at 15x+)

```
┌─ ◆ CONTEXT ────────────────────┐
│ Funding at 15x: -$47/day       │
│                                │
│ Last 3x funding was this       │
│ negative: price dropped 12%    │
│ within 48h                     │
│                                │
│ Kelly sizing for this setup:   │
│ 2.1x                           │
│                                │
│ Your win rate at >10x leverage: 28% │
│                                │
│ [Adjust to Kelly (2.1x) ◆] [✕]│
└────────────────────────────────┘
```

### Kelly Guide Sidebar (C5-NEW)

```
┌─────────────────────────────────┐
│ Kelly Sizing Guide (slides R)   │ (300ms spring)
│                                 │
│ Step 1: Edge Stats              │ (collapsible)
│ ├─ Win Rate: 64%                │
│ ├─ Payoff Ratio: 1.8            │
│ └─ Sample: 47 trades            │
│                                 │
│ Step 2: Regime Filter           │ (slider to adjust)
│ Current: Trending ✅            │
│ Adjust: [−10% | Keep | +10%]   │
│                                 │
│ Step 3: Kelly Fraction          │ (formula visible)
│ f* = (W×R - (1-W)) / R = 17.8% │
│                                 │
│ Step 4: Confidence Intervals    │ (CI at 95%)
│ 95% CI: 14.2% - 21.6%          │
│                                 │
│ Step 5: Your Size               │ (preset buttons)
│ Conservative: 4.4%              │
│ Moderate:    5.9%  ← RECOMMENDED
│ Aggressive:  8.9%               │
│                                 │
│ You're using: 7.2%              │
│ Status: ✅ Within range          │
│                                 │
│ [Use Conservative]              │ (buttons fill on tap)
│ [Use Moderate]                  │
│ [Use Aggressive]                │
└─────────────────────────────────┘
```

### Safety Gauge (C6)

```
┌─────────────────────────────────┐
│ Liquidation Distance            │
│        18.2 km away             │ (large text)
│                                 │
│ ████████████ 🟢 SAFE (>20%)    │ (radial gauge)
│ Entry ─────────────────── Liquidation   │
│                                 │
│ Animation (on load):            │
│ • Gauge sweeps 0 → 18.2 km     │
│ • 500ms spring easing           │
│ • Color fills with gauge        │
│ • Number counts up              │
│ • Haptic: subtle buzz           │
│                                 │
│ If <10% (red zone):             │
│ • Pulsing animation (brightness)│
│ • Continuous pulse loop         │
│ • Red color maintained          │
└─────────────────────────────────┘
```

### Bottom Sheet (C6 Actions)

```
┌─────────────────────────────────┐
│ ◀ Close Position  [X Close]     │ (header)
├─────────────────────────────────┤
│                                 │
│ Position: 0.0146 BTC            │
│ Size: $2,051                    │
│                                 │
│ Close Amount: [0.0146]          │ (input field)
│                                 │
│ ──────────────────────────────  │
│ [Close 25%] [Close 50%]         │ (preset buttons)
│ [Close 75%] [Close All]         │
│                                 │
│ Estimated Return: 0.0146 BTC    │
│ (no change from entry)          │
│                                 │
│ ────────────────────────────────│
│ [Confirm Close]                 │ (CTA, large)
│                                 │
│ Sheet animation:                │
│ • Slides up from bottom (200ms) │
│ • Slight bounce on settle       │
│ • Dismiss: tap outside / back   │
└─────────────────────────────────┘
```

### Celebration Animation (C5 on fill)

```
Sequence (simultaneous, ~800ms total):

1. Confetti burst
   • 30 particles
   • Colors: gold, silver, green
   • Falls from top → bottom (300ms)
   • Fade out at bottom
   • Haptic: light buzz

2. Checkmark Lottie
   • Green check (✅) scales in
   • Spring easing: 0.5 → 1.0 scale
   • Bounce on settle (800ms)
   • Haptic: 3-pulse success pattern

3. Text overlay
   "Order Filled!"
   "SOL LONG 5x"
   "$2,051 position"

4. Auto-navigate after 2-3s
   • C5 → C6 (Position Monitor)
   • User can tap [View Position →] to skip
```

### Equity Curve Chart (TH1)

```
Drawing sequence (800ms L→R):

  ╱╲    ╱╲    ╱╲
 ╱  ╲  ╱  ╲  ╱  ╲
      ╲╱        ╲╱  ────────────

Start: $7,500                Cur: $8,400

Regime bands (background):
🟢 Trending: high equity slope
⚫ Consolidating: flat sections
🔴 Declining: downward slope

Interaction:
• Tap point → drill to date + P&L
• Swipe L/R → shift time window
• Pinch to zoom → expand time axis
```

---

## ANIMATION & HAPTIC REFERENCE

| Animation                        | Duration | Easing               | Haptic                        | Context                             |
| -------------------------------- | -------- | -------------------- | ----------------------------- | ----------------------------------- |
| Portfolio sparkline draw         | 400ms    | ease-out             | None                          | TH Portfolio Summary load           |
| Margin bar fill                  | 300ms    | ease-out             | None                          | TH Portfolio Summary load           |
| Regime Gate modal appear         | 200ms    | spring (0.8 damping) | Warning buzz                  | C5-NEW execute with regime mismatch |
| Cool-Down modal appear           | 200ms    | spring (0.8 damping) | Warning buzz                  | C5-NEW execute after 3+ losses      |
| Fine-tune expand/collapse        | 200ms    | ease-in-out          | None                          | C5-NEW Fine-tune toggle             |
| Lucid Signals Card update        | 150ms    | ease-out             | None                          | C5-NEW direction change             |
| Leverage slider color transition | 200ms    | ease-in-out          | None                          | Zone boundary cross                 |
| Kelly guide slide-in             | 300ms    | spring (0.8 damping) | Light tap on open             | C5-NEW guide trigger                |
| Position slider Kelly detent     | 100ms    | spring (0.9 damping) | Haptic magnet-like snap       | C5-NEW Kelly interaction            |
| Liquidation gauge sweep          | 500ms    | spring (0.7 damping) | Subtle pulse                  | C6 on load                          |
| Contextual insertion appear      | 300ms    | spring (0.8 damping) | None                          | C5-NEW at 15x+                      |
| Leverage snap to Kelly           | 400ms    | spring (0.7 damping) | Haptic with animation         | C5-NEW reactive behavior            |
| Countdown circle draw            | 5000ms   | linear               | Short buzz every 1000ms       | C5-NEW at ≥10x                      |
| Confetti burst                   | 300ms    | gravity physics      | Light buzz (vibrate)          | C5 on complete fill                 |
| Checkmark bounce                 | 800ms    | spring (0.6 damping) | 3-pulse on settle             | C5 celebration                      |
| Fill bar animate                 | 200ms    | ease-out             | Subtle tick on complete       | C5 real-time update                 |
| Bottom sheet slide-up            | 200ms    | spring (0.8 damping) | Subtle tap on settle          | C6 quick actions                    |
| Star rating scale-in             | 600ms    | spring (0.7 damping) | 5 short pulses (one per star) | C7 on load                          |
| Equity curve draw                | 800ms    | ease-in              | None                          | TH1 on load                         |
| Trade row expand                 | 200ms    | ease-in-out          | None                          | TH1 row tap                         |

---

## NAVIGATION ARCHITECTURE

**Tab Bar (always visible):**

- Home, Radar, Trade (active, position 3), Markets, You

**Trade Module Stack:**

```
TH (Trade Hub — Portfolio-First)
├─ → Symbol Picker (when [+ New Trade] tapped)
│   └─ → C5-NEW (Calculator Entry, on symbol selection)
│       ├─ → Regime Gate / Cool-Down modals (on execute)
│       ├─ → C5 (Execution Monitor, on order submit)
│       │   └─ → C6 (Position Monitor, on fill complete)
│       │       ├─ → Bottom Sheets (Close, Margin, TP/SL, Add)
│       │       ├─ → D2 (Trader Detail, if [View Leader →] tapped)
│       │       └─ → C7 (Trade Review FULL SCREEN, on position close)
│       │           └─ → TH1 (Trade History, if [Go to History] tapped)
│       │
│       └─ → (Symbol Picker, if symbol header tapped on C5-NEW)
│
├─ → Lucid Chat (G1, when [◆ Ask Lucid] tapped)
│
├─ → C6 (Position Monitor, if position card or copy card tapped)
│   └─ → (same flow as above)
│
├─ → Radar (if "Browse traders ›" tapped from My Copies)
│
└─ → TH1 (Trade History, if [View History] button tapped)
    └─ → C7 (Trade Review, if trade row [View Details] tapped)
```

**Back Navigation:**

- All screens support ◀ back button (except TH)
- Swipe right edge gesture also pops screen
- TH is modal root; back from TH goes to Home tab

---

## DEPENDENCY & INTEGRATION POINTS

| Dependency                  | Source                        | Integration                                                                                              |
| --------------------------- | ----------------------------- | -------------------------------------------------------------------------------------------------------- |
| TradeIntent                 | C3 (Markets) or R-AI2 (Radar) | Received as navigation parameter, pre-fills C5-NEW fields                                                |
| Current Symbol Price        | Price Stream API              | Real-time updates in TH, C5-NEW, C5, C6                                                                  |
| User's Trade Journal        | Local DB + Cloud Sync         | Feeds Kelly edge stats (win rate, payoff ratio) for C5-NEW guide; Lucid insights in C7/TH1               |
| Regime Context              | Radar or Backend              | Used in C5-NEW, C6, C7 for alignment validation; Lucid annotations throughout                            |
| Wallet Consensus            | W3 Blockchain                 | Shows copy source in C6, comparison in C7; Lucid consensus strength indicators                           |
| Lucid Suggestions           | Lucid AI Engine               | Pre-fills TP/SL in C5-NEW based on regime + volatility + behavioral patterns; annotations in C6, C7, TH1 |
| Order Submission API        | Exchange API                  | C5-NEW → C5 order flow                                                                                   |
| Position Stream API         | Exchange API                  | Real-time updates in C6 (P&L, margin, liquidation distance)                                              |
| User Account Settings       | Account Module                | Risk tolerance, leverage limits, display currency                                                        |
| Historical Volatility Data  | Backend                       | Liquidation distance context annotations in C5-NEW and C6                                                |
| Behavioral Pattern Analysis | Lucid Engine                  | Trailing stop recommendations, TP hit rate insights, exit pattern recognition                            |

---

## MOCK DATA — Detailed Trade Examples

**Trade 1: Winning Trade (SOL LONG)**

```json
{
  "id": "trade_47",
  "symbol": "SOL-PERP",
  "direction": "LONG",
  "leverage": 5,
  "source": "radar_signal",
  "entry_time": "2026-03-10T12:17:00Z",
  "entry_price": 187.2,
  "entry_size": 0.0146,
  "entry_risk": 500000,
  "exit_time": "2026-03-10T14:47:00Z",
  "exit_price": 197.3,
  "exit_size": 0.0146,
  "pnl_won": 145200,
  "roe_percent": 29.1,
  "duration_minutes": 150,
  "regime_at_entry": "TRENDING",
  "regime_at_exit": "CONSOLIDATING",
  "regime_alignment": true,
  "kelly_suggested_size": 400000,
  "actual_size": 500000,
  "kelly_multiple": 1.25,
  "tp_set": 198.5,
  "sl_set": 175.9,
  "exit_reason": "tp_hit",
  "wallet_consensus_direction": "LONG",
  "wallet_consensus_count": 3,
  "take_profit_hit": true,
  "reflection": "Entered in correct regime (Trending). Should have held longer when regime shifted—cut position too early.",
  "lucid_assessment": "Aligned: Trending regime + 3 wallets. Strong setup. Slightly over Kelly sizing (1.25x). Consider 0.33 Kelly for future similar conditions.",
  "behavioral_pattern": "Exit pattern shows 68% TP hit rate at this risk level. Recommend trailing stop (2%) for similar setups.",
  "suggested_rule": "Scale into Trending regime LONG positions sized at 0.33 Kelly when wallet consensus >= 3."
}
```

**Trade 2: Losing Trade (ETH SHORT)**

```json
{
  "id": "trade_46",
  "symbol": "ETH-PERP",
  "direction": "SHORT",
  "leverage": 3,
  "source": "manual",
  "entry_time": "2026-03-09T16:45:00Z",
  "entry_price": 2420.0,
  "entry_size": 0.0075,
  "entry_risk": 350000,
  "exit_time": "2026-03-09T23:00:00Z",
  "exit_price": 2405.0,
  "exit_size": 0.0075,
  "pnl_lost": -52300,
  "roe_percent": -1.9,
  "duration_minutes": 375,
  "regime_at_entry": "CONSOLIDATING",
  "regime_at_exit": "CONSOLIDATING",
  "regime_alignment": false,
  "kelly_suggested_size": 300000,
  "actual_size": 350000,
  "kelly_multiple": 1.17,
  "tp_set": 2390.0,
  "sl_set": 2450.0,
  "exit_reason": "manual",
  "wallet_consensus_direction": "LONG",
  "wallet_consensus_count": 2,
  "against_consensus": true,
  "reflection": "Traded against wallet consensus. Consolidating regime had low edge. Should have waited for Trending confirmation.",
  "lucid_assessment": "Regime mismatch warning: Consolidating regime has lower edge for your profile. Traded against 2-wallet consensus. Both factors reduced probability of success.",
  "behavioral_pattern": "You tend to trade against consensus in low-edge regimes. This pattern has 31% win rate. Avoid in Consolidating.",
  "suggested_rule": "Skip trades that conflict with both regime (Consolidating) and wallet consensus (LONG)."
}
```

**Trade 3: Big Winner (BTC LONG)**

```json
{
  "id": "trade_45",
  "symbol": "BTC-PERP",
  "direction": "LONG",
  "leverage": 2,
  "source": "radar_ai_strategy",
  "entry_time": "2026-03-08T15:30:00Z",
  "entry_price": 71200.0,
  "entry_size": 0.00437,
  "entry_risk": 250000,
  "exit_time": "2026-03-08T19:15:00Z",
  "exit_price": 72400.0,
  "exit_size": 0.00437,
  "pnl_won": 312400,
  "roe_percent": 9.8,
  "duration_minutes": 225,
  "regime_at_entry": "TRENDING",
  "regime_at_exit": "TRENDING",
  "regime_alignment": true,
  "kelly_suggested_size": 220000,
  "actual_size": 250000,
  "kelly_multiple": 1.14,
  "tp_set": 73500.0,
  "sl_set": 70000.0,
  "exit_reason": "tp_hit",
  "wallet_consensus_direction": "LONG",
  "wallet_consensus_count": 4,
  "strong_consensus": true,
  "reflection": "Perfect setup: entered Trending regime with 4-wallet consensus. Used conservative leverage. Textbook execution.",
  "lucid_assessment": "Best setup type for you: Trending regime + 4-wallet consensus + conservative Kelly sizing (1.14x). This combination shows 76% win rate in your history.",
  "behavioral_pattern": "This is your highest-confidence pattern. Replicate: Trending + 4+ wallets + 1-1.2x Kelly = 76% win rate, 2.3:1 payoff.",
  "suggested_rule": "Priority setup: Trending regime with 4+ wallet consensus, 0.25-0.33 Kelly sizing. Your edge: 76% win rate, 2.3:1 payoff."
}
```

---

## PERFORMANCE & TECHNICAL NOTES

**Critical Performance Metrics:**

- C5 fill bar update latency: <200ms (real-time)
- C6 liquidation distance update: <500ms
- Symbol switch animation (TH): 200ms crossfade (smooth, not laggy)
- Bottom sheet open: <200ms
- Trade history equity curve draw: 800ms (smooth animation, not jumpy)
- Position size slider Kelly detent haptic: <50ms response time
- Leverage slider funding annotation update: <100ms debounce

**Data Fetching:**

- TH position overview: cached, update every 5s
- C5-NEW calculator: live inputs, update every 100ms (debounced on leverage slider)
- C5 execution: streaming updates from exchange (WebSocket)
- C6 position: streaming updates, refresh every 2s minimum
- TH1 history: paginated, 20 trades per page, load more on scroll
- Lucid annotations: cached from backend, refresh on screen load

**Offline Handling:**

- TH: show cached positions with "Last updated X min ago"
- C5-NEW: disable CTA if offline, show banner
- C5: show "Reconnecting..." if connection drops, auto-retry
- C6: show "Offline mode" with warning, disable margin/adjust actions
- TH1: show cached data, disable filters until reconnected
- Lucid annotations: gracefully degrade to basic metrics if Lucid engine unavailable

---

## CHANGELOG — Version 10.2 (Trade Parameter Redesign)

> **Upstream:** Arx_Trade_Parameter_Redesign_Proposal.md

### Major Changes in v10.2:

**1. C5-NEW PERPS CALCULATOR ENHANCEMENTS (Trade Parameter Redesign)**

- **Regime Bar** added at top of calculator — persistent bar showing current market regime with confidence %, color-coded, bell icon for alerts
- **"WHAT THE MARKET IS SAYING"** header on Lucid Signals Card (Step 1) with cyan left border — renamed from generic "LUCID SIGNALS"
- **Risk % quick-select pills [1%] [2%] [5%]** added beside risk amount input in Step 2. Tapping auto-computes dollar amount from equity. Color-coded evidence: green (<3%), yellow (3-5%), red (>5%)
- **Kelly suggestion** shown as separate Lucid evidence block below risk amount (was inline hint)
- **"How much can you afford to lose?"** — reframed question text (was "How much to risk?")
- **Safety Margin renamed to "Liquidation Distance"** — now dynamically computed from leverage with color emoji (green/yellow/red)
- **Exit Plan (Step 4) enhanced:**
  - Shows TP/SL in both % AND $ amounts (e.g., +6.1% (+$153), -6.1% (-$500))
  - "Clear TP" / "Clear SL" links with **TP/SL removal friction dialog** (`tradeTPSLRemoveFriction(type)`) — behavioral speed bump with social proof nudge, [Keep] primary + [Remove Anyway] secondary
  - Trailing stop shows "2%" with behavioral recommendation ("you tend to exit winners early (+3%)")
  - **"Set by default" badge** replaces "Recommended"
- **Review Summary (Step 5) enhanced:** Now shows Position Size in units (e.g., "3.34 SOL ($625)") and Liquidation price explicitly
- Advanced sections order maintained: Leverage → Safety Limits → Position Sizing → Holding Cost → Risk Isolation → Order Type → Risk Scenarios

**2. SPOT CALCULATOR COMPLETE REDESIGN (`buildSpotTrade()` rewrite)**

- **Regime Bar** added (same as perps)
- **"You own X SOL"** ownership context shown below ticker
- **"View in Markets ->"** link on chart
- **BUY/SELL toggle** — SELL disabled if no holdings
- **Portfolio % quick pills [25%] [50%] [75%] [100%]** for amount selection (computes from available balance)
- **Lucid evidence:** portfolio allocation % with single-asset guideline
- **Market Info card** enhanced: best price, est. slippage in $ (was %), ownership info
- **Ownership education** Lucid block: "No leverage. No liquidation risk. No holding costs."
- **"Advanced Trade Settings" expandable** replaces old "Advanced Options", containing:
  1. Order Type (Market/Limit toggle)
  2. Sell Target (auto-sell at price with % gain display)
  3. Price Alert (notification-only, explicitly labeled "not an order")
  4. DCA Setup (Daily/Weekly/Monthly frequency pills with amount per interval, historical comparison evidence block)

**3. NEW RISK MANAGEMENT FUNCTIONS**

- `tradeTPSLRemoveFriction(type)` — Confirmation dialog when clearing TP or SL. Shows risk warning + social proof, [Keep] primary + [Remove Anyway] secondary. Logged for Lucid behavioral analysis.
- `detectTradeStyle()` — S2/S7 detection from `journeyState`. Sets `state.tradeStyle = 'active'` (S2) or `'copy'` (S7). Affects signal card emphasis and copy attribution display.

**4. NEW STATE VARIABLES**

- `state.tradeStyle` — `'active'` (S2) or `'copy'` (S7), set by `detectTradeStyle()`
- `state.spotAmount` — Spot trade dollar amount (default 500)
- `state.spotDir` — `'BUY'` or `'SELL'` for spot trades
- `state.tradeInstrType` — `'perps'` or `'spot'` (existed since v9.0, now explicitly documented as primary routing state)

### Backwards Compatibility:

- All 6 screens still present (TH, C5-NEW, C5, C6, C7, TH1)
- All data models compatible
- `state.tradeInstrType` already existed; new state variables are additive
- "Safety Margin" terminology preserved in C6 Position Monitor (only renamed in C5-NEW calculator context to "Liquidation Distance")
- Leverage color zones unchanged (green 1-5x, yellow 5-10x, red 10+x)

---

## CHANGELOG — Version 10.0

### Major Changes in v10.0:

**1. TH (TRADE HUB) REDESIGN — v3.0 → v4.0: PORTFOLIO-FIRST HUB**

- Removed single-ticker Symbol Header (swipeable ticker) and Price Pulse Widget
- Hub is now symbol-independent — computes totals from `MOCK.positions` and `MOCK.spotHoldings`
- New Portfolio Summary Card: Total Equity, Unrealized P&L (% + absolute), 30-point equity mini-sparkline with gradient, Margin utilization bar (used vs available with % label), Breakdown by type (Positions $ + Spot $)
- Quick Actions row: [+ New Trade] (opens Symbol Picker) + [◆ Ask Lucid] (opens Lucid chat)
- My Copies section (S7 users): shows copy positions with leader attribution ("Copied from @whale"), safety dots, leader status ("Leader still in" / "Leader exited"), signal strength
- Open Positions: ALL positions with safety margin percentage as primary metric (color dots: 🟢>20% 🟡10-20% 🔴<10%)
- Spot Holdings section: token holdings with quantity, USD value, P&L (no liquidation risk)

**2. C5-NEW (CALCULATOR ENTRY) REDESIGN — v5.0 → v6.0: 5-STEP GUIDED FLOW**

- Basic/Advanced toggle REMOVED — replaced with unified 5-step flow + "Advanced Trade Settings" expandable
- `isAdvanced` state variable no longer used by perps calculator
- Step 1: Direction [LONG/SHORT] + Inline Lucid Signals Card (Smart Money %, leader positions, regime, funding, signal strength) — signals co-located with direction decision
- Step 2: Risk Amount with Lucid hint (% of equity + professional guideline)
- Step 3: Safety Margin gauge (unchanged)
- Step 4: Set Your Exit Plan — TP/SL PROMOTED from buried Advanced section. Encouragement card with green left border + "Recommended" badge, social proof ("83% of profitable traders use TP/SL"), two-column TP/SL with ATR-based smart defaults pre-filled, R:R ratio inline ("2:1 — For every $1 risk, $2 target"), trailing stop checkbox, Lucid hit rate annotation
- Step 5: Quick Summary — compact card showing Leverage, Holding cost, Order type, Margin mode
- "Advanced Trade Settings" — single `<details>` (collapsed) containing 7 nested `<details>`: Adjust Leverage, Adjust Safety Limits, Position Sizing Guide, Holding Cost Details, Risk Isolation, Order Type, Risk Scenarios
- [◆ Ask Lucid Before Trading] — full-width button above Execute CTA
- Execute CTA: "Open LONG/SHORT — $X risk" + "Review in test mode →" link

**3. RISK CONTROLS — REGIME GATE + COOL-DOWN PROTECTION**

- `checkRegimeGate()`: compares user's win rate in current regime vs best regime. If gap >20pp, shows warning modal with regime WR comparison, [Cancel Trade] / [I Understand, Proceed]. **v9.3:** Now uses per-instrument regime (`inst.regime`) instead of global `MOCK.regime.label` — e.g., SOL may be Trending while global market is Range-bound. Warning message includes instrument name: "Going LONG in a Volatile regime for SOL".
- `checkCoolDown()`: consecutive loss protection after 3+ losses. Shows modal with loss count, [Set 4h Timer] / [Override — I Reviewed My Process]
- Execution chain: `executeConfirm()` → `checkCoolDown()` → `checkRegimeGate()` → `executeTradeConfirmed()`
- New mock data field: `MOCK.user.consecutiveLosses` (default: 0)

**4. SYMBOL PICKER ENHANCEMENTS**

- Watchlist is now default landing tab (`symbolPickerTab = 'watchlist'`)
- Recents horizontal strip: last 5 tapped instruments shown at top before tabs (when not searching)
- Asset class tabs expanded: ★ Watchlist, All, Perps, Spot, Stocks, FX, Commodities
- "Hot Right Now" section in Watchlist tab
- Sort options row: Volume (default), 24h Change, Signal Strength (`symbolSortMode = 'volume'`)
- `openSymbolPicker()` resets to watchlist tab and volume sort on every open

**5. MULTI-ASSET CALCULATORS — buildStockTrade() + buildCommodityTrade() IMPLEMENTED**

- `buildStockTrade(inst)`: BUY/SELL toggle (not LONG/SHORT), fractional shares display, Portfolio Allocation gauge (replaces Safety Margin — no liquidation for stocks), market status indicator (Pre-Market/Open/After-Hours/Closed based on ET), "Queue Order for Open" when market closed, 5 advanced sections
- `buildCommodityTrade(inst)`: LONG/SHORT toggle (leveraged CFDs), Safety Margin gauge (has liquidation), commodity-specific leverage ranges (Gold 20x, Oil 50x, Agriculture 15x), 6 advanced sections including Seasonal & Macro Context (OPEC for oil, FOMC for gold, planting/harvest for agriculture)

---

## CHANGELOG — Version 9.0

### Major Changes in v9.0:

**1. INTERACTIVE CHART ON TRADE SCREENS**

- Both perps (C5-NEW) and spot trade screens now embed an interactive TradingView-like chart
- HTML5 Canvas rendering via `drawInteractiveChart(canvasId, inst, height)` — 60 OHLC candlesticks (green up, red down)
- MA7 (cyan `#22D1EE`) and MA20 (purple `#8B5CF6`) overlay lines
- Volume histogram bars at bottom (15% of chart height, semi-transparent)
- Touch/mouse crosshair with price label + time label; OHLC data bar on hover/touch
- 500ms cubic ease-out animated entrance drawing left-to-right
- Canvas IDs: `tradeChartCanvas_${sym}` (perps), `spotChartCanvas_${sym}` (spot); 140px height
- "View in Markets →" pill (top-right) links to C3 asset detail

**2. SPOT TRADE ROUTING FIX**

- PERPS/SPOT toggle on calculator header now properly routes to spot instruments
- `state.tradeInstrType` set to `'spot'` on SPOT tap; `buildTrade()` resolves matching spot instrument (e.g., SOL-PERP → SOL-SPOT)
- `buildSpotTrade(spotInst)` renders full spot calculator: header with SPOT active, ticker + price with symbol picker, interactive chart, BUY/SELL toggle (green BUY default), amount input ($500 default with token qty estimate), market info card (best price, slippage, no leverage, no liquidation), Lucid ownership block, collapsible Advanced Options (price alert, sell target, DCA setup), execute CTA
- Switching back to PERPS restores the perps calculator with the same symbol

---

## CHANGELOG — Version 7.0

### Major Changes from v6.1 → v7.0:

**1. MULTI-ASSET CALCULATOR VARIANTS (HIP-3)**

- C5-NEW now supports 5 asset classes: Crypto Perps, Crypto Spot, US Stocks, FX, Commodities
- Each variant has asset-class-specific BASIC (3 inputs) and ADVANCED (4-7 collapsible sections)
- Universal pattern: Direction → Amount → Execute (BASIC), Risk → Cost → Context (ADVANCED ordering)
- New sections per asset class: Market Hours (Stocks/Commodities), Tax Awareness (Stocks), Swap Rate (FX), Session Awareness (FX), Correlation Warning (FX), Contract Details (Commodities), Seasonal & Macro Context (Commodities), DCA (Spot)
- Cross-asset summary matrix documenting all differences

**2. COLD START SYSTEM FOR SMART SIZING (KELLY) & REWARD-TO-RISK**

- 3-phase progressive unlock: Phase 1 (0-9 trades: fixed 1-2%), Phase 2 (10-29: emerging pattern with wide bands), Phase 3 (30+: full Kelly)
- Copy trade borrowing: leader's track record bootstraps Kelly and R:R for copied positions from day one
- Graduated S2 blending: own trades + 0.7x weighted copied trades
- R:R cold start: 2:1 default floor (Phase 1) → 1.5:1 (Phase 2) → personalized minimums (Phase 3)
- Full wireframe layouts for each phase in both Smart Sizing and R:R sections

**3. CHART FULLSCREEN + VIEW IN MARKETS PILL**

- Chart/price area tap now expands to fullscreen (~85% of screen) with [×] to collapse — user stays in Trade module
- [View in Markets →] floating pill at bottom-right of chart area for explicit C3 navigation
- Replaces previous behavior where tapping price elements navigated away to Markets tab
- Rationale: most common intent is "see more chart" not "leave Trade"

---

## CHANGELOG — Version 5.0 (Complete Redesign)

### Major Changes from v4.0 → v5.0:

**1. LIVE MARKET DATA ON EVERY SCREEN**

- TH: Price Pulse + mini 1h sparkline + key levels (new)
- C5-NEW: EMBEDDED INTERACTIVE PRICING CHART (40% left side or collapsible panel) + order book depth visualization (MOST CRITICAL NEW FEATURE)
- C5: Mini candlestick showing real-time fills vs price
- C6: Larger chart with entry/current/TP/SL overlay + mini order book
- All screens update every 500ms via WebSocket

**2. C5-NEW COMPLETE REDESIGN**

- Split-screen layout: live chart on left, calculator on right
- PERPS MODE: Basic/Advanced toggle (was single view)
  - Basic: 3 inputs only (direction, risk amount, execute) with auto-defaults applied
  - Advanced: 5 collapsible sections (Leverage, Safety Limits, Position Sizing, Holding Costs, Risk Scenarios)
- SPOT MODE: Ultra-simple (Buy/Sell, Amount, Confirm) with optional Advanced
- Embedded Lucid signal strip on every parameter
- 4 inline education cards for hard concepts (TP/SL, Leverage Risk, Holding Costs, Smart Sizing)
- Removed Kelly sizing guide sidebar — integrated into "Position Sizing Guide" collapsible
- Reactive contextual card at 15x+ leverage (still present)

**3. SIMPLIFIED LANGUAGE THROUGHOUT**

- Liquidation distance → "Safety margin"
- Kelly sizing → "Smart sizing"
- ATR → "Recent price swings" / "Normal price movement range"
- Funding rate → "Holding cost"
- R:R ratio → "Reward-to-risk"
- Confluence → "Signal strength"
- Margin mode → "Risk isolation"

**4. LUCID SIGNAL ANNOTATIONS ON EVERY PARAMETER**

- Direction: "◆ 4 of your leaders are LONG. Smart Money is 72% LONG. Signal strength: 4/5"
- Leverage: "◆ Your leaders average 2.8x on this asset. Best leverage historically: 3-5x"
- Safety Limits: "◆ Your TP hit rate at 5-7% in Trending: 68%. Support at $165 (volume cluster)"
- Position Size: "◆ Smart sizing suggests $2,400 (5.9% account). Your track record: 64% wins, 1.8:1 payoff"
- Holding Cost: "◆ Funding in top 20% (likely to reverse). Last time this high, price dropped 12% within 48h"

**5. TRADE SUMMARY & QUICK ACTIONS**

- Before execute CTA now shows all defaults clearly
- CTA text uses plain language: "[← OPEN LONG — $375 risk →]" (not "Buy 0.0146 BTC")
- Optional [Review in Test Mode] for paper trading

**6. EDUCATION CARDS (CONTEXTUAL)**

- Appear inline for first-time experiences
- "What is a Safety Limit?" - explains TP/SL with pro pattern
- "Why we're warning you" - 10x+ leverage with historical volatility
- "What is Smart Sizing?" - Kelly explanation with behavioral pattern
- "What is Holding Cost?" - funding explanation with APR warning

**7. C6 & C7 LANGUAGE UPDATES**

- All "liquidation distance" → "Safety margin"
- All "Kelly" → "Smart sizing"
- Lucid annotations use plain examples throughout

### Backwards Compatibility:

- All 6 screens still present (TH, C5-NEW, C5, C6, C7, TH1)
- All data models compatible
- Trading intent object extended with new signal fields (no breaking changes)

---

## MULTI-ASSET CALCULATOR VARIANTS (HIP-3)

C5-NEW adapts its parameters to the asset class being traded. The instrument selector at the top of C5-NEW determines which variant renders. Perps use the 5-step guided flow (v10.0); other asset classes follow a similar pattern adapted to their specifics. Every variant follows the same cognitive pattern (**Direction → Amount → Execute**) with asset-class-specific advanced sections. Visual treatment is identical — same collapsible sections, same Lucid annotation strips, same progressive disclosure animations. Only the content inside each section and which sections exist changes. **As of v10.0,** `buildStockTrade()` and `buildCommodityTrade()` are fully implemented in the prototype alongside the existing perps and spot calculators.

### Variant 1: CRYPTO PERPS (Perpetual Contracts) — updated v10.2

**Instrument Examples:** BTC-PERP, SOL-PERP, ETH-PERP

**5-STEP GUIDED FLOW (v10.0, enhanced v10.2 — Trade Parameter Redesign):**

- **Regime Bar** — Persistent at top, color-coded with confidence % and bell icon for alerts

1. **Step 1: Direction** — [LONG] [SHORT] + **"WHAT THE MARKET IS SAYING"** card (cyan left border, was "Lucid Signals Card")
2. **Step 2: Risk Amount** — "How much can you afford to lose?" (reframed) with Risk % quick-select pills [1%][2%][5%] + Kelly suggestion as separate evidence block
3. **Step 3: Liquidation Distance** — (renamed from "Safety Margin") dynamically computed from leverage with color emoji
4. **Step 4: Set Your Exit Plan** — TP/SL in dual $/% display, "Clear TP"/"Clear SL" with friction dialog, trailing stop with behavioral recommendation, "Set by default" badge
5. **Step 5: Review Summary** — Position Size in units (e.g., "3.34 SOL ($625)"), Liquidation price, Leverage, Holding cost, Order type, Margin

Auto-defaults: Leverage 3x (or user preference), Liquidation distance 1.5x ATR, R:R 2:1, Isolated margin, Market order

**"FINE-TUNE PARAMETERS" (7 nested collapsible sections):**

| #   | Section               | Key Parameters                                                                    | Unique to Crypto Perps                                |
| --- | --------------------- | --------------------------------------------------------------------------------- | ----------------------------------------------------- |
| 1   | Adjust Leverage       | Slider 1-125x, color zones (🟢1-5x 🟡5-10x 🔴10x+), holding cost impact           | Yes — leverage is the defining feature                |
| 2   | Adjust Safety Limits  | TP/SL fine-tuning (duplicate of Step 4 for precision), R:R display, trailing stop | Shared pattern, but liquidation adds urgency          |
| 3   | Position Sizing Guide | Smart Sizing (Kelly) with Cold Start phase-appropriate display                    | Shared pattern                                        |
| 4   | Holding Cost Details  | Funding rate breakdown (8h cycles), annualized cost, historical funding patterns  | Yes — funding is unique to perps                      |
| 5   | Risk Isolation        | Cross vs Isolated margin mode toggle                                              | Yes — margin mode only exists in perps                |
| 6   | Order Type            | Market (default) / Limit / Stop-Limit pills                                       | Shared pattern                                        |
| 7   | Risk Scenarios        | Price move → P&L → safety margin grid                                             | Liquidation scenarios unique to leveraged instruments |

**Key Signals from Radar/Markets:**

- Wallet consensus (leader direction + leverage)
- Funding rate percentile (cost/opportunity)
- OI × Price regime alignment
- Liquidation cluster map (where liquidations cluster = price magnets)

---

### Variant 2: CRYPTO SPOT (Buy & Hold) — v10.2 Redesign

**Instrument Examples:** BTC/USDT, SOL/USDT, ETH/USDT

**MAIN FLOW (v10.2 — ref: Arx_Trade_Parameter_Redesign_Proposal.md):**

1. **Regime Bar** — Persistent at top (same as perps)
2. **Ownership context** — "You own X SOL" below ticker
3. **Chart** — Interactive chart with "View in Markets ->" link
4. **Direction:** [BUY] [SELL] — SELL disabled if no holdings (`state.spotDir`)
5. **Amount:** "How much to spend?" with **Portfolio % quick pills [25%] [50%] [75%] [100%]** (`state.spotAmount`, default $500)
6. **Lucid evidence:** Portfolio allocation % with single-asset guideline
7. **Market Info card:** Best price, est. slippage (in $), ownership info
8. **Ownership education:** Lucid block — "No leverage. No liquidation risk. No holding costs."
9. [Buy SOL →] or [Sell SOL →]

No auto-defaults needed — no leverage, no liquidation, no funding.

**"MORE OPTIONS" EXPANDABLE (v10.2 — replaces "Advanced Options", 4 sections):**

| #   | Section     | Key Parameters                                                                                                                                                       | Notes                                           |
| --- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| 1   | Order Type  | Market (default) / Limit toggle ("Buy at specific price")                                                                                                            | Market/Limit toggle, not collapsible subsection |
| 2   | Sell Target | "Auto-sell when price reaches $X" with **% gain display** (e.g., "+12.2%") — equivalent of TP for spot                                                               | Shows gain percentage alongside price           |
| 3   | Price Alert | Notification when price hits target — explicitly labeled "not an order"                                                                                              | Passive monitoring only                         |
| 4   | DCA Setup   | Frequency pills: [Daily] [Weekly] [Monthly], amount per interval, **historical comparison evidence** (e.g., "DCA into SOL over 12mo returned +34% vs lump sum +28%") | Evidence block with real historical data        |

**What's ABSENT vs Perps:**

- No leverage section (1x only)
- No liquidation / liquidation distance (you own the asset outright)
- No funding cost (holding is free)
- No margin mode (no margin)
- No risk scenarios (no amplified P&L — $100 invested loses max $100)
- Portfolio allocation evidence replaces position sizing guide: "SOL: 12% of portfolio. Guideline: <20% in single asset."

**Key Signals from Radar/Markets:**

- Wallet accumulation/distribution (are whales buying or selling?)
- On-chain metrics (exchange inflows/outflows, active addresses)
- DCA vs lump-sum historical comparison for the asset (now shown inline in DCA Setup evidence block)

---

### Variant 3: US STOCKS — `buildStockTrade(inst)` (v10.0)

**Instrument Examples:** AAPL, TSLA, NVDA, SPY (ETFs included)

**Now fully implemented in prototype as `buildStockTrade(inst)`.**

**BASIC MODE (3 inputs):**

1. Direction: [BUY] [SELL] (not LONG/SHORT — stock language)
2. Amount: Dollar Amount with fractional shares display ("$500" → "≈ 2.78 shares at $179.85"). Fractional shares supported.
3. [Buy AAPL →] or [Sell AAPL →]

Auto-defaults: Market order, no TP/SL (stocks default to hold)

**Key UI Differences from Crypto Perps:**

- **BUY/SELL toggle** (not LONG/SHORT) — stock-appropriate terminology
- **Fractional shares display** — "≈ X shares at $Y" shown below amount input
- **Portfolio Allocation gauge** — replaces Safety Margin gauge (no liquidation for stocks). Shows what percentage of portfolio this purchase represents. Color zones: 🟢<5% 🟡5-10% 🔴>10% of portfolio in single stock
- **Market Status Indicator** — Always visible, shows current market state:
  - Pre-Market (4:00-9:30 AM ET) — amber badge
  - Open (9:30 AM-4:00 PM ET) — green badge
  - After-Hours (4:00-8:00 PM ET) — amber badge
  - Closed (8:00 PM-4:00 AM ET) — red badge
  - Based on current time in ET timezone
- **Execute CTA adapts:** When market is closed, button reads **"Queue Order for Open"** instead of "Buy AAPL"

**ADVANCED MODE (5 collapsible sections):**

| #   | Section                   | Key Parameters                                                                                                                                                                                                          | Unique to Stocks                                                          |
| --- | ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| 1   | [Order Type ▼]            | Market (default) / Limit / Stop / Stop-Limit. Plain-language: "Limit = buy only if price drops to your target."                                                                                                         | Shared pattern but more order types than spot                             |
| 2   | [Safety Limits ▼]         | TP/SL bracket orders. R:R display applies but without liquidation dimension. No leverage amplification.                                                                                                                 | Simpler than perps — no liquidation                                       |
| 3   | [Position Sizing Guide ▼] | Smart Sizing (Kelly) + portfolio concentration check: "This would be 8% of your portfolio in one stock. Diversification guideline: keep single positions under 10%."                                                    | Portfolio diversification context unique to stocks                        |
| 4   | [Market Hours ▼]          | Current status: Pre-market (4-9:30 AM ET) / Open (9:30 AM-4 PM ET) / After-hours (4-8 PM ET) / Closed. If closed: CTA changes to [Queue Order for Open →]. Pre/after-hours warning: "Limited liquidity. Wider spreads." | Yes — market hours are the #1 friction for crypto traders entering stocks |
| 5   | [Tax Awareness ▼]         | Holding period: "Held 8 months. Selling = short-term gains (higher tax). Hold 4 more months for long-term rate." Wash sale alert: "You bought AAPL 15 days ago. Selling now may trigger wash sale rule."                | Yes — tax implications unique to regulated securities                     |

**What's ABSENT vs Perps:**

- No leverage section (standard retail = 1x; margin accounts handled separately in future)
- No funding/holding cost (holding stocks is free)
- No margin mode (no cross/isolated concept)
- No liquidation (you own shares outright) — Portfolio Allocation gauge replaces Safety Margin

**What's ADDED vs Crypto:**

- Market hours with dynamic CTA ("Queue Order for Open" when closed)
- Tax awareness (capital gains, wash sales)
- Fractional shares (dollar-amount ordering with share count display)
- Portfolio Allocation gauge (diversification-focused, not liquidation-focused)
- Dividend awareness (future: "AAPL pays $0.96/share/year, next ex-date: May 9")

---

### Variant 4: FX (Foreign Exchange)

**Instrument Examples:** EUR/USD, GBP/JPY, USD/CHF

**BASIC MODE (3 inputs):**

1. Direction: [BUY] [SELL] (buying = long the base currency, selling = short the base currency)
2. Amount: Dollar amount (system converts to lot size: "$5,000 ≈ 0.05 standard lots of EUR/USD")
3. [Buy EUR/USD →] or [Sell EUR/USD →]

Auto-defaults: Leverage 10x (conservative for FX), Market order, SL at 50 pips

**ADVANCED MODE (5 collapsible sections):**

| #   | Section                 | Key Parameters                                                                                                                                                                                                                       | Unique to FX                                                                            |
| --- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| 1   | [Adjust Leverage ▼]     | Slider with region-aware caps (EU: 30:1 majors, US: 50:1). Color zones: 🟢1-10x 🟡10-30x 🔴30x+. Different thresholds than crypto — FX leverage is naturally higher because FX volatility is naturally lower.                        | Leverage exists but with different norms and regulatory caps                            |
| 2   | [Safety Limits ▼]       | TP/SL in **pips** (standard FX unit). Annotation translates: "50 pip stop = $50 risk on 1 mini lot of EUR/USD." R:R displayed in pips.                                                                                               | Pip-based rather than percentage-based TP/SL                                            |
| 3   | [Swap Rate ▼]           | Overnight holding cost. Can be POSITIVE (you earn): "+$1.20/day (long the higher-interest currency)" or NEGATIVE: "-$2.50/day (short the higher-interest currency)." This is the carry trade dimension.                              | Yes — swaps replace funding rates, and can be profitable                                |
| 4   | [Session Awareness ▼]   | Current session: Tokyo (low vol) / London (highest vol) / New York (high vol) / London-NY overlap (most liquid). "Trading during London session. EUR/USD spread: 0.8 pips (tight). During Tokyo session, spread widens to 1.5 pips." | Yes — FX liquidity varies dramatically by session (24/5 market)                         |
| 5   | [Correlation Warning ▼] | Cross-pair exposure check: "You already have EUR/USD long. Adding GBP/USD long increases USD-short exposure by 85% (correlation: 0.85). Combined position effectively 1.85x your intended size."                                     | Yes — FX pairs are highly correlated, doubling exposure is the #1 risk for FX beginners |

**Key differences from Crypto Perps:**

- Pips instead of percentages for TP/SL
- Swap rates can be positive (earn while holding) — opposite of funding which is always a cost
- Session-dependent liquidity (not 24/7 like crypto)
- Regulatory leverage caps vary by jurisdiction
- Pair correlations are a major risk factor

---

### Variant 5: COMMODITIES — `buildCommodityTrade(inst)` (v10.0)

**Instrument Examples:** Gold (XAU/USD), Crude Oil (WTI), Natural Gas (NG), Silver (XAG/USD)

**Now fully implemented in prototype as `buildCommodityTrade(inst)`. Trades as leveraged CFDs.**

**BASIC MODE (3 inputs):**

1. Direction: [LONG] [SHORT] (leveraged CFDs — uses LONG/SHORT, not BUY/SELL)
2. Amount: Dollar amount (system converts to contract/CFD units)
3. [Long Gold →] or [Short Gold →]

Auto-defaults: Leverage varies by commodity (Gold 20x, Oil 50x, Agriculture 15x), Market order, SL at 2% from entry

**Key UI Differences from Crypto Perps:**

- **LONG/SHORT toggle** (same as perps — leveraged instrument)
- **Safety Margin gauge** (has liquidation risk — same as perps, since these are leveraged CFDs)
- **Commodity-specific leverage ranges** — Different default and max leverage per commodity:
  - Gold/Silver: up to 20x (lower volatility precious metals)
  - Oil/Natural Gas: up to 50x (energy commodities)
  - Agriculture (wheat, corn, soybeans): up to 15x (seasonal volatility)
- **Seasonal context** integrated into Lucid annotations

**ADVANCED MODE (6 collapsible sections):**

| #   | Section                      | Key Parameters                                                                                                                                                                                                                                                                                                                          | Unique to Commodities                                                                    |
| --- | ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| 1   | [Adjust Leverage ▼]          | Commodity-specific ranges and color zone thresholds. Gold: 🟢1-10x 🟡10-15x 🔴15x+. Oil: 🟢1-20x 🟡20-35x 🔴35x+. Agriculture: 🟢1-5x 🟡5-10x 🔴10x+.                                                                                                                                                                                   | Leverage norms vary by commodity volatility                                              |
| 2   | [Safety Limits ▼]            | TP/SL in price or percentage. "TP: $2,380 (+2.1%), SL: $2,310 (-0.9%)." R:R display applies.                                                                                                                                                                                                                                            | Shared pattern                                                                           |
| 3   | [Position Sizing Guide ▼]    | Smart Sizing (Kelly) with Cold Start awareness. Same 3-phase progressive unlock as perps.                                                                                                                                                                                                                                               | Shared pattern                                                                           |
| 4   | [Contract Details ▼]         | CFD details: "No expiry. Overnight holding: $2.30/day." Rollover info if applicable. Contract size display.                                                                                                                                                                                                                             | Yes — futures expiry and rollover are unique to commodities                              |
| 5   | [Market Hours ▼]             | Commodity-specific windows. Gold: nearly 24h with 1h break. Oil: CME Globex hours. Agriculture: limited hours. "Market closes in 3h 45m. Orders after close will queue."                                                                                                                                                                | Each commodity has different trading hours                                               |
| 6   | [Seasonal & Macro Context ▼] | Context varies by commodity type: **Oil** → OPEC meeting calendar, inventory reports, geopolitical events. **Gold** → FOMC decisions, inflation data, safe-haven flows. **Agriculture** → Planting/harvest cycles, weather patterns, USDA reports. Shows: "OPEC meeting in 3 days. Historical oil volatility around OPEC: 2.3x normal." | Yes — commodities are uniquely driven by seasonal patterns, geopolitical events, weather |

**Key differences from Crypto and FX:**

- Commodity-specific leverage defaults (not one-size-fits-all)
- Seasonal and macro context as primary Lucid annotations
- Widely varying trading hours per commodity
- Contract specifications vary across commodities
- 6 advanced sections (vs 7 for perps, 5 for stocks/FX)

---

### Cross-Asset Summary Matrix

| Dimension                | Crypto Perps                                         | Crypto Spot                                 | US Stocks                         | FX                                  | Commodities                     |
| ------------------------ | ---------------------------------------------------- | ------------------------------------------- | --------------------------------- | ----------------------------------- | ------------------------------- |
| **Basic inputs**         | Direction + Risk + Execute                           | Buy/Sell + Amount + Execute                 | Buy/Sell + Shares/$ + Execute     | Buy/Sell + Amount + Execute         | Buy/Sell + Amount + Execute     |
| **Leverage**             | 1-125x, user-controlled                              | None (1x)                                   | None (retail)                     | 1-50x, region-capped                | 5-50x, commodity-specific       |
| **Liquidation risk**     | Yes — primary risk (shown as "Liquidation Distance") | No                                          | No                                | Yes (at high leverage)              | Yes (at high leverage)          |
| **Holding cost**         | Funding rate (always negative, 8h cycles)            | None                                        | None                              | Swap rate (can be positive!)        | Overnight financing or rollover |
| **TP/SL unit**           | Price / percentage                                   | Price / percentage                          | Price / percentage                | Pips                                | Price / percentage              |
| **Market hours**         | 24/7                                                 | 24/7                                        | 9:30-4 ET + extended              | 24/5 (session-dependent liquidity)  | Varies per commodity            |
| **Margin mode**          | Cross / Isolated                                     | N/A                                         | N/A                               | Cross (standard)                    | Cross (standard)                |
| **Unique dimension**     | Funding rate, liquidation clusters                   | DCA scheduling                              | Tax awareness, dividends          | Session liquidity, pair correlation | Seasonal patterns, macro events |
| **Advanced sections**    | 7 (nested in Advanced Trade Settings)                | 4 (in "Advanced Trade Settings" expandable) | 5                                 | 5                                   | 6                               |
| **Kelly / Smart Sizing** | Full (with cold start)                               | Simplified (portfolio %)                    | Full (with diversification check) | Full (with cold start)              | Full (with cold start)          |
| **R:R guidance**         | Full (with cold start)                               | Simplified (sell target only)               | Full                              | Full (in pips)                      | Full                            |

---

## DOCUMENT METADATA

| Property                | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Artifact ID             | Arx_4-1-1-3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| Version                 | 10.0 (v10.0: TH portfolio-first hub, C5-NEW 5-step guided flow with TP/SL promoted + Fine-tune expandable, Regime Gate + Cool-Down protection, Symbol Picker with Watchlist default + Recents + Sort, buildStockTrade + buildCommodityTrade implemented. v9.0: Interactive chart, spot routing, Mini Order Book Ladder. v8.0: 5+5 Horizontal Ladder. v7.0: Multi-asset HIP-3, Cold Start System, chart fullscreen. v5.0 base: Live Market Strip, embedded chart, Lucid annotations, simplified language, education cards) |
| Status                  | Active (Production Ready)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| Last Updated            | 2026-03-13                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| Upstream Dependencies   | 4-1-1-0 (Architecture), 4-2 (Design System), 4-1-1-2 (Markets), 4-1-1-6 (Lucid)                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Downstream Dependencies | 5-1 (Executable Spec), 5-3 (Build Prompts)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| Related Modules         | 4-1-1-2 (Home & Markets), 4-1-1-4 (Radar), 4-1-1-5 (Portfolio)                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| Screens Specified       | TH (v4.0 — portfolio-first hub), C5-NEW (v6.0 — 5-step guided flow + Fine-tune expandable + 5 asset-class variants), C5 (v7.0), C6 (v7.0), C7 (v7.0), TH1 (v7.0)                                                                                                                                                                                                                                                                                                                                                          |
| Calculator Variants     | 5 asset classes: Crypto Perps (7 nested advanced sections in Fine-tune), Crypto Spot (4), US Stocks (5, `buildStockTrade()`), FX (5), Commodities (6, `buildCommodityTrade()`)                                                                                                                                                                                                                                                                                                                                            |
| Cold Start Phases       | 3 phases (0-9 / 10-29 / 30+ trades) for Smart Sizing and R:R, with copy trade borrowing accelerator                                                                                                                                                                                                                                                                                                                                                                                                                       |
| Total Components        | 40+ unique, reusable components (Live Market Strips, Embedded Chart, Education Cards, Contextual Insertions)                                                                                                                                                                                                                                                                                                                                                                                                              |
| Total Interactions      | 60+ button/gesture interactions with full specifications                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| Animation Count         | 22 named animations with timing and haptic                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| Lucid Elements          | 40+ signal annotations (direction, leverage, safety limits, size, holding cost, on-chain)                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| Education Cards         | 4 inline contextual cards for hard concepts                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| Market Data Strips      | 4 adaptive variants (TH, C5-NEW chart+depth, C5 mini, C6 full)                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| Embedded Charts         | C5-NEW interactive via `drawInteractiveChart()` (v9.0: OHLC + MA7/MA20 + volume + crosshair), Spot interactive chart (v9.0), C5 mini candlestick, C6 full with overlays                                                                                                                                                                                                                                                                                                                                                   |
| Mock Data Trades        | 47 total (3 detailed examples with Lucid assessments)                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| Signal Mapping          | Fully specified (2-2-2 §4): direction, size, leverage, SL, TP, instrument selection signals                                                                                                                                                                                                                                                                                                                                                                                                                               |

---

## PROTOTYPE IMPLEMENTATION STATUS

> **Prototype URL:** https://arx-prototype.vercel.app
> **Last deployed:** 2026-03-13

| Screen                                   | Status           | Implementation Notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| ---------------------------------------- | ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Trade Tab (position 3)**               | ✅ Updated v10.0 | Portfolio-first hub architecture. No single-ticker header. Stone underline on tab bar.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| **Trade Hub (TH v4.0)**                  | ✅ Updated v10.0 | `buildTradeHub()` — Portfolio Summary Card (equity, P&L, sparkline, margin bar), Quick Actions ([+ New Trade] + [◆ Ask Lucid]), My Copies section (S7 with leader attribution, safety dots, leader status), Open Positions with safety margin as primary metric, Spot Holdings section. Symbol-independent — computes totals from MOCK.positions + MOCK.spotHoldings.                                                                                                                                                                                                                                                                                                                              |
| **Symbol Picker (v10.0)**                | ✅ Updated v10.0 | Watchlist default tab, Recents horizontal strip (last 5), asset class tabs (★ Watchlist, All, Perps, Spot, Stocks, FX, Commodities), "Hot Right Now" section, Sort options (Volume/24h Change/Signal Strength). `openSymbolPicker()` resets to watchlist + volume sort.                                                                                                                                                                                                                                                                                                                                                                                                                            |
| **C5-NEW Perps (v6.0, updated v10.2)**   | ✅ Updated v10.2 | 5-step guided flow with v10.2 Trade Parameter Redesign: Regime Bar at top with confidence %, "WHAT THE MARKET IS SAYING" card (cyan border, was "LUCID SIGNALS"), Risk % quick-select pills [1%][2%][5%] with color-coded evidence, Kelly suggestion as separate evidence block, reframed "How much can you afford to lose?", Step 3 renamed "Liquidation Distance" (was "Safety Margin") with dynamic computation + color emoji, Exit Plan enhanced with dual $/% display + "Clear TP"/"Clear SL" friction dialog + trailing stop behavioral recommendation + "Set by default" badge, Review Summary shows position size in units + liquidation price. `detectTradeStyle()` for S2/S7 adaptation. |
| **Risk Controls (v10.0, updated v10.2)** | ✅ Updated v10.2 | `checkRegimeGate()` — regime WR mismatch warning (>20pp gap). `checkCoolDown()` — consecutive loss protection (3+ losses). **New v10.2:** `tradeTPSLRemoveFriction(type)` — confirmation dialog when clearing TP/SL with social proof nudge and [Keep]/[Remove Anyway] buttons. `detectTradeStyle()` — S2/S7 segment detection from journeyState.                                                                                                                                                                                                                                                                                                                                                  |
| **Trade Confirmation**                   | ✅ Implemented   | Execute confirm overlay with position summary, confetti particle animation on confirm.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| **C6 Position Monitor**                  | ✅ Implemented   | Full-page navPush from position card tap. Shows position details: symbol, direction, leverage, entry/mark price, P&L, safety margin gauge, SL/TP levels, funding cost, regime alignment check. [Close Position] CTA.                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| **Stock Calculator (v10.0)**             | ✅ New v10.0     | `buildStockTrade(inst)` — BUY/SELL toggle, fractional shares display, Portfolio Allocation gauge (no liquidation), market status indicator (Pre-Market/Open/After-Hours/Closed based on ET), "Queue Order for Open" when closed. 5 advanced sections.                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| **Commodity Calculator (v10.0)**         | ✅ New v10.0     | `buildCommodityTrade(inst)` — LONG/SHORT toggle (leveraged CFDs), Safety Margin gauge, commodity-specific leverage (Gold 20x, Oil 50x, Agriculture 15x). 6 advanced sections including Seasonal & Macro Context (OPEC/FOMC/planting-harvest).                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| **C5-NEW Mini Ladder**                   | ⬜ Spec only     | v9.0 — confirmed 5+5 order book ladder with tap-to-prefill, depth bars, spread center, last trade arrow.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| **C5-NEW Interactive Chart**             | ⬜ Spec only     | v9.0 — `drawInteractiveChart()` with OHLC candles, MA7/MA20, volume histogram, crosshair, animated entrance.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| **Spot Trading (v10.2 redesign)**        | ✅ Updated v10.2 | `buildSpotTrade()` complete rewrite — Regime Bar, "You own X SOL" ownership context, BUY/SELL toggle (SELL disabled if no holdings), Portfolio % quick pills [25%][50%][75%][100%], Lucid portfolio allocation evidence, Market Info with $ slippage + ownership info, ownership education block ("No leverage. No liquidation risk. No holding costs."), "Advanced Trade Settings" expandable (was "Advanced Options"/"More options") with Order Type toggle, Sell Target with % gain, Price Alert, DCA Setup with historical comparison evidence. New state: `state.spotAmount`, `state.spotDir`.                                                                                                |
| **Education Cards**                      | ⬜ Spec only     | Inline contextual cards for leverage risk, holding costs.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| **Contextual Insertion**                 | ⬜ Spec only     | 15x+ leverage warning with Kelly recommendation.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
