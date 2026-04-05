# Arx Design System — Citadel & Moat

<!-- AUTO-GENERATED from specs/Arx_4-2 + specs/Arx_4-3 + build card Visual Specs.
     Do NOT hand-edit. Regenerate with `/design system sync`.
     Sources: Arx_4-2_Design_System.md (v5.7), Arx_4-3_Design_Taste.md, Arx_4-1-1-8 registries.
     Last generated: 2026-04-06 -->

> Agent-friendly design language for Stitch MCP, Figma MCP, AIDesigner, and all AI design tools.
> Human sources of truth: `specs/Arx_4-2_Design_System.md` + `specs/Arx_4-3_Design_Taste.md`

---

## 1. Tokens

### 1.1 Brand Palette: Stone & Water

**Stone Domain (Violet — AI, Structure, Actions)**

| Token | Hex | CSS Variable | Usage |
|-------|-----|-------------|-------|
| Stone | `#B38DF4` | `--color-primary` | Primary actions, Execute Trade, AI indicators |
| Stone Lit | `#9B6FE0` | `--color-primary-hover` | Hover — darker into stone, not lighter |
| Stone Deep | `#7E50C7` | `--color-primary-pressed` | Pressed/active feedback |
| Stone Glow | `#C19DF7` | `--color-stone-glow` | Ambient glow, hover highlights |

**Water Domain (Cyan — Data, Signals, Precision)**

| Token | Hex | CSS Variable | Usage |
|-------|-----|-------------|-------|
| Water | `#22D1EE` | `--color-data` | Prices, data streams, signal indicators |
| Water Deep | `#0891B2` | `--color-data-deep` | Pressed/active data elements |
| Water Glow | `#67E8F9` | `--color-data-glow` | Moat surface shimmer, sparkline peaks |

**Sky Domain (Pink — Social/Community) — Narrow scope**

| Token | Hex | CSS Variable | Usage |
|-------|-----|-------------|-------|
| Sky | `#F472B6` | `--color-sky` | Follower counts, community badges only |

**Rule: NO GRADIENTS.** Stone and Water never blend. Separation is the design principle. The Execute Trade button earns authority through size, elevation, and isolation — not color mixing.

### 1.2 Surfaces (deepest → highest)

| Level | Token | Hex | CSS Variable | Blur | Usage |
|-------|-------|-----|-------------|------|-------|
| Ground | Obsidian | `#08060F` | `--color-bg` | — | Page background |
| Chamber | Surface | `#0E0B1A` | `--color-surface` | 8px | Standard panels, cards |
| Rampart | Elevated | `#151028` | `--color-surface-elevated` | 12px | Active cards, popovers |
| Deep Keep | Modal | `#1C1438` | `--color-surface-modal` | 20px | Modals, drawers, dialogs |

> All surfaces carry violet undertone — never pure black, never navy.

### 1.3 Text

| Token | Hex | CSS Variable | Contrast vs bg | Usage |
|-------|-----|-------------|----------------|-------|
| Starlight | `#EDE9FE` | `--color-text-primary` | ~14:1 AAA | Body copy, labels |
| Stone Mid | `#A09AB8` | `--color-text-secondary` | ~7:1 AAA | Helper text, timestamps |
| Shadow | `#4D4670` | `--color-text-tertiary` | ~3.5:1 AA-lg | Disabled, inactive |

> No pure `#FFFFFF` — Starlight is white refracted through amethyst. Reduces retinal fatigue over 12h sessions.

### 1.4 Borders

| Token | Hex | CSS Variable | Usage |
|-------|-----|-------------|-------|
| Default | `#1E1636` | `--color-border` | Subtle dividers |
| Strong | `#2F2258` | `--color-border-strong` | Prominent dividers |
| Stone Accent | `#B38DF4` | `--color-border-accent` | Focused inputs, active nav |
| Water Accent | `#22D1EE` | `--color-border-data` | Data-focused inputs, charts |

### 1.5 Semantic Colors (fixed)

| Token | Hex | CSS Variable | Purpose |
|-------|-----|-------------|---------|
| Positive | `#A6FF4D` | `--color-positive` | Gains, bullish, up trends |
| Negative | `#FF6B7F` | `--color-negative` | Losses, bearish, alerts |
| Warning | `#FFB847` | `--color-warning` | Caution, pending |
| Info | `#4DB8FF` | `--color-info` | Informational, neutral |

