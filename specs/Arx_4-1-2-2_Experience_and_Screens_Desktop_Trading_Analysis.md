# ARX DESKTOP APP — PSEUDO-PROTOTYPE v2.0

> **STATUS: DEFERRED** — Desktop is not in the current build cycle. These specs reference Design System v1.0/v2.0 (Electric Cyan era) and are palette-incompatible with the current v5.7 (Citadel & Moat). When desktop becomes a build target, these specs must be updated to reference `Arx_4-2_Design_System.md` v5.7+ for all color tokens, regime colors, and component patterns. Do not use these specs for current design or engineering decisions.

## Part 2: Trading & Analysis (Watchlist W1 · Chart W2 · Order Book W3 · Order Entry W4 · Visual Order Builder W5 · Positions W6 · Trade History W7 · Symbol Overview W17 · Signal Cards W14 · Interaction Flows)

**Date:** March 2, 2026
**Baseline:** Mobile v2.0 screens C1–C7, TH1, Trade Hub → Desktop widget adaptations
**Scope:** Chart, Order Entry, Order Book, Positions, Trade History, Visual Order Builder, Watchlist, Symbol Overview
**Version line:** v2.0 — Radar rename, 6-regime model, P1-P5 signal taxonomy, wallet consensus on trading widgets
**v2.1 Amendment (per 3-5):** Liquidation distance as primary metric in W6, progressive leverage guard in W4, funding cost visualizer in W4/W6. Aligns desktop with mobile pain-alignment changes for S2+S7.
**Note:** Widget numbering follows the original v1.0 convention. W5 = Visual Order Builder (desktop-exclusive), W6 = Positions, W7 = Trade History.

---

## v2.0 CHANGE SUMMARY

| #   | Change                                  | Scope                  | Impact                                                                                                                                                                                                                                |
| --- | --------------------------------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Rename "Alpha" → "Radar" EVERYWHERE     | Global branding        | All references to Alpha Feed, Alpha Intelligence, Alpha Network become Radar Feed, Radar Intelligence, Radar Network. @AlphaHunter handles unchanged.                                                                                 |
| 2   | Update Regime to 6 states               | Regime display         | Trending Up (Emerald `#10B981`), Trending Down (Red `#EF4444`), Range-bound (Blue `#3B82F6`), Transition (Amber `#F59E0B`), Compression (Teal `#0D9488`), Crisis (Deep Orange `#EA580C`). All regime references updated.               |
| 3   | Add P1-P5 Signal Layer labels to W14    | Signal Cards widget    | Every signal card shows its P-layer label. Add filter dropdown: [All] [P1] [P2] [P3] [P4] [P5]                                                                                                                                        |
| 4   | Add Wallet Consensus to W4              | Order Entry widget     | In BOTH AI Strategy and Direct Trade modes: show "X All-Weather wallets [direction] on [asset]. Y total followed wallets aligned." In AI Strategy mode, insert as Step 2.5. In Direct Trade, add compact wallet bar below order form. |
| 5   | Add Wallet Alignment column to W6       | Positions widget       | New column showing count of followed wallets with same position direction. Regime shift highlight also shows wallet consensus change.                                                                                                 |
| 6   | Add Wallet Filter to W7                 | Trade History widget   | Add "Wallet-Aligned" filter toggle and "Wallet Alignment" column showing wallet consensus at trade entry time.                                                                                                                        |
| 7   | Add Wallet Context to W17               | Symbol Overview widget | New "Smart Money" section: count of All-Weather wallets with positions, net direction, recent activity.                                                                                                                               |
| 8   | Add Belief Capture to Trade Review flow | Trade expansion in W7  | When trade is expanded, show "Belief" section: conviction %, invalidation rule, time horizon, linked signals.                                                                                                                         |
| 9   | Preserve ALL v1.0 content               | Structural integrity   | All widget wireframes, interaction flows, column specs, drawing tools, indicator specs, order types, spot/perps variations unchanged.                                                                                                 |

---

## TABLE OF CONTENTS — PART 2

1. Watchlist Widget (W1)
2. Chart Widget (W2)
3. Order Book Widget (W3)
4. Order Entry Widget (W4)
5. Visual Order Builder (Chart Integration) — W5
6. Positions Widget (W6)
7. Trade History Widget (W7)
8. Symbol Overview Widget (W17)
9. Signal Cards Widget (W14)
10. Widget Interaction Flows

---

## 1. WATCHLIST WIDGET (W1)

The Watchlist is the primary navigation hub on desktop — always visible, always accessible. It serves as both the Symbol Watchlist and Wallet Watchlist from mobile, unified into tabs.

### 1.1 Wireframe

```
┌─ Watchlist ──────────────── [⚪] [⚙] [—] [×] ─┐
│ [📈 Symbols] [👤 Wallets]                       │
│ [🔍 Search / Add... ⌘/]                         │
├──────────────────────────────────────────────────┤
│ ★ FAVORITES                              ▾      │
│                                                  │
│ ● BTC     $67,420   ↑1.2%   ████▌ F:+0.01%    │
│ ● ETH     $3,420    ↑2.3%   ███▊  F:+0.035%   │
│ ● SOL     $142.30   ↓0.8%   ██▍   F:-0.002%   │
│                                                  │
│ 🔥 TRENDING SIGNALS                      ▾      │
│                                                  │
│ ● DOGE    $0.142    ↑8.2%   ████████▌          │
│   2 signals · Regime fit: ✅                     │
│ ● AVAX    $38.20    ↑4.1%   ██████▊            │
│   1 signal · Regime fit: ⚠                      │
│                                                  │
│ 📋 ALL WATCHLIST (12)                    ▾      │
│                                                  │
│ ● ARB     $1.82     ↓1.2%   █▊                 │
│ ● LINK    $18.40    ↑0.3%   ██▌                │
│ ● OP      $3.42     ↑1.1%   ███                │
│ ● ...                                           │
│                                                  │
├──────────────────────────────────────────────────┤
│ [+ Add Symbol]                    12/50 symbols  │
└──────────────────────────────────────────────────┘

WALLET TAB:
┌─ Watchlist ──────────────── [⚪] [⚙] [—] [×] ─┐
│ [📈 Symbols] [👤 Wallets]                       │
│ [🔍 Search wallets... ]                          │
├──────────────────────────────────────────────────┤
│ 🔮 FOLLOWING (3)                         ▾      │
│                                                  │
│ 🛡️ @CryptoSurgeon   +2.8% today                │
│   Active: Long ETH · ✅✅✅ · Last: 2h ago       │
│                                                  │
│ 🎯 @WhaleHunter     +1.1% today                │
│   Active: Long BTC · ✅✅✅ · Last: 5h ago       │
│                                                  │
│ 📉 @MoonChaser      -0.4% today                │
│   Active: Short SOL · ✅✅⚠ · Last: 1h ago      │
│                                                  │
│ 👁 WATCHING (8)                          ▾      │
│                                                  │
│ 🛡️ @RadarGenesis    +3.2% today                │
│   No active position · Last: 6h ago             │
│ 🍀 @LuckyLarry      +5.1% today     🔒         │
│   Active: Long DOGE · Blocked                   │
│ ...                                              │
│                                                  │
├──────────────────────────────────────────────────┤
│ [+ Add Wallet]                   11/100 wallets  │
└──────────────────────────────────────────────────┘
```

