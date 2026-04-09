# Evolve Signals

> Raw feedback signals from every gOS command invocation.
> Appended by session-save.sh Stop hook. Audited weekly by `/evolve audit`.

## Signal Key

- `accept` — Gary used output without changes
- `rework` — Gary asked for changes
- `reject` — Gary discarded output
- `love` — Gary explicitly praised output
- `repeat` — Gary had to re-explain something
- `skip` — Gary skipped a prescribed step

---

## Log

| Date | Time | Command | Signal | Context |
|------|------|---------|--------|---------|
| 2026-04-09 | 00:45 | /gos resume | rework | Resume briefing format "very confusing" — too much info, no hierarchy, unclear next action |
| 2026-04-09 | 01:00 | /gos resume | rework | Stop hook output also confusing — "TodoWrite, signals, feedback memory" meaningless to user |
| 2026-04-09 | 01:05 | /gos | accept | Redesigned resume + briefing + stop hook to Story+Table+Next Move format, synced 4 locations |
| 2026-04-09 | 01:20 | /think research | accept | Research on BATS, Promptfoo, ECC instincts, ROEGATE, agentmemory — accepted without changes |
| 2026-04-09 | 01:25 | /think research | rework | Gary asked about MemPalace vs agentmemory distinction — research missed context of existing tools |
| 2026-04-09 | 01:30 | /think research | accept | Karpathy LLM Wiki comparison + compilation layer recommendation — Gary engaged |
| 2026-04-09 | 01:45 | /think research | accept | Full 6-phase plan with Karpathy wiki integration presented — Gary asked to save and start |
| 2026-04-09 | 02:00 | /gos conductor | accept | Gary approved autonomous execution: "loop through all phases, build, review, ship" |
| 2026-04-09 | 02:30 | /build | accept | All 6 phases built, 32 tests passing, 3 instincts extracted, wiki + lint + craft gate shipped |
| 2026-04-09 | 03:00 | /review eval | accept | Independent agent scored 6.75 (honest, brutal) — Gary accepted without pushback |
| 2026-04-09 | 03:00 | /review eval | accept | Gary's instruction "evaluate on real value, not meaningless improvements" drove honest scoring |
| 2026-04-09 | 03:15 | /think research | accept | Improvement plan against v3 scorecard — "don't build more infrastructure, go use it" |
| 2026-03-29 | 18:45 | /evolve | accept | Self-evaluation: 4 design weaknesses identified and agreed |
| 2026-03-29 | 18:45 | /evolve | accept | Taste as separate Arx_4-3 spec artifact (not .claude/) |
| 2026-03-29 | 18:45 | /evolve | rework | Gary corrected: apps are FLOOR not ceiling; taste in specs/ not .claude/ |
| 2026-03-29 | 18:45 | /evolve | accept | Full implementation plan (7 tasks) executed and completed |
| 2026-03-29 | 18:45 | /evolve | accept | Stitch MCP API key configured, headless workflow |
| 2026-03-29 | 18:45 | /evolve | accept | Evaluation dry-run confirmed 4/4 weaknesses addressed |
| 2026-03-29 | 02:30 | /refine | accept | v5 spec 27-item audit + fixes accepted, C4.2b added |
| 2026-03-29 | 02:30 | /refine | accept | C5.6 Phase 2 cascade (7 refs) annotated with MVP fallbacks |
| 2026-03-29 | 02:30 | /refine | accept | §8.3 Position + §8.4 Copy Portfolio display objects added |
| 2026-03-29 | 02:30 | /refine | accept | Structural reorg plan approved: Data→Compute→Display→Feed→Journeys→Contract |
| 2026-03-29 | 02:30 | /refine | repeat | Reorg task approved but never executed — 2 sessions hit context limit before Write |
| 2026-03-27 | 18:38 | /design | accept | Phase 5 report + Iter 3 fixes accepted without changes |
| 2026-03-27 | 18:38 | /design | accept | DB schema + design rationale fixes accepted |
| 2026-03-27 | 18:38 | /design | skip | Gary chose "1 and 3", skipped PRD alignment (item 2) |
| 2026-03-27 | 15:34 | /review | accept | Relationship rationale + naming warning patch accepted |
| 2026-03-27 | 15:34 | /review | accept | 4 dropped D1 specs restored without changes |
| 2026-03-27 | 15:34 | /review | love | "yes please" to Follow collapse + filter chip restoration |
| 2026-03-27 | 15:34 | /review | accept | Common Labels system with permutation table accepted |
| 2026-03-27 | 15:34 | /review | accept | Full stale reference cleanup (10-point verification) accepted |
| 2026-04-09 | 00:00 | /gos | rework | Resume loaded wrong session (harness build instead of gOS restructure) |
| 2026-04-09 | 00:05 | /gos | rework | Initial plan had different scope than Gary's P1-P5 table — Gary provided exact priorities |
| 2026-04-09 | 00:10 | /gos | skip | Gary said "full conductor mode" — skipped briefing, went straight to P1-P5 work |
| 2026-04-09 | 00:30 | /gos | accept | P3 hooks wired (9 scripts, 6 events) — accepted without changes |
| 2026-04-09 | 00:40 | /gos | accept | P1-P5 execution — all 5 priorities built |
| 2026-04-09 | 00:50 | /gos | accept | Bonus: fixed 10 broken symlinks + gos-plugin path |
| 2026-04-09 | 00:55 | /gos | repeat | Stop hook tasks skipped — session ended without mandatory signal scan + memory update |
| 2026-04-09 | 01:00 | /ship | accept | "yes commit to git repo" — clean execution |
| 2026-04-09 | 01:05 | /aside | accept | Untracked files assessment — clear keep/remove recommendation |
| 2026-04-09 | 01:05 | /gos | repeat | Stop hook caught gOS AGAIN skipping mandatory signal+memory tasks |
| 2026-04-09 | 01:20 | /refine | accept | 10-dimension criteria created as evals/criteria/ files + scorecard |
| 2026-04-09 | 01:40 | /think | accept | VISION.md north star doc — "superior alien AI co-creator" vision documented |
| 2026-04-09 | 01:45 | /review | accept | Honest 12-dim review: 8.0→6.6 after adding craft+testing. Intuition validated |
| 2026-04-09 | 02:00 | /aside | accept | First-principles dimension validation + /aside command routing |
| 2026-04-09 | 02:00 | /gos | repeat | Stop hook skipped THIRD time — pattern: any "natural ending" triggers skip |
| 2026-04-09 | 02:10 | /build | accept | Fixed /aside autocomplete — synced all 14 commands across 4 locations |
| 2026-04-09 | 19:55 | /gos conductor | accept | Parallel agent diagnosis accepted — settings fine, root cause is command instructions |
| 2026-04-09 | 19:55 | /gos conductor | accept | 6 command upgrades with Agent() patterns — accepted approach without changes |
| 2026-04-09 | 19:55 | /gos conductor | accept | Broken symlink fix (15 dead links) + Stop hook sync — accepted |
| 2026-04-09 | 19:55 | /gos conductor | accept | spec-compliance hook bug (naming mismatch) flagged — Gary didn't pushback |