### 1.6 Regime Colors (6 market states — immutable)

| State | Hex | CSS Variable | Meaning |
|-------|-----|-------------|---------|
| Trending Up | `#10B981` | `--color-regime-up` | Strong uptrend |
| Trending Down | `#EF4444` | `--color-regime-down` | Strong downtrend |
| Range-bound | `#3B82F6` | `--color-regime-range` | Consolidation |
| Transition | `#F59E0B` | `--color-regime-transition` | Regime shift in progress |
| Compression | `#0D9488` | `--color-regime-compression` | Breakout pending |
| Crisis | `#EA580C` | `--color-regime-crisis` | Black swan event |

> RegimePill uses regime color, NOT `--color-primary`. Background: regime color at 15% opacity. Text: regime color at 100%.

### 1.7 Color Temperature System

| Zone | Name | Budget | Allowed |
|------|------|--------|---------|
| T0 | Ice | 80% | Surfaces, text, borders — the structural 80% of every screen |
| T1 | Cool | 15% | Regime at 40% opacity (border-left only), secondary text, sparkline fills at 10% |
| T2 | Warm | 4% | Positive/Negative on NUMBERS only, signal scores, safety gauges |
| T3 | Hot | 1% | Execute Trade button (solid Stone), liquidation warnings |

**Rules:** One hero per scroll frame (T2). Max 2 hot elements visible (T3). Color on data, not containers. Tints whisper, never shout.

### 1.8 Typography

| Level | Size | Weight | Family | Spacing | Use |
|-------|------|--------|--------|---------|-----|
| Hero | 28-32px | 700 | Mono | -0.03em | Portfolio equity, headline numbers |
| Hero-sm | 24px | 700 | Mono | -0.02em | Card headline values |
| Title | 16px | 700 | Sans | -0.01em | Card titles, section headers |
| Subtitle | 14px | 600 | Sans | 0 | Card subtitles, data labels |
| Body | 14px | 400 | Sans | 0 | Descriptions, detail text |
| Body-sm | 13px | 400 | Sans | 0 | Secondary descriptions |
| Label | 12px | 500 | Sans | 0.01em | Timestamps, metadata |
| Caption | 11px | 600 | Sans | 0.06em | Badges, overlines |
| Data | 14px | 600 | Mono | 0 | Prices, percentages, counts |
| Data-sm | 12-13px | 500 | Mono | 0 | Secondary data values |

**Fonts:**

```css
--font-sans: "Geist", "Inter", system-ui, -apple-system, sans-serif;
--font-mono: "Geist Mono", "JetBrains Mono", "SF Mono", ui-monospace, monospace;
```

### 1.9 Spacing

8px base grid. All spacing is multiples of 4px or 8px.

| Token | Value | CSS Variable | Usage |
|-------|-------|-------------|-------|
| 2xs | 4px | `--space-2xs` | Tight gaps, badge padding |
| xs | 8px | `--space-xs` | Inner element spacing |
| sm | 12px | `--space-sm` | Card gap, between cards in group |
| md | 16px | `--space-md` | Content padding, screen edge |
| lg | 24px | `--space-lg` | Between card groups |
| xl | 32px | `--space-xl` | Major section separation |
| 2xl | 48px | `--space-2xl` | Between sections (+ visual separator) |

**Mobile viewport:** 390x844 (iPhone 14 Pro), viewport-fit=cover.
**Safe areas:** `env(safe-area-inset-*)` for status bar and home indicator.
**Touch targets:** 44px minimum.

### 1.10 Glass

| Property | Value |
|----------|-------|
| Background | `rgba(91, 33, 182, 0.08)` — stone-tinted, not navy |
| Backdrop blur | `blur(20px)` — thick stone glass |
| Border | `1px solid #1E1636` |
| Outer radius | 16px |
| Inner radius | 12px |
| Shadow | None on cards — depth from surface color only |

### 1.11 Shadows

