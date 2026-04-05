# Arx Design Taste & Feel

**Artifact ID:** Arx_4-3
**Title:** Design Taste — Judgment Framework for Visual Decisions
**Last Updated:** 2026-03-29
**Status:** Active
**Dependencies:** `Arx_4-2_Design_System.md` (tokens), `Arx_2-1_Problem_Space_and_Audience.md` (personas)

<!-- AGENT: This spec defines HOW to make visual decisions when tokens don't dictate.
     Key files: specs/Arx_4-2_Design_System.md (tokens), apps/web-prototype/SOUL.md (feel layer)
     Dependencies: specs/Arx_2-1_Problem_Space_and_Audience.md (S7/S2 persona definitions)
     Test: Run 5 Premium Litmus Tests on every screen before ship.
-->

> **Reading order:** Read this FIRST, then `Arx_4-2_Design_System.md`, then screen specs.
>
> **Relationship:** 4-2 answers "what are our tokens." This file answers "how do we decide when tokens don't tell us." 4-2 is the material palette. This is the eye that picks the brush.

---

## 1. The Bar

These apps represent the MINIMUM quality floor. Arx must beat every one of them.

AI+human co-creation means Arx can ship taste that no traditional team can achieve at this speed. Every pixel is reviewed. Every state is specified. Every interaction is choreographed. This is not "good enough for a startup" — this is "best-in-class, period."

The apps below are good references, not ceilings. They were built by teams without AI co-creation. Arx has that advantage. Use it.

### S7 Floor (Capital Allocators — 95% of users)

| App           | What They Do Well                                                     | Where Arx Must Surpass                                                                                        |
| ------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **Robinhood** | Clean onboarding, friendly copy, approachable data visualization      | Deeper intelligence without added complexity — Robinhood simplifies by removing; Arx simplifies by organizing |
| **eToro**     | Social proof, copy trading UX, trust signals, community layer         | Real signal quality over popularity metrics — eToro shows who's popular; Arx shows who's actually good        |
| **Bitget**    | Copy trading mechanics, mobile-native execution, feature completeness | Taste. Bitget is functional but not beautiful. Every Arx screen should make Bitget feel utilitarian           |
| **Phantom**   | Wallet UX, transaction clarity, dark mode aesthetics, simplicity      | Broader scope without losing Phantom's clarity — full trading intelligence in Phantom's visual register       |

### S2 Floor (Leaders — 5%)

| App         | What They Do Well                                                   | Where Arx Must Surpass                                                                                          |
| ----------- | ------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| **Moomoo**  | Information density, chart tools, depth of data, institutional feel | Signal layer — Moomoo gives you tools; Arx gives you intelligence. Not just data, but what the data means       |
| **Webull**  | Pro features accessible to intermediate traders, clean dark mode    | AI-augmented decisions — Webull shows raw data; Arx shows data + regime context + what smart money does with it |
| **Binance** | Completeness, everything-available, the Swiss Army knife            | Curation. Less is more when it's the RIGHT less. Binance gives you 200 options; Arx gives you the 3 that matter |

### Tier 2: Design Excellence (not competitors — taste calibration)

These apps are not trading products, but they represent the actual quality bar. Trading apps set a low bar; these set the real one.

| App | What to Study | Specific Screens to Reference |
|-----|--------------|------------------------------|
| **Linear** | Opinionated software — density without noise, every pixel intentional | Issue detail, project views, keyboard-first UX |
| **Mercury** | Financial data that feels trustworthy and premium | Account dashboard, transaction detail, statement design |
| **Stripe Dashboard** | Information hierarchy at scale, table design | Payments list, customer detail panel, analytics charts |
| **Apple Stocks** | iOS-native financial data — sparklines, ticker formatting, portfolio summary | Watchlist, stock detail, My Symbols |
| **Things 3** | "Software as craft" — every animation, transition, and empty state designed | Task detail, today view, project list |
| **Airbnb** | Discovery UX — curated list as boutique, not catalog | Search results, listing detail, booking flow |
| **Apple Weather** | Data visualization done beautifully — charts and temporal data feel alive | Hourly forecast, 10-day view, precipitation map |

