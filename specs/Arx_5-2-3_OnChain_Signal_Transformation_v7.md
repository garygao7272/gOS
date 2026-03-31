# Arx — On-Chain Signal Transformation (Story-First)

**Artifact ID:** Arx_5-2-3 (v7)
**Last Updated:** 2026-03-30
**Status:** Active
**Supersedes:** Arx_5-2-3_OnChain_Signal_Transformation_v6.md (retained as engineering reference for pseudocode and API schemas)
**References:** Personas (`2-1`), Radar Module (`4-1-1-4`), Feed (`4-1-1-4-1`), Wallets (`4-1-1-4-2`), Trader Taxonomy (`5-3`), Raw Data Dictionary (`5-2-3_Hyperliquid`), Design System (`4-2`, v5.7)

## How to Use This Spec

| You are...           | Read...                                                     | Then...                                                                                           |
| -------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| **Product / Design** | Part I (personas) + Part II (stories)                       | Each story = user journey + signal matrix. Enough to design screens and write acceptance tests.   |
| **Engineering**      | Part II (stories for context) + Part III (signal reference) | Part III has every computation ID, freshness tier, and data source. For full formulas, open v6.   |
| **QA**               | Part II Steps + Edge Cases                                  | Each story has Pre/Post conditions and numbered steps = test script. Edge cases = negative tests. |

**Related files:**

| File                                            | What It Contains                                                                                   | When to Use                                     |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| `Arx_5-2-3_OnChain_Signal_Transformation_v6.md` | Full pseudocode for C1-C14, API request/response schemas, DB schemas, cron schedules, rate budgets | When implementing any computation               |
| `Arx_5-3_Trader_Wallet_Label_Taxonomy.md`       | 10-dimension taxonomy with full thresholds, sub-labels, sort keys, filter behavior                 | When building filters, presets, or trader cards |
| `Arx_4-1-1-4_Mobile_Radar.md`                   | Radar module screen architecture, navigation, shared design language                               | When building Radar UI                          |
| `Arx_4-1-1-4-1_Radar_Feed.md`                   | Feed tab detailed screen spec                                                                      | When building the feed                          |
| `Arx_4-1-1-4-2_Radar_Wallets.md`                | Traders/Wallets tab detailed screen spec                                                           | When building the traders tab                   |
| `Arx_4-2_Design_System.md`                      | Color tokens, typography, spacing, component library (v5.7)                                        | When making any visual decision                 |

---

# TABLE OF CONTENTS

**Part I — Who & Why**