| Token | Value | CSS Variable | Usage |
|-------|-------|-------------|-------|
| Execute | `0 0 40px rgba(179,141,244,0.35), 0 0 20px rgba(179,141,244,0.15)` | `--shadow-execute` | Execute Trade button only |
| Elevated | `0 2px 8px rgba(0,0,0,0.3)` | `--shadow-elevated` | Floating elements |
| None | — | — | Cards — depth via surface color |

---

## 2. Components

### 2.1 Buttons

| Type | Background | Text | Min Height | Min Width | Radius | Shadow |
|------|-----------|------|-----------|-----------|--------|--------|
| Primary (Execute Trade) | Solid `#B38DF4` | White | 48px | 160px | 12px | `--shadow-execute` |
| Secondary | Transparent | Stone | 44px | — | 12px | None |
| Data/Info | Transparent | Water | 44px | — | 12px | None |

No gradients on any button — ever.

### 2.2 Badges & Chips

- Border-radius: `999px` (fully rounded)
- Padding: `4px 10px`
- Font: Caption (11px, 600 weight)
- Background: color at 15% opacity, text in full color

**Filter chips:** Selected = `--color-primary` bg, primary text. Default = `--color-surface-elevated` bg, secondary text.

### 2.3 Tab Bar

- Bottom tab bar, 5 items, 60px height + safe-area-inset-bottom
- Active: Stone Violet icon + label
- Inactive: Shadow (`#4D4670`) icon + label
- Background: Chamber (`#0E0B1A`) with top border
- Trade button: Elevated 48px circle, bg `--color-primary`, shadow `--shadow-execute`

### 2.4 Regime Bar

- Full-width strip at top of screen
- 4px height, color = current regime state
- Animates on regime transitions (300ms ease)

### 2.5 Glass Cards

Standard information containers throughout the app.

- Background: Glass (§1.10)
- Active/press: `scale(0.985)`, 200ms ease
- Content padding: 16px
- Between cards: 12px gap

### 2.6 Status Dots

- 10px circle, color by state (gain/warning/loss)
- Pulsing glow: shadow 8px→14px→8px, 2s ease-in-out infinite

### 2.7 Progress Bars

- 6px height, border-radius 3px
- Track: `--color-border` (`#1E1636`)
- Fill: accent color (varies by context)

### 2.8 Wallet Badges

| Badge | Color | Hex | Interpretation |
|-------|-------|-----|---------------|
| All-Weather | Emerald | `#10B981` | Proven stability |
| Specialist | Blue | `#3B82F6` | Strong niche |
| Cooling Down | Amber | `#F59E0B` | Volatility rising |
| Unproven | Gray | `#6B7280` | Insufficient data |
| Unverified | Gray Outline | `#6B7280` | Unconfirmed source |
| Non-Copyable | Red Outline | `#FF6B7F` | Cannot be copied |

---

## 3. Icon Registry

Primary library: **Lucide** (`lucide-react`). Finance supplement: **Tabler Icons** (`@tabler/icons-react`).

### 3.1 Tab Bar Icons

| Tab | Icon | Active Color | Inactive Color |
|-----|------|-------------|----------------|
| Home | `lucide:home` | `--color-primary` | `--color-text-tertiary` |
| Traders | `lucide:users` | `--color-primary` | `--color-text-tertiary` |
| Trade | `lucide:arrow-up-down` | `#FFFFFF` (on elevated circle) | `--color-text-tertiary` |
| Markets | `lucide:bar-chart-3` | `--color-primary` | `--color-text-tertiary` |
| You | `lucide:user` | `--color-primary` | `--color-text-tertiary` |

### 3.2 Feed Card Icons (C1-R0)

Each card type has a 40px icon circle with tinted background.

| Card Type | Icon | Circle BG | Icon Color |
|-----------|------|-----------|------------|
| Regime Shift | `lucide:trending-up` | `rgba(34,209,238,0.12)` | `--color-data` |
| Leader Consensus | `lucide:users` | `rgba(179,141,244,0.12)` | `--color-primary` |
| Smart Money Signal | `lucide:eye` | `rgba(34,209,238,0.12)` | `--color-data` |
| Divergence Alert | `lucide:git-branch` | `rgba(255,184,71,0.12)` | `--color-warning` |
| Trader Move | `lucide:arrow-right-left` | `rgba(179,141,244,0.12)` | `--color-primary` |
| Daily Earnings | `lucide:dollar-sign` | `rgba(166,255,77,0.12)` | `--color-positive` |
| Recovery | `lucide:shield-alert` | `rgba(255,107,127,0.12)` | `--color-negative` |
| Weekly Rollup | `lucide:calendar` | `rgba(179,141,244,0.12)` | `--color-primary` |
| WYWA | `lucide:check-circle` | `rgba(16,185,129,0.12)` | `#10B981` |
| Watch Nudge | `lucide:bell` | `rgba(179,141,244,0.12)` | `--color-primary` |

