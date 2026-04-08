"""Community signal sources: Reddit, Hacker News, Polymarket.

All sources use free, no-API-key-required endpoints:
- Reddit: Old Reddit JSON API (public, no auth needed)
- Hacker News: Algolia search API (free, unlimited)
- Polymarket: CLOB API (public REST)
"""

import asyncio
import re
from datetime import datetime, timezone
from typing import Any

import httpx

# ---------------------------------------------------------------------------
# Shared HTTP client config
# ---------------------------------------------------------------------------

_HEADERS = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "application/json",
}

_TIMEOUT = httpx.Timeout(15.0, connect=10.0)


# ---------------------------------------------------------------------------
# Reddit (public JSON API — no key needed)
# ---------------------------------------------------------------------------

def _reddit_search_sync(
    query: str,
    subreddits: list[str] | None = None,
    sort: str = "relevance",
    time_filter: str = "week",
    limit: int = 15,
) -> list[dict]:
    """Search Reddit via old.reddit.com JSON endpoint (no API key required).

    Returns list of post dicts with title, score, comments, url, subreddit.
    """
    results: list[dict] = []

    # Search across specified subreddits or site-wide
    subs = subreddits or ["all"]

    for sub in subs[:5]:  # Cap subreddit queries
        url = f"https://old.reddit.com/r/{sub}/search.json"
        params = {
            "q": query,
            "sort": sort,
            "t": time_filter,
            "limit": str(min(limit, 25)),
            "restrict_sr": "on" if sub != "all" else "off",
        }

        try:
            resp = httpx.get(
                url,
                params=params,
                headers={**_HEADERS, "Accept": "application/json"},
                timeout=_TIMEOUT,
                follow_redirects=True,
            )
            if resp.status_code != 200:
                continue

            data = resp.json()
            children = data.get("data", {}).get("children", [])

            for child in children:
                post = child.get("data", {})
                created_utc = post.get("created_utc", 0)

                results.append({
                    "source": "reddit",
                    "subreddit": post.get("subreddit", sub),
                    "title": post.get("title", ""),
                    "selftext": (post.get("selftext", "") or "")[:500],
                    "score": post.get("score", 0),
                    "num_comments": post.get("num_comments", 0),
                    "url": f"https://reddit.com{post.get('permalink', '')}",
                    "author": post.get("author", ""),
                    "created_utc": created_utc,
                    "created_at": datetime.fromtimestamp(
                        created_utc, tz=timezone.utc
                    ).isoformat() if created_utc else "",
                    "upvote_ratio": post.get("upvote_ratio", 0),
                })

        except Exception:
            continue  # Silently skip failed subreddits

    # Deduplicate by URL
    seen_urls: set[str] = set()
    deduped: list[dict] = []
    for r in results:
        if r["url"] not in seen_urls:
            seen_urls.add(r["url"])
            deduped.append(r)

    return deduped[:limit]


async def fetch_reddit(
    query: str,
    subreddits: list[str] | None = None,
    sort: str = "relevance",
    time_filter: str = "week",
    limit: int = 15,
) -> list[dict]:
    """Async wrapper for Reddit search."""
    return await asyncio.to_thread(
        _reddit_search_sync, query, subreddits, sort, time_filter, limit
    )


# ---------------------------------------------------------------------------
# Hacker News (Algolia API — free, no key needed)
# ---------------------------------------------------------------------------

def _hn_search_sync(
    query: str,
    tags: str = "story",
    num_results: int = 15,
    sort_by_date: bool = False,
) -> list[dict]:
    """Search Hacker News via Algolia API (completely free, no auth).

    tags: "story" | "comment" | "poll" | "show_hn" | "ask_hn"
    sort_by_date: True for chronological, False for relevance (points-weighted).
    """
    endpoint = (
        "https://hn.algolia.com/api/v1/search_by_date"
        if sort_by_date
        else "https://hn.algolia.com/api/v1/search"
    )

    params = {
        "query": query,
        "tags": tags,
        "hitsPerPage": str(min(num_results, 50)),
    }

    try:
        resp = httpx.get(
            endpoint,
            params=params,
            headers=_HEADERS,
            timeout=_TIMEOUT,
        )
        resp.raise_for_status()
        data = resp.json()

        results: list[dict] = []
        for hit in data.get("hits", []):
            story_id = hit.get("objectID", "")
            results.append({
                "source": "hackernews",
                "title": hit.get("title", "") or hit.get("story_title", ""),
                "url": hit.get("url", "") or f"https://news.ycombinator.com/item?id={story_id}",
                "hn_url": f"https://news.ycombinator.com/item?id={story_id}",
                "points": hit.get("points", 0) or 0,
                "num_comments": hit.get("num_comments", 0) or 0,
                "author": hit.get("author", ""),
                "created_at": hit.get("created_at", ""),
                "story_text": (hit.get("story_text", "") or "")[:500],
                "objectID": story_id,
            })

        return results

    except Exception:
        return []


