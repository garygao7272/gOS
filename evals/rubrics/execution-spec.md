# Eval Rubric: execution-spec doc-type

> Activates when frontmatter `doc-type: execution-spec`. Overlays on top of the calling verb's base rubric (`think.md` or `refine.md`); these three dims carry **60% combined weight** for execution-specs because they encode what "ready to code" actually means. Convergence stop criterion below.

## The three dimensions that bite

| Dimension | Weight | 1-3 (Poor) | 4-6 (Adequate) | 7-8 (Good) | 9-10 (Exceptional) |
|---|---|---|---|---|---|
| **Execution density** | 25% | <40% of body lines are operational (contract / edge / numeric / state / open Q); >40% is rationale, prose explanation, or process narrative | 40-60% operational | 60-80% operational | ≥80% operational; rationale fully compressed into opening |
| **Rationale cap** | 15% | Rationale sprawls — paragraphs of "why" interleaved through body sections | Rationale isolated to top but >10 lines | Rationale at top, ≤8 lines, no scatter | Rationale ≤6 lines at top, no "why" prose anywhere else; "why" moves to a sibling decision-record if it needs more |
| **Implementer-test** | 20% | A competent engineer with no context would have ≥6 unanswered questions to code this | 4-5 questions | 2-3 questions | ≤2 questions; remaining questions named explicitly under "Open questions" with resolver |

**Operational line definition:** a line that names one of — input/output type, state, transition, edge case (empty/overflow/error/concurrent/stale/forbidden/quota), numeric target with unit, contract clause, named open question with resolver, explicit cut-from-v1 item. Prose explanation, motivation, comparison-to-alternatives, and rationale are non-operational.

## Scoring rules

- **Execution density** — count operational lines / total body lines (exclude frontmatter, H1, opening rationale paragraph, appendix). Score = round(ratio × 10), capped at 10.
- **Rationale cap** — count lines from after H1 to first H2 that look like "Contract" / "Edges" / "Targets" / "State". ≤6 = 10. 7-8 = 8. 9-10 = 6. 11-15 = 4. 16+ = 2.
- **Implementer-test** — fresh-context critic agent (`agents/implementer-test.md`) reads spec, returns ranked list of "questions I'd have to ask to code this." Score = max(0, 10 - 2*questions).

## Anti-pattern flags (auto-fail this rubric to ≤4)

- **Process narrative leakage** — phrases like "we considered", "originally", "after reflection", "it's worth noting", "having established" in body prose. Already lint-detectable; if any fire, this rubric scores ≤4 regardless of dim totals.
- **Soft adjective without numeric** — "fast", "responsive", "comfortable", "smooth", "snappy", "approachable", "premium" in any operational section (Contract, Edges, Targets, State) without a number within 10 chars. Lint-detectable.
- **Rationale > 6 lines** — automatic ≤4 on the rationale-cap dim.
- **Rationale paragraph anywhere besides the top** — auto-fail. The "why" lives in one place.
- **Same point in two framings** — body restates a contract clause, edge case, or numeric target in different words (often hedge-rephrasing). Implementer-test surfaces this.

## Convergence stop criterion (for /refine cycles on execution-specs)

Stop iterating when **all four** hold:

1. Execution density ≥ 70% (dim score ≥ 7)
2. Rationale cap ≤ 6 lines (dim score ≥ 8)
3. Implementer-test ≤ 2 questions (dim score ≥ 6)
4. Zero anti-pattern flags fire

Replaces the default `/refine` stop ("all dims ≥1, gap resolution >90%") for execution-spec doc-type. Empirical target: **2-3 cycles for first draft, 1-2 for revision**, vs the historical 10-20 cycles when the loop scored against structural completeness instead of operational readiness.

## Overall score

For execution-spec doc-type:

```
exec_score = (density*25 + rationale_cap*15 + implementer*20) / 60     # the 3 dims = 60%
base_score = base rubric weighted score                                  # remaining 40%
overall = exec_score * 0.6 + base_score * 0.4
```

- 8-10 → ready to code
- 5-7 → another /refine cycle or manual rework
- 0-4 → reset: spec is wrong shape, run `/think discover` to re-examine the boundary

## How /refine and /think reference this

- `/think spec` and `/think discover` — when `doc-type: execution-spec` declared in frontmatter, score against this rubric instead of the generic think rubric.
- `/refine` — when target file's frontmatter has `doc-type: execution-spec`, swap convergence criterion to this file's stop criterion. Spawn `agents/implementer-test.md` as critic.