### 3.3 Common Component Icons

| Component | Icon | Notes |
|-----------|------|-------|
| StatusDot | (no icon — 10px circle) | Color: gain/warning/loss by risk state |
| RegimePill | (no icon — text + dot) | Color: regime state, NOT brand primary |
| FilterChip (selected) | none | bg: `--color-primary`, text: primary |
| FilterChip (default) | none | bg: elevated surface, text: secondary |
| FeedModeToggle | none | Segmented control, selected bg `rgba(179,141,244,0.2)` |

### 3.4 Icon Sizing

| Size | Grid | Usage |
|------|------|-------|
| XS | 16px | Badges, micro-labels |
| S | 20px | Form inputs, secondary UI |
| M | 24px | Primary UI, navigation, buttons |
| L | 32px | Large CTAs, hero sections |
| XL | 48px | Dashboard highlights, empty states |

Stroke: 1.5px default, 2px bold (active), 1px light (disabled).

### 3.5 Custom SVGs (not in Lucide)

Copy trading indicator, risk gauge, signal strength meter, regime state icons.

---

## 4. Embellishment Registry

### 4.1 Card Embellishments

| Card Type | Accent Border | Icon Circle | Glass |
|-----------|--------------|-------------|-------|
| WYWA | left 3px `#10B981` | Yes (green) | Yes |
| Regime Shift | none | Yes (cyan) | Yes |
| Leader Consensus | none | Yes (violet) | Yes |
| Smart Money Signal | none | Yes (cyan) | Yes |
| Daily Earnings | top 3px `--color-positive` | Yes (lime) | Yes |
| Recovery | left 3px `--color-negative` | Yes (red) | Yes |
| Divergence Alert | left 3px `--color-warning` | Yes (amber) | Yes |
| Trader Move | none | Yes (violet) | Yes |

### 4.2 Screen-Level Embellishments

| Element | Treatment |
|---------|-----------|
| Feed section divider | Caption, `--color-text-secondary`, letter-spacing 0.1em, 1px line extending right |
| Regime bar | 4px tall, full width, regime state color, top of viewport |
| Status dot pulse | Shadow 8px→14px→8px, 2s ease-in-out infinite |
| Progress bars | 6px height, radius 3px, bg `--color-border`, fill in accent color |

### 4.3 Embellishment Rules

- **Accent borders:** 3px max width. Left or top only. Single color — never gradient.
- **Icon circles:** 40px diameter. Background: color at 12% opacity. Icon: color at 100%.
- **Tints:** Maximum 15% opacity on any background tint. Never solid color fills on cards.
- **Glows:** Stone glow only on regime shifts and AI alerts. Water ripple only on live data updates. Never decorative.

---

## 5. Interaction Defaults

Unless overridden in a build card's `## Visual Spec`:

### 5.1 Touch Gestures

| Element | Gesture | Action |
|---------|---------|--------|
| Glass card | tap | Navigate to detail |
| Glass card | active (press) | `scale(0.985)`, 200ms ease |
| Filter chip | tap | Toggle filter, haptic light |
| Feed mode toggle | tap | Switch mode, 250ms transition |
| Feed | pull-down | Refresh: haptic medium + spinner + reload |
| Feed | scroll | Momentum, sticky header stays fixed |
| WYWA dismiss | tap "Dismiss" | Fade out 200ms, don't reappear until next 8h+ absence |
| Tab bar item | tap | Switch tab, no animation |
| Tab bar Trade | tap | Open trade hub, spring 350ms |

### 5.2 Animation Durations

