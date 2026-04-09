---
description: "Design mode: quick sketch, variants, flow, full pipeline, render to code, system tokens, sync, org (team structure), process (workflows) — visual, interaction, and organizational design"
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
| `render` | Code scaffold in `apps/` | Ready for `/build feature` |
| `system` | Direct update to `specs/Arx_4-2_Design_System.md` | No staging |
| `sync` | Bidirectional sync | No output file |
| `org` | `outputs/think/design/{slug}-org.md` | Suggest: "Promote to org spec?" |
| `process` | `outputs/think/design/{slug}-process.md` | Suggest: "Build playbook with `/build playbook`?" |

**Before designing (always):**
1. Read `specs/Arx_4-2_Design_System.md` for existing tokens
2. Read `DESIGN.md` for Stitch-consumable design language
3. Read `apps/web-prototype/SOUL.md` for design philosophy

**Anti-slop rules (mandatory):**
- **Blacklist visuals:** Purple gradients, 3-column feature grids, generic hero sections, stock imagery, glassmorphism cards, floating abstract shapes
- **Blacklist fonts:** Inter, Roboto, Poppins (unless explicitly chosen by Gary)
- **SAFE vs RISK framing:** For every design decision, label it SAFE (conventional, expected) or RISK (bold, differentiated). Default to RISK unless Gary says otherwise.
- **The AI test:** "If it looks like it was made by AI, reject it." Every screen must have a specific, opinionated point of view that a generic model would not produce.

**Intent Gate by default.** Present the design approach via the Intent Gate before executing. Restate, plan, wait for confirmation. See Intent Gate section below.

**Scratchpad checkpoints.** Update `sessions/scratchpad.md` at these moments:
- **On entry:** Write current task, mode (`Design > {sub-command}`), and input
- **After plan approval:** Write the approved approach to `Working State`
- **After each agent completes:** Log agent name + key output to `Agents Launched`
- **After synthesis:** Write design decisions to `Key Decisions Made This Session`
- **On dead end:** Append to `Dead Ends (don't retry)`
- **After compaction:** Re-read `sessions/scratchpad.md` to restore state

Parse the first word of `$ARGUMENTS` to determine sub-command. If no sub-command given, ask: "What kind of design? quick sketch, variant exploration, flow prototype, full design, org, or process?"

---

## Intent Gate (mandatory — runs before any sub-command)

**First-Principles Decomposition.** Every request is broken into 6 MECE dimensions before execution.

### Step 1: DECOMPOSE

Parse Gary's request. Fill every dimension and classify:

| Dim | Question | ✅ Stated | 🔮 Inferred | ❌ Unknown |
|-----|----------|-----------|-------------|-----------|
| **WHAT** | What are we designing? (screen, flow, system, component) | Gary named it | Derivable from context | Must ask |
| **WHY** | What outcome? (explore, refine, spec, render to code) | Gary stated purpose | Implied by sub-command | Must ask |
| **WHO** | Who is this for? (S7 follower, S2 leader, both, internal) | Gary specified | Obvious from screen type | Must ask |
| **HOW** | What method? (quick sketch, variants, full swarm, system update) | Gary chose sub-command | Matches complexity | Must ask |
| **SCOPE** | Which parts? (single screen, flow, full app, design tokens) | Gary bounded it | Inferrable from context | Must ask |
| **BAR** | What standard? (exploratory, production-spec, pixel-perfect) | Gary set the bar | Implied by stage | Must ask |

### Step 2: PRESENT & CLARIFY

Show the decomposition:

> | Dim | Value | Status |
> |-----|-------|--------|
> | WHAT | {target} | ✅/🔮/❌ |
> | WHY | {purpose} | ✅/🔮/❌ |
> | WHO | {audience} | ✅/🔮/❌ |
> | HOW | {approach} | ✅/🔮/❌ |
> | SCOPE | {boundary} | ✅/🔮/❌ |
> | BAR | {standard} | ✅/🔮/❌ |

