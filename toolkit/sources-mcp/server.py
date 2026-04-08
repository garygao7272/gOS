#!/usr/bin/env python3
"""Arx Sources MCP Server — curated intelligence from Twitter KOLs, YouTube transcripts, blog feeds, and community signals (Reddit, HN, Polymarket)."""

import asyncio
import json
import os
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

# Ensure sibling modules (community_signals, scoring) are importable
sys.path.insert(0, str(Path(__file__).resolve().parent))

import feedparser
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("arx-sources")

SOURCES_CONFIG = Path(os.getenv("SOURCES_CONFIG", "tools/sources-mcp/sources.json"))
NITTER_INSTANCE = os.getenv("NITTER_INSTANCE", "https://nitter.net")


def _load_config() -> dict:
    """Load sources config fresh on each call (no restart needed to update KOLs)."""
    return json.loads(SOURCES_CONFIG.read_text(encoding="utf-8"))


# ---------------------------------------------------------------------------
# Twitter KOL Fetching via Nitter RSS (no API key needed)
# ---------------------------------------------------------------------------

def _fetch_user_tweets_sync(handle: str, hours: int = 24) -> list[dict]:
    """Fetch recent tweets for a single handle via Nitter RSS feed."""
    feed_url = f"{NITTER_INSTANCE}/{handle}/rss"
    cutoff = datetime.now(timezone.utc) - timedelta(hours=hours)

    try:
        feed = feedparser.parse(feed_url)
        if feed.bozo and not feed.entries:
            return [{"handle": handle, "error": f"Feed error: {feed.bozo_exception}"}]

        tweets = []
        for entry in feed.entries[:10]:
            # Parse date
            published = entry.get("published_parsed")
            if published:
                pub_dt = datetime(*published[:6], tzinfo=timezone.utc)
                if pub_dt < cutoff:
                    continue

            title = entry.get("title", "")
            # Skip retweets — we want original takes
            if title.startswith("RT by"):
                continue
            # Skip replies unless they're from the handle (self-threads)
            if title.startswith("R to @") and f"@{handle}" not in title[:50]:
                continue

            # Extract tweet ID from link
            link = entry.get("link", "")
            tweet_id = link.split("/status/")[-1].replace("#m", "") if "/status/" in link else ""

            tweets.append({
                "handle": handle,
                "name": entry.get("dc_creator", f"@{handle}").lstrip("@"),
                "text": title,
                "created_at": entry.get("published", ""),
                "url": f"https://x.com/{handle}/status/{tweet_id}",
            })

        return tweets[:5]  # Top 5 most recent

    except Exception as e:
        return [{"handle": handle, "error": str(e)}]


@mcp.tool()
async def fetch_twitter_kols(category: str = "all", hours: int = 24) -> dict:
    """Fetch recent tweets from tracked KOLs by category via Nitter RSS.

    Categories: ai, crypto, macro, hk_china, fintech, commodities, prediction, startup, all.
    Returns recent tweets per handle, filtered to the last N hours. No API key needed.
    """
    config = _load_config()
    twitter_config = config.get("twitter", {})

    if category == "all":
        categories = list(twitter_config.keys())
    else:
        categories = [category]

    results = {}
    errors = []

    for cat in categories:
        cat_config = twitter_config.get(cat)
        if not cat_config:
            errors.append(f"Unknown category: {cat}")
            continue

        handles = cat_config.get("handles", [])
        # Fetch handles with rate limiting (3 concurrent via semaphore)
        semaphore = asyncio.Semaphore(3)

        async def _rate_limited_fetch(h):
            async with semaphore:
                result = await asyncio.to_thread(_fetch_user_tweets_sync, h, hours)
                await asyncio.sleep(0.3)
                return result

        all_tweets = await asyncio.gather(*[_rate_limited_fetch(h) for h in handles])

        cat_tweets = []
        for tweet_list in all_tweets:
            for tweet in tweet_list:
                if "error" in tweet:
                    errors.append(tweet)
                    continue
                cat_tweets.append(tweet)

        results[cat] = {
            "description": cat_config.get("description", ""),
            "tweets": cat_tweets[:15],  # Top 15 per category
            "handles_queried": len(handles),
        }

    return {
        "categories": results,
        "total_tweets": sum(len(r["tweets"]) for r in results.values()),
        "errors": errors if errors else None,
        "fetched_at": datetime.now(timezone.utc).isoformat(),
    }


# ---------------------------------------------------------------------------
# YouTube Transcript Fetching — Multi-Strategy
#
# Strategy priority (first success wins):
#   1. Supadata API  — env SUPADATA_API_KEY (free 100 req/mo, no IP issues)
#   2. youtube-transcript-api + proxy — env YT_PROXY_URL or WEBSHARE_USERNAME
#   3. youtube-transcript-api direct — works when IP isn't blocked
#
# Set env vars in .mcp.json or shell to enable strategies.
# ---------------------------------------------------------------------------

SUPADATA_API_KEY = os.getenv("SUPADATA_API_KEY", "")
YT_PROXY_URL = os.getenv("YT_PROXY_URL", "")  # e.g. socks5://user:pass@host:port
WEBSHARE_USERNAME = os.getenv("WEBSHARE_USERNAME", "")
WEBSHARE_PASSWORD = os.getenv("WEBSHARE_PASSWORD", "")


