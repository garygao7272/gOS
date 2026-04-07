---
name: Feel as Tokens
description: Feel targets should be abstracted as shared tokens (like colors), not redefined per build card. Gary corrected the approach of writing full Feel sections per card.
type: feedback
valid_from: 2026-04-06
valid_to: open
---

# Feel as Shared Tokens, Not Per-Card Definitions

Feel targets (motion choreography, density, temperature budget, skeleton specs, haptics) should be defined ONCE per screen type and referenced by name — exactly like color tokens.

**Why:** Gary corrected the approach when I added a 35-line `## Feel` section to C1-R0's build card. His insight: "feel should not be something we define for each build card, it shall be abstracted away as a common same [as] other design tokens." This follows the same pattern as colors (defined in 4-2, referenced by name) and prevents inconsistency across 30+ build cards.

**How to apply:** When writing a build card's `## Feel` section, reference a feel token from DESIGN.md §6.9 (e.g., `Feel: feel:home`). Only add overrides if this specific screen deviates from the screen type's default. Never redefine motion, density, or temperature inline. The full feel system lives in DESIGN.md §6.9 with 8 screen types and shared defaults.
