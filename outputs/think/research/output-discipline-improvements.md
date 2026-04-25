---
doc-type: research-memo
audience: Gary Gao (gOS author)
reader-output: ranked punch-list of improvements to output-discipline.md + direct-response.md
generated: 2026-04-19
sources: 4 independent fresh-context agent critiques (PM / Researcher / UX Designer / Solution Architect)
---

# Output Discipline — Improvement Research Memo

*Research memo for Gary on how four expert archetypes would improve `rules/common/output-discipline.md` and `output-styles/direct-response.md`. Reader produces: a ranked decision of which improvements to ship, defer, or reject. Why now: the rule just absorbed §1.1 (opener), §6.8 (doc-type order), §6.9 (visual aids), and §7 (voice). The additions are correct but the enforcement and architecture haven't caught up — which is what four independent lenses just surfaced.*

**Covers:** verdict · convergent high-leverage picks · per-lens key gaps · disagreement map · recommended ship order · appendix.

---

## Verdict (TL;DR)

The rule is **semantically strong but structurally fragile.** Four lenses independently named the same three root gaps:

1. **No single source of truth** — the rule and the style file duplicate §1.1 and §5 prose, and they already drift in wording.
2. **Response-prose rules have zero mechanical enforcement** — `tests/hooks/artifact-discipline.bats` lints files, nothing lints chat turns, so §1 mechanism-first / §1.1 OUTLINE / §5 NEXT MOVE decay silently.
3. **No entry point** — a reader in either file scrolls through 240+ lines before finding the rule that fires for their situation.

Three other gaps are 2-lens convergent: doc-type §6.8 is unroutable, the rule costs ~3500 tokens loaded into every context, and the positioning-sentence bats check is negative-only. Everything else is single-lens polish.

## Convergent high-leverage picks — ship order

| # | Recommendation | Lenses | Leverage | Effort |
|---|---|---|---|---|
| 1 | Collapse `direct-response.md` into a thin pointer — rule bodies in one file | PM, UX, Architect | **HIGH** — cuts ~40% duplication, eliminates drift surface | S (delete + cross-link) |
| 2 | Add `tests/hooks/response-discipline.bats` — regex lint for mechanism / OUTLINE / SUMMARY / NEXT MOVE / em-dash on session turns | PM, Architect | **HIGH** — fires 50×/day, catches decay before Gary does | M (new bats + wire into health-gate) |
| 3 | Add situation→rule index table at top of `output-discipline.md` | UX, Researcher | **HIGH** — 10-second entry for every reader, fatigue-proof | S (one table, ~12 rows) |
| 4 | Require `doc-type:` frontmatter + extend bats to check §6.8 ordering | PM, Researcher, Architect | **HIGH** — §6.8 is the most load-bearing unrouted rule | M (frontmatter schema + bats check + one-time migration) |
| 5 | Extract §6.9 catalog + §7.1 catalog into companion reference files; keep summaries | UX, Architect | **MEDIUM** — ~80 lines off the always-loaded rule, fewer tokens per session | S (file split + anchor summaries) |
| 6 | Extend `_check_opens_with_positioning` from negative to positive — must *have* positioning sentence, not just lack changelog | Architect | **MEDIUM** — closes the "empty open passes" gap | S (bats helper edit) |
| 7 | Add NEXT MOVE format constraint (imperative verb phrase ≤12 words + "Proceed?") + lint rule | PM | **MEDIUM** — converts SUMMARY from prose to handoff | S (rule line + one lint regex) |

Ship picks 1–4 in the next cycle; defer 5–7 unless a refine round surfaces them.

## Per-lens key gaps

**PM lens (Gary-as-user).** Biggest gap: rule is a rulebook, not a contract. No outcome sentence tells the reader what a compliant response *does for Gary* ("answer in one sentence / decide in one glance / act without re-read"). Without it, conflicts between §1 mechanism-first and §6.8 decision-record why-first have no tiebreaker. Second gap: adoption has no telemetry — artifact discipline is tested, response discipline isn't, so Gary's fatigue is the only detector.

