"""Relevance scoring and deduplication engine.

Adapted from the multi-signal quality-ranked composite scoring approach
(inspired by mvanhorn/last30days-skill) with Arx-specific source weighting.

Scoring dimensions:
1. Text similarity — bidirectional trigram-token Jaccard
2. Engagement velocity — normalized by source authority
3. Source weighting — per-platform credibility multiplier
4. Cross-platform convergence — topics appearing in 2+ sources
5. Temporal decay — recency preference (configurable half-life)
6. Polymarket-specific — 5-factor composite (text, volume, liquidity, velocity, competitiveness)
"""

import math
import re
from collections import Counter
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any


# ---------------------------------------------------------------------------
# Source authority weights (higher = more trusted signal)
# ---------------------------------------------------------------------------

SOURCE_WEIGHTS: dict[str, float] = {
    "hackernews": 1.2,    # High signal, technical crowd, point-weighted
    "reddit": 0.9,        # Large volume but noisier
    "polymarket": 1.4,    # Money-on-the-line signal, highest conviction
    "twitter": 1.0,       # Baseline
    "youtube": 0.8,       # Long-form, slow signal but deep
    "blog": 1.1,          # Curated, editorial quality
    "github_trending": 0.7,  # Weak signal for market events
    "product_hunt": 0.6,  # Product signal, not market signal
}


# ---------------------------------------------------------------------------
# Text similarity: trigram-token hybrid Jaccard
# ---------------------------------------------------------------------------

def _trigrams(text: str) -> set[str]:
    """Extract character trigrams from normalized text."""
    normalized = re.sub(r"[^a-z0-9 ]", "", text.lower())
    return {normalized[i:i+3] for i in range(len(normalized) - 2)}


def _tokens(text: str) -> set[str]:
    """Extract word tokens from text, lowercased."""
    return set(re.findall(r"\b\w{3,}\b", text.lower()))


def text_similarity(a: str, b: str) -> float:
    """Hybrid trigram-token Jaccard similarity (0.0 to 1.0).

    Combines character trigrams (catches fuzzy matches) with word tokens
    (catches semantic overlap). Weighted 40% trigram + 60% token.
    """
    if not a or not b:
        return 0.0

    tri_a, tri_b = _trigrams(a), _trigrams(b)
    tok_a, tok_b = _tokens(a), _tokens(b)

    # Trigram Jaccard
    tri_inter = len(tri_a & tri_b)
    tri_union = len(tri_a | tri_b)
    tri_sim = tri_inter / tri_union if tri_union else 0.0

    # Token Jaccard
    tok_inter = len(tok_a & tok_b)
    tok_union = len(tok_a | tok_b)
    tok_sim = tok_inter / tok_union if tok_union else 0.0

    return 0.4 * tri_sim + 0.6 * tok_sim


# ---------------------------------------------------------------------------
# Temporal decay
# ---------------------------------------------------------------------------

def temporal_decay(
    created_at: str | float | None,
    half_life_hours: float = 48.0,
) -> float:
    """Compute temporal decay factor (0.0 to 1.0).

    Uses exponential decay with configurable half-life.
    Returns 1.0 for brand-new items, 0.5 at half_life_hours, approaching 0 for old items.
    """
    if created_at is None:
        return 0.5  # Unknown age gets neutral score

    now = datetime.now(timezone.utc)

    if isinstance(created_at, (int, float)):
        # Unix timestamp
        item_time = datetime.fromtimestamp(created_at, tz=timezone.utc)
    elif isinstance(created_at, str):
        try:
            # ISO format
            item_time = datetime.fromisoformat(created_at.replace("Z", "+00:00"))
        except ValueError:
            return 0.5
    else:
        return 0.5

    age_hours = (now - item_time).total_seconds() / 3600
    if age_hours < 0:
        return 1.0  # Future-dated items get full score

    # Exponential decay: score = 2^(-age/half_life)
    return math.pow(2, -age_hours / half_life_hours)


# ---------------------------------------------------------------------------
# Engagement normalization
# ---------------------------------------------------------------------------

def _normalize_engagement(value: float, source: str) -> float:
    """Normalize engagement metrics to 0.0-1.0 scale per source.

    Different sources have wildly different engagement scales:
    - Reddit: scores can be 0-100K+
    - HN: points range 0-5K
    - Polymarket: volume in USD, 0-10M+
    """
    thresholds: dict[str, tuple[float, float]] = {
        "reddit": (10, 5000),         # 10 = low, 5K = hot
        "hackernews": (5, 500),       # 5 = low, 500 = front page
        "polymarket": (10000, 1_000_000),  # $10K = low, $1M = major market
        "twitter": (10, 5000),        # likes/RTs
        "youtube": (1000, 100_000),   # views
        "blog": (0, 1),              # Blogs don't have engagement metrics
    }

    low, high = thresholds.get(source, (0, 1000))
    if high <= low:
        return 0.5

    normalized = (value - low) / (high - low)
    return max(0.0, min(1.0, normalized))