### 1.2 Interactions

| Action             | Behavior                                                          |
| ------------------ | ----------------------------------------------------------------- |
| Click symbol row   | Sets symbol in all widgets linked to this Watchlist's group       |
| Right-click symbol | Context menu: Trade, View Details, Remove, Set Alert              |
| Drag symbol        | Reorder within list; or drag to chart widget to change its symbol |
| Hover symbol       | Tooltip: 24h high/low, volume, OI (perps), signal count           |
| Click wallet row   | Opens Wallet Profile widget (W8) with this wallet                 |
| Right-click wallet | Context menu: View Profile, Follow, Watch, Remove                 |
| Click signal count | Opens Signal Cards widget filtered to this symbol                 |
| ⌘/                 | Focus search bar within watchlist                                 |

### 1.3 Column Customization

```
SETTINGS DROPDOWN [⚙]:
┌─────────────────────────────┐
│ Columns:                    │
│ ☑ Price                     │
│ ☑ 24h Change (%)            │
│ ☑ Mini Sparkline            │
│ ☑ Funding Rate              │
│ ☐ Volume                    │
│ ☐ Open Interest             │
│ ☐ Market Cap                │
│ ☐ Signal Count              │
│ ☐ Confluence Score          │
│                             │
│ Sort by: [24h Change ▾]     │
│ Group by: [Favorites first ▾]│
│                             │
│ [Reset to Default]          │
└─────────────────────────────┘
```

---

## 2. CHART WIDGET (W2)

The Chart is the centerpiece of desktop trading — supporting technical analysis, indicator overlays, drawing tools, and visual order placement.

### 2.1 Wireframe

```
┌─ Chart: ETH/USDT ─────────── [🔴] [⚙] [—] [×] ─┐
│ ┌──────────────────────────────────────────────────┐│
│ │ ETH/USDT  $3,420  ↑2.3%  │ 🟢 Trending Up       ││
│ │ [1m][5m][15m][1H][4H][1D][1W] [Candle▾] [Ind▾]  ││
│ ├──────────────────────────────────────────────────┤│
│ │                                                  ││
│ │         ┌──┐                                     ││
│ │    ┌──┐ │  │ ┌──┐                                ││
│ │    │  │ │  │ │  │    ┌──┐                        ││
│ │ ┌──┤  ├─┤  ├─┤  ├────┤  │     ┌──┐              ││
│ │ │  │  │ │  │ │  │    │  │  ┌──┤  │              ││
│ │ │  └──┘ └──┘ └──┘    │  ├──┤  │  │              ││
│ │ │                     └──┘  │  └──┘              ││
│ │ └──                        └──       ← Candles   ││
│ │                                                  ││
│ │ ─── SMA(20) ─── EMA(50) ─── BB(20,2) ───        ││
│ │                                                  ││
│ │ ───── Regime transitions: ┊ T→R ┊ R→T ┊ ─────── ││
│ │                                                  ││
│ │ ── Positions: Long ETH ▬▬▬ entry $3,280 ──      ││
│ │ ── Stop Loss: ─ ─ ─ $3,180 (red dashed) ──      ││
│ │ ── Take Profit: ─ ─ ─ $3,650 (green dashed) ──  ││
│ │                                                  ││
│ ├──────────────────────────────────────────────────┤│
│ │ RSI(14): 62.3                                    ││
│ │ ████████████████████████████████░░░░░░░░  62     ││
│ ├──────────────────────────────────────────────────┤│
│ │ MACD: 12.4  Signal: 8.2  Histogram: +4.2        ││
│ │      ╱╲  ╱╲                                      ││
│ │ ────╱──╲╱──╲──── signal                          ││
│ │ ██▓▓▒▒░░░░▒▒▓▓██ histogram                      ││
│ └──────────────────────────────────────────────────┘│
│ Drawing: [─][╱][◇Fib][▭][✏][🗑] │ 🔍+ 🔍- [↺Fit]  │
└────────────────────────────────────────────────────┘

CHART COMPONENTS:
  Header Row:
    Symbol + price + change + Regime chip (updated with 6-state model)
    Timeframe selector (1m/5m/15m/1H/4H/1D/1W + custom)
    Chart type dropdown (Candle, Line, Heikin Ashi, Area)
    Indicators dropdown (add/remove)

  Main Chart Area:
    Candlestick data with volume bars at bottom
    Indicator overlays (SMA, EMA, BB, Ichimoku, etc.)
    Regime transition markers (vertical dashed lines with 6-state colors)
    Position lines (entry, SL, TP) when active position exists
    Signal annotations (optional — toggle in settings)

  Sub-Charts (collapsible panels below main):
    RSI, MACD, Volume, Stochastic, ADX, or any configured indicator
    Each sub-chart independently collapsible

  Drawing Toolbar:
    Horizontal line, Trend line, Fibonacci retracement,
    Rectangle selection, Freehand annotation, Eraser
    + zoom controls + fit-to-data button

  Footer:
    Crosshair coordinates on hover: "Jan 15, 14:00 | O: 3412 H: 3428 L: 3405 C: 3420 V: 12.4K"
```

### 2.2 Regime States (6-State Model v2.0)

When displaying regime colors and state in charts, use these 6 states:

| State         | Color    | Hex       | Abbreviation | Marker |
| ------------- | -------- | --------- | ------------ | ------ |
| Trending Up   | Emerald  | `#10B981` | T↑           | 🟢     |
| Trending Down | Red      | `#EF4444` | T↓           | 🔴     |
| Range-bound   | Blue     | `#3B82F6` | R            | 🔵     |
| Transition    | Amber    | `#F59E0B` | Tr           | 🟡     |
| Compression   | Teal     | `#0D9488` | C            | 🟢     |
| Crisis        | Deep Orange | `#EA580C` | ⚠         | 🟠⚠    |

**Regime transitions** are displayed as vertical dashed lines in chart with state change label: "T↑ → R" or "Tr → T↓"

### 2.3 Indicators (Available)

| Category     | Indicators                                                         |
| ------------ | ------------------------------------------------------------------ |
| Trend        | SMA (any period), EMA, WMA, Ichimoku Cloud, Parabolic SAR          |
| Momentum     | RSI, MACD, Stochastic, Williams %R, CCI                            |
| Volatility   | Bollinger Bands, ATR, Keltner Channels                             |
| Volume       | Volume bars, OBV, VWAP, Volume Profile                             |
| Arx-Specific | Regime overlay (color bands), Signal markers, Wallet trade markers |

**Maximum overlays:** 5 on main chart + 3 sub-charts

**Arx-specific indicators** are unique and not available elsewhere:

- **Regime overlay**: Colored background bands showing historical regime states (6 colors)
- **Signal markers**: Triangles on chart where Arx generated signals (labeled with P-layer)
- **Wallet trade markers**: Diamonds showing when followed wallets entered/exited

### 2.4 Drawing Tools

| Tool                  | Shortcut | Description                               |
| --------------------- | -------- | ----------------------------------------- |
| Horizontal Line       | H        | Price level marker (for S/R)              |
| Trend Line            | T        | Two-point line (extend optional)          |
| Fibonacci Retracement | F        | Multi-level retracement overlay           |
| Rectangle             | R        | Area highlight (e.g., supply/demand zone) |
| Freehand              | D        | Draw anything on chart                    |
| Eraser                | X        | Remove specific drawing                   |
| Clear All             | ⌘Shift+X | Remove all drawings from chart            |

**Drawing persistence:** Drawings save per-symbol per-chart instance. Persist across sessions.

### 2.5 Chart Interactions

| Action                   | Behavior                                                       |
| ------------------------ | -------------------------------------------------------------- |
| Left-click + drag        | Pan chart (time axis)                                          |
| Scroll wheel             | Zoom in/out (time axis)                                        |
| Right-click              | Context menu: Trade from here, Draw, Add indicator, Reset zoom |
| Hover candle             | Crosshair + OHLCV tooltip                                      |
| Click position line      | Highlight position, show P&L at cursor                         |
| Click regime transition  | Tooltip: "Regime changed: Trending Up → Range-bound"           |
| Double-click price level | Quick horizontal line at that price                            |
| ⌘+click price            | Open Order Entry pre-filled with this price as limit           |

---

## 3. ORDER BOOK WIDGET (W3)

### 3.1 Wireframe

```
┌─ Order Book: ETH ──────── [🔴] [⚙] [—] [×] ─┐
│ Precision: [0.01 ▾]  │  Depth: [20 ▾]         │
├────────────────────────────────────────────────┤
│  Cumulative │  Size  │ Price    │ Size │ Cumul  │
│    BIDS     │  BIDS  │          │ ASKS │  ASKS  │
├─────────────┼────────┼──────────┼──────┼────────┤
│             │        │ $3,428.50│ 12.4 │ ███    │
│             │        │ $3,427.80│  8.2 │ ██     │
│             │        │ $3,426.20│ 24.1 │ █████  │
│             │        │ $3,425.00│ 45.3 │ ████████│
│             │        │ $3,424.10│  6.8 │ █▌     │
│─────────────┼────────┼──────────┼──────┼────────│
│        SPREAD: $0.60 (0.02%)                    │
│─────────────┼────────┼──────────┼──────┼────────│
│ █▌          │  5.2   │ $3,423.50│      │        │
│ ██          │  9.8   │ $3,422.80│      │        │
│ ████        │ 18.4   │ $3,421.20│      │        │
│ ███████████ │ 67.2   │ $3,420.00│      │        │
│ ████        │ 15.1   │ $3,419.50│      │        │
│ ███         │ 12.8   │ $3,418.00│      │        │
│ █████████   │ 52.3   │ $3,415.00│      │        │
├────────────────────────────────────────────────┤
│ Best Bid: $3,423.50 │ Best Ask: $3,424.10      │
│ Bid depth: $2.1M    │ Ask depth: $1.8M         │
│ Bid/Ask ratio: 1.17 (buyers stronger)           │
└────────────────────────────────────────────────┘

VISUAL ENCODING:
  - Cumulative bars: Horizontal bars showing cumulative depth
  - Color: Bids in green, Asks in red
  - Large orders (>2x avg size): highlighted row (subtle yellow)
  - Spread: Center line with spread amount and percentage
  - Footer: Aggregate bid/ask depth + ratio interpretation

INTERACTIONS:
  Click price level → Opens Order Entry pre-filled at that price
  Hover row → Tooltip: cumulative total at this level
  Right-click → Context menu: Buy at price, Sell at price, Set alert
```

### 3.2 Depth Visualization Mode (Toggle)

```
DEPTH CHART MODE [⚙ → Visualization: Depth Chart]:
┌────────────────────────────────────────────────┐
│                                                │
│     ╱────────────────╲                         │
│    ╱ BIDS              ╲ ASKS                  │
│   ╱                      ╲                     │
│  ╱                        ╲                    │
│ ╱                          ╲                   │
│╱                            ╲                  │
│████████████████|████████████████                │
│  $3,415  $3,420  $3,424  $3,430                │
│              ↑ MID                              │
└────────────────────────────────────────────────┘
  Green area = cumulative bid depth
  Red area = cumulative ask depth
  Center line = mid price
  Click anywhere → Order Entry at that price level
```

---

## 4. ORDER ENTRY WIDGET (W4)

### 4.1 Mode Selector

The Order Entry widget supports two modes, matching mobile C4a/C4b:

