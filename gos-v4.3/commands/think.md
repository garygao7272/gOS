---
description: "Think mode: discover, research, decide, spec, intake, finance, fundraise, hire, gtm, legal — outputs to outputs/think/, promotes to specs/"
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
| `finance`   | `outputs/think/finance/{topic}.md`        | Suggest: "Promote to financial model or decision log?"   |
| `fundraise` | `outputs/think/fundraise/{topic}.md`      | Suggest: "Build pitch deck or investor materials?"       |
| `hire`      | `outputs/think/hire/{role}.md`            | Suggest: "Post JD or build interview playbook?"          |
| `gtm`       | `outputs/think/gtm/{topic}.md`           | Suggest: "Promote to GTM strategy spec?"                 |
| `legal`     | `outputs/think/legal/{topic}.md`          | Suggest: "Add to compliance checklist?"                  |

**Promotion flow:**

1. Think writes to `outputs/think/{sub-command}/{topic}.md`
2. At the end, Think recommends: "This should be promoted to `specs/Arx_X-X_{Slug}.md`" with the suggested artifact ID and altitude
3. User approves -> file moves to `specs/`, INDEX.md updated
4. User declines -> file stays in `outputs/think/` as reference material

**Intent Gate by default.** Think mode always runs the Intent Gate before executing. The whole point of Think is to align on _what_ before _how_. Restate, plan, then wait for confirmation before launching agents. See Intent Gate section below.

**Swarm execution by default.** Once the plan is approved, Think mode uses parallel agents (3-5) on every sub-command. This works because Think outputs are specs and documents — each agent produces an independent artifact with zero file conflicts. The synthesis step is where the human value lives: comparing perspectives, resolving contradictions, picking the bolder choice.

**Scratchpad checkpoints.** Update `sessions/scratchpad.md` at these moments:

- **On entry:** Write current task, mode (`Think > {sub-command}`), and input to `Current Task` and `Mode & Sub-command`
- **After plan approval:** Write the approved plan summary to `Working State`
- **After each agent completes:** Log agent name + key finding to `Agents Launched`
- **After synthesis:** Write key decisions to `Key Decisions Made This Session`
- **On dead end:** Append to `Dead Ends (don't retry)`
- **After compaction (if you notice lost context):** Re-read `sessions/scratchpad.md` to restore state

Parse the first word of `$ARGUMENTS` to determine sub-command. If no sub-command given, ask: "What kind of thinking? discover, research, decide, spec, intake, finance, fundraise, hire, gtm, or legal?"

---

## Intent Gate (mandatory — runs before any sub-command)

**First-Principles Decomposition.** Every request is broken into 6 MECE dimensions before execution.

### Step 1: DECOMPOSE

Parse Gary's request. Fill every dimension and classify:

| Dim | Question | ✅ Stated | 🔮 Inferred | ❌ Unknown |
|-----|----------|-----------|-------------|-----------|
| **WHAT** | What are we thinking about? (topic, question, decision) | Gary named it | Derivable from context | Must ask |
| **WHY** | What outcome? (understand, decide, spec, explore) | Gary stated purpose | Implied by sub-command | Must ask |
| **WHO** | Who needs this? (Gary, team, investors, users) | Gary specified | Obvious from context | Must ask |
| **HOW** | What method/depth? (quick scan, deep research, multi-agent swarm) | Gary chose sub-command | Matches complexity | Must ask |
| **SCOPE** | Which parts? (specific topic, broad domain, bounded question) | Gary bounded it | Inferrable from context | Must ask |
| **BAR** | What quality standard? (directional, defensible, publishable) | Gary set the bar | Implied by audience | Must ask |

### Step 2: PRESENT & CLARIFY

Show the decomposition:

> | Dim | Value | Status |
> |-----|-------|--------|
> | WHAT | {target} | ✅/🔮/❌ |
> | WHY | {purpose} | ✅/🔮/❌ |
> | WHO | {audience} | ✅/🔮/❌ |
> | HOW | {approach} | ✅/🔮/❌ |
> | SCOPE | {boundary} | ✅/🔮/❌ |
> | BAR | {standard} | ✅/🔮/❌ |

- **❌ Unknown** → ask ONE batched question covering all unknowns
- **🔮 Inferred** → state for confirmation
- **All ✅/🔮** → skip to Step 3

### Step 3: PLAN

> **Plan: Think > {sub-command}**
> - **Scope:** {WHAT + SCOPE resolved}
> - **Reads:** {specs, existing research, external sources}
> - **Writes:** {output file path in `outputs/think/`}
> - **Agents:** {N-agent team / swarm pattern / single agent}
> - **Output:** {format → destination, promotion suggestion}

**Before presenting "Go?":** Write to `sessions/scratchpad.md`:
- Update `## Current Task` with the resolved WHAT
- Update `## Mode & Sub-command` with the command > sub-command
- Update Pipeline State: `- [x] Intent Gate: WHAT={what} | WHY={why} | WHO={who} | HOW={how} | SCOPE={scope} | BAR={bar}`

### Step 4: CONFIRM
> **Go?**

**HARD STOP.** End your message here. Do NOT:
- Add a "preview" or "meanwhile" or "while you decide"
- Start producing output in the same message
- Say "Go?" and then keep writing

The message containing "Go?" must contain NOTHING after it. Wait for Gary's next message before doing any work.

### Step 5: PLAN MODE (mandatory after Gary confirms)

When Gary confirms ("go", "yes", "do it"), you MUST call `EnterPlanMode` before doing ANY work. This is not optional. This is not "consider using plan mode." This is deterministic:

```
Gary says "go" → call EnterPlanMode() → write plan to plan file → call ExitPlanMode() → Gary approves → THEN execute
```

**Why:** The plan mode creates an auditable, reviewable execution plan that Gary can approve or reject before any files are touched. Without it, the "Go?" confirmation only approves the *intent*, not the *implementation approach*.

**Exceptions (skip plan mode):**
- `--auto` flag (mobile/scheduled dispatch)
- Trust level T2+ for this domain (delegated — Gary already trusts the approach)
- Sub-commands marked `[skip-gate]` below

**[skip-gate]:** Any sub-command with `--auto` flag (mobile/scheduled dispatch).

---

## Context Protocol (runs after Intent Gate, before execution)

After the Intent Gate resolves all 6 dimensions, auto-load relevant context. See `gOS/.claude/context-map.md` for the full keyword → source mapping.

1. Parse resolved WHAT and SCOPE for keywords
2. Match against context map → candidate sources
3. Check file existence (skip missing silently)
4. Estimate token cost (lines / 4)
5. If total < 30% of remaining context → load silently
6. If total > 30% → present list and ask Gary to trim
7. Log loaded context to `sessions/scratchpad.md` under `Working State`
8. **Write scratchpad marker:** Update `sessions/scratchpad.md` Pipeline State: `- [x] Context Loaded: {list of files loaded or "none needed"}`

---

## Memory Recall (runs after Context Protocol, before Trust Check)

Query persistent memory for relevant past experience before executing. This is how gOS learns across sessions.

1. **Search claude-mem** for the current command + domain:
   - `mcp__plugin_claude-mem_mcp-search__search({ query: "{WHAT} {sub-command}", type: "observation", limit: 5 })`
   - Also search: `mcp__plugin_claude-mem_mcp-search__search({ query: "{domain} {sub-command} signal", limit: 3 })`
2. **Check self-model** for domain competence:
   - Read the row for `{domain}` in `.claude/self-model.md`
   - If accept rate < 70% or weaknesses listed → flag: "Note: my `{domain}` has {weakness}. Adjusting approach."
3. **Surface relevant findings:**
   - If past sessions had reworks/rejects in this domain → mention what went wrong and how you'll avoid it
   - If past sessions had accepts/loves → mention what worked and reuse the approach
   - If no relevant history → say "No prior experience in this domain — running full pipeline."
