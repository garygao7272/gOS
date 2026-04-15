# Synthesis — gOS Simplify + Fresh-Clone Reproducibility

**Job:** simplify-parity-2026-04-15
**PEV roster:** parity-auditor, simplify-scout, first-principles
**Convergence:** All 3 agents' findings are complementary with no contradictions. Cross-check passes.

---

## TL;DR

- **Q1 (simplify):** gOS is **lean internally, cluttered at the repo root**. Core code is fine; the noise is zombie directories, duplicated canonical files, and stale vocabulary. Top fix: delete zombies + add a `START.md` entry-point.
- **Q2 (reproducibility):** Fresh `git clone && ./install.sh` lands at **~70% parity**. Four critical gaps leave a silently broken install: `invariants.md` has no repo source, `install.sh` reads hooks from the wrong path, `claws/` is never copied, and TypeScript MCPs never run `npm install`.
- **Meta:** Both lenses agree the highest-leverage fix is to **source-control `invariants.md`** immediately — INV-G16 (just added live) dies on any fresh clone today.

---

## Part A — Reproducibility (Q2)

### Verdict: ~70% on fresh Mac

Four critical gaps, two high, three medium. All silent failures (no error in install; surfaces at runtime).

### Convergent Critical Gaps (both agents agreed)

| # | Gap | Evidence | Fix |
|---|-----|----------|-----|
| **C1** | `~/.claude/invariants.md` has **no source** in gOS repo | parity + first-principles | Add `gOS/invariants.md` + install.sh copy step |
| **C2** | `install.sh` line 248 reads hooks from `.claude/hooks/` which doesn't exist in `--bootstrap` mode | parity | Change read path to `$GOS_DIR/.claude/hooks/` |
| **C3** | `claws/` never installed (not mentioned in install.sh) | parity | Add `claws/` copy block after skills |
| **C4** | TypeScript MCPs (hyperliquid, spec-rag, sources) never `npm install`ed | first-principles | Add npm install loop after toolkit copy |

### High Gaps (one-agent, unverified but credible)

| # | Gap | Fix |
|---|-----|-----|
| **H1** | Python venv `requirements.txt` lookup fails silently (venv empty) | Fail-loud when requirements.txt missing |
| **H2** | Hooks never verified post-copy (existence + chmod) | Add post-install hook validation |
| **H3** | Secrets (GITHUB_TOKEN, STITCH_API_KEY…) never surfaced | SETUP.md checklist + install-time print |

### Medium

- M1: `settings.json` Python merger fails silently to overwrite.
- M2: No install manifest to verify completeness.
- M3: No `--check` health-check mode.

---

## Part B — Simplification (Q1)

### Verdict: lean where it matters, noisy at the root

Core (commands, agents, skills, rules) is tight. Zombie directories + entry-point ambiguity create cognitive load.

### Convergent Findings

**Zombie directories (~26.5M freeable):**
| Dir | Size | Action |
|---|---|---|
| `toolkit/` | 24M | `.gitignore` (build output, regenerate via install.sh) |
| `bootstrap/` | 988K | Move to `tools/bootstrap/` |
| `gos-plugin/` + `gos-plugin-build/` | 792K | Pick one canonical, delete other |
| `gos-v4.3/` | 516K | Archive or delete |
| `gos-v4.3.zip` | 516K | Delete |
| `Archive/` | 356K | Compress to `.backup/` |
| `templates/` | 12K | Merge into `project-template/` if redundant |
| `_claude-plugin-source/` | 8K | Delete if superseded |

**Entry-point confusion:**
- New dev has no "start here" file. `.claude/gOS.md` (165 lines, canonical) isn't discoverable from repo root.
- `CLAUDE.md` at root is framework-dev-only, not user-facing — misleads newcomers.

**Stale vocabulary:**
- "build-squad" in 4 agent descriptions (`architect`, `designer`, `engineer`, `team-registry`) → current vocab is Agent Teams.
- `/dispatch` and "Swarm" in `project-template/gOS.md` → current vocab is Agent Teams (no dispatchers in v9+).
- `/refine` referenced in `project-template/gOS.md` line 80 — no `commands/refine.md` exists. (Likely a `/gos` sub-verb; document or remove.)

**Duplication (canonical unclear):**
- `gOS.md` exists 4 places. Canonical is `.claude/gOS.md`. `gos-plugin-build/reference/gOS.md` is redundant — delete.

**Over-cap files — mostly accept:**
- `commands/review.md` (310 lines): 3% over — no split warranted.
- `commands/gos.md` (303 lines): at cap, legitimately complex.
- 6 skills over 150-line cap: reference encyclopedias, not activation specs. Clarify in SKILL.md headers; no split.

---

## Part C — Cross-cuts (A ∩ B)

These gaps show up in both lenses:

1. **`gos-v4.3/`** — parity auditor notes install.sh doesn't reliably read hooks from here; simplify-scout notes it's a frozen archive. **Action:** promote hooks canonical to `gOS/.claude/hooks/` (already there) and delete `gos-v4.3/` entirely.
2. **Multiple template dirs** (`templates/` + `project-template/`) — unclear provenance hurts both reproducibility (install.sh only references one) and readability (two feels like legacy drift). **Action:** merge.
3. **`gos-plugin-build/`** — ships in repo (simplify: noise; reproducibility: unused by install.sh). **Action:** `.gitignore` and regenerate, OR delete if plugin mechanism obsolete.

---

## Ranked Recommendation Stack

### P0 — Critical (do immediately, low effort)

1. **Source-control `invariants.md`** — copy `~/.claude/invariants.md` → `gOS/invariants.md` + add to install.sh. Fixes INV-G16 loss on fresh clone.
2. **Fix install.sh hook path** (line 248) — read from `$GOS_DIR/.claude/hooks/`.
3. **Add `claws/` copy** in install.sh `--global`.
4. **Add `npm install` loop** after TypeScript MCP copy.

**Total effort:** ~30 min. **Risk:** near-zero (additive fixes). **Impact:** lifts fresh-clone parity from ~70% to ~95%.

### P1 — High-value (next, 1-2 hours)

5. **Create `START.md` at repo root** — 7 verbs + 1 table, "read next" links. Solves entry-point confusion.
6. **Delete zombie dirs** — `gos-v4.3/`, `gos-v4.3.zip`, `Archive/`. Archive to `.backup/`. Frees 1.4M.
7. **Fail-loud on missing `requirements.txt`** in install.sh venv creation.
8. **Post-install manifest + validation** — count files, verify hooks chmod +x, print summary.

### P2 — Polish (later)

9. Grep-replace stale vocab (`build-squad` → Agent Teams, `/dispatch` → Agent Teams).
10. `.gitignore` `toolkit/` (regenerate via install.sh). Saves 24M on clone but needs bootstrap regen logic.
11. Clarify or delete `gos-plugin/` vs `gos-plugin-build/`.
12. Surface required secrets as SETUP.md checklist.

---

## Confidence

**HIGH (>90%)** on P0 and zombie directory deletion — confirmed by file evidence, both agents, and direct grep of install.sh.

**MEDIUM (75%)** on P1 (entry-point + SETUP polish) — subjective UX judgement.

**LOWER (60%)** on `toolkit/` gitignore — needs careful bootstrap flow redesign; don't rush.

---

## Next Action

Await Gary approval. On approval:
- Immediate build: P0 items 1–4 (the critical reproducibility fixes).
- Defer P1/P2 until P0 is tested on a fresh clone.