- **❌ Unknown** → ask ONE batched question covering all unknowns
- **🔮 Inferred** → state for confirmation
- **All ✅/🔮** → skip to Step 3

### Step 3: PLAN

> **Plan: Design > {sub-command}**
> - **Scope:** {WHAT + SCOPE resolved}
> - **Reads:** {design system, DESIGN.md, SOUL.md, specs}
> - **Writes:** {output file path}
> - **Agents:** {N-agent team / swarm / single agent}
> - **Output:** {format → destination, promotion suggestion}

**Before presenting "Go?":** Write to `sessions/scratchpad.md`:
- Update `## Current Task` with the resolved WHAT
- Update `## Mode & Sub-command` with the command > sub-command
- Update Pipeline State: `- [x] Intent Gate: WHAT={what} | WHY={why} | WHO={who} | HOW={how} | SCOPE={scope} | BAR={bar}`

### Step 4: CONFIRM
> **Go?**

**HARD STOP.** End your message here. Do NOT:
- Add a "preview" or "meanwhile" or "while you decide"
- Start producing output in the same message
- Say "Go?" and then keep writing

The message containing "Go?" must contain NOTHING after it. Wait for Gary's next message before doing any work.

### Step 5: PLAN MODE (mandatory after Gary confirms)

When Gary confirms ("go", "yes", "do it"), you MUST call `EnterPlanMode` before doing ANY work. This is not optional. This is deterministic:

```
Gary says "go" → call EnterPlanMode() → write plan to plan file → call ExitPlanMode() → Gary approves → THEN execute
```

**Exceptions (skip plan mode):**
- `--auto` flag (mobile/scheduled dispatch)
- Trust level T2+ for this domain
- Sub-commands marked `[skip-gate]`
- `quick` sub-command (fast sketch, not worth planning)

**[skip-gate]:** Any sub-command with `--auto` flag (mobile/scheduled dispatch).

---

## Taste Checkpoint (runs after Intent Gate, before Context Protocol)

Before designing, specify the taste profile for THIS task. See `gOS/.claude/taste.md` for the full reference.

1. **Primary persona:** Which persona's taste governs this screen? (S2 maximalist or S7 minimalist?) Reference the Persona Taste Profiles table in taste.md.

2. **Taste axes:** Where does this screen sit on each of the 5 axes?
   - Density: minimalist ← → maximalist
   - Warmth: cool/precise ← → warm/humanized
   - Authority: authoritative ← → transparent
   - Innovation: conservative ← → experimental
   - Control: guided ← → customizable

3. **Taste boundaries:** What would violate the taste even if technically correct? (e.g., "No tooltips on a pro trading dashboard — respect the expertise")

4. **Reference benchmark:** "This should feel like ___" (name a real product or screen — e.g., "Linear's issue detail" or "Bloomberg's command palette")

If the taste profile conflicts with the design system, flag the tension explicitly.

**Write to scratchpad:** `Taste: {primary persona} | {axes summary} | Benchmark: {reference}`

---

## Context Protocol (runs after Taste Checkpoint, before execution)

After the Intent Gate resolves all 6 dimensions, auto-load relevant context. See `gOS/.claude/context-map.md` for the full keyword → source mapping. Note: taste.md is now auto-loaded for all design keywords.

1. Parse resolved WHAT and SCOPE for keywords
2. Match against context map → candidate sources
3. Check file existence (skip missing silently)
4. Estimate token cost (lines / 4)
5. If total < 30% of remaining context → load silently
6. If total > 30% → present list and ask Gary to trim
7. Log loaded context to `sessions/scratchpad.md` under `Working State`
8. **Write scratchpad marker:** Update `sessions/scratchpad.md` Pipeline State: `- [x] Context Loaded: {list of files loaded or "none needed"}`

---

## Memory Recall (runs after Context Protocol, before Trust Check)

Query persistent memory for relevant past experience before executing. This is how gOS learns across sessions.

