---
effort: high
description: "Think mode: discover, research, decide, spec, intake — outputs to outputs/think/, promotes to specs/"
---

# Think Mode — Product + Strategy -> outputs/think/ -> specs/

**Think outputs go to `outputs/think/` first (staging), then promote to `specs/` if worthy.**

The separation matters: `outputs/think/` is the workshop. `specs/` is the showroom. Only conclusions worth building on get promoted.

**Output routing:**

| Sub-command | Output To | Then |
|-------------|-----------|------|
| `discover` | `outputs/think/discover/{topic}.md` | "Promote to `specs/Arx_3-X`?" |
| `research` | `outputs/think/research/{topic}.md` | "Promote to `specs/Arx_2-X`?" |
| `decide` | `outputs/think/decide/{topic}.md` | "Append to `specs/Arx_9-1_Decision_Log.md`?" |
| `spec` | **Direct to `specs/`** | No staging |
| `intake` | `outputs/think/research/{slug}-intake.md` | Absorb, scan, or manage sources |

**Plan mode by default.** Present approach and wait for approval before executing.

**Swarm execution by default.** Once approved, spawn 3-5 parallel Agent workers with sub-command-specific roles. Each produces an independent artifact with zero file conflicts. Cross-examine contradictions before synthesizing.

**Scratchpad checkpoints:** On entry, after plan approval, after each agent completes, after synthesis, on dead end, after compaction.

Parse the first word of `$ARGUMENTS`. If none given, ask: "What kind of thinking? discover, research, decide, or spec?"

---

## discover <seed idea>

**Purpose:** Take a raw seed idea and produce a validated product concept.

**Input:** 1-2 sentence seed idea

**Process:** Spawn 3 parallel agents for adversarial validation. **All 3 launch in a single message:**

```
Agent(
  prompt = "You are pm-researcher. Analyze: '{seed}'.
            WHO has this pain, HOW BADLY, WHAT they do today.
            Output: JTBD analysis, positioning, customer interview questions.
            Read specs/Arx_2-1* for existing persona context.",
  subagent_type = "general-purpose",
  model = "sonnet",
  run_in_background = true
)

Agent(
  prompt = "You are first-principles analyst. Decompose '{seed}' to atomic assumptions.
            Challenge each assumption. Generate 5 alternative framings.
            Read specs/ for existing Arx context.",
  subagent_type = "general-purpose",
  model = "opus",
  run_in_background = true
)

Agent(
  prompt = "You are market-analyst. Research '{seed}'.
            Search for: market size, adoption rates, failed attempts,
            adjacent solutions in non-crypto markets.
            Use WebSearch for current data. Every claim needs a source.",
  subagent_type = "general-purpose",
  model = "sonnet",
  run_in_background = true
)
```

**Cross-examination:** After all 3 report, challenge findings across agents — "Agent 1 found JTBD X. Agent 2, is that the real job or a surface symptom?"

**Synthesis:** Validated user pain + first-principles framing + market evidence. Resolve contradictions — note disagreements and your recommendation.

**Exit Gate:** "What specific pain from `specs/Arx_2-1` does this solve? If new, add it."

**Output:** `outputs/think/discover/{seed_slug}.md`. Suggest promotion to `specs/Arx_3-X`.

---

## research <question>

> **Includes UX research** (absorbed from former `/design research`). All research — market, competitor, user, AND UX — lives here.

**Purpose:** Deep research grounded in evidence.

**Before researching solutions, audit what's already installed.** Check settings.json, SETUP.md, installed MCP servers. Frame recommendations as "build on top of X" not "replace with Y". (Instinct: audit-existing-tools)

**Process:** Spawn 3 parallel agents. **All 3 launch in a single message:**

```
Agent(
  prompt = "You are deep-researcher. Research '{question}'.
            Find: academic papers, industry reports, expert analyses.
            Focus on data and numbers. Every claim sourced.
            Use WebSearch extensively.",
  subagent_type = "general-purpose",
  model = "sonnet",
  run_in_background = true
)

Agent(
  prompt = "You are competitor-crawler. Research '{question}'.
            Crawl 3-5 competitor products: features, pricing, UX patterns, reviews.
            Use WebSearch + WebFetch for product pages.",
  subagent_type = "general-purpose",
  model = "sonnet",
  run_in_background = true
)

Agent(
  prompt = "You are cross-referencer. Research '{question}'.
            Cross-reference findings with specs/Arx_2-3_Competitive_Landscape.md.
            Read the spec, identify gaps or contradictions with current landscape.",
  subagent_type = "general-purpose",
  model = "haiku",
  run_in_background = true
)
```

