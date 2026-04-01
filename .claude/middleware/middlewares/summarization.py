"""Summarization Middleware — compresses completed verb outputs.

When context usage exceeds the summarization threshold (80%), this middleware:
1. Identifies completed verb outputs in the current session
2. Compresses them to 3-line summaries + file pointers
3. Writes the summary to an archival file
4. Updates scratchpad with compression markers

This implements the working-memory vs archival-memory split from DeerFlow.

Blocking: NO — runs post-phase, advisory.
"""

from __future__ import annotations

import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from runner import Middleware, MiddlewareContext, PROJECT_ROOT

SUMMARIZE_THRESHOLD = 0.80  # Trigger at 80% context usage
ARCHIVAL_DIR = PROJECT_ROOT / "sessions" / "archival"


def _estimate_tokens(text: str) -> int:
    """Rough token estimate: ~4 chars per token for English."""
    return len(text) // 4


def _find_session_outputs(scratchpad_path: Path) -> list[Path]:
    """Find output files written during this session from scratchpad tracking."""
    if not scratchpad_path.exists():
        return []

    try:
        text = scratchpad_path.read_text(encoding="utf-8")
    except Exception:
        return []

    # Extract file paths from "Files Actively Editing" section
    files_match = re.search(
        r"## Files Actively Editing.*?\n(.*?)(?=\n## |\Z)", text, re.DOTALL
    )
    if not files_match:
        return []

    outputs: list[Path] = []
    for line in files_match.group(1).strip().split("\n"):
        # Format: - `path/to/file.md` (HH:MM)
        path_match = re.search(r"`([^`]+)`", line)
        if path_match:
            p = PROJECT_ROOT / path_match.group(1)
            if p.exists() and p.suffix == ".md" and "outputs/" in str(p):
                outputs.append(p)

    return outputs


def _compress_output(path: Path) -> dict:
    """Create a 3-line summary + pointer for an output file."""
    try:
        text = path.read_text(encoding="utf-8")
    except Exception:
        return {"path": str(path), "summary": "[unreadable]", "tokens_saved": 0}

    original_tokens = _estimate_tokens(text)

    # Extract title (first # heading)
    title_match = re.search(r"^#\s+(.+)$", text, re.MULTILINE)
    title = title_match.group(1) if title_match else path.stem

    # Extract key findings (look for numbered lists, bold items, ## sections)
    key_points: list[str] = []

    # Try numbered items
    for match in re.finditer(r"^\d+\.\s+\*\*(.+?)\*\*", text, re.MULTILINE):
        key_points.append(match.group(1))
        if len(key_points) >= 3:
            break

    # If not enough, try ## headings
    if len(key_points) < 2:
        for match in re.finditer(r"^##\s+(.+)$", text, re.MULTILINE):
            heading = match.group(1).strip()
            if heading not in ("Summary", "References", "Sources"):
                key_points.append(heading)
                if len(key_points) >= 3:
                    break

    # Build 3-line summary
    summary_lines = [f"**{title}**"]
    for point in key_points[:2]:
        summary_lines.append(f"  - {point}")

    summary = "\n".join(summary_lines)
    summary_tokens = _estimate_tokens(summary)

    return {
        "path": str(path.relative_to(PROJECT_ROOT)),
        "title": title,
        "summary": summary,
        "original_tokens": original_tokens,
        "summary_tokens": summary_tokens,
        "tokens_saved": original_tokens - summary_tokens,
    }


def _write_archival(compressions: list[dict]) -> Path | None:
    """Write compressed summaries to archival directory."""
    if not compressions:
        return None

    ARCHIVAL_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    archival_path = ARCHIVAL_DIR / f"archival-{timestamp}.md"

    lines = [
        "# Archival Summary",
        f"*Compressed at {datetime.now(timezone.utc).isoformat()}*",
        "",
        "These outputs were compressed to save context. Full content at the listed paths.",
        "",
    ]

    for comp in compressions:
        lines.append(f"### {comp['title']}")
        lines.append(f"*Full: `{comp['path']}`* ({comp['original_tokens']:,} tokens)")
        lines.append("")
        lines.append(comp["summary"])
        lines.append("")

    archival_path.write_text("\n".join(lines), encoding="utf-8")
    return archival_path


class SummarizationMiddleware(Middleware):
    name = "summarization"

    def should_run(self, ctx: MiddlewareContext) -> bool:
        if ctx.phase != "post":
            return False
        # Only run if context budget middleware flagged need for summarization
        return ctx.meta.get("context_needs_summarization", False)

    def run(self, ctx: MiddlewareContext) -> None:
        scratchpad = PROJECT_ROOT / "sessions" / "scratchpad.md"
        session_outputs = _find_session_outputs(scratchpad)

        if not session_outputs:
            return

        # Compress each output
        compressions: list[dict] = []
        total_saved = 0

        for output_path in session_outputs:
            comp = _compress_output(output_path)
            if comp["tokens_saved"] > 100:  # Only compress if meaningful savings
                compressions.append(comp)
                total_saved += comp["tokens_saved"]

        if not compressions:
            return

        # Write to archival
        archival_path = _write_archival(compressions)

        # Update scratchpad with compression marker
        if scratchpad.exists():
            try:
                text = scratchpad.read_text(encoding="utf-8")
                marker = (
                    f"\n## Compressed Outputs\n"
                    f"- {len(compressions)} outputs archived ({total_saved:,} tokens saved)\n"
                    f"- Archival: `{archival_path.relative_to(PROJECT_ROOT)}`\n"
                    f"- Re-read full outputs from listed paths if needed\n"
                )
                if "## Compressed Outputs" not in text:
                    text += marker
                    scratchpad.write_text(text, encoding="utf-8")
            except Exception:
                pass

        ctx.messages.append(
            f"[summarize] Compressed {len(compressions)} outputs, "
            f"saved ~{total_saved:,} tokens. "
            f"Archival at {archival_path.relative_to(PROJECT_ROOT) if archival_path else 'N/A'}"
        )