1. **Search claude-mem** for the current command + domain:
   - `mcp__plugin_claude-mem_mcp-search__search({ query: "{WHAT} {sub-command}", type: "observation", limit: 5 })`
   - Also search: `mcp__plugin_claude-mem_mcp-search__search({ query: "{domain} {sub-command} signal", limit: 3 })`
2. **Check self-model** for domain competence:
   - Read the row for `{domain}` in `.claude/self-model.md`
   - If accept rate < 70% or weaknesses listed → flag: "Note: my `{domain}` has {weakness}. Adjusting approach."
3. **Surface relevant findings:**
   - If past sessions had reworks/rejects in this domain → mention what went wrong and how you'll avoid it
   - If past sessions had accepts/loves → mention what worked and reuse the approach
   - If no relevant history → say "No prior experience in this domain — running full pipeline."
4. **Write scratchpad marker:** Update Pipeline State: `- [x] Memory Recalled: {N} observations, self-model: {domain} T{N} {accept_rate}`

**Keep it brief.** One line of insight, not a paragraph. The goal is to inform execution, not to recite history.

---

## Trust Check (runs after Context Protocol, before Pipe Resolution)

Check trust level for the current domain. See `gOS/.claude/trust-ladder.md` for rules.

1. Infer domain from resolved WHAT (e.g., "redesign copy trading screen" → `design-decisions`)
2. Read `sessions/trust.json` → get trust level for this domain
3. Adjust gate depth accordingly (T0=full, T1=lighter confirm, T2=execute-first, T3=silent)
4. Show trust context: "Trust: `{domain}` at T{N} ({history summary})"
5. **Write scratchpad marker:** Update Pipeline State: `- [x] Trust Level: T{N} for {domain}`

---

## Pipe Resolution (runs after Context Protocol, before execution)

Check for upstream artifacts that match the current task. See `gOS/.claude/artifact-schema.md` for the full schema and algorithm.

1. Parse WHAT from resolved intent
2. Search `outputs/` for files with matching topic in YAML frontmatter
3. Filter by types relevant to `/design`: research-brief, decision
4. If found: present list and auto-load as context ("📎 Upstream artifacts found...")
5. If not found: proceed without — design can start from brief alone
6. Update `outputs/ARTIFACT_INDEX.md` after writing output
7. **Write scratchpad marker:** Update Pipeline State: `- [x] Pipe Resolved: {N} upstream artifacts loaded` or `- [x] Pipe Resolved: none found`

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

**Team decision:**
- If design touches high-stakes screens (trading, copy trading, payments): Create team `design-full-{slug}` with 3 specialist teammates
- Otherwise: Use ad-hoc subagents (current behavior)

**If team mode:** After Stitch phases complete, create team for synthesis. Named teammates: `mobile-ux` (sonnet), `visual-design` (sonnet), `interaction-spec` (haiku). Lead adjudicates conflicts: "mobile-ux says card density HIGH, visual-design says MEDIUM. Which for S7 persona?" via `SendMessage`.

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

---

## render <screen-ref> [--target web|mobile|both]

**Purpose:** Translate a design output into platform-ready code scaffolds. Bridges the gap between "what it looks like" and "what you build it with." No more manual translation from design specs to components.

**Input:** A screen reference — either a design output file path, a screen name from a previous `/design` session, or a spec reference (e.g., `Arx_4-1-1-3`).

**Default target:** `mobile` (React Native + Tailwind). Use `--target web` for HTML/CSS, `--target both` for both.

**Before rendering (always):**
1. Load the `arx-ui-stack` skill for package versions, CDNs, and usage patterns
2. Read `specs/Arx_4-2_Design_System.md` for token-to-code mappings
3. Read the design output being rendered (from `outputs/think/design/` or Stitch screen)

**Process:**

### For `--target web` (HTML/CSS for `apps/web-prototype/`)

