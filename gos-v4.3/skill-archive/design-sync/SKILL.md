---
name: design-sync
description: Bidirectional sync between specs/Arx_4-2_Design_System.md, DESIGN.md, Figma tokens, and Stitch projects
---

# Design Sync Skill — Keep Design Systems in Harmony

Use this skill to synchronize the Arx design system across multiple representations:

- `specs/Arx_4-2_Design_System.md` — canonical source of truth (full spec)
- `DESIGN.md` — Stitch/agent-consumable compact format
- Figma — visual design tool tokens
- Stitch projects — `designTheme` configuration

## When to Use

- After updating `specs/Arx_4-2_Design_System.md` — sync changes to `DESIGN.md`
- After generating Stitch screens that introduce new patterns — extract and propose spec updates
- Before a `/think design` session — ensure `DESIGN.md` is current
- After Figma updates — pull fresh tokens and update both files

## Export: Spec → DESIGN.md

1. Read `specs/Arx_4-2_Design_System.md` (full spec)
2. Extract:
   - Color palette (all domains: Stone, Water, Backgrounds, Text, Borders, Semantic, Regime)
   - Typography rules (fonts, weights, scale)
   - Component styling (glass cards, buttons, badges, tab bars, regime bar)
   - Layout principles (grid, viewport, safe areas, spacing)
   - Animation tokens (durations, easings)
   - Production UI stack (from existing DESIGN.md section)
   - "What NOT to Do" rules
3. Write compact version to `DESIGN.md`
4. Preserve the Production UI Stack and Stitch Integration Notes sections

## Import: DESIGN.md → Spec (propose changes)

When Stitch screens or design exploration introduces new patterns:

1. Identify new tokens/patterns not in the canonical spec
2. Draft proposed additions with rationale
3. Present to user: "Stitch exploration introduced these new patterns. Promote to spec?"
4. If approved, update `specs/Arx_4-2_Design_System.md`

## Figma Integration

When Figma MCP is available:

1. Call `mcp__7e179557__get_variable_defs` to pull current Figma tokens
2. Compare with `specs/Arx_4-2_Design_System.md`
3. Flag any drift between Figma and spec
4. Call `mcp__7e179557__create_design_system_rules` to push spec rules back to Figma

## Stitch Project Sync

When creating or updating Stitch projects:

1. Read `DESIGN.md`
2. Map Arx tokens to Stitch `designTheme` format:
   ```
   designTheme: {
     colorMode: "DARK",
     customColor: "#5B21B6",  // Stone
     font: "INTER",
     designMd: "{full DESIGN.md content}"
   }
   ```
3. Inject into Stitch project creation/editing

## OKLCH Token Sync

When updating colors, maintain both hex and OKLCH representations:

| Token    | Hex     | OKLCH                |
| -------- | ------- | -------------------- |
| Stone    | #5B21B6 | oklch(0.42 0.18 280) |
| Water    | #22D1EE | oklch(0.78 0.12 195) |
| Profit   | #A6FF4D | oklch(0.72 0.19 142) |
| Loss     | #FF6B7F | oklch(0.63 0.22 25)  |
| Obsidian | #050609 | oklch(0.08 0.01 280) |

Use `culori` library for accurate conversions when exact OKLCH values are needed.

## Drift Detection

Run periodically (or before major design work) to check for drift:

1. Compare DESIGN.md Production UI Stack section with actual `package.json` dependencies
2. Compare DESIGN.md colors with `apps/web-prototype/index.html` CSS variables
3. Compare DESIGN.md typography with prototype font loading
4. Flag any inconsistencies for resolution