4. **Write scratchpad marker:** Update Pipeline State: `- [x] Memory Recalled: {N} observations, self-model: {domain} T{N} {accept_rate}`

**Keep it brief.** One line of insight, not a paragraph. The goal is to inform execution, not to recite history.

---

## Trust Check (runs after Context Protocol, before Pipe Resolution)

Check trust level for the current domain. See `gOS/.claude/trust-ladder.md` for rules.

1. Infer domain from resolved WHAT (e.g., "research copy trading" → `research-synthesis`)
2. Read `sessions/trust.json` → get trust level for this domain
3. Adjust gate depth:
   - T0: Full gate was already run (default)
   - T1: Inferences auto-confirmed, plan shown but confirm is lighter
   - T2: Execute directly, present summary after
   - T3: Execute silently, log to scratchpad
4. Show trust context: "Trust: `{domain}` at T{N} ({history summary})"
5. **Write scratchpad marker:** Update Pipeline State: `- [x] Trust Level: T{N} for {domain}`

---

## Pipe Resolution (runs after Context Protocol, before execution)

Check for upstream artifacts that match the current task. See `gOS/.claude/artifact-schema.md` for the full schema and algorithm.

1. Parse WHAT from resolved intent
2. Search `outputs/` for files with matching topic in YAML frontmatter
3. Filter by types relevant to `/think`: any prior thinking, research, decisions
4. If found: present list and auto-load as context ("📎 Upstream artifacts found...")
5. If not found: proceed without — Think often starts from scratch
6. Update `outputs/ARTIFACT_INDEX.md` after writing output
7. **Write scratchpad marker:** Update Pipeline State: `- [x] Pipe Resolved: {N} upstream artifacts loaded` or `- [x] Pipe Resolved: none found`

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

---

## finance <question>

**Purpose:** Financial analysis, modeling strategy, and business metrics research. Route to the right financial skill.

**Input:** Financial question or topic (e.g., "what should our pricing model be", "analyze unit economics", "build a revenue forecast")

**Routing table — match the question to the right skill:**

| Question Type | Skill to Invoke | Output |
|---------------|----------------|--------|
| Comparable companies / multiples | `financial-analysis:comps` | Comps table |
| DCF / intrinsic valuation | `financial-analysis:dcf` | DCF model |
| LBO / PE acquisition | `financial-analysis:lbo` | LBO model |
| 3-statement model | `financial-analysis:3-statement-model` | Financial model |
| Unit economics (LTV/CAC, cohorts) | `private-equity:unit-economics` | Unit economics analysis |
| Revenue model / pricing strategy | `anthropic-skills:business-idea-analyzer` | Business model analysis |
| Budget / expense planning | Research + spreadsheet build | Budget model |
| Competitive financial analysis | `financial-analysis:competitive-analysis` | Competitive landscape |

**Process:**

1. Parse the financial question from remaining `$ARGUMENTS`
2. Update scratchpad: `Think > finance`, question
3. **Classify** the question type from the routing table
4. **Research phase (parallel agents):**
   - Agent 1: Search for relevant benchmarks, industry data, comparable companies
   - Agent 2: Check existing specs for prior financial analysis or business model docs
   - Agent 3: Search for best practices and frameworks for this type of analysis
5. **Invoke the matched skill** with research context
6. **Synthesize** findings into actionable recommendations

**Output:** Write to `outputs/think/finance/{topic_slug}.md`. Suggest next step: "Build a financial model with `/build model`?" or "Run projections with `/simulate revenue`?"

---

## fundraise <topic>

**Purpose:** Fundraising strategy, investor targeting, pitch preparation, and deal structuring.

**Input:** Fundraising topic (e.g., "prepare for seed round", "build investor list", "draft investor update", "analyze term sheet")

**Routing table:**

