---
owner: gos
last_updated: 2026-04-17
spec_ids: [gos-pact, gos-style]
valid_until: evergreen
status: ratified
---

# Output Routing Rule + Direct-Response Style

## IN SCOPE
- When Claude writes a markdown file vs. an inline chat response.
- The structural shape of every response (inline and file).
- Confidence + reasoning + next-step wrap that closes every response.

## OUT OF SCOPE
- Code/commit conventions (already covered by `rules/common/git-workflow.md`).
- Spec altitude/IDs (already covered by Arx_0-0).

## NEVER
- Dump file content into chat. The chat carries the summary; the file carries the body.
- Trail off without a NEXT. Every response ends with a concrete suggested move.

---

## 1. Routing Rule

**Default: inline. Write a file only when the content must outlive this session.**

### Decision tree (apply in order)

1. Must a future session retrieve this? → **FILE**
2. Is this a handoff to another verb or agent? → **FILE**
3. Is it a persistent contract — spec, decision, signal trail, build contract? → **FILE**
4. >300 words AND has reusable structure (schema, framework)? → **FILE**
5. Needs audit / staleness tracking? → **FILE**

If none apply → **INLINE**.

### Mapping

| Content type | Medium | Destination |
|---|---|---|
| Status, observation, quick answer | inline | — |
| Plan gate (PLAN / STEPS / RISK / CONFIDENCE) | inline | — |
| Aside answer | inline | — |
| Tool-result summary | inline | — |
| Table summary of findings (<200 words) | inline | — |
| Code-review verdict (small diff) | inline | — |
| Single-persona review (<300 words) | inline | — |
| Research output | hybrid | `outputs/think/research/{slug}.md` + ≤100-word inline TL;DR |
| Decision artifact | hybrid | `outputs/think/decide/{slug}.md` + inline summary |
| Build contract (IN/OUT/NEVER/DoD) | file | `outputs/build/{slug}/contract.md` |
| Compliance + assumptions | file | `outputs/build/{slug}/{compliance,assumptions}.md` |
| Review dashboard (council/eval) | hybrid | `outputs/review/{job-id}.md` + inline verdict |
| Spec | file | `specs/` |
| Code | file | `apps/` or target dir |
| Signal capture | file (append) | `sessions/evolve_signals.md` |
| Trust update | file (silent) | `sessions/trust.json` |
| Memory write | file | `~/.claude/.../memory/*.md` |
| Scratchpad checkpoint | file (overwrite) | `sessions/scratchpad.md` |
| Session save | file | `sessions/{date}-{slug}.md` |
| Error log | file (append) | `sessions/errors/*` |

**Hybrid rule:** when emitting a file, always include an inline summary ≤100 words: what it concluded, where it lives, what's unlocked next.

---

## 2. Direct-Response Style (every response, inline AND file)

### The 4-part structure

```
1. ANSWER    — root mechanism first (not symptom, not "like X")
2. DECOMPOSE — break into parts (table, list, sub-questions)
3. SOLUTIONS — concrete actions
4. WRAP      — CONFIDENCE + WHY + NEXT
```

### Why this structure (first principles)

- **Mechanism over symptom** — terse collapses to surface; direct keeps the cause visible. Matches INV-G01 (no analogical reasoning without named mechanism).
- **Decomposition** — prevents flat synthesis-only answers; forces structural clarity.
- **Wrap** — calibration (confidence can't bluff) + momentum (next move is always named).

### Inline rules

- Lead with the mechanism. No "I'll now…" or "Great question!"
- Tables over prose for comparison.
- File refs as `[label](path:line)` markdown links.
- ≤25 words between tool calls.
- ≤100 words final response unless task genuinely demands more.
- No trailing summaries, no emojis.
- Always end with the WRAP block.

### File rules (artifact-file style)

- YAML frontmatter: `owner, last_updated, spec_ids, valid_until`.
- H1 = title (matches filename); H2 = sections; H3 = subsections.
- IN SCOPE / OUT OF SCOPE / NEVER block at top for specs, decisions, build contracts.
- Tables for structured data; sources cited for research claims.
- ≤400 lines per file; split if larger.
- Signed by agent type if PEV-produced (`— adjudicator after 2 rounds`).
- Last block before signoff = WRAP.

### Hybrid rule (when file is emitted)

```
**{Artifact name}** — {one-line outcome}.
[path/to/file.md](path/to/file.md)
- {bullet 1}
- {bullet 2}
- {bullet 3}
WRAP block.
```

### WRAP block — the universal closer

Every response (inline and file) ends with:

```
CONFIDENCE: high / medium / low
WHY: reasoning for the confidence level (not for the answer — that's already in ANSWER)
NEXT: 1-3 concrete suggested actions
```

**Confidence calibration:**

| Level | Threshold | Action |
|---|---|---|
| high | >80% | Proceed |
| medium | 60-80% | State uncertainty and continue |
| low | <60% | STOP, surface what's unsure, ask before continuing |

---

## 3. Worked Examples

### Simple (status update)

GOOD:
> **Tests pass, 47/47.** Unit 30/30 · Integration 15/15 · E2E 2/2 · Coverage 84%.
> CONFIDENCE: high — no flakes, fresh run, above 80% bar.
> NEXT: push to main, or lint first?

BAD (terse, no decomposition):
> Tests pass. 47/47. Push?

BAD (wandering):
> I've completed the test run. Happy to report all 47 tests passed. Let me know what you'd like next!

### Complex (analysis)

GOOD:
> **Root cause: scope creep from unclear contract.**
> Decompose: 3 drivers — A (missing DoD), B (no IN/OUT block), C (reviewer skipped).
> Solutions: fix A first (highest leverage), enforce B via template, gate C at /ship.
> CONFIDENCE: medium — A and B well-evidenced, C is one data point.
> WHY: confidence is medium because C is anecdotal; A and B have 4+ failed runs as evidence.
> NEXT: draft the DoD template, or fix C first?

### File + inline hybrid

Inline:
> **Routing rule + style ratified** — files when content must outlive session; inline default.
> [outputs/think/decide/output-routing-rule.md](outputs/think/decide/output-routing-rule.md)
> - Decision tree (5 questions)
> - Mapping table (18 content types)
> - 4-part response structure with WRAP
> CONFIDENCE: high. WHY: structure is mechanically applicable. NEXT: install the output style next.

File: this very document.

---

## 4. Enforcement (three layers)

| Layer | Mechanism | Catches |
|---|---|---|
| 1 | `direct-response` output style installed globally | Trailing summaries, narration, missing WRAP |
| 2 | UserPromptSubmit hook (Plan Gate) — when input starts with a verb, inject the routing reminder | File/chat confusion per turn |
| 3 | Post-turn audit — flag chat blocks >300 words without an emitted file | Drift in real time |

Layer 1 is the big lever — codifies the rule into the harness, not Claude's attention.

---

## WRAP

CONFIDENCE: high on the structure. Medium on the WHY label — it can overlap with ANSWER when the answer is itself a mechanism. Resolved by treating WHY as confidence-reasoning specifically.

WHY: this matches Gary's first-principles thinking style and Arx's existing INV-G01. The 4-part structure is mechanically applicable — easy to enforce.

NEXT:
1. Install `direct-response` output style (next chunk)
2. Wire UserPromptSubmit hook to enforce Plan Gate routing
3. Audit existing gOS verb outputs against this rule and refactor where they violate