```
┌─ Order Entry ──────────────── [🔴] [⚙] [—] [×] ─┐
│ [🤖 AI Strategy] [📝 Direct Trade]                 │
│ 🟢 Trending Up — momentum strategies favored       │
├─────────────────────────────────────────────────────┤
│                                                     │
│  (Mode-specific content below)                      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 4.2 AI Strategy Mode (Follow Trade)

```
┌─ Order Entry: AI Strategy ─── [🔴] [⚙] [—] [×] ─┐
│ [🤖 AI Strategy●] [📝 Direct Trade]                │
│ 🟢 Trending Up — momentum strategies favored        │
├─────────────────────────────────────────────────────┤
│                                                     │
│ SIGNAL SOURCE                                       │
│ 🛡️ @CryptoSurgeon opened Long ETH @ $3,420        │
│ Gate: ✅✅✅ | "All-Weather — best regime"          │
│                                                     │
│ ─── STEP 1: DIRECTION ────────────────────────────  │
│ [▲ LONG (recommended)]  [▼ SHORT]                   │
│                                                     │
│ ─── STEP 2: SIZING GUIDE ─────────────────────────  │
│ Recommended: $7,812 (15.5%)                         │
│ ██████████████░░░░░░░░░░░░░░ 15.5%                 │
│                                                     │
│ Based on:                                           │
│ • Win rate: 58% over 847 trades                     │
│ • Current regime: Trending Up (best fit)            │
│ • Your preference: Moderate                         │
│ • Track Record: ★★★★★                               │
│                                                     │
│ Regime breakdown:                                   │
│ Trending Up: $7,812 | Range: $1,060                │
│ Transition: $2,400  | Compression: $3,100          │
│                                                     │
│ [Adjust ↕ ─────●───── ]  [Why this size? →]        │
│ Custom: [$7,812 ___]                                │
│                                                     │
│ ─── STEP 2.5: WALLET CONSENSUS (NEW v2.0) ─────── │
│ 🛡️ 4 All-Weather wallets bullish on ETH           │
│ 📊 7 total followed wallets aligned (78% consensus)│
│ Status: Strong alignment with your position        │
│                                                     │
│ ─── STEP 3: RISK CONTROLS ───────────────────────   │
│ Stop-Loss:    [$3,280 ___] (-4.1%, 1.2 ATR) ✅     │
│ Take-Profit:  [$3,650 ___] (+6.7%)                  │
│ Leverage:     [3x ▾] (matching wallet)              │
│ Margin:       [Isolated ▾]                          │
│                                                     │
│ PROGRESSIVE LEVERAGE GUARD (v2.1):                  │
│ 🟢 1-5x: Standard — current selection              │
│ 🟡 5-10x: Requires confirm + shows liq preview     │
│ 🔴 10x+: 5s delay + "82% of 10x+ longs liq'd      │
│          within 7 days" historical stat             │
│                                                     │
│ LIQUIDATION DISTANCE (v2.1 — Hero metric):         │
│ 🟢 $530 to liquidation (15.5%)                     │
│ Liq price: $2,890                                   │
│                                                     │
│ FUNDING COST (v2.1):                                │
│ Current: ~$2.80/8h │ Daily: ~$8.40                  │
│ Annualized: ~39% │ ⓘ Reduces net return over time  │
│                                                     │
│ ┌─────────────────────────────────────────────────┐ │
│ │         [Execute Trade — Long $7,812 ETH]       │ │
│ └─────────────────────────────────────────────────┘ │
│                                                     │
│ ⚠ By executing, you agree to the sizing and risk    │
│ controls above. You can close at any time.          │
└─────────────────────────────────────────────────────┘
```

### 4.3 Direct Trade Mode

```
┌─ Order Entry: Direct Trade ─── [🔴] [⚙] [—] [×] ─┐
│ [🤖 AI Strategy] [📝 Direct Trade●]                 │
│ 🟢 Trending Up — momentum strategies favored        │
├──────────────────────────────────────────────────────┤
│                                                      │
│ Asset: [ETH/USDT ▾]     Side: [▲ Long] [▼ Short]    │
│                                                      │
│ Order Type: [Limit ▾]   Price: [$3,420.00 ___]      │
│                                                      │
│ Leverage: [3x ▾]        Margin: [Isolated ▾]        │
│                                                      │
│ ─── WALLET CONSENSUS (NEW v2.0) ──────────────────  │
│ 🛡️ 4 aligned | 📉 1 against | Consensus: Bullish (78%)│
│                                                      │
│ ─── STOP-LOSS ─────────────────────────────────────  │
│ [$3,280 ___]  -4.1% from entry                       │
│                                                      │
│ ┌─ ATR SIZING HELPER ──────────────────────────────┐ │
│ │ Stop: 1.2 ATR away  ✅ Normal range               │ │
│ │                                                   │ │
│ │ Risk 1%: $2,439 · 1.5x lev   [Apply]            │ │
│ │ Risk 2%: $4,878 · 3.0x lev   [Apply]            │ │
│ │ Risk 5%: $12,195 · 7.5x lev  [Apply]            │ │
│ └───────────────────────────────────────────────────┘ │
│                                                      │
│ Size: [$4,878 ___]    Leverage: ~3.0x                │
│                                                      │
│ ─── TAKE-PROFIT ──────────────────────────────────── │
│ [$3,650 ___]  +6.7% from entry                       │
│                                                      │
│ ─── PROGRESSIVE LEVERAGE GUARD (v2.1) ───────────── │
│ 🟢 3x selected — standard friction                   │
│ (At 5x+: confirm + liq preview. At 10x+: 5s delay)  │
│                                                      │
│ ─── SUMMARY ──────────────────────────────────────── │
│ 🟢 LIQ DISTANCE: $530 (15.5%) ← Hero metric        │
│ Liq price: $2,890                                    │
│ Risk/Reward: 1:1.63                                  │
│ Funding: ~$1.40/8h │ Daily: ~$4.20 │ Annual: ~18%   │
│                                                      │
│ ┌──────────────────────────────────────────────────┐ │
│ │        [Place Order — Limit Long $4,878 ETH]     │ │
│ └──────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

**NEW v2.0 Addition (Step 2.5 / Wallet Consensus Bar):**
Both modes now display wallet consensus information:

- In **AI Strategy mode**: inserted as STEP 2.5 between signal review and sizing
- In **Direct Trade mode**: compact wallet bar displaying aligned/against counts with overall consensus percentage

### 4.4 Spot Mode Variations

When trading spot (not perps), the Order Entry simplifies:

```
SPOT MODE DIFFERENCES:
  - No Leverage selector (always 1x)
  - No Margin Type selector
  - No Funding cost line
  - No Liquidation estimate
  - No Safety cushion gauge
  - Stop-Loss shows $ loss only (no ATR context for spot)
  - Size shows in asset terms: "Buy 1.42 ETH ($4,878)"

ORDER TYPES (Spot):
  Market, Limit, Stop-Market, Stop-Limit, Take-Profit
  (No Trailing Stop — perps only)
```

### 4.5 Order Confirmation Modal

```
ORDER CONFIRMATION (modal overlay):
┌──────────────────────────────────────────────┐
│ Confirm Order                        [×]     │
├──────────────────────────────────────────────┤
│                                              │
│  Long ETH/USDT                               │
│  Size: $7,812 (15.5% of balance)             │
│  Entry: $3,420.00 (Limit)                    │
│  Stop-Loss: $3,280.00 (-4.1%)               │
│  Take-Profit: $3,650.00 (+6.7%)             │
│  Leverage: 3x (Isolated)                     │
│                                              │
│  Sizing Guide: ✅ Following recommendation    │
│  Signal: @CryptoSurgeon · 🛡️ All-Weather    │
│  Wallet Consensus: 78% aligned (bullish)    │
│                                              │
│  Est. funding: ~$2.80/8h                     │
│  Est. liquidation: $2,890                    │
│                                              │
│  [Cancel]              [Confirm — Execute]   │
│                                              │
│  ☐ Don't show confirmation for AI trades     │
└──────────────────────────────────────────────┘
```

---

## 5. VISUAL ORDER BUILDER (Chart Integration) — W5

A desktop-exclusive feature inspired by InSilico Terminal's "Designer Mode" — placing orders visually on the chart.

### 5.1 Activation

```
ACTIVATION:
  Right-click on chart → "Place Order Here" → Visual builder activates
  OR ⌘+click on chart price level
  OR click "Visual" toggle in chart toolbar

VISUAL MODE INDICATOR:
  Chart header shows: [📐 Visual Order Mode — click to place]
  Cursor changes to crosshair with price label
```

### 5.2 Wireframe (Visual Builder Active)

