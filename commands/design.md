---
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

Parse the first word of `$ARGUMENTS` to route. If no match → ask: "What kind of design? card, ui, or system?"

**Intent confirmation (always).** Before planning, restate scope in one line: "I'll [sub-command] for [target], using [key constraints]. Proceed?" Skip only if Gary's input is already precise (e.g., exact spec ID or screen name).

---

## Before Designing (always)

1. Read `DESIGN.md` — the complete agent-consumable design language **(read this ONLY for most tasks)**
2. Consult `specs/Arx_4-3_Design_Taste.md` only for judgment calls not covered by DESIGN.md §6
3. Consult `specs/Arx_4-2_Design_System.md` only for token details beyond DESIGN.md §1

> **Why DESIGN.md first:** 380 lines synthesizing 2800+320 lines. Go to sources only for edge cases.

**Handoff (mandatory on approval):** When Gary approves the /design output, write `sessions/handoffs/design.json`:
```json
{"phase":"design","sub":"<sub-command>","output":"<path-to-artifact>","summary":"<one-line>","visual_ref":"<screenshot-or-url>","approved":true,"approved_at":"<ISO-8601>"}
```
This unlocks `/build` via the phase gate. See `specs/handoff-schemas.md`.

**Anti-slop rules (mandatory):**
- **Blacklist visuals:** Purple gradients, 3-column grids, generic hero sections, glassmorphism, floating shapes
- **Blacklist fonts:** Roboto, Poppins (Geist primary; Inter system fallback only)
- **SAFE vs RISK framing:** Label every decision. Default to RISK unless Gary says otherwise.
- **Reference floor:** Robinhood/eToro/Bitget/Phantom (S7), Moomoo/Webull/Binance (S2) — MINIMUM. Beat them.

---

## Synthesis boundary (INV-G10)

`/design` is synthesis. Every card/ui/system invocation must declare before producing:

```
IN SCOPE: [what this design produces]
OUT OF SCOPE: [adjacent design concerns handled elsewhere]
NEVER: [visual prohibitions — e.g., "no gradients" (INV from design system), "no hardcoded hex"]
INVARIANTS: [list INV-Gxx + DESIGN.md rules that apply]
```

For `/design card`: boundary is captured in the Product Half's Scope section — ensure IN/OUT/NEVER are explicit.
For `/design ui`: boundary is the visual contract — what screen, what feel token, what states.
For `/design system`: boundary is the token set being added/modified, and the propagation targets.

---

## Three Mandatory Gates (NON-SKIPPABLE)

### Gate -1: REFERENCE RESEARCH (before visual decisions)

1. Read `specs/Arx_4-3_Design_Taste.md` §1 for reference floor
2. Search 3+ reference implementations of the pattern
3. For each: what they do well, where they fall short, what Arx surpasses
4. Present findings. Gary picks direction before spec writing.

**Cannot be skipped.** Research every time.

### Gate 0: STATE MATRIX (before spec writing)

Generate the complete state matrix: `{screen} × {journey-state} × {data-state} × {edge-case} = all scenarios`. Use template from Arx_4-3 §8. Present for approval — this is the scenario contract.

### Gate 3c: FEEL PASS (after functional spec, before shipping)

Score each dimension 1-5. **Fix any ≤ 2.**

1. SCROLL RHYTHM — breathing points every 3-4 cards?
2. OPTICAL WEIGHT — heaviest element = most important info?
3. NEGATIVE SPACE — intentional, not lazy?
4. TYPOGRAPHY HIERARCHY — readable from weight/size alone?
5. MOTION NARRATIVE — choreography tells a story?

Then run **5 Premium Litmus Tests** from Arx_4-3 §2. Fix failures before proceeding.

**Gate enforcement checklist:**
```
[ ] Gate -1: Reference research logged (3+ apps)
[ ] Gate 0: State matrix generated and approved
[ ] Gate 3c: Feel Pass scored (all ≥ 3/5)
[ ] Litmus: 5 tests all PASS
```

---

**Plan mode by default.** Present approach before executing. Wait for approval.

**Scratchpad checkpoints:** On entry, after each gate, after plan approval, after each agent, after synthesis.

---

## card <screen>

**Purpose:** Author or update a complete build card for a screen.

**Process:**

1. **Check if card exists** at `specs/Arx_4-1-1-{module}_{screen}.md`
2. **If new:** Use template from `specs/Arx_0-1_Workflow_Workbook.md`
3. **Run Gate -1** (Reference Research)
4. **Run Gate 0** (State Matrix)
5. **Write REFERENCE section:** 2-3 specific screens from Arx_4-3 §1 tiers. Per reference: app, screen, what to adopt, where to surpass.
6. **Write PRODUCT half:** Why (trace to JTBD), What the User Does (3-7 steps with S7/S2 variants), Data (API source + computation), States (empty/loading/error/populated), Acceptance (EARS), Navigate (from/to with transitions), Verify
7. **Write VISUAL half:** Feel (token from DESIGN.md §6.9), Layout (ASCII wireframe with auto-layout annotations), Components (from Arx_4-2), Visual Spec (fixture pointer, icons, embellishments, interactions)
8. **Create/update mock data fixture** in `specs/Arx_4-1-1-8_Mock_Data_Fixtures.md`
9. **Run Build Card QA** checklist from Arx_0-1
10. **Run Gate 3c** on the Layout section

