# Mock Data Fixtures & Visual Registry

**Artifact ID:** Arx_4-1-1-8
**Title:** Canonical Mock Data, Icon Registry, and Embellishment Registry
**Last Updated:** 2026-04-05
**Status:** Active
**Dependencies:** `Arx_4-2_Design_System.md` (tokens), `Arx_4-1-1-0` (master architecture)

<!-- AGENT: This spec provides canonical test fixtures for all screens.
     When generating a design from a build card, load the fixture matching
     the screen ID. Use exact values, display formats, type levels, and
     color tokens. Do NOT invent or modify values.
     Key files: Every specs/Arx_4-1-1-X build card references this file.
-->

> **Purpose:** Eliminate design tool divergence. Every tool reading a build card MUST produce identical data values, icons, and visual treatments. This file is the single source of truth for "what the screen looks like with test data."

---

## 1. Type Scale Reference (from Arx_4-2 §3)

Build cards reference these names instead of raw pixel values:

| Level | Size | Weight | Family | Letter-spacing | Use |
|-------|------|--------|--------|----------------|-----|
| Hero | 28-32px | 700 | Mono | -0.03em | Portfolio equity, headline numbers |
| Hero-sm | 24px | 700 | Mono | -0.02em | Card headline values (+$487) |
| Title | 16px | 700 | Sans | -0.01em | Card titles, section headers |
| Subtitle | 14px | 600 | Sans | 0 | Card subtitles, data labels |
| Body | 14px | 400 | Sans | 0 | Descriptions, detail text |
| Body-sm | 13px | 400 | Sans | 0 | Secondary descriptions |
| Label | 12px | 500 | Sans | 0.01em | Timestamps, metadata |
| Caption | 11px | 600 | Sans | 0.06em | Badges, section headers, overlines |
| Data | 14px | 600 | Mono | 0 | Prices, percentages, counts |
| Data-sm | 12-13px | 500 | Mono | 0 | Secondary data, small values |

---

## 2. Icon Registry

### 2.1 Tab Bar Icons

