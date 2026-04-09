# Karpathy's LLM Knowledge Base vs RAG — Research Brief
*Researched: April 9, 2026 | For: gOS spec access strategy decision*

---

## 1. Karpathy's Position (Primary Source)

**Source:** X post April 3, 2026 + GitHub Gist `karpathy/442a6bf555914893e9891c11519de94f`
**URL:** https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
**Coverage:** VentureBeat, Analytics India Mag, DAIR.AI, Atlan — all April 4-7, 2026

### His Core Argument

Karpathy identifies the fundamental flaw in RAG: **every query rediscovers knowledge from scratch**. The AI searches raw source files, synthesizes on demand, and discards the work when the conversation ends. This is stateless knowledge management.

His alternative: treat the LLM as a **compiler**, not a retriever. The LLM reads raw documents once and writes a persistent, structured, interlinked wiki. From that point, queries hit the compiled artifact — not the raw sources.

> "LLMs don't get bored, don't forget to update a cross-reference, and can touch 15 files in one pass."

> "A large fraction of my recent token throughput is going less into manipulating code, and more into manipulating knowledge."

### The Three-Layer Architecture

```
raw/          ← immutable input docs (papers, articles, repos)
wiki/         ← LLM-compiled markdown: concept articles, summaries, backlinks
schema/       ← CLAUDE.md-style config defining wiki structure + workflows
```

**log.md** — append-only record with parseable prefixes (e.g., `## [2026-04-02] ingest`)
**index.md** — content-oriented catalog of all wiki pages with summaries

### Four Operations

1. **Ingest** — Process new source → update 10-15 wiki pages per source
2. **Compile** — Generate concept articles (~100 articles, ~400K words), cross-references, backlinks
3. **Query** — Search relevant pages, synthesize answer, file result back into wiki
4. **Lint** — Health-check for contradictions, stale claims, orphaned pages, new connections

### What He Actually Says About Scale

- At his current scale (~100 articles, ~400K words), **the index fits in context window** — no vector DB needed
- "As the wiki grows you want proper search" — optional tools like `qmd` (hybrid BM25/vector with LLM re-ranking)
- He explicitly scoped this to **individual researchers**, not enterprise
- Future direction: use the wiki to generate **synthetic training data + fine-tune** so the model knows the data in weights

### Key Philosophical Point

Karpathy references Vannevar Bush's *Memex* (1945) — a personal curated knowledge store with associative trails. The LLM solves what Bush couldn't: the maintenance burden of keeping cross-references consistent.

**His framing is NOT "RAG is dead." It's "for personal-scale knowledge, the compiled wiki is strictly better than stateless retrieval."**

---

## 2. The Broader RAG vs Long-Context Debate (2025-2026)

### The "RAG is Dead" Narrative

The "RAG is dead" claim is primarily a Twitter phenomenon. Enterprise RAG deployment grew 280% in 2025. The argument is not that RAG is dead — it's that **the default architecture for RAG (vector DB + chunking) is often the wrong tool.**

### The Strongest Anti-RAG Arguments (Practitioners, 2025-2026)

**Source:** "Is RAG Dead? Long Context, Grep, and the End of the Mandatory Vector DB" — Akita on Rails (April 6, 2026)
**URL:** https://akitaonrails.com/en/2026/04/06/rag-is-dead-long-context/

Key evidence-based arguments:

1. **Claude Code itself uses grep, not vector DB.** Anthropic's most advanced agent uses markdown index files (~25KB, <200 lines) + lexical grep on transcripts + smart context compaction. No LanceDB, no embeddings. If vector DB were right, Anthropic would have used it.

2. **Vector search has systematic failure modes rarely discussed:**
   - False neighbors: cosine similarity rewards topical similarity, not relevance
   - Chunking disasters: table boundaries split, function definitions separated from usage
   - Opaque failures: wrong chunk returned with no diagnostic signal
   - Index staleness: every doc update requires re-embedding

3. **Cost inversion (2023 assumption is now wrong):** In 2023, models were expensive, retrieval was cheap. In 2026, models are commodity, maintaining retrieval infrastructure is expensive. A 200K-token context query on Claude Sonnet 4.6 with caching costs ~$0.10. Setup costs for vector DB infrastructure: $1,600-$3,200 in engineering time. With that setup money, you could run ~30,000 queries.