| Token | Duration | CSS Variable | Usage |
|-------|---------|-------------|-------|
| Fast | 100ms | `--duration-fast` | Hover, focus feedback |
| Standard | 200ms | `--duration-standard` | Button presses, transitions |
| Slow | 300ms | `--duration-slow` | Page transitions, regime shifts |
| Glacial | 500ms | `--duration-glacial` | Complex multi-step sequences |

### 5.3 Easing Curves

| Curve | Value | CSS Variable | Usage |
|-------|-------|-------------|-------|
| Ease Out | `cubic-bezier(0, 0, 0.58, 1)` | `--easing-out` | Default — natural deceleration |
| Spring | `cubic-bezier(0.34, 1.56, 0.64, 1)` | `--easing-spring` | Entrance animations |
| iOS Sheet | `cubic-bezier(0.32, 0.72, 0, 1)` | — | Bottom sheets, modals (350ms) |

### 5.4 Keyframe Animations

**Stone Glow** (AI alert / regime shift only):
```css
@keyframes stoneGlow {
  0%, 100% { box-shadow: 0 0 0 0 rgba(179, 141, 244, 0.7); }
  50% { box-shadow: 0 0 0 8px rgba(179, 141, 244, 0); }
}
/* 2s ease-in-out infinite */
```

**Water Ripple** (live data update / signal):
```css
@keyframes waterRipple {
  0%, 100% { box-shadow: 0 0 0 0 rgba(34, 209, 238, 0.5); }
  50% { box-shadow: 0 0 0 6px rgba(34, 209, 238, 0); }
}
/* 1.5s ease-in-out infinite */
```

### 5.5 Scroll Behavior

- Momentum-based (`-webkit-overflow-scrolling: touch`)
- Sticky headers on feed scrolls
- Never more than 4 same-height cards in sequence — break rhythm with section headers or breathing space
- Every 5th viewport-height of scroll needs a visual anchor
- End-of-list: "You're caught up" message or fade — never abrupt cutoff

---

## 6. Taste Rules

> Full framework: `specs/Arx_4-3_Design_Taste.md`. This is the agent-executable summary.

### 6.1 Reference Floor (BEAT these — they are minimum, not ceiling)

**S7 (Followers, 95%):** Robinhood, eToro, Bitget, Phantom
**S2 (Leaders, 5%):** Moomoo, Webull, Binance

AI+human co-creation means Arx ships taste no traditional team can match. Not "good enough for a startup" — best-in-class, period.

### 6.2 Five Premium Litmus Tests

Run on EVERY screen before ship. Any fail = screen not ready.

| # | Test | Pass | Fail |
|---|------|------|------|
| 1 | **$10M Test** | Looks built by a design-obsessed team | Looks like a hackathon project |
| 2 | **Screenshot Test** | S7 user would screenshot to show a friend | Functional but not share-worthy |
| 3 | **Ive's Care Test** | Every pixel intentional, nothing filling space | Template artifacts remain |
| 4 | **Empty State Test** | Skeleton still looks premium without data | Grey boxes with placeholder text |
| 5 | **3-Second Test** | Hierarchy clear in 3 seconds without reading | Must read labels to understand |

### 6.3 Anti-Slop Checklist

| Anti-Pattern | Do Instead |
|-------------|-----------|
| Generic card grids (same height/width) | Vary heights by content importance |
| Purple gradients | Solid Stone OR Water — never both |
| Glassmorphism for decoration | Glass only for overlays, sheets, modals |
| "This feature allows you to..." copy | Second person, present tense: "Your traders moved" |
| Stock photography | Data visualization, iconography, geometric patterns |
| Competing CTAs | One primary (Stone), rest are ghost/text buttons |
| Loading spinners without context | Skeleton screens shaped like content + contextual label |
| Empty states with just "No data" | Designed screen: illustration + explanation + CTA |
| Modal-heavy flows | Bottom sheets for selection, full-screen for forms |

### 6.4 Material Honesty

- **Stone:** solid, opaque, heavy. Doesn't glow on its own. Shifts, locks, settles.
- **Water:** transparent, flowing, precise. Carries data. Can shimmer, doesn't hold structure.
- **Glass:** translucent, layered. Overlays only — bottom sheets, modals, status bar. Always blurs.

### 6.5 Density Rules

