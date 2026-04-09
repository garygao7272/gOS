# Handoff Schemas — Inter-Command Artifact Protocol

Each gOS command outputs a typed JSON artifact that the next command in the phase chain reads. Artifacts live in `sessions/handoffs/`.

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
  "summary": "One-line summary of what was decided/discovered",
  "approved": true,
  "approved_at": "ISO-8601 timestamp"
}
```

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

Commands write their handoff after Gary approves the output:

```bash
# In command logic (think, design, build):
mkdir -p sessions/handoffs
cat > sessions/handoffs/<phase>.json << EOF
{ "phase": "<phase>", "sub": "<sub>", "output": "<path>", "summary": "<summary>", "approved": true, "approved_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)" }
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
