# Arx Mobile — Radar: Wallets (D1 / D1b / D2 / D3 / Manage)

**Artifact ID:** Arx_4-1-1-4-2
**Title:** Radar Wallets — Trader Discovery, Profiles, Copy Setup & Management
**Last Updated:** 2026-03-30
**Status:** Active
**Parent:** `Arx_4-1-1-4_Mobile_Radar.md` (shared definitions, navigation, states, safety, compliance)
**References:** Signal Transformation (`5-2-3 v5`), Design System (`4-2`, v5.7 regime palette), Trade (`4-1-1-3`), Feed (`4-1-1-4-1`), Perceived Value (`2-6`)

<!-- AGENT: This spec defines the Wallets-side screens within the Radar module (D1, D1b, D2, D3, Manage).
     Sub-spec of: specs/Arx_4-1-1-4_Mobile_Radar.md
     Dependencies: specs/Arx_5-2-3_OnChain_Signal_Transformation_v5.md (leader profiles, cluster membership),
                   specs/Arx_4-2_Design_System.md (all color/typography tokens),
                   specs/Arx_4-1-1-4-1_Radar_Feed.md (cross-references for feed card impacts)
     Test: apps/web-prototype/ (visual verification at 390x844)
-->

---

## 1. Screen Overview

| Property          | Value                                                                                                                            |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **Screens**       | D1 (Traders), D1b (Cold Start), D2 (Wallet Profile), D3 (Copy Setup 2-step), Manage (sub-screen)                                 |
| **JTBD**          | "Who should I trust with my money?" — People-first discovery and evaluation for S7 capital allocators                            |
| **Primary Users** | S7 in all journey states (J0-J4). Browsing uses D1+D2. Copying uses Manage. All states use D2 as the trust evaluation center.    |
| **Entry Points**  | Tab bar "Radar" → Traders tab (default when Browsing), Feed card → D2 Profile, Home [Manage →], Cold Start (J0 first open)       |
| **Exit Points**   | D2 → [Copy Trader >] → D3 → Success → Feed (Copying state), D1 → Trade tab via tab bar, Manage → Feed, [Find More →] → D1        |
| **Key Metrics**   | Time-to-first-copy, copy activation rate (D2 view → D3 start), filter engagement rate, cold start conversion, manage visits/week |

### What This Spec Covers

- D1 Traders screen layout (Browsing, Copying states)
- 2-layer filter architecture (named filter chips → advanced panel)
- Lucid AI search (natural language → filter chips)
- Trader card 3-metric design with time toggle
- D1b Cold Start overlay (first-time UX)
- D2 Wallet Profile (Trust + Live Wallet + Action)
- D3 Copy Setup (2-step: How Much → Confirm)
- Manage sub-screen (safety bar + per-leader controls + danger zone)
- All screen wireframes, interactions, states, data requirements
- Filter data model (TraderFilterQuery TypeScript interface)
- Wallets-specific components, animations, and error states
- Phase boundary (MVP / P2)

### What This Spec Does NOT Cover

- R0 Feed screen (12 card types, altitude taxonomy, feed modes) → see `Arx_4-1-1-4-1`
- Shared design language (color system, typography, safety, compliance) → see parent `Arx_4-1-1-4`
- Leader profile computation, cluster membership → see `Arx_5-2-3 v5`
- S7 Matching Wizard (P2) → see `Arx_9-5`

---