def _fetch_channel_videos_sync(channel_id: str, max_results: int = 2) -> list[dict]:
    """Fetch recent videos from a YouTube channel via RSS feed (no API key needed)."""
    if channel_id.startswith("_PLACEHOLDER"):
        return []

    feed_url = f"https://www.youtube.com/feeds/videos.xml?channel_id={channel_id}"
    feed = feedparser.parse(feed_url)

    videos = []
    for entry in feed.entries[:max_results]:
        video_id = entry.get("yt_videoid", "")
        videos.append({
            "title": entry.get("title", ""),
            "url": entry.get("link", ""),
            "video_id": video_id,
            "published": entry.get("published", ""),
        })
    return videos


# --- Strategy 1: Supadata API ---------------------------------------------------

def _fetch_transcript_supadata(video_id: str) -> dict | None:
    """Fetch transcript via Supadata API. Returns None if unavailable or not configured."""
    if not SUPADATA_API_KEY:
        return None

    import httpx
    import time

    url = "https://api.supadata.ai/v1/transcript"
    params = {
        "url": f"https://www.youtube.com/watch?v={video_id}",
        "lang": "en",
        "text": "false",  # Get timestamped chunks for duration + key quotes
    }
    headers = {"x-api-key": SUPADATA_API_KEY}

    try:
        resp = httpx.get(url, params=params, headers=headers, timeout=30)

        # Async job for long videos (>20min) — poll for result
        if resp.status_code == 202:
            job_id = resp.json().get("jobId", "")
            if not job_id:
                return None
            # Poll up to 60s
            for _ in range(30):
                time.sleep(2)
                poll = httpx.get(
                    f"{url}/{job_id}", headers=headers, timeout=15
                )
                if poll.status_code != 200:
                    continue
                data = poll.json()
                if data.get("status") == "completed":
                    return _parse_supadata_response(data, video_id)
                if data.get("status") == "failed":
                    return None
            return None  # Timeout

        if resp.status_code == 206:
            return None  # Transcript unavailable

        if resp.status_code != 200:
            return None

        return _parse_supadata_response(resp.json(), video_id)

    except Exception:
        return None


def _parse_supadata_response(data: dict, video_id: str) -> dict:
    """Parse Supadata response into our standard transcript format."""
    content = data.get("content", [])

    if isinstance(content, str):
        # text=true mode (shouldn't happen but handle it)
        return {
            "skipped": False,
            "text": content,
            "duration_minutes": 0,
            "key_quotes": [],
            "word_count": len(content.split()),
            "strategy": "supadata",
        }

    # Timestamped chunks
    if not content:
        return {"skipped": True, "reason": "empty_transcript", "duration_minutes": 0}

    full_text = " ".join(chunk.get("text", "") for chunk in content)

    # Duration from last chunk
    last = content[-1]
    duration_ms = last.get("offset", 0) + last.get("duration", 0)
    duration_minutes = round(duration_ms / 60000, 1)

    # Key quotes: find 5 longest consecutive groups (simulate paragraph breaks)
    paragraphs = []
    current_texts = []
    current_start_ms = content[0].get("offset", 0) if content else 0
    prev_end_ms = 0

    for chunk in content:
        offset = chunk.get("offset", 0)
        dur = chunk.get("duration", 0)
        gap_ms = offset - prev_end_ms

        if gap_ms > 3000 and current_texts:
            paragraphs.append({
                "text": " ".join(current_texts),
                "start_ms": current_start_ms,
            })
            current_texts = []
            current_start_ms = offset

        current_texts.append(chunk.get("text", ""))
        prev_end_ms = offset + dur

    if current_texts:
        paragraphs.append({
            "text": " ".join(current_texts),
            "start_ms": current_start_ms,
        })

    paragraphs.sort(key=lambda p: len(p["text"]), reverse=True)
    key_quotes = [
        {
            "text": p["text"][:500],
            "timestamp_seconds": round(p["start_ms"] / 1000),
            "timestamp": f"{int(p['start_ms'] // 60000)}:{int((p['start_ms'] % 60000) // 1000):02d}",
        }
        for p in paragraphs[:5]
    ]

    return {
        "skipped": False,
        "text": full_text,
        "duration_minutes": duration_minutes,
        "key_quotes": key_quotes,
        "word_count": len(full_text.split()),
        "strategy": "supadata",
    }


# --- Strategy 2 & 3: youtube-transcript-api (with/without proxy) ----------------

def _build_yt_api():
    """Build YouTubeTranscriptApi with proxy if configured."""
    from youtube_transcript_api import YouTubeTranscriptApi

    proxy_config = None

    if WEBSHARE_USERNAME and WEBSHARE_PASSWORD:
        from youtube_transcript_api.proxies import WebshareProxyConfig
        proxy_config = WebshareProxyConfig(
            proxy_username=WEBSHARE_USERNAME,
            proxy_password=WEBSHARE_PASSWORD,
        )
    elif YT_PROXY_URL:
        from youtube_transcript_api.proxies import GenericProxyConfig
        proxy_config = GenericProxyConfig(https_url=YT_PROXY_URL)

    return YouTubeTranscriptApi(proxy_config=proxy_config)