```
┌─ Chart: ETH/USDT [📐 Visual Order Mode] ──────────┐
│                                                     │
│         ┌──┐                                        │
│    ┌──┐ │  │ ┌──┐                                   │
│    │  │ │  │ │  │    ┌──┐                           │
│ ┌──┤  ├─┤  ├─┤  ├────┤  │     ┌──┐                 │
│ │  │  │ │  │ │  │    │  │  ┌──┤  │                 │
│ │  └──┘ └──┘ └──┘    │  ├──┤  │  │                 │
│ │                     └──┘  │  └──┘                 │
│ │                           └──                     │
│ │                                                   │
│ ─ ─ ─ ─ ─ ─ ─ $3,650 ─ ─ ─ ─ ─ ─ [TP] ─ ─ ─ 🟢  │
│                                                     │
│ ● ● ● ● ● ● ● $3,420 ● ● ● ● ● ● [Entry] ● ● ○  │
│                                                     │
│ ─ ─ ─ ─ ─ ─ ─ $3,280 ─ ─ ─ ─ ─ ─ [SL] ─ ─ ─ 🔴   │
│                                                     │
│ ┌─────────────────────────────────────────────────┐ │
│ │ Long ETH | Entry: $3,420 | SL: $3,280 (-4.1%)  │ │
│ │ TP: $3,650 (+6.7%) | R:R 1:1.63                │ │
│ │ Sizing Guide: $7,812 | Leverage: 3x            │ │
│ │                                                 │ │
│ │ [Confirm Order]  [Adjust in Panel →]  [Cancel]  │ │
│ └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘

INTERACTION:
  1. Click price level → sets Entry (orange dotted line)
  2. Drag line UP from entry → sets Take-Profit (green dashed)
  3. Drag line DOWN from entry → sets Stop-Loss (red dashed)
  4. Summary bar appears at bottom showing full order details
  5. Sizing Guide automatically calculates based on SL distance
  6. [Confirm] → executes order | [Adjust in Panel] → transfers to W4

LINE DRAGGING:
  - Drag any line (entry/SL/TP) to adjust price
  - Summary updates in real-time as lines move
  - ATR context shows on SL line: "1.2 ATR ✅"
  - Risk/Reward ratio updates dynamically

VISUAL CUES:
  - Green shaded area between entry and TP (profit zone)
  - Red shaded area between entry and SL (risk zone)
  - Width of shaded area = visual risk/reward proportion
```

### 5.3 Calculation Logic

```
VISUAL ORDER BUILDER SIZING:

ON SL PLACEMENT:
  stop_distance_pct = abs(entry_price - sl_price) / entry_price
  stop_distance_ATR = abs(entry_price - sl_price) / ATR_14

  // Auto-compute position size at user's default risk %
  default_risk_pct = user_settings.default_risk_pct  // e.g., 0.02 (2%)
  position_size = (balance × default_risk_pct) / stop_distance_pct
  leverage = position_size / balance

ON TP PLACEMENT:
  profit_distance_pct = abs(tp_price - entry_price) / entry_price
  risk_reward_ratio = profit_distance_pct / stop_distance_pct

DISPLAY:
  Update summary bar with all computed values in real-time
  ATR context updates as SL moves
  R:R ratio updates as TP moves
```

---

## 6. POSITIONS WIDGET (W6)

> **v2.1 Amendment (per 3-5):** Liquidation Distance is now the PRIMARY safety metric, displayed before P&L. Funding cost column added. Aligns with mobile C1 position card changes.

### 6.1 Wireframe

```
┌─ Positions ────────────────────── [⚪] [⚙] [—] [×] ─┐
│ Open: 4 positions | Total P&L: +$1,842 (+3.7%)       │
├──────┬────┬───────┬────────┬──────────┬─────────┬────────┬───────────────┤
│Asset │Side│Entry  │Current │Liq Dist  │  P&L    │Funding │Wallet         │
│      │    │Price  │Price   │(PRIMARY) │         │Cost    │Alignment      │
├──────┼────┼───────┼────────┼──────────┼─────────┼────────┼───────────────┤
│ ETH  │🟢 L│$3,280 │$3,420  │🟢 $530   │+$420    │$2.80/8h│4 wallets match│
│ 3x   │    │       │        │  (15.5%) │(+4.3%)  │        │same direction │
├──────┼────┼───────┼────────┼──────────┼─────────┼────────┼───────────────┤
│ BTC  │🟢 L│$66,800│$67,420 │🟢 $13,400│+$1,240  │$4.20/8h│2 wallets match│
│ 2x   │    │       │        │  (19.9%) │(+1.9%)  │        │same direction │
├──────┼────┼───────┼────────┼──────────┼─────────┼────────┼───────────────┤
│ SOL  │🔴 S│$145   │$142    │🟡 $16.80 │+$360    │$0.90/8h│1 wallet match │
│ 5x   │    │       │        │  (11.8%) │(+2.1%)  │        │same direction │
├──────┼────┼───────┼────────┼──────────┼─────────┼────────┼───────────────┤
│DOGE  │🟢 L│$0.138 │$0.142  │🔴 $0.009 │-$178    │$1.50/8h│0 wallets match│
│ 10x  │    │       │        │  (6.3%)  │(-2.9%)  │        │(isolated)     │
├──────┴────┴───────┴────────┴──────────┴─────────┴────────┴───────────────┤
│ Unrealized: +$1,842 │ Funding: -$9.40/8h │ Funding (cumul): -$84.60     │
│ Margin used: $8,420 │ Available: $4,030                                  │
│ Regime: 🟢 Trending Up (2 positions aligned, 1 misaligned)              │
└──────────────────────────────────────────────────────────────────────────┘

COLUMN DETAILS:
  Asset:    Symbol + leverage badge
  Side:     🟢 L (Long) or 🔴 S (Short) with color
  Entry:    Average entry price
  Current:  Live market price (real-time)
  Liq Distance (v2.1 — PRIMARY):
            Dollar amount + percentage to liquidation price
            Color-coded zones:
            - 🟢 >20%: Safe (green)
            - 🟡 10-20%: Caution (amber)
            - 🔴 <10%: Danger (red, pulsing row border)
            Hover: shows exact liq price + "You have $X buffer"
  P&L:      Dollar amount + percentage (green/red color)
  Funding Cost (v2.1 — NEW):
            Cost per 8h funding interval
            Hover: daily cost, annualized %, cumulative since open
            Warning icon if annualized >50%
  Wallet Alignment (v2.0):
            Shows count of followed wallets with matching direction
            Hover for breakdown: "4 All-Weather wallets long"

REGIME ALIGNMENT:
  Regime indicator shows current regime state
  Breakdown: "2 positions aligned, 1 misaligned"
  When regime shifts since position entry:
    Row background: subtle amber tint
    Tooltip: "Regime shifted since you entered this position.
             Consider reviewing your thesis."
    Wallet consensus change also noted in expanded view
```

### 6.2 Position Detail (Row Expansion)

