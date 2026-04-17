---
owner: gos
last_updated: 2026-04-17
spec_ids: [commands/ship.md, tools/sync-gos.sh, install.sh]
valid_until: evergreen
status: design
---

# `/ship gos` — One-Command Pipeline Design

## IN SCOPE
- Architecture of the single-command propagation from gOS source to all live targets.
- What's synced, what's excluded, in what order, with what failure handling.
- Verification that source and every live target actually match.

## OUT OF SCOPE
- `/ship commit` / `/ship push` / `/ship pr` — general-purpose git ops (see `commands/ship.md`).
- How individual primitives work at runtime (hooks, commands, skills — covered elsewhere).
- Plugin marketplace distribution (GitHub → other users) — this pipeline only handles Gary's local env.

## NEVER
- Commit session artifacts (`sessions/*`, `memory/*`) unless the user explicitly asks.
- Overwrite the plugin cache without first pushing to GitHub — source of truth must be reachable.
- Run destructive git ops (`reset --hard`, `push --force`) inside this pipeline.

---

## ANSWER — the mechanism

gOS lives in three runtime places: (1) the repo on disk, (2) the user install under `~/.claude/`, and (3) the plugin cache at `~/.claude/plugins/cache/gos-marketplace/gos/<version>/`. Autocomplete in Claude Code ≥ 2.1.84 reads **only** from the plugin cache; the user install registers as Skills; the repo is inert until something syncs from it.

**`/ship gos` is a 7-stage pipeline:** detect → validate → stage → commit → push → sync → verify. The sync stage fans out to all three targets from the repo. Push precedes sync so the plugin cache always has a GitHub fallback if the marketplace re-pulls.

## DECOMPOSE — the architecture

### Source of truth (repo layout)

| Path in repo | Role | Synced to |
|---|---|---|
| `commands/*.md` | Slash-command definitions + skill descriptions | user install, plugin cache |
| `agents/*.md` | Sub-agent definitions | user install, plugin cache |
| `skills/*/SKILL.md` | Skill auto-trigger definitions | user install, (plugin cache archive) |
| `rules/**/*.md` | Coding standards, git workflow, etc. | user install, plugin cache |
| `.claude/hooks/*.sh` | Lifecycle hooks (PreToolUse, UserPromptSubmit, Stop…) | user install, plugin cache |
| `output-styles/*.md` | Response-format styles (e.g., `direct-response`) | user install only (no plugin support yet) |
| `tools/gos-statusline.sh` | Shell command that renders the editor status line | user install only |
| `settings/settings.json` | Settings template (merged, not overwritten) | user install only |
| `evals/rubrics/*.md` | Command quality rubrics | repo only (for `/review eval`) |
| `claws/*` | Persistent scheduled agents | user install only |

### Live targets

| Target | Path | Role |
|---|---|---|
| **Repo (git)** | `gOS/` + `https://github.com/garygao7272/gOS.git` | Source of truth + GitHub mirror |
| **User install** | `~/.claude/{commands,agents,hooks,rules,skills,output-styles,statusline.sh}` | Skills catalog + hook runtime + output style + status line |
| **Plugin cache** | `~/.claude/plugins/cache/gos-marketplace/gos/<latest>/` | **Slash-autocomplete** in CC ≥ 2.1.84 |

### Exclusions (stay in the repo, do not sync)

| Path | Reason |
|---|---|
| `sessions/*` | Session-local state (scratchpad, trust.json, state.json) |
| `memory/*` | User-scoped memory, not framework |
| `outputs/*` | Ephemeral workspace (think/build/review jobs) |
| `.claude/scheduled_tasks.lock` | Runtime lock file |
| `apps/*` | Project apps, not framework |
| `specs/*` | Project specs (Arx-specific), not framework |
| `*.bak`, `* 2*` | iCloud conflict duplicates |

---

## SOLUTIONS — the 7-stage pipeline

### Stage 1 — Detect

Input: git status in the gOS repo. Classify each changed file:

```
scope = framework | session | excluded | unknown
```

- **framework** → include in commit + sync
- **session** → skip by default; include only if Gary explicitly requests
- **excluded** → never commit (use .gitignore)
- **unknown** → surface to Gary, ask

Rule: framework scope = any path matching `commands/`, `agents/`, `hooks/`, `.claude/hooks/`, `rules/`, `skills/`, `tools/`, `output-styles/`, `evals/`, `claws/`, `bootstrap/`, `settings/settings.json`, `install.sh`, `CLAUDE.md`, `README.md`, `invariants.md`.

