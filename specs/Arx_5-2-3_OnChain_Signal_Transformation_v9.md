# Arx — On-Chain Signal Transformation (Story-First)

**Artifact ID:** Arx_5-2-3 (v9)
**Last Updated:** 2026-03-31
**Status:** Active
**Supersedes:** Arx_5-2-3_OnChain_Signal_Transformation_v8.md (retained as editorial reference)
**References:** Personas (`2-1`), Radar Module (`4-1-1-4`), Feed (`4-1-1-4-1`), Wallets (`4-1-1-4-2`), Design System (`4-2`, v5.7)

## How to Use This Spec

- **Product / Design:** Read Part I (personas) + Part II (stories). Each story = user journey + data & signal matrix.
- **QA:** Read Part II steps + edge cases. Pre/post conditions and numbered steps map directly to test scripts. Edge case tables = negative tests.
- **Engineering:** Read Part II + Part III (Feed System). Each story's Data & Signal Matrix lists data sources and freshness. For full formulas and API schemas, see v6.

**Related files:**

| File                                            | What It Contains                                                                              | When to Use                       |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | --------------------------------- |
| `Arx_5-2-3_OnChain_Signal_Transformation_v6.md` | Full pseudocode, API request/response schemas, database schemas, cron schedules, rate budgets | When implementing any computation |
| `Arx_4-1-1-4_Mobile_Radar.md`                   | Radar module screen architecture, navigation, shared design language                          | When building Radar UI            |
| `Arx_4-1-1-4-1_Radar_Feed.md`                   | Feed tab detailed screen spec                                                                 | When building the feed            |
| `Arx_4-1-1-4-2_Radar_Wallets.md`                | Traders/Wallets tab detailed screen spec                                                      | When building the traders tab     |
| `Arx_4-2_Design_System.md`                      | Color tokens, typography, spacing, component library (v5.7)                                   | When making any visual decision   |

---

# TABLE OF CONTENTS

**Part I — Who & Why**

