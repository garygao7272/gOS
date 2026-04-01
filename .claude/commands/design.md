---
description: "Design mode: research, sketch, ui, motion, system, audit, render, sync — 5-stage design pipeline with persona-driven audit"
---

# Design Mode — 5-Stage Pipeline + Utilities → outputs/think/design/ → specs/

**All visual and interaction design work. Maps to a 5-stage pipeline: Research → Prototype → UI Design → Design System → Implementation.**

**The master command `/design <brief>` IS the holistic workflow.** It runs the full pipeline with stage gates between each step. Individual sub-commands are entry points into specific stages when you know exactly what you need.

## Pipeline Overview

| Stage             | Sub-command | Question                               | Tools                                       |
| ----------------- | ----------- | -------------------------------------- | ------------------------------------------- |
| 1. UX Research    | `research`  | Who uses it and what hurts?            | WebSearch, specs, persona simulation        |
| 2. Prototyping    | `sketch`    | What could it look like?               | Stitch MCP (generate, variants, edit, flow) |
| 3. UI Design      | `ui`        | What does it look like at pixel level? | Stitch, Figma MCP, shadcn MCP, design swarm |
| 3b. Motion        | `motion`    | How does it move and feel?             | Framer Motion, Rive, animation tokens       |
| 4. Design System  | `system`    | Are tokens and components consistent?  | Style Dictionary, specs/Arx_4-2, DESIGN.md  |
| 5. Implementation | `render`    | How does it translate to code?         | shadcn MCP, Storybook, arx-ui-stack         |
| — Audit           | `audit`     | Does it work for Sarah and Jake?       | Persona walkthrough, journey tracing        |
| — Utility         | `sync`      | Are all sources in harmony?            | design-sync skill, Figma MCP                |

**Output routing:**

| Sub-command       | Output To                                         | Then                                                |
| ----------------- | ------------------------------------------------- | --------------------------------------------------- |
| (no args / brief) | Full pipeline with stage gates                    | Each stage outputs to its own file                  |
| `research`        | `outputs/think/design/{slug}-research.md`         | "Promote personas to `specs/Arx_2-1`?"              |
| `sketch`          | `outputs/think/design/{slug}-sketch.md`           | "Go deeper with `ui` or explore `sketch variants`?" |
| `ui`              | `outputs/think/design/{slug}-ui.md`               | "Promote to `specs/Arx_4-1-X_{Slug}.md`?"           |
| `motion`          | `outputs/think/design/{slug}-motion.md`           | "Merge into `specs/Arx_4-1-X` motion section?"      |
| `system`          | Direct update to `specs/Arx_4-2_Design_System.md` | No staging                                          |
| `render`          | Code scaffold in `apps/`                          | "Ready for `/build feature`"                        |
| `audit`           | `outputs/think/design/{slug}-audit.md`            | "Fix findings? Run `/design ui` to address?"        |
| `sync`            | Sync report + updated files                       | No output file                                      |

**Before designing (always):**

1. Read `specs/Arx_4-3_Design_Taste.md` for judgment framework and feel targets **(READ FIRST)**
2. Read `specs/Arx_4-2_Design_System.md` for existing tokens
3. Read `DESIGN.md` for Stitch-consumable design language
4. Read `apps/web-prototype/SOUL.md` for design philosophy

**Anti-slop rules (mandatory — see 4-3 §6 for the full list):**

- **Blacklist visuals:** Purple gradients, 3-column feature grids, generic hero sections, stock imagery, glassmorphism cards, floating abstract shapes
- **Blacklist fonts:** Inter, Roboto, Poppins (unless explicitly chosen by Gary)
- **SAFE vs RISK framing:** For every design decision, label it SAFE (conventional, expected) or RISK (bold, differentiated). Default to RISK unless Gary says otherwise.
- **The AI test:** "If it looks like it was made by AI, reject it."
- **Reference floor:** Robinhood/eToro/Bitget/Phantom (S7), Moomoo/Webull/Binance (S2) are the MINIMUM. Beat them.

**Three mandatory gates (NEW — v5.5):**

These gates are NON-SKIPPABLE. They run before, during, and after the design pipeline.

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
If a cell is uncovered later, it's a spec gap that the audit will catch and that should have been prevented here.

### Gate 3c: FEEL PASS (after functional spec, before audit)

After the functional spec is complete but BEFORE running the audit:

Score each dimension 1-5. **Fix any ≤ 2 before proceeding.**

1. **SCROLL RHYTHM:** Where does the eye rest? Breathing points every 3-4 cards?
2. **OPTICAL WEIGHT:** Heaviest element matches most important information?
3. **NEGATIVE SPACE:** Empty space is earned (intentional) not lazy (forgot)?
4. **TYPOGRAPHY HIERARCHY:** Hierarchy readable from weight/size alone (cover colors)?
5. **MOTION NARRATIVE:** What enters first? Does choreography tell a story?

Then run the **5 Premium Litmus Tests** from `specs/Arx_4-3_Design_Taste.md` §2 on the complete screen.
If any litmus test fails, fix before proceeding to audit.

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

Parse the first word of `$ARGUMENTS` to determine sub-command. If it matches a recognized sub-command (research, sketch, ui, motion, system, render, audit, sync), route to that stage. **If it does NOT match a sub-command, treat the entire argument as a design brief and run the holistic workflow.**

---

## Holistic Workflow: `/design <brief>` (Master Command)

**Purpose:** Complete design pipeline from research to implementation scaffolds. This IS the holistic workflow — each stage gates to the next, Gary approves transitions.

**Process:**

1. **Stage 1 — Research:** Run `/design research <brief>`. Present findings. Ask: "Ready for sketches?"
2. **Stage 2 — Sketch:** Run `/design sketch <brief>`. Show screens. Ask: "Pick a direction, or explore variants?"
3. **Stage 2b — Variants (if requested):** Run `/design sketch variants`. Compare. Pick winner.
4. **Stage 3 — UI:** Run `/design ui <winner>`. Full pixel-level spec. Ask: "Ready for motion?"
5. **Stage 3b — Motion:** Run `/design motion <screens>`. Animation specs. Ask: "Ready for audit?"
6. **Audit Gate:** Run `/design audit <screens>`. Persona walkthrough. Fix any findings.
7. **Stage 4 — System:** Check if new tokens needed. Run `/design system add` if so.
8. **Stage 5 — Render:** Run `/design render <screens>`. Code scaffolds.
9. **Sync:** Run `/design sync` to propagate changes.

**Each stage transition requires explicit approval.** Gary can skip stages, jump to any stage, or abort at any point. The pipeline suggests but never auto-advances.

---

## Stage 1: research <topic or screen>

**Purpose:** UX research before visual design. Personas, journey maps, pain points, usability findings.

**Swarm mode (3 agents in parallel):**

1. **`persona-analyst` (sonnet):** Read `specs/Arx_2-1`. Map feature to personas (P1 Jake, S2, S7). For each: current pain, desired outcome, success metric, emotional state before/during/after.

2. **`journey-mapper` (sonnet):** Map the user journey:
   - Trigger → Steps → Friction points → Emotional arc
   - Cross-reference with `specs/Arx_4-1-0` for existing flows
   - Identify the MOMENT OF RELIEF — where does the pain stop?

3. **`evidence-gatherer` (sonnet):** Search for:
   - Competitor UX patterns (WebSearch, Firecrawl)
   - Usability research (Nielsen Norman, Baymard)
   - App store reviews from `outputs/think/research/`
   - Accessibility requirements (WCAG 2.1 AA)

**Synthesis:** Merge into UX research brief with:

- Persona impact matrix
- Journey map with annotated friction points
- Competitor pattern analysis
- Design requirements (MoSCoW)
- Open questions

**Exit Gate:** "Can you name the specific person, the specific moment, and the specific relief this design creates?"

**Output:** `outputs/think/design/{slug}-research.md`

---

## Stage 2: sketch <description> [variants|flow]

**Purpose:** Rapid visual exploration via Stitch MCP. Quantity over quality.

### sketch (single screen)

1. Load `stitch-design` skill for Arx-aware generation
2. Call `mcp__stitch__generate_screen_from_text` with DESIGN.md context
3. Present the Stitch screen

### sketch variants <screen-ref> [refine|explore|reimagine] [layout|color|typography|content]

Generate 3-5 alternatives via `mcp__stitch__generate_variants`. Present side by side with SAFE/RISK labels.

### sketch flow <screen-ids...>

Connect screens via `mcp__stitch__edit_screens` with navigation, transitions, back buttons.

**Output:** `outputs/think/design/{slug}-sketch.md`