### Tier 3: Pattern References (steal specific patterns, not whole apps)

| App | Pattern to Steal | Apply To |
|-----|-----------------|----------|
| **Revolut** | Complex financial features accessible to non-experts | Trade entry flow (C5-NEW) |
| **Arc Browser** | "Reveal complexity on demand" — power-user tools that feel approachable | S2/S7 adaptive density |
| **Telegram** | Animation system — speed and polish coexisting at scale | Feed card transitions, message-style activity feed |
| **Notion** | Composable blocks — flexible information architecture | Lucid copilot interaction (G1) |

> **How to use tiers:** Tier 1 apps are the floor — beat them on every screen. Tier 2 apps are the ceiling — match their craft quality. Tier 3 apps provide specific patterns to adopt. Every build card's `## Reference Screenshots` should cite at least one app from each relevant tier.

### The Arx Design Thesis

Arx sits at an intersection no existing app occupies:

```
                    HIGH INTELLIGENCE
                          |
              Arx --------+
             /             |
    Robinhood              |           Moomoo
    (simple,               |           (dense,
     low signal)           |            high signal)
                           |
         LOW DENSITY ------+------ HIGH DENSITY
                           |
    Phantom                |           Binance
    (simple,               |           (dense,
     low signal)           |            low signal)
                           |
                    LOW INTELLIGENCE
```

Arx occupies the upper quadrant — high intelligence, adaptive density. S7 sees the app at low density (Robinhood register). S2 sees it at high density (Moomoo register). Same data engine, two presentation modes.

---

## 2. Premium Litmus Tests

Five binary pass/fail checks. Run on EVERY screen before it ships. If any test fails, the screen is not ready.

| #   | Test                 | Pass                                                                             | Fail                                                                              |
| --- | -------------------- | -------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| 1   | **$10M Test**        | "This looks like it was built by a well-funded, design-obsessed team"            | "This looks like a hackathon project with a nice color scheme"                    |
| 2   | **Screenshot Test**  | "An S7 user would screenshot this to show a friend: 'look at this app I use'"    | "Functional but not share-worthy — nobody screenshots their bank app"             |
| 3   | **Ive's Care Test**  | "Every pixel is intentional — nothing is filling space, nothing is default"      | "Some elements are there because the template had them, not because they earn it" |
| 4   | **Empty State Test** | "Strip all data — the skeleton still looks premium, the empty state is designed" | "Without data, it's grey boxes with placeholder text"                             |
| 5   | **3-Second Test**    | "The hierarchy is clear in 3 seconds without reading any text"                   | "You have to read labels to understand what matters on this screen"               |

### How to Apply

After completing a screen design or spec:

1. Read each test aloud
2. Answer honestly — if you hesitate, it's a fail
3. For each fail, identify the specific element or decision that causes it
4. Fix before proceeding

---

## 3. Feel Targets by Screen Type

Every screen type has a target feel. The feel is not decoration — it's the emotional architecture that makes the functional spec work for the human holding the phone.

| Screen Type            | Target Feel                                                    | Motion Character                                                                            | Density                                                                   | Must Beat                              |
| ---------------------- | -------------------------------------------------------------- | ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | -------------------------------------- |
| **Feed (R0)**          | Morning briefing — calm, oriented, no urgency unless crisis    | Gentle cards entering from below, staggered 50ms. Crisis cards snap in without easing.      | Medium-low for S7, medium-high for S2                                     | Apple News + Robinhood notifications   |
| **Discovery (D1/D1b)** | Curated boutique — few choices, each compelling, each earned   | Cards with presence — they don't scroll by, they arrive. Slight parallax on scroll.         | Low for S7 (4-6 featured traders), medium for S2 (full list with filters) | Airbnb search + Phantom discover       |
| **Profile (D2)**       | Investor factsheet — credible, earned authority, one clear CTA | Subtle data count-up on load. Equity curve draws itself. Stats don't appear — they reveal.  | Medium                                                                    | Mercury account + Bloomberg profile    |
| **Copy Setup (D3)**    | Commitment moment — deliberate, clear, no ambiguity            | Each step locks in with a satisfying haptic. Progress bar is prominent. No rush.            | Low (one decision per step)                                               | Robinhood first trade flow             |
| **Trade Execution**    | Cockpit — focused, zero distraction, one action dominates      | Precise, mechanical, responsive. The Execute button is the only warm element on screen.     | High (intentional — S2 needs everything visible)                          | Bloomberg order ticket + Binance trade |
| **Manage**             | Control room — everything accessible, nothing noisy            | Functional transitions. No animation waste — every motion serves navigation clarity.        | Medium-high                                                               | iOS Settings + Revolut account         |
| **Onboarding**         | First handshake — warm, confident, fast                        | Progressive reveal. Each screen has one idea. Reward moment at completion.                  | Very low (one thing per screen)                                           | Phantom setup + Robinhood onboarding   |
| **Home**               | Command center — your world at a glance, personalized, alive   | Cards breathe with live data. Regime bar pulses subtly. The screen feels ALIVE, not static. | Adaptive (S7 sees 4 cards, S2 sees 8)                                     | Robinhood home + Moomoo dashboard      |