| Topic Type | Skill to Invoke | Output |
|-----------|----------------|--------|
| Pitch deck strategy | `anthropic-skills:product-strategy` | Deck strategy |
| Investor list / targeting | `private-equity:source` or `everything-claude-code:market-research` | Buyer/investor list |
| Investor update / memo | `everything-claude-code:investor-materials` | Update memo |
| Investment thesis | `equity-research:thesis` | Thesis document |
| Due diligence prep | `private-equity:dd-checklist` | DD checklist |
| Term sheet analysis | `anthropic-skills:finance-domain` | Term analysis |
| Data room preparation | Research + file organization | Data room checklist |

**Process:**

1. Parse the fundraising topic from remaining `$ARGUMENTS`
2. Update scratchpad: `Think > fundraise`, topic
3. **Research phase (parallel agents):**
   - Agent 1: Market intelligence — recent funding rounds in the sector, investor activity, valuations
   - Agent 2: Company positioning — review existing specs, product metrics, competitive advantages
   - Agent 3: Best practices — fundraising playbooks, pitch frameworks, common mistakes
4. **Invoke the matched skill** with context
5. **Synthesize** into a fundraising brief

**Output:** Write to `outputs/think/fundraise/{topic_slug}.md`. Suggest next step: "Build a pitch deck with `/build deck pitch`?" or "Draft outreach with `/ship pitch`?"

---

## hire <role>

**Purpose:** Define hiring needs, write job descriptions, design interview processes, and build evaluation criteria.

**Input:** Role to hire (e.g., "senior frontend engineer", "head of product", "founding designer")

**Process:**

1. Parse the role from remaining `$ARGUMENTS`
2. Update scratchpad: `Think > hire`, role
3. **Research phase (parallel agents):**
   - Agent 1: Role benchmarking — search for similar JDs at top companies, compensation benchmarks, required skills
   - Agent 2: Internal needs analysis — review existing specs, product roadmap, and team structure to define what this role needs to accomplish in the first 90 days
   - Agent 3: Interview best practices — search for interview frameworks, assessment methods, and hiring playbooks for this role type
4. **Synthesize into a hiring brief:**

```markdown
# Hiring Brief: {role}

## Why This Role
{business justification — what changes when this person joins}

## Role Definition
- **Title:** {title}
- **Level:** {IC/manager, seniority}
- **Reports to:** {who}
- **Compensation range:** {range based on benchmarks}
- **Location:** {remote/onsite/hybrid}

## Key Responsibilities (90-day view)
1. {first 30 days — onboarding and quick wins}
2. {30-60 days — ownership and execution}
3. {60-90 days — strategic contribution}

## Must-Have Qualifications
- {skill 1 — with evidence criteria}
- {skill 2}
- {skill 3}

## Nice-to-Have
- {differentiator 1}
- {differentiator 2}

## Interview Process
| Round | Focus | Format | Duration | Evaluator |
|-------|-------|--------|----------|-----------|
| 1 | Culture + motivation | Conversation | 30min | Hiring manager |
| 2 | Technical depth | Live exercise | 60min | Technical lead |
| 3 | System design / Case study | Whiteboard | 45min | Senior engineer |
| 4 | Final / Team fit | Panel | 45min | Team |

## Evaluation Rubric
| Dimension | 1 (No Hire) | 3 (Hire) | 5 (Strong Hire) |
|-----------|------------|----------|-----------------|
| {dim 1} | {criteria} | {criteria} | {criteria} |
| {dim 2} | {criteria} | {criteria} | {criteria} |

## Sourcing Strategy
- {channel 1: where to find candidates}
- {channel 2}
- {channel 3}
```

**Output:** Write to `outputs/think/hire/{role_slug}.md`. Suggest: "Build the full playbook with `/build playbook hiring`?" or "Write the JD for posting with `/build content jd`?"

---

## gtm <market>

**Purpose:** Go-to-market strategy, market entry planning, pricing, distribution, and launch playbooks.

