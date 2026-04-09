# Prototype a New Feature (Arx-Specific)

Build a quick working prototype in `drafts/` — NOT in the main `index.html`.

## Instructions

1. **Create a new draft file**: `drafts/{feature-name}-v1.html`
2. **Copy the minimal scaffolding** from index.html (CSS variables, base styles, viewport meta)
3. **Build the feature in isolation** — focus on UX feel, not polish
4. **Keep it self-contained** — no external dependencies, single file
5. **Test in 390x844 viewport** (iPhone 14 Pro)

## Rules
- This is a PROTOTYPE — speed over perfection
- Try 2-3 different approaches if the first doesn't feel right
- Name iterations: `{feature}-v1.html`, `{feature}-v2.html`, etc.
- Do NOT modify `index.html` — prototypes live in `drafts/`
- When satisfied, tell the user which version to promote to main

## After Prototyping
Run `/simplify` on the winning prototype, then merge into `index.html` with a version bump.