1. Extract design specs: colors, typography, spacing, layout, states
2. Map design tokens to CSS variables:
   ```
   Design spec: "Stone-600 border"  → var(--color-stone-600)
   Design spec: "8px padding"       → var(--spacing-2)
   Design spec: "Geist Mono"        → var(--font-mono)
   ```
3. Generate single-file HTML with:
   - CSS variables from design system
   - Semantic HTML structure
   - All states (loading, empty, error, populated, disabled)
   - Mobile-first layout (390x844)
   - No inline styles for state toggles (use CSS classes)
4. Output to `apps/web-prototype/drafts/{screen-name}-v1.html`
5. Anti-slop check before saving

### For `--target mobile` (React Native for `apps/mobile/`)

1. Extract design specs: colors, typography, spacing, layout, states, interactions
2. Map design tokens to the mobile stack:
   ```
   Design spec: "Stone-600 border"  → className="border-stone-600" (NativeWind/Tailwind)
   Design spec: "8px padding"       → className="p-2"
   Design spec: "Geist Mono"        → fontFamily: "GeistMono" (pre-loaded in app)
   Design spec: "slide-in from right" → Framer Motion: { initial: {x: 100}, animate: {x: 0} }
   ```
3. Generate component scaffold:
   ```
   apps/mobile/src/screens/{ScreenName}.tsx     ← Screen component
   apps/mobile/src/components/{Feature}/         ← Extracted sub-components
   ```
4. Include:
   - Correct imports (React Native, NativeWind, Framer Motion, Zustand)
   - TypeScript types for props and state
   - All visual states as separate render branches
   - Placeholder hooks (e.g., `useCopyTradeLeaders()`) with TODO comments
   - Accessibility labels
5. Do NOT include business logic — only the visual scaffold. `/build feature` fills in logic.

### For `--target both`

Run web and mobile in sequence. Web first (faster to verify visually), then mobile.

**Token mapping table (auto-applied):**

| Design Token | CSS Variable | Tailwind Class | React Native |
|-------------|-------------|----------------|-------------|
| Stone-50 | `--color-stone-50` | `stone-50` | `colors.stone[50]` |
| Stone-600 | `--color-stone-600` | `stone-600` | `colors.stone[600]` |
| spacing-1 (4px) | `--spacing-1` | `p-1` / `m-1` | `4` |
| spacing-2 (8px) | `--spacing-2` | `p-2` / `m-2` | `8` |
| font-mono | `--font-mono` | `font-mono` | `"GeistMono"` |
| font-sans | `--font-sans` | `font-sans` | `"GeistSans"` |
| radius-sm | `--radius-sm` | `rounded-sm` | `borderRadius: 4` |
| radius-md | `--radius-md` | `rounded-md` | `borderRadius: 8` |

Extend this table from `specs/Arx_4-2_Design_System.md` on each render.

**Output:**

```
Render: {screen-name} → mobile
  Created: apps/mobile/src/screens/CopyTradeLeaderboard.tsx (scaffold)
  Created: apps/mobile/src/components/CopyTrade/LeaderCard.tsx
  Created: apps/mobile/src/components/CopyTrade/index.ts (exports)

  Tokens mapped: 14 design tokens → Tailwind classes
  States covered: loading, empty, populated, error
  Placeholders: useCopyTradeLeaders() hook (TODO)

  Next: /build feature "copy trading leaderboard" to fill in logic and tests
```

**Exit gate:** The scaffold must compile without errors (no missing imports, no type errors). It should render a static version of the design with placeholder data. If it doesn't compile, fix before outputting.

**Output:** Sync report + updated files.

---

## org <structure or question>

**Purpose:** Design organizational structures — team composition, reporting lines, role definitions, and growth plans. Visual + strategic org design.

**Input:** Description of what to design (e.g., "engineering team for 10 people", "startup org chart", "add a product team", "restructure for Series A")

**Process:**