**Researcher lens (vs. best-in-class).** Ahead of state-of-the-art on three things: PASS/KILL/DEFER is sharper than Nygard's ADR; NEXT MOVE beats Shape Up's pitch close; decisive/suggestive signal calibration is a concept most style guides don't reach. Behind on two things: no **audience + content-type taxonomy** (Google / Microsoft baseline at [developers.google.com/style/audience](https://developers.google.com/style/audience) and [learn.microsoft.com/style-guide](https://learn.microsoft.com/en-us/style-guide/top-10-tips-style-voice)); no **diátaxis-style mode split** ([diataxis.fr](https://diataxis.fr/)) — gOS treats all prose as one surface when published practice treats it as four (tutorial / how-to / reference / explanation).

**UX lens (reader experience).** Top failure: no 10-second scan path. The rule has 7 H2s + 9 H3s + 4 H4s with no top-of-file index. Under fatigue (60–70% context), the response-vs-artifact split is the first thing the reader drops. §6 has nine subsections of equal visual weight when it should have three tiers (Must / Shape / Hygiene). §7 and §6.9 are reference catalogs mixed with live rules — they dilute the active rule surface.

**Architect lens (enforcement + drift).** Load-bearing-but-unenforced rules: §1 mechanism-first, §1.1 OUTLINE, §3 DEFER, §4 signal calibration, §5 NEXT MOVE, §6.8 doc-type ordering, most of §7. The positioning-sentence bats check in `tests/hooks/artifact-discipline.bats:15-24` uses only a negative regex — a file with no opener at all passes. A real linter globs session transcripts, runs regex/awk on response-shape heuristics, and feeds warn-count into `/evolve audit` as a structural signal alongside Gary's manual feedback.

## Disagreement map

The four lenses substantially agree. Two real disagreements worth flagging:

1. **Scope of the token-budget fix.** Architect recommends three-tier split (core / artifacts / voice) with verb-scoped loading; UX recommends extracting catalogs to companion files but keeping one rule file. *Resolution:* start with UX's lighter split (picks 1 + 5 above); only escalate to architect's three-tier scheme if token measurements show >5% of context budget going to the rule.

2. **AI smell calibration.** Researcher flags §7.3 em-dash thresholds as anchored on one in-house reference ("single sample is not calibration"); PM and Architect treat §7 as live rule, not research claim. *Resolution:* reframe §7.3 as "gOS house style" rather than general AI-smell detection — keep the caps, drop the implied universality. Low-effort wording fix.

## Rejected / deferred (lower-leverage)

- Researcher #2 (full diátaxis adoption) — too heavy; §6.8 already solves 80% of the same problem with a lighter taxonomy.
- PM #1 (outcome sentence) — covered implicitly by pick #3 (situation→rule table, which names the situation = the outcome trigger).
- UX #3 (re-cluster §6 into Must/Shape/Hygiene tiers) — taste call; pick #5 (catalog extraction) captures the load reduction without the re-cluster churn.

## Recommended next actions

1. **Approve picks 1–4 for a refine cycle** — target: one shipped commit per pick, self-mode `/refine` with dim-6 gate.
2. **Defer picks 5–7** to the next `/evolve audit` — if response-discipline linter (pick 2) shows drift in mechanism-first or NEXT MOVE, re-promote them.
3. **Run pick 1 first** — removing duplication eliminates the drift surface, so every subsequent edit only lands in one place.

## Appendix: raw lens outputs

Full per-lens critiques archived at the session level. Condensed findings above. PM agent ID `a48d73cb87709a541`, Researcher `a08d843f250998773`, UX `ae88663fe3bb1ecb8`, Architect `af2609fae8d8bdd22` — re-open via SendMessage if a specific rec needs more depth.
