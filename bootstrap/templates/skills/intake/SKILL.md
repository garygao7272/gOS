---
name: intake
description: "Absorb content from URLs (YouTube, podcasts, articles, threads), scan topics for material movements, and manage a watchlist of sources. Use when the user pastes a URL, asks to research a topic's recent developments, or wants to manage their intelligence sources."
---

# Intake — Data Acquisition & Content Intelligence

Three modes: **absorb** (deep content processing), **scan** (broad topic search), **sources** (watchlist management).

Parse the first word of $ARGUMENTS to route.

---

## Dependencies & Setup (run-once, no permission prompts after)

All tools below are pre-authorized in `~/.claude/settings.local.json`. No permission prompts required.

**Primary extraction tool — Defuddle (preferred for ALL URLs):**

```bash
# Installed via npm in project. Zero API keys, runs locally.
# Extracts clean HTML or Markdown from any URL. Site-specific extractors for
# YouTube (transcript via InnerTube API), Reddit, Twitter/X, GitHub, HackerNews,
# ChatGPT, Claude, Gemini, Grok conversations.
npx defuddle parse '<URL>' --markdown          # Clean markdown output
npx defuddle parse '<URL>' --json              # JSON with full metadata
npx defuddle parse '<URL>' -p title            # Extract single property
npx defuddle parse '<URL>' -m -o output.md     # Save to file
npx defuddle parse '<URL>' --lang en           # Language preference (BCP 47)
```

**Why defuddle first:**

- YouTube: Fetches transcript via InnerTube API with chapter headings and timestamps — no Python, no API key, handles 2hr+ videos in seconds
- Articles/blogs: More forgiving than Readability, extracts schema.org metadata, uses mobile CSS heuristics
- Social: Built-in extractors for Reddit, X/Twitter, HN, GitHub
- AI chats: Extracts ChatGPT, Claude, Gemini, Grok conversations
- Zero runtime dependencies in browser, only `commander` for CLI

**Fallback tools (when defuddle fails or is insufficient):**

1. **Firecrawl CLI** — for anti-bot protected sites, JavaScript-heavy SPAs

```bash
npx firecrawl-cli scrape '<url>' -o .firecrawl/{slug}.md
```

2. **youtube-transcript-api (Python)** — backup for YouTube if defuddle's InnerTube path is blocked

```python
python3 -c "
from youtube_transcript_api import YouTubeTranscriptApi
video_id = 'VIDEO_ID_HERE'
ytt = YouTubeTranscriptApi()
transcript = ytt.fetch(video_id)
for entry in transcript:
    mins = int(entry.start // 60)
    secs = int(entry.start % 60)
    print(f'[{mins:02d}:{secs:02d}] {entry.text}')
"
```

3. **Whisper local transcription** — nuclear option for videos with NO captions at all

```bash
yt-dlp -x --audio-format mp3 --audio-quality 5 \
  -o ".firecrawl/audio/%(id)s.%(ext)s" \
  'https://www.youtube.com/watch?v=VIDEO_ID_HERE'

python3 -c "
import whisper
model = whisper.load_model('base')  # 'base' for speed, 'medium' for accuracy
result = model.transcribe('.firecrawl/audio/VIDEO_ID_HERE.mp3', verbose=False)
for seg in result['segments']:
    mins = int(seg['start'] // 60)
    secs = int(seg['start'] % 60)
    print(f'[{mins:02d}:{secs:02d}] {seg[\"text\"].strip()}')
"
```

Performance: ~2 min for 40 min audio on M-series Mac CPU. No API key needed.

---

## absorb <url or topic>

**Purpose:** Take a single content source (YouTube, podcast, article, X thread, PDF, blog post) and produce a structured knowledge document. Zero nuance loss.

**Language rule:** Output document MUST be in the same language as the source content. Chinese video → Chinese document. English article → English document.

### Step 1: Extract raw content

Detect source type from URL and use the right tool:

| Source                                  | Primary                                                                                                                               | Fallback                                                                                |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| YouTube (`youtube.com`, `youtu.be`)     | `npx defuddle parse '<url>' --json` — transcript via InnerTube API with chapters, timestamps, metadata. One command, full extraction. | `youtube-transcript-api` (Python) → Whisper local transcription (for no-caption videos) |
| Reddit, Twitter/X, GitHub, HN           | `npx defuddle parse '<url>' --markdown` — built-in site-specific extractors                                                           | `npx firecrawl-cli scrape '<url>'`                                                      |
| AI chat (ChatGPT, Claude, Gemini, Grok) | `npx defuddle parse '<url>' --markdown` — conversation extractors                                                                     | N/A                                                                                     |
| Article / Blog                          | `npx defuddle parse '<url>' --markdown` — forgiving extraction, schema.org metadata                                                   | `npx firecrawl-cli scrape '<url>'` for anti-bot sites                                   |
| Podcast (Spotify, Apple, RSS)           | `npx defuddle parse '<url>' --markdown` for show notes                                                                                | Whisper for audio-only                                                                  |
| PDF                                     | Read tool or PDF MCP tools                                                                                                            | N/A                                                                                     |
| Any other URL                           | `npx defuddle parse '<url>' --markdown`                                                                                               | `npx firecrawl-cli scrape '<url>'`                                                      |

