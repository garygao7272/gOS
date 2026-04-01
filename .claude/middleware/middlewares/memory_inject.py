"""Memory Injection Middleware — injects top-N structured facts into context.

Reads facts.json, filters by relevance to active verb and topic,
sorts by confidence * recency, and injects the top 15 as context.

Blocking: NO — informational, enriches context.
"""

from __future__ import annotations

import math
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from runner import Middleware, MiddlewareContext

# Category relevance per verb
VERB_CATEGORY_WEIGHTS = {
    "think": {"knowledge": 1.0, "context": 0.8, "goal": 0.9, "preference": 0.5, "behavior": 0.3},
    "design": {"preference": 1.0, "knowledge": 0.7, "context": 0.8, "behavior": 0.5, "goal": 0.6},
    "build": {"knowledge": 1.0, "behavior": 0.8, "context": 0.7, "preference": 0.4, "goal": 0.5},
    "review": {"behavior": 1.0, "knowledge": 0.8, "preference": 0.6, "context": 0.5, "goal": 0.4},
    "simulate": {"knowledge": 1.0, "context": 0.9, "goal": 0.8, "preference": 0.3, "behavior": 0.3},
    "ship": {"context": 1.0, "knowledge": 0.7, "goal": 0.6, "behavior": 0.5, "preference": 0.3},
    "evolve": {"behavior": 1.0, "preference": 0.9, "knowledge": 0.7, "context": 0.5, "goal": 0.6},
    "refine": {"knowledge": 1.0, "context": 0.9, "goal": 0.8, "preference": 0.5, "behavior": 0.4},
}

MAX_FACTS = 15
CONFIDENCE_FLOOR = 0.2  # Don't inject facts below this confidence


def _recency_score(created_at: str) -> float:
    """Exponential decay: half-life of 14 days."""
    try:
        created = datetime.fromisoformat(created_at.replace("Z", "+00:00"))
        now = datetime.now(timezone.utc)
        days_old = (now - created).total_seconds() / 86400
        return math.exp(-0.693 * days_old / 14)  # ln(2)/half_life * days
    except Exception:
        return 0.5  # Unknown age gets moderate score


def _relevance_score(fact: dict, verb: str, topic: str) -> float:
    """Compute relevance score for a fact given the active verb and topic."""
    category = fact.get("category", "knowledge")
    confidence = fact.get("confidence", 0.5)
    recency = _recency_score(fact.get("created_at", ""))

    # Category weight for this verb
    weights = VERB_CATEGORY_WEIGHTS.get(verb, {})
    cat_weight = weights.get(category, 0.5)

    # Topic overlap (simple keyword check)
    topic_bonus = 0.0
    if topic:
        content_lower = fact.get("content", "").lower()
        topic_words = set(topic.lower().split())
        matching = sum(1 for w in topic_words if w in content_lower)
        topic_bonus = 0.3 * (matching / max(len(topic_words), 1))

    return confidence * cat_weight * recency + topic_bonus


class MemoryInjectMiddleware(Middleware):
    name = "memory_inject"

    def should_run(self, ctx: MiddlewareContext) -> bool:
        return ctx.phase == "pre" and len(ctx.facts) > 0

    def run(self, ctx: MiddlewareContext) -> None:
        # Extract topic from state
        cmd = ctx.state.get("current_command", "")
        topic_words = cmd.split(">", 1)[1].strip().split()[1:] if ">" in cmd else []
        topic = " ".join(topic_words)

        # Filter and score facts
        scored: list[tuple[float, dict]] = []
        for fact in ctx.facts:
            if fact.get("confidence", 0) < CONFIDENCE_FLOOR:
                continue
            score = _relevance_score(fact, ctx.verb, topic)
            scored.append((score, fact))

        # Sort by score descending, take top N
        scored.sort(key=lambda x: x[0], reverse=True)
        top_facts = [f for _, f in scored[:MAX_FACTS]]

        ctx.meta["injected_facts"] = top_facts
        ctx.meta["total_facts_available"] = len(ctx.facts)

        if top_facts:
            ctx.messages.append(
                f"[memory] Injecting {len(top_facts)} facts "
                f"(of {len(ctx.facts)} total, filtered by {ctx.verb} relevance)"
            )
