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

## Plan Gate (mandatory — runs before ANY sub-command)

Before executing any design sub-command, present this to Gary and WAIT for confirmation:

> **PLAN:** [1-line restatement of what you'll design — comprehension check]
> **STEPS:**
> 1. [action] — [why this first]
> 2. [action] — [depends on #1]
> 3. [action] — [why]
> **REFS:** [which reference apps are relevant — from Arx_4-3 §1]
> **MEMORY:** [check L1_essential.md + relevant L2 files — "last design session: ...", "feedback rule: ..."]
> **RISK:** [biggest assumption or thing that could go wrong]
> **CONFIDENCE:** [high/medium/low] — [1-line reason]
>
> **Confirm?** [y / modify / abort]

After confirmation:
1. Write approved plan to `sessions/scratchpad.md` under `## Plan History`
2. Create TodoWrite items for each step
3. Begin execution step by step, updating TodoWrite as each completes

**Skip gate ONLY if:** Gary explicitly says "just do it" or the task is a quick token update.

---

## card <screen>

**Purpose:** Author or update a complete build card for a screen. The build card is the SINGLE SOURCE OF TRUTH for what gets built — combining product requirements and visual specification.

**Process:**

1. **Check if card exists:** Look for `specs/Arx_4-1-1-{module}_{screen}.md`
2. **If new:** Use template from `specs/Arx_0-1_Workflow_Workbook.md`
3. **Run Gate -1** (Reference Research) — research how reference apps handle this screen
4. **Run Gate 0** (State Matrix) — generate all scenarios before writing
5. **Write the REFERENCE section:**
   - `## Reference Screenshots` — cite 2-3 specific screens from Arx_4-3 §1 tiers. Per reference: app, screen, what to adopt, where to surpass. Include AI tool instruction line.
6. **Write the PRODUCT half:**
   - `## Why` — trace to JTBD + pain in Arx_2-1
   - `## What the User Does` — 3-7 numbered steps with S7/S2 variants
   - `## Data` — API source + computation for every visible element
   - `## States` — empty, loading, error, populated + persona variants
   - `## Acceptance (EARS)` — WHEN/SHALL testable criteria
   - `## Navigate` — from/to with triggers and transition type (`push-right`, `sheet-up`, `modal-center`, `fade`)
   - `## Verify` — test command
7. **Write the VISUAL half:**
   - `## Feel` — reference a feel token from DESIGN.md §6.9 (e.g., `Feel: feel:home`). Only add overrides if this screen deviates from the screen-type default. Do NOT redefine motion, density, or temperature inline.
   - `## Layout (Stitch-ready)` — ASCII wireframe with auto-layout annotations (`column`/`row`, `fill-w`/`hug`, `gap=Npx`). Use named type levels (Hero, Title, Body, Caption, Data), NOT raw px values.
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

**Pipeline: Code-First, Figma-Second.**

The 2026 paradigm: build in code first (fastest iteration, real interactions, Apple-level craft), then push to Figma for design handoff. This inverts the traditional design→code flow.

```
Build Card → HTML Prototype (code-first) → Preview Verify → Approve → Figma Recreation
     ↑              ↑                            ↑
   specs/      DESIGN.md +              Claude Preview at
               Apple Craft Ref           390×844 viewport
```

**Tool priority (primary → fallback):**

| Priority | Tool | When | Output |
|---|---|---|---|
| **1 (Primary)** | HTML prototype + Claude Preview | Always — fastest iteration, real interactions | `apps/web-prototype/{screen}.html` |
| **2 (Handoff)** | Figma MCP `use_figma` | After approval — design system components | Figma file URL |
| **3 (Explore)** | AIDesigner MCP | Creative exploration, moodboarding | HTML + PNG |
| **4 (Alt)** | Stitch MCP | Alternative directions | HTML via stitch-design skill |

**Pre-flight checks:**

- [ ] Build card exists for this screen? If not → run `card` first
- [ ] Build card has `## Feel` section? If not → add feel token reference
- [ ] DESIGN.md is current? Check `Last generated:` date in header
- [ ] Apple Craft Reference exists? `outputs/think/design/Apple_Design_Craft_Reference.md`

### The Code-First Pipeline

#### Step 1: Gather Context (parallel reads)

Read in parallel:
- Build card: `specs/Arx_4-1-1-{module}_{screen}.md`
- Design system: `DESIGN.md` (primary, 380 lines)
- Apple craft: `outputs/think/design/Apple_Design_Craft_Reference.md` (animation curves, glass specs, micro-interactions)
- Fixture data: `specs/Arx_4-1-1-8_Mock_Data_Fixtures.md`
- Feel token: look up the card's `## Feel` token in DESIGN.md §6.9

#### Step 2: Generate HTML Prototype

Dispatch a subagent with `mode: bypassPermissions` to write a single self-contained HTML file.

**Agent prompt must include:**
- Full build card content (layout, data, states, components, acceptance)
- ALL design tokens from DESIGN.md §1 (surfaces, colors, text, borders, semantic, regime)
- Apple craft specs: animation curves, spring presets, glass tiers, micro-interactions
- Typography stack: Inter + JetBrains Mono from Google Fonts CDN
- Viewport: `<meta name="viewport" content="width=390">` + 390×844 frame
- Fixture data: exact values from Arx_4-1-1-8 (no improvisation)

**Mandatory prototype features (from Apple Craft Reference):**

| Feature | Spec |
|---|---|
| Loading skeleton | 1.5-2s shimmer, left-to-right gradient sweep, then stagger-reveal |
| Price tick flash | 150ms color flash + 400ms fade to neutral, every 1.5-2s |
| List stagger-in | Items fade + slide up, 40ms stagger between rows |
| Card tap feedback | Scale to 0.97-0.98 on press, spring back 200ms |
| Glass cards | `backdrop-filter: blur(20px) saturate(150%)`, 3-layer shadow, stone-tinted |
| Tab indicator slide | 250ms spring easing between tab positions |
| Sparkline draw | SVG path draws left-to-right, 600ms ease-out-expo |
| Swipe-to-action | Touch swipe left reveals action button, 200ms |
| Search focus expand | Bar expands, Cancel appears, background dims, 300ms |
| All state transitions | Every state change animated — no instant visual pops |

**Mandatory CSS tokens:**
```css
--ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
--ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);
--ease-spring: cubic-bezier(0.17, 0.89, 0.32, 1.28);
--duration-instant: 100ms;
--duration-fast: 200ms;
--duration-normal: 300ms;
--duration-slow: 500ms;
```

**Output:** `apps/web-prototype/{screen-slug}.html`

#### Step 3: Preview Verify

1. Start preview server: `preview_start` → `arx-prototype`
2. Navigate to the screen: `preview_eval` → `window.location.href = 'http://localhost:8080/{screen-slug}.html'`
3. Set viewport: `preview_resize` → 390×844
4. Wait for load + animations: 3-4 seconds
5. Screenshot: `preview_screenshot`
6. Check console: `preview_console_logs` → no errors
7. Test interactions: `preview_click` on tabs, search, cards
8. Screenshot after interaction to verify animation states

**Quality checklist (from screenshot):**
- [ ] Dark violet surfaces, no pure black/white/navy
- [ ] Stone for actions, Water for data — never mixed
- [ ] Glass cards have visible blur + 3-layer shadow
- [ ] Prices in mono font with tabular-nums
- [ ] Real minus (−) not hyphen (-)
- [ ] Positive green, Negative red on data only
- [ ] 44px minimum touch targets
- [ ] Content within 390px, safe areas respected
- [ ] Regime indicators visible and color-coded
- [ ] Typography hierarchy clear from weight/size alone

#### Step 4: Run Design Gates

1. **Gate 3c: Feel Pass** — Score 1-5 on scroll rhythm, optical weight, negative space, typography hierarchy, motion narrative. Fix any ≤ 2.
2. **5 Premium Litmus Tests** from Arx_4-3 §2.
3. If issues found → edit HTML → re-preview → re-screenshot → re-check.

#### Step 5: Present for Approval

```
VISUAL CHECKPOINT: {screen}
[screenshot from Claude Preview]

Interactions demonstrated: {list}
Apple craft applied: {skeleton, price ticks, stagger-in, glass, springs}

Key design decisions:
- {decision 1}: {why}
- {decision 2}: {why}

Feel Pass: {scores}/5 per dimension
Litmus: {PASS/FAIL per test}

Approve this visual? Or adjust before we build.
```

Wait for approval. Do NOT proceed to `/build` or Figma until Gary says "go."

#### Step 6: Figma Recreation (post-approval, optional)

After approval, recreate in Figma using design system components for handoff.

1. Load `figma:figma-use` + `figma:figma-generate-design` skills
2. Use existing Figma file: `pG8iP5irNjYfGbkce31d9V`
3. Create new page named `{Screen ID} — {Screen Name}`
4. Build incrementally (one section per `use_figma` call):
   - Import components from the Components page by key
   - Bind variables (colors, spacing, radii) — never hardcode hex
   - Use auto-layout on all containers
   - Return all created node IDs
5. Screenshot each section for verification
6. Screenshot full screen, compare against HTML prototype

**Figma API gotchas (from research):**
- Set `layoutSizingHorizontal/Vertical = 'FILL'` AFTER `appendChild`
- Colors: 0-1 range (divide hex by 255)
- Font loading: `await figma.loadFontAsync({ family: "Inter", style: "Semi Bold" })` — note the space in "Semi Bold"
- Fills are immutable arrays — clone, modify, reassign
- `setBoundVariableForPaint` returns a NEW paint — capture it
- Page context resets between calls — always `await figma.setCurrentPageAsync(page)` first

**For flows:** Generate linked screens. Each screen follows the same pipeline.

**Output:** HTML prototype path + (optionally) Figma file URL.

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
