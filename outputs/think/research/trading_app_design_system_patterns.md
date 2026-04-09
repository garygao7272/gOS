# Trading App Design System Patterns Research

**Date:** 2026-04-06
**Purpose:** Actionable design system patterns from Robinhood, Coinbase, TradingView, Binance, Bybit, and best-in-class fintech apps -- for Arx design system enrichment.
**Upstream:** `specs/Arx_4-2_Design_System.md`, `specs/Arx_4-3_Design_Taste.md`

---

## 1. Color Systems

### 1.1 Semantic Color Architecture (Industry Consensus)

Every production trading app uses a three-layer color architecture:

| Layer | Purpose | Example |
|-------|---------|---------|
| **Spectrum** | Raw hue ramps (blue-10 through blue-100) | Coinbase CDS: `blue60: '0,82,255'` |
| **Semantic** | Intent-based tokens (bgPositive, fgNegative) | Coinbase CDS: `bgPositive: 'rgb(9,133,81)'` |
| **Component** | Scoped to specific UI (chart-candle-up, regime-bar-crisis) | TradingView: `--tv-color-toolbar-button-text-active` |

**Arx gap:** Arx has strong spectrum (Stone/Water ramps) and component tokens, but the semantic layer is thin (only 4 tokens: positive, negative, warning, info). Coinbase CDS v8 has ~30+ semantic tokens including `bgPrimary`, `bgSecondary`, `fgPrimary`, `fgMuted`, `bgPositive`, `bgNegative`, `bgWarning`, `bgLine`, `bgLinePrimary`.

### 1.2 Profit/Loss Color Pairs

| App | Profit | Loss | Neutral | Notes |
|-----|--------|------|---------|-------|
| Robinhood | Custom green (Robin Neon `#B7DF2F`) | Red | White | Brand-differentiated green |
| Coinbase Light | `rgb(9,133,81)` | `rgb(207,32,47)` | Gray | Classic forest green / crimson |
| Coinbase Dark | `rgb(39,173,117)` | `rgb(240,97,109)` | Gray | Lighter, higher luminance for dark bg |
| TradingView | `#26a69a` (teal-green) | `#ef5350` (red) | `#787b86` | Configurable per user |
| Binance | `#0ECB81` | `#F6465D` | `#848E9C` | High-saturation neon |
| Bybit | `#20B26C` | `#EF454A` | `#72768F` | Similar to Binance |
| **Arx current** | `#A6FF4D` | `#FF6B7F` | — | Lime green, coral red |

**Key insight from Coinbase:** They explicitly avoid using color as the sole indicator of profit/loss. Their accessibility team requires text labels AND directional icons (arrows) alongside color, because some cultures do not associate green=good / red=bad.

**Recommendation for Arx:** The current `#A6FF4D` (lime green) is distinctive but extremely saturated. Consider whether it causes eye fatigue during extended sessions. Coinbase's approach of shifting profit green lighter in dark mode (from `#098551` to `#27AD75`) is worth adopting -- Arx should define explicit light-mode variants even if dark-only for MVP.

### 1.3 Dark Mode Palette Strategies

| Strategy | Used By | How It Works |
|----------|---------|--------------|
| **Near-black with brand tint** | Robinhood (`#000000`), Arx (`#08060F`) | Pure/near-black bg, brand color tints surfaces |
| **Warm dark gray** | Coinbase dark mode | Dark but not black; warmer grays |
| **User-configurable** | TradingView | Users pick bg/fg, platform adapts |
| **System-matched** | All modern apps | `prefers-color-scheme` auto-detection |

**TradingView CSS variable pattern:**
```css
:root:not(.theme-dark) { /* light theme values */ }
.theme-dark:root { /* dark theme values */ }
```

This pattern with CSS custom properties and a class toggle on `:root` is the industry standard. TradingView exposes ~30 CSS custom properties for toolbar, pane, popup, and button states.

### 1.4 Data Visualization Palettes

Trading apps need 6-8 distinguishable colors for multi-series charts. The challenge: they must be distinguishable from profit/loss green/red AND from regime colors.