4. **BM25 from 1990 remains competitive.** BEIR benchmark: BM25 without fine-tuning "remains ridiculously competitive in out-of-domain scenarios." Anthropic's Contextual Retrieval (2024): combining contextual BM25 with embeddings drops failure rates 5.7% → 2.9%; BM25 is the centerpiece, not secondary.

5. **Google DeepMind paper (EMNLP 2024):** "Long context beats RAG on average quality" for stable document bases. RAG offers token savings but not quality advantages when the corpus is stable.

### Research Literature (2024-2025)

| Paper | Finding |
|-------|---------|
| *Retrieval Augmented Generation or Long-Context LLMs?* (Google DeepMind, EMNLP 2024) | Long context beats RAG on average quality; token savings favor RAG |
| *Long Context vs. RAG for LLMs* (Jan 2025) | Long context beats RAG on QA benchmarks, especially stable doc bases |
| *Long Context RAG Performance of LLMs* (Databricks) | RAG + long context together outperforms either alone |
| *Long Context vs. RAG* (ACM SIGIR 2025) | Models should route between approaches themselves |

### Context Window Reality Check (2026)

| Model | Context | Practical Recall at Full Context |
|-------|---------|----------------------------------|
| Gemini 3.1 Pro | 1M+ tokens | ~60% average recall at 1M (40% "lost in the middle") |
| Claude Opus | 200K tokens | 94.1% RULER benchmark |
| Claude Sonnet 4.6 | 200K tokens | — |

**Key finding:** "Lost in the Middle" effect is real. Gemini at 800K-token legal contract sets missed one relevant clause per ~15 queries. Large context ≠ reliable full-context recall.

### Enterprise Practitioner Consensus (2025-2026)

The industry converged on **"retrieval-first, long-context containment":**
- Use retrieval to locate relevant documents
- Then use long-context to reason across those documents coherently

RAG is evolving from "vector search + chunked answer" to a "Context Engine" with intelligent assembly. GraphRAG, TreeRAG, and hybrid BM25+embedding approaches dominate new production deployments.

---

## 3. What This Means for gOS Spec Access

### Current State

- **Current tool:** LanceDB-based spec-RAG MCP (`gOS/toolkit/spec-rag-mcp/server.py`)
- **Model:** `all-MiniLM-L6-v2` sentence-transformers (25MB, CPU)
- **Top-K:** 5 results per query, 600-char snippets
- **Scope:** Was built for "65+ spec files" but Arx now has 339 total / 130 active specs

### The Numbers That Matter

| Metric | Value |
|--------|-------|
| Total spec files (Arx, all) | 339 files |
| Active spec files (non-Archive) | 130 files |
| Active specs total size | ~4.4MB / ~1.1M tokens |
| Largest single spec | ~373KB (Archive), ~320KB (Archive) |
| Largest active spec | ~231KB (Design System) |
| Karpathy's scale (wiki fits in context) | ~400K words (~500K tokens) |

**The verdict on "just load all specs":** At 1.1M tokens for active specs alone, this is 5x Claude's 200K context window and at the edge of Gemini 1M. Not feasible for all-in-context today, and recall drops sharply at that scale.

### Analysis Against the Three Alternatives

#### Option A: Keep Current LanceDB Spec-RAG (Status Quo)

**Problems identified:**
- Returns 600-char snippets — far too small for specs that are thousands of words; loses cross-references, table context, related sections
- `all-MiniLM-L6-v2` is a general embedding model not tuned for structured markdown specs
- Returns top-5 chunks with no index awareness — misses structural relationships between spec groups (e.g., spec 3-1 → 4-1 → 5-1 cascade)
- Becomes stale without re-indexing after spec updates
- Opaque failure mode: wrong chunk returned with no signal

**Verdict:** The current implementation has all the classic RAG failure modes. The 339/130 spec count and 1.1M token corpus are in the "RAG might make sense" range, but the implementation is weak.

#### Option B: Full Context Load (1M Window)

**Problems:**
- Active specs at 1.1M tokens exceed Claude 200K. Even Gemini at 1M shows ~60% recall.
- Cost: every query loads the full corpus (~$0.10+ per query, no caching benefit on fresh sessions)
- "Lost in the Middle" effect means specs in the middle of a 1M dump get missed
- Individual large specs (Design System at 231KB ≈ 58K tokens alone) consume significant budget

**Where it could work:** Loading a focused subset (e.g., only specs for a specific feature area: group 1+2, or group 4 design system) fits in 200K comfortably.

**Verdict:** All-or-nothing full-context load is not viable. Selective subset loading is viable.

