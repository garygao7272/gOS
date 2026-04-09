# Research: Design System + AI Tool Pipeline & Simulation Expansion

> Date: 2026-04-06
> Sources: 4 parallel research agents (Figma MCP workflow, design leaders 2026, build card optimization, simulation catalog)
> Promote to: specs/Arx_4-2 amendments, specs/Arx_3-6 simulation catalog, /design command updates

---

## Q1: How to Get Jony Ive-Level Output from AI Design Tools

### The Core Insight

**The bottleneck is not the tools — it's what we feed them.** Figma MCP's `figma-generate-design` assembles from existing design system assets. If the Figma file has no variable collections and no published components, the tool has nothing to compose. AIDesigner reads `.aidesigner/DESIGN.md` automatically. If that file is thin or missing, output is generic.

### Three Actions That Move the Needle Most

**1. Build the Figma Foundation (do once, enables everything)**

```
Phase 1: use_figma → Create Variable Collections
  - "Arx Colors" (Dark mode): Stone, Water, Sky, Surfaces, Text, Borders, Semantic, Regime
  - "Arx Spacing": 4/8/12/16/24/32/48px
  - "Arx Radii": 8/12/16/999px

Phase 2: use_figma → Build Core Components (bound to variables)
  - Button (Primary/Secondary/Data), Glass Card, Badge, Tab Bar, Regime Bar
  - Status Dot, Filter Chip, Progress Bar, Wallet Badge

Phase 3: Code Connect → Link Figma components to React Native code

Phase 4: figma-generate-design → Compose screens from components
```

Without Phase 1-2, `figma-generate-design` has nothing to assemble. This is the blocker.

**2. Create `.aidesigner/DESIGN.md` (copy of DESIGN.md)**

AIDesigner auto-injects this file into every `generate_design` call. Currently missing — AIDesigner falls back to generic Tailwind defaults. Fix: symlink or copy `DESIGN.md` to `.aidesigner/DESIGN.md`.

**3. Add `## Feel` Section to Every Build Card**

The single biggest gap in current build cards. AIDesigner responds primarily to emotional descriptors. Figma MCP doesn't use it but humans reviewing output need it. Format:

```markdown
## Feel
- **Target:** Morning briefing — calm, oriented, no urgency unless crisis
- **Motion:** Regime bar → portfolio header → cards stagger in (50ms each)
- **Density:** S7 medium-low, S2 medium-high
- **Reference:** "Like Apple News morning digest but for your trading portfolio"
- **Temperature:** T0 80% (surfaces, text) | T1 15% (regime, labels) | T2 4% (P&L numbers) | T3 1% (Execute button)
```

### Build Card v2 Template Changes

| Current Section | Change | Why |
|----------------|--------|-----|
| `## Layout` (ASCII) | Add auto-layout annotations: `column`, `fill-w`, `gap=12px` | Maps directly to Figma auto-layout properties |
| (missing) | Add `## Feel` section | AIDesigner primary input; taste enforcement |
| (missing) | Add `## Motion Choreography` table | Specifies entrance order, prevents "everything appears at once" |
| `## States` | Add skeleton shape specs per state | "Shimmer skeleton" means nothing without dimensions |
| `## Visual Spec` | Add haptic feedback map | Trigger + iOS haptic type per interaction |
| (missing) | Add `## Taste Baseline` | When litmus tests last passed + feel scores |

### Who Reads What

| Tool | Reads | Ignores |
|------|-------|---------|
| AIDesigner | `## Feel` + `## Layout` structure + DESIGN.md | Exact px values, fixture data |
| Figma MCP | `## Layout` annotations + `## Visual Spec` + DESIGN.md tokens | Feel targets, motion narrative |
| Stitch MCP | `## Feel` + `## Layout` + `## States` + DESIGN.md | Figma-specific annotations |
| `/build` | Everything — full card is the build spec | Nothing |

### Design Leaders to Study (2026)

| Leader | Key Principle for Arx |
|--------|----------------------|
| **Karri Saarinen** (Linear) | "Design is search, not production." Explore possibility space before converging. Quality first. |
| **Dylan Field** (Figma) | "Craft and POV are the differentiator." AI builds anything — taste decides WHAT to build. |
| **shadcn** (shadcn/ui) | Registry pattern: structured JSON that AI agents consume. Arx should expose components this way. |
| **Rune Madsen** (Design Systems International) | "Meta-design" — design the system that generates designs, not the designs themselves. |
| **Rasmus Andersson** (Inter) | Designers who implement, not just spec. Reject silos between design and engineering. |

### Pipeline Recommendation for Arx

**Pipeline C: Spec → Code → Visual Verification → Iterate**

