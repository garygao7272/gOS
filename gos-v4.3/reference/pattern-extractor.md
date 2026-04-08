# Pattern Extractor — Active Learning from Signal Clusters

> Runs automatically at `/gos save` (Part B of the Learning Loop).
> Scans evolve_signals.md for clusters and extracts reusable patterns.

## When to Run

- At `/gos save` — full scan of session signals
- At `/evolve learn` — deep scan of all accumulated signals
- When 5+ signals have accumulated without extraction

## Extraction Algorithm

### Step 1: Cluster Detection

Read `sessions/evolve_signals.md`. Group signals by:

1. **Command cluster** — same command getting reworked repeatedly
   - e.g., `/think research` → rework 3x in last 5 sessions
   - Pattern: "Gary wants research structured differently"

2. **Dimension cluster** — same Output Contract dimension scoring low
   - e.g., Actionability ≤ 3 on 4 out of 5 outputs
   - Pattern: "Outputs need more specific next steps with owners"

3. **Topic cluster** — same topic triggering different signals across commands
   - e.g., "copy trading" → accept on /think, rework on /design, reject on /build
   - Pattern: "Copy trading design needs more iteration before building"

4. **Temporal cluster** — signals changing over time for a domain
   - e.g., code-review was T0, now getting consistent accepts
   - Pattern: "Ready for trust promotion in code-review domain"

### Step 2: Pattern Classification

For each detected cluster:

| Type | Action | Destination |
|------|--------|------------|
| **Approach preference** | Save as feedback memory | `memory/feedback_*.md` |
| **Command weakness** | Update command file | `gOS/.claude/commands/{cmd}.md` |
| **Domain knowledge** | Save as project memory | `memory/project_*.md` |
| **Self-model update** | Update self-model | `gOS/.claude/self-model.md` |

### Step 3: Auto-Apply

- Feedback patterns → write to memory immediately
- Command weaknesses → draft proposed update, present to Gary for approval
- Trust promotions → update `sessions/trust.json` (if rules met)
- Self-model → update competence scores

## Anti-Noise Rules

- Ignore clusters with < 3 signals (insufficient evidence)
- Don't extract from a single session (may be context-specific)
- Don't overfit to recent signals (weight last 10 sessions, not just last 1)
- If a pattern contradicts a previous pattern, present both and ask Gary
