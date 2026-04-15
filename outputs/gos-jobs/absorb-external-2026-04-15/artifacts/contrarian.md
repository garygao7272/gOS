# Contrarian Pre-Mortem

## Failure Scenario 1: The Karpathy Guidelines Become Dead Dogma

Causal chain: The four principles (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) get absorbed as a named skill → gOS starts invoking `karpathy-guidelines` in `/build` and `/review` pipelines → the guidelines are treated as a checklist rather than internalised heuristics → Gary starts seeing bureaucratic friction ("per Karpathy principle 3, I should mention...") on tasks where judgment was already sufficient → he starts skipping the check → the skill becomes dead weight that loads into context on every coding session, burning tokens forever while producing zero signal.

The deeper trap: gOS *already* encodes these principles. "Simplicity First" is `rules/common/coding-style.md` §Immutability + small files. "Surgical Changes" is already in the Autonomy Framework. "Goal-Driven Execution" is the Plan Gate. Absorbing Karpathy is not adding capability — it is adding *redundancy with a foreign label*. Redundancy in a system that must stay lean is not neutral; it is a slow poison that degrades attention and inflates context on every invocation.

---

## Failure Scenario 2: Hermes Colonises gOS's Identity

Causal chain: The Hermes absorption is scoped as "just the learning loop + FTS5 session search" → the PR is clean → but Hermes is an opinionated, Python-heavy, multi-platform, multi-user *product*, not a composable library → to get any one Hermes feature, you pull in its dependency graph (Honcho, serverless backends, gateway process, trajectory compression) → gOS's `install.sh` becomes fragile, the `~/.claude/` layout starts growing non-Claude-native files → within three sessions Gary is debugging a `hermes gateway` process that died overnight instead of doing product work.

The identity problem: gOS is Claude Code-native and single-user-by-design. Hermes is model-agnostic and multi-user-by-architecture. Every Hermes design decision optimises for "run anywhere, talk from Telegram." Gary runs exactly one Claude Code session, on one machine. The features that make Hermes powerful (platform gateways, serverless hibernation, subagent RPC) are irrelevant to that context and will create surface area that needs maintenance without ever being used.

---

## Failure Scenario 3: Autonomous Skill Creation Poisons the Memory Palace

Causal chain: Hermes's "closed learning loop — autonomous skill creation after complex tasks" gets absorbed into `/evolve` → the loop runs after Gary's sessions → new skills are auto-generated and written to `~/.claude/skills/` without explicit approval → after 30 sessions there are 40+ auto-generated skills, most derived from one-off sessions that Gary never revisited → `/gos` loads them on startup → context bloat hits the 20% warning threshold → Gary's L1 memory gets crowded out → gOS starts forgetting cross-session context while simultaneously hallucinating "skills" it invented for past one-off tasks.

The feedback memory `lean_smart` is explicit: "no token bloat, no over-engineering." Autonomous skill creation is the opposite of surgical. It is an entropy machine. gOS's memory architecture is deliberately curated (L0/L1/L2/L3); Hermes's learning loop is deliberately autonomous. These design philosophies are incompatible, not complementary.

---

## Kill Shot

The single weakest assumption in "we should absorb these repos":

**"Taking a piece of a system designed for a different context is safe if the piece looks useful."**

Both repos are coherent wholes. Karpathy Guidelines works because Karpathy is describing principles he follows *implicitly*, not a checklist to append to prompts. Hermes works because its features are co-designed around a specific runtime (persistent server, multi-platform gateway, model-agnostic loop). Extracting a "piece" from either requires you to also absorb the implicit assumptions of the whole — or rewrite the piece until it's no longer theirs. At that point you built it yourself anyway, which is cheaper.

---

## Wargame (if Hermes/Nous decided to attack gOS)

If Hermes wanted to displace gOS for Gary's use, here is how absorption hands them the weapon:

Gary installs Hermes components "just for the FTS5 search." Hermes's installer is opinionated — it writes `~/.hermes/`, sets up its own config layer, and registers a gateway process. Now there are two competing persistence layers: gOS's `sessions/` + `memory/` structure and Hermes's own memory store. Gary gets confused about which system holds the canonical state of a project. He asks Hermes a question — Hermes answers from its own user model (Honcho dialectic) which doesn't know gOS's signal vocabulary. The answer is reasonable but wrong for gOS's framework. Confidence erodes. Gary starts treating the combined system as "neither owns the truth." gOS's signal discipline breaks down. The `lean_smart` invariant is violated from within.

Hermes doesn't need to attack. Absorption creates a split-brain system that destroys trust in both.

---

## Steel Man (the narrow path where absorption DOES work)

Karpathy absorption works **if and only if** the four principles replace overlapping gOS rules rather than stack on top of them. Specifically: audit `rules/common/coding-style.md` and the Plan Gate, identify any gap, and write one targeted sentence into an existing file. Net addition: 0 new files, ~4 new lines. No skill file created. No invocation path added.

Hermes absorption works **if and only if** you extract one self-contained utility with no runtime dependency — the most credible candidate is the FTS5 session search query pattern, ported as a shell function into `tools/` that runs against gOS's existing `sessions/` markdown files. This requires reading ~50 lines of Hermes source, extracting the SQL query logic, and dropping a `tools/session-search.sh`. No Python, no Honcho, no gateway. Estimated effort: 2 hours. This is not "absorbing Hermes" — it is reading Hermes for one implementation idea, which is just research.

---

## Verdict

**CONCERN** — Karpathy is redundant; Hermes is architecturally incompatible. Neither repo should be absorbed as-is. Absorb Karpathy only as 4 targeted line-edits to existing rule files. Absorb Hermes only as a research reference for one shell utility. Treat both as reading material, not dependencies.
