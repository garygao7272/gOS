# BUILD: C1-R0 — Home + Feed (Merged)

<!--
  Sources: Arx_4-1-1-2 §C1, Arx_3-2-7 §US-SHARED-HOME-01, §US-SHARED-HOME-02
  IA change: R0 Feed migrated into Home tab. C1 portfolio summary is sticky top; R0 feed scrolls below.
-->

## Why
> JTBD-SHARED-01: "What happened since I last checked? Am I going to be okay?"
> Pain: High-frequency daily check-in split across two tabs (Home + Radar) added friction and context switching.
> Persona: Shared (S7 Sarah — capital allocator / S2 Jake — independent trader)

## What the User Does
1. Opens app → sticky C1 portfolio header renders immediately from cache with equity + status dot
2. Sees WYWA card pinned at top of feed (if absent ≥8h) → reads absence summary → taps Dismiss or drills into affected leader
3. Scrolls R0 feed — personalized by A1b intent (S7: earnings + leader moves first; S2: regime + signals first)
4. [S7]: taps Daily Earnings card (Card #9) → copy performance detail / [S2]: taps Regime card (Card #1) → regime deep-dive sheet
5. Taps feed mode toggle [My Feed] / [Discover] to switch between relationship-based and signal-based content
6. Pull-to-refresh → haptic + feed reload

## Feel

- **Target:** Command center — your world at a glance, personalized, alive
- **Density:** S7 medium-low (4 cards visible), S2 medium-high (8 cards, denser data)
- **Reference:** "Robinhood home's calm confidence with Apple News's morning digest intelligence"
- **Temperature:** T0 80% (obsidian bg, chamber cards, starlight text) | T1 15% (regime bar at 40%, sparklines, timestamps) | T2 4% (P&L numbers in gain/loss color) | T3 1% (none on this screen — no Execute button)

### Motion Choreography (on-load)

| Order | Element | Animation | Delay | Duration | Easing |
|-------|---------|-----------|-------|----------|--------|
| 1 | Regime bar | instant render | 0ms | 0ms | — |
| 2 | Portfolio header | fade-in from cache | 0ms | 100ms | ease-out |
| 3 | Status dot | appear + pulse begins | 100ms | 200ms | ease-out |
| 4 | Feed mode toggle | fade-in | 150ms | 150ms | ease-out |
| 5 | WYWA card (if shown) | fade-up | 200ms | 200ms | spring |
| 6 | Feed cards | fade-up stagger | 250ms | 200ms each, 50ms stagger | spring |

### Skeleton (loading state)

- Header: shimmer rectangle fill-w h=80px (equity placeholder 120x32px + pill 80x24px)
- Feed cards: 3x shimmer cards, each 358x120px, gap=12px
- Card skeleton: icon-circle 40px (left) + 2 text lines (right, 60% and 40% width)
- Shimmer: left-to-right, 1.5s, rgba(255,255,255,0.04) → rgba(255,255,255,0.08)

### Haptics

| Trigger | Haptic | iOS API |
|---------|--------|---------|
| Pull-to-refresh | impact medium | UIImpactFeedbackGenerator(.medium) |
| Filter chip tap | impact light | UIImpactFeedbackGenerator(.light) |
| WYWA dismiss | — | none |
| Card tap (navigate) | — | none |

---

## Layout (Stitch-ready)
```
[viewport: 390x844, safe-area: top 59px, bottom 34px]

REGIME BAR: row, fill-w, h=4px, regime-color bg (see DESIGN.md §1.6)

STICKY HEADER: column, fill-w, hug-h, glass Level 2, px=16px, py=12px
  ├── Label: "PORTFOLIO" (Caption, --color-text-secondary)
  ├── row: fill-w, gap=8px, align=center
  │    ├── Equity: "$12,450.00" (Hero mono, --color-text-primary)
  │    └── Daily P&L: "+$487.00 (+2.3%)" (Data, --color-gain)
  ├── row: fill-w, gap=8px, align=center
  │    ├── Status dot: 10px, gain/amber/loss by risk state (pulsing glow)
  │    ├── Regime pill: "● Trending" (Body-sm, regime state color — NOT --color-primary)
  │    └── Position count: "3 open" (Body, --color-text-secondary), align=right

FEED MODE TOGGLE: row, fill-w, hug-h, mx=16px, mt=12px
  ├── [My Feed]: selected, bg rgba(179,141,244,0.2), text --color-primary
  └── [Discover]: unselected, text --color-text-secondary
  (hidden when user has no relationships J0/J1)

FILTER CHIPS: row, scroll-x, hug-h, h=32px, gap=8px, px=16px
  └── [All] [Market] [Consensus] [Moves] [My Copies]

SECTION HEADER: row, fill-w, hug-h, px=16px, mt=16px
  └── "TODAY'S INTELLIGENCE" (Caption, 0.1em spacing, line extending right)

SCROLLABLE CONTENT: column, fill-w, gap=12px, px=16px, bg=--color-bg
  ├── WYWA CARD (pinned, conditional: absence ≥8h, accent-border left 3px #10B981)
  │   ├── Icon: lucide:check-circle in 40px circle bg rgba(16,185,129,0.12)
  │   ├── Header: "WHILE YOU WERE AWAY" (Caption) + "8h" (Label, right)
  │   ├── S7: "All safe" (Subtitle, --color-gain) + "Earned +$847 across 4 leaders" (Body)
  │   ├── S2: regime change badge + transition arrow + signal count
  │   └── CTAs: [Dismiss] (--color-text-secondary) | [View Leaders →] (--color-primary)
  │
  ├── FEED CARDS (each: glass card, 16px radius, icon circle + badge + content)
  │   Card types: #1 Regime, #3 Consensus, #5 Smart Money, #7 Divergence,
  │               #8a Trader Move, #9 Earnings, #10 Recovery
  │   Icon + embellishment per card: see DESIGN.md §3.2, §4.1
  │
  └── EMPTY STATE (J0/J1)
      └── Discover mode CTA: "Follow leaders to see your feed" + [Explore Traders →]

FOOTER: Tab bar — trade-button = elevated-circle (see DESIGN.md §3.1)
```

## Data
| Element | Source | Computation |
|---------|--------|-------------|
| Equity + daily P&L | Portfolio API | `totalEq`, `dailyPnl`, `pctChange24h` |
| Status dot | Position API + Copy API | `positionsAtRisk > 0` → red; `leadersAtRisk > 0` → red; else green |
| Regime pill | Regime API | `regime_state`, `regime_human_label` |
| WYWA: `last_foreground_at` | Arx client local storage | Exact timestamp |
| WYWA: `copy_pnl_delta` | Arx DB | SUM(copy P&L) since `last_foreground_at`, <5s freshness |
| WYWA: `safety_status` | Arx DB | Per-leader stop-loss consumption, <5s freshness |
| WYWA: `regime_changes` | Arx Server | Regime state transitions since last visit, 1-min tier |
| Feed cards | Arx Signal API | Personalized by A1b intent; ranked by segment weight |
| **— Safety System —** | | |
| Safety Bar (stop loss %) | [ARX-COPY] copy_equity_tracking | C7.1: (starting_allocation - current_copy_equity) / per_leader_protection × 100. Color zones: 0–60% green, 60–80% amber, 80–100% red |
| Recovery Card | [ARX-COPY] safety_events | Triggered when safety limit hit. Shows: leader handle, amount returned, [Resume] / [Stop & Return Capital] CTAs |
| Resume Cooldown Timer | [ARX-COPY] safety_events | 4-hour countdown after resume. Prevents re-trigger loop. "Safety resumes in 3h 42m" |
| Regime Mismatch Warning | [ARX-REGIME] C5.1 + [ARX-COPY] | Fires when copied leader's per-regime win rate < 55% in current regime. "@Pro wins only 52% in ranging" |
| Funding Alert | [HL-INFO] funding_rate + [ARX-COPY] | Fires when annualized funding > 50% on assets held by copied leaders. Shows "$X/day per $1K at stake" |
| Correlation Alert | [ARX-COMPUTE] | Fires when 2+ copied leaders both hold same asset. "2 leaders both long BTC — combined $4,200" |
| **— Feed Card Data —** | | |
| Regime Shift Card (#1) | [ARX-REGIME] C5.1 | Fires on regime transition. Shows: asset, old regime → new regime, confidence score, what it means for copied leaders |
| Leader Consensus Card (#3) | [ARX-COPY] + [HL-STATE] | "3 of 4 leaders you copy are long BTC" with combined dollar exposure and avg entry |
| Smart Money Signal (#5) | [ARX-COMPUTE] cluster_consensus | "72% of Elite+Proven traders are long BTC" with avg entry and distance to liquidation zone |
| Trader Move Card (#8a) | [HL-FILLS] get_user_fills (leader) | Real-time card: leader opened/closed position. What, at what price, win rate, copy P&L generated |
| Weekly Rollup (#12) | [ARX-COPY] + [ARX-REGIME] | Monday summary: weekly P&L, per-leader stats, dominant regime, all-time cumulative |
| Watch Nudge | [ARX-COPY] watch_relationships | After watching 3+ days with positive returns: "You would have earned +$847 since watching" |
| Margin Ratio (portfolio) | [HL-STATE] get_user_state | C1.4: committed_margin / total_equity. Shown in portfolio header |

## States
- **Empty (J0/J1):** No WYWA card. Feed shows Discover mode. Onboarding CTA instead of feed cards.
- **Loading (cold start):** Shimmer skeleton on C1 header + 3 card placeholders. Target: <2s feed load.
- **Error (network):** Cached C1 renders. Feed shows "Last updated X min ago" + [Retry].
- **Populated (S7 active copies):** WYWA (if ≥8h) → Daily Earnings card first → leader move cards.
- **Populated (S2):** WYWA (if ≥8h) → Regime bar context card → Smart Money Signal cards.
- **All copies paused:** C1 shows "Paused" status dot; feed shows recovery guidance cards (#10) pinned top.
- **50+ unread:** Feed caps at 50; "See more" pagination. No infinite scroll.

## Components (from Arx_4-2)
- PortfolioStickyHeader — glass Level 2, holds equity + regime pill + status dot
- WYWACard — pinned feed card, glass material, S7/S2 variant content
- FeedModeToggle — segmented [My Feed] / [Discover], hidden for J0/J1
- FilterChipsRow — horizontal scroll chips, 32px height
- FeedCard — base glass card shell; 12 card type variants (Card #1–#10 + WYWA + graduation C5-NEW)
- RegimePill — colored pill, 44px touch target, taps → regime bottom sheet
- StatusDot — 10px dot, gain/amber/loss color by risk state

## Visual Spec

Fixture: C1-R0 (see Arx_4-1-1-8 §4.1 for all mock data values)
Icons: see DESIGN.md §3.2 (feed card icons) + §3.1 (tab bar)
Embellishments:
  - WYWA: accent-border left 3px #10B981, icon-circle green
  - Daily Earnings (#9): accent-border top 3px --color-gain, icon-circle lime
  - Recovery (#10): accent-border left 3px --color-loss, icon-circle red
  - Divergence (#7): accent-border left 3px --color-warning, icon-circle amber
  - All other cards: icon-circle only (per DESIGN.md §3.2), no accent borders
  - section-header: "TODAY'S INTELLIGENCE" before first feed card
Interactions:
  - RegimePill tap → bottomSheet(regime-detail)
  - FeedCard (leader) tap → navigate(D2-wallet-profile, {leader_id})
  - FeedCard (signal) tap → navigate(C3-asset-detail, {asset})
  - FeedCard (signal) [Trade →] → openTrade({asset, side})
  - WYWA [Dismiss] tap → fadeOut 200ms, suppress until next 8h+ absence
  - card-entry: fade-up 200ms stagger(50ms)
  - pull-to-refresh: haptic medium + spinner + feed reload
Tab bar: trade-button = elevated-circle

## Acceptance (EARS)
- WHEN app opens THE SCREEN SHALL render C1 sticky header from cache within 500ms before feed loads
- WHEN absence ≥8 hours THE SCREEN SHALL pin WYWA card at top of feed below C1 header
- WHEN WYWA is dismissed THE SCREEN SHALL fade it out in 200ms and not reappear until next 8h+ absence
- WHEN user is S7 with active copies THE SCREEN SHALL surface Daily Earnings card (Card #9) within first 3 feed positions
- WHEN user is S2 THE SCREEN SHALL render Regime bar context (Card #1) above first feed card
- WHEN any leader safety is amber/red THE SCREEN SHALL render WYWA in escalated state with --color-loss indicator
- WHEN recovery event occurs THE SCREEN SHALL pin Card #10 above all other feed content
- WHEN feed load fails THE SCREEN SHALL show cached feed with stale indicator, not blank state
- WHEN user has no relationships (J0/J1) THE SCREEN SHALL show Discover feed, not empty state
- WHEN safety_bar exceeds 80% THE SCREEN SHALL show red Safety Bar with pulsing animation
- WHEN a Recovery Card is active THE SCREEN SHALL pin it above all other feed content
- WHEN a Regime Shift occurs THE SCREEN SHALL insert Regime Shift Card at position 0 in feed

## Verify
```bash
npm test -- --grep "C1-R0|home-feed|WYWA"
```

## Navigate
- **From:** App launch (default), tab bar Home tap, any drill-down back navigation
- **To:** Regime bottom sheet (regime pill tap), D2 Leader Profile (leader feed card tap), C3 Asset Detail (signal card [Details →]), Trade tab via `openTrade()` (signal card [Trade →]), D4 Copy Dashboard ([Manage →]), Traders tab (Discover CTA / J0 onboarding CTA)
