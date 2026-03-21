---
name: stitch-design
description: Wrapper around Stitch MCP tools with Arx DESIGN.md auto-injection, token remapping, and design pipeline integration
---

# Stitch Design Skill — Arx-Aware Screen Generation

Use this skill when generating, editing, or exploring design variants via Google Stitch MCP. It ensures all Stitch output respects the Arx Citadel & Moat design language.

## Before Any Stitch Operation

1. **Read `DESIGN.md`** at the project root — this is the Stitch-consumable design system
2. **Read `specs/Arx_4-2_Design_System.md`** for the canonical token definitions
3. **Inject DESIGN.md content** into Stitch prompts as design context

## Quick Sketch (generate_screen_from_text)

```
1. Call mcp__stitch__list_projects to find existing Arx projects
2. If no suitable project exists, call mcp__stitch__create_project with:
   - title: "Arx - {feature name}"
   - device: "MOBILE"
3. Call mcp__stitch__generate_screen_from_text with:
   - project_id: the Arx project
   - prompt: "{user's description}\n\nDesign System:\n{DESIGN.md content}"
   - device: "MOBILE"
4. Call mcp__stitch__get_screen to retrieve the HTML
5. Present to user with Stitch integration notes from DESIGN.md
```

## Variant Exploration (generate_variants)

```
1. Get screen_id from user reference or Phase 0 output
2. Call mcp__stitch__generate_variants with:
   - screen_ids: [screen_id]
   - creative_range: REFINE | EXPLORE | REIMAGINE (user's choice, default EXPLORE)
   - aspects: [LAYOUT, COLOR_SCHEME, IMAGES, TEXT_FONT, TEXT_CONTENT] (user's choice)
   - num_variants: 3-5 (user's choice, default 4)
3. Retrieve all variant screens
4. Present side by side with comparison notes
5. Suggest /judge design-variant for formal evaluation
```

## Screen Editing (edit_screens)

```
1. Call mcp__stitch__edit_screens with:
   - screen_ids: [target screen(s)]
   - prompt: "{user's edit request}\n\nReminder: {key DESIGN.md rules}"
2. Retrieve updated screen
3. Check for common Stitch violations (gradients, pure white, missing monospace)
```

## Stitch→Arx Token Remapping

After retrieving any Stitch screen, apply these remappings:

| Stitch MD3 Token         | Arx Token      | Hex Value |
| ------------------------ | -------------- | --------- |
| `primary`                | Stone          | #5B21B6   |
| `primary-container`      | Stone Deep     | #4C1D95   |
| `secondary`              | Water          | #22D1EE   |
| `surface`                | Obsidian       | #050609   |
| `surface-container`      | Chamber        | #0A0918   |
| `surface-container-high` | Rampart        | #100E26   |
| `on-surface`             | Starlight      | #EEE9FF   |
| `on-surface-variant`     | Stone Mid      | #9D96B8   |
| `outline`                | Border Default | #1C1338   |
| `outline-variant`        | Border Strong  | #2D1F55   |
| `error`                  | Negative       | #FF6B7F   |

### Post-Processing Checklist

After every Stitch generation:

- [ ] Remove any gradients (`bg-gradient-*`, `linear-gradient`)
- [ ] Replace `#FFFFFF` / `white` with Starlight `#EEE9FF`
- [ ] Replace `#000000` / `black` with Obsidian `#050609`
- [ ] Add `font-family: 'Geist Mono', 'JetBrains Mono', monospace` to numeric data
- [ ] Add `viewport-fit=cover` and safe-area-inset handling
- [ ] Verify touch targets are 44px minimum
- [ ] Check border-radius: 16px outer cards, 12px inner elements
- [ ] Replace Stitch font (Space Grotesk/Plus Jakarta Sans) with Inter/Geist

## Integration with /think design Pipeline

This skill is invoked automatically by `/think design` Phase 0 and Phase 0.5. It can also be used standalone for quick explorations.

## MCP Tools Used

- `mcp__stitch__create_project`
- `mcp__stitch__generate_screen_from_text`
- `mcp__stitch__generate_variants`
- `mcp__stitch__edit_screens`
- `mcp__stitch__get_screen`
- `mcp__stitch__list_screens`
- `mcp__stitch__list_projects`
- `mcp__stitch__get_project`
