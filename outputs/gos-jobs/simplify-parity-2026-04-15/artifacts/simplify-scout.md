# Simplification Report

**Agent:** simplify-scout (abd1094e158d6ecdc)
**Question:** Line-count + cognitive-load audit. Zombie directories, over-cap files, duplication, entry-point confusion.

---

## Zombie Directories (safe to delete, >80% confidence)

| Dir | Size | Verdict |
|---|---|---|
| `gos-v4.3/` | 516K | Frozen historical snapshot. Canonical is `commands/`. Archive or delete. |
| `gos-v4.3.zip` | 516K | Archive of same. Delete. |
| `gos-plugin/` + `gos-plugin-build/` | 276K + 516K | Source vs built output unclear. Deprecate one. |
| `Archive/` | 356K | 16 dated superseded files. Compress to `.backup/`. |
| `bootstrap/` | 988K | Operational infra, shouldn't be top-level. Move to `tools/bootstrap/`. |
| `templates/` | 12K | Only 4 files. Merge into `project-template/` if redundant. |
| `toolkit/` | **24M** | Build output, not source. `.gitignore` + regenerate via install.sh. |
| `_claude-plugin-source/` | 8K | Unclear purpose; likely superseded by `gos-plugin/`. Delete. |

**Freeable:** ~26.5M (toolkit alone is 24M).

---

## Over-cap Files (mostly accept as-is)

- `commands/review.md` (310 lines, cap 300): marginal overflow, no split warranted. Mark as exception in file-structure.md.
- `commands/gos.md` (303 lines, at cap): conductor orchestration is legitimately complex.
- Skills over 150-line cap: `python-testing` (816), `python-patterns` (750), `backend-patterns` (598), `coding-standards` (530), `tdd-workflow` (410), `intake` (398). These are reference encyclopedias, not activation specs. **Action:** clarify in SKILL.md headers.

---

## Duplication (canonical unclear)

`gOS.md` appears in 4 places:
- `.claude/gOS.md` (165 lines) — **canonical** (Claude Code loads this)
- `project-template/gOS.md` (120 lines) — template copy, correct
- `gos-v4.3/reference/gOS.md` — frozen snapshot
- `gos-plugin-build/reference/gOS.md` — **plugin bundle copy, redundant; delete**

**Stale terminology:** `build-squad` in 4 agent descriptions (`architect.md`, `designer.md`, `engineer.md`, `team-registry.md`). Current vocabulary is `/build team` + Agent Teams. **Grep-replace `build-squad` → `Agent Teams`.**

---

## Entry-Point Confusion

Fresh dev reads gOS — which file is "start here"?
- `README.md` — setup instructions
- `CLAUDE.md` (61 lines) — framework development docs (missing 7 verbs explainer)
- `.claude/gOS.md` (165 lines) — **de facto canonical** but not discoverable from repo root
- `project-template/gOS.md` — project copy, misleading

**Fixes:**
1. Rename root `CLAUDE.md` → `FRAMEWORK_DEV.md` (clarifies audience).
2. Add **`START.md`** at root with: "What is gOS?" (2 sentences), 7-verbs + 1 table, links to README.md / .claude/gOS.md / FRAMEWORK_DEV.md.
3. Promote or soft-link `.claude/gOS.md` visibility from root.

---

## Stale References

- `agents/architect.md` line 2: "Use for build-squad technical design phase." → update.
- `project-template/gOS.md` line 80: lists `/refine` command. **No `commands/refine.md` exists.** Verify: sub-verb of `/gos`? Document or remove.
- `project-template/gOS.md` lines 87–88: mentions Swarm + `dispatch`. Current vocab is Agent Teams (no dispatchers in v9+). Update template.

---

## Top 5 Simplification Actions

1. **Delete zombie dirs** (gos-v4.3, gos-v4.3.zip, Archive/) → compress to backup — gain HIGH, risk LOW. Frees ~1.4M.
2. **Create START.md** at root with 7-verbs+1 table, entry-point map — gain HIGH, risk LOW. 2-min fix.
3. **Grep-replace stale vocab** (`build-squad` → `Agent Teams`, `/dispatch` → Agent Teams) in 4 agents + 2 templates — gain MED, risk LOW. 30 min.
4. **Move `toolkit/` to .gitignore** or `.setup/` — gain MED, risk MED. Requires bootstrap to regenerate. Saves 24M on clone.
5. **Clarify plugin architecture** — gos-plugin/ vs gos-plugin-build/ — gain LOW, risk LOW. 5 min. Removes 800K duplication.