**Recommended data viz palette (8 colors, perceptually uniform):**
```
Series 1: #22D1EE (Water -- Arx brand)
Series 2: #F472B6 (Sky -- Arx brand)
Series 3: #FBBF24 (Amber)
Series 4: #34D399 (Emerald, distinct from profit green)
Series 5: #818CF8 (Indigo)
Series 6: #FB923C (Orange)
Series 7: #A78BFA (Stone Glow)
Series 8: #38BDF8 (Sky Blue)
```

---

## 2. Typography for Financial Data

### 2.1 The Tabular Numbers Rule (Non-Negotiable)

Every serious trading app enforces tabular (monospaced-width) numbers for financial data. This is the single most impactful typography decision for a trading app.

**Required CSS:**
```css
.price, .pnl, .quantity, .percentage {
  font-variant-numeric: lining-nums tabular-nums;
}
```

**Fallback for older browsers:**
```css
font-feature-settings: "lnum" 1, "tnum" 1;
```

**Why:** Without tabular figures, `$1,111.00` and `$8,888.00` have different widths. In scrolling lists of positions or prices, this means decimal points don't align vertically, making scanning impossible.

### 2.2 Font Selection for Financial Interfaces

| Category | Best Choices | Why |
|----------|-------------|-----|
| **Primary UI** | Inter, Roboto, SF Pro | Tabular figures built-in, excellent small-size legibility |
| **Price displays** | Inter (tabular), SF Mono, JetBrains Mono | Fixed-width digits, clear at 11-14px |
| **Headlines** | Custom brand serif or sans | Personality layer |
| **Robinhood** | "Robinhood Phonic" (custom sans) + Martina Plantijn (serif for headlines) | Brand differentiation |
| **Coinbase** | System stack with CDS overrides | Platform-native feel |

**Arx current:** Inter for UI, Inter tabular for numbers. This is the correct choice. Inter's tabular figures are excellent.

### 2.3 Typography Scale for Trading Data

Based on industry analysis, the critical type sizes for a trading app:

| Element | Size | Weight | Feature | Example |
|---------|------|--------|---------|---------|
| Portfolio total value | 28-34px | 600-700 | `tabular-nums` | `$142,847.23` |
| Position PnL (card) | 18-22px | 600 | `tabular-nums` | `+$2,341.50` |
| Price in ticker/list | 14-16px | 500 | `tabular-nums` | `64,231.42` |
| Price change % | 13-14px | 500 | `tabular-nums` | `+3.24%` |
| Order book prices | 12-13px | 400 | `tabular-nums`, monospace | `64,231.42` |
| Timestamp | 11-12px | 400 | — | `14:32:05` |

### 2.4 Number Formatting Rules

| Rule | Correct | Wrong | Source |
|------|---------|-------|--------|
| Use real minus sign | `−$234.50` (U+2212) | `-$234.50` (hyphen-minus) | Unicode standard |
| Use currency symbols | `$`, `€`, `₿` | `USD`, `EUR`, `BTC` | Space efficiency |
| Trailing zeros | `$54.00` | `$54` | Tabular alignment |
| Locale formatting | `Intl.NumberFormat` | Manual string concat | i18n compliance |
| Thousands separator | `64,231.42` | `64231.42` | Scanability |

### 2.5 Price Change Indicators

Industry patterns for showing direction:

| Pattern | Example | Used By | Notes |
|---------|---------|---------|-------|
| Color + arrow icon | `↑ +3.24%` in green | Robinhood, Coinbase | Most accessible (Coinbase requirement) |
| Color only | `+3.24%` in green | Binance, Bybit | Fails accessibility |
| Background pill | Green pill with white text | Robinhood portfolio | High visibility |
| Inline triangle | `▲ 3.24%` | TradingView | Compact |
| Color + sign | `+3.24%` / `−1.82%` | Most apps | Minimum viable |

**Recommendation:** Always use color + sign + directional icon. This is the only pattern that passes Coinbase's accessibility bar (color not sole indicator).

---

## 3. Component Patterns Unique to Trading

### 3.1 Order Entry Form