def _hn_top_stories_sync(limit: int = 15) -> list[dict]:
    """Fetch current top stories from HN (no search query, just trending)."""
    try:
        resp = httpx.get(
            "https://hn.algolia.com/api/v1/search?tags=front_page",
            headers=_HEADERS,
            timeout=_TIMEOUT,
        )
        resp.raise_for_status()
        data = resp.json()

        results: list[dict] = []
        for hit in data.get("hits", [])[:limit]:
            story_id = hit.get("objectID", "")
            results.append({
                "source": "hackernews",
                "title": hit.get("title", ""),
                "url": hit.get("url", "") or f"https://news.ycombinator.com/item?id={story_id}",
                "hn_url": f"https://news.ycombinator.com/item?id={story_id}",
                "points": hit.get("points", 0) or 0,
                "num_comments": hit.get("num_comments", 0) or 0,
                "author": hit.get("author", ""),
                "created_at": hit.get("created_at", ""),
            })

        return results

    except Exception:
        return []


async def fetch_hackernews(
    query: str,
    tags: str = "story",
    num_results: int = 15,
    sort_by_date: bool = False,
) -> list[dict]:
    """Async wrapper for HN search."""
    return await asyncio.to_thread(
        _hn_search_sync, query, tags, num_results, sort_by_date
    )


async def fetch_hn_trending(limit: int = 15) -> list[dict]:
    """Async wrapper for HN front page."""
    return await asyncio.to_thread(_hn_top_stories_sync, limit)


# ---------------------------------------------------------------------------
# Polymarket (CLOB API — public REST, no key needed)
# ---------------------------------------------------------------------------

_POLYMARKET_API = "https://clob.polymarket.com"
_GAMMA_API = "https://gamma-api.polymarket.com"


def _polymarket_search_sync(
    query: str,
    limit: int = 10,
) -> list[dict]:
    """Search Polymarket prediction markets via the Gamma API (no auth needed).

    Returns markets with title, probability, volume, liquidity.
    """
    try:
        resp = httpx.get(
            f"{_GAMMA_API}/events",
            params={
                "tag": "all",
                "limit": str(min(limit * 2, 50)),  # Over-fetch, filter later
                "active": "true",
                "closed": "false",
            },
            headers=_HEADERS,
            timeout=_TIMEOUT,
        )
        resp.raise_for_status()
        events = resp.json()

        query_lower = query.lower()
        query_terms = set(re.findall(r"\w+", query_lower))

        results: list[dict] = []
        for event in events:
            title = event.get("title", "")
            description = event.get("description", "") or ""
            full_text = f"{title} {description}".lower()

            # Text match: check if any query terms appear
            text_terms = set(re.findall(r"\w+", full_text))
            overlap = query_terms & text_terms
            if not overlap and len(query_terms) > 0:
                continue

            text_relevance = len(overlap) / max(len(query_terms), 1)

            # Extract market data from outcomes
            markets = event.get("markets", [])
            outcomes: list[dict] = []
            total_volume = 0.0
            total_liquidity = 0.0

            for market in markets:
                outcome_price = float(market.get("outcomePrices", "0.5") or "0.5")
                if isinstance(market.get("outcomePrices"), str):
                    # Sometimes it's a JSON string like "[0.55, 0.45]"
                    try:
                        prices = _safe_parse_prices(market.get("outcomePrices", ""))
                        outcome_price = prices[0] if prices else 0.5
                    except Exception:
                        outcome_price = 0.5

                vol = float(market.get("volume", 0) or 0)
                liq = float(market.get("liquidityNum", 0) or 0)
                total_volume += vol
                total_liquidity += liq

                outcomes.append({
                    "question": market.get("question", title),
                    "probability": round(outcome_price, 4),
                    "volume": round(vol, 2),
                    "liquidity": round(liq, 2),
                })

            # Compute outcome competitiveness (how close to 50/50)
            if outcomes:
                max_prob = max(o["probability"] for o in outcomes)
                competitiveness = 1.0 - abs(max_prob - 0.5) * 2  # 1.0 at 50/50, 0.0 at 100/0
            else:
                competitiveness = 0.5

            results.append({
                "source": "polymarket",
                "title": title,
                "description": description[:300],
                "url": f"https://polymarket.com/event/{event.get('slug', '')}",
                "outcomes": outcomes[:4],  # Top 4 outcomes
                "total_volume": round(total_volume, 2),
                "total_liquidity": round(total_liquidity, 2),
                "competitiveness": round(competitiveness, 3),
                "text_relevance": round(text_relevance, 3),
                "start_date": event.get("startDate", ""),
                "end_date": event.get("endDate", ""),
            })

        # Sort by combined relevance (text match + volume)
        results.sort(
            key=lambda r: r["text_relevance"] * 0.4 + min(r["total_volume"] / 1_000_000, 1.0) * 0.6,
            reverse=True,
        )

        return results[:limit]

    except Exception:
        return []


