---
effort: high
description: "Think mode: discover, research, decide, spec, intake — outputs to outputs/think/, promotes to specs/"
---

# Think Mode — Product + Strategy -> outputs/think/ -> specs/

**Think outputs go to `outputs/think/` first (staging), then promote to `specs/` if worthy.**

The separation matters: `outputs/think/` is the workshop. `specs/` is the showroom. Not every piece of thinking deserves to become a canonical spec. Think produces working documents — research briefs, brainstorms, decision analyses. Only the conclusions worth building on get promoted to `specs/`.

**Output routing by sub-command:**

| Sub-command | Output To                                 | Then                                                    |
| ----------- | ----------------------------------------- | ------------------------------------------------------- |
| `discover`  | `outputs/think/discover/{topic}.md`       | Suggest: "Promote to `specs/Arx_3-X` as product brief?" |
| `research`  | `outputs/think/research/{topic}.md`       | Suggest: "Promote to `specs/Arx_2-X` as market intel?"  |
| `decide`    | `outputs/think/decide/{topic}.md`         | Suggest: "Append to `specs/Arx_9-1_Decision_Log.md`?"   |
| `spec`      | **Direct to `specs/`**                    | No staging — `spec` IS the promotion step               |
| `intake`    | `outputs/think/research/{slug}-intake.md` | Absorb, scan, or manage sources                         |

**Promotion flow:**

1. Think writes to `outputs/think/{sub-command}/{topic}.md`
2. At the end, Think recommends: "This should be promoted to `specs/Arx_X-X_{Slug}.md`" with the suggested artifact ID and altitude
3. User approves -> file moves to `specs/`, INDEX.md updated
4. User declines -> file stays in `outputs/think/` as reference material

**Plan mode by default.** Think mode always presents a plan for approval before executing. The whole point of Think is to align on _what_ before _how_. Use `EnterPlanMode` at the start of every Think sub-command, present the approach, and wait for approval before launching agents.

**Swarm execution by default.** Once the plan is approved, Think mode uses parallel agents (3-5) on every sub-command. This works because Think outputs are specs and documents — each agent produces an independent artifact with zero file conflicts. The synthesis step is where the human value lives: comparing perspectives, resolving contradictions, picking the bolder choice.

**Scratchpad checkpoints.** Update `sessions/scratchpad.md` at these moments:

- **On entry:** Write current task, mode (`Think > {sub-command}`), and input to `Current Task` and `Mode & Sub-command`
- **After plan approval:** Write the approved plan summary to `Working State`
- **After each agent completes:** Log agent name + key finding to `Agents Launched`
- **After synthesis:** Write key decisions to `Key Decisions Made This Session`
- **On dead end:** Append to `Dead Ends (don't retry)`
- **After compaction (if you notice lost context):** Re-read `sessions/scratchpad.md` to restore state

Parse the first word of `$ARGUMENTS` to determine sub-command. If no sub-command given, ask: "What kind of thinking? discover, research, decide, or spec?"

---

## discover <seed idea>

**Purpose:** Take a raw seed idea and produce a validated product concept with clear scope.

**Input:** 1-2 sentence seed idea (e.g., "copy trading that shows leader's reasoning, not just their trades")

**Team Mode (always for discover — adversarial validation is the core value):**

```
TeamCreate(team_name="think-discover-{slug}")
```

Launch 3 named teammates:

1. **`pm-researcher` (sonnet):** Use the Product-Manager-Skills plugin. Run the /discover workflow — JTBD analysis, positioning, customer interview questions. Focus on: WHO has this pain, HOW BADLY, and WHAT they do today.

2. **`first-principles` (opus):** Use anthropic-skills:first-principles-decomposition + anthropic-skills:brainstorming-ideation. Decompose the seed to atomic assumptions. Challenge each. Generate 5 alternative framings of the same problem.

3. **`market-analyst` (sonnet):** If MAS Sequential Thinking MCP is available, use it. Otherwise, simulate six perspectives with research:
   - Factual: What data exists? Search for market size, adoption rates.
   - Critical: Why would this fail? Search for failed attempts.
   - Creative: What adjacent solutions exist in non-crypto markets?
   - Optimistic: What's the maximum upside if this works perfectly?

**Adversarial cross-examination:** After all 3 teammates report, the lead routes challenges:

- `SendMessage(to="first-principles", message="pm-researcher found JTBD X. Challenge: is that the real job or a surface symptom?")`
- `SendMessage(to="market-analyst", message="first-principles decomposed to assumption Y. What evidence supports or refutes?")`

**Synthesis:** After cross-examination, synthesize:

- The validated user pain (from pm-researcher, pressure-tested by first-principles)
- The first-principles framing (from first-principles, grounded by market-analyst)
- The market evidence (from market-analyst, validated against JTBD)

**Shutdown:** `SendMessage(to="*", message={type: "shutdown_request"})` then `TeamDelete`

- Resolve any contradictions — if agents disagree, note the disagreement and your recommendation

**Exit Gate:** Before moving on, answer: "What specific pain from `specs/Arx_2-1_Problem_Space_and_Audience.md` does this solve? If it's a new pain, add it to that spec."

**Output:** Write product brief to `outputs/think/discover/{seed_slug}.md`. Then suggest: "Promote to `specs/Arx_3-X_{Slug}.md`?" with recommended artifact ID and altitude. Link to upstream pain in specs/Arx_2-1.

---

## research <question>

**Purpose:** Deep market, competitor, or user research grounded in evidence.

