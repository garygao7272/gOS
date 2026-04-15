# Synthesis — Absorb External Frameworks (Karpathy + Hermes)

**Date:** 2026-04-15
**Task:** Scan karpathy-skills + NousResearch/hermes-agent, propose absorption into gOS.
**Artifacts:** `artifacts/contrarian.md`, `artifacts/first-principles.md`, `artifacts/spec-rag.md`

---

## PEV Convergence

| Agent | Verdict | Key Finding |
|---|---|---|
| contrarian | CONCERN | Both repos are coherent wholes — partial absorption kills either. Karpathy = 4 line-edits max. Hermes = research reference only. |
| first-principles | ALIGNED | K3 Surgical Changes is the only real Karpathy gap. 7 of 16 Hermes features are anti-absorptions (lean_smart violations). |
| spec-rag | ALIGNED | 3/4 Karpathy principles already in gOS (Plan Gate, INV-G01, INV-G06). Top Hermes candidate: autonomous skill creation — contrarian disagrees. |

**Convergence:** All three agents agree Karpathy K3 (Surgical Changes) is the one real gap. Divergence on Hermes: contrarian rejects all; first-principles ranks 4 tightening candidates (H2/H5/H11/H12); spec-rag surfaces autonomous skill creation (which contrarian flags as dangerous).

## Decision (Gary-approved via /gos conductor)

**Phase 1 — ABSORB (executed):**
1. `INV-G16 Surgical edits only` → `~/.claude/invariants.md`
2. Plan Gate bias check: "Multiple interpretations? Present them, don't pick silently." → `~/.claude/CLAUDE.md`
3. Practitioner Rule 5: "Simplicity tax — if 200 lines could be 50, rewrite. If it feels clever, it's probably wrong." → `~/.claude/CLAUDE.md`

**Phase 2 — DEFER (documented, not executed):**
- Hermes H2 (inline auto-patch on 3+ repeats) — already covered by `/evolve upgrade` direct-to-command learning
- Hermes H5 (PEV depth bound) — add if PEV recursion becomes observable problem
- Hermes H11 (protected turns during compression) — useful but not urgent
- Hermes H12 (self-scan on new skills) — only relevant if we adopt autonomous skill creation
- Autonomous skill creation — REJECTED per contrarian; violates lean_smart invariant

**Phase 3 — REJECT:**
- Honcho dialectic user modeling — Gary is source of truth on Gary
- MemoryProvider ABC — speculative flexibility
- Multi-platform gateway, ACP adapter, 6 terminal backends, RL training — mission mismatch

## Rationale

Contrarian's "kill shot" held: both repos are coherent wholes. We're absorbing the minimum tensile load — the one cultural principle (surgical edits) and the one meta-bias (multi-interpretation) that don't require importing their infrastructure. Everything else Gary can revisit after seeing whether the 3 edits change behavior observably.

CONFIDENCE: high — three agents converged on same minimum; contrarian's "line edits only" floor respected.
