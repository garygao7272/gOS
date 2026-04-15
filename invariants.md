# gOS Global Invariants

> **Falsifiable rules enforced every session, every project.** Each invariant answers: *what catastrophe does this prevent?* If you can't name the catastrophe, it's aspirational — demote to a rule or cut it.
>
> **Scope:** Applies to every project that loads `~/.claude/CLAUDE.md`. Project-specific invariants live in `<project>/.claude/invariants.md`.
>
> **Enforcement:** Hooks read this file. Violations either warn (exit 1) or block (exit 2).

---

## INV-G01 — First-principles distillation

Every synthesis output decomposes to first principles before recommending. Causal, not analogical. Trace symptom → mechanism → primitive. If you stopped at *"like X"* without naming the underlying cause, the output is not done.

**Catastrophe prevented:** Shallow output missing root cause → wrong decisions compound across downstream specs and code.

**Applies to:** `/think spec`, `/think decide`, `/build`, `/design`, `/review`, `/ship`. **Exempt:** `/think discover|research|intake` (exploration — constraint would kill divergent thinking).

**Self-check:** "Did I trace to root, or stop at symptom? Name the primitives."

---

## INV-G02 — /ship blocks without PASSED review

`/ship commit|pr|deploy` never advances when `/review gate` has not returned PASSED for the current diff.

**Catastrophe prevented:** Shipping code that violates the very invariants it was meant to uphold.

**Enforcement:** `phase-gate.sh` hook reads latest handoff JSON; exits 2 if gate missing.

---

## INV-G03 — Read-before-edit

No file is edited without being read in the same session.

**Catastrophe prevented:** Overwriting in-progress work; losing context the file was carrying that the current task depends on.

**Enforcement:** Claude Code's built-in Edit tool requires this; `read-tracker.sh` hook logs violations.

---

## INV-G04 — No silent dependency additions

No new dependency (npm, pip, brew, MCP server, plugin) is added without explicit Gary approval in the chat.

**Catastrophe prevented:** Supply-chain drift, security surface expansion, lean-constraint violation.

**Applies to:** `/build`, `/design`, any tool install.

---

## INV-G05 — TDD for `/build feature`

Tests are written before implementation. RED → GREEN → REFACTOR. Tests must fail before code is written.

**Catastrophe prevented:** Code that "works" but doesn't match intent; silent drift invisible until production.

**Exempt:** `/build fix` (bug already has a repro), `/build prototype` (throwaway), `/build model` (xlsx).

---

## INV-G06 — Compliance matrix on `/build feature`

Every `/build feature` produces `outputs/build/{slug}/compliance.md` mapping each Definition-of-Done item → file:line. `/ship` blocks if missing.

**Catastrophe prevented:** Invisible gap between spec and shipped code; "did we cover this?" answered by vibes not evidence.

**Exempt:** fixes < 50 LOC, prototypes, refactors.

---

## INV-G07 — Assumption log on `/build`

Every `/build` session logs decisions made outside the declared spec/plan to `outputs/build/{slug}/assumptions.md`. `/gos save` ingests these as gaps for the next `/think spec`.

**Catastrophe prevented:** Silent assumptions compound into bugs or product decisions Gary never actually made.

---

## INV-G08 — Shared-history git ops require approval

No `git push --force`, `git reset --hard`, `git rebase -i` on pushed commits, or amend of pushed commits without explicit Gary approval in the chat for the specific operation.

**Catastrophe prevented:** Lost work; destroyed collaborator state; unrecoverable history.

**Enforcement:** `git-safety.sh` hook.

---

## INV-G09 — Secrets never commit

Secrets (API keys, tokens, private keys, `.env` contents) never land in committed files or PR bodies.

**Catastrophe prevented:** Credential exposure → account compromise, financial loss, identity theft.

**Enforcement:** `secret-scan.sh` pre-commit hook exits 2.

---

## INV-G10 — Declarative discipline only on synthesis

IN / OUT / NEVER boundary sections and compliance artifacts apply **only** to synthesis commands (`/build`, `/design`, `/ship`, `/review`, `/think spec`). Exploration commands (`/think discover|research|intake`, `/simulate scenario`, `/gos refine` early cycles) are unconstrained.

**Catastrophe prevented:** Killing divergent thinking by imposing convergent discipline during ideation.

---

## INV-G11 — Unverified memory flagged

Any response drawing on memory without verification is prefixed with `"From memory (unverified):"`. If the memory has `valid_until` expired, prefix with `"From memory (may be stale):"` and re-verify before acting.

**Catastrophe prevented:** Compounding errors from stale state; Gary trusting a fact that was true 3 months ago but isn't now.

---

## INV-G12 — Confidence on every output

Every synthesis output ends with `CONFIDENCE: high|medium|low — reason`. Confidence < 60% → STOP, state uncertainty, ask before proceeding.

**Catastrophe prevented:** False certainty leading Gary to over-trust output; irreversible actions on weak evidence.

---

## INV-G13 — `/build fix` stays in scope

`/build fix` is restricted to: missing imports, type errors, lint failures, test wiring, syntax. Never architectural changes. Never spec edits. Never new behavior.

**Catastrophe prevented:** Bug-fix session silently becomes a refactor; scope creep eats a day.

---

## INV-G14 — Phase-gate handoffs mandatory

`/design` requires a valid `sessions/handoffs/think.json` (approved=true). `/build` requires a valid `sessions/handoffs/design.json`. Missing or unapproved → block.

**Catastrophe prevented:** Building against a spec that wasn't approved; designing against research that wasn't synthesized.

**Enforcement:** `phase-gate.sh` hook.

---

## INV-G15 — Denied tool calls are final

When Gary denies a specific tool call, the exact same call is never retried in the same session. Adjust approach based on the denial, don't re-attempt.

**Catastrophe prevented:** Eroding Gary's control; forcing repeated denials; ignoring implicit feedback.

---

## INV-G16 — Surgical edits only

Every edit changes only what the task requires. No drive-by reformatting, no "while I'm here" refactors, no opportunistic comment cleanup, no unrequested renames. If a cleanup is warranted, surface it as a separate suggestion — do not fold it into the task diff.

**Catastrophe prevented:** Drive-by edits corrupt working code, bloat diffs beyond review capacity, erode trust that the diff matches the described change.

**Applies to:** `/build`, `/design`, `/ship`, any Edit/Write tool use. **Self-check:** "Is every hunk in this diff required by the stated task? If no — split."

---

## Invariant lifecycle

- **Add:** When a hook is added that enforces a structural rule, add the corresponding INV-Gxx here. Hook without INV = silent enforcement (bad).
- **Remove:** When a hook is removed, the INV becomes aspirational — demote to `rules/` or cut.
- **Review:** `/evolve audit` checks every INV-Gxx quarterly: is it still enforced? If not, is the hook broken or the rule obsolete?

## Cap

Max 20 INVs in this file. Above 20 = either not structural (move to rules) or project-specific (move to `<project>/.claude/invariants.md`).
