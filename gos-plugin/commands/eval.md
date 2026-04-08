---
description: "Eval — measure gOS command quality against rubrics with synthetic inputs"
---

# Eval — Command Quality Measurement

Eval runs gOS commands against synthetic test inputs, scores output against rubrics, and compares to baselines. This is how you know if gOS commands are getting better or worse over time.

Parse the first word of `$ARGUMENTS` to route:

| Argument | Action |
|----------|--------|
| `<command-name>` | Run and score (e.g., `eval think-research`) |
| `create <command-name>` | Create a new test input interactively |
| `baseline <command-name>` | Set current results as baseline |
| `report` | Show all commands' eval scores and trends |
| `compare <command-name>` | Compare latest run to baseline |

---

## Running an Eval: `/eval <command-name> [--runs N]`

Default N=1. Maximum N=5 (cost guard).

### Step 1: Load Test Input

Read `~/.claude/evals/test-inputs/{command-name}-input.md`. If not found, offer to create one via `/eval create`.

### Step 2: Load Rubric

Read `~/.claude/evals/rubrics/{command-name}.md`. Extract dimensions, weights, and scoring criteria.

### Step 3: Execute Runs

For each run (1 to N):

1. **Spawn executor agent** with fresh context:
   ```
   Agent(
     prompt = "Execute this task and produce output. Do NOT score yourself.
               Task: {test-input content}
               Command context: {load the relevant command .md file}
               Produce your output as if this were a real task from the user.",
     subagent_type = "general-purpose",
     model = "sonnet",  # use sonnet for cost efficiency on evals
     run_in_background = true
   )
   ```

2. **Capture output** when agent completes.

3. **Spawn scoring agent** (separate from executor — no self-grading):
   ```
   Agent(
     prompt = "You are a strict quality scorer. Score the following output against the rubric.

     ## Rubric
     {rubric content}

     ## Output to Score
     {executor's output}

     ## Scoring Rules
     - Be strict. 5 = adequate. 7 = good. 9 = exceptional. 10 = almost never.
     - For each dimension, provide:
       1. Score (1-10)
       2. One-line justification
     - Calculate weighted overall score.

     ## Output Format (respond ONLY with this JSON)
     ```json
     {
       \"dimensions\": [
         { \"name\": \"Completeness\", \"score\": 8, \"weight\": 25, \"justification\": \"Covered all aspects but missed regulatory nuance\" }
       ],
       \"overall\": 7.6,
       \"token_estimate\": 45000,
       \"notes\": \"Strong on sources, weak on synthesis\"
     }
     ```",
     subagent_type = "general-purpose",
     model = "sonnet"
   )
   ```

4. **Save results** to `~/.claude/evals/results/{command-name}/{date}-run{N}.json`:
   ```json
   {
     "command": "think-research",
     "date": "2026-03-22",
     "run": 1,
     "scores": { /* from scoring agent */ },
     "baseline_comparison": null,
     "model_used": "sonnet"
   }
   ```

### Step 4: Compare to Baseline

Read `~/.claude/evals/baselines/{command-name}/latest.json` if it exists.

For each dimension:
- Delta = current score - baseline score
- If delta > +0.5: IMPROVED
- If delta < -0.5: REGRESSED
- Otherwise: STABLE

### Step 5: Report

```
Eval: /think research (3 runs)
─────────────────────────────────────
           Run 1   Run 2   Run 3   Avg    Baseline   Δ        Status
Complete    8       9       7      8.0      7.5     +0.5      IMPROVED
Accurate    7       8       8      7.7      7.0     +0.7      IMPROVED
Sources     9       8       9      8.7      8.0     +0.7      IMPROVED
Synthesis   6       7       6      6.3      6.0     +0.3      STABLE
Actionable  7       8       7      7.3      7.0     +0.3      STABLE

Overall: 7.6/10 (baseline: 7.1) → IMPROVED
Variance: 0.8 (acceptable if <1.5)
Est. cost: ~$0.32/run × 3 = $0.96
```

If any dimension REGRESSED: flag with explanation and suggest `/evolve upgrade {command}`.

---

## Creating Test Inputs: `/eval create <command-name>`

Interactive flow:

1. Ask: "What should this command be tested with? Describe the synthetic task."
2. Generate a test input file based on the description
3. For review commands: offer to generate code with planted bugs
4. Save to `~/.claude/evals/test-inputs/{command-name}-input.md`
5. Offer: "Run the first eval now to establish a baseline?"

---

## Setting Baseline: `/eval baseline <command-name>`

1. Read the most recent results from `~/.claude/evals/results/{command-name}/`
2. If multiple runs exist, use the average scores
3. Copy to `~/.claude/evals/baselines/{command-name}/latest.json`
4. Report: "Baseline set for `{command-name}`: overall {score}/10. Future evals will compare against this."

---

## Full Report: `/eval report`

Read all baselines and recent results. Display:

```
gOS Eval Report
═══════════════════════════════════════════════
Command          Baseline   Latest   Δ       Status      Last Eval
think-research     7.1       7.6    +0.5     IMPROVED    2 days ago
think-discover     —         —       —       NO BASELINE  never
review-code        8.2       7.9    -0.3     STABLE      1 day ago
build-feature      —         —       —       NO BASELINE  never
design-quick       6.8       7.4    +0.6     IMPROVED    3 days ago

Commands without evals: think-decide, think-spec, build-prototype, review-test
Recommendation: Run /eval think-decide to establish baseline
```

---

## Comparing: `/eval compare <command-name>`

1. Read baseline and latest results
2. Show dimension-by-dimension comparison
3. Highlight regressions
4. If regressed: "Consider running `/evolve upgrade {command}` to address {weakest dimension}"

---

## Integration with /evolve

`/evolve audit` should read eval results alongside accept/rework/reject signals:

```
Command Health: /think research
  Signals: 8 accepts, 2 reworks, 0 rejects (signal score: 80%)
  Eval: 7.6/10 (baseline: 7.1, IMPROVED)
  Weakest dimension: Synthesis (6.3/10)
  Recommendation: Focus /evolve upgrade on synthesis quality
```

---

## Cost Guards

- Default 1 run (cheapest)
- Maximum 5 runs per eval
- Use sonnet model for eval runs (not opus) — 3x cheaper
- Scoring agent uses sonnet
- Estimated cost: ~$0.30-0.50 per run (executor + scorer)
- `/eval report` is free (reads cached results)

---

## Available Test Inputs

Pre-built test inputs (in `~/.claude/evals/test-inputs/`):
- `think-research-input.md` — AI trading terminals for retail crypto
- `review-code-input.md` — TypeScript API handler with 3 planted bugs
- `design-quick-input.md` — Copy trading leaderboard screen
