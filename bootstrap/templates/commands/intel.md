---
description: "Intelligence briefings: war-room (events/trades), signal-scan (innovation), both, status"
---

# Intel Mode — Intelligence Briefings → outputs/briefings/

**Two briefing products, on-demand or scheduled. Dual-mode: invoke here for immediate generation, or let cron run them via `~/.claude/scheduled-tasks/`.**

| Product         | Focus                                                               | Key Tools                       | Output                           |
| --------------- | ------------------------------------------------------------------- | ------------------------------- | -------------------------------- |
| **War Room**    | Events → MiroFish simulation (top 3) → trade recs (5 asset classes) | sources, hyperliquid, WebSearch | `war-room-{date}.md/html/pdf`    |
| **Signal Scan** | AI/fintech/crypto innovation + viral discovery (GitHub/PH/X)        | sources, WebSearch              | `signal-scan-{date}.md/html/pdf` |

**Scratchpad checkpoints.** Update `sessions/scratchpad.md`:

- **On entry:** Write current task, mode (`Intel > {sub-command}`), and period
- **After data fetch:** Log source counts to `Working State`
- **After output:** Log file paths and sizes to `Files Actively Editing`
- **After compaction:** Re-read `sessions/scratchpad.md` to restore state

Parse the first word of `$ARGUMENTS` to determine sub-command. If no sub-command given, ask: "Which briefing? war-room, signal-scan, both, or status?"

---

## Period Parsing

All generation sub-commands accept an optional period argument after the sub-command name.

| Input                     | Hours                                            | Example                 |
| ------------------------- | ------------------------------------------------ | ----------------------- |
| _(none)_                  | 24                                               | `/intel war-room`       |
| `48h`                     | 48                                               | `/intel war-room 48h`   |
| `3d`                      | 72                                               | `/intel signal-scan 3d` |
| `7d` or `1w`              | 168                                              | `/intel both 7d`        |
| `2w`                      | 336                                              | `/intel war-room 2w`    |
| `1m` or `this month`      | Calculate hours from 1st of current month to now | `/intel both 1m`        |
| Month name (e.g. `march`) | Calculate hours from 1st of that month to now    | `/intel war-room march` |

Pass the computed `hours` value to `fetch_all_sources(hours=N)`, `fetch_trending_events(period_hours=N)`, and adjust WebSearch queries to cover the period.

---

## war-room [period]

**Purpose:** Generate a War Room briefing — events, MiroFish simulations, trade recommendations across 5 asset classes.

**Process:**

1. Parse period from remaining `$ARGUMENTS` (default: 24h)
2. Update scratchpad: `Intel > war-room`, period, timestamp
3. Read `~/.claude/scheduled-tasks/war-room/SKILL.md` for the full execution template
4. Execute the SKILL.md steps in order:
   - **Step 1:** Fetch sources + trending events (parallel)
   - **Step 2:** Fetch Hyperliquid live data + macro WebSearches (parallel)
   - **Step 3:** Deep content pass on top 3 events
   - **Step 4:** MiroFish simulation — top 3 events by market influence
   - **Step 5:** Synthesize briefing with 5-asset-class trade recs
   - **Step 6:** Verify source URLs + output MD/HTML/PDF
5. Output to: `outputs/briefings/war-room-{YYYY-MM-DD}.md` (+ `.html` + `.pdf`)
6. Update scratchpad with output file paths and sizes

**Key data sources:**

- `fetch_all_sources(hours=N)` — Twitter KOLs, YouTube transcripts, blog articles
- `fetch_trending_events(period_hours=N)` — event discovery ranked by market influence
- Hyperliquid MCP — `get_asset_contexts`, `get_predicted_fundings`, `get_perps_at_oi_cap`, `get_all_mids`
- WebSearch — macro indices, geopolitical events, prediction market odds
- `verify_source_urls(urls=[...])` — batch URL verification before output

**Zero hallucination policy:** Every claim has an inline source link. Dead links marked `[Link unavailable — cached quote]`. No orphan claims.

---

## signal-scan [period]

**Purpose:** Generate a Signal Scan briefing — AI, fintech, crypto innovation + viral discovery layer.

**Process:**