### Step 2: Clean the transcript/content

If transcript extracted:

1. Remove filler words (um, uh, like, you know, right, so, basically, literally, I mean)
2. Remove false starts and repetitions
3. **KEEP all timestamps** — format as `[MM:SS]` markers at natural paragraph breaks
4. Keep ALL substantive content — every data point, every example, every aside
5. Preserve speaker attribution if multiple speakers

### Step 3: Restructure into knowledge document

Transform raw content into a structured document using these principles:

**Structure (MECE — mutually exclusive, collectively exhaustive):**

```markdown
# {Title} — Intake Summary

> Source: {url}
> Date: {publication date}
> Speaker(s): {names and roles}
> Duration: {length}

## TL;DR (3-5 bullets)

The absolute essence. What would you tell someone in 30 seconds?

## Key Thesis

What is the speaker's core argument or insight? State it as a single, specific claim.

## Structured Breakdown

### 1. {First Major Theme}

[MM:SS] {Content organized by theme, not chronologically}

**What they said:** {Faithful representation — no nuance lost}
**Why it matters:** {Context for someone with no prior knowledge}
**Key data:** {Any numbers, metrics, percentages, dates}

### 2. {Second Major Theme}

...

### N. {Nth Major Theme}

...

## Quantitative Insights

| Metric | Value | Context |
| ------ | ----- | ------- |
| ...    | ...   | ...     |

## Qualitative Insights

- {Non-numeric insights: opinions, predictions, frameworks, mental models}

## Concepts Explained

For each concept referenced that requires prior knowledge:

**{Concept name}:** {First-principles explanation — what it is, why it exists, how it works, in 2-3 sentences. Assume the reader has never heard of it.}

## Complementary Context

{What the speaker didn't say but the reader should know:}

- Counter-arguments or alternative viewpoints
- Related developments since publication
- How this connects to other known topics (check memory for Gary's interests)

## Actionable Takeaways

1. {Specific, actionable insight — not generic advice}
2. ...

## Source Timestamps

Quick reference to find specific topics in the original:
| Topic | Timestamp |
|-------|-----------|
| ... | [MM:SS] |
```

**Rules:**

- First principles: decompose every claim to its atomic components
- MECE: themes should not overlap, and together should cover everything said
- Systematic: organize by theme, not by chronological order of the conversation
- No loss: if the speaker said it and it's substantive, it must appear somewhere
- Enrich: add context for EVERY non-obvious term, company, technology, or concept
- Quantitative + Qualitative: always separate hard data from opinions/predictions

### Step 4: Output

Write to `outputs/think/research/{slug}-intake.md`

If the content relates to one of Gary's active projects (Arx, Dux, Atome Wealth, etc.), note specific implications at the end.

---

## scan <topic> [--period <timeframe>]

**Purpose:** Search for material movements — company news, technology developments, market events, regulatory changes. Broad sweep, then filter for signal.

### Step 1: Parse the query

Extract:

- **Topic**: company name, technology, sector, or event
- **Period**: default last 7 days. Parse `--period 30d`, `--period 3m`, `--period 1w`, etc.

### Step 2: Multi-source search (parallel agents)

Launch 2-3 agents:

**Agent 1 (News & Events):** Use Firecrawl search for:

- `"{topic}" news {current month} {current year}`
- `"{topic}" announcement`
- `"{topic}" launch OR release OR update`
  Focus on: funding rounds, product launches, partnerships, regulatory actions, leadership changes, earnings.

**Agent 2 (Technical & Deep):** Use Firecrawl search for:

- `"{topic}" analysis OR deep-dive OR breakdown`
- `"{topic}" technology OR architecture OR how`
  Focus on: technical developments, architecture changes, protocol upgrades, new capabilities.

**Agent 3 (Community & Sentiment):** Use Firecrawl search for:

- `"{topic}" site:x.com OR site:reddit.com`
- `"{topic}" opinion OR prediction OR outlook`
  Focus on: community reaction, KOL takes, sentiment shifts.

### Step 3: Synthesize