1. [Sarah (S7) — The Capital Allocator](#1-sarah-s7--the-capital-allocator)
2. [Jake (S2) — The Strategic Learner](#2-jake-s2--the-strategic-learner)
3. [Jobs to Be Done](#3-jobs-to-be-done)

**Part II — Radar Stories**

| #   | Story                | Persona  | Stage    |
| --- | -------------------- | -------- | -------- |
| 4   | Cold Start Discovery | S7 Sarah | S0       |
| 5   | Browsing & Filtering | S7 Sarah | S1       |
| 6   | Watching → Copying   | S7 Sarah | S2 → S3  |
| 7   | Monitoring (My Feed) | S7 Sarah | S3       |
| 8   | Discover & Explore   | S7 + S2  | S1+ / L0 |
| 9   | Warning & Recovery   | S7 Sarah | S3w      |
| 10  | Pre-Trade Analysis   | S2 Jake  | L0       |

**Part III — Signal Reference**

| #   | Section                        |
| --- | ------------------------------ |
| 11  | Signal → Story Cross-Reference |
| 12  | Computation Index (C1-C14)     |
| 13  | Cluster Consensus Engine (C10) |
| 14  | Display Object Schemas         |
| 15  | API Source Registry            |
| 16  | Feed System                    |

---

# PART I — WHO & WHY

---

# 1. Sarah (S7) — The Capital Allocator

Sarah has $10K–$100K in crypto. She doesn't trade herself — and she knows it. She's tried trading, lost money, and realized the gap between "understanding markets" and "making money trading" is enormous. She's not lazy; she's self-aware.

**What she wants:** Put her money behind someone who actually has edge. Check in briefly. Sleep at night.

**What she's afraid of:**

- Picking someone who _looks_ good but blows up (survivorship bias, one lucky trade)
- Not understanding when something goes wrong until it's too late
- Feeling stupid or out of control — the "I have no idea what's happening to my money" anxiety
- Getting rug-pulled by fake track records or inflated metrics

**What success feels like:** She opens the app, sees green, closes it in 30 seconds. Twice a day. On Mondays she reads a summary. Her money grows at 1-3% per month. She tells a friend about Arx.

**Her core questions on Radar** (everything Sarah sees must answer one of these):

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

Jake has $10K–$100K and trades his own ideas. He's T3-T4 skill — competent enough to be dangerous, not yet consistently profitable. He reads charts, follows macro, has opinions. He also becomes a **leader** on Arx — people copy him, and that earns him fees.

**What he wants:** Better market intelligence to sharpen his edge. A clearer picture of what smart money is doing. Position sizing that isn't guesswork.

**What he's afraid of:**

- Missing a trade because he didn't see the signal
- Sizing too large and getting liquidated
- Being wrong about the regime (trading a trend in a choppy market)

**What success feels like:** He opens Radar, immediately sees the market regime, what the Elite cluster is doing, and where consensus is forming. He sizes his trade with Kelly guidance. He manages his position with full awareness of regime shifts. His followers make money, and he earns 2bps per trade.

**His core workflow on Radar:**

| Stage           | Question                                      | Primary Surface          |
| --------------- | --------------------------------------------- | ------------------------ |
| L0 — Pre-Trade  | "What's the market doing? Where's the edge?"  | Radar Discover mode      |
| L1 — Execution  | "What size, what leverage, what stops?"       | Trade Panel              |
| L2 — Management | "How are my trades doing? Any regime shifts?" | Portfolio                |
| L3 — Review     | "Did I follow my process?"                    | Analytics [Phase 2]      |
| L4 — Leadership | "How are my followers doing?"                 | Leader Profile [Phase 2] |

---

# 3. Jobs to Be Done

## Sarah's Jobs (S7)

| JTBD                                           | Trigger                                         | Success Metric                               |
| ---------------------------------------------- | ----------------------------------------------- | -------------------------------------------- |
| **Find a trustworthy trader to copy**          | First app open, or when adding a new leader     | Copies a leader within first session         |
| **Compare traders to make a confident choice** | Browsing after initial discovery                | Narrows from 50+ to 2-3 candidates           |
| **Monitor my portfolio without anxiety**       | Every app open, 3-8x daily                      | Checks status in <30 seconds, feels informed |
| **Discover new traders and expand portfolio**  | Comfortable with first copy, curious about more | Adds a second leader within 30 days          |
| **Be protected when things go bad**            | Market crash, leader drawdown                   | Safety system fires before she panics        |
| **Recover after a loss event**                 | Post-safety-trigger, post-drawdown              | Makes a clear decision (resume or stop)      |

## Jake's Jobs (S2)

> Scope: only Radar-surface JTBDs listed here. Position sizing (Trade Panel) and portfolio management (Portfolio) are handled in their respective specs.

| JTBD                                             | Trigger                          | Success Metric                                 | Radar Story |
| ------------------------------------------------ | -------------------------------- | ---------------------------------------------- | ----------- |
| **Read the market regime before entering**       | Opening trading session          | Knows regime state + confidence in <10 seconds | Story 7     |
| **Know what smart money is doing**               | Any time during analysis         | Sees cluster consensus direction + strength    | Story 7     |
| **Find market signals that inspire trade ideas** | Browsing Discover feed passively | Identifies actionable setup in <15 seconds     | Story 5     |

# PART II — RADAR STORIES

---

# Story 1 — "When I open the app for the first time with money sitting idle, I want to see who's consistently making money with proof I can verify, so I can pick someone to copy without needing to be a trader myself."

**Persona:** Sarah (S7) | **Stage:** S0 — Cold Start | **JTBD:** Find a trustworthy trader to copy

**Pre:** Wallet connected with USDC balance. No follows or copies yet.
**Post:** Followed or copied at least one trader, or returned to keep browsing.

## Steps

1. Tap **Radar** in bottom nav → land on **Traders** sub-tab → see preset cards + Lucid search bar → §Presets
2. Tap a preset (e.g., "Consistent Winners") → filter bar reveals active filters built from taxonomy dimensions → trader list loads sorted by preset default
3. Scroll trader list → each card shows at-a-glance signals → §Trader Card
4. Tap a trader card → full profile opens with due diligence signals → §Trader Profile
5. Decide: tap **[Follow]** (→ Story 3) or **[Copy]** (→ Story 3 copy flow) or **back** (→ Story 2)

**Alt path:** At step 1, type in Lucid search bar instead of tapping a preset. Results show same card format.

## Signal Matrix

### §Presets — Curated Starting Points

Sarah's fear: "There are too many traders and I don't know where to start." Presets collapse the taxonomy into one-tap starting points.

Each preset combines two types of criteria:

- **Dimension filters** (F1-F10) — the 10 taxonomy dimensions, shown as filter chips in the filter bar
- **Metric conditions** — computed values (e.g., recent return thresholds), shown as condition badges in the filter bar

All criteria are visible and individually removable after selection. Wallets with Last Active = Dormant (D9: 30+ days inactive) excluded across all presets by default via platform toggle.

| Preset                     | What It Answers               | Dimension Filters                                                                                                 | Metric Conditions                                         | Default Sort                                                                        |
| -------------------------- | ----------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| **P1: Consistent Winners** | "Who keeps making money?"     | Track Record >= Rising. Consistency Score = 4/4 (D10). Sub-chip: Capital Scale = `[All] [Small] [Mid] [Large]`    | (none — dimension filters are sufficient)                 | Profit Streak                                                                       |
| **P5: Safe Hands**         | "Who won't blow up my money?" | Risk Behavior = Conservative or Moderate. Track Record >= Proven. Social Proof: Copyable = Yes.                   | (none — dimension filters are sufficient)                 | Sharpe (risk-adjusted return)                                                       |
| **P6: Popular Picks**      | "Who do other people trust?"  | Social Proof = Established or Top Leader or Alpha Source. Track Record >= Verified. Social Proof: Copyable = Yes. | (none)                                                    | Follower count. **†Gate:** hidden until ≥10 platform-wide copy relationships exist. |
| **P8: Hot This Week**      | "Who's making money NOW?"     | Track Record >= Verified.                                                                                         | Traded within last 7 days. Positive 7d Follower's Return. | 7-day Follower's Return                                                             |

**Phase 2 presets:**

| Preset                 | Dimension Filters                                                 | Metric Conditions                                                                |
| ---------------------- | ----------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| **P7: Regime Readers** | Regime Timing = Anticipator or Adapter. Track Record >= Verified. | (none)                                                                           |
| **P9: All-Weather**    | Track Record >= Verified.                                         | Profitable in >=3 of 4 regime types (trending, range-bound, compression, crisis) |

**How presets display in the filter bar:** When Sarah taps a preset, the filter bar shows dimension filters as chips (e.g., `[Risk: Conservative/Moderate]` `[Consistency: 4/4]`) and metric conditions as badges (e.g., `[7d active]`). Both are removable. The preset is a shortcut, not a cage.

### §Taxonomy — 10 Dimensions That Power Presets and Filters

Every preset, filter chip, and sort control maps to one of these dimensions. Each dimension answers one question about a trader's wallet that no other dimension can answer.

| Dim | Name                 | The Question                 | Labels                                                                                                                                 | How It's Calculated                                                                                                                                                                                                                                                                                                                               | User-Adjustable?                       |
| --- | -------------------- | ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| 1   | **Capital Scale**    | "How much money?"            | Shrimp (<$10K) / Fish ($10-50K) / Dolphin ($50-500K) / Whale ($500K-5M) / Mega Whale (>$5M)                                            | Total account equity, snapshot daily                                                                                                                                                                                                                                                                                                              | Yes — bracket boundaries               |
| 2   | **Strategy**         | "How do they trade?"         | Scalper / Day Trader / Swing Trader / Position Trader / HODLer                                                                         | Average hold time across 90 days of trades: <4h = Scalper, 4-24h = Day, 1-14d = Swing, 14-90d = Position, >90d = HODLer. Entry logic labels (Momentum/Carry/Mean Reversion) deferred to Phase 2 — require ML inference on entry patterns, not direct observation.                                                                                 | No                                     |
| 3   | **Track Record**     | "Are they good?"             | Elite / Proven / Verified / Rising / Unranked                                                                                          | Realized Return (closed P&L + net funding / avg equity) + Sharpe ratio. ALL conditions must be met per tier. See §Track Record below.                                                                                                                                                                                                             | Yes — min ROI, Sharpe, trade count     |
| 4   | **Risk Behavior**    | "How much risk?"             | Conservative / Moderate / Aggressive / Degen                                                                                           | Average leverage + worst drawdown + position sizing consistency. Conservative = leverage ≤3x AND worst drawdown >-10% AND consistent sizing. Degen = any ONE extreme: leverage >25x OR drawdown >-35% OR erratic sizing.                                                                                                                          | Yes — max leverage, max worst drawdown |
| 5   | **Market Focus**     | "What do they trade?"        | BTC-Focused / ETH-Focused / Multi-Coin / Cross-Asset / etc.                                                                            | Distribution of trades across assets over 90 days. ≥60% in one asset = "[Asset]-Focused." No single asset >40% = "Multi-Coin."                                                                                                                                                                                                                    | No [Phase 2]                           |
| 6   | **Social Proof**     | "Do others trust them?"      | Top Leader (400+ followers) / Established (100-400) / Emerging (10-100) / Private (no copy) / Alpha Source (copier returns in top 10%) | Follower count + copier median return. Alpha Source = regardless of follower count, copiers' median return is in top 10% platform-wide. **Cold start:** All Social Proof labels hidden until platform reaches ≥10 total copy relationships; prior to that, display per §Cold Start fallbacks.                                                     | No                                     |
| 7   | **Regime Timing**    | "Can they read shifts?"      | Anticipator / Adapter / Follower / Blind                                                                                               | Scored per regime transition (last 3 per ticker): Exit Score (reduced ≥20% exposure in 3d before shift) × 0.60 + Entry Score (entered aligned within 5d after shift) × 0.40. Weighted avg across ≥3 transitions → band label. [Phase 2] See §Regime Timing Algorithm. **Launch fallback:** sort defaults to Sharpe descending.                    | No                                     |
| 8   | **Current Exposure** | "What are they holding NOW?" | Heavy (>80% deployed) / Moderate (40-80%) / Light (10-40%) / Sidelined (<10%)                                                          | Total position value as percentage of account equity, measured in real-time. Plus per-asset breakdown (e.g., "60% in BTC, 25% in ETH").                                                                                                                                                                                                           | Yes — min %, asset filter              |
| 9   | **Last Active**      | "Are they still trading?"    | Active (traded in last 7d) / Recent (8-30d) / Quiet (31-90d) / Dormant (90d+)                                                          | Days since most recent closed or open position change. Dormant wallets are hidden by default across all views; toggle "Show inactive" to reveal.                                                                                                                                                                                                  | No                                     |
| 10  | **Consistency**      | "How steadily do they win?"  | 4/4 / 3/4 / 2/4 / 1/4 / 0/4                                                                                                            | Count of 4 rolling windows (7d, 30d, 60d, 90d) with positive closed P&L. Computed nightly. Only ~10-15% of active wallets score 4/4 at any given time. **Graceful degradation:** wallets with <90d history are scored on available windows only (e.g., 30d history → 2/2 not 2/4), displayed as N/M with tooltip explaining reduced window count. | No                                     |

Full dimension specs, threshold details, sub-labels, and sort keys: → [Arx_5-3_Trader_Wallet_Label_Taxonomy.md](Arx_5-3_Trader_Wallet_Label_Taxonomy.md)

### §Regime Timing Algorithm — How D7 Labels Are Assigned

**Data required:** Regime transition timestamps (from regime engine) + per-wallet position history. Minimum: ≥3 confirmed regime transitions with overlapping position history.

**Per-transition scoring:**

| Window                         | Measure                                                                     | Score             |
| ------------------------------ | --------------------------------------------------------------------------- | ----------------- |
| **Exit window** (T−3d to T−1d) | Did net exposure in affected assets drop ≥20% before the shift?             | 1 if yes, 0 if no |
| **Entry window** (T+0 to T+5d) | Was the first significant trade after the new regime directionally aligned? | 1 if yes, 0 if no |

**Aligned entry definition by new regime:**

- TRENDING → opened long / increased directional exposure
- RANGE_BOUND → reduced leverage, opened range-sized positions
- COMPRESSION → moved toward sidelined / reduced open interest
- CRISIS → moved to sidelined or cash-equivalent

**Weighted score per transition:**

```
transition_score = (exit_score × 0.60) + (entry_score × 0.40)
```

**Label assignment (last 3 transitions per primary ticker):**

```
weighted_avg = mean(transition_score) across last 3 transitions

Anticipator   ≥ 0.70   exits early AND enters early — reads the shift
Adapter       0.50–0.69 adjusts after the shift, doesn't fight it
Follower      0.30–0.49 gets there eventually, slow
Blind         < 0.30   no observable relationship to regime shifts
```

**Constraints:**

- Minimum 3 confirmed transitions (regime engine held new state ≥24h) with overlapping wallet history → otherwise null (wallet excluded from D7 filter)
- "Last 3 per ticker" prevents stale behavior from inflating recent scores
- Phase 2 only: not computed at MVP; D7 filter hidden until sufficient regime history exists platform-wide

### §Track Record Tiers (ALL conditions must be met per tier)

Track Record is Dimension 3 of the taxonomy. It determines the badge displayed on every trader card.

**Realized Return** = sum of all closed P&L plus net funding payments, divided by average account equity over the period. Funding payments are real cash flows in perpetual futures (not accounting entries) and must be included. All-time is the default; the Trader Card also supports toggling to 7d, 30d, or 90d views.

**Calculation roadmap:** MVP uses realized return (closed P&L + net funding / avg equity) from public Hyperliquid API. V1.1 upgrades to Time-Weighted Return (TWR) — sub-period returns chained at deposit/withdrawal boundaries, eliminating capital-flow distortion. V2 adds Sharpe-on-TWR for risk-adjusted tier ranking.

**Sharpe** = risk-adjusted return: annualized return divided by annualized volatility of daily equity changes. Measures how much return was earned per unit of risk taken. Above 1.5 is excellent.

| Tier         | All-Time Realized Return | Sharpe (risk-adjusted return) | Min Trades | Badge                   |
| ------------ | ------------------------ | ----------------------------- | ---------- | ----------------------- |
| **Elite**    | >= 30%                   | >= 1.5                        | 50+        | Gold                    |
| **Proven**   | >= 15%                   | >= 1.0                        | 50+        | Purple                  |
| **Verified** | >= 5%                    | >= 0.7                        | 50+        | Green                   |
| **Rising**   | > 0%                     | any                           | 10-49      | Yellow                  |
| **Unranked** | any                      | any                           | < 10       | Hidden from leaderboard |

### §Trader Card — What Sarah scans in <2 seconds to decide whether to tap

Sarah's fear: picking someone who looks good but blows up. Every field on this card fights one specific anxiety.

**Card anatomy:** `[Avatar] @Name [Badge] | [Strategy chip] [Wallet chip]` — then a liveness sub-line, then 5 core signals. The two chips are identity context, not primary decision signals.

The **Time Window view control** `[7d] [30d●] [90d]` at the top of the trader list is a **display control, not a filter**. It does not classify wallets or narrow the list — it recalculates the time-dependent display values on every visible card simultaneously. See §View Controls below.

| Signal                              | Display                        | How It's Built                                                                                                                                                                                | Time-Togglable?                    |
| ----------------------------------- | ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| **Track Record Badge** (header)     | Gold / Purple / Green / Yellow | Tier from §Track Record Tiers. Shown in card header next to name.                                                                                                                             | No — always all-time               |
| **Strategy** (header chip)          | `Swing Trader`                 | D2: 90-day avg hold time. Header chip — identity context, not a decision signal.                                                                                                              | No                                 |
| **Wallet Size** (header chip)       | `Dolphin`                      | D1: equity bracket. Header chip.                                                                                                                                                              | No                                 |
| **Last Active** (liveness sub-line) | `Active · 3h ago`              | D9: days since last trade. Sub-line under name. Prevents ghost-wallet: high badge, stopped trading.                                                                                           | No — always live                   |
| **Follower's Return**               | `+8.2%`                        | Total copier P&L divided by total copier allocation over the selected window. Day-1 fallback: leader's own return labeled "Leader's Return."                                                  | **Yes** — 7d / 30d (default) / 90d |
| **Worst Month**                     | `-3.1%`                        | Worst calendar month in entire equity history. Downside anchor — Sarah can see return and risk together on the card without opening the profile.                                              | No — always all-time               |
| **Consistency Score**               | `4/4`                          | D10: profitable in all 4 rolling windows (7d, 30d, 60d, 90d). ~10-15% of active wallets score 4/4.                                                                                            | No — always checks all 4 windows   |
| **Current Exposure**                | `Moderate · 60% BTC`           | D8: position value as % of equity, real-time. "Sidelined" if <10% deployed. Top single-asset concentration shown if ≥40% in one asset. Answers: "are they actively doing anything right now?" | No — always live                   |
| **Spots Remaining**                 | `77 spots left`                | Max copy capacity minus current followers. Scarcity signal that drives conversion urgency.                                                                                                    | No                                 |

**Moved to §Trader Profile:** Profit Streak and Win Rate. Both require interpretive context (win rate varies by strategy type; streak duration needs regime context) — valuable in due-diligence but cognitive noise on a 2-second scan card.

### §Trader Profile — Due diligence Sarah reads before committing money

Sarah has tapped a card. She is deciding whether to trust this person with her capital. The profile is organized in three layers: **performance history** (verify the track record), **current activity** (see what they're in right now), and **copy setup** (commit with a safety net).

**Layer 1 — Performance History:**

| Signal                    | Display                      | How It's Built                                                                                                                                 | Time-Togglable?                    |
| ------------------------- | ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| **Equity Curve**          | Chart                        | Running equity from closed positions + cumulative funding. Tabs: 30d (default) / 7d / 90d / All-time.                                          | **Yes** — tab switches chart range |
| **Sharpe Ratio**          | `1.8` (risk-adjusted return) | Annualized return / annualized volatility of daily equity. Above 1.5 = excellent. All-time.                                                    | No                                 |
| **Worst Drawdown**        | `-12.4%`                     | Worst peak-to-trough loss in all-time equity curve. "The worst it ever got."                                                                   | No                                 |
| **Win Rate**              | `68%`                        | Profitable closings / total closings. Shown alongside avg trade duration for context (e.g., "68% · avg 3.2d"). <5 trades in window: shows "—". | **Yes** — 7d / 30d (default) / 90d |
| **Profit Streak**         | `12 weeks running`           | Consecutive Mon-Sun weeks with positive closed P&L, counting backward from today. Resets to zero on any losing week.                           | No — always backward from today    |
| **Copier Total Earnings** | `$47K earned for followers`  | Total P&L generated for all copiers, all relationships, all-time. Cold start: hidden if zero.                                                  | No                                 |
| **Regime State**          | `TRENDING 12d` (green)       | Current market regime for assets this leader trades. → See §Regime Engine (Story 3)                                                            | No — live                          |

**Layer 2 — Current Activity (live):**

| Signal                | Display                | How It's Built                                                                                                                                                                                               |
| --------------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Current Positions** | Up to 3 open positions | From live account state. Each row: Asset · Direction · Size · Entry Price · Current P&L · Leverage. Example: `BTC Long · $12K · entry $68,200 · +$840 (+7.0%) · 5x`. "No open positions right now" if empty. |
| **Recent Trades**     | Last 5 closed trades   | From userFills (closed positions). Each row: Asset · Direction · Hold Duration · P&L%. Example: `BTC Long · 3d · +4.2%`. Shows last available if no trades in 30d, with date.                                |

Engineering note: Current Positions and Recent Trades map to C15 (live positions) and C16 (fills history) — see §Computation Index stubs.

**Layer 3 — Copy Setup (sticky footer):**

| Signal                     | Display        | How It's Built                                                                                                       |
| -------------------------- | -------------- | -------------------------------------------------------------------------------------------------------------------- |
| **Copy Wizard Projection** | `Avg +$128/mo` | Follower's 30d Return % multiplied by Sarah's proposed allocation. Updates live as she adjusts the allocation input. |

### §Cold Start — Day 1 Fallbacks

| Signal                | Day-1 Problem                            | Fallback                                                             |
| --------------------- | ---------------------------------------- | -------------------------------------------------------------------- |
| Follower's Return     | No copiers                               | Leader's own 30d return, labeled "Leader's 30d"                      |
| Track Record tier     | No copier component (removed from tiers) | ROI 55% + Sharpe 45% (copierProfit not required — see §Track Record) |
| Social Proof labels   | <10 platform-wide copy relationships     | All Social Proof labels hidden; D6 displays as "—"                   |
| P5 "Safe Hands"       | Copyable = 0                             | Drop Social Proof: Copyable filter, label "Copy coming soon"         |
| P6 "Popular Picks"    | <10 platform-wide copy relationships     | Entire P6 preset hidden from preset list                             |
| Copier Total Earnings | No copiers                               | Hide field entirely                                                  |
| Spots Remaining       | Copy not live                            | Show "Coming soon"                                                   |

## Edge Cases

| Condition                  | Behavior                                                        |
| -------------------------- | --------------------------------------------------------------- |
| <10 traders match a preset | Show results + "More traders coming" banner                     |
| All presets return 0       | Show trending traders sorted by 7d return, no preset active     |
| Lucid search returns 0     | "No matches. Try a preset ->" with link to presets              |
| Trader at full capacity    | Card shows "Full" badge, [Copy] disabled, [Follow] still active |

---

# Story 2 — "When I have a list of traders but need to narrow it down, I want to toggle time windows, stack filters, and sort by different metrics, so I can compare them head-to-head and make a confident choice."

**Persona:** Sarah (S7) | **Stage:** S1 — Browsing | **JTBD:** Compare traders to make a confident choice

**Pre:** Trader list visible from Story 1 preset or search. Filter bar shows active filters. Still on Radar > Traders sub-tab.
**Post:** Narrowed to 2-3 candidates. Followed, copied, or still comparing.

## Steps

Sarah's comparison loop typically cycles 2–3 times before she commits. The loop is: preset → tweak → scan → tap profile → [Back] → re-sort → narrow to 2–3 finalists.

1. **Start** from a preset (carried from Story 1) or tap **[Clear All]** to see the full unfiltered list. Active filters shown as chips in filter bar.
2. **Toggle Time Window** `[7d] [30d●] [90d]` → all cards update simultaneously (list unchanged) → §View Controls, §Time Metrics
3. **Tap a filter chip** to add a dimension filter (e.g., F2: Swing Trader, F4: Conservative) → list narrows. Stack up to 5 filters. → §Filters
4. **Adjust threshold sliders** on configurable filters (e.g., ROI > 20% AND Sharpe > 1.0) → §Filters
5. **Tap sort control** → pick from §Sort Mechanisms → list reorders instantly
6. **Scroll and compare** → cards show relationship badge (blue = Watching, purple = Copying +$X)
7. **Tap a card** → full profile opens → §Trader Profile (Story 1)
8. **Decide:** [Follow], [Copy], or **[← Back]** to return to the list with all filters and sort preserved
9. **Iterate:** re-sort by a different dimension, adjust a slider, repeat steps 6–8 until narrowed to 2–3 finalists

## Signal Matrix

### §Time Metrics — How Sarah compares the same trader across different windows

Sarah's need: "Are they good right now, or were they good months ago?" Time toggling lets her separate recency from track record.

| Metric             | 7d        | 30d         | 90d          | How It's Built                                   |
| ------------------ | --------- | ----------- | ------------ | ------------------------------------------------ |
| **Return %**       | This week | This month  | Quarter      | Closed P&L / equity at window start              |
| **Win Rate**       | This week | This month  | 90-day       | Profitable closings / total closings. <5 -> "--" |
| **Sharpe**         | Not shown | Noisy       | Reliable     | Annualized return / annualized volatility        |
| **Worst Drawdown** | Not shown | Recent only | Full picture | Worst peak-to-trough in equity curve             |
| **Profit Factor**  | Not shown | Available   | Reliable     | Total won / total lost. >1.5 = solid edge        |

### §Filters — 10 Taxonomy Dimensions

Sarah's need: "I know what I want — let me say it." Each filter maps to exactly one taxonomy dimension.

| Filter            | Dim | Type                         | Default                      | Adjustable                             |
| ----------------- | --- | ---------------------------- | ---------------------------- | -------------------------------------- |
| F1: Capital Scale | 1   | Single-select                | All                          | Yes — brackets                         |
| F2: Strategy      | 2   | Multi-select                 | All                          | No                                     |
| F3: Track Record  | 3   | Multi-select + sliders       | All (excl. Unranked)         | Yes — min ROI, Sharpe, trades          |
| F4: Risk Behavior | 4   | Single-select + sliders      | All                          | Yes — max leverage, max Worst Drawdown |
| F5: Market Focus  | 5   | Multi-select                 | All                          | No [Phase 2]                           |
| F6: Social Proof  | 6   | Multi-select + toggle        | All, "Copyable only" ON      | No                                     |
| F7: Regime Timing | 7   | Single-select                | All                          | No [Phase 2]                           |
| F8: Exposure      | 8   | Single-select + asset picker | All                          | Yes — min %, specific asset            |
| F9: Last Active   | 9   | Single-select                | Active + Recent (hides 90d+) | No — platform default hides Dormant    |
| F10: Consistency  | 10  | Single-select (min score)    | All                          | No                                     |

Platform default: F9 excludes Dormant wallets (Last Active = 90d+). Toggle "Show inactive" to reveal them.

### §View Controls — Display State, Not Filters

View controls change how data is **displayed** on cards. They do not classify wallets, narrow the list, or appear as filter chips. A trader who appears under the 30d view also appears under 7d — only the metric values displayed change.

| Control         | UI Element                        | What It Changes                                       | What It Does NOT Change                              |
| --------------- | --------------------------------- | ----------------------------------------------------- | ---------------------------------------------------- |
| **Time Window** | `[7d] [30d●] [90d]` toggle at top | Follower's Return, Win Rate, Return % displayed value | Which traders appear, trader card sort order, badges |

**Time Window behavior:**

- Default: 30d
- Affects: Follower's Return display, Win Rate display, Return % in §Time Metrics table
- Does NOT affect: Track Record Badge (always all-time), Consistency Score (always checks all 4 windows), Worst Month (always all-time), Profit Streak (always backward from today), Spots Remaining (live)
- If selected window has < 5 trades: show `—` for that metric

**Key distinction from filters:** If Sarah has F3 set to Track Record >= Verified and switches Time Window from 30d to 7d, the list of traders shown is identical. Only the return % values on each card update.

### §Sort Mechanisms — How Sarah ranks the list

All 8 sorts are available at MVP. Each answers a different question. Time-window-aware sorts update when Sarah changes the Time Window toggle.

| Sort                              | Ranks By                                        | Question It Answers                    | Time-Window?              | Notes                                                                       |
| --------------------------------- | ----------------------------------------------- | -------------------------------------- | ------------------------- | --------------------------------------------------------------------------- |
| **Follower's Return** _(default)_ | What copiers earned in selected window (C13.2)  | "Who actually made people money?"      | ✅ Yes                    | Day-1 fallback: leader's own return labeled "Leader's Return"               |
| **Win Rate**                      | % profitable closings in selected window (C3.5) | "Who wins most consistently?"          | ✅ Yes                    | Hides traders with <5 trades in window (`—`)                                |
| **Worst Month**                   | Worst 30d return, all-time (C13.3)              | "Who keeps drawdowns small?"           | No — always all-time      | Lets Sarah compare return and risk without opening profiles                 |
| **Sharpe Ratio**                  | Risk-adjusted return, 90d (C3.2)                | "Who earns most per unit of risk?"     | No — 90d only             | Best for final comparison of 2–3 finalists; noisy at shorter windows        |
| **Consistency Score**             | Count of 4 windows profitable (D10)             | "Who makes money in every time frame?" | No — always all 4 windows | ~10–15% of active wallets score 4/4 at any time                             |
| **Spots Remaining**               | Copy capacity remaining, ascending              | "Who is in high demand?"               | No — live                 | Low spots = scarcity signal. Surfaces leaders near capacity first.          |
| **Capital Scale**                 | Total account equity, descending (D1)           | "Who has the most skin in the game?"   | No — daily snapshot       | Large wallets less likely to self-destruct; alignment signal                |
| **Recent Activity**               | Days since last trade, ascending (D9)           | "Who is actively trading right now?"   | No — live                 | Dormant wallets hidden by default. Sort reveals most recently active first. |

## Edge Cases

| Condition                       | Behavior                                            |
| ------------------------------- | --------------------------------------------------- |
| Filter combo returns 0 results  | "No matches. Remove a filter?" with chip highlights |
| Time toggle to 7d with <5 fills | Show "--" for metrics that need minimum data        |
| User removes all filters        | Return to full list, no preset active               |
| Sort + filter yields <3 results | Show results + "Try fewer filters" nudge            |

---

# Story 3 — "When I've been watching a trader for a few days and their moves look good, I want the app to show me what I've missed and make it easy to start copying, so I can commit capital with confidence."

**Persona:** Sarah (S7) | **Stage:** S2 — Watching → Copying | **JTBD:** Convert from watcher to copier

**Pre:** Following ≥1 trader for ≥3 days. Has been watching Trader Move cards in the feed. Not yet copying.
**Post:** Actively copying with safety limit set. Enters Story 4 (My Feed monitoring).

## Steps

1. Open app → Radar > **My Feed** → see **Watch Nudge** card pinned at top → §Watch Nudge
2. Card shows: how much the leader's copiers earned since Sarah started watching, copier count, current regime
3. Tap **[Copy Now]** on the card (or tap leader name → re-opens full profile from Story 1 §Trader Profile)
4. **Copy Wizard** opens: enter allocation amount → monthly projection updates live → §Safety
5. Review **regime context pill** inline: TRENDING = green / CRISIS = warning with reduced recommendation
6. Set **safety limit** (default 50%, range 20-90%) → preview green/amber/red zones
7. Tap **[Confirm Copy]** → copy activates

## Signal Matrix

### §Watch Nudge — The feed card that converts a watcher into a copier

Sarah's emotional trigger: "I've been watching — now I can see exactly what I missed." The nudge quantifies the cost of inaction in real P&L terms.

| Signal              | Display                                                           | How It's Built                                                                                               |
| ------------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| **Missed Earnings** | "@SwingMaster's 23 copiers made +$847 since you started watching" | Follower's Return % since Sarah's follow date × median active copier allocation. Plain dollar figure, not %. |
| **Copier Count**    | `23 people copying`                                               | Current active copier count at time of card render                                                           |
| **Regime Context**  | `TRENDING 12d` (green pill)                                       | Current regime for this leader's primary assets — inline copy timing signal                                  |
| **CTA**             | `[Copy Now]`                                                      | Opens Copy Wizard directly, pre-filled with this leader                                                      |

**Card trigger conditions:**

- Sarah has been following (not copying) this leader for ≥3 days
- Leader had positive Follower's Return during that watch period
- Dismissed: card disappears after viewing; re-surfaces after 7 days if still not copying

### §Copier Social Proof — At the moment of commitment

Sarah's need at the copy wizard: "I'm not the only one who sees this is good." Not asset consensus (that's Jake) — social proof that real people are copying and profiting.

| Signal                 | Display                   | How It's Built                                                       |
| ---------------------- | ------------------------- | -------------------------------------------------------------------- |
| **Active Copiers**     | `23 people copying`       | Current active copier count                                          |
| **Median Return**      | `Median +6.2% this month` | Median Follower's Return across all active copiers in current window |
| **Social Proof Label** | `Established`             | D6 Social Proof dimension label                                      |

### §Regime Engine — Copy timing context

Sarah's need: "Is now a good time to start copying?" Regime is shown inline in the Copy Wizard as a green/amber/red signal — not a separate analysis panel.

| State           | Color       | Copy Sizing | Inline Message                                     |
| --------------- | ----------- | ----------- | -------------------------------------------------- |
| **TRENDING**    | Green       | 1.0x        | "Good conditions for copy trading"                 |
| **RANGE_BOUND** | Blue        | 0.5x        | "Choppy market — watch safety bar closely"         |
| **COMPRESSION** | Amber       | 0.3x        | "Low volatility — smaller allocation recommended"  |
| **CRISIS**      | Deep Orange | 0.1x        | "High volatility — wizard recommends smaller size" |
| **TRANSITION**  | Grey        | 0.25x       | "Unclear conditions — caution"                     |

Per-asset classification. Portfolio regime = worst-case across all assets this leader trades. The allocation wizard automatically pre-scales the recommendation to the regime multiplier; Sarah can override.

### §Safety — Circuit Breaker Setup

Sarah's need: "What if it goes wrong while I'm asleep?" The safety limit is a server-side kill switch that fires even if her phone is off.

- **Limit:** User sets max loss tolerance (default 50%, range 20-90%). Per-leader override allowed.
- **Zones** (scaled to chosen limit): Green Healthy (0 to limit × 0.6), Amber Watch (limit × 0.6 to limit × 0.8), Red Danger (limit × 0.8 to limit)
- **Auto-pause:** At 100% of limit → server-side pause, even if phone is off
- Example: 50% limit → zones 0-30% / 30-40% / 40-50%. Pauses at 50% loss.

## Edge Cases

| Condition                                           | Behavior                                                                                |
| --------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Regime = CRISIS when copy attempted                 | Wizard warns: "High volatility. Recommended allocation reduced to 0.1x. Are you sure?"  |
| Leader at full capacity                             | [Copy] disabled. "Join waitlist" shown instead.                                         |
| Insufficient wallet balance                         | Wizard shows max available and prevents overshoot                                       |
| Leader had 0 or negative return during watch period | Watch Nudge card suppressed. Sarah only sees it when inaction had a real positive cost. |

---

# Story 4 — "When I open the app during my day, I want to see in 30 seconds whether my money is safe and what happened, so I can close the app and get on with my life."

**Persona:** Sarah (S7) | **Stage:** S3 — Copying | **JTBD:** Monitor without anxiety

**Pre:** Actively copying at least one trader. Notifications enabled.
**Post:** Informed and reassured (→ close app), curious about markets (→ Story 5 Discover), or concerned (→ Story 6 Recovery).

## Steps

1. Open app -> Radar loads with **Feed** sub-tab as default for users with active copies
2. Scan **top-of-screen summary** in <5 seconds -> §Live Signals
3. Read **context line**: "All healthy, portfolio trending 12d" + regime pill
4. Scroll **feed** -> cards in priority order -> §Feed Cards
5. Read relevant cards -> each is a self-contained story at one altitude -> §Altitudes
6. Close app. 30-second check complete.

**While You Were Away** (after 24h+ absence):

1. Open app -> Radar loads -> **Feed** sub-tab -> pinned WYWA card at top
2. Card shows: safety status (first), absence duration, total earned, per-leader breakdown
3. Tap to dismiss -> regular feed

**Weekly Summary** (Mondays after first copy):

1. Open app -> Radar loads -> **Feed** sub-tab -> Weekly Rollup card
2. Shows: weekly P&L, all-time P&L, per-leader stats, market summary

## Signal Matrix

### §Live Signals — What Sarah sees before she even scrolls (refresh 1-5s)

Sarah's question: "Am I okay?" Every signal in this strip answers that in under 5 seconds.

| Signal                | Display                          | How It's Built                                               |
| --------------------- | -------------------------------- | ------------------------------------------------------------ |
| **Total P&L**         | `+$28.13 today`                  | Closed + unrealized P&L across all copies for current day    |
| **Per-Leader Chips**  | `@SwingMaster +$47` (green)      | Per-leader copy equity change since allocation               |
| **Safety Bar**        | `22% used` (green)               | Percentage of loss tolerance consumed. See §Safety (Story 3) |
| **Portfolio Equity**  | `$12,450`                        | Total account value                                          |
| **Correlation Alert** | `Both leaders long BTC — $4,200` | 2+ copied leaders same asset + same direction                |

### §Altitudes — Feed Card Layers

Sarah's need: "What level of detail do I need right now?" Cards are organized from macro to personal so she can stop scrolling the moment she's satisfied.

| Altitude      | Scope        | Question                       | Example                           |
| ------------- | ------------ | ------------------------------ | --------------------------------- |
| A1 — Market   | Environment  | "What's happening?"            | "BTC shifted to TRENDING"         |
| A2 — Group    | Consensus    | "What does smart money think?" | "Your leaders all long BTC"       |
| A3 — Trader   | Individual   | "What did they do?"            | "@SwingMaster opened BTC Long 5x" |
| A4 — Position | Trade detail | (Embedded in A3/A5)            | --                                |
| A5 — Personal | Your money   | "Am I okay?"                   | "Your copy: +$13.50"              |

### §Feed Cards — 13 MVP Types

Sarah's need: "What happened while I wasn't looking?" Each card is a self-contained update she can read, understand, and dismiss in seconds.

| #   | Card              | Alt | Trigger                                                       | Display                                                                       | Feed     |
| --- | ----------------- | --- | ------------------------------------------------------------- | ----------------------------------------------------------------------------- | -------- |
| 1   | Regime Shift      | A1  | Regime transition                                             | "BTC shifted to TRENDING. Leaders win 68% in trending."                       | Both     |
| 2   | Funding Alert     | A1  | Rate extreme                                                  | "BTC longs paying +42% APR"                                                   | Both     |
| 3   | Leader Consensus  | A2  | >=60% copied agree                                            | "3 of 4 leaders long BTC. Entered at $68,200 (+1.9%)"                         | My       |
| 4   | Watch Consensus   | A2  | >=60% watched agree                                           | Same, cyan border                                                             | My       |
| 5   | Smart Money       | A2  | Elite consensus                                               | "72% of Elite traders long BTC"                                               | Discover |
| 6   | Regime Specialist | A2  | Regime Winners                                                | "80% of trending specialists long BTC"                                        | Discover |
| 7   | Divergence        | A2  | Clusters disagree                                             | "Your leaders disagree with smart money" (amber)                              | Both     |
| 8   | Trader Move       | A3  | Leader trade                                                  | "@SwingMaster opened BTC Long 5x — Your copy: +$13.50"                        | My       |
| 9   | Recommended Move  | A3  | Elite/Proven trade                                            | Same format, CTA: [Follow] [Copy]                                             | Discover |
| 10  | Copy Earnings     | A5  | Daily 8am local                                               | "Yesterday: +$47.20. Best: @SwingMaster +$33"                                 | My       |
| 11  | Recovery          | A5  | Safety triggered                                              | "@Alpha hit limit. -$420. [Resume] [Stop]" (RED, PINNED)                      | My       |
| 12  | Weekly Rollup     | A5  | Mondays                                                       | "This week: +$87.20. All-time: +$1,245 (+14.6%)"                              | My       |
| 13  | Watch Nudge       | A5  | Following ≥3d, not copying, leader profitable in watch period | "@SwingMaster's 23 copiers made +$847 since you started watching. [Copy Now]" | My       |

Ordering: Pinned > Critical > High > Normal > Low. My Feed > Discover. >24h -> "Earlier" section.
Dedup: Same leader+asset+direction within 5min -> merge. Safety + Recovery -> Recovery only.

### §Push Notifications

Sarah's need: "Tell me when something matters so I don't have to check constantly."

| Type               | Priority | Trigger                           |
| ------------------ | -------- | --------------------------------- |
| Safety triggered   | Critical | Circuit breaker 100%              |
| Safety approaching | High     | Circuit breaker > 60%             |
| Regime mismatch    | Medium   | Leader WR < 50% in current regime |
| Leader inactive    | Medium   | No trades 14+ days                |
| Regime change      | Medium   | State transition                  |
| Copy executed      | Low      | Leader trade -> copy placed       |
| Daily P&L          | Low      | End of day                        |

## Edge Cases

| Condition                              | Behavior                                                                                           |
| -------------------------------------- | -------------------------------------------------------------------------------------------------- |
| Feed empty (S0 user navigates to Feed) | Discover-mode cards only + banner: "Follow traders to see their activity. Start on Traders tab ->" |
| All leaders inactive 14+ days          | Push "Leader inactive" + feed banner: "Your leaders haven't traded recently"                       |
| Stale data (>15 min)                   | Cards show "delayed" indicator. After 15 min stale -> suppress entirely                            |
| Card with null primary field           | Suppress card. Never show broken data.                                                             |

---

# Story 5 — "When I open the app with time to browse, I want to see what's happening in the market and discover interesting traders, so I can stay informed and find opportunities."

**Persona:** Sarah (S7) + Jake (S2) | **Stage:** S1+ (Sarah) / L0 (Jake) | **JTBD:** Discover new traders and expand portfolio (S7) · Find market signals that inspire trade ideas (S2)

**Pre:** App open. User is not responding to an alert — this is a curiosity-driven open.
**Post:** S7: followed or bookmarked a new trader, or absorbed market context. S2: identified a signal worth analyzing → proceeds to Story 7, or decided to wait.

## Steps

**S7 (Sarah) path:**

1. Open app → Radar → tap **[Discover]** toggle in Feed tab (or land here by default if no active copies)
2. Scan **Market Overview strip** at top → current regime + dominant cluster consensus → §Market Overview
3. Scroll Discover feed → cards ordered by priority: Regime Shift → Smart Money → Regime Specialist → Recommended Move → Funding Alert → §Discover Feed Cards
4. Tap a **Recommended Move** card → [Follow] CTA → opens trader profile (Story 1 §Trader Profile)
5. Tap **[Copy]** from profile → enters Story 3 copy wizard
6. Or: tap **[View all Elite traders →]** on a Smart Money card → Traders tab filtered to Elite + Proven, sorted by Follower's Return

**S2 (Jake) path:**

1. Open app → Radar → Discover feed (or Feed tab → Discover toggle)
2. Scan Market Overview strip → regime state, cluster direction, funding alert count → §Market Overview
3. Read **Smart Money card** or **Regime Shift card** → directional signal forms
4. Tap **[Analyze →]** on any signal card → asset detail view loads with regime context pre-populated
5. Proceed to Story 7 (Pre-Trade Analysis) or close if signal doesn't meet entry criteria

## Signal Matrix

### §Market Overview Strip — What Both Personas See First

The top strip is a single-glance market dashboard. Loads on Discover open, refreshes every 5 min.

| Signal                      | Display                                 | How It's Built                                                          |
| --------------------------- | --------------------------------------- | ----------------------------------------------------------------------- |
| **Regime per asset**        | `BTC TRENDING 12d` `ETH RANGE_BOUND 4d` | C5.1 per top 3 assets by OI. Duration since last transition.            |
| **Elite cluster direction** | `72% of Elite traders long BTC`         | C10.1 Performance Elite cluster. Shown only when ≥60% consensus exists. |
| **Active alerts count**     | `2 funding alerts active`               | Count of active Funding Alert cards in current feed session.            |

### §Discover Feed Cards — What Surfaces in Discover Mode

Discover mode shows only cards relevant to market intelligence and trader discovery — not personal portfolio cards. Sarah sees CTAs oriented toward traders; Jake sees CTAs oriented toward analysis.

| Card                       | Alt | Trigger                    | S7 CTA                                               | S2 CTA                                                       |
| -------------------------- | --- | -------------------------- | ---------------------------------------------------- | ------------------------------------------------------------ |
| **Regime Shift** (#1)      | A1  | Regime transition          | Passive — read for context                           | `[Analyze →]` opens asset with regime pre-loaded             |
| **Funding Alert** (#2)     | A1  | Rate extreme               | Passive — market awareness                           | `[Analyze →]` opens asset; funding shown as cost/opportunity |
| **Smart Money** (#5)       | A2  | Elite ≥60% consensus       | `[View all →]` filters Traders tab to Elite cluster  | `[Analyze →]` opens asset with consensus data pre-loaded     |
| **Regime Specialist** (#6) | A2  | Regime Winners ≥60% agree  | `[View all →]` filters Traders tab to Regime Winners | `[Analyze →]` same as Smart Money                            |
| **Recommended Move** (#9)  | A3  | Elite/Proven trader action | `[Follow]` / `[Copy]` — opens trader profile         | `[Watch]` — adds trader to Jake's watched list               |

**Card ordering in Discover feed:** Regime Shift and Funding Alerts first (time-sensitive), then Smart Money and Regime Specialist (consensus intelligence), then Recommended Move cards (individual trader actions). Dedup: same asset+direction within 5 min → merge into one card.

**Note:** Cards #3 (Leader Consensus), #4 (Watch Consensus), #8 (Trader Move), #10 (Copy Earnings), #11 (Recovery), #12 (Weekly Rollup), and #13 (Watch Nudge) are My Feed only — they require an active copy or follow relationship and are not shown in Discover.

## Edge Cases

| Condition                                              | Behavior                                                                                        |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| No active clusters (market too thin)                   | Smart Money card not shown. Strip shows "No cluster consensus today."                           |
| Regime = TRANSITION across all assets                  | Show "Markets in flux — no clear regime signal" in strip                                        |
| No Elite/Proven traders active in 30d                  | Recommended Move cards suppressed. Show "Discover more traders" banner pointing to Traders tab. |
| Jake taps [Analyze →] with no asset detail spec loaded | Opens asset overview with regime + market signals from §Market Overview (Story 7 context)       |

---

# Story 6 — "When something goes wrong and the system paused my copies, I want to understand what happened and make a clear decision about what to do next."

**Persona:** Sarah (S7) | **Stage:** S3w — Warning | **JTBD:** Recover after loss

**Pre:** Safety limit reached for one or more leaders. System auto-paused copies (server-side). Critical push sent.
**Post:** Resumed with cooldown (open positions stay open), or stopped with capital returned (~2 min).

## Steps

1. **Receive push notification** (lock screen):
   `"@AlphaTrader hit your 50% loss limit. Copies paused. -$420."`
   Format: `"@{leader} hit your {limit}% loss limit. Copies paused. {net_pnl}."`

2. **Tap notification** → app opens to **Radar > Feed > My** → **Recovery Card** pinned at top, red border, above all other cards

3. **Recovery Card** shows current state (see §Recovery Card States below):
   - Leader name + avatar: "@AlphaTrader"
   - Loss amount: "-$420 (52% of safety limit)"
   - Capital secured: "$2,250 of $2,500 returned to balance"
   - Trigger reason: "BTC dropped 15% in 4h. Hit 50% limit."
   - Card state: **LIMIT HIT**

4. **Read contextual signals** (if present, shown below the trigger reason):
   - **Correlation alert**: "Both @Alpha and @SwingMaster are long BTC — combined $4,200 exposure still open"
   - **Regime mismatch**: "@Alpha wins only 52% in choppy markets (current regime: RANGE_BOUND)"

5. **Decision tree** — two buttons with consequence text shown inline on the card:

   | Option     | Button                    | Consequence Text (shown on card)                                                                                                 |
   | ---------- | ------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
   | **Resume** | `[Resume Copying]`        | "4h cooldown begins. Safety limit re-arms after cooldown. **Open positions stay open.** Next copy after cooldown expires."       |
   | **Stop**   | `[Stop & Return Capital]` | "Copy relationship ends. **Capital returned in ~2 min.** Open positions closed at market price. You can re-copy @Alpha anytime." |

6. **Sarah taps [Resume]** → cooldown timer starts → card enters **RESOLVING** state: "Safety resumes in 3h 42m. Open positions continue."

   **Or Sarah taps [Stop]** → confirmation modal: "Stop copying @Alpha? Open positions will close at market. Capital (~$2,250) returns in ~2 min." → `[Confirm Stop]` / `[Cancel]` → on confirm, card enters CLOSED state, capital returns to balance.

7. **Post-decision confirmation** (card stays dimmed for 24h, then auto-dismisses):
   - If resumed: "Resumed at {time}. Cooldown expires {time}. Safety limit reset to {configured_limit}%."
   - If stopped: "Stopped at {time}. $2,248 returned to balance. (@Alpha had 2.3% slippage on close.)"

## §Recovery Card States — 3-State Machine

The Recovery Card surfaces in different states depending on system trigger and Sarah's actions.

| State               | Trigger                                        | Card Color | Header                                       | Primary Action                            |
| ------------------- | ---------------------------------------------- | ---------- | -------------------------------------------- | ----------------------------------------- |
| **ACTIVE LOSS**     | Safety bar crossing 40%+ but not at limit yet  | Amber      | "⚠️ @Alpha approaching limit — {pnl} (-40%)" | `[Review]` → opens leader profile         |
| **LIMIT HIT**       | Circuit breaker fires, copies auto-paused      | Red        | "🛑 @Alpha hit limit. Copies paused. {pnl}"  | `[Resume Copying]` / `[Stop & Return]`    |
| **MANUALLY PAUSED** | Sarah paused copies herself from Manage screen | Grey       | "⏸ @Alpha paused by you"                     | `[Resume Copying]` / `[Stop Permanently]` |

State transitions:

```
ACTIVE LOSS       → LIMIT HIT        (circuit breaker fires)
LIMIT HIT         → RESOLVING        (Sarah taps Resume, cooldown active)
RESOLVING         → ACTIVE LOSS      (cooldown expires, new copy session begins)
LIMIT HIT         → CLOSED           (Sarah taps Stop)
MANUALLY PAUSED   → CLOSED           (Sarah taps Stop Permanently)
MANUALLY PAUSED   → ACTIVE LOSS      (Sarah taps Resume)
```

## §Multi-Leader Scenario — Partial Portfolio Alert

If Sarah has 3 leaders and only 1 hits the safety limit:

- Feed shows **1 Recovery Card** (pinned, red) for @AlphaTrader
- Below it: 2 normal active copy cards for unaffected leaders
- No bulk action offered — each leader is a separate, deliberate decision
- **Portfolio summary line** above all cards: "2 of 3 leaders active. @Alpha paused."

If 2+ leaders hit limits simultaneously (e.g., correlated long BTC during flash crash):

- Multiple Recovery Cards stacked, most recent trigger on top
- **Correlation warning** pinned above stack: "⚠️ @Alpha and @SwingMaster both triggered. Both long BTC — possible correlated risk."
- Each card resolved independently — Sarah decides per leader

## §Warning Signals — What Sarah needs to make a decision under stress

Sarah's state: scared, confused, possibly angry. Every signal must be dead simple and actionable. No jargon.

| Signal                | Display                             | How It's Built                                                          |
| --------------------- | ----------------------------------- | ----------------------------------------------------------------------- |
| **Safety Alert**      | "@Alpha hit limit. -$420. Paused."  | Circuit breaker triggers → auto-pause → push notification. Server-side. |
| **Recovery Card**     | State + returned amount + options   | See §Recovery Card States above                                         |
| **Resume Cooldown**   | "Safety resumes in 3h 42m"          | 4h cooldown prevents Resume → re-trigger loops                          |
| **Correlation Alert** | "Both long BTC — $4,200 combined"   | 2+ leaders same direction on same asset detected                        |
| **Regime Mismatch**   | "@Alpha wins 52% in choppy markets" | Leader WR in current regime < 55% (MVP: overall WR < 55%)               |

## Edge Cases

| Condition                                    | Behavior                                                                                                        |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Sarah ignores Recovery Card for 7+ days      | Push reminder: "Copies still paused for @Alpha. Resume or stop?"                                                |
| Resume → immediate re-trigger after cooldown | Card shows again with updated numbers. Hard stop at 3 triggers in 24h → requires manual review before resuming. |
| App closed when limit hits                   | Push arrives, Recovery Card ready when app opens. No action required to surface it.                             |
| Capital return fails (network/chain issue)   | "Return in progress — check again in 10 min. Contact support if balance hasn't updated."                        |

---

# Story 7 — "When I'm about to trade, I want to see the market regime, what smart money is doing, and the structural signals in 10 seconds, so I can decide whether to enter."

**Persona:** Jake (S2) | **Stage:** L0 — Pre-Trade | **JTBD:** Read the market before entering

**Pre:** Funded wallet. About to trade. Radar accessible.
**Post:** Decided to trade (→ Trade Panel, see Arx_4-1-1-3) or wait.

## Steps

Jake's pre-trade flow often starts in the Discover feed (Story 5) where a signal card triggers his interest. He arrives here either from a Discover card [Analyze →] CTA or by opening Radar directly.

1. **Entry point A:** From Story 5, tap **[Analyze →]** on a Regime Shift, Smart Money, or Funding Alert card → asset detail opens with regime context pre-populated
2. **Entry point B:** Open Radar directly → tap **Traders** sub-tab → **Discover** mode → Market Overview strip loads
3. **Scan regime pill:** state, duration, confidence → §Regime Engine (Story 3)
4. **Read market data strip** → §Market Signals (§Jake's Trigger Cards below shows which feed cards led here)
5. **Check cluster consensus:** "Elite 75% long BTC" + weighted entry + liq zone → §Clusters
6. **Check impact prices:** bid/ask spread for $5K order size → execution quality
7. **Decide:** trade (→ Trade Panel, Arx_4-1-1-3) or wait

## Signal Matrix

### §Jake's Trigger Cards — Feed Cards That Lead to This Story

Jake's pre-trade analysis is rarely cold. In most sessions, a feed card in Story 5 creates the itch. These are the cards that lead him from Discover → Story 7.

| Card                          | What Jake Sees                                                              | Why It Triggers                                                                                                                          | Action Chain                                                              |
| ----------------------------- | --------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| **Regime Shift** (#1)         | "BTC shifted to TRENDING — regime specialist win rate 71% in this regime"   | Regime change = new directional opportunity. Jake trades with the trend, not against it.                                                 | `[Analyze →]` → loads asset with regime pre-filled + §Market Signals      |
| **Smart Money** (#5)          | "72% of Elite traders long BTC — avg entry $68,200 (+1.9%)"                 | Large-capital directional consensus = validation for Jake's own thesis. Entry price shows whether the move has started.                  | `[Analyze →]` → loads asset + §Clusters pre-filled with Elite consensus   |
| **Regime Specialist** (#6)    | "80% of trending specialists long BTC"                                      | Strategy-filtered consensus. More relevant than broad market — these traders outperform specifically in this regime type.                | `[Analyze →]` → same as Smart Money                                       |
| **Funding Alert** (#2)        | "BTC longs paying +42% APR — 3rd consecutive high-funding hour"             | Funding extreme = market is overcrowded. Jake uses this as a contrarian trigger (fade the crowd) or a cost signal (holds are expensive). | `[Analyze →]` → asset view with annualized funding cost shown prominently |
| **Trader Move** (#8, watched) | "@SwingMaster opened BTC Long 10x — 3rd trending trade this month, won 2/2" | Jake watches leaders not to copy, but as signal. A watched Elite trader acting = pre-qualified setup.                                    | `[Analyze →]` → asset view + sees @SwingMaster's position in cluster data |

**Distance to trade from feed card:** 2–3 taps (card → [Analyze →] → regime/market view → Trade Panel). No search, no filter, no separate navigation step.

**Regime Alignment sort (Traders tab):** When Jake is in pre-trade mode on the Traders tab, a **Regime Alignment** sort is available: ranks traders by how well their strategy D2 matches current regime. In TRENDING, Swing Traders and Position Traders rank first. In RANGE_BOUND, Day Traders rank first. Shortest path to finding a leader whose strategy fits current conditions.

### §Market Signals — The 10-second dashboard Jake reads before every trade

Jake's question: "What's the market doing right now?" This strip gives him the raw numbers to form a directional thesis.

| Signal               | Display             | How It's Built                                                                |
| -------------------- | ------------------- | ----------------------------------------------------------------------------- |
| **24h Price Change** | `+2.3%`             | Mark price vs previous day price                                              |
| **Funding Rate**     | `+5.5% APR`         | Hourly funding rate annualized. Settles every hour (not 8h like competitors). |
| **Open Interest**    | `26,394 BTC`        | Total outstanding contracts. Rising OI + rising price = strong trend.         |
| **24h Volume**       | `$2.1B`             | Activity level. Low = thin liquidity.                                         |
| **Premium**          | `-0.03%`            | Mark-to-oracle divergence. Negative = shorts slightly dominant.               |
| **Impact Prices**    | `$69,018 / $69,019` | Estimated execution for $5K order. Direct from order book.                    |

### §Clusters — Group Consensus

Jake's need: "What are the smart money players actually positioned in?" Cluster consensus tells him whether his directional thesis has large-capital backing.

| Cluster                | What Jake Sees                         | Min Members | Trigger                  |
| ---------------------- | -------------------------------------- | ----------- | ------------------------ |
| **Performance Elite**  | "72% of Elite traders long BTC"        | 10          | >=60% agree on direction |
| **Regime Specialists** | "80% of trending specialists long BTC" | 5           | >=60% agree on direction |

Enrichments: weighted avg entry price ("entered at $68,200, +1.9%"), liquidation heatmap (shown when zone <15% from mark price).

Consensus detected every 5 min. Breaking when strength drops below 55% (5% hysteresis).

**Note on Sarah's use of cluster signals:** Sarah's feed (Story 4 §Feed Cards, Cards #3/#4) shows "your watched/copied leaders are both long BTC" — this is position correlation risk for her copy portfolio, not market intelligence. Jake uses clusters here as a directional signal for his own trades.

### §Signal Confluence [Phase 2]

Jake's need: "Give me one number that tells me how many signals agree." At MVP, Jake sees individual signals above. Phase 2 unifies into 5-layer score (0-10).

| Layer          | Measures           | Sub-Signals                                      |
| -------------- | ------------------ | ------------------------------------------------ |
| P1 Macro       | Market environment | Regime + events + sentiment                      |
| P2 Instrument  | Asset signals      | Trend + volume + funding + technicals            |
| P3 Participant | Who's doing what   | Consensus + flows + whale activity               |
| P4 Structural  | Microstructure     | OI delta + spread + book depth + liq clusters    |
| P5 Pattern     | Historical         | Pattern match + recurrence + timeframe alignment |

Confluence = count of layers agreeing on direction (0-5) x 2 -> 0-10 score.

## Edge Cases

| Condition                             | Behavior                                                             |
| ------------------------------------- | -------------------------------------------------------------------- |
| Regime = TRANSITION (ambiguous)       | Show "No clear pattern — monitor only" guidance                      |
| Cluster consensus <60% (no consensus) | Hide consensus line. Show "No consensus among Elite traders"         |
| HIP-3 asset outside market hours      | Show "Market closed. Opens [time]." Price data frozen at last close. |

---

---

# PART III — SIGNAL REFERENCE

> This section is the **engineering appendix**. Every signal from Part II maps back to a computation here. When Part II says "how it's built," this section has the full specification.
>
> For complete formulas with pseudocode, API request/response schemas, and implementation details, see [Arx_5-2-3_OnChain_Signal_Transformation_v6.md](Arx_5-2-3_OnChain_Signal_Transformation_v6.md) (retained as the engineering reference).

---

# 11. Signal → Story Cross-Reference

Every signal in Arx exists because someone needs it at a specific moment. This table maps signals to the stories that give them meaning.

| Signal                  | Computation       | Stories Used In                    | Persona | Freshness     |
| ----------------------- | ----------------- | ---------------------------------- | ------- | ------------- |
| Follower's Return       | C13.2             | Story 1, Story 3                   | S7      | Batch-daily   |
| Track Record Tier       | C3.8              | Story 1, Story 2                   | S7      | Batch-weekly  |
| Spots Remaining         | Direct            | Story 1, Story 3                   | S7      | Session-fresh |
| Worst Month             | C13.3             | Story 1, Story 2                   | S7      | Batch-weekly  |
| Consistency Score       | C3.6              | Story 1, Story 2                   | S7      | Batch-daily   |
| Profit Streak           | C3.7              | Story 1, Story 2                   | S7      | Batch-daily   |
| Win Rate                | C3.5              | Story 1, Story 2                   | S7, S2  | Batch-weekly  |
| Trading Style           | C4.1              | Story 1, Story 2                   | S7      | Batch-weekly  |
| Wallet Size             | Direct            | Story 1, Story 2                   | S7      | Batch-daily   |
| Return % (time-toggled) | C3.1              | Story 2                            | S7      | Batch-daily   |
| Sharpe Ratio            | C3.2              | Story 2, Story 3                   | S7, S2  | Batch-weekly  |
| Max Drawdown            | C3.3              | Story 2, Story 3                   | S7, S2  | Batch-weekly  |
| Profit Factor           | C3.4              | Story 2                            | S7      | Batch-weekly  |
| Regime State            | C5.1              | Story 3, Story 4, Story 5, Story 7 | S7, S2  | Session-fresh |
| Regime Confidence       | C5.2              | Story 7                            | S2      | Session-fresh |
| Cluster Consensus       | C10.1             | Story 3, Story 4, Story 5, Story 7 | S7, S2  | Session-fresh |
| Copy Wizard Projection  | Direct            | Story 3                            | S7      | On-demand     |
| Total P&L               | C1.1              | Story 4                            | S7      | Live (<5s)    |
| Per-Leader P&L          | Direct            | Story 4                            | S7      | Live (<5s)    |
| Safety Bar              | C7.1              | Story 4, Story 6                   | S7      | Live (<5s)    |
| Context Line            | Template          | Story 4                            | S7      | Session-fresh |
| Regime Pill             | C5.1              | Story 4                            | S7      | Session-fresh |
| Correlation Alert       | C7.2              | Story 4, Story 6                   | S7      | Live (<5s)    |
| Safety Alert            | C7.1 event        | Story 6                            | S7      | Instant (<2s) |
| Recovery Card           | C7.1 + ARX-SAFETY | Story 6                            | S7      | Instant (<2s) |
| Feed Cards (13 types)   | Various           | Story 4, Story 5                   | S7, S2  | Session-fresh |
| Kelly Fraction          | C6.1-C6.2         | (removed — Trade Panel scope)      | S2      | Batch-weekly  |
| Regime-Adjusted Size    | C6.5              | Story 3                            | S7      | Session-fresh |
| Unrealized PnL          | Direct            | (removed — Portfolio scope)        | S2      | Live (<5s)    |
| Liquidation Distance    | C2.2              | (removed — Portfolio scope)        | S2      | Live          |
| Safety Gauge            | C2.3              | (removed — Portfolio scope)        | S2      | Live          |
| Funding Since Open      | Direct            | (removed — Portfolio scope)        | S2      | Live          |
| Exposure Ratio          | C4.3              | (removed — Portfolio scope)        | S2      | Live          |
| Concentration (HHI)     | C4.4              | (removed — Portfolio scope)        | S2      | Live          |

---

# 12. Computation Index

Each computation is referenced by its C-number throughout the stories. Full formulas with pseudocode are in the v6 engineering spec. Below is the product-level summary of each.

## Portfolio Metrics (C1)

| ID   | Name             | What It Tells You                  | Inputs                               | Update         |
| ---- | ---------------- | ---------------------------------- | ------------------------------------ | -------------- |
| C1.1 | Daily P&L        | How much money was made/lost today | Hyperliquid portfolio (day period)   | Live           |
| C1.2 | 30-Day Return    | Monthly performance                | Hyperliquid portfolio (month period) | Session-fresh  |
| C1.3 | 24h Price Change | Asset momentum                     | Current mark vs yesterday's mark     | Near-real-time |
| C1.4 | Margin Ratio     | How much buffer exists             | Margin used ÷ account value          | Live           |

## Position Metrics (C2)

| ID   | Name                    | What It Tells You                              | Inputs                                                                                      | Update        |
| ---- | ----------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------- | ------------- |
| C2.1 | Unrealized PnL          | Paper profit/loss on each open trade           | Position data + mark prices                                                                 | Live          |
| C2.2 | Liquidation Distance    | How far from forced closure (%)                | Liquidation price vs mark price                                                             | Live          |
| C2.3 | Safety Gauge            | Composite 0-100 health score (green/amber/red) | Liquidation distance (80%) + leverage severity (20%)                                        | Live          |
| C2.4 | Notional Value          | Full dollar value of position                  | Size × mark price                                                                           | Live          |
| C2.5 | Funding Cost Since Open | Total funding paid/earned on this position     | Hyperliquid cumFunding field                                                                | Live          |
| C2.6 | Annualized Funding Rate | The yearly cost of holding this position       | Hourly rate × 24 × 365. Note: Hyperliquid settles funding HOURLY (not 8h like competitors). | Session-fresh |

## Trader Performance Metrics (C3)

| ID   | Name                    | What It Tells You                                               | Inputs                                                                                                                             | Update       |
| ---- | ----------------------- | --------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| C3.1 | ROI                     | Total return on investment                                      | Closed P&L ÷ starting equity. Supports 7d/30d/90d/all windows.                                                                     | Batch-daily  |
| C3.2 | Sharpe Ratio            | Return per unit of risk (above 1.5 = excellent)                 | Annualized return ÷ annualized volatility of equity changes                                                                        | Batch-weekly |
| C3.3 | Max Drawdown            | Worst peak-to-trough loss ever                                  | Walk equity curve, report deepest valley                                                                                           | Batch-weekly |
| C3.4 | Profit Factor           | Total money won ÷ total money lost (above 1.5 = solid edge)     | Gross wins ÷ gross losses from 90d closing fills                                                                                   | Batch-weekly |
| C3.5 | Win Rate                | % of trades that made money                                     | Profitable closings ÷ total closings. Supports 7d/30d/90d windows. <5 trades → "—"                                                 | Batch-weekly |
| C3.6 | Consistency Score (0-4) | How many of 4 time windows (7d/30d/60d/90d) are profitable      | Count of positive-PnL windows                                                                                                      | Batch-daily  |
| C3.7 | Profit Streak           | Consecutive profitable weeks, counting backward                 | Count of consecutive Mon-Sun weeks with positive P&L                                                                               | Batch-daily  |
| C3.8 | Track Record Tier       | Overall quality ranking (Elite/Proven/Verified/Rising/Unranked) | ROI (40%) + Sharpe (30%) + copier earnings (30%). MVP fallback: ROI (55%) + Sharpe (45%) when no copiers exist. Minimum 30 trades. | Batch-weekly |

## Classification Logic (C4)

| ID    | Name                | What It Tells You                                    | How                                                                                                             | Update       |
| ----- | ------------------- | ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | ------------ |
| C4.1  | Trading Strategy    | Hold time pattern (Scalper to HODLer)                | Average hold time from 90 days of matched open/close fills                                                      | Batch-weekly |
| C4.2b | Risk Profile        | Leverage + drawdown behavior (Conservative to Degen) | Average leverage + MDD + sizing consistency. Sub-labels: Hedged, Concentrated, Disciplined Stops, Erratic Sizer | Batch-weekly |
| C4.3  | Exposure Ratio      | How deployed the account is                          | Total notional ÷ equity. <10% = Sidelined, 10-40% = Light, 40-80% = Moderate, >80% = Heavy                      | Live         |
| C4.4  | Concentration (HHI) | Position diversification                             | Sum of squared per-asset weights. >0.5 = Single-Asset, 0.18-0.5 = Top-Heavy, <0.18 = Diversified                | Live         |

## Regime Engine (C5)

| ID        | Name                      | What It Tells You                      | How                                                                                                                                     | Update                      |
| --------- | ------------------------- | -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- |
| C5.1      | Regime Classification     | Current market weather per asset       | 4 technical indicators (ADX, BBW, Hurst, realized vol) → 5 states. Priority: CRISIS > TRENDING > COMPRESSION > RANGE_BOUND > TRANSITION | Session-fresh (every 5 min) |
| C5.2      | Regime Confidence (0-100) | How certain is the classification?     | Distance from classification threshold, normalized to 0-100                                                                             | Session-fresh               |
| C5.3-C5.6 | Regime Timing metrics     | How well a trader reads regime changes | [Phase 2] Exit timing + entry timing + combined adaptability + per-regime win rate                                                      | Batch-weekly                |

## Kelly Sizing (C6)

| ID   | Name                      | What It Tells You                  | How                                                                                                   | Update        |
| ---- | ------------------------- | ---------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------- |
| C6.1 | Win Rate and Payoff Ratio | Historical edge                    | Win rate (W) + avg win / avg loss ratio (R) from 90d closing fills. Min 30 fills.                     | Batch-weekly  |
| C6.2 | Kelly Fraction            | Mathematically optimal bet size    | Kelly = (W×R - (1-W)) / R. Capped 0-1. Half Kelly = Kelly × 0.5 (recommended).                        | Batch-weekly  |
| C6.4 | Confidence Tier           | How much to trust the Kelly number | 200+ trades = HIGH (full), 100-199 = MEDIUM (75%), 30-99 = LOW (50%), <30 = INSUFFICIENT (fixed 1-2%) | Batch-weekly  |
| C6.5 | Recommended Position Size | Final dollar size for the trade    | Kelly × regime multiplier × risk preference × confidence factor. Hard cap at 25% of equity.           | Session-fresh |

## Copy Trading (C7)

| ID   | Name                         | What It Tells You         | How                                                                                                                               | Update     |
| ---- | ---------------------------- | ------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| C7.1 | Safety Bar (Circuit Breaker) | How close to auto-pause   | `(1 - current_equity / starting_equity) × 100`. User-configurable limit (20-90%, default 50%). Three zones scale to chosen limit. | Live (<5s) |
| C7.2 | Cross-Leader Correlation     | Hidden concentration risk | Check if 2+ copied leaders hold same asset in same direction. Report combined exposure.                                           | Live (<5s) |

## Cluster Consensus (C10)

| ID    | Name                     | What It Tells You                   | How                                                                                                                                              | Update                      |
| ----- | ------------------------ | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------- |
| C10.1 | Consensus Detection      | Group directional agreement         | For each asset: count Long vs Short across cluster members. ≥60% = consensus. Includes strength %, combined exposure, count.                     | Session-fresh (every 5 min) |
| C10.2 | Consensus Breaking       | Group is losing agreement           | Previous consensus drops below 55% or direction flips. 5% hysteresis.                                                                            | Session-fresh               |
| C10.3 | Cross-Cluster Divergence | Two groups disagree                 | Compare consensus direction between cluster pairs. Both ≥60% but opposite = divergence.                                                          | Session-fresh               |
| C10.5 | Weighted Avg Entry Price | Where the group entered             | Notional-weighted average entry price across agreeing members. Shows if group is in profit or underwater.                                        | Session-fresh               |
| C10.6 | Liquidation Heatmap      | Where liquidation risk concentrates | Bucket liquidation prices by range, identify densest zone. Risk level: <5% away = close (red), 5-15% = visible (yellow), >15% = distant (green). | Session-fresh               |

## Copier Metrics (C13)

| ID    | Name               | What It Tells You                   | How                                                                                             | Update       |
| ----- | ------------------ | ----------------------------------- | ----------------------------------------------------------------------------------------------- | ------------ |
| C13.2 | Follower's Return  | How much copiers actually earned    | Sum of copier P&L ÷ total allocation. Supports 7d/30d/90d. Day-1 fallback: leader's own return. | Batch-daily  |
| C13.3 | Worst Month Return | Worst month for the leader's equity | Scan entire equity history month by month, report minimum.                                      | Batch-weekly |

## Utility Computations (C14)

| ID    | Name               | What It Tells You                            | How                                                         | Update    |
| ----- | ------------------ | -------------------------------------------- | ----------------------------------------------------------- | --------- |
| C14.1 | Activity Cadence   | How often a trader trades                    | Fill count per day, averaged over 7d/30d/90d                | Daily     |
| C14.4 | Position Open Time | How long a position has been open            | Reconstruct from trade fill timestamps                      | On-demand |
| C14.5 | TP/SL Matching     | Which orders are attached to which positions | Cross-reference open orders (isPositionTpsl) by coin + side | Live      |

---

# 13. Cluster Consensus Engine

**Four MVP clusters, each answering a different question:**

| Cluster               | Question                             | Members                                                                    | Min Size | Feed Mode |
| --------------------- | ------------------------------------ | -------------------------------------------------------------------------- | -------- | --------- |
| **My Copied**         | "What are my copied leaders doing?"  | Sarah's active copy relationships                                          | 2        | My Feed   |
| **My Watched**        | "What are my watched leaders doing?" | Sarah's follows minus already-copied                                       | 2        | My Feed   |
| **Performance Elite** | "What are the best traders doing?"   | Elite + Proven tier, active in 30 days                                     | 10       | Discover  |
| **Regime Winners**    | "Who dominates this market regime?"  | Win rate >65%, active in 90 days. MVP: overall WR. Phase 2: per-regime WR. | 5        | Discover  |

**Future:** Same-Style Cluster (Phase 2) — traders matching Sarah's preferred style inferred from copy history.

**Consensus algorithm:** Every 5 minutes, check positions of all cluster members. For each asset, count Long vs Short. ≥60% agreeing = consensus detected. 5% hysteresis for breaking detection. Anti-gaming: positions held <30 minutes are excluded.

**API failure handling:** Single member failure → exclude, recompute. All members fail → keep previous state flagged "stale." After 15 min stale → suppress signal entirely.

**Full implementation details with pseudocode and state machine:** See v6 spec §3.

---

# 14. Display Object Schemas

Each signal renders through a typed display object. The complete schemas (Trader Profile, Position, Regime State, Copy Portfolio, Cluster Consensus, Feed Card, Safety Alert, Notification, Market Overview, Preset Filter Result) are defined in v6 spec §4.

**Key display object: Trader Profile** — maps directly to the 10 taxonomy dimensions plus composite metrics (Performance, Concentration, Compatibility). Note: v6 spec references "13 dimensions" — this was the 9+4 model. The v7 taxonomy originally consolidated to 8 dimensions (Activity Cadence absorbed into Strategy); v7.1 adds D9 (Last Active) and D10 (Consistency Score) as explicit filterable dimensions. Display objects should reflect all 10.

**Key display object: Feed Card Base Schema** — every card wraps in a container with: card_type (1-13), altitude (A1-A5), priority (critical/high/normal/low), context_pill (regime), context_line (cluster), your_impact (personal P&L), CTA, and feed_mode (my_feed/discover/both).

---

# 15. API Source Registry

**Three data sources:**

| Source                    | What                                                                                      | Auth          | Rate Limit            |
| ------------------------- | ----------------------------------------------------------------------------------------- | ------------- | --------------------- |
| **Hyperliquid REST**      | All on-chain data (positions, fills, prices, candles, orders, portfolio, funding, book)   | None (public) | 1200 req/min (20/sec) |
| **Hyperliquid WebSocket** | Real-time fills for copy execution                                                        | None          | Push-based, sub-100ms |
| **Arx Database**          | Copy relationships, profiles, regime snapshots, safety events, cluster state, preferences | Internal      | N/A                   |

**External (Phase 2+):** CoinGecko/CMC for market cap, CME/CBOE for macro (DXY, VIX), TokenUnlocks for event calendar.

**Full endpoint specifications (request/response schemas, field types, gotchas):** See v6 spec §1.

**Key API corrections (verified 2026-03-27):**

- Hyperliquid funding settles **every 1 hour** (not 8h like competitors)
- `liquidationPx` can be **null** for some position types
- `midPx` can be **null** for illiquid markets (fall back to `markPx`)
- k-prefix assets (kPEPE, kBONK) have **1000× scaled** prices
- Portfolio snapshots are ~2h apart (not continuous) — compute intra-day from fills
- Fill sort order is **time descending** (most recent first)

---

# 16. Feed System

## Freshness Tiers

| Tier                     | Latency        | Signals                                                | Why                               |
| ------------------------ | -------------- | ------------------------------------------------------ | --------------------------------- |
| **Instant** (<2s)        | Sub-300ms      | Copy execution, circuit breaker, safety push           | Money is at stake                 |
| **Live** (<5s)           | 1-5s refresh   | P&L, safety bar, positions, prices, correlation        | "Am I okay?" check                |
| **Session-fresh** (5min) | Every 5 min    | Feed cards, regime, clusters, context line             | Periodic update                   |
| **Batch-daily**          | Overnight      | Consistency, streaks, activity, wallet size, followers | Slow-changing discovery metrics   |
| **Batch-weekly**         | Weekend        | Tier, style, risk, Sharpe, MDD, Kelly                  | Profile metrics stable over weeks |
| **On-demand**            | When requested | Profile narrative, position reconstruction             | Lazy compute                      |

## Build Order (Recommended)

| Sprint | Focus                    | Components                                                                    |
| ------ | ------------------------ | ----------------------------------------------------------------------------- |
| 1      | API integration          | All 12 Hyperliquid endpoints + Arx DB schema                                  |
| 2      | Core computations        | C1-C4 (portfolio, position, performance, classification)                      |
| 3      | Regime + Copy + Safety   | Per-asset regime engine (C5.1-C5.2) + copy trading (C7) + configurable safety |
| 4      | Clusters + Feed          | Cluster engine (C10) + feed cards 1-6                                         |
| 5      | Remaining feed + Journey | Cards 7-12 + S7 journey state machine                                         |
| 6      | Leader signals           | S2 L0 signals (Story 7): regime, clusters, market data, trigger cards         |

**MVP scope, phase boundaries, and developer contract (cron schedules, rate budgets, verification checklist):** See v6 spec §0 and §9.

---

# END OF SPEC