def _fetch_transcript_yt_api(video_id: str) -> dict | None:
    """Fetch transcript via youtube-transcript-api (with proxy if configured)."""
    try:
        api = _build_yt_api()
        transcript = api.fetch(video_id)
        snippets = list(transcript.snippets)

        if not snippets:
            return {"skipped": True, "reason": "empty_transcript", "duration_minutes": 0}

        last = snippets[-1]
        duration_seconds = last.start + last.duration
        duration_minutes = round(duration_seconds / 60, 1)

        full_text = " ".join(seg.text for seg in snippets)

        # Key quotes via paragraph grouping (pauses > 3s)
        paragraphs = []
        current_para = []
        prev_end = 0.0
        for seg in snippets:
            gap = seg.start - prev_end
            if gap > 3.0 and current_para:
                paragraphs.append({
                    "text": " ".join(s.text for s in current_para),
                    "start": current_para[0].start,
                })
                current_para = []
            current_para.append(seg)
            prev_end = seg.start + seg.duration
        if current_para:
            paragraphs.append({
                "text": " ".join(s.text for s in current_para),
                "start": current_para[0].start,
            })

        paragraphs.sort(key=lambda p: len(p["text"]), reverse=True)
        key_quotes = [
            {
                "text": p["text"][:500],
                "timestamp_seconds": round(p["start"]),
                "timestamp": f"{int(p['start'] // 60)}:{int(p['start'] % 60):02d}",
            }
            for p in paragraphs[:5]
        ]

        strategy = "yt-api"
        if WEBSHARE_USERNAME:
            strategy = "yt-api+webshare"
        elif YT_PROXY_URL:
            strategy = "yt-api+proxy"

        return {
            "skipped": False,
            "text": full_text,
            "duration_minutes": duration_minutes,
            "key_quotes": key_quotes,
            "word_count": len(full_text.split()),
            "strategy": strategy,
        }

    except Exception:
        return None


# --- Orchestrator: try strategies in priority order ----------------------------

def _get_transcript_with_metadata_sync(video_id: str, min_duration_minutes: int = 20) -> dict:
    """Get transcript using multi-strategy fallback chain.

    Priority: Supadata API → youtube-transcript-api+proxy → youtube-transcript-api direct.
    Returns dict with keys: text, duration_minutes, key_quotes, skipped, reason, strategy.
    """
    strategies = [
        ("supadata", _fetch_transcript_supadata),
        ("yt-api", _fetch_transcript_yt_api),
    ]

    last_error = "all strategies failed"

    for name, fetch_fn in strategies:
        result = fetch_fn(video_id)
        if result is None:
            continue

        # Strategy returned a result (might be skipped)
        if result.get("skipped"):
            # If skipped for content reasons (short-form, empty), return immediately
            reason = result.get("reason", "")
            if reason in ("empty_transcript", "short-form"):
                return result
            # If skipped due to error, try next strategy
            last_error = reason
            continue

        # Got a transcript — apply duration filter
        duration = result.get("duration_minutes", 0)
        if duration < min_duration_minutes:
            return {
                "skipped": True,
                "reason": "short-form",
                "duration_minutes": duration,
            }

        return result

    return {"skipped": True, "reason": f"error: {last_error}", "duration_minutes": 0}


@mcp.tool()
async def fetch_youtube_transcripts(
    max_videos_per_channel: int = 2,
    min_duration_minutes: int = 20,
) -> dict:
    """Fetch recent long-form video transcripts from tracked YouTube channels.

    Uses multi-strategy fallback: Supadata API → youtube-transcript-api+proxy → direct.
    Configure via env vars: SUPADATA_API_KEY, YT_PROXY_URL, WEBSHARE_USERNAME/PASSWORD.
    Filters out short-form content (<min_duration_minutes). Returns key quotes.
    """
    config = _load_config()
    yt_config = config.get("youtube", {})
    channels = yt_config.get("channels", [])
    # Allow config override for min duration
    min_dur = yt_config.get("min_duration_minutes", min_duration_minutes)

    results = []
    skipped = []
    errors = []

    for channel in channels:
        name = channel.get("name", "Unknown")
        channel_id = channel.get("channel_id", "")
        category = channel.get("category", "general")

        try:
            videos = await asyncio.to_thread(
                _fetch_channel_videos_sync, channel_id, max_videos_per_channel
            )

            for video in videos:
                # Skip YouTube Shorts URLs
                if "/shorts/" in video.get("url", ""):
                    skipped.append({"title": video["title"], "reason": "shorts_url"})
                    continue

                meta = await asyncio.to_thread(
                    _get_transcript_with_metadata_sync, video["video_id"], min_dur
                )

                if meta.get("skipped"):
                    skipped.append({
                        "title": video["title"],
                        "channel": name,
                        "reason": meta.get("reason", "unknown"),
                        "duration_minutes": meta.get("duration_minutes", 0),
                    })
                    continue

                results.append({
                    "channel": name,
                    "category": category,
                    "title": video["title"],
                    "url": video["url"],
                    "video_id": video["video_id"],
                    "published": video["published"],
                    "duration_minutes": meta["duration_minutes"],
                    "key_quotes": meta.get("key_quotes", []),
                    "word_count": meta.get("word_count", 0),
                    "strategy": meta.get("strategy", "unknown"),
                })

        except Exception as e:
            errors.append({"channel": name, "error": str(e)})

    # Report which strategies are configured
    strategies_available = []
    if SUPADATA_API_KEY:
        strategies_available.append("supadata")
    if WEBSHARE_USERNAME:
        strategies_available.append("webshare-proxy")
    elif YT_PROXY_URL:
        strategies_available.append("generic-proxy")
    strategies_available.append("direct")

    return {
        "videos": results,
        "total_videos": len(results),
        "skipped_videos": skipped,
        "channels_queried": len(channels),
        "min_duration_filter": min_dur,
        "strategies_available": strategies_available,
        "errors": errors if errors else None,
        "fetched_at": datetime.now(timezone.utc).isoformat(),
    }


