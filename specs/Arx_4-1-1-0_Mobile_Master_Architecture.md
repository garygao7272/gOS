# Arx Mobile App — Master Architecture

**Artifact ID:** Arx_4-1-1-0
**Title:** Mobile Master Architecture — Module Map, Navigation, Cross-Module Flows, Global Components, Shared Frameworks
**Version:** 6.5 (v6.5: Trade Parameter Redesign per Arx_Trade_Parameter_Redesign_Proposal — Perps: 5-step flow with regime bar, risk % pills [1%][2%][5%], reframed questions, enhanced exit plan with TP/SL removal friction dialog, enhanced summary with position size units + liquidation. Spot: complete rewrite with portfolio % pills, Market Info card, More options expandable (Order Type, Sell Target, Price Alert, DCA). New state vars: tradeInstrType, tradeStyle, spotAmount, spotDir. New functions: detectTradeStyle(), tradeTPSLRemoveFriction(type), buildSpotTrade(inst). Modified: buildTrade() perps section enhanced, buildSpotTrade(inst) complete rewrite. S2/S7 detection, regime gate, cool-down timer integrated. | v6.4: D3 Copy Setup redesigned per Arx 9-7 — 3-step Quick + 8-step Full replaced with 4-step Briefing-First Wizard (Gate Check → Briefing Card → How Much → Safety Limits → Confirm & Start). New functions: d3CalcDecay, d3PortfolioFit, d3RegimeFit, d3RenderStep, d3ShowCustomize, d3ShowCapacityFull, d3ConfirmCopy, d3ToggleConsent, d3SetAlloc, d3UpdateAllocFromInput. New state vars: d3Alloc, d3MaxLossPct, d3CopyMode, d3LevCap, d3PerTradeSL, d3TradeSizeLimit, d3SlippageTol, d3SlippageFallback, d3DailyLossLimit, d3MonthlyDDLimit, d3RegimeScaling, d3AllocMode, d3RiskConsentChecked. Customize Protections bottom sheet replaces Full Setup. Capacity Full sheet added with waitlist + similar leaders. | v6.3: A4 Fund screen upgraded from static cards to 3 interactive sub-flows — MoonPay (4-step), Transak (3-step), Deposit (QR+address). 20 new functions added to registry for fund sub-flows, MoonPay, Transak, and Connect Wallet flows. A0 WalletConnect button now opens wallet selection modal with 4 wallets + connecting/success states. Skip button copy standardized to "Skip — explore first" across all onboarding screens. New state variables: mpAmount, tkAmount, tkMethod. | v6.2: Onboarding rewrite per Arx_9-5 proposal — S0 updated to Neural Pulse animation, A0 now Privy auth, A1 optional, added S7 Matching Wizard screens wiz1-wiz5 + wizDone, A4 updated to geo-detected fiat on-ramp. New critical paths for S7 Fast/Recommended/S2 flows. Wizard cross-module entry points and output feeds added. obNavigate() and obFinish() added to function registry. | v6.1: Added openTrade() and openTradeWithIntent() to function registry. Documented same-tab rebuild handling for contextual trade navigation. Implementation notes added to cross-module flows 5.1 and 5.2. | v6.0: Reordered tab bar: Home→Traders→Trade→Markets→You. Traders now position 2 (adjacent to Home), Trade position 3, Markets position 4. S7 primary path is now Home→Traders→Trade as a continuous left-to-right swipe. Added Spot vs Perps as system-wide instrument separation — every tab adapts content by instrument type with global [Perps/Spot/Both] filter. Exploration Trinity updated for new adjacency. All cross-module flows updated.)
**Last Updated:** 2026-03-19
**Status:** Active
**Prototype:** [deploy-five-peach.vercel.app](https://deploy-five-peach.vercel.app) — Arx_Mobile_WebApp_v1.0 (deploy/index.html) — single-file HTML/CSS/JS interactive prototype, mobile-native viewport with browser history navigation
**Design System Reference:** `Arx_4-2_Design_System.md` (all tokens, colors, typography, spacing, motion referenced by name, not redefined here)
**Mock Data & Visual Registry:** `Arx_4-1-1-8_Mock_Data_Fixtures.md` (canonical mock data, icon registry, embellishment registry — all design tools must use these exact values)
**Lucid Interaction Reference:** `Arx_6-1_Lucid_Interaction_Design_System.md` (unified Lucid interaction patterns — Hint, Card, Global ◆ — color tokens, CSS, migration checklist)

> **What this file IS:** The structural blueprint of the Arx mobile app. It defines how 7 modules compose into a cohesive product, how users navigate between them, what components are shared globally, and what frameworks underpin multiple screens.
>
> **What this file is NOT:** Individual screen specifications. Those live in module files 4-1-1-1 through 4-1-1-7. This file defines the architecture; module files define the screens.

---

## 1. DESIGN PHILOSOPHY

### Core Premise

Arx makes derivatives trading as intuitive as checking the weather. Every screen answers one question, every visualization replaces a paragraph of numbers, and every decision is guided — but never forced.

### 19 Design Principles

1. **Signal-First, Not Chart-First** — Lead with actionable intelligence, let users drill into charts when they choose.
2. **Visual Before Numerical** — Show the liquidation map before the liquidation price. Show the safety gauge before the percentage.
3. **Progressive Disclosure** — Show what matters now, let users expand for detail. Three taps maximum to any screen.
4. **Plain Language Always** — "Your safety cushion is 42%" not "Maintenance margin ratio: 142%."
5. **One Primary Action Per Screen** — Every screen has exactly one thing it wants you to do. Secondary actions exist but don't compete.
6. **Cognitive Load Budget** — Each screen targets 5 or fewer information chunks. Group related data visually. Use whitespace generously.
7. **Education in Context** — Explain concepts where they appear, not in a separate academy. Info tooltips expand without leaving the screen.
8. **Celebration Over Punishment** — Celebrate good process (using stop-losses, writing rationales) more than good outcomes. Never shame losses.
9. **Safety as Architecture** — Mandatory stop-losses, position limits, and wellness checks are structural, not optional settings.
10. **Mobile-Native Gestures** — Swipe to execute. Long-press for details. Pull-to-refresh. Pinch-to-zoom on charts. Haptic on key actions.
11. **Lucid as Intelligence Layer** — Intelligence is woven into every screen, not layered on top. The screen IS smart. Lucid surfaces data-driven insights through embedded annotations (◆), contextual insertions, and pull-thread conversations — never through floating overlays or separate AI interfaces.
12. **Social Proof Without Pressure** — Show what smart wallets are doing, but never frame it as "everyone is doing this, you should too."
13. **Consistency Across Contexts** — Same data, same visual treatment everywhere. A position card looks the same on Home, Portfolio, and Follow Dashboard.
14. **Accessibility by Default** — Color-blind safe palettes, sufficient contrast, screen reader labels, haptic feedback alternatives.
15. **Delight in Details** — Spring physics on cards, confetti on milestones, smooth equity curve draws. Quality signals trust.
16. **One Interface, Adapted Content** — Spot and perps share the same navigation, but each screen adapts its content. The user never has to "switch modes."
17. **Watchlist as Home Base** — Your watchlist is your personalized lens. Signals, prices, alerts, and recommendations all prioritize your watchlist items.
18. **Regime as Context Layer** — The current market regime is always visible, always informing. Every signal, trade suggestion, and wallet evaluation is regime-aware. The Regime Bar is the single most important piece of context on any screen.
19. **Protective Intelligence Over Permissive Access** — The system actively prevents bad follow decisions. Wallet classification badges, Three-Gate evaluation, and Sizing Guide recommendations are protective by design.

---

## 2. APP STRUCTURE — TAB BAR & MODULE MAP

### Tab Bar

```
┌──────────┬──────────┬────────────┬──────────┬──────┐
│   Home   │ Traders  │  ⚡ TRADE  │ Markets  │  You │
└──────────┴──────────┴────────────┴──────────┴──────┘
```

Each tab has a single Job to Be Done (JTBD), a primary segment it serves best, and a clear boundary with other tabs:

| Tab             | JTBD                                                | Primary Segment                             | What It IS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | What It Is NOT                                                                                             |
| --------------- | --------------------------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| **Home** (1)    | "What's happening right now that matters to me?"    | Both S2 + S7                                | Personalized dashboard: portfolio snapshot, watchlist, intelligence preview, quick actions, onboarding stepper. Content adapts by instrument type (spot vs perps).                                                                                                                                                                                                                                                                                                                                              | Not a discovery surface. Not where you find new assets.                                                    |
| **Traders** (2) | "Who should I follow? What signals should I trust?" | S7 (Copy Followers) primary, S2 secondary   | People-first exploration: discover leaders, copy trading, intelligence feed. Three browsable views (Feed, Traders, Market) plus dual-path action layer (Copy Trade for S7, Trade Myself for S2). Instrument filter (Perps/Spot/Both) applies across all views. Every path leads to a trade.                                                                                                                                                                                                                     | Not where you execute trades. Not where you explore instruments. Traders starts from THE PEOPLE (the trust). |
| **Trade** (3)   | "Execute my decision."                              | S2 primary, S7 secondary                    | Pure execution convergence: calculator entry, order management, position monitoring, trade history. Instrument type (perp vs spot) determines flow — perps: 5-step with regime bar, risk % pills, reframed questions, TP/SL friction, enhanced summary; spot: redesigned with portfolio % pills, Market Info, More options (Order Type, Sell Target, Price Alert, DCA). S2/S7 detection adapts defaults. Includes live pricing data (Price Pulse) and condensed order book (Smart Depth) for execution context. | Not where you decide WHAT to trade. That's Markets + Traders. Trade is the endpoint, not the starting point. |
| **Markets** (4) | "What should I trade? Show me the instruments."     | S2 (Aspiring Traders) primary, S7 secondary | Ticker-first exploration: browse, filter, sort all tradeable assets. Drill into asset detail with signal framework organized around the instrument. Separate views for perps (funding, OI, liquidation) and spot (volume, holders, support levels). Includes retail-friendly pricing data (Price Pulse) and order book intelligence (Smart Depth). Every path leads to a trade.                                                                                                                                 | Not where you execute trades. Not where you discover people. Markets starts from THE THING (the ticker).   |
| **You** (5)     | "My performance, my settings, my identity."         | Both S2 + S7                                | Portfolio overview (with perp vs spot breakdown), behavioral analytics, public profile, settings (including instrument preferences), rewards, notifications, help.                                                                                                                                                                                                                                                                                                                                              | Not operational. You review and configure here; you act in other tabs.                                     |

### The Exploration Trinity — "Explore → Execute"

This is the core architectural insight that governs how Traders, Markets, and Trade relate. The user journey is a funnel: two exploration paths converge on one execution endpoint.

**Tab adjacency is designed for the S7 primary path:** Home (1) → Traders (2) → Trade (3) is a continuous left-to-right swipe. This puts the most common journey (see portfolio → check traders → execute) in the most natural gesture flow. Markets (4) is one more swipe right for S2 users who want ticker-first exploration.

```
EXPLORE (Traders — position 2)     EXPLORE (Markets — position 4)
──────────────────               ──────────────────
Starting point: THE PEOPLE       Starting point: THE TICKER
"Who should I follow?"           "What should I trade?"

Browse leaders (Traders tab)     Browse instruments
Intelligence feed (Feed tab)     Asset detail (signals, charts)
Market context (Market tab)      Price Pulse + Smart Depth
Copy Trade / Trade Myself        Signals per instrument

S7 primary path                  S2 primary path
One swipe right →                Two swipes left ←
        │                                │
        ▼                                ▼
        ╔════════════════════════════════╗
        ║    EXECUTE (Trade — position 3)║
        ║  ──────────────────────────    ║
        ║  Calculator Entry              ║
        ║  Perp: leverage, funding, liquidation  ║
        ║  Spot: simple buy/sell         ║
        ║  Price Pulse + Smart Depth     ║
        ║  Execution Monitor             ║
        ║  Position Monitor              ║
        ║  Trade History                 ║
        ╚════════════════════════════════╝

Traders answers: "WHO to trust?"  (people → signals → conviction → trade)
Markets answers: "WHAT to trade?" (ticker → signals → conviction → trade)
Trade answers:   "Execute RIGHT NOW." (pre-filled from either path)

Handoff: Both Traders and Markets pre-fill Trade calculator via TradeIntent.
         TradeIntent carries instrument type (perp/spot) which determines
         which fields appear on the calculator.
         User reviews, adjusts if needed, confirms.

Tab adjacency: Traders and Trade are side-by-side because that's
the S7 primary path. Markets is one more tab right for S2 users.
```

**Why this tab order works:**

1. **S7 fast path — the primary journey** — S7 users (95% of demand) go Home (1) → Traders (2) → Trade (3), a continuous left-to-right swipe. The critical Copy → Trade handoff is a single adjacent tab switch. No detours.
2. **Traders is the center of gravity** — Position 2 (most reachable) matches Traders being the highest-frequency tab for S7. One swipe from Home, one swipe to Trade.
3. **Trade is the execution convergence** — Position 3 (center) means it's equidistant from both exploration tabs. Traders users swipe right once. Markets users swipe left once.
4. **S2 natural flow** — S2 users who want ticker-first exploration go to Markets (position 4), then swipe left to Trade (3) to execute. Markets → Trade is one swipe left.
5. **Markets as deep-dive, not daily habit** — Markets moves from position 2 to position 4 because it's used less frequently than Traders for the primary audience. S2 users who need it find it easily; S7 users who rarely need it aren't distracted by it.

### Spot vs Perps — System-Wide Instrument Separation

Arx trades two fundamentally different instrument types with different mechanics, signals, and risk profiles. Rather than creating separate app modes, every tab adapts its content based on instrument type. One app, adapted content.

**The two instrument types:**

| Concept           | Perpetual Futures (Perps)                                                     | Spot (Buy & Hold)                                         |
| ----------------- | ----------------------------------------------------------------------------- | --------------------------------------------------------- |
| **What it is**    | A bet on price direction with leverage. You don't own the asset.              | Buying and owning the actual asset.                       |
| **Leverage**      | 1x–50x available. Amplifies gains AND losses.                                 | 1x only. No leverage.                                     |
| **Funding Rate**  | Cost of holding — longs pay shorts (or vice versa) every 8 hours.             | Does not exist. You own the asset outright.               |
| **Open Interest** | Total value of all outstanding bets on this asset.                            | Not applicable.                                           |
| **Liquidation**   | If price moves too far against you, you're force-closed and lose your margin. | Cannot be liquidated. You own the asset.                  |
| **Shorting**      | Yes — bet that prices fall.                                                   | Not directly possible.                                    |
| **Basis Spread**  | The price gap between perp and spot. Indicates crowd sentiment.               | N/A — spot IS the reference price.                        |
| **Key signals**   | Funding rate, Open Interest, liquidation zones, leverage distribution, basis  | Volume, holder trends, exchange flows, support/resistance |

**How instrument type flows through the app:**

| Tab                      | Perps Content                                                                                                                   | Spot Content                                                                            | Shared                                  |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- | --------------------------------------- |
| **Home**                 | Portfolio shows leveraged positions with liquidation distance, funding P&L                                                      | Portfolio shows holdings with cost basis, unrealized P&L                                | Watchlist, notifications, quick actions |
| **Home Feed**            | Trader activity cards show leverage, funding context. Opportunity cards show Open Interest, liquidation clusters, funding cost. | Trader activity cards show buy/sell only. Opportunity cards show volume, holder trends. | Trader discovery, copy trade flow       |
| **Markets tab — Market Intelligence** | Asset drill-down with Open Interest charts, liquidation heatmap, cohort positions, funding charts                               | Asset drill-down with volume, support/resistance zones, holder distribution             | Regime map, correlations, events        |
| **Traders**              | Traders filtered/badged by whether they trade perps, spot, or both                                                              | Same                                                                                    | Discovery, follow, copy flows           |
| **Trade**                | Calculator shows leverage slider, margin mode, liquidation price, funding cost estimate                                         | Simpler calculator: amount to buy/sell, no leverage/margin fields                       | Order placement, position monitor       |
| **Markets**              | Asset detail shows funding, Open Interest, liquidation zones, basis spread, leverage stats                                      | Asset detail shows volume, holder trends, exchange flows, supply data                   | Price charts, regime, correlations      |
| **You**                  | Portfolio breakdown shows perp P&L with funding costs, margin usage                                                             | Portfolio shows spot holdings with cost basis                                           | Behavioral analytics, settings          |

**Global instrument filter:** A [Perps] [Spot] [Both] toggle is available on Traders (persistent below sub-tabs) and Markets (in the filter bar). When set, it filters all content in that tab. User preference is saved and persists across sessions. Default: Both.

**Instrument badges:** Every card, signal, and data point that is instrument-type-specific displays a badge — `PERP` (orange pill) or `SPOT` (blue pill). Users always know which type of trading a signal applies to.

**TradeIntent instrument awareness:** The TradeIntent object (which passes data from Traders/Markets to Trade) includes `instrument_type: "perp"|"spot"`. The Trade calculator adapts its fields based on this value — showing leverage/funding/liquidation fields for perps, hiding them for spot.

### Module Inventory

| Module         | File    | Tab(s)                                  | Screens                                                                                                        | Primary JTBD                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| -------------- | ------- | --------------------------------------- | -------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Onboarding** | 4-1-1-1 | Pre-auth                                | S0, A0, A1 _(optional)_, A1b, wiz1, wiz2, wiz3, wiz4, wiz5, wizDone, A2, A3, A4                                | S0 = Luminous Convergence animation (28 bubbles → cyan dots → spiral → bloom) → "Intelligence. Amplified." + "The future of autonomous trading" → crossfade to onboarding. A0 = Privy auth (Apple/Google/Email/Phone) + WalletConnect button opens wallet selection modal (MetaMask, Coinbase, WalletConnect, Rabby) with connecting spinner and success states → A1b direct. A1 = (Optional — removed from required path per 9-5). wiz1-wiz5 = S7 Matching Wizard Q1-Q5. wizDone = Match Result. A4 = Fund screen with 3 interactive sub-flows: MoonPay (amount → payment → processing → success), Transak (amount+method → instructions → pending), Deposit (QR + address + network details). All skip buttons use "Skip — explore first" copy and call obFinish(). Get the user from zero to first value in minimum time. |
| **Funding**    | 4-1-1-1 | Fund Hub (modal/tab)                    | B1, B2, B3, B4, B5, B6, B7                                                                                     | Move money in and out of Arx                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| **Home**       | 4-1-1-2 | Home (1)                                | C1                                                                                                             | Personalized at-a-glance status. Content adapts by instrument type.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| **Traders**    | 4-1-1-4 | Traders (2)                             | R0, D1, D1b, D2, D3 (4-step Briefing-First Wizard per Arx 9-7), D4, D5, D6 + Market sub-tab + Asset Drill-Down | People-first exploration: discover leaders, copy trade, signal feed (5-question framework). Spot/perps instrument filter. ~~R-AI1, R-AI2, R-INT1 removed in v5.0~~                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| **Trade**      | 4-1-1-3 | Trade (3)                               | TH, C5-NEW, C5, C6, C7, TH1                                                                                    | Execute and manage positions (convergence endpoint). Perps: 5-step flow with regime bar, risk % pills [1%][2%][5%], reframed questions, enhanced exit plan with TP/SL removal friction, enhanced summary with position size units + liquidation. Spot: redesigned with portfolio % pills, Market Info card, More options expandable (Order Type, Sell Target, Price Alert, DCA). Risk management: TP/SL removal friction, S2/S7 detection via `detectTradeStyle()`, regime gate, cool-down timer.                                                                                                                                                                                                                                                                                                                            |
| **Markets**    | 4-1-1-2 | Markets (4)                             | C2, C2-F, C3, C3-OB                                                                                            | Discover and evaluate assets. Separate signal views for perps vs spot.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| **You**        | 4-1-1-5 | You (5)                                 | E1, H1, P1, S1, R1, NC1, HC1, SEC1, KYC1, FEE1, REF1                                                           | Review performance (perp/spot breakdown), manage settings (instrument preferences).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| **Lucid**      | 4-1-1-6 | Cross-cutting (embedded + bottom sheet) | G1 + all screens                                                                                               | Complete intelligence layer — philosophy, moments, data architecture, G1 bottom sheet, prompt templates                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| **Data Model** | 4-1-1-7 | Reference                               | N/A                                                                                                            | Entity/relationship/state reference                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |

---

## 3. GLOBAL COMPONENTS

These components appear on every (or most) post-authentication screens. They are defined once here and referenced in module files.

### 3.1 Global Header

```
┌──────────────────────────────────────────────────────────────┐
│ ● $12,450 +$28 today ↑2.3% [🟢 Trending]   🔍  🔔(3)  │
└──────────────────────────────────────────────────────────────┘
```

| Element        | Data                                                           | Tap Action                                                      | Visual Feedback                                                                     | Notes                                                                                                                |
| -------------- | -------------------------------------------------------------- | --------------------------------------------------------------- | ----------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| ● (status dot) | Connection status: green=live, amber=delayed, red=disconnected | Tap → connection detail sheet                                   | Badge scales 0.95 + haptic light                                                    | WebSocket health indicator                                                                                           |
| $12,450        | Total account equity (anchor value)                            | Tap → E1 Portfolio                                              | Scales 0.95 on tap, color lightens 10%                                              | Updates real-time via WebSocket. Base value for blended display.                                                     |
| +$28 today     | Daily P&L: Copy Earnings (S7) or Unrealized P&L (S2)           | Same as equity tap                                              | Matches PnL color (green/red/gray)                                                  | Shows daily performance separate from equity. Blended metric updates in real-time.                                   |
| ↑2.3%          | 24h equity change %                                            | Same as equity tap                                              | Same as equity                                                                      | Green up / Red down / Gray flat. Part of blended header metrics.                                                     |
| [🟢 Trending]  | Current regime pill (persistent across all tabs/screens)       | Long-press → Regime detail sheet                                | Color matches regime state (emerald/red/blue/amber/purple); pulses on regime change | Consistent regime context. Pill is always visible, always in same position. Shows regime state with emoji indicator. |
| 🔍             | Global search                                                  | Tap → Search overlay                                            | Scale 0.9 + haptic light                                                            | Searches assets, leaders, strategies                                                                                 |
| 🔔(3)          | Notification bell with unread count                            | Tap → NC1 Notification Center                                   | Scale 0.95 + haptic light; badge bounces 1.2x then settles                          | Badge count: unread notifications                                                                                    |
| ◆              | Lucid intelligence marker                                      | Tap → Lucid conversational sheet with context-specific insights | Pulse animation on data update (scale 1.0→1.1→1.0, 600ms)                           | Universal signature of embedded intelligence                                                                         |

**Blended Header Display:** The header shows four interconnected metrics: total equity as the anchor value, daily P&L as the performance acceleration indicator, daily change percentage as the directional summary, and persistent regime pill as the contextual layer. The regime pill (colored badge) remains consistent across ALL tabs and screens, ensuring users always know the market context. Together these four elements answer: "What do I have? How am I doing today? What's the direction? What's the regime?"

> **v10 note (Home-specific):** On C1 Home, the equity header is expanded into a full **Portfolio Card** with an interactive equity chart (canvas-rendered, Water cyan line with electricity pulse) for users with positions. This card includes time period selector (Apple Stocks pattern), line/bar toggle ("Daily P&L"/"Equity"), expandable breakdown (Spot Equity, Copy P&L, Unrealized, Margin Used), and a regime pill with plain-language label. For users without positions, a simpler sparkline variant is shown. See `4-1-1-2` State × Element Matrix for full state logic. The global header (this spec) shows the compact blended display on all other tabs.

**Appears on:** Every post-auth screen except fullscreen modals.
**Does NOT appear on:** S0 (splash), A0-A4 (onboarding), B2-B7 (funding flow screens in modal).

### 3.2 Regime Bar

```
┌──────────────────────────────────────────────────┐
│ ████████████████ TRENDING ↑ (72%) ████████████  ℹ │
└──────────────────────────────────────────────────┘
```

| State         | Background | Text                         | Hex (Dark Mode) | Tap Action                   | Animation                                                       |
| ------------- | ---------- | ---------------------------- | --------------- | ---------------------------- | --------------------------------------------------------------- |
| Trending Up   | Emerald    | "TRENDING ↑" + confidence %  | `#10B981`       | Expand → regime detail sheet | Color transition 300ms ease-in-out + pulse to attract attention |
| Trending Down | Red        | "TRENDING ↓" + confidence %  | `#EF4444`       | Expand → regime detail sheet | Color transition 300ms ease-in-out + pulse                      |
| Range-bound   | Blue       | "RANGE-BOUND" + confidence % | `#3B82F6`       | Expand → regime detail sheet | Color transition 300ms ease-in-out + pulse                      |
| Transition    | Amber      | "TRANSITION" + confidence %  | `#F59E0B`       | Expand → regime detail sheet | Color transition 300ms ease-in-out + pulse                      |
| Compression   | Purple     | "COMPRESSION" + confidence % | `#8B5CF6`       | Expand → regime detail sheet | Color transition 300ms ease-in-out + pulse                      |
| Crisis        | Deep Red   | "CRISIS" + confidence %      | `#DC2626`       | Expand → regime detail sheet | Color transition 300ms ease-in-out + pulse                      |

**Interactions:**

- **Default (collapsed):** Colored bar, regime label + confidence %, 32dp height.
- **Tap:** Expands to show regime label + confidence, duration (e.g., "Trending for 4h 23m"), 2-line explanation, "What works / What to avoid" guidance. Scale 1.0 + haptic light.
- **Long-press:** Full regime detail sheet with historical frequency, current indicators, strategy recommendations. Scale 0.98 on press.
- **Animation on change:** Color crossfade 400ms ease-in-out + pulse effect (scale 1.0→1.05→1.0 over 400ms).
- **Accessibility:** Screen reader announces regime and confidence on every screen load.

**Appears on:** EVERY post-auth screen.
**Does NOT appear on:** S0 (splash), A0-A4 (pre-auth onboarding).

### 3.3 Tab Bar

```
┌──────────┬──────────┬──────────┬────────────┬──────┐
│ 🏠 Home  │ 📊Markets│📡Traders │  ⚡ TRADE  │ 👤You│
│          │          │          │ ▰▰ (CTA)  │      │
└──────────┴──────────┴──────────┴────────────┴──────┘
```

| Property       | Value                                              | Tap Action    | Visual Feedback                                            |
| -------------- | -------------------------------------------------- | ------------- | ---------------------------------------------------------- |
| Height         | 49dp (iOS standard) + safe area                    | —             | —                                                          |
| Active state   | Filled icon + label, stone-glow color `#A78BFA`    | Tab tap       | Cross-fade 200ms + content slides in direction of tab      |
| Inactive state | Outline icon + label, text-secondary `#9D96B8`     | —             | —                                                          |
| Badge on Traders | Numeric badge (new signals)                        | Tap Traders tab | Scale 0.95 + haptic light, badge bounces 1.2x then settles |
| Badge on Trade | PnL dot (see Trade CTA below)                      | Tap Trade tab | Scale 0.95 + haptic medium                                 |
| Badge on You   | Numeric badge (notifications)                      | Tap You tab   | Scale 0.95 + haptic light, badge bounces 1.2x then settles |
| Haptic         | Light impact on tab switch                         | —             | 15ms light haptic                                          |
| Animation      | Cross-fade 150ms between icons + directional slide | —             | Icon cross-fades as content slides                         |

#### The Trade Tab — Distinguished CTA Design

The Trade tab is the core action center of Arx. It must stand out from the other four tabs without being garish (no Bitget oversized floating circle). The design uses the **stone signature** — solid `#5B21B6` with enhanced elevation and a subtle stone glow — to signal "this is where action happens."

**Design Concept: "The Pulse"**

```
┌──────────┬──────────┬──────────┬─────────────┬──────┐
│          │          │          │             │      │
│  🏠      │  📊      │  📡      │  ⚡ TRADE   │  👤  │
│  Home    │ Markets  │ Traders  │   ▬▬▬▬▬▬   │  You │
│          │          │          │             │      │
└──────────┴──────────┴──────────┴─────────────┴──────┘
                                  └── stone underline + lift ──┘
```

| Property                  | Spec                                                                                                                                                                                                        |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Icon**                  | ⚡ Lightning bolt (custom, not emoji — sharp geometric, matching Arx Architectural A style)                                                                                                                 |
| **Label**                 | "TRADE" in `--font-weight-bold (700)` + letter-spacing 0.5px. All caps. Other tabs use Title Case                                                                                                           |
| **Stone underline**       | 3px bar below the Trade tab. Solid `#5B21B6` (stone violet). The only colored underline in the tab bar. Width = full tab cell width                                                                         |
| **Lift effect**           | The Trade icon + label are positioned 2dp higher than siblings — subtle visual lift that draws the eye without breaking alignment                                                                           |
| **Text color (inactive)** | When Trade tab is NOT selected: icon and label use `#EEE9FF` (text-primary) instead of `#9D96B8` (text-secondary) that other inactive tabs use. Trade is _always_ slightly brighter                         |
| **Text color (active)**   | Solid `#5B21B6` (stone violet). Consistent with the stone underline.                                                                                                                                        |
| **Glow**                  | Subtle 8px stone glow (`#5B21B6` at 20% opacity) beneath the stone underline. Visible in dark mode, invisible in light mode                                                                                 |
| **PnL dot**               | When user has open positions: tiny 6px dot to the right of "TRADE" text. Green = aggregate PnL positive. Red = aggregate PnL negative. Pulses gently (scale 0.8→1.0→0.8, 2s loop) when positions are active |
| **No-position state**     | Stone underline still present. No PnL dot. The visual distinctiveness is permanent, not conditional                                                                                                         |
| **Tap animation**         | On tap: stone underline scales width 0.8x→1.0x (100ms spring). Icon scales 0.9→1.0 (150ms spring). Haptic: medium impact (not light like other tabs)                                                        |

**Dark Mode:**

```css
.tab-trade {
  /* Stone underline */
  border-bottom: 3px solid #5b21b6;

  /* Subtle glow */
  box-shadow: 0 4px 8px rgba(91, 33, 182, 0.2);

  /* Lift */
  transform: translateY(-2px);

  /* Always brighter than siblings when inactive */
  color: #eee9ff; /* vs #9D96B8 for other inactive tabs */
}

.tab-trade.active {
  /* Stone text */
  color: #5b21b6;
}
```

**Light Mode:**

```css
.tab-trade {
  /* Stone underline */
  border-bottom: 3px solid #5b21b6;

  /* No glow in light mode */
  box-shadow: none;

  /* Lift */
  transform: translateY(-2px);

  /* Brighter = darker in light mode */
  color: #0a0918; /* vs #6B7280 for other inactive tabs */
}

.tab-trade.active {
  /* Stone text */
  color: #5b21b6;
}
```

**Why this works:**

1. **Brand consistency**: Stone violet is the brand primary used for the Execute Trade button. Using the same solid color on the tab's underline creates a visual throughline — stone means "trade" everywhere. No gradients exist in the design system.
2. **Not oversized**: Unlike Bitget/Binance's floating circle, this is architecturally flush with the tab bar. It's differentiated by _materials_ (stone underline, glow, lift), not by _size_.
3. **Subtle but unmissable**: The 2dp lift + stone underline + always-brighter text creates a gravity well for the eye. Testing will determine if the glow needs adjustment.
4. **Works in both modes**: Stone violet + water cyan works on both dark and light backgrounds — this was designed into the brand palette from day one.

**Traders tab special behavior:** For S7 users, Traders badge shows count of unread copy portfolio events. Tap action: Switch to Traders tab + content slides left-to-right (from Home) or right-to-left (from Trade) with cross-fade. Traders sits at position 2 (second from left), making it the natural hub between Home (left) and execution (Trade, right).

### 3.4 Bottom Sheets (Shared Pattern)

Bottom sheets are the primary pattern for non-navigating detail views.

| Type      | Height                            | Behavior                                                                          | Use Cases                                                                        | Animation                                       | Tap/Swipe Actions                                                   |
| --------- | --------------------------------- | --------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | ----------------------------------------------- | ------------------------------------------------------------------- |
| Peek      | 30% viewport                      | Swipe up to expand, swipe down to dismiss                                         | Quick info (regime detail, price alert config)                                   | Slide up 300ms spring(0.8) + backdrop blur 16px | Swipe up: expand to Half; Swipe down: dismiss with 200ms slide-down |
| Half      | 50% viewport                      | Content scroll within sheet                                                       | Filters, confirmations, short forms                                              | Slide up 300ms spring(0.8) + backdrop blur 16px | Swipe up: expand to Full; Swipe down: collapse to Peek              |
| Full      | 90% viewport                      | Near-fullscreen with drag handle                                                  | D3 Copy Setup, long forms, detail views                                          | Slide up 300ms spring(0.8) + backdrop blur 16px | Swipe down: collapse to Half                                        |
| Lucid Q&A | 50% viewport → expandable to Full | Pull-thread conversation. Starts at Half, can expand to Full for longer responses | Context-specific insights, multi-turn follow-ups, deep dives triggered by ◆ taps | Slide up 300ms spring(0.8) + backdrop blur 16px | Swipe up: expand to Full; Swipe down: dismiss                       |

**Shared properties:** 8px corner radius top, `#1E293B` surface color, drag handle (40x4px, centered, `#334155`), backdrop blur 16px on background.

### 3.5 Toast Notifications

| Type    | Color               | Duration               | Position              | Animation                        | Dismissal                           |
| ------- | ------------------- | ---------------------- | --------------------- | -------------------------------- | ----------------------------------- |
| Success | Emerald left border | 3s auto-dismiss        | Top, below regime bar | Slide in from top 300ms ease-out | Auto-dismiss or swipe up to dismiss |
| Error   | Red left border     | Sticky until dismissed | Top, below regime bar | Slide in from top 300ms ease-out | Tap ✕ or swipe up                   |
| Warning | Amber left border   | 5s auto-dismiss        | Top, below regime bar | Slide in from top 300ms ease-out | Auto-dismiss or swipe up            |
| Info    | Blue left border    | 3s auto-dismiss        | Top, below regime bar | Slide in from top 300ms ease-out | Auto-dismiss or swipe up            |

**All toasts:** Slide out 300ms ease-in on dismiss.

### 3.6 Global Search Overlay

Triggered by 🔍 in global header.

```
┌──────────────────────────────────────────────────┐
│  🔍 Search Arx...                          ✕    │
├──────────────────────────────────────────────────┤
│  RECENT SEARCHES                                 │
│  BTC/USD · ETH/USD · @CryptoSurgeon             │
│                                                  │
│  TRENDING                                        │
│  SOL/USD ↑12.3% · DOGE/USD ↑8.1%               │
├──────────────────────────────────────────────────┤
│  [Results appear as you type]                    │
│                                                  │
│  ASSETS                                          │
│  ├ BTC/USD  $67,234  ↑1.2%          [View →]    │
│  ├ BTC/ETH  0.0234   ↓0.3%          [View →]    │
│                                                  │
│  LEADERS                                         │
│  ├ @BitcoinWhale 🛡️ +42% 90d        [Profile →] │
│                                                  │
│  AI STRATEGIES                                   │
│  ├ BTC Trend Follower  +28% backtest [View →]    │
└──────────────────────────────────────────────────┘
```

| Feature           | Behavior                                         | Tap/Interaction Action                                |
| ----------------- | ------------------------------------------------ | ----------------------------------------------------- |
| Input             | Auto-focus, keyboard appears immediately         | Text input captures user query                        |
| Debounce          | 300ms after last keystroke before search fires   | Server-side search executes                           |
| Result categories | Assets, Leaders, AI Strategies (parallel search) | Each category loads independently                     |
| Asset tap         | → C3 Asset Detail                                | Scale 0.97 on tap, slide transition 350ms spring(0.8) |
| Leader tap        | → D2 Wallet Profile                              | Scale 0.97 on tap, slide transition 350ms spring(0.8) |
| Strategy tap      | → R-AI2 Strategy Detail                          | Scale 0.97 on tap, slide transition 350ms spring(0.8) |
| Empty state       | "No results for [query]" with suggestions        | Fade in 200ms ease-out                                |
| Dismiss (✕)       | Close overlay, return to previous screen         | Scale 0.95 on tap, overlay slides down 300ms ease-in  |
| Swipe down        | Close overlay                                    | Drag tracked, slides down on release, 300ms ease-in   |

### 3.7 Paper Trading Mode Toggle (Phase 1)

**Purpose:** Allow users to switch between live trading and paper trading (demo mode) without logging out. Paper trading uses simulated funds and real market data but executes no real trades. Designed for net-new traders who need a zero-risk sandbox.

**Access points:**

- **Settings (S1):** Toggle under "Trading Preferences" section — `[Paper Trading Mode] [ON/OFF]`
- **Profile header (You tab):** When active, a persistent `PAPER` badge appears next to the equity display in the global header
- **Onboarding (A1b):** Alternative path for users who select "Never traded" experience level (see 4-1-1-1)

**Visual indicators when Paper Trading is active:**

- Global header equity label prefixed with `PAPER` pill badge (orange outline, 10px, `--color-warning`)
- Tab bar shows subtle dashed bottom border (2px, `--color-warning`, 40% opacity) as persistent reminder
- All trade confirmation screens show "This is a simulated trade — no real funds used" disclaimer
- Copy trading is disabled in paper mode — [Copy] buttons show tooltip "Switch to live trading to copy"

**State:** `state.paperTradingMode` (boolean, default `false`). Persisted in user preferences. Toggling requires confirmation dialog: "Switch to paper trading? Your live positions remain open but you won't be able to place new live trades until you switch back."

**Paper trading balance:** Starts at $10,000 simulated USDC. Resettable from Settings. Separate from live balance — both visible on the Assets (W1) screen when paper mode is active.

### 3.8 Shared Simplified Language Glossary

All user-facing labels across Markets (4-1-1-2) and Trade (4-1-1-3) use simplified terminology for maximum accessibility. This is the single source of truth — all screen specs MUST use these terms.

| Jargon Term             | Display Term                           | Tooltip / Plain-Language Rule                                                                                                                                                                                                                       |
| ----------------------- | -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| "Open Interest"         | "Outstanding Positions" or "Open Bets" | "the total value of all active trades on this asset"                                                                                                                                                                                                |
| "Funding Rate"          | "Holding Cost"                         | "A fee charged every 8 hours for holding a leveraged position. Longs pay shorts when positive, or vice versa"                                                                                                                                       |
| "Liquidation"           | "Forced Close"                         | "when the exchange automatically closes your position because losses ate up your safety margin"                                                                                                                                                     |
| "Liquidation distance"  | "Liquidation Distance"                 | v10.2: renamed back from "Safety margin" per Trade Parameter Redesign. Dynamically computed from leverage with color emoji: 🟢 safe, 🟡 caution, 🔴 danger. Tooltip: "How far price can move against you before your position closes automatically" |
| "Basis Spread"          | "Perp vs Spot Gap"                     | "the price difference between perpetuals and spot"                                                                                                                                                                                                  |
| "Long/Short Ratio"      | "Bull/Bear Balance"                    | "what percentage of traders are betting up vs down"                                                                                                                                                                                                 |
| "Confluence"            | "Signal Strength"                      | "how many independent signals agree on this trade direction — higher = stronger conviction"                                                                                                                                                         |
| "ATR"                   | Never shown as label                   | Replace with "Recent price swings" or "Normal price movement range"                                                                                                                                                                                 |
| "Kelly sizing"          | "Smart sizing"                         | "A math-based way to size your position based on your track record"                                                                                                                                                                                 |
| "R:R ratio"             | "Reward-to-risk"                       | Plain example: "For every $1 you risk, you could make $2.3"                                                                                                                                                                                         |
| "Leverage"              | Keep "Leverage"                        | Always explain: "Leverage multiplies both gains AND losses. At 3x, a 1% price move affects your position by 3%"                                                                                                                                     |
| "Margin mode"           | "Risk isolation"                       | cross = "shared risk across all trades" / isolated = "risk limited to this trade only"                                                                                                                                                              |
| "Open Interest × Price" | —                                      | Always explained in plain English sentences (e.g., "Money flowing IN — new capital entering with rising price, not just short covering")                                                                                                            |

**Rule:** Every metric includes a one-line plain-language annotation or tooltip. No jargon appears bare.

---

## 4. THE ◆ (DIAMOND) SYSTEM — LUCID'S EMBEDDED INTELLIGENCE

### What ◆ Means

The ◆ (diamond) is Lucid's universal signature. Every data-driven, intelligence-powered element across the app is marked with ◆. Users learn one thing: "the diamond means there's intelligence behind this number."

### ◆ Visual Specification

| Property        | Value                                          |
| --------------- | ---------------------------------------------- |
| Glyph           | ◆ (U+25C6, Black Diamond)                      |
| Size            | 12px inline with text                          |
| Color           | Contextual accent color (matches insight type) |
| Hit area        | 44×44px minimum (tap target)                   |
| Pulse animation | Scale 1.0→1.1→1.0 over 600ms when data updates |

### ◆ Interaction Model

| Action                               | Result                                                                       |
| ------------------------------------ | ---------------------------------------------------------------------------- |
| Tap ◆ on any screen element          | Bottom sheet slides up with expanded evidence + text input for follow-up Q&A |
| Tap ◆ in navigation header           | General Lucid conversational sheet opens                                     |
| Long-press any Lucid-powered element | Same as tap ◆ — opens context-specific bottom sheet                          |

### ◆ Accent Colors

| Insight Type             | ◆ Color              |
| ------------------------ | -------------------- |
| Opportunity / Confluence | Gold (#FFB800)       |
| Risk / Caution           | Amber (#FF8A00)      |
| Reflection / Learning    | Slate Blue (#6B7FE8) |
| Leader Intelligence      | Teal (#00C4B4)       |
| Regime / Market State    | Matches regime color |

### Proactive Notifications

For events that can't be embedded (regime changes while on different screen, leader trades):

| Element    | Behavior                                             |
| ---------- | ---------------------------------------------------- |
| Top banner | Slides down from top, auto-dismisses after 4 seconds |
| Content    | Single-line: "◆ Regime shifted: Volatile-Choppy [→]" |
| Tap        | Navigates to relevant context                        |
| Logged     | Always saved to notification center                  |

---

## 5. CROSS-MODULE NAVIGATION FLOWS

These are the critical user journeys that span multiple modules. Each describes the exact screen sequence and handoff mechanism with explicit animations at every transition.

### 5.1 Markets → Trade Flow (S2 Primary Journey)

This is the most common trading flow: browsing markets, finding an asset, executing a trade. **Optimized for speed-to-trade: 2 taps from C3 to order placed.**

```
C2 Markets List
  │ Tap asset row
  ▼ [Card presses: scale 0.97 + shadow lift 150ms spring]
C3 Asset Detail (content adapts to instrument type — see 4-1-1-2)
  │ Shows: type-specific content (crypto perp: chart, OB, funding, Open Interest, signals, wallets)
  │        (stock perp: + earnings, sector, fundamentals)
  │        (commodity perp: + macro, supply/demand, COT)
  │ Primary CTA: [Trade ▶] (sticky bottom)
  │ Tap [Trade ▶]
  ▼ [Shared element transition: symbol morphs from C3 to C5-NEW 350ms spring(0.8)]
C5-NEW Calculator Entry (DIRECT — skips TH)
  │ Perps: 5-step flow — regime bar, direction, leverage, risk % pills [1%][2%][5%], enhanced exit plan (TP/SL with removal friction), enhanced summary (position size units + liquidation)
  │ Spot: portfolio % pills, Market Info card, Advanced Trade Settings (Order Type, Sell Target, Price Alert, DCA)
  │ Ticker name tappable → Quick Ticker Search (switch asset without going back)
  │ Primary CTA: [Open Long — $375 risk]
  │ Tap CTA
  ▼ [Button scale 0.95 + haptic + success confetti burst 1s ease-out]
C5 Execution Monitor
  │ Order submitted → pending → filling → filled
  │ On fill complete:
  ▼ [Transition: slide up 300ms spring(0.8)]
C6 Position Monitor
  │ Live position: entry, PnL, safety gauge, liquidation distance
  │ Ticker name tappable → Quick Ticker Search (switch to another C3)
  │ Actions: Close, Add Margin, Set TP/SL, View Trade Review (C7)
```

**Speed optimization:** C3 [Trade ▶] goes **directly to C5-NEW Calculator**, skipping the Trade Hub (TH). TH is still accessible via the Trade tab for position management, but the critical path from "I see this asset" to "I'm sizing my trade" is now **2 taps** (tap asset → tap [Trade ▶]).

**Implementation:** `openTrade(sym)` handles this flow. It sets `state.tradeMode = 'calc'` and `state.tradeSymbol = sym`, then either rebuilds the Trade screen in place (if already on Trade tab) or calls `switchTab('trade')`. The same-tab detection is critical because `switchTab()` returns early when already on the current tab — without the explicit rebuild, navigating from one Trade screen to another Trade screen would appear to do nothing.

**Quick Ticker Switch throughout the flow:** At any point (C3, C5-NEW, C6), tapping the ticker name opens the Quick Ticker Search overlay. User can switch to a different asset without navigating back. On C5-NEW, the calculator resets with the new symbol. On C6, it navigates to C3 for the new symbol.

**Handoff mechanism:** When user taps [Trade ▶] on C3, the app writes to a shared `TradeIntent` object:

```
TradeIntent {
  symbol: "SOL-PERP"
  instrument_type: "perp"           // Drives calculator adaptation: "perp" → C5-NEW-P, "spot" → C5-NEW-S
  source: "markets_c3"
  direction: null                   // User chooses on C5-NEW
  regime_context: { state: "TRENDING", strength: 72, change_prob_4h: 0.15 }
  funding_rate: 0.012               // From On-Chain tab
  funding_percentile: 82            // Derived — for Lucid: "Funding in top 20%"
  wallet_consensus: { direction: "BULLISH", count: 4, strength: 0.72 }
  leader_positions: [top 5]         // From Traders tab
  smart_money_net_position: 0.72    // Smart Money aggregate
  suggested_tp: null                // Populated by Lucid on C5-NEW
  suggested_sl: null
  suggested_size: null
  entry_price: null                 // Set if user taps order book level
  oi_regime_alignment: true         // Open Interest × Price analysis from On-Chain tab
  session_state: null               // For stocks/commodities
  market_hours_warning: false       // True if market closed
}
```

C5-NEW reads this intent and adapts the calculator to the instrument type.

### 5.2 Traders → Trade Flow (Signal-Driven — Adjacent Tab Handoff)

User sees a signal in Traders and wants to act on it. Since Traders (position 2) and Trade (position 3) are now adjacent tabs, the handoff is a single swipe right — the most natural gesture on mobile.

```
~~R-INT1 Intelligence Feed (Traders tab, position 2)~~ *(removed in v5.0)*
  │ Sees: "BTC breaks above resistance with 80% confidence"
  │ CTA: [Trade this signal →]
  │ Tap CTA
  ▼ [Signal card morphs to calculator header 350ms spring(0.8)]
Trade Tab activates (position 3, one tab right) → C5-NEW Calculator Entry
  │ Pre-filled: symbol=BTC-USD, direction=Long, suggestedTP/SL from signal
  │ Price Pulse widget shows live pricing context + Smart Depth summary
  │ User reviews, adjusts, confirms
  ▼ [Button scale 0.95 + haptic + confetti burst 2s ease-out]
C5 Execution Monitor → C6 Position Monitor
  │ Order fills, position live
  ▼ [Celebration animation: confetti + haptic pattern]
```

**Also works from:**

- R-AI2 Strategy Detail → [Deploy] → Trade Calculator (pre-filled with strategy params) — Button: scale 0.95 + haptic light, transition 350ms spring(0.8)
- D2 Wallet Profile → [Copy] → D3 Copy Setup (different flow — goes to Traders setup, not Trade) — Button: scale 0.95 + haptic light
- D2 Wallet Profile → [Trade Myself] → Trade Calculator (pre-filled with signal context from leader's position) — Button: scale 0.95 + haptic light
- G1 Lucid → "Open a long BTC position" → Trade Calculator — Bottom sheet slides down 300ms, calculator scales up 350ms spring(0.8)

**Implementation:** `openTradeWithIntent(sym, dir, lev, source)` handles all Traders → Trade flows. It pre-fills `state.tradeSymbol`, `state.tradeDir`, `state.tradeLev`, and `state.tradeIntent`, then navigates to calculator mode. Same-tab handling ensures that clicking [Trade Myself] while already on the Trade tab correctly rebuilds the calculator with the new parameters. A toast notification confirms the pre-fill source ("Pre-filled from signal" or "Pre-filled from @leader").

### 5.3 Onboarding Critical Paths (Updated per Arx_9-5)

Three onboarding paths serve different user intents. Only A0 auth + A1b intent selection are REQUIRED steps; everything else is optional or skippable.

#### S7 Fast Path (skip everything)

```
S0 (Luminous Convergence → "Intelligence. Amplified." → crossfade)
  ▼
A0 (Privy auth: Apple/Google/Email/Phone + WalletConnect)
  ▼
A1b ("Follow" intent selected)
  ▼
App (lands on Home tab)
```

#### S7 Recommended Path (wizard + optional fund)

```
S0 → A0 (Privy) → A1b ("Follow" intent)
  ▼ [List items fade-in + slide-up staggered 50ms 300ms ease-out per item]
Wiz1 (S7 Matching Wizard Q1) → Wiz2 (Q2) → Wiz3 (Q3) → Wiz4 (Q4) → Wiz5 (Q5)
  ▼ [Transition: fade + slide 200ms ease-in-out per question]
wizDone (Match Result — personalized leader recommendations)
  ▼
[A4] Fund prompt (MoonPay/Transak, geo-detected) — optional, skippable
  ▼
App (lands on Home tab, pre-filtered by wizard results)
  │ "What's Moving" + Top Leaders carousel (personalized)
  │ Tap leader card
  ▼ [Card scale 0.97 + shadow lift, then slide transition 350ms spring(0.8)]
D1 Discover Leaders (enhanced with copier profit, tier badges, style tags)
  │ Browse, filter, sort
  │ Tap [Copy] on a leader card
  ▼ [Button scale 0.95 + haptic light]
D2 Wallet Profile (full evaluation: Three-Gate, stats, style tags)
  │ Primary CTA: [Copy This Trader →]
  ▼ [Button scale 0.95 + haptic light, bottom sheet slides up 300ms spring(0.8)]
D3 Copy Setup (pre-filled from wizard output)
  │ 4-step Briefing-First Wizard (per Arx 9-7): Gate Check → Briefing Card → How Much → Safety Limits → Confirm & Start
  │ Customize Protections bottom sheet for advanced controls
  ▼ [Swipe-to-execute animation: thumb tracks along rail + fills green]
D4 Copy Dashboard
  │ Portfolio health bar, active copies, daily earnings
  │ S7 SUCCESS: watching money work for them
  ▼ [Success celebration: confetti burst + haptic pattern 2s ease-out]
```

#### S2 Path (self-directed traders)

```
S0 → A0 (Privy) → A1b ("Trade" intent)
  ▼
[A2 → A2b → A3 → A4] — all optional, brackets = skippable
  ▼
App (lands on C1 Home)
```

**Note:** Only A0 auth + A1b intent are REQUIRED steps. A1 (experience level) is optional — removed from required path per Arx_9-5.

**Time-to-value target:** Under 10 minutes from A0 to D4 (first copy active) for S7 Recommended path. Under 60 seconds for S7 Fast path.

### 5.4 Markets → Traders → Trade Flow (Full Exploration Trinity)

The complete exploration journey: user starts from an instrument, seeks social proof via Traders, then executes. This flow leverages the new tab adjacency (Markets → Traders → Trade are positions 4→2→3).

```
C2 Markets List (Markets tab, position 4)
  │ Browse instruments, see Price Pulse summaries
  │ Tap asset row
  ▼ [Card presses: scale 0.97 + shadow lift 150ms spring]
C3 Asset Detail
  │ 5-question signal framework organized around the ticker:
  │   Q4 Trust: "Who's trading this?" → wallet consensus, smart money flow
  │   Q5 What Changed: "Why now?" → recent signals, regime shift, news
  │   Q1 High Conviction: "Should I trade this?" → confluence score, entry/exit
  │   Q2 Timing: "Is now the right time?" → regime context, funding, momentum
  │   Q3 Construction: "How should I size it?" → Kelly, leverage, risk budget
  │ Price Pulse + Smart Depth for pricing intelligence
  │ Two CTAs: [Trade ▶] and [See Who's Trading →]
  │
  ├─ Tap [See Who's Trading →]
  │  ▼ [Slide transition to Traders tab, position 2]
  │  Traders tab → D1 Discover Leaders (filtered to this asset)
  │  │ See leaders with positions in this instrument
  │  │ Tap leader → D2 Wallet Profile
  │  │ [Copy This Trader →] or [Trade Myself →]
  │  ▼
  │  Trade Tab (position 3) → C5-NEW Calculator
  │
  └─ Tap [Trade ▶]
     ▼ [Shared element transition: symbol morphs 350ms spring(0.8)]
     Trade Tab (position 3) → C5-NEW Calculator Entry (DIRECT)
     │ Pre-filled from Markets context
     ▼
     C5 → C6 (execution flow)
```

**Key UX insight:** The [See Who's Trading →] CTA on C3 Asset Detail creates a bridge between the ticker-first exploration (Markets) and the people-first exploration (Traders). It answers: "I'm interested in this asset — who else thinks it's a good trade?" This is the moment where S2 behavior (independent research) seeks S7-style social proof.

### 5.5 Portfolio Review → Adjust

```
You Tab → E1 Portfolio Overview
  │ See: Trading Portfolio tab / Copy Portfolio tab
  │ [Tab switch: content cross-fades + directional slide 200ms ease-in-out]
  │
  ├─ Tap position in Trading Portfolio
  │  ▼ [Card scale 0.97 + shadow lift, slide transition 350ms spring(0.8)]
  │  C6 Position Monitor (in Trade tab)
  │  │ Actions: Close, Add Margin, Set TP/SL
  │
  ├─ Tap leader in Copy Portfolio
  │  ▼ [Card scale 0.97 + shadow lift, slide transition 350ms spring(0.8)]
  │  D4 Copy Dashboard (in Traders tab)
  │  │ Actions: Pause, Adjust allocation, Stop copying
  │
  ├─ Tap [Manage in Traders →]
     ▼ [Button scale 0.95 + haptic light, transition 350ms spring(0.8)]
     Home tab → D4 Copy Dashboard
```

### 5.6 Deposit → Fund → Trade

```
[Anywhere: global header shows low balance warning]
  │ Tap "Fund Account" CTA or navigate to B1
  ▼ [Button scale 0.95 + haptic light, bottom sheet slides up 300ms spring(0.8)]
B1 Fund Hub
  │ Options: Deposit (on-chain), Fiat On-Ramp, Transfer, Simple Swap
  │ Tap chosen method
  ▼ [Tab scale 0.95 + haptic light, transition 200ms ease-in-out]
B2 Deposit / B4 Fiat On-Ramp / B6 Simple Swap
  │ Complete funding flow
  │ On success:
  ▼ [Success toast slides in from top 300ms ease-out]
Success toast + "Start Trading" or "Browse Leaders" CTA
  │ Tap CTA
  ▼ [Button scale 0.95 + haptic light, confetti burst + transition 350ms spring(0.8)]
C1 Home (default) OR Home tab (if S7)
```

### 5.7 S7 Matching Wizard — Cross-Module Entry Points & Output Feeds

The S7 Matching Wizard (wiz1-wiz5 + wizDone) can be entered from multiple surfaces, not just onboarding. Wizard output feeds downstream screens.

**Entry points:**

| Source               | Trigger                               | Entry Screen | Context                                |
| -------------------- | ------------------------------------- | ------------ | -------------------------------------- |
| Onboarding A1b       | User selects "Follow" intent          | wiz1         | First-run, no prior preferences        |
| Dashboard (C1)       | Quick action card: "Find your match"  | wiz1         | Post-onboarding, user wants to refine  |
| You tab (E1)         | Matching Profile card → "Retake quiz" | wiz1         | User wants to update preferences       |
| Traders D1 Traders tab | "Not finding the right fit?" prompt   | wiz1         | User has been browsing but not copying |

**Wizard output feeds:**

| Downstream Screen        | How Wizard Output Is Used                                                                                                            |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| D1 Discover Leaders      | Leader filtering pre-applied based on wizard answers (risk tolerance, style, asset preferences)                                      |
| D3 Copy Setup            | 4-step Briefing-First Wizard pre-filled (allocation amount from investment tier, safety limits from wizard risk profile) per Arx 9-7 |
| E1 Matching Profile card | Displays current wizard results as a profile card with "Retake quiz" option                                                          |

---

## 6. NAVIGATION STATE PRESERVATION

The app preserves scroll positions, tab selections, and navigation context to prevent disorientation.

### 6.1 Scroll Position Persistence

| Screen              | Saved Data                                              | Behavior                                                           | Duration                         |
| ------------------- | ------------------------------------------------------- | ------------------------------------------------------------------ | -------------------------------- |
| C1 Home             | Scroll offset + expanded/collapsed card states          | When returning from detail view, scroll restored to exact position | Session (cleared on app restart) |
| C2 Markets          | Scroll offset + active filter selections                | Filter state persisted; scrolling restored                         | Session                          |
| C3 Asset Detail     | Chart zoom level + selected timeframe                   | User preference restored on return                                 | Session                          |
| D1 Discover Leaders | Scroll offset + filter state (tier, style tags, region) | Filter state persisted across navigation                           | Session                          |
| R0 Home tab         | Scroll offset + active section state                    | Section expansion state preserved                                  | Session                          |
| D4 Copy Dashboard   | Scroll offset + tab selection (Overview/History)        | Tab state persisted                                                | Session                          |
| E1 Portfolio        | Scroll offset + tab selection (Trading/Copy)            | Portfolio view preference remembered                               | Session                          |

### 6.2 Tab Selection Persistence

| Tab     | Behavior                                                              | Data Persisted                    |
| ------- | --------------------------------------------------------------------- | --------------------------------- |
| Home    | Last visited C1 section (Watchlist / Quick Actions / Positions)       | Section state                     |
| Markets | Last active view: C2 (all assets) or C2-F (filtered)                  | Sort order, filters, search query |
| Traders | Last active section: R0 (home) or D1 (leaders) or D4 (copy dashboard) | Tab state                         |
| Trade   | Last screen viewed: TH (hub) or C6 (position detail)                  | Selected position (if any)        |
| You     | Last active section: E1 (portfolio) or S1 (settings) or P1 (profile)  | Section state                     |

### 6.3 TradeIntent Object Survival

When user navigates between Markets → Trade, Traders → Trade, or Lucid → Trade, the `TradeIntent` object persists:

```
TradeIntent persists across:
  ✓ Tab navigation (Home → Markets → Traders → Trade and back)
  ✓ Screen dismissals and bottom sheets
  ✓ Symbol picker navigation

TradeIntent clears when:
  ✗ User confirms order (after C5 Execution Monitor completes)
  ✗ User manually clicks [Clear] in calculator
  ✗ 10 minutes of inactivity
```

### 6.4 Symbol Context in Symbol Picker

The symbol picker (used in TH Trade Hub, D3 Copy Setup) maintains a "Recent" list:

| Behavior                  | Data                                     | Limit       |
| ------------------------- | ---------------------------------------- | ----------- |
| Recently traded symbols   | Last 10 symbols user opened positions in | 10 symbols  |
| Recently viewed symbols   | Last 10 symbols user viewed on Markets   | 10 symbols  |
| Recently searched symbols | Last 10 symbols user searched            | 10 symbols  |
| Watchlist                 | User's saved watchlist items             | 50 symbols  |
| Recency order             | Recently used first, oldest last         | Auto-sorted |

**Persistent across:** Tab navigation, screen dismissals, app backgrounds (up to 30 days).
**Cleared when:** User clears app cache or explicitly clears history.

---

## 7. GLOBAL BUTTON STYLE GUIDE & INTERACTION SPECS

Every button in the Arx app follows one of 7 type definitions. Each type has explicit tap animations, loading states, and error states.

### 7.1 Primary CTA Button

**Visual:** Full-width, 48dp height, rounded 12px, solid fill `var(--primary)` (#5B21B6), bold text, white/light text.

| State                 | Background                           | Text Color     | Shadow        | Tap Action                        | Loading State                                   | Error State                               |
| --------------------- | ------------------------------------ | -------------- | ------------- | --------------------------------- | ----------------------------------------------- | ----------------------------------------- |
| Default               | Gradient stone `#5B21B6` → `#4C1D95` | White          | Elevation 4dp | Scale 0.95 + haptic medium (50ms) | Spinner overlay 24dp centered + button disabled | Red border + error text below + retry CTA |
| Hover (if applicable) | Brighten 10%                         | White          | Elevation 6dp | —                                 | —                                               | —                                         |
| Active/Pressed        | Scale 0.95, darken 10%, haptic       | White          | Elevation 2dp | Immediate                         | Spinner appears                                 | Error appears                             |
| Disabled              | Gray `#94A3B8`                       | Gray `#64748B` | Elevation 0dp | None                              | —                                               | —                                         |

**Animation on successful async action:** Scale 0.95 (100ms) → hold 200ms → scale back 1.0 (100ms), then success confetti burst from button center (particles spray out 100-300px radius over 2s ease-out) + haptic success pattern.

**Used in:** Trade execution CTAs, Copy setup confirmation, Fund account, Deposit/Withdraw, Create order.

### 7.2 Secondary CTA Button

**Visual:** Outline style, 40dp height, rounded 8px, 2px border (primary stone), transparent background, stone text.

| State          | Border              | Background        | Text           | Tap Action                                                             | Loading State                          | Error State                       |
| -------------- | ------------------- | ----------------- | -------------- | ---------------------------------------------------------------------- | -------------------------------------- | --------------------------------- |
| Default        | Stone `#5B21B6` 2px | Transparent       | Stone          | Scale 0.95 + fill with 10% stone opacity (100ms) + haptic light (30ms) | Spinner overlay 20dp + button disabled | Red border 2px + error text below |
| Hover          | Stone brighten 10%  | 5% stone opacity  | Stone brighten | —                                                                      | —                                      | —                                 |
| Active/Pressed | Stone darken 10%    | 10% stone opacity | Stone darken   | Hold fill state                                                        | Spinner appears                        | Error state                       |
| Disabled       | Gray `#CBD5E1`      | Transparent       | Gray           | None                                                                   | —                                      | —                                 |

**Animation:** Scale 0.95 on tap (100ms), fill animates in 100ms ease-out.

**Used in:** Alternative actions, Settings changes, View more CTAs, Secondary navigation.

### 7.3 Tertiary/Text Button

**Visual:** No container, text-only with underline on tap, small font (12-14px).

| State          | Text Color        | Underline           | Tap Action                           | Feedback            |
| -------------- | ----------------- | ------------------- | ------------------------------------ | ------------------- |
| Default        | Primary stone     | None                | Scale 0.95 + underline appears 100ms | Haptic light (20ms) |
| Hover          | Stone brighten 5% | None                | —                                    | —                   |
| Active/Pressed | Stone darken 10%  | Stone underline 1px | Underline animates in 100ms ease-out | Haptic light        |
| Disabled       | Gray `#94A3B8`    | None                | None                                 | —                   |

**Used in:** "View more", "Learn more", "Skip", "Cancel", links within text.

### 7.4 Destructive Button

**Visual:** Red fill `#EF4444`, white text, rounded 12px, 48dp height.

| State          | Background      | Text  | Border | Tap Action                        | Confirmation                          | Loading                   | Error                  |
| -------------- | --------------- | ----- | ------ | --------------------------------- | ------------------------------------- | ------------------------- | ---------------------- |
| Default        | Red `#EF4444`   | White | None   | Scale 0.95 + haptic medium (50ms) | Show 200ms confirmation modal overlay | Spinner 24dp centered     | Red darken 20% + retry |
| Hover          | Red brighten 5% | White | None   | —                                 | —                                     | —                         | —                      |
| Active/Pressed | Red darken 10%  | White | None   | Hold scale 0.95                   | Confirmation appears                  | Spinner + button disabled | Error state            |
| Disabled       | Gray `#94A3B8`  | Gray  | None   | None                              | —                                     | —                         | —                      |

**Confirmation Behavior:** After tap, show modal: "Close position? This cannot be undone." with [Cancel] [Confirm] buttons. 200ms delay before final action executes.

**Used in:** Close position, Remove from watchlist, Stop copying, Disconnect wallet, Delete settings.

### 7.5 Pill/Chip Button

**Visual:** 32dp height, rounded 16px, outline or fill variant, small text (12px).

| State          | Background                             | Text           | Border    | Tap Action                                     | Selected State                     |
| -------------- | -------------------------------------- | -------------- | --------- | ---------------------------------------------- | ---------------------------------- |
| Default        | Transparent                            | Stone text     | Stone 1px | Scale 0.98 + fill toggle on/off (150ms spring) | Filled stone, white text           |
| Active/Pressed | 20% stone opacity                      | Stone          | Stone 1px | Scale 0.98 pressed, toggle animates in         | Fill animates in 150ms spring(0.9) |
| Selected       | Solid stone `var(--primary)` (#5B21B6) | White          | None      | Scale 0.98 + haptic light                      | Holds selected state               |
| Disabled       | Gray `#E2E8F0`                         | Gray `#94A3B8` | Gray 1px  | None                                           | —                                  |

**Used in:** Filters (C2 Markets), Sort options, Style tags (D1 Leaders), Copy mode toggles (D3), Order type selections (C5-NEW).

### 7.6 Icon Button

**Visual:** 44dp touch target, 24dp icon, no container (or 8% opacity background on hover).

| State          | Icon Color      | Background       | Tap Action                      | Feedback                  |
| -------------- | --------------- | ---------------- | ------------------------------- | ------------------------- |
| Default        | Teal `#14B8A6`  | Transparent      | Scale 0.9 + haptic light (20ms) | Icon shrinks to center    |
| Hover          | Teal brighten   | 5% gray opacity  | —                               | Subtle background appears |
| Active/Pressed | Teal darken 10% | 10% gray opacity | Scale 0.9 (100ms)               | Hold pressed state        |
| Disabled       | Gray `#94A3B8`  | Transparent      | None                            | —                         |

**Loading variant:** Icon becomes a 20dp spinner, no scale animation.

**Used in:** Header icons (🔍, 🔔, ●), Card actions (overflow menu ⋯), Close modals (✕), Toggle favorites (★).

### 7.7 FAB (Floating Action Button)

**Visual:** 56dp circle, shadow elevation 8dp, solid fill `var(--primary)` (#5B21B6), centered icon 24dp.

| State          | Background                           | Shadow | Tap Action                        | Ripple                                            | Feedback            |
| -------------- | ------------------------------------ | ------ | --------------------------------- | ------------------------------------------------- | ------------------- |
| Default        | Gradient stone `#5B21B6` → `#4C1D95` | 8dp    | Scale 0.9 (100ms) + ripple effect | Light ripple spreads from center (200ms ease-out) | Haptic light (30ms) |
| Hover          | Brighten 5%                          | 10dp   | —                                 | —                                                 | —                   |
| Active/Pressed | Darken 10%                           | 4dp    | Scale 0.9 held                    | Ripple executes                                   | Haptic medium       |
| Disabled       | Gray `#94A3B8`                       | 0dp    | None                              | —                                                 | —                   |

**Note:** The Copilot FAB has been replaced by embedded Lucid intelligence throughout the app. See Section 4 (THE ◆ DIAMOND SYSTEM) for details on how intelligence is now surfaced via ◆ markers and bottom sheet interactions instead of a floating button.

**Used in:** Trade creation (C1 quick action if applicable), Primary floating actions.

### 7.8 Button Interaction Summary Table

| Button Type   | Tap Scale            | Duration             | Haptic        | Loading Indicator          | Error Recovery      |
| ------------- | -------------------- | -------------------- | ------------- | -------------------------- | ------------------- |
| Primary CTA   | 0.95                 | 100ms                | Medium (50ms) | Spinner overlay + disabled | Red border + retry  |
| Secondary CTA | 0.95 + fill          | 100ms                | Light (30ms)  | Spinner overlay + disabled | Red border + retry  |
| Tertiary/Text | 0.95 + underline     | 100ms                | Light (20ms)  | None (text)                | Gray disabled state |
| Destructive   | 0.95 + confirm modal | 100ms → 200ms delay  | Medium (50ms) | Spinner on confirm         | Red darken + retry  |
| Pill/Chip     | 0.98 + fill toggle   | 150ms spring(0.9)    | Light (20ms)  | None                       | Gray disabled state |
| Icon          | 0.9                  | 100ms                | Light (20ms)  | Spinner overlay            | Gray disabled state |
| FAB           | 0.9 + ripple         | 100ms + 200ms ripple | Light (30ms)  | Spinner overlay            | Gray disabled state |

---

## 8. GLOBAL ANIMATION CATALOG

All animations in the Arx app are defined here to ensure consistency, predictability, and delight. Every transition, every interaction, every state change uses one of these defined animation types.

| Animation                        | Type                                                | Duration            | Easing                       | When Used                                                               | Wow Factor                                                                                                            | Notes                                                                              |
| -------------------------------- | --------------------------------------------------- | ------------------- | ---------------------------- | ----------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| **Screen transition**            | Shared element + fade                               | 350ms               | spring(0.8)                  | Every screen navigation (C2→C3, C3→TH, D1→D2, etc.)                     | Hero element (symbol card, leader card, position) morphs between screens while content fades                          | Most critical animation for perceived speed; spring ease makes it feel intentional |
| **Tab switch**                   | Cross-fade + slide                                  | 200ms               | ease-in-out                  | Tab bar tap, new content loads                                          | Content cross-fades while sliding in direction of tab motion (left tab = slide right, right tab = slide left)         | Reinforces left-right spatial model                                                |
| **Card press**                   | Scale 0.97 + shadow lift                            | 150ms               | spring(0.85)                 | Any card tap (position card, leader card, asset card)                   | Card compresses into screen then springs back slightly as destination loads                                           | Haptic light feedback makes it tactile                                             |
| **Button press**                 | Scale 0.95 + color darken 10% + haptic              | 100ms               | ease-out                     | Any button tap (CTA, secondary, icon, FAB)                              | Crisp, immediate tactile feel; pressing into screen                                                                   | Haptic medium on primary CTAs, light on secondary                                  |
| **Success celebration**          | Confetti burst + haptic pattern                     | 2000ms              | ease-out                     | Trade filled, copy activated, deposit confirmed, milestone unlocked     | Particle effects spray from CTA button, expand outward 100-300px over 2s; haptic success pattern (light-medium-light) | Celebrate user wins; creates emotional resonance                                   |
| **Error shake**                  | Horizontal shake 3x ±4px                            | 300ms               | ease-in-out                  | Validation error, failed action, margin call                            | Whole card or input shakes side-to-side 3 times; haptic error pattern (3 rapid taps)                                  | Attention-grabbing but not alarming                                                |
| **Pull-to-refresh**              | Spring overscroll + spinner                         | —                   | spring(1.2)                  | Any scrollable screen (C1, C2, D1, R0)                                  | Overscroll bounces with branded spinner appearing; on release, spinner animates while data loads                      | Satisfying physics; signals refresh in progress                                    |
| **List item enter**              | Fade-in + slide-up 20px, staggered 50ms             | 300ms per item      | ease-out                     | Any list load (C2 assets, D1 leaders, D4 positions, E1 portfolio)       | Items cascade-reveal: each item fades in + slides up 20px, each offset 50ms from previous                             | Creates sense of content flowing in; cascading effect is delightful                |
| **Number counter**               | Rolling digits from old→new value                   | 300ms               | ease-in-out                  | Any real-time value change (PnL, equity, copy earnings, safety gauge %) | Digits roll smoothly from old value to new (like slot-machine digits); numeric display feels alive                    | Most noticeable on PnL and equity header updates                                   |
| **Equity curve draw**            | SVG path progressive reveal L→R                     | 800ms               | ease-out                     | Home (C1), Portfolio (E1) on load                                       | Line chart draws itself left-to-right like handwriting being drawn in real-time                                       | Premium feel; suggests careful, thoughtful design                                  |
| **Safety gauge fill**            | Radial sweep from 0→value                           | 500ms               | spring(0.7)                  | Position cards (C6), Calculator (C5-NEW), Copy setup (D3)               | Circular safety gauge fills from 0% clockwise to current value with slight spring bounce at end                       | Gauge "fills up" with confidence; spring bounce shows arriving at target           |
| **Regime bar transition**        | Color crossfade + pulse                             | 400ms               | ease-in-out                  | Regime state change (Trending→Range-bound, etc.)                        | Background color fades to new regime color; bar pulses (scale 1.0→1.02→1.0) to attract attention                      | Most important context indicator changes get attention                             |
| **Bottom sheet open**            | Slide up + backdrop blur 16px                       | 300ms               | spring(0.8)                  | Any bottom sheet (regime detail, filters, copy setup, confirmation)     | Sheet slides up from bottom; backdrop blurs and dims to 70% opacity simultaneously                                    | Backdrop blur is cinematic and modern                                              |
| **Toast notification**           | Slide in from top + auto-dismiss                    | 300ms in, 300ms out | ease-out (in), ease-in (out) | Success/error/warning/info messages                                     | Toast slides in from top below regime bar; at dismiss time, slides back up out of view                                | Consistent messaging interface                                                     |
| **◆ marker pulse**               | Scale 1.0→1.1→1.0                                   | 600ms               | spring(0.5)                  | When data updates behind a ◆ marker                                     | Diamond gently expands and contracts to signal fresh insight available                                                | Non-intrusive but noticeable; invites user to tap for more                         |
| **Bottom sheet spring-up**       | Slide up from bottom                                | 350ms               | spring(0.8)                  | Lucid Q&A sheet, contextual detail views                                | Sheet glides up smoothly with natural deceleration                                                                    | Feels responsive and intentional                                                   |
| **Contextual insertion appear**  | Height 0→auto with content fade-in                  | 300ms               | spring(0.7)                  | When Lucid inserts inline intelligence                                  | New data appears with content fading in simultaneously; height expands naturally                                      | Organic feel; doesn't interrupt reading flow                                       |
| **Contextual insertion dismiss** | Height auto→0                                       | 200ms               | ease-in                      | When user dismisses inline insight                                      | Content fades as height collapses; clean removal                                                                      | Quick, satisfying removal                                                          |
| **Proactive banner slide**       | Slide down from top                                 | 250ms               | spring(0.7)                  | Regime change notification, leader trade alert                          | Banner slides down from very top, pushes content below; auto-dismisses after 4s or user taps                          | Captures attention without interrupting                                            |
| **Swipe-to-execute**             | Thumb tracks along rail + fills green               | —                   | linear track                 | Trade confirmation (swipe to confirm order)                             | User's thumb position maps to progress bar fill (0→100%); at >90%, action triggers                                    | Physical, satisfying gesture; commit-requiring interaction                         |
| **Liquidation distance bar**     | Width transition + color zone change                | 300ms               | ease-out                     | Calculator (C5-NEW) input change, Position monitor (C6) real-time       | Bar smoothly resizes as margin % changes; color zones (green→yellow→red) crossfade                                    | Visualizes safety margin in real-time                                              |
| **Sparkline draw**               | Mini SVG path draw                                  | 400ms               | ease-out                     | Watchlist cards (C1), Leader cards (D1, D2), Price cards (C2)           | Small price chart sparklines draw themselves left-to-right                                                            | Micro-interaction adds polish; shows price trend emerging                          |
| **Badge count update**           | Scale bounce 1.0→1.2→1.0                            | 200ms               | spring(0.9)                  | New notification/signal/message                                         | Badge number bounces: scales to 1.2x then back to 1.0; happens once per update                                        | Draws attention to new info without being annoying                                 |
| **Milestone unlock**             | Gold shimmer + expand + confetti                    | 1500ms              | custom bezier                | Rewards unlocked, trading goals achieved, tier promotions               | Full-screen overlay with expanding gold shimmer effect + confetti burst + haptic celebration pattern                  | Premium moment; memorable achievement                                              |
| **Circuit breaker trigger**      | Red pulse + screen dim 20% + haptic warning pattern | 600ms               | ease-in-out                  | Portfolio floor breached, liquidation imminent                          | Screen dims 20% opacity red overlay, pulses (opacity 20%→40%→20%) 3x; haptic warning pattern (medium-light-medium)    | Dramatic but not alarming; unmissable warning                                      |

**Global Notes:**

- All transitions use spring easing by default for natural motion. Linear easing reserved for progress indicators.
- Haptic feedback pairs with visual feedback: haptic fires at animation start (100-200ms mark) for synchronization.
- All animations respect system motion settings (reduced motion in Accessibility settings disables spring easing, uses instant transitions).

---

## 9. SHARED FRAMEWORKS

These frameworks are used across multiple module files. Defined once here, referenced by name in screen specs.

### 9.1 Wallet Classification Framework

Every wallet with 30+ closed trades is classified into exactly one of 6 types. Classification is PROTECTIVE — it blocks or warns against following unreliable wallets.

| #   | Type              | User Label         | Badge    | Can Follow?                              | Stage |
| --- | ----------------- | ------------------ | -------- | ---------------------------------------- | ----- |
| 1   | Genuinely Skilled | All-Weather Trader | 🛡️ Gold  | Full Sizing Guide                        | 2     |
| 2   | Lucky Trend Rider | Unproven           | 🍀 Gray  | Blocked: "No clear edge detected"        | 1     |
| 3   | Smokescreen       | Unverified         | ❓ Red   | Blocked: "Signal unreliable"             | 1     |
| 4   | Specialist        | Specialist         | 🎯 Blue  | Conditional (auto-pauses in weak regime) | 2     |
| 5   | Fading Edge       | Cooling Down       | 📉 Amber | Sizing reduced 50%                       | 2     |
| 6   | Bot/Market Maker  | Non-Copyable       | 🤖 Gray  | Blocked: "Can't replicate"               | 1     |

**Classification Priority (first match wins):** Type 6 → Type 3 → Type 2 → Type 5 → Type 1 → Type 4

**Badge display rules:**

- Types 2/3/6: [Copy] button DISABLED (🔒). Tap shows explanation bottom sheet.
- Type 5: [Copy] ENABLED with amber warning: "Edge declining — sizing reduced 50%"
- Type 4: [Copy] ENABLED with blue info: "Specialist — auto-pauses when conditions shift"
- Type 1: [Copy] fully enabled, gold accent.
- Under 30 trades: ⏳ "Evaluating" — can watch but not copy.

**Detection logic:** See `Arx_4-1-1-7_Mobile_Data_Object_Model.md` for full calculation specs (Kelly fraction, Wilson score, RIS scoring).

### 9.2 Leader Tier System (v2.2)

Tiers create scarcity and trust signals for copy trading.

| Tier     | Badge | Follower Cap | Criteria                                                                 |
| -------- | ----- | ------------ | ------------------------------------------------------------------------ |
| Verified | 🟢    | 100 copiers  | Classification Type 1 or 4, 100+ trades, 90d+ history                    |
| Proven   | 🟡    | 300 copiers  | Verified + positive RIS + copier profit > 0                              |
| Elite    | ⭐    | 500 copiers  | Proven + 6-month history + max drawdown < 20% + copier profit in top 10% |

**Display format on leader cards:** `Elite ⭐ (423/500)` — shows capacity utilization creating FOMO.

### 9.3 Trading Style Tags (v2.2)

8 algorithmically derived behavioral tags applied to leaders:

| Tag          | Derivation                                            | Used In        |
| ------------ | ----------------------------------------------------- | -------------- |
| Conservative | Average leverage < 3x, max drawdown < 15%             | D1, D2, D3, R0 |
| Aggressive   | Average leverage > 10x or max drawdown > 30%          | D1, D2, D3, R0 |
| Short-term   | Average holding period < 4 hours                      | D1, D2         |
| Long-term    | Average holding period > 24 hours                     | D1, D2         |
| BTC-focused  | > 70% of trades in BTC                                | D1, D2         |
| Multi-coin   | Trades 5+ distinct assets regularly                   | D1, D2         |
| Rising star  | Account < 90 days, metrics improving month-over-month | D1             |
| Newcomer     | Account < 30 days                                     | D1             |

**Display:** Horizontal scroll pills below leader name. Max 3 visible, +N for overflow.

### 9.4 Copy Mode Architecture (v2.2)

2 modes × 3 timing variants = 6 possible copy configurations.

**Allocation Modes:**
| Mode | How It Works | Max Leaders | Best For |
|---|---|---|---|
| Proportional Copy | Separate fund pool per leader. Mirrors position proportions relative to leader's account. | 10 | S7 who want true portfolio mirroring |
| Fixed-Amount Copy | Shared pool. Each copied trade uses a fixed dollar amount regardless of leader's position size. | 20+ | S7 who want simple, predictable allocation |

**Timing Modes:**
| Mode | Behavior | Latency |
|---|---|---|
| Full Mirror | Copy every trade immediately | < 1 second |
| Delayed | Copy with user-configurable delay (5s, 30s, 2min) for review | User-set |
| Tracking | Notify only — user manually confirms each copy | Manual |

### 9.5 Three-Gate Follow Decision Framework

Before ANY copy action, the system evaluates the wallet through three gates:

```
PRE-QUALIFICATION (Stage 1):
  IF Type 6 (Bot) → BLOCK
  IF Type 3 (Smokescreen) → BLOCK
  IF Type 2 (Lucky) → BLOCK
  ELSE → proceed to gates

GATE 1 — Regime Awareness: RIS > 0 (navigated past transitions successfully)
GATE 2 — Current Relevance: regime_kelly[current_regime] > 0 (edge applies NOW)
GATE 3 — Edge Freshness: kelly_30d >= kelly_90d × 0.50 (not declining)

ALL PASS → "All-Weather Trader" — Copy with full sizing
GATE 1 FAIL → "Unproven" — Don't copy
GATE 2 FAIL → "Specialist — paused" — Wait for matching conditions
GATE 3 FAIL → "Cooling Down" — Copy with 50% reduced sizing
```

**Full calculation specs:** See `Arx_4-1-1-7_Mobile_Data_Object_Model.md` for RIS scoring, Kelly computation, Wilson confidence intervals.

### 9.6 Sizing Guide Framework

Instead of arbitrary risk percentages, the system RECOMMENDS mathematically optimal position sizes based on track record, regime, risk preference, and confidence.

**Pipeline:** Wallet Kelly → Confidence Tier (Wilson) → Regime-Conditional Kelly → Risk Preference Multiplier → Confidence Discount → Hard Cap (25%) → Dollar Amount.

**User-facing terms:** Always "Sizing Guide" or "Recommended Size" — the word "Kelly" NEVER appears in UI.

**Display context:** Used in C5-NEW Calculator (self-directed), D3 Copy Setup (copy trades), D2 Wallet Profile (evaluation).

**Full calculation:** See `Arx_4-1-1-7_Mobile_Data_Object_Model.md`.

### 9.7 Watchlist Architecture

**Dual watchlists:**

| Watchlist        | What               | Limit | Add From                                    | Display                                                |
| ---------------- | ------------------ | ----- | ------------------------------------------- | ------------------------------------------------------ |
| Symbol Watchlist | Assets to track    | 50    | C3 star, C2 long-press, Search, Lucid       | Price, 24h %, sparkline, funding rate, signal count    |
| Wallet Watchlist | Leaders to monitor | 100   | D2 Watch button, D1 quick-watch, Home Feed | Handle, badge, 24h PnL, positions count, latest thesis |

**Where they appear:** C1 Home (Your Watchlist card + Wallet Pulse), C2 Markets (filter chip), C3 (star icon), D1 (filter), D5 Feed (filter), G1 Lucid (queryable).

### 9.8 Instrument Type Framework

Arx supports five instrument types. All share the same navigation architecture but each screen adapts content. See `4-1-1-2 C3` for full per-type specifications.

| Type               | Symbol Format      | Examples                        | Underlying         | Key Data                                                     |
| ------------------ | ------------------ | ------------------------------- | ------------------ | ------------------------------------------------------------ |
| **Crypto Perp**    | `{ASSET}-PERP`     | `SOL-PERP`, `BTC-PERP`          | Cryptocurrency     | Funding rate, Open Interest, liquidation map, leverage, 24/7 |
| **Crypto Spot**    | `{ASSET}/USDT`     | `SOL/USDT`, `BTC/USDT`          | Cryptocurrency     | On-chain metrics, staking yield, tokenomics, no leverage     |
| **US Stock Perp**  | `{TICKER}.US-PERP` | `AAPL.US-PERP`, `NVDA.US-PERP`  | US equity          | Market hours, earnings, P/E, sector correlation, funding     |
| **Commodity Perp** | `{ASSET}.CMD-PERP` | `GOLD.CMD-PERP`, `OIL.CMD-PERP` | Physical commodity | Macro (DXY, rates), supply/demand, COT, seasonal, funding    |
| **Commodity Spot** | `{ASSET}.CMD/USD`  | `GOLD.CMD/USD`                  | Physical commodity | Reference pricing, portfolio hedge, no leverage              |

**Screen Adaptation by Instrument Type:**

| Screen                | Crypto Perp                                                                                                                                                                                                | Crypto Spot                                                                                                                              | US Stock Perp                                           | Commodity Perp                                               | Commodity Spot                   |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------ | -------------------------------- |
| **C1 Home**           | Positions: leverage, safety gauge, funding                                                                                                                                                                 | Holdings: quantity, value, PnL                                                                                                           | Positions + session badge + earnings countdown          | Positions + session badge + macro context                    | Holdings: value, PnL             |
| **C2 Markets**        | Funding rate, Open Interest, Open Interest change                                                                                                                                                          | Market cap, volume, staking yield                                                                                                        | Funding rate, Open Interest, session status, sector tag | Funding rate, Open Interest, session status, DXY correlation | Volume, 24h %, market cap        |
| **C3 Asset Detail**   | Liquidation Map, Wallets, Funding, Open Interest tabs                                                                                                                                                      | On-Chain, Fundamentals, Staking tabs                                                                                                     | Fundamentals, Earnings tabs + session badge             | Macro, Supply/Demand tabs + session badge                    | Macro (condensed), no order book |
| **C5-NEW Calculator** | 5-step flow: regime bar, direction, leverage, risk % pills [1%][2%][5%], reframed questions, enhanced exit plan (TP/SL with removal friction dialog), enhanced summary (position size units + liquidation) | Redesigned: portfolio % pills, Market Info card, More options expandable (Order Type, Sell Target, Price Alert, DCA), BUY/SELL direction | Same as crypto perp + session liquidity warning         | Same as crypto perp + session liquidity warning              | Amount → Buy (no leverage)       |
| **C6 Position**       | Leverage, safety gauge, funding, liquidation distance                                                                                                                                                      | Value, PnL, staking yield                                                                                                                | + session badge, earnings proximity warning             | + session badge, macro event proximity                       | Value, PnL                       |
| **E1 Portfolio**      | Perps Positions section                                                                                                                                                                                    | Spot Holdings section                                                                                                                    | Perps Positions + earnings calendar                     | Perps Positions + macro calendar                             | Spot Holdings section            |

**Quick Ticker Switch (all instrument types):**
Tap the ticker name text on any screen (C3, TH, C5-NEW, C6) → opens full-screen Quick Ticker Search overlay with auto-focus search, recent pills (last 5), watchlist rows with live data, and hot tickers. Tap any result → the current screen updates **in-place** without navigation push. See `4-1-1-2 C3 Quick Ticker Switch` for full specification.

**Margin Types (Perps Only — Crypto, US Stock, Commodity):**

- **Isolated** (default): Each position has own margin. Liquidation affects only this position.
- **Cross** (Level 2+): All positions share margin pool. Requires explicit acknowledgment.

**Order Types:** Market, Limit, Stop-Market, Stop-Limit, Trailing Stop (perps only), Take-Profit.

**Market Hours (US Stock + Commodity Perps):**

- Perps trade 24/7 on Hyperliquid regardless of underlying market hours
- During closed hours: spreads widen, liquidity reduces, gap risk increases
- Session badge always visible on C3 header and C6 position monitor
- ◆ Lucid proactively warns about session-dependent behavior

### 9.9 Portfolio Circuit Breaker (v2.2)

Account-level equity floor that stops ALL copy trading if total drawdown exceeds threshold.

| Parameter | Default                                                         | Range             | Unit                               |
| --------- | --------------------------------------------------------------- | ----------------- | ---------------------------------- |
| Floor     | 70%                                                             | 50%-90%           | % of initial copy portfolio equity |
| Trigger   | Equity drops below floor                                        | Checked every 30s | Automatic                          |
| Action    | Pause all copy trades, close no existing positions, notify user | Immediate         | System                             |
| Reset     | Manual re-enable after user reviews portfolio                   | Requires tap      | User action                        |

**Display:** Portfolio Health Bar on D4 Copy Dashboard — visual gauge showing equity vs. circuit breaker threshold.

---

## 10. NOTIFICATION ARCHITECTURE

### Notification Types

| Category     | Examples                                                          | Default             | Delivery      |
| ------------ | ----------------------------------------------------------------- | ------------------- | ------------- |
| **Trade**    | Position opened, filled, closed, liquidation warning, margin call | On                  | Push + In-App |
| **Copy**     | Leader opened/closed position, copy executed, leader paused       | On                  | Push + In-App |
| **Earnings** | Daily earnings summary (9 AM), weekly digest, milestone reached   | On (S7)             | Push          |
| **Signals**  | Price alert triggered, regime change, Lucid proactive suggestion  | On (S2)             | Push + In-App |
| **System**   | Deposit confirmed, withdrawal processed, security alert           | On (cannot disable) | Push + In-App |
| **Social**   | New follower on your profile, leader you watch published thesis   | Off                 | In-App only   |

### Notification Center (NC1) — see 4-1-1-5 for screen spec.

---

## 11. DEEP LINK SCHEMA

Every screen is deep-linkable for push notifications, sharing, and Lucid actions.

| Pattern                                        | Example                              | Destination                  |
| ---------------------------------------------- | ------------------------------------ | ---------------------------- |
| `arx://home`                                   | —                                    | C1 Home                      |
| `arx://markets/{symbol}`                       | `arx://markets/BTC-USD`              | C3 Asset Detail              |
| `arx://trade/{symbol}?direction={long\|short}` | `arx://trade/BTC-USD?direction=long` | C5-NEW Calculator pre-filled |
| `arx://radar/leaders/{address}`                | `arx://radar/leaders/0x...`          | D2 Wallet Profile            |
| `arx://radar/copy/{address}`                   | `arx://radar/copy/0x...`             | D3 Copy Setup                |
| `arx://radar/strategy/{id}`                    | `arx://radar/strategy/trend-01`      | R-AI2 Strategy Detail        |
| `arx://portfolio`                              | —                                    | E1 Portfolio                 |
| `arx://settings`                               | —                                    | S1 Settings                  |
| `arx://lucid?prompt={text}`                    | `arx://lucid?prompt=analyze+BTC`     | G1 with pre-filled prompt    |

---

## 12. NAMING CONVENTIONS & TERMINOLOGY

| Internal Term      | User-Facing Term                | Never Say                          |
| ------------------ | ------------------------------- | ---------------------------------- |
| Kelly fraction     | Sizing Guide / Recommended Size | "Kelly"                            |
| RIS                | Regime Navigation (★ rating)    | "RIS", "Regime Intelligence Score" |
| Alpha Feed         | Home Feed                      | "Alpha"                            |
| Maintenance margin | Safety cushion                  | "Maintenance margin ratio"         |
| Liquidation price  | Safety boundary                 | —                                  |
| Copy trading       | Copy / Follow                   | "Social trading"                   |
| Circuit breaker    | Protection floor                | —                                  |
| Copilot / AI       | Lucid Intelligence              | "AI", "Copilot", "Assistant"       |

---

## 13. SCREEN LAYOUT TEMPLATE

Every post-auth screen follows this structure:

```
┌──────────────────────────────────────────────────────────────┐
│ ● $12,450 +$28 today ↑2.3% [🟢 Trending]   🔍  🔔(3)  │  ← Global Header (3.1)
├──────────────────────────────────────────────────────────────┤
│ ████████████████ TRENDING ↑ (72%) ████████████  ℹ │  ← Regime Bar (3.2)
├──────────────────────────────────────────────────┤
│                                                  │
│  [Screen-specific content area]                  │
│  Scrollable. Full width minus 16dp side margins. │
│  Content uses 4-column grid (375px viewport).    │
│  May include ◆ markers for Lucid intelligence    │
│                                                  │
├──────────────────────────────────────────────────┤
│  [Lucid Bottom Sheet (optional, contextual)]     │  ← Opens on ◆ tap
├──────────┬──────────┬──────────┬──────────┬──────┤
│  Home    │ Markets  │ Traders  │  Trade   │  You │  ← Tab Bar (3.3)
└──────────┴──────────┴──────────┴──────────┴──────┘

Total height: Status bar + Header (44dp) + Regime Bar (32dp) + Content + Tab Bar (49dp + safe)
Usable content height: ~600dp on iPhone 14 (844dp screen)
Side margins: 16dp each side → usable width: 343dp
Grid: 4 columns, 12dp gutters
```

---

## 14. PROTOTYPE IMPLEMENTATION STATUS

> **Prototype URL:** https://deploy-five-peach.vercel.app
> **Tech:** Arx_Mobile_WebApp_v1.0 — single-file HTML/CSS/JS (deploy/index.html). Desktop: iPhone 15 Pro frame (393x852). Mobile (`@media max-width:430px`): fills `100dvh`, browser history navigation (back/forward/swipe). Citadel & Moat design tokens.
> **Last deployed:** 2026-03-15

### Implementation Coverage by Module

| Module           | Screen              | Status          | Notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ---------------- | ------------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Home (C1)**    | Dashboard           | ✅ Updated v8.0 | Journey-state adaptive (S7_NEW/S7_ACTIVE/S2_NEW/S2_ACTIVE). Equity header with Glass Level 2, canvas equity curve, period selector, expandable Perps/Spot/Copy breakdown. Lucid Moments carousel (3 cards). Quick actions: [⚡ Quick Trade][💰 Fund][👥 Top Traders][📡 Signals][🔍 Explore]. Regime context card, watchlist with sparklines, activity feed (4 items), positions with safety gauges, copy portfolio (S7), unfunded hero card (NEW states).                            |
| **Home (C1)**    | Quick Actions       | ✅ Updated v8.0 | Universal 5-pill card-style set with emoji icons. All functional navigation.                                                                                                                                                                                                                                                                                                                                                                                                          |
| **Home (C1)**    | Lucid Moments       | ✅ New v8.0     | Full-width swipeable carousel with scroll-snap. Morning Brief, Position Review, Opportunity cards with [◆ Ask a follow-up] buttons.                                                                                                                                                                                                                                                                                                                                                   |
| **Home (C1)**    | Copy Portfolio      | ✅ New v8.0     | S7 only. 3 leaders with tier badges, allocation, daily P&L, per-leader circuit breaker. Account-level circuit breaker bar.                                                                                                                                                                                                                                                                                                                                                            |
| **Traders (R0)** | Feed                | ✅ Updated v8.0 | Per-tab onboarding card (dismissible), bookmarkable object filter row, per-tab instrument filter [All/Perps/Spot], My Copies snapshot with [Manage →], content filter chips, 8 feed items (3 card types).                                                                                                                                                                                                                                                                             |
| **Traders (D1)** | Traders             | ✅ Updated v8.0 | Per-tab onboarding, Lucid Find input, Style Wizard, Copying/Following sections with `showMyTradersSheet()`, Copier Median Return hero metric, 6 leader cards with bookmark ☆/★, alpha decay, LucidTooltip.                                                                                                                                                                                                                                                                            |
| **Traders (M)**  | Market              | ✅ Updated v8.0 | Per-tab onboarding, HyperTracker gateway ("The Market Right Now" narrative), Market Temperature, Asset Signal Map, Liquidation Clusters, Position Concentration, Coming Up calendar, Your Traders.                                                                                                                                                                                                                                                                                    |
| **Traders (D2)** | Leader Detail       | ✅ Updated v8.0 | 3-tab view: Stats (Copier Median Return hero, regime performance, capacity, alpha decay, Lucid insight), Evidence Check (6 trust checks), Positions (Safety Margin PRIMARY, Trade Myself/Copy This). Bookmark ☆/★.                                                                                                                                                                                                                                                                    |
| **Trade**        | Trade Hub           | ✅ Updated v6.5 | Hub mode with instrument cards + Trade Ticket. Perps: 5-step flow with regime bar, risk % pills [1%][2%][5%], reframed questions, enhanced exit plan with TP/SL removal friction dialog (risk warning, Keep/Remove), enhanced summary with position size units + liquidation. Spot: redesigned with portfolio % pills, Market Info card, More options expandable (Order Type, Sell Target, Price Alert, DCA). S2/S7 detection via `detectTradeStyle()`, regime gate, cool-down timer. |
| **Markets (C2)** | Overview            | ✅ Implemented  | Sub-tabs (Overview/Watchlist/Crypto/Forex/Commodities/Indices), per-tab instrument filter, top movers grid, asset list with regime badges.                                                                                                                                                                                                                                                                                                                                            |
| **Markets (C3)** | Asset Detail        | ✅ Implemented  | Full-page navPush, chart placeholder, timeframe pills, detail tabs, Open Interest & Liquidation heatmap, Wallet Cohort Breakdown, Traders in Asset, bookmark ☆/★.                                                                                                                                                                                                                                                                                                                     |
| **You**          | Portfolio           | ✅ Implemented  | Equity curve, margin usage, period selector, Trading/Copying/Behavioral sub-tabs, position list, spot holdings, copy portfolio, trade history (20 trades), Lucid insights.                                                                                                                                                                                                                                                                                                            |
| **You**          | Behavioral          | ✅ Implemented  | Win rate chart, P&L chart, regime performance, habit score, trading patterns.                                                                                                                                                                                                                                                                                                                                                                                                         |
| **You**          | Profile             | ✅ Implemented  | User stats, process score, wallet classification, trading style.                                                                                                                                                                                                                                                                                                                                                                                                                      |
| **You**          | Rewards             | ✅ Implemented  | Points, tier progress, achievements, leaderboard.                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **You**          | Settings            | ✅ Implemented  | Theme toggle, notifications, security, default trading prefs.                                                                                                                                                                                                                                                                                                                                                                                                                         |
| **You**          | Assets              | ✅ Implemented  | Spot holdings (BTC 0.0042 · $285.15, SOL 2.1 · $365.82), total $650.                                                                                                                                                                                                                                                                                                                                                                                                                  |
| **Global**       | Tab Bar             | ✅ Implemented  | Home→Traders→Trade→Markets→You, Trade elevated with stone underline (gradient removed).                                                                                                                                                                                                                                                                                                                                                                                                 |
| **Global**       | Header              | ✅ Implemented  | Equity ticker, search, notifications, Lucid diamond ◆.                                                                                                                                                                                                                                                                                                                                                                                                                                |
| **Global**       | Search              | ✅ Implemented  | Full overlay with instrument + leader results.                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| **Global**       | Notifications       | ✅ Implemented  | Date-grouped items, filter pills (All/Trades/Signals/System), read/unread states.                                                                                                                                                                                                                                                                                                                                                                                                     |
| **Global**       | navPush/navPop      | ✅ Implemented  | Full-page detail views with back button, slide transition.                                                                                                                                                                                                                                                                                                                                                                                                                            |
| **Global**       | Lucid Drawer        | ✅ New v8.0     | `showLucidDrawer(question)` — bottom sheet with prepopulated question, thinking animation, mock response.                                                                                                                                                                                                                                                                                                                                                                             |
| **Global**       | Theme Toggle        | ✅ Implemented  | Light/dark mode with `[data-theme="light"]` CSS overrides.                                                                                                                                                                                                                                                                                                                                                                                                                            |
| **Global**       | Splash Screen       | ✅ Implemented  | Logo particles, merge animation, "See further." slogan, auto-dismiss.                                                                                                                                                                                                                                                                                                                                                                                                                 |
| **Global**       | Onboarding          | ✅ Updated v6.3 | 6-screen flow (A0 login → A1 experience → A1b intent → A2/A2s7 assets → A3 fund), segment selection (S2/S7), progress bar. A0 WalletConnect opens wallet selection modal (4 wallets) with connecting/success states. A4 Fund screen with 3 interactive sub-flows: MoonPay (4 steps), Transak (3 steps), Deposit (QR+address). All skip buttons standardized to "Skip — explore first".                                                                                                |
| **Global**       | Bottom Sheets       | ✅ Implemented  | `showSheet()`/`hideSheet()` with overlay, used throughout app.                                                                                                                                                                                                                                                                                                                                                                                                                        |
| **Global**       | Lucid Sheet         | ✅ New v8.0     | `showLucidSheet(html)` — Lucid-branded bottom sheet with dark teal gradient background, cyan top border. Used by `showLucidDrawer()`, `showLucid()`, `showLucidWeightPanel()`.                                                                                                                                                                                                                                                                                                        |
| **Global**       | Lucid Card          | ✅ New v8.0     | `lucidCard(text, ctaLabel, ctaQuestion, context)` — Unified insight card with ◆ header, context label, CTA button. Replaces legacy `lucidBlock()`. See Arx_6-1.                                                                                                                                                                                                                                                                                                                       |
| **Global**       | Value Props Overlay | ✅ New v8.0     | `showValueProps()` / `dismissValueProps()` — Post-onboarding 4-card swipeable overlay, one-time via `state.showedValueProps`.                                                                                                                                                                                                                                                                                                                                                         |
| **Global**       | Bookmarks           | ✅ New v8.0     | Universal `toggleBookmark(type, item)` for tickers + traders.                                                                                                                                                                                                                                                                                                                                                                                                                         |
| **Global**       | Stagger Entrance    | ✅ New v8.0     | `.anim-item` sequential fade-in animation on tab/sub-tab switch.                                                                                                                                                                                                                                                                                                                                                                                                                      |

### Not Yet Prototyped (Spec Only)

| Screen                    | Spec Location | Notes                                                                                                                                                                                                                                              |
| ------------------------- | ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| D3-D6 Traders drill-downs | 4-1-1-4       | D3 Copy Setup: 4-step Briefing-First Wizard per Arx 9-7 (Gate Check → Briefing Card → How Much → Safety Limits → Confirm & Start), Customize Protections sheet, Capacity Full sheet. D4 copy dashboard, performance attribution, market drill-down |
| Trade Advanced mode       | 4-1-1-3       | Multi-leg, conditional orders, strategy builder. (Note: basic perps and spot flows now redesigned per Trade Parameter Redesign — advanced mode remains spec-only.)                                                                                 |
| C3 Lucid View / Technical | 4-1-1-2       | v8.0 synthesis layer, TradingView annotations, Technical tab                                                                                                                                                                                       |
| C3 Spot variant           | 4-1-1-2       | Spot-specific tabs (On-Chain, Holders, Fundamentals)                                                                                                                                                                                               |
| Copy Management (D4)      | 4-1-1-4       | Active copy monitoring, graduation flow (Copy → Trade Myself)                                                                                                                                                                                      |
| W1 Assets & Wallet        | 4-1-1-5       | Multi-pool balance view, deposit/withdraw/transfer                                                                                                                                                                                                 |
| TH1 Trade History detail  | 4-1-1-5       | Filterable trade log with regime context, export                                                                                                                                                                                                   |
| OH1 Order History         | 4-1-1-5       | Open + historical orders                                                                                                                                                                                                                           |
| TX1 Transaction History   | 4-1-1-5       | Non-trade financial movements                                                                                                                                                                                                                      |
| TAX1 P&L & Tax            | 4-1-1-5       | Period P&L, per-asset breakdown, export                                                                                                                                                                                                            |
| HC1 Help Center           | 4-1-1-5       | Help articles, Lucid examples                                                                                                                                                                                                                      |
| SEC1 Security             | 4-1-1-5       | 2FA, session management                                                                                                                                                                                                                            |
| KYC1 Verification         | 4-1-1-5       | Identity verification flow                                                                                                                                                                                                                         |

### Key Functions (Prototype JS)

| Function                                          | Purpose                                                                                                                                                                                                                                                                                                    |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `buildHome()`                                     | Renders Home C1 with journey-state adaptation                                                                                                                                                                                                                                                              |
| `buildHomePositions()`                            | Helper: renders position cards for Home                                                                                                                                                                                                                                                                    |
| `buildHomeActivity()`                             | Helper: renders Feed section (renamed from "Activity" v9.1) for Home                                                                                                                                                                                                                                       |
| `switchEquityMode(mode)`                          | Toggles equity chart between Line (cumulative curve + pulse animation) and Bar (daily P&L deltas). Updates SVG icon in toggle button                                                                                                                                                                       |
| `drawEquity(canvasId, w, h, period)`              | Renders equity chart on canvas. Supports `state.equityChartMode` = 'line' (bezier curve with electricity pulse RAF animation) or 'bar' (daily P&L bars green/red)                                                                                                                                          |
| `buildMarkets()`                                  | Renders Markets C2 list                                                                                                                                                                                                                                                                                    |
| `buildTrade()`                                    | Renders Trade tab (hub + ticket mode). Perps section enhanced per Trade Parameter Redesign: regime bar, risk % pills [1%][2%][5%], reframed questions, enhanced exit plan with TP/SL friction, enhanced summary with position size units + liquidation. Routes to `buildSpotTrade()` for spot instruments. |
| `buildTradeHub(s, sym, inst)`                     | Renders Trade Hub with instrument cards                                                                                                                                                                                                                                                                    |
| `buildTraders()`                                    | Renders Traders container with sub-tab navigation                                                                                                                                                                                                                                                            |
| `setTradersTab(tab)`                                | Switches Traders sub-tab with stagger entrance                                                                                                                                                                                                                                                               |
| `buildYou()`                                      | Renders You tab container                                                                                                                                                                                                                                                                                  |
| `buildYouPortfolio()`                             | You > Portfolio sub-tab                                                                                                                                                                                                                                                                                    |
| `buildYouAssets()`                                | You > Assets sub-tab (spot holdings)                                                                                                                                                                                                                                                                       |
| `buildYouBehavioral()`                            | You > Behavioral sub-tab                                                                                                                                                                                                                                                                                   |
| `buildYouProfile()`                               | You > Profile sub-tab                                                                                                                                                                                                                                                                                      |
| `buildYouRewards()`                               | You > Rewards sub-tab                                                                                                                                                                                                                                                                                      |
| `buildYouSettings()`                              | You > Settings sub-tab                                                                                                                                                                                                                                                                                     |
| `showLeaderDetail(handle)`                        | D2 leader detail (navPush)                                                                                                                                                                                                                                                                                 |
| `showAssetDetail(sym)`                            | C3 asset detail (navPush) — v9.3: Lucid Synthesis Card + 5-tab system (Flow/Signal/Fundmntls/Risk/Traders). See `Arx_4-1-1-2d`.                                                                                                                                                                            |
| `showPositionMonitor(id)`                         | C6 position monitor (navPush)                                                                                                                                                                                                                                                                              |
| `showLucidDrawer(question)`                       | Lucid Intelligence bottom sheet                                                                                                                                                                                                                                                                            |
| `showLucidSheet(html)`                            | Renders Lucid content in bottom sheet with dark teal gradient background (`linear-gradient(180deg, rgba(8,22,28,0.98) 0%, rgba(5,10,18,0.99) 100%)`), cyan top border (`rgba(34,209,238,0.15)`). Used by `showLucidDrawer()`, `showLucid()`, and `showLucidWeightPanel()`.                                 |
| `lucidCard(text, ctaLabel, ctaQuestion, context)` | Unified Lucid insight card renderer. Returns HTML with ◆ Lucid header, body text, context label (top-right), and CTA button that opens Lucid drawer with pre-filled question. Replaces legacy `lucidBlock()`. See Arx_6-1 for full spec.                                                                   |
| `showValueProps()` / `dismissValueProps()`        | Post-onboarding value proposition overlay. Shows 4 swipeable cards, dismissed with "Got it" button. One-time display controlled by `state.showedValueProps`.                                                                                                                                               |
| `showStyleWizard()`                               | Trading Style Wizard bottom sheet                                                                                                                                                                                                                                                                          |
| `showMyTradersSheet(mode)`                        | Copying/Following list management sheet                                                                                                                                                                                                                                                                    |
| `toggleBookmark(type, item)`                      | Universal bookmark toggle                                                                                                                                                                                                                                                                                  |
| `showSheet(html)` / `hideSheet()`                 | Generic bottom sheet                                                                                                                                                                                                                                                                                       |
| `navPush(html)` / `navPop()`                      | Full-page navigation stack                                                                                                                                                                                                                                                                                 |
| `switchTab(tab)`                                  | Tab bar navigation                                                                                                                                                                                                                                                                                         |
| `openTrade(sym)`                                  | Contextual trade entry — sets `tradeMode='calc'`, navigates to Trade tab calculator for specified symbol. Handles same-tab case (rebuilds in place if already on Trade tab). Used by Markets C3 [Trade ▶], Home Quick Trade, Copy Dashboard [Trade Myself].                                                |
| `openTradeWithIntent(sym, dir, lev, source)`      | Pre-filled trade entry — sets symbol, direction, leverage, source, then navigates to calculator. Handles same-tab case. Used by Home Feed [Trade Myself], signal cards [Trade →].                                                                                                                         |
| `staggerEntrance()`                               | Sequential `.anim-item` fade-in animation                                                                                                                                                                                                                                                                  |
| `obNavigate('wiz1'...'wiz5','wizDone')`           | S7 Matching Wizard screen navigation — advances through wizard questions (wiz1-wiz5) and result screen (wizDone). Manages wizard state, progress bar, and back navigation within the wizard flow.                                                                                                          |
| `obFinish()`                                      | Exit onboarding to main app — called from any skip button ("Skip — explore first") or after completing the onboarding flow. Clears onboarding state, sets journey flags, and transitions to the appropriate landing screen (R0 for S7, C1 for S2).                                                         |
| `obOpenFundFlow(provider)`                        | Opens funding sub-flow overlay. `provider`: `'moonpay'` \| `'transak'` \| `'deposit'`                                                                                                                                                                                                                      |
| `obCloseFundFlow(provider)`                       | Closes and resets funding sub-flow for the specified provider                                                                                                                                                                                                                                              |
| `mpUpdateAmount(input)`                           | Updates MoonPay amount from input field                                                                                                                                                                                                                                                                    |
| `mpSetAmount(el, val)`                            | Sets MoonPay amount from preset pill                                                                                                                                                                                                                                                                       |
| `mpCalc()`                                        | Recalculates MoonPay fees and USDC receive amount                                                                                                                                                                                                                                                          |
| `mpShowPayment()`                                 | Transitions to payment method step                                                                                                                                                                                                                                                                         |
| `mpBackToAmount()`                                | Returns to amount step                                                                                                                                                                                                                                                                                     |
| `mpSelectPay(el)`                                 | Selects payment method radio                                                                                                                                                                                                                                                                               |
| `mpProcess()`                                     | Starts animated 3-step processing flow (4s total)                                                                                                                                                                                                                                                          |
| `mpResetSteps()`                                  | Resets all MoonPay steps to initial state                                                                                                                                                                                                                                                                  |
| `tkUpdateAmount(input)`                           | Updates Transak amount from input                                                                                                                                                                                                                                                                          |
| `tkSetAmount(el, val)`                            | Sets Transak amount from preset pill                                                                                                                                                                                                                                                                       |
| `tkCalc()`                                        | Recalculates fees (ACH: 0.5%, Wire: $15 flat)                                                                                                                                                                                                                                                              |
| `tkSelectMethod(el)`                              | Selects ACH or Wire transfer method                                                                                                                                                                                                                                                                        |
| `tkProcess()`                                     | Shows bank transfer instructions                                                                                                                                                                                                                                                                           |
| `tkBackToAmount()`                                | Returns to amount step                                                                                                                                                                                                                                                                                     |
| `tkConfirm()`                                     | Shows pending confirmation screen                                                                                                                                                                                                                                                                          |
| `tkResetSteps()`                                  | Resets all Transak steps                                                                                                                                                                                                                                                                                   |
| `obOpenWalletConnect()`                           | Opens wallet selection bottom sheet modal                                                                                                                                                                                                                                                                  |
| `obCloseWalletModal()`                            | Closes wallet selection modal                                                                                                                                                                                                                                                                              |
| `obSelectWallet(wallet)`                          | Starts wallet connection (`MetaMask`, `Coinbase`, `WalletConnect`, `Rabby`). Shows connecting spinner for 2.2s, then success                                                                                                                                                                               |
| `obCloseWalletConnecting()`                       | Cancels connection attempt                                                                                                                                                                                                                                                                                 |
| `obWalletConnectDone()`                           | Closes success modal, navigates to A1b                                                                                                                                                                                                                                                                     |
| `d3CalcDecay(l)`                                  | Sigmoid alpha decay model: computes decay-adjusted CMR based on capacity utilization                                                                                                                                                                                                                       |
| `d3PortfolioFit(l)`                               | Checks directional alignment + asset HHI against existing copy portfolio                                                                                                                                                                                                                                   |
| `d3RegimeFit(l)`                                  | Checks leader's win rate in current regime                                                                                                                                                                                                                                                                 |
| `showCopySetup(handle)`                           | Entry: runs gate check animation, pre-fills allocation from investment tier, opens 4-step wizard (or Capacity Full sheet if at max)                                                                                                                                                                        |
| `d3RenderStep(l, step)`                           | Renders wizard steps 0-3 (Briefing, How Much, Safety, Confirm)                                                                                                                                                                                                                                             |
| `d3ShowCustomize(handle)`                         | Opens bottom sheet with all protection controls (replaces Full Setup steps 4-7)                                                                                                                                                                                                                            |
| `d3ShowCapacityFull(l)`                           | Shows capacity full sheet with waitlist + style-matched alternatives                                                                                                                                                                                                                                       |
| `d3ConfirmCopy(handle)`                           | Validates consent checkbox, launches confetti, creates copy relationship                                                                                                                                                                                                                                   |
| `d3ToggleConsent()`                               | Toggles risk consent checkbox on Step 3                                                                                                                                                                                                                                                                    |
| `d3SetAlloc(val, l)`                              | Quick pick allocation setter                                                                                                                                                                                                                                                                               |
| `d3UpdateAllocFromInput(input, l)`                | Parses amount input field                                                                                                                                                                                                                                                                                  |
| `detectTradeStyle()`                              | S2/S7 segment detection from journeyState — returns `'active'` (S2) or `'copy'` (S7). Used to adapt trade flow behavior and risk defaults.                                                                                                                                                                 |
| `tradeTPSLRemoveFriction(type)`                   | TP/SL removal friction dialog — shows risk warning with Keep/Remove buttons when user attempts to remove take-profit or stop-loss. `type`: `'tp'` \| `'sl'`. Protects against impulsive removal of exit plan.                                                                                              |
| `buildSpotTrade(inst)`                            | Redesigned spot trade screen — portfolio % pills for amount selection, Market Info card, Advanced Trade Settings expandable section (Order Type, Sell Target, Price Alert, DCA). BUY/SELL direction toggle. Complete rewrite per Trade Parameter Redesign Proposal.                                        |
| `alertBellIcon(type, id, size)`                   | Reusable alert bell icon component. Returns HTML string — filled purple when subscribed (`state.alertSubs[key].includes(id)`), outline gray when not. `type`: `'leader'`\|`'instrument'`\|`'signal'`. Default size 20px. Long-press opens `showAlertQuickSetup()`.                                         |
| `toggleAlertSub(type, id, el)`                    | Toggles alert subscription in `state.alertSubs`. Shows toast (subscribed/unsubscribed). Re-renders bell icon fill and stroke in-place without full re-render.                                                                                                                                              |
| `showAlertManagement()`                           | Full-page navPush Alert Management Hub. Master toggle, 4 category sections (Signal Alerts 7 types, Social Alerts 4 types, Copy Trading Alerts 4 types, Delivery Preferences). Individual toggle switches per preference. Entry from S1 Settings or NC1 gear icon.                                          |
| `showAlertQuickSetup(type, id)`                   | Bottom sheet for quick per-entity alert configuration. Entry from long-press on any `alertBellIcon`.                                                                                                                                                                                                       |
| `showAlertLeaderPicker()`                         | Bottom sheet to select leaders for trade alert subscriptions. Entry from Social Alerts section in Alert Management.                                                                                                                                                                                        |
| `showTradeThread(tradeEventId)`                   | Full-page navPush Trade Discussion thread. Shows trade header (leader, symbol, direction, leverage, entry, size, status), rationale card, comment thread with leader badges, comment input, persistent [Copy This Trade] footer. Closed trades show P&L banner.                                            |
| `buildForumLiveTrades()`                          | Returns HTML for Community Forum Live Trades tab — renders all `MOCK.tradeEvents` as discussion cards with [Join Discussion →] CTAs.                                                                                                                                                                       |
| `switchForumTab(idx)`                             | Switches Community Forum sub-tabs: 0=Trending, 1=Live Trades, 2=Latest, 3=Trade Ideas, 4=Education.                                                                                                                                                                                                        |
| `showCommunityForum()`                            | Full-page navPush Community Forum with 5-tab navigation. Live Trades tab aggregates trade events across all leaders.                                                                                                                                                                                       |

### State Variables (Prototype JS)

| Variable               | Type    | Default                                                                                           | Purpose                                                                                                      |
| ---------------------- | ------- | ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `mpAmount`             | number  | 100                                                                                               | Current MoonPay purchase amount in USD                                                                       |
| `tkAmount`             | number  | 500                                                                                               | Current Transak transfer amount in USD                                                                       |
| `tkMethod`             | string  | `'ach'`                                                                                           | Transak method: `'ach'` \| `'wire'`                                                                          |
| `d3Alloc`              | number  | 0                                                                                                 | Copy allocation amount in USD                                                                                |
| `d3MaxLossPct`         | number  | 15                                                                                                | Max loss percentage for copy                                                                                 |
| `d3CopyMode`           | string  | `'proportional'`                                                                                  | Copy mode: `'proportional'` \| `'fixed'`                                                                     |
| `d3CustomizeOpen`      | boolean | false                                                                                             | Whether Customize Protections bottom sheet is open                                                           |
| `d3LevCap`             | number  | 10                                                                                                | Leverage cap for copied trades                                                                               |
| `d3PerTradeSL`         | number  | 5                                                                                                 | Per-trade stop-loss percentage                                                                               |
| `d3TradeSizeLimit`     | number  | 25                                                                                                | Max single trade size as % of allocation                                                                     |
| `d3SlippageTol`        | number  | 1                                                                                                 | Slippage tolerance percentage                                                                                |
| `d3SlippageFallback`   | string  | `'skip'`                                                                                          | Slippage fallback action: `'skip'` \| `'limit'`                                                              |
| `d3DailyLossLimit`     | number  | 10                                                                                                | Daily loss limit percentage                                                                                  |
| `d3MonthlyDDLimit`     | number  | 20                                                                                                | Monthly drawdown limit percentage                                                                            |
| `d3RegimeScaling`      | boolean | true                                                                                              | Whether to scale position size by regime                                                                     |
| `d3AllocMode`          | string  | `'quick'`                                                                                         | Allocation mode: `'quick'` \| `'custom'`                                                                     |
| `d3RiskConsentChecked` | boolean | false                                                                                             | Risk consent checkbox state on Step 3                                                                        |
| `tradeInstrType`       | string  | `'perps'`                                                                                         | Explicit instrument type routing: `'perps'` \| `'spot'`                                                      |
| `tradeStyle`           | string  | `'active'`                                                                                        | Trade style detected from behavior: `'active'` (S2) \| `'copy'` (S7)                                         |
| `spotAmount`           | number  | 500                                                                                               | Spot trade dollar amount                                                                                     |
| `spotDir`              | string  | `'BUY'`                                                                                           | Spot trade direction: `'BUY'` \| `'SELL'`                                                                    |
| `alertSubs`            | object  | `{leaders:['ProTrader','AlphaHunter'], instruments:['BTC-PERP','SOL-PERP'], signals:['P4','P5']}` | Runtime alert subscription state — initialized from `MOCK.alertSubscriptions`, mutated by `toggleAlertSub()` |

### Mock Data Summary (Prototype)

| Entity              | Count | Source                                                                                                            |
| ------------------- | ----- | ----------------------------------------------------------------------------------------------------------------- |
| Leaders             | 6     | ProTrader, AlphaHunter, RangeKing, CryptoSurgeon, WalletAce, BTCMaxi                                              |
| Perp Instruments    | 15    | BTC, ETH, SOL, HYPE, ARB, DOGE, SUI, AVAX, LINK, PEPE, WIF, OP, AAPL, TSLA, NVDA, MSFT, GOLD, SILVER, OIL, NATGAS |
| Spot Instruments    | 4     | BTC-SPOT, ETH-SPOT, SOL-SPOT, HYPE-SPOT                                                                           |
| Feed Items          | 8     | 3 trades, 2 opportunities, 2 market events, 1 trade                                                               |
| Signals             | 5     | P1–P5 layers                                                                                                      |
| Positions           | 2     | SOL-PERP LONG 5x, ETH-PERP SHORT 3x                                                                               |
| Spot Holdings       | 2     | BTC 0.0042 ($285.15), SOL 2.1 ($365.82)                                                                           |
| Copy Portfolio      | 3     | CryptoSurgeon (Elite), TrendRider (Proven), SOLMaster (Verified)                                                  |
| Trade History       | 20    | With regime context, fee, source attribution                                                                      |
| Watchlist           | 5     | SOL, BTC, ETH, HYPE, ARB                                                                                          |
| Alert Preferences   | 1     | 4 categories, 16 toggles (signals, social, copy trading, delivery)                                                |
| Alert Subscriptions | 1     | 3 arrays: leaders (2), instruments (2), signals (2)                                                               |
| Trade Events        | 4     | With nested comment threads and copy counts                                                                       |

---

## Implementation Notes

> **S7 Forums + Trade-Sparked Discussions + Alert Management (2026-03-13):** Three enhancements implemented. (1) **Forums under each trader profile:** Leader Discussion tab (D2, tab index 3) enhanced with trade-sparked discussion threads from `MOCK.tradeEvents`. Community Forum (`showCommunityForum()`) with 5-tab navigation including Live Trades tab. Trade Thread screen (`showTradeThread()`) for full discussion with inline copy. (2) **Alert Management System:** Reusable `alertBellIcon(type, id, size)` component placed across Feed cards, Market grid, Traders list, and Notification Center. `toggleAlertSub()` manages runtime subscription state. Alert Management Hub (`showAlertManagement()`) with 4 categories and 16 toggles. Alert Quick Setup sheet and Leader Picker sheet. (3) **New MOCK data:** `alertPreferences`, `alertSubscriptions`, `tradeEvents` (4 events with comment threads), `state.alertSubs`. 10 new functions, 1 new state variable. Source: `Arx_7-1_S7_Forum_Alerts_UX_Architecture.md`.
>
> **v6.5 Trade Parameter Redesign (2026-03-13):** Trade module redesigned per Arx_Trade_Parameter_Redesign_Proposal. Perps flow enhanced to 5-step with regime bar at top, risk % pills [1%][2%][5%] replacing free-form input, reframed questions for cognitive clarity, enhanced exit plan with TP/SL removal friction dialog (shows risk warning with Keep/Remove buttons when user attempts to remove stop-loss or take-profit), and enhanced summary showing position size in asset units + liquidation price. Spot flow completely rewritten with portfolio % pills for amount selection, Market Info card, and More options expandable section containing Order Type, Sell Target, Price Alert, and DCA settings. New state variables: `tradeInstrType` (perps/spot routing), `tradeStyle` (S2 active / S7 copy detection), `spotAmount` (default 500), `spotDir` (BUY/SELL). New functions: `detectTradeStyle()` (S2/S7 segment detection from journeyState), `tradeTPSLRemoveFriction(type)` (TP/SL removal friction dialog), `buildSpotTrade(inst)` (redesigned spot trade screen). `buildTrade()` perps section modified with regime bar, risk pills, and enhanced summary. Risk management additions: TP/SL removal friction prevents impulsive exit plan removal, S2/S7 detection adapts defaults, regime gate integration, cool-down timer.
>
> **v6.4 D3 Copy Setup Redesign (2026-03-13):** D3 Copy Setup redesigned per Arx 9-7. The previous 3-step Quick + 8-step Full setup replaced with a 4-step Briefing-First Wizard: Gate Check → Briefing Card (step 0) → How Much (step 1) → Safety Limits (step 2) → Confirm & Start (step 3). New functions added: d3CalcDecay (sigmoid alpha decay), d3PortfolioFit (directional alignment + HHI), d3RegimeFit (regime win rate), showCopySetup (entry with gate check animation), d3RenderStep (wizard step renderer), d3ShowCustomize (Customize Protections bottom sheet replacing Full Setup steps 4-7), d3ShowCapacityFull (capacity full sheet with waitlist + similar leaders), d3ConfirmCopy (consent validation + confetti), d3ToggleConsent, d3SetAlloc, d3UpdateAllocFromInput. 14 new state variables for allocation, risk limits, and protection controls. Customize Protections bottom sheet provides advanced control without cluttering the main wizard. Capacity Full sheet handles at-max leaders with waitlist and style-matched alternatives.
>
> **v6.3 Fund Sub-Flows & Wallet Connect (2026-03-13):** A4 Fund screen upgraded from static cards to 3 interactive sub-flows — MoonPay (amount → payment → processing → success, 4 steps), Transak (amount+method → bank instructions → pending, 3 steps), Deposit (single screen with QR code, address, network details). 20 new functions added to prototype: fund sub-flow openers/closers, MoonPay 8-function flow, Transak 8-function flow, WalletConnect 5-function modal flow. A0 WalletConnect button now opens a wallet selection bottom sheet (MetaMask, Coinbase, WalletConnect, Rabby) with connecting spinner (2.2s) and success states. All onboarding skip buttons standardized to "Skip — explore first" copy, all calling obFinish(). New state variables: mpAmount (default 100), tkAmount (default 500), tkMethod (default 'ach').
>
> **v6.2 Onboarding Changes (2026-03-13):** All onboarding updates in this version (S0 Luminous Convergence, Privy auth on A0, A1 made optional, S7 Matching Wizard wiz1-wiz5 + wizDone, A4 geo-detected fiat on-ramp, new critical paths, wizard cross-module flows, obNavigate/obFinish functions) are sourced from the `Arx_9-5` proposal. See that document for the full rationale, screen-by-screen specs, and wizard question definitions.

---

## Document Metadata

| Property                | Value                                                                                                                                                                                                                                                                                                      |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Upstream Dependencies   | 3-2 PRD, 3-3 Customer Journey Maps, 4-2 Design System, Arx_9-5 (onboarding proposal), Arx_9-7 (D3 Copy Setup redesign), Arx_Trade_Parameter_Redesign_Proposal (trade parameter redesign), Arx_7-1 (S7 Forum & Alerts UX Architecture), Arx_6-1 (Lucid Interaction Design System), prototype implementation |
| Downstream Dependencies | All module files (4-1-1-1 through 4-1-1-7), 5-1 Executable Spec, 5-3 Build Prompts                                                                                                                                                                                                                         |
| Update Trigger          | New module added, tab bar changed, navigation model changed, new shared framework, Lucid intelligence model change                                                                                                                                                                                         |
| Mock Data & Visual Registry | `Arx_4-1-1-8_Mock_Data_Fixtures.md` — canonical mock data, icon registry, embellishment registry                                                                                                                                                                                                                                          |