**Robinhood pattern (swipe-to-confirm):**
1. Bottom sheet slides up from asset detail screen
2. Simple form: Buy/Sell toggle, amount ($ or shares), order type dropdown
3. Review screen shows: estimated price, fees, buying power impact
4. **Swipe up to confirm** (not tap) -- intentional friction for financial actions
5. Success: checkmark animation + confetti (controversial but effective for engagement)

**Binance/Bybit pattern (professional):**
1. Split screen: chart top, order form bottom (or side panel on tablet)
2. Order type tabs: Limit / Market / Stop-Limit / Trailing Stop
3. Leverage slider with color-coded risk zones (green→yellow→orange→red)
4. Size input with quick-set buttons: 25% / 50% / 75% / 100% of available margin
5. Estimated liquidation price shown inline before confirmation
6. Confirmation modal with full position summary

**For Arx (sophisticated but accessible):**
- Bottom sheet order entry (mobile native)
- Swipe-to-confirm for market orders (Robinhood influence)
- Tap-to-confirm with explicit modal for limit/stop orders
- Leverage selector with risk gradient, not just a number
- Always show: estimated entry, liquidation price, max loss before confirmation

### 3.2 Price Ticker / Watchlist Item

**Standard watchlist row anatomy:**
```
[Icon] [Name/Symbol]              [Price]  [Change]
 BTC    Bitcoin        ·····    $64,231.42  ▲ +3.24%
                                            [sparkline]
```

| Element | Alignment | Typography | Animation |
|---------|-----------|-----------|-----------|
| Symbol | Left | 14px/600 | None |
| Name | Left, below symbol | 12px/400, secondary color | None |
| Price | Right | 14px/500, tabular-nums | Flash on update (200ms) |
| Change % | Right, below price | 13px/500, colored | Direction arrow |
| Sparkline | Right, inline or below | 32x48px SVG | Draw on scroll-in |

**Price flash animation (industry standard):**
- Price increases: brief green background flash (`200ms ease-out`)
- Price decreases: brief red background flash (`200ms ease-out`)
- Duration: 200-300ms, never longer (distracting in fast markets)
- Implementation: CSS transition on background-color with JS toggling a class

### 3.3 Portfolio Card

**Robinhood portfolio card:**
- Total value: large, top-center, bold
- Day change: colored pill below value (`+$234.50 (+1.24%)`)
- Sparkline chart: full-width, 120px tall, colored by day direction
- Time range selector: 1D / 1W / 1M / 3M / 1Y / ALL (horizontal pills)

**Professional crypto portfolio card:**
- Total equity: large display
- Unrealized PnL: colored, with both $ and %
- Realized PnL (today): secondary
- Margin used / available: progress bar
- Positions summary: count + direction (3 Long, 1 Short)

### 3.4 Position Card

**Standard position card anatomy (Bybit/Binance pattern):**
```
┌─────────────────────────────────────────┐
│ BTC/USDT  LONG  10x           ⋮ [close] │
│─────────────────────────────────────────│
│ Size        Entry       Mark       Liq  │
│ 0.5 BTC    $63,200    $64,231   $58,100 │
│─────────────────────────────────────────│
│ Unrealized PnL          ROE              │
│ +$515.50 (+1.63%)       +16.3%           │
│─────────────────────────────────────────│
│ [TP/SL]  [Add Margin]  [Close Position] │
└─────────────────────────────────────────┘
```

**Key data points (every exchange shows these):**
- Symbol + direction (Long/Short) + leverage
- Size (in base currency)
- Entry price, mark price, liquidation price
- Unrealized PnL ($ and %)
- ROE (Return on Equity) -- leveraged return
- TP/SL status indicators
- Quick actions: Close, Add Margin, Set TP/SL

### 3.5 Chart Component Patterns

**TradingView charting library patterns:**
- CSS custom properties for all colors (30+ variables)
- Theme toggle via class on `:root` element
- Mobile: touch gestures for pan, pinch-zoom, long-press for crosshair
- Overlay system: indicators stack as transparent layers
- Time axis: adaptive formatting (HH:MM for intraday, DD/MM for daily)