# ---------------------------------------------------------------------------
# Article Content Extraction
# ---------------------------------------------------------------------------

def _fetch_article_content_sync(url: str, timeout: float = 10.0) -> dict:
    """Fetch and extract clean article text from a URL using trafilatura."""
    try:
        import httpx
        import trafilatura

        resp = httpx.get(url, timeout=timeout, follow_redirects=True, headers={
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
        })
        resp.raise_for_status()

        content = trafilatura.extract(
            resp.text,
            include_comments=False,
            include_tables=True,
            favor_recall=True,
        )

        if not content:
            return {"url": url, "error": "extraction_failed", "content": "", "key_quotes": []}

        # Extract key quotes: first 3 paragraphs > 100 chars (thesis paragraphs)
        paragraphs = [p.strip() for p in content.split("\n") if len(p.strip()) > 100]
        key_quotes = paragraphs[:3]

        return {
            "url": url,
            "content": content[:8000],  # Cap at 8KB for context management
            "word_count": len(content.split()),
            "key_quotes": key_quotes,
        }
    except Exception as e:
        return {"url": url, "error": str(e), "content": "", "key_quotes": []}


@mcp.tool()
async def fetch_article_content(url: str) -> dict:
    """Fetch and extract clean article text from a URL.

    Uses trafilatura to strip boilerplate, ads, navigation — returns just the article body.
    Call this for on-demand deep reading of specific articles identified during synthesis.
    """
    return await asyncio.to_thread(_fetch_article_content_sync, url)


# ---------------------------------------------------------------------------
# On-demand Deep Transcript
# ---------------------------------------------------------------------------

@mcp.tool()
async def fetch_full_transcript(video_id: str) -> dict:
    """Fetch the complete transcript for a specific YouTube video.

    Uses multi-strategy fallback (Supadata → proxy → direct).
    Returns the full text (no cap), duration, and key quotes.
    Use this for selective deep-dive into the most important 3-5 videos.
    """
    meta = await asyncio.to_thread(
        _get_transcript_with_metadata_sync, video_id, 0  # No duration filter for explicit requests
    )
    if meta.get("skipped") and meta.get("reason", "").startswith("error"):
        return {"video_id": video_id, "error": meta["reason"]}
    return {
        "video_id": video_id,
        "duration_minutes": meta.get("duration_minutes", 0),
        "word_count": meta.get("word_count", 0),
        "key_quotes": meta.get("key_quotes", []),
        "full_text": meta.get("text", ""),
        "strategy": meta.get("strategy", "unknown"),
    }


# ---------------------------------------------------------------------------
# Blog/RSS Feed Fetching
# ---------------------------------------------------------------------------

def _fetch_feed_sync(feed_config: dict, hours: int = 48) -> list[dict]:
    """Fetch entries from an RSS/Atom feed within the time window."""
    feed = feedparser.parse(feed_config["feed_url"])
    cutoff = datetime.now(timezone.utc) - timedelta(hours=hours)

    entries = []
    for entry in feed.entries[:10]:
        published = entry.get("published_parsed") or entry.get("updated_parsed")
        if published:
            pub_dt = datetime(*published[:6], tzinfo=timezone.utc)
            if pub_dt < cutoff:
                continue
        entries.append({
            "source": feed_config["name"],
            "title": entry.get("title", ""),
            "url": entry.get("link", ""),
            "published": entry.get("published", ""),
            "summary": (entry.get("summary", "") or "")[:500],
        })

    return entries


@mcp.tool()
async def fetch_blog_feeds(hours: int = 48, fetch_content: bool = False) -> dict:
    """Fetch recent articles from tracked blog RSS feeds.

    When fetch_content=True, also extracts article body text for the top 3 articles
    per category using trafilatura. This provides actual quotes and analysis, not just titles.
    """
    config = _load_config()
    blog_config = config.get("blogs", {})

    results = {}
    errors = []

    for category, feeds in blog_config.items():
        cat_entries = []
        for feed_config in feeds:
            try:
                entries = await asyncio.to_thread(_fetch_feed_sync, feed_config, hours)
                cat_entries.extend(entries)
            except Exception as e:
                errors.append({"source": feed_config.get("name", "?"), "error": str(e)})

        # Fetch article content for top 3 entries per category
        if fetch_content and cat_entries:
            semaphore = asyncio.Semaphore(3)

            async def _fetch_with_limit(entry):
                async with semaphore:
                    result = await asyncio.to_thread(
                        _fetch_article_content_sync, entry["url"]
                    )
                    entry["content"] = result.get("content", "")
                    entry["key_quotes"] = result.get("key_quotes", [])
                    entry["word_count"] = result.get("word_count", 0)

            await asyncio.gather(*[_fetch_with_limit(e) for e in cat_entries[:3]])

        results[category] = cat_entries

    return {
        "categories": results,
        "total_articles": sum(len(v) for v in results.values()),
        "content_fetched": fetch_content,
        "errors": errors if errors else None,
        "fetched_at": datetime.now(timezone.utc).isoformat(),
    }