**Input:** Research question (e.g., "what do retail crypto traders actually want from copy trading?")

**Team decision:**

- If question involves disputed claims or multi-source validation: Create team `think-research-{slug}` with 3 teammates
- Otherwise: Use ad-hoc subagents (cheaper, no cross-examination needed)

**Swarm Pattern — Launch 3 agents (as named teammates if team mode, ad-hoc otherwise):**

1. **`deep-researcher` (sonnet):** Use Exa/Firecrawl deep research tools. Search for: academic papers, industry reports, expert analyses. Focus on data and numbers.

2. **`competitor-crawler` (sonnet):** Use Firecrawl to crawl 3-5 competitor products related to the question. Extract features, pricing, UX patterns, user reviews.

3. **`cross-referencer` (haiku):** Use everything-claude-code skills for structured research. Cross-reference with `specs/Arx_2-3_Competitive_Landscape.md` for existing analysis.

**If team mode:** After reports, lead routes fact-checks via `SendMessage` — e.g., "deep-researcher, competitor-crawler found claim X. Verify with primary sources."

**Synthesis:** Produce a research brief with:

- Key findings (numbered, with sources)
- Data points (quantified where possible)
- Competitive comparison table
- Implications for Arx (specific, actionable)
- Open questions for further research

**Output:** Write research brief to `outputs/think/research/{question_slug}.md`. Then suggest: "Promote to `specs/Arx_2-X_{Slug}.md`?" or "Update existing `specs/Arx_2-X` with these findings?"

---

## decide <question>

**Purpose:** Make a product, design, or architectural decision with multi-perspective analysis.

**Input:** Decision question (e.g., "should copy trading show full P&L transparency or only summary stats?")

**Team Mode (always for decide — deliberation requires interaction):**

```
TeamCreate(team_name="think-decide-{slug}")
```

Launch 6 named teammates (all on `sonnet` except blue-hat on `opus`):

1. **`white-hat`:** What data do we have? Search for relevant benchmarks. Check existing specs for prior decisions.
2. **`red-hat`:** What does intuition say? What would users feel? What's the gut reaction?
3. **`black-hat`:** What could go wrong? What are the risks? Research failures of similar decisions.
4. **`yellow-hat`:** What's the best case? What opportunities does this create?
5. **`green-hat`:** Are there alternatives no one has considered? What would a completely different approach look like?
6. **`blue-hat` (opus):** Wait for all 5 hats to report via TaskUpdate. Then cross-examine disagreements via `SendMessage` — e.g., "black-hat, yellow-hat claims X upside. What's the specific failure mode?" Synthesize a recommendation with confidence level (HIGH/MEDIUM/LOW).

**Shutdown:** After blue-hat synthesis, shut down all teammates and `TeamDelete`.

**Output:** Write decision analysis to `outputs/think/decide/{question_slug}.md`. Then suggest: "Append this decision to `specs/Arx_9-1_Decision_Log.md`?" Include in the output:

- Decision question
- Context (what prompted this)
- Options considered
- Six Hats analysis (1 line per hat)
- Decision made + rationale
- Confidence level
- Review date (when to revisit)

---

## spec <topic>

**Purpose:** Write or update a spec file based on upstream thinking (discover, research, decide outputs).

**Input:** Topic or spec file to update (e.g., "write the copy trading spec" or "update specs/Arx_4-1-1-6")

**Process:**

1. Read `specs/Arx_0-0_Artifact_Architecture.md` for naming conventions and altitude rules
2. Read `specs/INDEX.md` for existing spec inventory
3. If updating: read the existing spec file first
4. If creating: determine the correct artifact ID and altitude
5. Write the spec following the altitude convention — higher altitude = more strategic, lower = more detailed
6. Use Context Mode if available to compress research into the writing session

**Rules:**

- Follow the naming convention: `Arx_{Group}-{Artifact}_{Slug}.md`
- No version numbers in filenames — use git history
- Cascade rule: changes flow downward only. If this spec change implies upstream changes, note them in `specs/Arx_9-5_Hypothesis_Question_Log.md`
- Single source of truth: link to other specs, don't duplicate content

**Output:** New or updated spec file in `specs/`. Update `specs/INDEX.md` if a new spec was created.

---

## intake <url | scan <topic> | sources <action>>

**Purpose:** Absorb content from URLs, scan topics for material movements, or manage the source watchlist. Invokes the `intake` skill.

**Config:** `~/.claude/config/intake-sources.md` — the global gOS watchlist of YouTube channels, X accounts, blogs, podcasts. Universal across all projects.

Parse the second word to route:

- **`intake <url>`** — Absorb mode. Extract transcript/content from YouTube, podcast, article, X thread. Clean filler words, keep timestamps, restructure into MECE knowledge document with first-principles explanations. Output: `outputs/think/research/{slug}-intake.md`

- **`intake scan <topic> [--period <timeframe>]`** — Scan mode. Multi-source search for material movements. 2-3 parallel agents: news, technical, sentiment. Default period: 7 days. Output: `outputs/think/research/{topic}-scan-{date}.md`

- **`intake sources list`** — Show current watchlist from `config/intake-sources.md`
- **`intake sources add <url> [--name <name>]`** — Add a source to the watchlist
- **`intake sources remove <name or url>`** — Remove a source
- **`intake sources check [--period <timeframe>]`** — Check all sources for new content. Recommend top 3 worth absorbing.

When invoked, load the full `intake` skill via `Skill("intake")` and follow its instructions.
