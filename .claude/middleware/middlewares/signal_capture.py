"""Signal Capture Middleware — captures accept/rework/reject signals.

Post-phase middleware that records the session's signal into trust.json
and evolve_signals.md. Applies progression/demotion rules.

This middleware runs at session end (post-phase of the final verb),
but the actual signal detection happens via the Stop hook prompt.
This middleware handles the trust.json update mechanics.

Blocking: NO — runs post-phase.
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from runner import Middleware, MiddlewareContext, PROJECT_ROOT, TRUST_PATH


# Progression rules
PROMOTE_THRESHOLD = {
    0: 3,   # T0 -> T1: 3 consecutive accepts
    1: 8,   # T1 -> T2: 8 consecutive accepts
    # T2 -> T3: ONLY by explicit Gary grant (never auto)
}


def _update_trust(trust: dict, domain: str, signal: str) -> tuple[dict, str | None]:
    """Update trust.json with a new signal. Returns (updated_trust, level_change_msg)."""
    domains = trust.setdefault("domains", {})
    domain_data = domains.setdefault(domain, {
        "level": 0,
        "history": [],
        "consecutive_accepts": 0,
        "last_reject": None,
        "floor": None,
    })

    now_iso = datetime.now(timezone.utc).isoformat()

    # Record signal
    domain_data["history"].append({
        "signal": signal,
        "timestamp": now_iso,
    })

    # Keep last 20 history entries
    domain_data["history"] = domain_data["history"][-20:]

    level_change = None
    old_level = domain_data["level"]

    if signal in ("accept", "love"):
        domain_data["consecutive_accepts"] = domain_data.get("consecutive_accepts", 0) + 1

        # Check promotion
        threshold = PROMOTE_THRESHOLD.get(old_level)
        if threshold and domain_data["consecutive_accepts"] >= threshold:
            # Check floor
            floor = domain_data.get("floor")
            new_level = old_level + 1
            if floor is not None and new_level > floor:
                level_change = (
                    f"Domain '{domain}' reached {domain_data['consecutive_accepts']} accepts "
                    f"but T{new_level} exceeds floor T{floor}. Staying at T{old_level}."
                )
            else:
                domain_data["level"] = new_level
                domain_data["consecutive_accepts"] = 0
                level_change = (
                    f"Trust update: '{domain}' promoted T{old_level} -> T{new_level} "
                    f"({threshold} consecutive accepts)"
                )

    elif signal == "reject":
        # Immediate demotion
        if old_level > 0:
            domain_data["level"] = old_level - 1
            level_change = (
                f"Trust update: '{domain}' demoted T{old_level} -> T{old_level - 1} (reject)"
            )
        domain_data["consecutive_accepts"] = 0
        domain_data["last_reject"] = now_iso

    elif signal == "rework":
        # Check for 2 reworks in last 5
        recent = domain_data["history"][-5:]
        rework_count = sum(1 for h in recent if h.get("signal") == "rework")
        if rework_count >= 2 and old_level > 0:
            domain_data["level"] = old_level - 1
            level_change = (
                f"Trust update: '{domain}' demoted T{old_level} -> T{old_level - 1} "
                f"(2 reworks in last 5)"
            )
            domain_data["consecutive_accepts"] = 0

    trust["last_updated"] = now_iso
    return trust, level_change


def _save_trust(trust: dict) -> None:
    """Persist trust.json."""
    TRUST_PATH.write_text(
        json.dumps(trust, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )


class SignalCaptureMiddleware(Middleware):
    name = "signal_capture"

    def should_run(self, ctx: MiddlewareContext) -> bool:
        # Only runs when a signal is available in meta (set by Stop hook)
        return ctx.phase == "post" and "signal" in ctx.meta

    def run(self, ctx: MiddlewareContext) -> None:
        signal = ctx.meta.get("signal", "")
        domain = ctx.meta.get("trust_domain", "architecture")

        if not signal:
            return

        # Update trust
        trust = dict(ctx.trust)  # Copy
        trust, level_msg = _update_trust(trust, domain, signal)
        _save_trust(trust)

        if level_msg:
            ctx.messages.append(f"[signal] {level_msg}")

        # Log to evolve_signals.md
        signals_path = PROJECT_ROOT / "sessions" / "evolve_signals.md"
        try:
            now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M")
            entry = f"| {now} | {ctx.verb} | {domain} | {signal} | T{trust['domains'][domain]['level']} |\n"

            if signals_path.exists():
                text = signals_path.read_text(encoding="utf-8")
                text += entry
            else:
                text = "| Timestamp | Verb | Domain | Signal | Trust |\n|---|---|---|---|---|\n" + entry

            signals_path.write_text(text, encoding="utf-8")
        except Exception:
            pass
