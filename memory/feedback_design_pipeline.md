---
name: Code-First Design Pipeline
description: Design pipeline is code-first (HTML prototype → preview verify → Figma recreation), not Figma-first. Proven 2026-04-06.
type: feedback
valid_from: 2026-04-06
valid_to: open
---

# Code-First Design Pipeline Beats Figma-First

The optimal pipeline for producing high-fidelity mobile UIs is code-first: write HTML prototype → verify in Claude Preview at 390×844 → approve → optionally recreate in Figma with design system components.

**Why:** Tested both approaches in same session. Figma MCP `use_figma` hit 3 errors (FILL-before-append, node ID cross-call, page reference loss) before producing a result — and the result was static with no interactions. HTML prototype was dispatched as a subagent, produced 1219 lines of working code with live price ticks, glass effects, stagger animations, swipe interactions, and skeleton loading — all in one pass.

**How to apply:**
- `/design ui` now uses HTML prototype as PRIMARY tool, Figma MCP as SECONDARY (for handoff)
- Always inject DESIGN.md tokens + Apple Craft Reference into prototype generation prompt
- Use Claude Preview at 390×844 for visual verification (screenshot + interaction test)
- Figma recreation is post-approval, optional, and incremental (one section per `use_figma` call)

**Key Figma MCP gotchas (when used):**
- `layoutSizingHorizontal = 'FILL'` must be set AFTER `appendChild` — this alone caused 2/3 failures
- Node IDs don't persist across `use_figma` calls — fetch by name/traversal each time
- Page context resets every call — always `await figma.setCurrentPageAsync(page)` first
- Colors are 0-1 range, not 0-255
- Font loading: "Semi Bold" has a space, "SemiBold" fails
- Build incrementally — one section per call, screenshot to verify between sections

**Research outputs (2026-04-06):**
- `outputs/think/research/figma_mcp_programmatic_design_reference.md`
- `outputs/think/design/Apple_Design_Craft_Reference.md`
- `outputs/think/research/ai_design_tools_landscape_apr2026.md`