If disputed claims: route fact-checks between agents after initial reports.

**Synthesis:** Key findings (numbered, sourced) → data points → competitive table → Arx implications → open questions.

**Output:** `outputs/think/research/{question_slug}.md`. Suggest promotion or spec update.

---

## decide <question>

**Purpose:** Multi-perspective decision analysis.

**Input:** Decision question (e.g., "should copy trading show full P&L transparency?")

**Process:** Spawn 5 parallel agents (Six Thinking Hats), then 1 adjudicator. **First 5 launch in a single message:**

```
Agent(
  prompt = "You are white-hat analyst. Question: '{question}'.
            Provide ONLY data and benchmarks. Check specs/Arx_9-1_Decision_Log.md
            for prior decisions. Numbers, facts, evidence only.",
  subagent_type = "general-purpose", model = "sonnet", run_in_background = true
)

Agent(
  prompt = "You are red-hat analyst. Question: '{question}'.
            Intuition pass. What would users FEEL? Gut reactions from
            S7-Sarah (cautious), S2-Jake (efficiency), S1-Alex (excitement).
            Read specs/Arx_2-1* for persona context.",
  subagent_type = "general-purpose", model = "sonnet", run_in_background = true
)

Agent(
  prompt = "You are black-hat analyst. Question: '{question}'.
            Risks ONLY. Research failures of similar decisions.
            Use WebSearch for case studies. What goes wrong and why.",
  subagent_type = "general-purpose", model = "sonnet", run_in_background = true
)

Agent(
  prompt = "You are yellow-hat analyst. Question: '{question}'.
            Best case ONLY. What opportunities does this create?
            Second-order benefits. Strategic upside.",
  subagent_type = "general-purpose", model = "sonnet", run_in_background = true
)

Agent(
  prompt = "You are green-hat analyst. Question: '{question}'.
            Alternatives ONLY. Generate 3-5 options no one considered.
            Lateral thinking. Reframe the question itself.",
  subagent_type = "general-purpose", model = "sonnet", run_in_background = true
)
```

**After all 5 report,** the lead (opus) cross-examines disagreements and synthesizes recommendation with confidence (HIGH/MEDIUM/LOW).

**Output:** `outputs/think/decide/{question_slug}.md`. Include: question, context, options, six-hat analysis, decision + rationale, confidence, review date. Suggest appending to Decision Log.

---

## spec <topic>

> **Strategy specs only.** Build cards are authored via `/design card`.

**Purpose:** Write or update a strategy spec from upstream thinking.

**Input:** Topic or spec file (e.g., "update personas in Arx_2-1")

**Process:**

1. Read `specs/Arx_0-0_Artifact_Architecture.md` for naming/altitude rules
2. Read `specs/INDEX.md` for inventory
3. If updating: read existing spec. If creating: determine artifact ID + altitude.
4. Write following altitude convention. Cascade rule: changes flow downward only.
5. Single source of truth: link, don't duplicate.

**Output:** New or updated spec in `specs/`. Update `specs/INDEX.md` if new.

---

## intake <url | scan <topic> | sources <action>>

**Purpose:** Absorb content, scan topics, manage the source watchlist. Invokes the `intake` skill.

**Config:** `~/.claude/config/intake-sources.md` — global watchlist.

- **`intake <url>`** — Absorb: extract transcript/content, clean filler, restructure into MECE knowledge doc
- **`intake scan <topic> [--period <timeframe>]`** — Multi-source search for material movements (default: 7 days)
- **`intake sources list|add|remove|check`** — Manage watchlist

When invoked, load the full `intake` skill via `Skill("intake")`.

---

## Think Convergence Loop (applies to discover, research, decide)

Multi-step think sub-commands run a convergence check before finalizing:

1. **After synthesis:** Cross-examine agent outputs for contradictions
2. **If contradictions found:** Route disputed claims between agents for resolution. Spawn a fact-checker if needed.
3. **If resolution changes the conclusion:** Re-synthesize with corrected facts.
4. **Max 3 cross-examination rounds** before presenting with flagged disagreements.

This ensures think outputs are internally consistent before Gary sees them.
