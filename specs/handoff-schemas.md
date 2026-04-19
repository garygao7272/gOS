# Handoff Schemas — Inter-Command Artifact Protocol

Each gOS command outputs a typed JSON artifact that the next command in the phase chain reads. Artifacts live in `sessions/handoffs/`.

**Doc-type gate (§6.8 of `rules/common/output-discipline.md`).** Before a command writes its handoff JSON, it MUST validate the upstream artifact's frontmatter and H2 ordering by calling:

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
  "approved": true,
  "approved_at": "ISO-8601 timestamp"
}
```

`doc_type` is required. Must match the artifact's frontmatter doc-type. `validate-doc-type.sh` verifies this before the handoff is written.

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
