"""Context Budget Middleware — tracks and enforces token budget.

Estimates current context usage and warns at thresholds.
At 80%+, flags for auto-summarization. At 90%+, recommends fresh session.

Blocking: NO — advisory only, triggers summarization downstream.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from runner import Middleware, MiddlewareContext

# Context window sizes by model
MODEL_CONTEXT = {
    "opus": 1_000_000,
    "sonnet": 680_000,
    "haiku": 200_000,
}

# Thresholds
WARN_PCT = 0.50
ALERT_PCT = 0.70
CRITICAL_PCT = 0.85
SUMMARIZE_PCT = 0.80

# Token estimation file (written by context-monitor.sh)
TOKEN_ESTIMATE_PATH = Path(os.environ.get(
    "TOKEN_ESTIMATE_FILE",
    "/tmp/gos-context-estimate.json"
))


class ContextBudgetMiddleware(Middleware):
    name = "context_budget"

    def should_run(self, ctx: MiddlewareContext) -> bool:
        return ctx.phase == "pre"

    def run(self, ctx: MiddlewareContext) -> None:
        # Try to read token estimate from context-monitor.sh
        estimated_tokens = 0
        try:
            import json
            if TOKEN_ESTIMATE_PATH.exists():
                data = json.loads(TOKEN_ESTIMATE_PATH.read_text())
                estimated_tokens = data.get("estimated_tokens", 0)
        except Exception:
            pass

        # Default to opus context window
        max_tokens = MODEL_CONTEXT.get("opus", 1_000_000)
        usage_pct = estimated_tokens / max_tokens if max_tokens > 0 else 0

        ctx.meta["context_usage_pct"] = usage_pct
        ctx.meta["context_estimated_tokens"] = estimated_tokens
        ctx.meta["context_needs_summarization"] = usage_pct >= SUMMARIZE_PCT

        if usage_pct >= CRITICAL_PCT:
            ctx.messages.append(
                f"[context] CRITICAL: {usage_pct:.0%} context used (~{estimated_tokens:,} tokens). "
                f"Auto-save recommended. Consider fresh session."
            )
        elif usage_pct >= ALERT_PCT:
            ctx.messages.append(
                f"[context] ALERT: {usage_pct:.0%} context used (~{estimated_tokens:,} tokens). "
                f"Summarization will trigger on next post-phase."
            )
        elif usage_pct >= WARN_PCT:
            ctx.messages.append(
                f"[context] {usage_pct:.0%} context used. Monitoring."
            )
