---
effort: high
description: "Design: card (author build card), ui (visualize via Figma/AIDesigner/Stitch MCPs), system (design tokens + components)"
---

# Design — Build Card + Visual Design → specs/ + Figma + prototypes

**Design owns the build card — the central artifact of the Arx 3-layer workflow. It authors cards, generates visual prototypes, and maintains the design system.**

**3 sub-commands:**

| Sub-command | Question | Tools | Output |
|---|---|---|---|
| `card` | What are we building? | Specs, fixtures, DESIGN.md | `specs/Arx_4-1-1-X_*.md` + fixture entry |
| `ui` | What does it look like? | Figma MCP, AIDesigner, Stitch, shadcn | Figma file, HTML prototype, screenshots |
| `system` | Are tokens consistent? | Style Dictionary, Arx_4-2, DESIGN.md, Figma MCP | Updated design system files |

Parse the first word of `$ARGUMENTS` to determine sub-command. If matches card/ui/system → route. If no match → ask: "What kind of design? card (author build card), ui (visualize it), or system (update tokens)?"

**Output routing:**

| Sub-command | Output To |
|---|---|
| `card` | `specs/Arx_4-1-1-{module}_{screen}.md` + fixture in `Arx_4-1-1-8` |
| `ui` | Figma file URL, `apps/web-prototype/drafts/{screen}.html`, or screenshots |
| `system` | Direct update to `specs/Arx_4-2_Design_System.md` + `DESIGN.md` |

---

## Before Designing (always)

1. Read `DESIGN.md` — the complete agent-consumable design language **(READ THIS ONLY for most tasks)**
2. Consult `specs/Arx_4-3_Design_Taste.md` only when making judgment calls not covered by DESIGN.md §6
3. Consult `specs/Arx_4-2_Design_System.md` only when you need token details beyond DESIGN.md §1

> **Why DESIGN.md first:** It's 380 lines synthesizing 2800 lines of 4-2 + 320 lines of 4-3. Reading all three wastes context. DESIGN.md is the compiled output — go to sources only for edge cases.

**Anti-slop rules (mandatory — see DESIGN.md §6.3 and 4-3 §6 for full list):**

- **Blacklist visuals:** Purple gradients, 3-column feature grids, generic hero sections, stock imagery, glassmorphism cards, floating abstract shapes
- **Blacklist fonts:** Roboto, Poppins (Geist is primary; Inter is acceptable as system fallback only)
- **SAFE vs RISK framing:** For every design decision, label it SAFE (conventional, expected) or RISK (bold, differentiated). Default to RISK unless Gary says otherwise.
- **The AI test:** "If it looks like it was made by AI, reject it."
- **Reference floor:** Robinhood/eToro/Bitget/Phantom (S7), Moomoo/Webull/Binance (S2) are the MINIMUM. Beat them.

---

## Three Mandatory Gates (NON-SKIPPABLE)

These gates apply to BOTH `card` and `ui` sub-commands. They run before, during, and after the design pipeline.

### Gate -1: REFERENCE RESEARCH (before any visual decisions)

Before any screen spec or visual design decision:

1. Read `specs/Arx_4-3_Design_Taste.md` §1 for the reference floor
2. Search 3+ reference implementations of the pattern being designed
3. For each: what they do well, where they fall short, what Arx should surpass
4. Present: "Here's how [apps] handle this. Here's where Arx beats them."
5. Gary picks direction before spec writing begins.

Sources: App Store screenshots, Mobbin, Dribbble, competitor apps, WebSearch.
**This gate cannot be skipped.** "I already know how this works" is not an excuse — research every time.

### Gate 0: STATE MATRIX (before any spec writing)

Before writing ANY screen spec, generate the complete state matrix:

```
{screen} × {journey-state} × {data-state} × {edge-case} = all scenarios
```

Use the template from `specs/Arx_4-3_Design_Taste.md` §8.
Present matrix for approval. This is the SCENARIO CONTRACT — every cell must be addressed in the spec.

### Gate 3c: FEEL PASS (after functional spec, before shipping)

After the spec/visual is complete but BEFORE declaring done:

Score each dimension 1-5. **Fix any ≤ 2 before proceeding.**