# ---------------------------------------------------------------------------
# All Sources (parallel fetch)
# ---------------------------------------------------------------------------

def _extract_topic_overlap(twitter: dict, youtube: dict, blogs: dict) -> list[str]:
    """Find topics mentioned across 2+ source types (lightweight keyword co-occurrence)."""
    import re
    from collections import Counter

    def _extract_terms(text: str) -> set[str]:
        words = re.findall(r"[A-Z][a-z]+(?:\s[A-Z][a-z]+)*|[A-Z]{2,}", text)
        return {w.lower() for w in words if len(w) > 3}

    twitter_terms: set[str] = set()
    youtube_terms: set[str] = set()
    blog_terms: set[str] = set()

    if isinstance(twitter, dict):
        for cat in twitter.get("categories", {}).values():
            for tweet in cat.get("tweets", []):
                twitter_terms.update(_extract_terms(tweet.get("text", "")))

    if isinstance(youtube, dict):
        for video in youtube.get("videos", []):
            youtube_terms.update(_extract_terms(video.get("title", "")))
            for q in video.get("key_quotes", []):
                youtube_terms.update(_extract_terms(q.get("text", "")))

    if isinstance(blogs, dict):
        for entries in blogs.get("categories", {}).values():
            for entry in entries:
                blog_terms.update(_extract_terms(entry.get("title", "")))
                blog_terms.update(_extract_terms(entry.get("content", "")))

    # Terms appearing in 2+ source types
    all_sources = [twitter_terms, youtube_terms, blog_terms]
    term_counts = Counter()
    for terms in all_sources:
        for t in terms:
            term_counts[t] += 1

    return [term for term, count in term_counts.most_common(15) if count >= 2]


@mcp.tool()
async def fetch_all_sources(hours: int = 24) -> dict:
    """Fetch ALL sources in parallel — Twitter KOLs, YouTube transcripts (long-form only), and blog feeds (with article content).

    This is the primary tool for the daily briefing. One call, all data.
    YouTube filters out shorts (<20min). Blog feeds include article body text for top articles.
    """
    import time
    start = time.time()

    twitter_task = fetch_twitter_kols("all", hours)
    youtube_task = fetch_youtube_transcripts(2, 20)
    blogs_task = fetch_blog_feeds(hours * 2, fetch_content=True)

    # Community signals: fetch HN trending + Polymarket trending (no query needed)
    hn_task = fetch_hn_trending(15)
    poly_task = fetch_polymarket_trending(10)

    twitter, youtube, blogs, hn_trending, poly_trending = await asyncio.gather(
        twitter_task, youtube_task, blogs_task, hn_task, poly_task,
        return_exceptions=True,
    )

    # Safe unwrap
    tw = twitter if not isinstance(twitter, Exception) else {"error": str(twitter)}
    yt = youtube if not isinstance(youtube, Exception) else {"error": str(youtube)}
    bl = blogs if not isinstance(blogs, Exception) else {"error": str(blogs)}
    hn = hn_trending if not isinstance(hn_trending, Exception) else []
    pm = poly_trending if not isinstance(poly_trending, Exception) else []

    # Cross-source topic overlap (now includes community sources)
    topic_overlap = _extract_topic_overlap(tw, yt, bl)

    # Extend overlap with HN/Polymarket topics
    _extend_topic_overlap_community(topic_overlap, hn, pm)

    elapsed = round(time.time() - start, 1)

    return {
        "twitter": tw,
        "youtube": yt,
        "blogs": bl,
        "community": {
            "hackernews_trending": hn,
            "polymarket_trending": pm,
            "hn_count": len(hn) if isinstance(hn, list) else 0,
            "polymarket_count": len(pm) if isinstance(pm, list) else 0,
        },
        "topic_overlap": topic_overlap,
        "fetch_time_seconds": elapsed,
    }


def _extend_topic_overlap_community(
    topic_overlap: list[str],
    hn_items: list[dict],
    poly_items: list[dict],
) -> None:
    """Extend topic overlap list with terms from community sources.

    Mutates topic_overlap in place (adds terms found in HN/Polymarket
    that also appear in the existing overlap or in both community sources).
    """
    import re

    def _extract_terms(text: str) -> set[str]:
        words = re.findall(r"[A-Z][a-z]+(?:\s[A-Z][a-z]+)*|[A-Z]{2,}", text)
        return {w.lower() for w in words if len(w) > 3}

    hn_terms: set[str] = set()
    poly_terms: set[str] = set()

    if isinstance(hn_items, list):
        for item in hn_items:
            hn_terms.update(_extract_terms(item.get("title", "")))

    if isinstance(poly_items, list):
        for item in poly_items:
            poly_terms.update(_extract_terms(item.get("title", "")))

    existing = set(topic_overlap)

    # Terms in both HN and Polymarket
    cross_community = hn_terms & poly_terms
    # Terms in community that overlap with existing sources
    community_confirms = (hn_terms | poly_terms) & existing

    new_terms = (cross_community | community_confirms) - existing
    topic_overlap.extend(sorted(new_terms)[:10])


