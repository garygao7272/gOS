---
name: source-monitor
description: Check intake sources for new content every 12 hours
schedule: "0 9,21 * * *"
trigger: cron
model: haiku
---

# Source Monitor Claw

## Purpose
Check all sources in `~/.claude/config/intake-sources.md` for new content since last check. Queue findings for the next `/gos` briefing.

## Execution Steps

1. Read `~/.claude/config/intake-sources.md` for the watchlist
2. Read `~/.claude/claws/source-monitor/state.json` for last check timestamps
3. For each source category:
   - **YouTube channels**: WebSearch for "{channel_name} new video" filtered to last check period
   - **X/Twitter accounts**: WebSearch for "from:{handle} site:x.com" filtered to last check period
   - **Blogs/Newsletters**: WebSearch for "site:{blog_url}" filtered to last check period
   - **Podcasts**: WebSearch for "{podcast_name} new episode" filtered to last check period
4. For each new item found:
   - Record: title, url, source, date, one-line summary
   - Add to `state.json.pending_items`
5. Update `state.json.last_checked` timestamps
6. Write `state.json`

## Output Format (in state.json)

```json
{
  "last_run": "ISO timestamp",
  "run_count": 0,
  "last_checked": {
    "source_name": "ISO timestamp"
  },
  "pending_items": [
    {
      "title": "...",
      "url": "...",
      "source": "...",
      "date": "...",
      "summary": "one line",
      "absorbed": false
    }
  ],
  "last_digest": "summary of last run findings"
}
```

## Surfacing in /gos Briefing

When `/gos` runs, it reads `state.json` and shows:
```
Claws > source-monitor: {N} new items since last check ({time_ago})
  Top picks:
  1. {title} — {source} — /think intake {url}
  2. {title} — {source} — /think intake {url}
  3. {title} — {source} — /think intake {url}
```

## Token Budget
Max 5,000 tokens per run. Use haiku model. Keep searches targeted.
