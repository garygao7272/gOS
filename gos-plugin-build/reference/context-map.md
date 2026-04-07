# Context Map — Auto-Context Resolution

> Referenced by all gOS commands. Runs after Intent Gate resolves all 6 dimensions, before execution.
>
> **ENFORCEMENT: This is MANDATORY, not advisory.** When keywords match, the context MUST be loaded before any implementation. Skipping context loading is a pipeline violation. If you find yourself making color choices, layout decisions, or design calls without having read the design system in this session — STOP and load it first.

## Keyword → Context Source Mapping

When the resolved WHAT or SCOPE dimension contains these keywords, auto-load the corresponding context sources:

| Keywords | Context Sources |
|----------|----------------|
| `prototype`, `screen`, `UI`, `layout` | `apps/web-prototype/SOUL.md`, `specs/Arx_4-2_Design_System.md` |
| `trading`, `order`, `position`, `execution` | `specs/Arx_4-1-1-3*`, Hyperliquid MCP availability check |
| `copy`, `leader`, `follow`, `mirror` | `specs/Arx_4-1-1-6*`, `specs/Arx_3-2*` |
| `design`, `visual`, `color`, `typography` | `specs/Arx_4-2_Design_System.md`, `DESIGN.md`, `apps/web-prototype/SOUL.md`, `.claude/taste.md` |
| `taste`, `judgment`, `aesthetic`, `premium`, `quality` | `.claude/taste.md`, `specs/Arx_4-2_Design_System.md` |
| `anticipate`, `proactive`, `suggest`, `predict` | `.claude/anticipation.md` |
| `friction`, `alternative`, `instead`, `challenge`, `contrarian` | `.claude/creative-friction.md` |
| `spec`, `product`, `feature`, `roadmap` | `specs/INDEX.md` + matched specs by topic |
| `market`, `funding`, `price`, `volume` | Hyperliquid MCP, recent `outputs/briefings/*` |
| `investor`, `pitch`, `raise`, `fundraise` | `outputs/think/fundraise/*`, `specs/Arx_1-*` |
| `hire`, `team`, `role`, `candidate` | `outputs/think/hire/*`, `outputs/think/design/*-org.md` |
| `legal`, `compliance`, `terms`, `regulation` | `outputs/think/legal/*` |
| `signal`, `regime`, `indicator`, `alpha` | `specs/Arx_3-3*`, `specs/Arx_5-*` |
| `persona`, `jake`, `sarah`, `s2`, `s7` | `specs/Arx_2-1_Problem_Space_and_Audience.md` |
| `architecture`, `system`, `engineering` | `specs/Arx_5-*`, `specs/Arx_0-0*` |
| `decision`, `tradeoff`, `choice` | `specs/Arx_9-1_Decision_Log.md` |
| `gos`, `command`, `evolve`, `upgrade` | `gOS/CLAUDE.md`, relevant command files in `.claude/commands/` |

## Token Budget Rules

```
1. Estimate token cost of each matched source (lines / 4)
2. Sum all candidates
3. If total < 30% of remaining context window → load ALL silently
4. If total > 30% → present list: "I'll load [list]. Total ~Nk tokens. Trim anything?"
5. If a single file > 15% of context window → summarize instead of loading full
```

## Scratchpad Logging

After loading, write to `sessions/scratchpad.md` under `Working State`:

```markdown
## Context Loaded
- {file1} ({N}k tokens)
- {file2} ({N}k tokens)
- Total: {N}k tokens (~{%}% of context)
```

## Hard Rules (non-negotiable)

**Prototype/UI work ALWAYS loads these — no exceptions:**
- `specs/Arx_4-2_Design_System.md` — color palette, typography, spacing, components
- `apps/web-prototype/SOUL.md` — feel layer, animation specs, principles

**If you are about to choose a color, font size, spacing value, or animation timing — and you have NOT read the design system in this session — STOP and read it.** Do not rely on memory, cached knowledge, or "I know the palette." The design system is the single source of truth.

**Visual/design work ALWAYS includes research:**
- Before implementing any chart, toggle, selector, or interaction pattern — research how 3+ reference apps handle the same pattern
- Use Agent tool for research, not assumptions from training data
- Present the research findings in the plan before implementing

## Fallback Rules

- If a matched file doesn't exist → skip silently (no error)
- If MCP tool is unavailable → note in scratchpad, use WebSearch fallback
- If no keywords match → load nothing (context-free execution is valid for some tasks)
- Gary can always override: "also load X" or "don't load Y"