1. Build card spec (our `specs/Arx_4-1-1-X`) defines intent
2. AI generates code from spec + DESIGN.md tokens
3. Screenshot at 390x844 → compare to feel targets
4. Iterate until litmus tests pass

This is faster than Figma roundtrips and leverages our existing spec quality. Use Figma MCP for the component library and design system documentation, not for per-screen generation.

---

## Q2: Complete Simulation Catalog for `/simulate`

### Current: 2 sub-commands

| Sub-command | What |
|-------------|------|
| `market` | MiroFish Monte Carlo + regime detection + backtesting |
| `scenario` | What-if projection + adversarial analysis |

### Proposed: 6 sub-commands (current 2 + 4 new)

| Sub-command | Question It Answers | Simulations Inside |
|-------------|--------------------|--------------------|
| `market` | What's the market doing? | Regime detection, Monte Carlo, backtesting (existing) |
| `scenario` | What if X happens? | What-if projection, adversarial analysis (existing) |
| **`risk`** | How much can I lose? | Portfolio stress, liquidation cascade, max drawdown, herding risk |
| **`copy`** | Will copying this leader work? | Copy P&L projection, recommendation engine, graduation readiness |
| **`signal`** | Are our signals accurate? | Signal quality validation, Lucid accuracy, agent strategy backtest, regime transition probability |
| **`business`** | Will the business work? | Revenue Monte Carlo, referral virality, marketplace balance, onboarding funnel, persona journey |

### Tier 1 Simulations (14 — HIGH value, build as named sub-types)

**Risk (user-facing safety)**
- `portfolio-stress` — Replay historical crashes against user's current portfolio
- `liquidation-cascade` — Model self-reinforcing liquidation loops on Hyperliquid
- `max-drawdown` — Extreme value theory worst-case drawdown estimation

**Copy Trading**
- `copy-pnl` — Project copier returns accounting for slippage, fees, timing delay
- `recommendation-engine` — Backtest the leader-matching algorithm
- `onboarding-funnel` — Simulate drop-off rates at each onboarding step

**Signal/AI**
- `signal-quality` — Walk-forward validation of P1-P5 signal layers
- `copilot-accuracy` — Would Lucid's recommendations have made money?
- `agent-strategy` — Backtest AI trading agent strategies pre-launch
- `regime-transition` — Probability matrix for regime changes at 1d/7d/30d

**Business**
- `revenue-projection` — Monte Carlo with 10K runs (replaces 3-scenario model)
- `referral-virality` — K-factor and viral coefficient of 30/5/2 referral program
- `marketplace-balance` — S2:S7 ratio stability over 24 months
- `persona-journey` — Synthetic persona walkthrough of built screens

### Tier 2 (12 — MEDIUM value, build as scenario templates)

| Simulation | Category | Notes |
|-----------|----------|-------|
| `fee-impact` | Financial | Tier comparison, subscription break-even |
| `capital-efficiency` | Financial | Multi-leader portfolio optimization |
| `funding-arb` | Market | Carry trade opportunity scanner |
| `whale-impact` | Market | P3 participant signal operationalization |
| `herding-risk` | Risk | Crowded exit detection |
| `protocol-risk` | Risk | Hyperliquid dependency assessment |
| `regulatory-scenario` | Risk | Jurisdiction impact modeling |
| `cac-ltv` | Business | Per-cohort unit economics |
| `retention-curve` | User | D1/D7/D30 curve modeling |
| `graduation` | User | Copy-to-independence readiness |
| `competitor-response` | Competitive | Quarterly war-gaming |
| `market-capture` | Competitive | Hyperliquid volume share |

### Tier 3 (2 — LOW value, nice to have)

- `correlation-breakdown` — Niche relative-value trading
- `cognitive-load` — Design-time Sweller framework scoring

---

## Recommended Next Steps

### Design System (do in order)

1. **Now:** Copy `DESIGN.md` to `.aidesigner/DESIGN.md` (enables AIDesigner auto-injection)
2. **Next session:** Build Figma variable collections via `use_figma` (Phase 1-2 above)
3. **Next session:** Add `## Feel` section to top 3 build cards (C1-R0, C2, C3) as template
4. **Later:** Set up Code Connect for bidirectional Figma-code sync
5. **Later:** Create shadcn registry exposing Arx components for v0/AI consumption

### Simulation (do in order)

1. **Now:** Add the 4 new sub-commands to `/simulate` command file (routing only)
2. **Next sprint:** Implement `risk` (portfolio-stress + liquidation-cascade) — highest user value
3. **Next sprint:** Implement `copy` (copy-pnl) — validates the core copy trading value prop
4. **Later:** Implement `signal` (signal-quality) — validates the intelligence moat
5. **Later:** Implement `business` (revenue-projection) — upgrades the 3-scenario model
