# ARX_3-2: Product Requirements Document

## PROPERTY TABLE

| Property    | Value                                                                                                                                                                     |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Artifact ID | ARX_3-2                                                                                                                                                                   |
| Title       | Product Requirements Document                                                                                                                                             |
| Group       | 3 — Product Definition                                                                                                                                                    |
| Owner       | PM / CEO                                                                                                                                                                  |
| Status      | Living Document — Weekly During Build                                                                                                                                     |
| Created     | 2026-03-01                                                                                                                                                                |
| Last Review | 2026-03-09                                                                                                                                                                |
| Version     | 1.0 (consolidates PRD v3→v7 + GenAI Spec + Prototype insights)                                                                                                            |
| Upstream    | ARX_2-1, ARX_2-6 (Perceived Value Framework), ARX_1-2, ARX_3-1, ARX_2-2, ARX_2-2-2 Trading Signal & Radar Foundational Research, ARX_9-1, ARX_2-3-6 Bitget Benchmark V3.0 |
| Downstream  | ARX_4-1, ARX_5-1, ARX_5-3, ARX_6-2, ARX_7-1                                                                                                                               |
| Confidence  | Strong — grounded in 7 iterations + prototype validation                                                                                                                  |

## ARCHITECTURE REQUIREMENTS FOR 3.2 PRD

This document must satisfy the following completeness criteria:

- Exec summary and north star metrics
- Personas × journey matrix
- Information architecture (every screen, purpose, data, actions, nav)
- Feature specs by pillar with Given/When/Then acceptance criteria
- AI features with behavior, guardrails, and fallback modes
- Integrations (3P, APIs, build-vs-buy decision)
- Data flows & schemas
- NFRs (latency, uptime, security, accessibility)
- Phasing and release sequence
- Test criterion: An engineer can build the full product without asking "what should happen when...?"

## KEY UPDATES FROM v7 → v1.0

1. **Narrowed audience confirmed**: P1 Jake (Strategic Learner, T3-T4, S2-S3) as beachhead, with progressive expansion to P2-P5
2. **Prototype validation**: Desktop pseudo-prototype (4 parts, 30/30 PASS) and Mobile pseudo-prototype (4 parts, 17/17 PASS) validated IA and interaction model
3. **GenAI Integration Spec incorporated**: Three-stage intelligence progression (GenAI → Quant → ML) now part of core PRD
4. **Trust ladder formalized**: Advisory → Collaborative → Delegated → Autonomous progression built into feature sequencing
5. **Competitive landscape sharpened**: 20 competitors analyzed, 6 positioning gaps identified
6. **Business model grounded**: Builder codes (2.5bps) + Gold ($29/mo) + Copy fees, targeting $175K/mo at beachhead

---

# SECTION 1: EXECUTIVE SUMMARY

## 1.1 What Is Project Arx

Project Arx is a mobile-first crypto trading terminal that unifies smart money intelligence, trade execution, and risk management into a single decision layer. At launch, Arx targets Hyperliquid as the primary venue, with venue-agnostic architecture for expansion. Over time, Arx evolves into an AI co-pilot that surfaces patterns from a user's own trade history, flags when setups rhyme with past outcomes, and progressively reduces friction between conviction and execution.

The product compounds from **tool → thinking partner → co-pilot**, and the data moat deepens with every trade plan saved, every outcome attributed, and every belief tested.

### Core Mission

Enable the largest underserved cohort of crypto traders — those who read smart money signals but lack the system to turn observation into confident execution — to trade with evidence, speed, and learning.

### Why Now

- Hyperliquid has achieved product-market fit with 10K+ active traders, 50M+ daily trade events, and venue economics (builder codes) that align product with revenue
- GenAI has matured enough to synthesize contradictory signals into coherent trade plans and confidence scores
- Mobile-first trading is table stakes; zero existing competitors have simultaneous iOS + Android + Desktop parity
- Mid-capital traders ($10K-$100K) are willing to pay for augmentation; Gold SaaS economics work at $29/mo

## 1.2 Customer Pitch

**Problem**: Mirror traders copy whale wallets and inherit positions without knowing the thesis or exit plan — they're renting someone else's edge. Autonomous traders have their own systems and don't need another tool. The largest and most underserved group sits in the middle — tracking smart money, reading flows, forming opinions, but lacking a system to turn observation into a trade they trust.

**Solution**: Arx gives that system:

- **Evidence heatmaps** showing where smart money clusters, segmented by risk profile and holding time
- **Thesis capture** with confidence levels and invalidation triggers
- **Cluster-to-plan translator** that suggests entry/exit/size based on evidence distribution
- **Risk guardrails** that prevent oversizing and liquidation cascades
- **Feedback loop** linking every trade to the evidence and belief behind it
- **Copilot** that suggests next moves based on user's own trade history and current market regime

**Why Arx**: Not a copier tool (user decides), not a black-box AI (user sees reasoning), not a power terminal (takes 15 min to load), not another signal provider (synthesizes existing signals into plans). Arx is the _thinking partner_ between observation and execution.

## 1.3 North Star Metrics

| Metric                                    | Definition                                                    | Target (Y1)                                        | Why It Matters                                                                                                                                             |
| ----------------------------------------- | ------------------------------------------------------------- | -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Time-to-Trade**                         | Signal observation to order execution                         | <10 min average; <90s Copilot-assisted             | Friction kills conviction                                                                                                                                  |
| **Signal-to-Fill Quality**                | % of trades capturing intended edge                           | >60% (not luck, not noise)                         | Revenue confidence; repeatable skill                                                                                                                       |
| **Copilot Adoption**                      | % of trades using copilot assist                              | >40%                                               | Stickiness, retention, upsell                                                                                                                              |
| **DAU/MAU**                               | Daily / Monthly Active Users                                  | 2,500 / 8,000                                      | Engagement + cohort health                                                                                                                                 |
| **Gold Conversion**                       | Free tier → Gold upgrade                                      | >15% (CTR + conversion rate)                       | Revenue per user                                                                                                                                           |
| **Execution Quality**                     | Slippage + fees vs VWAP                                       | <0.5% (industry: 1-3%)                             | Trust + ARU (average revenue per user)                                                                                                                     |
| **Referral NPS**                          | Net Promoter Score                                            | >40 (industry: 20-30 for fintech)                  | Word-of-mouth, CAC reduction                                                                                                                               |
| **ARPU (Average Revenue Per User)**       | (Builder codes + Gold + Copy fees) / DAU                      | $85/mo at beachhead                                | Payback period, investor math                                                                                                                              |
| **LTV:CAC Ratio**                         | 12-month lifetime value ÷ customer acquisition cost           | >20:1 (target >10x CAC)                            | Unit economics sustainability                                                                                                                              |
| **Aggregate Copier Profit**               | Total realized profit across all copy followers (net of fees) | Positive within 90 days of copy marketplace launch | Per 2-3-6 V3.0: the most powerful trust signal — "has following leaders on Arx made people money?" Concrete and visceral vs. abstract metrics like Sharpe. |
| **Copy Marketplace Active Relationships** | Number of active leader-follower copy relationships           | 100+ by end of Cycle 1, 1,000+ by end of Cycle 5   | Two-sided marketplace health; leading indicator of copy fee revenue                                                                                        |

---

# SECTION 2: PROBLEM SPACE & PERSONAS

## 2.1 The Problem (First Principles)

Three irreducible problems that Arx solves:

### Problem 1: Fragmented Workflow

- **Current state**: Traders use 7-17 tools (Nansen, TradingView, Hyperliquid UI, Discord, Twitter, Telegram, CoinGecko, etc.)
- **Friction**: 15-20 minutes signal-to-fill; 80% of time spent aggregating context
- **Arx solution**: Single pane with chart, evidence, intelligence, and execution in one view
- **Measurement**: Reduce time-to-trade from 15 min to <10 min (Day 1), <90s (Copilot-assisted)

### Problem 2: No Synthesis Layer

- **Current state**: 12+ signals/day without framework to rank, cluster, or understand
- **Friction**: "I see 3 wallets moving, funding is positive, but volume is low. Do I trade? How much?"
- **Arx solution**: Radar 3-tab architecture (Feed/Traders/Market — see ARX_2-2-2 §5) + confluence scoring + regime context + Copilot reasoning + 4-layer rationale on every signal (headline, breakdown, leader context, warnings — see ARX_2-2-2 §5C). Two action paths: **Copy Trade** (S7: leader IS the strategy) and **Trade Myself** (S2: signals as reference points) — see ARX_2-2-2 §5A/§5B
- **Measurement**: >70% trades executed in favorable regime; >60% trades capture intended edge

### Problem 3: Copying Without Learning

- **Current state**: Mirror a position, outcome good/bad, no reflection, no graduation
- **Friction**: Luck vs. skill indistinguishable; no feedback loop; repeated mistakes
- **Arx solution**: Mandatory thesis capture; auto-populated journal; attribution analysis (direction/timing/execution/luck)
- **Measurement**: >50% trades include rationale capture; measurable win-rate improvement over 30 trades

## 2.2 Persona Framework (4 Dimensions)

Arx personas live on three orthogonal axes plus an autonomy overlay. This 4D model ensures feature design serves multiple personas without bloat.

### Axis 1: Capital at Risk (CAR)

| Tier | Range       | Wallet Count (Hyperliquid) | Daily Volume % | Day 1 Focus |
| ---- | ----------- | -------------------------- | -------------- | ----------- |
| T1   | $0-$250     | 156,000                    | 8%             | No          |
| T2   | $250-$1K    | 98,400                     | 12%            | No          |
| T3   | $1K-$10K    | 58,800                     | 18%            | **YES**     |
| T4   | $10K-$100K  | 34,200                     | 28%            | **YES**     |
| T5   | $100K-$500K | 8,200                      | 19%            | Phase 2     |
| T6   | $500K-$5M   | 2,100                      | 11%            | Phase 3     |
| T7   | $5M+        | 300                        | 4%             | Phase 4+    |

**Day 1 focus**: T3-T4 ($10K-$100K), representing 34.2K wallets (19.8% of Hyperliquid), 46% of daily volume, 67% of high-intent traders.

- Why? Serious enough to fund product ($29/mo), not so large that they have institutional-grade infrastructure already.

### Axis 2: Sophistication

| Level | Definition | Typical Background                          | Tools Used                              | Day 1 Focus |
| ----- | ---------- | ------------------------------------------- | --------------------------------------- | ----------- |
| S1    | Novice     | No trading experience                       | Spot CEX + YouTube                      | No          |
| S2    | Competent  | <2 years; some losses; knows Greeks         | TradingView + Discord                   | **YES**     |
| S3    | Advanced   | 2-5 years; positive bias; custom thesis     | TradingView + Nansen + custom           | **YES**     |
| S4    | Expert     | 5+ years; published research; consistent    | Proprietary tools + public sources      | Phase 2     |
| S5    | Researcher | PhD math/stats; building proprietary models | Backtesters + APIs + research platforms | Phase 3+    |

**Day 1 focus**: S2-S3 (Competent to Advanced) — they know _what_ to look for but not _how_ to structure it.

### Axis 3: Intent

| Level | Definition  | Typical Trading Style             | Holding Time     | Leverage | Day 1 Focus         |
| ----- | ----------- | --------------------------------- | ---------------- | -------- | ------------------- |
| I1    | Speculative | FOMO, news, memes                 | Minutes to hours | 5-20x    | **YES**             |
| I2    | Strategic   | Thesis-driven, smart money follow | Hours to days    | 2-8x     | **YES**             |
| I3    | Systematic  | Backtested edge, algorithm-like   | Days to weeks    | 1-4x     | Phase 2             |
| I4    | Mimic       | Copy winners, minimal analysis    | Varies           | Varies   | Phase 2 (Copy tier) |
| I5    | Automated   | Fully autonomous, grid/DCA        | Months           | Fixed    | Phase 3+            |

**Day 1 focus**: I1-I2 (Speculative to Strategic) — they form opinions and want to act on them with confidence.

### Autonomy Overlay (The Trust Ladder)

Arx's feature progression maps to increasing autonomy:

| Stage             | User Role                                | Copilot Role                 | Example                                                                              |
| ----------------- | ---------------------------------------- | ---------------------------- | ------------------------------------------------------------------------------------ |
| **Advisory**      | Makes all decisions                      | Suggests with reasoning      | "Based on cluster heatmap, consider long 28-30K. Confidence: 72%"                    |
| **Collaborative** | Decides structure, Copilot fills details | Implements user intent       | User: "I want to trend-follow"; Copilot pre-fills plan matching user's past style    |
| **Delegated**     | Sets guardrails, Copilot decides         | Optimizes within constraints | User sets max 3x leverage + max size; Copilot auto-adjusts as regime changes         |
| **Autonomous**    | User checks occasionally                 | Executes, notifies           | Copilot trades autonomously, user reviews at day-end (Day 2 feature, phased rollout) |

**Day 1-M3**: Advisory + Collaborative modes only. Autonomous locked until M6.

## 2.3 Five Named Personas

### P1: Jake — "The Edge Seeker" (BEACHHEAD)

**Profile**

- Age: 32, ex-SWE, current IC at startup
- Capital: $45K account (T4)
- Sophistication: S2-S3
- Intent: I1-I2 (Speculative → Strategic)
- Experience: 5 days/week, 2.1x avg leverage, 58% win rate
- Device: Mobile-first (trades from coffee shops), desktop for research

**Pain Points**

1. 7 tools/tabs → context switching kills momentum
2. No synthesis → sees 3 bullish signals + 1 bearish + 1 neutral → "Do I trade?"
3. Execution leakage → 3-5 bps slippage per fill × 5 trades/day = lost edge
4. Sybil risk → follow a whale, it's actually a sybil farm or liquidation bait
5. No feedback → "Did I win because my thesis was right or because I got lucky?"

**Core Need**: All smart money signals in one place + a second opinion before trading + faster execution + post-trade attribution + conviction intelligence

**Desired Jobs to Be Done** (ranked)

1. Find good "teachers" for a symbol (signal quality filtering)
2. Decide whether now is good time to act (regime context)
3. Form trade plan from evidence (cluster → plan)
4. Act when smart money moves (alert + speed)
5. Execute efficiently (low slippage)
6. Learn and graduate (rationale capture + attribution)

**Success Criteria for Arx**

- Trades in <10 min (vs. 15 min currently)
- > 60% trades capturing intended edge
- > 50% trades with saved rationale
- 3-4 trades/day vs. 5/day (higher quality, not volume)
- Uses Copilot for >40% of trades by M3

**Channel/CAC**

- Discord DeFi trading communities
- Twitter trading communities (Trader Mobb, Wagerr, etc.)
- Referral from leaderboard top performers
- Estimated CAC: $35-45

---

### P2: Maya — "The Social Learner" (PHASE 2)

**Profile**

- Age: 26, FinTech analyst, learning to trade
- Capital: $8K account (T3)
- Sophistication: S1-S2
- Intent: I1 (Speculative, wants to learn I2)
- Experience: 2 days/week, 1-2x leverage, 45% win rate
- Device: Mobile only

**Pain Points**

1. Doesn't know who to trust or follow
2. Wants to learn _why_ smart money trades, not just copy
3. Gets overwhelmed by 10+ signals
4. Executes too fast → FOMO trades
5. No community → feels isolated

**Core Need**: Educational hand-holding + social proof + confidence + learning community

**Jobs to Be Done**

1. Find trusted educators (not copiers)
2. Understand the reasoning
3. Practice with guardrails
4. Grow confidence through community

**Success Criteria**

- Follows 2-3 trusted traders after M1
- Reads every Copilot explanation
- Joins study group or Discord channel
- Win rate improves to 50%+ by M3

**Unlock Path**: P1 adoption → referral → Arx social features attract P2 → shared signals raise P1 ARU

---

### P3: Marcus — "The Process Trader" (PHASE 2)

**Profile**

- Age: 38, financial analyst, algo-curious
- Capital: $180K account (T5)
- Sophistication: S3-S4
- Intent: I3 (Systematic)
- Experience: 4 days/week, custom backtested system, 62% win rate
- Device: Desktop-primary

**Pain Points**

1. Wants to layer macro/smart money signals into systematic rules
2. Current tools: TradingView + backtest platform + manual journal
3. Wants to backtest signal combinations against own history
4. Dislikes AI black boxes; wants explainability
5. Wants to automate execution (but with guardrails)

**Core Need**: Backtesting framework + rule engine + API for automation + explainability

**Jobs to Be Done**

1. Import own trade history and backtest signals
2. Test signal combinations
3. Build triggering rules
4. Execute with risk automation

**Success Criteria**

- Uploads 30+ past trades
- Tests 3+ signal combinations
- Builds custom rule set
- Implements via API by M4

---

### P4: Sophia — "The View Expresser" (PHASE 2)

**Profile**

- Age: 29, crypto investor, building personal brand
- Capital: $55K account (T4)
- Sophistication: S2-S3
- Intent: I2 (Strategic, wants I4 on copy tier)
- Experience: 3 days/week, trades her thesis, 56% win rate
- Device: Mobile + desktop

**Pain Points**

1. Trades well but has small personal audience
2. Wants to monetize by allowing followers to copy
3. Lacks trading journal / proof of performance
4. Wants to build credibility on-chain
5. Sybil problem (fake followers)

**Core Need**: Journal → credibility → audience → monetization via copy trading

**Jobs to Be Done**

1. Auto-journal for on-chain reputation
2. Prove performance + reduce sybil
3. Build audience
4. Enable copy trading with performance fees

**Success Criteria**

- 100+ verified followers by M2
- > 90% trades journaled
- Copy tier earning $200+/mo by M4

---

### P5: Chen — "The Automation Builder" (PHASE 3+)

**Profile**

- Age: 34, ML engineer ex-Citadel, crypto native
- Capital: $500K account (T6)
- Sophistication: S4-S5
- Intent: I5 (Automated)
- Experience: Daily trading + model development, 71% win rate
- Device: Headless API (no UI)

**Pain Points**

1. Wants to pipe Hyperliquid data into own ML pipeline
2. Wants to execute via Arx guardrails but with custom logic
3. Wants to share models in alpha marketplace
4. Wants to backtest against Arx's historical signal library

**Core Need**: API-first design + data access + execution delegation + marketplace

**Jobs to Be Done**

1. Access signal library via API
2. Execute via Arx guardrails
3. Train models on attributed outcomes
4. Publish and monetize models

**Success Criteria**

- Builds custom model by M6
- Executes 10+ trades/day via API
- Publishes model to marketplace by M7

---

## 2.4 Why This Niche Generates Revenue

Five structural reasons the Strategic Learner (P1) persona is a revenue beachhead:

1. **High-frequency data generation**: At 10K users, 5 trades/day, 50M events/week = data moat + machine learning signal
2. **Mid-capital = serious buyer**: T3-T4 ($10K-$100K) traders have skin in game; willing to pay $29/mo for edge; not price-sensitive to 2.5bps
3. **Strategic Learner = revenue sweet spot**: Not too sophisticated (P5 will build own tooling), not too naive (P1 abandons). Needs augmentation, pays for augmentation.
4. **Bridge persona enables expansion**: Same underlying pipeline (signal → plan → execute), different UI/messaging = P2, P3, P4, P5 use same core
5. **Hyperliquid venue economics**: Builder code = 2.5bps per trade, paid by Hyperliquid (not user). At 10K users × 5 trades/day × 0.025% × $100K avg notional = $192K/mo. Gold upside + copy fees = $220K/mo.

---

# SECTION 3: COMPETITIVE POSITION

## 3.1 Competitive Landscape Analysis

20 competitors audited; 6 positioning gaps identified:

| Competitor                      | Type               | Strength                | Weakness                                            | Arx Advantage                       |
| ------------------------------- | ------------------ | ----------------------- | --------------------------------------------------- | ----------------------------------- |
| **Minara Finance**              | AI copilot         | Black-box high accuracy | No explainability; copy-only; not mobile            | Transparency + execution + mobile   |
| **Hyperliquid Terminal**        | In-house terminal  | Native liquidity; fast  | Basic UX; no AI; no intelligence                    | Polish + intelligence + learning    |
| **Nansen**                      | On-chain analytics | Deep wallet data        | Terminal-separate; slow; high price                 | Integration + unified surface       |
| **TradingView**                 | Charting/alerts    | 50M users; ecosystem    | Generic; not crypto-native; no execution            | Crypto-native + execution pipeline  |
| **Bitmex Terminal**             | Power terminal     | Sophisticated features  | Complex UX; desktop-only; no mobile                 | Mobile-first + simplified UX        |
| **Bybit Mirror Trading**        | Copy tool          | Simple copy UX          | No thesis; no learning; mirror is dumb              | Thesis + learning + confidence      |
| **DeFi Protocol Dashboards**    | Aggregators        | Protocol-native         | Fragmented; no unified UX; no learning              | Unified experience                  |
| **Discord Trading Communities** | Social signal      | Real people; free       | Signal lost in noise; advice ≠ execution            | Structured + AI synthesis           |
| **Twitter Crypto Influencers**  | Signal             | Trusted voices          | Stale; biased; no execution; incentive misalignment | Systematic + transparent incentives |
| **Dune Analytics**              | Query platform     | Custom dashboards       | Manual queries; steep learning curve                | Pre-built, one-click intelligence   |

## 3.2 Six Defensible Differentiators

### 1. Real-Time Signal Synthesis

- **What**: Wallet clustering + heatmap generation + regime context + confidence scoring in <10 seconds
- **Why competitors don't**: Signal providers build for slow (hourly) workflows; terminals don't synthesize signals; copilot platforms are generic
- **How we do it**: Custom Hyperliquid data pipeline + precomputed clusters + streaming relevance update
- **Moat**: Data + speed + crypto-native focus

### 2. Rationale-Driven Trading

- **What**: Every trade plan includes the "why" — which evidence cluster, confidence, invalidation trigger, regime context
- **Why competitors don't**: Copy tools hide thesis; AI tools are black boxes; terminals have no thesis layer
- **How we do it**: Mandatory thesis capture (Belief Snapshot) + Copilot reasoning chain visible + journal linking
- **Moat**: Transparency + user trust + learning data

### 3. Safe Execution Layer

- **What**: Sizing guardrails, liquidation prevention, slippage estimates, regime veto, Kelly fraction capping
- **Why competitors don't**: Copiers don't guard; terminals don't contextualize; AI tools autonomous (risky)
- **How we do it**: Risk engine + pre-fill with guardrail-adjusted sizing + plan preview before submit
- **Moat**: Risk management + user retention (no blow-ups) + compliance-ready

### 4. Social + Signal Feedback Loop

- **What**: Execute → mark outcome → improve shared signal library + leaderboard credibility
- **Why competitors don't**: Copy tools are one-way; signal tools are anonymous; terminals have no social
- **How we do it**: Journal auto-population + attribution tracking + on-chain reputation (via Nansen/Privy)
- **Moat**: User-generated signal quality + network effects + viral leaderboard

### 5. Mobile-First Decision Loop

- **What**: Signal → Thesis → Execute → Learn, all in pocket, <90s
- **Why competitors don't**: Power terminals are desktop; copiers are web; mobile crypto trading is low-quality
- **How we do it**: Native iOS + Native Android + responsive web; optimized IA for 6" screen
- **Moat**: Lock-in (habit forming), accessibility (all-day trading), switching cost (learned muscle memory)

### 6. Hyperliquid-Native Integration

- **What**: Specialized, not generic; leverage Hyperliquid's builder codes, perp universe, funding dynamics
- **Why competitors don't**: Generic terminals don't optimize for one venue; Hyperliquid terminal lacks UX
- **How we do it**: Deep HLP API integration + Hyperliquid-specific heatmaps + vault dynamics
- **Moat**: Switching cost (retraining on other terminals), economic alignment (builder codes)

## 3.3 Six Positioning Gaps (Where Arx Wins)

| Gap # | Gap                             | Incumbent                                                         | Arx Solution                                                                              |
| ----- | ------------------------------- | ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| **1** | Intelligence on execution       | Minara (AI) OR Hyperliquid (execution) but never both             | Arx = Copilot suggests entry at 28K; pre-fills plan; submits; monitors                    |
| **2** | Explainable AI                  | Minara black-box; Nansen generic                                  | Every Copilot suggestion: evidence + confidence + counter-case + regime context           |
| **3** | Multi-asset DeFi terminal       | TradingView (generic), Dune (query), Hyperliquid (venue-specific) | Unified terminal: HLP perps + HIP-3 equities + spot + yield, one interface                |
| **4** | AI + Social hybrid              | Either weak AI (Discord) or weak social (Minara copy)             | Strong AI (Copilot) + strong social (leaderboard + copy tier + social signals)            |
| **5** | Progressive sophistication      | Different UIs for different users (complexity cliff)              | One product: Guided tier (P2), Standard tier (P1), Pro tier (P3/P5); tier-aware interface |
| **6** | On-chain transparency for trust | Centralized leaderboards (Bybit) or no proof (Discord)            | Privy + Nansen integration = every profile verifiable on-chain; sybil-resistant           |

