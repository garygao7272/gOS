---
name: Design Simplification — Collapse Tiers to Toggles
description: Gary prefers collapsing overlapping relationship/tier models into a single tier + boolean toggle rather than maintaining separate tiers with distinct UX paths
type: feedback
---

When two tiers serve closely related behaviors (e.g., Watch vs Follow both being non-copy relationships), collapse to the simpler one and express the variant behavior as a configurable toggle (`notify_on_trade: bool`, notification settings, etc.) rather than maintaining a separate tier with distinct UI surfaces.

**Why:** Arx Radar v5 had Watch/Follow/Copy. Gary identified via `/aside` that Follow was over-complicating it — notifications are always configurable per-trader, not a separate commitment level. Decision: two tiers (Watch + Copy), with `notify_on_trade: bool` on `watch_relationship`.

**How to apply:** When proposing multi-tier relationship models or UX commitment ladders, ask: "Could this tier's distinguishing behavior be a toggle on the simpler tier instead?" If yes, propose the collapsed version first. Only propose separate tiers when the behavioral distinction is large enough to warrant distinct DB entities AND distinct UX paths.
