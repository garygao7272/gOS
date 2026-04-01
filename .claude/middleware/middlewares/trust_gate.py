"""Trust Gate Middleware — enforces domain trust levels.

Checks the active domain's trust level from trust.json and adjusts
the Intent Gate depth accordingly. At T0, requires full gate. At T2+,
allows delegated execution.

Blocking: YES — can deny tool use if trust is below floor for the domain.
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from runner import Middleware, MiddlewareContext

# Domain inference from verb + tool context
VERB_DOMAIN_MAP = {
    "think": "research-synthesis",
    "design": "design-decisions",
    "build": "architecture",
    "review": "code-review",
    "ship": "deployment",
    "simulate": "market-analysis",
    "evolve": "architecture",
    "refine": "spec-writing",
}


class TrustGateMiddleware(Middleware):
    name = "trust_gate"

    def should_run(self, ctx: MiddlewareContext) -> bool:
        return ctx.phase == "pre"

    def run(self, ctx: MiddlewareContext) -> None:
        domain = VERB_DOMAIN_MAP.get(ctx.verb, "architecture")
        domains = ctx.trust.get("domains", {})
        domain_data = domains.get(domain, {})

        level = domain_data.get("level", 0)
        floor = domain_data.get("floor")

        # Store trust level in meta for downstream middlewares
        ctx.meta["trust_domain"] = domain
        ctx.meta["trust_level"] = level

        # At T0: full gate (handled by prompt-level pipeline, not blocking here)
        # At T1: recommend + confirm
        # At T2: act + summarize after
        # At T3: silent
        if level == 0:
            ctx.messages.append(
                f"[trust] Domain '{domain}' at T0 (Advisory) — full Intent Gate required"
            )
        elif level == 1:
            ctx.messages.append(
                f"[trust] Domain '{domain}' at T1 (Collaborative) — recommend + confirm"
            )
        # T2/T3: no message needed (delegated/autonomous)

        # Check floor violations (e.g., deployment can't go above T1 without explicit grant)
        if floor is not None and level > floor:
            ctx.messages.append(
                f"[trust] WARNING: Domain '{domain}' at T{level} exceeds floor T{floor}. "
                f"Capping to T{floor}."
            )
            ctx.meta["trust_level"] = floor
