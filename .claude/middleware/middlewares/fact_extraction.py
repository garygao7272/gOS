"""Fact Extraction Middleware — extracts structured facts from session output.

After a verb completes, scans the scratchpad's "Key Decisions" and
"Important Values" sections for fact-worthy content. Creates structured
facts with category, confidence, and source attribution.

Also applies confidence decay to existing facts not reinforced this session.

Blocking: NO — runs post-phase, updates facts.json.
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from runner import Middleware, MiddlewareContext, PROJECT_ROOT, FACTS_PATH

# Confidence decay per session for unreinforced facts
DECAY_PER_SESSION = 0.05
MIN_CONFIDENCE = 0.1  # Below this, facts get pruned


def _generate_id(content: str) -> str:
    """Generate a stable fact ID from content."""
    return hashlib.sha256(content.encode()).hexdigest()[:12]


def _is_duplicate(existing: list[dict], content: str, threshold: float = 0.7) -> str | None:
    """Check if content is a near-duplicate of an existing fact.

    Returns the ID of the duplicate if found, None otherwise.
    Simple word overlap check (not perfect, but fast).
    """
    content_words = set(re.findall(r"\b\w{3,}\b", content.lower()))
    if not content_words:
        return None

    for fact in existing:
        fact_words = set(re.findall(r"\b\w{3,}\b", fact.get("content", "").lower()))
        if not fact_words:
            continue
        overlap = len(content_words & fact_words) / max(len(content_words | fact_words), 1)
        if overlap >= threshold:
            return fact.get("id", "")

    return None


def _extract_from_scratchpad(scratchpad_path: Path) -> list[dict]:
    """Extract potential facts from scratchpad sections."""
    if not scratchpad_path.exists():
        return []

    try:
        text = scratchpad_path.read_text(encoding="utf-8")
    except Exception:
        return []

    extracted: list[dict] = []

    # Extract from "Key Decisions Made This Session"
    decisions_match = re.search(
        r"## Key Decisions.*?\n(.*?)(?=\n## |\Z)", text, re.DOTALL
    )
    if decisions_match:
        for line in decisions_match.group(1).strip().split("\n"):
            line = line.strip().lstrip("- ")
            if len(line) > 20:  # Skip trivially short lines
                extracted.append({
                    "content": line,
                    "category": "knowledge",
                    "source": "scratchpad/decisions",
                })

    # Extract from "Important Values"
    values_match = re.search(
        r"## Important Values.*?\n(.*?)(?=\n## |\Z)", text, re.DOTALL
    )
    if values_match:
        for line in values_match.group(1).strip().split("\n"):
            line = line.strip().lstrip("- ")
            if len(line) > 10:
                extracted.append({
                    "content": line,
                    "category": "context",
                    "source": "scratchpad/values",
                })

    return extracted


def _save_facts(facts: list[dict]) -> None:
    """Persist facts to facts.json."""
    FACTS_PATH.parent.mkdir(parents=True, exist_ok=True)
    data = {
        "version": "1.0",
        "last_updated": datetime.now(timezone.utc).isoformat(),
        "facts": facts,
    }
    FACTS_PATH.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")


class FactExtractionMiddleware(Middleware):
    name = "fact_extraction"

    def should_run(self, ctx: MiddlewareContext) -> bool:
        return ctx.phase == "post"

    def run(self, ctx: MiddlewareContext) -> None:
        existing_facts = list(ctx.facts)  # Copy
        now_iso = datetime.now(timezone.utc).isoformat()

        # 1. Extract new facts from scratchpad
        scratchpad = PROJECT_ROOT / "sessions" / "scratchpad.md"
        candidates = _extract_from_scratchpad(scratchpad)

        new_count = 0
        reinforced_count = 0

        for candidate in candidates:
            content = candidate["content"]

            # Check for duplicate
            dup_id = _is_duplicate(existing_facts, content)
            if dup_id:
                # Reinforce existing fact (bump confidence, update timestamp)
                for fact in existing_facts:
                    if fact.get("id") == dup_id:
                        fact["confidence"] = min(1.0, fact.get("confidence", 0.5) + 0.1)
                        fact["last_reinforced"] = now_iso
                        reinforced_count += 1
                        break
                continue

            # Create new fact
            new_fact = {
                "id": _generate_id(content),
                "content": content,
                "category": candidate.get("category", "knowledge"),
                "confidence": 0.6,  # New facts start at moderate confidence
                "created_at": now_iso,
                "last_reinforced": now_iso,
                "source": candidate.get("source", f"{ctx.verb}/session"),
                "verb": ctx.verb,
            }
            existing_facts.append(new_fact)
            new_count += 1

        # 2. Apply confidence decay to unreinforced facts
        decayed = 0
        pruned = 0
        session_facts = {f.get("id") for f in existing_facts if f.get("last_reinforced") == now_iso}

        for fact in existing_facts:
            if fact.get("id") not in session_facts:
                old_conf = fact.get("confidence", 0.5)
                fact["confidence"] = max(MIN_CONFIDENCE, old_conf - DECAY_PER_SESSION)
                if fact["confidence"] <= MIN_CONFIDENCE:
                    decayed += 1

        # Prune facts below minimum confidence
        before_count = len(existing_facts)
        existing_facts = [f for f in existing_facts if f.get("confidence", 0) > MIN_CONFIDENCE]
        pruned = before_count - len(existing_facts)

        # 3. Save
        _save_facts(existing_facts)

        if new_count > 0 or reinforced_count > 0:
            ctx.messages.append(
                f"[memory] Facts: +{new_count} new, {reinforced_count} reinforced, "
                f"{pruned} pruned ({len(existing_facts)} total)"
            )
