# First-Principles Mechanism Map

**Scope:** Decomposing `andrej-karpathy-skills` (single skill, 4 principles) and `NousResearch/hermes-agent` (full self-improving agent framework) to atomic mechanisms. Each mechanism is evaluated against gOS by its *causal function* (what it prevents / what primitive it implements), not by surface resemblance.

---

## Karpathy Mechanisms

Source: `skills/karpathy-guidelines/SKILL.md` + `CLAUDE.md`. Four pre-coding behavioral rules.

| # | Mechanism (what it prevents) | gOS equivalent | Gap? |
|---|---|---|---|
| K1 | **Assumption surfacing** — force explicit statement of assumptions before code; prevents silent interpretation divergence between user intent and model action | Plan Gate (CLAUDE.md) already enforces: PLAN → STEPS → MEMORY → RISK → CONFIDENCE → Confirm. Gary's "Spec before agent" rule. Intent-confirmation added across all 8 commands (commit 084d8c8). | **Full equivalent.** gOS's Plan Gate is stronger — it also includes memory search and risk naming. |
| K2 | **Simplicity ceiling** — "200 lines where 50 suffice → rewrite"; prevents over-engineering caused by LLM tendency to demonstrate competence via volume | `feedback_lean_smart.md` ("gOS must stay lean: no token bloat, no over-engineering, shell > Python when sufficient"). `health-gate.sh` runs on every commit. `simplify` skill available. Bias check line in Plan Gate: "Am I over-engineering?" | **Full equivalent** as a rule; gOS has the gate + memory rule. Karpathy's framing ("would a senior engineer say this is overcomplicated?") is a crisper test — worth absorbing as a one-liner. |
| K3 | **Surgical change discipline** — "every changed line traces to the user's request"; prevents drive-by refactors that expand blast radius and dilute diffs | No explicit rule. `feedback_large_structural_writes.md` exists but is about write size, not scope creep. `code-reviewer` agent catches post-hoc, not pre-hoc. Practitioner rule #4 ("Check blast radius") is adjacent but targets *dependencies*, not *scope*. | **Partial gap.** The traceability test ("every changed line traces to the request") is missing as an explicit pre-edit gate. |
| K4 | **Goal-driven verification loop** — transform "do X" into "test X passes"; prevents weak success criteria that require human re-clarification mid-task | `tdd-workflow` skill, `verification-loop` skill, `evals/` rubrics per command, PEV protocol validator step. Rules/common/testing.md mandates TDD. | **Full equivalent.** gOS is actually deeper — PEV has validator iteration, evals have rubrics. |

---

## Hermes Mechanisms

Source: README.md, AGENTS.md, `agent/`, `tools/`, `acp_adapter/`, `acp_registry/`. Verified via raw file reads where claims were specific.

