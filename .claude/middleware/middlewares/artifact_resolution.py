"""Artifact Resolution Middleware — resolves upstream artifacts by topic.

Scans outputs/ for files with YAML frontmatter matching the current topic.
Filters by artifact_type relevance to the active verb. Loads newest first.

Blocking: NO — informational, populates ctx.meta with found artifacts.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from runner import Middleware, MiddlewareContext, PROJECT_ROOT

# Which artifact types are relevant to which verbs
VERB_ARTIFACT_RELEVANCE = {
    "think": None,  # any
    "design": {"research-brief", "decision"},
    "build": {"research-brief", "design-spec", "decision", "build-plan"},
    "review": {"code-scaffold", "build-plan", "design-spec"},
    "simulate": {"research-brief", "financial-model", "decision"},
    "ship": {"verdict"},
    "evolve": {"verdict", "decision"},
    "refine": None,  # any
}


def _extract_frontmatter(path: Path) -> dict | None:
    """Extract YAML frontmatter from a markdown file."""
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return None

    match = re.match(r"^---\s*\n(.*?)\n---", text, re.DOTALL)
    if not match:
        return None

    fm = {}
    for line in match.group(1).split("\n"):
        if ":" in line:
            key, _, value = line.partition(":")
            fm[key.strip()] = value.strip()
    return fm


def _fuzzy_topic_match(topic_a: str, topic_b: str) -> bool:
    """Check if two topic strings are roughly the same."""
    if not topic_a or not topic_b:
        return False
    # Normalize: lowercase, replace hyphens/underscores with spaces
    norm = lambda s: re.sub(r"[-_]", " ", s.lower().strip())
    a, b = norm(topic_a), norm(topic_b)
    # Check if one contains the other, or significant word overlap
    words_a = set(a.split())
    words_b = set(b.split())
    overlap = words_a & words_b
    if not words_a or not words_b:
        return False
    return len(overlap) / min(len(words_a), len(words_b)) >= 0.5


class ArtifactResolutionMiddleware(Middleware):
    name = "artifact_resolution"

    def should_run(self, ctx: MiddlewareContext) -> bool:
        return ctx.phase == "pre"

    def run(self, ctx: MiddlewareContext) -> None:
        outputs_dir = PROJECT_ROOT / "outputs"
        if not outputs_dir.exists():
            return

        # Extract topic from state
        cmd = ctx.state.get("current_command", "")
        topic_words = cmd.split(">", 1)[1].strip().split()[1:] if ">" in cmd else []
        topic = " ".join(topic_words) if topic_words else ""

        if not topic:
            return

        # Scan for artifacts
        relevant_types = VERB_ARTIFACT_RELEVANCE.get(ctx.verb)
        found: list[dict] = []

        for md_file in outputs_dir.rglob("*.md"):
            fm = _extract_frontmatter(md_file)
            if not fm:
                continue

            artifact_type = fm.get("artifact_type", "")
            artifact_topic = fm.get("topic", "")

            # Filter by type relevance
            if relevant_types and artifact_type not in relevant_types:
                continue

            # Filter by topic match
            if not _fuzzy_topic_match(topic, artifact_topic):
                continue

            found.append({
                "path": str(md_file.relative_to(PROJECT_ROOT)),
                "type": artifact_type,
                "topic": artifact_topic,
                "created_by": fm.get("created_by", ""),
                "status": fm.get("status", ""),
                "created_at": fm.get("created_at", ""),
            })

        # Sort by created_at descending
        found.sort(key=lambda x: x.get("created_at", ""), reverse=True)

        ctx.meta["upstream_artifacts"] = found[:10]  # Cap at 10

        if found:
            ctx.messages.append(
                f"[artifacts] {len(found)} upstream artifact(s) found for '{topic}'"
            )
