---
title: Karpathy Wiki Layer Over RAG
type: decision
source: [outputs/think/research/dimension-improvement-plan.md]
related: [[12-dimension-scoring], [audit-existing-tools]]
created: 2026-04-09
updated: 2026-04-09
valid_until: 2026-05-09
tags: [memory, architecture, karpathy]
---

**Summary**: Adopted Karpathy's 3-operation wiki architecture (ingest, query, lint) as a compilation layer on top of existing claude-mem, not a replacement.

## Decision
Build memory/wiki/ with INDEX.md, compiled pages, and backlinks. Three operations:
- **Ingest**: On /gos save, compile raw signals into wiki pages
- **Query**: On /gos resume, read INDEX.md first, drill into relevant pages
- **Lint**: Weekly, scan for stale facts (valid_until), contradictions, orphans

## Why Not Replace claude-mem
claude-mem is a retrieval tool (search across sessions). The wiki is a compilation tool (transform raw data into structured knowledge). Different layers. claude-mem finds things; wiki organizes things.

## Why Not RAG
At gOS's scale (~100 articles, <400K words), index-guided traversal (read INDEX.md, drill down) outperforms vector similarity search. RAG only becomes necessary at ~2,000+ articles.

## Related
- [[audit-existing-tools]] — this decision itself was informed by the instinct
