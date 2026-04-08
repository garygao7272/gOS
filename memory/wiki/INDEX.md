# gOS Knowledge Wiki — INDEX

> Compiled knowledge from raw signals, sessions, and decisions.
> Karpathy wiki architecture: ingest → query → lint.
> Each page has backlinks. Staleness tracked via `valid_until`.

## Patterns (compiled from evolve_signals.md)

- [no-system-jargon](../instincts/no-system-jargon.yaml) — Never show system internals to Gary. Story+Table+Next Move format.
- [audit-existing-tools](../instincts/audit-existing-tools.yaml) — Check what's installed before recommending new tools.
- [context-limit-awareness](../instincts/context-limit-awareness.yaml) — Large writes at high context fail. Dispatch as agent or save checkpoint.

## Decisions

- [12-dimension-scoring](decisions/12-dimension-scoring.md) — Added Craft + Testing at 1.5x weight. Honest score: 6.6.
- [karpathy-wiki-over-rag](decisions/karpathy-wiki-over-rag.md) — Compilation layer on existing claude-mem, not replacement.

## Preferences

- [output-format](preferences/output-format.md) — All session-facing output: Story + Table + Next Move.
- [stop-hook-behavior](preferences/stop-hook-behavior.md) — Bookkeeping silent, wrap-up human-readable.

---

*Last compiled: 2026-04-09. Next lint: 2026-04-16.*