### sketch visual <section-name> (Visual Checkpoint — no Stitch required)

**Purpose:** Build a minimal visual draft of ONE section directly in the prototype for Gary's visual approval before full implementation. This is the Visual Checkpoint from conductor Phase 3.5. Works without Stitch MCP.

**When to use:**

- Before implementing any UI change in `apps/web-prototype/`
- As part of `/gos` conductor Phase 3.5
- When you need Gary to SEE a design before building it

**Process:**

1. Read the approved plan + design system (`specs/Arx_4-2_Design_System.md`) + `SOUL.md`
2. Build ONLY the section being sketched — not the full page
3. Inject into the running prototype temporarily, or create in `apps/web-prototype/drafts/`
4. Screenshot via `preview_screenshot`
5. Present to Gary with explicit callouts:

   ```
   VISUAL CHECKPOINT: {section-name}
   [screenshot]

   Key design decisions:
   - {decision 1}: {why}
   - {decision 2}: {why}

   Approve this visual? Or adjust before I build the full feature.
   ```

6. Wait for approval — do NOT proceed without explicit "go"
7. If adjustments → modify → re-screenshot → re-present
8. Save approved screenshot reference to scratchpad under `## Visual Checkpoints`

**Anti-patterns:**

- Do NOT skip for "small" changes — they compound
- Do NOT batch more than 3 sections — visual fatigue kills feedback
- Do NOT present without callouts — Gary needs to know WHAT to evaluate
- Do NOT proceed on silence — explicit approval required

---

## Stage 3: ui <brief or screen-ref>

**Purpose:** Pixel-level design production. All states, responsive behavior, visual polish.

**Design Swarm (3 agents in parallel):**

1. **Agent 1 (mobile-design-engine):** Screen design, all states (default/loading/empty/error/overflow/disabled), density classification per persona
2. **Agent 2 (ui-ux-pro-max):** Design system compliance, anti-pattern detection, information density calibration (S2 HIGH density, S7 LOW density)
3. **Agent 3 (Anthropic Design Suite):** design-interaction + canvas-design. Bold, non-generic, anti-AI-aesthetic.

**Synthesis:** Majority rules. Always pick the bolder choice. Produce complete screen spec with layout grid, all states, typography map, color usage, touch targets.

**Stitch → HTML Bridge:** Convert winner to `apps/web-prototype/drafts/`.

**Exit Gate:** "Can you show the screen where the user feels relief?"

**Output:** `outputs/think/design/{slug}-ui.md`

---

## Stage 3b: motion <screen-ref or feature>

**Purpose:** Animation and interaction design. Spring parameters, transition choreography, gesture responses.

**For each interaction, specify:**

- Trigger, animation type, parameters, purpose, performance budget
- Categorize by temperature: T0 Ice (80% — subtle) / T1 Cool (15% — transitions) / T2 Warm (4% — milestones) / T3 Hot (1% — celebrations)

**Gesture mapping (mobile):**

- Swipe L/R → navigation, pull-down → refresh, long-press → context menu, pinch → zoom

**Produce Framer Motion + Rive code snippets** ready for `/design render` or `/build`.

**Output:** `outputs/think/design/{slug}-motion.md`

---

## Stage 4: system [add|update|deprecate|audit]

**Purpose:** Manage the canonical design language.

**Token pipeline:** Figma (Tokens Studio) → W3C DTCG JSON → Style Dictionary v4 → CSS variables + Tailwind config + React Native theme

- `system add <token-type> <definition>` — Propose new token
- `system update <token-name> <new-value>` — Modify existing token
- `system deprecate <token-name>` — Mark for removal
- `system audit` — Full consistency scan across specs, prototype CSS, and code

**On change:** Update `specs/Arx_4-2`, run `sync`, flag downstream files.

**Output:** Updated spec + downstream sync report.

---

## Stage 5: render <screen-ref> [--target web|mobile|both]

**Purpose:** Design → code scaffolds. Output is a design artifact, not production code.

### --target web (HTML for prototype)

Map tokens to CSS variables. Generate single-file HTML in `apps/web-prototype/drafts/`.

### --target mobile (React Native)

Generate component scaffolds with TypeScript types, NativeWind classes, Framer Motion animations, Zustand state hooks (placeholder), accessibility labels. Storybook stories included.

### --target both

Web first (fast verify), then mobile.