## 3.4 Where Arx Does NOT Compete

Arx explicitly does NOT optimize for:

- **Lowest fees**: We charge 2.5bps (Free) or $29/mo (Gold); we don't compete on pure fee. We compete on _value_.
- **Global institutional scale**: We start with Hyperliquid, 10K users. We don't target 1M+ global audience in Y1.
- **Memecoin speed**: We don't support 10K meme tokens with 1-min candle data. We support 50-100 major perps.
- **Pure social network**: We're not Discord. We're a trading tool with social proof, not a social platform.
- **Desktop power-trading complexity**: We're mobile-first; desktop is responsive, not a power terminal for matrix traders.

---

# SECTION 4: BUSINESS MODEL & METRICS

## 4.1 Revenue Streams

### Stream 1: Builder Code Fees (2.5 bps on Free Tier Trades) — Day 1

**Mechanism**: Hyperliquid pays Arx 2.5 bps per notional traded on Free tier. Arx receives this whether user is aware or not.

**Math at Beachhead (2,060 Free users)**:

- Free users: 1,700 / 2,060 (82.5%)
- Trades/user/day: 5
- Avg notional per trade: $100K (mix of sizes)
- Free trades/day: 1,700 × 5 = 8,500 / day
- Monthly trades: 8,500 × 30 = 255,000
- Revenue: 255,000 × $100K × 0.0002 = $5.1M notional / month × 0.02% = **$154K / month**

**Sensitivity**:

- If 10K users: 1 million trades/mo = $770K/mo
- If 50K users: 5 million trades/mo = $3.85M/mo

### Stream 2: Subscriptions — Explore / Follow / Command

> **⚠️ UPDATED 2026-03-18:** Tier architecture redesigned from feature-gated (Free/Gold $29) to outcome-aligned (Explore/Follow/Command). See **Arx_3-7_Business_Model_and_Pricing.md** for complete feature segregation matrix.

**Tiers**: Explore (Free), Follow ($29/mo), Command ($79/mo)

**Key changes from original:**

- **Signals are FREE** — all 5 layers, real-time, no delay. Signals drive volume → builder fees.
- **Builder fee (2.5 bps) applies to ALL tiers** — no 0-bps waiver for paid users
- **Tiers defined by user intent**, not feature counts: Explore = "trade yourself", Follow = "copy traders you trust", Command = "automate your edge"
- **Leaders earn 30/5/2 referral commissions on referred users' builder fees (2.5 bps)** + free Command at 50+ copiers (supply-side incentive for two-sided marketplace). See Arx_3-7 §4.

**Revenue per user:**

- Explore (Free): $10.50/mo (builder fees only)
- Follow ($29): $44.00/mo (builder + subscription + copy volume uplift)
- Command ($79): $105.33/mo (builder + subscription + copy mgmt fee + volume uplift)

**Pricing Rationale**:

- $29 = 2.5 × Copilot API cost + infrastructure
- Payback period: 6 weeks (if CAC < $50)
- LTV (12mo): 12 × $29 = $348 (+ builder codes on trading if kept on free tier)

### Stream 3: Copy Trading Revenue — The Flywheel (Phase 2, M6+)

> **⚠️ UPDATED 2026-03-18:** Copy trading revenue model redesigned based on competitive research (14 platforms analyzed — Bitget, OKX, BingX, Bybit, Binance, Gate.io, KuCoin, MEXC, HTX, Phemex + eToro, ZuluTrade, NAGA, Darwinex). See **Arx_3-7 §4 and §7** for full details.

**Key changes from original 20% outperformance fee model:**

- **No platform cut of leader performance fee** (0% — matching all 10 crypto CEXs)
- Leaders keep 100% of their performance fee (10-20%, leader sets)
- **Revenue from copy trading:** (A) volume uplift → builder fees, (B) 1% annual mgmt fee on Pro "AI Risk Shield" managed copy AUM only
- **Leader incentive:** 30/5/2 referral commissions on referred users' builder fees (2.5 bps) + free Command at 50+ copiers
- **Rationale:** Darwinex (only TradFi platform with a platform fee) charges 1.2% mgmt + 5% perf because they add risk management value. Arx's "AI Risk Shield" justifies a similar modest mgmt fee. But NO crypto CEX takes a performance cut — doing so would deter leader recruitment.

### Stream 4: Referral Rebate from Hyperliquid — Day 1

**Mechanism**: Hyperliquid pays 50% of first 30 days of trading fees earned on referred users.

**Math at Beachhead**:

- New users referred: 100/month (via referral link + leaderboard)
- Avg trading volume/new user: $200K/month
- Hyperliquid takes 2.5 bps (per their schedule)
- Revenue: 100 × $200K × 0.025% × 50% = **$2.5K / month**

At 10K users: ~$12K/mo. At 50K: ~$60K/mo.

---

## 4.2 Financial Projections — Beachhead Cohort

| Metric                    | M1     | M3    | M6     | M12       |
| ------------------------- | ------ | ----- | ------ | --------- |
| **Total Users**           | 250    | 1,200 | 2,600  | 8,000     |
| **Free Users**            | 205    | 990   | 2,210  | 6,800     |
| **Gold Users**            | 45     | 210   | 390    | 1,200     |
| **Builder Code Revenue**  | $19K   | $77K  | $167K  | $330K     |
| **Gold Revenue**          | $1.3K  | $6.1K | $11.3K | $34.8K    |
| **Copy Revenue**          | $0     | $0    | $3K    | $24K      |
| **Referral Revenue**      | $0.2K  | $1K   | $2.5K  | $12K      |
| **Total Monthly Revenue** | $20.5K | $84K  | $184K  | $400K     |
| **Total Annual (M12)**    | —      | —     | —      | **$4.8M** |

**Payback Period**: Assuming CAC of $50/user, LTV of 12-month revenue of $50/user = break-even. Assuming LTV extends 24mo, LTV:CAC ratio >10:1 by M12.

## 4.3 Unit Economics

| Metric                              | Value                    | Notes                                         |
| ----------------------------------- | ------------------------ | --------------------------------------------- |
| **CAC (Customer Acquisition Cost)** | <$50                     | Referral + organic; higher if paid ads needed |
| **ARPU (Average Revenue Per User)** | $85 / month              | Blended: (Free builder 2.5bps) + (Gold 17.5%) |
| **LTV (Lifetime Value, 12mo)**      | $1,020                   | 12 × $85                                      |
| **LTV:CAC**                         | >20:1                    | Sustainable                                   |
| **Payback Period**                  | ~6 weeks                 | (CAC / (ARPU × % margin))                     |
| **Churn Rate Target**               | <5% / month              | (Fintech typical: 5-8%)                       |
| **Retention (12mo)**                | >60%                     | Implies 94.5% monthly retention               |
| **Upgrade Rate (Free → Gold)**      | >15% (Day 1) → 25% (M12) | Copilot engagement drives                     |

---

# SECTION 5: JOBS TO BE DONE

## 5.1 Six Jobs the Strategic Learner (P1) Hires Arx to Do

| JTBD # | Job Statement                          | Core Pain                                                                            | Arx Solution                                                                                                                                                         | Success Metric                                        | Priority |
| ------ | -------------------------------------- | ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- | -------- |
| **1**  | Find good "teachers" for a symbol      | Smart money is noise without segmentation; sybil risk; hidden incentives             | Cohort Filters (by style, leverage, holding time, risk) → Signature Cards → Follow/Subscribe                                                                         | Identify 1-2 trusted traders in <30s                  | **P0**   |
| **2**  | Decide whether now is good time to act | No regime context; trade in wrong conditions 40% of time; miss when conditions right | Regime Bar (trending/range/compression/transition) + Market Narrative (funding, OI, sentiment z-scores)                                                              | >70% of trades in favorable regime                    | **P1**   |
| **3**  | Form trade plan from evidence          | "I see smart money" but "I have no entry/exit/size" — 15 min gap to usable plan      | Cluster-to-Plan Translator (suggests entry/TP/SL/size based on cluster distribution) + Plan Builder (chart overlay + guardrails)                                     | Evidence-to-Plan: <60s                                | **P0**   |
| **4**  | Act when smart money moves             | Copy stale moves; miss fast movers; alert fatigue (100+ alerts/day)                  | Ranked alerts (by confidence, regime, recency) + Arx suggests next move (Copilot Conviction Card) + Trigger → Prefilled order                                        | Alert-to-action: <30s                                 | **P0**   |
| **5**  | Execute efficiently                    | 3-5s decision-to-button delay; slippage 5-20bps; fees 2.5bps                         | One-tap execution with pre-filled ticket; execution strategy selector (market/limit/bracket → TWAP/VWAP for Gold); slippage meter; guaranteed fill confirmation      | Slippage <5bps (vs. 15bps industry)                   | **P1**   |
| **6**  | Learn and graduate                     | No "why" capture; luck/skill indistinguishable; repeated mistakes                    | Mandatory Belief Snapshot (pre-trade rationale) + Auto-journal (trade + outcome + evidence saved) + Attribution Analysis (direction/timing/execution/luck breakdown) | >50% trades rationale-captured; measurable win-rate ↑ | **P1**   |

## 5.2 P0 Conversion Chain (Critical Path)

The seven-stage flow below is the core value proposition. Missing **any** link breaks P1's ability to execute:

```
┌─────────────┬──────────┬─────────┬─────────┬──────────┬────────┬──────────┐
│ Teachers    │ Evidence │ Plan    │ Trigger │ Execute  │Monitor │ Learn    │
├─────────────┼──────────┼─────────┼─────────┼──────────┼────────┼──────────┤
│ Cohort      │ Heatmaps │ Cluster │ Subscribe│ Prefilled│ Alerts │ Rationale│
│ Filters →   │ Cohort   │→ Plan   │→ Recency │→ Order   │→ De-   │→ Journal │
│ Signature   │ Overlay  │ Guardian│→ Signal  │→ Risk    │→ Health│→ Attrib  │
│ Cards       │ Evidence │ Sizing  │ Monitor  │→ Confirm │ Review │ Attribution
│             │ Bundle   │ TradePlan │        │          │        │          │
└─────────────┴──────────┴─────────┴─────────┴──────────┴────────┴──────────┘
```

**Validation Rules**:

- Engineer can build each link independently from 5.2 spec
- Each link has acceptance criteria (Given/When/Then)
- No link leaves user in ambiguous state
- At M1 end, P0 links (1, 2, 3, 4) complete 100%; P1 links (5, 6) at 80%

---

# SECTION 6: THE JOURNEY — SEVEN STAGES

The Strategic Learner's trading journey through Arx, mapped to screens, IA, features, and interactions:

## Stage A: ORIENT — Choose symbol, set constraints, generate candidate set

**Goal**: User decides what to trade and who to follow.

**Information Architecture**

- Primary screens: Explore/Discovery → Symbol Detail → Filter Panel → Ranked Address List → Signature Cards
- Secondary: Leaderboard → Trader Detail

**Data Displayed**

- Symbol cards: Price, 24h change, volume, smart money signal score (0-100), trending direction (up/down/mixed)
- Filters: Leverage range (1-20x), win rate (30-100%), holding time (5m-30d), style (momentum/counter/scalp), region if available
- Address list: Ranked by (1) confluence (how many other cohort members agree), (2) recent activity, (3) win rate
- Signature card: Wallet stats (win rate, avg hold, avg size, leverage), recent trades (direction, outcome), risk profile (Sharpe ratio, max DD)

**P0 Features Required**

1. **Cohort Filters** — Drill into "traders who are bullish on BTC right now"
   - Filter by leverage (1-10x)
   - Filter by holding time (<1h, 1-4h, 4h-1d, 1d+)
   - Filter by win rate (last 30 trades)
   - Filter by style (momentum/counter/scalp)
   - Filter by recent activity (traded in last 24h)
2. **Signature Cards** — One-screen snapshot of a trader
   - Wallet address (truncated, copyable)
   - On-chain verification badge (from Nansen)
   - Win rate (last 30 trades)
   - Avg hold time
   - Avg leverage
   - Recent trades (last 5: direction, entry, exit, P&L, duration)
   - Risk profile (max drawdown, Sharpe)
   - Follow button (free)
   - Subscribe button (for alerts)
3. **Compatibility Scoring** — "How well does this trader match my style?"
   - Compare user's past leverage vs. trader's average → compatibility %
   - Compare user's holding time vs. trader's average → compatibility %
   - Compare user's symbols vs. trader's symbols → overlap %
   - Overall compatibility score (0-100)
   - Display: "You match this trader 82%. Consider following."

**Key Interaction Patterns**

1. User taps Explore → see trending assets by signal strength
2. User taps asset card → Symbol Detail screen
3. User filters by leverage + holding time → narrows candidate set from 500 to 40 traders
4. User taps trader from list → Signature Card pops up
5. User taps Follow → trader added to "Following" list
6. User taps Subscribe Alerts → configures alert types (entry, exit, new position)

**State Machine**

```
[No Symbol Selected]
    ↓ (user taps asset)
[Symbol Detail Loaded, Filters Visible]
    ↓ (user adjusts filters)
[Filtered Address List, N traders shown]
    ↓ (user taps trader)
[Signature Card Displayed, Follow/Subscribe buttons active]
    ↓ (user follows)
[Trader Added to Following, Ready for Stage B]
```

**Edge Cases**

- User filters too narrow → 0 results → Show "Try relaxing filters" + suggestions
- Trader has <5 trades → Show warning "Limited history; use caution"
- Trader stopped trading 30+ days ago → Show stale indicator; suggest similar active trader
- User tries to follow self → Show warning; prevent

**Acceptance Criteria (Given/When/Then)**

| #   | Scenario              | Given                      | When                                           | Then                                                                         |
| --- | --------------------- | -------------------------- | ---------------------------------------------- | ---------------------------------------------------------------------------- |
| A1  | User discovers asset  | User on Explore screen     | User taps BTC card                             | Symbol Detail loads <1.5s                                                    |
| A2  | User filters traders  | Symbol Detail loaded       | User adjusts leverage filter from 1-5x → 2-10x | List updates <500ms                                                          |
| A3  | User follows trader   | Signature Card shown       | User taps Follow                               | Trader added to Following list; confirm toast "Following [wallet_truncated]" |
| A4  | Compatibility scoring | Signature Card shown       | User taps trader                               | Compatibility % shown; color-coded (green >70%, yellow 50-70%, red <50%)     |
| A5  | Zero traders match    | User filters applied       | All traders excluded                           | Show "No traders match. Try relaxing leverage filter." + suggestion cards    |
| A6  | Stale trader          | Trader last traded 45d ago | User views signature card                      | Show warning badge "Not active recently"                                     |

---

## Stage B: DEVELOP BELIEF — Gather evidence, form directional bias, record conviction

**Goal**: User looks at the evidence and makes a call: bullish, bearish, or neutral. Strength?

**Information Architecture**

- Primary screen: Trade Screen (Chart Zone + Intelligence Drawer)
- Intelligence Drawer tabs: Evidence, Clusters, Copilot, Social

**Data Displayed in Evidence Tab**

1. **Entry/Exit/Liquidation Heatmaps** — On chart, show density of buys/sells/liquidations
   - Entry heatmap: Red (short clusters) to Green (long clusters), 20-100K range, labeled "15 traders long 28-30K"
   - Exit heatmap: Where traders take profit (TP zones)
   - Liquidation heatmap: Where cascades happen (risk zones)
   - Funding rate heatmap: Overleaf showing funding dynamics
2. **Cohort Comparison Overlay** — "Followed traders vs. broader market"
   - Blue line: Price
   - Green shaded area: Where your followed traders are concentrated (bimodal if disagreement)
   - Alpha bar: "Your cohort is 340 bps ahead of index (last 7d)"
3. **Cluster Drill-Down** — "Click heatmap cluster to see who's there"
   - Tap 28-30K cluster → show list of 15 traders with positions there, ordered by credibility
   - Show confluence: "8/15 are in + regime, 7/15 have >60% win rate"
   - Show divergence: "2/15 are contrarian short here"
4. **Market Narrative** — LLM synthesis of all signals
   - "Longs paying 0.04%/8h (historically precedes pullback 67% of time). OI up 12% in 4h. 5 whale clusters long 28-30K. Counter: spot volume down, retail selling on CEX."
   - Confidence: 62%

**P0 Features Required**