```
CLICK ROW → Expands to show detail:
┌──────────────────────────────────────────────────┐
│ ▼ ETH — Long 3x (Isolated)                      │
├──────────────────────────────────────────────────┤
│ 🟢 LIQ DISTANCE: $530 (15.5% from liq)  ← Hero │
│ Liq. Price: $2,890 │ Buffer: $530                │
│                                                    │
│ Entry: $3,280.00 │ Current: $3,420.00 │ Size: $7,812│
│ Stop-Loss: $3,180 (-3.0%) │ TP: $3,650 (+11.3%)    │
│ P&L: +$420 (+4.3%)                                │
│                                                    │
│ FUNDING COST (v2.1):                               │
│ Rate: -$2.80/8h │ Daily: -$8.40 │ Annualized: 39%  │
│ Cumulative since open: -$16.80 (2d 4h)            │
│                                                    │
│ Duration: 2d 4h │ Signal: @CryptoSurgeon           │
│ Regime at entry: 🟢 Trending Up                    │
│ Current regime: 🟢 Trending Up (same)              │
│ Sizing Guide: $7,812 (15.5%) │ Actual: $7,812 ✅   │
│                                                    │
│ Wallet Alignment (v2.0):                           │
│ 4 All-Weather wallets long ETH                     │
│ 7 total followed wallets aligned (78% consensus)   │
│ Consensus change: No shift since entry             │
│                                                    │
│ [Adjust SL/TP]  [Add to Position]  [Close Position]│
└──────────────────────────────────────────────────┘
```

### 6.3 Interactions

| Action                   | Behavior                                                |
| ------------------------ | ------------------------------------------------------- |
| Click row                | Expand/collapse position detail                         |
| Double-click asset       | Opens chart widget with that symbol                     |
| Right-click row          | Context menu: Close, Adjust, View in chart, View signal |
| Click "Wallet Alignment" | Shows breakdown of wallets with matching direction      |
| Hover Safety gauge       | Tooltip: exact % + liquidation price + distance         |
| Sort column header       | Click to sort ascending/descending                      |

---

## 7. TRADE HISTORY WIDGET (W7)

### 7.1 Wireframe

```
┌─ Trade History ──────────────── [⚪] [⚙] [—] [×] ─┐
│ [All] [Winners] [Losers] │ Period: [90d ▾] [Export]   │
│ [Regime: All ▾] [Type: All ▾] [Sizing: All ▾]        │
│ [Wallet-Aligned ▾] (NEW v2.0)                        │
├──────┬─────┬──────┬───────┬───────┬──────┬────────┬─────────┤
│Date  │Asset│Side  │P&L    │Regime │Regime│Sizing  │Wallet   │
│      │     │      │       │@Entry │@Exit │Adherence│Alignment│
│      │     │      │       │       │      │         │(NEW)    │
├──────┼─────┼──────┼───────┼───────┼──────┼────────┼─────────┤
│Feb 28│ETH  │🟢 L  │+$420  │🟢    │🟢   │✅ Fol. │4 wallets│
│      │     │      │(+5.4%)│      │      │$7,812  │aligned  │
├──────┼─────┼──────┼───────┼───────┼──────┼────────┼─────────┤
│Feb 26│BTC  │🔴 S  │-$280  │🟢    │🟡   │⚠ +35%  │2 wallets│
│      │     │      │(-2.1%)│      │      │over    │against  │
│      │     │      │       │      │      │guide   │         │
├──────┼─────┼──────┼───────┼───────┼──────┼────────┼─────────┤
│Feb 24│SOL  │🟢 L  │+$1,120│🟡    │🟢   │✅ Fol. │3 wallets│
│      │     │      │(+8.2%)│      │      │$5,200  │aligned  │
├──────┼─────┼──────┼───────┼───────┼──────┼────────┼─────────┤
│Feb 22│AVAX │🟢 L  │-$450  │🔵    │🔵   │❌ Ignore│0 wallets│
│      │     │      │(-6.1%)│      │      │$0 (no) │aligned  │
├──────┴─────┴──────┴───────┴───────┴──────┴────────┴─────────┤
│ Summary: 47 trades │ Win: 58% │ Avg: +$142                  │
│ Regime-aligned: 72% win │ Regime-misaligned: 38% win        │
│ Sizing followed: 71% win │ Over guide: 52% win              │
│ Wallet-aligned trades: 68% win (18 trades)                  │
└────────────────────────────────────────────────────────────┘

FILTERS:
  [Regime: All ▾] → All | Trending Up | Trending Down | Range-bound | Transition | Compression | Crisis
  [Type: All ▾]   → All | AI Strategy | Direct | Follow | Carry
  [Sizing: All ▾] → All | Followed Guide | Over Guide | Under Guide | No Guide
  [Wallet-Aligned ▾] (NEW v2.0) → All | Aligned | Against | No consensus

EXPORT:
  [Export ▾] → CSV | PDF Report | Clipboard

WALLET ALIGNMENT COLUMN (NEW v2.0):
  Shows count of followed wallets with same position direction at entry time
  Examples:
    "4 wallets aligned" = 4 wallets were long/short the same asset
    "2 against" = 2 wallets were shorting while you were longing
    "0 aligned" = no wallet consensus at entry

SIZING ADHERENCE COLUMN:
  ✅ Followed: position size was within ±10% of Sizing Guide recommendation
  ⚠ +X% over guide: position size exceeded recommendation by X%
  ⚠ -X% under guide: position size was below recommendation by X%
  ❌ Ignored: no Sizing Guide was available or user traded without following

SUMMARY BAR:
  Shows aggregate stats with regime, sizing, and wallet alignment cross-analysis
  New metric: "Wallet-aligned trades: 68% win" provides behavioral insight
```

### 7.2 Interactions

| Action                          | Behavior                                                      |
| ------------------------------- | ------------------------------------------------------------- |
| Click row                       | Expand to show full trade details + belief capture            |
| Click regime badge              | Filter table to that regime                                   |
| Sort any column                 | Sort ascending/descending                                     |
| Click "Regime-aligned: 72% win" | Opens Copilot: "Tell me more about my regime performance"     |
| Click "Wallet-aligned" filter   | Filter to trades where followed wallets aligned with position |
| Export CSV                      | Downloads complete trade history with all columns             |
| Export PDF                      | Generates formatted trade journal report                      |

### 7.3 Trade Expansion with Belief Capture (NEW v2.0)

