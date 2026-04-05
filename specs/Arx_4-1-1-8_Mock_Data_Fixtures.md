# Mock Data Fixtures

**Artifact ID:** Arx_4-1-1-8
**Title:** Canonical Mock Data for Screen Fixtures
**Last Updated:** 2026-04-06
**Status:** Active
**Dependencies:** `Arx_4-2_Design_System.md` (tokens), `DESIGN.md` (icons, embellishments, interactions), `Arx_4-1-1-0` (master architecture)

<!-- AGENT: This spec provides canonical test fixtures for all screens.
     When generating a design from a build card, load the fixture matching
     the screen ID. Use exact values, display formats, type levels, and
     color tokens. Do NOT invent or modify values.
     Icons & embellishments: see DESIGN.md §3-4.
     Interaction defaults: see DESIGN.md §5.
     Key files: Every specs/Arx_4-1-1-X build card references this file.
-->

> **Purpose:** Eliminate design tool divergence. Every tool reading a build card MUST produce identical data values. This file is the single source of truth for "what the screen looks like with test data."
>
> **Icons, embellishments, and interaction defaults** have moved to `DESIGN.md` (§3, §4, §5).

---

## 1. Type Scale Reference (from Arx_4-2 §3 / DESIGN.md §1.8)

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

## 2. Screen Fixtures

### 2.1 Fixture: C1-R0 (Home + Feed)

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

## 3. Adding New Screen Fixtures

When creating a new build card:

1. Add a fixture section here: `### 2.X Fixture: {screen-id}`
2. Include ALL display values with exact format, type level, and color token
3. Reference icons from `DESIGN.md` §3 or add new ones there
4. Reference embellishments from `DESIGN.md` §4 or add new ones there
5. In the build card, add `Fixture: {screen-id}` to the `## Visual Spec` section