**Input:** Market or product to plan GTM for (e.g., "launch copy trading", "enter Korean market", "pricing strategy for Gold tier")

**Process:**

1. Parse the GTM target from remaining `$ARGUMENTS`
2. Update scratchpad: `Think > gtm`, target
3. **Team Mode (recommended for GTM — cross-functional perspectives matter):**

```
TeamCreate(team_name="think-gtm-{slug}")
```

Launch 3 named teammates:

- **`market-analyst` (sonnet):** Market sizing, TAM/SAM/SOM, competitor positioning, channel analysis. Use WebSearch and Exa for current market data.
- **`product-strategist` (sonnet):** Use `anthropic-skills:product-strategy`. Positioning, value proposition, pricing models, feature prioritization for launch.
- **`growth-hacker` (sonnet):** Distribution channels, acquisition cost estimates, viral loops, referral mechanics, launch sequence. Research what worked for similar products.

4. **Adversarial cross-examination:** After all 3 report:
   - "market-analyst, product-strategist claims pricing at $X. Does the market data support this?"
   - "growth-hacker, market-analyst found TAM of $Y. Is your distribution plan sized for this?"

5. **Synthesize into GTM brief:**

```markdown
# GTM Strategy: {target}

## Market Opportunity
- TAM / SAM / SOM with sources
- Growth rate and trends
- Key segments and beachhead

## Positioning
- Category: {where do we play}
- Differentiator: {why us vs alternatives}
- Value prop: {one sentence}

## Pricing Strategy
| Tier | Price | Target Segment | Key Features |
|------|-------|---------------|-------------|

## Distribution & Channels
| Channel | CAC Estimate | Volume Potential | Priority |
|---------|-------------|-----------------|----------|

## Launch Sequence
| Week | Action | Success Metric |
|------|--------|---------------|

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
```

**Shutdown:** `SendMessage(to="*", message={type: "shutdown_request"})` then `TeamDelete`

**Output:** Write to `outputs/think/gtm/{target_slug}.md`. Suggest: "Promote to go-to-market spec?" or "Build sales playbook with `/build playbook sales`?"

---

## legal <topic>

**Purpose:** Legal and compliance research. Regulatory requirements, terms of service, privacy policy, IP documentation, contract analysis.

**Input:** Legal topic (e.g., "crypto regulatory requirements for US users", "draft terms of service", "review this contract", "GDPR compliance checklist")

**IMPORTANT:** gOS is not a lawyer. All legal outputs include a disclaimer: "This is research for discussion with legal counsel, not legal advice."

**Process:**

1. Parse the legal topic from remaining `$ARGUMENTS`
2. Update scratchpad: `Think > legal`, topic
3. **Research phase (parallel agents):**
   - Agent 1: Regulatory landscape — search for current laws, regulations, enforcement actions, and case law relevant to the topic
   - Agent 2: Industry practices — how do competitors and industry peers handle this? What's standard?
   - Agent 3: Risk assessment — what are the penalties for non-compliance? What are the common pitfalls?
4. **Synthesize into a legal research brief:**

```markdown
# Legal Research: {topic}

> **Disclaimer:** This is research for discussion with legal counsel, not legal advice. Consult a licensed attorney before making legal decisions.

## Regulatory Landscape
{current laws, regulations, and enforcement environment}

## Key Requirements
| Requirement | Jurisdiction | Status | Risk Level |
|-------------|-------------|--------|------------|

## Industry Standard Practices
{how peers handle this — anonymized where appropriate}

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|

## Compliance Checklist
- [ ] {requirement 1}
- [ ] {requirement 2}
- [ ] {requirement 3}

## Recommended Next Steps
1. {action with timeline}
2. {action with timeline}

## Open Questions for Legal Counsel
- {question 1}
- {question 2}
```

**Output:** Write to `outputs/think/legal/{topic_slug}.md`. Suggest: "Review compliance with `/review compliance`?" or "Draft the document with `/build content legal`?"