1. Parse period from remaining `$ARGUMENTS` (default: 24h)
2. Update scratchpad: `Intel > signal-scan`, period, timestamp
3. Read `~/.claude/scheduled-tasks/signal-scan/SKILL.md` for the full execution template
4. Execute the SKILL.md steps in order:
   - **Step 1:** Fetch sources + viral signals (parallel)
   - **Step 2:** Deep content pass — YouTube transcripts, blog articles, GitHub READMEs
   - **Step 3:** Synthesize by section (Viral, AI, Crypto, Fintech, YouTube, Blogs, Prediction Markets)
   - **Step 4:** Verify source URLs + output MD/HTML/PDF
5. Output to: `outputs/briefings/signal-scan-{YYYY-MM-DD}.md` (+ `.html` + `.pdf`)
6. Update scratchpad with output file paths and sizes

**Key data sources:**

- `fetch_all_sources(hours=N)` — focus categories: ai, crypto, fintech, startup
- `fetch_viral_signals()` — GitHub trending, Product Hunt launches
- WebSearch — AI product launches, crypto protocol updates, fintech funding
- `verify_source_urls(urls=[...])` — batch URL verification before output

**Geographic focus:** APAC + US. Not Euro-centric.
**Relevance filter:** Trading, investing, lending, productivity. Skip if irrelevant.
**Zero hallucination policy:** Same as War Room — inline verified links, no orphan claims.

---

## both [period]

**Purpose:** Generate both briefings in parallel. This is the "full intelligence run."

**Process:**

1. Parse period from remaining `$ARGUMENTS` (default: 24h)
2. Update scratchpad: `Intel > both`, period, timestamp
3. Launch **2 parallel agents** using the Agent tool:
   - **Agent 1:** Execute War Room SKILL.md with computed hours
   - **Agent 2:** Execute Signal Scan SKILL.md with computed hours
4. Both agents run in background (`run_in_background: true`)
5. Report to user: "Both briefings launched. You'll be notified as each completes."
6. On completion, update scratchpad with both output paths

**Execution pattern:** Swarm (2 parallel agents, independent outputs, no file conflicts).

---

## status

**Purpose:** Show the state of intelligence briefings — last run times, output files, source quality.

**Process:**

1. List files in `outputs/briefings/` matching `war-room-*` and `signal-scan-*`
2. Sort by modification time, show the 5 most recent of each type
3. For the most recent of each, show:
   - File size (MD + HTML + PDF)
   - Generation timestamp
   - Source counts (if parseable from the Source Quality section)
4. Show scheduled task status via `mcp__scheduled-tasks__list_scheduled_tasks` (filter for war-room and signal-scan)

**Output format:**

```
## Intelligence Status

### War Room
Last run: {date} at {time}
Files: war-room-{date}.md (32K) · .html (36K) · .pdf (479K)
Sources: {N} tweets · {N} transcripts · {N} articles · Hyperliquid live
Schedule: {cron expression} · Next: {next run time}

### Signal Scan
Last run: {date} at {time}
Files: signal-scan-{date}.md (21K) · .html (24K) · .pdf (380K)
Sources: {N} tweets · {N} transcripts · {N} articles · {N} GitHub repos
Schedule: {cron expression} · Next: {next run time}

### Recent Briefings
| Type | Date | Size | Sources |
|------|------|------|---------|
| War Room | 2026-03-17 | 479K pdf | 109 tweets, 6 transcripts |
| Signal Scan | 2026-03-17 | 380K pdf | 127 tweets, 0 transcripts |
```

---

## Output Pipeline (shared by war-room and signal-scan)

Both briefings use the same output pipeline:

1. **Write markdown** to `outputs/briefings/{type}-{YYYY-MM-DD}.md`
2. **Convert to HTML** using Python markdown2 with Apple-minimalist CSS:
   - Font: -apple-system, BlinkMacSystemFont, 'SF Pro Text'
   - Code blocks: #f5f5f7 background
   - Links: #007aff
   - Tables: dark header (#1d1d1f), hover highlight
   - Print-optimized CSS (@media print)
3. **Generate PDF** via Playwright:
   - Load HTML via `file://` URL
   - `page.pdf()` with A4 format, 20mm margins, printBackground: true
4. **Version handling:** If a file for today already exists, append `-v2`, `-v3`, etc.

Python environment for markdown2 + Playwright: `tools/sources-env/bin/python`