```
CLICK TRADE ROW → Expands to show full details:
┌──────────────────────────────────────────────────────┐
│ ▼ Feb 28 · ETH · Long 3x · +$420 (+5.4%)            │
├──────────────────────────────────────────────────────┤
│                                                      │
│ Entry: $3,420.00 (Limit) │ Entry time: Feb 28, 9:42 AM│
│ Exit: $3,520.00 (Market) │ Exit time: Feb 28, 2:15 PM │
│ Duration: 4h 33m        │ Funding paid: -$1.80       │
│                                                      │
│ ─ POSITION CONTEXT ────────────────────────────────  │
│ Regime at entry: 🟢 Trending Up                      │
│ Regime at exit: 🟢 Trending Up (same)                │
│ Sizing: $7,812 (Followed guide, +0%)                 │
│                                                      │
│ ─ WALLET ALIGNMENT ────────────────────────────────  │
│ 4 All-Weather wallets long ETH at entry              │
│ 2 Specialists long at entry                          │
│ Overall consensus: Bullish (78%)                     │
│                                                      │
│ ─ BELIEF CAPTURE (NEW v2.0) ──────────────────────   │
│ Conviction: 85%                                      │
│ Thesis: Price broke above $3,400 resistance.         │
│         Strong institutional accumulation detected   │
│         (OI surge + whale flow alignment).           │
│                                                      │
│ Invalidation rule: Close if price falls below $3,280 │
│                   (breaks recent support)            │
│                                                      │
│ Time horizon: 12-24 hours                            │
│                                                      │
│ Linked signals:                                      │
│  • 🔴 P4 STRUCTURAL: OI surge +$340M (2.7σ)         │
│  • 🟢 P2 PARTICIPANT: @CryptoSurgeon long ETH        │
│  • 🟡 P3 INSTRUMENT: Positive funding (carry)        │
│                                                      │
│ [Close Trade]  [Reopen]  [Pin to Journal]            │
└──────────────────────────────────────────────────────┘

BELIEF CAPTURE FIELDS (NEW v2.0):
  Conviction (%):    Your confidence level at entry (0-100%)
  Thesis:            The reason/narrative behind the trade
  Invalidation rule: Under what condition the trade thesis breaks
  Time horizon:      How long you expected to hold
  Linked signals:    Which P-layer signals triggered the trade
```

---

## 8. SYMBOL OVERVIEW WIDGET (W17)

This widget adapts mobile's C3 (Symbol Deep-Dive) into a compact panel showing key metrics.

### 8.1 Wireframe

```
┌─ Symbol: ETH ──────────────── [🔴] [⚙] [—] [×] ─┐
│ ETH/USDT  $3,420.00  ↑2.3%  │ 🟢 Trending Up      │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ── KEY METRICS ──────────────────────────────────── │
│ 24h Volume: $4.2B    │ Market Cap: $412B            │
│ 24h Range: $3,340-$3,445 │ ATR(14): $82.30         │
│                                                     │
│ ── PERPS DATA ───────────────────────────────────── │
│ Funding: +0.035%/8h (38% ann.)  ⚡ Elevated         │
│ Open Interest: $8.2B (+$340M 24h)                   │
│ Long/Short Ratio: 1.42 (72% long)                   │
│ Basis: +0.8% (healthy premium)                      │
│                                                     │
│ ── REGIME CONTEXT ───────────────────────────────── │
│ Current: 🟢 Trending Up (ADX: 31.2, Hurst: 0.62)   │
│ Duration: 2 days in current regime                  │
│ Best strategy: Momentum, buy pullbacks              │
│ Sizing rule: Full half-Kelly                        │
│                                                     │
│ ── SMART MONEY (NEW v2.0) ────────────────────────  │
│ 4 All-Weather wallets actively long ETH             │
│ 2 Specialists adding positions                      │
│ Net direction: Bullish (6/8 tracked wallets)        │
│ Recent activity: 3 wallets accumulated in last 4h   │
│                                                     │
│ ── SIGNALS (4 active) ───────────────────────────── │
│ ⚡ P4 STRUCTURAL: Funding z=2.1 (carry opportunity) │
│ 📈 P4 STRUCTURAL: OI surge +$340M (conviction)      │
│ 🐋 P2 PARTICIPANT: Whale flow +$28M net inflow      │
│ 🛡️ P2 PARTICIPANT: 3 All-Weather wallets long       │
│                                                     │
│ [🤖 AI Strategy →]  [📝 Direct Trade →]             │
│ [📊 Full Confluence →]  [🤖 Ask Copilot →]          │
└─────────────────────────────────────────────────────┘

DESKTOP ENHANCEMENT vs MOBILE C3:
  - ALL tab content visible simultaneously (mobile shows one tab at a time)
  - Regime context section with indicators visible inline
  - Smart Money activity section (NEW v2.0) showing wallet alignment
  - P-layer labels on signals (P1-P5 mapped correctly)
  - Direct links to trading and analysis actions
```

---

## 9. SIGNAL CARDS WIDGET (W14)

### 9.1 Wireframe

```
┌─ Signals ──────────────────── [🔴] [⚙] [—] [×] ─┐
│ [All] [🔥 Hot] [⚡ Anomaly] [🐋 Whale] [💰 Funding]│
│ P-Layer Filter: [All ▾] [P1] [P2] [P3] [P4] [P5]    │
│ Regime fit: [All ▾]  │ Classification: [All ▾]      │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ┌─── ETH ─ 🔴 P4 STRUCTURAL ─ 12 min ago ────────┐ │
│ │ ⚡ OI surge: +$340M in 4h (2.7σ)                │ │
│ │ Regime fit: ✅ Trending Up aligns               │ │
│ │ "Large position building without proportional    │ │
│ │ price movement — informed accumulation pattern"  │ │
│ │ Historical: preceded +3-5% move 71% of time     │ │
│ │ [🤖 Trade This →]  [📊 Details →]               │ │
│ └─────────────────────────────────────────────────┘ │
│                                                     │
│ ┌─── BTC ─ 🟢 P2 PARTICIPANT ─ 45 min ago ───────┐ │
│ │ 🛡️ @CryptoSurgeon opened Long BTC              │ │
│ │ Gate: ✅✅✅ | Sizing: $12,500 (25%)             │ │
│ │ Regime fit: ✅ Current regime = best for them    │ │
│ │ [Follow Trade →]  [View Profile →]              │ │
│ └─────────────────────────────────────────────────┘ │
│                                                     │
│ ┌─── ETH ─ 🟡 P3 INSTRUMENT ─ 2h ago ──────────┐  │
│ │ 💰 Funding rate elevated: +0.035%/8h (z=2.1)  │  │
│ │ "38% annualized — carry opportunity available"  │  │
│ │ Regime fit: ⚠ Works in any regime               │  │
│ │ [Open Carry Strategy →]  [Details →]            │  │
│ └─────────────────────────────────────────────────┘  │
│                                                     │
│ ... more signals                                    │
└─────────────────────────────────────────────────────┘
```

### 9.2 Signal Types and P-Layer Mapping (NEW v2.0)

| Type            | Icon       | P-Layer        | Source                                               | Example                                     |
| --------------- | ---------- | -------------- | ---------------------------------------------------- | ------------------------------------------- |
| Anomaly         | ⚡         | P4 STRUCTURAL  | Statistical anomaly detection + GenAI interpretation | OI surge, funding extreme, volume spike     |
| Wallet          | 🛡️🎯📉🍀🤖 | P2 PARTICIPANT | Followed/watched wallet activity                     | Trade opened, closed, thesis update         |
| Funding         | 💰         | P3 INSTRUMENT  | Funding rate monitor                                 | Rate extreme, carry opportunity             |
| Whale           | 🐋         | P2 PARTICIPANT | Large wallet movement detection                      | Net inflow/outflow to exchanges             |
| Technical       | 📈         | P5 PATTERN     | Pattern recognition (Stage 1)                        | Breakout, support test, divergence          |
| Confluence      | 📊         | P1 REGIME      | Confluence score threshold (Tier 2)                  | Score crossed 70 or dropped below 30        |
| Narrative/Macro | 🎙️         | P1 REGIME      | News aggregation + GenAI                             | Policy change, macro event, sentiment shift |
| Liquidation     | ⚠️         | P4 STRUCTURAL  | Liquidation cascade monitor                          | Cascade detected, distribution building     |