**Token mapping auto-applied:** Design Token → CSS Variable → Tailwind Class → React Native value.

**Exit gate:** Scaffold compiles. Static render matches design.

**Output:** Scaffold files + Storybook stories.

---

## Audit: `/design audit <screen-ref or "all">`

**Purpose:** Persona-driven design quality gate. Works BACKWARDS from the persona to evaluate every touchpoint. Not a checklist — a simulated user experience.

**This is NOT a code review or accessibility scan.** This is: "Walk through this screen AS Sarah (S7) and AS Jake (S2) and tell me where it fails them."

### Process

**For each persona (S7 Sarah, S2 Jake, and optionally S1 Alex, S3 Marcus):**

#### Step 1: Customer Journey Trace

Starting from the persona's TRIGGER (why are they on this screen?), trace the complete journey:

- What brought them here? (Previous screen, notification, external link)
- What is their emotional state on arrival? (Anxious, curious, rushed, bored)
- What is the ONE THING they need from this screen? (The job-to-be-done)
- How many seconds until they find it? (Measure in taps and scroll distance)

#### Step 2: Information Architecture Audit

For every element visible on the screen, ask:

- Does this persona UNDERSTAND this element? (Vocabulary check — S7 at C1-C2)
- Does this persona NEED this element? (Relevance check — is it for them or the other persona?)
- Is this element in the RIGHT POSITION? (Hierarchy check — most important = most prominent?)
- Is there a MISSING element this persona expects? (Gap check)

Score each element: ESSENTIAL / USEFUL / NOISE / MISSING

#### Step 3: Copy Audit

For every user-facing string:

- **Clarity:** Can this persona understand it in under 2 seconds?
- **Voice:** Does it match the Arx voice? (Confident, clear, protective — like a skilled navigator)
- **Action orientation:** Does the CTA tell the persona what HAPPENS, not what to DO?
- **Emotional resonance:** Does the copy address the persona's FEELING, not just their task?
- **Jargon check:** Any terms that require C3+ capability to understand?

#### Step 4: Flow & Interaction Audit

- **Primary action:** Is it obvious? Can the persona find it in <3 seconds?
- **Secondary actions:** Are they discoverable but not competing?
- **Escape hatches:** Can the persona go back, undo, or dismiss?
- **Error recovery:** If something goes wrong, does the screen help?
- **Progressive disclosure:** Is complexity hidden appropriately for this persona?
- **Cross-navigation:** Are links to related screens discoverable? (Exploration Trinity check)

#### Step 5: Emotional Arc Validation

Map the persona's emotional state through the screen:

```
Entry state → First impression → Key discovery → Action taken → Exit state
(anxious)    → (oriented)       → (informed)    → (confident)  → (relieved)
```

If the arc doesn't end in RELIEF or CONFIDENCE, the design has failed.

### Output Format

```markdown
## Design Audit: {screen} — Persona: {name}

### Journey Trace

- **Trigger:** {why they're here}
- **Emotional entry:** {feeling on arrival}
- **Job:** {the one thing they need}
- **Time to job:** {seconds/taps}

### Information Architecture

| Element   | Understand? | Need? | Position?                  | Verdict                          |
| --------- | ----------- | ----- | -------------------------- | -------------------------------- |
| {element} | {Y/N + why} | {Y/N} | {correct/too low/too high} | {ESSENTIAL/USEFUL/NOISE/MISSING} |

### Copy

| String   | Clarity | Voice            | Action | Emotion | Jargon?    | Fix       |
| -------- | ------- | ---------------- | ------ | ------- | ---------- | --------- |
| "{copy}" | {1-5}   | {match/mismatch} | {Y/N}  | {Y/N}   | {Y/N term} | {rewrite} |

### Flow

- **Primary action clarity:** {score 1-10}
- **Escape hatches:** {present/missing}
- **Error recovery:** {present/missing}
- **Cross-nav:** {discoverable/hidden/absent}

### Emotional Arc

{Entry} → {Impression} → {Discovery} → {Action} → {Exit}
**Arc verdict:** {HEALTHY / BROKEN at {stage}}

### Fatal Flaws

1. {the one thing that would make this persona close the app}

### Verdict: {PASS / REFINE / REDESIGN}
```