| Tab | Icon | Active Color | Inactive Color |
|-----|------|-------------|----------------|
| Home | `lucide:home` | --color-primary (#B38DF4) | --color-text-tertiary (#4D4670) |
| Traders | `lucide:users` | --color-primary | --color-text-tertiary |
| Trade | `lucide:arrow-up-down` | #FFFFFF (on elevated circle) | --color-text-tertiary |
| Markets | `lucide:bar-chart-3` | --color-primary | --color-text-tertiary |
| You | `lucide:user` | --color-primary | --color-text-tertiary |

**Trade button:** Elevated circle (48px, bg --color-primary, shadow 0 0 40px rgba(179,141,244,0.35)). Text "TRADE" in white, Caption weight.

### 2.2 Feed Card Icons (C1-R0)

Each card type has a 40px icon circle with a tinted background.

| Card Type | Icon | Circle BG | Icon Color |
|-----------|------|-----------|------------|
| Regime Shift (#1) | `lucide:trending-up` | rgba(34,209,238,0.12) | --color-data (#22D1EE) |
| Leader Consensus (#3) | `lucide:users` | rgba(179,141,244,0.12) | --color-primary (#B38DF4) |
| Smart Money Signal (#5) | `lucide:eye` | rgba(34,209,238,0.12) | --color-data (#22D1EE) |
| Divergence Alert (#7) | `lucide:git-branch` | rgba(255,184,71,0.12) | --color-warning (#FFB847) |
| Trader Move (#8a) | `lucide:arrow-right-left` | rgba(179,141,244,0.12) | --color-primary (#B38DF4) |
| Daily Earnings (#9) | `lucide:dollar-sign` | rgba(166,255,77,0.12) | --color-gain (#A6FF4D) |
| Recovery (#10) | `lucide:shield-alert` | rgba(255,107,127,0.12) | --color-loss (#FF6B7F) |
| Weekly Rollup (#12) | `lucide:calendar` | rgba(179,141,244,0.12) | --color-primary (#B38DF4) |
| WYWA | `lucide:check-circle` | rgba(16,185,129,0.12) | #10B981 |
| Watch Nudge | `lucide:bell` | rgba(179,141,244,0.12) | --color-primary (#B38DF4) |

### 2.3 Common Component Icons

| Component | Icon | Notes |
|-----------|------|-------|
| StatusDot | (no icon — 10px circle) | Color: gain/warning/loss by risk state |
| RegimePill | (no icon — text + dot) | Color: regime state color, NOT brand primary |
| FilterChip (selected) | none | bg: --color-primary, text: --color-text-primary |
| FilterChip (default) | none | bg: --color-surface-elevated, text: --color-text-secondary |
| PortfolioStickyHeader | none | Glass Level 2 |
| FeedModeToggle | none | Segmented control, selected bg rgba(179,141,244,0.2) |

---

## 3. Embellishment Registry

### 3.1 Card Embellishments

| Card Type | Accent Border | Icon Circle | Section Header | Glass |
|-----------|--------------|-------------|----------------|-------|
| WYWA | left 3px #10B981 | Yes (green) | none | Yes |
| Regime Shift | none | Yes (cyan) | none | Yes |
| Leader Consensus | none | Yes (violet) | none | Yes |
| Smart Money Signal | none | Yes (cyan) | none | Yes |
| Daily Earnings | top 3px --color-gain | Yes (lime) | none | Yes |
| Recovery | left 3px --color-loss | Yes (red) | none | Yes |
| Divergence Alert | left 3px --color-warning | Yes (amber) | none | Yes |
| Trader Move | none | Yes (violet) | none | Yes |

### 3.2 Screen-Level Embellishments

| Element | Treatment |
|---------|-----------|
| Feed section divider | "TODAY'S INTELLIGENCE" — Caption, --color-text-secondary, letter-spacing 0.1em, with 1px line extending right |
| Regime bar | 4px tall, full width, regime state color, top of viewport |
| Status dot | Pulsing glow animation: 0→50%→100% shadow 8px→14px→8px, 2s ease-in-out infinite |
| Progress bars | 6px height, border-radius 3px, bg --color-border (#1E1636), fill in accent color |

---

## 4. Screen Fixtures

### 4.1 Fixture: C1-R0 (Home + Feed)

| Field | Raw Value | Display Format | Type Level | Color Token |
|-------|-----------|---------------|------------|-------------|
| equity | 12450.00 | "$12,450.00" | Hero mono | --color-text-primary |
| daily_pnl | 487.00 | "+$487.00" | Data | --color-gain |
| daily_pnl_pct | 2.3 | "(+2.3%)" | Data | --color-gain |
| status | safe | green dot 10px | — | --color-gain |
| regime_state | trending_up | "● Trending" pill | Body-sm | #10B981 (regime color) |
| regime_pill_bg | — | rgba(16,185,129,0.15) | — | — |
| positions_open | 3 | "3 open" | Body | --color-text-secondary |
| portfolio_label | — | "PORTFOLIO" | Caption | --color-text-secondary |
| absence_hours | 8 | "8h" | Label | --color-text-secondary |
| wywa_safety | all_safe | "All safe" | Subtitle | --color-gain |
| wywa_earned | 847.00 | "+$847" | Data | --color-gain |
| wywa_leaders | 4 | "across 4 leaders" | Body | --color-text-primary |
| regime_from | ranging | "Ranging" | Title | --color-text-primary |
| regime_to | trending | "Trending" | Title | --color-data |
| regime_confidence | 87 | "87%" | Data | --color-data |
| regime_duration_min | 134 | "2h 14m" | Data | --color-text-primary |
| regime_timestamp | — | "2h ago" | Label | --color-text-tertiary |
| consensus_aligned | 3 | "3 of 4" | Title (partial) | --color-primary |
| consensus_total | 4 | (inline) | Title | --color-text-primary |
| consensus_asset | BTC | "long BTC" | Title | --color-text-primary |
| consensus_exposure | 4200.00 | "$4,200" | Data | --color-data |
| consensus_avg_entry | 67450.00 | "$67,450" | Data-sm | --color-text-secondary |
| consensus_timestamp | — | "45m ago" | Label | --color-text-tertiary |
| smart_money_pct | 72 | "72%" | Data | --color-data |
| smart_money_direction | long | "long" | Title | --color-gain |
| smart_money_asset | BTC | "BTC" | Title | --color-text-primary |
| smart_money_wallets | 184 | "184 wallets" | Data-sm | --color-text-secondary |
| smart_money_timestamp | — | "1h ago" | Label | --color-text-tertiary |
| earnings_daily | 487.00 | "+$487" | Hero-sm mono | --color-gain |
| earnings_leaders | 4 | "today from 4 leaders" | Body | --color-text-secondary |
| earnings_best | 234.00 | "+$234" | Data | --color-text-primary |
| earnings_worst | 42.00 | "+$42" | Data | --color-text-primary |
| earnings_win_rate | 87 | "87%" | Data | --color-text-primary |
| earnings_active | "4/4" | "4/4" | Data | --color-text-primary |

**Filter chips (canonical, do NOT modify):** [All] [Market] [Consensus] [Moves] [My Copies]

**Feed mode toggle:** [My Feed] (selected) | [Discover]

---

## 5. Interaction Defaults

Unless overridden in the build card's `## Visual Spec`:

| Element | Gesture | Action |
|---------|---------|--------|
| Glass card | tap | Navigate to detail (specified per card in build card) |
| Glass card | active (press) | scale(0.985), 200ms ease |
| Filter chip | tap | Toggle filter, haptic light |
| Feed mode toggle | tap | Switch mode, 250ms transition |
| Feed | pull-down | Refresh: haptic medium + spinner + reload |
| Feed | scroll | Momentum, sticky header stays fixed |
| WYWA dismiss | tap "Dismiss" | Fade out 200ms, don't reappear until next 8h+ absence |
| Tab bar item | tap | Switch tab, no animation |
| Tab bar Trade | tap | Open trade hub (TH), spring 350ms |

---

## 6. Adding New Screen Fixtures

When creating a new build card:

1. Add a fixture section here: `### 4.X Fixture: {screen-id}`
2. Include ALL display values with exact format, type level, and color token
3. Reference existing icons from the registry (§2) or add new ones
4. Reference existing embellishments from the registry (§3) or add new ones
5. In the build card, add `Fixture: {screen-id}` to the `## Visual Spec` section