1. [Sarah (S7) — The Capital Allocator](#1-sarah-s7--the-capital-allocator)
2. [Jake (S2) — The Strategic Learner](#2-jake-s2--the-strategic-learner)
3. [Jobs to Be Done](#3-jobs-to-be-done)
4. [Signal Reference](#4-signal-reference) — Trader classification · Track record tiers · Key metrics · Feed system

**Part II — Radar Stories**

| #   | Story                | Persona  | Stage                |
| --- | -------------------- | -------- | -------------------- |
| 1   | Cold Start Discovery | S7 Sarah | Cold Start           |
| 2   | Browsing & Filtering | S7 Sarah | Browsing             |
| 3   | Watching → Copying   | S7 Sarah | Watching → Copying   |
| 4   | Monitoring (My Feed) | S7 Sarah | Actively Copying     |
| 5   | Discover & Explore   | S7 + S2  | Browsing / Pre-Trade |
| 6   | Warning & Recovery   | S7 Sarah | Warning              |
| 7   | Pre-Trade Analysis   | S2 Jake  | Pre-Trade            |

**Part III — Feed System**

| #   | Section                                                  |
| --- | -------------------------------------------------------- |
| 1   | Feed System (Card Index · Freshness Tiers · Build Order) |

---

# PART I — WHO & WHY

---

# 1. Sarah (S7) — The Capital Allocator

Sarah has $10K–$100K in crypto. She doesn't trade herself. She's tried trading, lost money, and recognizes the gap between understanding markets and making money trading. She wants to allocate capital to someone with proven edge.

**What she wants:** Put her money behind a trader with edge. Check in briefly. Sleep at night.

**What she's afraid of:**

- Picking someone who looks good but blows up (survivorship bias, one lucky trade)
- Not knowing when something goes wrong until it's too late
- Getting misled by fake track records or inflated metrics

**What success looks like:** She opens the app, sees green, closes it in 30 seconds. Twice a day. On Mondays she reads a summary. Her money grows at 1–3% per month.

**Her core questions on Radar** (every signal must answer one of these):

| #   | Question                          | When She Asks It                             |
| --- | --------------------------------- | -------------------------------------------- |
| A   | "Can I find someone I trust?"     | First time on Traders tab, or when exploring |
| B   | "Is this person real and good?"   | Comparing traders, reading profiles          |
| C   | "Can I set this up safely?"       | About to copy, setting limits                |
| D   | "Am I okay?"                      | Every app open (30-second check)             |
| E   | "Will the system protect me?"     | When markets move sharply                    |
| F   | "What do I do now?"               | After something went wrong                   |
| G   | "Am I getting smarter?"           | Over time, absorbing context from feed       |
| H   | "What's happening in the market?" | Anytime, as background context               |

---

# 2. Jake (S2) — The Strategic Learner

Jake has $10K–$100K and trades his own ideas. He's T3–T4 skill — competent, not yet consistently profitable. He reads charts, follows macro, has opinions. He also becomes a **leader** on Arx — people copy him, earning him fees.

**What he wants:** Better market intelligence to sharpen his edge. A clearer view of what smart money is doing.

**What he's afraid of:**

- Missing a trade because he didn't see the signal
- Sizing too large and getting liquidated
- Being wrong about the regime (trading a trend in a choppy market)

**His core workflow on Radar:**

| Stage      | Question                                      | Primary Surface          |
| ---------- | --------------------------------------------- | ------------------------ |
| Pre-Trade  | "What's the market doing? Where's the edge?"  | Radar Discover mode      |
| Execution  | "What size, what leverage, what stops?"       | Trade Panel              |
| Management | "How are my trades doing? Any regime shifts?" | Portfolio                |
| Review     | "Did I follow my process?"                    | Analytics [Phase 2]      |
| Leadership | "How are my followers doing?"                 | Leader Profile [Phase 2] |

---

# 3. Jobs to Be Done

## Sarah's Jobs (S7)

| User Goal                                         | Trigger                                         | Success Metric                          |
| ------------------------------------------------- | ----------------------------------------------- | --------------------------------------- |
| **Find a trustworthy trader to copy**             | First app open, or when adding a new leader     | Copies a leader within first session    |
| **Compare traders to make a confident choice**    | Browsing after initial discovery                | Narrows from 50+ to 2–3 candidates      |
| **Monitor portfolio without checking constantly** | Every app open, 3–8x daily                      | Checks status in <30 seconds            |
| **Discover new traders and expand portfolio**     | Comfortable with first copy, curious about more | Adds a second leader within 30 days     |
| **Be protected when things go bad**               | Market crash, leader drawdown                   | Safety system fires before she notices  |
| **Recover after a loss event**                    | Post-safety-trigger, post-drawdown              | Makes a clear decision (resume or stop) |

## Jake's Jobs (S2)

> Scope: Radar-surface user goals only. Position sizing (Trade Panel) and portfolio management (Portfolio) are in their respective specs.

| User Goal                                        | Trigger                          | Success Metric                                 | Radar Story |
| ------------------------------------------------ | -------------------------------- | ---------------------------------------------- | ----------- |
| **Read the market regime before entering**       | Opening trading session          | Knows regime state + confidence in <10 seconds | Story 7     |
| **Know what smart money is doing**               | Any time during analysis         | Sees cluster consensus direction + strength    | Story 7     |
| **Find market signals that inspire trade ideas** | Browsing Discover feed passively | Identifies actionable setup in <15 seconds     | Story 5     |

---

# 4. Signal Reference

## Trader Classification — 10 Dimensions

| Dim | Dimension        | Labels                                                          | Update       |
| --- | ---------------- | --------------------------------------------------------------- | ------------ |
| D1  | Capital Scale    | Shrimp / Fish / Dolphin / Whale / Mega Whale                    | Batch-daily  |
| D2  | Strategy         | Scalper / Day Trader / Swing Trader / Position Trader / HODLer  | Batch-weekly |
| D3  | Track Record     | Elite / Proven / Verified / Rising / Unranked                   | Batch-weekly |
| D4  | Risk Behavior    | Conservative / Moderate / Aggressive / Degen                    | Batch-weekly |
| D5  | Market Focus     | BTC-Focused / ETH-Focused / Multi-Coin / Cross-Asset            | Batch-weekly |
| D6  | Social Proof     | Top Leader / Established / Emerging / Private / Alpha Source    | Batch-daily  |
| D7  | Regime Timing    | Anticipator / Adapter / Follower / Blind                        | Batch-weekly |
| D8  | Current Exposure | Heavy / Moderate / Light / Sidelined                            | Live (<5s)   |
| D9  | Last Active      | Active / Recent / Quiet / Dormant                               | Batch-daily  |
| D10 | Consistency      | 4/4 / 3/4 / 2/4 / 1/4 / 0/4 (profitable quarters out of last 4) | Batch-daily  |

## Track Record Tiers (D3)

| Tier     | Return | Sharpe | Min Trades | Badge  |
| -------- | ------ | ------ | ---------- | ------ |
| Elite    | ≥30%   | ≥1.5   | 50+        | Gold   |
| Proven   | ≥15%   | ≥1.0   | 50+        | Purple |
| Verified | ≥5%    | ≥0.7   | 50+        | Green  |
| Rising   | >0%    | any    | 10–49      | Yellow |
| Unranked | any    | any    | <10        | Hidden |

Return = (closed P&L + net funding) ÷ arithmetic mean of daily equity snapshots. Phase 1.1 upgrades to time-weighted return.

## Key Trader Metrics

| Metric                    | Definition                                                                          | Time Window              |
| ------------------------- | ----------------------------------------------------------------------------------- | ------------------------ |
| **Copier Return**         | Total copier P&L ÷ total copier allocation across all copiers                       | 7d / 30d / 90d toggle    |
| **Worst Month**           | Worst 30-day return in all-time equity history                                      | All-time                 |
| **Profit Streak**         | Consecutive Mon–Sun weeks with positive closed P&L (completed weeks only)           | Back from last full week |
| **Win Rate**              | Profitable closings ÷ total closings. Shows "—" if <5 trades in window              | 7d / 30d / 90d toggle    |
| **Profit Factor**         | Gross wins ÷ gross losses. >1.5 = strong edge                                       | 7d / 30d / 90d toggle    |
| **Sharpe Ratio**          | Annualised return ÷ annualised volatility of daily equity returns. >1.5 = excellent | 90d                      |
| **Worst Drawdown**        | Worst peak-to-trough loss in all-time equity curve                                  | All-time                 |
| **Copier Total Earnings** | Net sum of all copier P&L across all copy relationships, all-time                   | All-time                 |

## Feed System

### Event Structure

Every feed card originates from a FeedEvent. Viewer context is applied at read time — the same event produces different card types depending on the viewer's relationship to the subject.

**4 event subjects:**

| Subject       | Scope                               | Altitude |
| ------------- | ----------------------------------- | -------- |
| Market        | Asset-level market state            | A1       |
| Cluster       | Consensus across a group of wallets | A2       |
| Wallet        | A single trader taking an action    | A3       |
| Copy Position | Viewer's open copy relationship     | A5       |

A4 (position detail) is always embedded inside an A3 or A5 card — never a standalone.

### My Feed vs Discover

The same wallet event produces different cards based on viewer relationship:

| Viewer relationship to wallet               | Card type                                 | Feed     |
| ------------------------------------------- | ----------------------------------------- | -------- |
| Actively copying                            | Trader Move — with copy P&L impact shown  | My       |
| Watching (not copying)                      | Trader Move — without copy P&L            | My       |
| No relationship; Elite or Proven tier       | Recommended Move — with [Follow] / [Copy] | Discover |
| No relationship; below Elite or Proven tier | No card generated                         | —        |

A5 (Copy Position) events are My Feed only. Cards #10, #11, #12, #13, #14 all require an active copy or follow relationship to appear.

### Cluster Aggregation

Cluster cards are recomputed snapshots — not event-driven. The card fires when consensus crosses the threshold and is suppressed when it breaks.

| Cluster                | Population                                                                                | Threshold                    | Min Members | Recompute   | Breaks when |
| ---------------------- | ----------------------------------------------------------------------------------------- | ---------------------------- | ----------- | ----------- | ----------- |
| Smart Money (#5)       | Elite + Proven, active 30d                                                                | ≥60% one direction           | 10          | Every 5 min | <55%        |
| Regime Specialist (#6) | D7 = Anticipator or Adapter; regime-specific win rate >60%, ≥10 regime trades; active 90d | ≥60% one direction           | 5           | Every 5 min | <55%        |
| My Leaders (#3)        | Viewer's actively copied leaders                                                          | ≥60% same direction on asset | —           | Every 5 min | —           |
| My Watched (#4)        | Viewer's watched (not copied) leaders                                                     | ≥60% same direction on asset | —           | Every 5 min | —           |

### Deduplication

| Rule                                                   | Behaviour                 |
| ------------------------------------------------------ | ------------------------- |
| Same `(subject_id, asset, direction)` within 5 minutes | Merge into one card       |
| Stop loss approaching + Recovery for same leader       | Show Recovery only        |
| Age >24h                                               | Move to "Earlier" section |

### Freshness Tiers

| Tier           | Latency | Used by                                   |
| -------------- | ------- | ----------------------------------------- |
| Live           | <5s     | Exposure, price, cluster consensus        |
| Near-real-time | <30s    | Position changes, P&L updates             |
| Session-fresh  | <5 min  | Regime state, signal scores               |
| Batch-daily    | 24h     | Capital scale, social proof, last active  |
| Batch-weekly   | 7d      | Strategy, risk, track record, consistency |

---

# PART II — RADAR STORIES

---

# Story 1 — "When I open the app for the first time with money sitting idle, I want to see who's consistently making money with proof I can verify, so I can pick someone to copy without needing to be a trader myself."

**Persona:** Sarah (S7) | **Stage:** Cold Start | **Goal:** Find a trustworthy trader to copy

**Pre:** Wallet connected with USDC balance. No follows or copies yet.
**Post:** Followed or copied at least one trader, or returned to keep browsing.

## Steps

1. Tap **Radar** in bottom nav → land on **Traders** sub-tab → see preset cards + Lucid search bar → Presets
2. Tap a preset (e.g., "Consistent Winners") → filter bar reveals active filters built from taxonomy dimensions → trader list loads sorted by preset default
3. Scroll trader list → each card shows at-a-glance signals → Trader Card
4. Tap a trader card → full profile opens with due diligence signals → Trader Profile
5. Decide: tap **[Follow]** (→ Story 3) or **[Copy]** (→ Story 3 copy flow) or **back** (→ Story 2)

**Alt path:** At step 1, type in Lucid search bar instead of tapping a preset. Results show same card format.

## Data & Signal Matrix

### Presets

Each preset combines two types of criteria:

- **Dimension filters** (F1–F10) — the 10 taxonomy dimensions, shown as filter chips in the filter bar
- **Metric conditions** — computed values (e.g., recent return thresholds), shown as condition badges in the filter bar

All criteria are visible and individually removable after selection. Wallets with Last Active = Dormant (D9: 30+ days inactive) excluded across all presets by default via platform toggle.

| Preset                     | What It Answers               | Dimension Filters                                                                                                 | Metric Conditions                                         | Default Sort                                                                        |
| -------------------------- | ----------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| **P1: Consistent Winners** | "Who keeps making money?"     | Track Record >= Rising. Consistency Score = 4/4. Sub-chip: Capital Scale = `[All] [Small] [Mid] [Large]`          | (none — dimension filters sufficient)                     | Profit Streak                                                                       |
| **P5: Safe Hands**         | "Who won't blow up my money?" | Risk Behavior = Conservative or Moderate. Track Record >= Proven. Social Proof: Copyable = Yes.                   | (none — dimension filters sufficient)                     | Sharpe (risk-adjusted return)                                                       |
| **P6: Popular Picks**      | "Who do other people trust?"  | Social Proof = Established or Top Leader or Alpha Source. Track Record >= Verified. Social Proof: Copyable = Yes. | (none)                                                    | Follower count. **†Gate:** hidden until ≥10 platform-wide copy relationships exist. |
| **P8: Hot This Week**      | "Who's making money NOW?"     | Track Record >= Verified.                                                                                         | Traded within last 7 days. Positive 7d Follower's Return. | 7-day Follower's Return                                                             |

**Phase 2 presets:**

| Preset                 | Dimension Filters                                                 | Metric Conditions                                                                |
| ---------------------- | ----------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| **P7: Regime Readers** | Regime Timing = Anticipator or Adapter. Track Record >= Verified. | (none)                                                                           |
| **P9: All-Weather**    | Track Record >= Verified.                                         | Profitable in >=3 of 4 regime types (trending, range-bound, compression, crisis) |

**Preset display in filter bar:** When Sarah taps a preset, the filter bar shows dimension filters as chips (e.g., `[Risk: Conservative/Moderate]` `[Consistency: 4/4]`) and metric conditions as badges (e.g., `[7d active]`). Both are removable. The preset is a shortcut, not a cage.

### Taxonomy — 10 Dimensions

Every preset, filter chip, and sort control maps to one of these dimensions. Each dimension answers one question that no other dimension answers.

| Dim | Name                 | The Question                 | Labels                                                                                                                                 | How It's Calculated                                                                                                                                                                                                                                                                                                                           | User-Adjustable?                       |
| --- | -------------------- | ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| 1   | **Capital Scale**    | "How much money?"            | Shrimp (<$10K) / Fish ($10–50K) / Dolphin ($50–500K) / Whale ($500K–5M) / Mega Whale (>$5M)                                            | Total account equity, snapshot daily                                                                                                                                                                                                                                                                                                          | Yes — bracket boundaries               |
| 2   | **Strategy**         | "How do they trade?"         | Scalper / Day Trader / Swing Trader / Position Trader / HODLer                                                                         | Average hold time across 90 days of trades: <4h = Scalper, 4–24h = Day, 1–14d = Swing, 14–90d = Position, >90d = HODLer. Entry logic labels (Momentum/Carry/Mean Reversion) deferred to Phase 2 — require ML inference on entry patterns.                                                                                                     | No                                     |
| 3   | **Track Record**     | "Are they good?"             | Elite / Proven / Verified / Rising / Unranked                                                                                          | Realized Return (closed P&L + net funding / avg equity) + Sharpe ratio. ALL conditions must be met per tier. See Track Record below.                                                                                                                                                                                                          | Yes — min ROI, Sharpe, trade count     |
| 4   | **Risk Behavior**    | "How much risk?"             | Conservative / Moderate / Aggressive / Degen                                                                                           | Average leverage + worst drawdown + position sizing consistency. Conservative = leverage ≤3x AND worst drawdown >-10% AND consistent sizing. Degen = any ONE extreme: leverage >25x OR drawdown >-35% OR erratic sizing.                                                                                                                      | Yes — max leverage, max worst drawdown |
| 5   | **Market Focus**     | "What do they trade?"        | BTC-Focused / ETH-Focused / Multi-Coin / Cross-Asset / etc.                                                                            | Distribution of trades across assets over 90 days. ≥60% in one asset = "[Asset]-Focused." No single asset >40% = "Multi-Coin."                                                                                                                                                                                                                | No [Phase 2]                           |
| 6   | **Social Proof**     | "Do others trust them?"      | Top Leader (400+ followers) / Established (100–400) / Emerging (10–100) / Private (no copy) / Alpha Source (copier returns in top 10%) | Follower count + copier median return. Alpha Source = regardless of follower count, copiers' median return is in top 10% platform-wide. **Cold start:** All Social Proof labels hidden until platform reaches ≥10 total copy relationships; display per Cold Start fallbacks until then.                                                      | No                                     |
| 7   | **Regime Timing**    | "Can they read shifts?"      | Anticipator / Adapter / Follower / Blind                                                                                               | Scored per regime transition (last 3 per ticker): Exit Score (reduced ≥20% exposure in 3d before shift) × 0.60 + Entry Score (entered aligned within 5d after shift) × 0.40. Weighted avg across ≥3 transitions → band label. [Phase 2] See Regime Timing Algorithm. **Launch fallback:** sort defaults to Sharpe descending.                 | No                                     |
| 8   | **Current Exposure** | "What are they holding NOW?" | Heavy (>80% deployed) / Moderate (40–80%) / Light (10–40%) / Sidelined (<10%)                                                          | Total position value as percentage of account equity, real-time. Plus per-asset breakdown (e.g., "60% in BTC, 25% in ETH").                                                                                                                                                                                                                   | Yes — min %, asset filter              |
| 9   | **Last Active**      | "Are they still trading?"    | Active (traded in last 7d) / Recent (8–30d) / Quiet (31–90d) / Dormant (90d+)                                                          | Days since most recent closed or open position change. Dormant wallets hidden by default across all views; toggle "Show inactive" to reveal.                                                                                                                                                                                                  | No                                     |
| 10  | **Consistency**      | "How steadily do they win?"  | 4/4 / 3/4 / 2/4 / 1/4 / 0/4                                                                                                            | Count of 4 rolling windows (7d, 30d, 60d, 90d) with positive closed P&L. Computed nightly. Only ~10–15% of active wallets score 4/4 at any given time. **Graceful degradation:** wallets with <90d history scored on available windows only (e.g., 30d history → 2/2 not 2/4), displayed as N/M with tooltip explaining reduced window count. | No                                     |

### Regime Timing Algorithm — D7 Label Assignment

**Data required:** Regime transition timestamps (from regime engine) + per-wallet position history. Minimum: ≥3 confirmed regime transitions with overlapping position history.

**Per-transition scoring:**

| Window                         | Measure                                                                     | Score             |
| ------------------------------ | --------------------------------------------------------------------------- | ----------------- |
| **Exit window** (T−3d to T−1d) | Did net exposure in affected assets drop ≥20% before the shift?             | 1 if yes, 0 if no |
| **Entry window** (T+0 to T+5d) | Was the first significant trade after the new regime directionally aligned? | 1 if yes, 0 if no |

**Aligned entry definition by new regime:**

- TRENDING → opened long / increased directional exposure
- RANGE_BOUND → reduced leverage, opened range-sized positions
- COMPRESSION → moved toward sidelined / reduced open positions
- CRISIS → moved to sidelined or cash-equivalent

**Weighted score per transition:**

```
transition_score = (exit_score × 0.60) + (entry_score × 0.40)
```

**Label assignment (last 3 transitions per primary ticker):**

```
weighted_avg = mean(transition_score) across last 3 transitions

Anticipator   ≥ 0.70   exits early AND enters early
Adapter       0.50–0.69 adjusts after the shift, doesn't fight it
Follower      0.30–0.49 gets there eventually, slow
Blind         < 0.30   no observable relationship to regime shifts
```

**Constraints:**

- Minimum 3 confirmed transitions (regime engine held new state ≥24h) with overlapping wallet history → otherwise null (wallet excluded from D7 filter)
- "Last 3 per ticker" prevents stale behavior from inflating recent scores
- Phase 2 only: not computed at launch; Regime Timing filter hidden until sufficient regime history exists platform-wide

### Track Record Tiers (ALL conditions must be met per tier)

Track Record is Dimension 3. It determines the badge displayed on every trader card.

**Realized Return** = sum of all closed P&L plus net funding payments, divided by average account equity over the period. Funding payments are real cash flows in perpetual futures and must be included. All-time is the default; the Trader Card also supports toggling to 7d, 30d, or 90d views.

**Average account equity:** arithmetic mean of daily equity snapshots. Snapshot taken at 00:00 UTC from the Hyperliquid account state API (cross-margin balance + unrealized P&L).

**Calculation roadmap:** At launch, uses realized return (closed P&L + net funding / avg equity) from public Hyperliquid API. V1.1 upgrades to Time-Weighted Return (TWR) — sub-period returns chained at deposit/withdrawal boundaries. V2 adds Sharpe-on-TWR.

**Sharpe** = annualized return divided by annualized volatility of daily equity changes. Above 1.5 is excellent.

| Tier         | All-Time Realized Return | Sharpe (risk-adjusted return) | Min Trades | Badge                   |
| ------------ | ------------------------ | ----------------------------- | ---------- | ----------------------- |
| **Elite**    | >= 30%                   | >= 1.5                        | 50+        | Gold                    |
| **Proven**   | >= 15%                   | >= 1.0                        | 50+        | Purple                  |
| **Verified** | >= 5%                    | >= 0.7                        | 50+        | Green                   |
| **Rising**   | > 0%                     | any                           | 10–49      | Yellow                  |
| **Unranked** | any                      | any                           | < 10       | Hidden from leaderboard |

### Trader Card

**Card anatomy:** `[Avatar] @Name [Badge] | [Strategy chip] [Wallet chip]` — then a liveness sub-line, then 5 core signals. The two chips are identity context, not primary decision signals.

The **Time Window view control** `[7d] [30d●] [90d]` at the top of the trader list is a **display control, not a filter**. It recalculates time-dependent values on every visible card simultaneously without narrowing the list. See View Controls.

| Signal                              | Display                        | How It's Built                                                                                                                      | Time-Togglable?                    |
| ----------------------------------- | ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| **Track Record Badge** (header)     | Gold / Purple / Green / Yellow | Tier from Track Record Tiers. Shown in card header next to name.                                                                    | No — always all-time               |
| **Strategy** (header chip)          | `Swing Trader`                 | 90-day avg hold time. Identity context, not a decision signal.                                                                      | No                                 |
| **Wallet Size** (header chip)       | `Dolphin`                      | Capital Scale bracket. Identity context.                                                                                            | No                                 |
| **Last Active** (liveness sub-line) | `Active · 3h ago`              | Days since last trade. Prevents ghost-wallet: high badge but stopped trading.                                                       | No — always live                   |
| **Follower's Return**               | `+8.2%`                        | Total copier P&L ÷ total copier allocation over the selected window. Day-1 fallback: leader's own return labeled "Leader's Return." | **Yes** — 7d / 30d (default) / 90d |
| **Worst Month**                     | `-3.1%`                        | Worst calendar month in entire equity history.                                                                                      | No — always all-time               |
| **Consistency Score**               | `4/4`                          | Profitable in all 4 rolling windows (7d, 30d, 60d, 90d). ~10–15% of active wallets score 4/4.                                       | No — always checks all 4 windows   |
| **Spots Remaining**                 | `77 spots left`                | Max copy capacity minus current active copiers.                                                                                     | No                                 |

**Max copy capacity:** 500 active copiers per leader at launch. Leaders may not reduce their cap below their current active copier count. Setting is per-leader in account settings. When at full capacity: [Copy] disabled, [Follow] active, [Join Waitlist] shown.

**Moved to Trader Profile:** Profit Streak, Win Rate, and Current Exposure. Win rate varies by strategy type; streak needs regime context; exposure needs position detail to be meaningful.

### Trader Profile

Profile organized in three layers: **performance history** (verify the track record), **current activity** (see what they're in right now), and **copy setup** (commit with a safety net).

**Layer 1 — Performance History:**

| Signal                    | Display                      | How It's Built                                                                                                                                 | Time-Togglable?                    |
| ------------------------- | ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| **Equity Curve**          | Chart                        | Running equity from closed positions + cumulative funding. Tabs: 30d (default) / 7d / 90d / All-time.                                          | **Yes** — tab switches chart range |
| **Sharpe Ratio**          | `1.8` (risk-adjusted return) | Annualized return / annualized volatility of daily equity. Above 1.5 = excellent. All-time.                                                    | No                                 |
| **Worst Drawdown**        | `-12.4%`                     | Worst peak-to-trough loss in all-time equity curve.                                                                                            | No                                 |
| **Win Rate**              | `68%`                        | Profitable closings / total closings. Shown alongside avg trade duration for context (e.g., "68% · avg 3.2d"). <5 trades in window: shows "—". | **Yes** — 7d / 30d (default) / 90d |
| **Profit Streak**         | `12 weeks running`           | Consecutive Mon–Sun weeks with positive closed P&L, counting backward from today. Resets to zero on any losing week.                           | No — always backward from today    |
| **Copier Total Earnings** | `$47K earned for followers`  | Total P&L generated for all copiers, all relationships, all-time. Cold start: hidden if zero.                                                  | No                                 |
| **Regime State**          | `TRENDING 12d` (green)       | Current market regime for assets this leader trades. → See Regime Engine (Story 3)                                                             | No — live                          |

**Layer 2 — Current Activity (live):**

| Signal                | Display                | How It's Built                                                                                                                                                                                     |
| --------------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Current Exposure**  | `Moderate · 60% BTC`   | Total position value as % of equity, real-time. "Sidelined" if <10% deployed. Top asset concentration shown if ≥40% in one asset.                                                                  |
| **Current Positions** | Up to 3 open positions | From live account state. Each row: Asset · Direction · Size · Entry Price · Current P&L · Leverage. Example: `BTC Long · $12K · entry $68,200 · +$840 (+7.0%) · 5x`. "No open positions" if empty. |
| **Recent Trades**     | Last 5 closed trades   | From Hyperliquid fills history. Each row: Asset · Direction · Hold Duration · P&L%. Example: `BTC Long · 3d · +4.2%`. Shows last available if no trades in 30d, with date.                         |

**Layer 3 — Copy Setup (sticky footer):**

| Signal                     | Display        | How It's Built                                                                                                       |
| -------------------------- | -------------- | -------------------------------------------------------------------------------------------------------------------- |
| **Copy Wizard Projection** | `Avg +$128/mo` | Follower's 30d Return % multiplied by Sarah's proposed allocation. Updates live as she adjusts the allocation input. |

### Cold Start — Day 1 Fallbacks

| Signal                | Day-1 Problem                            | Fallback                                                                        |
| --------------------- | ---------------------------------------- | ------------------------------------------------------------------------------- |
| Follower's Return     | No copiers                               | Leader's own 30d return, labeled "Leader's 30d"                                 |
| Track Record tier     | No copier component (removed from tiers) | Total return 55% + Sharpe 45% (copier earnings not required — see Track Record) |
| Social Proof labels   | <10 platform-wide copy relationships     | All Social Proof labels hidden; D6 displays as "—"                              |
| P5 "Safe Hands"       | Copyable = 0                             | Drop Social Proof: Copyable filter, label "Copy coming soon"                    |
| P6 "Popular Picks"    | <10 platform-wide copy relationships     | Entire P6 preset hidden from preset list                                        |
| Copier Total Earnings | No copiers                               | Hide field entirely                                                             |
| Spots Remaining       | Copy not live                            | Show "Coming soon"                                                              |

## Edge Cases

| Condition                  | Behavior                                                        |
| -------------------------- | --------------------------------------------------------------- |
| <10 traders match a preset | Show results + "More traders coming" banner                     |
| All presets return 0       | Show trending traders sorted by 7d return, no preset active     |
| Lucid search returns 0     | "No matches. Try a preset ->" with link to presets              |
| Trader at full capacity    | Card shows "Full" badge, [Copy] disabled, [Follow] still active |

---

# Story 2 — "When I have a list of traders but need to narrow it down, I want to toggle time windows, stack filters, and sort by different metrics, so I can compare them head-to-head and make a confident choice."

**Persona:** Sarah (S7) | **Stage:** Browsing | **Goal:** Compare traders to make a confident choice

**Pre:** Trader list visible from Story 1 preset or search. Filter bar shows active filters. Still on Radar > Traders sub-tab.
**Post:** Narrowed to 2–3 candidates. Followed, copied, or still comparing.

## Steps

Sarah's comparison loop typically cycles 2–3 times before she commits: preset → tweak → scan → tap profile → [Back] → re-sort → narrow to 2–3 finalists.

1. **Start** from a preset (carried from Story 1) or tap **[Clear All]** to see the full unfiltered list. Active filters shown as chips in filter bar.
2. **Toggle Time Window** `[7d] [30d●] [90d]` → all cards update simultaneously (list unchanged) → View Controls, Time Metrics
3. **Tap a filter chip** to add a dimension filter (e.g., F2: Swing Trader, F4: Conservative) → list narrows. Stack up to 5 filters. → Filters
4. **Adjust threshold sliders** on configurable filters (e.g., ROI > 20% AND Sharpe > 1.0) → Filters
5. **Tap sort control** → pick from Sort Mechanisms → list reorders instantly
6. **Scroll and compare** → cards show relationship badge (blue = Watching, purple = Copying +$X)
7. **Tap a card** → full profile opens → Trader Profile (Story 1)
8. **Decide:** [Follow], [Copy], or **[← Back]** to return to the list with all filters and sort preserved
9. **Iterate:** re-sort by a different dimension, adjust a slider, repeat steps 6–8 until narrowed to 2–3 finalists

## Data & Signal Matrix

### Time Metrics

All metrics are computed from Hyperliquid fills history — data predates Arx launch, so there is no cold-start problem. Any wallet with on-chain trading history has data for any window it was active.

| Metric             | 7d                         | 30d                         | 90d           | How It's Built                                                    |
| ------------------ | -------------------------- | --------------------------- | ------------- | ----------------------------------------------------------------- |
| **Return %**       | This week                  | This month                  | Quarter       | Closed P&L ÷ equity at window start                               |
| **Win Rate**       | This week                  | This month                  | Quarter       | Profitable closings ÷ total closings. <5 trades in window → `—`   |
| **Sharpe**         | Available †                | Available †                 | Most reliable | Annualized return ÷ annualized volatility of daily equity changes |
| **Worst Drawdown** | Available (7d peak-trough) | Available (30d peak-trough) | Full picture  | Worst peak-to-trough loss within the selected window              |
| **Profit Factor**  | Available †                | Available                   | Most reliable | Total gross wins ÷ total gross losses. >1.5 = solid edge          |

† **Low-sample footnote:** When the selected window has fewer than 10 closed trades, the metric shows with a `ⓘ` indicator: "Based on N trades — interpret with caution." The value is shown, not hidden.

### Filters — 10 Taxonomy Dimensions

| Filter            | Dim | Type                         | Default                      | Adjustable                                      |
| ----------------- | --- | ---------------------------- | ---------------------------- | ----------------------------------------------- |
| F1: Capital Scale | 1   | Single-select                | All                          | Yes — brackets                                  |
| F2: Strategy      | 2   | Multi-select                 | All                          | No                                              |
| F3: Track Record  | 3   | Multi-select + sliders       | All (excl. Unranked)         | Yes — minimum return, Sharpe ratio, trade count |
| F4: Risk Behavior | 4   | Single-select + sliders      | All                          | Yes — max leverage, max drawdown                |
| F5: Market Focus  | 5   | Multi-select                 | All                          | No [Phase 2]                                    |
| F6: Social Proof  | 6   | Multi-select + toggle        | All, "Copyable only" ON      | No                                              |
| F7: Regime Timing | 7   | Single-select                | All                          | No [Phase 2]                                    |
| F8: Exposure      | 8   | Single-select + asset picker | All                          | Yes — min %, specific asset                     |
| F9: Last Active   | 9   | Single-select                | Active + Recent (hides 90d+) | No — platform default hides Dormant             |
| F10: Consistency  | 10  | Single-select (min score)    | All                          | No                                              |

Platform default: F9 excludes Dormant wallets (Last Active = 90d+). Toggle "Show inactive" to reveal them.

### View Controls

View controls change how data is **displayed** on cards. They do not classify wallets, narrow the list, or appear as filter chips.

| Control         | UI Element                        | What It Changes                                       | What It Does NOT Change                              |
| --------------- | --------------------------------- | ----------------------------------------------------- | ---------------------------------------------------- |
| **Time Window** | `[7d] [30d●] [90d]` toggle at top | Follower's Return, Win Rate, Return % displayed value | Which traders appear, trader card sort order, badges |

**Time Window behavior:**

- Default: 30d
- Affects: Follower's Return display, Win Rate display, Return % in Time Metrics table
- Does NOT affect: Track Record Badge (always all-time), Consistency Score (always checks all 4 windows), Worst Month (always all-time), Profit Streak (always backward from today), Spots Remaining (live)
- If selected window has < 5 trades: show `—` for that metric

**Key distinction from filters:** If Sarah has F3 set to Track Record >= Verified and switches Time Window from 30d to 7d, the trader list is identical. Only return % values on each card update.

### Sort Mechanisms

All 8 sorts available at launch. Time-window-aware sorts update when the Time Window toggle changes.

| Sort                              | Ranks By                                         | Question It Answers                    | Time-Window?              | Notes                                                                       |
| --------------------------------- | ------------------------------------------------ | -------------------------------------- | ------------------------- | --------------------------------------------------------------------------- |
| **Follower's Return** _(default)_ | What copiers earned in selected window           | "Who actually made people money?"      | ✅ Yes                    | Day-1 fallback: leader's own return labeled "Leader's Return"               |
| **Win Rate**                      | % profitable closings in selected window         | "Who wins most consistently?"          | ✅ Yes                    | Hides traders with <5 trades in window (`—`)                                |
| **Worst Month**                   | Worst 30d return, all-time                       | "Who keeps drawdowns small?"           | No — always all-time      | Lets Sarah compare return and risk without opening profiles                 |
| **Sharpe Ratio**                  | Risk-adjusted return, 90d                        | "Who earns most per unit of risk?"     | No — 90d only             | Best for final comparison of 2–3 finalists; noisy at shorter windows        |
| **Consistency Score**             | Count of 4 rolling windows with positive returns | "Who makes money in every time frame?" | No — always all 4 windows | ~10–15% of active wallets score 4/4 at any time                             |
| **Spots Remaining**               | Copy capacity remaining, ascending               | "Who is in high demand?"               | No — live                 | Low spots = scarcity signal. Surfaces leaders near capacity first.          |
| **Capital Scale**                 | Total account equity, descending                 | "Who has the most skin in the game?"   | No — daily snapshot       | Large wallets less likely to self-destruct; alignment signal                |
| **Recent Activity**               | Days since last trade, ascending                 | "Who is actively trading right now?"   | No — live                 | Dormant wallets hidden by default. Sort reveals most recently active first. |

## Edge Cases

| Condition                       | Behavior                                            |
| ------------------------------- | --------------------------------------------------- |
| Filter combo returns 0 results  | "No matches. Remove a filter?" with chip highlights |
| Time toggle to 7d with <5 fills | Show "--" for metrics that need minimum data        |
| User removes all filters        | Return to full list, no preset active               |
| Sort + filter yields <3 results | Show results + "Try fewer filters" nudge            |

---

# Story 3 — "When I've been watching a trader for a few days and their moves look good, I want the app to show me what I've missed and make it easy to start copying, so I can commit capital with confidence."

**Persona:** Sarah (S7) | **Stage:** Watching → Copying | **Goal:** Convert from watcher to copier

**Pre:** Following ≥1 trader for ≥3 days. Has been watching Trader Move cards in the feed. Not yet copying.
**Post:** Actively copying with stop loss set. Enters Story 4 (My Feed monitoring).

## Steps

1. Open app → Radar > **My Feed** → see **Watch Nudge** card pinned at top → Watch Nudge
2. Card shows: how much the leader's copiers earned since Sarah started watching, copier count, current regime
3. Tap **[Copy Now]** on the card (or tap leader name → re-opens full profile from Story 1 Trader Profile)
4. **Copy Wizard** opens: enter allocation amount → monthly projection updates live → Safety
5. Review **regime context pill** inline: TRENDING = green / CRISIS = warning with reduced recommendation
6. Set **stop loss %** (default 50%, range 20–90%) → preview green/amber/red zones
7. Tap **[Confirm Copy]** → copy activates

## Data & Signal Matrix

### The Feed — First Encounter

The Radar feed is a live intelligence stream: structured signals filtered and ranked by what matters to the viewer. Cards surface in **My Feed** (personalised — requires a copy or follow relationship) or **Discover** (market intelligence — visible to anyone). Cards evolve with Sarah's journey: Watch Nudge here, monitoring cards in Story 4, discovery intelligence in Story 5, recovery in Story 6.

### Watch Nudge

| Signal              | Display                                                           | How It's Built                                                                                               |
| ------------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| **Missed Earnings** | "@SwingMaster's 23 copiers made +$847 since you started watching" | Follower's Return % since Sarah's follow date × median active copier allocation. Plain dollar figure, not %. |
| **Copier Count**    | `23 people copying`                                               | Current active copier count at time of card render                                                           |
| **Regime Context**  | `TRENDING 12d` (green pill)                                       | Current regime for this leader's primary assets — inline copy timing signal                                  |
| **Button**          | `[Copy Now]`                                                      | Opens Copy Wizard directly, pre-filled with this leader                                                      |

**Card trigger conditions:**

- Sarah has been following (not copying) this leader for ≥3 days
- Leader had positive Follower's Return during that watch period
- Dismissed: card disappears after viewing; re-surfaces after 7 days if still not copying

### Copier Social Proof

| Signal                 | Display                   | How It's Built                                                       |
| ---------------------- | ------------------------- | -------------------------------------------------------------------- |
| **Active Copiers**     | `23 people copying`       | Current active copier count                                          |
| **Median Return**      | `Median +6.2% this month` | Median Follower's Return across all active copiers in current window |
| **Social Proof Label** | `Established`             | D6 Social Proof dimension label                                      |

### Regime Engine — Copy Timing Context

| State           | Color       | Copy Sizing | Inline Message                                     |
| --------------- | ----------- | ----------- | -------------------------------------------------- |
| **TRENDING**    | Green       | 1.0x        | "Good conditions for copy trading"                 |
| **RANGE_BOUND** | Blue        | 0.5x        | "Choppy market — watch safety bar closely"         |
| **COMPRESSION** | Amber       | 0.3x        | "Low volatility — smaller allocation recommended"  |
| **CRISIS**      | Deep Orange | 0.1x        | "High volatility — wizard recommends smaller size" |
| **TRANSITION**  | Grey        | 0.25x       | "Unclear conditions — caution"                     |

Per-asset classification. Portfolio regime = worst-case across all assets this leader trades. The allocation wizard automatically pre-scales the recommendation to the regime multiplier; Sarah can override.

### Implementation Constraints

**Execution channel:** HIP-3 builder codes. Each copy relationship uses an Arx-managed sub-account. Latency target: <2s from leader fill to copy order submission. 2.5bps builder fee per copied trade flows to Arx revenue.

**Margin scaling:** If the sub-account cannot hold full proportional notional at leader's leverage, scale down to maximum supportable notional at same leverage. If scaled-down notional is <$10 (HL minimum order size), skip and log. Do not fill partial.

**Full copy architecture spec:** `Arx_5-2-3_OnChain_Signal_Transformation_v6.md` § Copy Engine.

### Stop Loss

**What it measures:**

Each copy relationship has its own stop loss, tracking:

```
loss% = (initial allocation − current copy equity) / initial allocation
```

**Current copy equity** = realized profit/loss (closed trades) + unrealized profit/loss (open positions) + net funding payments. All three are included, not just closed trades. Measured per-leader — not across the total portfolio.

**Example:** Sarah allocates $2,500 to @Alpha. @Alpha's open positions are currently down $1,200. Copy equity = $1,300. Loss% = (2,500 − 1,300) / 2,500 = 48%.

**How to set it:**

- **Stop loss %:** Maximum loss tolerated on this leader's allocation (default 50%, range 20–90%). Per-leader override allowed.
- **Zones** (displayed as a bar in the Live Signals strip, scaled to the chosen limit):
  - Green — Healthy: 0 to limit × 0.6
  - Amber — Watch: limit × 0.6 to limit × 0.8
  - Red — Danger: limit × 0.8 to limit
- **Auto-pause trigger:** When loss% reaches 100% of the limit → server-side pause, even if phone is off. Open positions stay open (not force-closed); new copies stop until Sarah resumes or stops the relationship.

**Example with 50% limit:** Green 0–30% / Amber 30–40% / Red 40–50%. Auto-pauses at 50% loss ($1,250 on a $2,500 allocation).

**At launch:** Static stop loss — does not trail upward as the copy makes profit. Trailing stop is Phase 2.

**Per-leader:** Each copied leader has its own independent stop loss. @Alpha hitting its limit does not affect @SwingMaster's copy.

## Edge Cases

| Condition                                           | Behavior                                                                               |
| --------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Regime = CRISIS when copy attempted                 | Wizard warns: "High volatility. Recommended allocation reduced to 0.1x. Are you sure?" |
| Leader at full capacity                             | [Copy] disabled. "Join waitlist" shown instead.                                        |
| Insufficient wallet balance                         | Wizard shows max available and prevents overshoot                                      |
| Leader had 0 or negative return during watch period | Watch Nudge card suppressed.                                                           |

---

# Story 4 — "When I open the app during my day, I want to see in 30 seconds whether my money is safe and what happened, so I can close the app and get on with my life."

**Persona:** Sarah (S7) | **Stage:** Actively Copying | **Goal:** Monitor without checking constantly

**Pre:** Actively copying at least one trader. Notifications enabled.
**Post:** Informed (→ close app), curious about markets (→ Story 5 Discover), or concerned (→ Story 6 Recovery).

## Steps

1. Open app → Radar loads with **Feed** sub-tab as default for users with active copies
2. Scan **top-of-screen summary** in <5 seconds → Live Signals
3. Read **context line**: "All healthy, portfolio trending 12d" + regime pill
4. Scroll **feed** → cards in priority order → Feed Cards
5. Read relevant cards → each is a self-contained signal at one altitude → Altitudes
6. Close app. 30-second check complete.

**While You Were Away** (after 24h+ absence):

1. Open app → Radar loads → **Feed** sub-tab → pinned WYWA card at top
2. Card shows: safety status (first), absence duration, total earned, per-leader breakdown
3. Tap to dismiss → regular feed

**Weekly Summary** (Mondays after first copy):

1. Open app → Radar loads → **Feed** sub-tab → Weekly Rollup card
2. Shows: weekly P&L, all-time P&L, per-leader stats, market summary

## Data & Signal Matrix

### Live Signals (refresh 1–5s)

| Signal                | Display                          | How It's Built                                                      |
| --------------------- | -------------------------------- | ------------------------------------------------------------------- |
| **Total P&L**         | `+$28.13 today`                  | Closed + unrealized P&L across all copies for current day           |
| **Per-Leader Chips**  | `@SwingMaster +$47` (green)      | Per-leader copy equity change since allocation                      |
| **Stop Loss Bar**     | `22% used` (green)               | Percentage of stop loss tolerance consumed. See Stop Loss (Story 3) |
| **Portfolio Equity**  | `$12,450`                        | Total account value                                                 |
| **Correlation Alert** | `Both leaders long BTC — $4,200` | 2+ copied leaders same asset + same direction                       |

### Altitudes — Feed Card Layers

| Altitude      | Scope        | Question                       | Example                           |
| ------------- | ------------ | ------------------------------ | --------------------------------- |
| A1 — Market   | Environment  | "What's happening?"            | "BTC shifted to TRENDING"         |
| A2 — Group    | Consensus    | "What does smart money think?" | "Your leaders all long BTC"       |
| A3 — Trader   | Individual   | "What did they do?"            | "@SwingMaster opened BTC Long 5x" |
| A4 — Position | Trade detail | (Embedded in A3/A5)            | --                                |
| A5 — Personal | Your money   | "Am I okay?"                   | "Your copy: +$13.50"              |

### Feed Data Model

Every card is generated from a **FeedEvent** with a **viewer context** applied on top. Understanding this structure prevents confusion when one event appears as different card types depending on who's viewing.

**The 4 event subjects:**

| Subject         | What It Covers                              | Examples                                           |
| --------------- | ------------------------------------------- | -------------------------------------------------- |
| Market          | Asset-level market state                    | Regime change, funding rate extreme                |
| Cluster (Group) | Consensus across a group of wallets         | ≥60% of Elite traders long BTC                     |
| Wallet          | A single trader taking an action            | @SwingMaster opened BTC Long 5x                    |
| Copy Position   | Sarah's relationship with a specific leader | Stop loss triggered, daily earnings, nudge to copy |

**How altitude maps to subject:**

- A1 (Market events) → subject = market
- A2 (Group / consensus) → subject = cluster
- A3 (Individual trader) → subject = wallet
- A5 (Your money) → subject = copy position
- A4 (Position detail) is never a standalone card — always embedded inside A3 or A5

**My Feed vs Discover computed at read time:**

| Viewer relationship to @SwingMaster   | Card type                                  | Feed     |
| ------------------------------------- | ------------------------------------------ | -------- |
| Actively copying                      | Trader Move — with copy profit/loss impact | My Feed  |
| Watching (not copying)                | Trader Move — without copy profit/loss     | My Feed  |
| No relationship; Elite or Proven tier | Recommended Move — with [Follow] / [Copy]  | Discover |
| No relationship; not Elite or Proven  | No card generated                          | —        |

**Multi-asset, multi-leader card logic:**

- Each event is tied to one `(wallet, asset)` pair. @SwingMaster opening BTC Long and ETH Long are two separate events.
- Consensus cards (A2) are **aggregations** across multiple wallet-asset positions, recomputed every 5 minutes — not one event per trade.
- Dedup key: `(subject_id, asset, direction)` within a 5-minute window → merge into one card.

**Copy position events (A5) are always personal — never shown in Discover:**
Cards #10 (Copy Earnings), #11 (Recovery), #12 (Weekly Rollup), and #13 (Watch Nudge) require an active copy or follow relationship. My Feed only by definition.

### My Feed Cards

These are the cards Sarah encounters in Story 4. Each requires a copy or follow relationship. Cards #1 (Regime Shift), #2 (Funding Alert), #5 (Smart Money), #6 (Regime Specialist), and #9 (Recommended Move) appear in **Discover** mode and are defined in Story 5. Card #11 (Recovery) is defined in Story 6.

| #   | Card             | Alt | Trigger                                                | Display Example                                        | Data Sources                                                                                                         | Freshness     | User Question Answered                                      |
| --- | ---------------- | --- | ------------------------------------------------------ | ------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- | ------------- | ----------------------------------------------------------- |
| 14  | WYWA             | A5  | App opens after ≥8h absence with active copies         | "While you were away: All healthy. +$47 total."        | Arx copy P&L + stop loss status across all leaders; timestamped from last foreground. Pinned, dismisses on tap.      | Live (<5s)    | "What happened while I was gone?"                           |
| 3   | Leader Consensus | A2  | ≥60% of Sarah's copied leaders same direction on asset | "3 of 4 leaders long BTC. Entered at $68,200"          | Live positions of Sarah's copied leaders (asset, direction, notional, avg entry). Hyperliquid account state + Arx DB | Live (<5s)    | "Are my leaders all betting the same way?"                  |
| 4   | Watch Consensus  | A2  | ≥60% of Sarah's watched leaders same direction         | Same format, cyan border                               | Live positions of Sarah's watched leaders (not copied). Same source as Card 3                                        | Live (<5s)    | "Are the traders I'm watching all in the same direction?"   |
| 7   | Divergence       | A2  | My Leaders cluster opposes Elite cluster direction     | "Your leaders disagree with smart money" (amber)       | Cross-comparison of Card 3 (My Leaders) vs Card 5 (Elite cluster). Defined in Story 5.                               | Session-fresh | "Are my leaders out of step with smart money?"              |
| 8   | Trader Move      | A3  | Sarah's copied or watched leader opens or closes       | "@SwingMaster opened BTC Long 5x — Your copy: +$13.50" | Hyperliquid real-time fills stream. Leader trade fill + Arx copy P&L change for Sarah                                | Live (<5s)    | "What did my leader just do, and what happened to my copy?" |
| 10  | Copy Earnings    | A5  | Daily 8am push                                         | "Yesterday: +$47.20. Best: @SwingMaster +$33"          | Arx copy P&L tracking (closed positions + funding) aggregated by day per leader                                      | Batch-daily   | "How much did I make?"                                      |
| 12  | Weekly Rollup    | A5  | Mondays (first copy active)                            | "This week: +$87.20. All-time: +$1,245 (+14.6%)"       | Arx copy P&L aggregated weekly; per-leader breakdown                                                                 | Batch-weekly  | "How is my portfolio doing over time?"                      |

**Card 14 — WYWA states:**

- **All safe:** "While you were away (6h): All healthy. +$47 total."
- **Amber:** "While you were away (6h): @SwingMaster approaching stop loss limit — 72% consumed."
- **Red / triggered:** "While you were away: @Alpha hit stop loss limit. Copies paused." — links directly to Recovery Card (#11)

**Ordering:** Pinned (WYWA, Recovery) > Critical > High > Normal > Low. Items older than 24h move to "Earlier" section.
**Dedup:** Same leader + asset + direction within 5 min → merge into one card. Stop loss approaching + Recovery for same leader → show Recovery only.

### Push Notifications

| Type                  | Priority | Trigger                                                                  |
| --------------------- | -------- | ------------------------------------------------------------------------ |
| Stop loss triggered   | Critical | Loss reached stop loss limit (100%)                                      |
| Stop loss approaching | High     | Loss exceeded 60% of stop loss limit                                     |
| Regime mismatch       | Medium   | Leader win rate < 55% in current regime (launch: overall win rate < 55%) |
| Leader inactive       | Medium   | No trades 14+ days                                                       |
| Regime change         | Medium   | State transition                                                         |
| Copy executed         | Low      | Leader trade → copy placed                                               |
| Daily P&L             | Low      | End of day                                                               |

## Edge Cases

| Condition                              | Behavior                                                                                           |
| -------------------------------------- | -------------------------------------------------------------------------------------------------- |
| Feed empty (S0 user navigates to Feed) | Discover-mode cards only + banner: "Follow traders to see their activity. Start on Traders tab ->" |
| All leaders inactive 14+ days          | Push "Leader inactive" + feed banner: "Your leaders haven't traded recently"                       |
| Stale data (>15 min)                   | Cards show "delayed" indicator. After 15 min stale → suppress entirely                             |
| Card with null primary field           | Suppress card. Never show broken data.                                                             |

---

# Story 5 — "When I open the app with time to browse, I want to see what's happening in the market and discover interesting traders, so I can stay informed and find opportunities."

**Persona:** Sarah (S7) + Jake (S2) | **Stage:** Browsing (Sarah) / Pre-Trade (Jake) | **Goal:** Discover new traders and expand portfolio (S7) · Find market signals that inspire trade ideas (S2)

**Pre:** App open. Not responding to an alert — curiosity-driven open.
**Post:** S7: followed or bookmarked a new trader, or absorbed market context. S2: identified a signal worth analyzing → proceeds to Story 7, or decided to wait.

## Steps

**S7 (Sarah) path:**

1. Open app → Radar → tap **[Discover]** toggle in Feed tab (or land here by default if no active copies)
2. Scan **Market Overview strip** at top → current regime + dominant cluster consensus → Market Overview
3. Scroll Discover feed → cards ordered by priority: Regime Shift → Smart Money → Regime Specialist → Recommended Move → Funding Alert → Discover Feed Cards
4. Tap a **Recommended Move** card → tap [Follow] → opens trader profile (Story 1 Trader Profile)
5. Tap **[Copy]** from profile → enters Story 3 copy wizard
6. Or: tap **[View all top traders →]** on a Smart Money card → Traders tab filtered to Elite + Proven, sorted by Follower's Return

**S2 (Jake) path:**

1. Open app → Radar → Discover feed (or Feed tab → Discover toggle)
2. Scan Market Overview strip → regime state, cluster direction, funding alert count → Market Overview
3. Read **Smart Money card** or **Regime Shift card** → directional signal forms
4. Tap **[Analyze →]** on any signal card → asset detail view loads with regime context pre-populated
5. Proceed to Story 7 (Pre-Trade Analysis) or close if signal doesn't meet entry criteria

## Data & Signal Matrix

### Market Overview Strip

Loads on Discover open, refreshes every 5 min.

| Signal                      | Display                                 | How It's Built                                                                                                |
| --------------------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **Regime per asset**        | `BTC TRENDING 12d` `ETH RANGE_BOUND 4d` | Regime engine (technical price indicators) per top 3 assets by open interest. Duration since last transition. |
| **Elite cluster direction** | `72% of Elite traders long BTC`         | Performance Elite cluster consensus. Shown only when ≥60% of Elite traders agree on direction.                |
| **Active alerts count**     | `2 funding alerts active`               | Count of active Funding Alert cards in current feed session.                                                  |

### Discover Cards

Discover mode surfaces market intelligence and trader discovery signals. No copy or follow relationship required. Sarah sees trader-oriented CTAs; Jake sees analysis-oriented CTAs.

**Card ordering:** Regime Shift and Funding Alerts first (time-sensitive), then Smart Money and Regime Specialist (consensus intelligence), then Recommended Move cards (individual trader actions). Dedup: same asset + direction within 5 min → merge into one card.

---

**Card #1 — Regime Shift** (A1 · Both)

|                   |                                                                                                                          |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------ |
| **Trigger**       | Market regime transitions to a new state for any tracked asset                                                           |
| **Display**       | "BTC shifted to TRENDING. Regime specialists win 68% in trending."                                                       |
| **Data sources**  | Regime engine: technical price indicators (momentum, volatility, trend strength) applied to Hyperliquid candlestick data |
| **Freshness**     | Session-fresh (5 min)                                                                                                    |
| **Sarah CTA**     | Passive — read for market context                                                                                        |
| **Jake CTA**      | `[Analyze →]` opens asset with regime pre-populated in Market Signals                                                    |
| **User question** | "What changed in the market?"                                                                                            |

---

**Card #2 — Funding Alert** (A1 · Both)

|                   |                                                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------- |
| **Trigger**       | Funding rate >20% APR on any tracked asset, or 3+ consecutive high-funding hours                        |
| **Display**       | "BTC longs paying +42% APR — 3rd consecutive high-funding hour"                                         |
| **Data sources**  | Hyperliquid funding endpoint. Annualized: hourly rate × 24 × 365                                        |
| **Freshness**     | Session-fresh (5 min)                                                                                   |
| **Sarah CTA**     | Passive — market awareness                                                                              |
| **Jake CTA**      | `[Analyze →]` opens asset; annualized funding cost shown prominently as carry cost or contrarian signal |
| **User question** | "Is the market overcrowded on one side?"                                                                |

---

**Card #5 — Smart Money** (A2 · Discover)

|                   |                                                                                                                                                                      |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Trigger**       | Elite + Proven tier traders: ≥60% consensus on direction for one asset (minimum 10 traders)                                                                          |
| **Display**       | "72% of top traders long BTC — avg entry $68,200 (+1.9%)"                                                                                                            |
| **Data sources**  | Live positions of Elite + Proven tier traders active in last 30d. Weighted avg entry price. Cluster recomputed every 5 min. Breaking threshold: 55% (5% hysteresis). |
| **Freshness**     | Session-fresh (5 min)                                                                                                                                                |
| **Sarah CTA**     | `[View all →]` filters Traders tab to Elite + Proven, sorted by Copier Return                                                                                        |
| **Jake CTA**      | `[Analyze →]` opens asset with Elite + Proven consensus pre-loaded in Clusters                                                                                       |
| **User question** | "What are the best traders doing?"                                                                                                                                   |

Display copy uses "top traders" or "smart money" — not "Elite traders" — because the cluster includes Proven tier.

---

**Card #6 — Regime Specialist** (A2 · Discover)

|                        |                                                                                                                                                             |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Trigger**            | Regime Winners cluster: ≥60% consensus on direction for one asset (minimum 5 traders in cluster)                                                            |
| **Display**            | "80% of trending specialists long BTC"                                                                                                                      |
| **Cluster definition** | Traders with D7 label = Anticipator or Adapter AND regime-specific win rate in current regime >60%, with ≥10 trades in that regime type, active in last 90d |
| **Data sources**       | D7 Regime Timing labels (batch-weekly) + regime-specific win rate per trader (batch-weekly) + live positions                                                |
| **Freshness**          | Session-fresh (5 min)                                                                                                                                       |
| **Sarah CTA**          | `[View all →]` filters Traders tab to Regime Winners cluster                                                                                                |
| **Jake CTA**           | `[Analyze →]` opens asset with regime-specialist consensus data                                                                                             |
| **User question**      | "Who's winning specifically in this market condition?"                                                                                                      |

Smart Money is a performance cluster (top traders overall). Regime Specialist is a context cluster (top traders in the current regime type). In a CRISIS regime, a conservative Adapter may outrank a high-return trader who struggles in crashes.

---

**Card #9 — Recommended Move** (A3 · Discover)

|                   |                                                                                                                                                                   |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Trigger**       | Elite or Proven tier trader opens or closes a position                                                                                                            |
| **Display**       | "@SwingMaster opened BTC Long 5x — 28 active copiers · Copier Return +6.2% this month"                                                                            |
| **Data sources**  | Hyperliquid real-time fills stream + Track Record tier from Arx database (only Elite/Proven trigger this) + active copier count + 30d Copier Return (batch-daily) |
| **Freshness**     | Near-real-time (<30s)                                                                                                                                             |
| **Sarah CTA**     | `[Follow]` / `[Copy]` — opens trader profile                                                                                                                      |
| **Jake CTA**      | `[Watch]` — adds trader to Jake's watched list. `[Analyze →]` if from a trigger card.                                                                             |
| **User question** | "Who made an interesting move I should consider?"                                                                                                                 |

**Copier P&L context:** Active copier count and 30d Copier Return are shown on the card (not just in the profile). Cold start fallback: if <3 active copiers, show "New leader" instead of copier stats.

## Edge Cases

| Condition                                              | Behavior                                                                                        |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| No active clusters (market too thin)                   | Smart Money card not shown. Strip shows "No cluster consensus today."                           |
| Regime = TRANSITION across all assets                  | Show "Markets in flux — no clear regime signal" in strip                                        |
| No Elite/Proven traders active in 30d                  | Recommended Move cards suppressed. Show "Discover more traders" banner pointing to Traders tab. |
| Jake taps [Analyze →] with no asset detail spec loaded | Opens asset overview with regime + market signals from Market Overview (Story 7 context)        |

---

# Story 6 — "When something goes wrong and the system paused my copies, I want to understand what happened and make a clear decision about what to do next."

**Persona:** Sarah (S7) | **Stage:** Warning | **Goal:** Recover after loss

**Pre:** Safety limit reached for one or more leaders. System auto-paused copies (server-side). Critical push sent.
**Post:** Resumed with cooldown (open positions stay open), or stopped with capital returned (~2 min).

## Steps

1. **Receive push notification** (lock screen):
   `"@AlphaTrader hit your 50% loss limit. Copies paused. -$1,300."`
   Format: `"@{leader} hit your {limit}% loss limit. Copies paused. {net_pnl}."`

2. **Tap notification** → app opens to **Radar > Feed > My** → **Recovery Card** pinned at top, red border, above all other cards

3. **Recovery Card** shows current state (see Recovery Card States below):
   - Leader name + avatar: "@AlphaTrader"
   - Loss amount: "-$1,300 (52% of $2,500 allocation — past 50% limit)"
   - Copy equity remaining: "$1,200 of $2,500 allocation"
   - Trigger reason: "BTC dropped 15% in 4h. Hit 50% limit."
   - Card state: **LIMIT HIT**

4. **Read contextual signals** (if present, shown below the trigger reason):
   - **Correlation alert**: "Both @Alpha and @SwingMaster are long BTC — combined $4,200 exposure still open"
   - **Regime mismatch**: "@Alpha has a 52% win rate in choppy markets (current regime: RANGE_BOUND)"

5. **Decision tree** — two buttons with consequence text shown inline on the card:

   | Option     | Button                    | Consequence Text (shown on card)                                                                                                 |
   | ---------- | ------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
   | **Resume** | `[Resume Copying]`        | "4h cooldown begins. Safety limit re-arms after cooldown. **Open positions stay open.** Next copy after cooldown expires."       |
   | **Stop**   | `[Stop & Return Capital]` | "Copy relationship ends. **Capital returned in ~2 min.** Open positions closed at market price. You can re-copy @Alpha anytime." |

6. **Sarah taps [Resume]** → cooldown timer starts → card enters **RESOLVING** state: "Safety resumes in 3h 42m. Open positions continue."

   **Or Sarah taps [Stop]** → confirmation modal: "Stop copying @Alpha? Open positions will close at market. Capital (~$1,200) returns in ~2 min." → `[Confirm Stop]` / `[Cancel]` → on confirm, card enters CLOSED state, capital returns to balance.

7. **Post-decision confirmation** (card stays dimmed for 24h, then auto-dismisses):
   - If resumed: "Resumed at {time}. Cooldown expires {time}. Safety limit reset to {configured_limit}%."
   - If stopped: "Stopped at {time}. $1,172 returned to balance. (@Alpha had 2.3% slippage on position close.)"

## Data & Signal Matrix

### Card #11 — Recovery (A5 · My Feed)

|                   |                                                                                                           |
| ----------------- | --------------------------------------------------------------------------------------------------------- |
| **Trigger**       | Stop loss limit reached — server-side event, fires even if phone is off                                   |
| **Display**       | "@Alpha hit limit. -$420. [Resume Copying] [Stop & Return]" (RED, PINNED)                                 |
| **Data sources**  | Arx stop loss system: copy position loss%, open position profit/loss, capital secured — server-side event |
| **Freshness**     | Instant (<2s)                                                                                             |
| **User question** | "Something went wrong — what do I do?"                                                                    |

The Recovery card is always pinned above all other content when active. It does not age out or move to "Earlier." It stays until Sarah acts. See Recovery Card States below.

### Recovery Card States — 3-State Machine

| State               | Trigger                                        | Card Color | Header                                       | Primary Action                            |
| ------------------- | ---------------------------------------------- | ---------- | -------------------------------------------- | ----------------------------------------- |
| **ACTIVE LOSS**     | Safety bar crossing 40%+ but not at limit yet  | Amber      | "⚠️ @Alpha approaching limit — {pnl} (-40%)" | `[Review]` → opens leader profile         |
| **LIMIT HIT**       | Stop loss limit reached, copies auto-paused    | Red        | "🛑 @Alpha hit limit. Copies paused. {pnl}"  | `[Resume Copying]` / `[Stop & Return]`    |
| **MANUALLY PAUSED** | Sarah paused copies herself from Manage screen | Grey       | "⏸ @Alpha paused by you"                     | `[Resume Copying]` / `[Stop Permanently]` |

State transitions:

```
ACTIVE LOSS       → LIMIT HIT        (stop loss limit reached)
LIMIT HIT         → RESOLVING        (Sarah taps Resume, cooldown active)
RESOLVING         → ACTIVE LOSS      (cooldown expires, new copy session begins)
LIMIT HIT         → CLOSED           (Sarah taps Stop)
MANUALLY PAUSED   → CLOSED           (Sarah taps Stop Permanently)
MANUALLY PAUSED   → ACTIVE LOSS      (Sarah taps Resume)
```

### Multi-Leader Scenario

If Sarah has 3 leaders and only 1 hits the stop loss limit:

- Feed shows **1 Recovery Card** (pinned, red) for @AlphaTrader
- Below it: 2 normal active copy cards for unaffected leaders
- No bulk action offered — each leader is a separate, deliberate decision
- **Portfolio summary line** above all cards: "2 of 3 leaders active. @Alpha paused."

If 2+ leaders hit limits simultaneously (e.g., correlated long BTC during flash crash):

- Multiple Recovery Cards stacked, most recent trigger on top
- **Correlation warning** pinned above stack: "⚠️ @Alpha and @SwingMaster both triggered. Both long BTC — possible correlated risk."
- Each card resolved independently — Sarah decides per leader

### Warning Signals

| Signal                | Display                              | How It's Built                                                              |
| --------------------- | ------------------------------------ | --------------------------------------------------------------------------- |
| **Safety Alert**      | "@Alpha hit limit. -$1,300. Paused." | Stop loss limit reached → auto-pause → push notification. Server-side.      |
| **Recovery Card**     | State + returned amount + options    | See Recovery Card States above                                              |
| **Resume Cooldown**   | "Safety resumes in 3h 42m"           | 4h cooldown prevents Resume → re-trigger loops                              |
| **Correlation Alert** | "Both long BTC — $4,200 combined"    | 2+ leaders same direction on same asset detected                            |
| **Regime Mismatch**   | "@Alpha wins 52% in choppy markets"  | Leader win rate in current regime < 55% (at launch: overall win rate < 55%) |

## Edge Cases

| Condition                                    | Behavior                                                                                                                                                                                                                                                     |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Sarah ignores Recovery Card for 7+ days      | Push reminder: "Copies still paused for @Alpha. Resume or stop?"                                                                                                                                                                                             |
| Resume → immediate re-trigger after cooldown | Card shows again with updated numbers. At 3 triggers in 24h → [Resume] button locked for 24h. Card shows: "Safety triggered 3× today. Resume available at {time}. You can still [Stop & Return Capital]." Auto-unlocks after 24h — no support flow required. |
| App closed when limit hits                   | Push arrives, Recovery Card ready when app opens.                                                                                                                                                                                                            |
| Capital return fails (network/chain issue)   | "Return in progress — check again in 10 min. Contact support if balance hasn't updated."                                                                                                                                                                     |

---

# Story 7 — "When I'm about to trade, I want to see the market regime, what smart money is doing, and the structural signals in 10 seconds, so I can decide whether to enter."

**Persona:** Jake (S2) | **Stage:** Pre-Trade | **Goal:** Read the market before entering

**Pre:** Funded wallet. About to trade. Radar accessible.
**Post:** Decided to trade (→ Trade Panel, see Arx_4-1-1-3) or wait.

## Steps

Jake's pre-trade flow often starts in the Discover feed (Story 5) where a signal card triggers his interest. He arrives here either from a Discover card [Analyze →] CTA or by opening Radar directly.

1. **Entry point A:** From Story 5, tap **[Analyze →]** on a Regime Shift, Smart Money, or Funding Alert card → asset detail opens with regime context pre-populated
2. **Entry point B:** Open Radar directly → tap **Traders** sub-tab → **Discover** mode → Market Overview strip loads
3. **Scan regime pill:** state, duration, confidence → Regime Engine (Story 3)
4. **Read market data strip** → Market Signals (Jake's Trigger Cards below shows which feed cards led here)
5. **Check cluster consensus:** "Elite 75% long BTC" + weighted entry + liq zone → Clusters
6. **Check impact prices:** bid/ask spread for $5K order size → execution quality
7. **Decide:** trade (→ Trade Panel, Arx_4-1-1-3) or wait

## Data & Signal Matrix

### Jake's Trigger Cards

Jake's pre-trade analysis rarely starts cold. A feed card in Story 5 creates the itch. These are the cards that lead from Discover → Story 7.

| Card                          | What Jake Sees                                                              | Why It Triggers                                                                                                 | Action Chain                                                              |
| ----------------------------- | --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| **Regime Shift** (#1)         | "BTC shifted to TRENDING — regime specialist win rate 71% in this regime"   | Regime change = new directional opportunity.                                                                    | `[Analyze →]` → loads asset with regime pre-filled + Market Signals       |
| **Smart Money** (#5)          | "72% of Elite traders long BTC — avg entry $68,200 (+1.9%)"                 | Large-capital directional consensus = validation for Jake's thesis. Entry price shows whether move has started. | `[Analyze →]` → loads asset + Clusters pre-filled with Elite consensus    |
| **Regime Specialist** (#6)    | "80% of trending specialists long BTC"                                      | Strategy-filtered consensus. More relevant than broad market — these traders outperform in this regime type.    | `[Analyze →]` → same as Smart Money                                       |
| **Funding Alert** (#2)        | "BTC longs paying +42% APR — 3rd consecutive high-funding hour"             | Funding extreme = market overcrowded. Jake uses as contrarian trigger (fade the crowd) or a cost signal.        | `[Analyze →]` → asset view with annualized funding cost shown prominently |
| **Trader Move** (#8, watched) | "@SwingMaster opened BTC Long 10x — 3rd trending trade this month, won 2/2" | Jake watches leaders as signal, not to copy. A watched Elite trader acting = pre-qualified setup.               | `[Analyze →]` → asset view + sees @SwingMaster's position in cluster data |

**Distance to trade from feed card:** 2–3 taps (card → [Analyze →] → regime/market view → Trade Panel). No search, no filter, no separate navigation step.

**Regime Alignment sort (Traders tab):** When Jake is in pre-trade mode on the Traders tab, a **Regime Alignment** sort ranks traders by how well their strategy (D2) matches current regime. In TRENDING, Swing Traders and Position Traders rank first. In RANGE_BOUND, Day Traders rank first.

### Market Signals

Jake's question: "What's the market doing right now?"

| Signal               | Display             | How It's Built                                                                                                                                                                                        |
| -------------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **24h Price Change** | `+2.3%`             | Mark price vs previous day price                                                                                                                                                                      |
| **Funding Rate**     | `+5.5% APR`         | `hourly_rate × 8,760 = APR`. HL settles every hour. Positive = longs paying shorts. Source: `fundingHistory` endpoint.                                                                                |
| **Open Interest**    | `26,394 BTC`        | Total open contracts in base asset. Rising OI + rising price = trend conviction; rising OI + falling price = short pressure.                                                                          |
| **24h Volume**       | `$2.1B`             | Total traded notional in USD. Low volume = thin liquidity, higher slippage risk.                                                                                                                      |
| **Premium**          | `-0.03%`            | `(mid_price − oracle_price) / oracle_price`. On HL, mark price = oracle price for funding calculations; premium reflects order book imbalance. Negative = asks pulling below oracle = short pressure. |
| **Impact Prices**    | `$69,018 / $69,019` | Estimated fill price for $5K order long / $5K order short. Direct from L2 book. Shows real execution cost, not just mid.                                                                              |

### Clusters — Group Consensus

| Cluster                | What Jake Sees                         | Min Members | Trigger                  |
| ---------------------- | -------------------------------------- | ----------- | ------------------------ |
| **Performance Elite**  | "72% of Elite traders long BTC"        | 10          | >=60% agree on direction |
| **Regime Specialists** | "80% of trending specialists long BTC" | 5           | >=60% agree on direction |

Enrichments: weighted avg entry price ("entered at $68,200, +1.9%"), liquidation heatmap (shown when nearest concentration is <15% from mark price).

**Liquidation heatmap data source:** Computed by Arx from open positions of tracked wallets. For each wallet with a known position, estimate liquidation price from: entry price, leverage, and maintenance margin rate (0.5% for most HL perp markets). Group estimated prices into $100 bins. Display as bar chart beneath cluster consensus when the densest bin is <15% from current mark price. This is an approximation [approx] — HL does not expose individual liquidation prices via public API. Phase 2: use HL's native liquidation levels endpoint if/when available.

Consensus detected every 5 min. Breaking when strength drops below 55% (5% hysteresis).

Cards #3/#4 in Sarah's My Feed show "your watched/copied leaders are both long BTC" — this is position correlation risk for her copy portfolio, not market intelligence. Jake's cluster panel here is a directional signal for his own trades.

**Phase 2:** A 5-layer Confluence score (0–10) unifies these signals into a single entry conviction indicator.

## Edge Cases

| Condition                                               | Behavior                                                                                     |
| ------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Regime = TRANSITION (ambiguous)                         | Show "No clear pattern — monitor only" guidance                                              |
| Cluster consensus <60% (no consensus)                   | Hide consensus line. Show "No consensus among Elite traders"                                 |
| HIP-1 spot token with low liquidity (<$100K 24h volume) | Show liquidity warning: "Low volume — impact costs high. Check impact prices before sizing." |

---

---

# PART III — FEED SYSTEM

---

# 1. Feed System

## Card Index — All 14 Cards

Quick reference. For full definitions, see the story where each card is introduced.

| #   | Card              | Alt | Feed     | Introduced | Freshness      | Persona      |
| --- | ----------------- | --- | -------- | ---------- | -------------- | ------------ |
| 13  | Watch Nudge       | A5  | My       | Story 3    | Batch-daily    | S7 Sarah     |
| 14  | WYWA              | A5  | My       | Story 4    | Live (<5s)     | S7 Sarah     |
| 3   | Leader Consensus  | A2  | My       | Story 4    | Live (<5s)     | S7 Sarah     |
| 4   | Watch Consensus   | A2  | My       | Story 4    | Live (<5s)     | S7 Sarah     |
| 7   | Divergence        | A2  | Both     | Story 4    | Session-fresh  | S7 Sarah     |
| 8   | Trader Move       | A3  | My       | Story 4    | Live (<5s)     | S7 Sarah     |
| 10  | Copy Earnings     | A5  | My       | Story 4    | Batch-daily    | S7 Sarah     |
| 12  | Weekly Rollup     | A5  | My       | Story 4    | Batch-weekly   | S7 Sarah     |
| 1   | Regime Shift      | A1  | Both     | Story 5    | Session-fresh  | S7 + S2 Jake |
| 2   | Funding Alert     | A1  | Both     | Story 5    | Session-fresh  | S7 + S2 Jake |
| 5   | Smart Money       | A2  | Discover | Story 5    | Session-fresh  | S7 + S2 Jake |
| 6   | Regime Specialist | A2  | Discover | Story 5    | Session-fresh  | S7 + S2 Jake |
| 9   | Recommended Move  | A3  | Discover | Story 5    | Near-real-time | S7 + S2 Jake |
| 11  | Recovery          | A5  | My       | Story 6    | Instant (<2s)  | S7 Sarah     |

**Cards not shown in Discover:** #3, #4, #8, #10, #11, #12, #13, #14 — all require a copy or follow relationship.
**Cards not shown in My Feed:** #5, #6, #9 — market intelligence, no relationship required.
**Cards in both:** #1, #2, #7 — market context relevant regardless of copy status.

## Freshness Tiers

| Tier                     | Latency        | Signals                                                | Why                               |
| ------------------------ | -------------- | ------------------------------------------------------ | --------------------------------- |
| **Instant** (<2s)        | Sub-300ms      | Copy execution, stop loss trigger, safety push         | Money is at stake                 |
| **Live** (<5s)           | 1–5s refresh   | P&L, safety bar, positions, prices, correlation        | "Am I okay?" check                |
| **Session-fresh** (5min) | Every 5 min    | Feed cards, regime, clusters, context line             | Periodic update                   |
| **Batch-daily**          | Overnight      | Consistency, streaks, activity, wallet size, followers | Slow-changing discovery metrics   |
| **Batch-weekly**         | Weekend        | Tier, strategy, risk, Sharpe ratio, max drawdown       | Profile metrics stable over weeks |
| **On-demand**            | When requested | Profile narrative, position reconstruction             | Lazy compute                      |

## Build Order (Recommended)

| Sprint | Focus                    | Components                                                                       |
| ------ | ------------------------ | -------------------------------------------------------------------------------- |
| 1      | API integration          | All 12 Hyperliquid endpoints + Arx database schema                               |
| 2      | Core computations        | portfolio, position, performance, and classification computations                |
| 3      | Regime + Copy + Safety   | Per-asset regime engine + copy trading + configurable safety                     |
| 4      | Clusters + Feed          | Cluster engine + feed cards 1–6                                                  |
| 5      | Remaining feed + Journey | Cards 7–12 + Sarah's journey state machine                                       |
| 6      | Leader signals           | Jake's pre-trade signals (Story 7): regime, clusters, market data, trigger cards |

**Launch scope, phase boundaries, and developer contract (cron schedules, rate budgets, verification checklist):** See v6 spec 0 and 9.

---

# END OF SPEC
