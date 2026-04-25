# Handoff Schemas — Inter-Command Artifact Protocol

Each gOS command outputs a typed JSON artifact that the next command in the phase chain reads. Artifacts live in `sessions/handoffs/`.

**Doc-type gate (doc-type ordering rule in `rules/common/output-discipline.md`).** Before a command writes its handoff JSON, it MUST validate the upstream artifact's frontmatter and H2 ordering by calling:

```bash
bash tools/validate-doc-type.sh <artifact-path> <expected-doc-type>
# exit 0 → write handoff
# exit 2 → refuse handoff, surface the failure to Gary, loop back to /refine or direct edit
```

This prevents downstream verbs (/design, /build) from consuming mis-shaped upstream output — the thing Gary named as "outputs aren't great product specs articulating why/what/how." Missing frontmatter, wrong doc-type, missing `audience:` / `reader-output:` fields, or H2 drift all fail the gate.

## Phase Chain

```
/think → /design → /build
```

`/review`, `/ship`, `/evolve`, `/simulate` — not gated, can run anytime.

## Handoff Artifacts

### think.json — Output of /think

Written when Gary approves a /think output (spec, research, decision).

```json
{
  "phase": "think",
  "sub": "research|decide|spec|discover",
  "output": "path/to/artifact.md",
  "doc_type": "research-memo|decision-record|discovery|product-spec|design-spec|strategy",
  "summary": "One-line summary of what was decided/discovered",
  "primitives": {
    "invariants_declared": ["<hard constraint 1>", "<hard constraint 2>"],
    "decisive_signals": ["<falsifier that would flip the call>"],
    "rule_form": "maximise <objective> subject to <invariants>",
    "boundary": {
      "in": "<what this output covers>",
      "out": "<adjacent handled elsewhere>",
      "never": "<what it refuses and why>"
    }
  },
  "approved": true,
  "approved_at": "ISO-8601 timestamp"
}
```

**`doc_type`** is required. Must match the artifact's frontmatter doc-type. `validate-doc-type.sh` verifies this before the handoff is written.

**`primitives`** is required for sub-commands that produce a decision or spec (`decide`, `spec`); optional for `research` and `discover`. Downstream verbs (/design, /build) read the typed primitive payload instead of re-parsing the prose — this kills the "prose re-interpretation" failure mode where /design reads the same spec differently than /think wrote it.

- **`invariants_declared`** — array of hard constraints the downstream work must preserve. /design and /build refuse to violate these without a re-approval.
- **`decisive_signals`** — array of named falsifiers. If any fires during downstream work, pause and re-open the decision instead of proceeding.
- **`rule_form`** — the FP-OS rule-form primitive rule in `maximise X subject to Y` form. Downstream selection among alternatives MUST use this same rule.
- **`boundary`** — IN / OUT / NEVER contract. /design cannot expand scope without a re-approval cycle.

Sub-commands that don't require primitives write `"primitives": null` — explicit, not omitted, so the schema field is always present.

### design.json — Output of /design

Written when Gary approves a /design output (build card, UI spec, system design).

```json
{
  "phase": "design",
  "sub": "card|ui|system",
  "output": "path/to/artifact.md",
  "summary": "One-line summary of what was designed",
  "visual_ref": "path/to/screenshot-or-figma-url (optional)",
  "approved": true,
  "approved_at": "ISO-8601 timestamp"
}
```

### refine.json — Spawned by /refine (job-scoped, not in sessions/)

Written when /refine identifies a CRITICAL/HIGH gap requiring external `/think` work. Lives at `outputs/refine/{slug}/cycle-N/pending-think.json` — **job-scoped**, NOT in `sessions/handoffs/`. Refine can spawn N parallel asks per cycle; each is its own file.

```json
{
  "phase": "refine",
  "spawned_for": "research|decide|spec|discover",
  "gap_question": "<the question /think should answer — must be self-contained>",
  "acceptance_signal": "<what evidence/decision would close this gap>",
  "resolver_type": "research|decide|spec|discover",
  "return_to": {
    "refine_job": "outputs/refine/{slug}/",
    "cycle": <N>,
    "draft_section": "<which section of the draft this informs>"
  },
  "deposit_result_at": "outputs/refine/{slug}/external/think-{slug}.md",
  "wake_signal_at": "outputs/refine/{slug}/external/.ready",
  "spawned_at": "ISO-8601 timestamp"
}
```

**`gap_question`** must be self-contained — the spawned /think runs in fresh context and cannot read the refine job's draft. Writer must extract enough context for /think to act independently.

**`acceptance_signal`** is what closes the gap (e.g., "competitor adoption count with source", "verdict between option A vs B with rationale"). Used by `evidence-merger` to verify the returned /think output actually addresses the question.

**`deposit_result_at` and `wake_signal_at`** are the contract: /think writes its result to the deposit path AND touches the wake-signal file. Refine's cycle state machine watches the wake-signal to transition `waiting-on-X` → `running`.

### build.json — Output of /build (optional, for /review context)

Written after /build completes. Not a gate input — /review doesn't require it.

```json
{
  "phase": "build",
  "sub": "feature|fix|refactor|prototype",
  "output": ["path/to/file1", "path/to/file2"],
  "summary": "One-line summary of what was built",
  "tests": "pass|fail|none",
  "approved_at": "ISO-8601 timestamp"
}
```

## Writing Handoffs

Commands write their handoff after Gary approves the output AND the doc-type gate passes:

```bash
# In command logic (think, design, build):
EXPECTED_TYPE="<doc-type per sub-command>"  # see per-command doc-type contract
if ! bash tools/validate-doc-type.sh "<path>" "$EXPECTED_TYPE"; then
  echo "Handoff refused — fix frontmatter or H2 ordering, then re-approve." >&2
  exit 2
fi

mkdir -p sessions/handoffs
cat > sessions/handoffs/<phase>.json << EOF
{
  "phase": "<phase>",
  "sub": "<sub>",
  "output": "<path>",
  "doc_type": "$EXPECTED_TYPE",
  "summary": "<summary>",
  "approved": true,
  "approved_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
```

## Clearing Handoffs

`/gos` conductor clears handoffs at the start of a new goal:
```bash
rm -f sessions/handoffs/*.json
```

This ensures each goal goes through the full phase chain fresh.

## /gos status — Coverage View

`/gos status` reads handoffs to show phase completion:

```
Pipeline: /think [done] → /design [done] → /build [pending]
  think:  research — "Bitget wallet model analysis" (2026-04-09)
  design: card — "Radar Leaders S0-S4 build card" (2026-04-09)
  build:  (not started)
```