---

## 4. Information Density Spectrum

Arx serves two personas with opposite density needs. This is the central design tension.

### S7 (Followers — 95%): LOW Density

- Progressive disclosure. One CTA visible per context.
- **Cards, not tables.** Headlines, not datasets.
- Every piece of data has a label that explains WHY it matters, not just what it is.
- "Show me what to do" not "show me everything."
- Jargon budget: zero. If a term requires C3+ trading knowledge, rewrite it or add inline context.
- Maximum items in any list before "See all": **4-6**.

### S2 (Leaders — 5%): HIGH Density

- Everything visible. Keyboard shortcuts. Power-user affordances.
- **Tables, not cards.** Data, not prose.
- Respect their expertise — no tooltips on basic concepts (what leverage is, what funding rate means).
- "Show me everything" — they know what they're looking for.
- Jargon is welcomed — it's their native language.
- Maximum items in any list: **unlimited with virtualized scroll**.

### Adaptive Rule

When S7 and S2 share a screen, **default to S7 density**. S2 complexity lives behind:

- Taps (expand to see more)
- Toggles (switch to "Pro" or "Advanced" view)
- Dedicated S2-only screens (accessed from same entry point, branched by user type)

**Never sacrifice S7 clarity for S2 convenience.** S2 users can find a hidden feature. S7 users will leave if overwhelmed.

---

## 5. Scroll Rhythm & Visual Weight

### Scroll Rhythm Rules

- **Never show more than 4 same-height elements in sequence.** Break with: a different card type, a section header, breathing space (24px+), or a visual anchor.
- **Every 5th viewport-height of scroll must have a VISUAL ANCHOR** — something the eye rests on. A section header, a different-format card, a stat callout, a transition to a new section.
- **The FIRST element visible on screen load sets the emotional tone.** If it's a loading skeleton, that skeleton must look premium. If it's a card, it must be the most important card.
- **Scroll velocity matching:** Dense sections (tables, lists) should be preceded by sparse sections (headers, stats) so the user's scroll speed naturally adjusts.
- **End-of-list design:** Never end with an abrupt cutoff. Use a fade, a "You're caught up" message, or a gentle transition to the next section.

### Optical Weight Hierarchy

- **HEAVIEST element** = the one thing the user came here for (CTA, primary metric, key insight).
- The heaviest element should be identifiable WITHOUT reading — through size, color, position, or elevation alone.
- **If two elements compete for weight, one must yield.** No draws. The hierarchy must be unambiguous.
- Weight is created by: size > color saturation > elevation > position > animation. In that order.
- The Execute Trade button is ALWAYS the heaviest element on any screen where it appears.

### Negative Space Rules

- Negative space is DESIGNED, not leftover. If you can't explain why space exists, the layout isn't finished.
- The ratio of content to space should feel like a premium magazine, not a spreadsheet and not a SaaS dashboard.
- **Between cards within a group:** 12px (`--space-sm`)
- **Between card groups:** 24px (`--space-lg`) minimum
- **Between sections:** 48px (`--space-2xl`) + a visual separator (border-bottom or background-color shift)
- **Screen edge padding:** 16px (`--space-md`) on mobile — never 0, never 8px (too tight on 390px viewport).

