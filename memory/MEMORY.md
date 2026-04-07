# Memory Index

## Layer Architecture

```
L0: Identity (≤100 tok)  — ALWAYS loaded. Read at session start.
L1: Essential (≤800 tok) — ALWAYS loaded. Active state + rules. Updated every save.
L2: On-Demand (search)   — Loaded when relevant via Palace Protocol.
L3: Deep Search           — claude-mem (349MB) + spec-rag. Semantic query.
```

**Loading order:** L0 → L1 → (task-relevant L2 files) → L3 only if L2 insufficient.

---

## L0 — Identity (always loaded)

- [L0_identity.md](L0_identity.md) — Gary + Arx in 100 tokens. Load first, always.

## L1 — Essential Story (always loaded)

- [L1_essential.md](L1_essential.md) — Active focus, feedback rules, recent decisions, known gaps. Updated every /gos save.

## L2 — On-Demand

### User Profile
- [user_gary_soul.md](user_gary_soul.md) — Full profile: identity, objectives, skills, traits, strengths, weaknesses, working preferences

### Feedback (obey these when relevant)
- [feedback_design_taste.md](feedback_design_taste.md) — Reference apps are FLOOR; taste in specs/; 3 mandatory design gates
- [feedback_stitch_mcp.md](feedback_stitch_mcp.md) — Custom proxy fixes for stitch-mcp
- [feedback_large_structural_writes.md](feedback_large_structural_writes.md) — >500 lines: dispatch as fresh agent
- [feedback_financial_modeling_v2.md](feedback_financial_modeling_v2.md) — 10 rules from financial model sessions
- [feedback_feel_as_tokens.md](feedback_feel_as_tokens.md) — Feel = shared tokens, reference by screen type
- [feedback_design_pipeline.md](feedback_design_pipeline.md) — Code-first pipeline beats Figma-first

### Projects
- [project_dux.md](project_dux.md) — Dux simulation engine: architecture, status, tech stack
- [project_gos_rename.md](project_gos_rename.md) — gOS rename: 38 → 8 verbs (2026-03-21)

### Evolve
- [evolve_audit_2026-04-07.md](evolve_audit_2026-04-07.md) — Latest audit: all commands ≥80%, but /design has zero coverage

### References
- [~/.claude/config/intake-sources.md] — Global gOS watchlist: YouTube, X, blogs, podcasts

## L3 — Deep Search

- **claude-mem:** `search()`, `timeline()`, `get_observations()` — 349MB cross-session history
- **spec-rag:** `search_specs()`, `get_spec()` — semantic search over 60+ spec files