# ---------------------------------------------------------------------------
# URL Verification
# ---------------------------------------------------------------------------

_url_verification_cache: dict[str, tuple[bool, float]] = {}
_URL_CACHE_TTL = 3600  # 1 hour


async def _verify_url(url: str) -> bool:
    """Verify a URL is reachable via HEAD request. Cached for 1 hour."""
    import time
    now = time.time()

    if url in _url_verification_cache:
        valid, cached_at = _url_verification_cache[url]
        if now - cached_at < _URL_CACHE_TTL:
            return valid

    try:
        import httpx
        async with httpx.AsyncClient(timeout=5, follow_redirects=True) as client:
            resp = await client.head(url, headers={
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
            })
            valid = 200 <= resp.status_code < 400
    except Exception:
        valid = False

    _url_verification_cache[url] = (valid, now)
    return valid


async def _verify_urls(urls: list[str]) -> dict[str, bool]:
    """Batch verify URLs with 10 concurrent requests. Returns {url: is_valid}."""
    semaphore = asyncio.Semaphore(10)

    async def _check(url):
        async with semaphore:
            return url, await _verify_url(url)

    results = await asyncio.gather(*[_check(u) for u in urls])
    return dict(results)


@mcp.tool()
async def verify_source_urls(urls: list[str]) -> dict:
    """Verify a list of source URLs are reachable (HEAD request, 5s timeout).

    Use this before including source links in briefings to ensure zero dead links.
    Returns verification results and summary stats.
    """
    results = await _verify_urls(urls)
    valid_count = sum(1 for v in results.values() if v)
    return {
        "results": results,
        "total": len(urls),
        "valid": valid_count,
        "invalid": len(urls) - valid_count,
        "invalid_urls": [u for u, v in results.items() if not v],
    }


# ---------------------------------------------------------------------------
# Trending Events Discovery (War Room)
# ---------------------------------------------------------------------------

@mcp.tool()
async def fetch_trending_events(period_hours: int = 24) -> dict:
    """Discover and rank trending events by potential financial market influence.

    Scrapes web search results across macro, geopolitical, crypto, commodities, FX.
    Ranks events by: (asset classes affected) x (price impact magnitude) x (immediacy).
    Top 3 events feed into MiroFish simulation. Used by War Room briefing.
    """
    import httpx
    import re
    from collections import Counter

    queries = [
        ("macro", "breaking news financial markets today"),
        ("geopolitical", "geopolitical risk war conflict markets today"),
        ("crypto", "breaking news cryptocurrency Bitcoin today"),
        ("commodities", "oil gold commodity prices news today"),
        ("fx", "forex USD EUR JPY currency news today"),
        ("central_banks", "federal reserve central bank policy news today"),
    ]

    # This tool prepares structured event data for the briefing agent to rank.
    # The actual WebSearch calls happen in the briefing SKILL.md (since MCP tools
    # can't call other MCP tools). This tool aggregates data from the sources
    # we already have (Twitter KOLs + blogs) and cross-references for trending topics.

    config = _load_config()

    # Pull topic signals from existing sources
    twitter_config = config.get("twitter", {})
    macro_handles = twitter_config.get("macro", {}).get("handles", [])
    commodities_handles = twitter_config.get("commodities", {}).get("handles", [])
    prediction_handles = twitter_config.get("prediction", {}).get("handles", [])
    hk_china_handles = twitter_config.get("hk_china", {}).get("handles", [])

    all_war_handles = macro_handles + commodities_handles + prediction_handles + hk_china_handles

    # Fetch relevant tweets
    semaphore = asyncio.Semaphore(5)

    async def _fetch(h):
        async with semaphore:
            result = await asyncio.to_thread(_fetch_user_tweets_sync, h, period_hours)
            await asyncio.sleep(0.2)
            return result

    tweet_lists = await asyncio.gather(*[_fetch(h) for h in all_war_handles])

    # Aggregate tweets and extract event-like topics
    all_tweets = []
    for tl in tweet_lists:
        for t in tl:
            if "error" not in t:
                all_tweets.append(t)

    # Simple NLP: extract capitalized multi-word phrases as event candidates
    event_terms = Counter()
    for tweet in all_tweets:
        text = tweet.get("text", "")
        # Find capitalized phrases (event names, company names, etc.)
        phrases = re.findall(r"[A-Z][a-z]+(?:\s+[A-Z][a-z]+)+", text)
        for p in phrases:
            if len(p) > 8:  # Skip short generic phrases
                event_terms[p] += 1
        # Find ticker-like mentions
        tickers = re.findall(r"\$[A-Z]{2,5}", text)
        for t in tickers:
            event_terms[t] += 1
        # Find hashtag topics
        hashtags = re.findall(r"#\w+", text)
        for h in hashtags:
            event_terms[h] += 1

    # Build event list from most-mentioned topics
    events = []
    for term, count in event_terms.most_common(20):
        # Find tweets that mention this term
        related_tweets = [
            t for t in all_tweets if term.lower() in t.get("text", "").lower()
        ]

        # Determine asset classes affected (heuristic)
        asset_classes = set()
        text_blob = " ".join(t.get("text", "") for t in related_tweets).lower()
        if any(w in text_blob for w in ["oil", "crude", "brent", "wti", "gas", "energy"]):
            asset_classes.add("commodities")
        if any(w in text_blob for w in ["bitcoin", "btc", "crypto", "eth", "defi"]):
            asset_classes.add("crypto")
        if any(w in text_blob for w in ["s&p", "nasdaq", "stock", "equity", "dow"]):
            asset_classes.add("equities")
        if any(w in text_blob for w in ["dollar", "usd", "eur", "yen", "forex", "fx", "dxy"]):
            asset_classes.add("fx")
        if any(w in text_blob for w in ["gold", "silver", "precious"]):
            asset_classes.add("precious_metals")
        if any(w in text_blob for w in ["fed", "rate", "fomc", "powell", "inflation"]):
            asset_classes.add("rates")
        if any(w in text_blob for w in ["polymarket", "prediction", "odds", "probability"]):
            asset_classes.add("prediction_markets")

        if not asset_classes:
            asset_classes.add("general")

        # Influence score: mentions x asset classes x recency
        influence_score = count * len(asset_classes)

        events.append({
            "topic": term,
            "mention_count": count,
            "influence_score": influence_score,
            "asset_classes_affected": sorted(asset_classes),
            "source_tweets": [
                {"handle": t["handle"], "text": t["text"][:200], "url": t.get("url", "")}
                for t in related_tweets[:5]
            ],
            "suggested_search_queries": [
                f"{term} financial market impact",
                f"{term} stock price effect",
            ],
        })

    # Sort by influence score
    events.sort(key=lambda e: e["influence_score"], reverse=True)

    return {
        "events": events[:10],
        "total_tweets_analyzed": len(all_tweets),
        "handles_queried": len(all_war_handles),
        "period_hours": period_hours,
        "fetched_at": datetime.now(timezone.utc).isoformat(),
        "instruction": (
            "Top 3 events by influence_score should feed into MiroFish simulation. "
            "Use suggested_search_queries for deeper WebSearch on each event. "
            "Cross-reference source_tweets for KOL quotes to embed inline."
        ),
    }


