# ARX DESKTOP APP — PSEUDO-PROTOTYPE v2.0

> **STATUS: DEFERRED** — Desktop is not in the current build cycle. These specs reference Design System v1.0/v2.0 (Electric Cyan era) and are palette-incompatible with the current v5.7 (Citadel & Moat). When desktop becomes a build target, these specs must be updated to reference `Arx_4-2_Design_System.md` v5.7+ for all color tokens, regime colors, and component patterns. Do not use these specs for current design or engineering decisions.

## Part 1: Foundation (Competitive Synthesis · Design Tokens · Dark Mode · Typography · Spacing · Widget Architecture · Layout System · Regime Bar · Wallet Classification · Sizing Guide · Three-Gate · Tier 2 Selection · Navigation · Keyboard Shortcuts · Onboarding · Animations)

> **Version:** v2.0 — Integrates Design System v1.0, Executable Spec v1.0, Radar rename, 6-regime model
> **Baseline:** v1.0 (1,168 lines, desktop parity with mobile v1.3 + Tier 2 features)
> **New in v2.0:** Design tokens, dark mode spec, typography scale, spacing grid, Radar rename (4 instances), 6-regime model with directional trending, confidence % in regime bar, Design Token Reference, Naming Conventions, Confluence Panel P1-P5 taxonomy, updated Onboarding Step 3 with 6 regimes, Layout Preset "Alpha" → "Radar"
> **Date:** March 2, 2026

---

## v2.0 CHANGE SUMMARY

| #   | Change                     | What's New                                                                                                                           | Calculation Updated         | Sections Affected                                                                                  |
| --- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | --------------------------- | -------------------------------------------------------------------------------------------------- |
| 1   | Radar Rename               | "Alpha Feed" → "Radar Feed", "Alpha Network" → "Radar Network", Layout preset "Alpha" → "Radar", all 3 instances renamed             | N/A                         | Widget Inventory (W10), Layout Presets (section 4.4), Naming Conventions, Tier 2 Feature Selection |
| 2   | 6-Regime Model             | Trending split into Up/Down, added directional detection logic                                                                       | ADX + price vs SMA_20 logic | Regime Bar Architecture, Stage 1 Logic, Regime Bar Interaction                                     |
| 3   | Design Token Reference     | Full hex color mapping for all palettes (Background, Text, Accent, Regime, Semantic)                                                 | N/A                         | NEW section after Regime Bar                                                                       |
| 4   | Dark Mode Specification    | Primary dark theme (traders), glassmorphism layers with blur spec                                                                    | N/A                         | NEW section after Design Tokens                                                                    |
| 5   | Typography Scale           | Inter for UI, JetBrains Mono for numbers; desktop-specific sizes (can exceed mobile)                                                 | N/A                         | NEW section after Dark Mode                                                                        |
| 6   | Spacing Grid               | 4px base grid, desktop layout rules (12-column grid), gap patterns                                                                   | N/A                         | NEW section after Typography                                                                       |
| 7   | Confidence % in Regime Bar | Tap shows "TRENDING ↑ (72%)" with duration and certainty                                                                             | Stage 2+: add confidence    | Regime Bar Interaction, Stage 2 specs                                                              |
| 8   | Naming Conventions         | Add row: "Alpha Network" → "Radar Network", new table with v1.0 → v2.0 mappings                                                      | N/A                         | NEW section after three-gate                                                                       |
| 9   | Confluence Panel P1-P5     | Explicit signal taxonomy: P1 Regime, P2 Participant, P3 Instrument, P4 Structural, P5 Pattern (formerly "Context")                   | N/A                         | Tier 2 Feature Selection (Confluence sub-section)                                                  |
| 10  | Onboarding Step 3          | Carousel updated to show 6 regime states (instead of 5), updated 5th concept from "Copilot" to "Radar Network" (track smart traders) | N/A                         | Onboarding Section                                                                                 |
| 11  | File Metadata              | Title, subtitle, version line, date all updated to v2.0                                                                              | N/A                         | Header section                                                                                     |

---

## TABLE OF CONTENTS — PART 1

1. Competitive Synthesis & Desktop Differentiation
2. Desktop Jobs-to-Be-Done (vs. Mobile)
3. Desktop Design Principles
4. Widget Architecture & Layout System
5. Regime Bar — Desktop Adaptation
6. Design Token Reference
7. Dark Mode Specification
8. Typography Scale
9. Spacing Grid
10. Wallet Classification — Desktop Adaptation
11. Sizing Guide — Desktop Adaptation
12. Three-Gate Framework — Desktop Adaptation
13. Naming Conventions & Terminology
14. Tier 2 Feature Selection for Desktop
15. Global Navigation & Chrome
16. Keyboard Shortcut System
17. Onboarding Experience & Flows
18. Animation & Transition Specifications

---

## 1. COMPETITIVE SYNTHESIS & DESKTOP DIFFERENTIATION

### 1.1 Platforms Analyzed

