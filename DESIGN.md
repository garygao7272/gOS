# Arx Design System — Citadel & Moat

> Agent-friendly design language for Stitch MCP and other AI design tools.
> Source of truth: `specs/Arx_4-2_Design_System.md` (v5.7) + `specs/Arx_4-3_Design_Taste.md`

## Taste Framework (summary — full spec: `specs/Arx_4-3_Design_Taste.md`)

**Reference floor (BEAT these):**

- S7: Robinhood, eToro, Bitget, Phantom — these are the minimum, not the ceiling
- S2: Moomoo, Webull, Binance — same: minimum bar, not the target

**5 Litmus Tests (run on every screen):**

1. **$10M Test** — looks built by a design-obsessed team, not a hackathon
2. **Screenshot Test** — S7 user would screenshot to show a friend
3. **Ive's Care Test** — every pixel intentional, nothing filling space
4. **Empty State Test** — skeleton still looks premium without data
5. **3-Second Test** — hierarchy clear in 3 seconds without reading

**Density rule:** S7=low (cards, headlines, one CTA), S2=high (tables, data, everything visible). Shared screens default to S7.

**Arx advantage:** AI+human co-creation surpasses what any traditional team ships. Not "good enough for a startup" — best-in-class, period.

---

## Visual Theme & Atmosphere

Dark fortress aesthetic. A crypto trading terminal that feels like standing inside an amethyst citadel at night. Near-black backgrounds carry three points of violet undertone — never pure black, never navy. Sustained visual comfort across 8-16 hour trading sessions. Mobile-native (390×844 viewport, iPhone 14 Pro).

**Mood:** Authoritative, precise, calm under pressure. Not flashy — geological. Like stone that has stood for centuries.

**Density:** High information density controlled through spacing and typography hierarchy, not decoration. Every element serves function. The citadel has no ornamentation.

**Key rule: NO GRADIENTS.** Stone and Water never blend. They are two substances, one system. Separation is the design principle.

## Color Palette & Roles

### Primary Domain: Stone (Violet — Structure, AI, Actions)