---

## 6. Anti-Patterns

### Never Do (Arx-Specific)

| Anti-Pattern                                                         | Why It Fails                                                           | What To Do Instead                                                                                   |
| -------------------------------------------------------------------- | ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Generic card grids (every card same height/width/layout)             | Looks like a template, not a product                                   | Vary card heights based on content importance and altitude                                           |
| Uniform information density (no hierarchy within a list)             | The eye has nowhere to rest, everything feels equally (un)important    | Create visual rhythm — some items are featured, others are compact                                   |
| Copy that reads like documentation ("This feature allows you to...") | Cold, impersonal, reads like a manual                                  | Second person, present tense: "Your traders moved" not "The system shows user's traders"             |
| Purple gradients                                                     | Stone and Water never blend — this is the One Decision                 | Solid stone OR water. Never both on the same element.                                                |
| Stock photography or generic illustrations                           | Instantly signals "template product"                                   | Use data visualization, iconography, or abstract geometric patterns                                  |
| Glassmorphism for decoration                                         | Glass is a functional material (overlays, sheets), not wallpaper       | Glass only for: modals, bottom sheets, floating overlays, status bar                                 |
| Modal-heavy flows                                                    | Modals interrupt; bottom sheets extend                                 | Bottom sheets for selection, full-screen for forms, modals only for destructive confirmation         |
| Loading spinners without context                                     | "Loading..." tells the user nothing about progress or what's coming    | Skeleton screens shaped like the content they'll contain + contextual label ("Loading your feed...") |
| Empty states with just an icon and "No data"                         | Missed opportunity — empty state is often the FIRST screen a user sees | Every empty state is a designed screen with: illustration, explanation, CTA, and personality         |
| Competing CTAs                                                       | Two buttons of equal weight = decision paralysis                       | One primary CTA (stone), all others are ghost/text buttons                                           |

### Always Do

- **Vary card heights** based on content importance and altitude level
- **Use Stone/Water duality** to create clear visual domains — actions are stone, data is water
- **Write copy in second person** — "Your traders" not "The user's traders"
- **Show data WITH context** — "+12% vs last week" not just "+12%"
- **Design empty states as their own screens** — they're often the first impression
- **Use motion to explain, not decorate** — a card entering from below means "new"; sliding in from right means "next"
- **Test at extremes** — the design must work with 1 item AND 100 items, with $0.01 AND $1,000,000

---

## 7. The Ive Principles (Applied to Arx)

From Jony Ive's design philosophy, adapted for a digital trading terminal:

### 7.1 Inevitable, Not Arbitrary

Every design choice should feel like the ONLY possible choice. Not "we picked rounded corners" but "rounded corners at 12px because sharp edges contradict the protective citadel metaphor and because they match the iOS system language our users expect on mobile."

**Test:** For any design decision, ask "why this and not the opposite?" If the answer is "preference" or "it looks nice," the decision is arbitrary. If the answer traces to a principle, persona need, or constraint, it's inevitable.

### 7.2 Resolve Complexity Into Clarity

Trading IS complex. The design's job is not to remove complexity but to ORGANIZE it so clearly that complexity becomes comprehensible.

The altitude cascade (A1-A5) is the canonical example — five levels of market complexity, but the user only sees what's relevant to their journey state. The complexity exists. The user doesn't feel it.

