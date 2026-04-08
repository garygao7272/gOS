---
name: stitch-design
description: Wrapper around Stitch MCP tools with Arx DESIGN.md auto-injection, token remapping, and design pipeline integration
---

# Stitch Design Skill — Arx-Aware Screen Generation

Use this skill when generating, editing, or exploring design variants via Google Stitch MCP. It ensures all Stitch output respects the Arx Citadel & Moat design language.

## The Bridge: DESIGN.md

`DESIGN.md` at the project root is the bridge artifact between Stitch and Claude Code:

- **Stitch reads it** → constrains generation to Arx tokens
- **Claude Code reads it** → constrains code to Arx tokens
- **Source of truth:** `specs/Arx_4-2_Design_System.md` → `DESIGN.md` is the compressed mirror

## Before Any Stitch Operation

1. **Read `specs/Arx_4-3_Design_Taste.md`** — judgment framework, feel targets, litmus tests
2. **Read `DESIGN.md`** at the project root — Stitch-consumable design system
3. **Read `specs/Arx_4-2_Design_System.md`** for canonical token definitions (if needed)
4. **Inject DESIGN.md content** into Stitch prompts as design context

## MCP Tools Available (3 tools via `@_davideast/stitch-mcp`)

| Tool               | What It Does                                  | When to Use                                 |
| ------------------ | --------------------------------------------- | ------------------------------------------- |
| `build_site`       | Maps screens to routes, returns HTML per page | Multi-page flows, site-level generation     |
| `get_screen_code`  | Returns HTML for a specific screen            | Pulling one screen's code after generation  |
| `get_screen_image` | Returns screenshot as base64 image            | Visual reference for specs, design preamble |

**Note:** Screen generation and editing are done via the Stitch web UI or SDK — the MCP server provides read-access to existing projects.

## Integration with /design Pipeline

### Gate -1.5: STITCH VIBE SKETCH (optional, recommended for new screens)

After Gate -1 (Reference Research), before Gate 0 (State Matrix):

1. Formulate the feel target from `specs/Arx_4-3_Design_Taste.md` §3 as a Stitch prompt
2. Open stitch.withgoogle.com and generate 3-5 variants (EXPLORE mode)
3. Pull screenshots via `get_screen_image` MCP tool
4. Use variants as VISUAL REFERENCE — note what Stitch got right and wrong
5. Add to Design References section in the spec

### Gate 0.5: STITCH STATE VISUALIZATION (optional)

After Gate 0 (State Matrix), use Stitch multi-screen generation for top 5 states:

1. Generate connected screens for: Default, Empty, Loading, Error, Crisis
2. Pull via `get_screen_image` for each
3. Use as visual companion to the markdown state matrix

### Render Phase: STITCH → PROTOTYPE BRIDGE

When converting Stitch output to prototype code:

1. Pull HTML via `get_screen_code`
2. Apply the token remapping table below
3. Run the post-processing checklist
4. Write to `apps/web-prototype/` with Arx CSS variables

## Stitch → Arx Token Remapping

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

## Post-Processing Checklist

After every Stitch generation, before using the code:

- [ ] Remove any gradients (`bg-gradient-*`, `linear-gradient`) — Stone and Water never blend
- [ ] Replace `#FFFFFF` / `white` with Starlight `#EEE9FF`
- [ ] Replace `#000000` / `black` with Obsidian `#050609`
- [ ] Replace Stitch fonts (Space Grotesk/Plus Jakarta Sans) with `"SF Pro Display", "Inter", system-ui`
- [ ] Add `font-family: 'SF Mono', 'JetBrains Mono', monospace` to numeric data
- [ ] Add `viewport-fit=cover` and `env(safe-area-inset-*)` handling
- [ ] Verify touch targets are 44px minimum
- [ ] Check border-radius: 14px outer cards, 12px inner elements
- [ ] Replace Stitch color values with Arx CSS custom properties (`var(--color-primary)`, etc.)
- [ ] Run 5 Premium Litmus Tests from `specs/Arx_4-3_Design_Taste.md` §2

## DESIGN.md Sync Protocol

**Direction: Arx → Stitch (before generation):**

1. Read `specs/Arx_4-2_Design_System.md`
2. Verify `DESIGN.md` is current (compare key tokens)
3. If stale, regenerate `DESIGN.md` from 4-2
4. Paste DESIGN.md content into Stitch project's design context

**Direction: Stitch → Arx (after generation):**

1. If Stitch reveals a useful new pattern (layout, component), note it
2. Do NOT update 4-2 tokens from Stitch — 4-2 is source of truth
3. Update `DESIGN.md` only if 4-2 changes

## Stitch Prompt Formula

For best results, structure Stitch prompts as:

```
[WHAT] A {screen type} for {app name}
[WHO] Used by {persona description}
[FEEL] Should feel like {feel target from 4-3 §3}
[CONSTRAINT] Dark mode, mobile-first (390x844), {key design rules}

Design System:
{paste DESIGN.md content}
```

Example:

```
A home dashboard for Arx, a crypto trading terminal.
Used by S7 capital allocators who copy professional traders.
Should feel like a command center — your world at a glance, personalized, alive.
Dark mode, mobile-first (390x844), no gradients, stone violet for actions, cyan for data.

Design System:
{DESIGN.md content}
```

## Variant Exploration

When exploring design alternatives:

| Creative Range | When to Use               | For Arx                                            |
| -------------- | ------------------------- | -------------------------------------------------- |
| **REFINE**     | Polish existing direction | Tweaking spacing, hierarchy within approved layout |
| **EXPLORE**    | Find better alternatives  | **Default for Arx** — always start here            |
| **REIMAGINE**  | Challenge assumptions     | Use when self-model flags boldness deficit         |

Aspects to vary:

- `LAYOUT` — structure, composition, element arrangement
- `COLOR_SCHEME` — palette application (within Arx tokens)
- `TEXT_FONT` — typography hierarchy, weight distribution
- `TEXT_CONTENT` — copy, labels, CTAs
- `IMAGES` — icons, illustrations, data visualizations

## Fallback (When Stitch MCP Unavailable)

If Stitch MCP is not responding:

1. Skip Gates -1.5 and 0.5 (they're optional)
2. Use WebSearch for competitor screenshots as visual reference
3. Design directly in the prototype without Stitch intermediary
4. The core pipeline (Gate -1, 0, 3c) still runs without Stitch

## MCP Authentication

Configured in `.mcp.json` with `STITCH_API_KEY` environment variable.
API key must be set as an environment variable before use.
