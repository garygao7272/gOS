# Build Card Structure for AI Design Tools — Research Findings

**Date:** 2026-04-06
**Scope:** How to structure Arx build cards so Figma MCP, AIDesigner MCP, and Stitch MCP produce pixel-perfect output
**Sources:** Figma MCP docs, AIDesigner MCP docs, Stitch MCP docs, existing Arx build cards (C2, C5-NEW, C1-R0), Arx_4-2 Design System, Arx_4-3 Design Taste, DESIGN.md

---

## Executive Summary

The current build card format is 85% there. The five gaps that cause AI design tools to deviate from intent are: (1) no structured component tree for layout, (2) no motion choreography sequence, (3) "feel" is implied but not encoded, (4) skeleton/transition specs are absent, and (5) the three tools need different information densities from the same card. Below are specific structural changes with examples.

---

## Question 1: What's Missing from the Current Format?

### What's already strong

- **Why section** — JTBD + pain is exactly right. AI tools ignore this (correctly), but human reviewers need it for judgment calls.
- **What the User Does** — Numbered steps give clear interaction flow. Good as-is.
- **Data section** — Source + computation tables are excellent. No tool needs more.
- **States section** — Current coverage (empty, loading, error, populated + edge cases) is good. Missing: skeleton shape spec and state transition choreography.
- **Components section** — Lists design system components by name. Good for code gen. Insufficient for visual design tools (they need hierarchy, not a flat list).
- **Acceptance section** — EARS format is precise and testable. Good as-is.

### What's missing

**A. Component Hierarchy Tree (not just a flat list)**

The current `## Components` section is a flat list: "SearchBar, CategoryTabBar, TopMoversGrid..." This tells a code generator what to import but tells Figma MCP nothing about nesting, containment, or relative positioning. The Layout ASCII wireframe partially compensates, but ASCII is ambiguous about containment (is the regime bar INSIDE the header or ABOVE it?).

**Recommendation:** Add a `## Component Tree` section using indented YAML-like notation that makes parent-child relationships explicit.

**B. Motion Choreography Sequence**

The Visual Spec section mentions "card-entry: fade-up 200ms stagger(50ms)" but doesn't specify the ORDER of entrance. Arx_4-3 says "First: regime bar, then: portfolio header, then: cards stagger in" — this choreography is critical for premium feel but is never encoded in individual build cards.

**C. Skeleton Screen Shape Spec**

States mention "shimmer skeleton" but never describe the shape. A skeleton for a card with an icon circle + two text lines looks completely different from a skeleton for a full-width chart. The shape IS the design.

**D. Scroll Behavior Annotations**

The Layout section marks elements as "sticky" or "scrollable" but never specifies: at what scroll offset does the header compact? Does the search bar collapse? What's the parallax factor on the Top Movers grid? These affect pixel-perfect output significantly.

**E. Responsive Breakpoint — Not Needed**

Arx is mobile-first at 390x844. No breakpoints needed. The Desktop specs (4-1-2-x) are separate documents. This is correct.

**F. Accessibility Annotations — Partially Needed**

Not full WCAG audit, but three things should be in every build card:
- Touch target sizes (already implied by 44px minimum, but not per-element)
- Screen reader label for any icon-only element
- Contrast check for any element using color to convey meaning (gain/loss, regime state)

**G. Z-Index Ordering — Only for Overlapping Elements**

Not needed globally, but needed when the card specifies sticky headers, floating buttons, or bottom sheets. The current format handles this implicitly via the ASCII wireframe's top-to-bottom ordering, which works. Add explicit z-index only for overlays.

---

## Question 2: How Should the Layout Section Be Structured for Figma MCP?

### ASCII Wireframe: Keep It, But Add a Component Tree

ASCII wireframes are surprisingly effective for LLMs. Both Figma MCP's `use_figma` tool and AIDesigner's `generate_design` tool consume natural-language descriptions better than JSON component trees. The ASCII wireframe is the right primary format.

However, the wireframe is ambiguous about three things that Figma auto-layout needs:
1. **Direction** — Is a group horizontal or vertical?
2. **Sizing** — Does an element fill the parent or hug its content?
3. **Alignment** — Left-aligned? Center? Space-between?

### Recommendation: Add Auto-Layout Annotations to ASCII

Instead of a separate JSON tree, annotate the existing ASCII with Figma auto-layout keywords inline:

```
## Layout (Stitch-ready)

[viewport: 390x844, safe-area: top 59px, bottom 34px]

HEADER: sticky, --color-surface-elevated, column, fill-w, hug-h
  ├── Regime bar: row, fill-w, h=4px, regime-color bg
  └── Portfolio pill: row, hug, align-right, gap=8px
       ├── "●" status-dot 10px
       ├── "$12,450" (Hero mono)
       └── "↑2.3%" (Data, --color-gain)

SEARCH BAR: fill-w, h=44px, --color-surface, radius=12px, mx=16px
  └── "[Search instruments...]" (Body, --color-text-tertiary)

CATEGORY TABS: row, fill-w, scroll-x, gap=0, hug-h
  └── [Watchlist] [Hot] [Gainers] [Losers] [New] [Vol]
      Active: underline 2px --color-primary, slide 200ms

TOP MOVERS GRID: grid(2col), fill-w, gap=12px, px=16px
  └── Cell: column, hug, --color-surface-elevated, radius=12px, p=12px
       ├── row: symbol(Data-sm) + price(Data) + gap=auto
       ├── sparkline: fill-w, h=40px
       └── row: 24h%(Data-sm, gain/loss color) + ◆ badge(Caption)
```

The key additions are: `column`/`row`/`grid(2col)` for direction, `fill-w`/`hug`/`hug-h` for sizing, and `gap=Npx` for spacing. These map directly to Figma auto-layout properties and are readable by any LLM.

### What NOT to Do: JSON Component Tree

A JSON tree like `{ type: "frame", layout: "vertical", children: [...] }` is theoretically precise but:
- Hard for humans to review
- Figma MCP's `use_figma` tool accepts JavaScript code, not JSON schemas — it needs to be translated anyway
- AIDesigner ignores structured layout specs entirely (it generates from vibes + constraints)
- Stitch MCP doesn't consume component trees — it generates from prompts

The annotated ASCII is the right middle ground.

---

## Question 3: How to Encode "Feel" into a Build Card

### The Problem

Arx_4-3 defines feel targets per screen type (e.g., "Morning briefing — calm, oriented" for Feed). But individual build cards don't carry this forward. The C1-R0 build card has no feel section at all, even though Arx_4-3 explicitly prescribes a "Design Preamble Template" with feel targets.

### Recommendation: Add `## Feel` Section (Mandatory)

This section bridges the gap between functional spec and emotional intent. It's consumed by AIDesigner (which responds well to vibes) and by human reviewers.

```markdown
## Feel

**Target:** Cockpit — focused, zero distraction, one action dominates
**Density:** High (S2 needs everything visible), S7 sees guided wizard
**Reference:** "Bloomberg order ticket confidence with Robinhood clarity"

### Motion Choreography (on-load sequence)
1. Regime bar renders instantly (0ms) — sets emotional context
2. Symbol header + chart fade in (100ms, easing-out) — orients the trader
3. Step cards cascade top-to-bottom (200ms each, stagger 80ms) — guided flow
4. Execute CTA fades in LAST (400ms total) — earned, not rushed

### Color Temperature Budget
- T0 Ice (80%): Surface bg, borders, body text, step card containers
- T1 Cool (15%): Regime bar at 40% opacity, sparkline fill, order book depth bars
- T2 Warm (4%): Direction toggle active state, gain/loss on PnL values
- T3 Hot (1%): Execute Trade CTA (solid Stone), liquidation warning flash

### Scroll Rhythm
- Steps 1-3 visible without scroll on 844px viewport
- Step 4 (Exit Plan) starts half-visible — scroll invitation
- Advanced Settings lives below the fold deliberately — S7 never sees it
- Visual anchor at Step 5 (Review Summary) breaks the card rhythm
```

### How AI Tools Consume This

- **AIDesigner:** Responds to "Target feel" and "Reference" strings directly. Feed these into the AIDesigner prompt as vibes.
- **Figma MCP:** The motion choreography maps to Figma prototype interactions. The `use_figma` tool can set up Smart Animate transitions between states.
- **Stitch MCP:** Color temperature budget informs which elements get color treatment vs. monochrome. Stitch's design agent respects "feel" descriptors in its canvas prompt.
- **Human review:** The 5 litmus tests from Arx_4-3 become reviewable against explicit feel targets.

