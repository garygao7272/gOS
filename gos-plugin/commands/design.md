---
effort: high
description: "Design mode: quick sketch, variants, flow, full pipeline, system tokens, sync — visual and interaction design"
---

# Design Mode — Visual + Interaction Design -> outputs/think/design/ -> specs/

**All visual and interaction design work. Extracted from /think as a top-level verb because design deserves its own command.**

**Output routing:**

| Sub-command | Output To | Then |
|-------------|-----------|------|
| `quick` | `outputs/think/design/{slug}.md` | Suggest: "Go deeper with variants or full pipeline?" |
| `variants` | `outputs/think/design/{slug}-variants.md` | Suggest: "Refine winner with full swarm?" |
| `flow` | `outputs/think/design/{slug}-flow.md` | Suggest: "Promote to `specs/Arx_4-1-X`?" |
| `full` / default | `outputs/think/design/{slug}.md` | Suggest: "Promote to `specs/Arx_4-1-X_{Slug}.md`?" |
| `system` | Direct update to `specs/Arx_4-2_Design_System.md` | No staging |
| `sync` | Bidirectional sync | No output file |

**Before designing (always):**
1. Read `specs/Arx_4-2_Design_System.md` for existing tokens
2. Read `DESIGN.md` for Stitch-consumable design language
3. Read `apps/web-prototype/SOUL.md` for design philosophy

**Anti-slop rules (mandatory):**
- **Blacklist visuals:** Purple gradients, 3-column feature grids, generic hero sections, stock imagery, glassmorphism cards, floating abstract shapes
- **Blacklist fonts:** Inter, Roboto, Poppins (unless explicitly chosen by Gary)
- **SAFE vs RISK framing:** For every design decision, label it SAFE (conventional, expected) or RISK (bold, differentiated). Default to RISK unless Gary says otherwise.
- **The AI test:** "If it looks like it was made by AI, reject it." Every screen must have a specific, opinionated point of view that a generic model would not produce.

**Plan mode by default.** Present the design approach before executing. Wait for approval.

**Scratchpad checkpoints.** Update `sessions/scratchpad.md` at these moments:
- **On entry:** Write current task, mode (`Design > {sub-command}`), and input
- **After plan approval:** Write the approved approach to `Working State`
- **After each agent completes:** Log agent name + key output to `Agents Launched`
- **After synthesis:** Write design decisions to `Key Decisions Made This Session`
- **On dead end:** Append to `Dead Ends (don't retry)`
- **After compaction:** Re-read `sessions/scratchpad.md` to restore state

Parse the first word of `$ARGUMENTS` to determine sub-command. If no sub-command given, ask: "What kind of design? quick sketch, variant exploration, flow prototype, or full design?"

---

## quick <description>

**Purpose:** Phase 0 only. Fast visual sketch via Stitch MCP. Get something on screen in under a minute.

**Process:**

1. Read `DESIGN.md` and inject it as context for Stitch generation
2. Call `mcp__stitch__list_projects` to find or create an Arx project
3. Call `mcp__stitch__generate_screen_from_text` with:
   - The design description as prompt
   - Device: MOBILE
   - Include DESIGN.md content in the prompt for style guidance
4. Call `mcp__stitch__get_screen` to retrieve the HTML output
5. Present the Stitch screen to Gary

**Output:** Show the screen. Then ask:

> Quick sketch done. Want to:
> - **Variants** — explore 3-5 alternatives?
> - **Full** — run the design swarm for production-grade specs?
> - **Iterate** — refine this specific screen?

Write sketch notes to `outputs/think/design/{slug}.md`.

---

## variants <screen-ref> [refine|explore|reimagine] [layout|color|typography|content]

**Purpose:** Phase 0.5. Generate 3-5 variants via Stitch to systematically explore the design space.

**Input:**
- `screen-ref`: Screen ID from a previous Stitch generation, or a description to generate fresh
- Creative range (optional, default `explore`):
  - `refine` — subtle tweaks, same structure
  - `explore` — balanced, new directions within constraints
  - `reimagine` — radical departures, break assumptions
- Aspects to vary (optional, default all):
  - `layout` — restructure information hierarchy
  - `color` — alternative color treatments within the design system
  - `typography` — font pairing and scale experiments
  - `content` — alternative copy, data density, information architecture

**Process:**

1. If `screen-ref` is not a Stitch screen ID, first generate a base screen via `quick`
2. Call `mcp__stitch__generate_variants` with:
   - Screen ID(s) from the base screen
   - Creative range: REFINE | EXPLORE | REIMAGINE
   - Aspects: LAYOUT, COLOR_SCHEME, IMAGES, TEXT_FONT, TEXT_CONTENT
   - Count: 3-5 variants
3. Retrieve all variant screens
4. Present them side by side with labels (A, B, C, D, E)
5. For each variant, note what's SAFE vs RISK about it

**Output:** User picks a winner (or requests another round). Write variant analysis to `outputs/think/design/{slug}-variants.md`.

Then ask: "Want to refine the winner with the full design swarm?"

---

## flow <screen-ids...>

**Purpose:** Phase 0.75. Connect multiple screens into a navigable prototype.

**Input:** 2+ screen references (Stitch IDs, descriptions, or spec references like "Arx_4-1-1-3")

**Process:**

1. Call `mcp__stitch__list_screens` to find referenced screens
2. If any screens don't exist yet, generate them via `quick`
3. Call `mcp__stitch__edit_screens` to add navigation connections:
   - Define tap targets and their destinations
   - Set transition types (slide, fade, modal)
   - Add back navigation
