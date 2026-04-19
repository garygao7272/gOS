# Memory Index

## Layer Architecture

```
L0: Identity (≤100 tok)  — ALWAYS loaded. Read at session start.
L1: Essential (≤800 tok) — ALWAYS loaded. Active state + rules. Updated every save.
L2: On-Demand (search)   — Loaded when relevant via Palace Protocol.
L3: Deep Search           — claude-mem (349MB) + spec-rag. Semantic query.
```

**Loading order:** L0 → L1 → (task-relevant L2 files) → L3 only if L2 insufficient.

**Temporal validity:** Every memory file has `valid_from` and `valid_to` in frontmatter. `valid_to: open` means still current. A specific date means the fact may be stale — verify before acting on it. When loading, check `valid_to` first.

---

## L0 — Identity + Reasoning Kernel (always loaded)

- [L0_identity.md](L0_identity.md) — Gary + Arx in 100 tokens. WHO. Load first, always.
- [L0_reasoning_kernel.md](L0_reasoning_kernel.md) — 8 reasoning invariants (K1–K8, from First Principles OS). HOW. Load alongside identity.

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
- [feedback_verify_subagent_research.md](feedback_verify_subagent_research.md) — Spot-check subagent research against primary sources before presenting
- [feedback_workflow_docs.md](feedback_workflow_docs.md) — Pipeline over process, decompose don't duplicate, templates separate, verb-centric
- [feedback_self_inflicted_regression.md](feedback_self_inflicted_regression.md) — Smoke-test evolve changes before commit; MCP servers need disabled:true without tokens; UserPromptSubmit hooks must be lightweight
- [feedback_orientation_after_gaps.md](feedback_orientation_after_gaps.md) — When Gary signals confusion, give ONE recommendation — not an open menu of options
- [feedback_scout_verify_premise.md](feedback_scout_verify_premise.md) — Scout-type agents must verify premise with direct file read/command run before recommending (decisive: 3/4 false positives on 2026-04-15)
- [feedback_signal_log_hygiene.md](feedback_signal_log_hygiene.md) — session-end auto-entries go to sessions/activity.log, not evolve_signals.md (2026-04-19)
- [feedback_stop_hook_compliance.md](feedback_stop_hook_compliance.md) — Stop hook default-skips; full persist only on /gos save or >4h stale (SUPERSEDES 2026-04-15 "never skip" version)

### Projects

- [project_dux.md](project_dux.md) — Dux simulation engine: architecture, status, tech stack
- [project_gos_rename.md](project_gos_rename.md) — gOS rename: 38 → 8 verbs (2026-03-21)

### Evolve

- [evolve_audit_2026-04-19.md](evolve_audit_2026-04-19.md) — Latest audit: 27 real signals (67% noise ratio from session-end auto-entries), 87 commits shipped, 4 decisive signals acted on inline (scout verify-premise, signal log hygiene, Stop hook override, phase-gate scratchpad drift fired live during audit)
- [evolve_audit_2026-04-08.md](evolve_audit_2026-04-08.md) — Prior audit: 0 new signals, all commands ≥80%, Phase 1 auto-signal hooks landed
- [evolve_audit_2026-04-07.md](evolve_audit_2026-04-07.md) — 12 signals from 2026-04-06, /design still zero coverage

### References

- [~/.claude/config/intake-sources.md] — Global gOS watchlist: YouTube, X, blogs, podcasts

## Episodic Memory (M3)

- [episodes.md](episodes.md) — Episode index linking related sessions (gos-agent-audit, financial-modeling, web-prototype, design-system, signal-transformation)

When starting a task, search memory for the episode to load prior decisions and dead ends.

## Procedural Memory (M4)

Procedures capture HOW to do things (not just WHAT was decided). Created by the Stop hook when a workflow is validated.

Format: `procedure_{task-type}.md` with `type: procedure` in frontmatter.

### Known Procedures

- [procedure_financial_modeling.md](procedure_financial_modeling.md) — OfficeCLI + LibreOffice workflow for .xlsx edits
- [procedure_spec_editing.md](procedure_spec_editing.md) — Cascade rules, archive-first, journey structure for specs/

## Garbage Collection (M8)

Weekly: scan memory/ for stale, duplicate, or contradicted entries.

- Files with `valid_to` date in the past → flag for review
- Files contradicting current codebase → update or remove
- Duplicate content across files → merge

Run via `/evolve audit` or scheduled task.

## Cross-Session Scope (L6)

**Cross-session scope:** When the Stop hook creates a memory, tag it as `scope: arx` (project-specific) or `scope: global` (applies to all Gary's projects). Global learnings go to user or feedback memories.

---

## L3 — Deep Search

- **claude-mem:** `search()`, `timeline()`, `get_observations()` — 349MB cross-session history
- **spec-rag:** `search_specs()`, `get_spec()` — semantic search over 60+ spec files