### Stage 2 — Validate

Pre-flight gate. All must pass or STOP.

| Check | Command | Fails on |
|---|---|---|
| Frontmatter discipline | `bats tests/hooks/command-frontmatter.bats` | Deprecated `effort:` field, missing `description:` |
| No secrets staged | grep for common patterns in staged diff | `.env`, API keys, tokens |
| No session artifacts | git status check | `sessions/state.json` without `--include-session` flag |
| Spec freshness (warn only) | `bash tools/spec-freshness.sh` | Broken cross-refs (warn, don't block) |
| Working tree clean enough | `git status --porcelain` | Mid-rebase, merge conflicts |

### Stage 3 — Stage

- Stage files individually by name (`git add <path>` — never `-A` / `.`).
- Bucket by concern: primary change, test, docs, session artifacts (if opted in).
- Verify staged set against Stage 1 scope.

### Stage 4 — Commit

- Conventional-commit format: `feat(gos): ...`, `fix(gos): ...`, `chore(gos): ...`.
- Message body: mechanism + what + why (3-6 lines), no file list (diff has that).
- Attribution disabled globally (`attribution.commit: ""` in settings).
- Never `--amend` after a pre-commit hook failure — always a new commit.

### Stage 5 — Push

- `git push origin <branch>` (default `main`).
- New branch → `-u`.
- Non-fast-forward → STOP, surface reason, never auto-resolve.
- Never `--force` without explicit Gary approval in the same turn.

### Stage 6 — Sync (fan-out)

Delegate to `tools/sync-gos.sh`. One script, parallel-safe where possible, idempotent.

| Order | Action | Script step | Target |
|---|---|---|---|
| 1 | `install.sh --global` | stage A | `~/.claude/{commands,agents,hooks,rules,skills}` + settings merge |
| 2 | Copy `output-styles/*.md` | stage B | `~/.claude/output-styles/` |
| 3 | Copy `tools/gos-statusline.sh` | stage C | `~/.claude/statusline.sh` (chmod +x) |
| 4 | Mirror to plugin cache | stage D | `~/.claude/plugins/cache/gos-marketplace/gos/<latest>/` |

Plugin-cache mirror uses `rsync -a --delete` (or `cp -R` fallback). Subdirs mirrored: `commands/`, `agents/`, `rules/`, `hooks/` (from `.claude/hooks/` source).

**Version resolution:** find the highest-versioned dir under `~/.claude/plugins/cache/gos-marketplace/gos/` via `ls -1d */ | sort -V | tail -1`. Skip stage 4 if no plugin dir exists (fresh install).

### Stage 7 — Verify

| Check | Method |
|---|---|
| Push succeeded | HEAD sha matches `origin/<branch>` sha |
| User install synced | `diff -q commands/*.md ~/.claude/commands/` → silent |
| Plugin cache synced | `diff -q commands/*.md <plugin_dir>/commands/` → silent |
| Output style present | `test -f ~/.claude/output-styles/direct-response.md` |
| Status line executable | `test -x ~/.claude/statusline.sh` |
| Frontmatter tests still green | `bats tests/hooks/command-frontmatter.bats` |

Any mismatch → report drift, exit non-zero, do not claim success.

---

## Decision matrix — key architectural choices

| Decision | Options | Chosen | Why |
|---|---|---|---|
| Push before or after local sync? | A: sync then push B: push then sync | **B** | GitHub is the plugin-marketplace source. If the marketplace re-pulls mid-sync, local changes get overwritten; pushing first ensures the remote is authoritative. |
| Plugin cache: sync locally or trigger re-install? | A: copy files into cache B: `claude plugin update` | **A** | Direct copy is immediate, deterministic, and works offline. Plugin update is async, depends on marketplace round-trip, and can silently fail. |
| One script or inlined in ship.md? | A: one `sync-gos.sh` B: inlined bash in command | **A** | Reusability (fresh clones, `install.sh` can call it, other verbs can call it) and testability. |
| Include session artifacts by default? | A: yes B: no C: opt-in flag | **B** | Session artifacts change every turn; including them bloats commit history and leaks local state. Opt-in via explicit Gary ask, not default. |
| Marketplace version drift handling? | A: pin B: latest always | **B (latest-always)** | `sync-gos.sh` auto-detects latest version dir. Pinning adds maintenance burden; latest is idempotent. |
| rsync vs cp -R? | A: rsync with fallback B: cp -R only | **A** | rsync `--delete` removes stale files (old command that got renamed); cp -R leaves orphans. Fallback to cp -R if rsync unavailable. |
| Fail if plugin cache missing? | A: yes B: skip silently with log | **B** | Fresh clones / non-Gary machines won't have the marketplace installed. Silent skip with log keeps the command universal. |

---

## Failure modes + handling

| Failure | Detection | Handling |
|---|---|---|
| Frontmatter test fails | Stage 2 exits 1 | STOP. Show failing test. No commit. |
| Secret detected | Stage 2 grep match | STOP. Name the file. Ask Gary before proceeding. |
| Push rejected (non-fast-forward) | `git push` exit 1 | STOP. Show `git status -uno` + `git log origin/main..HEAD`. Never auto-pull or force. |
| install.sh errors | sync-gos.sh stage A exit 1 | STOP after commit + push (GitHub is safe). Report user-install failure. Don't attempt plugin cache. |
| Plugin cache mismatch after sync | Stage 7 diff | Report drift. Suggest running sync again. Keep commit — just surface. |
| Marketplace overwrites cache (async) | Stage 7 detects post-hoc | Document: if Gary sees stale autocomplete, re-run `bash tools/sync-gos.sh`. Future work: hook into marketplace pull events. |

---

## Verification after sync

Post-sync, automatic sanity check (5 seconds, cheap):

```bash
# 1. Repo is synced with GitHub
test "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)"

# 2. User install matches
for f in commands/*.md; do
  diff -q "$f" "$HOME/.claude/$f" >/dev/null || echo "DRIFT: $f"
done

# 3. Plugin cache matches
PLUGIN_DIR="$(ls -1d $HOME/.claude/plugins/cache/gos-marketplace/gos/*/ | sort -V | tail -1)"
for f in commands/*.md; do
  diff -q "$f" "$PLUGIN_DIR/$f" >/dev/null || echo "DRIFT: $f"
done

# 4. Frontmatter regression test
bats tests/hooks/command-frontmatter.bats
```

Exit with structured report:

```
✓ gOS synced
  repo:    main @ <sha>     → origin/main ✓
  user:    72 files          → ~/.claude/
  plugin:  116 files         → gos/4.4.0/
  styles:  1                 → output-styles/direct-response.md
  status:  1                 → statusline.sh
  tests:   7/7 passing
```

---

## Current state vs. this design

| Capability | Today (commit `e61f271`) | This design | Gap |
|---|---|---|---|
| Detect framework scope | Implicit (ad-hoc git add) | Stage 1 explicit classification | Add scope classifier |
| Frontmatter validation | Manual (`bats` run on request) | Stage 2 blocking gate | Wire into sync-gos.sh |
| Session artifact exclusion | Ad-hoc | Stage 1 classification | Add rule + opt-in flag |
| Push before sync | Done | ✓ | — |
| sync-gos.sh | Works | ✓ | — |
| Plugin cache mirror | Works | ✓ | — |
| Output styles + statusline | Works | ✓ | — |
| Post-sync verification | Reported counts only | Diff-based drift check | Add verify stage |
| Failure modes documented | Partial | Full table | Document in ship.md |

---

## WRAP

**CONFIDENCE: high** on the 7-stage architecture. **Medium** on the marketplace-overwrite handling — the plugin cache will get clobbered whenever CC auto-updates the plugin from GitHub. Mitigation today: push to GitHub first, so cache clobber = re-sync from GitHub = same content. Risk: if Gary edits locally without pushing, then CC auto-updates, the local edits vanish from the cache (but stay in the repo working tree).

**WHY (confidence calibration):** the architecture is verified by three shipped commits this session — each ran through commit + push + sync and produced visible results in the skills catalog. The medium confidence is on the marketplace-overwrite edge case, which I haven't yet observed in practice but can predict from the cache-update logic.

**NEXT:**
1. Add Stage 1 scope classifier + Stage 2 validation gate to `sync-gos.sh`. Two new functions, ~30 lines. Makes session-artifact leaks impossible.
2. Add Stage 7 verification pass. Another ~20 lines. Post-sync drift becomes visible, not hidden.
3. Consider (future): watch `~/.claude/plugins/cache/gos-marketplace/gos/` for marketplace-triggered overwrites and re-sync automatically. Out of scope for v1.
4. Update `commands/ship.md` `gos` sub-command to reflect the 7-stage pipeline (currently shows simpler model).
