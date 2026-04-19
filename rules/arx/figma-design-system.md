# Figma Design System Rules — Arx

> Rules for Figma MCP when generating or modifying designs in the Arx Design System file.

## Design System Structure

### Token Source
All design tokens are defined in `DESIGN.md` (auto-generated from `specs/Arx_4-2_Design_System.md`). The Figma file at `pG8iP5irNjYfGbkce31d9V` contains these as Figma Variable Collections.

### Variable Collections

| Collection | Type | Mode | Variables |
|-----------|------|------|-----------|
| Arx Colors | COLOR | Dark | 29 variables (Stone, Water, Sky, Surface, Text, Border, Semantic, Regime) |
| Arx Spacing | FLOAT | Default | 7 variables (2xs=4, xs=8, sm=12, md=16, lg=24, xl=32, 2xl=48) |
| Arx Radii | FLOAT | Default | 4 variables (sm=8, md=12, lg=16, pill=999) |

### Color Domains (NEVER MIX)

- **Stone (Violet)** — AI, structure, actions, CTAs. Primary: `#B38DF4`
- **Water (Cyan)** — Data, signals, prices. Primary: `#22D1EE`
- **Sky (Pink)** — Social/community only. `#F472B6`

**Rule: NO GRADIENTS.** Stone and Water never blend on the same element.

## Component Architecture

### Components (in Figma file)

| Component | Variants | Key Properties |
|-----------|---------|---------------|
| Button | Type=Primary, Secondary, Data | Primary is solid Stone, 48px height, 160px width. No gradients. |
| Filter Chip | State=Selected, Default | Pill shape (999 radius), 28px height |
| Glass Card | — | 16px radius, stone-tinted glass bg, blur 20px, border Default |
| Regime Bar | — | 4px height, fill width, regime color |
| Status Dot | — | 10px ellipse, Positive color default |
| Icon Circle | — | 40px, 20px radius, tinted bg at 12% opacity |
| Tab Bar | — | 5 tabs, 60px height, elevated Trade circle button |

### When Creating New Components

1. Always bind fills/strokes to Arx Colors variables — never hardcode hex values
2. Always bind spacing to Arx Spacing variables
3. Always bind corner radii to Arx Radii variables
4. Use auto-layout on all containers (layoutMode VERTICAL or HORIZONTAL)

## Styling Rules

### Typography
- UI text: Inter (Semi Bold for headings, Medium for labels, Regular for body)
- Numeric data: JetBrains Mono (if available) or Inter with tabular-nums
- Minimum text size: 11px (Caption level)
- All numeric data must use `font-variant-numeric: tabular-nums`

### Color Temperature
- **T0 Ice (80%):** Surface backgrounds, text, borders — the structural majority
- **T1 Cool (15%):** Regime indicators at 40% opacity, secondary text, sparklines
- **T2 Warm (4%):** Positive/Negative on NUMBERS only, signal scores
- **T3 Hot (1%):** Execute Trade button, liquidation warnings

### Surfaces (darkest → lightest)
- Obsidian `#08060F` — page background
- Chamber `#0E0B1A` — cards, panels
- Rampart `#151028` — active cards, popovers
- Deep Keep `#1C1438` — modals, drawers

### What NOT to Do
- NO pure white `#FFFFFF` — use Starlight `#EDE9FE`
- NO pure black `#000000` — use Obsidian `#08060F`
- NO navy/blue backgrounds — all surfaces carry violet undertone
- NO gradients — anywhere
- NO decorative elements — every pixel serves function
- NO mixing Stone and Water on the same element

## Icon System
- Primary library: Lucide (1,500+ icons, 24px default grid)
- Finance supplement: Tabler Icons
- Sizes: 16px (XS), 20px (S), 24px (M), 32px (L), 48px (XL)
- Stroke: 1.5px default, 2px bold, 1px light
- Color: inherits from parent or bound to color variable

## Responsive
- Primary viewport: 390x844 (iPhone 14 Pro)
- Touch targets: 44px minimum
- Content padding: 16px horizontal
- Card gap: 12px between cards in a group
- Section gap: 24px between groups

## Feel Tokens
Screens reference feel tokens (see DESIGN.md DESIGN tokens section): `feel:home`, `feel:trade`, `feel:discovery`, etc. Each defines target feel, motion choreography, density mode, and color temperature budget.
