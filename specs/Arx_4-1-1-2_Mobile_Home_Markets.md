# Arx Mobile — Module: Home & Markets

**Artifact ID:** Arx_4-1-1-2
**Title:** Mobile Home & Markets — Screens C1, C2, C2-F, C3, C3-OB
**Version:** v9.5 (v9.5: Mobile-native viewport — `@media (max-width:430px)` fills `100dvh`, removes phone frame, respects safe areas. Browser history API integration — `navPush`/`navPop`/`switchTab` use `history.pushState()`/`popstate`, enabling browser back/forward buttons and iOS swipe-back gesture for all navigation (detail pages + tab switches). v9.4: Cross-navigation unified — all Home/Markets CTAs routing to Radar Traders now use `navigateToTradersWithContext()` helper with proper preset/sort/instrument/dimFilter params. Home Quick Actions "Copy Leader" → `{sort:'s2',preset:'topCopyLeaders'}`, "My Leaders/Top Traders" → `{sort:'s2'}`. Markets C3 "[See Who's Trading →]" → `{instrument:sym,sort:'s2'}`. v9.2: Markets tab C2 restructured to clean trading dashboard — intelligence hub content moved to Radar → Markets sub-tab. C2 JTBD narrows to search + filter + sort instrument list. All market intelligence (Market Narrative, heatmaps, Top Movers, Risk Map, OI/Volume, Top Wallets, Structural Edges, etc.) now lives in Radar → Markets, not here. Onboarding streamline — users arrive at Home faster (S7 fast path ~20s, S2 path varies based on optional screens). A1 Experience Level no longer in required path. S7 wizard nudge card added to Quick Actions for users who skipped/defaulted wizard. Post-onboarding nudge system per Arx_9-5 §Part 3. v9.1: Fixed critical path — Markets C3 [Trade ▶] routes directly to C5-NEW Calculator via openTrade(sym), skipping Trade Hub. Home Quick Trade documented with openTrade() routing. Implementation notes added for Trade button behaviors. v9.0: Fund Hub staking flow implemented — `showStakeFlow()` opens full staking UI via navPush for USDT/ETH/SOL with amount input, yield details, and Lucid explainer. Lucid Moments carousel upgraded to full-width snap-scroll (`.lucid-scroll`/`.lucid-card`, IntersectionObserver dots, scale/opacity transitions). Fund Hub navBack() bug fixed — confirmation buttons now use `navPop()`. C3-C tab order updated to [Overview][Technical][Fundamentals][Depth][Traders], C3-D tab order updated to [Overview][Technical][Fundamentals][Depth][Traders]. Depth Staircase (Layer 2) spec expanded with cumulative area chart, annotated cliffs, draggable impact price calculator overlay. C3 Shared IA table updated to reflect Technical as Tab 2 across all variants and revised tab positions for US Stock and Commodity perps. Implementation status rows split: Lucid View, Technical Tab, and Order Book 3-Layer tracked separately. v8.0: Lucid View synthesis layer added to C3 Shared Shell — overall + 5 factor cluster bars (Regime, Technical, On-Chain & Structural, Participant, Fundamental) with regime-conditional auto-weighting and Customize panel (Auto/Manual modes). TradingView annotation overlay (S/R lines, regime zones, leader entries, user positions) with toggle. Technical tab added to all C3 variants (C3-A, C3-B, C3-C, C3-D) — TA Summary, Oscillators, Moving Averages, Volatility, Key Levels, Volume Analysis; C3-B adds on-chain valuation metrics (NVT, MVRV, Realized Price). Three-layer order book progressive disclosure — Layer 0 Price Pulse (Overview default), Layer 1 Horizontal Ladder (Depth tab default, tap-to-set-limit, wall detection), Layer 2 Depth Staircase (toggle). Tab orders updated: C3-A adds [Technical], C3-B adds [Technical], C3-C replaces [Signals] with [Technical]+[Traders], C3-D replaces [Signals] with [Technical]+[Traders]. Cluster visibility rules by instrument type. v6.3: All abbreviations spelled out — WR→win rate, OI→Open Interest, Liq→Liquidation. Teal→stone. Gradient→layered in C3-OB. v6.2: Lucid Moments repositioned between equity header and quick actions. Equity animation enhanced with time-horizon chart types. Quick Actions redesigned as universal 5-pill set. Journey-state Home variants added (S7 New, S7 Active, S2 New, S2 Active). Universal bookmark system integrated. Gradient references removed. Copier Win Rate replaced with Copier Median Return. LucidTooltip integrated for complex terms. v6.0→v6.1: Home quick access pills updated to [BTC Perp] [Radar Feed] [Top Traders] [Portfolio] [Markets]. Home "Signals · Personalized" section replaced with "Radar Feed" preview showing feed items from Radar R0. Asset Detail C3 now includes Open Interest & Liquidation Heatmap, Wallet Cohort Breakdown (All-Weather/Specialist/Retail), and Traders in This Asset section. v6.0 changes preserved: C3 redesigned with on-chain data, perp/spot tab separation, language simplification, Hyperliquid data mapping, cohort deep-dive bridges.)
**Last Updated:** 2026-03-15
**Status:** Active
**Prototype:** [arx-prototype.vercel.app](https://arx-prototype.vercel.app)
**References:** Master Architecture (`4-1-1-0`), Design System (`4-2`), Lucid (`4-1-1-6`)

---

## MODULE OVERVIEW

| Property             | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **JTBD (Home)**      | "What's happening right now that matters to me?" — personalized at-a-glance status with embedded Lucid insights                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| **JTBD (Markets)**   | "Show me the instruments — search, filter, sort, and tap in." — a clean trading dashboard. No intelligence hub content here; that lives in Radar → Markets. Markets C2 is the instrument-list surface: search by name/symbol, filter by asset class and instrument type, sort by any column, tap any row to open C3 Asset Detail. Price Pulse and Smart Depth (C3) are the intelligence layers, not C2 itself. Every path leads to a trade. (v9.2: intelligence content formerly shown in C2 — market narrative, heatmaps, top movers with cohort rationale, OI/volume dashboards, structural edges — moved to Radar → Markets sub-tab.) |
| **Primary Segments** | Home: both S2 + S7 (content adapts). Markets: S2 primary (aspiring traders), S7 secondary                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| **Success Metrics**  | Home: DAU, session frequency, time-to-action. Markets: asset discovery rate, C3 drill-through rate, Markets→Trade conversion                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| **Entry Points**     | Home: app launch, tab bar, deep link `arx://home`. Markets: tab bar, Home watchlist tap, deep link `arx://markets`, `arx://asset/{symbol}`. **Onboarding streamline (v9.2):** Users arrive at Home faster — S7 fast path ~20s, S2 path varies based on optional screens. A1 Experience Level is no longer in the required onboarding path.                                                                                                                                                                                                                                                                                               |
| **Exit Points**      | Home → Markets (watchlist tap), Home → Trade (position tap), Home → Radar (signal tap, Lucid Q&A tap). Markets C2 → C3 → Trade (via [Trade ▶] CTA), Markets C2 → C3 → Radar (via [See Who's Trading →] CTA bridging to leaders filtered by asset). **v9.2:** Markets C2 → Radar → Markets (via [Go to Radar → Markets →] CTA for users wanting intelligence context before trading).                                                                                                                                                                                                                                                     |
| **Screens**          | C1, C2, C2-F, C3, C3-OB                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |

**Critical path (Markets → Trade):** C2 Markets → tap asset → C3 Asset Detail → [Trade ▶] → C5-NEW Calculator (direct via `openTrade(sym)` — skips TH)
**Critical path (Home → Trade):** C1 Home → Quick Trade → C5-NEW Calculator (direct via `openTrade(sym)`) | C1 Home → tap position → C6 Position Monitor | C1 Home → tap signal [Trade →] → C5-NEW Calculator
**Critical path (Home → Copy, S7):** C1 Home → Copy Leader → Radar Traders tab (via `navigateToTradersWithContext({sort:'s2',preset:'topCopyLeaders'})`) | C1 Home → My Leaders → Radar Traders tab (via `navigateToTradersWithContext({sort:'s2'})`) | C1 Home → Feed "All →" → Radar Feed Copies tab

**Instrument Type Adaptation:**
Home and Markets both adapt their content based on instrument type. Markets C2 includes a [Perps/Spot/Both] filter in the category tabs. C3 Asset Detail shows different signal sections for perps (funding rate, Open Interest, liquidation zones, basis spread) vs spot (volume trends, holder data, support/resistance, exchange flows). Home C1 portfolio section distinguishes leveraged perp positions (showing liquidation distance, funding cost) from spot holdings (showing cost basis, unrealized P&L).

---

## SCREEN INVENTORY

| ID    | Screen                               | Purpose                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Priority | S2/S7                 |
| ----- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------------- |
| C1    | Home Dashboard                       | Personalized pulse: portfolio, watchlist, signals, positions, copy portfolio (S7), Lucid context sections, onboarding stepper                                                                                                                                                                                                                                                                                                                                                                                                         | P0       | Both (content adapts) |
| C2    | Markets List                         | **v9.2: Clean trading dashboard** — search, filter, sort instrument list. Category tabs, sortable instrument rows with ◆ regime-fit badges. Intelligence hub content (market narrative, heatmaps, top movers with rationale, structural edges) moved to Radar → Markets. Dual Signals/Instruments toggle removed.                                                                                                                                                                                                                     | P0       | S2 primary            |
| C2-F  | Advanced Filter Drawer               | Multi-axis signal and instrument filtering                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | P1       | S2 primary            |
| C3    | Asset Detail                         | Everything about one instrument: chart, Lucid View synthesis, regime context, on-chain signals, order book, liquidation map, trader consensus. Tabs vary by instrument type. Crypto Perp: [Overview] [Technical] [On-Chain] [Depth] [Liquidation Map] [Traders]. Crypto Spot: [Overview] [Technical] [On-Chain] [Order Book] [Holders] [Fundamentals]. US Stock Perp: [Overview] [Technical] [Fundamentals] [Depth] [Traders]. Commodity Perp: [Overview] [Technical] [Fundamentals] [Depth] [Traders]. Quick-switch swipe navigation | P0       | Both                  |
| C3-A  | Crypto Perp Detail                   | Perp-focused tabs with Open Interest analysis, funding deep-dive, trade flow, cohort positions, liquidation cascade risk, bridges to Radar for trader discovery by cohort                                                                                                                                                                                                                                                                                                                                                             | P0       | S2 primary            |
| C3-B  | Crypto Spot Detail                   | Spot-focused tabs with exchange flow, whale tracking, supply distribution, holder analysis, fundamentals                                                                                                                                                                                                                                                                                                                                                                                                                              | P0       | S2 primary            |
| C3-OB | Smart Depth — Order Book (within C3) | Enhanced L2 order book with Lucid annotations, impact price calculator, buy/sell pressure, institutional wall detection                                                                                                                                                                                                                                                                                                                                                                                                               | P1       | S2                    |

---

## SCREEN SPECIFICATIONS

### Screen C1: Home Dashboard

**Purpose:** Your personal trading cockpit — answering "What matters to me right now?" through the lens of the 5-Question Signal Framework. Every element earns its place by answering Q4 (Who to trust?), Q5 (What changed?), or Q1 (Should I act?). Content adapts to S2/S7 segment and trading activity level.
**JTBD:** "Show me what matters to me right now."
**Regime Bar:** No longer a persistent full-width bar. Now a subtle **regime status pill** embedded in the equity header (see below).
**Tab Bar:** Yes (Home highlighted)

#### Design Language — Liquid Glass Application on C1

C1 is the first screen users see. It sets the visual tone for the entire app. Apply the Color Temperature system rigorously:

- **Temperature 0 (Ice):** Background, all card surfaces, section headers. 80% of the screen.
- **Temperature 1 (Cool):** Regime pill tint, sparkline fills, secondary labels, P-layer dots.
- **Temperature 2 (Warm):** P&L numbers (green/red on number only), signal strength badges, safety margin gauges.
- **Temperature 3 (Hot):** Primary CTAs only ([Trade →], [Copy →]). Maximum 2 visible at once.

Card hierarchy uses elevation + glass:

- Standard cards: Level 1 elevation (shadow1, no blur). Clean, flat, surface-colored.
- Hero card (equity dashboard when expanded): Level 2 elevation (shadow2, subtle blur). Slight glass effect.
- Sticky CTA bar: Level 3 glass material (blur 20px, translucent background).
- All cards: 14px border-radius, 1px borderLight, NO colored backgrounds. Color only on data within.

#### Entry Points

- App launch (default landing after auth)
- Tab bar "Home" tap
- Deep link `arx://home`
- Back navigation from any drill-down

#### Wireframe

```
┌──────────────────────────────────────────────────┐
│                                                  │
│  EQUITY HEADER (Glass Level 2, sticky on scroll) │
│  ┌──────────────────────────────────────────────┐│
│  │ $12,450.00                                   ││
│  │ +$487 (+2.3%) today    [🟢 Trending]         ││
│  │ ┌──────────────────────────────────────────┐ ││
│  │ │      /\    /\                            │ ││
│  │ │     /  \  /  \  /\   /\                 │ ││
│  │ │    /    \/    \/  \ /  \  /             │ ││
│  │ └──────────────────────────────────────────┘ ││
│  │ [1D] [7D] [30D] [90D] [YTD]                 ││
│  │                                              ││
│  │ ▼ Tap to expand breakdown                    ││
│  └──────────────────────────────────────────────┘│
│                                                  │
│  EXPANDED BREAKDOWN (on tap, slides down):       │
│  ┌──────────────────────────────────────────────┐│
│  │ Perps:  $7,200 (+3.1%)    ████████░░  58%   ││
│  │ Spot:   $3,800 (+1.2%)    ████░░░░░░  31%   ││
│  │ Copy:   $1,450 (+0.8%)    █░░░░░░░░░  11%   ││
│  │ ─────────────────────────────────────────    ││
│  │ Cash:   $2,100 (available for new positions) ││
│  │ Process Score: 82 [↑ improving]              ││
│  │                                              ││
│  │ TOP HOLDINGS:                                ││
│  │  SOL  $4,200 (34%)  +6.3%                   ││
│  │  BTC  $3,100 (25%)  +1.1%                   ││
│  │  ETH  $2,800 (22%)  -1.8%                   ││
│  │  HYPE $1,350 (11%)  +12.1%                  ││
│  │  [See full portfolio →]                      ││
│  └──────────────────────────────────────────────┘│
│                                                  │
│  📡 LUCID MOMENTS ──────────────── [See all →]   │
│  (Full-width cards, swipe card-by-card)           │
│  ┌──────────────────────────────────────────────┐│
│  │ 🌅 MORNING BRIEF                             ││
│  │ The market shifted to Trending 4h ago.       ││
│  │ Your leaders are 72% aligned with the trend. ││
│  │ SOL is your strongest position right now.    ││
│  │                                               ││
│  │         [◆ Ask a follow-up question]          ││
│  └──────────────────────────────────────────────┘│
│  ← swipe for next card →                         │
│  ● ○ ○ (card position indicators)                │
│                                                  │
│  QUICK ACTIONS ────────────────── [Customize]    │
│  S2: [⚡ Quick Trade] [💰 Fund] [👥 Top Traders] │
│      [📡 Signals] [🔍 Explore]                   │
│  S7: [👥 Copy Leader] [💰 Fund] [🏆 My Leaders]  │
│      [🧬 Trading DNA] [📡 Signals] [🔍 Explore]  │
│  (Universal pill set, horizontal scroll,          │
│   reorderable via Customize. S7 replaces          │
│   Quick Trade with Copy Leader → Radar Traders)   │
│                                                  │
│  ┌── REGIME ALERT (conditional, on change) ─────┐│
│  │ 🟢 Market shifted to Trending 4h ago         ││
│  │ Your win rate in Trending: 72%                     ││
│  │ 3 of your leaders increased positions         ││
│  │                              [◆ Details] [✕] ││
│  └──────────────────────────────────────────────┘│
│  (Appears on regime change. Dismissible.         │
│   After dismiss, regime state shows as pill in   │
│   equity header only: [🟢 Trending])             │
│                                                  │
│  📋 MY COPIES (S7 only) ──────── [Manage →]     │
│  ┌──────────────────────────────────────────────┐│
│  │ Total: $6,900 (+$28 today, +0.41%) ││
│  │ ┌────────────────────┐                       ││
│  │ │████████████░░░░░░░░│ Circuit breaker: 68% ││
│  │ └────────────────────┘ 🟢 Safe              ││
│  │ Tap to expand per-leader breakdown           ││
│  └──────────────────────────────────────────────┘│
│  (Conditional: S7 users with ≥1 active copy)     │
│                                                  │
│  YOUR WATCHLIST ──────────── [Edit ✏ ] [All →]   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐         │
│  │SOL       │ │ETH       │ │BTC       │         │
│  │$174.20   │ │$3,245    │ │$67,890   │         │
│  │↑2.8%     │ │↓0.4%     │ │↑1.1%     │         │
│  │◆ 4/5     │ │          │ │● 1 signal│         │
│  └──────────┘ └──────────┘ └──────────┘         │
│  ←[horizontal scroll]→                           │
│                                                  │
│  ACTIVITY ─────────────────── [See All →]        │
│  (Unified feed: leader actions + signals +       │
│   regime events. Weighted by segment.)           │
│                                                  │
│  ┌──────────────────────────────────────────────┐│
│  │ 🛡️ @CryptoSurgeon opened SOL LONG · 2h ago  ││
│  │ Entry: $174.20 · 5x leverage                ││
│  │ ◆ Signal strength: 4/5 on SOL               ││
│  │                    [Follow Trade →] [Profile] ││
│  ├──────────────────────────────────────────────┤│
│  │ ● P4 STRUCTURAL · SOL                        ││
│  │ Open Interest surged +$340M in 4h — new capital flowing ││
│  │ ◆ Signal strength: 78/100                    ││
│  │                      [Trade →] [◆ Details →] ││
│  ├──────────────────────────────────────────────┤│
│  │ 🎯 @AlphaHunter published ETH thesis · 4h   ││
│  │ "Accumulating ahead of Shanghai upgrade"     ││
│  │                    [Read →] [Profile]         ││
│  └──────────────────────────────────────────────┘│
│                                                  │
│  OPEN POSITIONS (3) ─────────── [See All →]      │
│  ┌──────────────────────────────────────────────┐│
│  │ SOL LONG · 5x · Perps                       ││
│  │ Safety margin: $1,247 (18.3%) ████████████░░ ││
│  │ +$489 (+6.3%)                                ││
│  │ Holding cost: -$2.40/8h                      ││
│  ├──────────────────────────────────────────────┤│
│  │ ETH SHORT · 3x · Perps           ⚠          ││
│  │ Safety margin: $680 (12.1%) ████████░░░░░░░░ ││
│  │ -$120 (-1.8%)                                ││
│  │ Holding cost: +$1.80/8h                      ││
│  ├──────────────────────────────────────────────┤│
│  │ BTC LONG · Spot                               ││
│  │ +$60 (+1.1%)   No leverage                   ││
│  └──────────────────────────────────────────────┘│
│                                                  │
│  ┌──────────────────────────────────────────────┐│
│  │ 🎯 GETTING STARTED           Step 2 of 4    ││
│  │ ██████████░░░░░░░░░░         50%            ││
│  │ ✅ Fund account                              ││
│  │ → [Browse leaders →]  (S2: Scan markets)     ││
│  │ ○ Set your protection                        ││
│  │ ○ Go live!  (S7 only)                        ││
│  │ Earn points: +250 on completion              ││
│  └──────────────────────────────────────────────┘│
│  (Conditional: first 7 days only, dismissible)    │
│                                                  │
│  ⚠ WELLNESS ALERT (conditional, from Trade tab)  │
│  ┌──────────────────────────────────────────────┐│
│  │ ⚠ You've been trading for 3h                 ││
│  │ Your accuracy drops 18% after 2h.            ││
│  │ Consider reviewing before your next trade.   ││
│  │                     [Take a break] [Dismiss] ││
│  └──────────────────────────────────────────────┘│
│  (Only appears when Wellness state = Yellow/Red.  │
│   Primary home is Trade tab TH and C5-NEW.)      │
│                                                  │
├──────────┬──────────┬──────────┬──────────┬──────┤
│  Home●   │  Radar   │  Trade   │ Markets  │  You │
└──────────┴──────────┴──────────┴──────────┴──────┘
```

#### Information Architecture

| #   | Section                | Data Fields                                                                                                                                 | Source                         | Hierarchy                                                                                                                                                                                                                                 | States                                                                                                                                                              |
| --- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Portfolio Card         | `portfolio_total_value`, `daily_pnl`, `pct_change_24h`, `equity_curve[]`, `regime_state_pill`, `portfolio_status_badge`                     | Portfolio API + Regime API     | Hero, Glass Level 2. Contains chart + regime pill + status badge                                                                                                                                                                          | Hidden when `!isFunded`. Sparkline when `!hasPositions`. Full interactive chart (canvas, 6 time periods, line/bar toggle, expandable breakdown) when `hasPositions` |
| 1a  | Portfolio Status Badge | `positions_at_risk_count`, `consecutive_losses`, `leaders_at_risk_count`                                                                    | Position API + Behavioral API  | Top-right of portfolio card. Specific label, not vague                                                                                                                                                                                    | "All Good" (green) / "X at risk" (red) / "X losses" (warning) / "X leaders flagged" (red)                                                                           |
| 1b  | Equity Breakdown       | Allocation buckets: `copied_traders_value` + `copy_pnl`, `own_positions_value` + `own_pnl`, `available_balance`, `total` + `total_pnl`      | Portfolio API + Copy API       | Expandable panel below chart, collapsed by default. Triggered by "▼ Breakdown". Rows add up to total — same kind of thing per row (allocation bucket + P&L). No jargon: "Copied Traders" not "Spot Equity", "Available" not "Margin Used" | Only when `hasPositions` (full chart mode). "Copied Traders" row only when `isCopying`. "Your Positions" row only when `hasPositions`                               |
| 1c  | Chart Mode Toggle      | `equity_chart_mode` (line/bar)                                                                                                              | Client state                   | Subtle text link "Daily P&L" / "Equity" next to Breakdown trigger                                                                                                                                                                         | Only available when `hasPositions`                                                                                                                                  |
| 1d  | Time Period Selector   | Active period (1D, 7D, 30D, 90D, YTD, ALL)                                                                                                  | Client state                   | Apple Stocks pattern: plain text labels, selected = bold Water cyan + dot indicator. No pill boxes                                                                                                                                        | Only available when `hasPositions`                                                                                                                                  |
| 1e  | Regime Pill            | `regime_state`, `regime_day`, `regime_human_label`                                                                                          | Regime API                     | Bottom of portfolio card. Plain language ("Market going up") + day count. 44px min touch target. Tap → regime detail sheet                                                                                                                | Hidden when `!isFunded`                                                                                                                                             |
| 2   | Quick Actions          | 3 state-driven verb buttons: Money (wallet icon), Copy (people icon), Trade (lightning icon)                                                | User state                     | 3-column equal-width row directly below portfolio card. Always visible above the fold                                                                                                                                                     | Labels change by state — see State × Element Matrix above                                                                                                           |
| 3   | Contextual CTA         | `isFunded`, `atRiskCount`, `consecutiveLosses`                                                                                              | Portfolio API + Behavioral API | Single card, max 1 shown. Priority: unfunded → at-risk positions → consecutive losses                                                                                                                                                     | "Add funds to start" (S0) / "X positions need attention" (risk) / "X consecutive losses" (behavioral) / hidden (healthy)                                            |
| 4   | Watching Section       | `watched_traders[]` with `handle`, `allocation`, `pnl`, `status` (Following/Copying)                                                        | Copy API                       | Card with trader list rows, "See all →" link to copy dashboard                                                                                                                                                                            | Hidden when `!hasWatched`. Shows "Following" or "Copying · $X" per trader. Total copy P&L row when `isCopying`                                                      |
| 5   | Position Cards         | `symbol`, `direction` (↑ Bought / ↓ Sold), `pnl`, `safety_pct` (derived from `liqDist`), `safety_label` (Safe/Watch/At risk), `entry_price` | Position API                   | Top 3 positions shown. "Positions" header with conditional "All →" (only when >3 positions). Each card tappable → position monitor                                                                                                        | Hidden when `!hasPositions`                                                                                                                                         |
| 6   | Lucid Card             | `insight_text`, `ask_prompt`, `action_label`                                                                                                | Lucid API                      | Bottom of screen (lean-back element). Single card, not carousel. Contextual based on user state                                                                                                                                           | Hidden when `!isFunded`. Content adapts: regime tip (S1) / trader activity (S2) / copy performance (S3-S4) / position + market intel (S5)                           |

> **Removed from v10:** Watchlist Cards (moved to Markets tab), Feed (moved to Radar tab), Lucid Moment Stack carousel (replaced with single contextual card at bottom), Onboarding Stepper (replaced with contextual CTA), Wellness Alert (absorbed into consecutive losses CTA + Lucid). Quick Actions reduced from 5 pills to 3 verbs.

#### Component Inventory

> **⚠ v10 OVERRIDE:** The Component Inventory below contains v9.x descriptions that are **partially superseded** by the v10 state-driven architecture documented in the "State-Driven Content Adaptation" section above. When conflicts exist, the v10 section is authoritative. Key changes:
>
> - **Row 2 (Quick Actions):** Now 3 verb buttons (Add Funds / [state-driven] / Trade), not 5-pill set
> - **Row 4 (Copy Portfolio Card):** Replaced by "Watching" section (universal, state-driven, not S7-only)
> - **Row 5/6 (Watchlist, Feed):** Moved to Markets and Radar tabs respectively
> - **Row 8 (Lucid Moment Stack):** Replaced by single contextual Lucid card at bottom of Home
> - **Portfolio chart:** Full interactive canvas chart (Water cyan, line/bar, 6 periods, breakdown) for users with positions; sparkline for others. See Design System §11.3 for color spec.
> - **Status badge:** Specific labels ("All Good", "X at risk", "X losses", "X leaders flagged") not generic traffic light

| #   | Component              | Type                                   | Behavior                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Design Token Ref                       |
| --- | ---------------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| 1   | Equity Header          | Glass Level 2, sticky                  | Shows total equity + 24h P&L + mini equity curve (canvas). Regime status pill inline: small colored pill with regime icon + label (e.g., [🟢 Trending]). Tap pill → regime context bottom sheet. Tap "▼ Details" text link → expand breakdown. Timeframe selector for curve: [1D] [7D] [30D] [90D] [YTD]. **Chart mode toggle (v9.1):** Subtle 28×28px icon button right-aligned next to period pills. Single tap toggles between Line (cumulative equity curve) and Bar (daily P&L deltas). Icon updates to reflect current mode: line chart SVG path or bar chart SVG rects. Default: Line. **Line mode:** Smooth quadratic bezier curve with gradient fill + electricity pulse animation (glowing radial-gradient point traveling along curve via `requestAnimationFrame` loop, 3 trailing glow dots with decreasing opacity, pulsing end dot with sine-wave size variation). **Bar mode:** Daily P&L deltas as rounded bars above/below zero line. Green (`--positive`) for up days, red (`--negative`) for down days. Zero line at vertical midpoint. Both modes controlled by `state.equityChartMode` and rendered by `drawEquity()`. `switchEquityMode(mode)` toggles mode + updates SVG icon + redraws chart. All currency displayed in USD (no KRW/₩). On load: equity counter animates 0 → value (400ms, ease-out cubic via `animateEquityCounter()`), curve renders immediately (canvas).                                     | `surface` + glass material, `shadow2`  |
| 1b  | Equity Breakdown       | Expandable panel                       | Triggered by tapping "▼ Details" text link at bottom of equity card (`toggleEquityBreakdown()`). Three-column grid: Perps/Spot/Copy each with value, P&L %, and progress bar showing allocation percentage. [See full position breakdown →] CTA navigates to You > Portfolio. **Prototype note:** Cash available, Process Score, and Top 5 holdings are spec targets not yet in prototype. Collapse via "▲ Hide" text link. Uses `display:none` toggle (not spring animation).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `surface`, `borderLight`               |
| 2   | Quick Actions          | Icon-card grid (horizontal scroll)     | **Universal set:** [⚡ Quick Trade] [💰 Fund] [👥 Top Traders] [📡 Signals] [🔍 Explore]. Implemented as square cards (86px min-width) with large emoji icon + small bold label. Same 5 cards for all users (S2, S7, new). Each card: tap → navigate. **Quick Trade Implementation:** Calls `openTrade('SOL-PERP')` (or user's most-traded asset). Routes directly to calculator, not Trade Hub. **S7 Wizard Nudge Card (v9.2):** If S7 user has NOT completed the wizard (or has defaults), show nudge card below Quick Actions: "🎯 Find your ideal leaders / Answer 5 quick questions so we can match you with traders who fit your goals. Takes under 60 seconds. / [Start Matching →] [✕]". Dismiss behavior: Reappears after 3 days. After 2 dismissals, card does not reappear (wizard still accessible via You tab and Radar). **Implementation note:** Post-onboarding nudge system per Arx_9-5 §Part 3. Dashboard wizard prompt for S7 users who skipped wizard during onboarding. **Prototype note:** [Customize] feature not yet implemented.                                                                                                                                                                                                                                                                                                                                                                                | `card`, `surface-el`                   |
| 3   | Regime Alert Card      | Conditional card with dismiss          | Appears only on regime change event. Shows: new regime, user's win rate in this regime, leader adaptation status. Two CTAs: [◆ Details] → regime deep-dive bottom sheet, [✕] → dismiss (regime indicator persists as pill in equity header). Auto-dismisses after 24h if not interacted with. Background: Temperature 1 (regime color at 8% opacity tint on surface). Left border: 3px in regime color at 40% opacity                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `surface`, regime color at T1          |
| 4   | Copy Portfolio Card    | Expandable summary                     | Conditional: S7 with ≥1 active copy. Collapsed: aggregate equity + daily P&L + circuit breaker bar. Expanded (tap): per-leader breakdown with tier badges, ◆ Lucid consistency annotations. [Manage →] → D4. Circuit breaker bar: 🟢 0-70%, 🟡 70-90%, 🔴 >90%. Only the circuit breaker bar uses Temperature 2 color. Card itself is Temperature 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | `surface`, `shadow1`, `borderLight`    |
| 5   | Watchlist Cards        | Horizontal scroll cards                | Each card: symbol, price, 24h %, mini sparkline (drawn on load 400ms). Signal strength badge (small, inline). NO funding rate on card (too dense — available on tap to C3). Tap → C3. [Edit ✏] → watchlist management. [All →] → C2 Markets. Card: Temperature 0 (white/surface, borderLight). Sparkline: Temperature 1 (green/red at 40% opacity). Bookmark integration: star icon (☆/★) on each card uses universal Bookmark component (Design System §6.3). Tap star = add/remove from watchlist.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | `surface`, `shadow1`, `borderLight`    |
| 6   | Feed                   | Unified interleaved feed               | Section title: "Feed" (renamed from "Activity" v9.1 to align with Radar Feed tab). Merges: leader actions (wallet events), signal alerts, regime events into ONE chronological stream. Ranking algorithm weights by segment: S7 leader_weight=1.5, signal_weight=1.0; S2 signal_weight=1.5, leader_weight=1.0. Each item type has distinct but subtle visual treatment: leader events have wallet badge, signals have P-layer dot (8px, colored), regime events have regime icon. All cards Temperature 0 with minimal color accents. [All →] → Radar Feed tab. Max 3-4 items shown on Home                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | `surface`, `shadow1`                   |
| 6a  | Activity: Leader Event | Feed item                              | Wallet badge (classification icon), leader name, action, asset, time ago. Key metric inline (entry price, leverage). [Follow Trade →] CTA (S7) or [View Profile →]. Temperature 0 card, wallet badge is Temperature 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `surface`                              |
| 6b  | Activity: Signal Alert | Feed item                              | P-layer dot (8px, colored), signal type, asset, description (1-2 lines). Signal strength badge. [Trade →] → C5-NEW with TradeIntent. [◆ Details →] → C3 + Lucid. Temperature 0 card, dot is Temperature 1, [Trade →] is Temperature 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `surface`                              |
| 6c  | Activity: Regime Event | Feed item                              | Regime icon, event description, personal relevance (win rate, leader adaptation). [◆ Details] CTA. Subtle, Temperature 0-1 only                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | `surface`                              |
| 7   | Position Cards         | Compact list cards                     | Perps: safety margin as gauge bar (Temperature 2 — green fill for healthy, amber for warning, red for danger). P&L as number (green/red text only, Temperature 2). Holding cost in textSecondary. Spot: P&L only, no gauge. Card border: Temperature 0 (NO colored borders — old system removed). ◆ Lucid annotation inline if relevant. Tap → C6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | `surface`, `shadow1`, `borderLight`    |
| 8   | Lucid Moment Stack     | Full-width snap-scroll carousel (v9.0) | Positioned between equity header (or unfunded hero card if unfunded) and quick actions. **v9.0 full-width carousel:** Container uses `.lucid-scroll` class with `scroll-snap-type: x mandatory`, `overflow-x: auto`. Each card uses `.lucid-card` class with `scroll-snap-align: center`, `min-width: calc(100% - 0px)` (full viewport width, no side peeking). Active card: `scale(1)`, `opacity(1)`; inactive: `scale(0.95)`, `opacity(0.6)`. Transition: `300ms cubic-bezier` spring for scale/opacity. 12px border-radius, Temperature 0 background, and a 3px left accent border (color varies by card type: data/warning/positive). Follow-up button label is contextual per card (e.g., "◆ Ask a follow-up", "◆ What should I do?", "◆ Show me the evidence") — opens Lucid drawer via `showLucidDrawer(question)` with prepopulated question. Dot indicators below via `initLucidSwipeDots()` using IntersectionObserver to track active card. Three default cards: Morning Brief (data border), Position Review (warning border), Opportunity (positive border). Always shown in prototype (not conditional). **Lucid card rendering (v9.3):** All Moment cards now use the unified `lucidCard(text, ctaLabel, ctaQuestion, context)` function from Arx_6-1. CTA buttons open the Lucid drawer with contextual pre-filled questions (no fake inputs). See Arx_6-1_Lucid_Interaction_Design_System.md for complete pattern spec. | `surface`, `shadow1`, `borderLight`    |
| 9   | Onboarding Stepper     | Progress card                          | Conditional: first 7 days. Two tracks: S2 (3 steps: Fund → Watchlist → First Trade), S7 (4 steps: Fund → Browse Leaders → Set Protection → Go Live). Progress bar: Temperature 2 (stone fill `#5B21B6`). Dismissible via ✕                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `surface`, `accent-primary`            |
| 10  | Wellness Alert         | Conditional alert card                 | Only appears when Wellness Meter state = Yellow or Red (pushed from Behavioral API). Shows session duration, accuracy degradation %. [Take a break] → suggested activities. [Dismiss] → hides for 1h. Primary home of Wellness system is Trade tab (TH, C5-NEW). Home only gets the alert, not the persistent meter. Background: Temperature 1 (amber tint at 8% for Yellow, red tint for Red)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `surface`, warning/danger colors at T1 |

#### LucidTooltip Pattern (Global Component, v8.0)

The LucidTooltip is a small ◆ button placed inline next to complex terms. It is a mobile-first pattern — tapping it opens the Lucid drawer with a prepopulated question (no hover tooltip).

| Property        | Spec                                                                                         |
| --------------- | -------------------------------------------------------------------------------------------- |
| Trigger element | `.lucid-tooltip-btn` — 20×20px circular button, ◆ symbol                                     |
| Visual          | Stone-glow color (`#A78BFA`), `rgba(91,33,182,0.1)` background, `rgba(91,33,182,0.2)` border |
| Tap behavior    | Opens Lucid drawer via `showLucidDrawer(question)` with prepopulated question string         |
| Usage (C1)      | Regime Alert card (next to alert label)                                                      |
| Usage (Radar)   | Copier Median Return label, Market Narrative section header                                  |
| Usage (C3)      | Lucid View cluster bars, Technical tab indicators                                            |

#### Interactions & CTAs

| #   | Element                                       | Tap →                                                                                                                                | Long Press →                 | Swipe →               | Visual Feedback                 | Animation                                                  |
| --- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------- | --------------------- | ------------------------------- | ---------------------------------------------------------- |
| 1   | "▼ Details" text link (bottom of equity card) | Toggle breakdown expand/collapse                                                                                                     | —                            | —                     | Label text changes ▼→▲          | Instant (display toggle — spring animation is spec target) |
| 2   | Equity curve                                  | Crosshair overlay                                                                                                                    | Hold for sustained crosshair | —                     | Date/value tooltip              | Crosshair draw 200ms                                       |
| 3   | Timeframe pill [1D] etc.                      | Switch curve timeframe via `selectPeriod(el, period)` → redraws in current chart mode (line or bar)                                  | —                            | —                     | Pill active state updates       | Instant canvas redraw                                      |
| 3b  | Chart mode icon (28×28px)                     | Toggle between Line ↔ Bar mode via `switchEquityMode()`. SVG icon updates to reflect new mode. Redraws equity chart in selected mode | —                            | —                     | Icon swap with 200ms transition | Instant canvas redraw                                      |
| 4   | Regime pill [🟢 Trending]                     | Open regime context bottom sheet                                                                                                     | —                            | —                     | Pill highlight                  | 100ms                                                      |
| 5   | Entire screen                                 | —                                                                                                                                    | —                            | Pull down             | Spinner + content slide         | Spring physics                                             |
| 6   | Quick Action pill                             | Navigate to destination                                                                                                              | —                            | —                     | Scale 0.95 + stone tint flash   | 150ms bounce                                               |
| 7   | [Customize] (Quick Actions)                   | Open customization bottom sheet                                                                                                      | —                            | —                     | Fill flash                      | 100ms                                                      |
| 8   | Regime Alert [◆ Details]                      | Open regime deep-dive bottom sheet                                                                                                   | —                            | —                     | Button highlight                | 100ms                                                      |
| 9   | Regime Alert [✕]                              | Dismiss card (regime persists as pill in header)                                                                                     | —                            | —                     | Card fade-out                   | 300ms fade                                                 |
| 10  | Copy Portfolio Card                           | Expand per-leader breakdown                                                                                                          | —                            | —                     | Height expand with spring       | 300ms spring                                               |
| 11  | [Manage →] (Copy)                             | Navigate to D4 Copy Dashboard                                                                                                        | —                            | —                     | Text color flash                | 100ms                                                      |
| 12  | Watchlist card                                | Navigate to C3 Asset Detail                                                                                                          | —                            | —                     | Scale 0.98 + shadow lift        | 150ms                                                      |
| 13  | [Edit ✏] (Watchlist)                          | Open watchlist management bottom sheet                                                                                               | —                            | —                     | Icon rotate 45°                 | 200ms                                                      |
| 14  | Feed item (leader)                            | Navigate to D2 Wallet Profile                                                                                                        | —                            | —                     | Scale 0.98                      | 150ms                                                      |
| 15  | Feed item (signal) [Trade →]                  | Pre-fill TradeIntent → C5-NEW                                                                                                        | —                            | —                     | Button ripple (Temperature 3)   | 100ms                                                      |
| 16  | Feed item (signal) [◆ Details →]              | Navigate to C3 + Lucid Q&A sheet                                                                                                     | —                            | —                     | Button ripple                   | 100ms                                                      |
| 17  | Feed item (any)                               | —                                                                                                                                    | —                            | Swipe left            | Dismiss animation, undo toast   | 250ms slide-out                                            |
| 18  | Position card                                 | Navigate to C6 Position Monitor                                                                                                      | —                            | —                     | Scale 0.98 + gauge highlight    | 150ms                                                      |
| 19  | Lucid Moment card                             | Story interaction                                                                                                                    | —                            | Swipe left: next card | Scale + highlight               | 150ms / 250ms slide                                        |
| 20  | Onboarding CTA                                | Navigate to current step                                                                                                             | —                            | —                     | Button ripple                   | 100ms                                                      |
| 21  | Wellness Alert [Take a break]                 | Show suggested activities bottom sheet                                                                                               | —                            | —                     | Button highlight                | 100ms                                                      |
| 22  | 🔍 (header)                                   | Global Search overlay                                                                                                                | —                            | —                     | Icon scale + ripple             | 100ms                                                      |
| 23  | 🔔 (header)                                   | NC1 Notification Center                                                                                                              | —                            | —                     | Badge highlight                 | 100ms                                                      |

#### State-Driven Content Adaptation (v10 — replaces S2/S7 persona model)

> **Architecture change (2026-03-23):** Home no longer branches on persona identity (isS7/isS2). It branches on **user state** — what the user has DONE, not who they ARE. The same user progresses through states as they fund, watch, copy, and trade. This is a spectrum, not a binary.

**User States (journey progression):**

| State                   | `isFunded` | `hasWatched` | `isCopying` | `hasPositions` | Description                                 |
| ----------------------- | ---------- | ------------ | ----------- | -------------- | ------------------------------------------- |
| **S0: New**             | false      | false        | false       | false          | Just signed up, no funds                    |
| **S1: Funded**          | true       | false        | false       | false          | Has funds, hasn't discovered traders yet    |
| **S2: Watching**        | true       | true         | false       | false          | Following traders, hasn't allocated capital |
| **S3: Copying**         | true       | true         | true        | false          | Allocated to leaders, no own positions yet  |
| **S4: Copying+Trading** | true       | true         | true        | true           | Full active user — copying AND trading      |
| **S5: Trading only**    | true       | false        | false       | true           | Independent trader, no copy activity        |

**Quick Actions — 3 verbs, state-driven labels:**

All labels are verbs. Icon provides the noun. No navigation-only buttons.

| Slot                     | S0 New                                            | S1 Funded                         | S2 Watching                       | S3 Copying                       | S4 Copy+Trade                    | S5 Trade Only                                     |
| ------------------------ | ------------------------------------------------- | --------------------------------- | --------------------------------- | -------------------------------- | -------------------------------- | ------------------------------------------------- |
| 1 Money (wallet icon)    | "Fund" → `showFundHub()`                          | "Add Funds" → `showFundHub()`     | "Add Funds" → `showFundHub()`     | "Add Funds" → `showFundHub()`    | "Add Funds" → `showFundHub()`    | "Add Funds" → `showFundHub()`                     |
| 2 Copy (people icon)     | "Find Traders" → `navigateToTradersWithContext()` | "Find Traders" → same             | "Copy Now" → same w/ preset       | "Manage" → `showCopyDashboard()` | "Manage" → `showCopyDashboard()` | "Find Traders" → `navigateToTradersWithContext()` |
| 3 Trade (lightning icon) | "Trade" → `showFundingSheet('trade')`             | "Trade" → `openTrade('BTC-PERP')` | "Trade" → `openTrade('BTC-PERP')` | "Trade" → `openTrade(lastSym)`   | "Trade" → `openTrade(lastSym)`   | "Trade" → `openTrade(lastSym)`                    |

**Full State × Element Matrix:**

| Element               | S0 New               | S1 Funded                | S2 Watching         | S3 Copying             | S4 Copy+Trade                           | S5 Trade Only               |
| --------------------- | -------------------- | ------------------------ | ------------------- | ---------------------- | --------------------------------------- | --------------------------- |
| **Portfolio card**    | Hidden               | Sparkline                | Sparkline           | Sparkline              | **Full chart**                          | **Full chart**              |
| **Chart type**        | —                    | SVG (7d, no interaction) | SVG (7d)            | SVG (7d)               | Canvas (line/bar, 6 periods, breakdown) | Canvas (same)               |
| **Status badge**      | —                    | "All Good"               | "All Good"          | "All Good" / risk      | "All Good" / risk                       | "All Good" / risk           |
| **CTA card**          | "Add funds to start" | —                        | —                   | —                      | risk/loss CTA if applicable             | risk/loss CTA if applicable |
| **Watching section**  | Hidden               | Hidden                   | Shows ("Following") | Shows ("Copying · $X") | Shows ("Copying · $X")                  | Hidden                      |
| **Positions section** | Hidden               | Hidden                   | Hidden              | Hidden                 | Shows (top 3)                           | Shows (top 3)               |
| **Lucid card**        | Hidden               | Generic regime tip       | Trader activity     | Copy performance       | Copy + position intel                   | Position + market intel     |
| **Regime pill**       | Hidden               | Shows                    | Shows               | Shows                  | Shows                                   | Shows                       |

**Key design decisions:**

- Chart earns hero status only at S4/S5 (user has position data worth charting)
- Quick action slot 2 reverts to "Find Traders" for S5 (trading-only user hasn't engaged with copy)
- Risk states override "All Good": `positionsAtRisk > 0` → "X at risk", `consecutiveLosses >= 3` → "X losses", `leadersAtRisk > 0` → "X leaders flagged"
- Lucid is null for S0 (nothing useful to say yet)

#### Portfolio Breakdown (expandable, full chart mode only)

When expanded via "▼ Breakdown", shows allocation buckets that add up to the total. Every row is the same kind of thing — where money lives + today's P&L. No mixed categories, no jargon.

```
┌─────────────────────────────────────────┐
│ Copied Traders    $8,500        +$120 ↑ │  ← only when isCopying
│ Your Positions    $2,054         +$34 ↑ │  ← only when hasPositions
│ Available         $1,896                │  ← always (total minus allocated)
│─────────────────────────────────────────│
│ Total             $12,450       +$154 ↑ │  ← bold, verifiable sum
└─────────────────────────────────────────┘
```

**State-driven rows:**

| Row            | Condition      | Value                           | P&L                     |
| -------------- | -------------- | ------------------------------- | ----------------------- |
| Copied Traders | `isCopying`    | Sum of all leader allocations   | Sum of leader P&L today |
| Your Positions | `hasPositions` | Margin in use (positions value) | Unrealized P&L today    |
| Available      | Always         | `total - copied - positions`    | —                       |
| **Total**      | Always         | `totalEq`                       | Combined P&L (bold)     |

**Design rationale:** S7 users think in terms of "where is my money" not "what type of P&L is this." Rows that add up to the total build trust — the user can verify the math. "Available" tells you what you CAN do (forward-looking), not "Margin Used" which tells you what you've already committed (backward-looking).

#### Layout Order (all states)

```
1. Portfolio card (sparkline or full chart — state-dependent)
2. Quick Actions (Add Funds | [state-driven] | Trade)
3. Contextual CTA (fund / risk warning / loss warning — if applicable, max 1)
4. Watching section (if hasWatched)
5. Positions (if hasPositions, top 3)
6. Lucid insight card (bottom — lean-back element, always accessible via ◆ header)
```

#### Signal Layer Mapping (Global)

| User-Facing Label        | P-Layer | Dot Color        | Example Signals                              |
| ------------------------ | ------- | ---------------- | -------------------------------------------- |
| Regime Intelligence      | P1      | Blue (#3B82F6)   | Macro narrative shifts, regulatory events    |
| Participant Intelligence | P2      | Green (#10B981)  | Smart money flows, wallet accumulation       |
| Instrument Intelligence  | P3      | Amber (#F59E0B)  | Funding rate spikes, Open Interest anomalies |
| Structural Intelligence  | P4      | Red (#EF4444)    | Liquidation cascades, volume surges          |
| Pattern Intelligence     | P5      | Violet (#7C3AED) | Technical patterns, support/resistance       |

Note: P-layers displayed as small 8px colored dots (Temperature 1), NOT full-color badge backgrounds. Dot only. Label text is textSecondary (monochrome).

#### State Changes

| Trigger                            | Visual Change                                                                                                                                                                           |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Regime changes                     | Regime pill in equity header updates color + label (200ms cross-fade). If user on Home, Regime Alert Card slides in from top (300ms spring). Position cards update alignment indicators |
| Regime Alert dismissed             | Card fades out (300ms). Regime pill persists in equity header                                                                                                                           |
| Equity breakdown toggled           | Panel slides down/up (300ms spring). Chevron rotates. On expand: bars animate left-to-right fill (400ms stagger)                                                                        |
| `active_copy_count` changes 0 → ≥1 | Copy Portfolio Card slides in (300ms ease-out)                                                                                                                                          |
| Copy Portfolio expanded            | Per-leader breakdown slides down with Lucid annotations                                                                                                                                 |
| New activity item                  | Item inserts at top of Activity feed with slide-in (250ms). Existing items shift down                                                                                                   |
| Position P&L crosses threshold     | Safety margin gauge color updates. Haptic pulse on danger threshold                                                                                                                     |
| Wellness state → Yellow/Red        | Wellness Alert card slides in above positions (300ms spring). Amber/red tint at Temperature 1                                                                                           |
| Wellness state → Green             | Wellness Alert card fades out (300ms)                                                                                                                                                   |
| User completes onboarding step     | Progress bar fills + checkmark draw (300ms)                                                                                                                                             |
| Screen loads                       | Equity counter 0→value (400ms). Curve draws L→R (800ms). Watchlist sparklines draw (400ms). Activity items cascade-enter with 50ms stagger                                              |
| Lucid morning brief available      | Lucid Moment Stack appears above Onboarding (fade-in 300ms)                                                                                                                             |

#### Loading / Empty / Error States

| State                        | Visual Treatment                                                                                                                                                                                                                          |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Loading (first visit)**    | Shimmer skeleton: equity block shimmer, 3 watchlist card skeletons, 2 activity item skeletons. Regime pill shows "Loading..." in textTertiary                                                                                             |
| **Loading (return visit)**   | Cached data shown immediately. Pull-to-refresh spinner for updates. Stale data indicator: "Updated 5m ago" in textTertiary                                                                                                                |
| **Empty portfolio**          | Custom illustration: growing plant or seed. Copy: "Your portfolio starts here. Fund your account to begin." CTA: [Fund Account →]. No positions section, no equity curve                                                                  |
| **Empty watchlist**          | "Add assets to your watchlist to see them here." CTA: [Browse Markets →]                                                                                                                                                                  |
| **Empty activity**           | "No activity yet. Follow leaders or add assets to your watchlist to see updates." Illustration: telescope looking at stars                                                                                                                |
| **No signals**               | Activity feed hides signal items. Leader events and regime events still show if available                                                                                                                                                 |
| **Error (network)**          | Cached data shown. Error banner: "Unable to refresh. Check your connection." [Retry] button                                                                                                                                               |
| **Error (API)**              | Per-section degradation: failed sections show "Unable to load" with [Retry], other sections render normally                                                                                                                               |
| **Low balance**              | When available cash < 10% of total equity OR < $50: amber "Low Balance" pill appears next to Cash in expanded breakdown. Fund pill in Quick Actions pulses once (subtle amber ring, 1s). No blocking modal — just ambient awareness.      |
| **Trading Style incomplete** | When user skipped A2b or has `auto_detect` with <10 trades: "Complete Your Trading Style" card appears between Lucid Moments and Quick Actions for first 14 days. After 14 days, system auto-populates from behavior and card disappears. |

#### Funding Quick Actions (v4.0)

The `[💰 Fund]` quick action pill in the universal 5-pill set opens a **funding action sheet** (bottom sheet) rather than navigating directly to B1 Fund Hub. This puts the 4 most common funding actions one tap away from Home:

```
┌──────────────────────────────────────────────────┐
│  QUICK FUND ──────────────────────── [All options →] │
│                                                  │
│  Available cash: $2,100                          │
│                                                  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │ Deposit  │ │ Withdraw │ │ Transfer │ │ Convert  │ │
│  │  ↓ In    │ │  ↑ Out   │ │  ↔ Move  │ │  🔄 Swap │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ │
│                                                  │
│  RECENT:                                         │
│  Deposit $500 USDC · 2 days ago                  │
│  Transfer $200 Trading → Copy · 5 days ago       │
│                                                  │
│  [All options →] → navigates to B1 Fund Hub     │
└──────────────────────────────────────────────────┘
```

| Action          | Tap →                    | Target                             |
| --------------- | ------------------------ | ---------------------------------- |
| Deposit         | → B2 (Deposit On-Chain)  | Pre-selected asset: USDC           |
| Withdraw        | → B5 (Withdrawal)        | Pre-selected from: Trading account |
| Transfer        | → B3 (Internal Transfer) | Source/dest dropdowns              |
| Convert         | → B6 (Simple Swap)       | Convert interface                  |
| [All options →] | → B1 (Fund Hub)          | Full fund dashboard                |

#### Balance Breakdown Enhancement (v4.0)

The expanded equity breakdown (tap-to-expand in equity header) now includes pool-level detail with quick-transfer shortcuts:

```
EXPANDED BREAKDOWN:
┌──────────────────────────────────────────────────┐
│ POOL BALANCES                                    │
│ Trading:  $7,200  ████████░░  58%  [Transfer →]  │
│ Spot:     $3,800  ████░░░░░░  31%  [Transfer →]  │
│ Copy:     $1,450  █░░░░░░░░░  11%  [Transfer →]  │
│ ─────────────────────────────────────────         │
│ Cash (USDC): $2,100 (available)  [Deposit →]     │
│ ⚠ Low balance (10% of equity)                     │
│                                                  │
│ Process Score: 82 [↑ improving]                  │
└──────────────────────────────────────────────────┘
```

Each [Transfer →] opens B3 (Internal Transfer) pre-filled with that pool as source. [Deposit →] opens B2.

**Low Balance Warning logic:**

- Trigger: `available_cash / total_equity < 0.10` OR `available_cash < 50`
- Display: Amber ⚠ text + subtle amber tint on Cash row
- Condition: Only when user has ≥1 open position (not for empty accounts)

#### Trading Style Surface on Home (v4.0)

**When style is complete:** No persistent card on Home — the Trading Style powers Lucid Moments, signal relevance, and Radar matching silently. Lucid may surface style-related insights as Moment cards (e.g., "Your swing trades in Trending outperform your day trades by 15pp").

**When style is incomplete (skipped A2b):** A "Complete Your Style" card appears:

```
┌──────────────────────────────────────────────────┐
│  📌 COMPLETE YOUR TRADING STYLE                   │
│                                                  │
│  Help Arx personalize signals, sizing, and       │
│  leader matching for you.                        │
│  Takes 30 seconds.                               │
│                                                  │
│  [Set Up →]                          [Dismiss ✕] │
└──────────────────────────────────────────────────┘
```

Position: Between Lucid Moments and Quick Actions. Dismissible. Reappears once after 7 days if still incomplete. After 14 days or 10 trades (whichever first), system auto-populates from behavior and card no longer appears.

**When style drift detected:** Lucid Moment card (within the Moment Stack):

```
┌──────────────────────────────────────────────────┐
│  📌 YOUR STYLE MAY HAVE SHIFTED                   │
│                                                  │
│  You declared Swing Trading, but your last 20    │
│  trades averaged 4-hour holds.                   │
│  Day Trading might be a better fit.              │
│                                                  │
│  [Update to Day Trading →]    [Keep Swing]       │
│  [◆ Ask Lucid about it]                          │
└──────────────────────────────────────────────────┘
```

---

### Screen C2: Markets List

> **v9.2 restructure:** C2 is now a clean trading dashboard — its JTBD is instrument discovery via search, filter, and sort. All market intelligence (narrative, cohort heatmaps, top movers with rationale, structural edges, risk map, OI/volume dashboards) moved to **Radar → Markets sub-tab**. The Signals view and dual Signals/Instruments toggle are removed from C2. The Top Movers grid is retained as a quick-glance price summary but without the intelligence narrative layer. For deep market intelligence, users navigate to Radar → Markets.

**Purpose:** Browse, filter, and sort all tradeable instruments. Tap any row to open C3 Asset Detail. Quick-access entry to the trade calculator via swipe-left. The primary surface for "I know roughly what I want to trade — show me the list."
**JTBD:** "Show me the instruments. Let me search, filter by type, sort by signal or price, and tap in."
**Regime Bar:** Yes
**Tab Bar:** Yes (Markets highlighted)

#### Entry Points

- Tab bar "Markets" tap
- Home watchlist [All →]
- Deep link `arx://markets`
- Global Search → asset tap → C3 (bypasses C2)
- Notification tap (e.g., price alert) → C2 or C3

#### Wireframe

> **v9.2:** Signals view removed. Top Movers grid retained as price summary (no narrative). Intelligence content moved to Radar → Markets. C2 is now a pure instrument-list dashboard.

```
┌──────────────────────────────────────────────────┐
│ ● $12,450 ↑2.3%                      🔍  🔔(3)  │
├──────────────────────────────────────────────────┤
│ ████████████████ TRENDING ██████████████████  ℹ │
├──────────────────────────────────────────────────┤
│                                                  │
│  🔍 [Search instruments...]                      │
│                                                  │
│  Category Tabs (horizontal scroll):              │
│  [Watchlist] [Hot] [Gainers] [Losers] [New] [Vol]│
│  Underline indicator slides to active tab (200ms)│
│                                                  │
│  TOP MOVERS (2×3 Grid) ────────────────────────── │
│  ┌───────────┬───────────┬───────────┐           │
│  │BTC $67,853│ETH $3,842 │SOL $187   │           │
│  │▲+2.3% 📈 │▼-1.1% 📉 │▲+5.7% 📈 │           │
│  │◆ 4/5      │◆ 3/5      │◆ 5/5      │           │
│  ├───────────┼───────────┼───────────┤           │
│  │HYPE $28.45│ARB $1.12  │DOGE $0.18 │           │
│  │▲+12.1%📈 │▼-3.2% 📉 │→0.0%  ➡️  │           │
│  │◆ 5/5      │◆ 2/5      │◆ 1/5      │           │
│  └───────────┴───────────┴───────────┘           │
│  Each cell tappable → C3. Long-press → QT sheet  │
│  (No narrative/rationale on cells — see Radar)   │
│                                                  │
│  INSTRUMENTS ─────────────────────────────────── │
│  [⭐ Watchlist] [Perps] [Spot] [Both●]           │
│  [Sort: ◆ Signal ▾] [Filter ▽]  [⋮]            │
│                                                  │
│  ── Sorted by: Signal strength (◆) ──            │
│                                                  │
│  ┌──────────────────────────────────────────┐    │
│  │ SOL/USD  $187.20  ↑5.7%  ◆ 4/5          │    │
│  │ Vol: $2.1B  F: 0.012%/8h  Trending 🟢    │ ← │
│  │ ← Swipe left reveals [Trade →] (green)   │    │
│  ├──────────────────────────────────────────┤    │
│  │ BTC/USD  $67,853  ↑2.3%  ◆ 4/5          │    │
│  │ Vol: $18B   F: 0.008%/8h  Trending 🟢    │ ← │
│  ├──────────────────────────────────────────┤    │
│  │ HYPE/USD $28.45   ↑12.1% ◆ 5/5          │    │
│  │ Vol: $890M  F: 0.021%/8h  Breakout 🟢    │ ← │
│  └──────────────────────────────────────────┘    │
│                                                  │
│  [Load more ↓]                                   │
│                                                  │
│  ◆ Want deeper market intelligence?              │
│  [Go to Radar → Markets →]                       │
│                                                  │
├──────────┬──────────┬──────────┬──────────┬──────┤
│  Home    │  Radar   │  Trade   │ Markets● │  You │
└──────────┴──────────┴──────────┴──────────┴──────┘
```

#### Information Architecture

> **v9.2:** Dual Signals/Instruments toggle removed. C2 shows only the Instruments list. Signal intelligence accessible via C3 (drill-down) or Radar → Markets. Search bar promoted to top of C2 for direct instrument lookup.

**Search Bar (v9.2 — promoted to top):**

- Always visible at the top of C2, above category tabs
- Type-ahead search across all 858 instruments by symbol or name
- Results appear inline, replacing category tab content (ESC or tap outside to dismiss)
- Tapping a search result navigates to C3

**Category Tabs (top-level, horizontal scroll):**

| Tab       | Sort Logic                                       | Default                    | Animation              |
| --------- | ------------------------------------------------ | -------------------------- | ---------------------- |
| Watchlist | User's watchlist order (drag-reorderable)        | Shows only watchlist items | Underline slides 200ms |
| Hot       | Weighted: signal_count × confluence × volume_24h | All assets                 | Underline slides 200ms |
| Gainers   | Descending by pct_change_24h (positive only)     | All assets                 | Underline slides 200ms |
| Losers    | Ascending by pct_change_24h (negative only)      | All assets                 | Underline slides 200ms |
| New       | Listed date descending (last 30 days)            | Newly listed               | Underline slides 200ms |
| Volume    | Descending by volume_24h_usd                     | All assets                 | Underline slides 200ms |

**Top Movers Grid (2×3, auto-refresh every 30s):**

| Cell      | Data Fields                                                              | Animation                                    |
| --------- | ------------------------------------------------------------------------ | -------------------------------------------- |
| Each cell | symbol, current_price, pct_change_24h, sparkline_24h, ◆ confluence_badge | Stagger-fade-in on load (50ms between cards) |

Note: Top Movers cells show price + signal strength only. Narrative rationale (cohort positioning, structural edge reasoning) is not shown here — users tap the cell to reach C3, or navigate to Radar → Markets for market intelligence.

**Instruments List (v9.2 — replaces dual view toggle):**

| View            | Content                                                                                                                                 | Sort Options                                           |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| **Instruments** | Asset rows. Each row: symbol, price, 24h change, volume, funding rate (perps), ◆ confluence badge, regime badge, optional sentiment tag | ◆ Signal (default), Price, Change, Volume, Funding, OI |

The Signals view (signal cards with P-layer badges, edge decay rings, narrative text) is removed from C2 in v9.2. Those cards now live exclusively in Radar → Markets.

**Instruments Row Data:**

| Field                   | Format                                     | Source                  | Example                             |
| ----------------------- | ------------------------------------------ | ----------------------- | ----------------------------------- |
| Symbol                  | `BTC/USDT`                                 | Static                  | SOL/USD                             |
| Price                   | `$67,853` (local fiat)                     | Market data (real-time) | $187.20                             |
| 24h Change              | `+2.3%` with color                         | Derived                 | ↑5.7%                               |
| ◆ Signal Strength Badge | `◆ 4/5 signal strength`                    | Lucid Signal API        | ◆ 4/5 signal strength               |
| Volume                  | `$4.2B`                                    | Market data             | $2.1B                               |
| Funding Rate            | `0.012%/8h` (perps only)                   | Market data             | F: 0.012%/8h                        |
| Regime Badge            | `Trending 🟢`                              | Regime API              | Trending 🟢                         |
| Sentiment Tag           | `[Reserve conf 🟢]` (optional, ≤1 per row) | Intelligence API        | [Reserve conf 🟢] [Funding spike ⚠] |
| Watchlist Star          | ⭐ if on watchlist                         | User data               | ⭐                                  |

#### Component Inventory

| #   | Component               | Type                                                   | Behavior                                                                                                                                                                            | Spec                   |
| --- | ----------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| 1   | Search Bar              | Text input (always visible, top of C2)                 | Type-ahead across all instruments. Results replace tab content inline. Tap result → C3. Dismiss: ESC or tap outside                                                                 | Debounce 300ms         |
| 2   | Category Tabs           | Horizontal scrollable tab bar with underline indicator | Tap to switch sort. Active tab underlined. Content below re-sorts with 200ms fade. Underline animates to new tab (200ms, ease-out)                                                  | Spring physics scroll  |
| 3   | Top Movers Grid         | 2×3 static grid with ◆ confluence badges               | Each cell tappable → C3. Auto-refreshes every 30s. Sparklines drawn on load (400ms). No narrative text on cells. Long-press → quick-trade bottom sheet                              | Responsive 2×3 layout  |
| 4   | Instrument Type Filter  | Segmented chips                                        | [Perps] [Spot] [Both●]. Single-select. Filters instrument list only. Persists per session                                                                                           | Spring pills           |
| 5   | Sort Control            | Tappable label + sort sheet                            | [Sort: ◆ Signal ▾] tappable. Sort options: Signal, Price, Change, Volume, Funding, OI. Sort direction toggle                                                                        | Bottom sheet           |
| 6   | Filter Button           | Icon + label                                           | [Filter ▽] opens C2-F Advanced Filter drawer                                                                                                                                        | Tappable               |
| 7   | Overflow Menu           | Three-dot (⋮)                                          | Opens menu: Set price alert, Change display currency, Customize columns                                                                                                             | Bottom sheet           |
| 8   | Instrument Rows         | List rows with swipe action and ◆ confluence badges    | Tap → C3. Long-press → quick action sheet. ◆ Confluence badge inline. Swipe left reveals green [Trade →] button (sticky, animates in 200ms)                                         | Full width             |
| 9   | Sentiment Tags          | Inline chips (≤1 per row)                              | Optional, appears only when material event within 24h. Colored by sentiment (🔴 bearish, 🟢 bullish, ⚡ activity)                                                                   | Inline, right of price |
| 10  | Sort Indicator          | Label                                                  | Shows current sort method. Tappable to change sort direction                                                                                                                        | Text, tappable         |
| 11  | Load More               | Button                                                 | Paginated: 20 items per page. Tap loads next 20. Infinite scroll optional                                                                                                           | Center-aligned button  |
| 12  | Intelligence Bridge CTA | Text link                                              | [Go to Radar → Markets →] appears below the list. Navigates to Radar Markets sub-tab for users who want to see market narrative, heatmaps, top movers rationale. **v9.2 addition.** | Low-emphasis text link |

#### Interactions & CTAs (Complete Interaction Table)

| #   | Element                                 | Tap →                                  | Long Press →                                                      | Swipe →    | Visual Feedback                                 | Animation            |
| --- | --------------------------------------- | -------------------------------------- | ----------------------------------------------------------------- | ---------- | ----------------------------------------------- | -------------------- |
| 1   | Search bar                              | Focus + keyboard up                    | —                                                                 | —          | Bar expands, overlay dims                       | 200ms                |
| 2   | Search result                           | Navigate to C3                         | —                                                                 | —          | Scale 0.98 + highlight                          | 150ms scale          |
| 3   | Category tab                            | Re-sort content below (200ms fade)     | —                                                                 | —          | Underline fill + indicator slide                | 200ms slide          |
| 4   | Top Movers cell                         | Navigate to C3 Asset Detail            | —                                                                 | —          | Scale 0.98 + highlight                          | 150ms scale          |
| 5   | Top Movers cell                         | —                                      | Quick-trade bottom sheet (direction picker + [Open Calculator →]) | —          | Context menu appear                             | 150ms popup          |
| 6   | Instrument type chip [Perps/Spot/Both]  | Filter instrument list                 | —                                                                 | —          | Chip highlight + content fade                   | 200ms fade           |
| 7   | [Sort: ◆ Signal ▾]                      | Open sort options bottom sheet         | —                                                                 | —          | Sheet slide up                                  | 300ms slide          |
| 8   | [Filter ▽]                              | Open Advanced Filter drawer            | —                                                                 | —          | Drawer slide up                                 | 300ms slide          |
| 9   | ⋮ overflow                              | Open options menu                      | —                                                                 | —          | Menu popup                                      | 150ms popup          |
| 10  | Instrument row                          | Navigate to C3                         | —                                                                 | —          | Scale 0.98 + highlight                          | 150ms scale          |
| 11  | Instrument row                          | —                                      | Quick action bottom sheet: Add to watchlist, Set alert, Trade     | —          | Context menu appear                             | 150ms popup          |
| 12  | Instrument row                          | —                                      | —                                                                 | Swipe left | [Trade →] button slides in (green)              | 200ms slide-in       |
| 13  | Instrument row [Trade →] (swipe reveal) | Navigate to C5-NEW (pre-filled symbol) | —                                                                 | —          | Button press highlight                          | 100ms highlight      |
| 14  | Instrument row watchlist star           | Toggle watchlist membership            | —                                                                 | —          | Star fill/unfill + haptic                       | 150ms scale + haptic |
| 15  | Sentiment tag                           | —                                      | —                                                                 | —          | Chip highlight on context menu (long-press row) | —                    |
| 16  | ◆ Confluence badge                      | Tap to open Lucid context bottom sheet | —                                                                 | —          | Badge highlight                                 | 100ms highlight      |
| 17  | [Load more ↓]                           | Fetch next page (20 items)             | —                                                                 | —          | Spinner appear                                  | 150ms spin           |
| 18  | [Go to Radar → Markets →]               | Navigate to Radar Markets sub-tab      | —                                                                 | —          | Text link highlight                             | 100ms                |
| 19  | 🔍 (header)                             | Focus search bar                       | —                                                                 | —          | Icon scale + ripple                             | 100ms                |
| 20  | 🔔 (header)                             | Navigate to NC1                        | —                                                                 | —          | Badge highlight                                 | 100ms                |
| 21  | Entire list                             | —                                      | —                                                                 | Pull down  | Spinner rotate + content slide                  | Spring physics       |

#### State Changes

| Trigger                             | Visual Change                                                                                               |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| Category tab switch                 | Content list cross-fades (200ms) to new sort order. Underline slides to new tab                             |
| Filter applied                      | Results count badge appears on [Filter ▽]. List re-renders with applied filters (200ms fade)                |
| New signal arrives (real-time)      | Signal inserts at top of list with slide-in (250ms). Badge count on Signals toggle updates                  |
| Price update (real-time)            | Price and % change update in-place. Flash green (up) or red (down) for 500ms. ◆ Confluence badge may update |
| Asset added to watchlist            | Star fills (⭐), haptic tap. If Watchlist tab active, row appears                                           |
| Sentiment tag appears               | Chip slides in next to price (200ms). Market data updates every 10s                                         |
| View toggle (Signals ↔ Instruments) | Content cross-fade (200ms). Scroll position resets to top                                                   |

#### Loading / Empty / Error States

| State                         | Visual Treatment                                                                                           |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------- |
| **Initial load**              | Top Movers grid: 6 shimmer cells with ◆ badge placeholders. List: 5 shimmer rows with ◆ badge placeholders |
| **No results (with filters)** | "No assets match your filters. Try adjusting your criteria." with [Reset Filters] CTA                      |
| **No signals**                | "No active signals right now. Signals are generated when Lucid detects opportunities."                     |
| **No watchlist items**        | "Your watchlist is empty. Tap the star on any asset to add it."                                            |
| **Search no results**         | "No assets found for '[query]'. Check spelling or try a different term."                                   |
| **Network error**             | Banner: "Market data unavailable. Showing cached prices." Stale prices at opacity 0.6                      |
| **Market closed (spot)**      | Assets marked with "Market closed" badge. Perp assets normal                                               |

#### Edge Cases

| Scenario                                             | Behavior                                                                                                |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| **User has no watchlist items**                      | Watchlist tab shows: "Your watchlist is empty. Tap the star on any asset to add it."                    |
| **Hundreds of assets**                               | Paginated at 20. Top Movers always shows top 6 with ◆ regime-fit badges. Category tabs show count badge |
| **Rapid price movements**                            | Throttle price flash animation to max 1 per second per row. ◆ Confluence badge updates async            |
| **Sentiment tag overload**                           | Max 1 sentiment tag per asset row. Most recent material event takes priority                            |
| **Top Movers in different regime**                   | Each cell shows its own ◆ regime-fit badge. If regime is Mixed, badge shows mixed state                 |
| **Swipe action on touch-screen with small viewport** | [Trade →] button remains visible after swipe if row still in viewport                                   |

---

### Screen C2-F: Advanced Filter Drawer

**Purpose:** Multi-axis filtering for both signals and instruments. Enables power users to narrow discovery to exactly what they're looking for.
**JTBD:** "Show me only what matches my specific criteria."
**Presentation:** Bottom sheet (70% screen height), slides up from bottom

#### Wireframe

```
┌──────────────────────────────────────────┐
│  FILTERS                        [Reset]  │
│                                          │
│  Asset Class                             │
│  [All●] [Majors] [Alts] [Stables]       │
│                                          │
│  Symbol / Watchlist                      │
│  [All●] [⭐ Watchlist only]             │
│  [search: type to filter symbols...]     │
│                                          │
│  Signal Type                             │
│  [All●] [Anomaly] [Funding] [Wallet]    │
│  [Narrative] [Liquidation]               │
│                                          │
│  Signal Intelligence Layer               │
│  [All●] [P1 Regime] [P2 Participant]    │
│  [P3 Instrument] [P4 Structural]        │
│  [P5 Pattern]                            │
│                                          │
│  Wallet Source                           │
│  [All●] [👁 Watched only]               │
│  [🛡️ All-Weather only]                  │
│  [🎯 Specialists in regime]             │
│                                          │
│  Wallet Classification                   │
│  [All●] [🛡️ All-Weather] [🎯 Specialist]│
│  [Exclude 🍀🤖❓]                       │
│                                          │
│  Trading Mode                            │
│  [All●] [Spot only] [Perps only]        │
│                                          │
│  Confluence Threshold                    │
│  ○────────●───────○  min: 60            │
│                                          │
│  Regime Alignment                        │
│  [All●] [✅ Aligned only]               │
│                                          │
│  Timeframe                               │
│  [1H] [4H●] [24H] [7D]                 │
│                                          │
│  [Apply Filters]                         │
└──────────────────────────────────────────┘
```

#### Component Inventory

| #   | Component                 | Type                | Behavior                                                                      |
| --- | ------------------------- | ------------------- | ----------------------------------------------------------------------------- |
| 1   | Asset Class               | Multi-select chips  | Majors (BTC, ETH, SOL, etc.), Alts, Stables. Selecting "All" deselects others |
| 2   | Symbol/Watchlist          | Toggle + search     | Search is type-ahead with debounce 300ms. Watchlist filter is a chip          |
| 3   | Signal Type               | Multi-select chips  | Filter by signal category                                                     |
| 4   | Signal Intelligence Layer | Multi-select chips  | Filter by P1-P5. Power user feature                                           |
| 5   | Wallet Source             | Multi-select chips  | Filter by wallet relationship                                                 |
| 6   | Wallet Classification     | Multi-select chips  | Filter by wallet type. "Exclude" option removes low-quality wallets           |
| 7   | Trading Mode              | Single-select       | Spot, Perps, or All                                                           |
| 8   | Confluence Threshold      | Slider              | Range 0-100. Default 0 (no filter). Shows numeric value                       |
| 9   | Regime Alignment          | Toggle chip         | "Aligned only" filters to signals matching current regime                     |
| 10  | Timeframe                 | Single-select pills | 1H, 4H (default), 24H, 7D. Affects signal recency                             |
| 11  | [Apply Filters]           | Primary CTA button  | Closes drawer, applies filters, updates C2 list. Shows result count preview   |
| 12  | [Reset]                   | Text button         | Clears all filters to defaults                                                |

#### Interactions

| #   | Element                | Gesture   | Action                                              | Animation                              |
| --- | ---------------------- | --------- | --------------------------------------------------- | -------------------------------------- |
| 1   | Drawer handle          | Drag down | Close drawer (discard changes)                      | Spring physics                         |
| 2   | Chip                   | Tap       | Toggle selection                                    | Scale 0.98 + highlight flash           |
| 3   | Confluence slider      | Drag      | Adjust minimum threshold                            | Thumb follow cursor                    |
| 4   | Search field           | Type      | Filter symbols (debounce 300ms)                     | Keyboard slide-up                      |
| 5   | [Apply Filters]        | Tap       | Apply + close. Badge count on filter button updates | Button press ripple, drawer slide-down |
| 6   | [Reset]                | Tap       | Clear all to defaults (confirmation not needed)     | Chips fade + reset                     |
| 7   | Outside drawer (scrim) | Tap       | Close drawer (discard changes)                      | Scrim fade-out                         |

#### State Persistence

- Filter state persists for the session (not across app restarts)
- Active filter count shown as badge on [Filter ▽] button in C2
- "Reset" available both in drawer and as chip on C2 when filters active

---

<!-- TRACE: US-S2-EVAL-01 | Pain: P1/P2 (signal thesis validation, unified view) | Job: JTBD-S2-01 -->
<!-- TRACE: US-S2-FVAL-01 | Pain: E2/E3 (regime caution, skip trade decision) | Job: JTBD-S2-01 -->

### Screen C3: Asset Detail

**Purpose:** Everything about one instrument, organized by the 5-question signal framework from ARX_2-2-2. This is the ticker-first exploration surface — the user has either determined what to trade or is exploring instruments. All information answers five questions in sequence: Q4 Trust ("Who's trading this?"), Q5 What Changed ("Why now?"), Q1 High Conviction ("Should I trade this?"), Q2 Timing ("Is now the right time?"), Q3 Construction ("How should I size it?"). The starting point is the instrument itself — the questions are answered relative to the ticker as insertion point. **Every path leads to a trade.**

C3 is the most information-dense screen in the app. Multi-tab design manages cognitive load. **Adapts content dynamically** based on instrument type (crypto perp, crypto spot, US stock, commodity perp, commodity spot) to show the most decision-relevant data for each asset class. Includes the new **Price Pulse** (retail-friendly pricing intelligence) and **Smart Depth** (order book intelligence) dual-layer paradigm for pricing data.

> **Prototype Implementation Note (v9.4):** The deployed prototype (`Arx_Mobile_WebApp_v1.0`) implements a unified 5-tab system: **`[Flow] [Signal] [Fundamentals] [Risk] [Traders]`** across all instrument types. The full spec for this implemented tab system is in §"C3 Ticker Detail — 5-Tab System" below. The per-instrument-type tab variants (C3-A through C3-D) documented further below represent the full production spec.

> **Simplified Language Glossary:** See `Arx_4-1-1-0_Mobile_Master_Architecture.md` §Shared Simplified Language Glossary. All screen specs MUST use these terms.

**JTBD:** "Tell me everything I need to know about this asset. Show me the on-chain signals. Help me answer: Who's trading it? What changed? Should I trade it? When? How much?"
**Regime Bar:** Yes
**Tab Bar:** Yes (Markets highlighted) — varies by instrument type

#### The 5-Question Framework on C3 (Ticker Insertion Point)

When a user lands on C3, they've chosen a specific instrument. The 5 signal questions from ARX_2-2-2 still apply but are now organized around the ticker as the starting point. The information display sequence matches how traders naturally evaluate an instrument:

| Question                                         | What It Answers                                                                                                      | Where on C3                                                                                              | Data Source (Hyperliquid)                                                 |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| **Q4: Trust — "Who's trading this?"**            | Which smart wallets, leaders, and tracked traders hold positions in this instrument? What's the consensus direction? | Context Card ("X leaders long this"), Wallets tab, [See Who's Trading →] CTA bridging to Radar           | clearinghouseState.assetPositions (via wallet tracking), userFills        |
| **Q5: What Changed — "Why now?"**                | What signals fired recently? What triggered the move? What's different today vs yesterday?                           | Signals tab, Intelligence Feed section in Overview, Context Card ("Signal: Open Interest surged +$340M") | recentTrades, fundingHistory, candleSnapshot (regime detection)           |
| **Q1: High Conviction — "Should I trade this?"** | What's the confluence score? How many P-layers align? What do both data and people suggest?                          | ◆ Confluence Badge (hero metric), Context Card, Top Signals in Overview                                  | All P1-P5 signals aggregated per instrument                               |
| **Q2: Timing — "Is now the right time?"**        | What's the current regime? Funding cost? Momentum? Where are we in the cycle?                                        | Regime Bar (persistent), Context Card (regime + duration), Funding Rate Strip, Chart                     | assetCtxs (funding.rate, markPx, oraclePx, Open Interest), candleSnapshot |
| **Q3: Construction — "How should I size it?"**   | What entry, stop, target? What leverage? What's the Kelly optimal size? Where's liquidation?                         | Price Pulse widget, Smart Depth, [Trade ▶] CTA → C5-NEW pre-filled, Context Card (Kelly size)            | l2Book (bid/ask/depth), allMids, impactPxs                                |

**[See Who's Trading →] / [Find Leaders →] CTA:** A secondary CTA on every C3 instance that bridges to Radar (adjacent tab). **v9.4:** Now calls `navigateToTradersWithContext({instrument: inst.sym, sort: 's2'})` (S2 label: "See Who is Trading →") or `navigateToTradersWithContext({instrument: inst.sym, sort: 's2', preset: 'topCopyLeaders'})` (S7 label: "Copy [T] Leader ▶"). The "See All N Traders on [T] →" link in trader consensus also uses `navigateToTradersWithContext()`. Previously used raw `state.radarSubTab='traders';state.traderInstrFilter=sym;switchTab('radar');navPop()`. This is the critical bridge between ticker-first exploration (Markets) and people-first exploration (Radar).

#### Price Pulse — Retail-Friendly Pricing Intelligence (NEW)

Traditional order books are intimidating for retail traders — a wall of numbers with no context. Price Pulse is a dual-layer approach that makes pricing data accessible to all users while preserving power-user depth.

**Layer 1: Smart Price Card (Default, always visible on C3 Overview)**

```
┌──────────────────────────────────────────┐
│ 💎 PRICE PULSE                   [Expand]│
│                                          │
│ $174.20                                  │
│ ↑ $2.80 (1.6%) today                    │
│                                          │
│ ┌──── BUY/SELL PRESSURE ────────────┐   │
│ │ ████████████████░░░░░│ 72% Buying │   │
│ │ "Strong buy pressure — above avg"  │   │
│ └────────────────────────────────────┘   │
│                                          │
│ Support: $171.50 (1.6% below)           │
│ Resistance: $176.80 (1.5% above)        │
│ Spread: 0.02% — Tight ✅                │
│                                          │
│ ◆ "Buyers are in control. Key level at  │
│   $176.50 — a break above could trigger │
│   short squeezes worth $28M."           │
│                                          │
│ [See Full Depth →]                       │
└──────────────────────────────────────────┘
```

| Component                   | Data Source (Hyperliquid API)                                                           | What It Shows                                                                                               |
| --------------------------- | --------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Current Price**           | `allMids[symbol]` or `assetCtxs.midPx`                                                  | Mid price, updated real-time via WebSocket                                                                  |
| **24h Change**              | `assetCtxs.prevDayPx` (calculate delta)                                                 | Dollar and percentage change from previous day                                                              |
| **Buy/Sell Pressure Gauge** | Aggregated from `l2Book.levels` — total bid volume vs total ask volume within 2% of mid | Visual bar showing buying vs selling pressure as a percentage. Plain-language annotation from Lucid         |
| **Support Level**           | Largest bid wall from `l2Book.levels[0]` (bid side), filtered for significant clusters  | Nearest major support with distance from current price                                                      |
| **Resistance Level**        | Largest ask wall from `l2Book.levels[1]` (ask side), filtered for significant clusters  | Nearest major resistance with distance from current price                                                   |
| **Spread Health**           | `l2Book.levels[1][0].px - l2Book.levels[0][0].px` (best ask - best bid)                 | Spread as percentage. Annotated: Tight ✅ (<0.05%), Normal 🟡 (0.05-0.15%), Wide 🔴 (>0.15%)                |
| **◆ Lucid Narrative**       | Synthesized from all order book data + signals                                          | 1-2 sentence plain-language insight about what the order book is telling us. Updated on significant changes |
| **[See Full Depth →]**      | Navigation                                                                              | Expands to Layer 2: Smart Depth (full order book)                                                           |

**Layer 2: Smart Depth (Expanded, replaces old C3-OB)**

Accessed via [See Full Depth →] from Price Pulse or via the "Price & Depth" tab. This is the enhanced order book with Lucid annotations — the existing C3-OB design upgraded with retail-friendly annotations and Hyperliquid data integration.

See C3-OB section below for full specification. The key enhancement: every order book row includes `impactPxs` data from Hyperliquid showing the price impact of market orders at various sizes, and ◆ Lucid annotations translate raw depth data into actionable language.

**Why Price Pulse works for retail:**

1. **No numbers overload** — The default view shows 6 data points, not 100 order book rows
2. **Plain language** — "Strong buy pressure" instead of "bid volume: 234,500 SOL"
3. **Actionable** — Support/resistance levels tell traders exactly where to set stops and targets
4. **Progressive disclosure** — Power users tap [See Full Depth →] for the full L2 order book
5. **Always up-to-date** — Real-time Hyperliquid WebSocket data, not stale snapshots

#### Instrument Types and Classification

Arx supports five instrument types, each with distinct data requirements and trader mental models:

| Instrument Type    | Symbol Format      | Examples                                           | Underlying         | Tradeable Mode                   | Key Differentiators                                                                          |
| ------------------ | ------------------ | -------------------------------------------------- | ------------------ | -------------------------------- | -------------------------------------------------------------------------------------------- |
| **Crypto Perp**    | `{ASSET}-PERP`     | `SOL-PERP`, `BTC-PERP`, `ETH-PERP`                 | Cryptocurrency     | Perpetual futures on Hyperliquid | Funding rate, Open Interest, liquidation map, leverage, 24/7 trading                         |
| **Crypto Spot**    | `{ASSET}/USDT`     | `SOL/USDT`, `BTC/USDT`, `ETH/USDT`                 | Cryptocurrency     | Spot buy/sell                    | No leverage, no funding, no liquidation. On-chain metrics, whale accumulation, staking yield |
| **US Stock Perp**  | `{TICKER}.US-PERP` | `AAPL.US-PERP`, `TSLA.US-PERP`, `NVDA.US-PERP`     | US equity          | Perpetual futures (synthetic)    | Market hours awareness, earnings calendar, pre/post-market, sector correlation, P/E, revenue |
| **Commodity Perp** | `{ASSET}.CMD-PERP` | `GOLD.CMD-PERP`, `OIL.CMD-PERP`, `SILVER.CMD-PERP` | Physical commodity | Perpetual futures (synthetic)    | Macro correlation, supply/demand fundamentals, seasonal patterns, geopolitical sensitivity   |
| **Commodity Spot** | `{ASSET}.CMD/USD`  | `GOLD.CMD/USD`, `OIL.CMD/USD`                      | Physical commodity | Spot price exposure              | Reference pricing, portfolio hedge, no leverage                                              |

**Design Principle:** The C3 shell (header, chart, sticky CTA, quick-switch) is identical across all types. The **header data strip**, **context card**, and **tab content** adapt based on instrument type. Users never "switch modes" — the screen simply shows what's relevant.

#### Entry Points

- C2 Markets → tap instrument row or signal card [◆ Deep-Dive →]
- C1 Home → tap watchlist card
- Global Search → tap asset result
- Deep link `arx://asset/{symbol}` (e.g., `arx://asset/SOL-PERP`)
- **Radar Market deeplink (v7.2):** `arx://markets/c3/{ticker}?tab={relevant_tab}&source=radar_market` — arrives with pre-selected sub-tab matching the context the user was viewing in Radar Market drill-down (e.g., if user was viewing Open Interest data, C3 opens on "Derivatives" tab). Source parameter enables back-navigation to Radar.
- Notification → price alert or signal tap
- Radar → signal card [◆ Deep-Dive →]

**Radar Market Deeplink Tab Mapping (v7.2):**

| Radar Market Context       | C3 Tab Target                          | `?tab=` param               |
| -------------------------- | -------------------------------------- | --------------------------- |
| Open Interest / Money Flow | Derivatives (perps) or On-Chain (spot) | `derivatives` or `on-chain` |
| Liquidation Clusters       | Liquidation Map                        | `liquidation-map`           |
| Funding Rates              | Overview (funding section)             | `overview`                  |
| Cohort Positions           | Traders                                | `traders`                   |
| Price + Trend overview     | Overview                               | `overview`                  |
| Holder Trends (spot)       | On-Chain                               | `on-chain`                  |

When `source=radar_market`, the C3 header shows a contextual back-arrow label: "← Back to Radar Market" instead of the default "← Markets".

- **Quick Ticker Switch** → tap **any tappable ticker name throughout the app** (C3, C5-NEW, C6 Position Monitor, TH Trade Hub) → opens ticker search overlay (see §Quick Ticker Switch)
- **Trade Hub (TH)** → tap symbol header → opens C3 for that symbol

#### Quick Ticker Switch — Mobile-Native Speed Navigation

Desktop trading terminals let traders switch tickers instantly by typing a symbol. Mobile needs a different pattern optimized for touch:

**The Ticker Tap Pattern:**

```
┌──────────────────────────────────────────────────┐
│ ← Markets    [SOL/USD Perp ▾]    ★  🔔  ⋮      │
│              ↑ TAPPABLE TICKER                   │
└──────────────────────────────────────────────────┘
```

**Tap the ticker name** anywhere on C3 (or TH, C5-NEW, C6) → opens Quick Ticker Search overlay:

```
┌──────────────────────────────────────────────────┐
│  🔍 [Search ticker...          ]          [✕]   │
│  (keyboard auto-opens, cursor in search field)   │
├──────────────────────────────────────────────────┤
│  RECENT (last 5 tickers viewed):                 │
│  [SOL-PERP] [BTC-PERP] [ETH/USDT] [AAPL.US-PERP]│
│  (tap pill → instant switch, no search needed)   │
│                                                  │
│  WATCHLIST:                                      │
│  ┌──────────────────────────────────────────┐    │
│  │ BTC-PERP    $67,234 ↑1.2%  ◆4/5  🟢    │    │
│  │ ETH-PERP    $3,842  ↓0.8%  ◆3/5  🟢    │    │
│  │ NVDA.US-PERP $892   ↑3.1%  ◆4/5  🟡    │    │
│  │ GOLD.CMD-PERP $2,340 ↑0.4%  ◆2/5 🔵   │    │
│  └──────────────────────────────────────────┘    │
│                                                  │
│  (As user types, results filter instantly)       │
│  (Tap any row → C3 updates in-place, no nav)    │
│                                                  │
│  HOT RIGHT NOW:                                  │
│  [HYPE ↑12%] [ARB ↑8%] [SOL ↑5%]              │
│  (trending tickers as quick pills)               │
└──────────────────────────────────────────────────┘
```

| Property             | Spec                                                                                                                                                                     |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Trigger**          | Tap ticker name text on C3 header, TH header, C5-NEW header, or C6 header                                                                                                |
| **Overlay type**     | Full-screen overlay with 80% opacity backdrop, 300ms slide-down from top                                                                                                 |
| **Search**           | Auto-focus search field, keyboard opens immediately, fuzzy search across all instruments                                                                                 |
| **Recent pills**     | Last 5 tickers the user viewed, displayed as horizontal pill buttons. Single tap → instant switch                                                                        |
| **Watchlist rows**   | User's watchlist with live price, 24h %, confluence badge, regime dot. Single tap → switch                                                                               |
| **Hot tickers**      | Top 3 movers right now as pill buttons                                                                                                                                   |
| **Switch behavior**  | Tap any result → overlay dismisses (200ms fade-up) → C3 updates **in-place** (no navigation push). Chart crossfades (300ms), header data updates, tabs reset to Overview |
| **Keyboard dismiss** | Swipe down on overlay → dismiss. Tap [✕] → dismiss. Tap outside search area → dismiss                                                                                    |
| **Performance**      | Search results filter as-you-type with <50ms latency. Overlay render <100ms                                                                                              |

**Why this is better than desktop typing:**

- Desktop: muscle memory + keyboard speed makes typing `SOL` fast
- Mobile: typing on a keyboard is slow. Instead, **recent pills + watchlist** cover 90% of use cases with a single tap
- The remaining 10% (new ticker) uses search with type-ahead
- Net result: 1 tap (recent) or 2 taps (search + select) to switch — faster than swiping through a list

**Quick-Switch also works from Trade screens:**

- On TH (Trade Hub): tap symbol header → Quick Ticker Search → switch changes both TH context and linked C5-NEW
- On C5-NEW (Calculator): tap symbol in header → Quick Ticker Search → switch resets calculator with new symbol
- On C6 (Position Monitor): tap symbol → Quick Ticker Search → navigates to C3 for selected ticker (doesn't change position view)

#### C3 Shared Shell (All Instrument Types)

The following elements are **identical** across all instrument types:

```
┌──────────────────────────────────────────────────┐
│ ← Markets    [SOL/USD Perp ▾]    ★  🔔  ⋮      │
├──────────────────────────────────────────────────┤
│ ████████████████ TRENDING ██████████████████  ℹ │
├──────────────────────────────────────────────────┤
│                                                  │
│  ── HEADER DATA STRIP (varies by type) ────────  │
│                                                  │
│  ── CONTEXT CARD (varies by type) ──────────────  │
│                                                  │
│  ┌──────────────────────────────────────────┐    │
│  │  ✦ TradingView chart (240px) ✦          │    │
│  │  Lucid overlay: S/R lines, regime zone,  │    │
│  │  leader entry markers (toggle via [◆])   │    │
│  │  [1m] [5m] [15m] [1H●] [4H] [1D] [1W]  │    │
│  │  Indicators: [+Add]   [◆ Overlay ●]     │    │
│  │  (pinch to zoom, tap+hold for crosshair) │    │
│  └──────────────────────────────────────────┘    │
│                                                  │
│  ┌─── ◆ LUCID VIEW ──────── [⚙ Customize] ──┐  │
│  │ OVERALL: BULLISH (72/100)                  │  │
│  │ ████████████████████░░░░░░░░               │  │
│  │                                            │  │
│  │ Regime:     ████████░░ 8/10 · Trending D4  │  │
│  │ Technical:  ███████░░░ 7/10 · RSI 67, MA+  │  │
│  │ On-Chain:   ████████░░ 8/10 · Money in     │  │
│  │ Participant:████████░░ 8/10 · 78% long     │  │
│  │                                            │  │
│  │ ◆ "Strong trend with genuine inflow.       │  │
│  │   Technicals confirm but RSI approaching   │  │
│  │   overbought. Leaders aligned. Main risk:  │  │
│  │   crowded positioning."                    │  │
│  │                                            │  │
│  │ [Trade with this View →] [◆ Ask Lucid]     │  │
│  └────────────────────────────────────────────┘  │
│                                                  │
│  ── TABS (vary by type) ───────────────────────  │
│                                                  │
│  ── TAB CONTENT ───────────────────────────────  │
│                                                  │
├──────────────────────────────────────────────────┤
│ [See Who's Trading→]   [Trade ▶] or [Buy ▶]     │
│  (secondary, outline)   (primary, sticky)         │
└──────────────────────────────────────────────────┘
```

**TradingView Annotation Overlay (v9.0):**

The TradingView chart includes toggleable annotation overlays rendered as a separate HTML layer above the chart iframe. Toggle row sits below chart timeframe pills. Each overlay is independent — users control which layers are visible.

| Overlay            | Source                                                            | Visual                                                                          | Default               |
| ------------------ | ----------------------------------------------------------------- | ------------------------------------------------------------------------------- | --------------------- |
| **S/R lines**      | Order book walls + Fibonacci + pivot points                       | Horizontal dashed lines with pill labels: "$171.50 Support — $58M below"        | ON                    |
| **Regime zones**   | ADX-derived trending channel or BB-derived range boundaries       | Background shading: green=trending, blue=range, amber=volatile, gray=compressed | ON                    |
| **Leader entries** | `clearinghouseState.assetPositions` for **followed leaders only** | Small avatar circles at entry/exit price levels                                 | OFF                   |
| **User positions** | User's own open positions in this asset                           | Entry line (solid), TP line (green dashed), SL line (red dashed)                | ON if position exists |

S7 Sarah sees useful context without adding indicators. S3 Marcus can toggle individual overlays OFF and add his own indicators via [+Add].

**Lucid View (v9.0):**

The Lucid View sits between the TradingView chart and the tab bar. It synthesizes all signal clusters into a single weighted assessment. This is the "so what?" layer — every user sees the conclusion before diving into tab details.

| Property                     | Spec                                                                                                                                                                                                                            |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Position**                 | Below TradingView chart, above tabs. Always rendered.                                                                                                                                                                           |
| **Collapsible**              | Default expanded on first visit. Remembers user preference via `lucid_view_collapsed: boolean`. When collapsed, shows single line: `◆ BULLISH 72/100 — "Strong trend, money inflow, RSI near overbought" [▼]` (~50px height)    |
| **Overall score**            | Weighted composite of all enabled factor clusters (0-100). Labeled with fuzzy language: Very Bearish (0-20), Bearish (21-40), Neutral (41-55), Bullish (56-75), Very Bullish (76-100)                                           |
| **Cluster bars**             | One horizontal bar per active cluster. Bar length = score/10. Inline summary (≤5 words). LucidTooltip on each bar explains what it means                                                                                        |
| **Narrative**                | 2-3 sentence plain-language synthesis. Template: "[Regime context]. [Strongest signal] confirms [direction]. [Weakest/conflicting signal] is the main risk — [specific concern]. [Action suggestion for user's trading style]." |
| **[Trade with this View →]** | Navigates to C5-NEW with full TradeIntent pre-populated from Lucid View data. Direction pre-suggested (not pre-selected) based on overall score                                                                                 |
| **[◆ Ask Lucid]**            | Opens Lucid bottom sheet (Tier 2) with the View as conversation context: "Tell me more about why Technical is 7/10"                                                                                                             |
| **[⚙ Customize]**            | Opens Customize bottom sheet (see below)                                                                                                                                                                                        |
| **Update frequency**         | Re-computed on C3 load + every 60 seconds via background refresh. Score changes >5 points trigger subtle pulse animation on the overall bar                                                                                     |

**Lucid View Factor Clusters (v9.0):**

Five factor clusters cover all tradeable information without overlap. Which clusters are active depends on instrument type:

| Cluster                   | Maps to P-Layer | Active For                                 | Key Indicators                                                                                                                                                                                                                                                      |
| ------------------------- | --------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Regime**                | P1              | All instruments                            | ADX(14), ATR z-score, Bollinger Band position, regime classification, regime duration, regime change probability                                                                                                                                                    |
| **Technical**             | P2 + P5         | All instruments                            | RSI(14), MACD + Signal, Moving Average alignment (20/50/200), Bollinger squeeze, Volume Profile / VWAP, key S/R + Fibonacci levels, ADX direction                                                                                                                   |
| **On-Chain & Structural** | P3 partial + P4 | All instruments (content varies)           | **Perps:** Open Interest + trend, Funding rate + percentile, Basis spread, Liquidation clusters, Money flow, Position crowding. **Spot:** Exchange flow, Whale accumulation, Active addresses, Supply distribution, Staking/yield, NVT ratio, MVRV                  |
| **Participant**           | P3 core         | All instruments                            | Leader consensus, Smart money direction, Whale activity, Retail crowding, Cohort divergence (smart money vs retail)                                                                                                                                                 |
| **Fundamental**           | N/A             | Crypto Spot, US Stock Perp, Commodity Perp | **Crypto Spot:** Tokenomics, Ecosystem TVL, Dev activity, Competitive position. **US Stock:** P/E, P/S, Revenue growth, Earnings, Analyst consensus, Insider activity. **Commodity:** Supply/demand balance, Inventory levels, Seasonal patterns, Geopolitical risk |

**Cluster visibility by instrument type:**

| Instrument     | Regime | Technical | On-Chain/Structural | Participant       | Fundamental    |
| -------------- | ------ | --------- | ------------------- | ----------------- | -------------- |
| Crypto Perp    | ✅     | ✅        | ✅ (perps set)      | ✅                | ❌ hidden      |
| Crypto Spot    | ✅     | ✅        | ✅ (spot set)       | ✅                | ✅ (crypto)    |
| US Stock Perp  | ✅     | ✅        | ✅ (perps, lighter) | ✅ (leaders only) | ✅ (equity)    |
| Commodity Perp | ✅     | ✅        | ✅ (perps, lighter) | ✅ (leaders only) | ✅ (commodity) |
| Commodity Spot | ✅     | ✅        | ❌                  | ❌                | ✅ (commodity) |

**Regime-Conditional Auto-Weighting (v9.0):**

Lucid applies different weights to each cluster based on the current market regime. This is the default "Auto" mode — users can switch to "Manual" to set fixed weights.

| Regime                        | Regime Weight | Technical | On-Chain/Structural | Participant | Fundamental |
| ----------------------------- | ------------- | --------- | ------------------- | ----------- | ----------- |
| **Trending**                  | 10%           | 35%       | 25%                 | 30%         | 0%          |
| **Range-Bound**               | 10%           | 25%       | 35%                 | 20%         | 10%         |
| **Volatile / Transition**     | 30%           | 10%       | 30%                 | 25%         | 5%          |
| **Compressed / Pre-Breakout** | 25%           | 10%       | 40%                 | 20%         | 5%          |

_Rationale: In trends, momentum (Technical) and who's on the right side (Participant) matter most. In ranges, flow data (On-Chain) detects breakout before price. In volatile transitions, regime identity IS the question. In compression, accumulation signals (On-Chain) predict direction before the move._

For instruments where Fundamental is enabled (Spot, US Stock, Commodity), the Fundamental weight is taken proportionally from On-Chain/Structural and Technical.

**Lucid View Customize Panel (v9.0):**

Accessed via [⚙ Customize] button. Bottom sheet (400px height, spring animation, 80% backdrop).

```
┌──────────────────────────────────────────┐
│  ◆ CUSTOMIZE YOUR VIEW                   │
│                                          │
│  Weighting Mode:                         │
│  [Auto●]  [Manual]                       │
│  Auto = Lucid adjusts weights by regime  │
│  Manual = You set fixed weights          │
│                                          │
│  ── FACTOR CLUSTERS ──────────────────── │
│                                          │
│  [✅] Regime Context                     │
│       Trend, volatility, regime maturity │
│       Weight: [Auto-managed by Lucid]    │
│                                          │
│  [✅] Technical Analysis                 │
│       RSI, MACD, MAs, Volume Profile     │
│       Weight: [████████░░ 35%] (Auto)    │
│                                          │
│  [✅] On-Chain & Structural              │
│       Open Interest, Funding, Money Flow │
│       Weight: [██████░░░░ 25%] (Auto)    │
│                                          │
│  [✅] Participant Behavior               │
│       Leaders, Smart Money, Crowding     │
│       Weight: [██████░░░░ 30%] (Auto)    │
│                                          │
│  [☐] Fundamentals                        │
│       (disabled for perps by default)    │
│       Weight: [░░░░░░░░░░ 0%]            │
│                                          │
│  In Manual mode, drag sliders to set     │
│  custom weights. Total must equal 100%.  │
│                                          │
│  [Apply]  [Reset to Default]             │
└──────────────────────────────────────────┘
```

| Property           | Spec                                                                                                   |
| ------------------ | ------------------------------------------------------------------------------------------------------ |
| **Default mode**   | Auto — Lucid manages regime-conditional weights                                                        |
| **Manual mode**    | User drags weight sliders. Total enforced to 100% (adjusting one reduces others proportionally)        |
| **Cluster toggle** | Unchecking a cluster removes it from the score calculation. Weight redistributed to remaining clusters |
| **Persistence**    | Saved per-user in `user_preferences.lucid_view_weights`. Separate settings per instrument type         |
| **Reset**          | Returns to Auto mode with all clusters enabled                                                         |

---

#### C3 Ticker Detail — 5-Tab System (Implemented)

> Merged from Arx_4-1-1-2d (2026-03-30). Ticker detail is now fully specified in this file.

**Version:** 3.1 · **Status:** Implemented (2026-03-14) — QA verified, all 5 tabs rendering with zero errors. v3.1 adds Flow tab enhancements: 5-3 taxonomy labels, Entry Price Distribution (§TD-4.5), Fund Loading (§TD-4.6), Liquidation Clusters by Cohort (§TD-4.7).

**Supersedes:** Arx_Ticker_Page_Redesign_Proposal_v2 (v2 design), Arx_4-1-1-2a §Card 6
**Upstream:** Arx_5-3 Taxonomy v1.0, Arx_5-3 Filter & Sort Review, Arx_5-3 Implementation Proposal v2, Arx_6-1 Lucid Interaction Design System, Arx_Radar_Markets_Soul_Search_v1
**Prototype:** Arx_Mobile_WebApp_v1.0 (`deploy/index.html`) — `showAssetDetail()` function
**Visual companion:** `.superpowers/brainstorm/72453-1773482503/ticker-design-final.html`

##### TD-0: Design Philosophy

**The Shift: Tabs Up, Narrative Down**

The current ticker detail shows insight cards (Who's In, What's Moving, Conditions, Danger Zones, Entry Guide) stacked vertically, with "Explore Data" tabs buried at the bottom. S2 Jake scrolls past 5 cards before reaching the data he wants to explore.

**v3 restructure:** Move the tab system up directly below the price header + chart. The current insight cards become _content within tabs_, not separate overarching modules. A Lucid Synthesis Card above the tabs provides the AI-synthesized "so what?" — regime-weighted, dynamic, and actionable.

**Mental model:** Price → Lucid tells me what matters → I pick the tab I want to explore → I trade.

**Cascading from Radar Markets**

The Radar Markets 5-act narrative (Pulse → Flow → Leaders → Edge → Risk) cascades to ticker level. Each tab mirrors a Radar act but scoped to a single instrument:

| Radar Act      | Ticker Tab       | Question                              |
| -------------- | ---------------- | ------------------------------------- |
| Act 2: Flow    | **Flow**         | "Who's in & where's the money going?" |
| Act 4: Edge    | **Signal**       | "What's the conviction?"              |
| —              | **Fundamentals** | "What drives value?"                  |
| Act 5: Risk    | **Risk**         | "What could go wrong?"                |
| Act 3: Leaders | **Traders**      | "Who's trading this?"                 |

Act 1 (Pulse) lives in the Lucid Synthesis Card — macro context at a glance.

##### TD-1: Page Structure (Top → Bottom)

```
┌──────────────────────────────┐
│  Price Header + Chart        │ ← Unchanged (TD-0)
├──────────────────────────────┤
│  ◆ Lucid Synthesis Card      │ ← NEW: regime-weighted summary
├──────────────────────────────┤
│  [Flow|Signal|Fundmntls|Risk|Traders] │ ← Tab bar (moved UP)
├──────────────────────────────┤
│  Tab Content                 │ ← Modules distributed to tabs
├──────────────────────────────┤
│  Sticky CTA Bar              │ ← Unchanged
└──────────────────────────────┘
```

##### TD-2: Lucid Synthesis Card (Above Tabs)

The overarching intelligence layer. Uses `lucidCard()` pattern from Arx_6-1.

**Content:**

- **Context strip:** Regime badge (☀️ Trending / ⛈️ Volatile / etc.), funding cost, OI, smart money % (from Who's In cohort data)
- **Signal score:** Composite 1–5 with interpretation text
- **Factor pills:** Weighted by current regime — each pill shows the factor name + score, with visual weight (opacity/size) proportional to regime importance
- **Interpretation paragraph:** 2–3 sentences synthesizing all factors. Uses regime context to emphasize what matters most.
- **CTA button:** "◆ Walk me through the full picture" → opens `showLucidDrawer()` (Arx_6-1 defined function) with full analysis

**Regime-Driven Weighting**

The Lucid Synthesis Card dynamically weights which factors are emphasized based on the current regime (D18):

| Regime            | Flow    | Signal  | Fundamentals | Risk    | Traders |
| ----------------- | ------- | ------- | ------------ | ------- | ------- |
| ☀️ Trending       | **35%** | **30%** | 10%          | 15%     | 10%     |
| ⛈️ Volatile       | 15%     | 15%     | 15%          | **40%** | 15%     |
| 🌧️ Mean-Reverting | 20%     | **30%** | 20%          | 20%     | 10%     |
| 🌤️ Transition     | 15%     | 15%     | **30%**      | 20%     | 20%     |
| 😴 Low-Vol        | 20%     | 25%     | 25%          | 10%     | 20%     |

Factor pills are rendered with opacity proportional to weight. The interpretation text leads with the highest-weighted factor. Example in Trending regime: "**High conviction long.** Smart money 82% bullish with expanding momentum..." (leads with Flow because 35% weight).

**Render Function:**

```javascript
function lucidSynthesisCard(instrument, regime) {
  // Uses existing lucidCard() shell from Arx_6-1
  // Adds: weighted factor pills, regime badge, interpretation
  // Data: aggregates from all 5 tab data sources
  // CTA: showLucidDrawer() with full walk-through
}
```

##### TD-3: Tab Bar

5 horizontal scrollable pills below the Lucid Synthesis Card.

```
[Flow] [Signal] [Fundamentals] [Risk] [Traders]
```

- Active tab: Water Cyan (#22D1EE) text + 2px bottom border
- Inactive: #888 text
- Scrollable on mobile (Fundamentals + Risk + Traders may overflow)
- State: `state.assetDetailTab` (replaces current `state.assetTab`)

```javascript
function switchAssetDetailTab(tab) {
  // tab: 'flow' | 'signal' | 'fundamentals' | 'risk' | 'traders'
  // Renders appropriate content below tab bar
  // Each tab function handles its own modules
}
```

##### TD-4: Tab 1 — Flow ("Who's in & where's the money going?")

Cascades Radar Act 2 to ticker level. Two dimensions: **Money Flow** (actual fund transfers) + **Asset Flow** (instrument behavior).

**§TD-4.1 Who's In** _(migrated from TD-1 overarching card)_

- **5 MECE Cohorts (Arx_5-3 D1 Wallet Size Taxonomy):** 🐳 Whale / Mega Whale, ⚡ Daily Active, 🛡 All-Weather, 🔬 Specialists, 🦐 Shrimp / Fish
- Each cohort shows: positioning % + Δ24h change + exposure trend (D62)
- Notable trader callout: shows dim3_tier badge + dim2_strategy + dim1_size inline
- Expandable: L0 = summary (Smart/Retail split), L1 = full 5-cohort bars
- Use-case context: `ticker_whos_in`, default sort: `position_size_in_x` (S11)

**§TD-4.2 Money Flow (NEW)**

Wallet fund transfers in and out of positions on this asset — not trading volume, actual capital movement.

Components:

- **Net Flow Gauge:** Headline inflow/outflow/net with visual ratio bar
- **Cohort Waterfall:** Bidirectional bars per cohort — right = inflow, left = outflow, centered on zero line
- **Flow Velocity Timeline:** 24h hourly bar chart — green = inflow, red = outflow. Annotated spikes (whale events)
- **Exchange Flow Tracker:** Sankey-inspired pipe diagram showing fund sources (CEX Wallets, DeFi Yield, Fresh Capital) → instrument → destinations. Pipe thickness ∝ flow volume

Time toggles: 24h | 7d | 30d

**§TD-4.3 Asset Flow (NEW)**

Volume, OI, buy/sell pressure, and market structure changes on the instrument itself.

Components:

- **Buy/Sell Pressure Gauge:** Tug-of-war bar (taker flow). Shows duration and comparison to average
- **Metrics Grid:** 24h Volume (vs 30D avg), Open Interest (with Δ), Volume/OI Ratio, Exchange Net Flow
- **OI vs Price Overlay:** Dual-line SVG chart (7d). Highlights divergence/confirmation

**§TD-4.4 Whale Activity (NEW)**

- Filtered to D1 Size: Whale ($500K–$5M) + Mega Whale (>$5M) from R13 accountValue
- Each entry shows: dim3_tier badge, dim2_strategy, dim4_risk labels
- Feed format: action + size + timeago
- Net whale flow (24h) summary

**§TD-4.5 Entry Price Distribution (NEW — v5-3)**

Heatmap showing where each wallet size tier (D1) accumulated positions at different price levels.

Components:

- **Stacked bar chart** per price level: BUYS column + SELLS column, color-coded by D1 wallet size (Mega Whale=gold, Whale=blue, Dolphin=cyan, Fish=green, Shrimp=gray)
- **Current price marker** (◄) highlights the nearest price level
- **Legend:** Color-coded wallet size labels from `DIM_LABELS.dim1`
- **Insight card:** Whale avg entry vs Retail avg entry, concentration zones

Data: `MOCK.tickerEntryDistribution[sym]` — price levels with buy/sell volume breakdown by wallet size + summary with avg entry prices and concentration zones.

Why: S2 Jake needs to know _where_ smart money entered — if whale avg entry is significantly lower, it reveals support levels and conviction. If retail avg entry is near current price, they're late — potential bag-holder risk.

**§TD-4.6 Fund Loading / Wallet Deposits (NEW — v5-3)**

Capital entering wallets before being deployed to positions — a leading indicator of upcoming positioning.

Components:

- **Summary row:** Total Deposits | Withdrawals | Net Inflow (3-up grid)
- **Net Flow by Wallet Size (D1):** Horizontal bar chart per tier showing net capital flow + wallet count
- **7-day Deposit Trend:** Sparkline bar chart showing daily deposit volume
- **Insight card:** Auto-generated narrative about unusual deposit patterns (e.g., "Mega Whales deposited 3.4x their 30d average")

Data: `MOCK.tickerFundLoading[sym]` — totalDeposits/withdrawals/netInflow, bySize breakdown with walletCount/avgDeposit, trend7d array, insight text.

Why: Fund loading precedes trading. If Mega Whales are depositing large amounts but haven't opened positions yet, it signals intent. S2 Jake can front-run the positioning surge.

**§TD-4.7 Liquidation Clusters by Cohort (NEW — v5-3)**

Which wallet size cohorts hold what percentage of at-risk liquidation volume at each price level.

Components:

- **Long liquidation clusters** (below current price): sorted by distance from current price, each showing price level, volume, % from current, stacked cohort bar, avg leverage
- **Short liquidation clusters** (above current price): same format
- **Cohort breakdown bar** per cluster: color-coded segments showing which D1 wallet sizes hold the liquidation volume
- **Legend:** Color-coded cohort labels
- **Risk note:** Auto-generated narrative about overexposed cohorts (e.g., "Shrimp / Fish hold 67% of at-risk volume below $180 with 12.4x leverage")

Data: `MOCK.tickerLiqByCohort[sym]` — clusters array with price, volume, type (long/short), byCohort breakdown, avgLeverage, riskNote.

Why: S2 Jake needs to know where the liquidation cascades are and _who_ gets liquidated. If shrimp/fish hold most of the at-risk volume with high leverage, a cascade is more likely. If whales are the ones at risk, it's a different kind of move.

**§TD-4.8 Cohort Flow Divergence (NEW)**

- Auto-generated when cohorts diverge (e.g., 🐳 Whale / Mega Whale + 🛡 All-Weather accumulating while 🦐 Shrimp / Fish reducing)
- References D62 exposure ratio change
- Historical win rate for similar divergence patterns
- Rendered as Lucid hint (Arx_6-1 pattern)

**§TD-4.9 Lucid Hint**

Summary of Flow tab findings. Pattern: Arx_6-1 inline hint with ◆ expand button.

##### TD-5: Tab 2 — Signal ("What's the conviction?")

Merges Conditions + Technical. Cascades Radar Act 4 (Edge) to ticker level.

**§TD-5.1 Conditions (Signal Strength)** _(migrated from TD-3 overarching card)_

- P1–P5 factor bars with scores (0–100)
- Signal strength: X/5 independent signals agree
- Regime context: "Your win rate in [regime]: X% — your [best/worst] regime"
- Diamond rating (◆◆◆◆○)

**§TD-5.2 Pattern Scanner (NEW)**

- Auto-detected chart patterns (Bull Flag, Ascending Triangle, etc.)
- Each pattern: name, confidence %, target price
- Card format, 2-up grid

**§TD-5.3 Technical Indicators (NEW)**

- RSI (14), MACD, VWAP — 3-up grid
- Each: current value, interpretation label, supporting detail
- Previously in separate "Technical" tab — now integrated into Signal

**§TD-5.4 Key Levels** _(migrated from current ticker detail)_

- Support / Current / Resistance in monospace
- Single row, compact

**§TD-5.5 Entry Guide** _(migrated from TD-5 overarching card)_

- Leader avg entry price
- Kelly sizing recommendation
- Setup freshness / expiry bar

**§TD-5.6 Lucid Hint**

Summary of Signal tab. Bull flag + MACD cross + above VWAP type synthesis.

##### TD-6: Tab 3 — Fundamentals ("What drives value?")

Asset-class dependent content. Weighted higher in Transition regimes.

**§TD-6.1 Asset Class Sub-Tabs**

Toggle: Crypto | Stocks | Commodities — determines which modules render. Not yet implemented — branches by inst.type internally.

**§TD-6.2 Crypto Fundamentals**

- **On-Chain Health:** TVL, Protocol Revenue (30d), Active Addresses (7d), Dev Activity (commits/mo)
- **Tokenomics & Supply:** Circulating %, Next Unlock (date + % supply), Inflation rate
- **Ecosystem & Catalysts:** DeFi TVL rank, NFT volume, upcoming catalysts (e.g., Firedancer mainnet)

**§TD-6.3 Stocks Fundamentals** _(stub — coming soon)_

- P/E Ratio, Earnings (next date + estimate), Revenue Growth, Sector Performance
- Analyst consensus (Buy/Hold/Sell distribution)

**§TD-6.4 Commodities Fundamentals** _(stub — coming soon)_

- Supply/Demand balance, Seasonality indicators, Inventory levels
- Geopolitical risk factors

**§TD-6.5 Lucid Hint**

Asset-class-specific synthesis. Token unlock warnings, catalyst assessment.

##### TD-7: Tab 4 — Risk ("What could go wrong?")

Cascades Radar Act 5 to ticker level. Enhanced with full position/funding/liquidation detail.

**§TD-7.1 Danger Zones** _(migrated from TD-4 overarching card)_

- Safety score (0–100 gauge)
- Nearest danger level: price + distance % + capital at risk

**§TD-7.2 Liquidation Heatmap (ENHANCED)**

- Price-level bars: short squeeze zones above, long cascade zones below
- Current price marker
- Color intensity ∝ liquidation volume at each level
- Previously a basic indicator — now full heatmap with price×volume bars

**§TD-7.3 Funding Rate History (NEW)**

- Current rate + annualized + 7d avg
- Chart placeholder: 8h intervals, 14d history
- Warning when elevated (>0.01% — longs paying premium)

**§TD-7.4 Open Interest Breakdown (NEW)**

- Total OI with Δ24h
- Long/Short ratio bar
- **OI by Cohort (5 MECE §TD-4.1):** share %, direction, avg leverage (dim4_avgLeverage)

**§TD-7.5 Position Concentration (NEW)**

- Avg leverage (longs vs shorts)
- Top 10 wallets' share of OI
- Overexposed cohort warning (when one cohort >80% in one direction with high leverage)

**§TD-7.6 Order Book**

- Toggle: Ladder | Depth Chart _(not yet implemented — always renders ladder mode)_
- Wall detection + market impact calculation

**§TD-7.7 Lucid Hint**

Risk synthesis. Funding, liquidation clusters, Shrimp / Fish concentration risk.

##### TD-8: Tab 5 — Traders ("Who's trading this?")

Full Arx_5-3 Taxonomy integration. Primary axes: **Performance Tier (D3) + Wallet Size (D1) + Presets (P1-P9)**.

**§TD-8.1 Quick Filters**

_Presets (curated subset of P1-P9, scoped to asset):_
Horizontal scrollable chips: All | 🏆 Consistent Winners (P1) | 🛡 Safe Hands (P5) | 🔮 Regime Readers (P7) | 🔥 Hot This Week (P8) | 🌤 All-Weather (P9) | ⭐ Top Copy Leaders (P6)

Six of nine P1-P9 presets shown. P2-P4 (Consistent by size tier) omitted — size filtering is handled by the Wallet Size (D1) filter row, making size-specific consistency presets redundant at the ticker level. Each preset applies its composed filter definition from Arx_5-3 Implementation Proposal §2.4, scoped to wallets with exposure to this instrument.

_Performance Tier (D3):_ Filter chips: Elite (gold) | Proven (purple) | Verified (green) | Rising (yellow)

_Wallet Size (D1):_ Filter chips: 🦐 <$10K | 🐟 $10-50K | 🐬 $50-500K | 🐋 $500K-5M | 🐳 >$5M

**§TD-8.2 Sort Controls**

Sort pills: Regime Adaptability (S1/D61, default) | Position Size (S11) | Entry Recency (S12) | Profit Factor (S5) | Consistency (D65/S15)

S1 (Regime Adaptability, D61) is the most actionable sort key. Per-instrument regime win rate is computed (derived from D61 + R23 fills filtered by current regime and instrument). Min 15 trades in current regime to qualify.

**§TD-8.3 Trader Cards**

Each card shows:

_Header row:_ Handle + dim3_tier badge (Elite gold / Proven purple / Verified green / Rising yellow) + D66 profit streak badge ("🔥 8-wk streak") + 7d PnL (right-aligned)

_Label chips (secondary):_ D1 size icon (🐋 Whale) + D2 strategy (Swing) + D4 risk (Moderate) + D5 instrument (SOL-Focused) + D8 regime timing (🔮 Anticipator) — Arx's unique differentiator

_Position row (D9/D64):_ Direction (LONG/SHORT) + notional size + leverage + entry recency. Background: dark card with monospace values.

_Capacity bar (D7 Social):_ Progress bar: Open (<60%) | Filling Up (60-80%) | Nearly Full (80-95%). follower count / maxFollowers.

_CTAs:_ Profile → (opens leader detail) | Copy ▶ (opens copy setup, only if copyable + capacity available)

_Contra signal:_ When an Elite/Proven trader takes a position opposite to majority consensus, flag with "CONTRA" badge and Lucid explanation referencing D59 exit timing.

**§TD-8.4 Recent Notable Trades** _(not yet implemented)_

Feed of recent position changes, filtered to: dim3_tier ∈ {Elite, Proven} AND dim1_size ∈ {Dolphin, Whale, Mega Whale}. Sorted by S12 (entry recency).

**§TD-8.5 Aggregate Stats**

Expandable summary: Total wallets with exposure | % Elite + Proven | % Whale+ ($500K+)

**§TD-8.6 Cross-Navigation**

- "See All X Traders on [SYMBOL] →" — navigates to **Radar Traders page** with `traderInstrFilter` pre-set
- Uses use-case context `whos_trading_x` from Arx_5-3 Implementation Proposal §2.5
- Note: `ticker_whos_in` (§TD-4.1) is the in-tab cohort view; `whos_trading_x` routes to the full Radar Traders leaderboard with instrument pre-filter.

**§TD-8.7 Lucid Hint**

Trader consensus synthesis. Highlights: top performer agreement, notable contra signals, cohort leverage concentration.

##### TD-9: Module Migration Map

| Current Module       | Current Location        | New Location                                                                | Changes                                  |
| -------------------- | ----------------------- | --------------------------------------------------------------------------- | ---------------------------------------- |
| Price Header + Chart | TD-0 (overarching)      | TD-0 (unchanged)                                                            | None                                     |
| Who's In             | TD-1 (overarching card) | **Flow tab §TD-4.1**                                                        | Add Δ24h, D62 exposure trend             |
| What's Moving        | TD-2 (overarching card) | **Flow tab §TD-4.3** (Asset Flow)                                           | Expanded metrics grid, OI vs Price chart |
| Conditions           | TD-3 (overarching card) | **Signal tab §TD-5.1**                                                      | Unchanged                                |
| Danger Zones         | TD-4 (overarching card) | **Risk tab §TD-7.1**                                                        | Unchanged                                |
| Entry Guide          | TD-5 (overarching card) | **Signal tab §TD-5.5**                                                      | Unchanged                                |
| On-Chain tab         | Explore Data tab        | **Flow tab** (market-flow) + **Fundamentals tab §TD-6.2** (on-chain health) | Split by content type                    |
| Technical tab        | Explore Data tab        | **Signal tab §TD-5.2-5.3** (merged)                                         | Pattern scanner, indicators added        |
| Depth tab            | Explore Data tab        | **Risk tab §TD-7.6** (Order Book)                                           | Unchanged                                |
| Liq Map tab          | Explore Data tab        | **Risk tab §TD-7.2** (enhanced)                                             | Full heatmap with price-level bars       |
| Traders tab          | Explore Data tab        | **Traders tab** (full redesign)                                             | 5-3 taxonomy, presets, sort controls     |
| Sticky CTA           | Bottom bar              | Bottom bar (unchanged)                                                      | None                                     |

**New Modules (not in original prototype):**

| Module                                                        | Tab          | Source                     |
| ------------------------------------------------------------- | ------------ | -------------------------- |
| Lucid Synthesis Card                                          | Above tabs   | Arx_6-1 + regime weighting |
| Money Flow (net gauge, waterfall, velocity, exchange tracker) | Flow         | NEW                        |
| Cohort Flow Divergence                                        | Flow         | NEW                        |
| Pattern Scanner                                               | Signal       | NEW                        |
| Technical Indicators (RSI/MACD/VWAP)                          | Signal       | Merged from Technical tab  |
| Fundamentals (asset-class dependent)                          | Fundamentals | NEW                        |
| Funding Rate History                                          | Risk         | NEW                        |
| OI Breakdown by cohort                                        | Risk         | NEW                        |
| Position Concentration                                        | Risk         | NEW                        |
| Preset filter chips (P1-P9)                                   | Traders      | Arx_5-3 Impl. Proposal     |
| Performance Tier + Size filters                               | Traders      | Arx_5-3 Taxonomy D1/D3     |
| Trader DNA aggregate stats                                    | Traders      | NEW                        |

##### TD-10: Data Requirements

From existing MOCK:

- `cohortHeatmapData` → Who's In (§TD-4.1)
- `signalFactors` → Conditions (§TD-5.1)
- `dangerZones` → Danger Zones (§TD-7.1)
- `entryGuide` → Entry Guide (§TD-5.5)
- `keyLevels` → Key Levels (§TD-5.4)
- `traderLeaderboard` → Trader Cards (§TD-8.3)

New MOCK data needed:

```javascript
// §TD-4.2 Money Flow
moneyFlow: {
  inflows: 48200000, outflows: 31600000, net: 16600000,
  byCohort: { topWallets: 18400000, activeTraders: 8200000, allWeather: 4100000, specialists: -2800000, grinders: -11300000 },
  velocity: [...], // 24 hourly net values
  exchangeFlows: { cexToPerp: 14200000, defiToPerp: 6800000, freshCapital: 22000000, perpToDex: 5200000, perpToStables: 3800000 },
  timeframe: '24h'
},
// §TD-4.3 Asset Flow
assetFlow: {
  volume24h: 1840000000, volumeVs30dAvg: 0.87, oi: 3200000000, oiDelta24h: 0.042,
  buyPressure: 0.59, volumeOiRatio: 0.58, exchangeNetFlow: 'outflows',
  oiVsPrice7d: [...] // dual series for SVG chart
},
// §TD-4.4 Whale Activity
whaleActivity: [
  { action: 'opened', size: 4200000, direction: 'long', sizeLabel: 'mega_whale', tier: 'elite', strategy: 'swing', timeago: '2h' },
  { action: 'added', size: 1800000, direction: 'long', count: 3, sizeLabel: 'whale', timeago: '6h' }
],
// §TD-5.2 Pattern Scanner
patterns: [
  { name: 'Bull Flag', confidence: 78, target: 198.40 },
  { name: 'Ascending Triangle', confidence: 62, target: 204.10 }
],
// §TD-5.3 Indicators
indicators: { rsi: 62.4, macd: 'bullish', macdCrossAge: '2d', vwap: 184.30, priceVsVwap: 'above' },
// §TD-6.2 Fundamentals (crypto)
fundamentals: {
  tvl: 8400000000, tvlDelta30d: 0.123,
  revenue30d: 42800000, revenueMoM: 0.081,
  activeAddresses7d: 1200000, addressDelta: -0.032,
  devActivity: 412,
  circulatingPct: 0.782, nextUnlockDays: 18, unlockPct: 0.021, inflationRate: 0.052,
  defiRank: 3, nftVolume: 28000000,
  catalysts: [{ name: 'Firedancer mainnet', type: 'bullish', description: 'Network throughput 10x' }]
},
// §TD-7.3 Funding Rate
fundingRate: { current: 0.00012, annualized: 0.131, avg7d: 0.00008, history: [...] },
// §TD-7.4 OI Breakdown
oiBreakdown: {
  total: 3200000000, delta24h: 0.042,
  longShort: { long: 58, short: 42 },
  byCohort: [
    { cohort: 'topWallets', share: 42, direction: 'long', avgLeverage: 3.8 },
    { cohort: 'activeTraders', share: 28, direction: 'long', avgLeverage: 5.2 },
    { cohort: 'grinders', share: 18, direction: 'mixed', avgLeverage: 8.1 },
    { cohort: 'specialists', share: 8, direction: 'long', avgLeverage: 4.8 },
    { cohort: 'allWeather', share: 4, direction: 'long', avgLeverage: 2.1 }
  ]
},
// §TD-7.5 Position Concentration
positionConcentration: { avgLeverageLong: 4.2, avgLeverageShort: 3.1, top10WalletsOiPct: 34, overexposedCohort: { name: 'grinders', longPct: 89, avgLeverage: 8.1 } },
// §TD-8 Traders (enhanced)
tickerTraders: {
  totalWallets: 467, eliteProvenPct: 16, whalePlusPct: 12,
  traders: [
    {
      handle: 'CryptoAlpha', address: '0x...',
      dim1: 'whale', dim2: 'swing', dim3: 'elite', dim4: 'moderate',
      dim5: 'SOL-Focused', dim6: 'daily', dim7_capacity: 'filling',
      dim7_followers: 248, dim7_maxFollowers: 400,
      dim8: 'anticipator', dim9: 'heavy',
      regimeWR: 78, d61_adaptability: 82, d65_consistency: 4, d66_streak: 8,
      sharpe: 1.82, profitFactor: 2.4, pnl7d: 142000,
      position: { direction: 'long', notional: 820000, leverage: 4.2, entryAge: '3d' }
    }
  ]
}
```

##### TD-11: State Variables

```javascript
state.assetDetailTab = "flow"; // 'flow' | 'signal' | 'fundamentals' | 'risk' | 'traders'
state.moneyFlowTimeframe = "24h"; // '24h' | '7d' | '30d'
state.traderPreset = "all";
state.traderTierFilter = []; // ['elite', 'proven', 'verified', 'rising']
state.traderSizeFilter = []; // ['shrimp', 'fish', 'dolphin', 'whale', 'mega_whale']
state.traderSort = "regime_adaptability";
state.orderBookView = "ladder"; // 'ladder' | 'depth'
// Replaced: state.assetTab → state.assetDetailTab
```

##### TD-12: Render Functions

**New Functions:**

| Function                                 | Purpose                                             |
| ---------------------------------------- | --------------------------------------------------- |
| `lucidSynthesisCard(instrument, regime)` | Renders the weighted synthesis card above tabs      |
| `assetDetailTabBar()`                    | Renders 5-tab pill bar                              |
| `switchAssetDetailTab(tab)`              | Tab router                                          |
| `flowTab()`                              | Full Flow tab content                               |
| `moneyFlowSection()`                     | Net gauge + waterfall + velocity + exchange tracker |
| `assetFlowSection()`                     | Buy/sell pressure + metrics + OI vs Price chart     |
| `whaleActivitySection()`                 | D1 Whale+ feed                                      |
| `cohortDivergenceSection()`              | Divergence alert with Lucid hint                    |
| `signalTab()`                            | Full Signal tab content                             |
| `patternScanner()`                       | Chart pattern detection cards                       |
| `technicalIndicators()`                  | RSI/MACD/VWAP grid                                  |
| `fundamentalsTab()`                      | Asset-class dependent content                       |
| `riskTab()`                              | Full Risk tab content                               |
| `fundingRateSection()`                   | Funding rate history + chart                        |
| `oiBreakdownSection()`                   | OI total + long/short + by cohort                   |
| `positionConcentrationSection()`         | Leverage + concentration metrics                    |
| `tradersTab()`                           | Full Traders tab with 5-3 filters                   |
| `traderQuickFilters()`                   | Preset chips + D3 + D1 filters                      |
| `traderCard(trader)`                     | Individual trader card with 9-dim labels            |

**Modified Functions:**

| Function            | Changes                                                                            |
| ------------------- | ---------------------------------------------------------------------------------- |
| `showAssetDetail()` | Restructured: Price → Chart → Lucid Synthesis → Tab bar → Tab content → Sticky CTA |
| `switchAssetTab()`  | Replaced by `switchAssetDetailTab()`                                               |

##### TD-13: CSS Additions

```css
/* Tab bar */
.asset-detail-tab {
  padding: 8px 14px;
  font-size: 12px;
  color: #888;
  white-space: nowrap;
  cursor: pointer;
}
.asset-detail-tab.active {
  color: #22d1ee;
  font-weight: 600;
  border-bottom: 2px solid #22d1ee;
}
/* Money flow gauge */
.flow-gauge-bar {
  height: 8px;
  background: #1a1a2e;
  border-radius: 4px;
  overflow: hidden;
  position: relative;
}
/* Waterfall bars */
.waterfall-center {
  position: absolute;
  left: 50%;
  border-left: 1px dashed #333;
  height: 100%;
}
/* Buy/sell pressure tug-of-war */
.pressure-bar {
  height: 20px;
  border-radius: 10px;
  overflow: hidden;
  position: relative;
}
.pressure-center {
  position: absolute;
  left: 50%;
  width: 2px;
  background: #fff;
  z-index: 1;
}
/* Trader card */
.trader-dim-chip {
  font-size: 7px;
  padding: 1px 4px;
  background: rgba(255, 255, 255, 0.06);
  color: #888;
  border-radius: 2px;
}
.trader-dim-chip.regime {
  background: rgba(167, 139, 250, 0.1);
  color: #a78bfa;
}
.trader-tier-elite {
  background: rgba(255, 215, 0, 0.15);
  color: #ffd700;
}
.trader-tier-proven {
  background: rgba(167, 139, 250, 0.15);
  color: #a78bfa;
}
.trader-tier-verified {
  background: rgba(52, 211, 153, 0.1);
  color: #34d399;
}
.trader-tier-rising {
  background: rgba(251, 191, 36, 0.1);
  color: #fbbf24;
}
/* Capacity bar */
.capacity-bar {
  height: 3px;
  max-width: 80px;
  background: #1a1a2e;
  border-radius: 2px;
  overflow: hidden;
}
```

##### TD-14: Verification Checklist

1. Price header + chart renders correctly (unchanged)
2. Lucid Synthesis Card shows regime badge, weighted factor pills, interpretation text, CTA
3. Tab bar renders 5 tabs, active state works, scrollable on mobile
4. **Flow tab:** Who's In (5 cohorts with Δ, 5-3 taxonomy labels), Money Flow (gauge + waterfall + velocity + exchange), Entry Price Distribution (§TD-4.5, stacked heatmap by D1 wallet size), Fund Loading (§TD-4.6, deposits/withdrawals/trend), Asset Flow (pressure + metrics + OI chart), Whale Activity, Liquidation Clusters by Cohort (§TD-4.7, long/short breakdown by D1), Divergence
5. **Signal tab:** Conditions (P1-P5 bars), Pattern Scanner, Indicators (RSI/MACD/VWAP), Key Levels, Entry Guide
6. **Fundamentals tab:** Crypto fundamentals (TVL/revenue/addresses/dev/tokenomics/ecosystem). §TD-6.3 Stocks and §TD-6.4 Commodities are stub-only ("coming soon"). §TD-6.1 asset-class toggle UI not yet implemented.
7. **Risk tab:** Danger Zones, Liquidation Heatmap (enhanced), Funding Rate, OI Breakdown (by cohort with leverage), Position Concentration, Order Book. Order Book toggle not yet implemented — always renders ladder mode.
8. **Traders tab:** Preset chips (curated P1-P9), Performance Tier filter (D3), Wallet Size filter (D1), Sort controls (S1 regime adaptability default), Trader cards (9-dim labels + capacity + CTAs), Aggregate stats. §TD-8.4 Recent Notable Trades not yet implemented.
9. Sticky CTA bar renders correctly (unchanged)
10. All Lucid hints render at bottom of each tab
11. Tab switching preserves scroll position
12. Cross-navigation: "See All Traders" links work, "Who's Trading X" works
13. Zero console errors
14. Deploy to Vercel succeeds

---

#### C3-A: Crypto Perpetual Futures

The primary trading instrument on Arx. Maximum information density — traders making leveraged bets need on-chain signals, funding mechanics, liquidation zones, and cohort consensus to manage risk. **Tabs: `[Overview] [Technical] [On-Chain] [Depth] [Liquidation Map] [Traders]`**

**Header Data Strip:**

```
SOL / USD Perp  ★  🔔
$174.20 ◆ 4/5 signal strength  ↑2.8%  24H Vol: $4.2B
Bid: $174.18 · Ask: $174.22 · Spread: 0.02%
```

**Context Card:**

```
◆ REGIME + FUNDING CONTEXT ──────────────────
Status: TRENDING 🟢 · Day 4 · "River with strong current"
Holding Cost: 0.012%/8h · Next: 2h 14m · 🟢 Longs earn
◆ Kelly size: $2,400 · Your win rate in Trending: 72%
3 of your leaders are long SOL  [◆ Details]
```

##### Overview Tab — Crypto Perp

Organized by signal sequence. Focused on regime context, price, and positioning overview.

```
┌──────────────────────────────────────────┐
│ 💎 PRICE PULSE                [See Depth]│
│ $174.20                                  │
│ ↑ $2.80 (1.6%) today                    │
│ ████████░░░░ 72% Buying                 │
│ Support: $171.50 | Resistance: $176.80  │
│ Spread: 0.02% — Tight ✅                │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 💰 MONEY FLOW                            │
│ ┌───────────────────────────────┐        │
│ │ 🟢 MONEY FLOWING IN           │        │
│ │ Capital inflow: +$127M (4h)   │        │
│ │ Based on: Open Interest ↑ + Price ↑      │        │
│ └───────────────────────────────┘        │
│ Interpretation: Real buying pressure.    │
│ Rising Open Bets + rising price =        │
│ genuine capital entering, not short      │
│ covering.                                │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ ⚠️  POSITION CROWDING                     │
│ Bull/Bear Balance: 73% long / 27% short  │
│                                          │
│ WARNING: Extremely crowded long ⚠️        │
│ 73% of open positions betting up.        │
│ Historically, this extreme has           │
│ preceded 8% pullbacks 60% of the time.   │
│ Consider taking profits or setting       │
│ tighter stops.                           │
│                                          │
│ [See liquidity map for forced closes]    │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 24H STATS                                │
│ High: $176.80 | Low: $171.20             │
│ Volume: $4.2B | Open Bets: $3.2B         │
│ Open Bets change: +$340M (+11.9%)        │
│ Interpretation: New money entering.      │
│ Trades today: 847K                       │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ HOLDING COST (Funding Rate)              │
│ Current: 0.012%/8h                       │
│ 🟢 Favorable — Longs earn 🟢             │
│ Annualized at 1x: 1.64%/year             │
│ Annualized at 3x: 4.92%/year             │
│ Annualized at 5x: 8.20%/year             │
│ Next funding in 2h 14m                   │
│ 7-day average: 0.008%/8h (Lower)         │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ REGIME-BEHAVIOR FIT                      │
│ ◆ Your performance in Trending (today):  │
│ Win rate: 72% (vs your baseline 54%)     │
│ Average profit: +$890 per winning trade  │
│ ✅ Aligned: Trending regimes favor       │
│   momentum-following strategies.         │
│                                          │
│ Recommendation: Full Kelly size.         │
│ Avoid countertrend trades.               │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ TOP SIGNALS                              │
│ ◆ P4 STRUCTURAL: Open Interest surged +$340M (4h)  │
│   ◆ Signal Strength: 78/100 | Lucid     │
│   [Trade →] [See Details →]              │
│                                          │
│ ◆ P3 INSTRUMENT: Funding ↑0.08% (8h)    │
│   ◆ Confluence: 52/100 | Source: Market │
│   [Trade →] [See Details →]              │
└──────────────────────────────────────────┘
```

| Component         | Data Source                                                                           | Annotation                                                                            |
| ----------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Price Pulse       | `allMids`, `l2Book`, `impactPxs`, `prevDayPx`                                         | Always visible. Retail-friendly pricing layer                                         |
| Money Flow        | Derived from `assetCtxs.openInterest` + `prevDayPx` + `l2Book` (trade flow imbalance) | Plain-English interpretation: "Money IN" or "Money OUT" with $ amount and time window |
| Position Crowding | Derived from `clearinghouseState` cohort long/short breakdown + historical percentile | Flags extreme crowding (>70/30) with historical precedent and risk warning            |
| 24H Stats         | `assetCtxs.dayNtlVlm`, `openInterest`, `prevDayPx`, `markPx`                          | Volume vs Open Interest divergence as accumulation/distribution indicator             |
| Holding Cost      | `assetCtxs.funding.rate` + derived annualized costs                                   | Simplified "Holding Cost" label. Annualized table for transparency                    |
| Regime Fit        | `candleSnapshot` (regime detection) + user performance data                           | Personalized: "You historically [win/lose] money in this regime on this asset class"  |
| Top Signals       | Aggregated P1-P5 signals (all sources)                                                | Two top by confluence. P-layer badges. [Trade →] CTAs                                 |

##### On-Chain Tab — Crypto Perp

Deep dive into on-chain capital flows, order flow, and cohort positioning. This is the NEW tab that brings on-chain intelligence into Markets.

```
┌──────────────────────────────────────────┐
│ 📊 OPEN BETS (Outstanding Positions)     │
│ Current: $3.2B                           │
│ 1H change: +$78M (+2.5%)                 │
│ 4H change: +$240M (+7.9%)                │
│ 24H change: +$340M (+11.9%)              │
│                                          │
│ 30D Chart: [sparkline showing Open Interest trend]  │
│                                          │
│ Interpretation:                          │
│ New money entering on the long side.     │
│ Rising Open Bets + rising price =        │
│ genuine buying, not short covering.      │
│ (If Open Interest rising + price flat = informed   │
│  accumulation. If Open Interest falling + price     │
│  falling = capitulation/panic selling)   │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 💰 HOLDING COST DEEP-DIVE                │
│                                          │
│ Current Funding: 0.012%/8h               │
│ Predicted next: 0.015%/8h (↑0.003)      │
│ 7-day average: 0.008%/8h                 │
│ 30-day chart: [sparkline]                │
│                                          │
│ Annualized Cost Table:                   │
│ ┌────────────────────────────┐           │
│ │ Leverage │ Annual Cost      │           │
│ │ 1x       │ 1.64% of capital │           │
│ │ 3x       │ 4.92% of capital │           │
│ │ 5x       │ 8.20% of capital │           │
│ │ 10x      │ 16.40% of capital│           │
│ └────────────────────────────┘           │
│                                          │
│ Cost Percentile: 85th                    │
│ ◆ High cost: Current funding is higher  │
│ than 85% of the last 90 days. Holding   │
│ longs is expensive right now.            │
│                                          │
│ Longs vs Shorts: Longs pay shorts        │
│ when positive ✅ (longs benefit today)   │
│                                          │
│ [View 90D history]                       │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 📈 TRADE FLOW                            │
│ Real-time buy vs sell volume balance     │
│ ████████░░ 72% Buy | 28% Sell            │
│ Buy volume: $847M (24h)                  │
│ Sell volume: $329M (24h)                 │
│ Imbalance: +$518M favor of buyers        │
│                                          │
│ 4H rolling trend: ↗️ Strengthening buy   │
│ pressure                                 │
│                                          │
│ Large trades (>$100K):                   │
│ Buy: 342 trades · Average: $2.8M         │
│ Sell: 128 trades · Average: $2.2M        │
│ Interpretation: Big money buying.        │
│                                          │
│ [View recent large trades]               │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 🔗 PERP VS SPOT GAP (Basis Spread)      │
│ Current premium: +0.32%                  │
│ (Perpetual $0.56 above spot)             │
│                                          │
│ Historical percentile: 62nd               │
│ Interpretation: Moderate premium.        │
│ Crowd is moderately bullish.             │
│ Typical range: -1.2% to +2.1%            │
│                                          │
│ 30D chart: [basis history]               │
│                                          │
│ Trader View: When basis is high (+2%+), │
│ perp buyers are paying a premium.        │
│ This creates fade opportunities.         │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 👥 COHORT POSITIONS (THE KEY BRIDGE)    │
│                                          │
│ Smart Money:                             │
│ Direction: 68% Long / 32% Short          │
│ Position size: $1.2B total                │
│ Change 24h: +$89M (↑7.9%)                │
│ [Deep-Dive → See Traders] 📡             │
│                                          │
│ Whale Moves (> $5M position):            │
│ 12 positions | 10 long, 2 short          │
│ Average entry: $171.30 | Average PnL: +$52K │
│ [See These Traders →] 📡                 │
│                                          │
│ Retail Crowd (< $50K position):          │
│ Direction: 81% Long / 19% Short          │
│ Total size: $340M                        │
│ ◆ Contrarian warning: Heavily skewed     │
│ to one side. Historical reversal rate    │
│ at 80%+ crowding: 58%.                   │
│ [See Retail Traders →] 📡                │
│                                          │
│ Proven Traders (your leaders):           │
│ 7 out of 12 followed leaders are long    │
│ Average direction: 71% long              │
│ Average leverage: 3.2x                   │
│ [See Your Leaders →] 📡                  │
│                                          │
│ Note: 📡 buttons bridge to Radar D1      │
│ Discover Leaders, pre-filtered to this   │
│ asset + cohort. Deep-dive into who's     │
│ actually making money here.              │
└──────────────────────────────────────────┘
```

| Component        | Data Source                                                                        | Annotation                                                                                                           |
| ---------------- | ---------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Open Bets        | `assetCtxs.openInterest`, historical snapshots (10-min intervals)                  | Plain-language interpretation of Open Interest × Price relationship                                                  |
| Holding Cost     | `assetCtxs.funding.rate`, predicted rate, 7D/30D history                           | Annualized table for all leverage levels. Percentile for context                                                     |
| Trade Flow       | `recentTrades` buy/sell ratio, `l2Book` aggregated, large trade detection (>$100K) | Real-time buy/sell imbalance. Large trade flagging                                                                   |
| Perp vs Spot Gap | Derived from `assetCtxs.markPx` (perp) vs spot price feed                          | Historical percentile context. Plain-English interpretation                                                          |
| Cohort Positions | `clearinghouseState.assetPositions` aggregated by cohort classification            | **KEY: Each cohort has [Deep-Dive →] button that navigates to Radar D1 Discover Leaders filtered by asset + cohort** |

**Cohort Deep-Dive Bridges (Critical for User Discovery):**
Each cohort section includes a `[Deep-Dive → See {Cohort} Traders]` CTA that navigates:

- **From:** C3-A, On-Chain tab, Cohort Positions section
- **To:** Radar tab → D1 Discover Leaders
- **Pre-filtered by:** `{ asset: "SOL-PERP", cohort: "smart_money" }` (or "whales", "retail", "proven_traders")
- **Shows:** All traders in that cohort holding this asset, sorted by position size or performance. Full profile access to deep-dive into who those traders are, what else they hold, their track record

This bridges the gap between Markets (ticker-first) and Radar (people-first). User can see "Retail is 81% long" and immediately deep-dive to see which specific retail traders they should follow (or fade).

##### Technical Tab — Crypto Perp (v9.0)

Technical analysis indicators with Lucid interpretation. Every metric includes a LucidTooltip (Tier 1: inline plain-language explanation + "Ask Lucid more" button → Tier 2: full Lucid conversation).

```
┌──────────────────────────────────────────┐
│ 📊 TA SUMMARY                           │
│                                          │
│ Technical Score: 7/10 BULLISH            │
│ ██████████████░░░░░░ 7/10               │
│                                          │
│ ◆ "Momentum indicators confirm the      │
│   trend. RSI at 67 is healthy but        │
│   approaching caution zone. All major    │
│   moving averages aligned bullish.       │
│   MACD positive and accelerating.        │
│   Consider trailing stops rather than    │
│   new entries at these levels."          │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 📈 OSCILLATORS                           │
│                                          │
│ RSI(14): 67 · Bullish ✅                 │
│   ◆ "Healthy momentum. Not yet          │
│     overbought (>70). Room to run."     │
│                                          │
│ Stochastic RSI: 0.82 · Overbought ⚠    │
│   ◆ "Fast oscillator showing extended.  │
│     Often leads RSI — early warning."   │
│                                          │
│ MACD: +1.24 · Bullish Crossover ✅      │
│   Signal: +0.98 · Histogram: +0.26      │
│   ◆ "MACD above signal and widening.    │
│     Momentum accelerating."             │
│                                          │
│ CCI(20): +118 · Bullish ✅              │
│   ◆ "Above +100 confirms uptrend.       │
│     Above +200 would be extreme."       │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 📏 MOVING AVERAGES                       │
│                                          │
│ Price vs MAs:                            │
│  20 MA: $171.20 (price above ✅)         │
│  50 MA: $168.50 (price above ✅)         │
│ 200 MA: $152.30 (price above ✅)         │
│                                          │
│ Alignment: 20 > 50 > 200 ✅             │
│ ◆ "Perfect bullish alignment —           │
│   short-term above long-term.            │
│   Golden Cross active (50 > 200)."       │
│                                          │
│ EMA(9): $173.80 (near-term trend)       │
│ VWAP: $172.40 (today's fair value)       │
│ ◆ "Price above VWAP — buyers in         │
│   control of today's session."           │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 📊 VOLATILITY                            │
│                                          │
│ Bollinger Bands:                         │
│ Upper: $178.40 · Mid: $171.20 · Lower: $164.00 │
│ Position: Near upper band (76th %ile)    │
│ ◆ "Price approaching upper band —        │
│   extended but not extreme. Band width   │
│   widening = trend strengthening."       │
│                                          │
│ ATR(14): $4.20                           │
│ ◆ "Average daily range of $4.20.         │
│   Moderate volatility — normal for       │
│   this asset in Trending regime."        │
│                                          │
│ ADX(14): 32 · Strong Trend ✅            │
│ ◆ "ADX above 25 confirms directional    │
│   trend. At 32, the trend is strong     │
│   but not yet extreme (>40)."           │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 🎯 KEY LEVELS                            │
│                                          │
│ Fibonacci Retracements (recent swing):   │
│ 0.236: $176.80 (first support)           │
│ 0.382: $173.10 (key support)             │
│ 0.500: $170.20 (mid-point)               │
│ 0.618: $167.30 (deep support)            │
│ 1.618 extension: $194.80 (target)        │
│                                          │
│ Pivot Points (daily):                    │
│ R2: $178.60 · R1: $176.40               │
│ Pivot: $174.20                           │
│ S1: $172.00 · S2: $169.80               │
│                                          │
│ ◆ "Key level to watch: $176.80           │
│   (Fib 0.236 aligns with daily R1).     │
│   Break above opens path to $180+.       │
│   Support cluster at $173 (Fib 0.382    │
│   + 20 MA confluence)."                  │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 📊 VOLUME ANALYSIS                       │
│                                          │
│ 24H Volume: $4.2B                        │
│ vs 7D Average: +18% (above average ✅)   │
│ vs 30D Average: +32% (well above ✅)     │
│                                          │
│ Volume Profile (20D):                    │
│ Point of Control: $171.50                │
│ Value Area High: $176.20                 │
│ Value Area Low: $167.80                  │
│                                          │
│ ◆ "Volume confirming the move — price    │
│   rising on above-average volume is      │
│   genuine demand, not thin-market        │
│   drift. POC at $171.50 is strong       │
│   support where most volume traded."     │
└──────────────────────────────────────────┘
```

| Component       | Data Source                                                                  | Annotation                                                        |
| --------------- | ---------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| TA Summary      | Aggregate of all oscillator + MA + volatility scores                         | Weighted score with Lucid narrative                               |
| Oscillators     | Computed from `candleSnapshot` historical OHLCV data                         | Each indicator has LucidTooltip with plain-English interpretation |
| Moving Averages | Computed from `candleSnapshot` + current `allMids`                           | Alignment check + Golden/Death cross status                       |
| Volatility      | Bollinger Bands + ATR from `candleSnapshot`, ADX from directional indicators | Band position + trend strength confirmation                       |
| Key Levels      | Fibonacci from recent swing high/low, Pivot Points from daily OHLCV          | Level confluence detection (Fib + MA + S/R alignment)             |
| Volume Analysis | `assetCtxs.dayNtlVlm` + historical volume, Volume Profile from OHLCV         | Volume confirmation + Point of Control (institutional fair value) |

---

##### Depth Tab — Crypto Perp

Three-layer progressive disclosure for order book information (v9.0). The Depth tab defaults to the Horizontal Ladder view, with a toggle to switch to the Depth Staircase. Wall detection threshold: >3× average volume for institutional wall annotation. Both Layer 1 (Ladder) and Layer 2 (Staircase) support tap-to-preset-limit functionality.

**View Toggle (top of tab):** `[Ladder●] [Depth Chart]`

**Layer 0 — Price Pulse:** Always visible in the Overview tab (see above). 6 data points + Lucid narrative. Serves 80% of users (S7).

**Layer 1 — Horizontal Ladder (DEFAULT in Depth tab):**

```
┌──────────────────────────────────────────┐
│ [Ladder●] [Depth Chart]                  │
│                                          │
│ ──────── ASKS (sellers) ────────         │
│ ▓▓▓▓▓▓▓▓ $176.80  0.90 BTC              │
│ ▓▓▓▓▓    $176.20  0.52 BTC              │
│ ▓▓▓      $175.80  0.35 BTC              │
│ ▓▓       $174.40  0.12 BTC  ◄ last ask  │
│ ▓        $174.22  0.05 BTC              │
│ ─────── SPREAD: 0.02% ($0.04) ──────── │
│ ▓        $174.18  0.03 BTC              │
│ ▓▓       $174.10  0.09 BTC  ◄ last bid  │
│ ▓▓▓      $173.50  0.28 BTC              │
│ ▓▓▓▓▓▓   $172.80  0.68 BTC  ★ WALL      │
│ ▓▓▓▓▓▓▓▓ $171.50  0.92 BTC  ★ WALL      │
│ ──────── BIDS (buyers) ────────         │
│                                          │
│ Impact: Buy $5K → fill $174.25 (0.03%)  │
│ Impact: Sell $5K → fill $174.15 (0.02%) │
│                                          │
│ ◆ "Strong bid walls at $172.80 and      │
│   $171.50. Total support: $1.6M within  │
│   1.5% of price. Ask side is thinner —  │
│   less resistance above."               │
└──────────────────────────────────────────┘
```

| Property                 | Spec                                                                                                                                                                           |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Default view**         | Ladder (indicated by ● dot on [Ladder●] toggle)                                                                                                                                |
| **Levels shown**         | 10 levels visible (5 ask + 5 bid), scrollable for up to 20 each side                                                                                                           |
| **Bar rendering**        | Horizontal bars, length proportional to volume at level relative to max visible volume. Asks = red bars (left-aligned from price), Bids = green bars (left-aligned from price) |
| **Wall detection**       | Levels with >3× average volume across visible range get ★ WALL label and subtle glow border                                                                                    |
| **Tap behavior**         | Tap any price level → pre-fills limit order price in C5-NEW. Navigates to C5-NEW if not already open                                                                           |
| **Last trade indicator** | ◄ arrow on the row where the most recent trade executed                                                                                                                        |
| **Impact calculator**    | Always visible below the ladder. Shows estimated fill price and slippage for preset sizes ($1K, $5K, $10K, $25K). Computed from `impactPxs` data                               |
| **Lucid annotation**     | 1-2 sentence narrative below impact calculator. Summarizes support/resistance balance and notable walls                                                                        |
| **Update frequency**     | Real-time via WebSocket. Bars animate smoothly on updates (200ms transition)                                                                                                   |
| **Scroll behavior**      | Scroll within the ladder to see deeper levels. Sticky spread row always visible in center                                                                                      |

**Layer 2 — Depth Staircase (toggle to [Depth Chart]):**

Cumulative area chart showing overall liquidity shape. Bids build up from the left (green), asks build down from the right (red). Y-axis = cumulative volume at each price level. "Cliffs" in the staircase = walls (large orders at a single level causing a sharp step in the curve).

| Property                            | Spec                                                                                                                                                                                                                         |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Chart type**                      | Cumulative area chart, bids left (green fill), asks right (red fill). X-axis = price, Y-axis = cumulative volume                                                                                                             |
| **Annotated cliffs**                | Major walls (>3x average volume) are annotated with labels: `"$0.9M wall @ $171.50"`. Dashed vertical line from cliff to price axis                                                                                          |
| **Impact price calculator overlay** | Draggable horizontal line overlaid on chart. User drags to a size → chart highlights the fill region and shows estimated average fill price + slippage percentage. Example: `"Buy $50K → avg fill $174.38 (0.10% slippage)"` |
| **Current price marker**            | Vertical dashed line at current mid-price, labeled                                                                                                                                                                           |
| **Zoom**                            | Pinch to zoom into tighter price range. Double-tap to reset                                                                                                                                                                  |
| **Lucid annotation**                | Same narrative as Ladder view, positioned below chart                                                                                                                                                                        |

##### Liquidation Map Tab — Crypto Perp

Liquidation heatmap, key levels, cascade risk, and trader breakdown.

```
┌──────────────────────────────────────────┐
│ 🔥 LIQUIDATION HEATMAP                   │
│ (Y-axis: Price levels | X-axis: $ risk) │
│                                          │
│      ▲ Ask side (forced buying)          │
│      │                                   │
│ $178 │ ◼◼ ($12M in liquidations)        │
│ $176 │ ◼◼◼◼◼ ($42M in liquidations)     │
│ $174 │ ▲ CURRENT: $174.20               │
│ $172 │ ◼◼◼◼◼◼◼ ($58M in liquidations)   │
│ $170 │ ◼◼◼ ($28M in liquidations)       │
│      │                                   │
│      ▼ Bid side (forced selling)         │
│                                          │
│ Color intensity = concentration          │
│ (darker = more liquidations at that px)  │
│                                          │
│ User position overlay (if applicable):   │
│ Your long position liq at $152.30 (18%) │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 📍 KEY LIQUIDATION LEVELS                │
│                                          │
│ Heavy long liquidations at $172:         │
│ $58M at risk — major support magnet      │
│                                          │
│ Heavy short squeeze zone at $178:        │
│ $42M at risk — major resistance magnet   │
│                                          │
│ Interpretation: These price levels      │
│ will see intense buying/selling as       │
│ traders' positions force-close. Price    │
│ gravitates toward them.                  │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ ⚠️  CASCADE RISK                          │
│                                          │
│ Probability of liquidation cascade:      │
│ ████░░░░░ 40% Moderate                   │
│                                          │
│ If price drops 5% to $165:                │
│ $42M of long positions forced close      │
│ → Potential cascade of further selling   │
│ → Estimated additional 2-3% pressure     │
│ → Could accelerate to $160 if momentum   │
│    builds                                │
│                                          │
│ Historical precedent: When $42M+         │
│ liquidations trigger, 68% of the time    │
│ cascades extend 1-2 more price levels.   │
│                                          │
│ Implication: If you're long, place       │
│ stops above liquidation clusters or be   │
│ prepared for volatility.                 │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 👥 WHO GETS LIQUIDATED?                  │
│                                          │
│ Smart Money: 12 positions within 10%     │
│ of liquidation ($340M at risk)           │
│ [See Smart Money Positions →] 📡         │
│                                          │
│ Whales: 3 positions within 10%           │
│ ($34M at risk)                           │
│ [See Whale Positions →] 📡               │
│                                          │
│ Retail Crowd: 340 positions within 5%    │
│ of liquidation ($8.2M total)             │
│ ⚠️  High concentration of retail margin  │
│ Call. If support breaks, retail gets     │
│ wiped. Profit opportunity when you       │
│ understand retail's pain points.         │
│ [See Retail Positions →] 📡              │
│                                          │
│ Proven Traders: 2 positions within 10%   │
│ ($1.8M at risk)                          │
│ [See Your Leaders →] 📡                  │
│                                          │
│ Note: 📡 buttons deep-dive to Radar     │
│ D1 filtered by cohort. Understand who    │
│ holds the positions at risk.             │
└──────────────────────────────────────────┘
```

| Component           | Data Source                                                                     | Notes                                           |
| ------------------- | ------------------------------------------------------------------------------- | ----------------------------------------------- | ------------------------------------- |
| Liquidation Heatmap | Derived from `l2Book` + exchange liquidation data                               | Y-axis: price levels                            | X-axis: aggregated liquidatable value |
| Key Levels          | Cluster detection from liquidation data                                         | Callouts for major concentration points         |
| Cascade Risk        | Historical analysis of liquidation depth impact + current structure             | Probability gauge + precedent context           |
| Who Gets Liquidated | `clearinghouseState.assetPositions` aggregated by cohort + liquidation distance | Each cohort has [See Traders →] bridge to Radar |

##### Traders Tab — Crypto Perp

Leader positions, smart money activity, and cohort consensus heatmap.

```
┌──────────────────────────────────────────┐
│ 👤 LEADER POSITIONS                      │
│ Your followed leaders holding SOL-PERP:  │
│                                          │
│ @ProTrader Elite:                        │
│ Direction: LONG · Entry: $172.40         │
│ Size: $340K (5x) · Current PnL: +$3.2K  │
│ [View Profile →]                         │
│                                          │
│ @GridMaster:                             │
│ Direction: LONG · Entry: $171.80         │
│ Size: $120K (3x) · Current PnL: +$2.8K  │
│ [View Profile →]                         │
│                                          │
│ @OptimusCopy:                            │
│ Direction: SHORT · Entry: $176.50        │
│ Size: $80K (2x) · Current PnL: +$1.2K   │
│ [View Profile →]                         │
│                                          │
│ Total leader positions: 7 long, 2 short  │
│ Leader consensus: 78% long on this asset │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 💎 SMART MONEY ACTIVITY                  │
│ Top 5 smart money wallets with recent    │
│ activity on SOL-PERP (last 7D):          │
│                                          │
│ Wallet: 0x82a7...                        │
│ Tier: Tier-1 Smart Money                 │
│ Direction: LONG · Entry: $169.50         │
│ Size: $2.3M (4x) · Current PnL: +$12K   │
│ Recent activity: Added $500K 2h ago      │
│ [Follow →]                               │
│                                          │
│ Wallet: 0x5f3c...                        │
│ Tier: Tier-1 Smart Money                 │
│ Direction: LONG · Entry: $171.20         │
│ Size: $1.8M (3x) · Current PnL: +$5.8K  │
│ Recent activity: Took partial profit 6h  │
│ [Follow →]                               │
│                                          │
│ [See all smart money wallets →] 📡       │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 📊 COHORT CONSENSUS GRID                 │
│ Visual heatmap of each cohort's          │
│ direction on this asset:                 │
│                                          │
│ ┌──────────────────────────────┐         │
│ │ Smart Money:  🟢🟢🟢🟢🟢        │ 68% L │
│ │ Whales:       🟢🟢🟢🟢🟡        │ 61% L │
│ │ Retail:       🟢🟢🟢🟢🟢🟢      │ 81% L │
│ │ Proven Trad:  🟢🟢🟢🟢🔴        │ 67% L │
│ └──────────────────────────────┘         │
│                                          │
│ Size of box = position magnitude         │
│ 🟢 = long · 🔴 = short · 🟡 = neutral   │
│                                          │
│ Interpretation:                          │
│ Retail is heavily long (81%). Smart     │
│ money slightly less bullish (68%).       │
│ Whales cautious (61%). Classic crowd     │
│ vs smart money divergence — watch for    │
│ whales taking the other side.            │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ [See All Traders for SOL-PERP →]         │
│                                          │
│ Navigate to Radar D1 Discover Leaders,   │
│ pre-filtered to SOL-PERP only. See all   │
│ traders holding this asset, sorted by    │
│ position size or track record.           │
│                                          │
│ This is the full bridge from Markets     │
│ (ticker-first) to Radar (people-first). │
└──────────────────────────────────────────┘
```

| Component            | Data Source                                                            | Annotation                                              |
| -------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------- |
| Leader Positions     | `clearinghouseState.assetPositions` filtered by followed leaders       | Profile buttons bridge to Radar → Leader Detail         |
| Smart Money Activity | Top tracked wallets, aggregated from `clearinghouseState` + blockchain | Recent activity highlighting showing capital moves      |
| Cohort Consensus     | Aggregated cohort direction breakdown (long/short %)                   | Visual grid showing relative positioning and divergence |
| See All Traders CTA  | Navigation                                                             | Bridges C3 → Radar D1 pre-filtered by asset             |

**Sticky CTA (dual):**

```
┌──────────────────────────────────────────────────┐
│ [See Who's Trading →]    [Trade ▶ SOL-PERP]      │
│  (secondary, outline)     (primary, stone)        │
└──────────────────────────────────────────────────┘
```

- `[Trade ▶ SOL-PERP]` (Primary) → C5-NEW with full TradeIntent populated from C3 data:

  ```
  TradeIntent {
    symbol: "SOL-PERP",
    direction: null,                        // User chooses on C5-NEW
    source: "markets_c3",
    instrument_type: "perp",
    regime_context: { state, strength, change_prob_4h },  // From Regime Bar
    funding_rate: assetCtxs.funding.rate,   // From On-Chain tab
    funding_percentile: derived,            // From Holding Cost section
    wallet_consensus: { direction, count, strength },     // From Traders tab
    leader_positions: [top 5],              // From Traders tab Leader Positions
    smart_money_net_position: derived,      // From Traders tab Smart Money Activity
    suggested_tp: null,                     // Populated by Lucid on C5-NEW
    suggested_sl: null,                     // Populated by Lucid on C5-NEW
    suggested_size: null,                   // Populated by Lucid on C5-NEW
    entry_price: null,                      // Set if user taps order book level
    oi_regime_alignment: derived            // From On-Chain Open Interest × Price analysis
  }
  ```

  **Note:** C3 has access to ALL on-chain and trader data needed to populate TradeIntent. Fields like `funding_rate`, `wallet_consensus`, `leader_positions`, and `smart_money_net_position` are already computed for C3 display and passed through to pre-fill Lucid annotations on C5-NEW.

  **[Trade ▶] Implementation:** Calls `navPop(); openTrade(sym)` where `sym` is the current asset's symbol (e.g., 'SOL-PERP'). `openTrade()` sets `state.tradeMode = 'calc'` and navigates directly to the Trade calculator for that instrument, bypassing the Trade Hub. The `navPop()` dismisses the C3 detail overlay before switching tabs.

  **Return navigation from Trade (v7.0):** When user navigates to C5-NEW via [Trade ▶], the Trade module shows a [View in Markets →] floating pill on the chart area. Tapping this pill navigates back to C3 for the same symbol. On return, C3 displays a floating [Return to Trade →] pill at the bottom for 5 seconds (auto-dismiss) so the user can jump back to their in-progress trade. This two-way bridge preserves state in both modules.

- `[See Who's Trading →]` (Secondary, outline style) → Radar tab → D1 Discover Leaders filtered to SOL-PERP. Bridges ticker-first → people-first exploration

---

#### C3-B: Crypto Spot

Spot trading is simpler — no leverage, no liquidation, no funding. Focus shifts to on-chain fundamentals, accumulation patterns, staking yield, and long-term value metrics. **Tabs: `[Overview] [Technical] [On-Chain] [Order Book] [Holders] [Fundamentals]`**

**Header Data Strip:**

```
SOL / USDT Spot  ★  🔔
$174.20 ◆ 3/5 signal strength  ↑2.8%  24H Vol: $1.8B
Bid: $174.18 · Ask: $174.23 · Spread: 0.03%
```

**Context Card:**

```
◆ REGIME + ON-CHAIN CONTEXT ─────────────────
Status: TRENDING 🟢 · Day 4 · "River with strong current"
On-chain: Whale accumulation +$12M (7D) · Exchange outflow
Staking APY: 7.2% · 68% staked (↑ from 65% last month)
[◆ Details]
```

##### Overview Tab — Crypto Spot

Simplified overview for spot traders — price, market fundamentals, accumulation signals, yield opportunities.

```
┌──────────────────────────────────────────┐
│ 💎 PRICE PULSE                [See Depth]│
│ $174.20                                  │
│ ↑ $2.80 (1.6%) today                    │
│ ████████░░░░ 72% Buying                 │
│ Support: $171.50 | Resistance: $176.80  │
│ Spread: 0.03% — Normal 🟡               │
│ ◆ "Volume breaking to upside. Spot     │
│   buyers showing strength."              │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 📊 24H STATS                             │
│ High: $176.80 | Low: $171.20             │
│ Volume: $1.8B | Market cap: $82B         │
│ Circulating supply: 47.2M SOL            │
│ Fully diluted: 56.8M SOL (projected)    │
│ FDV: $97.5B                              │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 📈 PRICE PERFORMANCE                     │
│ 1D: +1.6% | 7D: +8.3% | 30D: -2.1%     │
│ 90D: +28.4% | YTD: +35.2% | 1Y: +118%  │
│                                          │
│ All-time high: $260.40 (Nov 2021)       │
│ Distance from ATH: -33% (discount)      │
│ All-time low: $0.50 (Jan 2020)          │
│                                          │
│ Interpretation: SOL has recovered from  │
│ lows but still 33% below peak. Long-    │
│ term trend: strong growth (118% YTD).   │
│ Currently trading in middle of range.    │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 💰 YIELD OPPORTUNITIES                   │
│ Native staking APY: 7.2%                 │
│ Validators: 2,340 active                 │
│ % of supply staked: 68% (↑ from 65%)    │
│                                          │
│ Liquid staking alternatives:             │
│ • Lido stSOL: 7.0% APY                   │
│ • Marinade mSOL: 7.1% APY                │
│ • JitoSOL: 8.2% APY (higher risk)       │
│                                          │
│ DeFi yield on lending protocols:         │
│ • Lending on Lend Protocol: 8.5% APY    │
│ • Lending on Marinade: 6.8% APY         │
│                                          │
│ Takeaway: If holding spot, you earn     │
│ yield. 7%+ is solid for crypto.         │
│ Compound annually = meaningful wealth    │
│ building over 5+ years.                  │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 👁️ WALLET CONSENSUS                      │
│ All-Weather wallets: 58% accumulating    │
│ (buying more than selling)               │
│ Specialist wallets: 71% accumulating     │
│                                          │
│ Net inflow 24H: +$340M                   │
│ Net inflow 7D: +$1.2B                    │
│                                          │
│ Interpretation: Smart money is buying.   │
│ Accumulation + yield staking = long-     │
│ term bullish positioning.                │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 📋 REGIME-BEHAVIOR FIT                   │
│ Your spot trading in Trending regime:    │
│ Win rate: 68% (vs baseline 52%)          │
│ Average profit per winning trade: $520   │
│ ✅ Well-suited: Trending favors spot     │
│    buyers who accumulate on dips.        │
│                                          │
│ Suggested approach:                      │
│ • Buy on support ($171.50)               │
│ • HODL to resistance ($176.80)           │
│ • Consider dollar-cost averaging into    │
│   position over 2-4 weeks                │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 🎯 TOP SIGNALS                           │
│ ◆ P3 ACCUMULATION: Whale buying +$12M   │
│   ◆ Confluence: 71/100 | Lucid source   │
│   [See Details →]                        │
│                                          │
│ ◆ P2 ON-CHAIN: Exchange outflow rising   │
│   ◆ Confluence: 58/100 | Lucid source   │
│   [See Details →]                        │
└──────────────────────────────────────────┘
```

| Component           | Data Source                                                            | Notes                          |
| ------------------- | ---------------------------------------------------------------------- | ------------------------------ |
| Price Pulse         | `allMids`, `l2Book`, `prevDayPx`                                       | Retail-friendly pricing        |
| 24H Stats           | `assetCtxs.dayNtlVlm`, spot market cap feeds                           | Market fundamentals            |
| Price Performance   | Historical price feeds                                                 | Long-term trend context        |
| Yield Opportunities | Staking protocol feeds (Lido, Marinade, etc.) + on-chain lending rates | Spot holder yield options      |
| Wallet Consensus    | `clearinghouseState.assetPositions` spot positions                     | Smart money directional signal |
| Regime Fit          | User performance data in current regime                                | Personalized approach          |
| Top Signals         | Aggregated P-layer signals adapted for spot                            | Spot-specific signal sources   |

##### Technical Tab — Crypto Spot (v9.0)

Same structure as Crypto Perp Technical tab (see above), with two additions for spot-specific on-chain valuation metrics:

```
┌──────────────────────────────────────────┐
│ 🔗 ON-CHAIN VALUATION METRICS            │
│                                          │
│ NVT Ratio: 42.3 · Fair value zone ✅     │
│ ◆ "Network Value to Transactions ratio   │
│   measures if the network is overvalued  │
│   relative to its usage. 42 is within    │
│   historical fair range (30-60)."        │
│                                          │
│ MVRV Z-Score: 1.8 · Moderate ✅          │
│ ◆ "Market Value to Realized Value shows  │
│   if holders are in aggregate profit.    │
│   1.8 is moderate — not overheated       │
│   (>3.5 = danger) nor undervalued        │
│   (<0.5 = accumulation zone)."           │
│                                          │
│ Realized Price: $148.30                  │
│ ◆ "Average cost basis of all holders.    │
│   Current price ($174) is 17% above      │
│   realized — holders are in profit       │
│   but not excessively so."               │
└──────────────────────────────────────────┘
```

All other sections (TA Summary, Oscillators, Moving Averages, Volatility, Key Levels, Volume Analysis) are identical to the Crypto Perp Technical tab. The Lucid View score for the Technical cluster incorporates NVT and MVRV for spot instruments.

---

##### On-Chain Tab — Crypto Spot

Deep dive into on-chain fundamentals, exchange flows, whale tracking, supply distribution, developer activity.

```
┌──────────────────────────────────────────┐
│ 📤 EXCHANGE FLOW (Key Accumulation)      │
│                                          │
│ Net flow 24H: -$340M (outflow)           │
│ ➜ More coins leaving exchanges than      │
│   entering. Accumulation signal. 🟢     │
│                                          │
│ Net flow 7D: -$1.2B                      │
│ ➜ Sustained outflow. Holders removing    │
│   coins from exchanges (HODL mentality). │
│                                          │
│ Exchange reserve change (24H):           │
│ • Binance: -$45M (outflow)               │
│ • Kraken: -$28M (outflow)                │
│ • Coinbase: -$18M (outflow)              │
│ → All major exchanges seeing outflows    │
│                                          │
│ Interpretation: When coins leave        │
│ exchanges, it means holders are          │
│ moving them to wallets for long-term     │
│ holding. This is bullish.                │
│ Historical: Major bottoms often precede  │
│ sustained exchange outflows.             │
│                                          │
│ 30D chart: [showing outflow trend]       │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 🐋 WHALE TRACKER                         │
│ Top 10 holder changes (7D):              │
│                                          │
│ Holder: 0x2f41... (Whale A)              │
│ Previous balance: 2.1M SOL               │
│ Current balance: 2.3M SOL                │
│ Change: +200K SOL (+9.5%) ↑ BUYING      │
│ Holdings: $400M+ total (Tier-1)         │
│                                          │
│ Holder: 0x8a3b... (Whale B)              │
│ Previous: 1.8M SOL                       │
│ Current: 1.8M SOL (no change)            │
│ Hodling and earning yield (staked).     │
│                                          │
│ Holder: 0x5c7f... (Whale C)              │
│ Previous: 950K SOL                       │
│ Current: 920K SOL                        │
│ Change: -30K SOL (-3.2%) ↓ SELLING      │
│ (Taking partial profits)                 │
│                                          │
│ New whale addresses (7D):                │
│ 3 new wallets >1M SOL appeared           │
│ → Fresh whale capital entering          │
│                                          │
│ Whale transaction count: 8 large         │
│ transactions (>$1M each) in last 7D     │
│                                          │
│ Interpretation: 7 of 10 top whales are  │
│ holding or buying. Only 1 selling.      │
│ New whale money flowing in. Mixed        │
│ bullish signal — mostly accumulation,    │
│ minimal selling.                         │
│                                          │
│ [See all whale wallets →] 📡             │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 📊 ACTIVE ADDRESSES                      │
│ Daily active addresses: 485,230          │
│ (↑ from 421,000 last week)               │
│ % change: +15.2% week-over-week          │
│                                          │
│ Transaction count (24h): 1.2M            │
│ Unique senders: 340K                     │
│ Unique receivers: 380K                   │
│                                          │
│ Trend (30D): ↗️ Growing network usage     │
│                                          │
│ Interpretation: More people using SOL    │
│ on-chain. Growing adoption = bullish     │
│ long-term. Could indicate fresh FOMO or │
│ sustainable network growth.              │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 🔐 SUPPLY DISTRIBUTION                   │
│ Top 10 holders: 12.3% of supply          │
│ Top 50 holders: 28.1% of supply          │
│ Top 100 holders: 35.7% of supply         │
│                                          │
│ Concentration Score: 6.2/10              │
│ (0=fully decentralized, 10=max monopoly)│
│                                          │
│ Interpretation: 35.7% concentration in  │
│ top 100 is moderate. Not overly         │
│ centralized, but not fully distributed.  │
│ Typical for mature Layer-1: 30-40%.     │
│ Risk: If top holders collude to dump,   │
│ price could fall. But unlikely given     │
│ diverse ownership.                       │
│                                          │
│ Historical: Supply concentration has     │
│ been decreasing over 2 years (more       │
│ decentralization). Positive sign.        │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 👨‍💻 DEVELOPER ACTIVITY                     │
│ GitHub commits (30D): 342                 │
│ Contributors: 87 active                   │
│ Protocol upgrades scheduled: 2 coming    │
│ • Firedancer optimization (Q2 2026)     │
│ • State compression v2 (Q3 2026)        │
│                                          │
│ Interpretation: High development        │
│ activity. SOL team actively building     │
│ scalability. Upgrades coming that could  │
│ improve transaction throughput by 10x.   │
│ Very bullish signal for long-term value.│
└──────────────────────────────────────────┘
```

| Component           | Data Source                                  | Notes                              |
| ------------------- | -------------------------------------------- | ---------------------------------- |
| Exchange Flow       | On-chain flow analytics (Glassnode, similar) | Accumulation vs distribution proxy |
| Whale Tracker       | Top holder tracking + blockchain             | Early signal of smart money moves  |
| Active Addresses    | On-chain metrics feed                        | Network health and adoption        |
| Supply Distribution | Holder concentration data                    | Centralization risk assessment     |
| Developer Activity  | GitHub + protocol roadmap                    | Fundamental development momentum   |

##### Order Book Tab — Crypto Spot

Same three-layer progressive disclosure as perps: Layer 0 Price Pulse (in Overview), Layer 1 Horizontal Ladder (default in Order Book tab), Layer 2 Depth Staircase (toggle). See Depth tab in C3-A for full spec. Tap any level to pre-fill limit order in C5-NEW. Wall detection (>3x average volume) with Lucid annotations.

##### Holders Tab — Crypto Spot (NEW for spot)

Top holders, supply distribution, staking participation, holder diversity.

```
┌──────────────────────────────────────────┐
│ 👥 SUPPLY DISTRIBUTION                   │
│                                          │
│ ┌────────────────────────────────┐       │
│ │ Top 10 Holders:  ████ 12.3%    │       │
│ │ Top 50 Holders:  ███████ 28.1%│       │
│ │ Top 100 Holders: ██████████35.7%      │
│ │ Rest: 64.3%                    │       │
│ └────────────────────────────────┘       │
│                                          │
│ Decentralization Score: 6.2/10           │
│ ➜ Moderate. Similar to BTC (7.1) and    │
│   ETH (5.8). Not overly concentrated.    │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 🔑 TOP HOLDERS (+ Bridge to Radar)       │
│                                          │
│ Holder: Jump Crypto (0x2f41...)          │
│ Ownership: 4.2% (1.98M SOL)              │
│ Type: Venture capital / Market maker    │
│ [View Whale Profile →] 📡                │
│                                          │
│ Holder: Multicoin Capital (0x8a3b...)    │
│ Ownership: 2.8% (1.32M SOL)              │
│ Type: Crypto fund                        │
│ [View Whale Profile →] 📡                │
│                                          │
│ Holder: Alameda Research (0x5c7f...)     │
│ Ownership: 1.9% (897K SOL)               │
│ Type: Trading firm                       │
│ Note: Holdings under observation         │
│ [View Whale Profile →] 📡                │
│                                          │
│ Note: 📡 buttons allow viewing tracked   │
│ whale wallets within Radar. See their    │
│ full on-chain activity, positions,      │
│ entry/exit history.                      │
│                                          │
│ [See all tracked holders →] 📡           │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 🏦 STAKING PARTICIPATION                 │
│ % of supply staked: 68%                  │
│ (↑ from 65% last month)                  │
│ Staking validators: 2,340 active         │
│                                          │
│ Staking APY breakdown:                   │
│ • Native staking: 7.2%                   │
│ • Liquid staking (Lido): 7.0%            │
│ • Liquid staking (Marinade): 7.1%        │
│ • Lending protocol yield: 8.5%           │
│                                          │
│ Interpretation: High staking participation│
│ (68%) is healthy. Most holders are       │
│ earning yield and long-term committed.   │
│ Growing staking over time (65%→68%)     │
│ = strengthening fundamental engagement.  │
└──────────────────────────────────────────┘
```

| Component             | Data Source                        | Notes                                        |
| --------------------- | ---------------------------------- | -------------------------------------------- |
| Supply Distribution   | Holder tracking feeds              | Concentration risk + decentralization metric |
| Top Holders           | Tracked whale wallets + blockchain | Each bridges to Radar whale profile view     |
| Staking Participation | On-chain staking data              | Network commitment + yield opportunity       |

##### Fundamentals Tab — Crypto Spot

Tokenomics, ecosystem health, competitive position.

```
┌──────────────────────────────────────────┐
│ 📋 TOKENOMICS                            │
│ Total supply: 500M SOL (max)             │
│ Circulating supply: 47.2M (9.4%)         │
│ Inflation rate: Decreasing over time     │
│ Current annual inflation: 2.1%           │
│                                          │
│ Next unlock event: May 15, 2026          │
│ Unlock amount: 3.2M SOL (-0.7% dilution)│
│ (Cumulative: 48.9M circulating after)    │
│                                          │
│ Vesting schedule:                        │
│ [Chart showing unlock schedule next 5Y]  │
│                                          │
│ Interpretation: Dilution rate is         │
│ declining (good). Most major holders     │
│ have vested already. Modest future       │
│ unlocks. Not a major selling pressure.   │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 🌍 ECOSYSTEM STRENGTH                    │
│ Total Value Locked (TVL): $12.3B         │
│ TVL change (30D): +$2.1B (+20.7%)        │
│                                          │
│ Major protocols built on Solana:         │
│ • Marinade (liquid staking): $4.2B TVL  │
│ • Magic Eden (NFT): $800M TVL           │
│ • Orca (DEX): $620M TVL                 │
│ • Raydium (DEX): $540M TVL              │
│                                          │
│ Ecosystem partnerships:                  │
│ • 2,340+ validators                      │
│ • 500+ projects built on Solana          │
│ • Growing institutional adoption          │
│                                          │
│ Interpretation: Healthy, growing        │
│ ecosystem. TVL growth at +20.7% is      │
│ strong. More capital flowing into        │
│ protocols = more network utility = more  │
│ token demand.                            │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 🏆 COMPETITIVE POSITION                  │
│ Layer-1 ranking: #7 by market cap        │
│ Market share vs other L1s: 4.2%          │
│ (Top L1: Ethereum at 62% market share)   │
│                                          │
│ Comparable assets:                       │
│ Avax (L1): $36B mcap · Solana: $82B mcap│
│ Poly (L1): $12B mcap · Solana: $82B mcap│
│                                          │
│ SOL premium: 2.3x vs AVAX, 6.8x vs POLY│
│ ➜ Valuation reflects Solana's stronger  │
│   ecosystem and technical advantages.    │
│                                          │
│ Relative strength: Year-to-date, Solana │
│ +35.2% vs Layer-1 index +12.1%. Beating │
│ category. Strong relative position.      │
└──────────────────────────────────────────┘
```

| Component            | Data Source                           | Notes                      |
| -------------------- | ------------------------------------- | -------------------------- |
| Tokenomics           | Supply data + unlock schedule         | Dilution risk assessment   |
| Ecosystem            | TVL feeds + protocol data             | Network value capture      |
| Competitive Position | Market cap rankings + peer comparison | Relative valuation context |

**Sticky CTA:** `[Buy SOL ▶]` (no direction toggle — spot is buy/sell, not long/short) → C5-NEW with TradeIntent:

```
TradeIntent {
  symbol: "SOL/USDT",
  direction: "long",                      // Spot buy = long by default
  source: "markets_c3",
  instrument_type: "spot",                // Routes to C5-NEW-S (Spot Calculator)
  regime_context: { state, strength, change_prob_4h },
  funding_rate: null,                     // N/A for spot
  funding_percentile: null,               // N/A for spot
  wallet_consensus: { direction, count, strength },     // From Holders tab
  leader_positions: [top 5],              // From Holders Top Holders with Radar bridges
  smart_money_net_position: derived,      // From On-Chain whale tracker
  suggested_tp: null,                     // Populated by Lucid on C5-NEW
  suggested_sl: null,                     // N/A for basic spot (available in advanced)
  suggested_size: null,                   // Populated by Lucid on C5-NEW
  entry_price: null,                      // Set if user taps order book level
  oi_regime_alignment: null               // N/A for spot
}
```

---

#### C3-C: US Stock Perpetual Futures

US stock perps are synthetic perpetual futures on Hyperliquid that track US equity prices. Traders need traditional equity data (earnings, P/E, revenue) blended with the perp mechanics (funding, Open Interest, leverage). **Market hours awareness** is critical — these assets have different behavior during and outside US market hours.

**Header Data Strip:**

```
AAPL.US / USD Perp  ★  🔔
$198.45 ◆ 3/5 signal strength  ↑1.2%  24H Vol: $890M
Bid: $198.42 · Ask: $198.48 · Spread: 0.03%
⏰ US Market: OPEN (closes in 2h 14m) · Pre: +0.3%
```

**Context Card:**

```
◆ REGIME + MARKET HOURS CONTEXT ──────────────
Status: TRENDING 🟢 · "River with strong current"
Market: NYSE OPEN · Next event: AAPL Earnings Apr 24
Funding: 0.008%/8h · 🟢 Favorable · ◆ Kelly: $1,800
Sector: Tech (XLK) ↑0.8% today · SPY ↑0.4%
[◆ Details]
```

**Market Hours Badge States:**

| State              | Badge                                | Color | Implication                                                            |
| ------------------ | ------------------------------------ | ----- | ---------------------------------------------------------------------- |
| **US Market Open** | `⏰ OPEN (closes in Xh Xm)`          | Green | Full liquidity, normal spreads, real-time price discovery              |
| **Pre-Market**     | `⏰ PRE-MARKET (opens in Xh Xm)`     | Amber | Reduced liquidity, wider spreads, gap risk                             |
| **After-Hours**    | `⏰ AFTER-HOURS (until Xh Xm)`       | Amber | Same as pre-market. Earnings reactions happen here                     |
| **Market Closed**  | `⏰ CLOSED (opens Mon Xh Xm)`        | Gray  | Perp still trades but spread widens, liquidity thins. Weekend gap risk |
| **Holiday**        | `⏰ HOLIDAY — [Name] (opens [date])` | Gray  | Extended closure period. Higher gap risk                               |

**Tabs:** `[Overview] [Technical] [Fundamentals] [Depth] [Traders]`

**Overview Tab — US Stock Perp:**

| Section                  | Fields                                                                                   | Why It Matters                                                                        |
| ------------------------ | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| **24H Stats**            | High, Low, Volume ($), Open Interest, Open Interest change, 24H trades, funding rate     | Perp mechanics — same as crypto perp                                                  |
| **Market Hours Context** | Current session, time to next session change, pre/post-market price change               | Gap risk management — most dangerous moment is session transitions                    |
| **Sector Performance**   | Sector ETF (XLK, XLF, etc.) 24H %, sector relative strength, SPY correlation coefficient | "Is AAPL moving because of AAPL or because tech sector is moving?"                    |
| **Index Context**        | SPY, QQQ, sector ETF — 24H %, current level, direction                                   | Macro context — individual stocks are pulled by index gravity                         |
| **Funding Rate Detail**  | Current rate, predicted next, annualized cost, long/short imbalance                      | Same as crypto perp — holding cost matters                                            |
| **Top Signals**          | Top 2-3 by confluence for this stock's perp, P-layer badges                              | Arx signal intelligence applied to stock perps                                        |
| **Regime-Behavior Fit**  | User's win rate on stock perps in current regime, hours-specific performance             | "Your stock perp trades during market hours: 68% win rate. After-hours: 41% win rate" |

**Fundamentals Tab — US Stock Perp:**

| Section                     | Fields                                                                               | Why It Matters                                                |
| --------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------- |
| **Valuation Snapshot**      | P/E (trailing + forward), P/S, P/B, EV/EBITDA, PEG ratio                             | Is this stock cheap or expensive relative to earnings?        |
| **Revenue & Earnings**      | Last quarter revenue, YoY growth, EPS (actual vs estimate), revenue trend (4Q chart) | Fundamental growth trajectory                                 |
| **Analyst Consensus**       | Buy/Hold/Sell count, average price target, range (low/high), consensus change 30D    | Wall Street view — useful as contrarian indicator at extremes |
| **Institutional Ownership** | Top 5 institutional holders, % institutionally owned, 13F change (quarterly)         | Smart money positioning in the underlying                     |
| **Dividend**                | Yield, ex-date, payout ratio, growth rate (5Y)                                       | Affects perp pricing around ex-dividend dates                 |
| **Key Ratios Comparison**   | This stock vs sector average vs S&P 500 average — P/E, growth, margin                | Relative valuation in context                                 |

**Earnings Tab — US Stock Perp:**

| Section                 | Fields                                                                                                              | Why It Matters                                                                                        |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| **Next Earnings**       | Date, time (BMO/AMC), days until, estimated EPS, estimated revenue                                                  | The single most important event for stock perps — volatility explodes around earnings                 |
| **Earnings History**    | Last 8 quarters: EPS estimate vs actual, revenue estimate vs actual, stock reaction (%)                             | Pattern recognition — does this stock usually beat? How does the perp react?                          |
| **Implied Move**        | Options-implied expected move (%), historical actual move (%), IV percentile                                        | How much volatility is already priced in — are you getting paid for the risk?                         |
| **Earnings Playbook ◆** | Lucid's analysis: historical earnings reaction pattern, typical pre-earnings drift, post-earnings continuation rate | Intelligence — "AAPL has beaten estimates 7 of last 8 quarters, but stock dropped 4 of those 7 times" |

**Sticky CTA:** `[Trade AAPL ▶]` → C5-NEW. During market closed: CTA shows `[Trade AAPL ▶ ⚠ Market Closed]` with amber tint (still functional — perps trade 24/7, but warns about reduced liquidity).

---

#### C3-D: Commodity Perpetual Futures

Commodity perps track physical commodity prices (gold, oil, silver, natural gas). Traders need macro context, supply/demand fundamentals, seasonal patterns, and geopolitical sensitivity that equities traders don't care about.

**Header Data Strip:**

```
GOLD.CMD / USD Perp  ★  🔔
$2,340.80 ◆ 2/5 signal strength  ↑0.4%  24H Vol: $1.2B
Bid: $2,340.60 · Ask: $2,341.00 · Spread: 0.02%
⏰ Comex: OPEN (closes in 4h 22m)
```

**Context Card:**

```
◆ REGIME + MACRO CONTEXT ────────────────────
Status: RANGE_BOUND 🔵 · "Tennis ball between floor and ceiling"
DXY: 103.2 (↓0.3%) · 10Y: 4.32% (↓2bp) · VIX: 18.4
Funding: 0.005%/8h · 🟢 Low cost · ◆ Kelly: $3,100
Gold correlation: DXY -0.82 · SPY -0.31 · BTC +0.12
[◆ Details]
```

**Tabs:** `[Overview] [Technical] [Fundamentals] [Depth] [Traders]`

**Overview Tab — Commodity Perp:**

| Section                 | Fields                                                                   | Why It Matters                                                                    |
| ----------------------- | ------------------------------------------------------------------------ | --------------------------------------------------------------------------------- |
| **24H Stats**           | High, Low, Volume ($), Open Interest, Open Interest change, funding rate | Standard perp data                                                                |
| **Macro Dashboard**     | DXY (dollar index), 10Y yield, VIX, real yields, Fed funds rate          | Commodities are driven primarily by macro — dollar strength, rates, risk appetite |
| **Correlation Matrix**  | Rolling 30D correlation: vs DXY, vs SPY, vs BTC, vs other commodities    | "Gold rallies when DXY drops" — knowing current correlations prevents surprise    |
| **Session Context**     | Comex/NYMEX session status, London fix time, Asian session activity      | Commodity pricing is session-dependent — London fix moves gold daily              |
| **Funding Rate Detail** | Current, predicted, annualized, long/short imbalance                     | Perp holding cost                                                                 |
| **Top Signals**         | Top 2-3 by confluence, P-layer badges                                    | Arx signal intelligence for commodities                                           |
| **Regime-Behavior Fit** | User's commodity win rate in current regime                              | "Your gold trades in Range-Bound: 62% win rate at range boundaries"               |

**Macro Tab — Commodity Perp:**

| Section                    | Fields                                                                        | Why It Matters                                                            |
| -------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| **Dollar Index (DXY)**     | Current, 24H %, 30D chart overlay with commodity price, correlation strength  | The #1 driver of commodity prices — inverse correlation for most          |
| **Interest Rates**         | Fed funds, 2Y, 10Y, 30Y yields + changes, real yield (TIPS), rate expectation | Higher real rates = headwind for gold. Lower rates = tailwind             |
| **Inflation Expectations** | 5Y breakeven, CPI trend, PCE trend                                            | Commodities as inflation hedge — inflation expectations drive positioning |
| **Central Bank Activity**  | Fed next meeting date, ECB/BOJ rate decisions, CB gold purchases (quarterly)  | Policy shifts move commodities more than any technical signal             |
| **Geopolitical Risk**      | GPR Index, active conflicts affecting supply, sanctions                       | Gold/oil are the primary geopolitical hedges                              |
| **ETF Flows**              | GLD/SLV/USO inflows/outflows (weekly), trend                                  | Retail and institutional positioning via ETFs                             |

**Supply/Demand Tab — Commodity Perp:**

| Section              | Fields                                                                                                 | Why It Matters                                                                     |
| -------------------- | ------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| **Production**       | Major producer countries, production trend, mine output (gold), OPEC+ quotas (oil)                     | Supply-side fundamentals                                                           |
| **Demand**           | Industrial demand, jewelry demand (gold), refinery runs (oil), EV impact, seasonal pattern             | Demand-side fundamentals                                                           |
| **Inventory**        | COMEX warehouse stocks, strategic reserves (SPR for oil), LME stocks                                   | Physical inventory = supply/demand balance indicator                               |
| **Seasonal Pattern** | Average monthly returns (20Y), current month's historical bias, seasonal chart overlay                 | "Gold historically rallies Sep-Feb" — seasonal tendencies are real for commodities |
| **COT Positioning**  | CFTC Commitments of Traders: commercial hedger net position, speculator net position, extreme readings | When speculators are max long, the trade is crowded. Commercials know more         |

**Sticky CTA:** `[Trade GOLD ▶]` → C5-NEW. Session awareness badge on CTA if Comex is closed.

---

#### C3-E: Commodity Spot

Simplified view for spot price exposure. No leverage mechanics. Focus on price reference, portfolio hedging context, and macro drivers.

**Header Data Strip:**

```
GOLD.CMD / USD Spot  ★  🔔
$2,340.50  ↑0.4%  24H Range: $2,328-$2,345
London Fix: $2,338.20 (AM) · Next fix: 3:00 PM GMT
```

**Context Card:**

```
◆ MACRO CONTEXT ─────────────────────────────
DXY: 103.2 (↓0.3%) · 10Y: 4.32% · VIX: 18.4
Portfolio hedge: Gold = 8% of your portfolio
Correlation to your portfolio: -0.41
[◆ Details]
```

**Tabs:** `[Overview] [Macro] [Supply/Demand]`

**Overview Tab — Commodity Spot:**

| Section               | Fields                                                              | Why It Matters                                                                            |
| --------------------- | ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| **Price Stats**       | High, Low, VWAP, London Fix (AM/PM), 24H Volume                     | Reference pricing for spot exposure                                                       |
| **Performance**       | 1D, 7D, 30D, 90D, YTD, 1Y, 5Y returns                               | Long-term trend context for spot holders                                                  |
| **Portfolio Context** | Current allocation %, correlation to portfolio, hedge effectiveness | "Adding gold would reduce your portfolio drawdown by 12% based on backtested correlation" |
| **Macro Snapshot**    | DXY, rates, inflation expectations                                  | Condensed macro context                                                                   |

**Sticky CTA:** `[Buy GOLD ▶]` → C5-NEW with `TradeIntent { symbol: "GOLD/USD", direction: "long", source: "markets_c3", instrument_type: "spot", ... }`. Simplified spot purchase flow (amount → buy, no leverage).

---

#### C3 Shared: Information Architecture

**Header Section (Always Visible — All Types):**

| Field                  | Format           | Source                       | Adaptation by Type                                                                                            | Animation                         |
| ---------------------- | ---------------- | ---------------------------- | ------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| Ticker Name (tappable) | `SOL/USD Perp ▾` | Static                       | All types — ticker name + instrument type badge                                                               | Tap → Quick Ticker Search overlay |
| Price                  | `$174.20`        | Real-time                    | All types                                                                                                     | Color flash 500ms on update       |
| ◆ Confluence Badge     | `◆ 4/5`          | Lucid Signal API             | All types (fewer signals for stocks/commodities)                                                              | Pulse 300ms on update             |
| 24h Change             | `↑2.8%`          | Derived                      | All types                                                                                                     | Color flash                       |
| Watchlist Star         | ⭐               | User data                    | All types                                                                                                     | Fill 150ms on toggle              |
| Alert Bell             | 🔔               | User data                    | All types                                                                                                     | Badge color                       |
| Overflow               | ⋮                | Context                      | All types                                                                                                     | Tap → bottom sheet                |
| Session Badge          | `⏰ OPEN`        | Market data                  | US stocks + commodities only. Hidden for crypto (24/7)                                                        | Color-coded by session state      |
| Context Card           | Varies by type   | Regime + Lucid + market data | Crypto: regime + funding + wallet. Stock: regime + sector + earnings. Commodity: regime + macro + correlation | Pulse on regime change            |

**Tab Content by Instrument Type:**

| Tab Position         | Crypto Perp                                                                                  | Crypto Spot                                                                                                                       | US Stock Perp                                                                                                 | Commodity Perp                                                                                  | Commodity Spot                                                   |
| -------------------- | -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| **Tab 1: Overview**  | Price Pulse, Money Flow, Position Crowding, 24H Stats, Holding Cost, Regime Fit, Top Signals | Price Pulse, 24H Stats, Price Performance, Yield Opportunities, Wallet Consensus, Regime Fit, Top Signals                         | Price + 24H Data, Market Hours Context, Sector/Index, Funding, Signals, Regime Fit                            | 24H Stats, Macro Dashboard, Correlation, Session, Funding, Signals, Regime Fit                  | Price Stats, Performance, Portfolio Context, Macro Snapshot      |
| **Tab 2: Technical** | TA Summary, Oscillators, Moving Averages, Volatility, Key Levels, Volume Analysis            | TA Summary, Oscillators, Moving Averages, Volatility, Key Levels, Volume Analysis, On-Chain Valuation (NVT, MVRV, Realized Price) | TA Summary, Oscillators, Moving Averages, Volatility, Key Levels, Volume Analysis                             | TA Summary, Oscillators, Moving Averages, Volatility, Key Levels, Volume Analysis               | TA Summary, Oscillators, Moving Averages, Volatility, Key Levels |
| **Tab 3**            | On-Chain: Open Bets, Holding Cost Deep-Dive, Trade Flow, Perp vs Spot Gap, Cohort Positions  | On-Chain: Exchange Flow, Whale Tracker, Active Addresses, Supply Distribution, Developer Activity                                 | Fundamentals: Valuation, Revenue & Earnings, Analyst Consensus, Institutional Ownership, Dividend, Key Ratios | Fundamentals: Macro Dashboard, Correlation, Supply/Demand Balance, Inventory, Seasonal Patterns | —                                                                |
| **Tab 4**            | Depth: Horizontal Ladder (default) + Depth Staircase (toggle)                                | Order Book: Horizontal Ladder (default) + Depth Staircase (toggle)                                                                | Depth: Horizontal Ladder + Depth Staircase                                                                    | Depth: Horizontal Ladder + Depth Staircase                                                      | —                                                                |
| **Tab 5**            | Liquidation Map: Heatmap, Key Levels, Cascade Risk, Who Gets Liquidated                      | Holders: Supply Distribution, Top Holders, Staking Participation                                                                  | Traders: Leader Positions, Smart Money Activity, Cohort Consensus                                             | Traders: Leader Positions, Smart Money Activity, Cohort Consensus                               | —                                                                |
| **Tab 6**            | Traders: Leader Positions, Smart Money Activity, Cohort Consensus, See All Traders           | Fundamentals: Tokenomics, Ecosystem, Competitive Position                                                                         | —                                                                                                             | —                                                                                               | —                                                                |

#### Component Inventory

| #   | Component                          | Type                                      | Behavior                                                                                                                                                                                                | Spec                                          |
| --- | ---------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| 1   | Header: Ticker Name (tappable)     | Text + dropdown indicator                 | Tap → Quick Ticker Search overlay. Shows `{symbol} ▾` with dropdown caret indicating tappability                                                                                                        | Sticky, always visible, primary font          |
| 2   | Header: Price + 24h %              | Large text + color                        | Real-time updated. Flash green (up) or red (down) for 500ms                                                                                                                                             | XL font, color-coded                          |
| 3   | Header: ◆ Confluence Badge         | Tappable badge                            | Tap → Lucid context bottom sheet. Pulses 300ms on update                                                                                                                                                | Badge with color coding                       |
| 4   | Header: Watchlist star ⭐          | Toggle icon                               | Tap to add/remove from watchlist. Haptic on toggle                                                                                                                                                      | Scale 1.2 on press                            |
| 5   | Header: Alert bell 🔔              | Toggle icon with badge                    | Tap to manage price alert                                                                                                                                                                               | Scale 1.2 on press                            |
| 6   | Header: Overflow menu ⋮            | Icon button                               | Tap → bottom sheet: alert, watchlist, share, compare, settings                                                                                                                                          | Ripple feedback                               |
| 7   | Header: Session Badge              | Status badge                              | Only for US stocks + commodities. Shows session state with time remaining. Color-coded                                                                                                                  | Auto-updates every minute                     |
| 8   | Quick-Switch Gesture               | Swipe left/right on header area           | Swipe to navigate to next/prev watchlist asset. Header + chart transition with parallax                                                                                                                 | Smooth animation 300ms                        |
| 9   | Context Card                       | Embedded first-class card                 | Varies by instrument type (see per-type specs above). Always includes regime + [◆ Details] CTA                                                                                                          | Card with colored left border matching regime |
| 10  | Chart                              | Full-width interactive chart              | TradingView integration. Timeframe selector. Pinch-zoom, tap+hold for crosshair                                                                                                                         | Responsive height                             |
| 11  | Tab Bar                            | Horizontal scrollable tabs                | Tabs vary by instrument type (see table above). Tap to switch. Active tab underlined                                                                                                                    | Scrollable                                    |
| 12  | Tab Content                        | Stacked sections                          | Content varies by instrument type and tab. See per-type Overview specs                                                                                                                                  | Full width                                    |
| 13  | [Trade ▶] / [Buy ▶] CTA            | Sticky bottom button (primary)            | Perps: `[Trade ▶ {SYMBOL}]` with direction picker. Spot: `[Buy {SYMBOL} ▶]`. Session badge on CTA for stocks/commodities during closed hours. ◆ Kelly annotation for perps                              | Sticky, primary color, bounce on load         |
| 13b | [See Who's Trading →] CTA          | Sticky bottom button (secondary, outline) | Navigates to Radar tab → D1 Discover Leaders filtered by this instrument. Bridges ticker-first → people-first exploration. S7 variant: label changes to "See Your Leaders →"                            | Sticky, secondary outline style               |
| 14  | Quick Ticker Search Overlay        | Full-screen overlay                       | Triggered by ticker tap. Auto-focus search, recent pills, watchlist list, hot tickers. Tap result → C3 updates in-place                                                                                 | 300ms slide-down, 200ms dismiss               |
| 15  | Market Hours Banner                | Conditional banner                        | For US stocks + commodities: shows session transitions ("Market closes in 15 min — spreads may widen")                                                                                                  | Amber banner, 5s auto-dismiss unless tapped   |
| 16  | Funding Rate Strip                 | Data line                                 | For perps only: rate, next funding, Kelly annotation. Color-coded by cost direction                                                                                                                     | Bold, inline                                  |
| 17  | Macro Context Row                  | Data line                                 | For commodities: DXY + rates + VIX in compact row                                                                                                                                                       | Compact, real-time                            |
| 18  | Price Pulse Widget                 | Inline card in Overview                   | Smart Price Card showing current price, buy/sell pressure gauge, support/resistance, spread health, ◆ Lucid narrative. Always visible at top of Overview tab. [See Full Depth →] expands to Smart Depth | Real-time WebSocket, 300ms transitions        |
| 19  | Smart Depth (in Price & Depth tab) | Enhanced order book                       | Full L2 depth visualization with Lucid annotations. Replaces old "Order Book" tab. Includes impact price visualization from Hyperliquid                                                                 | Progressive load, tap rows to pre-fill        |

**Total unique components on C3: 19** (up from 17)

#### Interactions & CTAs (Complete Interaction Table)

| #   | Element                             | Tap →                                                                  | Long Press →         | Swipe →                                       | Visual Feedback                    | Animation            |
| --- | ----------------------------------- | ---------------------------------------------------------------------- | -------------------- | --------------------------------------------- | ---------------------------------- | -------------------- |
| 1   | Back arrow (←)                      | Navigate back to previous screen                                       | —                    | —                                             | Icon highlight                     | 100ms highlight      |
| 2   | Ticker name text                    | Open Quick Ticker Search overlay                                       | —                    | —                                             | Text underline flash               | 200ms                |
| 3   | ◆ Confluence Badge                  | Open Lucid confluence context bottom sheet                             | —                    | —                                             | Badge highlight + scale            | 100ms                |
| 4   | Watchlist star ⭐                   | Toggle watchlist membership                                            | —                    | —                                             | Star fill/unfill + haptic          | 150ms scale + haptic |
| 5   | Alert bell 🔔                       | Open alert management bottom sheet                                     | —                    | —                                             | Bell scale + ripple                | 100ms                |
| 6   | Overflow menu ⋮                     | Open bottom sheet (share, compare, alert, settings)                    | —                    | —                                             | Menu popup                         | 150ms                |
| 7   | Session Badge                       | Open session detail bottom sheet (schedule, next open, historical gap) | —                    | —                                             | Badge scale                        | 100ms                |
| 8   | Context Card [◆ Details]            | Open Lucid context bottom sheet (type-adapted)                         | —                    | —                                             | Button highlight                   | 100ms                |
| 9   | Header area                         | —                                                                      | —                    | Swipe left/right to next/prev watchlist asset | Header + chart crossfade           | 300ms transition     |
| 10  | Chart                               | Pinch to zoom                                                          | Tap+hold → crosshair | —                                             | Zoom animation                     | Pinch follow         |
| 11  | Tab bar                             | Tap to switch tabs                                                     | —                    | —                                             | Tab underline slide + content fade | 200ms                |
| 12  | Signal card in Overview             | Open signal detail                                                     | —                    | —                                             | Scale 0.98                         | 150ms                |
| 13  | Signal card [Trade →]               | Pre-fill TradeIntent → C5-NEW                                          | —                    | —                                             | Button ripple                      | 100ms                |
| 14  | [Trade ▶] / [Buy ▶] sticky CTA      | Navigate to C5-NEW (pre-filled)                                        | —                    | —                                             | Ripple + scale bounce              | 100ms                |
| 14b | [See Who's Trading →] secondary CTA | Navigate to Radar tab → D1 filtered by instrument                      | —                    | —                                             | Outline button highlight           | 100ms                |
| 14c | Price Pulse [See Full Depth →]      | Expand to Smart Depth (full L2 order book) within Price & Depth tab    | —                    | —                                             | Expand animation                   | 300ms spring         |
| 14d | Price Pulse buy/sell pressure gauge | Show tooltip with exact volumes and ◆ context                          | —                    | —                                             | Tooltip fade-in                    | 150ms                |
| 15  | Entire screen                       | —                                                                      | —                    | Pull down (overscroll) → refresh              | Refresh spinner                    | Spring physics       |
| 16  | Earnings row (stocks only)          | Open earnings detail bottom sheet                                      | —                    | —                                             | Row highlight                      | 100ms                |
| 17  | Macro data row (commodities)        | Open macro detail bottom sheet (DXY, rates, VIX)                       | —                    | —                                             | Row highlight                      | 100ms                |
| 18  | On-Chain metric (crypto spot)       | Open on-chain detail bottom sheet                                      | —                    | —                                             | Row highlight                      | 100ms                |
| 19  | Funding rate strip (perps)          | Open funding rate history + projection bottom sheet                    | —                    | —                                             | Strip highlight                    | 100ms                |

#### S2 vs S7 Content Adaptation (All Types)

| Section               | S2 (Aspiring Traders)                                          | S7 (Copy Followers)                                                         |
| --------------------- | -------------------------------------------------------------- | --------------------------------------------------------------------------- |
| ◆ Confluence Badge    | Shows confluence score with Lucid context on tap               | Shows confluence + leader alignment on tap                                  |
| Context Card          | Regime fit + type-specific context                             | + "X of your leaders hold this asset"                                       |
| Price Pulse           | Full Smart Price Card with support/resistance, pressure gauge  | + "Your leaders' avg entry: $X" annotation                                  |
| Signal Cards          | Full detail, [Trade →] CTA                                     | Simplified, [Follow Trade →] routes through Radar                           |
| Quick-Switch          | Navigate within entire watchlist                               | Navigate within watched leaders + personal watchlist                        |
| [Trade ▶] / [Buy ▶]   | Direct to C5-NEW with ◆ Kelly size                             | Direct to C5-NEW or show copy-setup option                                  |
| [See Who's Trading →] | Label: "See Who's Trading →" — discover leaders for this asset | Label: "See Your Leaders →" — see followed leaders' positions in this asset |

#### State Changes (All Types)

| Trigger                                 | Visual Change                                                                                   |
| --------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Price updates                           | Price + % flash green/red for 500ms. ◆ Confluence may pulse                                     |
| Regime changes                          | Context Card pulses (300ms). Badges update. Funding color may update                            |
| Chart loads                             | Chart draws left-to-right (800ms ease-out)                                                      |
| New signal arrives                      | Signal list updates. ◆ Confluence may change                                                    |
| Tab switched                            | Content cross-fades (200ms). Tab underline slides (200ms)                                       |
| Quick-switch completes                  | Header + chart transition (300ms). New asset data loads                                         |
| **Session change (stocks/commodities)** | Session Badge color changes with 400ms transition. Banner appears: "Market [opened/closed]"     |
| **Earnings approaching (stocks)**       | Context Card shows countdown badge: "Earnings in X days". Pulses daily when <3 days             |
| **Macro event (commodities)**           | Context Card highlights affected macro row. Fed meeting, CPI release, etc.                      |
| **Ticker switch via Quick Search**      | C3 updates in-place: header crossfades (200ms), chart crossfades (300ms), tab content refreshes |

#### Loading / Empty / Error States

| State                             | Visual Treatment                                                                                                                       |
| --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **Initial load**                  | Chart skeleton. Header skeleton with badge placeholders. Tab content shimmer                                                           |
| **No signals**                    | "No signals for this asset right now."                                                                                                 |
| **No order book data**            | "Order book data unavailable."                                                                                                         |
| **Network error**                 | "Chart data unavailable. Last update: [timestamp]"                                                                                     |
| **Market closed (spot)**          | Header shows "Market closed" badge. Chart shows last close                                                                             |
| **Instrument type unknown**       | Fallback to Crypto Perp layout (most complete)                                                                                         |
| **US stock perp — market closed** | Full C3 still functional (perps trade 24/7). Session badge shows CLOSED. ◆ Lucid annotation: "Spread may be wider during closed hours" |

#### Edge Cases

| Scenario                                               | Behavior                                                                                                                                                                  |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Swipe navigation across different instrument types** | When swiping from SOL-PERP (crypto) to AAPL.US-PERP (stock), tabs and context card smoothly transition to the stock layout. No jarring layout change — content crossfades |
| **Quick Ticker Search while in trade flow**            | If user is on C5-NEW calculator and taps ticker → overlay opens. On select, calculator resets with new symbol. Confirm dialog if order is partially filled                |
| **Earnings during trade**                              | If user holds AAPL.US-PERP position and earnings are within 24h, C3 and C6 both show earnings countdown banner with implied move warning                                  |
| **Commodity session transitions**                      | When Comex closes while user is viewing GOLD.CMD-PERP, session badge transitions and ◆ Lucid annotation appears: "Comex closed — liquidity reduced, spreads wider"        |
| **Very large order book depth**                        | Paginate at 50 rows. ◆ Lucid annotations on notable levels                                                                                                                |
| **Asset not in watchlist**                             | Swipe navigation includes all recently viewed symbols + watchlist                                                                                                         |

#### Animations per C3

| Animation                       | Duration                   | Easing               | Trigger                |
| ------------------------------- | -------------------------- | -------------------- | ---------------------- |
| Chart initial draw              | 800ms                      | ease-out             | C3 load                |
| Regime badge pulse              | 300ms, repeat 2x           | ease-in-out          | Regime change          |
| ◆ Confluence badge pulse        | 300ms                      | ease-in-out          | Signal update          |
| Price flash (up/down)           | 500ms                      | linear               | Price update           |
| Tab underline slide             | 200ms                      | ease-out             | Tab switch             |
| Content cross-fade (tabs)       | 200ms                      | ease-out             | Tab switch             |
| Quick-switch transition         | 300ms                      | ease-out             | Swipe left/right       |
| [Trade ▶] bounce entrance       | 300ms                      | spring(0.6, 100, 10) | C3 load                |
| Quick Ticker overlay slide-down | 300ms                      | ease-out             | Ticker tap             |
| Quick Ticker overlay dismiss    | 200ms                      | ease-in              | Selection or cancel    |
| Session badge color transition  | 400ms                      | ease-in-out          | Market open/close      |
| Ticker switch in-place          | 300ms chart + 200ms header | cross-fade           | Quick Search selection |

---

### Screen C3-OB: Smart Depth — Order Book Intelligence (Within C3, Layer 2)

**Purpose:** Full-depth L2 order book visualization with Lucid intelligence annotations. This is Layer 2 of the Price Pulse dual-layer paradigm — accessed via [See Full Depth →] from the Price Pulse widget or directly from the "Price & Depth" tab. Enables power users to understand liquidity structure, identify institutional walls, and place precise limit orders. Includes Hyperliquid `impactPxs` data showing the price impact of market orders at various sizes.
**Parent Screen:** C3 Asset Detail (Tab: Price & Depth, Layer 2)
**JTBD:** "Where is liquidity, and at what price should I enter?"

#### Wireframe

```
┌──────────────────────────────────────────┐
│ ORDER BOOK: SOL/USD                      │
│ [10] [25] [50] [100] [500]  [Refresh]   │
├──────────────────────────────────────────┤
│                                          │
│  BUY/SELL RATIO BAR:                     │
│  ┌────────────────────────────────────┐  │
│  │██████████░░░░░░│ Buy: 45%, Sell: 55%│
│  │◆ 68% buy pressure — above average    │
│  └────────────────────────────────────┘  │
│  (Bar color: Green if more bids, Red if  │
│   more asks)                             │
│                                          │
│  DEPTH VISUALIZATION (layered):         │
│  ┌────────────────────────────────────┐  │
│  │ Ask Side ▲ (color: darker = volume)│  │
│  │ ◼◼◼◼◼ $176.50 · 2,340 SOL         │  │
│  │ ◆ Large ask wall — resistance      │  │
│  │ ◼◼◼◼  $176.25 · 1,890 SOL         │  │
│  │ ◼◼◼   $176.00 · 1,245 SOL         │  │
│  │ ◼◼    $175.75 · 890 SOL           │  │
│  │ ◼     $175.50 · 450 SOL           │  │
│  │                                    │  │
│  │ ───────────────────────────────    │  │
│  │ Last: $174.20                      │  │
│  │ ───────────────────────────────    │  │
│  │                                    │  │
│  │ ◼     $173.90 · 560 SOL           │  │
│  │ ◆ Large bid wall — potential sup. │  │
│  │ ◼◼    $173.65 · 1,120 SOL         │  │
│  │ ◼◼◼   $173.40 · 2,010 SOL         │  │
│  │ ◼◼◼◼  $173.15 · 3,450 SOL         │  │
│  │ ◼◼◼◼◼ $172.90 · 5,670 SOL         │  │
│  │ Bid Side ▼                         │  │
│  └────────────────────────────────────┘  │
│                                          │
│  DETAILED ROWS (tap any bid/ask row):    │
│  Ask Rows (tappable, tap → pre-fill):    │
│  ┌──────────────────────────────────┐    │
│  │ $176.50 · 2,340 SOL              │    │
│  │ (Tap → pre-fill limit buy @176.50)   │
│  │ ◆ Large ask wall — resistance     │    │
│  └──────────────────────────────────┘    │
│                                          │
│  Bid Rows (tappable):                    │
│  ┌──────────────────────────────────┐    │
│  │ $173.90 · 560 SOL                │    │
│  │ (Tap → pre-fill limit sell @173.90)  │
│  │ ◆ Bid wall potential support      │    │
│  └──────────────────────────────────┘    │
│                                          │
│  [Load more (Ask side)] [Load more (Bid)]│
│                                          │
└──────────────────────────────────────────┘
```

#### Information Architecture

| #   | Component            | Data Fields                                                                          | Source                 |
| --- | -------------------- | ------------------------------------------------------------------------------------ | ---------------------- |
| 1   | Depth Level Selector | [10], [25], [50], [100], [500]                                                       | User preference        |
| 2   | Refresh Button       | Timestamp of last update                                                             | Order Book API         |
| 3   | Buy/Sell Ratio Bar   | bid_volume, ask_volume, ◆ buy_pressure_context                                       | Order Book API + Lucid |
| 4   | Depth Visualization  | ask_side[], bid_side[], each with [price, size, cumulative_size, ◆ lucid_annotation] | Order Book API + Lucid |
| 5   | Last Price Line      | current_price                                                                        | Market Data API        |
| 6   | Bid/Ask Rows         | price, size (SOL), cumulative_size, ◆ lucid_annotation                               | Order Book API + Lucid |

#### Component Inventory

| #   | Component                    | Type                                                        | Behavior                                                                                                                                                                                                    | Spec                             |
| --- | ---------------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| 1   | Depth Level Selector         | Horizontal pill buttons                                     | Tap to change depth. Shows [10], [25], [50], [100], [500]. Persists selection for session                                                                                                                   | Tappable, highlight on active    |
| 2   | Refresh Button               | Icon + label                                                | Tap to manually refresh order book data. Shows timestamp of last update                                                                                                                                     | Tappable, icon rotate on press   |
| 3   | Buy/Sell Ratio Bar           | Horizontal bar chart with ◆ Lucid annotation                | Green = more bid volume, Red = more ask volume. ◆ Context annotation (e.g., "◆ 68% buy pressure — above average"). Labels: "Buy: 45%, Sell: 55%". Real-time update                                          | Animated bar width               |
| 4   | Depth Visualization          | Layered rectangles (layered) with ◆ Lucid level annotations | Ask side (above last price), Bid side (below). Darker color = more volume. ◆ Annotations on notable levels (e.g., "◆ Large bid wall at $173 — potential support"). Each row tappable → pre-fill limit order | Color layered: white → dark gray |
| 5   | Last Price Line              | Center line                                                 | Shows current_price in bold. Separates ask (above) from bid (below)                                                                                                                                         | Horizontal divider               |
| 6   | Ask/Bid Rows (Detailed List) | List rows with ◆ Lucid annotations                          | Tap row at price X → pre-fill limit order at price X in C5-NEW. ◆ Lucid context shown (e.g., "◆ Bid wall potential support"). Cumulative size shown on right                                                | Scale 0.98 on press              |
| 7   | Pagination Controls          | [Load more] buttons                                         | Paginate if depth > 50 rows. Separate buttons for ask and bid sides                                                                                                                                         | Centered buttons                 |

#### Interactions & CTAs (Complete Interaction Table)

| #   | Element                             | Tap →                                                                              | Long Press → | Swipe → | Visual Feedback               | Animation       |
| --- | ----------------------------------- | ---------------------------------------------------------------------------------- | ------------ | ------- | ----------------------------- | --------------- |
| 1   | Depth level pill ([10], [25], etc.) | Change depth, re-render OB                                                         | —            | —       | Pill highlight + content fade | 200ms fade      |
| 2   | Refresh button                      | Manually refresh order book                                                        | —            | —       | Icon rotate                   | 500ms spin      |
| 3   | Buy/Sell ratio bar                  | Show tooltip with exact volumes and ◆ Lucid context                                | —            | —       | Tooltip fade-in               | 150ms fade      |
| 4   | Depth visualization row (ask)       | Pre-fill limit BUY order at that price → C5-NEW                                    | —            | —       | Row highlight + ripple        | 100ms ripple    |
| 5   | Depth visualization row (bid)       | Pre-fill limit SELL order at that price → C5-NEW                                   | —            | —       | Row highlight + ripple        | 100ms ripple    |
| 6   | ◆ Lucid annotation on notable level | Tap to open Lucid context bottom sheet                                             | —            | —       | Annotation highlight          | 100ms highlight |
| 7   | Detailed ask/bid row (tap)          | Pre-fill limit order at that price → C5-NEW (direction determined by ask/bid side) | —            | —       | Row highlight + ripple        | 100ms ripple    |
| 8   | Detailed ask/bid row (long-press)   | Show row details: cumulative size, % of total, notional value, ◆ Lucid context     | —            | —       | Tooltip popup                 | 150ms popup     |
| 9   | [Load more] button (ask side)       | Fetch next batch of ask rows                                                       | —            | —       | Spinner appear                | 150ms spin      |
| 10  | [Load more] button (bid side)       | Fetch next batch of bid rows                                                       | —            | —       | Spinner appear                | 150ms spin      |

#### State Changes

| Trigger                         | Visual Change                                                                                                     |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Depth level changed             | Visualization re-renders (200ms fade), rows update, ◆ Lucid annotations update                                    |
| Price changes                   | Last Price line updates in-place. Buy/Sell ratio bar animates width (200ms). ◆ Context may update                 |
| Ask/Bid rows update (real-time) | Rows update in-place. Volume changes flash green (increase) or red (decrease) for 300ms. ◆ Annotations may change |
| Refresh pressed                 | Spinner rotates. Data reloads. Timestamp updates. ◆ Lucid annotations refresh                                     |

#### Edge Cases

| Scenario                         | Behavior                                                                                                    |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Thin order book (few orders)** | Show all available orders. ◆ Lucid annotations shown on any walls found. "Load more" hidden                 |
| **Spreadprice > 0.1%**           | Show warning: "Wide spread detected. Price may slip on large orders." ◆ Lucid context explains implications |
| **No bid/ask data**              | "Order book data unavailable. Try refreshing."                                                              |
| **Rapid order flow**             | Throttle visual updates to max 1 per 100ms to avoid flicker. ◆ Annotations batch-update                     |

---

## MOCK DATA REFERENCE

All screens use this consistent mock data across the app:

### Jake's Watchlist (S2 Primary User)

- SOL/USD: $174.20, ↑2.8%, F: 0.012%/8h, ◆ 4/5 signal strength, 2 signals
- ETH/USD: $3,245, ↓0.4%, F: -0.021%/8h, ◆ 2/5 signal strength, 0 signals
- BTC/USD: $67,890, ↑1.1%, F: 0.031%/8h, ◆ 4/5 signal strength, 1 signal
- HYPE/USD: $28.45, ↑12.1%, F: 0.045%/8h, ◆ 5/5 signal strength, 3 signals
- ARB/USD: $1.12, ↓3.2%, F: -0.005%/8h, ◆ 2/5 signal strength, 1 signal

### Sarah's Copy Portfolio (S7 Primary User)

- @ProTrader Elite: $3,900 (+$14 daily, ⭐⭐, Tier: Pro, ◆ consistency 91%, today +2.3%)
- @GridMaster: $2,100 (+$9 daily, ⭐, Tier: Expert, ◆ consistency 87%, today +1.8%)
- @OptimusCopy: $900 (+$6 daily, ⭐⭐⭐, Tier: Master, ◆ consistency 94%, today +2.1%)
- Total: $6,900 (+$28 daily)
- Circuit Breaker: $5,250 limit ($1,650 buffer = 68% of limit), Status: 🟢 Safe
- ◆ Cash available: $675 — room for 2 more Kelly-sized positions

### Top Movers Grid (All 12 Crypto Perps from Master Data)

1. BTC/USDT-PERP: $67,853, ↑2.3%, ◆ 4/5 regime-fit, Regime: Trending 🟢
2. ETH/USDT-PERP: $3,842, ↓1.1%, ◆ 2/5 regime-fit, Regime: Ranging 🟡
3. SOL/USDT-PERP: $187, ↑5.7%, ◆ 5/5 regime-fit, Regime: Volatile 🔴
4. HYPE/USDT-PERP: $28.45, ↑12.1%, ◆ 5/5 regime-fit, Regime: Breakout 🟢
5. ARB/USDT-PERP: $1.12, ↓3.2%, ◆ 2/5 regime-fit, Regime: Trend Down 🔴
6. DOGE/USDT-PERP: $0.18, →0.0%, ◆ 2/5 regime-fit, Regime: Quiet ⚪

### Signals Example (per C1 and C2)

- **P4 STRUCTURAL SOL**: Open Interest surged +$340M in 4h (2.7σ), price +0.8%. ◆ Signal Strength: 78. Source: @CryptoSurgeon + 2 others.
- **P3 INSTRUMENT BTC**: Funding rate spike +0.08% (8h). ◆ Signal Strength: 52. Source: Market data.
- **P2 PARTICIPANT ETH**: Whale accumulation detected, 3 of 5 tracked wallets increasing. ◆ Signal Strength: 71.

### Lucid Context Examples

- **Regime Context (C1)**: "Trending-Up · Day 4 · Your win rate in Trending: 72% · Momentum strategies favored"
- **Position Annotation (C1)**: "◆ Trending 72% win rate — consider adding"
- **Signal Strength Badge (C2, C3)**: "◆ 4/5 signal strength" (tappable for Lucid details)
- **Order Book Annotation (C3-OB)**: "◆ Large bid wall at $173 — potential support"
- **Kelly Size (C3)**: "◆ Kelly size: $2,400 based on account risk"

### Intelligence Feed Examples

- 🔴 ETH sells 157M — ETH -2.1% (23m ago)
- 🟢 BTC Reserve confirmed — BTC +1.5% (1h ago)
- ⚡ @ProTrader opened LONG ETH 5x (4h ago)

### Positions Example (Jake's Open Positions)

1. SOL LONG · 5x · Perps: Liquidation distance $1,247 (18.3%), P&L +$489 (+6.3%), F: -$2.40/8h, ◆ Regime: ✅ aligned
2. ETH SHORT · 3x · Perps: Liquidation distance $680 (12.1%), P&L -$120 (-1.8%), F: +$1.80/8h, ◆ Regime: ✅ aligned
3. BTC LONG · Spot: P&L +$60 (+1.1%), No leverage

### Trading Instruments (Full List)

Crypto Perps: BTC, ETH, SOL, HYPE, ARB, DOGE (+ 6 more from extended list)
Crypto Spot: BTC, ETH, SOL, HYPE, ARB, DOGE, USDC, USDT
Stock Perps: AAPL, GOOGL, TSLA (3 major equities)
Commodity Perps: GOLD, CRUDE, NATURAL_GAS (3 commodities)
FX Perps: EURUSD, GBPUSD, JPYUSD (3 major pairs)

Total: 12 crypto perps + spot variants + 3 stocks + 3 commodities + 3 FX = 20+ tradeable instruments

---

## ANIMATION & PERFORMANCE SPECIFICATION

### Premium Effects (All Screens)

**On C1 Load:**

1. Regime Context Card appears (fade-in 300ms)
2. Equity curve draws itself L→R (800ms, ease-out)
3. Watchlist sparklines draw (400ms each, staggered 50ms)
4. Signal confluence rings animate: fill + pulse at 0.8s intervals
5. Earnings counter rolls 0 → final value (400ms)
6. Copy Portfolio card slides in with ◆ Lucid annotations (300ms, if S7 with active copies)
7. Lucid Moment Stack appears if morning brief available (fade-in 300ms)

**On C2 Load:**

1. Category tab underline animates to active tab (200ms)
2. Top Movers grid cards with ◆ regime-fit badges stagger-fade-in (50ms between cards)
3. Asset rows with ◆ confluence badges cascade-enter with 50ms stagger

**On C3 Load:**

1. Header with ◆ confluence badge appears (fade-in 300ms)
2. Chart draws from left to right (800ms, ease-out)
3. Regime Context Card appears with ◆ details (fade-in 300ms)
4. [Trade ▶] bounces in with ◆ Kelly annotation (300ms, spring physics)

### Performance Targets

- Initial load to interactive: < 2s
- Tab switch: < 300ms (fade + re-render)
- Real-time price updates: < 100ms latency
- ◆ Confluence updates: < 200ms latency
- Swipe navigation (C3): < 150ms per transition
- Pull-to-refresh: Complete within 3s

### GPU & Hardware Optimization

- Equity curve: Use SVG path instead of canvas for sharpness
- Animations: Use transform + opacity only (no layout recalculations)
- Watchlist scroll: Use hardware-accelerated scrolling
- ◆ Badge updates: Lightweight DOM updates
- Order Book rows: Virtualize if > 100 rows
- Charts: Lazy-load indicators (not all on initial render)

---

## SUMMARY OF ENHANCEMENTS (v5.0 → v6.0 On-Chain Intelligence & Trader Discovery)

**C3 Redesign: Complete restructuring to bring on-chain signals and cohort positioning into Markets (ticker-first exploration).**

### Crypto Perp Tabs (NEW structure)

1. **[Overview] Tab** — Price Pulse, Money Flow meter (capital in/out), Position Crowding warnings, 24H Stats, Holding Cost (funding rate simplified), Regime Fit, Top Signals
2. **[On-Chain] Tab — NEW** — Open Bets (Open Interest analysis) with sparklines, Holding Cost Deep-Dive with annualized tables, Trade Flow (buy/sell imbalance), Perp vs Spot Gap (basis), **Cohort Positions with [Deep-Dive →] bridges to Radar D1 per cohort**
3. **[Depth] Tab** — Price Pulse (Layer 1 retail) + Smart Depth (Layer 2 power user) with impact price calculator
4. **[Liquidation Map] Tab — ENHANCED** — Liquidation heatmap + Key Levels + **Cascade Risk meter** + **"Who Gets Liquidated?" section with [See Traders →] bridges per cohort**
5. **[Traders] Tab — NEW** — Leader Positions, Smart Money Activity, Cohort Consensus heatmap, [See All Traders →] bridge to Radar D1

### Crypto Spot Tabs (NEW structure for spot clarity)

1. **[Overview] Tab** — Price Pulse, 24H Stats, Price Performance, Yield Opportunities (staking APY), Wallet Consensus, Regime Fit
2. **[On-Chain] Tab** — Exchange Flow, Whale Tracker (7D changes), Active Addresses, Supply Distribution, Developer Activity
3. **[Order Book] Tab** — Price Pulse + Smart Depth (same as perps)
4. **[Holders] Tab — NEW** — Supply Distribution, Top Holders (with Radar bridges), Staking Participation
5. **[Fundamentals] Tab** — Tokenomics, Ecosystem, Competitive Position

### Language Simplification (Retail Accessibility)

- "Open Interest" → "Outstanding Positions" or "Open Bets"
- "Funding Rate" → "Holding Cost"
- "Liquidation" → "Forced Close"
- "Basis Spread" → "Perp vs Spot Gap"
- "Long/Short Ratio" → "Bull/Bear Balance"
- Every metric paired with one-line plain-English annotation

### Critical Bridge Feature: Cohort Deep-Dive to Radar

- **On-Chain tab**: Each cohort (Smart Money, Whales, Retail, Proven Traders) shows [Deep-Dive → See {Cohort} Traders] button
- **Liquidation Map tab**: "Who Gets Liquidated?" section shows cohorts by size tier, each with [See These Traders →] bridge
- **Navigation**: C3 → [Deep-Dive] → Radar D1 Discover Leaders pre-filtered by `{asset: "SOL-PERP", cohort: "smart_money"}` etc.
- **Use case**: User sees "Retail is 81% long (crowded)" and immediately discovers which specific retail traders to follow or fade

### Data Architecture: Hyperliquid API Fields Mapped

- `metaAndAssetCtxs.funding.rate`, `openInterest`, `markPx`, `prevDayPx` → On-Chain tab (Open Interest analysis, Holding Cost)
- `l2Book.levels` → Depth tab + Smart Depth (order book visualization)
- `recentTrades` (buy/sell ratio) → Trade Flow in On-Chain tab
- `clearinghouseState.assetPositions` (cohort aggregation) → Cohort Positions (On-Chain) + Traders tab + Liquidation Map cohort breakdowns
- Derived metrics: Money Flow (Open Interest Δ + price + trade flow), Position Crowding (long/short %), Cascade Risk (liquidation cluster analysis)

### Component Changes

- NEW: Money Flow meter (visual gauge: "Money IN" / "Money OUT" with $ amount)
- NEW: Position Crowding section (Bull/Bear Balance with historical precedent warnings)
- ENHANCED: Holding Cost table (annualized costs for 1x, 3x, 5x, 10x leverage)
- NEW: Cascade Risk gauge (probability + precedent)
- NEW: Cohort Consensus grid (visual heatmap showing each cohort's direction on this asset)
- MULTIPLE [Deep-Dive] CTAs → Radar bridges (per cohort, on multiple tabs)
- SIMPLIFIED labels throughout (retail-friendly terminology)

### Version Bump & References

- **Version 6.0** (from 5.0) — On-Chain Intelligence & Trader Discovery integration
- References: Hyperliquid API (raw data), Lucid (derived signals), Radar (trader discovery)
- Status: Production-ready spec for development

---

## SUMMARY OF ENHANCEMENTS (v2.0 → v3.0 Lucid Embedded Intelligence)

1. **Regime Context Card (3.1)**: Embedded first-class section at top of C1, shows regime state, fit, user's win rate in regime, [◆ More] CTA for Lucid breakdown
2. **Watchlist ◆ Annotations (3.2)**: Confluence badges (◆ 4/5) and leader position badges (◆ 3 leaders long) on each card
3. **Portfolio ◆ Lucid Annotations (3.3)**: Per-leader rationale consistency %, daily %, cash available annotation, regime alignment checkmark
4. **Position ◆ Context (3.4)**: Inline Lucid annotations (e.g., "◆ Trending 72% win rate — consider adding") on position cards
5. **Signal [◆ Details →] (3.5)**: Renamed from [Deep-Dive →], navigates to C3 + opens Lucid Q&A bottom sheet
6. **C2 ◆ Regime-Fit Badges (3.6)**: Top Movers grid and instrument rows show ◆ confluence badges (e.g., "◆ 4/5 confluence")
7. **C2 ◆ Trending Fit Filter (3.7)**: New quick filter chip [◆ Trending Fit] for smart filtering by regime alignment
8. **C3 Header ◆ Confluence Badge (3.8)**: Shows confluence score (e.g., "◆ 4/5 confluence"), tappable for Lucid context
9. **C3 Regime Context Card (3.9)**: First-class embedded section below header, shows regime, fit, leader positions (S7), [◆ Details] CTA
10. **C3 Funding Rate ◆ Kelly Annotation (3.10)**: Displays Kelly-sized position (e.g., "◆ Kelly size: $2,400") near funding rate
11. **C3 [Trade ▶] ◆ Kelly (3.11)**: ◆ Kelly size annotation near CTA button
12. **C3-OB ◆ Annotations (3.12)**: Large bid/ask walls marked with Lucid context (e.g., "◆ Large bid wall at $173 — potential support"), buy/sell ratio annotated
13. **Lucid Moment Stack (3.13)**: First-class card stack at top of C1 when morning brief available, swipeable story-format moments, last card morphs to order form
14. **Global ◆ Symbol (3.14)**: All intelligence-driven elements marked with ◆ symbol, tappable for Q&A via bottom sheet
15. **Copilot → Lucid Rename (3.15)**: All references to "Copilot" changed to "Lucid" (Quick Access Bar, CTAs, contexts)
16. **Version Update (3.16)**: Version bumped to 3.0, reference to 4-1-1-6 (Lucid) in header
17. **NO Floating Button / FAB (3.17)**: Removed all references to floating button, floating cards, 🤖 FAB — intelligence fully embedded

---

## NAVIGATION GRAPH

```
┌─────────────────────────────────────────┐
│              APP ENTRY POINTS            │
├─────────────────────────────────────────┤
│  App Launch → C1 Home                   │
│  Tab: Home → C1 Home                    │
│  Tab: Markets → C2 Markets              │
│  Deep Link: arx://home → C1             │
│  Deep Link: arx://markets → C2          │
│  Deep Link: arx://asset/{symbol} → C3   │
└────────────┬────────────────────────────┘
             │
    ┌────────┴─────────────────────┐
    │                              │
    ▼                              ▼
┌──────────┐                   ┌──────────┐
│   C1     │◄──────────────────│   C2     │
│  Home    │  Watchlist [All]  │ Markets  │
│          │─────────────────► │          │
└─┬────────┘  Watchlist card    └┬─────────┘
  │                               │
  │ [Trade →], position tap       │ Asset row, signal
  │ [◆ Details →]                 │ [◆ Deep-Dive →], Top Movers
  │ Signal [Trade →]              │ Long-press → quick-trade
  │ Position card tap             │ [Trade →] (swipe left)
  │ Copy Portfolio [Manage →]     │
  │ Wallet Pulse event tap        │
  │ Regime Context [◆ More]       │
  │ Lucid Moment card tap         │
  │                               │
  └───────────┬───────────────────┘
              │
              ▼
          ┌──────────┐
          │   C3     │
          │  Asset   │
          │ Detail   │
          └────┬─────┘
               │
               │ [Trade ▶]
               │ Tab: Order Book ─────────────┐
               │ [◆ Confluence Badge]         │
               │ Regime Context [◆ Details]   │
               │                              │
               ▼                              ▼
          ┌──────────┐                  ┌──────────┐
          │  C5-NEW  │                  │ C3-OB    │
          │Calculator│                  │Order Book│
          └──────────┘                  │(with ◆   │
                                        │annotations
                                        │└────┬─────┘
                                             │
                                             │ Tap bid/ask row
                                             │
                                             ▼
                                        ┌──────────┐
                                        │  C5-NEW  │
                                        │ (pre-fill)
                                        └──────────┘

Additional Navigation:
C1 → D4 (Copy Portfolio [Manage →])
C1 → D2 (Wallet Pulse event)
C1 → Lucid Q&A (Regime Context [◆ More], Signal [◆ Details →], Position ◆ annotation, etc.)
C1 → NC1 (🔔 Notification Center)
C2 → C2-F (Filter ▽)
C2 → Lucid Q&A (◆ Confluence badge, Signal [◆ Deep-Dive →])
C3 → C6 (Radar [Follow Trade →], or position monitor)
C3 → Lucid Q&A (◆ Confluence badge, Regime Context [◆ Details], Funding Rate ◆, Order Book ◆)
```

---

## DESIGN SYSTEM TOKENS

All screens reference the design system from **4-2**:

### Colors

- `regime-trending`: #10B981 (green)
- `regime-ranging`: #F59E0B (amber/yellow)
- `regime-volatile`: #EF4444 (red)
- `signal-p1`: #3B82F6 (blue)
- `signal-p2`: #10B981 (green)
- `signal-p3`: #F59E0B (yellow)
- `signal-p4`: #EF4444 (red)
- `signal-p5`: #8B5CF6 (purple)
- `status-safe`: #10B981
- `status-warning`: #F59E0B
- `status-danger`: #EF4444
- `lucid-badge`: #6366F1 (indigo — for ◆ symbol)

### Typography

- Hero Title: 32px, 700 weight, line-height 1.2
- Section Header: 18px, 600 weight
- Body: 14px, 400 weight
- Caption: 12px, 400 weight

### Spacing

- Gutter: 16px (standard padding)
- Card margin: 12px
- Button height: 44px (touch target min)
- Tab height: 48px

### Animations

- Standard transition: 200ms, ease-out
- Fast transition: 100ms, ease-out
- Slow transition: 400ms, ease-out
- Spring physics: spring(1, 80, 12)

---

## TESTING & QA CHECKLIST

### Functional

- [ ] C1: Regime Context Card appears at top, [◆ More] tappable
- [ ] C1: Equity curve draws on load
- [ ] C1: Quick Access pills navigate correctly (Lucid → Lucid context)
- [ ] C1: Watchlist cards show ◆ confluence and ◆ leader badges
- [ ] C1: Copy Portfolio expands, shows per-leader ◆ Lucid annotations
- [ ] C1: Position cards show ◆ Lucid regime context
- [ ] C1: Signal cards show [◆ Details →] (not [Deep-Dive →])
- [ ] C1: Lucid Moment Stack appears if morning brief available
- [ ] C2: Top Movers grid shows ◆ regime-fit badges
- [ ] C2: Instrument rows show ◆ confluence badges
- [ ] C2: [◆ Trending Fit] filter chip available and functional
- [ ] C2: Signal [◆ Deep-Dive →] navigates to C3 + Lucid Q&A
- [ ] C3: Header shows ◆ confluence badge, tappable
- [ ] C3: Regime Context Card embedded below header with [◆ Details]
- [ ] C3: Funding rate shows ◆ Kelly size annotation
- [ ] C3: [Trade ▶] shows ◆ Kelly size annotation
- [ ] C3-OB: Notable levels marked with ◆ Lucid annotations
- [ ] C3-OB: Buy/Sell ratio shows ◆ context (e.g., "◆ 68% buy pressure")
- [ ] All ◆ elements: tappable for Q&A via bottom sheet
- [ ] All screens: No floating button, no floating cards, no 🤖 FAB

### Performance

- [ ] C1 initial load to interactive: < 2s
- [ ] C2 tab switch: < 300ms
- [ ] C3 chart draw: 800ms (smooth, not janky)
- [ ] ◆ Badge updates: < 200ms latency
- [ ] Real-time price updates: < 100ms latency
- [ ] Smooth 60fps animations (no frame drops)

### Accessibility

- [ ] All tappable elements: ≥ 44px height
- [ ] ◆ Symbol: clear visual indicator + context on tap
- [ ] Color not sole differentiator (patterns + icons)
- [ ] Fonts: minimum 12px
- [ ] High contrast on backgrounds
- [ ] Screen reader labels on all interactive elements

### Device Support

- [ ] iPhone 12 mini (5.4") — verify layouts fit
- [ ] iPhone 14 Pro (6.1") — standard test device
- [ ] iPad (7th gen, 10.2") — tablet layout
- [ ] Android: Samsung Galaxy S21 (6.2"), Pixel 6 (6.1")
- [ ] Dark mode: all screens have dark theme variants

### Network Conditions

- [ ] Slow 4G (50ms latency): graceful degradation
- [ ] Offline: cached data displayed with banner
- [ ] Data stale >30s: show ⏳ indicator

---

## DEPENDENCIES & EXTERNAL INTEGRATIONS

| Component                    | API / Service             | Update Frequency  |
| ---------------------------- | ------------------------- | ----------------- |
| Regime Bar                   | Regime API                | Event-driven      |
| Regime Context Card (C1, C3) | Regime API + Lucid        | Event-driven      |
| Equity Curve                 | Portfolio API             | Real-time (tick)  |
| Watchlist Sparklines         | Market Data API           | 1s                |
| ◆ Confluence Badges          | Lucid Signal API          | Real-time         |
| ◆ Leader Positions           | Copy API + Lucid          | Real-time         |
| Signal Cards                 | Signal API                | Event-driven      |
| Top Movers Grid              | Market Data API + Lucid   | 30s               |
| Funding Rate                 | Market Data API           | 8h funding window |
| ◆ Kelly Size                 | Portfolio API + Lucid     | Real-time         |
| Order Book                   | Order Book API            | Real-time         |
| ◆ Order Book Annotations     | Order Book API + Lucid    | Real-time         |
| Intelligence Feed            | Intelligence API (R-INT1) | Event-driven      |
| Sentiment Tags               | Intelligence API          | Hourly            |
| Wallet Pulse                 | Wallet API                | Event-driven      |
| Copy Portfolio               | Copy API (D4) + Lucid     | Real-time         |
| Lucid Moment Stack           | Lucid API                 | Event-driven      |

---

## FUTURE ENHANCEMENTS (v3.1+)

1. **Pinned Assets on C2**: Users can pin top 3 assets for quick access
2. **Custom Tabs on C3**: Allow users to add/remove tabs
3. **Alert Customization**: Set price alerts directly from C3 header bell
4. **Collaborative Watchlists**: Share curated watchlists with other users
5. **Equity Curve Detail**: Tap equity curve to drill into daily/weekly/monthly breakdown
6. **Sentiment Heatmap (C2)**: Color-code all asset rows by sentiment (green/yellow/red)
7. **Onboarding Analytics**: Track drop-off at each stepper step
8. **◆ Lucid AI Suggestions**: Lucid recommends next pill based on behavior
9. **Order Book Depth Heatmap**: Visual heatmap overlay on depth chart with ◆ annotations
10. **Multi-Asset Comparison (C3)**: Side-by-side chart compare 2-3 assets with ◆ confluence comparison

---

## PROTOTYPE IMPLEMENTATION STATUS

> **Prototype URL:** https://arx-prototype.vercel.app
> **Last deployed:** 2026-03-13

| Screen                             | Status          | Implementation Notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| ---------------------------------- | --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **C1 Home Dashboard**              | ✅ Updated v9.2 | Journey-state adaptive (S7_NEW/S7_ACTIVE/S2_NEW/S2_ACTIVE). Equity header with Glass Level 2, canvas equity curve, period selector (1D/7D/30D/90D/YTD), **chart mode toggle (v9.1):** subtle 28×28px icon button toggles Line (cumulative curve + electricity pulse animation) ↔ Bar (daily P&L deltas, green/red). `switchEquityMode()` + `drawEquity()` with `state.equityChartMode`. Expandable Perps/Spot/Copy breakdown with progress bars. Lucid Moments full-width snap-scroll carousel (v9.0). Quick actions: [⚡ Quick Trade][💰 Fund][👥 Top Traders][📡 Signals][🔍 Explore]. Regime context card. Watchlist with sparklines. **Feed** (renamed from Activity, v9.1) — 4 items from feedItems. Open positions with safety gauges. Copy portfolio card (S7 only) with circuit breaker. **All currency in USD** (no KRW/₩). Unfunded hero card for NEW states. LucidTooltip (◆) integrated. **S7 wizard nudge card (v9.2):** shown in Quick Actions area for S7 users who skipped/defaulted wizard. Post-onboarding nudge system per Arx_9-5 §Part 3. |
| **C1 Quick Actions**               | ✅ Updated v9.2 | Universal 5-pill set: [⚡ Quick Trade][💰 Fund][👥 Top Traders][📡 Signals][🔍 Explore]. Card-style pills with emoji icons and labels. Each navigates to correct tab/sub-tab or opens sheet. **S7 Wizard Nudge Card (v9.2):** Below quick actions, conditional card for S7 users who have not completed wizard (or have defaults): "🎯 Find your ideal leaders / Answer 5 quick questions so we can match you with traders who fit your goals. Takes under 60 seconds. / [Start Matching →] [✕]". Dismiss: reappears after 3 days; after 2 dismissals, does not reappear (still accessible via You tab and Radar). Implementation: post-onboarding nudge system per Arx_9-5 §Part 3. Dashboard wizard prompt for S7 users who skipped wizard during onboarding.                                                                                                                                                                                                                                                                                                |
| **C1 Lucid Moments**               | ✅ Updated v9.0 | Full-width snap-scroll card carousel. Container `.lucid-scroll` with `scroll-snap-type: x mandatory`, `overflow-x: auto`. Each `.lucid-card` uses `scroll-snap-align: center`, `min-width: calc(100% - 0px)` — full viewport width, no side peeking. Active card: `scale(1)`, `opacity(1)`; inactive: `scale(0.95)`, `opacity(0.6)`. Transition: `300ms cubic-bezier` spring for scale/opacity. Dot indicators via `initLucidSwipeDots()` with IntersectionObserver. 3 cards: Morning Brief (data border), Position Review (warning border), Opportunity (positive border). Each has [◆ Ask a follow-up] button opening Lucid drawer with context. Positioned between equity header and quick actions per SOT spec.                                                                                                                                                                                                                                                                                                                                            |
| **C1 Equity Breakdown**            | ✅ New v8.0     | Expandable panel with 3-column grid (Perps $7,200/Spot $3,800/Copy $1,450), each with percentage bar, P&L, and allocation %. [See full position breakdown →] CTA. Toggle with ▼ Details.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| **C1 Journey States**              | ✅ New v8.0     | 4 journey states: S7_NEW (unfunded S7 hero + browse leaders CTA), S7_ACTIVE (full dashboard with copy portfolio), S2_NEW (unfunded S2 hero + explore CTA), S2_ACTIVE (full dashboard without copy). Unfunded hero has Fund Account button, How Arx Works link, and Explore link.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| **C1 Copy Portfolio**              | ✅ New v8.0     | S7 only. Shows 3 leaders (@CryptoSurgeon Elite 37%, @TrendRider Proven 33%, @SOLMaster Verified 29%) with tier badges, allocation, daily P&L, and per-leader circuit breaker. Account-level circuit breaker bar (68% current, floor 70, buffer 18%). [Manage in Radar →] CTA.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| **C1 Spot Holdings**               | ✅ Updated v8.0 | BTC 0.0042 · $285.15 · +$12 (+4.5%), SOL 2.1 · $365.82 · +$18 (+5.2%). Total $650. Displayed in You > Portfolio tab.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| **C1 Feed**                        | ✅ Updated v9.3 | Renamed from "Activity" to "Feed" (v9.1) to align with Radar Feed tab naming. Uses `buildHomeActivity()` helper. Shows first 4 feedItems. **S7 adaptations (v9.3):** [All →] navigates to Radar Feed **Copies** tab for S7 (`state.feedSubTab='copies'`), **forYou** tab for S2. Trending cards show "Find Leader →" CTA for S7 (instead of timestamp). Opportunity cards show "Copy →" CTA for S7. Whale Move cards show "Find Leader →" button for S7 (instead of "Trade →"). Position alert cards show "Your leader trades this" for S7.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| **C1 Positions**                   | ✅ Updated v8.0 | Uses buildHomePositions() helper. Safety margin as largest visual element with gauge bar. P&L as number text. Tap → Position Monitor (C6).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **C2 Markets**                     | ✅ Implemented  | Sub-tabs (Overview/Watchlist/Crypto/Forex/Commodities/Indices), per-tab instrument filter [All/Perps/Spot], asset list with regime badges and change percentages. Top movers grid on Overview.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| **C3 Asset Detail**                | ✅ Implemented  | Full-page navPush, price header with regime badge and confluence score, chart placeholder, timeframe pills (1m–1W), detail tabs (Overview/Order Book/Signals/Liquidation Map/Wallets for perps), 24h stats grid. Bookmark (☆/★) integration.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| **C3 Open Interest & Liquidation** | ✅ New v6.1     | Open Interest with 24h change, liquidation heatmap bars (shorts above, longs below)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| **C3 Cohort Breakdown**            | ✅ New v6.1     | Wallet Cohort Breakdown showing All-Weather/Specialist/Retail with bias %, direction, and net flow                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| **C3 Traders in Asset**            | ✅ New v6.1     | "Your Traders in [Asset]" section showing copied leaders with active positions in that instrument                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| **C3 Spot variant**                | ⬜ Spec only    | Spot-specific tabs (Overview/On-Chain/Order Book/Holders/Fundamentals) not yet in prototype                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| **C3 Lucid View**                  | ⬜ Spec only    | v9.0 Lucid View synthesis layer with overall score bar, 5 factor cluster breakdown, regime-conditional auto-weighting, Customize panel (Auto/Manual modes)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **C3 Technical Tab**               | ⬜ Spec only    | v9.0 Technical tab (all C3 variants) — TA Summary, Oscillators, Moving Averages, Volatility, Key Levels, Volume Analysis                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| **C3 Order Book 3-Layer**          | ⬜ Spec only    | v9.0 Three-layer progressive disclosure — Layer 0 Price Pulse (Overview), Layer 1 Horizontal Ladder (Depth tab default, tap-to-set-limit, wall detection), Layer 2 Depth Staircase (toggle). Current depth tab is a simplified version                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| **Fund Hub Staking Flow**          | ✅ New v9.0     | Fund Hub staking cards now open full staking UI via `showStakeFlow(token, price, apy, min, lock)` instead of "coming soon" toasts. Opens via `navPush('Stake ' + token, content)`. Three staking options: USDT (5.2% APY, Flexible), ETH (3.8% APY, 30 days), SOL (6.1% APY, Flexible). UI: token icon + "Stake [TOKEN]" header with APY/lock info, amount input card with preset pills (25%/50%/75%/MAX), yield details card (daily yield estimate, lock period, unstake fee — None for Flexible / 0.1% for locked, reward distribution: Daily), Lucid block explaining staking terms, "Stake [amount] [TOKEN]" execute button, auto-compound enabled note. On confirmation: toast "TOKEN staked successfully!" + `navPop()`.                                                                                                                                                                                                                                                                                                                                 |
| **Fund Hub navBack() Fix**         | ✅ Fixed v9.0   | Fund Hub confirmation buttons (Withdrawal, Transfer, Swap) now correctly use `navPop()` instead of the non-existent `navBack()` function.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| **C2-F Forex/Indices**             | ⬜ Spec only    | Non-crypto asset classes present in tab bar but no differentiated content                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