def _safe_parse_prices(price_str: str) -> list[float]:
    """Parse Polymarket price strings like '[0.55, 0.45]' or '0.55'."""
    if not price_str:
        return [0.5]
    price_str = price_str.strip()
    if price_str.startswith("["):
        try:
            import json
            return [float(p) for p in json.loads(price_str)]
        except Exception:
            return [0.5]
    try:
        return [float(price_str)]
    except ValueError:
        return [0.5]


def _polymarket_trending_sync(limit: int = 10) -> list[dict]:
    """Fetch trending/high-volume Polymarket events (no search query needed)."""
    try:
        resp = httpx.get(
            f"{_GAMMA_API}/events",
            params={
                "limit": str(min(limit * 2, 50)),
                "active": "true",
                "closed": "false",
                "order": "volume24hr",
                "ascending": "false",
            },
            headers=_HEADERS,
            timeout=_TIMEOUT,
        )
        resp.raise_for_status()
        events = resp.json()

        results: list[dict] = []
        for event in events[:limit]:
            title = event.get("title", "")
            markets = event.get("markets", [])

            outcomes: list[dict] = []
            total_volume = 0.0

            for market in markets:
                prices = _safe_parse_prices(market.get("outcomePrices", ""))
                outcome_price = prices[0] if prices else 0.5
                vol = float(market.get("volume", 0) or 0)
                total_volume += vol

                outcomes.append({
                    "question": market.get("question", title),
                    "probability": round(outcome_price, 4),
                    "volume": round(vol, 2),
                })

            results.append({
                "source": "polymarket",
                "title": title,
                "url": f"https://polymarket.com/event/{event.get('slug', '')}",
                "outcomes": outcomes[:4],
                "total_volume": round(total_volume, 2),
            })

        return results

    except Exception:
        return []


async def fetch_polymarket(query: str, limit: int = 10) -> list[dict]:
    """Async wrapper for Polymarket search."""
    return await asyncio.to_thread(_polymarket_search_sync, query, limit)


async def fetch_polymarket_trending(limit: int = 10) -> list[dict]:
    """Async wrapper for Polymarket trending."""
    return await asyncio.to_thread(_polymarket_trending_sync, limit)


# ---------------------------------------------------------------------------
# Combined community signal fetch
# ---------------------------------------------------------------------------

async def fetch_community_signals_for_topic(
    topic: str,
    reddit_subreddits: list[str] | None = None,
    limit_per_source: int = 10,
) -> dict[str, Any]:
    """Fetch Reddit + HN + Polymarket for a single topic in parallel.

    Returns a dict with keys: reddit, hackernews, polymarket, metadata.
    No API keys required for any source.
    """
    import time
    start = time.time()

    # Default subreddits for crypto/trading context
    default_subs = reddit_subreddits or [
        "cryptocurrency", "defi", "hyperliquid",
        "wallstreetbets", "CryptoMarkets",
    ]

    reddit_task = fetch_reddit(
        topic, subreddits=default_subs, limit=limit_per_source
    )
    hn_task = fetch_hackernews(topic, num_results=limit_per_source)
    poly_task = fetch_polymarket(topic, limit=limit_per_source)

    reddit, hn, poly = await asyncio.gather(
        reddit_task, hn_task, poly_task,
        return_exceptions=True,
    )

    reddit_results = reddit if not isinstance(reddit, Exception) else []
    hn_results = hn if not isinstance(hn, Exception) else []
    poly_results = poly if not isinstance(poly, Exception) else []

    elapsed = round(time.time() - start, 1)

    return {
        "reddit": reddit_results,
        "hackernews": hn_results,
        "polymarket": poly_results,
        "metadata": {
            "topic": topic,
            "total_results": len(reddit_results) + len(hn_results) + len(poly_results),
            "reddit_count": len(reddit_results),
            "hackernews_count": len(hn_results),
            "polymarket_count": len(poly_results),
            "fetch_time_seconds": elapsed,
            "fetched_at": datetime.now(timezone.utc).isoformat(),
        },
    }