### Motion Choreography Format

Use a numbered sequence with timing. This is the format that translates best across tools:

```
### Motion Choreography
| Order | Element          | Animation          | Delay | Duration | Easing      |
|-------|------------------|--------------------|-------|----------|-------------|
| 1     | Regime bar       | instant render      | 0ms   | 0ms      | —           |
| 2     | Symbol header    | fade-in + slide-up  | 0ms   | 200ms    | easing-out  |
| 3     | Chart            | fade-in             | 100ms | 200ms    | easing-out  |
| 4     | Step 1 card      | fade-up             | 200ms | 200ms    | easing-spring |
| 5     | Step 2 card      | fade-up             | 280ms | 200ms    | easing-spring |
| 6     | Step 3 card      | fade-up             | 360ms | 200ms    | easing-spring |
| 7     | Execute CTA      | fade-in             | 500ms | 300ms    | easing-out  |
```

---

## Question 4: Visual Spec Section Improvements

### Current State

The C1-R0 Visual Spec is the best example:
```
Fixture: C1-R0 (see Arx_4-1-1-8 §4.1)
Icons: see DESIGN.md §3.2
Embellishments: [per-card accent borders]
Interactions: [per-element tap/gesture behaviors]
```

This is functional but missing several dimensions that affect pixel-perfect output.

### Recommended Additions

#### A. Skeleton Screen Spec

```markdown
### Skeleton (loading state)
- Header: shimmer rectangle fill-w h=80px (contains equity placeholder 120x32px + pill 80x24px)
- Feed cards: 3x shimmer cards, each 358x120px, gap=12px
  Card skeleton: icon-circle 40px (left) + 2 text lines (right, 60% and 40% width)
- Shimmer direction: left-to-right, 1.5s, rgba(255,255,255,0.04) → rgba(255,255,255,0.08)
- Skeleton matches populated layout EXACTLY — same heights, same gaps, same positions
```