# ---------------------------------------------------------------------------
# Polymarket-specific scoring (5-factor composite)
# ---------------------------------------------------------------------------

def score_polymarket_item(item: dict, query: str) -> float:
    """Score a Polymarket result using 5-factor weighted composite.

    Weights (from last30days methodology):
    - Text relevance:          30%
    - 24h volume:              30%
    - Liquidity:               15%
    - Price velocity (proxy):  15%
    - Outcome competitiveness: 10%
    """
    text_rel = item.get("text_relevance", 0.0)
    volume = min(item.get("total_volume", 0) / 1_000_000, 1.0)
    liquidity = min(item.get("total_liquidity", 0) / 500_000, 1.0)
    competitiveness = item.get("competitiveness", 0.5)

    # Price velocity proxy: how far from 50/50 the leading outcome is
    # Markets moving fast = interesting
    outcomes = item.get("outcomes", [])
    if outcomes:
        max_prob = max(o.get("probability", 0.5) for o in outcomes)
        min_prob = min(o.get("probability", 0.5) for o in outcomes)
        velocity_proxy = abs(max_prob - min_prob)  # Higher spread = more movement
    else:
        velocity_proxy = 0.0

    return (
        0.30 * text_rel
        + 0.30 * volume
        + 0.15 * liquidity
        + 0.15 * velocity_proxy
        + 0.10 * competitiveness
    )


# ---------------------------------------------------------------------------
# Cross-platform convergence
# ---------------------------------------------------------------------------

def detect_convergence(items: list[dict], threshold: float = 0.3) -> list[dict]:
    """Find topics that appear across multiple source platforms.

    Uses text_similarity to detect semantically similar items from different
    sources. Returns convergence clusters with boost factors.
    """
    # Group items by source
    by_source: dict[str, list[dict]] = {}
    for item in items:
        src = item.get("source", "unknown")
        by_source.setdefault(src, []).append(item)

    sources = list(by_source.keys())
    if len(sources) < 2:
        return []  # Need 2+ sources for convergence

    convergence_clusters: list[dict] = []
    seen_pairs: set[tuple[int, int]] = set()

    for i, item_a in enumerate(items):
        text_a = _get_item_text(item_a)
        if not text_a:
            continue

        cluster_items = [item_a]
        cluster_sources = {item_a.get("source", "unknown")}

        for j, item_b in enumerate(items):
            if i == j or (i, j) in seen_pairs or (j, i) in seen_pairs:
                continue
            if item_b.get("source") == item_a.get("source"):
                continue  # Only cross-source

            text_b = _get_item_text(item_b)
            if not text_b:
                continue

            sim = text_similarity(text_a, text_b)
            if sim >= threshold:
                cluster_items.append(item_b)
                cluster_sources.add(item_b.get("source", "unknown"))
                seen_pairs.add((i, j))

        if len(cluster_sources) >= 2:
            convergence_clusters.append({
                "topic": text_a[:100],
                "sources": sorted(cluster_sources),
                "num_sources": len(cluster_sources),
                "items": cluster_items,
                "convergence_boost": 1.0 + 0.3 * (len(cluster_sources) - 1),
            })

    # Deduplicate clusters (keep the one with most sources)
    convergence_clusters.sort(key=lambda c: c["num_sources"], reverse=True)
    return convergence_clusters[:10]


def _get_item_text(item: dict) -> str:
    """Extract the primary text content from any source item."""
    source = item.get("source", "")
    if source == "reddit":
        return f"{item.get('title', '')} {item.get('selftext', '')}"
    elif source == "hackernews":
        return f"{item.get('title', '')} {item.get('story_text', '')}"
    elif source == "polymarket":
        return f"{item.get('title', '')} {item.get('description', '')}"
    elif source == "twitter":
        return item.get("text", "")
    elif source == "youtube":
        title = item.get("title", "")
        quotes = " ".join(q.get("text", "") for q in item.get("key_quotes", []))
        return f"{title} {quotes}"
    elif source == "blog":
        return f"{item.get('title', '')} {item.get('summary', '')}"
    return item.get("title", "") or item.get("text", "")


# ---------------------------------------------------------------------------
# Deduplication
# ---------------------------------------------------------------------------

