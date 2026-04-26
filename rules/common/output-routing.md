# Output Routing — inline vs file

> **What this is.** Single source of truth for choosing whether a verb's output goes to chat (inline) or to a file (MD artifact). Every gOS verb consults this rule before generating output; the rule overrides any verb-level default file path when the auto-default fires.
>
> **Audience.** Every gOS command file (`commands/*.md`) and every agent that produces persisted output.
>
> **Reader output.** A one-line routing decision — `Routing → inline (~Nw, no retrieval need)` or `Routing → file (decision-record, audit trail required)` — printed before the verb's substantive work begins.
>
> **Why now.** Verb-level hardcoded file paths overrode §7.9.6's inline default. Specs and audits got persisted that should have been chat replies, polluting `outputs/` and forcing Gary to fight the verb wiring when he wanted a quick answer.

**Covers:** the two-layer design · the routing heuristic · the explicit flag · what each verb's default is · what to print before executing.

## Two-layer design

| Layer | What it does | When it fires |
|---|---|---|
| **Auto-default** (this file) | Estimates token count + retrieval need + audit need; picks inline or file; prints one-line decision | Every verb invocation, unless flag overrides |
| **Explicit flag** (`--inline` / `--file`) | User overrides the auto-default with a single keystroke | When the user already knows the right shape and doesn't want to trust the heuristic |

The flag wins. The auto-default is the safety net for the ~90% of cases where the user shouldn't have to think about routing.

## The routing heuristic

A verb's output goes **inline** when **all three** hold:

1. **Estimated word count < 200** — anything longer than ~30 lines reads as artifact-shaped, not chat-shaped.
2. **No future-session retrieval need** — the user won't grep for this in a week. Status checks, factual answers, single-shot advisory all qualify as zero-retrieval. Audits, decision records, specs, build cards do not.
3. **No audit-trail or handoff need** — this output isn't input to another verb (`/build` reading a spec from `/think`, `/ship` checking a contract from `/build`). If a downstream verb consumes this output, it's a file.

Otherwise → **file**.

The decision is conservative — when in doubt, file. A misjudged inline answer is annoying to recover; a misjudged file is a dead artifact that takes one `rm` to clean.

## The explicit flag

| Flag | Effect |
|---|---|
| `--inline` | Force chat output. Verb's default file path is ignored. Truncate to fit if necessary. |
| `--file` | Force file output. Use the verb's default path, or ask if none exists. |
| `--file=<path>` | Force file output to a specific path. Overrides the verb's default. |
| (no flag) | Auto-default — apply the heuristic above. |

Flags work on every gOS verb (`/think`, `/design`, `/build`, `/review`, `/refine`, `/simulate`, `/ship`, `/intake`, `/save`, `/resume`, `/gos`). A verb that ignores the flag is a bug.

## What to print before executing

Before any substantive work, the verb prints exactly one line so the routing decision is legible:

```
Routing → inline (~180w est, no retrieval need)
Routing → file (decision-record, audit trail required) → memory/evolve_audit_2026-04-26.md
Routing → inline (--inline flag override)
Routing → file (--file=outputs/think/research/topic.md flag override)
```

The line is part of the verb's pre-flight, not part of the output. It costs one line; it makes the heuristic falsifiable.

## Per-verb default targets (used when `--file` fires or auto-default chooses file)

| Verb | Default file target | Inline-OK? |
|---|---|---|
| `/think research` | `outputs/think/research/{slug}.md` | Yes — short factual research can stay inline |
| `/think decide` | `outputs/think/decide/{question}.md` | Rarely — decisions usually want audit trail |
| `/think discover` | `outputs/think/discover/{topic}.md` | No — discovery is structurally a doc |
| `/think spec` | `specs/{slug}.md` or `outputs/think/design/{slug}.md` | No — specs are by definition persisted |
| `/design card` | `specs/{N}-{N}_Card.md` | No — cards persist |
| `/design ui` | `apps/web-prototype/index.html` or sibling | No — UI is code |
| `/build feature` | `outputs/build/{slug}/contract.md` + code | No — contract persists |
| `/build fix` | (no doc — code only) | N/A |
| `/review fresh/code/gate` | `outputs/review/{slug}/verdict.md` | Yes — short verdicts can be chat |
| `/review ultra/council` | `outputs/review/{ultra,council}/{slug}/synthesis.md` | No — multi-agent synthesis persists |
| `/refine` | `outputs/refine/{slug}/cycle-N/...` | No — cycles persist |
| `/simulate market` | `outputs/simulate/{run-id}/results.md` | No — sim runs persist |
| `/simulate scenario` | `outputs/simulate/scenario/{slug}.md` | Yes — short scenarios can be chat |
| `/ship commit/pr/deploy` | (no doc — git/CI does the work) | N/A — output is a status line |
| `/intake` | `config/sources/{name}.md` or notes | Yes — short intake summaries can be chat |
| `/save` | `sessions/{date}.md` | N/A — always file |
| `/resume` | (reads file, outputs briefing) | Yes — briefing is always inline |
| `/gos aside` | (always inline by definition) | Always |
| `/gos` (conductor) | depends on the orchestrated verb | Mixed |
| `/evolve audit` | `memory/evolve_audit_{date}.md` | Rarely — audits persist |

## Resisting /think for routing-only decisions

`/think` is for genuine cognitive work — novelty, multi-source synthesis, ≥3 viable options, persistence need. Routing (file vs inline) is a binary format choice, not /think material. The conductor (`/gos`) refuses to spawn `/think` when the user's question is single-source factual, status-check, or already has an obvious answer in the user's recent context. See [commands/gos.md](../../commands/gos.md) Phase 2.5 for the trigger heuristic.

## How commands reference this rule

Each command file adds one line near the top of its substantive section:

```markdown
**Output routing** — see [rules/common/output-routing.md](../rules/common/output-routing.md). Default: {inline | file | per-sub-command}. Override: `--inline` / `--file` / `--file=<path>`.
```

The line declares the verb's default and points here for the heuristic + flag spec.

## Anti-patterns

- **Verb hardcodes a file path Gary then has to `rm`.** Always check the heuristic first; the verb's default is a starting point, not a contract.
- **Auto-default wrong twice in a row on the same task class.** If the heuristic mis-routes the same shape twice, the heuristic is wrong — file an evolve signal naming the task class and the right default.
- **`--inline` flag ignored, output written to file anyway.** Bug. Every verb must honor flags.
- **Routing decision not printed.** The one-line print is non-negotiable; without it the heuristic isn't legible and can't be improved.