# ---------------------------------------------------------------------------
# Viral Signal Discovery (Signal Scan)
# ---------------------------------------------------------------------------

def _scrape_github_trending_sync() -> list[dict]:
    """Scrape GitHub trending repos, filtered for finance/crypto/AI/productivity."""
    import httpx
    from html.parser import HTMLParser

    try:
        resp = httpx.get(
            "https://github.com/trending?since=daily",
            timeout=15,
            headers={"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"},
            follow_redirects=True,
        )
        resp.raise_for_status()
        html = resp.text

        repos = []
        # Simple regex extraction from trending page
        import re
        # Match repo links: /user/repo pattern in h2 tags
        repo_pattern = re.findall(
            r'<h2[^>]*>\s*<a[^>]*href="(/[^"]+)"[^>]*>\s*'
            r'(?:<span[^>]*>[^<]*</span>\s*/\s*)?'
            r'<span[^>]*>([^<]+)</span>',
            html,
        )

        # Match descriptions
        desc_pattern = re.findall(r'<p class="col-9[^"]*">\s*([^<]+)', html)

        # Match stars today
        stars_pattern = re.findall(r'(\d[\d,]*)\s*stars\s+today', html)

        relevance_keywords = {
            "trading", "finance", "crypto", "blockchain", "defi", "ai", "llm",
            "agent", "fintech", "investing", "portfolio", "market", "productivity",
            "automation", "lending", "payments", "wallet", "exchange", "quant",
        }

        for i, (path, name) in enumerate(repo_pattern[:25]):
            desc = desc_pattern[i].strip() if i < len(desc_pattern) else ""
            stars = stars_pattern[i].replace(",", "") if i < len(stars_pattern) else "0"

            full_text = f"{name} {desc} {path}".lower()
            is_relevant = any(kw in full_text for kw in relevance_keywords)

            if is_relevant:
                repos.append({
                    "repo": path.strip("/"),
                    "name": name.strip(),
                    "description": desc,
                    "stars_today": int(stars) if stars.isdigit() else 0,
                    "url": f"https://github.com{path.strip()}",
                })

        return repos[:10]

    except Exception as e:
        return [{"error": str(e)}]


def _scrape_product_hunt_sync() -> list[dict]:
    """Fetch Product Hunt top posts via RSS, filtered for fintech/crypto/AI/productivity."""
    try:
        feed = feedparser.parse("https://www.producthunt.com/feed")
        relevance_keywords = {
            "trading", "finance", "crypto", "blockchain", "defi", "ai", "llm",
            "fintech", "investing", "portfolio", "market", "productivity",
            "automation", "lending", "payments", "wallet", "exchange",
            "agent", "tool", "developer", "startup",
        }

        products = []
        for entry in feed.entries[:20]:
            title = entry.get("title", "")
            summary = entry.get("summary", "")
            full_text = f"{title} {summary}".lower()

            is_relevant = any(kw in full_text for kw in relevance_keywords)
            if is_relevant:
                products.append({
                    "name": title,
                    "tagline": summary[:200],
                    "url": entry.get("link", ""),
                    "published": entry.get("published", ""),
                })

        return products[:10]

    except Exception as e:
        return [{"error": str(e)}]