| # | Mechanism (what primitive it implements) | gOS equivalent | Gap? |
|---|---|---|---|
| H1 | **Agent-authored skill creation** — `tools/skill_manager_tool.py` exposes create/edit/patch/delete/write_file/remove_file as tool calls to the model, so the agent writes skills to `~/.hermes/skills/` during a session after a successful novel task (verified: file header + directory layout) | gOS: `/evolve learn` (manual teaching), `/evolve upgrade` (signal-triggered command rewrite). No tool-call path — Gary invokes a command; the model doesn't self-initiate writes to `skills/`. | **Partial gap.** gOS has the memory-write path (`learn`) and command-rewrite path (`upgrade`), but not *in-session autonomous procedural extraction* as a tool the agent can call without a verb invocation. |
| H2 | **Self-improving skills during use** — skill_manager_tool's `patch` action lets the agent edit a skill's SKILL.md mid-session when it discovers a correction (verified: "patch -- Targeted find-and-replace within SKILL.md") | `/evolve upgrade <command>` rewrites command files from signals, but is Gary-invoked, not auto. Direct-to-command learning annotation ("Instinct: {name}") exists. | **Partial gap.** gOS waits for 3+ repeat signals + manual `/evolve upgrade`. Hermes patches skills inline during the turn that surfaced the correction. |
| H3 | **Periodic memory-persistence nudges** — README claims "nudges itself to persist knowledge"; `agent/memory_manager.py` has `sync_all` post-turn and `on_turn_start` hook on memory providers, triggering extraction | gOS Stop hook runs signal scan + L1 update + state.json (per feedback_stop_hook_compliance.md). `/gos save` batch-logs. | **Equivalent at session boundary.** Gap: gOS lacks *mid-session* nudge. Stop hooks fire on exit, not periodically during a long session. |
| H4 | **FTS5 session search** — `hermes_state.py` uses SQLite CREATE VIRTUAL TABLE messages_fts USING fts5 with sanitized MATCH queries for cross-session recall (verified) | gOS has `sessions/` markdown files + claude-mem (L3) for RAG. No FTS5 index. `episode-recaller` agent uses `memory/episodes.md` + grep. | **Full gap.** gOS recall is markdown-scan based. FTS5 would be a structural upgrade for session-volume recall, but requires SQLite + indexing cron. Cost vs value depends on session count. |
| H5 | **Subagent parallelization with context isolation** — `tools/delegate_tool.py` spawns child AIAgent instances with fresh conversation, own task_id, restricted toolsets, blocked recursion (MAX_DEPTH=2), default 3-concurrent (verified) | gOS: PEV protocol (`pev-planner` → parallel agent execution → `pev-validator` → `adjudicator`). Parallel Task execution documented in rules/common/agents.md. `REGISTRY.yaml` has 25-agent cap. | **Full equivalent.** gOS's PEV is the same primitive with stronger orchestration (validator iteration, veto agents). Hermes's innovation is the *recursion bound* (MAX_DEPTH=2) — worth absorbing. |
| H6 | **Honcho dialectic user modeling** — external memory provider (pluggable via `memory_provider.py` abstract class) that builds a user model across sessions; Hermes architecture allows ONE external provider + BuiltinMemoryProvider (verified in memory_manager.py) | gOS has `memory/user_gary_soul.md` (static file), `self-model.md`, `L0_identity.md`. Manual updates via `/evolve learn user`. No dialectic (model-driven belief update from conversation). | **Partial gap.** gOS has a user model file; it lacks the *dialectic extraction loop* that updates the model from conversation traces. |
| H7 | **Pluggable memory-provider interface** — `MemoryProvider` ABC with lifecycle hooks (initialize, prefetch, sync_turn, on_turn_start, on_session_end, on_pre_compress, on_delegation) enforces single external provider + always-on builtin | gOS memory is directory-based (L0/L1/L2/L3 files), no provider abstraction. Hot-swapping would mean editing file paths in commands. | **Structural gap.** gOS memory has no interface — it's tightly coupled to file layout. Cost of adopting provider ABC = high; benefit depends on whether Gary wants to A/B test memory backends (he doesn't, per lean principle). |
| H8 | **Agentskills.io compatibility** — open standard for skill format (frontmatter YAML + SKILL.md body); `agent/skill_utils.py` parses this format | gOS skills use similar markdown+frontmatter pattern (`name`, `description`, `layer`, `valid_from` seen in L1_essential.md). | **Approximate equivalent.** gOS already close; formal compatibility = small diff to align frontmatter keys. |
| H9 | **Multi-platform messaging gateway** — single gateway process dispatches to Telegram/Discord/Slack/WhatsApp/Signal/Email with shared slash-command registry | gOS is CLI-only (Claude Code harness). No gateway. | **Out of scope.** gOS philosophy = CLI-native, Gary works in one terminal. Rejecting. |
| H10 | **Cron scheduler with natural-language task delivery** — `cron/` directory, jobs + scheduler, delivers reports to any platform | gOS: `claws/` (market-regime, source-monitor, spec-drift — persistent scheduled agents). | **Full equivalent.** Both primitives = "scheduled agent writes a report." gOS's claws are smaller, domain-specific. No absorption needed. |
| H11 | **Context compression engine interface** — `ContextEngine` ABC with `should_compress`, `compress`, threshold_percent=0.75, protect_first_n=3, protect_last_n=6 (verified) | gOS: `strategic-compact` skill, scratchpad bridge on compaction (CLAUDE.md: "Re-read on compaction"). No threshold-triggered auto-compress with protected turns. | **Partial gap.** gOS relies on Claude Code's built-in compaction. Hermes's innovation = protected turn ranges (first/last) so critical context survives compression. Worth absorbing as a skill rule. |
| H12 | **Security scanning on agent-authored skills** — `skills_guard.py` scans every skill the agent creates before allowing install (verified in skill_manager_tool.py: `_security_scan_skill`) | gOS: no skill-level security scan. `/review` command exists. Agents class has `security-reviewer`. | **Gap worth closing.** If H1 is absorbed, H12 must come with it — self-authored skills need pre-install scanning or the attack surface is the agent itself. |
| H13 | **ACP adapter for IDE integration** — `acp_adapter/server.py` exposes agent over Agent Client Protocol for VS Code/Zed/JetBrains | gOS runs inside Claude Code (already IDE-adjacent via CLI). | **Out of scope.** Different substrate. |
| H14 | **6 terminal backends** (local/Docker/SSH/Daytona/Singularity/Modal) with serverless idle hibernation | gOS runs in Claude Code locally. | **Out of scope.** Gary's workflow is local-first. |
| H15 | **Agent todo tool** — `tools/todo_tool.py` intercepted by run_agent.py before handle_function_call; agent maintains its own task list as procedural state | gOS: TodoWrite tool (Claude Code built-in). Used per rules/common/hooks.md. | **Full equivalent** (same primitive, different implementation). |
| H16 | **Batch trajectory generation + RL training loop** — `batch_runner.py`, Atropos environments, tinker-atropos submodule for training next-gen tool-calling models | gOS: signal capture → `memory/evolve_audit_*.md` → `/evolve upgrade`. Human-in-the-loop, not RL. | **Out of scope.** Gary's evolution loop is prompt-level, not weight-level. Rejecting. |

