# Taste & Judgment — gOS Design Intelligence

> Loaded automatically during `/design` and `/review design` via context-map.md.
> This file is gOS's aesthetic conscience — it defines what "good" looks like before a single pixel is placed.

---

## A. Universal Design Principles

### Jony Ive's Five Principles

1. **Care as a signal.** Users sense when something was made with care. Fanatical attention to details that are often overlooked — every loading state, every empty state, every edge case designed. The compound effect of thousands of invisible micro-decisions is what separates exceptional from competent.

2. **True simplicity through order.** Simplicity is not the absence of clutter — it is bringing order to complexity. There is profound beauty in clarity and efficiency. True simplicity requires deeply understanding the complexity beneath, then resolving it. A trading terminal that hides complexity is not simple; one that organizes complexity IS.

3. **A thousand no's for every yes.** Rigorous elimination defines great products. Every element that survives must earn its place. When in doubt, remove. The discipline to say "no" to good ideas to protect the integrity of what remains.

4. **Perception before specification.** Design begins with how the product should FEEL, not with specs. The emotional experience precedes the technical implementation. Ask "how should the trader feel when using this?" before "what components do we need?"

5. **Making, not decorating.** Design is not a surface layer applied to engineering. It is inseparable from how the thing works. Decoration without function is noise. Every visual choice must serve the experience.

### Dieter Rams' 10 Principles (Applied to Arx)

| # | Principle | Arx Translation |
|---|-----------|-----------------|
| 1 | **Innovative** | Push what a trading terminal can be — don't clone Bloomberg in dark mode |
| 2 | **Useful** | Every pixel serves the trader's workflow. If it doesn't help execution, cut it |
| 3 | **Aesthetic** | Visual beauty affects how seriously users take the tool and how long they stay |
| 4 | **Understandable** | Complex financial data must be self-explanatory through hierarchy and clarity |
| 5 | **Unobtrusive** | The terminal is an instrument, not a statement — extension of the trader's mind |
| 6 | **Honest** | No dark patterns, no hidden fees, no misleading data viz. Trust > engagement |
| 7 | **Long-lasting** | Avoid trendy design that ages. Timeless typography, restrained color, classic layout |
| 8 | **Thorough to the last detail** | Every tooltip, loading state, error state, and edge case considered |
| 9 | **Environmentally friendly** | Respect the user's time and energy. Dark mode on OLED. Minimize cognitive waste |
| 10 | **As little design as possible** | Subtract until only the essential remains |

### Premium Dark-Mode-First Patterns

Learned from Linear, Superhuman, Arc, Raycast, Things 3:

**Elevation through lightness** (Superhuman's rule):
- The closer a layer is to the user, the lighter the surface
- Five shades of gray create spatial hierarchy
- Modals and popovers are lighter; backgrounds are darker
- This mimics how light falls in a dark room

**Never use pure black:**
- Base: dark grays (#0D0D0D to #1A1A1A), never #000000
- Pure black causes OLED smearing, feels jarring, matches nothing in nature
- Text: 87% opacity white (high emphasis), 60% (secondary), 38% (disabled)

**Speed is a design principle:**
- Target sub-100ms for every interaction (Superhuman: 50-60ms internally)
- When software responds at the speed of thought, it feels like a premium instrument
- Every millisecond of latency degrades the feeling of quality

**Keyboard-first, mouse-optional:**
- Cmd+K command palette for all actions
- Every clickable action has a keyboard shortcut
- Shortcuts surfaced contextually (hover hints, inline labels)
- Tab/arrow navigation for all data grids

**Animations that serve, not perform:**
- 150-300ms duration, ease-out curve
- Communicate state change and spatial relationships only
- Never decorative. Never longer than 300ms. Never block interaction

---

## B. Arx-Specific Taste

### The Taste Stack (Apply in Order)

When evaluating any design decision for Arx, run these 5 filters in sequence:

1. **Does it help the trader execute?** (Rams #2) — If the element does not serve the trading workflow, remove it. No exceptions.

2. **Does it feel fast?** (Superhuman rule) — Perceived speed is non-negotiable. Skeleton screens over spinners. Optimistic updates over loading states. Latency is the enemy of trust.

3. **Does it respect the trader's expertise?** (Bloomberg pattern) — Progressive disclosure. Power is available but not imposed. Conceal complexity, reveal on demand. Don't patronize S2 leaders or overwhelm S7 followers.

4. **Does it feel like it was made with care?** (Ive test) — Every loading state designed. Every empty state designed. Every error state designed. Every edge case considered. The user should feel that a human agonized over this.

5. **Is it honest?** (Rams #6) — No hidden costs. No misleading visualizations. No dark patterns. Crypto traders are already wary; trust is earned pixel by pixel.

### Dark Mode Checklist

- [ ] Base background: dark gray (#0D0D0D to #1A1A1A), violet undertone per Arx design system
- [ ] Elevation: lighter layers are closer to the user (5 shade levels)
- [ ] Text hierarchy: 87% / 60% / 38% white opacity
- [ ] Accent: Stone violet (#5B21B6) for primary actions, Water cyan (#22D1EE) for data — used sparingly
- [ ] Borders: subtle (1px, low-opacity white) preferred over shadows on dark
- [ ] Animations: 150-300ms, ease-out, state communication only

### Keyboard-First Checklist

- [ ] Cmd+K (or /) command palette for all actions
- [ ] Every button/action has a visible keyboard shortcut
- [ ] Tab/arrow navigation for all tables and data grids
- [ ] Hotkeys for order entry: buy (B), sell (S), close (C), modify (M)
- [ ] Shortcuts discoverable via hover hints

### The Cheap vs Premium Litmus Test

| Cheap (reject) | Premium (aspire to) |
|-----------------|---------------------|
| Neon gradients, pixel art branding | Restrained palette, typographic hierarchy |
| Confetti on trade execution | Subtle confirmation with position update |
| Laggy charts, spinner-heavy loading | Instant render, skeleton screens, optimistic updates |
| Mouse-only interaction | Keyboard-first with mouse support |
| One-size-fits-all layout | Customizable workspace, remembers preferences |
| "Web3 aesthetic" (playful, unserious) | "Financial instrument aesthetic" (precise, trustworthy) |
| Features dumped on screen | Progressive disclosure, contextual power |
| Dark mode = inverted light theme | Dark mode designed from scratch with elevation system |
| Generic hero sections, 3-column grids | Purpose-built layouts that serve the specific screen's task |
| Decoration without function | Every visual element earns its place |

### Trading Terminal Excellence Patterns

**From Bloomberg:** Conceal complexity across thousands of functions so any single workflow feels focused. Progressive disclosure is the meta-pattern.

**From TradingView:** Clean chart rendering with customizable overlays. The standard traders bring to every terminal. If your charts are worse than TradingView, you've already lost.

**From Robinhood:** Zero friction for core actions. The path from insight to execution must be as short as physically possible. Swipe-to-trade removes steps.

**From Revolut:** Onboarding that respects time. 24 taps vs 120 for traditional banks. Every unnecessary step is a user lost.

**From Linear:** Speed as the product identity. Sub-100ms response. Animations that flow like water. The feeling that the tool was built by people who use it.

### Anti-Patterns (Reject on Sight)

- Gamification of trading (confetti, badges, streaks) — destroys trust for serious traders
- Excessive color in data display (everything highlighted = nothing highlighted)
- Wallet pop-ups interrupting every action (sign, confirm, sign again)
- Copying TradingView's layout without TradingView's charting quality
- "Web3 aesthetic" that signals lack of seriousness
- Requiring blockchain expertise to place a basic trade
- Hiding real costs behind unclear fee structures
- Forced single layout (power users demand customization)

---

## C. Persona Taste Profiles

### The Five Taste Axes

| Axis | S2 Leaders (Jake) | S7 Followers (Sarah) |
|------|-------------------|---------------------|
| **Density** | Maximalist — uses 3-7 tools simultaneously, hates context-switching, wants everything visible | Minimalist — wants clarity not overwhelm, fewer panels, bigger text, more breathing room |
| **Warmth** | Cool/Precise — data focus, numbers first, no handholding, respect the craft | Warm/Humanized — trust cues, explanatory text, friendly guidance, reassurance |
| **Authority** | Authoritative — pro tools, earned respect through capability, power available | Transparent — show the math, explain the risk, reveal the fee, no hidden anything |
| **Innovation** | Conservative on core execution, experimental on analytics and signals | Conservative everywhere — familiarity = safety, standard patterns, no surprises |
| **Control** | Full customization — workspace layout, keyboard shortcuts, API access | Guided flows — guardrails, sensible defaults, auto-SL, cool-down timers |

### Taste Conflict Resolution

When S2 and S7 want different things, **the screen's primary persona wins:**

| Screen | Primary Persona | Taste Implication |
|--------|----------------|-------------------|
| Trading dashboard | S2 (Jake) | Maximalist density, keyboard shortcuts, pro tooling |
| Portfolio overview | S2 (Jake) | Data-rich, customizable panels, real-time P&L |
| Onboarding flow | S7 (Sarah) | Minimalist, warm, guided, trust-building |
| Copy trading | S7 (Sarah) | Transparent, explanatory, guardrailed, trust-first |
| Leader profile | Both | S7 reads it (trust signals), S2 owns it (reputation) — S7 taste governs layout |
| Risk management | S2 primary, S7 visible | Pro tools with clear explanations visible on hover |
| Signal feed | S2 creates, S7 consumes | S7 taste for display (readable), S2 taste for creation (precise) |

### The Persona Empathy Check

Before finalizing any design, ask:

**For S2 (Jake):**
- "Would a trader managing $200K across 3 positions feel in control using this?"
- "Can they go from seeing an opportunity to executing a trade in under 3 seconds?"
- "Does this respect their expertise or talk down to them?"

**For S7 (Sarah):**
- "Would someone who lost money on FTX feel safe depositing here?"
- "Can they understand what they're risking without a finance degree?"
- "If the market drops 20%, does this screen help them or panic them?"

---

## How to Use This File

### During `/design`:
1. Read the Taste Checkpoint (specified by the command)
2. Reference the relevant persona taste profile for the target screen
3. Apply the Taste Stack (5 filters) to every design decision
4. Label decisions as SAFE or RISK per existing convention
5. Run the Cheap vs Premium litmus test on the final output

### During `/review design`:
1. Score the design against the Taste Stack
2. Validate persona taste alignment
3. Run Cheap vs Premium litmus test
4. Apply Ive's "made with care" test
5. Check dark mode checklist compliance
6. Flag TASTE CONCERN if score < 3/5

### During `/review council`:
The `design-variant` persona uses this file as its primary lens. It evaluates against: Ive's care test, Rams' usefulness test, persona taste alignment, premium vs cheap signals, dark mode elevation system. Veto trigger: design looks assembled from components rather than designed as a coherent experience.