1. Parse the org design request from remaining `$ARGUMENTS`
2. Update scratchpad: `Design > org`, request
3. **Research phase:**
   - Search for org structures at similar-stage companies
   - Review existing team composition (check `outputs/think/hire/`)
   - Understand product roadmap dependencies on team structure
4. **Design the org:**

```markdown
# Org Design: {description}

## Current State
{current team, if known}

## Proposed Structure

### Executive / Leadership
```
CEO (Gary)
├── CTO / Head of Engineering
│   ├── Senior Frontend Engineer
│   ├── Senior Backend Engineer
│   └── Junior Engineer (intern/contractor)
├── Head of Product
│   └── Product Designer
└── Head of Growth
    └── Community Manager
```

### Role Definitions
| Role | Level | Key Responsibilities | Reports To | Hires When |
|------|-------|---------------------|-----------|-----------|
| {role} | {IC/Manager} | {top 3 responsibilities} | {who} | {trigger for this hire} |

### Growth Phases
| Phase | Headcount | Key Hires | Trigger |
|-------|-----------|-----------|---------|
| Current | {N} | — | — |
| +6mo | {N} | {roles} | {revenue/funding milestone} |
| +12mo | {N} | {roles} | {revenue/funding milestone} |
| +18mo | {N} | {roles} | {revenue/funding milestone} |

### Communication Structure
- **All-hands:** {frequency}
- **1:1s:** {who meets whom, frequency}
- **Stand-ups:** {teams, frequency}
- **Decision-making:** {how decisions are made at each level}

### Budget Impact
| Phase | Monthly Payroll | Annual Cost | Revenue Required |
|-------|----------------|-------------|-----------------|

## Alternatives Considered
{2-3 alternative structures with trade-offs}

## Risks
| Risk | Mitigation |
|------|-----------|
```

5. **Generate visual diagram** using Mermaid (via `generate_diagram` if available):
   - Org chart as a graph
   - Color-code by department/function

**Output:** Write to `outputs/think/design/{slug}-org.md`. Optionally generate diagram. Suggest: "Build hiring plan with `/simulate hiring`?" or "Write JDs with `/think hire`?"

---

## process <workflow>

**Purpose:** Design operational workflows and business processes. Visual process maps with decision points, owners, and SLAs.

**Input:** Process to design (e.g., "customer onboarding", "bug triage", "content publishing", "incident response", "deal pipeline", "sprint planning")

**Process:**

1. Parse the process design request from remaining `$ARGUMENTS`
2. Update scratchpad: `Design > process`, request
3. **Research phase:**
   - Search for industry-standard processes for this workflow
   - Review existing processes in the project
   - Identify stakeholders and systems involved
4. **Design the process:**

```markdown
# Process Design: {workflow}

## Purpose
{Why this process exists — what goes wrong without it}

## Trigger
{What starts this process — event, schedule, or request}

## Owner
{Primary owner responsible for the process}

## Process Map

### Happy Path
1. **{Step 1}** — Owner: {role} — SLA: {time}
   - Input: {what's needed}
   - Action: {what happens}
   - Output: {what's produced}
   - → Go to Step 2

2. **{Step 2}** — Owner: {role} — SLA: {time}
   - Input: {from step 1}
   - Action: {what happens}
   - Decision: If {condition A} → Step 3a, If {condition B} → Step 3b
   ...

### Exception Paths
| Exception | Detection | Response | Escalation |
|-----------|----------|----------|-----------|
| {what goes wrong} | {how detected} | {immediate action} | {who to escalate to} |

## Systems & Tools
| Step | Tool/System | Integration |
|------|-----------|------------|

## Metrics & KPIs
| Metric | Target | Measurement |
|--------|--------|------------|
| Cycle time | {target} | {how measured} |
| Error rate | <{%} | {how measured} |
| Throughput | {N/period} | {how measured} |

## Automation Opportunities
| Step | Current | Automatable? | Effort | Impact |
|------|---------|-------------|--------|--------|
```

5. **Generate visual diagram** using Mermaid:
   - Flowchart with decision nodes
   - Swimlanes by role/team