#### Option C: Karpathy's Wiki Approach Applied to Specs

**The alignment:** gOS specs ARE already a compiled knowledge base. They were designed as the authoritative, interlinked source of truth. The spec hierarchy (0→1→2→3→4→5→6→7→8→9) is already an intentional structure with cascade rules.

**The gap:** There's no index.md that fits in context, no cross-reference maintenance operation, and no lint pass. Specs accumulate but don't compound.

**Applied to gOS:** 
- `specs/INDEX.md` already exists — this IS the Karpathy index
- The missing piece: INDEX.md is not LLM-maintained. It should be auto-updated on every spec change.
- A "lint" operation would check for broken cross-references across specs.
- A "compile" step would generate a condensed summary layer that fits in 200K context.

**Verdict:** The right architecture. Specs already are a wiki. The access layer needs to match.

---

## 4. Recommendation for gOS Spec Access Strategy

### The Right Model: Karpathy-Aligned Hybrid (Tiered Access)

Following the principle: "retrieval-first, long-context containment" + Karpathy's "compile once, query the compiled artifact":

**Tier 1 — Index Load (always):** A maintained `specs/INDEX.md` (~2-5K tokens) loaded every session. Contains one-line summaries + file locations for all 130 active specs. This is the Karpathy `index.md`. The LLM can navigate from here.

**Tier 2 — Selective Full-File Load (on demand):** When a specific spec is needed, load the full file via `get_spec` (already in the MCP). NOT a chunk — the full spec. This solves the chunking disaster problem. A spec is an atom, not a collection of 600-char fragments.

**Tier 3 — Lexical Search Fallback (grep/BM25):** Replace vector search with `ripgrep` or `grep -l` over the specs directory. This is what Claude Code itself does. Zero infrastructure, zero staleness, transparent failures. Find by keyword → load full file.

**Tier 4 — Semantic Search (only if Tier 3 fails):** Keep LanceDB as a last resort for vocabulary mismatch cases (e.g., user says "order book" but spec says "depth feed"). But return full filenames, not snippets. Load the full spec.

### Specific Changes to spec-rag-mcp/server.py

1. Add a `load_index()` tool that returns the full `specs/INDEX.md` content (~the Karpathy index.md)
2. Add a `grep_specs(keyword)` tool using Python `subprocess` + ripgrep — returns matching filenames
3. Change `search_specs` to return full filenames only (not 600-char snippets) — let the caller load the full spec
4. Keep `get_spec()` as-is — this is already correct
5. Remove the 600-char snippet truncation — it's the root cause of context loss

### What to Deprioritize

- Fine-tuning embeddings for spec-specific vocabulary — over-engineering at current scale
- Graph-structured knowledge base — specs already have group hierarchy, no need for a separate graph DB
- Full-context injection at session start — 1.1M tokens is too large; use the index instead

### The Key Insight

Karpathy's insight applied to gOS: **the INDEX.md is the knowledge base**. The individual spec files are the raw sources. The workflow should be:

1. Load INDEX.md (compiled, fits in context)
2. Identify relevant spec files from the index
3. Load those specific files fully
4. For unknown terms, grep → load full file

This is identical to how Karpathy uses his wiki index — and how Claude Code uses its own markdown index files.

---

## 5. Sources

- Karpathy GitHub Gist (original): https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
- X post (April 3, 2026): https://x.com/karpathy/status/2039805659525644595
- VentureBeat coverage: https://venturebeat.com/data/karpathy-shares-llm-knowledge-base-architecture-that-bypasses-rag-with-an
- DAIR.AI Academy analysis: https://academy.dair.ai/blog/llm-knowledge-bases-karpathy
- Atlan: LLM Wiki vs RAG: https://atlan.com/know/llm-wiki-vs-rag-knowledge-base/
- Analytics India Mag: https://analyticsindiamag.com/ai-news/andrej-karpathy-moves-beyond-rag-builds-llm-powered-personal-knowledge-bases
- Akita on Rails (RAG is dead): https://akitaonrails.com/en/2026/04/06/rag-is-dead-long-context/
- RAGFlow 2025 year-end review: https://ragflow.io/blog/rag-review-2025-from-rag-to-context
- Markaicode RAG vs Long Context 2026: https://markaicode.com/vs/rag-vs-long-context/
- Google DeepMind EMNLP 2024 paper: (RAG or Long Context LLMs)
- ACM SIGIR 2025: https://dl.acm.org/doi/10.1145/3726302.3731690