**Run for BOTH personas** (S7 and S2) on every screen. If verdicts conflict, note the tension and recommend which persona to optimize for (default: S7, since they're 95% of users).

---

## Utility: sync

**Purpose:** Bidirectional sync between design system sources.

**Sync chain:** `specs/Arx_4-2` ↔ `DESIGN.md` ↔ Figma (Tokens Studio) ↔ Style Dictionary ↔ Stitch

1. Load `design-sync` skill
2. Read all sources, diff against each other
3. Report discrepancies (spec is source of truth)
4. On approval, update all downstream sources

**Output:** Sync report + updated files.

---

## Pipeline Composition

```
/design <brief>                          → Full holistic pipeline with gates
/design research copy-trading            → Stage 1 only
/design sketch onboarding               → Stage 2 only
/design sketch variants <id> explore     → Stage 2 variants
/design sketch flow <id1> <id2>          → Stage 2 flow
/design ui onboarding                    → Stage 3 only
/design motion trade-execution           → Stage 3b only
/design system audit                     → Stage 4 audit
/design system add color new-token       → Stage 4 add
/design render <ref> --target both       → Stage 5 only
/design audit home-screen                → Persona audit
/design audit all                        → Full app persona audit
/design sync                             → Utility sync
```

## Interaction With Other Commands

| Command            | Relationship                                                          |
| ------------------ | --------------------------------------------------------------------- |
| `/think discover`  | Upstream — produces product brief that `/design research` consumes    |
| `/think research`  | Upstream — market research feeds competitive analysis                 |
| `/review design`   | Downstream — visual QA at ship time (NOT the same as `/design audit`) |
| `/review council`  | Downstream — design-variant persona reviews final design              |
| `/build prototype` | Downstream — consumes `/design render --target web`                   |
| `/build feature`   | Downstream — consumes `/design render --target mobile`                |

**`/design audit` ≠ `/review design`.** Audit happens DURING design (formative). Review happens BEFORE ship (summative). The designer audits their own work against personas. The reviewer grades the final output independently.

## Output Contract Extension: Litmus Exit Gate

**Applies to ALL sub-commands that produce visual output (sketch, ui, motion, render, holistic).**

Before presenting ANY design output to Gary, run this mandatory scoring:

### Step 1: Feel Pass (5 dimensions, score 1-5 each)

| Dimension            | Score | Notes                                                      |
| -------------------- | ----- | ---------------------------------------------------------- |
| Scroll Rhythm        | {1-5} | Where does the eye rest? Breathing points every 3-4 cards? |
| Optical Weight       | {1-5} | Heaviest element = most important information?             |
| Negative Space       | {1-5} | Empty space is earned (intentional) not lazy (forgot)?     |
| Typography Hierarchy | {1-5} | Hierarchy readable from weight/size alone?                 |
| Motion Narrative     | {1-5} | What enters first? Does choreography tell a story?         |

**If any dimension ≤ 2:** Fix before proceeding. Do not present output with known feel failures.

### Step 2: Premium Litmus Tests (5 tests, pass/fail each)

From `specs/Arx_4-3_Design_Taste.md` §2:

| Test             | Result      | Issue (if fail)              |
| ---------------- | ----------- | ---------------------------- |
| $10M Test        | {PASS/FAIL} | {what looks cheap}           |
| Screenshot Test  | {PASS/FAIL} | {what's not share-worthy}    |
| Ive's Care Test  | {PASS/FAIL} | {what's default/unearned}    |
| Empty State Test | {PASS/FAIL} | {what breaks without data}   |
| 3-Second Test    | {PASS/FAIL} | {what's unclear at a glance} |

**If any litmus test FAILS:** Fix the specific issue before presenting. Log what was fixed.

### Step 3: Present with scores

Include in the output header:

```
📊 Quality: {screen-name}
   Completeness: {N}/5 | Evidence: {N}/5 | Actionability: {N}/5 | Accuracy: {N}/5 | Clarity: {N}/5
   Boldness: {N}/5
   Feel: Rhythm {N} | Weight {N} | Space {N} | Type {N} | Motion {N}
   Litmus: {N}/5 passed
   ⚠️ Weakest: {dimension} — {one-line explanation}
```

**Self-calibration reminder (from self-model.md):** When you rate design output 4/5, apply -1. It's probably 3/5. Run the litmus tests honestly — if you hesitate on any test, it's a fail.

---

## Safety

Before any destructive command, ALWAYS ask for explicit confirmation.
