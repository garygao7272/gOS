---
name: arx-ui-stack
description: Reference card for all Arx UI building blocks — packages, versions, CDNs, usage patterns for web and React Native
---

# Arx UI Stack — Quick Reference

Use this skill when implementing UI features, evaluating dependencies, or onboarding to the Arx tech stack. Canonical source: `DESIGN.md` (Production UI Stack section).

## The Stack at a Glance (~116kb gzipped total)

| Category        | Web                                                      | React Native                         | Bundle        |
| --------------- | -------------------------------------------------------- | ------------------------------------ | ------------- |
| **CSS/Styling** | Tailwind CSS v4 (`tailwindcss`)                          | NativeWind v4/v5 (`nativewind`)      | ~5kb          |
| **Animation**   | Motion (`motion`)                                        | react-native-reanimated v4           | ~3.8kb (web)  |
| **Icons**       | Lucide (`lucide-react`) + Tabler (`@tabler/icons-react`) | Same (lucide-react-native)           | ~4kb/20 icons |
| **Components**  | Shadcn UI (`shadcn` CLI)                                 | React Native Reusables (copy-paste)  | ~15kb/10 comp |
| **Charts**      | Lightweight Charts v5 (`lightweight-charts`)             | Same (via WebView) or Victory Native | ~35kb         |
| **Fonts**       | Geist Sans + Mono (`geist`)                              | Same (via expo-font)                 | ~40kb         |
| **Gestures**    | @use-gesture (`@use-gesture/react`)                      | react-native-gesture-handler v3      | ~10kb         |
| **Colors**      | OKLCH (CSS native) + culori (`culori`)                   | Same (via nativewind)                | ~3kb          |

## Web-Specific Packages

### Core

```
tailwindcss          # CSS framework (Rust engine, v4)
open-props           # Supplemental design tokens (easings, spacing)
motion               # Animation (3.8kb core, WAAPI)
```

### Components

```
shadcn               # CLI to add components (own the code)
vaul                 # Mobile drawer (replaces Dialog on mobile)
sonner               # Toast notifications
cmdk                 # Command palette
input-otp            # OTP input for 2FA
@react-aria/interactions  # Fallback if Radix stalls
```

### Data Visualization

```
lightweight-charts   # TradingView candlestick/volume/multi-pane (35kb)
@visx/shape          # Custom viz (heatmaps, donuts)
@visx/scale          # D3 scales in React
@visx/axis           # Chart axes
```

### Icons

```
lucide-react         # Primary icon set (1,500+, tree-shakeable)
@tabler/icons-react  # Finance supplement (chart-candle, currency-bitcoin)
```

### Typography

```
geist                # Geist Sans + Geist Mono (variable font)
@fontsource/inter    # Inter fallback
```

### Utilities

```
@use-gesture/react   # Touch gestures (drag, pinch, scroll)
culori               # Color manipulation (OKLCH conversions)
remotion             # Video generation from Stitch screens
```

## React Native-Specific Packages

### Core

```
nativewind           # Tailwind CSS for React Native (same classes as web)
react-native-reanimated   # 120fps animations, UI thread (non-negotiable)
react-native-gesture-handler  # Native gestures (non-negotiable)
moti                 # Declarative animations on reanimated (optional)
```

### Components (React Native Reusables stack)

```
react-native-reusables  # Copy-paste components (shadcn for RN, 8k stars)
@rn-primitives       # Radix for RN (accessible headless primitives)
@gluestack-ui/themed # Fallback component library (NativeWind-based)
```

### Data

```
lightweight-charts   # Via react-native-webview wrapper
# OR
victory-native       # Native chart rendering alternative
@shopify/flash-list  # Virtualized lists for order books/trade history
```

## Font Stack

```css
--font-sans: "Geist", "Inter", system-ui, -apple-system, sans-serif;
--font-mono: "Geist Mono", "JetBrains Mono", "SF Mono", ui-monospace, monospace;
```

**Rules:**

- All price data, P&L, quantities → `--font-mono` with `font-variant-numeric: tabular-nums`
- All UI labels, navigation, body text → `--font-sans`
- Display/headings → `--font-sans` weight 700, letter-spacing -0.02em

## Color System (OKLCH)

```css
--color-stone: oklch(0.42 0.18 280); /* #5B21B6 — primary actions */
--color-water: oklch(0.78 0.12 195); /* #22D1EE — data, signals */
--color-profit: oklch(0.72 0.19 142); /* #A6FF4D — gains */
--color-loss: oklch(0.63 0.22 25); /* #FF6B7F — losses */
--color-obsidian: oklch(0.08 0.01 280); /* #050609 — page background */
--color-chamber: oklch(0.12 0.02 280); /* #0A0918 — card background */
--color-starlight: oklch(0.93 0.02 280); /* #EEE9FF — primary text */
```

**Why OKLCH:** Perceptually uniform — profit green and loss red at the same lightness actually look equally bright. P3 wide gamut gives 30% richer colors on all modern iPhones.

## AI Tool Compatibility

All three major AI design tools output code compatible with this stack:

| Tool                | CSS            | Components | Icons              |
| ------------------- | -------------- | ---------- | ------------------ |
| **v0 (Vercel)**     | Tailwind       | Shadcn UI  | Lucide             |
| **Bolt.new**        | Tailwind       | Shadcn UI  | Lucide             |
| **Stitch (Google)** | Tailwind (CDN) | Raw HTML   | Material Symbols\* |

\*Stitch outputs Material Symbols; remap to Lucide when importing.

## Stitch-to-Arx Conversion

When importing Stitch-generated HTML:

1. Replace Tailwind CDN with production Tailwind v4
2. Remap MD3 color tokens → Arx tokens (see `stitch-design` skill)
3. Remove gradients (Arx forbids them)
4. Replace pure white → Starlight (#EEE9FF)
5. Add Geist Mono for numeric data
6. Add safe-area-inset handling
7. Replace Material Symbols → Lucide icons
8. Ensure 44px minimum touch targets

## Trading-Specific Patterns

### Price Display

```jsx
<span className="font-mono tabular-nums text-water">$42,069.42</span>
```

### P&L with Color

```jsx
<span
  className={cn(
    "font-mono tabular-nums",
    pnl >= 0 ? "text-profit" : "text-loss",
  )}
>
  {pnl >= 0 ? "+" : ""}
  {pnl.toFixed(2)}%
</span>
```

### Glass Card

```jsx
<div className="bg-stone/8 backdrop-blur-[20px] border border-border rounded-2xl p-4">
  {children}
</div>
```

### Regime Bar

```jsx
<div className={cn("h-1 w-full transition-colors duration-300", regimeColor)} />
```
