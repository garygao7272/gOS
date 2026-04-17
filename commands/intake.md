---
description: "Intake: absorb URL content, scan topics for material movements, manage source watchlist"
---

# /intake — Absorb & Scan

**Purpose:** Pull external content into the workspace with structure. Three modes: absorb a URL, scan a topic across sources, or manage the source watchlist. Wraps the `intake` skill — `/intake` is the canonical entry point (folded out of `/think intake`).

Parse the first word of `$ARGUMENTS`:

| Argument | Action |
|---|---|
| `<url>` (http...) | **Absorb** — extract transcript/content, clean filler, restructure into MECE knowledge doc |
| `scan <topic> [--period <timeframe>]` | Multi-source search for material movements. Default period: 7 days |
| `sources list\|add\|remove\|check` | Manage the source watchlist |
| _(no args)_ | Ask: "URL to absorb, topic to scan, or sources management?" |

**Config:** `~/.claude/config/intake-sources.md` — global watchlist (see `sources` sub-command).

**Output routing:**
- Absorb: `outputs/think/research/{slug}-intake.md`
- Scan: `outputs/think/research/scan-{topic}-{date}.md`
- Sources: updates to `~/.claude/config/intake-sources.md` in-place

---

## Execution

When invoked, load the full `intake` skill: `Skill("intake")`. The skill defines the URL parsers (YouTube transcripts, podcast feeds, article extractors, thread scrapers), the scan logic, and the watchlist format.

**Never invent scan results.** Every claim in a scan output must have a source URL and a date. If a source fails (rate-limited, 404, paywalled), mark it `[Link unavailable]` rather than fabricating.

---

## When to use /intake vs /think research

| Use `/intake` when | Use `/think research` when |
|---|---|
| You have a specific URL to absorb | You have an open-ended question |
| You want periodic watchlist monitoring | You want evidence-backed answers |
| Output is knowledge extraction (fidelity) | Output is synthesis (insight) |

If unsure: `/intake` for input-driven absorption, `/think research` for question-driven investigation.