1. **SCROLL RHYTHM:** Where does the eye rest? Breathing points every 3-4 cards?
2. **OPTICAL WEIGHT:** Heaviest element matches most important information?
3. **NEGATIVE SPACE:** Empty space is earned (intentional) not lazy (forgot)?
4. **TYPOGRAPHY HIERARCHY:** Hierarchy readable from weight/size alone (cover colors)?
5. **MOTION NARRATIVE:** What enters first? Does choreography tell a story?

Then run the **5 Premium Litmus Tests** from `specs/Arx_4-3_Design_Taste.md` §2 on the complete screen.
If any litmus test fails, fix before proceeding.

---

---

## Gate Enforcement (NON-NEGOTIABLE)

Before outputting any design artifact, verify this checklist. If any gate was skipped, go back and run it. Do not proceed.

```
[ ] Gate -1 DONE: Reference research logged in scratchpad (3+ apps researched)
[ ] Gate 0 DONE: State matrix generated and approved
[ ] Gate 3c DONE: Feel Pass scored (all dimensions ≥ 3/5)
[ ] Litmus DONE: 5 Premium Litmus Tests all PASS
```

**If context is tight and gates feel expensive:** Gate -1 can use cached research from a previous session for the same screen type. Gates 0, 3c, and Litmus cannot be cached — they must run on the current artifact.

---

**Plan mode by default.** Present the design approach before executing. Wait for approval.

**Scratchpad checkpoints.** Update `sessions/scratchpad.md`:

- **On entry:** Write current task, mode (`Design > {sub-command}`), and input
- **After Gate -1:** Log reference research findings to `Working State`
- **After Gate 0:** Log state matrix to `Working State`
- **After plan approval:** Write the approved approach to `Working State`
- **After each agent completes:** Log agent name + key output to `Agents Launched`
- **After Gate 3c:** Log feel pass scores and litmus results to `Working State`
- **After synthesis:** Write design decisions to `Key Decisions Made This Session`

---

## card <screen>

**Purpose:** Author or update a complete build card for a screen. The build card is the SINGLE SOURCE OF TRUTH for what gets built — combining product requirements and visual specification.

**Process:**

1. **Check if card exists:** Look for `specs/Arx_4-1-1-{module}_{screen}.md`
2. **If new:** Use template from `specs/Arx_0-1_Workflow_Workbook.md`
3. **Run Gate -1** (Reference Research) — research how reference apps handle this screen
4. **Run Gate 0** (State Matrix) — generate all scenarios before writing
5. **Write the PRODUCT half:**
   - `## Why` — trace to JTBD + pain in Arx_2-1
   - `## What the User Does` — 3-7 numbered steps with S7/S2 variants
   - `## Data` — API source + computation for every visible element
   - `## States` — empty, loading, error, populated + persona variants
   - `## Acceptance (EARS)` — WHEN/SHALL testable criteria
   - `## Navigate` — from/to with triggers
   - `## Verify` — test command
6. **Write the VISUAL half:**
   - `## Layout (Stitch-ready)` — using named type levels from Arx_4-2 (Hero, Title, Body, Caption, Data), NOT raw px values. Reference design tokens by name.
   - `## Components (from Arx_4-2)` — named component references
   - `## Visual Spec` — fixture pointer, icons (from DESIGN.md §3), embellishments (from DESIGN.md §4), interactions (from DESIGN.md §5), tab bar treatment
7. **Create/update mock data fixture** in `specs/Arx_4-1-1-8_Mock_Data_Fixtures.md`
8. **Run Build Card QA** checklist from Arx_0-1
9. **Run Gate 3c** (Feel Pass) on the Layout section

**Output:** Complete build card at `specs/Arx_4-1-1-{module}_{screen}.md`

**Exit gate:** "This card ready for `/design ui`? All sections complete, fixture created, QA passed?"

---

## ui <screen|flow>

**Purpose:** Generate a visual prototype from an enriched build card. Produces APPROVAL ARTIFACTS, not production code. Gary reviews the visual and approves before `/build` writes production code.

**Tool selection (auto or explicit):**

| Tool | When to Use | Output |
|---|---|---|
| **Figma MCP** (primary) | Production-quality, token-bound, component-aware | Figma file URL via `figma:figma-generate-design` |
| **AIDesigner MCP** | Rapid creative exploration, rich embellishments | HTML + PNG via `generate_design` + `refine_design` |
| **Stitch MCP** | Material-style clean exploration, alternative directions | HTML via stitch-design skill with DESIGN.md injection |
| **HTML prototype** (fallback) | When MCPs unavailable | Single file in `apps/web-prototype/drafts/` |