**Output:** Write to `outputs/think/design/{slug}-process.md`. Generate Mermaid diagram. Suggest: "Build the playbook with `/build playbook`?" or "Review compliance with `/review compliance`?"

---

## Creative Friction Check (runs after execution, before Output Contract)

See `gOS/.claude/creative-friction.md`. Design is where "obvious" solutions are most dangerous.

Before presenting, check: (1) Does the design converge on a template/safe pattern when the brief calls for RISK? → propose a bolder alternative with reference benchmark. (2) Does the layout look like competitors instead of Arx? → flag with taste.md Cheap vs Premium test. (3) Is there a missed persona opportunity? → surface it.

Max ONE friction per task. Tie to `taste.md` for justification. Suppress if Gary said "just" or "quick".

---

## Output Contract (MANDATORY — runs after execution, before presenting)

**You MUST complete all steps before showing output to Gary.** See `gOS/.claude/output-contract.md` for the full rubric.

1. Score on 5 universal dimensions (1-5): Completeness, Evidence, Actionability, Accuracy, Clarity
2. Score on Design extension: **Boldness** (1-5) — RISK vs SAFE ratio (target: >60% RISK)
3. Identify weakest dimension
4. If any dimension ≤ 2 → flag and offer to improve before Gary reads
5. Skip Confidence Calibration for design outputs (boldness is subjective, not claim-based)
6. Present scorecard at top of output
7. **Write YAML frontmatter** to the output file (per `gOS/.claude/artifact-schema.md`):
   ```yaml
   ---
   artifact_type: design-spec | code-scaffold
   created_by: /design {sub-command}
   created_at: {ISO timestamp}
   topic: {WHAT from intent}
   related_specs: [{matched specs}]
   quality_score: {scores from step 1-2}
   status: draft
   ---
   ```
8. **Update `outputs/ARTIFACT_INDEX.md`** — add or update entry for this artifact
9. **Write scratchpad markers:** Update Pipeline State:
   - `- [x] Output Scored: {avg}/5 (weakest: {dimension})`
   - `- [x] Frontmatter Written: {path}`
   - `- [x] Index Updated: {topic} added to ARTIFACT_INDEX`

---

## Red Team Check (runs after Output Contract, before presenting)

**Design red team question:** "What would a frustrated user say about this interface?"

1. Run the red team question against the draft output
2. If a genuine issue is found (would change Gary's decision):
   a. Fix it if possible (adjust the design)
   b. If not fixable: flag in output header with ⚔️ marker
3. If finding is LOW confidence or wouldn't change any decision → suppress (no noise)
4. **Write scratchpad marker:** Update Pipeline State: `- [x] Red Team Passed: {question asked} → {finding or "clean"}`

---

## Signal Capture (MANDATORY — after every execution)

**After presenting output, observe Gary's NEXT response and classify the signal.**

1. Classify Gary's response as one of:
   - `accept` — used output without changes, moved on
   - `rework` — "change this", "not quite", "try again"
   - `reject` — "no", "scratch that", "wrong approach"
   - `love` — "perfect", "great", "exactly", "hell yes"
   - `repeat` — same instruction given twice (gOS didn't learn)
   - `skip` — Gary jumped past a prescribed step

2. **Log to `sessions/evolve_signals.md`:**
   | Time | Command | Sub-cmd | Signal | Context |
   |------|---------|---------|--------|---------|

3. **Update `sessions/trust.json`** — adjust trust level for the current domain per `gOS/.claude/trust-ladder.md`:
   - `accept`/`love` → increment consecutive accept count
   - `rework`/`reject` → reset count, demote if threshold hit
   - Check progression rules (T0→T1 needs 3+ consecutive accepts)

4. If `repeat` detected → immediately update relevant command file or memory
5. If `love` detected → save the approach to feedback memory for reuse
6. **Write scratchpad marker:** Update Pipeline State: `- [x] Signal Captured: {signal type} for {domain}`