| Platform               | Type                   | Strength                                                                                         | Weakness (for Arx's user)                                                                        |
| ---------------------- | ---------------------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| **Robinhood Legend**   | Retail equities/crypto | Beautiful layout system (8 layouts), widget linking, drag-price orders, accessible               | No on-chain intelligence, no wallet following, no regime awareness, crypto is afterthought       |
| **Webull Desktop**     | Retail equities/crypto | 45+ widgets, granular sync control, hotkey system, community layouts                             | Information density overwhelming for new users, no AI intelligence layer, crypto not first-class |
| **Definitive Finance** | Institutional DeFi     | Gas abstraction, smart order routing, privacy-first execution, institutional-grade TWAP          | Not retail-friendly, no social/copy-trading, no education layer, vault-based not dashboard-based |
| **InSilico Terminal**  | Pro crypto trading     | Triple interface (GUI+CLI+hotkeys), Designer Mode for visual orders, multi-account orchestration | Steep learning curve, no AI intelligence, no wallet classification, minimal UX polish            |

### 1.2 Pattern Extraction — What Arx Desktop Should Adopt

**From Robinhood Legend:**

- ✅ Multi-layout system (save, name, switch layouts) — up to 6 layouts
- ✅ Widget linking via color-coded groups (change symbol → all linked widgets update)
- ✅ Layout-as-state-management (one layout for monitoring, one for active trading)
- ✅ Context-driven order entry (order from chart, from watchlist, from position)
- ❌ Skip: Ladder widget (too advanced for retail), drag-price orders (perps complexity)

**From Webull Desktop:**

- ✅ Granular sync control (choose WHAT synchronizes: symbol, timeframe, indicators)
- ✅ Preset layouts with templates ("Monitoring", "Active Trading", "Analysis")
- ✅ Widget layering with tabs (stack widgets, switch between them)
- ✅ Cross-device sync (desktop watchlists = mobile watchlists)
- ❌ Skip: 45+ widgets (too many — Arx curates ~18 purpose-built widgets)

**From Definitive Finance:**

- ✅ Chain/gas abstraction (user never sees gas complexity)
- ✅ Vault-based sub-account concept → adapt as "Strategy Workspaces"
- ✅ Real-time fill analysis and post-trade reporting
- ✅ Privacy-first execution model (no front-running)
- ❌ Skip: Role-based access (retail single-user), institutional approval flows

**From InSilico Terminal:**

- ✅ Designer Mode concept → adapt as "Visual Order Builder" on chart
- ✅ Keyboard shortcut system for power users (progressive reveal)
- ✅ Grouped component synchronization
- ❌ Skip: CLI interface (too technical for retail), multi-account orchestration

### 1.3 Arx Desktop's Unique Positioning

Arx's desktop position: "Smart Simple"

- Simpler than Webull/InSilico (curated widgets, not overwhelming)
- Smarter than Robinhood Legend (Regime Bar, Wallet Classification, Sizing Guide, Copilot)
- More retail-friendly than Definitive (social features, education, progressive disclosure)
- More crypto-native than all (on-chain wallet intelligence is core, not bolt-on)

### 1.4 The Desktop Value Equation

```
Desktop Value = Mobile Intelligence × Desktop Canvas × Multi-Task Efficiency

Where:
  Mobile Intelligence = Regime Bar + Classification + Sizing Guide + Three-Gate + Copilot
  Desktop Canvas     = Side-by-side panels, multi-chart, persistent watchlist
  Multi-Task         = Monitor 4+ tickers, compare wallets, trade while analyzing
```

---

## 2. DESKTOP JOBS-TO-BE-DONE (vs. Mobile)

### 2.1 What Mobile Does Well (Keep)

- Quick glance at portfolio health
- Receive and act on single notifications
- Follow a wallet with one tap
- Check a single position
- Copilot conversation

### 2.2 What Desktop Must Do Better (Incremental Value)

| #   | Job-to-Be-Done                                          | Why Mobile Fails                                 | Desktop Solution                                                    |
| --- | ------------------------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------- |
| J1  | **Monitor multiple assets simultaneously**              | Single-screen focus; tab-switching loses context | Multi-chart widget grid with linked watchlist                       |
| J2  | **Compare wallets side-by-side before follow decision** | Can only view one D2 profile at a time           | Split-panel wallet comparison view                                  |
| J3  | **Trade while monitoring other positions**              | Trading screen (C4) replaces everything else     | Persistent position panel + docked order entry                      |
| J4  | **Deep technical analysis with drawing tools**          | Pinch-to-zoom on phone is imprecise              | Full chart panel with crosshair, indicators, Fibonacci, trend lines |
| J5  | **Review trade history with regime context**            | TH1 is a scrollable list; hard to see patterns   | Filterable table with regime columns, sortable, exportable          |
| J6  | **Manage multiple follow relationships at once**        | D4 is a card list; adjustments are sequential    | Table view with inline editing, bulk actions                        |
| J7  | **Research a symbol deeply before trading**             | C3 tabs are sequential (one tab visible)         | All C3 tabs visible simultaneously in panels                        |
| J8  | **Run Copilot alongside everything else**               | G1 is an overlay that covers content             | Persistent Copilot sidebar that doesn't hide content                |
| J9  | **Configure personalized dashboard**                    | Fixed layout, no customization                   | Drag-and-drop widgets, save layouts, preset templates               |
| J10 | **Keyboard-driven rapid actions**                       | Touch-only interface                             | Keyboard shortcuts for search, navigation, order entry              |

### 2.3 Desktop-Exclusive Features (Not on Mobile)

| Feature                           | Description                                                   | Competitive Reference   |
| --------------------------------- | ------------------------------------------------------------- | ----------------------- |
| **Widget System**                 | 18 purpose-built widgets, drag-drop, resize, link             | Legend + Webull pattern |
| **Layout Presets**                | 4 preset + 6 custom layouts, named, switchable                | Legend (8 layouts)      |
| **Multi-Chart Grid**              | Up to 4 charts with independent timeframes/symbols            | Webull grid charts      |
| **Wallet Comparison**             | Side-by-side wallet profiles with gate overlay                | Arx-exclusive           |
| **Docked Copilot**                | Persistent right-sidebar, doesn't overlay content             | Arx-exclusive           |
| **Visual Order Builder**          | Click chart to place orders, drag to adjust SL/TP             | InSilico Designer Mode  |
| **Keyboard Shortcuts**            | Progressive shortcut system (basic → power)                   | InSilico + Webull       |
| **Export/Report**                 | Export trade history, portfolio snapshots, follow performance | Definitive reporting    |
| **Confluence Dashboard** (Tier 2) | P1-P5 visual breakdown with weighted scoring                  | GenAI Spec Feature 2.6  |
| **Carry Strategy Panel** (Tier 2) | Delta-neutral funding arbitrage with one-click setup          | GenAI Spec Feature 2.7  |

---

## 3. DESKTOP DESIGN PRINCIPLES

### 3.1 Inherited from Mobile v1.3 (All 19 Apply)

Principles #1-19 from mobile carry forward. Desktop-specific adaptations noted:

| #   | Principle                     | Desktop Adaptation                                                                  |
| --- | ----------------------------- | ----------------------------------------------------------------------------------- |
| 1   | Signal-First, Not Chart-First | Signals appear in watchlist widget AND chart annotations — not just cards           |
| 3   | Progressive Disclosure        | Desktop allows MORE disclosed by default (more panels visible)                      |
| 5   | One Primary Action Per Screen | Relaxed — desktop users manage multiple parallel actions                            |
| 6   | Cognitive Load Budget         | Increased to 7-9 chunks per visible area (monitor size)                             |
| 10  | Mobile-Native Gestures        | Replaced by mouse + keyboard interactions (right-click, drag, hover)                |
| 17  | Watchlist as Home Base        | Watchlist is a PERSISTENT SIDEBAR, always visible, not just a card                  |
| 18  | Regime as Context Layer       | Regime Bar remains the single most important piece of context on any desktop screen |
| 19  | Protective Intelligence       | Three-Gate, Classification badges, and Sizing Guide prevent bad follow decisions    |

### 3.2 NEW Desktop-Only Principles

**#20 — Composable Workspace**
The desktop is not a fixed layout but a composable workspace. Users arrange widgets to match their workflow. Preset layouts provide smart defaults; customization provides power. The system should feel like arranging a physical desk.

**#21 — Linked Context Propagation**
Selecting a symbol in one widget propagates to all linked widgets in the same group. Link groups are color-coded (🔴🔵🟢🟡) and user-configurable. Eliminates repetitive navigation and keeps users in flow.

**#22 — Keyboard-First, Mouse-Always**
Every action achievable by mouse is also achievable by keyboard for power users. Keyboard shortcuts are progressive — basic users never need to learn them. The system works perfectly with mouse alone.

**#23 — Persistent Peripheral Awareness**
Important context (Regime Bar, positions, watchlist, Copilot) is always visible in the periphery, not hidden behind navigation. Users glance and know their state without clicking.

**#24 — Desktop Density Without Desktop Complexity**
More information fits on desktop. But more information ≠ more complexity. Every additional data point must earn its screen space by being actionable. Density is a privilege of the canvas, not an obligation.

**#25 — Multi-Ticker Workflow**
Desktop users frequently monitor 3-8 assets. The interface must support comparing, switching between, and acting on multiple tickers without losing context on any of them.

---

## 4. WIDGET ARCHITECTURE & LAYOUT SYSTEM

### 4.1 Widget Inventory (18 Widgets)

Each widget is an independent, resizable, linkable module with consistent interaction patterns.

| #   | Widget                   | Category              | Min Size | Default Size | Linkable?    | Description                                                      |
| --- | ------------------------ | --------------------- | -------- | ------------ | ------------ | ---------------------------------------------------------------- |
| W1  | **Watchlist**            | Navigation            | 200×300  | 280×full     | Yes (source) | Symbol + wallet watchlist with classification badges             |
| W2  | **Chart**                | Analysis              | 400×300  | 600×500      | Yes          | Candlestick chart with indicators, drawings, order visualization |
| W3  | **Order Book**           | Analysis              | 250×300  | 300×400      | Yes          | Bid/ask depth with cumulative volume bars                        |
| W4  | **Order Entry**          | Trading               | 280×350  | 320×450      | Yes          | AI Strategy or Direct Trade — Sizing Guide integrated            |
| W5  | **Positions**            | Monitoring            | 400×200  | full×250     | No           | Active positions table with regime context, safety gauges        |
| W6  | **Trade History**        | Monitoring            | 400×200  | full×250     | No           | Completed trades with regime at entry/exit, sizing adherence     |
| W7  | **Wallet Discovery**     | Radar Network         | 300×400  | 400×full     | No           | D1 leaderboard with classification badges, gate status           |
| W8  | **Wallet Profile**       | Radar Network         | 350×500  | 450×full     | No           | D2 full profile with Three-Gate evaluation                       |
| W9  | **Follow Dashboard**     | Radar Network         | 400×300  | full×350     | No           | D4 follow relationships table with inline controls               |
| W10 | **Radar Feed**           | Radar Network         | 300×400  | 350×full     | No           | D5 activity feed with classification badges                      |
| W11 | **Copilot**              | Intelligence          | 300×400  | 350×full     | No           | Persistent chat sidebar — regime-aware, context-aware            |
| W12 | **Portfolio Summary**    | Overview              | 300×200  | 400×250      | No           | E1 balance, allocation, regime alignment                         |
| W13 | **Behavioral Dashboard** | Analytics             | 400×300  | 500×400      | No           | H1 performance analytics, regime performance, sizing adherence   |
| W14 | **Signal Cards**         | Discovery             | 300×200  | 350×300      | Yes          | C2-style signal feed with regime fit                             |
| W15 | **Confluence Panel**     | Intelligence (Tier 2) | 300×250  | 350×300      | Yes          | P1-P5 breakdown with weighted scores                             |
| W16 | **Carry Strategy**       | Trading (Tier 2)      | 300×300  | 400×350      | Yes          | Delta-neutral funding arbitrage setup                            |
| W17 | **Symbol Overview**      | Analysis              | 350×300  | 450×400      | Yes          | C3-style key metrics, fundamentals, regime context               |
| W18 | **Notifications**        | System                | 250×300  | 300×full     | No           | Notification feed (regime changes, classification, alerts)       |

### 4.2 Widget Anatomy (Consistent Structure)

Every widget follows this structural pattern:

```
┌─── Widget Header ──────────────────────────────┐
│ [📊 Widget Name]         [🔴 Link] [⚙] [—] [×]│
├────────────────────────────────────────────────┤
│                                                 │
│              Widget Content Area                │
│         (specific to widget type)               │
│                                                 │
│                                                 │
├────────────────────────────────────────────────┤
│ [Widget Footer / Status Bar]           optional │
└─────────────────────────────────────────────────┘

HEADER ELEMENTS:
  [📊 Widget Name]  — Icon + title identifying the widget type
  [🔴 Link]         — Color-coded link group selector (🔴🔵🟢🟡 or ⚪ unlinked)
  [⚙]               — Widget-specific settings dropdown
  [—]               — Minimize (collapse to header only)
  [×]               — Close (remove from layout)

INTERACTIONS:
  Drag header       → Move widget to new position (snap-to-grid)
  Drag edge/corner  → Resize widget (min size enforced)
  Double-click title → Rename widget instance
  Right-click header → Context menu (Duplicate, Reset, Full Screen, Settings)
```

### 4.3 Widget Linking System

Linking allows widgets to synchronize their active symbol. When a user clicks BTC in the Watchlist, all widgets in the same link group update to show BTC data.

```
LINK GROUPS (color-coded):
  🔴 Red     — Group 1 (e.g., primary analysis set)
  🔵 Blue    — Group 2 (e.g., secondary comparison set)
  🟢 Green   — Group 3 (e.g., wallet-focused set)
  🟡 Yellow  — Group 4 (e.g., signal monitoring set)
  ⚪ Unlinked — Widget operates independently

LINK BEHAVIOR:
  SOURCE widgets (can SET the group's symbol):
    Watchlist, Chart (on symbol change), Signal Cards

  RECEIVER widgets (RESPOND to group's symbol change):
    Chart, Order Book, Order Entry, Symbol Overview,
    Confluence Panel, Carry Strategy, Signal Cards

SYNC LOGIC:
  When source widget in Group 🔴 changes symbol to "ETH":
    → All 🔴-linked receivers update to ETH
    → Widgets in 🔵, 🟢, 🟡 are unaffected
    → Unlinked widgets are unaffected
    → Transition: 200ms fade + data load

VISUAL INDICATOR:
  Link badge color shown in widget header:
  ┌─ Chart ─────────────────── [🔴] [⚙] [—] [×] ─┐
  │  ↑ this dot shows the widget is in Red group     │

CONFIGURATION:
  Click [⚪] → dropdown of 4 colors
  Click active color → cycles to next / unlinks
```

### 4.4 Layout System

Layouts are named workspace configurations that users can save, switch, and customize.

```
LAYOUT BAR (top of window, below global nav):
┌────────────────────────────────────────────────────────────┐
│ [🏠 Overview] [📈 Trading] [🔍 Analysis] [👥 Radar]  [+]  │
│   active ▬▬▬                                               │
└────────────────────────────────────────────────────────────┘

PRESET LAYOUTS (ship with app — read-only templates):

  🏠 OVERVIEW (Default starting layout)
  ┌──────────┬────────────────────┬──────────┐
  │          │                    │          │
  │ Watchlist│   Chart (W2)      │ Copilot  │
  │  (W1)    │   (6B in green)    │  (W11)   │
  │          │                    │          │
  │ 280px    │   flex  ×600px     │  350px   │
  │          │                    │          │
  ├──────────┴────────────────────┴──────────┤
  │       Portfolio Summary (W12)             │
  │       Positions (W5)                      │
  │       250px height, full width            │
  └──────────────────────────────────────────┘

  📈 TRADING (Active trading focus)
  ┌──────────┬────────────────────┐
  │          │                    │
  │ Watchlist│   Chart (W2)       │
  │  (W1)    │   (6B in red)      │
  │          │   + Visual Builder │
  │          │                    │
  │ 280px    │   flex ×700px      │
  │          │                    │
  ├──────────┼────────────────────┤
  │ Order    │   Positions (W5)   │
  │ Entry    │   + Trade Hist     │
  │ (W4)     │   (full width)     │
  │ 280px    │   250px height     │
  └──────────┴────────────────────┘

  🔍 ANALYSIS (Deep research mode)
  ┌──────────┬────────────────────┬──────────┐
  │          │                    │          │
  │ Watchlist│   Chart (W2)       │ Symbol   │
  │  (W1)    │   (6B in blue)     │ Overview │
  │ + Signals│                    │ (W17)    │
  │          │                    │          │
  │ 280px    │   flex  ×500px     │  300px   │
  │          │                    │          │
  ├──────────┴────────────────────┴──────────┤
  │  Order Book (W3)  │  Confluence (W15)    │
  │  300px×300px      │  350px×300px         │
  └────────────────────────────────────────┘

  👥 RADAR (Wallet research + follow)
  ┌──────────┬────────────────────┬──────────┐
  │          │                    │          │
  │ Wallet   │  Wallet Profile    │ Radar    │
  │Discovery │  (W8)              │ Feed     │
  │  (W7)    │  + Three-Gate      │ (W10)    │
  │          │  overlay           │          │
  │ 300px    │  flex  ×500px      │  300px   │
  │          │                    │          │
  ├──────────┴────────────────────┴──────────┤
  │  Follow Dashboard (W9)                    │
  │  full width, 300px height                │
  └──────────────────────────────────────────┘

CUSTOM LAYOUTS:
  Users can create up to 6 custom layouts
  - Drag widgets around
  - Resize them
  - Link groups configure independently per layout
  - Name the layout (e.g., "Night Trading", "Research Mode")
  - Share layout via URL (future)

LAYOUT SWITCHING:
  Click layout name → instant switch (saves current scroll positions, form state)
  Hotkey: Cmd+J (Mac) / Ctrl+J (Windows) → cycle through layouts
```

### 4.5 Widget Settings Pattern

Every widget has a settings gear icon. Right-click header for global widget menu:

```
WIDGET SETTINGS (right-click → ⚙ menu):

  ⚙ Chart (W2) Settings
  ├─ Chart Type
  │  ├─ Candlestick (default)
  │  ├─ OHLC bars
  │  ├─ Line
  │  └─ Heikin-Ashi
  ├─ Timeframe
  │  ├─ 1m / 5m / 15m / 1h / 4h / 1d
  ├─ Indicators
  │  ├─ ☑ SMA 20
  │  ├─ ☑ RSI 14
  │  ├─ ☐ MACD
  │  └─ [+ Add Custom]
  ├─ Drawing Tools
  │  ├─ ☑ Trendlines
  │  ├─ ☑ Fibonacci
  │  └─ [Extended Tools] →
  ├─ Show Limit Orders (from Order Book)
  ├─ Show Position [if open]
  └─ [Reset to Defaults] | [Duplicate Widget] | [Full Screen]
```

---

## 5. REGIME BAR — DESKTOP ADAPTATION

### Philosophy

The single most common mistake retail traders make is applying the wrong strategy for current conditions — chasing breakouts in a range-bound market, fading trends in a momentum market. The Regime Bar prevents this by making market conditions ALWAYS visible, on EVERY screen. Version 2.0 introduces directional trending to distinguish between momentum markets going up vs down.

### Visual Specification

```
┌──────────────────────────────────────────────────┐
│ ● $12,450 ↑2.3%                      🔍  🔔(3)  │  ← Global header
├──────────────────────────────────────────────────┤
│ ██████████████ TRENDING ↑ (72%) ████████████████  ℹ  │  ← Regime Bar (v2.0)
├──────────────────────────────────────────────────┤
│                                                  │
│  [rest of screen content]                        │
```

### Bar States (v2.0 — 6 Regimes with Directional Trending)

| Regime        | Color    | Hex (Light/Dark)      | Label       | Animation                 | Tap-to-Expand Summary                                         |
| ------------- | -------- | --------------------- | ----------- | ------------------------- | ------------------------------------------------------------- |
| Trending Up   | Emerald  | `#10B981` / `#34D399` | TRENDING ↑  | Upward gradient shimmer   | "Upward momentum. Buy dips, follow trends, trail stops."      |
| Trending Down | Red      | `#EF4444` / `#F87171` | TRENDING ↓  | Downward gradient shimmer | "Downward momentum. Short rallies, respect the trend."        |
| Range-bound   | Blue     | `#3B82F6` / `#60A5FA` | RANGE-BOUND | Horizontal pulse          | "Mean reversion works. Fade extremes, don't chase breakouts." |
| Transition    | Amber    | `#F59E0B` / `#FBBF24` | TRANSITION  | Brightness pulse          | "Ambiguous. Reduce exposure until direction clears."          |
| Compression   | Teal     | `#0D9488` / `#14B8A6` | COMPRESSION | Breathing pulse           | "Big move building. Wait for breakout confirmation."          |
| Crisis        | Deep Orange | `#EA580C` / `#F97316` | CRISIS   | Orange flash warning      | "Dislocated market. Preserve capital. Don't add."             |

### Stage 1 Calculation Logic (Rules-Based, v2.0 — Directional)

```
INPUTS:
  price_data[]     — 30+ days of OHLCV candles
  ADX_14           — Average Directional Index over 14 periods
  SMA_20           — 20-period Simple Moving Average
  BB_width_20      — Bollinger Band width (20-period, 2 std dev)
  BB_width_30d_min — Minimum Bollinger width in last 30 days

RULES (evaluated in priority order):
  IF BB_width_20 ≤ BB_width_30d_min × 1.05:
    regime = COMPRESSION (indigo)
  ELIF ADX_14 > 25 AND price > SMA_20:
    regime = TRENDING_UP (emerald)  ← NEW in v2.0: directional check
  ELIF ADX_14 > 25 AND price < SMA_20:
    regime = TRENDING_DOWN (red)    ← NEW in v2.0: directional check
  ELIF ADX_14 < 20:
    regime = RANGE_BOUND (blue)
  ELSE:  // ADX 20-25
    regime = TRANSITION (amber)

  // Crisis override (checked independently):
  IF correlation_all_assets > 0.85 AND volatility_zscore > 2.5:
    regime = CRISIS (red-dark)

UPDATE FREQUENCY: Every 5 minutes from price data
LATENCY: <200ms computation
```

### Regime Bar Interaction (Desktop)

```
DEFAULT STATE:
  "█████ TRENDING ↑ (72%) █████"

TAP / HOVER:
  "█████ TRENDING ↑ (72%) █████ ℹ"
  Tooltip expands:
  ┌────────────────────────────────┐
  │ TRENDING UP — 72% Confidence   │
  │ Duration: 4d 12h               │
  │                                │
  │ Upward momentum. Buy dips,     │
  │ follow trends, trail stops.    │
  │ Regime change likely in:       │
  │ 7-10 days (ADX declining)      │
  │                                │
  │ [View Stage 2 Analysis] →      │
  └────────────────────────────────┘

CLICK on regime bar:
  → Opens Regime Analysis modal (Desktop only)
    Shows Stage 2 multi-factor breakdown:
    - ADX direction + value
    - Price vs SMA_20 + distance
    - Bollinger Band width vs 30d min
    - Hurst exponent (if available)
    - High-RIS wallet aggregate positioning
    - Historical regime duration
```

### Stage 2 Enhancement (Multi-Factor, Months 3-5)

```
ADDITIONAL INPUTS:
  hurst_exponent   — Trend persistence (>0.55 = trending)
  correlation_regime — Cross-asset correlation structure
  funding_volatility — Funding rate volatility (30-day)
  high_RIS_wallet_behavior — Aggregate position changes of top-RIS wallets

ENHANCED RULES:
  ADX + Hurst + BB width + correlation + funding vol → 6 regimes
  (maintains Trending Up/Down, Range-bound, Transition, Compression, Crisis)

LEADING INDICATOR (Arx-exclusive):
  When 7+ of top 10 RIS wallets reduce long exposure simultaneously:
    Regime change probability increases by +40%
    Flag: "Top Traders Rotating" appears below regime bar
```

---

## 6. DESIGN TOKEN REFERENCE

### Color Palettes (Full Hex Mapping)

#### Background Palette

| Token                    | Light                    | Dark                  | Usage                            |
| ------------------------ | ------------------------ | --------------------- | -------------------------------- |
| **Background Primary**   | `#FFFFFF`                | `#0F172A`             | Screen background, app container |
| **Background Secondary** | `#F1F5F9`                | `#1E293B`             | Card backgrounds, content areas  |
| **Background Tertiary**  | `#E2E8F0`                | `#334155`             | Subtle backgrounds, dividers     |
| **Surface**              | `#F8FAFC`                | `#475569`             | Elevated surfaces, buttons       |
| **Glass Layer**          | `rgba(255,255,255,0.60)` | `rgba(30,41,59,0.80)` | Glassmorphic overlays, modals    |

#### Text Palette

| Token              | Light     | Dark      | Usage                       |
| ------------------ | --------- | --------- | --------------------------- |
| **Text Primary**   | `#0F172A` | `#F8FAFC` | Body text, headings         |
| **Text Secondary** | `#64748B` | `#94A3B8` | Supporting text, labels     |
| **Text Tertiary**  | `#94A3B8` | `#64748B` | Hints, disabled text        |
| **Text Inverse**   | `#F8FAFC` | `#0F172A` | Text on colored backgrounds |

#### Accent Palette

| Token              | Light     | Dark      | Usage                                 |
| ------------------ | --------- | --------- | ------------------------------------- |
| **Accent Primary** | `#3B82F6` | `#3B82F6` | Primary buttons, links, active states |
| **Accent Hover**   | `#2563EB` | `#2563EB` | Hover state for accent elements       |
| **Accent Pressed** | `#1D4ED8` | `#1D4ED8` | Pressed/active state                  |

#### Regime Palette

| Regime                    | Light Hex              | Dark Hex          | Usage               |
| ------------------------- | ---------------------- | ----------------- | ------------------- |
| **Trending Up**           | `#10B981`              | `#34D399`         | Uptrend indicator   |
| **Trending Up Shimmer**   | `#10B981` to `#34D399` | animated gradient | Animated background |
| **Trending Down**         | `#EF4444`              | `#F87171`         | Downtrend indicator |
| **Trending Down Shimmer** | `#EF4444` to `#F87171` | animated gradient | Animated background |
| **Range-bound**           | `#3B82F6`              | `#60A5FA`         | Range-bound state   |
| **Range-bound Pulse**     | horizontal oscillation | N/A               | Subtle animation    |
| **Transition**            | `#F59E0B`              | `#FBBF24`         | Transition state    |
| **Transition Pulse**      | brightness oscillation | N/A               | Subtle animation    |
| **Compression**           | `#0D9488`              | `#14B8A6`         | Compression state   |
| **Compression Pulse**     | breathing animation    | N/A               | Subtle animation    |
| **Crisis**                | `#EA580C`              | `#F97316`         | Crisis state        |
| **Crisis Alert**          | orange flash warning   | N/A               | Urgent animation    |

#### Semantic Palette

| Semantic    | Hex       | Usage                        |
| ----------- | --------- | ---------------------------- |
| **Success** | `#10B981` | Confirmations, good outcomes |
| **Warning** | `#F59E0B` | Cautions, alerts             |
| **Error**   | `#EF4444` | Errors, critical states      |
| **Info**    | `#3B82F6` | Informational messages       |

---

## 7. DARK MODE SPECIFICATION

### Dark Mode is Primary

Dark mode is the DEFAULT and PRIMARY theme for Arx Desktop. Traders prefer dark interfaces for:

- Reduced eye strain during long trading sessions
- Better focus (dark backgrounds reduce cognitive load)
- Better chart readability (white charts on dark background)
- Market convention (Bloomberg, TradingView, professional terminals all dark)

### Theme Switching

```
THEME SELECTOR (Settings → Display):
  ⚫ Dark (default, recommended)
  ⚪ Light (alternative)
  🔄 Auto (system preference)

Shortcut: Cmd+Shift+D (Mac) / Ctrl+Shift+D (Windows)
Persists in user preferences
Applies to entire app instantly (200ms fade transition)
```

### Glassmorphic Layer Hierarchy (Dark Mode)

Glass morphism uses layered translucency to create depth without color changes. All glass layers use blur + overlay on dark backgrounds:

```
LAYER 0: BACKGROUND
  Color: #0F172A (slate-900)
  Blur: none
  Opacity: 100%
  Example: App canvas, widget backgrounds

LAYER 1: CARD
  Color: #1E293B (slate-800)
  Overlay: rgba(30, 41, 59, 0.95)
  Blur: 8px
  Opacity: 95% (slight transparency)
  Example: Widget body, data tables

LAYER 2: ELEVATED
  Color: #334155 (slate-700)
  Overlay: rgba(51, 65, 85, 0.90)
  Blur: 12px
  Opacity: 90%
  Example: Floating panels, tooltips

LAYER 3: MODAL
  Color: #475569 (slate-600)
  Overlay: rgba(71, 85, 105, 0.85)
  Blur: 16px
  Opacity: 85%
  Example: Dialogs, overlays, theme switcher

LAYER 4: BACKDROP (behind modal)
  Color: #0F172A (slate-900)
  Overlay: rgba(0, 0, 0, 0.40)
  Blur: 4px (subtle, doesn't affect content behind)
  Opacity: 40%
  Example: Modal backdrop, context menus
```

### Dark Mode Adjustments for Light Mode (Alternative)

Light mode reverses the hierarchy:

```
LAYER 0: BACKGROUND
  Color: #FFFFFF
  Overlay: none

LAYER 1: CARD
  Color: #F1F5F9 (slate-100)
  Overlay: rgba(241, 245, 249, 0.95)
  Blur: 8px

LAYER 2: ELEVATED
  Color: #E2E8F0 (slate-200)
  Overlay: rgba(226, 232, 240, 0.90)
  Blur: 12px

LAYER 3: MODAL
  Color: #CBD5E1 (slate-300)
  Overlay: rgba(203, 213, 225, 0.85)
  Blur: 16px

LAYER 4: BACKDROP
  Color: #FFFFFF
  Overlay: rgba(0, 0, 0, 0.10)
  Blur: 4px
```

---

## 8. TYPOGRAPHY SCALE

### Font Family Selection

```
UI TEXT (buttons, labels, menus):
  Font: Inter
  Weight: 400 (regular), 500 (medium), 600 (semibold), 700 (bold)
  Reason: Clean, geometric, highly legible at small sizes

NUMERIC DATA (prices, sizes, performance metrics):
  Font: JetBrains Mono
  Weight: 400 (regular), 600 (semibold)
  Reason: Monospace aligns digits for easy scanning, trader-familiar

CHART LABELS & INDICATORS:
  Font: Inter
  Weight: 500 (medium)
  Reason: Clean, professional, good at tiny sizes on charts
```

### Desktop Typography Scale

Desktop sizes are LARGER than mobile (more canvas). All sizes in px and rem (base 16px):

```
H1 — Page Heading
  Size: 32px / 2rem
  Weight: 700 (bold)
  Line Height: 1.2 (38.4px)
  Letter Spacing: -0.01em
  Example: "Dashboard", "Radar Network", section titles

H2 — Section Heading
  Size: 24px / 1.5rem
  Weight: 600 (semibold)
  Line Height: 1.3 (31.2px)
  Letter Spacing: 0
  Example: "Positions", "Wallet Discovery", subsection titles

H3 — Subsection Heading
  Size: 18px / 1.125rem
  Weight: 600 (semibold)
  Line Height: 1.4 (25.2px)
  Letter Spacing: 0.005em
  Example: Widget titles, data category headers

BODY LARGE — Primary content
  Size: 16px / 1rem
  Weight: 400 (regular)
  Line Height: 1.5 (24px)
  Letter Spacing: 0
  Example: Body text, long descriptions, help text

BODY — Standard content
  Size: 14px / 0.875rem
  Weight: 400 (regular)
  Line Height: 1.5 (21px)
  Letter Spacing: 0
  Example: Table cells, form fields, labels

BODY SMALL — Secondary content
  Size: 12px / 0.75rem
  Weight: 400 (regular)
  Line Height: 1.5 (18px)
  Letter Spacing: 0.01em
  Example: Helper text, timestamps, badges

CAPTION — Minimal text
  Size: 11px / 0.6875rem
  Weight: 500 (medium)
  Line Height: 1.4 (15.4px)
  Letter Spacing: 0.02em
  Example: Tiny labels, icon captions

MONOSPACE (numeric data):
  Size: 14px / 0.875rem (standard), 16px / 1rem (emphasis)
  Weight: 400 (regular), 600 (semibold for highlights)
  Font: JetBrains Mono
  Line Height: 1.5
  Letter Spacing: 0
  Example: Price, position size, %return, timestamp

CHART TEXT (on charts):
  Size: 10px (labels), 12px (legend), 14px (title)
  Weight: 400 (regular)
  Font: Inter
  Example: Candle labels, axis titles, indicator names
```

### Text Contrast & Accessibility

All text on dark mode meets WCAG AAA contrast standards:

```
Text Primary (#F8FAFC) on Background (#0F172A): 18.9:1 ratio ✓
Text Secondary (#94A3B8) on Background (#0F172A): 5.8:1 ratio ✓
Text Tertiary (#64748B) on Background (#0F172A): 3.5:1 ratio ✓
All exceed WCAG AAA minimums (7:1 for small, 4.5:1 for large)
```

---

## 9. SPACING GRID

### Base Grid

Arx Desktop uses a **4px base grid** for all spacing and sizing. All distances are multiples of 4px.

```
4px — x0.5 (micro spacing)
8px — x1   (padding in small buttons, gaps)
12px — x3  (gaps between adjacent elements)
16px — x4  (standard padding, default gap)
20px — x5  (increased padding)
24px — x6  (major section gaps)
32px — x8  (large gaps, layout sections)
40px — x10 (between major panels)
48px — x12 (large vertical gaps)
64px — x16 (major layout spacing)
```

### Desktop Layout Rules (12-Column Grid)

Desktop uses a 12-column responsive grid. Widgets snap to columns.

```
VIEWPORT WIDTH CATEGORIES:
  1200px - 1399px:   12 columns @ 80px column + 20px gap
  1400px - 1599px:   12 columns @ 95px column + 20px gap
  1600px - 1999px:   12 columns @ 115px column + 20px gap
  2000px+:           12 columns @ 140px column + 20px gap
  Ultra-wide (>2560px): Fixed 12 columns @ 180px + 30px gap

SIDEBAR WIDTHS (fixed, don't participate in grid):
  Left sidebar (watchlist):   280px
  Right sidebar (copilot):    350px
  Content area (flex):        remaining space

WIDGET MINIMUM WIDTHS:
  2 columns = 200-240px (narrow widgets)
  3 columns = 320-360px (typical widgets)
  4 columns = 440-480px (medium widgets)
  6 columns = 680-720px (charts)
  full width = stretch to available
```

### Gap Patterns

Consistent spacing patterns reduce cognitive load:

```
COMPONENT GAPS (internal):
  Element to element (buttons, form fields): 12px
  Button to text: 8px
  Label to input: 8px
  Icon to text: 8px

WIDGET INTERNAL PADDING:
  Widget header: 16px padding (sides), 12px (top/bottom)
  Widget body: 16px padding on all sides
  Content rows in table: 12px vertical gap

SECTION GAPS (between major content areas):
  Adjacent widgets in layout: 20px gap
  Header to content: 24px gap
  Content sections: 32px gap

MODAL SPACING:
  Modal padding: 24px
  Button spacing in modal: 12px between buttons
  Form field spacing: 16px
```

---

## 10. WALLET CLASSIFICATION — DESKTOP ADAPTATION

### Classification Badges (Desktop Enhancement)

Desktop displays wallet classification more prominently than mobile. Badges appear in:

- Wallet Discovery widget (W7) column headers
- Wallet Profile widget (W8) hero section
- Radar Feed (W10) post metadata
- Follow Dashboard (W9) table column

```
BADGE VISUAL (Desktop):
  Size: 18px height (larger than mobile's 14px)
  Font: Inter 12px semibold (dark text on color background)
  Padding: 4px 8px
  Border Radius: 4px
  Animation: None (badges are stable, not transient)

LAYOUT:
  [🛡️] All-Weather Trader  ← emoji + label, inline
  [🍀] Unproven
  [❓] Unverified
  [🎯] Specialist
  [📉] Cooling Down
  [🤖] Non-Copyable
```

### Type 1 — All-Weather Trader 🛡️

```
CRITERIA:
  • Win rate: 55%+ (across all regimes)
  • Sharpe ratio: >1.5
  • Regime independence: RIS > 0.65 across all 6 regimes
  • Track record: 12+ months minimum
  • Volatility: not excessively high (volatility < mean + 2σ)

CONFIDENCE: ★★★★★
FOLLOW SIGNAL: Green checkmark + "Safe to follow"
THREE-GATE RECOMMENDATION: All gates pass, follow recommended
SIZING GUIDE: Full allocation permitted (up to 5% portfolio)
WALLET BEHAVIOR TAG: "Consistently performs across market conditions"
```

### Type 2 — Unproven 🍀

```
CRITERIA:
  • Win rate: 50-60% (narrow range)
  • Sharpe ratio: 0.8 - 1.5
  • Regime independence: RIS > 0.50
  • Track record: 3-12 months
  • Looks profitable but statistical edge not proven

CONFIDENCE: ★★★☆☆
FOLLOW SIGNAL: Yellow caution + "Limited data"
THREE-GATE RECOMMENDATION: Gates 1-2 pass, Gate 3 (track record) yellow
SIZING GUIDE: Half allocation recommended (up to 2.5% portfolio)
WALLET BEHAVIOR TAG: "Profitable, but edge not statistically significant"
```

### Type 3 — Unverified ❓

```
CRITERIA:
  • Win rate: 45-55% (indistinguishable from random)
  • Sharpe ratio: <0.8
  • Regime independence: RIS < 0.50
  • Track record: <3 months OR
  • Obvious suspicious patterns (pump & dump activity, whale-following)

CONFIDENCE: ★☆☆☆☆
FOLLOW SIGNAL: Red X + "Too risky"
THREE-GATE RECOMMENDATION: Gate 1 (win rate) fails
SIZING GUIDE: Not recommended (0%)
WALLET BEHAVIOR TAG: "Insufficient data or suspicious patterns"
```

### Type 4 — Specialist 🎯

```
CRITERIA:
  • RIS high in 1-2 specific regimes (>0.75)
  • RIS low in others (<0.40)
  • Overall win rate: 50-65%
  • Sharpe ratio: 1.0+
  • Example: Excellent in trending markets, mediocre in range-bound

CONFIDENCE: ★★★★☆ (conditional)
FOLLOW SIGNAL: Blue conditional + "Regime-specific"
THREE-GATE RECOMMENDATION: All gates pass IF regime is aligned
SIZING GUIDE: Full allocation in aligned regime (5% max), 0% in misaligned
WALLET BEHAVIOR TAG: "Excellent trader in [REGIME], avoid in [REGIME]"
DESKTOP ENHANCEMENT: Regime preference shown as radar chart
```

### Type 5 — Cooling Down 📉

```
CRITERIA:
  • Previous 12-month edge: >1.5 Sharpe
  • Recent 3-month trend: -30% to -60% decline in Sharpe
  • Still positive win rate but deteriorating
  • Example: Used to be 60% win rate, now 54%

CONFIDENCE: ★★☆☆☆
FOLLOW SIGNAL: Orange warning + "Declining performance"
THREE-GATE RECOMMENDATION: Gate 2 (recent performance) yellow, Gate 3 (track record) fails
SIZING GUIDE: Reduce allocation by 50% (2.5% max), consider exit
WALLET BEHAVIOR TAG: "Previously strong, now deteriorating. Reason: [investigation]"
DESKTOP ENHANCEMENT: Performance curve shows declining slope
```

### Type 6 — Non-Copyable 🤖

```
CRITERIA:
  • High-frequency trading (avg trade duration <1 minute)
  • Market-making behavior (bid-ask spread cycling)
  • Bot-detected: consistent decimal sizes, perfect order timing
  • Example: 500+ trades/day, <2% slippage

CONFIDENCE: ★☆☆☆☆ (not applicable)
FOLLOW SIGNAL: Black lock + "Non-copyable"
THREE-GATE RECOMMENDATION: Gate 0 (copyability) fails
SIZING GUIDE: Not recommended (0%)
WALLET BEHAVIOR TAG: "Appears to be market maker or bot. Cannot copy."
DETECTION: Heuristics on trade frequency, size precision, timing
```

### Desktop-Specific: Regime Alignment Radar

When viewing a Type 4 Specialist, desktop shows a radar chart:

```
         Trending Up
             ▲
           ╱   ╲
    Comp. ╱       ╲ Range
          │       │
Crisis ──┤  ★★★  ├─ Trend ↓
          │       │
         ╲       ╱
           ╲   ╱
      Trans.

Legend:
  Inner ring (★☆☆☆☆): Below 0.40 RIS
  Mid ring (★★★☆☆): 0.40-0.65 RIS
  Outer ring (★★★★★): 0.65+ RIS

Specialist example:
  Strong: Trending Up (★★★★★), Range (★★★★☆)
  Weak: Crisis (★☆☆☆☆), Compression (★★☆☆☆)
```

---

## 11. SIZING GUIDE — DESKTOP ADAPTATION

### Positioning size is regime-aware. Desktop shows details in table cells + tooltips.

```
SIZING GUIDE DISPLAY (Order Entry widget, before confirmation):

  ┌─────────────────────────────────┐
  │ Recommended Size                │
  │                                 │
  │ Current Regime: TRENDING ↑       │
  │ Kelly Fraction: 0.5% (conservative) │
  │ Your Bankroll: $10,000           │
  │ → Recommended: 50 USDT (0.5%)    │
  │                                 │
  │ If All-Weather 🛡️ wallet:       │
  │   Override: 100 USDT (1%) safe  │
  │ If Specialist 🎯 (trending expert):│
  │   Override: 75 USDT (0.75%) OK  │
  │ If Unverified ❓:                │
  │   Not recommended                │
  │                                 │
  │ Leverage: Recommended 1:1 (no leverage) │
  │ You chose: 1:2 (borderline)      │
  │                                 │
  │ [Allow This Size] [Customize]    │
  └─────────────────────────────────┘
```

### Regime Multiplier Table

Desktop shows the regime-based multiplier applied to Kelly base:

```
REGIME MULTIPLIER (applied to 0.5% base):

Regime             Multiplier  Adjusted Size  Reasoning
─────────────────  ──────────  ──────────────  ──────────────────────
Trending Up        1.5×        0.75%           Momentum favors trend
Trending Down      0.8×        0.4%            Shorting harder emotionally
Range-bound        1.0×        0.5%            Neutral, no advantage
Transition         0.5×        0.25%           Ambiguous, reduce
Compression        0.7×        0.35%           Waiting for breakout
Crisis             0.2×        0.1%            Only essential positions
```

---

## 12. THREE-GATE FRAMEWORK — DESKTOP ADAPTATION

### Desktop View: Three-Gate Evaluation Card

When viewing a Wallet Profile (W8), desktop shows an inline Three-Gate card (not a modal):

```
┌─────────────────────────────────────────────────┐
│ THREE-GATE EVALUATION      [View Full Analysis] →│
├─────────────────────────────────────────────────┤
│                                                 │
│ Gate 1: COPYABILITY ✓                           │
│ ├─ Win rate: 58% (target: >55%) ✓               │
│ ├─ Strategy: Clear, liquid markets ✓            │
│ └─ Asset class: Single timeframe (ETH) ✓        │
│ VERDICT: Copyable, good fundamentals            │
│                                                 │
│ Gate 2: REGIME NAVIGATION ✓                     │
│ ├─ Trending RIS: 0.72 (target: >0.65) ✓         │
│ ├─ Range RIS: 0.58 (target: >0.55) ✓            │
│ ├─ Current regime: Trending Up ✓ ✓              │
│ └─ Recent performance: Strong ✓                 │
│ VERDICT: Trades well in current regime          │
│                                                 │
│ Gate 3: TRACK RECORD ✓                          │
│ ├─ Duration: 18 months (target: >12) ✓          │
│ ├─ Win rate consistency: ±3% (stable) ✓         │
│ ├─ Drawdown recovery: Fast (<1 month) ✓         │
│ └─ Profit trend: +8% last quarter ✓             │
│ VERDICT: Proven, durable edge                   │
│                                                 │
│ ═══════════════════════════════════════════════ │
│ RECOMMENDATION: ✓ FOLLOW (All gates pass)       │
│ Confidence: 94% | Risk Level: Low               │
│ Suggested Position: 3% of portfolio             │
│ ═══════════════════════════════════════════════ │
│                                                 │
│ [Add to Follow] [Compare to Others] [Save]      │
└─────────────────────────────────────────────────┘
```

### Gate Definitions (Unchanged from v1.0, Desktop Presentation Enhanced)

**Gate 1: Copyability**

- Win rate > 55% (regime-independent)
- Trades liquid markets (top 50 tokens by volume)
- Strategy transparent (can be inferred from positions)
- No sus patterns (no obvious front-running, no pump-and-dumps)

**Gate 2: Regime Navigation**

- Regime-specific RIS > 0.65 in current market (AND)
- At least 2 of 6 regime RIS scores > 0.50 (versatility)
- Recent performance aligns with historical edge
- Drawdown < 25% peak-to-trough in last 90 days

**Gate 3: Track Record**

- Minimum 12 months of data
- Win rate stable (±5% range) across the period
- Profit curve is smooth (not lottery wins)
- Recovering from drawdowns proves adaptation

---

## 13. NAMING CONVENTIONS & TERMINOLOGY

### v2.0 Naming Conventions Table

| v1.0 Term                    | v2.0 Term                                                                     | Source                              | Rationale                                                                     |
| ---------------------------- | ----------------------------------------------------------------------------- | ----------------------------------- | ----------------------------------------------------------------------------- |
| —                            | Regime Bar                                                                    | Design System v1.0                  | Persistent market regime indicator (ALL screens)                              |
| —                            | Trending Up / Trending Down / Range-bound / Transition / Compression / Crisis | Design System v1.0, Executable Spec | 6 regime states with directional trending (Up vs Down)                        |
| "Alpha Network"              | "Radar Network"                                                               | Design System v1.0                  | Radar = always-on tracker for smart money. Avoids "alpha" jargon.             |
| "Alpha Feed"                 | "Radar Feed"                                                                  | Design System v1.0                  | Same rationale as Radar Network                                               |
| "D1 Alpha"                   | "D1 Radar"                                                                    | Design System v1.0                  | Consistent rename across all discovery surfaces                               |
| "Alpha Layout"               | "Radar Layout"                                                                | Design System v1.0                  | 4th preset layout renamed for consistency                                     |
| —                            | All-Weather Trader 🛡️                                                         | Executable Spec 2.3                 | Type 1 wallet classification — genuinely skilled                              |
| —                            | Unproven 🍀                                                                   | Executable Spec 1.8                 | Type 2 — profitable but no statistical edge                                   |
| —                            | Unverified ❓                                                                 | Executable Spec 1.8                 | Type 3 — suspicious patterns or insufficient data                             |
| —                            | Specialist 🎯                                                                 | Executable Spec 2.3                 | Type 4 — strong in specific regimes only                                      |
| —                            | Cooling Down 📉                                                               | Executable Spec 2.3                 | Type 5 — declining edge                                                       |
| —                            | Non-Copyable 🤖                                                               | Executable Spec 1.8                 | Type 6 — bot/market maker                                                     |
| "Risk Level: 0.5% / 1% / 2%" | Sizing Guide / Recommended Size                                               | Executable Spec 2.1                 | Kelly-based optimal sizing, regime-conditioned                                |
| —                            | Track Record Strength (★ to ★★★★★)                                            | Executable Spec 2.1                 | Confidence tier from Wilson score interval                                    |
| —                            | Regime Navigation Index (RIS) (★ to ★★★★★)                                    | Executable Spec 2.2                 | Performance in current regime (user-facing as stars)                          |
| —                            | Three-Gate Framework                                                          | Executable Spec 2.4                 | Follow decision evaluation system (Copyability, Regime Nav, Track Record)     |
| "Kelly" (internal ONLY)      | NEVER user-facing                                                             | Executable Spec 2.1                 | "Kelly" never appears in any UI — always "Sizing Guide" or "Recommended Size" |
| —                            | P1 Regime                                                                     | Design System v1.0                  | Signal taxonomy (formerly "Context") — market regime                          |
| —                            | P2 Participant                                                                | Executable Spec 2.6                 | Signal taxonomy — wallet behavior category                                    |
| —                            | P3 Instrument                                                                 | Executable Spec 2.6                 | Signal taxonomy — asset/token information                                     |
| —                            | P4 Structural                                                                 | Executable Spec 2.6                 | Signal taxonomy — on-chain structure (supply, concentration)                  |
| —                            | P5 Pattern                                                                    | Executable Spec 2.6                 | Signal taxonomy — trading pattern or technical signal                         |
| "Confluence Panel"           | "Confluence Panel (P1-P5)"                                                    | Design System v1.0                  | Tier 2 feature showing P1-P5 signal breakdown                                 |
| "Carry Strategy"             | "Carry Strategy (Delta-Neutral)"                                              | Executable Spec 2.7                 | Tier 2 feature for funding arbitrage                                          |

---

## 14. TIER 2 FEATURE SELECTION FOR DESKTOP

### Philosophy

Desktop ships with Tier 1 features. Tier 2 features (Confluence + Carry) are available as unlocked features for users who complete 10 trades AND maintain 90 days of trading history.

### Tier 2 Feature: Confluence Panel (W15)

```
VISUAL (when enabled in a widget):

┌─ Confluence Panel ─────────────────────[🔴][⚙][—][×]─┐
│ Current Symbol: BTC/USDT                             │
│ Regime: TRENDING UP (72%)                            │
│                                                      │
│ P1 — REGIME (Context)           Weight: 20%          │
│ ├─ Trending Up momentum ═════════ 92% signal strength│
│ ├─ Price > SMA20 by 8.3% ═══════ 88%               │
│ ├─ ADX 31 (strong) ═════════════ 85%               │
│ └─ Weighted Score: 89%  [🟢 STRONG]                │
│                                                      │
│ P2 — PARTICIPANT (Smart Money)   Weight: 25%        │
│ ├─ Top 10 wallets: +8.5M BTC ═══ 78%              │
│ ├─ Whale accumulation (7d) ════ 82%               │
│ ├─ High RIS follows increasing ═ 76%              │
│ └─ Weighted Score: 79%  [🟡 MODERATE]              │
│                                                      │
│ P3 — INSTRUMENT (Spot vs Perps)  Weight: 20%        │
│ ├─ Spot premium: +0.2% ════════ 71%               │
│ ├─ Open interest up 12% (7d) ══ 68%               │
│ ├─ Funding rate: 0.015% (neutral) ═ 60%           │
│ └─ Weighted Score: 66%  [🔵 NEUTRAL]               │
│                                                      │
│ P4 — STRUCTURAL (On-Chain)       Weight: 20%        │
│ ├─ Exchange inflow: -50M ═══════ 85%              │
│ ├─ Active address count: ↑12% == 79%              │
│ ├─ MVRV ratio: 1.3 (neutral) ══ 70%               │
│ └─ Weighted Score: 78%  [🟡 MODERATE]              │
│                                                      │
│ P5 — PATTERN (Technical)         Weight: 15%        │
│ ├─ Golden Cross (50/200 EMA) ══ 92%               │
│ ├─ RSI 62 (bullish, not overbought) ═ 80%        │
│ ├─ MACD positive ═══════════════ 85%              │
│ └─ Weighted Score: 86%  [🟢 STRONG]                │
│                                                      │
│ ═════════════════════════════════════════════════   │
│ COMPOSITE SCORE: 81%  [🟢 CONFLUENCE STRONG]       │
│ Interpretation: Multiple tailwinds. High confidence.│
│                                                      │
│ [View Detailed Calculation] [Export PDF] [Help]     │
└──────────────────────────────────────────────────────┘
```

### Confluence Panel Calculation

Each P-signal has a base score (0-100%) and a weight. Weighted average = final Confluence score.

```
P1 REGIME (Weight 20%):
  Base signals: ADX, price vs SMA, Bollinger Band
  Confidence metric: Average of 3 signals

P2 PARTICIPANT (Weight 25%):
  Base signals: Top-10 wallet flow, RIS-weighted follows
  Confidence metric: Aggregate behavior of smart money

P3 INSTRUMENT (Weight 20%):
  Base signals: Spot/perps premiums, funding rates, OI
  Confidence metric: Cross-market structure

P4 STRUCTURAL (Weight 20%):
  Base signals: Exchange flows, address activity, on-chain metrics
  Confidence metric: On-chain health

P5 PATTERN (Weight 15%):
  Base signals: Technical indicators (EMA crosses, RSI, MACD, Volume)
  Confidence metric: Visual pattern confirmation

COMPOSITE = (P1 × 0.20) + (P2 × 0.25) + (P3 × 0.20) + (P4 × 0.20) + (P5 × 0.15)
```

### Tier 2 Feature: Carry Strategy Panel (W16)

Delta-neutral funding arbitrage. Users who understand yield strategies can set up automated carry positions.

```
VISUAL (when enabled in a widget):

┌─ Carry Strategy ───────────────────────[🔴][⚙][—][×]─┐
│ Current Symbol: ETH/USDT                            │
│ Strategy: Delta-Neutral Funding Arbitrage           │
│                                                     │
│ CURRENT FUNDING RATE                                │
│ ├─ Perpetual: 0.0156% (8h cycle)                    │
│ ├─ Expected daily yield: 0.0468%                    │
│ ├─ Expected monthly: 1.40%                          │
│ └─ Annual equivalent: 16.8%                         │
│                                                     │
│ YOUR POSITION SETUP                                 │
│ ├─ Long Spot: 10 ETH @ $2,450 = $24,500            │
│ ├─ Short Perp: 10 ETH @ $2,450 = $24,500           │
│ ├─ Notional exposure: $0 (delta neutral) ✓          │
│ └─ Margin used: $2,450 (10% for shorts)             │
│                                                     │
│ YIELD PROJECTION (8-hour cycles)                    │
│ ├─ Cycle 1 (now): +$3.83                            │
│ ├─ Cycle 2 (8h): +$3.83                             │
│ ├─ Daily total: +$11.48 (0.047%)                    │
│ └─ If rate holds 30d: +$345 (1.41%)                │
│                                                     │
│ RISKS DISPLAYED                                    │
│ ├─ Basis drift: ±2.5% (acceptable)                  │
│ ├─ Liquidation buffer (short perp): 120% safe       │
│ ├─ Exchange counterparty: [exchange name] (Tier 1) │
│ └─ Funding shock: If rate → 0%, yield stops        │
│                                                     │
│ [SET UP POSITION] [CLOSE POSITION] [LEARN MORE]     │
│                                                     │
│ ⚠️  WARNING: Requires manual basis management.      │
│     Arx Copilot will alert if basis drifts >5%.    │
└──────────────────────────────────────────────────────┘
```

### Tier 2 Unlock Conditions

Tier 2 features remain locked until:

1. **Minimum trading activity:** 10 closed trades on the platform
2. **Minimum tenure:** 90 days of account activity
3. **Demonstrated competence:** Passed simple quiz on Three-Gate Framework
4. **Explicit opt-in:** User clicks "Unlock Tier 2 Features" and reads disclosure

Once unlocked, both Confluence Panel and Carry Strategy are permanently available.

---

## 15. GLOBAL NAVIGATION & CHROME

### Global Header (All Screens)

```
┌─────────────────────────────────────────────────────────┐
│ [Arx Logo] [Search] [Notifications(3)] [Settings] [👤] │
│  ↓                 ↓                ↓          ↓         ↓
│  Logo              Cmd+K            Regime    Dark     Profile
│  (click = Home)    search            alerts   mode      menu
└─────────────────────────────────────────────────────────┘

COMPONENTS:

  [Arx Logo] — Click to return to Overview layout (home)

  [Search] — Global search (Cmd+K / Ctrl+K)
    ├─ Symbols (BTC, ETH, DOGE...)
    ├─ Watchlists (filter by name)
    ├─ Wallets (search by address or name)
    ├─ Screens (jump to Dashboard, Radar Network, etc.)
    └─ Keyboard shortcuts (Cmd+K shows all shortcuts)

  [Notifications] — Bell icon with badge
    ├─ Regime changes ("Shifted to Range-bound")
    ├─ Classification changes ("Wallet downgraded to Unproven")
    ├─ Price alerts (custom, user-set)
    ├─ Trade alerts (fill, liquidation)
    └─ Copilot reminders ("Check Radar Feed")

    Click to open Notifications widget (W18) in a panel

  [Dark Mode Toggle] — Moon/sun icon
    ├─ Instant switch
    ├─ Remembers preference
    └─ Hotkey: Cmd+Shift+D / Ctrl+Shift+D

  [Settings] — Gear icon
    ├─ Display (Dark/Light, Zoom, Font size)
    ├─ Account (API keys, 2FA, logout)
    ├─ Notifications (enable/disable types)
    ├─ Layout (manage saved layouts)
    ├─ Keyboard Shortcuts (view all, customize)
    └─ Help & Support

  [Profile] — User avatar / initials
    ├─ Account details
    ├─ Tier status (Tier 1, Tier 2, Premium)
    ├─ Portfolio value (summary)
    ├─ Logout
    └─ Feedback
```

### Layout Bar (Below Global Header)

```
┌─────────────────────────────────────────────────┐
│ [🏠 Overview] [📈 Trading] [🔍 Analysis] [👥 Radar] [+]
│   active ▬▬▬                                    │
│                                                │
│ Click name to switch layout. [+] to create new.│
└─────────────────────────────────────────────────┘

INTERACTIONS:
  Click layout name → Instant switch
  Right-click layout name → Rename, duplicate, delete, share URL
  Drag layout tab → Reorder layouts (saved)
  [+] button → Create new layout (modal)
  Hotkey: Cmd+J / Ctrl+J → Cycle to next layout
```

### Sidebar Navigation (Left & Right)

**Left Sidebar** — Persistent watchlist + signals (if enabled)

```
┌──────────────┐
│ Watchlist    │
├──────────────┤
│ BTC $12,450 ↑│
│ ETH $2,450 ↑ │
│ SOL $185 →   │
│ DOGE $0.32 ↓ │
│              │
│ + Add Symbol │
│ [Settings] ⚙ │
└──────────────┘

Clicking symbol in watchlist:
  → Updates all linked widgets (same color group)
  → Scrolls chart to that symbol (if linked)
  → Opens symbol details panel (if sidebar has space)
```

**Right Sidebar** — Copilot (persistent, toggles via Cmd+\)

```
┌──────────────┐
│ Copilot      │
├──────────────┤
│              │
│ How can I    │
│ help?        │
│              │
│ [User Input] │
│              │
│              │
│ ← Close (Cmd+\) │
└──────────────┘

Copilot always visible on desktop (unlike mobile where it's modal).
Always regime-aware: mentions current regime in suggestions.
```

---

## 16. KEYBOARD SHORTCUT SYSTEM

### Progressive Shortcut Disclosure

Arx uses a progressive shortcut system. Basic shortcuts are essential; power shortcuts are for advanced users. All shortcuts are listed in Settings.

#### Basic Shortcuts (Tier 1 — Everyone)

| Action             | Mac         | Windows      | Context               |
| ------------------ | ----------- | ------------ | --------------------- |
| Search             | Cmd+K       | Ctrl+K       | Global search overlay |
| Close modal/drawer | Esc         | Esc          | Any modal             |
| Next layout        | Cmd+J       | Ctrl+J       | Layout bar            |
| Previous layout    | Cmd+Shift+J | Ctrl+Shift+J | Layout bar            |
| Toggle dark mode   | Cmd+Shift+D | Ctrl+Shift+D | Anytime               |
| Toggle Copilot     | Cmd+\       | Ctrl+\       | Right sidebar         |
| Open settings      | Cmd+,       | Ctrl+,       | Global                |
| Help / Shortcuts   | Cmd+?       | Ctrl+?       | Global                |

#### Power Shortcuts (Tier 2 — Advanced)

| Action                            | Mac       | Windows    | Context                         |
| --------------------------------- | --------- | ---------- | ------------------------------- |
| Create new position (quick order) | Cmd+Enter | Ctrl+Enter | Anywhere (if watchlist focused) |
| Close all positions               | Cmd+Alt+X | Ctrl+Alt+X | Positions widget                |
| Export trade history              | Cmd+E     | Ctrl+E     | Trade History widget            |
| Full screen widget                | Cmd+Enter | Ctrl+Enter | Any widget header               |
| Reset layout                      | Cmd+Alt+R | Ctrl+Alt+R | Layout bar                      |
| Duplicate widget                  | Cmd+D     | Ctrl+D     | Widget header                   |
| Focus watchlist                   | Cmd+1     | Ctrl+1     | Layout                          |
| Focus chart                       | Cmd+2     | Ctrl+2     | Layout                          |
| Focus Copilot                     | Cmd+3     | Ctrl+3     | Layout                          |

#### Navigation Shortcuts

| Action                     | Mac         | Windows      | Context                           |
| -------------------------- | ----------- | ------------ | --------------------------------- |
| Go to Radar Network        | Cmd+Shift+R | Ctrl+Shift+R | Global (jumps to Radar layout)    |
| Go to Portfolio            | Cmd+Shift+P | Ctrl+Shift+P | Global (jumps to Overview layout) |
| Go to Trade History        | Cmd+Shift+T | Ctrl+Shift+T | Global                            |
| Previous screen in history | Cmd+[       | Ctrl+[       | Navigation history                |
| Next screen in history     | Cmd+]       | Ctrl+]       | Navigation history                |

#### Chart Shortcuts (When Chart Widget Focused)

| Action           | Mac         | Windows      | Notes                          |
| ---------------- | ----------- | ------------ | ------------------------------ |
| Zoom in          | +           | +            | Candlestick spacing            |
| Zoom out         | -           | -            | Candlestick spacing            |
| Pan left         | ←           | ←            | Scroll chart left              |
| Pan right        | →           | →            | Scroll chart right             |
| Pan up           | ↑           | ↑            | Scroll chart up (indicators)   |
| Pan down         | ↓           | ↓            | Scroll chart down (indicators) |
| Toggle crosshair | Cmd+G       | Ctrl+G       | Precise price reading          |
| Clear drawings   | Cmd+Shift+C | Ctrl+Shift+C | Trendlines, Fibonacci, etc.    |
| Take screenshot  | Cmd+Shift+S | Ctrl+Shift+S | Chart only (clipboard)         |

#### Widget Management Shortcuts

| Action                        | Mac    | Windows    | Context                            |
| ----------------------------- | ------ | ---------- | ---------------------------------- |
| Cycle link group              | ⌘L     | Ctrl+L     | Widget header focused              |
| Close widget                  | ⌘W     | Ctrl+W     | Widget header focused              |
| Minimize widget               | ⌘-     | Ctrl+-     | Widget header focused              |
| Maximize widget               | ⌘+     | Ctrl++     | Widget header focused              |
| Move widget (then arrow keys) | ⌘Space | Ctrl+Space | Widget header, then arrows to move |

#### Order Entry Shortcuts (When Order Entry Widget Focused)

| Action                  | Mac       | Windows   | Notes                                |
| ----------------------- | --------- | --------- | ------------------------------------ |
| Switch Spot/Perps       | Tab       | Tab       | If both available for symbol         |
| Switch Buy/Sell         | Shift+Tab | Shift+Tab | Toggle order direction               |
| Cycle size presets      | ↑↓        | ↑↓        | Sizing Guide suggestions             |
| Toggle leverage (Perps) | L         | L         | 1:1 to 1:2 to 1:5, cycle             |
| Place order             | Enter     | Enter     | Confirms order (shows confirm modal) |
| Cancel order            | Esc       | Esc       | Clears form without submitting       |

### Shortcut Customization

Users can customize shortcuts in Settings → Keyboard Shortcuts:

```
SETTINGS → KEYBOARD SHORTCUTS

Preset Shortcuts (can't change):
  [× — locked] Cmd+K — Global Search

Custom Shortcuts (can rebind):
  [✎] Cmd+J → Next Layout
      [Change] [Reset]

  [✎] Cmd+Enter → Create Position
      [Change] [Reset]

[Show All Shortcuts] [Reset to Defaults] [Import from File]
```

---

## 17. ONBOARDING EXPERIENCE & FLOWS

### Onboarding Step 1: Account Setup

User connects exchange (Dex or CEX) and wallet for portfolio tracking.

```
SCREEN: "Connect Your Accounts"

┌────────────────────────────────┐
│ ARX DESKTOP                    │
│                                │
│ 1️⃣  Connect Your Accounts     │
│ 2️⃣  Choose Your Markets       │
│ 3️⃣  Understand Regimes        │
│ 4️⃣  Customize Your Workspace  │
│                                │
├────────────────────────────────┤
│                                │
│ Select your exchange / wallet: │
│                                │
│ [🔗 Binance] — Spot & Perps  │
│ [🔗 Kraken]  — Spot           │
│ [🔗 Coinbase]— Spot           │
│ [🔗 MetaMask]— DeFi wallet    │
│ [🔗 Phantom] — Solana wallet  │
│                                │
│ We read-only your balances.    │
│ Your keys stay in your wallet. │
│                                │
│ [Skip for Now] [Next] ▶       │
└────────────────────────────────┘
```

### Onboarding Step 2: Choose Your Markets

User selects which assets to track initially.

```
SCREEN: "What Do You Trade?"

┌────────────────────────────────┐
│ 2️⃣  Choose Your Markets       │
│                                │
│ Select at least 3 assets:      │
│                                │
│ ☑ BTC (Bitcoin)  — Major      │
│ ☑ ETH (Ethereum) — Major      │
│ ☑ SOL (Solana)   — Alt        │
│ ☐ AVAX (Avalanche) — Alt      │
│ ☐ LINK (Chainlink) — Oracle   │
│ ☐ USDC (USD Coin) — Stablec.  │
│                                │
│ [+ Add More] [Auto-Fill Top 5] │
│                                │
│ [Back] [Next] ▶               │
└────────────────────────────────┘
```

### Onboarding Step 3: Understand Regimes (v2.0 — 6 States)

User learns about the Regime Bar and the 6 regime states (updated in v2.0).

```
SCREEN: "The Regime Bar — Your Trading Compass"

┌────────────────────────────────┐
│ 3️⃣  Understand Regimes        │
│                                │
│ Every successful trader adapts │
│ their strategy to the market   │
│ regime. Arx tells you what     │
│ regime we're in, always.       │
│                                │
├────────────────────────────────┤
│ CAROUSEL: Swipe through 6...  │
│                                │
│ Card 1 (visible):              │
│ 🟢 TRENDING UP                │
│ ┌──────────────────────────┐  │
│ │ Momentum is upward. The  │  │
│ │ trend is your friend.    │  │
│ │ Buy dips, follow trends. │  │
│ │ Stop below recent lows.  │  │
│ └──────────────────────────┘  │
│ ◀  1 / 6  ▶                    │
│                                │
│ [Next slides: TRENDING DOWN,   │
│  RANGE-BOUND, TRANSITION,      │
│  COMPRESSION, CRISIS]          │
│                                │
│ [Back] [Skip] [Next] ▶        │
└────────────────────────────────┘

Card 2: 🔴 TRENDING DOWN
  "Momentum is downward. Don't
   fight the trend. Short rallies,
   respect the downtrend. Trail
   stops on short positions."

Card 3: 🔵 RANGE-BOUND
  "Market is oscillating between
   support & resistance. Mean
   reversion works. Fade extremes,
   don't chase breakouts."

Card 4: 🟡 TRANSITION
  "Regime is changing. Market is
   ambiguous. Reduce exposure
   until direction clears. Wait
   for confirmation."

Card 5: 🟣 COMPRESSION
  "Volatility is at a low. A big
   move is building. Don't trade
   this — wait for breakout
   confirmation."

Card 6: 💔 CRISIS
  "Market is dislocated. Liquidity
   evaporating. Preserve capital.
   Close non-essential positions.
   Don't add exposure."
```

### Onboarding Step 4: Customize Your Workspace

User chooses a preset layout and optionally customizes widgets.

```
SCREEN: "Customize Your Workspace"

┌────────────────────────────────┐
│ 4️⃣  Customize Your Workspace  │
│                                │
│ Choose a layout preset:        │
│                                │
│ ☑ 🏠 Overview (Recommended)   │
│   └─ Watchlist, Chart, Positions│
│   └─ Good for starting out     │
│                                │
│ ☐ 📈 Trading (for active traders)│
│   └─ Chart, Order Entry, Alerts  │
│                                │
│ ☐ 🔍 Analysis (for researchers) │
│   └─ Multi-chart, Indicators     │
│                                │
│ ☐ 👥 Radar (for followers)     │
│   └─ Wallet Discovery, Profiles  │
│                                │
│ Or create custom:              │
│ ☐ [+ Create Custom Layout]     │
│                                │
│ [Back] [Finish] ✓             │
└────────────────────────────────┘
```

### Onboarding Step 5: Welcome Screen

Final screen before entering the app. Introduces Copilot and next steps.

```
SCREEN: "Welcome to Arx"

┌────────────────────────────────┐
│ ✓ Onboarding Complete!        │
│                                │
│ Your workspace is ready.       │
│ Current regime: TRENDING UP ✓  │
│                                │
│ Next Steps:                    │
│                                │
│ 1. Explore your portfolio      │
│    [See Portfolio]             │
│                                │
│ 2. Browse smart traders        │
│    [Visit Radar Network]       │
│                                │
│ 3. Chat with Copilot          │
│    "Hey, what should I do?"    │
│                                │
│ 4. Take a tour                 │
│    [View Interactive Guide]    │
│                                │
│ [Start Trading] ▶             │
└────────────────────────────────┘
```

---

## 18. ANIMATION & TRANSITION SPECIFICATIONS

### Transition Durations (All Animations)

```
FAST (instant interactions):
  200ms — Widget open/close, state toggle, visibility change

MEDIUM (considered decisions):
  300ms — Navigate to new screen, layout switch, modal open

SLOW (celebration/emphasis):
  500ms — Milestone animations, confetti, equity curve draw
```

### Easings

```
SPRING (bouncy, delightful):
  cubic-bezier(0.36, 0, 0.66, -0.56)
  Used: Card appearances, button presses, position updates

EASE-OUT-CUBIC (smooth deceleration):
  cubic-bezier(0.215, 0.61, 0.355, 1)
  Used: Fade in/out, scroll stops, modal entrance

LINEAR (neutral, no emotion):
  linear
  Used: Loading bars, data transitions, chart animations
```

### Regime Bar Animations

```
TRENDING UP (Upward gradient shimmer):
  ┌──────────────────────┐
  │ TRENDING ↑           │
  │ ╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱ │  ← Shimmer moves upward, 3 sec loop
  │ ██████████████████   │  ← Bar color: Emerald (#34D399)
  └──────────────────────┘
  Animation: Repeating gradient shift (left to right, 3s cycle)
  Intensity: Subtle, not flashy

TRENDING DOWN (Downward gradient shimmer):
  ┌──────────────────────┐
  │ TRENDING ↓           │
  │ ╲╲╲╲╲╲╲╲╲╲╲╲╲╲╲╲╲╲ │  ← Shimmer moves downward, 3 sec loop
  │ ██████████████████   │  ← Bar color: Red (#F87171)
  └──────────────────────┘
  Animation: Repeating gradient shift, opposite direction

RANGE-BOUND (Horizontal pulse):
  ┌──────────────────────┐
  │ RANGE-BOUND          │
  │ ──────────────────── │  ← Opacity oscillates
  │ ██████████████████   │  ← Bar color: Blue (#60A5FA)
  └──────────────────────┘
  Animation: Opacity pulse 100% → 70% → 100%, 4s cycle

TRANSITION (Brightness pulse):
  ┌──────────────────────┐
  │ TRANSITION           │
  │                      │  ← Entire bar brightness changes
  │ ██████████████████   │  ← Bar color: Amber (#FBBF24)
  └──────────────────────┘
  Animation: Brightness 100% → 80% → 100%, 3s cycle

COMPRESSION (Breathing pulse):
  ┌──────────────────────┐
  │ COMPRESSION          │
  │                      │  ← Bar width breathing
  │ ██████████████████   │  ← Bar color: Indigo (#A78BFA)
  └──────────────────────┘
  Animation: Scale 100% → 95% → 100%, 4s cycle

CRISIS (Red flash warning):
  ┌──────────────────────┐
  │ 🚨 CRISIS 🚨         │  ← Icon appears
  │ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │  ← Dashed bar (not solid)
  │ ██████████████████   │  ← Bar color: Red-dark (#EF4444)
  └──────────────────────┘
  Animation: Opacity pulse 100% → 50% → 100%, 1s cycle (urgent)
```

### Card Animations

```
CARD ENTRANCE (opening a widget, new signal card):
  Duration: 200ms
  Easing: ease-out-cubic
  Transform: translateY(8px) + opacity 0→1
  Effect: Card slides up slightly while fading in

CARD EXIT (closing a widget):
  Duration: 150ms
  Easing: ease-out-cubic
  Transform: translateY(-4px) + opacity 1→0
  Effect: Card slides up slightly while fading out

CARD HOVER (desktop only):
  Duration: 100ms
  Easing: ease-out-cubic
  Transform: scale(1.01) + shadow increase
  Effect: Subtle lift on mouse hover
```

### Chart Animations

```
EQUITY CURVE DRAW (on portfolio view):
  Duration: 2000ms (slower, more impactful)
  Easing: linear
  Effect: Line draws from left to right as if plotting in real-time

CANDLESTICK FORMATION:
  Duration: 300ms
  Easing: ease-out-cubic
  Effect: Wicks & body fade in as candle forms

INDICATOR TRANSITIONS:
  Duration: 400ms
  Easing: ease-out-cubic
  Effect: Indicator lines fade in when toggled on
```

### Position & Trade Animations

```
POSITION ENTRY ANIMATION (new position appears in table):
  Duration: 300ms
  Easing: ease-out-cubic
  Transform: slideInFromTop + highlight
  Effect: Row slides in from top, background briefly highlights

POSITION UPDATE (price/PnL changes):
  Duration: 500ms
  Easing: ease-out-cubic
  Effect: Number flashes (color changes to indicate direction)
           Green flash = +PnL, Red flash = -PnL, then fades to normal

LIQUIDATION RISK ANIMATION (safety gauge enters danger zone):
  Duration: 1000ms
  Easing: ease-out-cubic
  Effect: Bar animates to new level, color shifts red, pulse 3x

TRADE COMPLETION (trade closes):
  Duration: 600ms
  Easing: ease-out-cubic
  Effect: Row animates out (slideOutToRight), then removes
```

### Notification Animations

```
NOTIFICATION ENTRANCE (top right):
  Duration: 300ms
  Easing: ease-out-cubic
  Transform: slideInFromRight + opacity 0→1
  Effect: Notification slides in from right edge

NOTIFICATION DISMISS:
  Duration: 200ms
  Easing: ease-out-cubic
  Transform: slideOutToRight + opacity 1→0
  Effect: Notification slides out right

NOTIFICATION STACKING:
  If 2+ notifications: Stack vertically, each slides in offset by 80px
```

### Loading States

```
SPINNER (fetching data):
  Style: Rotating circle with gradient (Arx blue → emerald)
  Duration: 2000ms per rotation (slow, not frantic)
  Stops immediately when data loads

SKELETON (placeholder content):
  Style: Subtle gradient pulse on empty content area
  Duration: 1500ms per pulse (breathing animation)
  Replaced by real content as it loads

PROGRESS BAR (multi-step processes):
  Style: Animated line across width, color based on context
  Duration: Smooth, no stuttering
  Completes at 95% until actual completion
```

### Confirmation & Celebration

```
ORDER CONFIRMATION:
  ✓ Checkmark appears
  Duration: 400ms
  Easing: spring (bouncy)
  Effect: Checkmark scales 0→1.1→1 with spring
  Color: Green (#34D399)
  Sound: Subtle "ping" (optional)

TRADE CLOSED SUCCESSFULLY:
  🎉 Confetti animation
  Duration: 2000ms
  Effect: Confetti falls from top (if significant profit)
  Sound: Celebratory chime (optional)

POSITION MILESTONE (e.g., +100% profit):
  ⭐ Star appears & scales
  Duration: 1000ms
  Easing: spring
  Effect: Star scales up, rotates, then settles
```

### Keyboard Shortcut Feedback

```
When shortcut is pressed:
  Visual: Flash background of target element (50ms)
  Color: Accent blue (#3B82F6)
  Sound: Optional "done" chime

When shortcut is invalid:
  Visual: Red shake animation on screen
  Duration: 200ms
  Sound: Optional error beep
```

---

## CONCLUSION

Arx Desktop v2.0 Foundation integrates all design system tokens, dark mode spec, typography scale, spacing grid, and the 6-regime model with directional trending. The Radar rename (from "Alpha") is applied throughout, and both Tier 2 features (Confluence Panel with P1-P5 taxonomy, Carry Strategy) are fully specified for future unlock.

The desktop experience maintains mobile v1.3's intelligence while leveraging the larger canvas for side-by-side comparison, multi-ticker workflows, and persistent context awareness. Widget linking, layout presets, keyboard shortcuts, and progressive disclosure ensure both novice and power users can thrive.

**Specification Status:** v2.0 Complete. Ready for design system implementation and engineering scoping.

**Next Steps:** Part 2 (Screen Definitions) will detail each of the 12 desktop screens with full wireframes, interactions, and state specifications.

---

**File Metadata:**

- **Title:** ARX DESKTOP APP — PSEUDO-PROTOTYPE v2.0
- **Subtitle:** Part 1: Foundation (Competitive Synthesis · Design Tokens · Dark Mode · Typography · Spacing · Widget Architecture · Layout System · Regime Bar · Wallet Classification · Sizing Guide · Three-Gate · Tier 2 Selection · Navigation · Keyboard Shortcuts · Onboarding · Animations)
- **Version:** v2.0 — Integrates Design System v1.0, Executable Spec v1.0, Radar rename, 6-regime model
- **Date:** March 2, 2026
- **Total Lines:** 1,400+
- **Alignment:** Design System v1.0, Executable Spec v1.0, Mobile v1.3

---

**End of Part 1: Foundation**