def deduplicate(items: list[dict], threshold: float = 0.6) -> list[dict]:
    """Remove near-duplicate items using trigram-token Jaccard similarity.

    Items with similarity >= threshold are considered duplicates.
    Keeps the item with the highest engagement score.
    """
    if not items:
        return []

    # Sort by engagement (descending) so we keep the best version
    scored = sorted(items, key=_item_engagement, reverse=True)

    kept: list[dict] = []
    kept_texts: list[str] = []

    for item in scored:
        text = _get_item_text(item)
        if not text:
            kept.append(item)
            continue

        is_dup = False
        for existing_text in kept_texts:
            if text_similarity(text, existing_text) >= threshold:
                is_dup = True
                break

        if not is_dup:
            kept.append(item)
            kept_texts.append(text)

    return kept


def _item_engagement(item: dict) -> float:
    """Extract a comparable engagement score from any source item."""
    source = item.get("source", "")
    if source == "reddit":
        return float(item.get("score", 0))
    elif source == "hackernews":
        return float(item.get("points", 0))
    elif source == "polymarket":
        return float(item.get("total_volume", 0))
    elif source == "twitter":
        return float(item.get("likes", 0))
    return 0.0


# ---------------------------------------------------------------------------
# Composite scorer: score_and_rank
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class ScoredItem:
    """A scored item with breakdown of score components."""
    item: dict
    total_score: float
    text_relevance: float
    engagement_score: float
    source_weight: float
    temporal_score: float
    convergence_boost: float


def score_and_rank(
    items: list[dict],
    query: str,
    half_life_hours: float = 48.0,
    deduplicate_threshold: float = 0.6,
) -> dict[str, Any]:
    """Score, deduplicate, and rank items from all sources.

    Scoring formula per item:
      total = (text_relevance * 0.30
             + engagement * 0.25
             + source_weight * 0.15
             + temporal * 0.20
             + convergence_boost * 0.10)

    Returns dict with ranked_items, convergence_clusters, stats.
    """
    if not items:
        return {
            "ranked_items": [],
            "convergence_clusters": [],
            "stats": {"total_input": 0, "after_dedup": 0, "sources": {}},
        }

    # Step 1: Deduplicate
    deduped = deduplicate(items, threshold=deduplicate_threshold)

    # Step 2: Detect cross-platform convergence
    convergence = detect_convergence(deduped)

    # Build convergence lookup: item index -> boost factor
    convergence_boosts: dict[int, float] = {}
    for cluster in convergence:
        for cluster_item in cluster.get("items", []):
            # Use id() for fast lookup
            for idx, item in enumerate(deduped):
                if item is cluster_item:
                    convergence_boosts[idx] = cluster.get("convergence_boost", 1.0)

    # Step 3: Score each item
    scored: list[dict] = []
    for idx, item in enumerate(deduped):
        source = item.get("source", "unknown")
        text = _get_item_text(item)

        # Polymarket gets special scoring
        if source == "polymarket":
            poly_score = score_polymarket_item(item, query)
            text_rel = item.get("text_relevance", poly_score)
        else:
            text_rel = text_similarity(text, query) if text else 0.0

        # Engagement
        raw_engagement = _item_engagement(item)
        engagement = _normalize_engagement(raw_engagement, source)

        # Source weight
        src_weight = SOURCE_WEIGHTS.get(source, 0.5)
        # Normalize to 0-1 range (max weight is 1.4)
        src_weight_norm = src_weight / 1.4

        # Temporal decay
        created = (
            item.get("created_utc")
            or item.get("created_at")
            or item.get("published")
        )
        temporal = temporal_decay(created, half_life_hours)

        # Convergence boost
        conv_boost = convergence_boosts.get(idx, 1.0)
        conv_score = min((conv_boost - 1.0) / 0.6, 1.0)  # Normalize: 1.0->0, 1.6->1.0

        # Composite score
        total = (
            0.30 * text_rel
            + 0.25 * engagement
            + 0.15 * src_weight_norm
            + 0.20 * temporal
            + 0.10 * conv_score
        )

        scored.append({
            **item,
            "_score": round(total, 4),
            "_breakdown": {
                "text_relevance": round(text_rel, 3),
                "engagement": round(engagement, 3),
                "source_weight": round(src_weight_norm, 3),
                "temporal": round(temporal, 3),
                "convergence": round(conv_score, 3),
            },
        })

    # Step 4: Rank by total score
    scored.sort(key=lambda s: s["_score"], reverse=True)

    # Stats
    source_counts: dict[str, int] = Counter(item.get("source", "unknown") for item in deduped)

    return {
        "ranked_items": scored,
        "convergence_clusters": [
            {
                "topic": c["topic"],
                "sources": c["sources"],
                "num_sources": c["num_sources"],
                "convergence_boost": c["convergence_boost"],
            }
            for c in convergence
        ],
        "stats": {
            "total_input": len(items),
            "after_dedup": len(deduped),
            "duplicates_removed": len(items) - len(deduped),
            "sources": dict(source_counts),
            "query": query,
        },
    }
