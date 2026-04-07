# Artifact Schema — Typed Outputs with Pipe Resolution

> Referenced by all gOS commands. Enables automatic flow of outputs between commands.

## Artifact Header (YAML frontmatter)

Every gOS output file includes this header:

```yaml
---
artifact_type: research-brief | design-spec | decision | verdict | simulation | build-plan | code-scaffold | hiring-brief | gtm-strategy | financial-model | compliance-report | content-draft
created_by: /think research | /design full | /review code | etc.
created_at: 2026-03-23T15:00:00+08:00
topic: copy-trading-leaderboard
related_specs:
  - specs/Arx_4-1-1-6.md
  - specs/Arx_3-2.md
quality_score:
  completeness: 4
  evidence: 5
  actionability: 3
  accuracy: 4
  clarity: 5
supersedes: null  # path to earlier artifact this replaces
status: draft | reviewed | promoted | archived
---
```

## Artifact Type Enum

| Type | Produced By | Contains |
|------|-----------|----------|
| `research-brief` | `/think research`, `/think intake` | Findings, sources, implications |
| `design-spec` | `/design full`, `/design quick` | Visual specs, component definitions |
| `decision` | `/think decide` | Options analysis, recommendation |
| `verdict` | `/review code/test/gate/council` | APPROVE/CONCERN/BLOCK with findings |
| `simulation` | `/simulate market/scenario/backtest` | Scenarios, projections, forecasts |
| `build-plan` | `/build plan` | Implementation steps, file list |
| `code-scaffold` | `/design render`, `/build component` | Code files, component structure |
| `hiring-brief` | `/think hire` | Role definition, rubric, interview plan |
| `gtm-strategy` | `/think gtm` | Market sizing, positioning, launch plan |
| `financial-model` | `/think finance`, `/build model` | Projections, unit economics |
| `compliance-report` | `/review compliance`, `/think legal` | Checklist, gaps, risk assessment |
| `content-draft` | `/build content` | Blog post, JD, proposal, deck |

## Pipe Resolution Algorithm

When a command starts execution (after Intent Gate + Context Protocol), check for upstream artifacts:

```
1. Parse WHAT from resolved intent (e.g., "copy trading leaderboard")
2. Search outputs/ recursively for files with YAML frontmatter
3. Match by topic field (fuzzy match — "copy trading" matches "copy-trading-leaderboard")
4. Filter by artifact_type relevance to current command:

   /think   looks for: (any — thinks from scratch, but loads prior thinking if exists)
   /design  looks for: research-brief, decision
   /build   looks for: research-brief, design-spec, decision, build-plan
   /review  looks for: code-scaffold, build-plan, design-spec
   /simulate looks for: research-brief, financial-model, decision
   /ship    looks for: verdict (MUST be APPROVE status)
   /evolve  looks for: verdict, decision

5. Sort by created_at descending (newest first)
6. If found: present list and auto-load as context
   "📎 Upstream artifacts found for '{topic}':"
   "  - research-brief from /think research (Mar 22) — loading"
   "  - design-spec from /design full (Mar 23) — loading"
7. If not found: proceed without (upstream is optional except for blocking rules)
```

## Downstream Blocking Rules

Some commands REQUIRE upstream artifacts:

| Command | Requires | Error If Missing |
|---------|----------|-----------------|
| `/ship deploy` | verdict with status=APPROVE | "Deploy blocked — no passing `/review gate` verdict found. Run `/review gate` first." |
| `/ship pr` | verdict with status=APPROVE or CONCERN | "PR blocked — no review verdict found. Run `/review code` first." |
| `/design render` | design-spec | "Render needs a design spec. Run `/design full` or `/design quick` first." |

All other commands: upstream artifacts are recommended but not required.

## Artifact Index

Maintained at `outputs/ARTIFACT_INDEX.md`. Auto-updated whenever a command writes an output.

### Update Protocol

After writing any output file with an artifact header:
1. Read `outputs/ARTIFACT_INDEX.md`
2. Add or update the entry for this artifact
3. If the artifact supersedes another, mark the old one as `archived`
4. Write the updated index

### Index Format

```markdown
# Artifact Index

| Topic | Type | Created By | Date | Status | Path |
|-------|------|-----------|------|--------|------|
```