- **Stone** (#B38DF4) — Primary actions, Execute Trade button, AI indicators, active states
- **Stone Lit** (#9B6FE0) — Hover state — darker into stone, not lighter
- **Stone Deep** (#7E50C7) — Pressed/active feedback, geological depth
- **Stone Glow** (#C19DF7) — Ambient glow, hover highlights, amethyst in light

### Secondary Domain: Water (Cyan — Data, Signals, Precision)

- **Water** (#22D1EE) — Prices, data streams, signal indicators, focused data inputs
- **Water Deep** (#0891B2) — Pressed/active data elements
- **Water Glow** (#67E8F9) — Moat surface shimmer, sparkline peaks, callouts

### Backgrounds & Surfaces (deepest to highest)

- **Obsidian** (#08060F) — Page background, absolute floor (amethyst in total darkness)
- **Chamber** (#0E0B1A) — Standard panels, cards (inner stone)
- **Rampart** (#151028) — Active cards, hovered panels, popovers (raised battlements)
- **Deep Keep** (#1C1438) — Modals, drawers, dialogs (below the keep)

### Text

- **Starlight** (#EDE9FE) — Primary text (white refracted through amethyst, not pure white)
- **Stone Mid** (#A09AB8) — Secondary text, metadata, timestamps
- **Shadow** (#4D4670) — Tertiary/disabled text

### Borders

- **Default** (#1E1636) — Subtle dividers, panel separators
- **Strong** (#2F2258) — Prominent dividers, elevated borders
- **Stone Accent** (#B38DF4) — Focused inputs, active navigation
- **Water Accent** (#22D1EE) — Data-focused inputs, chart boundaries

### Semantic (fixed, never change)

- **Positive/Gains** (#A6FF4D) — Bullish, gains, up trends (lime green)
- **Negative/Losses** (#FF6B7F) — Bearish, losses, alerts (coral red)
- **Warning** (#FFB847) — Caution, pending states (amber)
- **Info** (#4DB8FF) — Informational, neutral updates (sky blue)

### Regime Colors (market state badges — 6 fixed states)

> **Regime Pill Rule:** The RegimePill component uses the **regime state color** below, NOT --color-primary (#B38DF4). The pill is a semantic indicator of market state. Background: regime color at 15% opacity. Text: regime color at 100%. This applies everywhere the regime pill appears (C1-R0 header, C3 asset detail, regime bottom sheet).

- **Trending Up** (#10B981) — Emerald, strong uptrend
- **Trending Down** (#EF4444) — Red, strong downtrend
- **Range-bound** (#3B82F6) — Blue, consolidation
- **Transition** (#F59E0B) — Amber, regime shift in progress
- **Compression** (#8B5CF6) — Violet (lighter than Stone), breakout pending
- **Crisis** (#EA580C) — Deep orange, black swan event (not red — avoids 3-red collision)

### Color Temperature Rules

- **T0 Ice (80% of screen):** Obsidian bg, Chamber surfaces, Starlight text, subtle borders
- **T1 Cool (15%):** Stone/Water accents at low opacity, secondary text, data labels
- **T2 Warm (4%):** Active elements, badges, regime indicators, focused inputs
- **T3 Hot (1%):** Execute Trade button (solid Stone), critical alerts, regime shifts

## Typography Rules

- **Display/Headings:** Inter, weight 700 (Bold), letter-spacing -0.02em
- **Body Text:** Inter, weight 400 (Regular), letter-spacing 0
- **Secondary/Labels:** Inter, weight 500 (Medium), letter-spacing 0.01em
- **Numeric/Data/Prices:** JetBrains Mono, weight 500, font-variant-numeric: tabular-nums
- **Scale:** 11px (caption) / 12px (label) / 13px (body small) / 14px (body) / 16px (subtitle) / 20px (title) / 24px (display)

## Component Styling

### Glass Cards

- Background: rgba(91, 33, 182, 0.08) — stone-tinted glass, not navy
- Backdrop blur: 20px (thick stone glass)
- Border: 1px solid #1E1636
- Border radius: 16px (outer cards), 12px (inner elements)
- No box-shadow on cards — depth from surface color only

### Buttons

- **Primary (Execute Trade):** Solid #B38DF4 background, white text, 48px min-height, 160px min-width, border-radius 12px, shadow: 0 0 40px rgba(179,141,244,0.35)
- **Secondary:** Transparent background, #B38DF4 border, Stone text
- **Data/Info:** Transparent background, #22D1EE border or text, Water accent
- No gradients on any button — ever

### Badges & Chips

- Border-radius: 999px (fully rounded)
- Padding: 4px 10px
- Font: 11px Inter Medium
- Background: color at 15% opacity, text in full color

### Tab Bars

- Bottom tab bar, 5 items, 60px height + safe-area-inset-bottom
- Active: Stone Violet icon + label
- Inactive: Shadow (#4D4670) icon + label
- Background: Chamber (#0E0B1A) with top border

### Regime Bar

- Full-width horizontal strip at top of screen
- 4px height, color = current regime state
- Animates on regime transitions (300ms ease)

## Layout Principles

- **Grid:** 8px base unit. All spacing multiples of 4px or 8px
- **Mobile viewport:** 390×844 (iPhone 14 Pro), viewport-fit=cover
- **Safe areas:** env(safe-area-inset-\*) for status bar and home indicator
- **Content padding:** 16px horizontal
- **Card gap:** 12px between cards
- **Section gap:** 24px between sections
- **Touch targets:** 44px minimum

## Animation & Motion

- **Default transition:** 200ms ease-out (interactions)
- **Regime shift:** 300ms ease (color transitions)
- **Sheet/modal:** 350ms cubic-bezier(0.32, 0.72, 0, 1) (iOS spring)
- **Stone glow pulse:** Used ONLY on regime shifts and system alerts, never decoratively
- **Scroll:** momentum-based, -webkit-overflow-scrolling: touch

## What NOT to Do

- NO gradients anywhere — stone and water never blend
- NO pure white (#FFFFFF) — use Starlight (#EDE9FE)
- NO pure black (#000000) — use Obsidian (#08060F)
- NO navy/blue backgrounds — all surfaces carry violet undertone
- NO decorative elements — every pixel serves function
- NO mixing Stone and Water on the same element
- NO animations beyond regime shifts and state transitions

---

## Production UI Stack

> Technology choices for web prototype, React web, and React Native builds.

### CSS & Styling

- **Web:** Tailwind CSS v4 (`tailwindcss`) — Rust engine, CSS-variable theming, mobile-first
- **React Native:** NativeWind v4/v5 (`nativewind`) — same Tailwind classes as web
- **Supplement:** Open Props (`open-props`, 4.4kb) — animation easings, spacing scales

### Animation

- **Web:** Motion (`motion`, 3.8kb) — Web Animations API, off main thread. `<motion.div>` for React
- **Web (free):** View Transitions API (native), CSS scroll-driven animations (native)
- **React Native:** react-native-reanimated v4 (120fps, UI thread) + react-native-gesture-handler v3
- **Video:** Remotion (`remotion`) — walkthrough videos from Stitch screens

### Icons

- **Primary:** Lucide (`lucide-react`) — 1,500+ icons, ~200b each, tree-shakeable. Shadcn/v0/Bolt default
- **Finance supplement:** Tabler Icons (`@tabler/icons-react`) — `chart-candle`, `currency-bitcoin`, `chart-dots`
- **Custom SVG:** Copy trading indicator, risk gauge, signal strength, regime icons

### Components

- **Web:** Shadcn UI (`shadcn` CLI) — own the code. Plus: vaul (drawer), sonner (toasts), cmdk (palette), input-otp
- **React Native:** React Native Reusables (copy-paste, 8k stars) + @rn-primitives (Radix for RN) + NativeWind
- **Fallback (RN):** Gluestack UI v4 (`@gluestack-ui/themed`)

### Charts

- **Primary:** TradingView Lightweight Charts v5 (`lightweight-charts`, 35kb) — candlestick, volume, multi-pane, touch zoom/pan
- **Custom viz:** visx (`@visx/shape`, `@visx/scale`, `@visx/axis`) — D3 in React for heatmaps, liquidation maps

### Typography

- **UI text:** Geist Sans (`geist`) — Vercel-designed for dense data UIs
- **Numeric data:** Geist Mono (`geist`) — tabular figures for price alignment
- **Fallback:** Inter → system-ui → sans-serif

```css
--font-sans: "Geist", "Inter", system-ui, -apple-system, sans-serif;
--font-mono: "Geist Mono", "JetBrains Mono", "SF Mono", ui-monospace, monospace;
```

### Color System

- **Color space:** OKLCH (CSS native) — perceptually uniform P&L colors, P3 wide gamut
- **Generation:** culori (`culori`, 3kb) — dynamic palette generation, used by Tailwind v4

```css
--color-stone: oklch(0.42 0.18 280); /* #B38DF4 */
--color-water: oklch(0.78 0.12 195); /* #22D1EE */
--color-profit: oklch(0.72 0.19 142); /* #A6FF4D */
--color-loss: oklch(0.63 0.22 25); /* #FF6B7F */
--color-obsidian: oklch(0.08 0.01 280); /* #08060F */
```

### Gestures

- **Web:** @use-gesture (`@use-gesture/react`) — drag, pinch, scroll. Pairs with Motion
- **React Native:** react-native-gesture-handler v3 (see Animation section)

### Total bundle: ~116kb gzipped (web)

### Stitch Integration Notes

Stitch generates from its own `designTheme`, not this file. When using Stitch MCP tools:

1. Always inject this DESIGN.md via the `designMd` field in `designTheme`
2. Remap MD3 color tokens → Arx tokens (primary→Stone, surface→Chamber, etc.)
3. Remove any gradients from Stitch output
4. Replace pure white (#FFFFFF) with Starlight (#EDE9FE)
5. Add JetBrains Mono / Geist Mono for numeric data — Stitch omits monospace fonts
