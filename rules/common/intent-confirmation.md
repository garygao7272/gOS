# Intent Confirmation

Every gOS verb (`/think`, `/design`, `/build`, `/review`, `/simulate`, `/ship`, `/refine`) confirms intent in one line before executing the substantive work.

**Currently wired** (each command file has a reference line): `/build`, `/design`, `/review`, `/simulate`, `/think`. **Not yet wired** (by intent — the verbs below handle their own intent-confirmation differently): `/ship` (confirms per-sub-command inline), `/refine` (has its own PLAN section). When adding a reference line to a new command, mirror the pattern from `commands/build.md`.

## The rule

Before planning or executing, restate the scope in one line using the verb's template below. Wait for confirmation.

**Skip only when:**
- Gary's input is already precise — it names a specific file, spec ID, sub-command, or parameter set that leaves no ambiguity.
- Gary said `"just do it"` / `"skip plan"` / `"no plan"` (explicit bypass).

## Per-verb templates

| Verb | Template |
|---|---|
| `/think` | "I'll [sub-command] [topic], covering [scope]. Proceed?" |
| `/design` | "I'll [sub-command] for [target], using [key constraints]. Proceed?" |
| `/build` | "I'll [sub-command] [target] based on [spec/handoff]. Proceed?" |
| `/review` | "I'll review [target] as [sub-command], covering [files/scope]. Proceed?" |
| `/simulate` | "I'll simulate [type] for [target], parameters: [key params]. Proceed?" |
| `/ship` | "I'll ship [what] to [where]. Proceed?" |
| `/refine` | "I'll refine [topic] for [N] iterations against [criteria]. Proceed?" |

## Why this rule exists

Intent confirmation is the cheapest failure-mode catch gOS has. One line costs Gary nothing to read; it prevents the rest of the verb from executing against a misread prompt. Every verb therefore applies the same pattern — the template varies per verb only because the shape of the work varies.

## How commands reference this rule

Each command file keeps its per-verb template inline (it's the single action Claude takes) but points here for the rule's rationale and skip conditions.

**Illustrative only** — the example below uses `/build`'s specific template. When adding a reference line to a new command, copy the verb's row from the "Per-verb templates" table above, do not copy the bracketed placeholders verbatim:

```markdown
**Intent confirmation** — see [rules/common/intent-confirmation.md](../rules/common/intent-confirmation.md). Template: "I'll [sub-command] [target] based on [spec/handoff]. Proceed?"
```