---

## Absorption Candidates (ranked by mechanism value, not feature count)

1. **K3 — Surgical-change traceability gate.** Add one line to Plan Gate in `CLAUDE.md`: "Every changed line must trace to the user's request. If it doesn't, remove it or flag it separately." Prevents drive-by refactors. Zero cost, high discipline value. Host: `~/.claude/CLAUDE.md` Plan Gate section + `rules/common/coding-style.md`.

2. **H2 — Auto-patch on repeat correction.** Lower `/evolve upgrade`'s threshold from "Gary invokes after 3+ signals" to "auto-propose patch after 3+ signals in one session, await approval inline." Keeps approval gate (Autonomy Framework compliance), removes the wait. Host: `commands/evolve.md` — add an "inline-upgrade" mode triggered by `signal-tallier`.

3. **H11 — Protected-turn compression rule.** Absorb the "protect first-N + last-N turns" heuristic into `skills/strategic-compact/SKILL.md`. Concrete rule: "On compaction, always preserve the first 3 turns (session intent) and last 6 turns (active context). Compress only the middle." Small rule, large effect on context quality. Host: `skills/strategic-compact/`.

4. **H12 — Skill/command self-scan.** If H2 is adopted (agent patching files), add a pre-write scan — run `review` agent on any `/evolve upgrade` diff before applying. Parallel to Hermes's `_security_scan_skill`. Host: `commands/evolve.md` — insert before step 7 "rewrite the command file."

