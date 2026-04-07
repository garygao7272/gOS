# Arx_0-1 — Workflow Workbook

<!-- AGENT: This is the operating manual for Arx's 3-layer development workflow.
     Key files: specs/Arx_0-1_Workflow_Workbook.md
     Dependencies: Arx_0-0, all strategy + build card files
-->

| Property       | Value                                                |
| -------------- | ---------------------------------------------------- |
| **ID**         | 0.1                                                  |
| **Owner**      | CEO / Product                                        |
| **Group**      | 0 — Meta                                             |
| **Status**     | Living Document                                      |
| **Created**    | 2026-04-04                                           |
| **Upstream**   | Arx_0-0 (Artifact Architecture)                      |
| **Downstream** | All spec creation, all gOS commands, all build work   |

---

## Why This Exists

Arx uses a 3-layer workflow (Strategy → Build Card → Code) designed for AI-assisted development. This workbook defines how to use it — the steps, templates, quality gates, and gOS commands for each layer. Without it, the workflow degrades into ad-hoc file creation.

---

## The 3-Layer Model

```
┌─────────────────────────────────────────┐
│  STRATEGY — the WHY (write once)         │
│  "Who are we building for, what hurts,   │
│   what's our edge, how does it look?"    │
│                                          │
│  Change trigger: new persona, new market,│
│  pivot, competitive shift                │
│  gOS: /think (research, discover, decide, │
│  spec, intake), /simulate (market,       │
│  scenario)                               │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  BUILD CARD — the WHAT+HOW (per screen)  │
│  "What does the user see, do, and get?"  │
│                                          │
│  Change trigger: new feature, UX change, │
│  data source change, design system update│
│  gOS: /design (card, ui, system),        │
│  /refine (convergence loop)              │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  CODE — the SHIP (generated)             │
│  "Component + test + navigation"         │
│                                          │
│  Change trigger: build card updated      │
│  gOS: /build (feature, fix, refactor),   │
│  /review (code, design, gate, council,   │
│  eval), /ship (commit, pr, deploy)       │
└─────────────────────────────────────────┘
```

---

## Layer 1: Strategy — How to Write and Maintain

### What lives here

| Artifact | ID | Purpose | Update trigger |
|----------|----|---------|---------------|
| Personas + JTBDs + Pains | Arx_2-1 | WHO + WHY + WHAT HURTS | New user research, persona validation |
| Journey Maps | Arx_3-3 | WHERE in adoption arc | Post-launch cohort data |
| PRD (exec shell) | Arx_3-2 | Business model, metrics, competitive | Quarterly review |
| Epic Map (THE index) | Arx_3-4 | Story→screen→signal traceability | Any screen/card added or removed |
| Design System | Arx_4-2 | Tokens, components, motion | New component or token needed |
| GTM Positioning | Arx_8-1 | Claims→pains→proof | Messaging change or new competitor |
| Master Architecture | Arx_4-1-1-0 | Tab bar, navigation, global components | Tab or flow structure change |

### Strategy Layer Template

When adding to the strategy layer, use this checklist:

```markdown
## New Strategy Artifact Checklist

- [ ] Does it trace to a user pain in Arx_2-1?
- [ ] Is there a JTBD it serves?
- [ ] Is it linked in the epic map (Arx_3-4)?
- [ ] Does it use IDs from the 7-layer hierarchy (S{n}, JTBD-S{n}-{nn}, E{n}, P{n})?
- [ ] Is it referenced in 0-0's artifact matrix?
- [ ] Single source of truth — no content duplicated from another spec?
```

### gOS Commands for Strategy

| Command | What it does |
|---------|-------------|
| `/think research <topic>` | Research → outputs/think/research/ |
| `/think decide <question>` | Decision → Arx_9-1 decision log |
| `/think spec <area>` | Spec draft → outputs/think/ → promote to specs/ |
| `/simulate market` | MiroFish scenario → outputs/briefings/ |
| `/refine <topic>` | Gap-hunt strategy layer → gap list |

---

## Layer 2: Build Cards — How to Write and Maintain

### Naming Convention

```
Arx_4-1-1-{module}_{screen-id}.md

Module numbers:
  1 = Onboarding + Funding (A*, B*)
  2 = Home + Markets (C1-R0, C2, C3)
  3 = Trade (TH, C5*, C6, C7)
  4 = Traders (D*)
  5 = You + Systems (E1, H1, P1, S1, SEC1)
  6 = AI Copilot (G1)
  F = Flow cards

Examples:
  Arx_4-1-1-1_A0-welcome.md
  Arx_4-1-1-4_D1-discover-leaders.md
  Arx_4-1-1-F_first-copy-S7.md
```

### Build Card Template