**Chart interaction patterns for mobile:**
- Single tap: show price tooltip at tap point
- Long press: activate crosshair mode (price + time)
- Horizontal drag: pan time axis
- Pinch: zoom time axis
- Double tap: reset zoom to default
- Swipe up from chart bottom: expand chart to full screen

### 3.6 Order Book Component

**Standard order book layout:**
```
         ASKS (sells) -- red
    Price     |  Size  |  Total
  64,235.00  |  1.234 |  ████████░░
  64,234.50  |  0.567 |  ████░░░░░░
  64,234.00  |  2.891 |  ██████████
─────────── SPREAD: $1.50 (0.002%) ──
  64,232.50  |  3.456 |  ██████████
  64,232.00  |  0.789 |  █████░░░░░
  64,231.50  |  1.234 |  ████████░░
         BIDS (buys) -- green
```

- Depth visualization: horizontal bars showing cumulative volume
- Color coding: asks in red/negative, bids in green/positive
- Tap on price: auto-fills order form with that price
- Grouping selector: 0.01 / 0.1 / 1 / 10 (decimal precision)
- Real-time animation: rows shift, sizes update with subtle flash

---

## 4. Information Density Strategies

### 4.1 Progressive Disclosure (Robinhood Model)

Robinhood's core innovation: extreme simplicity by default, complexity available on demand.

| Level | What's Shown | How to Access |
|-------|-------------|---------------|
| L0: Glanceable | Portfolio value, day change, watchlist prices | Default view |
| L1: Summary | Position details, basic chart | Tap asset |
| L2: Detail | Order book, advanced chart, fundamentals | Scroll down or tab |
| L3: Expert | Options chains, advanced order types, Greeks | Legend mode toggle |

### 4.2 Density Modes (TradingView / Binance Approach)

Professional trading platforms offer explicit density controls:

| Mode | Row Height | Font Size | Padding | Use Case |
|------|-----------|-----------|---------|----------|
| Comfortable | 56-64px | 14-16px | 16px | Casual monitoring |
| Standard | 44-48px | 13-14px | 12px | Active trading |
| Compact | 32-36px | 11-12px | 8px | Professional, many positions |

**Arx recommendation:** Start with "Standard" as default, offer "Compact" for S2 (independent traders). Never go below 32px row height on mobile (touch target minimum).

### 4.3 Screen Real Estate Budget (Mobile 390x844)

Based on analysis of top trading apps:

| Zone | Height | Content |
|------|--------|---------|
| Status bar | 54px | System (fixed) |
| Navigation header | 44-48px | Title, back, actions |
| Primary content | 560-600px | Charts, lists, forms |
| Tab bar | 49px | Bottom navigation |
| Safe area (bottom) | 34px | Home indicator |
| **Usable content** | **~560px** | **After all chrome** |

**Key insight:** On a standard iPhone, you get ~560px of usable vertical space. A position card (120px) + order form (300px) + chart preview (140px) = 560px exactly. This is why bottom sheets are essential -- they reclaim the chart space when order entry is needed.

### 4.4 The Revolut Dashboard Pattern

Revolut's approach to dense financial data on mobile:

- **Layered navigation:** Horizontal scroll between account types (checking, savings, crypto)
- **Color-coded categories:** Spending categories use consistent colors across all views
- **Collapsible sections:** Each section has a disclosure triangle; tapping collapses to single-line summary
- **Pull-to-refresh:** Standard iOS/Android pattern, refreshes all data streams

---

## 5. Animation in Financial UX

### 5.1 Animation Timing Standards

| Category | Duration | Easing | When |
|----------|----------|--------|------|
| Price flash | 200ms | ease-out | Price tick update |
| Chart transition | 300ms | ease-in-out | Timeframe change |
| Bottom sheet entry | 350ms | cubic-bezier(0.4, 0, 0.2, 1) | Order form open |
| Bottom sheet dismiss | 250ms | ease-in | Swipe down close |
| Loading skeleton | 1500ms loop | ease-in-out | Data loading |
| Success checkmark | 400ms | spring(1, 80, 10) | Order confirmed |
| Tab switch | 200ms | ease-out | Navigation |
| List item appear | 150ms staggered (50ms delay per item) | ease-out | List population |

