"""Scratchpad Sync Middleware — persists critical state after each phase.

Updates scratchpad.md with middleware chain results: trust level, artifacts
found, facts injected, context usage. Ensures state survives compaction.

Blocking: NO — runs post-phase.
"""

from __future__ import annotations

import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from runner import Middleware, MiddlewareContext, PROJECT_ROOT


class ScratchpadSyncMiddleware(Middleware):
    name = "scratchpad_sync"

    def should_run(self, ctx: MiddlewareContext) -> bool:
        return ctx.phase == "post"

    def run(self, ctx: MiddlewareContext) -> None:
        scratchpad = PROJECT_ROOT / "sessions" / "scratchpad.md"
        if not scratchpad.exists():
            return

        try:
            text = scratchpad.read_text(encoding="utf-8")
        except Exception:
            return

        # Build middleware state block
        now = datetime.now(timezone.utc).strftime("%H:%M")
        state_lines = [f"\n## Middleware State ({now})"]

        # Trust
        trust_level = ctx.meta.get("trust_level")
        trust_domain = ctx.meta.get("trust_domain")
        if trust_level is not None:
            state_lines.append(f"- Trust: T{trust_level} ({trust_domain})")

        # Artifacts
        artifacts = ctx.meta.get("upstream_artifacts", [])
        if artifacts:
            state_lines.append(f"- Upstream artifacts: {len(artifacts)}")
            for a in artifacts[:3]:
                state_lines.append(f"  - {a['type']}: `{a['path']}`")

        # Facts
        injected = ctx.meta.get("injected_facts", [])
        total_facts = ctx.meta.get("total_facts_available", 0)
        if injected:
            state_lines.append(f"- Facts injected: {len(injected)}/{total_facts}")

        # Context
        usage = ctx.meta.get("context_usage_pct")
        if usage is not None:
            state_lines.append(f"- Context usage: {usage:.0%}")

        # Only write if we have meaningful state to record
        if len(state_lines) <= 1:
            return

        state_block = "\n".join(state_lines) + "\n"

        # Replace existing middleware state block or append
        import re
        pattern = r"\n## Middleware State \(\d{2}:\d{2}\)\n.*?(?=\n## |\Z)"
        if re.search(pattern, text, re.DOTALL):
            text = re.sub(pattern, state_block, text, count=1, flags=re.DOTALL)
        else:
            text += state_block

        try:
            scratchpad.write_text(text, encoding="utf-8")
        except Exception:
            pass