**Output:** Complete build card at `specs/Arx_4-1-1-{module}_{screen}.md`

---

## ui <screen|flow>

**Purpose:** Generate visual prototype from build card. Produces APPROVAL ARTIFACTS — Gary reviews before `/build` writes production code.

**Pipeline: Code-First, Figma-Second.**

Build in code first (fastest iteration, real interactions), then push to Figma for design handoff.

**Tool priority:** 1) HTML prototype + Claude Preview (always), 2) Figma MCP (after approval), 3) AIDesigner (exploration), 4) Stitch (alternatives)

**Pre-flight:** Build card exists? Feel section present? DESIGN.md current?

### Step 1: Gather Context — PEV (see `specs/pev-protocol.md`)

Spawn `pev-planner` with task_class=synthesis, pool hint:
- `spec-rag` — read build card + DESIGN.md + Arx_4-3, extract feel/palette/type/components
- `spec-rag` (2nd contract) — read Arx_4-1-1-8 fixtures, extract mock data for all 5 states
- Optional: `design-auditor` if screen already has prior prototypes (fold in lessons)

Planner writes roster. Execute in parallel. `pev-validator` checks the two artifacts are consistent (fixtures match components referenced). Output feeds Step 2.

### Step 2: Generate HTML Prototype
Dispatch subagent to write self-contained HTML file. Include: full build card content, ALL design tokens from DESIGN.md §1, Apple craft specs (animation curves, springs, glass tiers, micro-interactions), Inter + JetBrains Mono from CDN, 390×844 viewport, fixture data. Apply mandatory features from Apple Craft Reference: loading skeleton, price tick flash, list stagger-in, card tap feedback, glass cards, sparkline draw, all state transitions animated.

**Output:** `apps/web-prototype/{screen-slug}.html`

### Step 3: Preview Verify
Start preview server → navigate → set viewport 390×844 → wait for animations → screenshot → check console → test interactions → screenshot after interaction

### Step 4: Run Design Gates
Gate 3c (Feel Pass) + 5 Premium Litmus Tests. Fix issues → re-preview → re-check.

### Step 5: Present for Approval
Screenshot + interactions demonstrated + Apple craft applied + feel pass scores + litmus results. **Wait for Gary's approval before proceeding.**

### Step 6: Figma Recreation (post-approval, optional)
Use Figma MCP to recreate with design system components. Import components by key, bind variables (never hardcode hex), use auto-layout on all containers.

---

## system [add|update|audit]

**Purpose:** Maintain canonical design language — tokens, components, cross-source sync.

**Sub-actions:**
- `system add` — new token/component to Arx_4-2 → regenerate DESIGN.md
- `system update` — modify token values, propagate to all files
- `system audit` — check consistency, report drift
- `system sync` — regenerate DESIGN.md from Arx_4-2 + Arx_4-3 + build card registries

**Sync targets (propagate to ALL):**
1. `specs/Arx_4-2_Design_System.md` — canonical source
2. `specs/Arx_4-3_Design_Taste.md` — taste framework
3. `DESIGN.md` — **AUTO-GENERATED**, never hand-edit
4. Figma variables via MCP
5. `apps/web-prototype` CSS `:root` variables

**Audit — PEV (see `specs/pev-protocol.md`):**

Spawn `pev-planner` with task_class=verification, pool hint:
- `design-auditor` — token drift between Arx_4-2 and DESIGN.md
- `design-auditor` (2nd contract) — CSS `:root` in `apps/web-prototype/` vs Arx_4-2 (hardcoded hex, missing tokens)
- `design-auditor` (3rd contract) — build card component refs vs Arx_4-2 component registry
- Optional: `tool-scout` if new design tool (Figma MCP variable) changed the source of truth

Planner writes roster. Execute in parallel. `pev-validator` consolidates drift reports; any CRITICAL (e.g., hardcoded color in production) blocks with STUCK. Adjudicator synthesizes fix list for Gary.

---

---

## Design Convergence Loop (applies to card and ui)

After producing design output, run a tightening pass:

1. **Gate 3c (Feel Pass):** Score each dimension 1-5. Fix any <=2.
2. **5 Premium Litmus Tests** from Arx_4-3. Fix failures.
3. **If fixes made:** Re-screenshot, re-audit changed areas.
4. **If new issues found after fix:** Fix and re-audit again.
5. **Max 3 design-audit-fix cycles** before presenting to Gary.

This ensures design outputs meet the quality bar before Gary reviews them.