5. **H3 — Mid-session memory nudge.** Current Stop hook fires at session end. Add a mini-checkpoint nudge at ~15 message intervals (CLAUDE.md already references this as a rule but enforcement is vague). Make it a hook: `hooks/mid-session-nudge.sh` that prompts "Log any signals? Update L1?" Host: new hook file + `settings/settings.json`.

6. **H5 — Recursion depth bound in PEV.** Add `MAX_DEPTH=2` to `specs/pev-protocol.md` so a `pev-planner` can't spawn a sub-PEV loop that spawns another. Hermes learned this the hard way; gOS gets it free. Host: `specs/pev-protocol.md` + `agents/pev-planner.md`.

7. **K2 sharper test.** Add "Would a senior engineer call this overcomplicated?" as a one-line bias check in Plan Gate. gOS already has the rule; this is a crisper mnemonic. Host: `~/.claude/CLAUDE.md` Plan Gate.

---

## Anti-Absorption (mechanisms we SHOULDN'T take)

- **H4 FTS5 session search** — Cost: SQLite schema + indexing cron + FTS5 sanitizer. Benefit: only pays off at 100+ sessions with cross-session recall needs. Gary's current recall is L0/L1/L2/L3 file-based + claude-mem; working. Violates `feedback_lean_smart.md`. **Revisit if session count > 200 and recall starts failing.**

- **H6 Honcho dialectic user modeling** — Adds external dependency (Honcho service), network calls, and a model-maintained belief file that could drift from Gary's actual state. gOS's `user_gary_soul.md` is hand-curated + edited via `/evolve learn user`. Dialectic = automation that Gary would need to audit. Net token cost > token saved. **Philosophy mismatch: Gary is the source of truth on Gary.**

- **H7 Pluggable memory-provider ABC** — Abstraction pays off when you swap providers. Gary never will. Adding an interface for one implementation is speculative flexibility — exactly what K2 (Simplicity First) forbids. **Anti-pattern per Gary's rules.**

- **H9 Multi-platform messaging gateway** — gOS is CLI-native by design. Telegram/Discord bots add auth surface, rate limits, and context fragmentation across platforms. **Scope mismatch.**

- **H13 ACP IDE adapter** — Claude Code is already the IDE-adjacent substrate. Duplicating the protocol = maintenance burden with no user benefit.

- **H14 Six terminal backends (Docker/SSH/Modal/etc.)** — Gary runs one machine, one project tree. Remote backends solve "agent runs while I sleep" — gOS solves this with `claws/` cron + local execution. **Out of scope.**

- **H16 RL training loop + Atropos** — Training models is Nous's business (they are a model-training lab). gOS is a prompt-and-workflow system. Weight-level evolution is an order of magnitude off mission. **Mission mismatch.**

- **H8 Formal agentskills.io frontmatter compatibility** — gOS skill frontmatter is already 80% aligned. Formalizing it gains nothing unless Gary wants to publish to the hub (he doesn't). **Low value unless public distribution becomes a goal.**

---

## Summary

**Karpathy:** 3 of 4 principles already live in gOS (stronger). Absorb K3 (surgical-traceability) as a one-liner + K2's sharper test phrasing. Net delta: ~4 lines in CLAUDE.md.

**Hermes:** 7 of 16 mechanisms are in-scope. Top 4 (H2 auto-patch, H5 depth bound, H11 protected turns, H12 self-scan) are structural upgrades to gOS's existing evolve/PEV/compact primitives — not new features. H1 (autonomous skill creation as tool call) is the largest single capability and worth prototyping, but only paired with H12. Anti-absorb H4/H6/H7/H9/H13/H14/H16 — each would violate `feedback_lean_smart.md` or mission scope.

**Causal summary:** gOS already has the *loops* (evolve, PEV, signal capture, memory tiers). Hermes's real contribution to absorb is *tightening the loops* — shorter latency from signal → patch (H2), inline protections (H11, H12), and bounded recursion (H5). Not new organs, sharper instincts.