---

## Creative Friction Check (runs after execution, before Output Contract)

See `gOS/.claude/creative-friction.md`. Think is the most fertile ground for friction.

Before presenting, check: (1) Is the conclusion too conventional? → present one contrarian alternative. (2) Does the research reveal an adjacent insight Gary didn't ask for? → surface it. (3) Does the output rest on an unstated assumption? → flag it.

Max ONE friction per task. Present as a choice, accept Gary's decision immediately. Suppress if Gary said "just" or "quick".

---

## Output Contract (MANDATORY — runs after execution, before presenting)

**You MUST complete all steps before showing output to Gary.** See `gOS/.claude/output-contract.md` for the full rubric.

1. Score on 5 universal dimensions (1-5): Completeness, Evidence, Actionability, Accuracy, Clarity
2. Score on Think extension: **Novelty** (1-5) — does it surface non-obvious insights?
3. Identify weakest dimension
4. If any dimension ≤ 2 → flag and offer to improve before Gary reads
5. Apply **Confidence Calibration** to key claims (see `gOS/.claude/confidence-calibration.md`):
   - Score each key claim on 6 structural factors → 🟢HIGH / 🟡MEDIUM / 🟠LOW / 🔴SPECULATIVE
   - Include aggregate confidence in scorecard header
   - Flag the single biggest uncertainty
6. Present scorecard + confidence summary at top of output
7. **Write YAML frontmatter** to the output file (per `gOS/.claude/artifact-schema.md`):
   ```yaml
   ---
   artifact_type: research-brief | decision | (match from schema)
   created_by: /think {sub-command}
   created_at: {ISO timestamp}
   topic: {WHAT from intent}
   related_specs: [{matched specs}]
   quality_score: {scores from step 1-2}
   status: draft
   ---
   ```
8. **Update `outputs/ARTIFACT_INDEX.md`** — add or update entry for this artifact
9. **Write scratchpad markers:** Update Pipeline State:
   - `- [x] Output Scored: {avg}/5 (weakest: {dimension})`
   - `- [x] Frontmatter Written: {path}`
   - `- [x] Index Updated: {topic} added to ARTIFACT_INDEX`

---

## Red Team Check (runs after Output Contract, before presenting)

**Think red team question:** "What's the strongest counterargument to this conclusion?"

1. Run the red team question against the draft output
2. If a genuine issue is found (would change Gary's decision):
   a. Fix it if possible (adjust the conclusion)
   b. If not fixable: flag in output header with ⚔️ marker
3. If finding is LOW confidence or wouldn't change any decision → suppress (no noise)
4. **Write scratchpad marker:** Update Pipeline State: `- [x] Red Team Passed: {question asked} → {finding or "clean"}`

---

## Signal Capture (MANDATORY — after every execution)

**After presenting output, observe Gary's NEXT response and classify the signal.**

1. Classify Gary's response as one of:
   - `accept` — used output without changes, moved on
   - `rework` — "change this", "not quite", "try again"
   - `reject` — "no", "scratch that", "wrong approach"
   - `love` — "perfect", "great", "exactly", "hell yes"
   - `repeat` — same instruction given twice (gOS didn't learn)
   - `skip` — Gary jumped past a prescribed step

2. **Log to `sessions/evolve_signals.md`:**
   | Time | Command | Sub-cmd | Signal | Context |
   |------|---------|---------|--------|---------|

3. **Update `sessions/trust.json`** — adjust trust level for the current domain per `gOS/.claude/trust-ladder.md`:
   - `accept`/`love` → increment consecutive accept count
   - `rework`/`reject` → reset count, demote if threshold hit
   - Check progression rules (T0→T1 needs 3+ consecutive accepts)

4. If `repeat` detected → immediately update relevant command file or memory
5. If `love` detected → save the approach to feedback memory for reuse
6. **Write scratchpad marker:** Update Pipeline State: `- [x] Signal Captured: {signal type} for {domain}`