- **S7 default:** Cards, headlines, one CTA. Progressive disclosure. Max 4-6 items before "See all."
- **S2 mode:** Tables, data, everything visible. Power-user affordances. Unlimited with virtualized scroll.
- **Shared screens:** Default to S7. S2 complexity behind taps, toggles, or dedicated screens.

### 6.6 Optical Weight

- HEAVIEST element = the one thing the user came here for. Identifiable WITHOUT reading.
- If two elements compete for weight, one must yield. No draws.
- Weight order: size > color saturation > elevation > position > animation.
- Execute Trade button is ALWAYS the heaviest element on any screen where it appears.

### 6.7 Negative Space

- Negative space is DESIGNED, not leftover. If you can't explain why space exists, layout isn't finished.
- Between cards in group: 12px. Between groups: 24px+. Between sections: 48px + separator.
- Screen edge: 16px — never 0, never 8px.

---

## 7. Production Stack

### CSS & Styling

- **Web:** Tailwind CSS v4 — Rust engine, CSS-variable theming, mobile-first
- **React Native:** NativeWind v4/v5 — same Tailwind classes as web
- **Supplement:** Open Props (4.4kb) — animation easings, spacing scales

### Animation

- **Web:** Motion (3.8kb) — Web Animations API, off main thread
- **Web (free):** View Transitions API, CSS scroll-driven animations (native)
- **React Native:** react-native-reanimated v4 (120fps, UI thread) + gesture-handler v3

### Icons

- **Primary:** Lucide (`lucide-react`) — 1,500+ icons, ~200b each, tree-shakeable
- **Finance:** Tabler Icons (`@tabler/icons-react`) — `chart-candle`, `currency-bitcoin`, `chart-dots`
- **Custom SVG:** Copy trading, risk gauge, signal strength, regime icons

### Components

- **Web:** Shadcn UI (own the code) + vaul (drawer) + sonner (toasts) + cmdk (palette) + input-otp
- **React Native:** React Native Reusables + @rn-primitives (Radix for RN) + NativeWind
- **Fallback (RN):** Gluestack UI v4

### Charts

- **Primary:** TradingView Lightweight Charts v5 (35kb) — candlestick, volume, multi-pane, touch zoom
- **Custom viz:** visx (`@visx/shape`, `@visx/scale`, `@visx/axis`) — heatmaps, liquidation maps

### Color System

- **Color space:** OKLCH (CSS native) — perceptually uniform, P3 wide gamut
- **Generation:** culori (3kb) — dynamic palette generation

```css
--color-stone: oklch(0.42 0.18 280);   /* #B38DF4 */
--color-water: oklch(0.78 0.12 195);   /* #22D1EE */
--color-profit: oklch(0.72 0.19 142);  /* #A6FF4D */
--color-loss: oklch(0.63 0.22 25);     /* #FF6B7F */
--color-obsidian: oklch(0.08 0.01 280); /* #08060F */
```

### Gestures

- **Web:** @use-gesture (`@use-gesture/react`) — drag, pinch, scroll
- **React Native:** react-native-gesture-handler v3

### Total bundle: ~116kb gzipped (web)

---

## What NOT to Do

- NO gradients anywhere — Stone and Water never blend
- NO pure white (`#FFFFFF`) — use Starlight (`#EDE9FE`)
- NO pure black (`#000000`) — use Obsidian (`#08060F`)
- NO navy/blue backgrounds — all surfaces carry violet undertone
- NO decorative elements — every pixel serves function
- NO mixing Stone and Water on the same element
- NO animations beyond regime shifts and state transitions
- NO color on containers — color goes on DATA (numbers, text), not backgrounds
- NO more than 2 hot (T3) elements visible in any viewport
- NO same-height card grids — vary heights by content importance

---

## Stitch / AI Tool Integration Notes

When using Stitch MCP, Figma MCP, or AIDesigner:

1. Inject this DESIGN.md via `designMd` field
2. Remap MD3 tokens → Arx tokens (primary→Stone, surface→Chamber)
3. Remove any gradients from output
4. Replace pure white with Starlight (`#EDE9FE`)
5. Add Geist Mono / JetBrains Mono for numeric data
6. Run 5 Litmus Tests (§6.2) on every generated screen
7. Check Color Temperature (§1.7) — 80% Ice, max 2 Hot elements