<!-- TRACE: US-S7-EVAL-01 | Pain: E4 (can't assess real leader quality) | Job: JTBD-S7-01 -->
<!-- TRACE: US-S7-ONBD-01 | Pain: P1 (choosing first leader to copy) | Job: JTBD-S7-01 -->

## 2. D1: Traders (Discovery)

### 2.1 Design Intent

The Traders tab is where S7 answers "who should I copy?" Two layers of progressive disclosure serve users from "just show me good ones" (named filter chips) to "I know exactly what I want" (advanced filters). The hierarchy always puts the user's existing relationships (copies, watches) at the top.

### 2.2 Layout — Browsing State (zero copies)

```
+-------------------------------------+
| Traders    [icon: filter-settings] [icon: search]  |  filter-settings = Advanced Filters
+-------------------------------------+
| WATCHING (2 traders)      See All > |  (if hasWatched)
| 0xSteady  +3.1% (7d)  4h ago      |
| DeFiSage  -0.8% (7d)  Idle        |
+-------------------------------------+
| DISCOVER                            |
| [All 47] [Conservative 9]           |  <- Filter chips (single horizontal scroll row)
| [Consistent 12] [High-Balance 6]    |     10 named chips, scroll right for more
| [Hot Hands 5] [Swing Style 8] ...   |
+-------------------------------------+
| 47 traders  [7d|30d*|90d]  Sort ▾  |  <- Controls bar
+-------------------------------------+
| [Trader cards...]                   |
+-------------------------------------+
```

**Section visibility rules:**

- If user has watches → WATCHING section at top, DISCOVER below
- If zero watches → WATCHING hidden, DISCOVER fills the screen
- Controls bar always visible when DISCOVER section is present

### 2.3 Layout — Copying State

```
+-------------------------------------+
| Traders                  [icon: filter-settings] [icon: search]  |
+-------------------------------------+
| MY COPIES (3)              Manage > |
| [CryptoKng] [Whale   ] [0xAce     ]|  <- Horizontal scroll chips
| [ +$210   ] [ +$98   ] [ +$39     ]|
| [ +2.1%   ] [ +0.8%  ] [ +1.5%   ]|
+-------------------------------------+
| WATCHING (2 traders)       Manage > |
| 0xSteady  +3.1% (7d)  4h ago      |
| DeFiSage  -0.8% (7d)  Idle        |
+-------------------------------------+
| DISCOVER                            |
| [Filter chips + list]               |
+-------------------------------------+
```

**MY COPIES section:** Horizontal scroll chips. Each chip: avatar (24px circle) + handle (11px) + today P&L (14px mono, green/orange) + return % (11px). Tap chip → D2 Profile. Tap "Manage >" → Manage sub-screen.

### 2.4 Search

Tap [icon: search] → search overlay:

```
+-------------------------------------+
| [🔍 Search by name or address    ] |
| Recent: 0xSteady, CryptoKing       |
+-------------------------------------+
| Results for "crypto"                |
| CryptoKing   +12.4% (30d)  2.1K   |
| CryptoWhale  +8.1% (30d)   340    |
+-------------------------------------+
```

**Match logic:** `display_name` (fuzzy match), wallet address (prefix match). Tap result → D2 Profile.

**Search overlay styling:** Full-screen overlay, bg `--color-bg`. Search input: 44px height, `--color-surface` bg, 10px radius. Results: trader card compact variant (name + return + follower count). Recent section: 11px `--color-text-tertiary` header, chips for last 5 searched handles.

### 2.5 Trader Card — 3 Metrics + Tier Badge + Capacity

```
+-----------------------------------+
| E 0xSteady          47/500 spots |   14px bold + tier badge | 11px tertiary
|                                   |
| Earned        Wins      Worst mo  |   9px tertiary headers
| +12.4%        81%       -3.1%     |   hero 18px --color-data / others 14px mono
| Conservative                      |   11px badge (risk profile label)
|                    [View Profile]  |   44pt tap -> D2
+-----------------------------------+
```

**Performance tier badge:** Single letter + color before handle. E=Elite (Gold #F59E0B), P=Proven (Silver #9CA3AF), V=Verified (Bronze #D97706), R=Rising (Grey #6B7280), U=no badge. Source: C3.8 from `Arx_5-2-3`. Badge renders as 11px bold, inline with handle.

**Risk profile label:** Below metrics row. "Conservative" / "Moderate" / "Aggressive" / "Degen". Source: C4.2b. 11px, `--color-text-secondary`. Sub-labels ("Hedged", "Concentrated") shown as suffix when present. Truncation rule: if label + sub-labels exceed 28 chars, show label only (sub-labels visible on D2 profile).

**Capacity indicator:** Right-aligned in header row. Format: `{available}/{max} spots` in 11px `--color-text-tertiary` mono. ("spots" not "open" to avoid ambiguity with "open positions" in trading context.) When at capacity: `FULL — waitlist` in 11px `--color-accent-warning` (amber). Source: `[ARX-COPY] copy_slots`. Omitted entirely if trader has not enabled copy trading (no max_slots set).

**Metric definitions:**

| Position | Label      | Meaning                                  | Source                                 | Format                                              |
| -------- | ---------- | ---------------------------------------- | -------------------------------------- | --------------------------------------------------- |
| 1 (hero) | "Earned"   | What FOLLOWERS earned in selected period | `COMPUTE: aggregate copier return`     | +XX.X% green/orange, 18px bold mono, `--color-data` |
| 2        | "Wins"     | Trade win percentage                     | `COMPUTE: profitable closes / total`   | XX%                                                 |
| 3        | "Worst mo" | Worst calendar month return              | `COMPUTE: min monthly from pnlHistory` | -XX.X%                                              |

**MVP fallback for Metric 1:** Label changes to "Returned" (trader's own return, NOT "Earned" or "Followers earned"). Long-press tooltip: "This shows the trader's own return. Follower earnings available soon." When follower aggregation ships, revert to "Followers earned."

**Time toggle:** [7d | 30d* | 90d] — changes ALL three metrics. Default 30d.

**Wallet state badges** (if watching or copying this trader):

- 🔵 "Watching" tag — cyan pill (`--color-data`), right of handle
- 🟣 "Copying +$X" — replaces [View Profile] with today P&L
- Watched/copied wallets sort to TOP of list

**Hero metric visual weight:** The "Earned" metric is the "read this first" number. It renders at 18px bold mono with `--color-data` treatment, visually distinct from the other two metrics at 14px bold mono. This creates a clear information hierarchy on the card.

**Card styling:** Padding 16px. Metric row gap 2px. Card gap 8px. Bg: `--color-surface`. Border: 1px `--color-border`. Radius: 10px. Handle: 14px bold. Metric headers: 9px `--color-text-tertiary`. Hero metric value: 18px bold mono `--color-data`. Other metric values: 14px bold mono. [View Profile]: 44pt tap target, outline `--color-primary`.

### 2.6 Filter Architecture — Two Layers of Progressive Disclosure

```
Layer 1: NAMED FILTER CHIPS (always visible, single horizontal scroll row)
         10 named chips — each is a specific permutation of advanced filter dimensions.
         One-tap shortcut to the most common S7 interests.
         "Show me Conservative traders" / "Who's hot right now?"

Layer 2: ADVANCED FILTER PANEL (tap [icon: filter-settings] → full-screen overlay)
         10 filter dimensions aligned with v5 signal spec + Lucid AI search.
         "I want exactly: swing style, conservative risk, >60% wins, trending regime."
```

**Selection rule:** Only one filter chip active at a time. Selecting a chip deselects any previous selection. Opening the Advanced Filter Panel while a chip is active pre-populates the panel with that chip's filter parameters. On [Apply Filters], the chip is deselected and replaced by the Active Filter Strip showing individual filters.

#### Layer 1: Named Filter Chips

Single horizontal scroll row, pill shape, stadium radius (24px). Height 32px. Padding 8px 16px. Selected: filled `--color-primary`, white text. Unselected: outline `--color-border`, `--color-text-secondary`. Gap: 8px. Match count: 11px `--color-text-tertiary` inline after label.

```
[All 47] [Conservative 9] [Consistent 12] [High-Balance 6] [Hot Hands 5] [Swing Style 8] [Rising 8] [Established 19] [Carry Traders 3] [🎯 My Matches 14]
```

Each chip is a named permutation of the advanced filter dimensions below:

| Label             | Advanced Filter Permutation                                                | S7 Emotion                   |
| ----------------- | -------------------------------------------------------------------------- | ---------------------------- |
| **All**           | No filter — all ranked traders                                             | "Show me everyone"           |
| **Conservative**  | Risk Profile: Conservative, Worst Month > -10%, Avg Leverage <3×           | "Safety first"               |
| **Consistent**    | Win Rate >60%, Worst Month > -15%, Track Record >30d                       | "I won't get burned"         |
| **High-Balance**  | Wallet Size: top 10%, Win Rate >55%, Track Record >6mo                     | "Follow the big players"     |
| **Hot Hands**     | 7d Return: top 10%, Min Trades 7d >5                                       | "Who's winning right now"    |
| **Swing Style**   | Trading Style: Swing, Win Rate >60%, Worst Month > -20%, Track Record >3mo | "Reliable, won't blow up"    |
| **Rising**        | Track Record <6mo OR <200 trades, Follower count <100                      | "Early, could be big"        |
| **Established**   | 200+ trades, Track Record 6-24mo, 50-500 followers                         | "Track record, not mega"     |
| **Carry Traders** | Trading Style: Carry/Position, Funding Bias: Positive, Avg Hold >7d        | "Steady earners"             |
| **🎯 My Matches** | Wizard profile filters (only if wizard completed)                          | "The AI picked these for me" |

**[🎯 My Matches]:** Only visible if user completed S7 Matching Wizard (`matching_profile` exists in DB). Active by default post-wizard. Includes [Refine →] link (11px, `--color-data`) to re-open wizard. See `Arx_9-5` for wizard spec.

**Chip styling:** Match count updates when time toggle changes. Chips scroll off-screen right — all 10 don't need to be visible at once. First 4-5 visible on 390px viewport.

#### Layer 2: Advanced Filter Panel

Tap [icon: filter-settings] → full-screen overlay. Slide up 300ms ease-out.

```
+-------------------------------------+
| Advanced Filters             [✕]   |
+-------------------------------------+
| [🔍 "Find a trader like..."     ]  |  <- Lucid AI search
| "winning in trending markets,       |
|  conservative, BTC focused"         |
+-------------------------------------+
| TRADING STYLE                       |
| [Scalper] [Day] [Swing●] [Position]|
| [Carry] [Momentum]                  |
+-------------------------------------+
| RISK PROFILE                        |
| [Conservative●] [Moderate]          |
| [Aggressive] [Degen]                |
+-------------------------------------+
| WALLET SIZE                         |
| $0 ══════════●══════ $5M+          |
+-------------------------------------+
| WIN RATE                            |
| 0% ══════════════●═══ 100%         |
+-------------------------------------+
| TRACK RECORD                        |
| 30d ═══════●═══════ 365d           |
+-------------------------------------+
| AVG LEVERAGE                        |
| 1× ═══════●════════ 50×            |
+-------------------------------------+
| MIN TRADES (7d)                     |
| 0 ════════●═════════ 50+           |
+-------------------------------------+
| MARKET REGIME STRENGTH              |
| [Trending] [Range-Bound]            |
| [All-Weather●]                      |
+-------------------------------------+
| FUNDING BIAS                        |
| [Positive] [Neutral] [Negative]     |
+-------------------------------------+
| ASSETS                              |
| [BTC] [ETH] [Alts] [Multi]         |
| [Cross-Asset]                       |
+-------------------------------------+
| 23 traders match                    |
|         [Apply Filters]             |  48px primary CTA
|         [Reset All]                 |  14px muted link
+-------------------------------------+
```

**10 Filter Dimensions (aligned with v5 signal spec `Arx_5-2-3` §8.1 + §C4):**

| #   | Dimension                  | Type                | Options                                        | v5 Source       | Default    |
| --- | -------------------------- | ------------------- | ---------------------------------------------- | --------------- | ---------- |
| 1   | **Trading Style**          | Multi-select chips  | Scalper, Day, Swing, Position, Carry, Momentum | C4.1            | None (all) |
| 2   | **Risk Profile**           | Single-select chips | Conservative, Moderate, Aggressive, Degen      | C4.2 + C3.3     | None (all) |
| 3   | **Wallet Size**            | Range slider        | $0 — $5M+ (log scale)                          | §8.1 dim 1      | Full range |
| 4   | **Win Rate**               | Range slider        | 0% — 100%                                      | C3.4            | Full range |
| 5   | **Track Record**           | Range slider        | 30d — 365d                                     | First fill date | Full range |
| 6   | **Avg Leverage**           | Range slider        | 1× — 50× (log scale)                           | C4.3 derived    | Full range |
| 7   | **Min Trades (7d)**        | Range slider        | 0 — 50+                                        | C14.1           | 0          |
| 8   | **Market Regime Strength** | Multi-select chips  | Trending, Range-Bound, All-Weather             | C5.1 + C5.6     | None (all) |
| 9   | **Funding Bias**           | Multi-select chips  | Positive, Neutral, Negative                    | C4 carry detect | None (all) |
| 10  | **Assets**                 | Multi-select chips  | BTC, ETH, Alts, Multi, Cross-Asset             | C14.2           | None (all) |

**v5 regime mapping (dimension #8):**

- **Trending** = Leaders with high win rate when v5 `regime_state = TRENDING` (C5.6 `regime_win_rate` in TRENDING > 60%)
- **Range-Bound** = Leaders with high win rate when v5 `regime_state = RANGE_BOUND` (C5.6 `regime_win_rate` in RANGE_BOUND > 60%)
- **All-Weather** = Leaders profitable in ≥3 of 5 regime states (TRENDING, RANGE_BOUND, COMPRESSION, CRISIS, TRANSITION). Maps to v5 performance tier P9 "All-Weather"

**Note:** The 5 v5 regime states (TRENDING, RANGE*BOUND, COMPRESSION, CRISIS, TRANSITION) describe the \_current market condition*. The filter dimension describes the _trader's historical strength_ in those conditions. Filtering by "Trending" finds traders who _perform well in trending markets_, not traders currently in a trending market.

**MVP regime filter fallback (dimension #8):**

- "Trending" filter = traders with C3.5 overall WR > 60% (not regime-specific at MVP)
- "All-Weather" filter = traders profitable in >=3 of 5 most recent regime periods (approximated from portfolio history dates + regime transitions)
- Post-C5.6: true per-regime win rate replaces overall WR

**Funding Bias computation (dimension #9):**

```python
def funding_bias(wallet, window="90d"):
    fills = get_user_fills_by_time(wallet, start=window)
    total_pnl = sum(f.closedPnl for f in fills if f.closedPnl != 0)
    funding_pnl = sum(f.cumFunding for f in fills)  # from [HL-STATE] cumFunding.sinceOpen
    if total_pnl == 0: return "Neutral"
    ratio = funding_pnl / total_pnl
    if ratio > 0.2: return "Positive"    # Earns >20% of PnL from funding
    elif ratio < -0.2: return "Negative"  # Pays >20% of PnL in funding
    else: return "Neutral"
```

**Assets dimension (#10) MVP computation:**

- `SELECT DISTINCT coin FROM user_fills WHERE wallet = ? AND time > 90d_ago` per asset
- BTC-Focused: >60% of trades in BTC. Multi-Coin: no asset >40%. Cross-Asset: trades in >=3 asset classes.

**Slider styling:** Track: 4px height, `--color-border`. Thumb: 20px circle, `--color-primary`. Active track: `--color-primary`. Labels: 11px mono at endpoints. Haptic: light on drag, medium at preset snap points.

**Live count:** "23 traders match" updates in real-time as filters change. If 0: "No traders match these filters" + [Broaden Filters] link.

**Active filter strip:** When advanced filters are applied and panel is closed, a horizontal strip appears below header showing active filters as dismissible chips:

```
[Swing ✕] [Conservative ✕] [Win >60% ✕] [Leverage <5× ✕]    [Clear All]
```

Strip styling: Horizontal scroll, pill chips, `--color-surface-elevated` bg, 11px text + [✕] dismiss. [Clear All]: 11px `--color-text-tertiary`. Height: 36px total.

#### Lucid AI Search

Natural language → filter chips. Input field at top of Advanced Filter Panel.

| User Types                          | Translates To                       |
| ----------------------------------- | ----------------------------------- |
| "winning over 90 days"              | Track Record ≥ 90d                  |
| "conservative BTC focused"          | Risk: Conservative + Assets: BTC    |
| "like High-Balance but swing style" | High-Balance chip + Style: Swing    |
| "consistently profitable"           | Win Rate > 60% + Track Record > 90d |
| "high win rate, low drawdown"       | Win Rate > 70% + Worst month > -10% |

**Implementation:** Chips appear below search field as user types. Tap chip to apply. User can edit chips manually. MVP: client-side keyword→filter mapping (no LLM call). P2: server-side NL inference.

**Lucid inline hint:** When Lucid detects high-confidence filter match, show subtle hint below search: "Try: 'winning in trending markets'" — 11px, `--color-text-tertiary`, fades after first use.

### 2.7 Sort Controls

```
47 traders  [7d|30d*|90d]  [Sort: Follower Return ▾]
```

| Sort Option     | Default? | Logic                                        |
| --------------- | -------- | -------------------------------------------- |
| Follower Return | Yes      | Median copier return (selected period), desc |
| Win Rate        |          | Win percentage, desc                         |
| Total Earned    |          | sum(copier PnL) all-time, desc               |
| Newest          |          | Account creation date, desc                  |

### 2.8 Watching Section Card Spec

```
0xSteady   +3.1% (7d)  Last trade: 4h ago
DeFiSage   -0.8% (7d)  Idle
```

| Field      | Source                                 | Notes                      |
| ---------- | -------------------------------------- | -------------------------- |
| 7d return  | `COMPUTE: 7d pnl delta`                | Green if >0, orange if <=0 |
| Last trade | `API: get_user_fills` latest timestamp | `--color-neutral`          |
| "Idle"     | No trade >48h                          | `--color-neutral`          |

Tap → D2 Profile.

### 2.9 S7 Matching Wizard Integration

When wizard is completed (`matching_profile` exists in DB):

- **[🎯 My Matches]** chip appears as LAST chip in filter row (rightmost, scroll to reveal)
- Active by default on first visit post-wizard
- Deactivatable — user can browse all traders
- **[Refine →]** link next to chip opens wizard for re-tuning

When wizard NOT completed, cold start prompt card shows above DISCOVER (see §3 D1b).

**Wizard spec reference:** `Arx_9-5_S7_Wizard_Privy_MoonPay_Onboarding_Proposal.md` §1

### 2.10 D1 Interactions

| Element                               | Tap     | Result                                               |
| ------------------------------------- | ------- | ---------------------------------------------------- |
| MY COPIES chip                        | Tap     | → D2 Profile for that leader                         |
| "Manage >" (copies)                   | Tap     | → Manage sub-screen                                  |
| WATCHING trader                       | Tap     | → D2 Profile                                         |
| "See All >" (watching)                | Tap     | → Manage sub-screen (watch list view)                |
| Filter chip                           | Tap     | Apply named filter, update list                      |
| [icon: filter-settings] filter button | Tap     | → Advanced Filter Panel (full-screen overlay)        |
| Active filter chip [✕]                | Tap     | Remove that filter, update list                      |
| [Clear All]                           | Tap     | Remove all advanced filters, return to [All] chip    |
| Time toggle pill                      | Tap     | Re-fetch metrics for period                          |
| Sort dropdown                         | Tap     | Change sort order                                    |
| Trader card (anywhere)                | Tap     | → D2 Profile                                         |
| [View Profile]                        | Tap     | → D2 Profile                                         |
| [🎯 My Matches]                       | Tap     | Apply wizard filters                                 |
| [Refine →]                            | Tap     | → S7 Matching Wizard                                 |
| [icon: search] search button          | Tap     | → Search overlay                                     |
| [Apply Filters]                       | Tap     | Close panel, apply filters, show active filter strip |
| [Reset All]                           | Tap     | Clear all filters to defaults                        |
| Pull down                             | Gesture | Refresh trader list                                  |

### 2.11 D1 States

| State                       | Behavior                                                                                                                                       |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Loading                     | Skeleton: header + 5 filter chip pills + 3 card placeholders, shimmer 1.5s                                                                     |
| Empty (zero filter results) | "No traders match" + [Broaden Filters] + [Browse All]                                                                                          |
| Empty (zero traders in DB)  | "Traders loading..." (should never persist — flag if >5s)                                                                                      |
| Error                       | "Couldn't load traders" + [Retry] + cached list if available                                                                                   |
| Advanced filters active     | Active filter strip visible below header. Count badge on [icon: filter-settings] icon                                                          |
| Offline                     | Amber banner "Offline — showing last-known data" + cached trader list. Filters disabled (grayed out). [icon: filter-settings] non-interactive. |

### 2.12 Advanced Filter Panel States

| State                     | Behavior                                                                                                                              |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Loading                   | Skeleton shimmer on filter chips + "— traders match" placeholder. Panel opens immediately; count populates on API response.           |
| Error (count fetch fails) | "23 traders match" → "Filters active — count unavailable". [Apply Filters] still works (filters applied client-side, count hidden).   |
| Offline                   | Panel does NOT open. Toast: "Filters need a connection. Showing cached results." (Filters require live API for count and validation.) |
| Zero results              | "No traders match these filters" + [Broaden Filters] link. [Apply Filters] disabled.                                                  |

---

## 3. D1b: Cold Start

### 3.1 Design Intent

Shown once on first open when user has zero copies AND zero watches. Removes decision paralysis by presenting 6 hand-curated traders with specific reasons. Every element gives permission to start small.

### 3.2 Layout

```
+-------------------------------------+
| Welcome to Arx                      |  28px bold
| Pick a trader to start.             |  14px
| Their trades become yours.          |
| Start small -- you can always       |
| add more later.                     |
|                                     |
| +-------------------------------+   |
| | 0xSteady                      |   |
| | Consistent swing — wins 68%   |   |  11px / DB: curated reason
| | Returned +12.4%/mo            |   |  14px green / COMPUTE (MVP: trader return)
| | 812 people copying            |   |  11px / DB
| |                [View Profile] |   |
| +-------------------------------+   |
| [... 5 more curated traders ...]    |
|                                     |
| These traders shown based on track  |  9px --color-text-tertiary
| record data, not personal advice.   |
|                                     |
| Just looking for now >              |  14px muted -> Traders tab
+-------------------------------------+  ↑ pinned to bottom safe area (sticky)
```

**375px breakpoint rule:** At viewport heights < 740px, "Just looking for now >" is pinned to the bottom safe area as a sticky footer (64px + safe area). Trader cards scroll behind it. Escape is always visible (Design Principle #5 from parent spec: "Escape is always possible").

### 3.3 Key Copy Decisions

- MVP: "Returned" (trader's own return). Post-MVP: "Followers earned" (aggregate copier return). NEVER show trader's own return under a label implying follower returns.
- "X people copying" not "X followers"
- "Start small — you can always add more later" — permission to be cautious
- "Just looking for now >" — non-committal exit (not "Skip")
- 6 curated traders, hand-picked for stability and track record
- Each card includes 1-line reason: "Consistent swing trader — wins 68% in trending markets" (answers S7 need #3: understanding WHY)

**Capacity freshness rule:** Curated traders must have >10% capacity remaining. Server substitutes from a ranked backup list if a curated trader's capacity fills. Each cold start card shows "{N} spots left" (11px, `--color-text-tertiary`; amber if <20 spots). This prevents the dead-end where a new user taps a curated trader only to find them at capacity.

### 3.4 Trigger & Dismissal

**Trigger:** First app open with zero copies AND zero watches.
**Dismissed after:** Tapping [View Profile], tapping [Watch] or [Copy] from within a profile, or tapping "Just looking for now >".
**Persistence:** Once dismissed, never shown again (persisted flag in local storage).

### 3.5 D1b Interactions

| Element                  | Tap     | Result                                              |
| ------------------------ | ------- | --------------------------------------------------- |
| Trader card              | Tap     | → D2 Profile. Cold start dismissed.                 |
| [View Profile]           | Tap     | → D2 Profile. Cold start dismissed.                 |
| "Just looking for now >" | Tap     | Dismiss cold start → Traders tab (Discover section) |
| Swipe down               | Gesture | Dismiss cold start → Traders tab                    |

### 3.6 D1b States

| State                  | Behavior                                                                    |
| ---------------------- | --------------------------------------------------------------------------- |
| Loading                | Skeleton: 6 card placeholders with shimmer. ~400ms (curated set is cached). |
| Error (DB fetch fails) | Skip cold start entirely → show Traders tab with Discover section           |
| Offline                | Skip cold start → Traders tab with cached data if available                 |

---

<!-- TRACE: US-S7-EVAL-01 | Pain: E4 (evaluating individual leader trust) | Job: JTBD-S7-01 -->
<!-- TRACE: US-S7-FVAL-01 | Pain: P3 (risk rail triggered, first protection event) | Job: JTBD-S7-02 -->

## 4. D2: Wallet Profile (Leader Detail)

### 4.1 Design Intent

S7 arrives with one question: "Can I trust this person with my money?" Three sections answer in order: Trust (can they trade?), Live Wallet (what are they doing now?), Action (commit or keep watching).

**Width:** 390px (iPhone 14 Pro logical). Viewport: 714px visible.

### 4.2 Wireframe — 390px

```
+==========================================+
| < Back                    ★  ⋮           |
+==========================================+
| [Avatar 48x48]  @CryptoWolf             |
|  rounded        Trading since            |
|                 Jan 15, 2024             |
|                 0x7a2f...3d9e >          |
+==========================================+
| === SECTION 1: TRUST ===============    |
|                                          |
| +--------------------------------------+ |
| |     Followers earned +$47,230        | |
| |     423 followers                    | |
| +--------------------------------------+ |
|                                          |
|   [7d] [30d] [90d] [All]        <- inherits D1 period; 90d if no prior              |
| +--------------------------------------+ |
| |      90d Equity Curve (180px h)      | |
| +--------------------------------------+ |
|                                          |
|  -- Stats Grid (2x3) -----------------  |
| +-------------+------------------------+ |
| | Win Rate    | Trades/Week            | |
| | 68%         | 8.3                    | |
| | 612 trades  |                        | |
| +-------------+------------------------+ |
| | Time Active | Worst Month            | |
| | 14 months   | -18% (Mar 2025)        | |
| +-------------+------------------------+ |
| | Typical Risk| Avg Hold               | |
| | 3.2x        | 2.4 days               | |
| +-------------+------------------------+ |
+==========================================+
| === SECTION 2: LIVE WALLET =========    |
|                                          |
|  v Recent Trades (last 5) (expanded)     |
| +--------------------------------------+ |
| | BTC LONG  +$1,200 (+3.1%)   2h ago  | |
| +--------------------------------------+ |
| | SOL SHORT +$430 (+1.8%)     5h ago  | |
| +--------------------------------------+ |
| | ETH LONG  -$180 (-0.9%)    12h ago  | |
| +--------------------------------------+ |
|                                          |
|  > Holdings (3 positions) (collapsed)    |
| +--------------------------------------+ |
| | BTC LONG   3x   $42,310             | |
| | Entry $69,800 -> Mark $70,310       | |
| | Unrealized: +$1,530 (+2.2%)    G    | |
| +--------------------------------------+ |
| | SOL LONG   5x  Unrealized: +$650  G | |
| +--------------------------------------+ |
| | ETH SHORT  2x  Unrealized: -$410  O | |  <- ORANGE (not red)
| +--------------------------------------+ |
|                                          |
|  > Funding Position (collapsed)          |
+==========================================+
| === SECTION 3: ACTION ==============    |
|                                          |
|  Copy fee: ~$0.50 per $1,000 traded     |
|  On-chain: 0x7a2f...3d9e > (Hyperliquid)|
+==========================================+
| 153 spots left          [Copy Trader >]  |  <- STICKY FOOTER
| [Watch]                                  |     Spots Left = urgency indicator
+==========================================+
```

### 4.3 Header Block

| Element                      | Typography                 | Color                            | Source                            |
| ---------------------------- | -------------------------- | -------------------------------- | --------------------------------- |
| Avatar                       | 48x48, border-radius: full | --                               | `DB` or Jazzicon                  |
| @Handle                      | 20px/28px, weight 600      | `--color-text-primary` #EEE9FF   | `DB` (fallback: truncated wallet) |
| "Trading since Jan 15, 2024" | 14px/22px, weight 400      | `--color-text-secondary` #9D96B8 | `COMPUTE` from earliest trade     |
| Wallet address               | 11px/16px, mono            | `--color-text-tertiary` #4A4468  | Wallet address param              |
| Verify link (tap)            | —                          | `--color-data` #22D1EE           | Constructed Hyperliquid URL       |

### 4.4 Section 1: Trust & Performance

**1a. Hero Stat Card (dual metric):** Leads with total follower earnings -- "+$47,230" in 28px bold mono. Below: "Median follower: +8.2%" in 14px mono green (source: C13.2 median copier return %). "423 followers" as supporting context (11px, `--color-text-secondary`). Card bg: `--color-surface-elevated`. Radius: 10px. Padding: 16px. The total $ is the attention-grabber; the median % is the attribution-correct metric (not skewed by large allocators).

**MVP fallback** (no backend follower aggregation): Show trader's own return. Label: "Leader's 30d: +12.4%" (source='leader' label from C13.2 headline_return()). Footnote: "Copy data building -- showing leader's verified return." Label "Returned" NOT "Earned" or "Followers earned." All Day 1 traders show this variant.

**1b. Equity Curve (90d default):** Height 180px. Smoothed area chart. Fill: rgba(34,209,238,0.08). Stroke: `--color-data` #22D1EE 1.5px. Chart draws left-to-right 800ms. Touch scrub tooltip. Source: `API:portfolio`. Time toggle: [7d | 30d | 90d* | All] — pills, same styling as filter chips. D2 inherits the time period selected on D1 as its initial default. If the user viewed the trader card at 7d, D2 opens at 7d.

**Equity curve attribution note:** Below the chart, 11px `--color-text-tertiary`: "Your copy returns may differ." with [?] tooltip expanding to full disclaimer: "This shows the trader's equity. Your copy returns may differ based on timing, allocation, and fees."

**1c. Stats Grid (2×3):**

| Cell         | Value            | Source                             | Notes                                    |
| ------------ | ---------------- | ---------------------------------- | ---------------------------------------- |
| Win Rate     | 68% / 612 trades | `COMPUTE`                          | Secondary: trade count                   |
| Trades/Week  | 8.3              | `COMPUTE: trade_count / weeks`     | Activity frequency signal                |
| Time Active  | 14 months        | `COMPUTE: earliest trade`          |                                          |
| Worst Month  | -18% (Mar 2025)  | `COMPUTE: min monthly`             | Month label for context                  |
| Typical Risk | Moderate (3.2x)  | `COMPUTE: C4.2b label + avg lever` | Label + number (e.g., "Moderate (3.2x)") |
| Avg Hold     | 2.4 days         | `COMPUTE: mean(close - open time)` | Distinguishes scalpers from swingers     |

Grid styling: Background `--color-surface`, border 1px `--color-border`, radius 14px. Cell gap: 1px border (visual separator). Values: 20px/28px weight 600. Labels: 9px `--color-text-tertiary`.

### 4.5 Section 2: Live Wallet State

**Section order rationale:** Trade history is the #1 trust signal for S7 -- it appears first. S2 taps to expand Holdings for depth.

**2a. Recent Trades (EXPANDED by default):** Last 5 trades. Trade history is the primary trust signal S7 looks for -- what has this trader actually done?

| Field       | Typography     | Color                                | Source                 |
| ----------- | -------------- | ------------------------------------ | ---------------------- |
| Coin symbol | 14px semi mono | `--color-text-primary`               | `API: get_user_fills`  |
| Direction   | 11px           | Green (LONG) / Orange (SHORT)        | `API: side`            |
| Size        | 11px mono      | `--color-text-secondary`             | `API: sz`              |
| Entry/Close | 11px mono      | `--color-text-secondary`             | `API: px`              |
| Closed P&L  | 14px bold mono | Green (gain) / Red (loss) — realized | `COMPUTE: closedPnl`   |
| Time        | 11px           | `--color-text-tertiary`              | `API: time` → relative |

**Row layout:** Coin+Direction left, P&L right-aligned. Price and time below in secondary row. Card: `--color-surface` bg, 12px padding, 4px gap between rows.

**2b. Holdings (COLLAPSED by default):**

**Holdings header enrichment:** When expanded, header shows exposure + concentration labels inline:

```
> Holdings (3 positions)  Heavy exposure — Top-Heavy
```

- **Exposure label**: from C4.3 (Heavy/Moderate/Light/Sidelined) — tells S7 how committed this leader is
- **Concentration label**: from C4.4 HHI (Single-Asset/Top-Heavy/Diversified) — tells S7 how diversified

Each position card (collapsed view):

| Field          | Typography     | Color                         | Source                 |
| -------------- | -------------- | ----------------------------- | ---------------------- |
| Coin symbol    | 14px semi mono | `--color-text-primary`        | `API: get_user_state`  |
| Direction      | 11px           | Green (LONG) / Orange (SHORT) | `API: side`            |
| Leverage       | 11px mono      | `--color-text-secondary`      | `API: leverage.value`  |
| Size           | 11px mono      | `--color-text-secondary`      | `API: szi × mark`      |
| Entry / Mark   | 11px mono      | `--color-text-secondary`      | `API: entryPx, markPx` |
| Unrealized P&L | 14px bold mono | Green (gain) / Orange (loss)  | `API: unrealizedPnl`   |

**Position expanded view (tap to reveal):** Additional fields on tap-expand per position:

| Field              | Typography | Color                                              | Source                        |
| ------------------ | ---------- | -------------------------------------------------- | ----------------------------- |
| Liquidation price  | 11px mono  | Amber if <10% distance, Deep Orange #EA580C if <5% | `API: liqPx`                  |
| TP / SL            | 11px mono  | `--color-text-secondary`                           | `API: get_open_orders isTpsl` |
| Funding since open | 11px mono  | Orange if negative, green if positive              | `API: cumFunding.sinceOpen`   |
| Regime at open     | 11px       | `--color-text-tertiary`                            | `COMPUTE: regime at entry`    |

Format: "Liq: $58,200 (16.2% below)" -- show "--" if null. "TP: $72,000 SL: $65,000" -- "Not set" if null. Funding: "-$14.20 since open". Regime: "Opened in Trending regime". Progressive disclosure preserves the clean collapsed view.

Position card styling: Left border 2px green (gain) or orange (loss). Card bg: `--color-surface`. 12px padding, 8px gap between cards.

**Unrealized losses in ORANGE, not red.** Red reserved for realized losses (closed trades). This is a deliberate design choice: orange = "still open, could recover"; red = "done, you lost."

**2c. Funding Position (COLLAPSED by default):** Account Value, Margin Used, Available. Source: `API: get_user_state`. Tap header to expand. Shows full funding breakdown when expanded.

### 4.6 Section 3: Engagement & Action

Fee disclosure: "Copy fee: ~$0.50 per $1,000 traded." (14px, `--color-text-secondary`)
On-chain verify: wallet address as tappable link → Hyperliquid explorer. (11px mono, `--color-data`)

**Spots Left (urgency indicator):** Shown in the sticky footer area, left of the CTA. Format: "{N} spots left" in 11px `--color-text-secondary`. When <20 spots: `--color-accent-warning` (amber). When 0: hidden (footer shows [Full -- Join Waitlist] instead). Source: `DB: max_slots - active_copies`.

### 4.7 Sticky Footer

Height 64px + safe area. Bg: `--color-surface-modal` #150C35, backdrop-filter: blur(20px).

| State                  | Left Side                 | Right Side                             |
| ---------------------- | ------------------------- | -------------------------------------- |
| Not watching           | [Watch] outline           | [Copy Trader >] primary                |
| Watching               | [Watching ✓] outline cyan | [Copy Trader >] primary                |
| Copying                | "Copying · +$12.40"       | [Add Funds] outline · [Manage] primary |
| At capacity            | [Watch] outline           | [Full — Join Waitlist]                 |
| Watching + At capacity | [Watching ✓] outline cyan | [Full — Join Waitlist]                 |
| $0 balance viewing     | [Watch] outline           | [Copy Trader >] primary                |

**Copying state detail:** Left side shows today P&L badge: "Copying · +$12.40" (green) or "Copying · -$3.20" (orange). Right side offers two actions:

- **[Add Funds]:** Outline button. Tap → bottom sheet with amount input, pre-populated with current allocation. Same flow as D3 Step 2 but skips leader selection (already copying). Confirm → on-chain transaction.
- **[Manage]:** Primary button. Tap → ManageCopy screen (pause, stop, adjust allocation, remove funds).

**Remove Funds:** Available inside [Manage] screen, not in footer directly. Partial withdrawal involves settlement timing and position impact — MVP shows the full Manage flow. P2: add [Remove Funds] as third footer action if usage data shows >30% of Manage taps are for withdrawal.

**[Watching ✓] tap = unwatch** (with confirm: "Stop watching @handle?"). Separate from notification toggle (P2).

**[Full — Join Waitlist] MVP fallback:** Toast "This trader is at capacity. We'll notify you when a spot opens." + auto-add to Watch list if not already watching.

**Watching + At capacity:** User already watching this trader who subsequently filled up. Left shows existing watch state; right shows waitlist CTA. Tapping [Full -- Join Waitlist] here shows toast without re-adding to watch list (already watching).

**$0 balance viewing:** Footer shows standard [Watch] + [Copy Trader >]. The $0 balance is handled in D3 Step 1 where the slider is disabled and [Deposit >] is shown. This avoids blocking exploration of the D2 profile.

**★ (bookmark) and footer sync:** Tapping ★ in header also toggles watch state. Both ★ and footer [Watch]/[Watching ✓] reflect the same DB state. Tapping either updates both.

### 4.8 D2 Interactions

| Element                            | Tap        | Result                                                                                                                                       |
| ---------------------------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| ← Back                             | Tap        | Navigate back to previous screen                                                                                                             |
| Wallet address                     | Tap        | Open Hyperliquid explorer in external browser                                                                                                |
| ★ (bookmark)                       | Tap        | Toggle watch. If not watching: add + toast + ★ fills solid. If watching: confirm "Stop watching?" → unwatch + ★ outline. Synced with footer. |
| ⋮ (more)                           | Tap        | Bottom sheet: [Share Profile], [Report]                                                                                                      |
| Time toggle [7d] [30d] [90d] [All] | Tap        | Re-fetch equity curve + stats for period                                                                                                     |
| Equity curve                       | Touch+drag | Scrub tooltip shows date + value                                                                                                             |
| Stat grid cell                     | —          | Display only                                                                                                                                 |
| Funding section header             | Tap        | Toggle collapse/expand, 200ms                                                                                                                |
| Holdings section header            | Tap        | Toggle collapse/expand, 200ms                                                                                                                |
| Recent Trades section header       | Tap        | Toggle collapse/expand, 200ms                                                                                                                |
| Position card (Holdings)           | Tap        | Expand to show entry/mark prices, margin details                                                                                             |
| [Watch]                            | Tap        | Add to watch list + button → [Watching ✓]                                                                                                    |
| [Watching ✓]                       | Tap        | Confirm "Stop watching @{handle}?" → unwatch                                                                                                 |
| [Copy Trader >]                    | Tap        | → D3 Copy Setup                                                                                                                              |
| [Manage]                           | Tap        | → Manage sub-screen (only shown in Copying state)                                                                                            |
| [Full — Join Waitlist]             | Tap        | Toast + auto-watch (MVP). → Waitlist registration (P2).                                                                                      |
| Pull down                          | Gesture    | Refresh all data                                                                                                                             |

### 4.9 D2 States

| State           | Behavior                                                                                                                                   |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Loading         | Skeleton 1.5s. Progressive render: Header first (~200ms), then Stats + Holdings (~400ms), then Equity curve (~300ms). Shimmer per section. |
| Error           | "Couldn't load trader data." + [Try Again]. Retry re-fires all 4 APIs.                                                                     |
| Partial load    | Show loaded sections, skeleton on pending. If only equity curve fails: stats with "Chart unavailable" placeholder.                         |
| Empty positions | "No open positions right now. Last trade: 3 days ago." (from `get_user_fills` latest timestamp)                                            |
| Empty trades    | "No recent trades." (distinct from new wallet — wallet exists but no fills in selected period)                                             |
| New wallet      | "No trading history." Only Watch available. Copy button hidden.                                                                            |
| Offline         | Amber banner "Offline — showing cached data" + last-known values + timestamp                                                               |

### 4.10 API Call Sequence (parallel on mount)

| #   | API Call              | Populates                         | Latency Target |
| --- | --------------------- | --------------------------------- | -------------- |
| 1   | `get_user_state`      | Header, Funding, Holdings         | ~200ms         |
| 2   | `get_portfolio`       | Equity curve                      | ~300ms         |
| 3   | `get_user_fills`      | Trades, stats, win rate, worst mo | ~400ms         |
| 4   | `get_user_spot_state` | Spot balances                     | ~200ms         |

All 4 fire in parallel on mount. Progressive rendering: show each section as its API resolves.

---

<!-- TRACE: US-S7-ONBD-01 | Pain: P1 (committing capital to first copy) | Job: JTBD-S7-01 -->

## 5. D3: Copy Setup (2 Steps)

### 5.1 Step 1: How Much?

```
+-------------------------------------+
| < Back                    Step 1/2  |
+-------------------------------------+
| Copy @CryptoKing                    |  28px bold
| 68% win rate — Moderate risk (3.2x) |  (risk label + leverage from C4.2b)
+-------------------------------------+
| G Trending — copies at full size    |  Regime banner (regime color bg)
+-------------------------------------+
| How much to allocate?               |
|                                     |
|   [$100] [$250] [$500] [Custom]     |  Quick picks
|   Suggested: $420                   |  C6.5 recommendation (14px bold --color-data)
|   (Based on your balance + market)  |  9px tertiary explanation
|                                     |
| [$50 ========|============ $2,500]  |  Slider
|              $420                    |  28px hero mono
+-------------------------------------+
| PROJECTION (at $420)                |
| +-------------------------------+   |
| | Typical month    +$26 (+6.1%) |   |
| | Best month       +$34 (+8.2%) |   |
| +-------------------------------+   |
| +-------------------------------+   |  <- Amber left border
| | Your safety net               |   |
| | Copying pauses at -$210       |   |
| | Worst month      -$60 (-14.3%)|   |
| | Safety limit: -$210 (50%)     |   |
| +-------------------------------+   |
| Past results don't guarantee future  |
| returns. Start small.               |
| ⚠ BTC is in crisis — your safety    |  <- Regime context banner
| limit of -$210 protects your capital |  Only shows for COMPRESSION, CRISIS, TRANSITION
|          [Continue >]               |
+-------------------------------------+
```

**C6.5 recommended size:** "Suggested: $420" in 14px bold, `--color-data`. Source: `C6.5: kelly x regime_sizing x risk_pref_multiplier x confidence_factor x accountValue`, capped at 25% of account. Explanation: "(Based on your balance + market)" in 9px `--color-text-tertiary`. NOT required -- user can pick any amount.

**Risk label in header:** "68% win rate -- Moderate risk (3.2x)" from C4.2b provides trust context before allocation decision.

**Regime sizing note in banner:** "copies at full size" / "copies at 0.5x -- choppy" / etc. Banner uses regime color (see Regime Color Palette below).

**Slider spec:** Min $50. Max: available balance. Haptic at quick pick values. Grey out unavailable quick picks (if > available balance). Track: 4px, `--color-border`. Thumb: 24px circle, `--color-primary`. Active track: `--color-primary`.

**Projection cards:** Two cards side by side (requires >=20 closing fills in last 90 days):

- **Green card** (positive): Typical month + Best month. Bg: `--color-surface`. Left border: 2px `--color-positive`.
- **Amber card** (protection): Header "Your safety net" + sub-line "Copying pauses automatically at -{safety_amount}". Shows Worst month stat + Safety limit (50% canonical default per C7.1 and competitor benchmarks). Bg: `--color-surface`. Left border: 2px `--color-warning`. Framed as protection, not loss.

**Insufficient history (< 20 fills in 90d):** Replace projection cards with single info card: "Not enough trading history for a projection. This trader has made [N] trades in 90 days." Show raw return and win rate inline instead. No Typical/Best/Worst month — sample size too small for meaningful statistics.

**Regime context banner:** Shown when **any asset in this leader's portfolio** has regime `COMPRESSION`, `CRISIS`, or `TRANSITION`. The banner names the specific asset(s) and ties to the user's concrete allocation and safety limit: "{Asset} is in {regime} — your safety limit of -${safety_amount} protects your capital" (e.g., "SOL is in compression — your safety limit of -$100 protects your capital"). For the allocation context line: "Your copies will follow at your set amount of ${allocation}". Hidden when all leader assets are `TRENDING` or `RANGE_BOUND` (benign regimes). Amber left border, 12px `--color-text-secondary`. Satisfies Design Principle #4 (from parent spec): "Context with every loss." Source: v5 C5.1 `classify_regime(asset)` per-asset, scoped to assets this leader trades. Safety amount from `COMPUTE: amount × 0.50`. Regime colors per section 12 palette (CRISIS = Deep Orange #EA580C, COMPRESSION = Teal #0D9488).

### 5.2 Step 2: Confirm

```
+-------------------------------------+
| < Back                    Step 2/2  |
+-------------------------------------+
| Confirm your copy                   |
| +-------------------------------+   |
| | Trader     CryptoKing         |   |
| | Amount     $500               |   |
| | Safety     Pauses at -$250    |   |  50% x amount (canonical default)
| | Fee        ~$0.10 per trade   |   |
| +-------------------------------+   |
| +-------------------------------+   |
| | What happens next:            |   |
| | · Future trades copied to $500|   |
| | · Current open positions NOT  |   |
| |   copied (new trades only)    |   |
| | · New copying pauses at -$100 |   |
| | · Open positions may still    |   |
| |   change after pause          |   |
| | · Pause or stop anytime       |   |
| | · Averages [N] trades/week    |   |
| +-------------------------------+   |
| Trading involves risk. Your safety   |
| limit will pause copying at -$100    |
| to protect your capital.             |
| [Learn more v]                       |
| Arx earns a fee on each trade made   |
| on your behalf.                      |
|                                      |
| ☐ I understand I may lose up to     |  Required checkbox
|   $100 on this copy                  |  (amount = safety limit)
|       [Start Copying]               |  48px primary CTA, disabled until ☐ checked
+-------------------------------------+
```

**Risk disclosure:** Primary inline copy: "Trading involves risk. Your safety limit will pause copying at -{safety_amount} to protect your capital." The [Learn more] expandable section contains the generic compliance disclosure: "Past results don't guarantee future returns. Copy trading involves the risk of loss. Your safety limit automatically pauses copying to limit downside. You can stop copying at any time." This keeps the actionable safety message prominent while satisfying compliance requirements in an accessible but non-prominent location.

**Safety auto-set at 50%** (canonical default per C7.1, aligned with Bitget/Bybit competitor benchmarks). MVP: not adjustable in D3. User can adjust post-copy via Manage screen. Safety limit line in Step 2: "Safety limit: 50% -- auto-pauses if losses reach ${safety_amount}". Projection recalculates from ARX-PREFS.safety_limit_default (or per-leader override).

**"Averages [N] trades/week":** Per-trader computed from `COMPUTE: trade_count / weeks_active`.

**Success flow:** Checkbox checked → [Start Copying] active → tap → disabled + "Starting..." + spinner → sign tx → broadcast → checkmark draw animation (400ms) → toast "Now copying @{handle}" → navigate to Feed tab (Copying state).

**Copy timing rule:** Copy starts from the NEXT new trade after confirmation timestamp. The leader's open positions at the time of copy start are NOT inherited. This prevents the race condition where a leader trades during the D3 setup flow.

**Leader activity context (Step 2):** If leader has open positions at render time, show info line: "This trader currently has [N] open positions. These won't be copied — only new trades going forward."

### 5.3 D3 Field Sources

| Field             | Source                                             | Notes                          |
| ----------------- | -------------------------------------------------- | ------------------------------ |
| Available balance | `API: get_user_state` → withdrawable               | Updated on mount               |
| Slider range      | Min: $50, Max: available balance                   | Haptic at quick pick values    |
| Quick picks       | [$100] [$500] [$1K] [$2.5K]                        | Grey out if > available        |
| Typical month     | `COMPUTE: median(monthly_returns) × amount`        | From `get_user_fills` last 90d |
| Best month        | `COMPUTE: max(monthly_returns) × amount`           | From `get_user_fills` last 90d |
| Worst month       | `COMPUTE: min(monthly_returns) × amount`           | From `get_user_fills` last 90d |
| Safety limit      | `COMPUTE: amount × 0.50`                           | 50% canonical default (C7.1)   |
| C6.5 suggestion   | `COMPUTE: C6.5 kelly × regime × risk × confidence` | Capped at 25% of account       |
| Fee estimate      | `COMPUTE: avg_trade_size × 0.0002 × avg_trades/wk` | Builder code rate              |
| Avg trades/week   | `COMPUTE: trade_count / weeks_active`              | From `get_user_fills`          |
| Step 2 summary    | Derived from Step 1 selections                     | No additional API calls        |

### 5.4 D3 Interactions

| Element         | Tap  | Result                                                                                                     |
| --------------- | ---- | ---------------------------------------------------------------------------------------------------------- |
| ← Back (Step 1) | Tap  | Return to D2 Profile                                                                                       |
| ← Back (Step 2) | Tap  | Return to Step 1, values preserved                                                                         |
| Slider          | Drag | Update amount hero + projections in real-time                                                              |
| Quick pick chip | Tap  | Set slider to value + haptic feedback                                                                      |
| [Continue >]    | Tap  | Validate amount ≥ $50 → slide transition to Step 2                                                         |
| [Start Copying] | Tap  | Disable → "Starting..." + spinner → sign tx → broadcast → checkmark (400ms) → toast → Feed (Copying state) |
| [Deposit >]     | Tap  | → Deposit flow (when $0 balance)                                                                           |
| Checkbox        | Tap  | Toggle. [Start Copying] enabled only when checked.                                                         |

### 5.5 D3 States

| State            | Behavior                                                                         |
| ---------------- | -------------------------------------------------------------------------------- |
| Loading          | Skeleton: amount hero + slider placeholder + 2 projection cards shimmer. ~300ms. |
| Submitting       | [Start Copying] disabled, text → "Starting...", spinner icon. Duration 1-3s.     |
| Success          | Checkmark draw animation (400ms) → toast → Feed tab                              |
| Error (network)  | "Your money wasn't moved." + [Retry]. Amount and settings preserved.             |
| Error (capacity) | "This trader just filled up." + [Find Another >] → Traders tab                   |

### 5.6 D3 Edge Cases

| Scenario                     | Behavior                                         |
| ---------------------------- | ------------------------------------------------ |
| $0 balance                   | Slider disabled. "Fund first" + [Deposit >]      |
| Balance < $50                | "Minimum $50 to copy."                           |
| Network error                | "Your money wasn't moved." + [Retry]             |
| Leader fills up during setup | "This trader just filled up." + [Find Another >] |
| App backgrounded             | State persists 30min, then resets                |
| Slider > 25% of equity       | Amber warning: "Consider starting smaller."      |

---

## 6. Manage (Sub-Screen)

### 6.1 Design Intent

Single screen to monitor and control all copy relationships. Aggregated safety bar at top answers "am I safe?" before showing per-leader details. Danger zone at bottom makes destructive actions hard to trigger accidentally.

### 6.2 Layout

```
+-------------------------------------+
| ← Manage                            |
+-------------------------------------+
| Allocated    P&L          Today     |
| $2,500       +$347        +$47     |
+-------------------------------------+
| Your safety net                     |
| Total limits: $500 across 3 copies  |
| Used: $152 (30%)  All within limits |
| [==========----------]  30%        |
|  CK:-$52  Wh:-$60  Ac:-$40         |
+-------------------------------------+
| YOUR TRADERS (3)                    |
| +-----------------------------------+
| | CryptoKing        $1,000 → +$210 |
| | +$22 today · Your return +8.2%   |
| | Wins 71% in trending (current)    |  <- Regime context (S7 need #3)
| |            [Pause]  [Manage Copy] |
| +-----------------------------------+
| +-----------------------------------+
| | Whale.eth         $1,000 → +$98  |
| | +$14 today · Your return +4.1%   |
| |            [Pause]  [Manage Copy] |
| +-----------------------------------+
| +-----------------------------------+
| | 0xAce              $500 → +$39   |
| | +$10 today · Your return +3.8%   |
| |            [Pause]  [Manage Copy] |
| +-----------------------------------+
+-------------------------------------+
| WATCHING (2)                        |
| 0xSteady  +3.1% (7d)  Updated 18h ago  [Copy →]  |
| DeFiSage  -0.8% (7d)  Updated 6h ago   [Unwatch] |
+-------------------------------------+
| [+ Find More Traders →]            |
+-------------------------------------+
+-------------------------------------+
| ─── DANGER ZONE ────────────────── |
| [Pause All]    [Stop All Copies]   |
+-------------------------------------+
```

### 6.3 Safety Bar

Aggregated: `sum(losses) / sum(safety_limits)` across ALL active copies. Per-leader mini-labels show each leader's contribution.

**Safety threshold alignment (Feed <-> Manage must match):**

Zones scale to user's configured limit (default 50%):

- Green: 0 to limit x 0.5 (e.g., 0-25% for 50% limit)
- Amber: limit x 0.5 to limit x 0.8 (e.g., 25-40%)
- Red: limit x 0.8 to limit (e.g., 40-50%)
- Triggered: >= limit

**Frontend vs backend zone mapping:** Frontend visual zones derive from UX thresholds. Backend C7.1 safety_zone uses its own tiers:

- C7.1 "Healthy" (0-60%) -> UX Green (0-50%)
- C7.1 "Watch" (60-80%) -> UX Amber (50-80%)
- C7.1 "Danger" (80-100%) -> UX Red (80-100%)

Single source of truth — these thresholds:

| Range   | Color           | Token              | Status Text       |
| ------- | --------------- | ------------------ | ----------------- |
| 0-50%   | Green (healthy) | `--color-positive` | All within limits |
| 50-80%  | Amber (watch)   | `--color-warning`  | Watch             |
| 80-100% | Red (danger)    | `--color-negative` | Danger            |

Safety bar styling: Track 4px height, 8px radius. Fill animates 400ms easeInOut. Per-leader mini labels below: 9px mono. At 6+ leaders, show top 4 by loss magnitude + "+N more" (9px, `--color-text-tertiary`).

### 6.4 Per-Leader Card

Each copy relationship shown as a card:

| Field           | Source                                             | Notes                                                                                                                |
| --------------- | -------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Tier badge      | `DB: C3.8 performance_tier`                        | E/P/V/R letter badge right of name, same styling as D1 card                                                          |
| Leader name     | `DB: display_name`                                 | 14px bold                                                                                                            |
| Allocated       | `DB: copy.allocated_amount`                        | 11px mono                                                                                                            |
| Unrealized P&L  | `COMPUTE: copy current value - allocated`          | 14px bold mono, green/orange                                                                                         |
| Today P&L       | `COMPUTE: sum(copy_fill.closedPnl) for today`      | 11px, green/orange. Source: [ARX-COPY] not leader's [HL-PORTFOLIO]. Freshness: live (same tier as copy fill stream). |
| Your return %   | `COMPUTE: (current - allocated) / allocated × 100` | 11px. USER's return on allocation, not leader's aggregate follower return.                                           |
| Win rate        | `COMPUTE: overall_win_rate`                        | "Wins 71% overall" -- MVP: "overall" not regime-specific until C5.6 ships                                            |
| Regime + sizing | `COMPUTE: current regime + copy sizing multiplier` | "Current: Trending 12d -- copies full size". Tap → bottom sheet explaining C5.1 table.                               |
| Freshness       | `COMPUTE: last batch update timestamp`             | "Updated 2h ago" in 9px `--color-text-tertiary` for batch-daily data. Live data (P&L, unrealized) has no indicator.  |

**Card left border colors (per-leader safety status):**

- <50% of safety limit: no border
- 50-80%: 2px `--color-warning`
- > 80%: 2px `--color-negative`

### 6.5 Management Actions

**[Pause] — Two-phase tap:**

1. First tap → button enters "confirming" state for 2 seconds: text changes to "Tap again to pause" (amber).
2. Second tap within 2s → executes pause. No second tap → reverts to [Pause].
3. Pauses new copy trades from this leader. Positions stay open.
4. Toast: "Paused @{handle} — open positions still active."

**Resume after pause — Two-phase tap (matches Pause pattern):**

1. First tap → button enters "confirming" state for 2 seconds: text changes to "Resume copying @{handle}? {N} trades were made during your pause and won't be copied." (amber).
2. Second tap within 2s → executes resume. No second tap → reverts to [Resume].
3. Resume only applies to NEW trades going forward. Trades the leader made during the pause are NOT retroactively copied. The copy may diverge from the leader's portfolio.
4. Toast: "Resumed @{handle} — copying new trades."

**Paused copy card appearance:**

- "PAUSED" badge (11px, `--color-warning`, uppercase) replacing the regime context line
- P&L values shift to `--color-neutral` (greyed)
- [Pause] becomes [Resume] (same size, outline style, `--color-primary`)
- All other card fields remain visible (allocated, P&L, today) so S7 can monitor open positions

**[Manage Copy] → Bottom sheet:**

| Option         | Action                                     | Style                |
| -------------- | ------------------------------------------ | -------------------- |
| Add Funds      | Increase allocation → amount picker        | Primary outline      |
| View Profile   | Navigate to D2                             | Default outline      |
| Stop This Copy | Confirm dialog → close positions at market | Red text, 500 weight |

**[Stop This Copy] confirm:** "Stop copying @{handle}? This will close all open positions at market. You keep proceeds."

### 6.6 Danger Zone

Below 1px `#FF6B7F` divider. Red outline buttons.

**[Pause All]:** Confirm "Pause all copies?" → pause all + toast "All copies paused."

**[Stop All Copies]:** Confirm "Stop all copies? Closes all positions at market. You keep proceeds." → stop all → navigate to Traders tab (Browsing state).

**[Pause] vs [Stop]:**

| Action | Effect                        | Positions             | Reversible? |
| ------ | ----------------------------- | --------------------- | ----------- |
| Pause  | No new trades copied          | Open positions remain | Yes         |
| Stop   | Close all positions, end copy | All closed at market  | No          |

### 6.7 Manage Field Sources

| Field                | Source                                      | Notes                       |
| -------------------- | ------------------------------------------- | --------------------------- |
| Allocated (total)    | `COMPUTE: sum(copy.allocated) all active`   | Header stat                 |
| P&L (total)          | `COMPUTE: sum(unrealizedPnl + realizedPnl)` | Header stat                 |
| Today (total)        | `COMPUTE: sum(copy.todayPnl)`               | Header stat, green/orange   |
| Safety bar %         | `COMPUTE: sum(losses) / sum(safety_limits)` | Aggregate across all copies |
| Per-leader mini loss | `COMPUTE: per-copy current loss`            | Inline in safety bar        |
| Watching return      | `COMPUTE: 7d pnl delta`                     | Watching section            |
| [Copy →] / [Unwatch] | —                                           | Watching section actions    |

### 6.8 Manage Interactions

| Element                       | Tap     | Result                                                          |
| ----------------------------- | ------- | --------------------------------------------------------------- |
| ← Manage (back)               | Tap     | Return to previous screen (Feed or Traders)                     |
| Safety bar                    | —       | Display only (visual indicator)                                 |
| Per-leader mini label         | Tap     | Scroll to that leader's card                                    |
| Leader card (anywhere)        | Tap     | → D2 Profile                                                    |
| [Pause] per card              | Tap     | Two-phase: "Tap again to pause" → execute pause + toast         |
| [Resume] per card             | Tap     | Two-phase: "Resume? {N} trades missed" → execute resume + toast |
| [Manage Copy] per card        | Tap     | → Bottom sheet: Add Funds, View Profile, Stop This Copy         |
| Add Funds (bottom sheet)      | Tap     | → Amount picker overlay (slider, same as D3 Step 1)             |
| View Profile (bottom sheet)   | Tap     | → D2 Profile                                                    |
| Stop This Copy (bottom sheet) | Tap     | Confirm → close positions at market → toast + remove card       |
| [Pause All]                   | Tap     | Confirm "Pause all copies?" → pause all + toast                 |
| [Stop All Copies]             | Tap     | Confirm → stop all → navigate to Traders tab (Browsing state)   |
| [+ Find More Traders →]       | Tap     | → Traders tab (Discover section)                                |
| Watching [Copy →]             | Tap     | → D3 Copy Setup for this leader                                 |
| Watching [Unwatch]            | Tap     | Remove from watching + toast "Removed @{handle}"                |
| Pull down                     | Gesture | Refresh all data                                                |

### 6.9 Manage States

| State                         | Behavior                                                                               |
| ----------------------------- | -------------------------------------------------------------------------------------- |
| Loading                       | Skeleton: header stats shimmer + 3 card placeholders + safety bar placeholder. ~400ms. |
| Empty (0 copies, has watches) | "No active copies." + WATCHING section visible + [+ Find More Traders →]               |
| Empty (0 copies, 0 watches)   | "No active copies or watches." + [Find a Trader →] → Traders tab                       |
| Error                         | "Couldn't load copy data." + [Try Again] + cached values if available                  |
| Offline                       | Amber banner "Offline — showing last-known data" + cached values + timestamp           |
| Last copy stopped             | After stop animation, navigate to Traders tab. App state → Browsing.                   |

---

## 7. Wallets Data Requirements

### 7.1 Hyperliquid API Objects Per Wallet

| Object       | API Call                        | Key Fields                                         |
| ------------ | ------------------------------- | -------------------------------------------------- |
| Account      | `get_user_state`                | accountValue, totalMarginUsed, withdrawable        |
| Position     | `get_user_state.assetPositions` | coin, szi, leverage, entryPx, unrealizedPnl, liqPx |
| Fill/Trade   | `get_user_fills`                | coin, dir, px, sz, closedPnl, time, fee            |
| Order        | `get_open_orders`               | coin, side, limitPx, sz, isTpsl, triggerPx         |
| Spot Balance | `get_user_spot_state`           | token, hold, total                                 |
| Equity Curve | `get_portfolio`                 | accountValueHistory (~11 pts), pnlHistory, vlm     |

### 7.2 Computed Metrics (Arx Server)

| Metric            | Computation                                                                          | Source         |
| ----------------- | ------------------------------------------------------------------------------------ | -------------- |
| Win rate          | profitable closes / total closes (excludes < 0.5% of account equity — see Safety §8) | get_user_fills |
| 30d/7d return     | pnl delta / starting value                                                           | get_portfolio  |
| Worst month       | min(monthly returns)                                                                 | get_portfolio  |
| Trade count       | count(opening fills)                                                                 | get_user_fills |
| Avg hold duration | mean(close - open time)                                                              | get_user_fills |
| Avg trades/week   | trade count / weeks active                                                           | get_user_fills |
| Follower earnings | sum(copier PnL)                                                                      | Arx DB         |

### 7.3 Arx DB Entities

| Entity            | Fields                                                                                                                     |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------- |
| CopyRelationship  | user, leader, amount, safety_limit, status, created_at                                                                     |
| WatchRelationship | user, leader, created_at                                                                                                   |
| LeaderProfile     | address, display_name, category, style, risk_profile, primary_assets[], regime_strength{}, avg_leverage, account_size_tier |
| LeaderRationale   | leader, trade_id, text, created_at                                                                                         |
| Notification      | user, type, content, read, created_at                                                                                      |
| DailySnapshot     | leader, date, accountValue, pnl                                                                                            |
| MatchingProfile   | user, style, risk_tolerance, size_range, min_win_rate, min_history, preferred_regime, preferred_assets[], created_at       |
| ArchetypePreset   | name, slug, filter_config{}, display_order                                                                                 |

### 7.4 Filter Data Model

```typescript
interface TraderFilterQuery {
  // Layer 1: Named filter chip (expands to filter params server-side)
  chip?:
    | "all"
    | "conservative"
    | "consistent"
    | "high_balance"
    | "hot_hands"
    | "swing_style"
    | "rising"
    | "established"
    | "carry_traders"
    | "my_matches";

  // Layer 2: Advanced filters
  style?: ("scalper" | "day" | "swing" | "position" | "carry" | "momentum")[];
  risk?: "conservative" | "moderate" | "aggressive" | "degen";
  account_size_min?: number; // USD
  account_size_max?: number;
  win_rate_min?: number; // 0-100
  win_rate_max?: number;
  history_min?: number; // days (30-365)
  history_max?: number;
  regime?: ("trending" | "range_bound" | "all_weather")[];
  assets?: ("btc" | "eth" | "alts" | "multi" | "cross_asset")[];
  avg_leverage_max?: number; // max average leverage (e.g., 3)
  min_trades_7d?: number; // minimum trades in last 7 days
  funding_bias?: "positive" | "negative" | "neutral"; // net funding direction
  avg_hold_min?: string; // minimum average hold time (e.g., "7d")

  // Sort + pagination
  sort: "follower_return" | "win_rate" | "total_earned" | "newest";
  period: "7d" | "30d" | "90d";
  offset: number;
  limit: number; // default 20
}
```

**Chip → filter expansion** (server-side):

| Chip            | Expands To                                                                                             |
| --------------- | ------------------------------------------------------------------------------------------------------ |
| `all`           | No filter — all ranked traders                                                                         |
| `conservative`  | `risk: conservative, avg_leverage_max: 3`                                                              |
| `consistent`    | `win_rate_min: 60, history_min: 30`                                                                    |
| `high_balance`  | `account_size_min: top_10_pct, win_rate_min: 55, history_min: 180`                                     |
| `hot_hands`     | `sort: follower_return, period: 7d, min_trades_7d: 5`                                                  |
| `swing_style`   | `style: [swing], win_rate_min: 60, history_min: 90`                                                    |
| `rising`        | `history_max: 180, follower_count_max: 100`                                                            |
| `established`   | `history_min: 180, history_max: 730, min_trades: 200, follower_count_min: 50, follower_count_max: 500` |
| `carry_traders` | `style: [carry, position], funding_bias: positive, avg_hold_min: 7d`                                   |
| `my_matches`    | `matching_profile_id: user.matching_profile.id`                                                        |

---

## 8. Wallets Error States

Error states specific to the Wallets screens. For shared error states (API outage, offline, stale data), see parent spec `Arx_4-1-1-4` §16.

| #   | Scenario                                                     | Screen      | Behavior                                                                                                                                                                                                   |
| --- | ------------------------------------------------------------ | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Before funding                                               | D3          | Browse OK. [Copy] → "Fund first" + [Deposit >]                                                                                                                                                             |
| 2   | Leader at capacity                                           | D2          | [Full — Join Waitlist]. MVP: toast + auto-watch.                                                                                                                                                           |
| 3   | Leader inactive 30d                                          | D2          | Grey badge, "Inactive" warning text                                                                                                                                                                        |
| 4   | All copies paused                                            | Manage      | Still Copying state, "$0 active"                                                                                                                                                                           |
| 5   | Zero filter matches                                          | D1          | "No match" + [Broaden Filters] + [Browse All]                                                                                                                                                              |
| 6   | Network error D3                                             | D3          | "Your money wasn't moved." + [Retry]                                                                                                                                                                       |
| 7   | Leader deleted mid-copy                                      | Feed/Manage | Server auto-closes positions at market. Feed card alert: "@{handle} is no longer available. Positions are being closed." Manage card: "CLOSING" badge (amber). After settlement: card fades out, archived. |
| 8   | $0 balance                                                   | D3          | Slider disabled + [Deposit >]                                                                                                                                                                              |
| 9   | Safety hit                                                   | Feed/Manage | Auto-pause (server-side). Feed hero → "Safety activated" (Red). Manage card: PAUSED badge + [Resume].                                                                                                      |
| 10  | Phone off during crash                                       | —           | Server-side safety fires anyway                                                                                                                                                                            |
| 11  | App backgrounded in D3                                       | D3          | State persists 30min, then resets                                                                                                                                                                          |
| 12  | Last copy stopped                                            | Manage      | Revert to Browsing state → Traders tab                                                                                                                                                                     |
| 13  | Leader style drift                                           | Feed        | When leverage/size/frequency exceeds 2× 90d average: alert card. If leverage >3× average: auto-pause + toast.                                                                                              |
| 14  | Leader inactive while copying                                | Feed/Manage | No trades 30+ days: alert card. Leader dot dim. Manage shows "Last trade: 45d ago." Hero includes idle count.                                                                                              |
| 15  | Batch safety (2+ simultaneous)                               | Feed        | Aggregate into single UX. One toast, one card, plural hero text.                                                                                                                                           |
| 16  | Gap-through safety                                           | Feed        | Safety jumps <50% to >80%: hero adds "Safety activated after rapid market move." Feed card: "Market moved faster than usual."                                                                              |
| 17  | Batch safety — multiple copies trigger safety simultaneously | Feed/Manage | Toast: "Safety limits triggered on {N} copies — all paused for review". Manage: all affected cards show PAUSED badge simultaneously. Hero: aggregate safety status.                                        |
| 18  | Gap-through safety — price gaps past safety threshold        | Feed/Manage | Toast: "Market gap detected — {leader} copy paused at -{amount}". Feed card explains gap. Manage card: PAUSED badge + actual loss amount (may exceed safety limit due to gap).                             |
| 19  | Max copies reached — user at copy limit                      | D2/D3       | Toast: "Copy limit reached. Stop an existing copy to start a new one." [Copy Trader >] disabled on D2. D3 blocked with message + [Manage Copies →] link.                                                   |

---

## 9. Wallets Animations

| Animation                       | Duration                      | Easing                         | Haptic                |
| ------------------------------- | ----------------------------- | ------------------------------ | --------------------- |
| Screen entry (D1/D2/D3/Manage)  | 300ms                         | ease-out                       | —                     |
| Card stagger-in                 | 80ms/card, 300ms total        | easeOut                        | —                     |
| Section collapse/expand         | 200ms                         | ease-in-out                    | —                     |
| Pull-to-refresh                 | 800ms/rot                     | linear                         | Light on release      |
| Safety bar fill                 | 400ms                         | easeInOut                      | Medium on zone change |
| Copy success (D3)               | 600ms                         | spring                         | Success               |
| Checkmark draw (D3)             | 400ms                         | ease-out                       | Success               |
| Slider drag                     | continuous                    | spring                         | Medium at quick picks |
| Hero stat roll-up               | 400ms                         | ease-out                       | —                     |
| Equity curve draw               | 800ms                         | linear (L-to-R)                | —                     |
| Stat grid stagger               | 50ms/cell                     | ease-out                       | —                     |
| Toast                           | Up 300ms, hold 2s, fade 200ms | ease-out                       | —                     |
| Skeleton shimmer                | 1500ms                        | ease-in-out infinite           | —                     |
| D3 Step 1→2 transition          | 300ms                         | ease-out (slide left)          | Light                 |
| D3 Step 2→1 (back)              | 250ms                         | ease-in (slide right)          | —                     |
| D1b Cold Start overlay          | 400ms                         | ease-out (scale 0.95→1 + fade) | —                     |
| Advanced Filter panel open      | 300ms                         | ease-out (slide up)            | —                     |
| Advanced Filter panel close (✕) | 250ms                         | ease-in (slide down)           | —                     |
| Advanced Filter close (Apply)   | 150ms                         | ease-out (fade)                | Light                 |
| P&L roll (Manage)               | 200ms                         | easeInOut                      | —                     |
| Pause confirm state             | 2000ms                        | — (timeout)                    | Light (first tap)     |

Respects `prefers-reduced-motion`: all animations → instant transition.

---

## 10. Wallets Components

Components specific to Wallets screens. For shared components (Safety Bar, Sticky Footer CTA, Alert Card), see parent spec `Arx_4-1-1-4` §13.

### 10.1 Trader Card (Discovery)

Padding 16px. Metric row gap 2px. Card gap 8px. Bg: `--color-surface`. Border: 1px `--color-border`. Radius: 10px. Handle: 14px bold. Metric headers: 9px `--color-text-tertiary`. Metric values: 14px bold mono. [View Profile]: 44pt tap target, outline `--color-primary`.

### 10.2 Named Filter Chip

Single horizontal scroll row. Pill shape, stadium radius (24px). Height 32px. Padding: 8px 16px. Selected: filled `--color-primary`, white text. Unselected: outline `--color-border`, `--color-text-secondary`. Gap: 8px. Match count: 11px `--color-text-tertiary` inline after label. [🎯 My Matches]: includes `--color-data` [Refine →] link.

### 10.3 Advanced Filter Panel

Full-screen overlay. Bg: `--color-bg`. Slide up 300ms ease-out. Header: "Advanced Filters" 20px semi + [✕] 44pt tap. Section headers: 11px semi `--color-text-tertiary`. Chip selectors: same as named filter chips. Sliders: track 4px `--color-border`, thumb 20px `--color-primary`, active track `--color-primary`. Labels: 11px mono. [Apply Filters]: 48px primary CTA. [Reset All]: 14px muted link.

### 10.4 Active Filter Strip

Horizontal scroll below header when advanced filters active. Chip: pill, `--color-surface-elevated`, 11px text + [✕] dismiss. [Clear All]: 11px `--color-text-tertiary`. Height: 36px total.

### 10.5 Overflow & Truncation Rules

| Element                       | Max         | Overflow Behavior                                                                                                       |
| ----------------------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------- |
| Wallet display name           | 18 chars    | `text-overflow: ellipsis`, single line. Full name in tooltip on long press.                                             |
| D3 amount hero                | 10 chars    | Numbers ≥$100K abbreviate: "$124.3K", ≥$1M: "$1.2M". Always mono 28px.                                                  |
| Active Filter Strip           | 4 chips     | Horizontal scroll. First 3 chips + "…+N" chip visible at 390px.                                                         |
| D2 Holdings (positions)       | 5 expanded  | First 5 expanded. Beyond 5: collapsed with "Show N more" link (14px, `--color-data`).                                   |
| D2 Recent Trades              | 5 shown     | "Show earlier trades" link below 5th.                                                                                   |
| Traders pagination            | 20 per load | Infinite scroll. Loading spinner at bottom. On filter change: scroll to top, fresh fetch. End: "No more traders match." |
| Named filter chips            | —           | Horizontal scroll. At 375px, ensure ≥2.5 chips visible (peek effect communicates scrollability).                        |
| Cold Start cards              | 6 fixed     | Vertical scroll within overlay. No pagination.                                                                          |
| D3 projection text            | —           | Wrap at card width. No truncation.                                                                                      |
| Manage per-leader mini labels | 4 shown     | At 6+ leaders: top 4 by loss magnitude + "+N more" (9px, `--color-text-tertiary`).                                      |

---

## 11. Phase Boundary — MVP vs P2

### 11.1 MVP (This Spec)

Everything specified above is MVP unless listed in §11.2.

- ✅ D1 Traders tab (Browsing + Copying layouts)
- ✅ 2-layer filter architecture (10 named filter chips + advanced panel)
- ✅ 9 named filter chips (excluding [🎯 My Matches] which requires wizard)
- ✅ 10-dimension advanced filter panel
- ✅ Lucid AI search (client-side keyword mapping)
- ✅ Trader card with 3 metrics + time toggle
- ✅ Sort controls (4 options)
- ✅ Search by name or address
- ✅ D1b Cold Start overlay (6 curated traders)
- ✅ D2 Profile (Trust + Live Wallet + Action)
- ✅ D3 Copy Setup (2-step: How Much → Confirm)
- ✅ Safety limit auto-set at 50% (canonical default, not adjustable in D3)
- ✅ Performance tier badges (E/P/V/R) on D1 card + Manage card
- ✅ Risk profile labels on D1 card
- ✅ C6.5 allocation recommendation in D3 Step 1
- ✅ Freshness indicators ("Updated Xh ago") on batch-daily data
- ✅ Liquidation price, TP/SL, funding on D2 Holdings (expanded view)
- ✅ Exposure/concentration labels on D2 Holdings header
- ✅ Manage sub-screen (safety bar + per-leader controls + regime sizing)
- ✅ Watch and Copy relationships
- ✅ Pause/Resume/Stop per-leader and bulk
- ✅ Regime context on Manage per-leader cards
- ✅ 19 error states handled

### 11.2 P2 (Deferred)

| Feature                                           | Rationale for Deferral                                                  |
| ------------------------------------------------- | ----------------------------------------------------------------------- |
| S7 Matching Wizard + [🎯 My Matches] chip         | High value (40% cite as hook) but complex. MVP uses named filter chips. |
| Watch→Copy nudge system (5 triggers)              | Behavioral optimization — need baseline data first.                     |
| Push notifications (10 triggers + loss callbacks) | Requires notification infrastructure. MVP: in-app only.                 |
| Correlation warning + position overlap            | Requires multi-leader portfolio analysis backend.                       |
| D3 pre-fill for 2nd+ leader                       | Nice UX, not blocking.                                                  |
| 7d divergence line on trader cards                | Requires fill-based equity reconstruction.                              |
| Per-trader notification toggle on Watch           | Notifications not in MVP.                                               |
| Leverage explainer on positions                   | Educational content, not blocking.                                      |
| Adjustable safety limit in D3 (10%-50%)           | Fixed 50% sufficient for MVP. Adjustment via Manage P2.                 |
| Lucid AI server-side NL inference                 | Client-side keyword mapping sufficient for MVP.                         |
| Waitlist registration                             | MVP fallback: toast + auto-watch.                                       |
| Per-trader notification toggle                    | Notifications not in MVP.                                               |

### 11.3 MVP Fallbacks

| Full Feature               | MVP Fallback                                                                                                   |
| -------------------------- | -------------------------------------------------------------------------------------------------------------- |
| Follower earnings on cards | Trader's own return. Label: "Returned" (NOT "Earned"). Long-press tooltip: "Follower earnings available soon." |
| Lucid AI inference         | Client-side keyword→filter mapping (no LLM)                                                                    |
| Real-time feed events      | Polling every 30s + pull-to-refresh                                                                            |
| Leader rationale text      | Hidden row if no rationale in DB                                                                               |
| Signal strength score      | Computed from available P1-P3 signals only (P4/P5 deferred)                                                    |
| [Full — Join Waitlist]     | Toast + auto-add to Watch list                                                                                 |

---

## 12. Regime Color Palette (Design System v5.7)

Canonical regime colors used across D1 filter chips, D2 regime context, D3 regime banner, and Manage regime + sizing labels.

| State       | Color       | Hex     | Usage                                                                             |
| ----------- | ----------- | ------- | --------------------------------------------------------------------------------- |
| TRENDING    | Emerald     | #10B981 | Regime indicators, D3 banner bg tint                                              |
| RANGE_BOUND | Blue        | #3B82F6 | Regime indicators                                                                 |
| COMPRESSION | Teal        | #0D9488 | Regime indicators (NOT red -- reserved for losses)                                |
| CRISIS      | Deep Orange | #EA580C | Regime indicators (NOT red -- orange family for open)                             |
| TRANSITION  | Amber       | #F59E0B | Regime indicators. S7-facing label "Shifting" renders in `--color-text-tertiary`. |

**Note:** CRISIS uses Deep Orange #EA580C, not red. Red is reserved exclusively for realized losses (closed trades). This aligns with the "orange = still open/recoverable, red = done/lost" design principle from section 4.5.

---

## 13. Changelog

| Date       | Change                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-03-30 | v2 design merge: Performance tier badges (E/P/V/R) on D1 + Manage cards. Risk profile labels on D1 card. C6.5 allocation recommendation in D3. Safety limit canonical default 50% (was 20%). Liq price/TP/SL/funding on D2 Holdings expanded view. Exposure + concentration labels on D2 Holdings header. Dual-metric D2 hero stat (total $ + median %). Freshness indicators on batch data. Funding Bias computation. Regime color palette table (v5.7). Equity curve attribution note. Safety bar zones configurable per user limit. Promoted from `outputs/think/design/radar-traders-design-v2.md`. |
| 2026-03-29 | Design audit fixes (W-1 through W-12): merge filter rows into single chip row, sync TS interface with UI, replace duplicate grid stat, reframe projection as protection, add missing footer states, improve compliance copy, reorder D2 sections (trades first), hero metric visual weight, fix Manage link in Browsing state, add Resume confirmation, fix capacity label ambiguity, add cold start capacity staleness rule.                                                                                                                                                                           |
| 2026-03-28 | Initial creation. Merged D1-D3/Manage content from v1+v2 canonical specs into self-contained sub-spec.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