4. Present the connected flow for review
5. Map the flow to spec structure (which Arx_4-1-X screens are represented)

**Output:** Connected prototype. Write flow documentation to `outputs/think/design/{slug}-flow.md`. Suggest: "Promote to `specs/Arx_4-1-1-0_Navigation_and_IA.md` update?"

---

## full <brief>

**Purpose:** Complete design pipeline from sketch to production-ready specs. This is the default if no sub-command matches.

If `$ARGUMENTS` doesn't start with a recognized sub-command (quick, variants, flow, system, sync), treat the entire argument as a design brief and run the full pipeline.

### Phase 0: Stitch Quick Sketch

Run the same process as `quick` above. Present the sketch. Then proceed automatically to Phase 1-3 unless Gary says stop.

### Phase 1-3: Full Design Swarm

**Launch 3 agents in parallel:**

1. **Agent 1 (mobile-design-engine):** Invoke the mobile-design-engine skill with the full 6-phase pipeline:
   - Phase 0: Deep Discovery (5+ rounds of questioning)
   - Phase 1: Research (iOS HIG, Material Design 3, benchmark apps)
   - Phase 2: UX Architecture (screen inventory, flows, density classification)
   - Phase 3: Screen Design (pixel-level specs, all states)
   - Phase 4: Animation Design (motion language, spring parameters, delight moments)
   - Phase 5: Prototype (deployable React + Tailwind + Framer Motion)
   - If a Stitch screen exists from Phase 0, pass its HTML as starting context. The agent refines rather than starting from scratch.

2. **Agent 2 (ui-ux-pro-max):** Invoke the ui-ux-pro-max skill. Focus on:
   - Design system generation (67 styles, 161 palettes, 57 font pairings)
   - Industry-specific reasoning (fintech/crypto rules)
   - Anti-pattern detection
   - Pre-delivery checklist
   - If variants were generated in Phase 0.5, evaluate all variants for design system compliance.

3. **Agent 3 (Anthropic Design Suite):** Use anthropic-skills in sequence:
   - design-discovery -> user research and problem framing
   - design-interaction -> interaction patterns and affordances
   - design-ui-animation -> motion and micro-interaction specifications
   - canvas-design -> visual mockup generation
   - This agent provides the "Anthropic taste" — bold, non-generic, anti-AI-aesthetic.

**Synthesis:** Compare all 3 outputs. For each design decision:

- If all 3 agree -> adopt
- If 2 agree, 1 differs -> adopt majority, note the minority view
- If all 3 differ -> present options to Gary with recommendation
- Always pick the bolder, more opinionated choice over the safe one

### Phase 4: Stitch -> HTML Bridge

After the swarm synthesis, convert the winning design into prototype-ready code:

1. Extract HTML/CSS from the Stitch screen (`get_screen`)
2. Remap Stitch MD3 color tokens to Arx CSS variables (primary -> Stone, surface -> Chamber, etc.)
3. Remove gradients, replace pure white with Starlight, add safe-area handling
4. Add Geist Mono / JetBrains Mono for numeric data
5. Output as a draft in `apps/web-prototype/drafts/` ready for `/build prototype` integration

**Exit Gate:** "Can you show the screen where the user feels relief from their pain?" — if not, the design doesn't solve the problem yet.

**Output:** Write design specs to `outputs/think/design/{feature_slug}.md`. Then suggest: "Promote to `specs/Arx_4-1-X_{Slug}.md`?" If new design tokens were introduced, suggest updating `specs/Arx_4-2_Design_System.md`. If new screens were added, suggest updating `specs/Arx_4-1-0_Experience_Design_Index.md`.

---

## system

**Purpose:** Update design system tokens. Manage the canonical design language.

**Process:**

1. Read `specs/Arx_4-2_Design_System.md` in full
2. Read `DESIGN.md` for current Stitch-consumable tokens
3. Read `apps/web-prototype/SOUL.md` for implementation constraints
4. Identify what needs updating based on Gary's input:
   - New color tokens
   - Typography scale changes
   - Spacing/sizing adjustments
   - Component pattern additions
   - Animation/motion tokens
5. Propose changes in a diff format: what's being added, modified, or deprecated
6. On approval, update `specs/Arx_4-2_Design_System.md`
7. Flag downstream files that need updating (DESIGN.md, CSS variables, component styles)

**Output:** Updated spec. List of downstream files to sync.

---

## sync

**Purpose:** Bidirectional sync between design system sources. Ensure consistency across all design artifacts.

**Sync chain:** `specs/Arx_4-2_Design_System.md` <-> `DESIGN.md` <-> Figma <-> Stitch

**Process:**

1. Read all four sources (where available):
   - `specs/Arx_4-2_Design_System.md` — canonical spec
   - `DESIGN.md` — Stitch-consumable format
   - Figma variables via `mcp__figma__get_variable_defs` (if Figma file connected)
   - Stitch project tokens via `mcp__stitch__list_projects`
2. Diff all sources against each other
3. Report discrepancies:

```
Sync Report:
  spec -> DESIGN.md: 3 tokens out of sync (Stone-600, spacing-xl, font-mono)
  spec -> Figma: 2 variables missing (accent-warning, radius-card)
  DESIGN.md -> Stitch: in sync
```

4. Propose resolution for each discrepancy (spec is source of truth)
5. On approval, update all downstream sources
6. Uses design-sync skill if available

**Output:** Sync report + updated files.

## Safety (when hooks unavailable)
Before any destructive command (rm -rf, git push --force, git reset --hard, DROP TABLE, kubectl delete, docker system prune), ALWAYS ask for explicit confirmation. Never auto-approve destructive operations.