**Process:**

1. **Read the build card** + fixture data from Arx_4-1-1-8
2. **Read design system:** DESIGN.md, Arx_4-2, Arx_4-3 taste
3. **Run Gate -1** (if not already done for this screen)
4. **Generate visual** via chosen tool(s):
   - Feed build card content + design tokens + fixture data as context
   - Viewport: 390x844 (iPhone 14 Pro)
   - All values from fixture (exact — no improvisation)
   - All icons from DESIGN.md §3 icon registry
   - All embellishments from DESIGN.md §4 embellishment registry
5. **Screenshot** at 390x844
6. **Run Gate 3c** (Feel Pass) — score 5 dimensions, fix any ≤ 2
7. **Run 5 Premium Litmus Tests** from Arx_4-3 §2
8. **Present to Gary:**
   ```
   VISUAL CHECKPOINT: {screen}
   [screenshot or Figma URL]

   Key design decisions:
   - {decision 1}: {why}
   - {decision 2}: {why}

   Tool used: {Figma MCP / AIDesigner / Stitch / HTML}
   Approve this visual? Or adjust before we build.
   ```
9. **Wait for approval.** Do NOT proceed to `/build` until Gary says "go" or gives adjustments.
10. If adjustments → modify → re-screenshot → re-present

**For flows:** Generate linked screens. Each screen follows the same process.

**Motion/animation:** If the card's Visual Spec defines animations (e.g., `card-entry: fade-up 200ms stagger(50ms)`), the HTML prototype should demonstrate them. Figma designs note them as annotations.

**Output:** Figma file URL, HTML file path, or screenshots for approval.

---

## system [add|update|audit]

**Purpose:** Maintain the canonical design language — tokens, components, and cross-source sync.

**Sub-actions:**

- `system add` — Add a new token or component to Arx_4-2 → regenerate DESIGN.md
- `system update` — Modify existing token values (propagate to all files)
- `system audit` — Check consistency across all design sources. Report drift.
- `system sync` — Regenerate DESIGN.md (procedure below)

**Sync targets (when tokens change, propagate to ALL):**

1. `specs/Arx_4-2_Design_System.md` — canonical source of truth (human-edited)
2. `specs/Arx_4-3_Design_Taste.md` — taste framework (human-edited)
3. `DESIGN.md` — **AUTO-GENERATED** from 4-2 + 4-3 + build card registries. Never hand-edit.
4. Figma variables — via `figma:figma-generate-library` or `use_figma` with `get_variable_defs`
5. `apps/web-prototype` CSS `:root` variables

### system sync procedure

1. Read `specs/Arx_4-2_Design_System.md` §2 (colors), §3 (typography), §4 (spacing), §5 (elevation), §7 (motion), §8 (icons)
2. Read `specs/Arx_4-3_Design_Taste.md` §1 (reference floor), §2 (litmus tests), §3 (feel targets), §6 (anti-patterns)
3. Scan all `specs/Arx_4-1-1-*` build cards for icon and embellishment additions not yet in DESIGN.md
4. Regenerate `DESIGN.md` with 7-section structure, updating the `Last generated:` date in the header
5. Verify: diff the new DESIGN.md against the old — report what changed
6. If Figma MCP available: compare Figma variables against DESIGN.md §1 tokens — report drift

> **When to run:** After any edit to 4-2 or 4-3. After adding a new build card with new icons/embellishments. Before any `/design ui` session.

**Tools:** Style Dictionary, Figma MCP (get_variable_defs, use_figma, search_design_system), shadcn MCP, design-sync skill.

**Audit checks:**
- Token values match across all 5 targets
- Component names match between Arx_4-2, build cards, and Figma
- Icon registry in DESIGN.md §3 covers all card types referenced in build cards
- No hardcoded colors in build card Layout sections (should be token names)
- DESIGN.md is in sync with 4-2 + 4-3 sources (check generated header date)

---

## Safety (when hooks unavailable)
Before any destructive command (rm -rf, git push --force, git reset --hard, DROP TABLE, kubectl delete, docker system prune), ALWAYS ask for explicit confirmation. Never auto-approve destructive operations.