This is critical because the Empty State Test (litmus #4) requires the skeleton to look premium.

#### B. State Transition Choreography

```markdown
### State Transitions
| From → To         | Animation                                           | Duration |
|--------------------|-----------------------------------------------------|----------|
| Loading → Populated | Shimmer cards cross-fade to real cards, top-to-bottom stagger 50ms | 300ms |
| Populated → Error   | Red banner slides down from top, content dims to 0.6 opacity | 200ms |
| Error → Retry       | Banner slides up, content restores opacity | 200ms |
| Any → Empty          | Fade to empty state illustration | 300ms |
```

#### C. Haptic Feedback Map

```markdown
### Haptics
| Trigger               | Haptic Type     | iOS API              |
|------------------------|-----------------|----------------------|
| Trade executed         | notification success | UINotificationFeedbackGenerator.success |
| Watchlist star toggled | impact light    | UIImpactFeedbackGenerator(style: .light) |
| Pull-to-refresh        | impact medium   | UIImpactFeedbackGenerator(style: .medium) |
| Error / rejection      | notification error | UINotificationFeedbackGenerator.error |
```

#### D. Scroll Behavior Annotations

```markdown
### Scroll Behavior
- Header compacts at scroll-y > 100px: equity shrinks Hero → Hero-sm, P&L hides, h transitions 80px → 48px (200ms)
- Category tabs become sticky at scroll-y > 160px (below compact header)
- Top Movers grid scrolls away normally (not sticky)
- End-of-list: "You're all caught up" message with lucide:check-circle, fade-in at 300ms
- Over-scroll: 16px elastic bounce, no pull-to-refresh on this screen (only on feed)
```

#### E. Color Temperature Audit

Already covered in the Feel section above. This replaces any per-element color spec — the build card author states the budget, and every element must fit within it.

---

## Question 5: Stitch MCP vs. Figma MCP vs. AIDesigner MCP — Input Differences

### Tool Comparison Matrix

| Dimension | Figma MCP (`use_figma`) | AIDesigner (`generate_design`) | Stitch MCP (`get_screen_code`) |
|-----------|------------------------|-------------------------------|-------------------------------|
| **Input format** | JavaScript Plugin API code | Natural-language prompt | Prompt + DESIGN.md auto-injected |
| **What it reads** | Exact pixel values, auto-layout props, color hex codes, font specs | Vibes, product type, audience, feel, constraints | DESIGN.md tokens, feel descriptions, component descriptions |
| **What it ignores** | "Feel" descriptions, JTBD, user stories | Exact pixel coordinates, component trees, data tables | Exact layout coordinates, data source tables |
| **Output** | Figma frames with auto-layout, styles, components | Standalone HTML/CSS (Tailwind) | HTML pages, exportable DESIGN.md |
| **Strength** | Pixel-perfect component construction, design system compliance | Visual exploration, creative composition, typography/layout taste | Rapid full-screen prototyping, DESIGN.md portability |
| **Weakness** | Needs very explicit instructions, no creative interpretation | Cannot reference existing Figma components, may ignore token constraints | Limited component-level control, may not match exact token values |

### Can One Build Card Serve All Three?

**Yes, with a layered reading strategy.** The build card should be structured so each tool reads the sections it needs and skips the rest.

```
## Why                    ← Human only (judgment context)
## What the User Does     ← Human + Stitch (user flow)
## Feel                   ← AIDesigner + Stitch + Human (vibes, choreography, feel)
## Layout                 ← Figma MCP + code gen (structural, precise)
## Component Tree         ← Figma MCP (nesting, auto-layout constraints)
## Visual Spec            ← All tools (icons, embellishments, interactions)
## Data                   ← Code gen only (API sources, computation)
## States                 ← All tools (empty, loading, error, populated + skeletons)
## Acceptance             ← Code gen + test (EARS behavioral specs)
## Navigate               ← Code gen + Figma prototyping (from/to)
## Taste Baseline         ← Human review (litmus scores, reference beat)
```

### Tool-Specific Adapter Strategy

Rather than maintaining three formats, use the build card as the single source and extract tool-specific prompts at generation time:

**For AIDesigner:** Extract `## Feel` target + reference + `## Layout` (top-level structure only, no pixel values) + `## Visual Spec` embellishments + DESIGN.md tokens. Compress into a 200-word art-directed prompt.

**For Figma MCP:** Extract `## Layout` with auto-layout annotations + `## Component Tree` + `## Visual Spec` exact values + DESIGN.md tokens. Generate JavaScript code for `use_figma` tool.

**For Stitch MCP:** Extract `## Feel` + `## Layout` + `## States` + DESIGN.md. Stitch auto-injects DESIGN.md, so the prompt focuses on screen purpose and user flow.

This extraction should be automated in the `/design ui` command, not done manually.

---

## Recommended Build Card v2 Template

```markdown
# BUILD: {ID} — {Screen Name}

<!-- Source: Arx_4-1-1-X §ID, Arx_3-2-X (user story ref) -->

## Why
> JTBD: "{one-line job}"
> Pain: {pain code} — {description}
> Persona: {primary} primary, {secondary} secondary

## What the User Does
1. {step}
2. {step}
...

## Feel
**Target:** {one sentence — from Arx_4-3 §3 feel targets}
**Density:** {S7 low / S2 high / adaptive}
**Reference:** "{feel like X with Y advantage}"

### Motion Choreography
| Order | Element          | Animation          | Delay | Duration | Easing      |
|-------|------------------|--------------------|-------|----------|-------------|
| 1     | {first element}  | {anim type}        | 0ms   | Xms      | {curve}     |
| ...   | ...              | ...                | ...   | ...      | ...         |

### Color Temperature Budget
- T0 Ice (80%): {what uses it}
- T1 Cool (15%): {what uses it}
- T2 Warm (4%): {what uses it}
- T3 Hot (1%): {what uses it}

## Layout
```
[viewport: 390x844, safe-area: top 59px, bottom 34px]

SECTION_NAME: {sticky|scroll}, {surface-token}, {column|row|grid(Ncol)}, {fill-w|hug}, {hug-h|h=Npx}
  ├── Element: {layout-direction}, {sizing}, {spacing}, {visual-spec-inline}
  │    ├── Child: "{content}" ({type-level}, {color-token})
  │    └── Child: ...
  └── ...
```

### Scroll Behavior
- {what's sticky, at what offset}
- {what compacts, how}
- {end-of-list treatment}

### Skeleton (loading state)
- {shape description matching populated layout}
- {shimmer direction and timing}

## Visual Spec
**Fixture:** {screen-ID} (see Arx_4-1-1-8 §X)
**Icons:** see DESIGN.md §3.X
**Embellishments:**
  - {element}: {treatment from DESIGN.md §4}
  - ...
**Interactions:**
  - {element} {gesture} → {action}
  - ...
**Haptics:**
  - {trigger}: {haptic-type}
  - ...

### State Transitions
| From → To         | Animation              | Duration |
|--------------------|------------------------|----------|
| Loading → Populated | {description}         | Xms      |
| ...                | ...                    | ...      |

## Data
| Element | Source | Computation |
|---------|--------|-------------|
| ... | ... | ... |

## States
- **Empty:** {description + CTA}
- **Loading:** {skeleton shape from above}
- **Error:** {banner + fallback behavior}
- **Populated:** {normal state description}
- **{Edge case}:** {description}

## Components (from Arx_4-2)
- {ComponentName} — {brief description of role}
- ...

## Acceptance (EARS)
- WHEN {trigger} THE SCREEN SHALL {behavior}
- ...

## Navigate
- **From:** {entry points}
- **To:** {exit points}

## Taste Baseline
- Litmus passed: {date or "pending"}
- Feel Pass: Rhythm {N}, Weight {N}, Space {N}, Type {N}, Motion {N}
- Reference beat: {which reference app this screen surpasses, and how}

## Verify
```bash
npm test -- --grep "{test-pattern}"
```
```

---

## Migration Path

The current build cards (C2, C5-NEW, C1-R0) are close to v2. The changes are additive — nothing gets removed.

| Section | Current Status | Action Needed |
|---------|---------------|---------------|
| Why | Complete | None |
| What the User Does | Complete | None |
| Feel | MISSING | Add — extract from Arx_4-3 §3 feel targets per screen type |
| Layout | Good ASCII | Add auto-layout annotations (column/row/fill-w/hug/gap) |
| Scroll Behavior | Mentioned in Layout | Extract to own subsection with compact/sticky/end-of-list specs |
| Skeleton | Mentioned in States | Add shape description + shimmer spec |
| Visual Spec | Exists, varies | Standardize: Fixture + Icons + Embellishments + Interactions + Haptics + State Transitions |
| Motion Choreography | Absent | Add table in Feel section |
| Color Temperature | Absent per card | Add to Feel section |
| Data | Complete | None |
| States | Good | Add skeleton shape cross-reference |
| Components | Flat list | Keep flat list (code gen needs it). Auto-layout tree is in Layout section. |
| Acceptance | Complete | None |
| Navigate | Complete | None |
| Taste Baseline | MISSING | Add — date + feel pass scores + reference beat |
| Verify | Present in some | Standardize across all cards |

---

## What NOT to Add

- **Pixel-level absolute coordinates** — Auto-layout makes these irrelevant. Relative positioning via the annotated ASCII is sufficient.
- **Z-index numbers** — Only needed for overlapping elements (modals, sheets). The natural top-to-bottom ordering in the Layout section handles normal stacking.
- **Responsive breakpoints** — Arx is 390x844. Desktop is a separate spec tree.
- **Full accessibility audit** — Overkill for build cards. Arx_4-2 already sets 44px touch targets, AAA contrast ratios, and the design system handles color-blind safety. Build cards should only annotate screen-reader labels for icon-only elements.
- **Named animation sequences as CSS @keyframes** — These belong in DESIGN.md (where they already live), not in individual build cards. Build cards reference them by name ("stoneGlow", "waterRipple").
- **JSON component trees** — Worse for human readability, no better for AI tools. The annotated ASCII is the right format.

---

## Sources

- [Figma MCP Server Guide](https://github.com/figma/mcp-server-guide/)
- [Figma Skills for MCP](https://help.figma.com/hc/en-us/articles/39166810751895-Figma-skills-for-MCP)
- [AIDesigner MCP Server Documentation](https://www.aidesigner.ai/docs/mcp)
- [AIDesigner Claude Code Skills](https://www.aidesigner.ai/blog/claude-code-skills)
- [Stitch MCP Setup](https://stitch.withgoogle.com/docs/mcp/setup/)
- [Stitch MCP GitHub](https://github.com/davideast/stitch-mcp)
- [Figma MCP Blog — Introducing Dev Mode MCP Server](https://www.figma.com/blog/introducing-figma-mcp-server/)
- [How to Structure Figma Files for MCP — LogRocket](https://blog.logrocket.com/ux-design/design-to-code-with-figma-mcp/)
