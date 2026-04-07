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

**YouTube transcript extraction:**
```bash
# Already installed: youtube-transcript-api via pip3
python3 -c "from youtube_transcript_api import YouTubeTranscriptApi; print('OK')"
```

**Web scraping (Firecrawl CLI):**
```bash
# Installed via npx, authenticated
npx firecrawl-cli --status
```

**Audio transcription (Whisper — nuclear option for no-caption videos):**
```bash
# Already installed: openai-whisper, yt-dlp, ffmpeg
yt-dlp --version    # downloads audio
whisper --help       # local speech-to-text (no API key needed, runs on CPU)
```

**Fallback chain for YouTube (in order):**
1. `youtube-transcript-api` Python package — fastest, works for videos with captions (~1 second)
2. `yt-dlp --write-auto-sub` — handles edge cases the Python lib misses, also gets chapters/description
3. **Whisper local transcription** — downloads audio via `yt-dlp -x`, transcribes with Whisper. Works on ANY video regardless of captions. Takes ~2-5 min for a 40-60 min video on CPU. Use `base` model for speed, `medium` for accuracy.
4. Direct HTTP metadata + WebSearch — always gets title/description/timestamps as minimum enrichment

**YouTube extraction script (copy-paste reliable):**
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

**Whisper transcription script (works on ANY video, even without captions):**
```bash
# Step 1: Download audio only
yt-dlp -x --audio-format mp3 --audio-quality 5 \
  -o ".firecrawl/audio/%(id)s.%(ext)s" \
  "https://www.youtube.com/watch?v=VIDEO_ID_HERE"

# Step 2: Transcribe with Whisper (auto-detects language)
python3 -c "
import whisper, sys
model = whisper.load_model('base')  # 'base' for speed, 'medium' for accuracy
result = model.transcribe('.firecrawl/audio/VIDEO_ID_HERE.mp3', verbose=False)
with open('.firecrawl/VIDEO_ID_HERE-whisper-transcript.txt', 'w') as f:
    for seg in result['segments']:
        mins = int(seg['start'] // 60)
        secs = int(seg['start'] % 60)
        f.write(f'[{mins:02d}:{secs:02d}] {seg[\"text\"].strip()}\n')
print(f'Wrote {len(result[\"segments\"])} segments, language: {result[\"language\"]}')
"
```
Performance: ~2 min for 40 min audio on M-series Mac CPU. No API key, no internet needed for transcription.

**YouTube metadata extraction (always works, even without captions):**
```python
python3 -c "
import urllib.request, re
url = 'https://www.youtube.com/watch?v=VIDEO_ID_HERE'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0', 'Accept-Language': 'en-US,en;q=0.9,zh;q=0.8'})
html = urllib.request.urlopen(req).read().decode('utf-8')
for field, pattern in [('TITLE', r'<title>(.*?)</title>'), ('CHANNEL', r'\"ownerChannelName\":\"(.*?)\"'), ('DURATION', r'\"lengthSeconds\":\"(\d+)\"'), ('DATE', r'\"publishDate\":\"(.*?)\"')]:
    m = re.search(pattern, html)
    if m: print(f'{field}: {m.group(1)}')
desc = re.search(r'\"shortDescription\":\"(.*?)\"', html)
if desc: print(f'DESCRIPTION: {desc.group(1)[:2000]}')
"
```

---

## absorb <url or topic>

**Purpose:** Take a single content source (YouTube, podcast, article, X thread, PDF, blog post) and produce a structured knowledge document. Zero nuance loss.

**Language rule:** Output document MUST be in the same language as the source content. Chinese video → Chinese document. English article → English document.

### Step 1: Extract raw content

Detect source type from URL and use the right tool:

| Source | Extraction Method |
|--------|------------------|
| YouTube (`youtube.com`, `youtu.be`) | **Step 1a:** Extract video ID from URL. **Step 1b:** Run `python3` youtube-transcript-api to get transcript with timestamps. **Step 1c:** If transcript fails (captions disabled), run `python3` metadata extraction to get title, channel, duration, description, timestamps. **Step 1d:** If description has timestamps/timeline, use those as structure. **Step 1e:** Search web for supplementary content (PR, news, summaries) to enrich. |
| Podcast (Spotify, Apple, RSS) | `npx firecrawl-cli scrape <url>` for show notes. If audio-only, note limitation and work with available show notes/description. |
| Article / Blog | `npx firecrawl-cli scrape <url> -o .firecrawl/{slug}.md` then read the output |
| X/Twitter thread | `npx firecrawl-cli scrape <url> -o .firecrawl/{slug}.md` then read the output |
| PDF | Use the Read tool or PDF MCP tools |
| Any other URL | `npx firecrawl-cli scrape <url> -o .firecrawl/{slug}.md` as default |

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
|--------|-------|---------|
| ... | ... | ... |

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
|---------|-------|------|------|
| ... | ... | ... | ... |

### X/Twitter
| Account | Notable Posts | Date |
|---------|-------------|------|
| ... | ... | ... |

### Blogs / Newsletters
| Source | Title | Date | Link |
|--------|-------|------|------|
| ... | ... | ... | ... |

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
  ├── YouTube/Podcast → Firecrawl scrape (transcript extraction)
  ├── X/Twitter → Firecrawl scrape (thread extraction)
  ├── Anti-bot protected → Notte MCP (if available)
  ├── Needs interaction → Claude in Chrome (login walls, dynamic content)
  ├── PDF → Read tool or PDF MCP
  └── Default → Firecrawl scrape

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