### 5.2 Price Animation Patterns

**Flash-on-update (most common):**
```css
.price-up {
  animation: flash-green 200ms ease-out;
}
.price-down {
  animation: flash-red 200ms ease-out;
}
@keyframes flash-green {
  0% { background-color: rgba(166, 255, 77, 0.25); }
  100% { background-color: transparent; }
}
```

**Counter animation (Robinhood portfolio):**
- Portfolio value animates between old and new value using requestAnimationFrame
- Duration: 400ms for small changes, 800ms for large changes
- Easing: ease-out (fast start, gentle landing)
- Never animate individual price ticks in lists (too distracting at scale)

**Rules:**
- Animate portfolio total value changes (single focal point)
- Flash individual prices in watchlists (background color pulse)
- Never animate all prices simultaneously (visual chaos)
- Chart transitions use crossfade, not slide
- Skeleton loading for initial data, never spinners for real-time updates

### 5.3 Loading States for Real-Time Data

| State | Pattern | Duration | Visual |
|-------|---------|----------|--------|
| Initial load | Skeleton shimmer | Until data arrives | Gray shapes matching layout |
| Reconnecting | Subtle top banner | While disconnected | "Reconnecting..." amber bar |
| Stale data | Dim + timestamp | After 5s no update | Reduced opacity + "Last: 14:32:05" |
| Error | Inline error | Until retry succeeds | Red text + retry button |
| Refreshing | Pull-to-refresh spinner | 1-3s typical | Standard platform spinner |

**Stale-while-revalidate pattern:** Show cached data immediately, fetch fresh data in background, update when received. This is the standard for all trading apps -- never show a loading spinner when you have cached data.

### 5.4 Order Confirmation Flow Animation

**Robinhood flow:**
1. Review screen slides up (350ms)
2. User swipes up to confirm
3. On swipe complete: haptic feedback (medium impact)
4. Processing: button shows spinner (200-2000ms)
5. Success: green checkmark draws in (400ms spring animation)
6. Screen auto-dismisses after 1.5s

**Professional flow (Bybit):**
1. Confirmation modal fades in (200ms)
2. User taps "Confirm"
3. Button shows "Submitting..." with spinner
4. Success: toast notification slides in from top
5. Position appears in positions list with highlight animation

---

## 6. Trust & Safety Patterns

### 6.1 Risk Communication Hierarchy

| Level | Visual Treatment | When Used | Example |
|-------|-----------------|-----------|---------|
| **Info** | Blue text, info icon | Educational context | "Limit orders execute at your price or better" |
| **Caution** | Amber background, warning icon | Elevated risk | "This asset has high volatility (ATR >5%)" |
| **Warning** | Red border, alert icon, requires acknowledgment | Significant risk | "Your liquidation price is within 5% of mark price" |
| **Danger** | Full-screen modal, red, explicit confirmation | Destructive/irreversible | "Close all positions? This cannot be undone" |

### 6.2 Confirmation Dialog Patterns

**Single-action confirmation (standard):**
```
┌─────────────────────────────────────┐
│          Close Position?            │
│                                     │
│  BTC/USDT LONG 0.5 BTC             │
│  Estimated PnL: +$515.50           │
│                                     │
│  [Cancel]          [Close Position] │
└─────────────────────────────────────┘
```

**High-risk confirmation (leverage change, large order):**
```
┌─────────────────────────────────────┐
│    ⚠ Increase Leverage to 50x?     │
│                                     │
│  Current: 10x → New: 50x           │
│  Liquidation price moves:           │
│  $58,100 → $63,000                  │
│                                     │
│  ⚠ Your position will be           │
│  liquidated if price drops 1.9%     │
│                                     │
│  [Cancel]    [I Understand, Apply]  │
└─────────────────────────────────────┘
```

**Destructive action (close all, withdraw):**
- Red-styled confirm button
- Requires typing confirmation text OR swipe gesture
- Shows explicit consequences (estimated PnL impact)
- 3-second delay before button becomes active (anti-misclick)

### 6.3 Leverage Risk Visualization