**NEW v2.0 Features:**

- **P-Layer Label Display:** Every signal card displays its P-layer classification: `🔴 P4 STRUCTURAL`, `🟢 P2 PARTICIPANT`, etc.
- **P-Layer Filter Dropdown:** In W14 header, add filter selector allowing users to show: [All] [P1] [P2] [P3] [P4] [P5]
- **Color Coding by P-Layer:**
  - P1 REGIME: 🟡 Amber
  - P2 PARTICIPANT: 🟢 Green
  - P3 INSTRUMENT: 🟠 Orange
  - P4 STRUCTURAL: 🔴 Red
  - P5 PATTERN: 🔵 Blue

---

## 10. WIDGET INTERACTION FLOWS

### 10.1 Flow: "I want to trade a signal I see"

```
Signal Cards (W14) → user clicks [🤖 Trade This →]
  → Order Entry (W4) opens/focuses in AI Strategy mode
  → Pre-filled with: signal asset, direction, sizing recommendation
  → Wallet Consensus displayed (Step 2.5)
  → User reviews → adjusts if needed → [Execute]
  → Position appears in Positions (W6) with wallet alignment
  → Chart (W2) shows entry line if linked to same symbol
```

### 10.2 Flow: "I want to follow a wallet's trade"

```
Radar Feed (W10) or Wallet Profile (W8) → user clicks [Follow Trade →]
  → Gate evaluation shown (if not already visible)
  → Order Entry (W4) opens in AI Strategy mode
  → Pre-filled with: wallet's trade, Sizing Guide amount
  → Wallet Consensus shown (Step 2.5): followed wallet + aligned wallets
  → User reviews gates ✅✅✅ + sizing → [Execute]
  → Follow Dashboard (W9) updates
  → Notification sent to wallet watchlist
```

### 10.3 Flow: "I want to analyze a symbol deeply"

```
Watchlist (W1) → click "ETH"
  → All 🔴-linked widgets update to ETH:
    Chart (W2): switches to ETH candlestick
    Order Book (W3): switches to ETH depth
    Symbol Overview (W17): shows ETH metrics + Smart Money section
    Confluence Panel (W15): recalculates for ETH
    Signal Cards (W14): filters to ETH signals (P1-P5 taxonomy visible)
  → User sees complete ETH picture across all panels simultaneously
```

### 10.4 Flow: "I want to compare two assets"

```
Setup: Link Chart 1 + Order Book 1 to 🔴
       Link Chart 2 + Order Book 2 to 🔵

Watchlist (W1): click ETH → 🔴 group shows ETH
Watchlist (W1): hold ⌘ + click BTC → 🔵 group shows BTC

Result: Side-by-side ETH and BTC analysis with independent charts
```

### 10.5 Flow: "I want to set up a carry trade"

```
Signal Cards (W14) → sees 💰 P3 INSTRUMENT Funding signal → [Open Carry Strategy →]
  → Carry Strategy (W16) opens/focuses
  → Shows current funding, yield calculation, risk factors
  → User reviews → [Open Carry Position]
  → Two orders placed (short perp + long spot)
  → Both legs appear in Positions (W6) as linked pair with wallet alignment
  → Carry Strategy widget shows active carry with earnings tracker
```

### 10.6 Flow: "I want to review my trade beliefs"

```
Trade History (W7) → user clicks row to expand
  → Trade details show entry/exit info
  → NEW: Belief Capture section displays:
    - Conviction % at entry
    - Original thesis
    - Invalidation rule
    - Time horizon
    - Linked signals (P1-P5 labeled)
  → User can reflect on decision-making process
  → Insights inform future trade setups
```

---

## APPENDIX: 6-REGIME MODEL COLOR REFERENCE

Use these colors consistently across all widgets when displaying regime state:

| Regime        | Hex Color | RGB            | Use Case                        |
| ------------- | --------- | -------------- | ------------------------------- |
| Trending Up   | #10B981   | (16, 185, 129) | Emerald — momentum favored      |
| Trending Down | #EF4444   | (239, 68, 68)  | Red — downtrend conditions      |
| Range-bound   | #3B82F6   | (59, 130, 246) | Blue — consolidation phase      |
| Transition    | #F59E0B   | (245, 158, 11) | Amber — regime change pending   |
| Compression   | #0D9488   | (13, 148, 136) | Teal — volatility contracting   |
| Crisis        | #EA580C   | (234, 88, 12)  | Deep Orange — market stress     |

**Display Convention:**

- Regime Bars: Full background colored band
- Regime Chips: Icon + label + color dot (e.g., "🟢 Trending Up")
- Regime Transitions: Vertical dashed line with color change (e.g., "T↑ → R")
- Regime Columns: Background tint (light shade of hex color)

---

## APPENDIX: P1-P5 SIGNAL INTELLIGENCE LAYER REFERENCE

When labeling signals, use these layer mappings consistently:

| P-Layer | Name                     | Color Icon | Signal Types                                                  | Key Example                                                            |
| ------- | ------------------------ | ---------- | ------------------------------------------------------------- | ---------------------------------------------------------------------- |
| P1      | REGIME Intelligence      | 🟡 Amber   | Narrative, Macro confluence, Market regime changes            | "Market in Trending Up — momentum strategies favored"                  |
| P2      | PARTICIPANT Intelligence | 🟢 Green   | Wallet activity, Smart money moves, whale flows               | "@CryptoSurgeon opened long BTC", "3 All-Weather wallets accumulating" |
| P3      | INSTRUMENT Intelligence  | 🟠 Orange  | Funding rates, basis, IV, open interest                       | "Funding elevated +0.035%/8h — carry opportunity"                      |
| P4      | STRUCTURAL Intelligence  | 🔴 Red     | OI surges, liquidation cascades, volume anomalies, taker buys | "OI surged +$340M in 4h (2.7σ) — smart money positioning"              |
| P5      | PATTERN Intelligence     | 🔵 Blue    | Technical analysis, candlestick patterns, support/resistance  | "Breakout above $3,400 resistance", "Divergence on RSI"                |

**Display Convention:**

- Signal Card Header: `[Color Icon] P[N] [LAYER NAME] · [Asset] · [Time]`
- Filter Dropdown: `[All] [P1] [P2] [P3] [P4] [P5]`
- Linked Signals in Trade Expansion: List all signals with P-layer labels

---

_ARX DESKTOP PSEUDO-PROTOTYPE v2.0 — Part 2: Trading & Analysis Widgets_
_Confidential — Product & Design_
_March 2, 2026_