```markdown
# BUILD: {Screen ID} — {Screen Name}

<!--
  Build Card v1.0
  One card = one screen = one /build = one PR
  Target: 50-80 lines. If >100, split the screen.
  Source: Strategy layer + archived stories/screen specs
-->

## Why
> {JTBD-S{n}-{nn}}: "{one-line job statement}"
> Pain: {E/P code} — {one sentence}
> Persona: {S2 / S7 / Shared}

## What the User Does
1. {action} → {system response}
2. {action} → {system response}
3. [S7]: {variant} / [S2]: {variant}

## Layout (Stitch-ready)
\```
[viewport: 390x844, safe-area: top 59px, bottom 34px]

HEADER: {sticky/scrollable}, {material}
  ├── {element}: "{content}" ({--token-ref})
  └── {element}

CONTENT: {scroll behavior}
  ├── {Component from 4-2}
  │   ├── {sub-element} ({--token})
  │   └── {sub-element} ({--token})
  └── {Component from 4-2}

FOOTER: {sticky/none}
  └── CTA: "{label}" ({style})
\```

## Data
| Element | Source | Computation |
|---------|--------|-------------|
| {visible element} | {API/field} | {formula or "raw"} |

## States
- **Empty:** {what appears}
- **Loading:** {skeleton/shimmer pattern}
- **Error:** {fallback + retry}
- **Populated:** {default view}

## Components (from Arx_4-2)
- {ComponentName} — {usage}

## Visual Spec (optional — omit for simple screens)

Fixture: {screen-id}  ← links to Arx_4-1-1-8_Mock_Data_Fixtures.md
Icons: {component}: lucide:{name}, ...
Embellishments:
  - {card/component}: {accent-border left 3px {color} | top 3px {color} | icon-circle | none}
  - section-header: "{TEXT}" — Caption, --color-text-secondary, letter-spacing 0.1em
Interactions:
  - {element} tap → {navigate(screen) | bottomSheet(name) | dismiss}
  - {element} swipe-left → {action | none}
  - card-entry: {fade-up 200ms stagger(50ms) | none}
  - pull-to-refresh: {haptic + spinner | none}
Tab bar: trade-button = {elevated-circle | flat-text}

> **Guidance:** Include this section for screens with feed cards, data visualization,
> or complex component layouts. Omit for onboarding screens (A0-A4), simple forms,
> and settings pages. See Arx_4-1-1-8 for the fixture file format.

## Acceptance (EARS)
- WHEN {trigger} THE SCREEN SHALL {behavior}
- WHEN {error} THE SCREEN SHALL {fallback}

## Verify
\```bash
npm test -- --grep "{screen-id}"
\```

## Navigate
- **From:** {screen} (on {trigger})
- **To:** {screen} (on {trigger})
```

### Flow Card Template

```markdown
# FLOW: {Flow Name} ({Persona})

> {One-line description}
> Persona: {S2/S7/Shared} | JTBDs: {list} | Timeline: {timeframe}

## Steps
1. → {Screen} (BUILD: {card-filename}) — {what happens}
2. → {Screen} (BUILD: {card-filename}) — {what happens}

## Key Transition Points
| From → To | Trigger | Tab Switch? |
|-----------|---------|-------------|

## End-to-End Verify
\```bash
npm run e2e -- --flow "{flow-name}"
\```

## Success Criteria
- WHEN {condition} THE SYSTEM SHALL {end state}
```

### Build Card Quality Checklist

Before marking a build card as ready for `/build`:

```markdown
## Build Card QA

- [ ] Why section traces to a JTBD and pain code from Arx_2-1
- [ ] User flow has 3-7 numbered steps (not more)
- [ ] Layout uses design tokens from Arx_4-2 (no hardcoded colors/sizes)
- [ ] Layout specifies viewport (390x844) and safe areas
- [ ] Data table has Source and Computation for every visible element
- [ ] All 4 states defined (empty, loading, error, populated)
- [ ] Components reference Arx_4-2 by name
- [ ] EARS criteria are testable (WHEN/SHALL, no vague "should")
- [ ] Verify section has a runnable test command
- [ ] Navigate section has from/to with triggers
- [ ] S2/S7 variants called out inline (not duplicated)
- [ ] Total lines < 100 (split if over)
- [ ] No duplicate content from another card or strategy spec
```

### gOS Commands for Build Cards

| Command | What it does |
|---------|-------------|
| `/design card <screen>` | Author or update a complete build card (product + visual) |
| `/design ui <screen>` | Generate visual prototype from card (Figma MCP, AIDesigner, Stitch) |
| `/design system` | Update design tokens + components (Arx_4-2, DESIGN.md) |
| `/refine <module>` | Audit build cards for gaps, enrich Visual Spec |
| `/build feature <screen>` | Generate production code from build card + design |
| `/review design <screen>` | Visual audit against card |
| `/review gate` | Pre-ship quality gate (tests, coverage, E2E, lint, types) |