**Test:** Can an S7 user with zero trading knowledge get value from this screen in under 10 seconds? If not, the complexity hasn't been resolved — it's been hidden (which means it'll resurface as confusion later).

### 7.3 Care You Can Feel

The difference between a $10 app and a $10M app is the attention to states nobody talks about:

- The **empty state** (what does the screen look like before any data arrives?)
- The **error recovery** (what happens when the API fails? Is the error screen designed or default?)
- The **transition between loading and loaded** (does content snap in, or does it arrive with choreography?)
- The **way a dismissed card exits** (does it just disappear, or does it leave gracefully?)
- The **boundary conditions** (what happens with a 1-character name? A 40-character name? A negative number?)

These details are invisible when they're right. They're painfully visible when they're wrong. The user doesn't think "what a nice empty state" — they think "this app feels premium." That feeling IS the care.

### 7.4 Material Honesty

Stone is stone. Water is water. Glass is glass. Each material has physical properties that the digital design must respect:

- **Stone** is solid, opaque, heavy. It doesn't glow on its own (stone-glow is reflected light, not emission). It doesn't animate fluidly — it shifts, locks, settles.
- **Water** is transparent, flowing, precise. It carries data — prices, signals, streams. It can shimmer (data-glow) but doesn't hold structure.
- **Glass** is translucent, layered, fragile. It's for overlays only — bottom sheets, modals, status bar. It blurs what's behind it (20px). It never pretends to be opaque.

Don't make stone behave like water (no purple gradients). Don't make glass pretend to be opaque (no solid-color bottom sheets). Don't make water hold structure (no cyan buttons for primary actions).

### 7.5 Restraint as Luxury

What you REMOVE defines premium more than what you add.

- Every element on screen must **earn its place**. If removing it doesn't hurt comprehension or functionality, it shouldn't be there.
- Every animation must **earn its motion**. If the screen works without it, the animation is decoration.
- Every color must **earn its saturation**. T0 Ice (80% of screen) means most of the screen is near-monochrome. Color is reserved for meaning.
- Every word of copy must **earn its space**. If a label can be replaced by position or iconography, remove the label.

**Test:** Take the screen. Remove one element. Does it still work? If yes, that element didn't earn its place. Repeat until every removal hurts.

---

## 8. State Matrix Template

Before writing ANY screen spec, generate this matrix first. Every cell must be addressed in the spec.

```
| State     | Journey   | Data Available     | What User Sees        | Edge Case              |
|-----------|-----------|--------------------|-----------------------|------------------------|
| Default   | J2 Active | Full data          | Normal screen         | —                      |
| Empty     | J0 New    | No data            | Onboarding/CTA        | First-ever open        |
| Loading   | Any       | Pending            | Skeleton              | Slow network (>3s)     |
| Error     | Any       | Failed             | Retry + explanation   | Repeated failures      |
| Partial   | Any       | Some data, some failed | Mixed state       | One API up, one down   |
| Overflow  | J2 Active | Too much data      | Pagination/collapse   | 20+ items              |
| Stale     | Any       | Old data, refresh failed | Stale badge + data | Offline for >5 min     |
| Crisis    | J2 Active | Urgent + normal    | Crisis pinned at top  | Multiple simultaneous  |
| Boundary  | Any       | Extreme values     | Formatted correctly   | $0.001, $999,999,999   |
```

This is the SCENARIO CONTRACT. If a cell is uncovered in the spec, it's a gap.

---

## 9. Design Preamble Template

Every screen spec must include these sections BEFORE the functional specification:

```markdown
## Design References

- [App 1]: What they do well | Where they fall short | What Arx adopts
- [App 2]: ...
- [App 3]: ...

## State Matrix

(Complete matrix from §8 template, filled for this specific screen)

## Feel Targets

- **Target feel:** {one sentence — e.g., "Morning briefing — calm, oriented"}
- **Density:** {S7 low / S2 high / adaptive with default}
- **Scroll rhythm:** {description of visual flow}
- **Motion narrative:** {what enters first, choreography sequence}
- **Reference feel:** "{This screen should feel like [reference] but with [Arx advantage]}"
- **Litmus:** {which of the 5 tests are highest risk for this screen}
```

---

## 10. Evolution Protocol

This document evolves through feedback signals, not arbitrary updates.

**Signal sources:**

- Gary's accept/rework/reject signals on design output
- Prototype user testing feedback
- Competitive landscape changes (new app releases that raise the floor)

**Update triggers:**

- A new reference app exceeds the current floor → update §1
- A litmus test consistently fails to catch a problem type → add a new test to §2
- A new screen type is added → add feel targets to §3
- A rework signal traces to a taste failure → update the relevant anti-pattern or principle

**The taste spec is alive.** It gets sharper with every design cycle, not just when someone remembers to update it.