1. **Heatmaps** (entry/exit/liquidation on chart)
2. **Cohort Overlay** (where followed traders cluster)
3. **Cluster Drill-Down** (who's in the cluster?)
4. **Thesis Capture** — "Record my belief now, before I trade"
   - Direction (long / short / neutral)
   - Confidence (0-100 slider)
   - Invalidation trigger ("if price breaks below 27K, I'm wrong")
   - Save as "Belief Snapshot"

**Key Interaction Patterns**

1. User taps Trade Screen for BTC
2. Chart loads with heatmaps visible
3. User reads Market Narrative (Copilot-generated)
4. User taps 28-30K cluster → Cluster Drill-Down shows 15 traders
5. User reviews confluence: 8/15 agree, all in + regime
6. User feels confident → opens Thesis Capture
7. User inputs: "Long, confidence 75%, invalidate below 27K"
8. Saves belief snapshot; advances to Stage C

**State Machine**

```
[Trade Screen Loaded, Evidence Tab Active]
    ↓ (user reviews heatmaps)
[Heatmaps analyzed, confidence forming]
    ↓ (user taps Cluster Drill-Down)
[Cluster Info Displayed]
    ↓ (user reviews confluence, narrative)
[Belief Formed]
    ↓ (user taps Thesis Capture)
[BeliefSnapshot Modal Open]
    ↓ (user inputs direction, confidence, invalidation)
[BeliefSnapshot Saved, Ready for Stage C]
```

**Edge Cases**

- Cluster too small (1 trader only) → Show warning "Limited agreement; consider widening view"
- Heatmaps show extreme disagreement (equal longs and shorts) → Narrative says "Indecision; consider waiting for regime clarity"
- User skips Thesis Capture → Show nudge "Save your belief? It helps you learn."

**Acceptance Criteria**

| #   | Scenario             | Given                              | When                                                                 | Then                                                                                          |
| --- | -------------------- | ---------------------------------- | -------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| B1  | Heatmap loads        | Trade Screen opened, chart visible | Chart finishes rendering                                             | Heatmaps appear <1s, overlays not occluding price                                             |
| B2  | Cluster drill-down   | Heatmap cluster visible            | User taps cluster                                                    | Popup shows list of traders + confluence score <300ms                                         |
| B3  | Confluence scoring   | Cluster drill-down open            | System displays 15 traders                                           | Confidence score calculated: "12/15 in + regime"                                              |
| B4  | Narrative generated  | Evidence tab loaded                | User views                                                           | Market Narrative displays within 3s; includes funding, OI, whale clusters, contrarian signals |
| B5  | Thesis capture       | Thesis Capture modal open          | User inputs: Direction=Long, Confidence=75, Invalidation="below 27K" | Save button active; saves with timestamp                                                      |
| B6  | Disagreement flagged | Heatmaps show equal longs/shorts   | Chart renders                                                        | Narrative says "Indecision" + regime bar shows low conviction                                 |

---

## Stage C: DEVELOP TRADE — Define entry, TP/SL, size, save plan

**Goal**: User turns belief into executable plan.

**Information Architecture**

- Primary screen: Trade Screen (Chart Zone, Intelligence Drawer, Action Panel)
- Action Panel sub-view: Plan Builder

**Data & Features in Plan Builder**

1. **Cluster-to-Plan Translator** — AI suggests entry/TP/SL from heatmap
   - System analysis: 15 traders clustered 28-30K; median entry 28.2K, 25th %ile 27.8K, 75th %ile 28.6K
   - Suggestion: "Entry 28K, TP 31K (+10.7%), SL 26.5K (-5.4%), Target Size $50K (2.1x leverage)"
   - Reasoning: "Based on 15-trader consensus at 28-30K. TP from observed exits. SL from liquidation zone below 26K."
2. **Plan Builder UI** — Drag-and-drop on chart + form inputs
   - Chart overlay: Draggable entry line, draggable TP line, draggable SL line
   - Form: Entry price [ ], TP price [ ], SL price [ ], Size $ [ ], Leverage [ ]
   - Guardrail feedback: "At this SL, you risk 5.4% of account. OK." or "Risk 12%. Consider tighter SL or smaller size."
3. **Sizing Guardrails** — Prevent reckless sizing
   - Max leverage: 3x (configurable, P1 Jake: 2.5x)
   - Max % account risk: 5% (configurable, P1 Jake: 4%)
   - Kelly fraction: Suggest size based on win rate + edge (conservative: 0.5x Kelly)
   - Liquidation warning: "If BTC moves 8% against you, account liquidates."
4. **Plan Preview** — Before submitting, show full trade diagram
   - Chart shows entry/TP/SL marked
   - Info box: "Entry $28K, TP $31K, SL $26.5K, Size $50K (2.1x), Risk $2.7K, Reward $15K, RR: 5.6:1"
   - Confidence: "Confidence 75% (from Belief). Copilot: 81% (ensemble)."

**P0 Features Required**

1. **Cluster-to-Plan Translator** (AI suggestion from heatmap clusters)
2. **Plan Builder** (chart overlay + form inputs)
3. **Sizing Guardrails** (leverage/risk capping)
4. **Plan Preview** (full diagram before submit)
5. **Plan Save** (store for later or immediate execution)

**Key Interaction Patterns**

1. User at Stage B end, BeliefSnapshot saved
2. Copilot Conviction Card appears: "Long BTC 28K → 31K"
3. User taps "Build Plan" button
4. Plan Builder opens; Translator suggests entry/TP/SL
5. User drags entry line on chart to 28.3K (refines)
6. User drags TP to 31.2K
7. User adjusts size from $50K to $40K (risk reduction)
8. Guardrail: "OK, risk 4.3% of account"
9. User reviews preview; hits "Save & Continue to Execute" or "Save & Monitor"

**State Machine**

```
[Stage B Complete, BeliefSnapshot Saved]
    ↓ (Copilot Conviction Card shown)
[User taps "Build Plan"]
    ↓
[Plan Builder Loads, Translator Suggests entry/TP/SL]
    ↓ (User adjusts via chart overlay or form)
[User Adjusts Parameters]
    ↓ (Guardrails validate, feedback given)
[Guardrails OK or flagged]
    ↓ (User reviews Plan Preview)
[Plan Preview Displayed]
    ↓ (User taps Save & Continue)
[TradePlan Saved, Ready for Stage D or E]
```

**Edge Cases**

- Translator has no data (brand new symbol) → Show manual form; suggest Kelly-based sizing
- User tries 10x leverage → Guardrail blocks; shows "Max 3x, consider 2x"; suggests size reduction
- Plan is contrarian to regime → Warning: "+ regime, but plan is short. Reconsider?"
- User saves plan but doesn't execute → Plan stored in Plans list; can execute later

**Acceptance Criteria**

| #   | Scenario                 | Given                                    | When                          | Then                                                                                              |
| --- | ------------------------ | ---------------------------------------- | ----------------------------- | ------------------------------------------------------------------------------------------------- |
| C1  | Translator suggests plan | Cluster data loaded                      | User views Plan Builder       | Suggestion appears <1.5s with entry/TP/SL/size/reasoning                                          |
| C2  | User adjusts via chart   | Suggestion loaded                        | User drags entry line         | Form inputs update <200ms                                                                         |
| C3  | Guardrail validation     | User sets 5x leverage, $60K size, SL 26K | System calculates risk        | Risk flagged as 8.2%; guardrail warning shown; Save button disabled until risk <5%                |
| C4  | Plan preview             | Plan Builder complete                    | User taps "Preview"           | Full diagram displays: entry/TP/SL marked, RR ratio shown, confidence and copilot agreement shown |
| C5  | Plan save                | Plan preview shown                       | User taps "Save Plan"         | TradePlan created; UUID assigned; saved to Plans list + linked to BeliefSnapshot                  |
| C6  | Contrarian plan          | Plan is short, regime is +               | Chart and guardrails rendered | Warning badge shown: "Regime is bullish; plan is bearish. Confirm?"                               |
| C7  | No data edge case        | Trader has 0 prior trades                | Translator runs               | Form opens empty; Kelly suggestion based on account size and risk %                               |

---

## Stage D: VALIDATE — Check plan against current market conditions

**Goal**: Ensure plan still makes sense given current price/regime/funding/liquidation dynamics. This stage applies to the **Trade Myself flow** (ARX_2-2-2 §5B) where the user sets every parameter. For the **Copy Trade flow** (ARX_2-2-2 §5A), validation is automatic — the system checks regime match, gating status, and allocation limits before executing the copy.

> **Rationale framework** (ARX_2-2-2 §5C): Every validation screen includes the 4-layer rationale — (1) headline rationale in plain language, (2) signal breakdown with verifiable sources, (3) leader's own words + TradingView links, (4) context warnings / contra-signals.

**Information Architecture**

- Primary screen: Trade Screen (Action Panel, sub-view: Validation)

**Data & Features in Validation Sub-View**

1. **Market Condition Check** — Is regime still favorable?
   - Regime bar: Trend / Range / Transition / Compression
   - Funding: 0.04% (8h), if >0.05% show warning "Longs overleveraged"
   - OI: Up 5% (4h), Up 12% (24h); suggest caution if extreme
   - Liquidation cascade risk: "Light; no cascades likely."
2. **Stale Evidence Warning** — Were heatmaps generated recently?
   - Evidence age: "Generated 5 min ago" (green) vs. "Generated 1h ago" (yellow) vs. "Generated 4h+ ago" (red)
   - Auto-refresh suggestion: "Evidence >30m old. Refresh? (may change recommendation)"
3. **Risk Exposure Check** — Will this trade breach any guardrails given current state?
   - Current account balance: $45K
   - Existing positions: Short 0.5 BTC (TP 31K, SL 26.5K) — OK
   - New plan: Long 1.2 BTC (TP 31K, SL 26.5K) — Check portfolio effect
   - Warning: "New position hedges existing short. Redundant? (net delta near 0)"
4. **Validator Status** — All-green or any reds?
   - ✅ Regime favorable (Trending + regime bar green)
   - ✅ Funding reasonable (<0.06%)
   - ✅ Evidence fresh (<10 min old)
   - ⚠️ High OI (OI up 15%; suggest smaller size or monitor carefully)
   - ✅ Account OK (would be 2.1x after trade; max 3x policy)

**P1 Features Required**

1. **Market Condition Check** (regime, funding, OI, liquidation risk)
2. **Stale Evidence Warning** (age of heatmaps)
3. **Risk Exposure Check** (portfolio-level, existing positions)
4. **Validator Status** (all-green or warnings)
5. **Auto-Refresh** (user can refresh evidence; Copilot suggests if >30m stale)

**Key Interaction Patterns**

1. User at Plan Preview stage, ready to execute
2. User taps "Validate" sub-view in Action Panel
3. Validation checks run (<500ms)
4. All-green or warnings displayed
5. If all-green: User taps "Ready to Execute" → Stage E
6. If warnings: User taps "Refresh Evidence" or "Adjust Plan" or proceeds anyway

**State Machine**

```
[Stage C Complete, Plan Preview Shown]
    ↓ (User taps "Validate")
[Validation Checks Run]
    ↓
[Validator Status Displayed: ✅✅⚠️✅✅]
    ↓ (User reviews warnings)
[User taps "Proceed" or "Adjust Plan"]
    ↓ (if Proceed)
[Ready for Stage E: Execute]
    OR
[User Modifies Plan, Returns to C]
```

**Edge Cases**

- Evidence is 2h old → Auto-nudge "Refresh?" → User taps → New heatmaps loaded; recommendation may change
- Regime changed to Compression → Warning "Regime unclear; consider waiting" but allow execution
- Account would hit 3x max leverage → Block execution; suggest size reduction
- Funding spiked to 0.08% → Warning "Longs paying high; liquidation risk up"

**Acceptance Criteria**

| #   | Scenario               | Given                                         | When                            | Then                                                                          |
| --- | ---------------------- | --------------------------------------------- | ------------------------------- | ----------------------------------------------------------------------------- |
| D1  | Regime check           | Trade screen, plan ready                      | Validation view opens           | Regime bar displays (Trending / Range / Compression / Transition) <200ms      |
| D2  | Funding alert          | Funding rate 0.07%                            | Validation renders              | Warning shown: "Longs paying 0.07%; liquidation risk. Consider smaller size." |
| D3  | Evidence freshness     | Evidence age 45 min                           | Validation shows                | Yellow age indicator + "Refresh?" button visible                              |
| D4  | Risk exposure check    | Existing short 0.5 BTC, new plan long 1.2 BTC | Validation calculates portfolio | Warning: "Net long 0.7 BTC. Current hedge short removed. Confirm?"            |
| D5  | All-green status       | All checks pass                               | Validator status displays       | All green ✅; "Ready to Execute" button active                                |
| D6  | High OI flag           | OI up 18% in 24h                              | Validation renders              | Orange warning: "High OI. Consider monitoring closely."                       |
| D7  | Stale evidence refresh | User taps "Refresh"                           | New data fetch starts           | Loading spinner; new heatmaps appear <2s; recommendation may update           |

---

## Stage E: EXECUTE — Place order, select execution strategy

**Goal**: Submit the order with minimal friction and maximum clarity.

**Information Architecture**

- Primary screen: Trade Screen (Action Panel, sub-view: Order Execution)

**Data & Features in Order Execution**

1. **Pre-Filled Order Ticket** — Populated from TradePlan
   - Side: Long (radio button)
   - Size: 1.2 BTC (editable)
   - Order type: Limit (dropdown: Market / Limit / Stop / Bracket)
   - Limit price: 28,000 (editable, defaults to entry from plan)
   - TP: 31,000 (auto-add child order if "Bracket" selected)
   - SL: 26,500 (auto-add child order if "Bracket" selected)
   - Leverage: 2.1x (editable up to policy max)
   - Slippage estimate: 0.3% (real-time, updates as price moves)

2. **Execution Strategy Selector** — For Gold tier only
   - Market: "Buy market, instant fill" (fastest; highest slippage)
   - Limit: "Buy at 28K or better" (slower; lower cost)
   - Stop: "If price hits 28.5K, buy at market" (conditional)
   - Bracket: "Entry + auto TP/SL" (recommended)
   - TWAP (Gold): "Divide into 10 trades over 5 min" (smooths entry)
   - VWAP (Gold): "Target volume-weighted avg price" (reduces slippage)
   - Iceberg (Gold): "Hide size, show 0.1 BTC increments" (reduces market impact)
   - Grid (Gold, P1): "Place 5 entries from 27.8K-28.2K, scale up on fills" (dollar-cost-average)

3. **Slippage Meter** — Real-time estimate
   - Current price: 28,015
   - Entry order: 28,000
   - Estimated slippage: 0.05% on market execution, 0.00% on limit
   - "Market fill would cost $336 in slippage on $1.2M notional. Limit may not fill if market rallies."

4. **One-Tap Confirm** — Big green button
   - "PLACE ORDER: Long 1.2 BTC @ 28K, TP 31K, SL 26.5K"
   - Disabled until all mandatory fields filled
   - On tap: Submit → Confirmation screen with order ID

5. **Order Confirmation** — After submit
   - Order ID (Hyperliquid order hash)
   - Status: "Pending" → "Filled" / "Partially Filled" / "Rejected"
   - Fill price, fill quantity
   - Actual slippage vs. estimate
   - Linked to BeliefSnapshot + TradePlan
   - Button: "Monitor Position" (goes to Stage F) or "Back to Explore"

**P0 Features Required**

1. **Pre-Filled Order Ticket** (from TradePlan)
2. **Execution Strategy Selector** (Free: Market/Limit/Stop/Bracket; Gold: + TWAP/VWAP/Iceberg/Grid)
3. **Slippage Meter** (real-time estimate)
4. **One-Tap Confirm** (safe, hard to misclick)
5. **Order Confirmation** (post-submit status)

**Key Interaction Patterns**

1. User at Validation stage, all-green
2. User taps "Execute" or "Place Order"
3. Order Execution view opens; ticket pre-filled from plan
4. User reviews ticket (entry, TP, SL, size, leverage)
5. User selects execution strategy (Free: Limit or Bracket; Gold: TWAP recommended)
6. User reviews slippage meter ("Market costs $336 slippage; Limit costs $0 but may not fill")
7. User taps "PLACE ORDER" → confirmation screen
8. Order submitted to Hyperliquid; awaits fill
9. On fill: "Position opened. Moving to monitoring." → Stage F

**State Machine**

```
[Stage D Complete, Validation Passed]
    ↓ (User taps "Execute" or "Place Order")
[Order Execution View Opens, Ticket Pre-Filled]
    ↓ (User adjusts ticket if needed)
[User Selects Execution Strategy]
    ↓ (User reviews slippage]
[User Taps "PLACE ORDER"]
    ↓
[Order Submitted, Status: Pending]
    ↓ (Hyperliquid processes)
[Order Status: Filled / Partial / Rejected]
    ↓ (if Filled)
[Confirmation Screen, Linked to BeliefSnapshot + TradePlan]
    ↓ (User taps "Monitor")
[Ready for Stage F: Monitoring]
```

**Edge Cases**

- User tries market order, slippage >0.5% → Warning: "Slippage 1.2%. Use limit?" but allow
- Order rejected (insufficient margin) → Error: "Insufficient margin. Reduce size or increase account funding." Suggest adjustment.
- Partial fill → Status shows "Filled 0.6 / 1.2 BTC". Option to "Cancel remainder and adjust SL/TP" or "Wait for more fills"
- Price moves >0.2% before fill → Slippage meter updates; show "Price moved. Slippage now 0.15%."
- User cancels order while pending → Status changes; returns to Plan Builder ("Cancel successful. Adjust plan?")

**Acceptance Criteria**

| #   | Scenario          | Given                          | When                    | Then                                                                                                  |
| --- | ----------------- | ------------------------------ | ----------------------- | ----------------------------------------------------------------------------------------------------- |
| E1  | Ticket pre-fill   | TradePlan ready                | Order Execution opens   | Ticket auto-populated: entry=28K, TP=31K, SL=26.5K, size=1.2 BTC                                      |
| E2  | Strategy selector | Order ticket displayed         | User views dropdown     | Free: Market/Limit/Stop/Bracket; Gold: +TWAP/VWAP/Iceberg/Grid                                        |
| E3  | Slippage meter    | Current price 28,015           | User views meter        | Estimate shown: "Market: 0.05% slippage ($336)" vs "Limit: 0.00% ($0 but may not fill)"               |
| E4  | Confirm button    | Ticket complete                | User reviews            | "PLACE ORDER" button enabled if all mandatory fields ≠ null                                           |
| E5  | Order submit      | User taps "PLACE ORDER"        | API call to Hyperliquid | Order ID returned; status "Pending"; <500ms confirmation page load                                    |
| E6  | Fill confirmation | Order pending, market hits 28K | Order matches           | Status updates: "Filled 1.2 BTC @ 27,998 avg. Actual slippage: 0.07%."                                |
| E7  | Partial fill      | Order pending, market hits 28K | 0.6 BTC fills           | Status: "Partial: 0.6 / 1.2 BTC filled @ 27,998". Options: "Cancel remainder" or "Wait for more"      |
| E8  | Order rejection   | User hits confirm              | Insufficient margin     | Error: "Rejected: Insufficient margin for 2.1x leverage. Max $38K notional. Reduce size to 0.85 BTC?" |

---

## Stage F: MONITOR — Manage positions, adjust, de-risk

**Goal**: Oversee position, adjust TP/SL as conditions change, take profits, prevent cascades.

**Information Architecture**

- Primary screens: Portfolio → Position Detail, Alerts

**Data & Features in Portfolio View**

1. **Position Health Snapshot**
   - Symbol: BTC
   - Entry: 28,000
   - Current: 28,850 (P&L +$10,200 on 1.2 BTC)
   - TP: 31,000 (profit remaining +$2,580)
   - SL: 26,500 (loss if triggered -$1,800)
   - % account: 2.1x leverage, 21% of $45K account at risk
   - Time open: 2h 14m
   - Status: Open, Healthy (green), P&L positive

2. **TP/SL Adjustment**
   - Move SL from 26,500 to 27,500 ("Trail stop" button: auto-tighten as price rises)
   - Move TP from 31,000 to 32,000 (let winners run)
   - Lock-in: "Close 50% at 31K, let 50% run to 32K" (partial take-profit)

3. **De-Risk Triggers** — Copilot alerts
   - Regime turned Ranging → Copilot: "Trend broken. Consider taking 50% profit?"
   - Funding spiked to 0.08% → Copilot: "Longs overleveraged. Risk on. Consider 30% SL tighten?"
   - Session health: "You've won 3 in a row; consider reducing size on next trade (overconfidence bias)"
   - Liquidation cascade risk: "Volume spike suggests whale liquidation. Consider partial close?"

4. **Position Monitoring Dashboard**
   - Chart: Real-time price with entry/TP/SL lines
   - P&L curve: Time-series of unrealized P&L
   - Alert log: All Copilot suggestions, user actions (SL tightened, partial profit-taken, etc.)

**P0 Features Required**

1. **Position Health Snapshot** (entry, current, TP, SL, P&L, leverage, status)
2. **TP/SL Adjustment** (buttons to move, partial profit-take)
3. **De-Risk Triggers** (Copilot alerts, regime changes, funding spikes)
4. **Position Monitoring Dashboard** (chart + P&L curve + alert log)

**P1 Features Required**

1. **Trailing Stop** (auto-tighten SL as price moves up)
2. **Alerts** (configure price, funding, regime alerts)
3. **Session Health Monitoring** (win rate this session, bias warnings)

**Key Interaction Patterns**

1. Order filled (Stage E complete)
2. User taps "Monitor Position" → Portfolio → Position Detail
3. User sees Position Health Snapshot
4. Copilot alerts arrive as position moves (real-time updates)
5. If TP hit: System auto-closes; shows "TP reached at 31,000. +$2,580 profit. Congratulations!"
6. If SL hit: System auto-closes; shows "SL hit at 26,500. -$1,800 loss. Lessons learned?"
7. If regime changes: Copilot suggests "Trend broken, consider 50% close"
8. User can adjust TP/SL, or let position run until automatic close

**State Machine**

```
[Stage E Complete, Order Filled, Position Opened]
    ↓ (User taps "Monitor" or navigates to Portfolio)
[Position Detail View Loaded]
    ↓ (Position monitored, Copilot alerts stream)
[Copilot Alerts / Price Movement / Regime Changes]
    ↓ (User reviews alerts)
[User taps "Take 50% Profit" or "Tighten SL" or "Let it run"]
    ↓ (Position adjusted or unchanged)
[Position Continues / TP Hit / SL Hit / Partial Close]
    ↓ (if TP/SL hit)
[Position Closed, Outcome Captured]
    ↓ (Ready for Stage G: Reflection)
```

**Edge Cases**

- Liquidation cascade starts; position at risk → Copilot aggressive: "CLOSE NOW. Cascade starting." Offer one-tap close.
- Funding spikes to 0.15% (extreme) → Copilot urgent: "Funding at extreme. Close or reduce?" with 30% risk reduction suggestion
- User manually sets SL too wide (3%) → Copilot: "SL very wide; typical: 2%. Tighten?"
- Position swings into large unrealized loss → Copilot: "Down $5K (11% account). Hold or cut? Belief still valid?"
- User steps away; comes back 6h later to position still open → Summary: "You were long BTC 6h ago @ 28K. Now 28,500. Still +$6K. TP still 31K. Want to monitor or close?"

**Acceptance Criteria**

| #   | Scenario             | Given                     | When                          | Then                                                                                     |
| --- | -------------------- | ------------------------- | ----------------------------- | ---------------------------------------------------------------------------------------- |
| F1  | Health snapshot      | Position open             | Portfolio view renders        | Entry, current, TP, SL, P&L, leverage, status all visible <1s                            |
| F2  | Copilot alert        | Regime changes to Ranging | Copilot monitors              | Alert pops: "Trend broken. Close 50%?" with one-tap button                               |
| F3  | SL adjustment        | User taps "Tighten SL"    | SL moves from 26.5K to 27K    | SL updated immediately; display shows "New max loss: $1.2K (vs. $1.8K)"                  |
| F4  | Partial profit-take  | User taps "Close 50%"     | Position 1.2 BTC, TP 31K      | Market order placed for 0.6 BTC; position becomes 0.6 BTC remaining                      |
| F5  | TP hit               | Price reaches 31,000      | System monitors               | Order auto-closes; "TP reached. +$2,580 profit" confirmation; position closed            |
| F6  | SL hit               | Price drops to 26,500     | System monitors               | Order auto-closes; "SL hit. -$1,800 loss" message; position closed; offer "review trade" |
| F7  | Funding spike alert  | Funding jumps to 0.10%    | Copilot monitors              | Orange alert: "Funding high. Liquidation risk. Consider tightening SL 30%?"              |
| F8  | Session health alert | User has 3 wins in a row  | Copilot psychological monitor | Alert: "3 wins! Overconfidence risk. Consider smaller size next trade."                  |

---

## Stage G: REFLECT — Trade journal, outcome attribution, learning

**Goal**: Capture what happened, why, and extract lessons.

**Information Architecture**

- Primary screens: Journal → Trade Detail

**Data & Features in Journal**

1. **Auto-Populated Trade Entry**
   - Belief Snapshot linked: "Long, 75% confidence, invalidate below 27K"
   - TradePlan linked: "Entry 28K, TP 31K, SL 26.5K, size 1.2 BTC, reason: 15-trader cluster, +regime"
   - Execution: "Filled 1.2 BTC @ 27,998, limit order, 5 min wait"
   - Outcome: "Closed at TP 31,000. +$2,580 profit. Held 4h 23m."
   - Journal timestamp: Date, time, duration open, final P&L

2. **Trade Performance Attribution** — Decompose profit into sources
   - Direction: "Were you right on direction?" → "Yes, long was right"
   - Timing: "Did you enter at optimal time?" → "Entered bottom 20% of move. Excellent timing."
   - Execution: "Did execution leak edge?" → "Slippage 0.07%, fees 2.5 bps. Cost: $134 (1.3% of profit). Acceptable."
   - Luck vs. Skill: "How much was edge vs. luck?" → "Regime favorable (+40 to trend), cluster had 75% agreement, you captured 80% of move. ~80% skill, 20% luck."

3. **Win Rate by Setup** — Aggregate learning
   - "Trades on cluster consensus 1-2K: 62% win rate (vs. 58% overall)"
   - "Trades in Trending regime: 71% win rate (vs. 58% in Ranging)"
   - "Trades with >70% confidence belief: 67% win rate"
   - Actionable: "Favor cluster consensus + Trending regime + high confidence beliefs"

4. **Manual Annotation** — User-added notes
   - "What happened?" text box (pre-fill prompt: "Did your thesis hold? Why/why not?")
   - Tags: [#luck], [#skill], [#bad-exit], [#good-entry], [#emotional], [#mechanical]
   - Links to similar past trades: "Similar trade 30 days ago: also long cluster 1-2K, +4.3% profit. Repeatable pattern?"

5. **Journal Filter + Analytics**
   - Filter by symbol, date range, win/loss, setup type
   - Charts: Win rate by setup, P&L distribution, holding time vs. outcome, confidence vs. outcome
   - Trend: "30-trade rolling win rate: 58% (up from 52% 60 days ago). Improving."

**P0 Features Required**

1. **Auto-Populated Trade Entry** (linked to Belief, Plan, Execution, Outcome)
2. **Trade Performance Attribution** (direction/timing/execution/luck breakdown)

**P1 Features Required**

1. **Win Rate by Setup** (aggregate by cluster, regime, confidence, symbol)
2. **Manual Annotation** (notes, tags, similar trades)
3. **Journal Filter + Analytics** (trends, patterns, learning)

**Key Interaction Patterns**

1. Position closed (Stage F: TP/SL hit)
2. Auto-modal or notification: "Trade closed. Review journal entry?"
3. User taps "Review" → Journal Detail page
4. Journal pre-populated with Belief, Plan, Execution, Outcome
5. System shows attribution: "80% skill, 20% luck"
6. User taps "Add notes" → inputs annotation ("Thesis held, timing excellent, execution clean")
7. User tags trade: [#skill] [#good-entry]
8. Journal auto-saves
9. User views Win Rate by Setup → "Cluster consensus trades: 62% WR"
10. User reflects: "I'm better at consensus clusters and trending regime. Focus there."

**State Machine**

```
[Position Closed (TP/SL/Manual)]
    ↓ (Trade outcome captured)
[Modal: "Review journal entry?"]
    ↓ (User taps "Review")
[Journal Detail Loaded, Auto-Populated]
    ↓ (User reviews attribution: direction/timing/execution/luck)
[User Annotates and Tags]
    ↓
[Journal Entry Saved]
    ↓ (User optionally views Win Rate by Setup)
[Learning Dashboard Shown]
    ↓ (User reads: "Cluster + Trending regime = 71% WR. Focus there.")
[End of Journey; User Returns to Stage A for next trade]
```

**Edge Cases**

- User closed position manually (not TP/SL) → Outcome reason required: "Why close?" options (Conviction lost, Risk too high, Partial profit, Technical issue, etc.)
- Trade was breakeven → Attribution: "Direction right, timing OK, execution cost all profit. Net: 0." Lesson: "Tighten execution or take earlier TP."
- User didn't capture Belief Snapshot → Journal pre-filled with Plan only; prompt: "What was your belief going in? (Helps learning)"
- Belief invalidated (price broke invalidation trigger) → Journal auto-flags: "Your invalidation trigger hit. Correct exit?" Lesson: "Good risk management."
- Trade marked as "Luck only" → Copilot nudge: "If pure luck, next trade may not work. Identify the edge for repeatable skill."

**Acceptance Criteria**

| #   | Scenario               | Given                                               | When                         | Then                                                                                                   |
| --- | ---------------------- | --------------------------------------------------- | ---------------------------- | ------------------------------------------------------------------------------------------------------ |
| G1  | Auto-populate journal  | Position closed, all stages complete                | Journal Detail opens         | All fields pre-filled: Belief, Plan, Execution, Outcome <500ms                                         |
| G2  | Attribution calculated | Journal loaded, outcome known                       | System calculates            | Attribution breakdown shown: Direction %, Timing %, Execution %, Luck %; confidence score 0-100        |
| G3  | Win rate by setup      | 30+ trades complete                                 | User views Journal Analytics | Breakdown by: cluster consensus, regime, confidence, symbol; each with % WR                            |
| G4  | Manual annotation      | Journal detail open                                 | User taps "Add notes"        | Text input appears; user types; tags selectable ([#skill], [#luck], etc.)                              |
| G5  | Trade linkage          | Similar past trade exists                           | Journal searches             | "Similar trade 30d ago: also cluster 1-2K, +4.3%. Repeatable pattern?" link shown                      |
| G6  | Belief invalidation    | Invalidation trigger: below 27K; final price: 26.8K | System flags                 | Auto-highlight in journal: "Invalidation hit 26.8K. You exited correctly at SL 26.5K. Good risk mgmt." |
| G7  | No belief captured     | Trade completed, no BeliefSnapshot saved            | Journal prompts              | "What was your belief? (Helps learning)" pre-fill in annotation field                                  |

---

## 6.8 COPY MARKETPLACE FEATURE SPECIFICATIONS (Per 2-3-6 V3.0 Gap Analysis)

> Added 2026-03-09. These specs detail the copy marketplace features introduced in Cycle 1 per the 3-5 Amendment and enriched by the Bitget V3.0 competitive benchmark analysis.

### 6.8.1 Copy Mode Architecture (2×3 Matrix)

Two allocation modes × three timing modes create a 2×3 matrix of copy configurations:

|                       | **Full Mirror** (real-time)                                                                                                                                           | **Delayed/Alert** (user confirms)                                                   | **Tracking Only** (observe)                                                         |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| **Proportional Copy** | Leader's exact portfolio proportions mirrored in real-time. Separate fund pool per leader. Best fidelity — leader's capital allocation IS the signal. Max 10 leaders. | Leader trades trigger alert; follower reviews and confirms proportional allocation. | Follower sees leader's portfolio proportions and performance. No capital committed. |
| **Fixed-Amount Copy** | Fixed $ or multiplier per trade from a shared fund pool. Simpler for S7 beginners. Supports following more leaders (up to 20+).                                       | Leader trades trigger alert; follower reviews and confirms fixed-amount execution.  | Follower sees leader's trades and outcomes. No capital committed.                   |

**Default for S7 new users:** Fixed-Amount Copy × Full Mirror (simplest active configuration).
**Recommended for experienced users:** Proportional Copy × Full Mirror (highest fidelity).

### 6.8.2 Leader Tier System

| Tier                 | Requirements                                                     | Follower Cap | Profit Share Rate                                       | Evaluation                                                  |
| -------------------- | ---------------------------------------------------------------- | ------------ | ------------------------------------------------------- | ----------------------------------------------------------- |
| **Verified** (entry) | 100+ verified trades, >45% win rate, min 30-day on-chain history | 100          | 10% of follower profit                                  | Weekly on 3 criteria: trade count, win rate, history length |
| **Proven** (mid)     | 300+ trades, Sharpe >1.0, <20% max drawdown, 90-day history      | 300          | 15% of follower profit                                  | Weekly on 5 criteria: +Sharpe, +drawdown                    |
| **Elite** (top)      | 500+ trades, Sharpe >1.5, <15% max drawdown, 180-day history     | 500          | 20% of follower profit (eligible for Steady Hand Bonus) | Weekly on 5 criteria + copier profit review                 |

**Tier display:** Badge on leader card + follower capacity indicator ("87/100 followers" — creates scarcity/FOMO).
**Demotion:** If a leader fails criteria for 2 consecutive weeks, they drop one tier. Existing followers are notified but NOT auto-removed.

### 6.8.3 Trading Style Tags (Algorithmic Classification)

Leaders are classified into behavioral tags via algorithmic analysis of their last 90 days of trading:

| Tag              | Classification Logic                             | Example                        |
| ---------------- | ------------------------------------------------ | ------------------------------ |
| **Conservative** | Avg leverage <5x, max drawdown <15%, Sharpe >1.0 | Low-risk, steady returns       |
| **Aggressive**   | Avg leverage >10x, max drawdown >25%             | High-risk, high-reward         |
| **Short-term**   | Avg hold time <4 hours                           | Scalper/day-trader             |
| **Long-term**    | Avg hold time >24 hours                          | Swing/position trader          |
| **BTC-focused**  | >60% of trades in BTC/ETH                        | Core crypto pairs              |
| **Multi-coin**   | <40% in any single asset                         | Diversified across instruments |
| **Rising star**  | Account age <60 days, Sharpe >1.5, 100+ trades   | High-performing newcomer       |
| **Newcomer**     | Account age <30 days, <100 trades                | New to platform                |

**Tags are NOT mutually exclusive:** A leader can be tagged "Conservative + Long-term + BTC-focused."
**Leaderboard filters:** Users can filter by any combination of tags. Toggle filters: "Hide full" (capacity reached), "Verified only", "Local" (same fiat currency).

### 6.8.4 Portfolio Circuit Breaker (Account Equity Floor)

Complements per-leader Follower Risk Rails with a portfolio-level protection:

- **Trigger:** If total account equity drops below user-defined threshold (default: 70% of initial deposit)
- **Action:** ALL copy trading stops immediately. All open copied positions are closed at market.
- **Notification:** Push + email: "Your Portfolio Circuit Breaker activated. Total account value dropped below your $2,625 floor. All copy trading has been paused. Your positions have been closed."
- **Resume:** Manual re-activation only. User must review which leaders caused the drawdown and explicitly restart.

**Why both per-leader and portfolio-level protection matter:** A follower with 5 leaders could have each leader lose 8% (below the per-leader 10% kill switch), but total portfolio loss = 40%. The portfolio circuit breaker catches this correlated-loss scenario.

### 6.8.5 Copier Profit Display

| Location                | Display                                                           | Detail                                                  |
| ----------------------- | ----------------------------------------------------------------- | ------------------------------------------------------- |
| **Leaderboard sort**    | "Sort by: Copier Profit" (secondary sort after Sharpe default)    | Total realized + unrealized profit across all followers |
| **Leader profile card** | "Followers earned: +$47,230"                                      | Aggregate copier profit, updated daily                  |
| **Leader detail page**  | Copier profit chart (30d/90d/all-time), per-follower distribution | Histogram showing how many followers are profitable     |
| **Follow confirmation** | "This leader's followers have earned $47,230 total"               | Pre-commitment social proof                             |

---

# SECTION 7: INFORMATION ARCHITECTURE — SCREEN MAP

## 7.1 Complete Screen Catalog

| Screen                        | Purpose                                                                                                         | Primary Persona | Key Data Displayed                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Primary Actions                                              | Navigation From                             | Navigation To                 |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------- | ----------------------------- |
| **Dashboard**                 | Daily overview + quick start                                                                                    | All             | Portfolio summary, active plans, Copilot picks, trending signals, regime bar, news alerts                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | View plan, execute, signal explore                           | Login/Home, App start                       | Plan, Trade, Portfolio        |
| **Explore / Discovery**       | Find opportunities                                                                                              | P1, P2, P4      | Assets by signal score, trending by cohort, sector heat maps, 24h change                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Tap asset → Trade Screen                                     | Dashboard, Watchlist                        | Trade Screen, Leaderboard     |
| **Leaderboard / Traders Tab** | Find "teachers" + copy leaders. **This IS the Radar Traders tab** (ARX_2-2-2 §5.3, Q4: "Who should I follow?"). | P1, P2, S7      | Ranked traders by performance (30d, 90d, 1y), **dual sort: Sharpe (quality) + Copier Profit (social proof)**, compatibility match, **trading style tags** (Conservative/Aggressive, Short-term/Long-term, BTC-focused/Multi-coin, Rising star, Newcomer), **tier badges** (Verified/Proven/Elite), **follower capacity** (X/Y followers), **configurable cohort filters** (6 dimensions: Size, Performance, Style, Risk, Regime Adaptation, Asset Focus — per ARX_2-2-2 §2), **natural language search** ("Find conservative BTC traders"), **preset cohorts** (Smart Money, Proven Swing Traders, etc.), **3-question onboarding wizard** for S7 cold start | Follow, copy, subscribe, **filter by dimension/tag**, search | Dashboard, Radar Feed tab, Radar Market tab | Trader Detail                 |
| **Trader Detail**             | Evaluate a specific trader                                                                                      | P1, P2, S7      | Wallet address, on-chain badges, win rate, holding time, avg leverage, recent trades, risk signature, Sharpe ratio, **copier profit** (aggregate profit of all followers), **tier badge** (Verified/Proven/Elite), **follower capacity** (e.g., "87/100 followers"), **trading style tags**                                                                                                                                                                                                                                                                                                                                                                  | Follow, subscribe alerts, copy setup                         | Leaderboard, search                         | Signature Card, Trade Screen  |
| **Trade Screen**              | Core trading surface (Stages A-E)                                                                               | P1, P3, P4      | Chart (TradingView), Intelligence Drawer (Evidence/Clusters/Copilot/Social), Action Panel (Thesis/Plan/Validation/Order)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Full A→E journey                                             | Explore, Watchlist, Dashboard               | Portfolio, Journal            |
| **Portfolio**                 | Position management                                                                                             | All             | Position list, P&L, risk exposure, correlation matrix, active alerts                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | Adjust TP/SL, close, add, monitor                            | Dashboard, Trade Screen, Alerts             | Position Detail, Dashboard    |
| **Position Detail**           | Single position management                                                                                      | All             | Entry, current, TP/SL, P&L, time open, health status, Copilot alerts, P&L curve                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | Tighten SL, take profit, close, adjust                       | Portfolio                                   | Portfolio, Journal            |
| **Journal**                   | Post-trade learning                                                                                             | P1, P3          | Trade history list (date, symbol, P&L, belief, outcome)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | View detail, filter, annotate                                | Portfolio, Dashboard                        | Trade Detail, Analytics       |
| **Trade Detail**              | Single trade analysis                                                                                           | P1, P3          | Belief Snapshot, TradePlan, Execution, Outcome, Attribution (direction/timing/execution/luck), user annotations, similar past trades                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | Annotate, tag, view similar                                  | Journal                                     | Journal, Trade Screen         |
| **Watchlist**                 | Symbols + traders                                                                                               | P1, P4          | Symbols tab (price, signal score, following status), People tab (followed traders, alerts)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | Quick access to Trade Screen, unfollow                       | Dashboard, top nav                          | Trade Screen, Leaderboard     |
| **Alerts**                    | Notification center                                                                                             | All             | Alert rules (active/inactive), triggered alerts (with action buttons), Copilot urgent alerts                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Configure, act on, dismiss                                   | Top nav, Dashboard                          | Trade Screen, Position Detail |
| **Settings**                  | Configuration                                                                                                   | All             | Account (wallet, email), experience tier, notification prefs, API keys (P5), payment method                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | Edit, save, export                                           | Hamburger menu                              | Dashboard                     |
| **Signature Card**            | Quick snapshot of trader                                                                                        | P1, P2          | Wallet, badges, WR, holding time, recent trades, Sharpe, follow button                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | Follow, subscribe                                            | Leaderboard, search results                 | Trader Detail, Trade Screen   |
| **Conviction Card**           | Copilot suggestion                                                                                              | P1              | Entry, TP, SL, size, rationale, confidence, counter-evidence                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Tap to Build Plan                                            | Trade Screen (Intelligence Drawer)          | Plan Builder                  |
| **Belief Snapshot Modal**     | Capture conviction pre-trade                                                                                    | P1, P3          | Direction (long/short/neutral), confidence (0-100), invalidation trigger                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Save                                                         | Trade Screen (Action Panel)                 | Plan Builder                  |
| **Plan Builder**              | Develop trade plan                                                                                              | P1, P3          | Chart overlay (draggable lines), form fields (entry, TP, SL, size, leverage), guardrails feedback, Plan Preview                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | Save, Preview                                                | Stage B/C transition                        | Plan Preview, Validation      |
| **Plan Preview**              | Review trade before submit                                                                                      | P1, P3          | Chart with entry/TP/SL marked, RR ratio, confidence, copilot agreement, risk $, reward $                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Edit, Validate, Execute                                      | Plan Builder                                | Validation, Trade Screen      |
| **Validation Checker**        | Pre-execute safety check                                                                                        | P1, P3          | Regime, funding, OI, liquidation risk, evidence freshness, account exposure                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | Refresh, Proceed, Adjust Plan                                | Plan Preview                                | Order Execution, Plan Builder |
| **Order Execution**           | Place order                                                                                                     | P1, P3          | Pre-filled ticket (side, size, price, TP, SL, leverage), execution strategy selector (Free vs. Gold), slippage meter                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | Place Order, Cancel                                          | Validation                                  | Order Confirmation            |
| **Order Confirmation**        | Post-submit status                                                                                              | All             | Order ID, status (pending/filled/partial/rejected), fill price, actual slippage, linked belief + plan                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | Monitor, Back to Explore                                     | Order Execution                             | Position Detail               |
| **Search / Symbol Lookup**    | Find symbol or trader                                                                                           | All             | Search box, autocomplete (symbols + trader names), recent searches                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Tap result                                                   | Top nav                                     | Trade Screen, Trader Detail   |
| **Onboarding Flow**           | First-time setup                                                                                                | New users       | Wallet connect (Privy), experience tier selection (Guided/Standard/Pro), tutorial carousel, tutorial actions                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Complete                                                     | App launch                                  | Dashboard                     |

---

> **§7.1.1 Beginner Mode — REMOVED (DEC-034 Rejected 2026-03-20).** Progressive disclosure via Beginner Mode was evaluated but rejected. Novice users will instead be served through: (1) 30-Day New User Protection (drawdown caps, leverage limits — see Arx_3-9 §12), (2) Paper Trading Mode (zero-risk entry — see Arx_3-9 §Phase 0), (3) Copy trading as default front-door (S7 matching wizard in onboarding), (4) Fiat-denominated display removing crypto jargon from P&L screens. These mechanisms reduce complexity without maintaining two separate UI modes.

---

## 7.1.2 Copier Median Return as Primary Leader Ranking (DEC-036)

> Added: 2026-03-20 | Source: YieldFund 90-day study (100K+ copier outcomes), IOSCO 2025 framework

**Problem:** 97% of leaders show positive own PnL, but only 43.61% produce positive follower PnL. Ranking by leader returns misleads followers — the leader-follower performance gap is the existential risk for copy trading platforms.

**Solution:** Copier Median Return is the PRIMARY ranking signal across all leader-facing surfaces:

| Surface               | Primary Metric                   | Secondary Metrics                   |
| --------------------- | -------------------------------- | ----------------------------------- |
| Leader Discovery (D1) | Copier Median Return (30d/90d)   | Win rate, copier count, style tag   |
| AI Leader Matching    | Copier Median Return weighted 2x | Sharpe, drawdown, holding time      |
| Leaderboard           | Sorted by Copier Median Return   | Leader own PnL shown but not ranked |
| Leader Profile (D2)   | Copier Median Return prominent   | Full stats available on drill-down  |

**Anti-gaming detection (P1):** Style drift alerts, martingale pattern detection, leverage spike flags, correlated position warnings. Leaders with max drawdown >20% in trailing 3 weeks are penalized in rankings (Bitget model).

**Given/When/Then:**

- Given a user views the leader discovery screen, When results load, Then leaders are sorted by Copier Median Return (90d) descending by default
- Given a leader's copier median return is negative for 30+ days, When the system evaluates leader quality, Then the leader is demoted in rankings and new copier onboarding is paused

---

## 7.1.3 First-Loss Recovery UX (DEC-037)

> Added: 2026-03-20 | Source: Betterment loss-framing, Duolingo Earn Back mechanic, fintech churn research

**Problem:** 71% of finance app users churn within 90 days. Loss aversion makes losses feel 2x as painful as gains (Kahneman & Tversky). The first loss in copy trading is the single most dangerous churn moment — and no existing platform has a structured recovery flow.

**Solution:** When a copier experiences their first significant loss (>5% on any copy position), trigger the First-Loss Recovery flow:

**Step 1 — Contextualize (immediate notification):**

- "This leader has recovered from similar drawdowns 8 out of 10 times"
- Show loss relative to: leader's historical max drawdown, current market conditions, portfolio-level impact
- Display what Arx prevented: "Your stop-loss saved you $X" / "30-Day Protection limited your loss to Y%"

**Step 2 — Social proof (within 1 hour):**

- "85% of copiers are staying with this leader through this drawdown"
- Show aggregate copier behavior (stayed/paused/exited percentages)

**Step 3 — Recovery path (within 24 hours):**

- Offer recovery challenge: review trade analysis, adjust risk settings, set tighter limits
- Show recovery probability: "Based on this leader's history, positions recover within X days Y% of the time"
- One-tap "Pause copying" (not "Stop") — framing preserves relationship

**Step 4 — Follow-up (D3, D7, D14):**

- If leader recovers: "Your patience paid off — this position is now +X%"
- If loss continues: suggest leader diversification, not platform exit

**What NOT to do (anti-patterns):**

- Don't hide the loss (breeds distrust)
- Don't use confetti or gamification on losses (Robinhood $7.5M fine)
- Don't manufacture urgency ("Act now or lose more!")

**Given/When/Then:**

- Given a copier's first copy position drops >5%, When the loss is detected, Then trigger the First-Loss Recovery notification sequence
- Given a copier receives a Step 2 social proof notification, When 85%+ of copiers are staying, Then show the "staying" stat prominently
- Given a copier pauses copying, When the leader's position recovers, Then send a recovery notification within 1 hour

---

## 7.1.4 Fiat-Denominated Display (DEC-038)

> Added: 2026-03-20 | Source: Revolut, Cash App, Robinhood fiat-first UX, APAC market requirements

**Problem:** Displaying everything in USDC forces users to do mental currency conversion. Vietnamese users see "$1,234.56 USDC" and must calculate VND equivalent. Every mass-market crypto app (Revolut, Cash App, Robinhood, PayPal) shows fiat first.

**Solution:** Default all monetary values to user's local fiat currency. USDC amounts shown as secondary detail.

**Display hierarchy:**

1. **Primary:** Fiat equivalent (VND, PHP, USD, KRW, IDR) — all P&L, portfolio values, position sizes
2. **Secondary:** USDC amount on tap/expand or in detail views
3. **Settings:** Currency selector in Profile > Settings (auto-detected from locale, user-changeable)

**Locale-aware formatting:**

| Currency | Format Example | Notes                                |
| -------- | -------------- | ------------------------------------ |
| USD      | $1,234.56      | Standard 2-decimal                   |
| VND      | ₫31,234,567    | No decimals, use thousand separators |
| PHP      | ₱69,876.54     | Standard 2-decimal                   |
| KRW      | ₩1,654,321     | No decimals                          |
| IDR      | Rp19,876,543   | No decimals, abbreviate >1B          |

**Edge case:** A user could be "up" in USDC but "down" in local fiat if USD weakens vs their currency. Show combined fiat-equivalent P&L with an info tooltip: "Includes FX movement: USDC +$50, FX -$12, Net +₫950,000"

**Technical:**

- Store all P&L in USDC (settlement currency)
- Apply FX conversion at display layer only
- Cache FX rates with 1-5 minute refresh
- Show "as of" timestamp for FX rate transparency

**Given/When/Then:**

- Given a user in Vietnam opens the app, When the portfolio screen loads, Then all values are displayed in VND by default
- Given a user taps on a VND-denominated value, When the detail view opens, Then the USDC equivalent is shown alongside

---

## 7.1.5 Fiat Off-Ramp via MoonPay/Transak (DEC-039)

> Added: 2026-03-20 | Source: MoonPay/Transak Arbitrum USDC support, IG Markets withdrawal benchmark

**Problem:** "Can I get my money out?" is the #1 complaint across all crypto platforms (Trustpilot). Without off-ramp, users must navigate external exchanges — destroying the "no crypto knowledge needed" promise. IG Markets (CFD benchmark) offers same-day withdrawal.

**Solution:** Two-step embedded off-ramp flow:

1. **Step 1 — Withdraw HL → Arbitrum:** User initiates withdrawal from Hyperliquid to their Arbitrum wallet (3-4 minutes, 1 USDC fee, handled by HL validators)
2. **Step 2 — Sell USDC → Fiat:** MoonPay or Transak sell-to-card widget converts Arbitrum USDC to fiat

**Provider comparison:**

| Provider             | Fee    | Speed                     | Coverage      |
| -------------------- | ------ | ------------------------- | ------------- |
| MoonPay Sell-to-Card | 1-4.5% | Near-instant to Visa card | 80+ countries |
| Transak Sell-to-Card | 1%     | Real-time via Visa Direct | 60+ countries |

**Total estimated time:** 10-30 minutes from HL to fiat on card. To bank account: 1-3 business days.

**Trust differentiator:** Hyperliquid is non-custodial — funds are NEVER frozen. Message: "Your funds are always yours. Withdraw anytime — your keys, your crypto." This directly addresses the #1 complaint (frozen funds) that plagues centralized exchanges.

**Integration point:** Arx_4-1-1-1 Funding screens (B5 Withdrawal flow) — add "Sell to Card" option alongside existing "Withdraw Crypto" flow.

**Given/When/Then:**

- Given a user taps "Withdraw" on the Funding screen, When the withdrawal options load, Then "Sell to Card (MoonPay/Transak)" appears as the first option above "Withdraw Crypto"
- Given a user completes a sell-to-card transaction, When the fiat reaches their card, Then a confirmation notification is sent with amount received and exchange rate used

---

## 7.2 Trade Screen — Three-Zone Architecture

The Trade Screen is the core surface where 95% of value lives (Stages A-E). Arx optimizes this screen obsessively.

### Zone 1: Chart

- **Component**: TradingView Lightweight Charts (embedded)
- **Data**: Candlesticks (4h candles by default; 1m-1d selectable), volume, volume profile
- **Overlays**:
  - Entry/Exit/Liquidation heatmaps (density histogram below price)
  - Regime bar (below volume; color-coded: green=trending, yellow=range, red=compression, gray=transition)
  - Funding rate curve (overlay or separate sub-panel)
  - Entry/TP/SL lines (from Plan Builder; draggable on mobile long-press, desktop drag)
  - Followed trader positions (dots at cluster zones with legend)
- **Dimensions (Mobile)**: Full width, 60% height
- **Dimensions (Desktop)**: 65% width, 100% height

### Zone 2: Intelligence Drawer

- **Position**: Bottom sheet (mobile), right panel (desktop)
- **Tabs**: Evidence | Clusters | Copilot | Social

  **Evidence Tab**:
  - Heatmap legend (15 traders clustered 28-30K, color intensity = signal strength)
  - Cohort Comparison Overlay (your traders' positions vs. index)
  - Market Narrative (AI-generated, 2-3 sentences, includes funding/OI/whale clusters/contrarian signals)
  - Confidence bar (0-100, color-coded)

  **Clusters Tab**:
  - Drill-down list of clusters (top 5 by confluence score)
  - Each cluster: price range, trader count, avg leverage, avg hold, confluence score, recent activity
  - Tap cluster → expand to show trader list with follow buttons

  **Copilot Tab**:
  - Conviction Card with AI suggestion (entry, TP, SL, size, reasoning, confidence)
  - Previous suggestions (history of Copilot recommendations for this symbol)
  - User feedback buttons: "Helpful" / "Too aggressive" / "Too conservative"

  **Social Tab**:
  - Sentiment summary ("85% bullish, 15% bearish")
  - Top tweets about symbol (via API or manual curation)
  - Community emoji reactions (moon, fire, etc.)
  - Popular hashtags

- **Dimensions (Mobile)**: Full width, 35% height (draggable resize)
- **Dimensions (Desktop)**: 30% width, 100% height

### Zone 3: Action Panel

- **Position**: Right side (desktop expandable), bottom expandable (mobile)
- **Sub-Views** (tabs/collapsible):

  **Thesis Capture** (Stage B):
  - Direction: (Long / Short / Neutral) radio buttons
  - Confidence: 0-100 slider with labels ("Low", "Medium", "High", "Conviction")
  - Invalidation trigger: Text input "if price breaks below 27K"
  - Save button

  **Plan Builder** (Stage C):
  - Chart overlay mode: Toggle "Drag on chart to adjust"
  - Form mode: Entry [ ], TP [ ], SL [ ], Size $ [ ], Leverage [ ]
  - Guardrails feedback: "Risk 4.3% of account. OK." (green) or "Risk 8%. Consider smaller size." (red)
  - Translator suggestion button: "Use Copilot suggestion"
  - Save & Continue / Save & Monitor buttons

  **Validation** (Stage D):
  - Regime check: Icon + label ("Trending +", "Range ~", "Compression !")
  - Funding: "0.04%/8h - normal"
  - OI: "Up 5% (4h) - OK"
  - Evidence freshness: "5 min old - fresh"
  - Account exposure: "Would be 2.1x - OK"
  - All-green or warning list
  - Refresh button; Proceed / Adjust Plan buttons

  **Order Execution** (Stage E):
  - Pre-filled ticket (all fields visible, editable)
  - Strategy selector (Free vs. Gold dropdown)
  - Slippage meter
  - "PLACE ORDER" button (large, green, disabled if fields invalid)
  - Execution history (last 5 orders, quick re-execute)

- **Dimensions (Mobile)**: Full width, collapsible; expanded ~40% height
- **Dimensions (Desktop)**: 20% width, 100% height; always visible

---

# SECTION 8: AI FEATURES & COPILOT

## 8.1 GenAI Integration: Three-Stage Progression

Arx's intelligence evolves in three layers over 12 months:

### Stage 1: GenAI + Statistics (M1-M3)

| Feature                       | What GenAI Does                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | What Statistics Do                                                                            | User Sees                                                                                                                                                                               | Accuracy Target                                 |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- | ---------------- | -------------- | ---------- | --------------------------------------------- |
| **Regime Bar**                | Nothing (rules-based)                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ADX (trending?), Bollinger Bands (range?), volatility percentile                              | Color-coded bar: Trending (green), Range (yellow), Compression (orange), Transition (gray)                                                                                              | 65% agreement with manual regime classification |
| **ATR Sizing**                | Nothing                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | ATR × user risk %, Kelly fraction calculation                                                 | "At this SL, risking 2.1%: Size $50K, 2.1x leverage"                                                                                                                                    | Within 5% of manual Kelly calc                  |
| **Market Narrative**          | Synthesize funding, OI, sentiment, whale clusters into 1-2 sentence story                                                                                                                                                                                                                                                                                                                                                                                                             | Provide z-scores (funding vs. 30d avg, OI vs. 30d avg, whale concentration %)                 | "Longs paying 0.04%/8h (historically precedes pullback 67% of time). OI up 12% in 4h. 5 whale clusters long 28-30K. Counter: spot volume down, retail selling on CEX. Confidence: 62%." | 70% user agreement on narrative utility         |
| **Wallet Stats**              | Summarize wallet patterns (this trader is momentum-follower, counter-trend, etc.)                                                                                                                                                                                                                                                                                                                                                                                                     | Win rate (last 30), Kelly fraction, avg hold, avg leverage, Sharpe, max DD                    | "Trader X: 62% win, avg hold 18h, style: swing, 8x leverage. Peak DD: 22%. Sharpe: 0.8."                                                                                                | Classification accuracy >75%                    |
| **Copilot Trade Structuring** | Synthesize evidence (cluster location, confluence, regime, wallet style) into trade plan suggestion. **Two flows** (see ARX_2-2-2 §5A/§5B): **Copy Trade** (S7: leader IS strategy, user controls only allocation/max-loss/auto-toggle) and **Trade Myself** (S2: signals as reference, user sets every parameter with multi-source reference points per parameter). **4-layer rationale** on every suggestion (ARX_2-2-2 §5C): headline, signal breakdown, leader context, warnings. | Compute entry/TP/SL from cluster distribution (median, 25th %, 75th %ile), Kelly-based sizing | Conviction Card: "Long 28K → 31K (+10.7%)                                                                                                                                               | SL 26.5K (-5.4%)                                | Size $50K (2.1x) | Confluence 81% | Regime +." | >60% user finds suggestion useful; >40% adopt |

### Stage 2: + Quant Frameworks (M3-M6)

| Feature                        | What It Adds                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Benefit                                                                                                                                                                  |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Kelly Sizing per Regime**    | Per-wallet, per-regime optimal position sizing based on historical edge in that regime                                                                                                                                                                                                                                                                                                                                                                                                       | "In trending regime, this trader has 65% win rate; suggests 2.3x Kelly (1.15% per trade). In range, 48% WR; suggests 0.2x Kelly (avoid)."                                |
| **Regime Intelligence Scores** | Score each wallet by regime awareness (do they trade in right conditions?)                                                                                                                                                                                                                                                                                                                                                                                                                   | "Trader X aware of regime (trades 80% in favorable regime). Trader Y unaware (trades 40% in favorable regime). Prefer X."                                                |
| **Wallet Classification**      | Three complementary systems: (1) **Behavioral types** (6 labels for analytics: Regime-Aware, Pattern Scalper, Momentum Follower, Counter-Trend, Liquidity Provider, Noise), (2) **Gating types** (6 safety categories per ARX_1-2 §3.2: Type 1 All-Weather through Type 6 Non-Copyable, enforced via Three-Gate Follow Framework), (3) **Configurable cohort dimensions** (6 user-facing discovery filters per ARX_2-2-2 §2: Size, Performance, Style, Risk, Regime Adaptation, Asset Focus) | "This trader is Momentum Follower (behavioral). Type 1 All-Weather (gating: safe to follow). Matches your 'Proven Swing Traders' cohort (discovery). Expect 2-8h holds." |
| **Confluence Scoring**         | Weighted signal agreement across P1-P5 signal layers (price action, whale clusters, funding, OI, sentiment)                                                                                                                                                                                                                                                                                                                                                                                  | "Entry suggested by 4/5 signal layers. Confidence 84%. (Counter: sentiment weak, only 3/5.)"                                                                             |

### Stage 3: + ML Models (M6+)

| Feature                            | What It Adds                                                                                                                                                                   |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Probabilistic Regime Detection** | ML ensemble (XGBoost + LSTM) replaces rules-based regime bar; outputs probability distribution (Trending: 72%, Ranging: 20%, Transitioning: 8%)                                |
| **Factor Ensembles**               | Multi-factor scoring that outperforms individual signals; learns which signal combinations predict profitable trades for user's own style                                      |
| **Personalized Intelligence**      | Per-user signal ranking based on user's trading history; if user 68% WR on cluster-consensus trades but 45% on momentum, system deprioritizes momentum, boosts cluster signals |
| **Autonomous Monitoring Agent**    | Always-on background agent that surfaces emerging opportunities ("5 new whale clusters forming at 27K; regime favorable; triggers your alert rules") even when user not in app |

## 8.2 Copilot Behavior by Persona

Copilot adapts tone, proactivity, and detail to persona:

| Persona       | Copilot Mode             | Proactivity                            | Tone                            | Detail Level                     | Example Output                                                                                                                                                                                                                                                                  |
| ------------- | ------------------------ | -------------------------------------- | ------------------------------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **P1 Jake**   | Advisory → Collaborative | Medium (suggests when evidence strong) | Direct, professional, skeptical | Full reasoning chain             | "Long 28K entry (8/15 traders agree, Trending regime, Funding normal). TP 31K (cluster exits), SL 26.5K (liquidation zone). 2.1x max (Kelly 2.3x). Confidence: 81%. Counter: Spot volume down—retail weak. Consider 50% size."                                                  |
| **P2 Maya**   | Educational              | High (proactive cards, explanations)   | Encouraging, clear, patient     | Simplified + "learn more" links  | "This entry makes sense because smart money is clustering here. Entry: 28K (where 8 other traders are buying). Take profit: 31K (where they usually sell). Stop loss: 26.5K (below the danger zone). Size: $50K (safe for your account). Learn more: [Kelly sizing explained]"  |
| **P3 Marcus** | Research assistant       | Low (responds to queries)              | Technical, concise, precise     | Deep data, minimal narrative     | "Cluster 28-30K: 15 wallets, 62% win rate, median hold 14h. Factor ensemble confidence: 78%. Probability distribution: Trending 72%, Range 20%, Transition 8%. Suggestion: [Entry params] [TP params] [SL params] [Size formula]. Backtest link: [run backtest]"                |
| **P4 Sophia** | Cross-asset analyst      | Medium                                 | Analytical, business-focused    | Cross-correlation focused        | "BTC long cluster (28K) correlates +0.87 with ETH longs (1.8K). Consider pair trade or hedged exposure. Copy tier opportunity: 12 followers interested in this setup. Expected monthly revenue from copy fees: $420 (if trade wins). Setup profitability: 67% WR historically." |
| **P5 Chen**   | Automation assistant     | Low (responds to queries)              | Technical, code-forward         | Rule specification, API guidance | "Cluster setup: `entry >= 28.0 && entry <= 28.2 && confluence >= 0.75 && regime == 'trending'`. Auto-trade rule via API: `POST /trades/auto` with params. Backtesting: [link to backtest data]. Model training data: [historical signal library access]."                       |

## 8.3 AI Guardrails & Safety

Critical rules to prevent harm:

### Copilot NEVER Executes Trades Autonomously (Day 1-M6)

- **Advisory mode**: Suggests with reasoning; user decides
- **Collaborative mode**: Implements user intent (e.g., "I want 2x long, no more"); user reviews before submit
- **Delegated mode**: Executes within user guardrails (max 3x, max 5% account risk); user notified in real-time
- **Autonomous mode**: M6+, opt-in, heavily tested; still notifies user every trade; user can disable/revoke anytime

### Every Suggestion Includes

- Confidence score (0-100)
- Counter-evidence ("But: spot volume down, which contradicts")
- Regime context ("Works in Trending regime; risky in Compression")
- Historical performance (if applicable) ("Similar setups: 64% WR, 3.2% avg profit")

### Sizing Guardrails

- **Max leverage**: 3x (user can lower; cannot raise past 3x)
- **Max account risk per trade**: 5% (user can lower; cannot raise)
- **Kelly fraction capping**: Copilot suggests size ≤ 0.5x Kelly (conservative)
- **Account health check**: If current leverage >1.5x, Copilot won't suggest new positions >1x

### Regime Veto

- If regime is Compression and Copilot confidence <60%, system blocks execution (shows warning, forces manual override)
- If regime shifted in last 10 min, evidence "stale" badge shown; user must refresh

### "I Don't Know" Responses

- If confidence <30%, Copilot shows "Insufficient signal clarity. Recommend waiting or reducing size." No hallucinated certainty.

### Drift Detection

- If Copilot's suggested entry → actual fill slippage >0.5%, system flags: "Slippage higher than predicted. Market conditions changed? Review."
- If suggested win rate drops >5% points over 30-day period, retraining triggered + user notified

---

# SECTION 9: INTEGRATIONS

## 9.1 Integration Map

| Integration                        | Type              | Purpose                                                                  | Owner (Arx)  | Build vs. Buy     | Day 1                           |
| ---------------------------------- | ----------------- | ------------------------------------------------------------------------ | ------------ | ----------------- | ------------------------------- |
| **Hyperliquid API**                | Primary venue     | Execution, market data, builder codes, vault integration                 | SDK provider | Build (native)    | YES                             |
| **Privy**                          | Auth/wallet       | Self-custodial wallet, social login (Google/Twitter), session management | 3P service   | Buy               | YES                             |
| **TradingView Lightweight Charts** | Charting          | Interactive price charts, overlays, responsive                           | 3P service   | Buy (open source) | YES                             |
| **Nansen**                         | On-chain data     | Wallet labels, trader credibility scores, sybil risk                     | 3P API       | Buy               | YES                             |
| **Claude API / GPT-4**             | AI inference      | LLM for Copilot reasoning, market narrative, wallet classification       | 3P service   | Buy               | YES                             |
| **Fiat on-ramp (MoonPay/Transak)** | Funding           | Fiat → crypto conversion (USD → USDC)                                    | 3P service   | Buy               | Phase 2                         |
| **Push Notifications (FCM/APNs)**  | Mobile engagement | Alert delivery, Copilot nudges                                           | 3P + Build   | Buy + Build       | YES (basic alerts; advanced P1) |
| **Dune Analytics API**             | Custom queries    | Pre-built dashboards (whale clustering, cohort analysis)                 | 3P API       | Buy               | Phase 2                         |
| **DefiLlama**                      | Protocol data     | TVL, yield rates, protocol health (for HIP-3 planning)                   | 3P API       | Buy               | Phase 3                         |
| **CoinGecko / Messari**            | Market data       | Sentiment scores, news feeds, macroeconomic context                      | 3P API       | Buy (freemium)    | Phase 1                         |

## 9.2 Data Flow & API Contracts

### Hyperliquid Integration

**Real-Time Data**: Every 250ms (4x/sec)

- Price: Last 5 candles (1m, 4h, 1d) → TradingView charts
- Funding rate: Current, 8h avg, 30d avg
- Open Interest: Current, 24h change, % open interest
- Volume: 24h volume, hourly volume
- Active positions: All wallet positions (anonymized) → heatmaps

**Execution**: On-demand

- Endpoint: `POST /api/orders` with auth (private key via Privy)
- Params: symbol, side, price, size, order_type, leverage, time_in_force
- Response: order_id, status, fill_price, timestamp
- Confirmation webhook: Order state change (pending → filled → partial → cancelled)

**Builder Code**: Automatic

- Arx registered as builder; 2.5 bps per trade paid by Hyperliquid to Arx
- Monthly settlement to Arx wallet
- Tracking: Arx tracks free-tier user trades; calculates revenue weekly

### Privy Integration

**Wallet Authentication**

- User clicks "Connect Wallet" → Privy modal
- Options: MetaMask, Ledger, Phantom, Social (Google/Twitter)
- Privy returns session token (JWT)
- Arx stores JWT in secure localStorage (no private keys stored)

**Self-Custody Trade Authorization**

- User initiates trade → Arx signs order with Privy-managed wallet
- Privy handles key storage (hardware-backed if available)
- User approves transaction on Ledger/MetaMask popup (no risk of theft)

### TradingView Lightweight Charts

**Setup**

- Embed `lightweight-charts` npm package
- Render chart with candlestick series
- Subscribe to price updates from Hyperliquid → update candlesticks
- Add custom overlays (heatmaps, regime bar, entry/TP/SL lines)

**Data Format**

```json
{
  "time": 1620000000,
  "open": 28100,
  "high": 28500,
  "low": 28000,
  "close": 28300,
  "volume": 50000
}
```

### Nansen Integration

**Wallet Intelligence**

- Endpoint: `GET /api/wallets/{wallet_address}/stats`
- Response: Win rate, holding time, leverage, risk profile, recent trades, labels
- Cached (refresh every 6h or on-demand)

**Sybil Detection**

- Endpoint: `GET /api/wallets/{wallet_address}/risk_score`
- Response: Sybil risk (0-100), linked wallets, trust score
- Display: "Follow" button disabled if risk >70%; show "high sybil risk" warning

---

# SECTION 10: NON-FUNCTIONAL REQUIREMENTS (NFRs)

## 10.1 Performance SLAs

| Category                    | Requirement                                       | Target                                  | Measurement                 | Owner                |
| --------------------------- | ------------------------------------------------- | --------------------------------------- | --------------------------- | -------------------- |
| **App Cold Start**          | Time to interactive (mobile, 4G)                  | <3s                                     | Lighthouse, RUM             | Mobile               |
| **Chart Render**            | Time to first candlestick visible                 | <1.5s                                   | RUM, custom instrumentation | Frontend             |
| **Order Submission**        | Latency from "Place Order" click to confirmation  | <800ms                                  | RUM, Hyperliquid latency    | Backend + HLP        |
| **Signal Load**             | Time to display heatmaps + narrative              | <2s                                     | RUM                         | Backend              |
| **Copilot First Token**     | Time to first token in Conviction Card            | <3s                                     | Custom instrumentation      | Backend + Claude API |
| **Signal-to-Trade**         | Full flow (discovery to execution)                | <60s (target: <90s with Copilot assist) | User telemetry              | Product              |
| **Chart Update Frequency**  | Price update latency (realtime feed to display)   | <250ms (4 updates/sec)                  | RUM                         | Frontend             |
| **Journal Auto-Population** | Time from position close to journal entry visible | <500ms                                  | Backend                     | Backend              |

## 10.2 Reliability SLAs

| Category                                | Requirement                                    | Target                                                                         | Impact If Failed                                         |
| --------------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------ | -------------------------------------------------------- |
| **Order Submission / Execution Uptime** | Availability of order endpoint                 | 99.9%                                                                          | User can't trade; revenue loss; churn                    |
| **Order Delivery Reliability**          | % of submitted orders delivered to Hyperliquid | 99.95%                                                                         | Missing trades; lost edge                                |
| **Data Freshness** — Price              | Max stale age before refresh required          | <5s                                                                            | Outdated heatmaps; wrong entry prices                    |
| **Data Freshness** — Signals / Evidence | Max stale age before warning shown             | <60s                                                                           | Old heatmaps; stale clusters                             |
| **Copilot Service**                     | Availability of AI inference                   | 98% (single points of failure acceptable; fallback to statistical suggestions) | Copilot unavailable; show statistical suggestion instead |
| **Database Uptime**                     | User data persistence                          | 99.99%                                                                         | Data loss; regulatory impact; brand damage               |

## 10.3 Security

| Requirement                 | Implementation                                                                                                   |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| **Non-Custodial Wallet**    | Arx NEVER stores private keys. Privy manages keys in secure enclave (hardware if available).                     |
| **API Authentication**      | User signs in via Privy JWT. JWT required for all API calls. Refresh token rotated every 6h.                     |
| **Rate Limiting**           | Per-user, per-endpoint: 100 API calls/min (except chart data: 1000/min). Enforce via middleware.                 |
| **Input Validation**        | All user inputs (sizes, prices, etc.) validated server-side. Type checks, range checks (size >0, leverage <max). |
| **SSL/TLS**                 | All traffic HTTPS. TLS 1.3 minimum. Certificate pinning on mobile (prevent MITM).                                |
| **Secrets Management**      | API keys (Hyperliquid, Nansen, Claude) stored in HashiCorp Vault. Rotated every 90 days.                         |
| **SQL Injection**           | Use parameterized queries (ORM). No string concatenation in SQL.                                                 |
| **CSRF Protection**         | SameSite cookie attribute. POST endpoints require CSRF token.                                                    |
| **XSS Prevention**          | React context API prevents stored XSS. Content Security Policy headers.                                          |
| **Data Encryption at Rest** | User trading history encrypted with user-specific keys. User is only one who can decrypt.                        |
| **Audit Logging**           | Every trade logged (belief, plan, execution, outcome). Immutable ledger.                                         |

## 10.4 Accessibility (WCAG 2.1 AA)

| Requirement               | Implementation                                                                           |
| ------------------------- | ---------------------------------------------------------------------------------------- |
| **Color Contrast**        | All text ≥4.5:1 ratio. Heatmaps use colorblind-friendly palettes (avoid red-green only). |
| **Keyboard Navigation**   | All interactive elements focusable via Tab. Logical tab order. Enter/Space to activate.  |
| **Screen Reader Support** | Chart overlays have text alternatives. Buttons labeled. Form inputs labeled.             |
| **Text Sizing**           | Support 200% zoom without horizontal scroll. Font sizes ≥14px.                           |
| **Motion**                | No auto-playing animations. Respect `prefers-reduced-motion`.                            |
| **Alternative Text**      | Charts include alt descriptions ("Heatmap: 15 traders clustered at 28-30K").             |

## 10.5 Platform Requirements

| Platform                      | Release Timeline               | Features                                                                             |
| ----------------------------- | ------------------------------ | ------------------------------------------------------------------------------------ |
| **Native iOS**                | M1 (simultaneous with Android) | Push notifications, biometric auth (Face ID), Tradingview charts, all Stages A-G     |
| **Native Android**            | M1 (simultaneous with iOS)     | Push notifications, biometric auth (fingerprint), TradingView charts, all Stages A-G |
| **Web (Desktop, Responsive)** | M1                             | Full feature parity with mobile; keyboard shortcuts; desktop-optimized layout        |

---

# SECTION 11: PHASING (Reference ARX_3-1)

## 11.1 Release Schedule

| Cycle                                      | Duration | Core Delivery                                                                          | P0 Features                                                                                                                                                                                                                                                                                        | Persona Focus                        | Success Criteria                                                                                |
| ------------------------------------------ | -------- | -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ | ----------------------------------------------------------------------------------------------- |
| **C1: Foundation + Copy Marketplace MVP**  | M1-1.5   | Execute on Hyperliquid + S7 copy marketplace (per 3-5 Amendment + 2-3-6 V3.0)          | Discovery, Trade Screen, Order Execution, Portfolio, **Copy Marketplace** (leaderboard with dual sort Sharpe + Copier Profit, leader tiers, trading style tags, copy mode architecture 2×3 matrix, Follower Risk Rails, Slippage Guard, Portfolio Circuit Breaker, Simple Swap), APAC fiat on-ramp | P1 Jake (S2) + **S7 Copy Followers** | 500 users, 100+ active copy relationships, >85% onboarding, copier profit positive              |
| **C2: Intelligence & Discovery**           | M1.5-3   | Heatmaps, clusters, market narrative, leaderboard                                      | Heatmap overlay, Cluster Drill-Down, Leaderboard, Trader Detail, Copilot Stage 1                                                                                                                                                                                                                   | P1                                   | 1,200 users, 4 trades/user/day, >15% Gold conversion                                            |
| **C3: AI Copilot v1**                      | M3-4.5   | GenAI integration, Conviction Cards, Thesis Capture                                    | Copilot Conviction Card, Belief Snapshot, Plan Builder (basic), Sizing Guardrails                                                                                                                                                                                                                  | P1                                   | 1,800 users, >40% Copilot adoption, Copilot confidence >70%                                     |
| **C4: Quant + Social**                     | M4.5-6   | Quant frameworks, wallet classification, regime intelligence                           | Quant scoring, Regime Intelligence, Confluence Scoring, Social Sentiment, Journal v1                                                                                                                                                                                                               | P1 + P2                              | 2,200 users, Win rate by setup >55%, Referral NPS >35                                           |
| **C5: Copy Marketplace Expansion + HIP-3** | M6-7.5   | Outcome-aligned copy fees, Trade Rationale archive, HIP-3 equity perps, copy analytics | Outcome-aligned fee engine (Steady Hand Bonus, Consistency Bonus, Tenure Multiplier, 50% Deferred Payout), Trade Rationale browsable archive, HIP-3 trading, copy marketplace analytics (leader slippage, follower retention, risk-adjusted returns)                                               | S7/S2 expansion + P4                 | 3,000 users, 1,000+ active copiers, >$20K/month copy fees, follower 90-day positive return >55% |
| **C6: Advanced Execution + P3 UX**         | M7.5-9   | TWAP/VWAP/Iceberg/Grid execution, API for P5                                           | Execution strategy selector (all strategies), API key management, P3-optimized UI                                                                                                                                                                                                                  | P3 + P5                              | 4,000 users, >30% Gold using advanced execution, <5 P5 builders                                 |
| **C7: ML Intelligence**                    | M9-10.5  | Probabilistic regime, factor ensembles, personalized signals                           | ML regime detection, Signal ranking per user, Backtesting API                                                                                                                                                                                                                                      | P1 + P3 + P5                         | 5,500 users, ML regime >75% accuracy, Copilot confidence >82%                                   |
| **C8: Automation + Alpha Marketplace**     | M10.5-12 | Autonomous trading mode, model marketplace, delegated autonomy                         | Autonomous trading (opt-in), Model sharing, Performance royalties                                                                                                                                                                                                                                  | P5                                   | 8,000 users, 100 autonomous users, $25K/month alpha marketplace revenue                         |

---

# SECTION 12: OPEN QUESTIONS

| #        | Question                                                                                                                                              | Owner       | Due                            | Impact                                                       | Status               |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ------------------------------ | ------------------------------------------------------------ | -------------------- |
| **OQ-1** | Experience tier unlock criteria — what behavioral signals trigger tier-up (Guided → Standard → Pro)?                                                  | Product     | C2                             | Affects onboarding, feature gating, revenue ceiling          | Open                 |
| **OQ-2** | Copilot pricing — should advanced Copilot features (unlimited queries, advanced execution) be separate product ($15/mo) vs. bundled in Gold ($29/mo)? | CEO         | C3                             | Revenue architecture, ARPU, unit economics                   | Open                 |
| **OQ-3** | HIP-3 market maturity — are equity perps reliable enough for P4? Timeline for phase-in?                                                               | Engineering | C4                             | Asset class expansion timing, product scope                  | In Discussion        |
| **OQ-4** | Copy trading compliance — IOSCO framework applicability? Need legal opinion? (Copy marketplace launches C1; compliance review must start immediately) | Legal       | C1 (start), ongoing through C5 | Copy feature design constraints, geo restrictions, liability | Pending Legal Review |
| **OQ-5** | ML training data — is 6 months of user trading history sufficient for personalization models? Do we need synthetic data?                              | ML/Data     | C7                             | Intelligence depth timeline, accuracy floor                  | Research Phase       |
| **OQ-6** | Autonomous trading guardrails — at what confidence threshold (75%? 85%?) do we allow delegated trades?                                                | Product     | C8                             | Safety vs. UX, brand risk, regulatory                        | Design Phase         |
| **OQ-7** | International expansion — geo-restrictions for Hyperliquid, regulatory environment for Asia/EU?                                                       | Legal       | M12+                           | Market TAM, timeline for global launch                       | Backlog              |

---

# SECTION 13: ARCHITECTURE TEST

## "Can an Engineer Build Without Slacking 'What Should Happen When...?'"

This PRD passes the test if, for **every** major screen and feature, an engineer has:

1. **Purpose**: Clear definition of screen goal and jobs served
2. **Data**: Exact data displayed, including edge cases (empty state, error state, loading state)
3. **Actions**: All possible user interactions, with state transitions
4. **State Machine**: Visual flow of states (given-when-then style)
5. **Edge Cases**: Explicit handling (zero results, stale data, extreme values, contradictions)
6. **Acceptance Criteria (Given/When/Then)**: Testable, measurable, unambiguous

### Verification Checklist

Each screen must pass:

- [ ] **Discovery** — Can engineer build asset browser + filters without questions? (See 7.1, Stage A, A1-A6)
- [ ] **Trade Screen** — Can engineer implement chart + intelligence + action panel? (See 7.2, all zones, B1-B6)
- [ ] **Plan Builder** — Can engineer implement suggestion, chart overlay, guardrails validation? (See C1-C7)
- [ ] **Validation** — Can engineer implement all 6 checks (regime, funding, OI, evidence, risk, portfolio)? (See D1-D7)
- [ ] **Order Execution** — Can engineer build pre-fill, strategy selector, slippage meter, submit flow? (See E1-E8)
- [ ] **Position Monitor** — Can engineer implement position health, alerts, TP/SL adjust, de-risk triggers? (See F1-F8)
- [ ] **Journal** — Can engineer auto-populate, calculate attribution, render analytics? (See G1-G7)
- [ ] **Copilot** — Can engineer implement suggestion logic, confidence scoring, guardrails? (See Section 8.1-8.3)
- [ ] **Alerts** — Can engineer implement alert rules, triggering, delivery, actions? (See 7.1 Alerts screen)

If any screen has blanks or ambiguous sections, PRD is incomplete.

---

# SECTION 14: LIVING DOCUMENT CONTROLS

## 14.1 Version History & Change Log

| Version           | Date       | Major Changes                                                                                         | Owner  |
| ----------------- | ---------- | ----------------------------------------------------------------------------------------------------- | ------ |
| **1.0**           | 2026-03-01 | Initial consolidated PRD (v7 → v1.0). Narrowed persona, prototype validation, GenAI spec integration. | PM/CEO |
| **1.1** (pending) | 2026-03-08 | Post-C1 learnings: Discovery UX refinement, Leaderboard sybil detection, Alert rules expanded         | PM     |

## 14.2 Update Cadence

- **Weekly** during active build (C1-C8): Product syncs review customer feedback, telemetry, and technical constraints. Updates to Sections 6-7 (journey, IA, features). Sections 1-4 (strategy) only change per cycle.
- **Monthly**: Phasing (Section 11) reviewed and adjusted if necessary.
- **Quarterly**: Competitive analysis (Section 3) refreshed; business model (Section 4) updated with real metrics.

## 14.3 Approval Process

| Change Type                          | Approval Required |
| ------------------------------------ | ----------------- |
| P0 feature spec (add/remove/change)  | PM + CEO          |
| P1 feature spec                      | PM (CEO notified) |
| P2 feature spec                      | PM                |
| Persona / positioning (Section 2-3)  | PM + CEO          |
| Business model / pricing (Section 4) | CEO               |
| Tech debt / architecture decisions   | CTO + PM          |
| Design system / aesthetic changes    | Design Lead + PM  |

---

# SECTION 15: APPENDIX — ACCEPTANCE CRITERIA INDEX

All Given/When/Then acceptance criteria listed above, indexed by stage and screen:

**Stage A (ORIENT)**: A1-A6 (Section 6, Stage A)
**Stage B (BELIEF)**: B1-B6 (Section 6, Stage B)
**Stage C (TRADE)**: C1-C7 (Section 6, Stage C)
**Stage D (VALIDATE)**: D1-D7 (Section 6, Stage D)
**Stage E (EXECUTE)**: E1-E8 (Section 6, Stage E)
**Stage F (MONITOR)**: F1-F8 (Section 6, Stage F)
**Stage G (REFLECT)**: G1-G7 (Section 6, Stage G)

---

## User Story Specifications (Arx_3-0 Template)

> Full story specifications following the [Arx_3-0 Requirements Framework](Arx_3-0_Requirements_Framework.md) Layer 6 template. Each story traces to a persona, job, journey stage, and pain code.

### S7 Stories (Follower / Capital Allocator)

---

# US-S7-EVAL-01

## Context

> "When I'm browsing leaders for the first time and feeling skeptical about whether any platform can be trusted after three signal groups burned me, I want to sort by Copier Profit so I can see which leaders actually make money for followers like me -- not just for themselves."

|                    |                                                                                                                                                                                                                                                                                              |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Persona**        | S7 -- Sarah (Capital Allocator)                                                                                                                                                                                                                                                              |
| **Stage**          | STAGE-S7-EVALUATE                                                                                                                                                                                                                                                                            |
| **Job**            | JTBD-S7-01: "Help me find trustworthy people to manage my money, so I can feel like my savings are safe with someone competent"                                                                                                                                                              |
| **Pain addressed** | E4 -- Past betrayal by signal groups makes every new platform guilty until proven innocent; Copier Profit is the concrete counter-evidence. P5 -- No framework to evaluate leader skill vs. luck; aggregate follower earnings are the one metric she can trust without statistical literacy. |
| **Priority**       | P0                                                                                                                                                                                                                                                                                           |

## Entry & Exit Conditions

|             |                                                                                                                                                                                                          |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Entry**   | S7 is on D1 (Traders) screen with at least 1 ranked leader visible. Account created (may or may not be funded).                                                                                          |
| **Success** | Leaders are reordered by descending aggregate copier PnL for the selected time window; Sarah identifies at least one leader to evaluate further (taps through to D2).                                    |
| **Failure** | If copier data is unavailable for all leaders, sort falls back to leader's own return with a label change ("Returned" not "Earned") and a tooltip explaining that follower earnings data is coming soon. |

## User Flow

1. Sarah lands on D1 Traders tab (default sort: Follower Return 30d) -> sees leader cards with "Earned" hero metric showing what followers made.
2. Sarah taps [Sort: Follower Return v] dropdown -> sees sort options: Follower Return (default), Win Rate, Total Earned, Newest.
3. Sarah selects "Total Earned" -> leader cards reorder by `sum(all_copier_realized_pnl)` all-time, descending. Hero metric on each card updates to show the all-time total dollar figure.
4. Sarah scans the reordered list. Notices verified tier badges (E/P/V/R) inline with handles, follower counts, and style tags ("Conservative", "Swing Style").
5. Sarah taps a leader card with E (Elite) badge and high copier profit -> navigates to D2 Wallet Profile.

## Information Architecture

### D1 Sort Controls

| Element       | Content                                                    | Data Source | Computation                               |
| ------------- | ---------------------------------------------------------- | ----------- | ----------------------------------------- | ---------- | --------------------------------------------------------------------------------------- |
| Sort dropdown | "Follower Return" / "Win Rate" / "Total Earned" / "Newest" | UI control  | Selection triggers re-sort of trader list |
| Time toggle   | [7d                                                        | 30d\*       | 90d]                                      | UI control | Changes window for Follower Return and card metrics. "Total Earned" is always all-time. |

### D1 Trader Card (per leader)

| Element                | Content              | Data Source                               | Computation                                                                                                                                                                                |
| ---------------------- | -------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Hero metric "Earned"   | "+8.2%" or "$47,230" | `[ARX-COPY] copy_execution_records`       | **Follower Return mode:** `C13.2 followers_return(wallet, window)` = `median(per_copier_returns) * 100`. **Total Earned mode:** `sum(all_copier_realized_pnl)` all-time from `[ARX-COPY]`. |
| Win rate               | "81%"                | `[HL-FILLS] get_user_fills`               | `C3.5: profitable_closes / total_closes` for selected window                                                                                                                               |
| Worst month            | "-3.1%"              | `[HL-FILLS] get_user_fills`               | `min(monthly_returns)` over trailing 12 months                                                                                                                                             |
| Performance tier badge | "E" (gold)           | `[ARX-PROFILE] C3.8 performance_tier`     | `C3.8`: ROI (C3.1) + Sharpe (C3.2) + copier earnings thresholds -> Elite/Proven/Verified/Rising/Unranked                                                                                   |
| Follower count         | "142 copiers"        | `[ARX-COPY] follower_relationships`       | `count(active_followers)` where `status = ACTIVE`                                                                                                                                          |
| Capacity indicator     | "47/500 spots"       | `[ARX-COPY] copy_slots`                   | `available / max_slots`. At capacity: "FULL -- waitlist" in amber.                                                                                                                         |
| Risk profile label     | "Conservative"       | `[ARX-PROFILE] C4.2b risk_classification` | Rule-based from avg leverage (C4.3), max drawdown (C3.3), trade frequency                                                                                                                  |
| Trading style tag      | "Swing Style"        | `[ARX-PROFILE] C4.1 trading_style`        | Classified from hold duration distribution + trade frequency                                                                                                                               |

### External References

-> See [Arx_5-2-3_OnChain_Signal_Transformation_v6.md](Arx_5-2-3_OnChain_Signal_Transformation_v6.md) C13.2 (Followers' Return), C3.8 (Performance Tier), C4.1-C4.2b (Style/Risk classification)
-> See [Arx_4-1-1-4-2_Radar_Wallets.md](Arx_4-1-1-4-2_Radar_Wallets.md) SS2.5 (Trader Card spec), SS2.7 (Sort Controls)

## Acceptance Criteria

- [ ] AC-01: Given S7 on D1, when tapping Sort -> "Total Earned", then leaders reorder by descending `sum(all_copier_realized_pnl)` all-time, and the hero metric label changes to "$" total format.
- [ ] AC-02: Given S7 on D1 with sort = "Follower Return" and time toggle = 30d, then hero metric shows `C13.2 followers_return(wallet, "30d")` as a percentage, and leaders are sorted descending by this value.
- [ ] AC-03: Given a leader with 0 active copiers, the hero metric shows "No copiers yet" (not "$0" or "0.0%"), and the leader sorts to the bottom of any copier-based sort.
- [ ] AC-04: Given a leader with <2 copiers in the selected window but >=2 copiers all-time, the hero metric shows the all-time copier return with a "(all-time)" suffix.
- [ ] AC-05: Given S7 taps a leader card, then navigation goes to D2 Wallet Profile with the leader's wallet address passed as parameter.
- [ ] AC-06: Given S7 on D1 with verified tier badges visible, each badge letter (E/P/V/R) renders in the correct color (Gold #F59E0B / Silver #9CA3AF / Bronze #D97706 / Grey #6B7280) at 11px bold inline with the handle.

## Edge Cases

| Condition                          | Expected Behavior                                                                                                             | Rationale                                                                                         |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Zero leaders with copier data      | Sort falls back to leader's own return (C3.1). Hero label changes to "Returned". Tooltip: "Follower earnings available soon." | Day-1 cold start: no leader has copiers yet. Must not show blank cards.                           |
| Leader has 1 copier only           | `C13.2` returns `None` (min 2 copiers). Fallback to leader's own return with "Returned" label for this card only.             | Single copier is statistically meaningless; showing it would mislead.                             |
| API timeout on copier data         | Show cached trader list with stale badge. Amber banner: "Data may be delayed." Sort still works on cached values.             | Don't block browsing. Copier data refreshes on next pull-to-refresh.                              |
| Time toggle changes during scroll  | Re-fetch metrics for new window. Maintain scroll position. Show shimmer on metric values only (not full card).                | Avoid jarring full-list reload. User should not lose their place.                                 |
| Copier Profit is negative all-time | Show negative value in orange. Do not hide leaders with negative copier profit.                                               | Transparency. Hiding negative-profit leaders would undermine the trust signal this sort provides. |

## Analytics Events

| Event                      | Trigger                                        | Properties                                                                            | Purpose                                                                  |
| -------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| `sort_changed`             | S7 taps sort dropdown and selects new option   | `sort_option`, `previous_sort`, `time_window`                                         | Measure which sort options S7 uses most (validates Copier Profit demand) |
| `time_toggle_changed`      | S7 taps time toggle pill                       | `new_window`, `previous_window`, `sort_active`                                        | Understand preferred evaluation window                                   |
| `trader_card_tapped`       | S7 taps any trader card on D1                  | `leader_wallet`, `card_position`, `sort_active`, `filter_active`, `hero_metric_value` | Track which leaders get attention and from what position                 |
| `copier_profit_sort_used`  | S7 selects "Total Earned" or "Follower Return" | `sort_option`, `session_number`, `time_on_d1_before_sort`                             | Measure trust-building behavior: are S7s seeking copier proof?           |
| `fallback_label_displayed` | Hero metric falls back to "Returned"           | `leader_wallet`, `reason` (no_copiers / insufficient)                                 | Track cold-start coverage gap                                            |

---

# US-S7-ONBD-01

## Context

> "When I'm about to commit my first $500 to copy a leader and I'm terrified of handing control of my money to a stranger, I want to configure my own Risk Rails (leverage cap, stop loss, max trade size, slippage guard) so I can feel protected even if this leader makes a reckless trade."

|                    |                                                                                                                                                                                                                                                                                                                                                                              |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Persona**        | S7 -- Sarah (Capital Allocator)                                                                                                                                                                                                                                                                                                                                              |
| **Stage**          | STAGE-S7-ONBOARD                                                                                                                                                                                                                                                                                                                                                             |
| **Job**            | JTBD-S7-02: "Help me protect my capital even when a leader makes a bad trade, so I can sleep at night knowing I won't wake up to a wipeout"                                                                                                                                                                                                                                  |
| **Pain addressed** | E4 -- The trust-delegation fear is at maximum intensity at the moment of first fund; Risk Rails are the only thing making it psychologically possible to hand real money to a stranger's decisions. E1 -- Fear of liquidation through a leader's position is identical to the fear of self-inflicted liquidation; configurable leverage cap is the direct structural answer. |
| **Priority**       | P0                                                                                                                                                                                                                                                                                                                                                                           |

## Entry & Exit Conditions

|             |                                                                                                                                                                                                                                                                                        |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Entry**   | S7 has tapped [Copy Trader >] on D2 Wallet Profile. Account is funded with >= $50 available balance. Leader has available copy slots.                                                                                                                                                  |
| **Success** | S7 completes D3 Step 1 (allocation + sees projections including safety net) and D3 Step 2 (confirms with checkbox acknowledging max loss). Copy relationship created with `status = ACTIVE`, Risk Rails persisted to `CopyRelationship` record. S7 lands on Feed tab in Copying state. |
| **Failure** | If balance < $50: slider disabled, "Fund first" + [Deposit >] CTA. If leader fills up during setup: "This trader just filled up." + [Find Another >]. If network error on tx broadcast: "Your money wasn't moved." + [Retry], all settings preserved.                                  |

## User Flow

1. Sarah lands on D3 Step 1 ("How Much?") -> sees leader handle, risk label ("68% win rate -- Moderate risk (3.2x)"), and regime banner.
2. Sarah sees allocation slider (min $50, max available balance) with quick picks [$100] [$250] [$500] [Custom] and C6.5 recommended size ("Suggested: $420").
3. Sarah selects $500 via quick pick or slider -> projection cards update in real-time:
   - Green card: "Typical month +$31 (+6.1%)" / "Best month +$41 (+8.2%)"
   - Amber card (protection): "Your safety net" / "Copying pauses at -$250" / "Worst month -$72 (-14.3%)" / "Safety limit: -$250 (50%)"
4. Sarah reads the regime context banner (if applicable): "BTC is in crisis -- your safety limit of -$250 protects your capital."
5. Sarah taps [Continue >] -> slides to D3 Step 2 ("Confirm").
6. Sarah reviews summary card: Trader, Amount ($500), Safety (Pauses at -$250), Fee (~$0.10/trade).
7. Sarah reads "What happens next" explainer: future trades copied, current open positions NOT copied, pause or stop anytime.
8. Sarah checks the required checkbox: "I understand I may lose up to $250 on this copy."
9. Sarah taps [Start Copying] -> button disables + "Starting..." + spinner -> tx signed -> checkmark animation (400ms) -> toast "Now copying @CryptoKing" -> navigates to Feed tab (Copying state).

## Information Architecture

### D3 Step 1: How Much?

| Element               | Content                                                                | Data Source                                                | Computation                                                                                                 |
| --------------------- | ---------------------------------------------------------------------- | ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| Leader risk label     | "68% win rate -- Moderate risk (3.2x)"                                 | `[ARX-PROFILE] C4.2b risk_classification`, `C3.5 win_rate` | `C4.2b` classification from avg leverage + MDD + trade frequency. Win rate from `C3.5`.                     |
| Regime banner         | "Trending -- copies at full size"                                      | `[ARX-REGIME] C5.1 classify_regime(asset)`                 | Per-asset regime state for assets this leader trades. Sizing modifier from C5.1 table.                      |
| Available balance     | "$2,500"                                                               | `[HL-STATE] get_user_state -> withdrawable`                | Raw value, updated on mount                                                                                 |
| C6.5 suggested size   | "Suggested: $420"                                                      | `[ARX-COMPUTE] C6.5`                                       | `kelly x regime_sizing x risk_pref_multiplier x confidence_factor x accountValue`, capped at 25% of account |
| Typical month         | "+$31 (+6.1%)"                                                         | `[HL-FILLS] get_user_fills` (leader's fills, last 90d)     | `median(monthly_returns) x allocation_amount`                                                               |
| Best month            | "+$41 (+8.2%)"                                                         | `[HL-FILLS] get_user_fills` (leader's fills, last 90d)     | `max(monthly_returns) x allocation_amount`                                                                  |
| Worst month           | "-$72 (-14.3%)"                                                        | `[HL-FILLS] get_user_fills` (leader's fills, last 90d)     | `min(monthly_returns) x allocation_amount`                                                                  |
| Safety limit          | "-$250 (50%)"                                                          | Derived from allocation                                    | `allocation_amount x 0.50` (canonical default per C7.1)                                                     |
| Regime context banner | "BTC is in crisis -- your safety limit of -$250 protects your capital" | `[ARX-REGIME] C5.1` per asset leader trades                | Shown only when any leader asset is in COMPRESSION, CRISIS, or TRANSITION regime                            |

### D3 Step 2: Confirm

| Element              | Content                              | Data Source                                           | Computation                                                              |
| -------------------- | ------------------------------------ | ----------------------------------------------------- | ------------------------------------------------------------------------ |
| Trader name          | "CryptoKing"                         | `[ARX-PROFILE] display_name`                          | Raw                                                                      |
| Amount               | "$500"                               | Step 1 selection                                      | Raw                                                                      |
| Safety limit         | "Pauses at -$250"                    | Step 1 derivation                                     | `allocation_amount x 0.50`                                               |
| Fee estimate         | "~$0.10 per trade"                   | `[ARX-COMPUTE]`                                       | `avg_trade_size x 0.0002 x avg_trades_per_week` (builder code rate 2bps) |
| Avg trades/week      | "Averages 4 trades/week"             | `[HL-FILLS] get_user_fills`                           | `trade_count / weeks_active`                                             |
| Open positions count | "3 open positions" (info line)       | `[HL-STATE] get_user_state(leader) -> assetPositions` | `count(positions where szi != 0)`. Shown only if > 0.                    |
| Checkbox label       | "I understand I may lose up to $250" | Step 1 derivation                                     | `allocation_amount x 0.50`                                               |

### CopyRelationship Record Created on Success

| Field                   | Value Set                                 | Source                                          |
| ----------------------- | ----------------------------------------- | ----------------------------------------------- |
| `allocation_mode`       | `FIXED_AMOUNT`                            | D3 Step 1 (MVP default)                         |
| `investment_amount`     | 500                                       | Slider / quick pick value                       |
| `max_leverage`          | Leader's avg leverage (from C4.3), capped | Auto-set from leader profile at copy start      |
| `independent_sl`        | `true`                                    | MVP default: follower always uses own stop loss |
| `max_trade_size`        | `investment_amount x 0.10`                | 10% of allocation (MVP default)                 |
| `slippage_guard`        | 0.5%                                      | "Standard" preset (MVP default)                 |
| `per_leader_protection` | `investment_amount x 0.50`                | 50% canonical default (C7.1)                    |
| `status`                | `ACTIVE`                                  | Set on successful tx broadcast                  |

### External References

-> See [Arx_4-1-1-4-2_Radar_Wallets.md](Arx_4-1-1-4-2_Radar_Wallets.md) SS5 (D3 Copy Setup full wireframe + field sources)
-> See [Arx_4-1-1-7_Mobile_Data_Object_Model.md](Arx_4-1-1-7_Mobile_Data_Object_Model.md) SS3.4 (CopyRelationship schema)
-> See [Arx_5-2-3_OnChain_Signal_Transformation_v6.md](Arx_5-2-3_OnChain_Signal_Transformation_v6.md) C6.5 (Recommended Size), C7.1 (Circuit Breaker)

## Acceptance Criteria

- [ ] AC-01: Given S7 on D3 Step 1, when adjusting slider or tapping quick pick, then projection cards (Typical month, Best month, Worst month, Safety limit) update within 200ms reflecting the new allocation amount.
- [ ] AC-02: Given S7 allocation > 25% of available balance, then an amber warning appears: "Consider starting smaller."
- [ ] AC-03: Given the leader has < 20 closing fills in 90 days, then projection cards are replaced with a single info card: "Not enough trading history for a projection. This trader has made [N] trades in 90 days."
- [ ] AC-04: Given S7 on D3 Step 2, the [Start Copying] button is disabled until the risk acknowledgment checkbox is checked.
- [ ] AC-05: Given S7 taps [Start Copying] with checkbox checked, then a `CopyRelationship` record is created with `max_leverage` = leader's avg leverage (C4.3), `independent_sl = true`, `slippage_guard = 0.5`, `per_leader_protection = amount x 0.50`, and `status = ACTIVE`.
- [ ] AC-06: Given successful tx broadcast, then checkmark animation plays (400ms), toast "Now copying @{handle}" appears, and S7 navigates to Feed tab in Copying state.
- [ ] AC-07: Given any leader asset is in COMPRESSION, CRISIS, or TRANSITION regime (C5.1), then regime context banner appears on Step 1 naming the specific asset and tying to the user's safety limit amount.

## Edge Cases

| Condition                      | Expected Behavior                                                                                          | Rationale                                                                                     |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| $0 balance                     | Slider disabled. Show "Fund your account first" + [Deposit >] CTA.                                         | Can't copy without funds. Direct to on-ramp flow immediately.                                 |
| Balance < $50                  | Show "Minimum $50 to copy" with current balance. [Deposit >] CTA.                                          | $50 minimum ensures meaningful allocation after safety limit math.                            |
| Leader fills up during D3 flow | "This trader just filled up." + [Find Another >] navigates back to D1.                                     | Capacity is checked at tx broadcast time, not page load. Prevents race condition.             |
| Network error on tx broadcast  | "Your money wasn't moved." + [Retry]. All Step 1/2 values preserved.                                       | S7 must never be uncertain about whether money moved. Explicit confirmation of failure.       |
| App backgrounded during D3     | State persists for 30 minutes, then resets to D2 Profile.                                                  | Prevents stale allocation with changed balance. 30min is generous for interruptions.          |
| Leader has 0 trades in 90d     | Projection cards hidden. Warning: "This trader hasn't been active recently." [Continue >] still available. | Don't block the flow but set expectations. S7 might still want to follow an inactive veteran. |

## Analytics Events

| Event                      | Trigger                                        | Properties                                                         | Purpose                                                                                 |
| -------------------------- | ---------------------------------------------- | ------------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| `copy_setup_started`       | S7 lands on D3 Step 1                          | `leader_wallet`, `available_balance`, `leader_tier`                | Top of copy funnel. Measure D2->D3 conversion.                                          |
| `allocation_changed`       | Slider moved or quick pick tapped              | `amount`, `method` (slider/quick_pick/suggested), `pct_of_balance` | Understand allocation behavior. Are S7s using C6.5 suggestion?                          |
| `projection_viewed`        | Projection cards render (viewport visible 2s+) | `amount`, `typical_month`, `worst_month`, `safety_limit`           | Confirm projections are being read before proceeding.                                   |
| `regime_banner_displayed`  | Regime context banner renders                  | `regime_state`, `asset`, `safety_amount`                           | Track how often S7s see crisis warnings during copy setup.                              |
| `copy_setup_step2_reached` | S7 taps [Continue >]                           | `amount`, `time_on_step1`                                          | Step 1->2 conversion. Long time_on_step1 = deliberation or confusion.                   |
| `copy_confirmed`           | [Start Copying] tapped and tx succeeds         | `leader_wallet`, `amount`, `safety_limit`, `time_on_step2`         | End of funnel. THE conversion event for S7.                                             |
| `copy_setup_abandoned`     | S7 navigates back from D3 without completing   | `step_abandoned` (1 or 2), `amount_selected`, `time_spent`         | Where in D3 does the funnel break? Step 1 = projection scary. Step 2 = commitment fear. |

---

# US-S7-FVAL-01

## Context

> "When a leader I'm copying takes a reckless 15x leveraged trade and I see my Risk Rails cap it at 5x, I want to see exactly how much money Arx just saved me so I can feel confident that my protection system works and this platform is fundamentally different from the signal groups that burned me."

|                    |                                                                                                                                                                                                                                                                                 |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Persona**        | S7 -- Sarah (Capital Allocator)                                                                                                                                                                                                                                                 |
| **Stage**          | STAGE-S7-FIRST-VALUE                                                                                                                                                                                                                                                            |
| **Job**            | JTBD-S7-02: "Help me protect my capital even when a leader makes a bad trade, so I can sleep at night knowing I won't wake up to a wipeout"                                                                                                                                     |
| **Pain addressed** | E4 -- The first "Arx Saved Me" moment is the direct antidote to trust-betrayal pain: it proves protection worked even when the leader didn't. E1 -- Seeing "$131 saved" makes liquidation-prevention concrete, not abstract; transforms an anxiety into a quantified near-miss. |
| **Priority**       | P0                                                                                                                                                                                                                                                                              |

## Entry & Exit Conditions

|             |                                                                                                                                                                                                                                                                                                              |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Entry**   | S7 has at least one active copy relationship (`CopyRelationship.status = ACTIVE`). A leader opens a trade where the leader's leverage exceeds the follower's `max_leverage` cap, OR leader's trade size exceeds the follower's `max_trade_size`, OR the trade is rejected due to `slippage_guard` threshold. |
| **Success** | S7 sees the Risk Rails intervention on their dashboard (Feed or Manage screen) with: (1) what the leader did, (2) what happened to Sarah's copy, (3) the dollar amount saved. Cumulative "Arx Saved Me" counter increments.                                                                                  |
| **Failure** | If savings computation fails (e.g., missing leader fill data), show the intervention event without dollar amount: "Your leverage cap protected you on this trade" with a generic shield icon. Log the computation failure for backend investigation.                                                         |

## User Flow

1. Leader opens a 15x BTC LONG position. Sarah's `max_leverage` is set to 5x. Arx copy engine detects divergence.
2. Arx executes Sarah's copy at 5x (her cap), not 15x (leader's leverage). Position is opened with reduced size.
3. **Push notification** fires: "Your Risk Rails just protected you. @CryptoKing used 15x leverage -- your copy stayed at 5x. Tap to see details."
4. Sarah taps notification -> opens Feed tab -> sees a Risk Rails Protection Card at the top of her feed:
   - Shield icon (animated pulse, 400ms)
   - "Risk Rails Protected You"
   - Leader leverage: 15x -> Your leverage: 5x
   - "Estimated savings: $131" (computed from leverage difference x position outcome)
   - "Cumulative savings: $347 across 4 events"
   - [View Trade Details >] -> expands to show leader's fill vs. Sarah's fill side-by-side
5. Sarah may also see the event on the Manage screen safety bar, where per-leader protection usage updates.
6. Over the next 1-14 days, Sarah accumulates 3+ "Arx Saved Me" moments -> advancement trigger to HABIT stage.

## Information Architecture

### Feed: Risk Rails Protection Card

| Element             | Content                                                | Data Source                                                      | Computation                                                                                                                                                                                                                                                      |
| ------------------- | ------------------------------------------------------ | ---------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Card type           | "Risk Rails Protected You"                             | `[ARX-COPY] copy_event.type = RISK_RAIL_TRIGGERED`               | Event generated by copy engine when divergence detected                                                                                                                                                                                                          |
| Leader leverage     | "15x"                                                  | `[HL-STATE] get_user_state(leader) -> assetPositions[].leverage` | Leader's actual leverage on the triggering trade                                                                                                                                                                                                                 |
| Follower leverage   | "5x"                                                   | `[ARX-COPY] CopyRelationship.max_leverage`                       | Sarah's configured cap from D3 setup                                                                                                                                                                                                                             |
| Estimated savings   | "$131"                                                 | `[ARX-COMPUTE]`                                                  | `abs(leader_pnl_at_leader_leverage - leader_pnl_at_follower_leverage) x (follower_allocation / leader_position_size)`. Uses leader's actual trade outcome (closed PnL) scaled to what Sarah's loss would have been at leader's leverage vs. her capped leverage. |
| Cumulative savings  | "$347 across 4 events"                                 | `[ARX-COPY] CopyPortfolio.risk_rails_savings` (aggregated)       | `sum(all estimated_savings)` from all `RISK_RAIL_TRIGGERED` events for this user                                                                                                                                                                                 |
| Event count         | "4 events"                                             | `[ARX-COPY] copy_events`                                         | `count(events where type = RISK_RAIL_TRIGGERED)`                                                                                                                                                                                                                 |
| Protection type     | "Leverage Cap" / "Trade Size Limit" / "Slippage Guard" | `[ARX-COPY] copy_event.rail_type`                                | Which specific rail triggered                                                                                                                                                                                                                                    |
| Leader fill price   | "$67,890"                                              | `[HL-FILLS] get_user_fills(leader)` latest fill                  | Leader's entry price on the triggering trade                                                                                                                                                                                                                     |
| Follower fill price | "$67,902"                                              | `[ARX-COPY] copy_fill` for this event                            | Sarah's actual copy entry price                                                                                                                                                                                                                                  |
| Slippage            | "0.02%"                                                | `[ARX-COMPUTE]`                                                  | `abs(follower_fill - leader_fill) / leader_fill x 100`                                                                                                                                                                                                           |

### Manage Screen: Safety Bar Update

| Element                 | Content             | Data Source                                                 | Computation                                                                       |
| ----------------------- | ------------------- | ----------------------------------------------------------- | --------------------------------------------------------------------------------- |
| Per-leader loss used    | "CK: -$52"          | `[ARX-COPY] sum(copy_fill.closedPnl)` for this leader today | Running loss against `per_leader_protection` limit                                |
| Aggregate safety bar    | "Used: $152 (30%)"  | `[ARX-COPY]` across all active copies                       | `sum(losses) / sum(per_leader_protection)` across all `ACTIVE` copy relationships |
| Protection status color | Green / Amber / Red | Derived from aggregate safety %                             | Green: 0-50%, Amber: 50-80%, Red: 80-100% of configured limits                    |

### Push Notification

| Element   | Content                                                        | Data Source             | Computation                                                             |
| --------- | -------------------------------------------------------------- | ----------------------- | ----------------------------------------------------------------------- |
| Title     | "Risk Rails Protected You"                                     | Static                  | --                                                                      |
| Body      | "@CryptoKing used 15x -- your copy stayed at 5x. Saved ~$131." | `[ARX-COPY] copy_event` | Leader handle + leader leverage + follower leverage + estimated savings |
| Deep link | Feed tab, scroll to protection card                            | --                      | Opens app to Feed with the protection card visible                      |

### External References

-> See [Arx_4-1-1-4-2_Radar_Wallets.md](Arx_4-1-1-4-2_Radar_Wallets.md) SS6.3 (Safety Bar thresholds)
-> See [Arx_4-1-1-7_Mobile_Data_Object_Model.md](Arx_4-1-1-7_Mobile_Data_Object_Model.md) SS3.4 (CopyRelationship), SS3.5 (CopyPortfolio)
-> See [Arx_5-2-3_OnChain_Signal_Transformation_v6.md](Arx_5-2-3_OnChain_Signal_Transformation_v6.md) C7.1 (Safety Bar / Circuit Breaker)

## Acceptance Criteria

- [ ] AC-01: Given a leader opens a trade at 15x leverage and S7's `max_leverage = 5`, then S7's copy executes at 5x leverage and a `RISK_RAIL_TRIGGERED` event is created with `rail_type = LEVERAGE_CAP`.
- [ ] AC-02: Given a `RISK_RAIL_TRIGGERED` event, then a push notification fires within 30 seconds containing the leader handle, leader leverage, follower leverage, and estimated savings amount.
- [ ] AC-03: Given S7 taps the push notification, then the app opens to Feed tab with the Risk Rails Protection Card scrolled into view.
- [ ] AC-04: Given the leader's trade closes (win or loss), then `estimated_savings` is computed as the absolute difference between the leader's outcome at leader leverage vs. the outcome at the follower's capped leverage, scaled to the follower's allocation.
- [ ] AC-05: Given S7 has accumulated 3+ `RISK_RAIL_TRIGGERED` events, then the cumulative savings counter on the Protection Card shows the correct running total.
- [ ] AC-06: Given S7's `max_trade_size` is exceeded by a leader trade, then the copy is scaled down to `max_trade_size` and a `RISK_RAIL_TRIGGERED` event fires with `rail_type = TRADE_SIZE_LIMIT`.
- [ ] AC-07: Given S7's `slippage_guard = 0.5%` and the copy would fill at > 0.5% slippage from leader's entry, then the copy is rejected and a `RISK_RAIL_TRIGGERED` event fires with `rail_type = SLIPPAGE_GUARD` and estimated savings = full trade amount avoided.

## Edge Cases

| Condition                                | Expected Behavior                                                                                                                                             | Rationale                                                                                               |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Leader trade still open (unrealized)     | Show "Protection active" card with leverage comparison but no dollar savings yet. Update to final savings when trade closes.                                  | Savings require a closed PnL. Don't show speculative savings that could reverse.                        |
| Multiple rails trigger on same trade     | Show the most protective rail (largest savings) as primary. Expand to show all triggered rails on [View Details].                                             | Don't overwhelm with 3 simultaneous cards. One clear message > three confusing ones.                    |
| Savings computation returns $0           | Show "Your Risk Rails were active on this trade" without a dollar amount. Still increment event count.                                                        | $0 savings means the capped trade had the same outcome. The protection still functioned correctly.      |
| Push notifications disabled              | Protection card still appears in Feed on next app open. In-app badge count increments.                                                                        | Push is the ideal channel but not the only one. Feed must be self-sufficient.                           |
| Leader closes trade at a profit          | Savings may be negative (S7 earned less due to lower leverage). Do NOT show negative savings. Show: "Your Risk Rails kept your leverage at 5x on this trade." | Showing "you missed $X profit" would undermine trust in the protection system. Frame as safety, always. |
| First-ever Risk Rail trigger for this S7 | Add celebratory micro-animation (shield pulse + confetti burst, 600ms). Extra copy: "This is your first Risk Rails save. Your protection is working."         | The first "Arx Saved Me" moment is the single most important retention event. Make it memorable.        |

## Analytics Events

| Event                          | Trigger                                        | Properties                                                                                               | Purpose                                                                   |
| ------------------------------ | ---------------------------------------------- | -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `risk_rail_triggered`          | Copy engine detects divergence and caps trade  | `leader_wallet`, `rail_type`, `leader_leverage`, `follower_leverage`, `estimated_savings`, `trade_asset` | Core retention metric. Frequency and magnitude of protection events.      |
| `savings_notification_sent`    | Push notification dispatched                   | `leader_wallet`, `rail_type`, `estimated_savings`                                                        | Notification delivery rate.                                               |
| `savings_notification_tapped`  | S7 taps the push notification                  | `leader_wallet`, `time_since_notification`                                                               | Engagement rate with protection events. Fast tap = high anxiety/interest. |
| `protection_card_viewed`       | Protection card is in viewport for 2+ seconds  | `leader_wallet`, `rail_type`, `estimated_savings`, `cumulative_savings`                                  | Are S7s reading the protection cards or scrolling past?                   |
| `protection_card_expanded`     | S7 taps [View Trade Details >]                 | `leader_wallet`, `rail_type`                                                                             | Deep engagement with protection explanation. Higher = more trust-seeking. |
| `cumulative_savings_milestone` | Cumulative savings crosses $100, $500, $1000   | `milestone_amount`, `event_count`, `days_since_first_copy`                                               | Milestone moments for potential celebratory UX and retention campaigns.   |
| `first_save_event`             | First-ever `RISK_RAIL_TRIGGERED` for this user | `leader_wallet`, `rail_type`, `estimated_savings`, `days_since_first_copy`                               | THE retention moment. Track everything about it.                          |

---

## S2 Jake — User Story Specifications

---

# US-S2-EVAL-01

## Context

> "When I'm exploring Arx for the first time and cross-checking it against my own analysis, I want to search for a symbol I'm already watching and immediately see Copilot's thesis so I can validate whether this tool sees the same setups I see — or surfaces noise."

|                    |                                                                                                                                                                                                                                                                                            |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Persona**        | S2 — Jake (Independent Trader)                                                                                                                                                                                                                                                             |
| **Stage**          | STAGE-S2-EVALUATE (Day 0, first session)                                                                                                                                                                                                                                                   |
| **Job**            | JTBD-S2-01 — "Help me trade my thesis without getting wrecked by signals I can't see, so I can feel like a professional in control"                                                                                                                                                        |
| **Pain addressed** | P1 — Fragmented 7-tool workflow means Jake has never seen regime, smart money, and technicals unified on one screen; he has to mentally stitch them together. P2 — Signal overload from disparate tools makes him primed for synthesis but skeptical it can be delivered in a single card. |
| **Priority**       | P0 — This is the retention-critical "aha moment" for S2. If Copilot doesn't reflect Jake's independent thesis, he bounces.                                                                                                                                                                 |

## Entry & Exit Conditions

|             |                                                                                                                                                                                                                                                                                  |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Entry**   | Jake has connected wallet, completed onboarding, and is on the R0 Feed (Discover tab) or has navigated to C3 Asset Detail for a symbol he already watches.                                                                                                                       |
| **Success** | Jake sees a signal card whose thesis matches his independent analysis, recognizes it was surfaced hours before he found it himself, and taps through to detail.                                                                                                                  |
| **Failure** | No matching signal exists for symbols Jake watches. Fallback: show "Set up your watchlist to see personalized signals" prompt with quick-add for his top 5 symbols. If Copilot disagrees with Jake's thesis, show the reasoning transparently (do not hide conflicting signals). |

## User Flow

1. Jake opens Arx and lands on R0 Feed (Discover tab, default for new S2 users without copied leaders).
2. Jake taps the search bar in Element A (Header) and types a symbol he's already watching (e.g., "SOL").
3. App navigates to C3 Asset Detail for SOL-PERP. The Regime Bar at the top of C3 shows the current regime state (e.g., "TRENDING 78%" in green).
4. Below the chart, a Smart Money Signal card (Card Type 5 from R0) or a Lucid Thesis card is displayed. The card shows: consensus direction, number of Performance Elite wallets aligned, regime context, and a confluence breakdown.
5. Jake reads the signal card. **Recognition moment:** The thesis matches his own analysis (long SOL, momentum continuation, funding supportive) — but the card timestamp shows it was generated 2 hours earlier than Jake's independent identification.
6. Jake taps the signal card to expand. The expanded view shows: individual signal layer agreement (P1 Regime, P2 Instrument, P3 Participant, P4 Structural), smart money wallet count, and a "Trade This Setup" CTA.
7. [Decision point:] Jake either (a) taps "Trade This Setup" which calls `openTradeWithIntent(sym, dir, lev, source)` routing to TH → C5-NEW, or (b) taps back to R0 to browse more signals — trust building but not yet ready to commit.

## Information Architecture

### C3 Asset Detail — Regime Bar

| Element           | Content                               | Data Source                        | Computation                                                                            |
| ----------------- | ------------------------------------- | ---------------------------------- | -------------------------------------------------------------------------------------- |
| Regime label      | "TRENDING"                            | `RegimeState.label`                | C5.1 regime classification from ADX-14, BB width, Hurst exponent                       |
| Regime confidence | "78%"                                 | `RegimeState.confidence`           | C5.2 confidence = f(ADX distance from threshold, BB width percentile, Hurst alignment) |
| Regime color      | Green bar (`--color-regime-trending`) | `RegimeState.color`                | Mapped from `RegimeState.regime` enum via design system `4-2` v5.7 regime palette      |
| Regime duration   | "4d"                                  | `RegimeState.started_at`           | `now() - RegimeState.started_at` formatted as days                                     |
| Bell icon         | Alert toggle                          | `[ARX-PREFS].regime_change_alerts` | Boolean toggle, tap opens alert config                                                 |

### C3 Asset Detail — Smart Money Signal Card (Card Type 5)

| Element             | Content                        | Data Source                                | Computation                                                                                 |
| ------------------- | ------------------------------ | ------------------------------------------ | ------------------------------------------------------------------------------------------- |
| Headline            | "Smart Money: 73% long SOL"    | `SmartMoneySignalCardProps.consensus_data` | `consensus_data.percentage` + `consensus_data.direction` + `consensus_data.asset`           |
| Supporting count    | "11 of 15 elite wallets agree" | `SmartMoneySignalCardProps.consensus_data` | `consensus_data.count` + " of " + `consensus_data.total`                                    |
| Combined notional   | "$4.2M total position"         | `consensus_data.combined_notional_usd`     | Sum of notional USD across consensus wallets; formatted with abbreviation (K/M/B)           |
| Regime context line | "Trending 4d"                  | `SmartMoneySignalCardProps.regime_context` | `regime_context.name` + `regime_context.duration_days` + "d". Color: `regime_context.color` |
| Card timestamp      | "2h ago"                       | `FeedEvent.created_at`                     | `now() - FeedEvent.created_at` formatted as relative time                                   |
| Left border         | 2px `--color-data`             | Design system `4-2`                        | Static styling per Card Type 5 spec                                                         |
| CTA                 | [Browse Elite Traders ->]      | —                                          | Routes to D1 Discover Leaders tab with Performance Elite filter pre-applied                 |

### C3 Asset Detail — Expanded Signal Detail (on card tap)

| Element                     | Content                                         | Data Source                             | Computation                                                                                                |
| --------------------------- | ----------------------------------------------- | --------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| P1 Regime layer             | "Regime: TRENDING (supports long)"              | `RegimeState.regime` + `.label`         | C5.1 classification; direction alignment check against consensus direction                                 |
| P2 Instrument layer         | "Funding: -0.003% (longs paying, normal)"       | `[HL-FUNDING].funding_rate`             | Raw funding rate from Hyperliquid `/info` endpoint; percentile from C5-2-3 funding distribution            |
| P3 Participant layer        | "Smart Money: 73% long ($4.2M)"                 | `consensus_data` from C10.1             | Performance Elite cluster consensus per C10 engine; direction + percentage + notional                      |
| P4 Structural layer         | "OI increasing with price (trend confirmation)" | `[HL-META].open_interest` + price delta | C2 open interest delta correlated with price delta over 4h window                                          |
| Signal generation timestamp | "Signal first detected: 10:42 AM"               | `FeedEvent.created_at`                  | Absolute timestamp of when C10 consensus threshold was first crossed                                       |
| Trade CTA                   | [Trade This Setup ->]                           | —                                       | Calls `openTradeWithIntent(sym='SOL-PERP', dir='long', lev=null, source='radar_signal')` routing to C5-NEW |

### External References

-> See [Arx_5-2-3_OnChain_Signal_Transformation_v7.md](Arx_5-2-3_OnChain_Signal_Transformation_v7.md) §3 (C10 Cluster Consensus Engine)
-> See [Arx_4-1-1-4-1_Radar_Feed.md](Arx_4-1-1-4-1_Radar_Feed.md) §Card Type 5 (Smart Money Signal)
-> See [Arx_4-1-1-7_Mobile_Data_Object_Model.md](Arx_4-1-1-7_Mobile_Data_Object_Model.md) §2.1 (RegimeState)

## Acceptance Criteria

- [ ] AC-01: Given S2 Jake on C3 Asset Detail for a symbol with an active Performance Elite consensus (>=60% same-direction, C10.1), when the page loads, then a Smart Money Signal card renders below the chart within 2 seconds showing consensus %, direction, wallet count, and regime context.
- [ ] AC-02: Given a Smart Money Signal card is displayed, when Jake taps the card body, then it expands (250ms spring animation) to show P1-P4 signal layer breakdown with individual agreement indicators and the signal generation timestamp.
- [ ] AC-03: Given Jake taps "Trade This Setup" on the expanded card, then `openTradeWithIntent()` is called with `symbol`, `direction` from consensus, `source='radar_signal'`, and `regime_context` pre-populated, and C5-NEW renders within 500ms with direction pre-selected and Lucid Signals Card showing the originating signal evidence.
- [ ] AC-04: Given no Performance Elite consensus exists for the searched symbol, then the signal card area shows "No smart money consensus on {SYMBOL} right now. We'll alert you when one forms." with an [Enable Alert] CTA that creates a consensus alert for this asset.
- [ ] AC-05: Given the signal card thesis conflicts with a common independent analysis direction (e.g., consensus is short but price is trending up), then the signal card shows the reasoning transparently and does NOT suppress the conflicting signal.

## Edge Cases

| Condition                                       | Expected Behavior                                                                                          | Rationale                                                                            |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| Symbol has no Performance Elite consensus       | Show "No smart money consensus" empty state with alert opt-in CTA                                          | S2 traders watch niche symbols; absence of signal is information, not a bug          |
| Consensus just crossed 60% threshold (<5 min)   | Show signal card with "Just formed" badge and lower visual temperature (muted border)                      | Recency flag prevents stale-looking signals from being mistaken for aged consensus   |
| Regime is TRANSITION (low confidence)           | Regime bar shows amber; signal card adds context line: "Regime unclear — signal reliability reduced"       | Honest uncertainty builds trust; hiding it destroys credibility with S2              |
| WebSocket disconnection during detail view      | Show stale data with "Last updated X min ago" badge; auto-reconnect in background                          | S2 traders are latency-sensitive; visible staleness prevents stale-data trades       |
| Performance Elite cluster has <10 members total | Suppress Smart Money Signal card entirely; fall back to individual P1-P4 signals without cluster consensus | Per C10 spec, minimum 10 members required for Performance Elite statistical validity |

## Analytics Events

| Event                        | Trigger                                              | Properties                                                                            | Purpose                                                                  |
| ---------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| `signal_card_viewed`         | Smart Money Signal card enters viewport on C3        | `asset`, `consensus_direction`, `consensus_pct`, `regime`, `card_age_seconds`         | Measure signal visibility and freshness at view time                     |
| `signal_card_expanded`       | Jake taps card to expand P1-P4 detail                | `asset`, `consensus_direction`, `time_on_card_ms`, `expand_duration_ms`               | Measure engagement depth — expanded = higher intent                      |
| `signal_matches_user_thesis` | Jake taps "Trade This Setup" within 60s of expanding | `asset`, `consensus_direction`, `signal_age_hours`, `regime`, `source='radar_signal'` | Core retention metric — signal-thesis match rate predicts D7 retention   |
| `signal_no_consensus`        | C3 loads with no Performance Elite consensus         | `asset`, `user_watchlist_contains`                                                    | Measure miss rate — how often Jake's symbols lack signals (gap analysis) |
| `signal_alert_enabled`       | Jake taps [Enable Alert] on empty consensus state    | `asset`, `alert_type='consensus'`                                                     | Re-engagement funnel — these alerts drive return visits                  |

---

# US-S2-ONBD-01

## Context

> "When I'm placing my first real-money trade on a new platform and feeling the tension between excitement and fear, I want the execution to feel noticeably faster than my old workflow so I can trust that this tool won't cost me bps when it matters."

|                    |                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Persona**        | S2 — Jake (Independent Trader)                                                                                                                                                                                                                                                                                                                                                                                      |
| **Stage**          | STAGE-S2-ONBOARD (Day 1-3)                                                                                                                                                                                                                                                                                                                                                                                          |
| **Job**            | JTBD-S2-01 — "Help me trade my thesis without getting wrecked by signals I can't see, so I can feel like a professional in control"                                                                                                                                                                                                                                                                                 |
| **Pain addressed** | P1 — Jake's current 7-tool workflow takes 15-20 minutes from signal identification to order placement; every minute adds leakage. E1 — First real-money trade on a new platform activates liquidation fear; any unexplained slippage or delay poisons trust permanently. P3 — Execution leakage (3-10bps slippage + 2-5bps spread) is invisible on most platforms; Jake needs proof that Arx doesn't make it worse. |
| **Priority**       | P0 — First trade execution quality determines whether Jake funds his account beyond the initial test deposit.                                                                                                                                                                                                                                                                                                       |

## Entry & Exit Conditions

|             |                                                                                                                                                                                                                                 |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Entry**   | Jake has funded his account (min $1K deposit), has a trade thesis (from EVAL stage signal match or independent analysis), and has navigated to C5-NEW Calculator via "Trade This Setup" CTA, TH Trade Hub, or `openTrade(sym)`. |
| **Success** | Order transitions from DRAFT to FILLED in under 5 seconds. Jake sees a fill confirmation with actual vs. expected entry price, fill latency, and slippage displayed transparently.                                              |
| **Failure** | Order is REJECTED (insufficient margin, API error) or fill takes >10 seconds. Fallback: show rejection reason in plain language with specific next step ("Add $X margin" or "Reduce size to Y"), never a raw error code.        |

## User Flow

1. Jake arrives at C5-NEW Calculator. The Regime Bar persists at top showing current regime (e.g., "TRENDING 78%"). If entering from signal card, direction is pre-selected (LONG) and the Lucid Signals Card in Step 1 shows the originating signal evidence.
2. **Step 1 — Direction:** Jake confirms LONG (pre-selected). The "WHAT THE MARKET IS SAYING" Lucid Signals Card shows: Smart Money 73% long, funding -0.003%, regime TRENDING. Jake scans it in 3 seconds — it confirms his thesis.
3. **Step 2 — Risk Amount:** "How much can you afford to lose?" Jake taps the [2%] quick-select pill (auto-computes $900 risk on his $45K account). The pill turns yellow (moderate risk). A Lucid evidence block below shows Kelly suggestion: "Kelly optimal: 2.4% — your 2% is conservative, good risk management."
4. **Step 3 — Liquidation Distance:** Auto-computed from leverage. Shows "23.4% away" with green emoji. Jake glances, confirms it's reasonable, moves on.
5. **Step 4 — Exit Plan:** TP and SL pre-filled from ATR defaults. TP shows "+6.1% (+$549)" and SL shows "-4.0% (-$360)". R:R badge shows "1.5:1". Jake adjusts TP upward using the iOS stepper (+/-) to "+8.0% (+$720)" — R:R updates to "2.0:1" live. Trailing stop checkbox is unchecked (default for first trade).
6. **Step 5 — Review Summary:** Position Size: "3.34 SOL ($625)". Leverage: "2x". Liquidation Price: "$112.40". Holding cost: "$0.84/day". Order type: "Market". Margin: "$312.50".
7. Jake taps **"Open LONG — $900 risk"** execution CTA. The button transitions to a progress spinner.
8. Order status transitions: DRAFT → SUBMITTED → FILLING → FILLED. Total elapsed time: <3 seconds. A confirmation card slides up from bottom with: fill price, slippage (actual vs. mid at submit time), fill latency, and a "Share This Trade" option.

## Information Architecture

### C5-NEW — Regime Bar (persistent top)

| Element      | Content        | Data Source              | Computation                  |
| ------------ | -------------- | ------------------------ | ---------------------------- |
| Regime label | "TRENDING"     | `RegimeState.label`      | C5.1 classification          |
| Confidence   | "78%"          | `RegimeState.confidence` | C5.2 formula                 |
| Color bar    | Green gradient | `RegimeState.color`      | Design system regime palette |

### C5-NEW Step 1 — Lucid Signals Card ("WHAT THE MARKET IS SAYING")

| Element                  | Content                                    | Data Source                            | Computation                                                                         |
| ------------------------ | ------------------------------------------ | -------------------------------------- | ----------------------------------------------------------------------------------- |
| Smart Money direction    | "Smart Money: 73% long"                    | `TradeIntent.smart_money_net_position` | C10.1 Performance Elite consensus percentage and direction                          |
| Leader positions summary | "3 of your watched leaders are long"       | `TradeIntent.leader_positions[]`       | Count of watched leaders with matching direction from `[ARX-FOLLOW]` + `[HL-STATE]` |
| Funding rate             | "Funding: -0.003% (longs paying)"          | `TradeIntent.funding_rate`             | Raw from `[HL-FUNDING]` endpoint; annotation from funding percentile C5-2-3         |
| Regime alignment         | "Regime: TRENDING (supports long entries)" | `TradeIntent.regime_context.state`     | C5.1 regime + directional alignment check                                           |
| Signal strength badge    | Cyan left border, `.lucid-hint` diamond    | Design system `4-2` Lucid styling      | Card rendered as `.card-glass` with `--color-lucid` left border per v10.3           |

### C5-NEW Step 2 — Risk Amount

| Element              | Content                               | Data Source                                          | Computation                                                                                                               |
| -------------------- | ------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| Risk % pills         | [1%] [2%] [5%]                        | —                                                    | Static UI; tap computes `equity * risk_pct` where equity from `[HL-STATE].marginSummary.accountValue`                     |
| Risk dollar amount   | "$900"                                | User selection + account equity                      | `$45,000 * 0.02 = $900`                                                                                                   |
| Pill color           | Green (<3%), Yellow (3-5%), Red (>5%) | Selected percentage                                  | Threshold-based color from design system                                                                                  |
| Kelly evidence block | "Kelly optimal: 2.4%"                 | `TradeIntent.leader_win_rate`, `leader_payoff_ratio` | C6.1 Kelly = `(win_rate * payoff_ratio - (1 - win_rate)) / payoff_ratio`; cold start uses leader stats from `TradeIntent` |

### C5-NEW Step 5 — Review Summary

| Element           | Content           | Data Source                       | Computation                                                                       |
| ----------------- | ----------------- | --------------------------------- | --------------------------------------------------------------------------------- |
| Position size     | "3.34 SOL ($625)" | `Order.size` + `Order.size_usd`   | `risk_budget / (entry - stop_loss)` for position sizing; USD = size \* mark price |
| Leverage          | "2x"              | `Order.leverage`                  | `size_usd / margin`; auto-computed from risk budget and liquidation distance      |
| Liquidation price | "$112.40"         | Computed                          | C6.2 liquidation = entry - (margin / size) for isolated long                      |
| Holding cost      | "$0.84/day"       | `[HL-FUNDING].funding_rate`       | `size_usd * abs(funding_rate) * 3` (3 funding periods/day)                        |
| Order type        | "Market"          | `Order.order_type`                | Default for first trade; selectable in Advanced Trade Settings                    |
| Margin required   | "$312.50"         | `Order.size_usd / Order.leverage` | `$625 / 2 = $312.50`                                                              |

### Execution Confirmation Card

| Element         | Content             | Data Source                            | Computation                                                    |
| --------------- | ------------------- | -------------------------------------- | -------------------------------------------------------------- |
| Fill price      | "$187.23"           | `Order.avg_fill_price`                 | Weighted average fill from Hyperliquid `[HL-FILLS]` response   |
| Expected price  | "$187.25"           | Mid price at `Order.submitted_at`      | Captured from `[HL-META].markPrice` at order submission moment |
| Slippage        | "-0.01% (-$0.02)"   | Computed                               | `(avg_fill_price - expected_price) / expected_price * 100`     |
| Fill latency    | "1.2s"              | `Order.filled_at - Order.submitted_at` | Timestamp delta formatted as seconds with 1 decimal            |
| Position status | "OPEN — monitoring" | `Position.status`                      | Transitioned from order fill to position tracking              |

### External References

-> See [Arx_4-1-1-3_Mobile_Trade.md](Arx_4-1-1-3_Mobile_Trade.md) §C5-NEW (Calculator Entry — 5-step guided flow)
-> See [Arx_4-1-1-7_Mobile_Data_Object_Model.md](Arx_4-1-1-7_Mobile_Data_Object_Model.md) §1.3 (Order), §1.4 (Order State Machine)
-> See [Arx_5-2-3_OnChain_Signal_Transformation_v7.md](Arx_5-2-3_OnChain_Signal_Transformation_v7.md) §C6.1 (Kelly Sizing)

## Acceptance Criteria

- [ ] AC-01: Given S2 Jake on C5-NEW with a valid TradeIntent (symbol + direction + regime_context populated), when the Calculator loads, then the Regime Bar shows current regime, direction is pre-selected, and the Lucid Signals Card renders with smart money %, funding rate, and regime alignment within 1 second.
- [ ] AC-02: Given Jake selects [2%] risk pill on a $45K account, when the pill is tapped, then risk dollar amount updates to "$900" within 100ms, pill color updates to yellow, and Kelly evidence block shows the optimal percentage from C6.1 computation.
- [ ] AC-03: Given Jake taps the "Open LONG" execution CTA with a valid Market order, when the order is submitted, then the order transitions DRAFT → SUBMITTED → FILLING → FILLED with total elapsed time <5 seconds, and a confirmation card slides up showing fill price, slippage, and latency.
- [ ] AC-04: Given slippage on Jake's fill exceeds 0.5% (10bps above expected), then the confirmation card highlights slippage in amber text and adds a Lucid hint: "Higher than usual slippage — consider limit orders for better fills."
- [ ] AC-05: Given the order is REJECTED (e.g., insufficient margin), then a plain-language error card appears within 500ms showing the reason ("You need $X more margin") and a specific action CTA ("Add Funds" or "Reduce Size"), never a raw API error code.
- [ ] AC-06: Given Jake completes his first trade, then a "First Trade Complete" celebration micro-animation plays (confetti-free, subtle glow on confirmation card) and the `first_trade_completed` analytics event fires.

## Edge Cases

| Condition                                           | Expected Behavior                                                                                                                                                      | Rationale                                                                                  |
| --------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Hyperliquid API timeout during order submission     | Show "Order submitted — waiting for confirmation" with a 30-second timeout. If no fill after 30s, show "Order may have been placed. Check positions." with link to C6. | API timeouts are ambiguous; never tell Jake the order failed when it might have succeeded. |
| Price moves >1% between Review and Execute          | Show a "Price has moved" interstitial: "Price moved from $187 to $189 (+1.1%). Continue at market?" with [Continue] and [Cancel].                                      | Protects against stale-price execution; S2 traders are slippage-sensitive.                 |
| Account equity is below minimum for selected risk % | Disable higher risk pills; show "Available: $X. Max risk at 2%: $Y" below pills.                                                                                       | Prevents impossible orders before they reach submission.                                   |
| First trade ever on platform (no historical data)   | Kelly evidence block shows "Not enough history for Kelly sizing. Using conservative 1% default." Cold start mode.                                                      | Honest about data limitations; doesn't fabricate confidence.                               |
| WebSocket drops during FILLING state                | Maintain "Confirming..." state; poll REST endpoint every 2 seconds for up to 30 seconds; show result when confirmed.                                                   | Fill confirmation matters more than real-time update; polling is acceptable fallback.      |

## Analytics Events

| Event                     | Trigger                                          | Properties                                                                                                                        | Purpose                                                                              |
| ------------------------- | ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `trade_calculator_opened` | C5-NEW renders with TradeIntent                  | `asset`, `direction`, `source`, `regime`, `has_signal_context`                                                                    | Measure trade intent funnel entry; segment by source (signal vs. manual)             |
| `risk_pill_selected`      | Jake taps a risk % pill                          | `asset`, `risk_pct`, `risk_usd`, `account_equity`, `kelly_optimal_pct`                                                            | Measure risk appetite vs. Kelly recommendation gap                                   |
| `first_trade_executed`    | Order reaches FILLED status for first time ever  | `asset`, `direction`, `size_usd`, `leverage`, `slippage_bps`, `fill_latency_ms`, `source`, `regime`, `order_type`                 | Core activation metric — first trade is the single most predictive retention event   |
| `fill_quality_displayed`  | Confirmation card renders with slippage data     | `slippage_bps`, `fill_latency_ms`, `expected_price`, `fill_price`, `order_type`                                                   | Measure execution quality perception; feeds into platform trust score                |
| `trade_abandoned`         | Jake navigates away from C5-NEW before executing | `asset`, `last_step_reached`, `time_on_calculator_ms`, `abandon_reason` (if detectable: price_moved, insufficient_margin, manual) | Identify friction points in the 5-step flow; optimize step where most users drop off |
| `order_rejected`          | Order transitions to REJECTED                    | `asset`, `reject_reason`, `size_usd`, `equity`, `margin_required`                                                                 | Measure rejection rate and causes; feeds into UX improvements for error prevention   |

---

# US-S2-FVAL-01

## Context

> "When I'm about to enter a trade and the regime bar turns red while Copilot suggests caution, I want to see exactly why the market conditions are unfavorable so I can skip the trade with confidence rather than FOMO — and then see that I was right to skip it."

|                    |                                                                                                                                                                                                                                                                                                                                                                     |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Persona**        | S2 — Jake (Independent Trader)                                                                                                                                                                                                                                                                                                                                      |
| **Stage**          | STAGE-S2-FIRST-VALUE (Day 3-14)                                                                                                                                                                                                                                                                                                                                     |
| **Job**            | JTBD-S2-01 — "Help me trade my thesis without getting wrecked by signals I can't see, so I can feel like a professional in control"                                                                                                                                                                                                                                 |
| **Pain addressed** | E2 — Under emotional stress (a setup looks tempting), Jake's cortisol impairs judgment; the regime bar is the external circuit breaker his prefrontal cortex needs. E3 — Without a verified process, Jake can't distinguish good skips from missed opportunities; the "saved trade" counter provides statistical evidence that caution has measurable dollar value. |
| **Priority**       | P0 — This is the moment Jake trusts Arx as a risk partner, not just a signal tool. It transforms the product from "faster execution" to "better decisions."                                                                                                                                                                                                         |

## Entry & Exit Conditions

|             |                                                                                                                                                                                                                                              |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Entry**   | Jake is on R0 Feed or C3 Asset Detail, sees a potential trade setup, and the Regime Bar is showing CRISIS, TRANSITION, or HIGH_VOL_TRENDING with confidence >60%. Alternatively, Jake opens C5-NEW Calculator and the Regime Gate activates. |
| **Success** | Jake skips the trade based on regime + Copilot caution. Within 30 minutes, the asset moves against the direction Jake would have traded. Arx surfaces a "Saved Trade" notification showing the avoided loss.                                 |
| **Failure** | Jake ignores the regime warning and trades anyway. Fallback: Post-trade journal entry attributes the loss to regime misalignment ("45% of this loss was regime-driven") per P&L attribution. No "I told you so" — just data.                 |

## User Flow

1. Jake is on C3 Asset Detail for ETH-PERP. He sees a setup he likes (price at support, bounced twice). His instinct says "long."
2. The **Regime Bar** at the top shows **"TRANSITION 67%"** in amber. The bar pulses subtly once to draw attention (not aggressively — S2 traders hate being patronized).
3. Jake taps the Regime Bar. A bottom sheet expands showing `RegimeState.explanation_long`: "The weather is changing but you don't know to what yet. The most dangerous regime for overconfident traders." Below: ADX = 18 (below 25 threshold), BB width narrowing, Hurst = 0.48 (near random walk).
4. Jake closes the bottom sheet and scrolls to the signal area. A **Lucid Caution Card** is displayed (amber left border, `.lucid-hint` diamond prefix) with: "Regime doesn't support directional entries. 3 of 5 similar transitions in the last 30 days reversed within 2 hours. Consider waiting for regime clarity."
5. [Decision point:] Jake decides to **skip the trade**. He taps [Skip — Save This Analysis] button on the Lucid Caution Card. The system records: asset, direction Jake would have taken, timestamp, regime state, and the price at decision time.
6. **22 minutes later:** ETH-PERP drops 3.8% (a regime-confirming crash). Arx sends a push notification: "Saved Trade: Your ETH long skip saved ~$1,710. Regime bar called it."
7. Jake opens the notification. The **Saved Trade Detail** screen shows: entry price he would have used, current price, the loss he avoided (computed from his typical position size), and the regime bar state at decision time. A running **"Saved Trade Counter"** in his profile increments: "Trades skipped on regime caution: 4 | Total avoided loss: $3,200."

## Information Architecture

### C3 / R0 — Regime Bar (amber/red state)

| Element         | Content                             | Data Source              | Computation                                                                                  |
| --------------- | ----------------------------------- | ------------------------ | -------------------------------------------------------------------------------------------- |
| Regime label    | "TRANSITION"                        | `RegimeState.label`      | C5.1 classification: ADX <25, BB width in mid-range, Hurst near 0.50                         |
| Confidence      | "67%"                               | `RegimeState.confidence` | C5.2 formula                                                                                 |
| Color bar       | Amber (`--color-regime-transition`) | `RegimeState.color`      | Design system v5.7 regime palette; TRANSITION = amber, CRISIS = red                          |
| Pulse animation | Single subtle pulse on load         | —                        | CSS animation, 1 pulse, 600ms, triggered when regime is TRANSITION or CRISIS (attention cue) |
| Tap target      | Entire bar                          | —                        | Opens regime detail bottom sheet                                                             |

### Regime Detail Bottom Sheet (on bar tap)

| Element            | Content                                                          | Data Source                             | Computation                                                                         |
| ------------------ | ---------------------------------------------------------------- | --------------------------------------- | ----------------------------------------------------------------------------------- |
| Headline           | "TRANSITION — Market is Changing"                                | `RegimeState.label`                     | Mapped from enum to user-facing headline                                            |
| Explanation        | "The weather is changing but you don't know to what yet..."      | `RegimeState.explanation_long`          | Pre-authored per regime type in data model §2.1                                     |
| ADX indicator      | "ADX: 18 (below 25 directional threshold)"                       | `RegimeState.adx_value`                 | Raw ADX-14 value; annotation based on 25 threshold                                  |
| BB width indicator | "Bollinger Width: narrowing (compression building)"              | `RegimeState.bollinger_width`           | Raw BB width; trend annotation (narrowing/widening/stable)                          |
| Hurst indicator    | "Hurst: 0.48 (near random walk — no trend detectable)"           | `RegimeState.hurst_exponent`            | Raw Hurst; annotation: <0.45 = mean-reverting, 0.45-0.55 = random, >0.55 = trending |
| Strategy guidance  | "What works: Wait for clarity. What fails: Directional entries." | `RegimeState.what_works`, `.what_fails` | Pre-authored per regime type per Lucid spec (4-1-1-6 §7)                            |

### Lucid Caution Card (below chart / in feed)

| Element            | Content                                              | Data Source                              | Computation                                                                                  |
| ------------------ | ---------------------------------------------------- | ---------------------------------------- | -------------------------------------------------------------------------------------------- |
| Diamond prefix     | "◆ Regime Caution"                                   | Design system `.lucid-hint` pattern      | Static Lucid styling                                                                         |
| Left border        | 2px amber (`--color-regime-transition`)              | Regime color                             | Matches regime bar color for visual continuity                                               |
| Caution message    | "Regime doesn't support directional entries."        | Generated from `RegimeState.regime`      | Template: "{regime} regime doesn't support {strategy_type} entries"                          |
| Historical context | "3 of 5 similar transitions reversed within 2h"      | `[ARX-REGIME].regime_transition` history | Count transitions of same type in last 30 days; compute reversal rate within 2h window       |
| Skip CTA           | [Skip — Save This Analysis]                          | —                                        | Records saved trade event: `{ asset, intended_direction, price_at_skip, regime, timestamp }` |
| Trade anyway link  | "Trade anyway (not recommended)" — muted, small text | —                                        | Routes to C5-NEW with regime warning banner persisted; no blocking gate for S2               |

### Saved Trade Notification & Detail

| Element               | Content                                    | Data Source                             | Computation                                                                                   |
| --------------------- | ------------------------------------------ | --------------------------------------- | --------------------------------------------------------------------------------------------- |
| Push notification     | "Saved Trade: ETH long skip saved ~$1,710" | Saved trade record + current price      | `typical_position_size * abs(price_at_skip - current_price) / price_at_skip`                  |
| Entry price (skipped) | "$3,245.00"                                | `saved_trade.price_at_skip`             | Mid price at moment Jake tapped [Skip]                                                        |
| Current price         | "$3,121.70"                                | `[HL-META].markPrice`                   | Live mark price at notification generation time                                               |
| Avoided loss          | "~$1,710"                                  | Computed                                | `saved_trade.typical_size_usd * (entry - current) / entry` for longs; sign-flipped for shorts |
| Regime at decision    | "TRANSITION 67%"                           | `saved_trade.regime_state`              | Snapshot of `RegimeState` at skip moment                                                      |
| Saved trade counter   | "Trades skipped on regime caution: 4"      | `[ARX-PREFS].saved_trade_count`         | Increment on each skip; persisted in user profile                                             |
| Total avoided loss    | "$3,200"                                   | `[ARX-PREFS].saved_trade_total_avoided` | Running sum of all avoided losses; only counts skips where market confirmed the caution       |

### External References

-> See [Arx_4-1-1-7_Mobile_Data_Object_Model.md](Arx_4-1-1-7_Mobile_Data_Object_Model.md) §2.1 (RegimeState fields, explanation strings)
-> See [Arx_4-1-1-6_Mobile_Lucid.md](Arx_4-1-1-6_Mobile_Lucid.md) §7 (Regime bottom sheet content, `.lucid-hint` styling)
-> See [Arx_5-2-3_OnChain_Signal_Transformation_v7.md](Arx_5-2-3_OnChain_Signal_Transformation_v7.md) §C5.1-C5.2 (Regime classification and confidence)

## Acceptance Criteria

- [ ] AC-01: Given S2 Jake on C3 Asset Detail where `RegimeState.regime` is TRANSITION or CRISIS with confidence >60%, when the page loads, then the Regime Bar renders in amber/red with a single subtle pulse animation and the Lucid Caution Card appears below the chart.
- [ ] AC-02: Given Jake taps the Regime Bar, when the bottom sheet opens, then it displays `explanation_long`, ADX value with threshold annotation, BB width with trend annotation, Hurst with interpretation, and strategy guidance — all within 300ms of tap.
- [ ] AC-03: Given Jake taps [Skip — Save This Analysis] on the Lucid Caution Card, then the system records `{ asset, intended_direction, price_at_skip, regime_state, timestamp }` and shows a confirmation toast: "Skip saved. We'll track what happens."
- [ ] AC-04: Given a saved trade exists where the asset moved >2% against Jake's intended direction within 60 minutes, then a push notification is sent within 5 minutes of the threshold breach showing the avoided loss amount and regime state at decision time.
- [ ] AC-05: Given Jake taps "Trade anyway," then C5-NEW opens with a persistent amber banner at top: "Regime caution active — TRANSITION 67%." The banner does not block execution but remains visible through all 5 steps.
- [ ] AC-06: Given the Saved Trade Counter has 3+ entries, then the counter is visible on Jake's profile summary and in the Trade Hub (TH) as a subtle badge: "4 trades saved by regime caution ($3.2K avoided)."

## Edge Cases

| Condition                                              | Expected Behavior                                                                                                            | Rationale                                                                                       |
| ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Asset moves IN Jake's intended direction after skip    | Do NOT send a "you missed out" notification. The counter only increments on confirmed saves (market moved against).          | Rubbing missed profits in Jake's face destroys trust in the caution system. Silence is correct. |
| Regime transitions to TRENDING within 10 minutes       | Send a neutral update: "ETH regime changed to TRENDING. Setup may be valid now." with CTA [Re-evaluate].                     | Fast regime changes happen; the system should adapt and re-invite, not be rigid.                |
| Jake skips 5+ trades in a row on regime caution        | After 5th skip, show Lucid insight: "You've been cautious — 4 of 5 skips were confirmed. Your discipline is your edge."      | Reinforces the behavior with data; prevents "am I being too cautious?" doubt spiral.            |
| Saved trade typical_size_usd has no history (new user) | Use position from last completed trade, or if none, use `equity * 0.02` (2% default risk) as proxy.                          | Must have a reasonable estimate; 2% of equity is conservative and defensible.                   |
| Push notifications are disabled                        | Show the saved trade detail as an in-app card on next R0 Feed visit: "While you were away: 1 saved trade confirmed."         | Critical moment shouldn't be lost to notification permissions; in-app fallback is essential.    |
| Regime is RANGE_BOUND (not TRANSITION or CRISIS)       | Show regime bar but do NOT trigger Lucid Caution Card. Range-bound supports mean reversion entries — caution is unwarranted. | S2 traders would distrust a system that cries wolf on non-dangerous regimes.                    |

## Analytics Events

| Event                          | Trigger                                                  | Properties                                                                                                   | Purpose                                                                                 |
| ------------------------------ | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| `regime_bar_viewed_caution`    | Regime Bar renders in amber/red on C3 or R0              | `asset`, `regime`, `confidence`, `session_trade_count`                                                       | Measure how often S2 users encounter cautionary regimes                                 |
| `regime_detail_opened`         | Jake taps Regime Bar to open bottom sheet                | `asset`, `regime`, `time_on_bar_before_tap_ms`                                                               | Engagement depth with regime education; faster tap = more regime-literate user          |
| `trade_skipped_regime`         | Jake taps [Skip — Save This Analysis]                    | `asset`, `intended_direction`, `regime`, `confidence`, `price_at_skip`, `session_trade_count`                | Core behavioral metric — regime-driven skip rate predicts long-term retention           |
| `trade_despite_caution`        | Jake taps "Trade anyway" on Lucid Caution Card           | `asset`, `intended_direction`, `regime`, `confidence`, `price_at_trade`                                      | Measure override rate; high override = regime education needs improvement               |
| `saved_trade_confirmed`        | Asset moves >2% against intended direction within 60 min | `asset`, `intended_direction`, `avoided_loss_usd`, `price_delta_pct`, `regime_at_skip`, `minutes_to_confirm` | Measure regime bar accuracy; feeds into trust score and retention prediction            |
| `saved_trade_notification_tap` | Jake opens the saved trade push notification             | `asset`, `avoided_loss_usd`, `time_since_skip_min`, `notification_delay_min`                                 | Notification engagement — confirms the re-engagement loop is working                    |
| `saved_trade_counter_viewed`   | Jake views the cumulative counter on profile or TH       | `total_skips`, `confirmed_skips`, `total_avoided_usd`, `counter_location` (profile or trade_hub)             | Measure how often Jake checks his discipline stats; high views = strong habit formation |

---

# END OF ARX_3-2_PRD v1.0

**Document Status**: APPROVED FOR BUILD
**Next Review**: 2026-03-08 (C1 end)
**Stakeholders**: PM, CEO, CTO, Design Lead, Engineering Lead
**Questions / Feedback**: Arx Slack #product-requirements
