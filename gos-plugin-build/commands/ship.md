---
description: "Ship — deliver: commit, push, pr, gos, deploy, docs, fundraise — or full ship sequence"
---

# Ship — Delivery Pipeline

**Purpose:** Ship whatever changed — specs, code, docs. Ship doesn't filter by file type. It packages work into commits, PRs, deployments, and documentation updates.

Parse the first word of `$ARGUMENTS` to determine sub-command. If none given, run the full ship sequence.

---

## (no args) — Full Ship Sequence

The complete delivery pipeline. Run when work is done and ready to go out.

**Boundary check (INV-G06, INV-G07) — runs first:**

Before any commit, if the diff includes a `/build feature` output (anything under `apps/` or a new module):
1. Check for `outputs/build/{slug}/compliance.md` — must exist with no ⚠️/❌ rows
2. Check for `outputs/build/{slug}/assumptions.md` — must exist (may be empty)
3. If missing: BLOCK with "Build deliverables missing. Run /build feature emitter or `/review fresh` first."

Small fixes (<50 LOC, no new files, `/build fix` only): exempt. Everything else: enforced.

**Pre-ship parallel checks** — launch all in a single message before committing:

```
Agent("Run test suite, report pass/fail count", subagent_type="general-purpose", model="haiku", run_in_background=true)
Agent("Run linter, report error count", subagent_type="general-purpose", model="haiku", run_in_background=true)
Agent("Run spec-freshness check: bash tools/spec-freshness.sh", subagent_type="general-purpose", model="haiku", run_in_background=true)
```

If any agent reports failures → STOP and report before committing. If all clean → proceed.

1. **Review gate:** Check if `/review` (code-reviewer agent) has been run on this work.
   - If review dashboard exists and is NOT CLEARED (has unresolved CRITICAL or HIGH issues): warn Gary and ask "Review has unresolved issues. Proceed anyway?"
   - If no review was run: check diff size with `git diff --stat <base>...HEAD | tail -1`. If ≥10 files OR ≥500 LOC, suggest `/ultrareview` (cloud parallel multi-agent, native CC v2.1.111+). Otherwise suggest `/review code`. Format: "No review on record. Diff is {N} files / {M} LOC — recommend `/ultrareview` (large diff) [or `/review code` (small diff)]. Run review or ship anyway?"
   - If review is CLEARED: proceed silently.

2. **Final test run:** Run the project's test suite one last time.
   - `npm test` or equivalent for the active app
   - If tests fail: STOP. Report failures. Do not ship broken code.

3. **Stage files:** Run `git status` to see what changed. Stage relevant files individually.
   - NEVER use `git add -A` or `git add .`
   - Add specific files by name
   - Skip files that look like secrets (.env, credentials, tokens)
   - Skip large binary files unless intentional

4. **Create commit:** Follow conventional commit format.
   - Read recent `git log --oneline -10` for style consistency
   - Analyze the diff to determine type: feat, fix, refactor, docs, test, chore, perf, ci
   - Write concise message (1-2 sentences, focus on "why" not "what")
   - No Co-Authored-By line (attribution disabled globally)

5. **Push:** Push to remote (see `push` sub-command for the atomic operation).
   - Use `-u` flag if this is a new branch
   - Never force-push without explicit approval

6. **Create PR:** Via `gh pr create` (assumes branch is already pushed).
   - Title: <70 chars
   - Body format:
     ```
     ## Summary
     <1-3 bullet points>

     ## Test plan
     - [ ] ...

     Generated with gOS
     ```
   - Return PR URL

7. **Auto-docs:** Trigger `/ship docs` automatically (see docs sub-command below).

8. **Report:**
   ```
   Shipped.
   Commit: {hash} — {message}
   PR: {url}
   Docs: {updated | no changes needed}
   ```

---

## commit

**Purpose:** Create a git commit only. No push, no PR.

**Process:**

1. Run `git status` to see all untracked and modified files
2. Run `git diff` (staged + unstaged) to see what changed
3. Read `git log --oneline -10` for recent commit message style
4. Analyze changes — determine type:
   - `feat`: new feature or capability
   - `fix`: bug fix
   - `refactor`: code restructuring, no behavior change
   - `docs`: documentation only
   - `test`: adding or updating tests
   - `chore`: maintenance, config, dependencies
   - `perf`: performance improvement
   - `ci`: CI/CD changes
5. Draft concise commit message (1-2 sentences, "why" not "what")
6. Stage specific files by name (never `git add -A` or `git add .`)
   - Skip .env, credentials, tokens, large binaries