```markdown
# Scan: {topic} — Last {period}

## Material Movements (ranked by significance)

### 1. {Most significant development}

**What:** {Factual description}
**When:** {Date}
**Why it matters:** {Impact assessment}
**Source:** {URL}

### 2. {Second most significant}

...

## Signal vs Noise Assessment

**High signal:** {developments that change the trajectory}
**Low signal:** {noise that can be ignored}

## Implications for Gary

{How does this affect Arx, Dux, Atome Wealth, or other active ventures?}

## Sources

- [{title}]({url}) — {one-line summary}
```

### Step 4: Output

Write to `outputs/think/research/{topic}-scan-{date}.md`

---

## sources <action> [args]

**Purpose:** Manage a persistent watchlist of content sources — YouTube channels, X accounts, blogs, newsletters, podcasts. Check for new content.

### Watchlist location

**Global (gOS-level):** `~/.claude/config/intake-sources.md`

This is universal across all projects. The curated KOL watchlist lives here — YouTube channels, X accounts, blogs, podcasts. All projects share the same sources.

### Actions

**`sources list`** — Show current watchlist, grouped by category.

**`sources add <url> [--category <cat>] [--name <name>]`** — Add a source.

- Auto-detect category from URL: youtube.com → YouTube, x.com → X/Twitter, substack.com → Newsletter, etc.
- Auto-detect name from page title if not provided
- Save to watchlist file

**`sources remove <name or url>`** — Remove a source from the watchlist.

**`sources check [--period <timeframe>]`** — Check all sources for new content since last check (default: 7 days).

For each source in the watchlist:

1. Use Firecrawl to scrape the source's page/feed
2. Identify content published within the period
3. For each new piece of content, extract: title, date, URL, 1-line summary

Output:

```markdown
# Source Check — {date}

## New Content (last {period})

### YouTube

| Channel | Title | Date | Link |
| ------- | ----- | ---- | ---- |
| ...     | ...   | ...  | ...  |

### X/Twitter

| Account | Notable Posts | Date |
| ------- | ------------- | ---- |
| ...     | ...           | ...  |

### Blogs / Newsletters

| Source | Title | Date | Link |
| ------ | ----- | ---- | ---- |
| ...    | ...   | ...  | ...  |

## Recommended Deep Dives

{Top 3 pieces worth running `/intake absorb` on, with reasoning}
```

**`sources check <name>`** — Check a single source for new content.

### Watchlist file format

```markdown
---
name: intake_sources
description: Watchlist of content sources for /intake sources check
type: reference
---

# Intake Sources

## YouTube

- [Channel Name](https://youtube.com/@handle) — {why this source matters}

## X / Twitter

- [@handle](https://x.com/handle) — {why this source matters}

## Blogs / Newsletters

- [Blog Name](https://url) — {why this source matters}

## Podcasts

- [Podcast Name](https://url) — {why this source matters}

## Other

- [Name](https://url) — {description}

---

Last checked: {date}
```

---

## Tool Selection Logic

The skill auto-selects tools based on what's needed:

```
URL provided?
  ├── YouTube → defuddle --json (InnerTube transcript + metadata)
  ├── Reddit/X/GitHub/HN → defuddle --markdown (site-specific extractors)
  ├── AI chat (ChatGPT/Claude/Gemini/Grok) → defuddle --markdown
  ├── Article/Blog → defuddle --markdown (first), firecrawl (fallback for anti-bot)
  ├── Anti-bot protected → Firecrawl scrape / Notte MCP
  ├── Needs interaction → Claude in Chrome (login walls, dynamic content)
  ├── PDF → Read tool or PDF MCP
  └── Default → defuddle --markdown (first), firecrawl (fallback)

Search needed?
  ├── Broad topic search → Firecrawl search
  ├── Code/technical → Firecrawl search + Exa
  ├── Company intel → Firecrawl search + Exa company search
  └── Academic → Firecrawl search (scholar/arxiv domains)

API data needed?
  ├── Crypto market → Hyperliquid MCP
  ├── GitHub → gh CLI
  └── Other → Direct HTTP via Firecrawl
```

---

## Scheduling Integration

To schedule recurring scans or source checks:

```
/gos schedule add "intake scan {topic}" --cron "0 9 * * 1"      # Weekly Monday 9am
/gos schedule add "intake sources check" --cron "0 8 * * *"     # Daily 8am
```

---

## Memory Integration

After processing, if the content contains:

- **Project-relevant insights** → Note implications for Arx/Dux/Atome
- **Feedback on how Gary works** → Save as feedback memory
- **New concepts/frameworks** → These live in the output document, not memory
- **Source quality signal** → If a source consistently produces valuable content, note it in the sources watchlist