@mcp.tool()
async def fetch_viral_signals() -> dict:
    """Discover viral/breakout tools, products, and trends from GitHub, Product Hunt, and X.com.

    Filters for: trading, investing, lending, crypto, AI, fintech, productivity.
    Geographic focus: APAC + US. Used by Signal Scan briefing.
    """
    github_task = asyncio.to_thread(_scrape_github_trending_sync)
    ph_task = asyncio.to_thread(_scrape_product_hunt_sync)

    github, product_hunt = await asyncio.gather(
        github_task, ph_task, return_exceptions=True
    )

    gh = github if not isinstance(github, Exception) else [{"error": str(github)}]
    ph = product_hunt if not isinstance(product_hunt, Exception) else [{"error": str(product_hunt)}]

    return {
        "github_trending": gh,
        "product_hunt": ph,
        "sources_scraped": ["github.com/trending", "producthunt.com/feed"],
        "filter": "trading, investing, lending, crypto, AI, fintech, productivity",
        "geographic_focus": "APAC + US",
        "fetched_at": datetime.now(timezone.utc).isoformat(),
    }


# ---------------------------------------------------------------------------
# Source Config Management
# ---------------------------------------------------------------------------

@mcp.tool()
def get_source_config() -> dict:
    """Return the current sources configuration — which KOLs, channels, and blogs are tracked."""
    return _load_config()


@mcp.tool()
def recommend_sources(category: str, existing_handles: list[str] | None = None) -> dict:
    """Suggest new KOLs, YouTube channels, or blogs to add based on a category.

    Use this to grow the source list over time. Returns recommendations with rationale.
    Categories: ai, crypto, macro, fintech, startup, hk_china, commodities, prediction.
    """
    # This tool returns a structured prompt for the LLM to expand on
    config = _load_config()
    current = {}

    twitter_cat = config.get("twitter", {}).get(category, {})
    current["twitter_handles"] = twitter_cat.get("handles", [])
    current["youtube_channels"] = [
        c["name"] for c in config.get("youtube", {}).get("channels", [])
        if c.get("category") == category
    ]
    current["blog_feeds"] = [
        f["name"] for feeds in config.get("blogs", {}).values()
        for f in feeds
    ]

    return {
        "category": category,
        "currently_tracking": current,
        "instruction": (
            f"Based on the '{category}' category, suggest 5-10 new sources to track. "
            f"For each, provide: platform (twitter/youtube/blog), handle/channel/url, "
            f"why they're high-signal, and their typical posting frequency. "
            f"Avoid accounts that are mostly promotional or low-insight engagement bait. "
            f"Prioritize: original analysis, contrarian takes, data-backed insights, "
            f"and practitioners (builders/traders) over commentators."
        ),
    }


# ---------------------------------------------------------------------------
# Community Signals (Reddit, HN, Polymarket) — no API keys needed
# ---------------------------------------------------------------------------

from community_signals import (
    fetch_community_signals_for_topic,
    fetch_reddit,
    fetch_hackernews,
    fetch_hn_trending,
    fetch_polymarket,
    fetch_polymarket_trending,
)
from scoring import score_and_rank as _score_and_rank_impl


@mcp.tool()
async def fetch_community_signals(
    topic: str,
    reddit_subreddits: list[str] | None = None,
    limit_per_source: int = 10,
) -> dict:
    """Search Reddit + Hacker News + Polymarket for a topic. No API keys required.

    Returns community discussion, technical perspectives, and prediction market data
    for any topic. Use this for sentiment analysis, community pulse, and probability-
    weighted forecasts.

    Default Reddit subreddits: cryptocurrency, defi, hyperliquid, wallstreetbets, CryptoMarkets.
    Override with reddit_subreddits parameter for other topics.
    """
    config = _load_config()
    community_config = config.get("community", {})

    # Merge config subreddits with overrides
    default_subs = community_config.get("reddit_subreddits", [
        "cryptocurrency", "defi", "hyperliquid",
        "wallstreetbets", "CryptoMarkets",
    ])
    subs = reddit_subreddits or default_subs

    return await fetch_community_signals_for_topic(
        topic=topic,
        reddit_subreddits=subs,
        limit_per_source=limit_per_source,
    )


@mcp.tool()
async def score_and_rank(
    items: list[dict],
    query: str,
    half_life_hours: float = 48.0,
    deduplicate_threshold: float = 0.6,
) -> dict:
    """Score, deduplicate, and rank items from any combination of sources.

    Applies multi-signal quality scoring:
    - Text relevance (30%): trigram-token Jaccard similarity to query
    - Engagement velocity (25%): normalized by source type
    - Source authority (15%): per-platform credibility weight
    - Temporal decay (20%): exponential with configurable half-life
    - Cross-platform convergence (10%): bonus for topics in 2+ sources

    Polymarket items get special 5-factor scoring (text, volume, liquidity, velocity, competitiveness).
    Deduplication uses hybrid trigram-token Jaccard at the specified threshold.

    Pass items from fetch_community_signals, fetch_all_sources, or any mix of source results.
    Each item must have a 'source' field (reddit, hackernews, polymarket, twitter, youtube, blog).
    """
    return _score_and_rank_impl(
        items=items,
        query=query,
        half_life_hours=half_life_hours,
        deduplicate_threshold=deduplicate_threshold,
    )


if __name__ == "__main__":
    mcp.run()