**Binance/Bybit leverage slider pattern:**
- Horizontal slider: 1x to 125x (or max)
- Color gradient on track: green (1-5x) → yellow (5-20x) → orange (20-50x) → red (50x+)
- Label updates in real-time: shows margin required + liquidation distance
- Snap points at common values: 1x, 2x, 3x, 5x, 10x, 20x, 50x, 100x
- Below slider: "Estimated liquidation price: $XX,XXX" updates live

### 6.4 Regulatory Compliance Patterns

- Risk disclaimers on first use (full-screen, must scroll to bottom)
- Leverage risk acknowledgment (checkbox + confirm)
- Position size warnings when exceeding % of portfolio
- Cool-down periods after large losses (some jurisdictions)
- "Are you sure?" for orders >X% of account equity

---

## 7. Mobile-Specific Patterns

### 7.1 Bottom Sheet Order Entry

**The bottom sheet is THE mobile trading pattern.** Every major app uses it.

| Property | Value | Notes |
|----------|-------|-------|
| Initial height | 40-50% screen | Shows essential order fields |
| Expanded height | 85-90% screen | Full order form with advanced options |
| Dismiss | Swipe down or tap outside | Standard gesture |
| Snap points | 2-3 detents | Collapsed (peek), half, full |
| Background | Blurred chart visible behind | Maintains market context |
| Corner radius | 12-16px top corners | Platform standard |
| Handle | 36x5px pill, centered | Visual grab indicator |

**Bottom sheet content layout:**
```
┌──────────────────── [═══] ─────────────────────┐
│  [Buy] [Sell]                    Order Type: ▼  │
│─────────────────────────────────────────────────│
│  Price:  [          64,231.42          ]  USDT  │
│  Size:   [                    ]  BTC    [Max]   │
│  ─── Quick Size: [25%] [50%] [75%] [100%] ───  │
│─────────────────────────────────────────────────│
│  Available: 12,450.00 USDT                      │
│  Est. Fee:  $3.21                               │
│  Liq. Price: $58,100                            │
│─────────────────────────────────────────────────│
│  ┌─────────────────────────────────────────┐    │
│  │        ═══ Swipe to Buy BTC ═══         │    │
│  └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
```

### 7.2 Swipe Actions

| Action | Gesture | Feedback | Used For |
|--------|---------|----------|----------|
| Swipe to confirm trade | Swipe right/up on button | Haptic + visual fill | Order submission |
| Swipe to close position | Swipe left on position card | Red reveal + close button | Quick close |
| Swipe to add to watchlist | Swipe right on asset | Green reveal + star icon | Watchlisting |
| Pull to refresh | Pull down on list | Platform spinner | Refresh market data |
| Swipe between tabs | Horizontal swipe | Page indicator dots | Navigate sections |

### 7.3 Pull-to-Refresh for Market Data

**Pattern:** Standard platform pull-to-refresh gesture, BUT with nuance for real-time apps:

- WebSocket data updates automatically (no pull needed)
- Pull-to-refresh triggers: re-subscribe to WebSocket, refresh REST endpoints, clear stale cache
- Show "Last updated: [timestamp]" when WebSocket disconnects
- Never show spinner over live data; use subtle top-bar indicator

### 7.4 Haptic Feedback Map

| Action | Haptic Type | When |
|--------|-------------|------|
| Order submitted | Medium impact | Swipe completes |
| Order filled | Success notification | Background fill event |
| Price alert triggered | Warning notification | Threshold crossed |
| Leverage slider snap | Light impact | Reaches snap point |
| Tab switch | Selection tick | Bottom tab change |
| Error | Error notification | Order rejected |

### 7.5 Gesture-First Navigation

**Robinhood auto-send feature:** Place order with just a few taps, instantly entering a trade within one screen. This removes the confirmation step for experienced users -- toggled in settings.

**Robinhood Legend on mobile (2025):** Advanced charts brought to mobile with multi-touch gestures for TradingView-quality charting.

---

## 8. Arx-Specific Recommendations

Based on this research, priority gaps in the current Arx design system (`specs/Arx_4-2_Design_System.md`):

### 8.1 Expand Semantic Color Layer

Add these tokens to the existing semantic colors section:

```
--color-fg-primary        (text on backgrounds)
--color-fg-secondary      (muted text)
--color-fg-positive       (profit text - distinct from bg-positive)
--color-fg-negative       (loss text)
--color-bg-positive-subtle (profit background tint, ~8% opacity)
--color-bg-negative-subtle (loss background tint, ~8% opacity)
--color-bg-warning-subtle  (warning background tint)
```

### 8.2 Add Price Typography Tokens

```css
--font-price: 'Inter', system-ui;
--font-price-feature: 'lnum' 1, 'tnum' 1;
--font-price-variant: lining-nums tabular-nums;
--font-mono: 'JetBrains Mono', 'SF Mono', monospace;
```

### 8.3 Add Animation Timing Tokens

```css
--duration-flash: 200ms;
--duration-transition: 300ms;
--duration-sheet-enter: 350ms;
--duration-sheet-exit: 250ms;
--duration-skeleton: 1500ms;
--duration-success: 400ms;

--ease-sheet: cubic-bezier(0.4, 0, 0.2, 1);
--ease-flash: ease-out;
--ease-standard: ease-in-out;
```

### 8.4 Define Position Card Component Spec

The position card is the most critical trading component. Define:
- Fixed anatomy (symbol, direction, leverage, size, entry, mark, liq, PnL, ROE)
- Color rules (Long=positive, Short=negative for direction badge)
- Always show liquidation price relative to current (% distance)
- Quick actions row (TP/SL, Add Margin, Close)

### 8.5 Add Trust/Safety Component Patterns

- Swipe-to-confirm for destructive financial actions
- Leverage risk gradient (visual, not just numeric)
- Liquidation proximity warning (inline, always visible)
- Confirmation modal hierarchy (info → caution → warning → danger)

---

## Sources

- [Robinhood Visual Identity](https://robinhood.com/us/en/newsroom/a-new-visual-identity/)
- [Coinbase Design System (CDS)](https://cds.coinbase.com/)
- [CDS Theming](https://cds.coinbase.com/getting-started/theming/)
- [CDS v8 Migration Guide](https://cds.coinbase.com/guides/v8-migration-guide)
- [Coinbase Open Source CDS](https://www.coinbase.com/blog/Coinbase-has-open-sourced-its-design-system)
- [Coinbase Accessibility](https://www.coinbase.com/blog/how-accessibility-drives-product-quality-at-Coinbase)
- [TradingView CSS Color Themes](https://www.tradingview.com/charting-library-docs/latest/customization/styles/CSS-Color-Themes/)
- [TradingView Mobile Development](https://www.tradingview.com/charting-library-docs/latest/mobile_specifics/)
- [TradingView Customization](https://www.tradingview.com/charting-library-docs/latest/customization/)
- [Fintech Typography Part 1: Readable Money](https://medium.com/design-bootcamp/the-elements-of-fintech-typography-part-1-readable-money-b6c1226acbde)
- [Choosing Typefaces for Fintech (Smashing Magazine)](https://www.smashingmagazine.com/2023/10/choose-typefaces-fintech-products-guide-part1/)
- [Financial App Design Strategies (Netguru)](https://www.netguru.com/blog/financial-app-design)
- [Fintech Design Guide 2026 (Eleken)](https://www.eleken.co/blog-posts/modern-fintech-design-guide)
- [Robinhood UX Tricks](https://medium.com/design-bootcamp/ux-tricks-from-robinhood-app-c485d6fba7a8)
- [Robinhood Legend Mobile Charts](https://robinhood.com/us/en/newsroom/introducing-robinhood-legend-charts-on-mobile/)
- [Robinhood HOOD Summit 2025](https://robinhood.com/us/en/newsroom/hood-summit-2025-news/)
- [PnL Cards (Tealstreet)](https://docs.tealstreet.io/docs/trade/pnl-cards)
- [Motion UI Trends 2025](https://www.betasofttechnology.com/motion-ui-trends-and-micro-interactions/)
- [Inter Font Review](https://madegooddesigns.com/inter-font/)
- [Design Robinhood System Design](https://www.systemdesignhandbook.com/guides/design-robinhood/)
