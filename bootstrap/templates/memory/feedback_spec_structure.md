---
name: Spec structure preferences
description: Gary wants specs organized around user journeys with self-contained cards, not technical architecture with cross-references
type: feedback
---

Technical-first spec structure (freshness tiers, D-codes, C-section cross-references) confuses Gary even though he's the product lead. He self-identifies as "a typical S7" when reading the spec.

**Why:** Cross-referencing between sections (Part B says "See C3.5") breaks reading flow and requires engineers to bounce between sections. Technical groupings (7 freshness tiers, 71-row mapping tables) are comprehensive but overwhelming.

**How to apply:**

- Organize specs around USER JOURNEY stages, not technical categories
- Every data point should be a self-contained card: What Sarah sees / Source / Computation (inline) / Edge cases / Screens
- Separate "engine internals" (things the system uses but the user never sees) from "user-facing signals"
- Use Core (must-have) vs Enrichment (nice-to-have) per journey stage — makes MVP cuts obvious
- 4 freshness tiers max (Instant/Live/Fresh/Background), not 7
- Keep the deep pseudocode in an appendix, but 80% of questions should be answered by the card alone