---

## Layer 3: Code — How to Build and Verify

### The `/build` Pipeline

```
1. gOS reads the build card
2. Injects context: persona (from 2-1), design system (from 4-2), navigation (from 4-1-1-0)
3. Hands to coding agent: card + CLAUDE.md + codebase context
4. Agent produces: component + test file + navigation wiring
5. Runs EARS verification: npm test -- --grep "{screen-id}"
6. If pass → /ship (commit + PR)
7. If fail → fix loop (retry against failing AC)
```

### The `/build flow` Pipeline

```
1. gOS reads the flow card
2. Identifies N build cards in sequence
3. Dispatches each as a build (parallel if independent, sequential if dependent)
4. Runs E2E: npm run e2e -- --flow "{flow-name}"
5. Reports: "N/N screens built. E2E passing. PR ready."
```

### Code Quality Gate

Before `/ship`:
- [ ] All EARS criteria pass
- [ ] E2E flow test passes
- [ ] No hardcoded values (tokens from 4-2)
- [ ] Responsive at 390x844 (iPhone 14 Pro)
- [ ] Empty/loading/error states render correctly
- [ ] S2/S7 branching works at A1b decision point

---

## Cross-Layer Operations

### Adding a New Screen

1. Check strategy layer: does a JTBD + pain exist? If not, add to 2-1 first.
2. Write a build card: `Arx_4-1-1-{module}_{screen}.md` using the template.
3. Add to epic map: update Arx_3-4 with new card in the right epic.
4. Add to sitemap: update Arx_4-1-0 if it changes tab structure or flows.
5. `/build {screen}` → code.

### Modifying an Existing Screen

1. Update the build card (Data, Layout, States, or Acceptance).
2. `/build {screen}` → regenerate code.
3. Run `/review` to verify EARS criteria still pass.

### Adding a New Signal

1. Add to Arx_5-2-3 (signal transformation spec) — the source of truth for signals.
2. Add to Arx_3-4 (epic map) — which epic does it serve? Which screen?
3. Update the build card's Data table with the new signal.
4. `/build {screen}` → regenerate.

### Changing IA (Tab Structure)

1. Update Arx_4-1-1-0 (Master Architecture) — tab bar, sitemap.
2. Update Arx_4-1-0 (Experience Design Index) — screen inventory, flows.
3. Update affected build cards (Navigate sections, Layout headers).
4. Update Arx_3-4 (epic map) — module tags.
5. Audit all build cards: `grep -r "old-tab-name" specs/Arx_4-1-1-*.md`

---

## File Index

### Strategy Layer (Groups 1-3 + 4-2 + 8)

| File | Role |
|------|------|
| `Arx_0-0` | Artifact architecture (this is the meta-spec) |
| `Arx_0-1` | This workbook (operating manual) |
| `Arx_2-1` | Personas, JTBDs, pains |
| `Arx_3-0` | Requirements framework + traceability matrix |
| `Arx_3-2` | PRD exec shell (business model, metrics) |
| `Arx_3-3` | Journey maps |
| `Arx_3-4` | Epic map (THE index) |
| `Arx_4-2` | Design system |
| `Arx_4-1-0` | Experience Design Index (sitemap) |
| `Arx_4-1-1-0` | Mobile Master Architecture |
| `Arx_8-1` | GTM positioning |

### Build Layer (Group 4 build cards)

| Prefix | Module | Count |
|--------|--------|-------|
| `Arx_4-1-1-1_` | Onboarding + Funding | 9 cards |
| `Arx_4-1-1-2_` | Home + Markets | 4 cards |
| `Arx_4-1-1-3_` | Trade | 5 cards |
| `Arx_4-1-1-4_` | Traders | 6 cards |
| `Arx_4-1-1-5_` | You + Systems | 5 cards |
| `Arx_4-1-1-6_` | AI Copilot | 1 card |
| `Arx_4-1-1-F_` | Flows | 3 cards |
| **Total** | | **33 cards** |

### Archive (reference only)

| Location | What |
|----------|------|
| `specs/archive/stories/` | Original user stories (Arx_3-2-1 through 3-2-7) |
| `specs/archive/screen-specs/` | Original module screen specs (4-1-1-1 through 4-1-1-7) |
| `specs/archive/build-cards-staging/` | Original build card template |

---

## Document Metadata

| Property | Value |
|----------|-------|
| Upstream | Arx_0-0 |
| Downstream | All spec creation, all gOS commands |
| Update Trigger | Workflow change, new template version, new gOS verb |