7. Create commit
8. Run `git status` to verify clean state

No Co-Authored-By attribution line (disabled globally).

If pre-commit hook fails: fix the issue and create a NEW commit. Never `--amend` the previous commit (amending after hook failure modifies the wrong commit).

---

## push

**Purpose:** Push the current branch to its remote. No commit, no PR, no deploy.

**Process:**

1. Run `git status` — confirm working tree is clean enough to push (warn if uncommitted changes exist; they won't be pushed but flag the mismatch).
2. Run `git rev-parse --abbrev-ref HEAD` to get the branch name.
3. Check upstream tracking: `git rev-parse --abbrev-ref --symbolic-full-name @{upstream}`. If no upstream, push with `-u origin <branch>`. Otherwise plain `git push`.
4. Never force-push without explicit approval. If push rejected (non-fast-forward), STOP and report — do not auto-resolve.
5. Report: `Pushed {branch} → {remote}/{branch} (N commits). HEAD: {short-sha}`.

---

## gos

**Purpose:** Commit and push a change to the **gOS repo** from anywhere. Use when you're working in another project (Arx, Advance Wealth, etc.) and want to upstream a framework fix — a hook, command, rule, skill, or claw — without manually cd-ing.

**Scope detection (blocking):** The change must touch one of the following, relative to the gOS repo root:
- `commands/*.md`, `agents/*.md`, `skills/**`, `rules/**`
- `hooks/*`, `claws/**`, `evals/**`, `launchd/*.plist`
- `tools/*.sh`, `settings/settings.json`, `install.sh`, `bootstrap/**`
- **Framework memory** (reusable substrate, ships with gOS): `memory/L0_*`, `memory/L1_*`, `memory/MEMORY.md`, `memory/user_*`, `memory/feedback_*`, `memory/procedure_*`
- **NOT in scope** (per-project state, stays local): `memory/project_*`, `memory/episodes.md`, `memory/evolve_audit_*`, `memory/reflection_*`, `memory/self-model.md`
- `CLAUDE.md` or `gOS/CLAUDE.md`, `README.md` at repo root

If the change doesn't fit gOS scope: STOP and say so. Do not silently fall back to the current repo.

**Process — 7-stage pipeline (see [outputs/think/decide/ship-gos-pipeline.md](../outputs/think/decide/ship-gos-pipeline.md) for the full design):**

| Stage | Does | Invoked by | Blocks on |
|---|---|---|---|
| 1. Detect | Classify changed files as framework / session / excluded / unknown | `sync-gos.sh --preflight` | unknown-scope file |
| 2. Validate | Frontmatter regression test (bats) + secret scan on staged diff | `sync-gos.sh --preflight` | test fail or leaked secret |
| 3. Stage | `git add <path>` by name — never `-A` or `.` | Claude | secrets / large binaries |
| 4. Commit | Conventional msg (feat/fix/chore/refactor + `(gos)` scope) | Claude | pre-commit hook fail |
| 5. Push | `git push origin <branch>` (or `-u` if new branch) | Claude | non-fast-forward — STOP |
| 6. Sync | Fan out to user install + output-styles + statusline + plugin cache | `sync-gos.sh` (default mode) | install.sh failure |
| 7. Verify | `diff -q` source vs each live target + frontmatter tests | `sync-gos.sh` (auto, end) | drift detected |

**Concrete commands:**

```bash
# From anywhere — resolve gOS repo path once:
GOS="/Users/garyg/Documents/Documents - SG-LT674/Claude Working Folder/gOS"

# Stage 1+2: pre-flight gate (fast — runs before you commit)
bash "$GOS/tools/sync-gos.sh" --preflight

# Stages 3-5: git in the gOS repo
git -C "$GOS" add <paths-by-name>
git -C "$GOS" commit -m "feat(gos): ..."
git -C "$GOS" push

# Stage 6+7: one script — default mode runs both
bash "$GOS/tools/sync-gos.sh" --quiet
```

**Source of truth rule:** always edit files at the gOS repo root (`commands/`, `agents/`, `hooks/`, `.claude/hooks/`, `tools/`, `output-styles/`). Never edit `~/.claude/` copies or the plugin cache directly — they get overwritten by every sync.

**Never** run destructive git ops (`reset --hard`, `push --force`, `clean -fd`) inside the gOS repo from another project's session.

**Fallback for older clones missing `sync-gos.sh`:** `bash install.sh --global && cp tools/gos-statusline.sh ~/.claude/statusline.sh && cp output-styles/*.md ~/.claude/output-styles/` — but the script is the canonical entry point and covers plugin-cache sync + verification that the fallback misses.

---

## pr

**Purpose:** Create a pull request only. Assumes the branch is already pushed. If not pushed, STOP and tell the user to run `/ship push` first — this sub-command does not push.

**Process:**

1. Check upstream tracking. If no upstream or remote HEAD is behind local HEAD, STOP: "Branch not pushed. Run `/ship push` first."
2. Determine the base branch (main, master, or develop).
3. Run `git diff {base-branch}...HEAD` to see the full diff.
4. Read ALL commits on the branch: `git log {base-branch}..HEAD --oneline` — analyze every commit, not just the latest.
5. Draft PR:
   - Title: <70 chars, summarizes the change
   - Body:
     ```
     ## Summary
     <1-3 bullet points covering ALL commits>

     ## Test plan
     - [ ] {specific test steps}

     Generated with gOS
     ```
6. Create PR via `gh pr create`.
7. Return PR URL.

---

## deploy

**Purpose:** Deploy to production or preview environment.

**Input:** Optionally specify target — `web` (default) or `mobile`.

**For web (Vercel):**

1. Pre-deploy checks:
   - Run build: `npm run build` (or equivalent)
   - Run lint: `npm run lint` (if configured)
   - Run tests: `npm test` (if configured)
   - If any check fails: STOP. Report the failure.
2. Deploy:
   - Use Vercel MCP `deploy_to_vercel` tool if available
   - Fallback: `npx vercel --prod --archive=tgz`
3. Monitor build logs via `get_deployment_build_logs` if build fails
4. Verify deployment URL loads correctly
5. Report deployment URL

**For mobile (Expo):**

1. Pre-deploy checks: build, lint, tests (same as web)
2. Deploy: `eas build --platform all` or `expo publish`
3. Report build URL or QR code

---

## docs

**Purpose:** Update documentation to match code changes. Absorbs the old `update-docs` and `update-codemaps` commands.

**Process:**

1. Run `git diff HEAD~1` (or `git diff` if uncommitted changes) to see what changed
2. Identify all changed files — code, specs, config
3. Search for all `.md` files in the project that might reference changed code:
   - `specs/` — product specs
   - `docs/` — documentation
   - `docs/CODEMAPS/` — architecture maps
   - `CLAUDE.md` — project instructions
   - `README.md` — project readme
   - Any other `.md` files
4. For each doc file, check if it references any changed code:
   - File paths that moved or were renamed
   - Function/component names that changed
   - API endpoints that changed
   - Configuration that changed
5. Update stale documentation with accurate information
6. If architecture changed (new modules, moved files, changed data flow):
   - Update relevant codemaps in `docs/CODEMAPS/`
   - Update project structure in `CLAUDE.md` if applicable
7. Commit doc updates separately: `docs: update documentation for {feature/change}`
   - Stage only the doc files, not code
   - This keeps doc commits distinct from code commits

---

---

## fundraise [--only <artifact>]

**Purpose:** Ship investor-ready materials. Bundles three artifacts by default: IC memo + one-pager + financial projections.

**Scope flag:** `--only ic` | `--only onepager` | `--only plan` — generate just that artifact. Without the flag, generate all three and cross-check numbers.

**Artifact → skill map:**

| Artifact | Flag value | Skill |
|---|---|---|
| IC memo | `ic` | `Skill("private-equity:ic-memo")` |
| One-pager | `onepager` | `Skill("investment-banking:strip-profile")` |
| Financial plan | `plan` | `Skill("wealth-management:financial-plan")` |

**Process:**

1. **Gather current state:** Read latest XLSX projections from `other specs/`, read existing investor materials.
2. **Generate:** if `--only` is set, call just that skill. Otherwise call all three.
3. **QA pass:** If multiple artifacts were generated, cross-check number consistency. Skip QA on single-artifact runs.
4. **Package:** Collect outputs into `outputs/fundraise/` with a date stamp.

**Convergence loop (multi-artifact only):** If numbers disagree between IC memo, one-pager, and projections XLSX, fix and re-check. Max 3 consistency passes.

**Output:** `outputs/fundraise/` → "Fundraise {artifact|package} ready. {N} documents, numbers {consistent|N/A single-artifact}."

---

## Signal Capture

After ship completes, log the outcome signal to `sessions/evolve_signals.md`:
- Command: `/ship`, sub-command used
- Signal: based on Gary's response (accept/rework/reject/love)
- Context: what was shipped, any issues encountered
