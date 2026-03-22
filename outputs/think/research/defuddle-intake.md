# Defuddle — Intake Summary

> Source: https://github.com/kepano/defuddle
> Author: Steph Ango (kepano) — creator of Obsidian
> Version: 0.14.0 (active development, "work in progress")
> Stars: 5,614 | License: MIT
> Created: 2025-02-27 | Last updated: 2026-03-22

## TL;DR

- TypeScript library that extracts main content from any web page, strips clutter, and returns clean HTML or Markdown
- Created for Obsidian Web Clipper but designed as a standalone, environment-agnostic tool
- Drop-in replacement for Mozilla Readability — more forgiving, better metadata extraction, mobile-style-aware
- Site-specific extractors for YouTube (with transcript via InnerTube API), ChatGPT, Claude, Gemini, Grok, Reddit, Twitter/X, GitHub, HackerNews
- Runs in browser (zero deps), Node.js (any DOM implementation), or CLI (`npx defuddle parse`)

## Key Thesis

Web pages are cluttered with non-content elements (ads, nav, comments, sidebars, footers). Existing solutions like Mozilla Readability are too aggressive — they remove uncertain elements, losing content. Defuddle takes a more forgiving approach: score content blocks, use mobile CSS as a signal for what's decorative, standardize output (footnotes, math, code blocks, headings), and extract rich metadata including schema.org data.

## Structured Breakdown

### 1. Architecture — Three-Layer Content Extraction

**Core pipeline:**

1. **Metadata extraction** — schema.org JSON-LD, Open Graph, meta tags, page-level signals
2. **Site-specific extractors** — pattern-matched classes that override generic parsing for known sites
3. **Generic content extraction** — scoring-based removal of non-content blocks, hidden element pruning, small image filtering

**Extractor registry pattern:** Each site gets a class extending `BaseExtractor` with `canExtract()` (URL matching), `extract()` (sync), and optional `extractAsync()` (for fetching external data like YouTube transcripts). Extractors can declare `prefersAsync()` to bypass sync extraction entirely.

**Key design decision:** If initial parse yields <200 words, automatically retries with `removePartialSelectors: false` — the system self-corrects when it's too aggressive.

### 2. Content Scoring Algorithm

The removal system uses a multi-signal scoring approach:

**Content indicators** (positive signals): `article`, `content`, `entry`, `image`, `figure`, `pre`, `main`, `post`, `story`, `table`

**Navigation indicators** (negative signals): `advertisement`, `cookie`, `comments`, `footer`, `header`, `menu`, `nav`, `newsletter`, `sidebar`, `social`, `sponsored`, `subscribe`, `trending`, etc.

**Additional heuristics:**

- Social profile URL patterns (LinkedIn, Twitter, Facebook, Instagram) used to detect author bios
- Date patterns to detect standalone bylines
- Byline pattern matching (`By [Capitalized Name]`)
- Navigation heading pattern matching against all nav indicators

### 3. Site-Specific Extractors

| Extractor          | What It Does                                                                                                                                                                             |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `youtube.ts`       | Extracts transcripts via InnerTube API (Android client context), DOM scraping, or async fetch. Groups segments by 20-second gaps, merges short utterances. Supports language preference. |
| `chatgpt.ts`       | Extracts ChatGPT conversation threads                                                                                                                                                    |
| `claude.ts`        | Extracts Claude conversation threads                                                                                                                                                     |
| `gemini.ts`        | Extracts Gemini conversation threads                                                                                                                                                     |
| `grok.ts`          | Extracts Grok conversation threads                                                                                                                                                       |
| `reddit.ts`        | Extracts Reddit posts and comments                                                                                                                                                       |
| `twitter.ts`       | Extracts tweets/threads                                                                                                                                                                  |
| `x-article.ts`     | Extracts X (Twitter) long-form articles                                                                                                                                                  |
| `github.ts`        | Extracts GitHub content (READMEs, issues, etc.)                                                                                                                                          |
| `hackernews.ts`    | Extracts HN discussions                                                                                                                                                                  |
| `_conversation.ts` | Base class for all AI chat extractors                                                                                                                                                    |

**YouTube is the most sophisticated extractor** — it hits YouTube's InnerTube API directly (using Android client context to get caption track URLs), supports language selection via BCP 47 tags, and has three fallback strategies: existing DOM transcript → InnerTube fetch → DOM interaction to open transcript panel.

### 4. HTML Standardization

Before output, Defuddle normalizes HTML for consistent downstream processing:

- **Headings:** First H1/H2 removed if it matches title. All H1s converted to H2s. Anchor links in headings stripped.
- **Code blocks:** Standardized syntax highlighting markers
- **Footnotes:** Consistent format for inline references and footnote lists
- **Callouts/admonitions:** Standardized container format
- **Math:** MathML ↔ LaTeX conversion (full bundle only, uses `temml` and `mathml-to-latex`)

### 5. Markdown Conversion

Uses Turndown internally with custom rules:

- Smart `srcset` parsing — picks best resolution image from responsive image sources
- Handles CDN URLs with commas in paths (e.g., Substack's `w_424,c_limit,f_webp`)
- Table detection with `isDirectTableChild` to prevent nested table issues

### 6. Bundle Strategy

| Bundle                 | Use Case       | Size    | Dependencies                   |
| ---------------------- | -------------- | ------- | ------------------------------ |
| Core (`defuddle`)      | Browser        | Minimal | Zero runtime deps              |
| Full (`defuddle/full`) | Browser + math | Larger  | `mathml-to-latex`, `temml`     |
| Node (`defuddle/node`) | Server-side    | Full    | Needs linkedom/JSDOM/happy-dom |

Only runtime dependency is `commander` (for CLI). Everything else is dev dependencies.

### 7. CLI Interface

```bash
npx defuddle parse <url-or-file> [--markdown] [--json] [--property <name>] [--output <file>]
```

Can parse both local HTML files and remote URLs. Debug mode available. Language preference via `--lang`.

## Quantitative Insights

| Metric                  | Value         | Context                                    |
| ----------------------- | ------------- | ------------------------------------------ |
| GitHub stars            | 5,614         | High adoption for a utility library        |
| Version                 | 0.14.0        | Active development, pre-1.0                |
| Runtime deps            | 1 (commander) | Extremely lightweight                      |
| Site extractors         | 13            | Covers major content platforms             |
| Content retry threshold | 200 words     | Auto-retries if too aggressive             |
| YouTube transcript gap  | 20 seconds    | Groups segments by silence gaps            |
| Turn merge max words    | 80            | Short utterances merged into previous turn |

## Concepts Explained

**InnerTube API:** YouTube's internal API that powers the mobile and web clients. Defuddle uses the Android client context (`ANDROID` client name) to bypass restrictions that affect browser-based API calls. This gets raw caption track URLs that can be fetched server-side without browser cookies.

**Content scoring:** A heuristic system that assigns positive or negative scores to DOM blocks based on class names, IDs, and text content. Blocks scoring below a threshold are removed as "non-content" (navigation, ads, sidebars). Defuddle's scoring is deliberately more forgiving than Readability's — it keeps uncertain elements rather than removing them.

**BCP 47:** The IETF standard for language tags (e.g., `en`, `en-US`, `zh-Hans-CN`). Defuddle uses this for language preference in both transcript extraction and content parsing.

**Turndown:** A popular HTML-to-Markdown converter for JavaScript. Defuddle wraps it with custom rules for images, tables, and code blocks.

**schema.org:** A structured data vocabulary used by search engines. Web pages embed JSON-LD scripts with schema.org markup for articles, products, events, etc. Defuddle extracts this as rich metadata alongside traditional meta tags.

## Complementary Context

- **vs Mozilla Readability:** Readability is battle-tested (used in Firefox Reader View) but more aggressive — it removes elements it's unsure about. Defuddle keeps them. Readability also doesn't extract schema.org data or support site-specific extractors.
- **vs Firecrawl:** Firecrawl is a hosted service that renders pages with a headless browser then extracts content. Defuddle runs client-side or server-side without a headless browser — it works on already-loaded DOM. Complementary tools: Firecrawl for fetching, Defuddle for parsing.
- **vs Jina Reader:** Jina's reader API is hosted and rate-limited. Defuddle is self-hosted with no API dependency.
- **Obsidian connection:** Created by Steph Ango (CEO of Obsidian). Built for Obsidian Web Clipper but deliberately decoupled — pure library with no Obsidian dependency.
- **AI chat extractors:** The inclusion of ChatGPT, Claude, Gemini, and Grok extractors suggests growing demand for clipping AI conversations into knowledge management tools.

## Actionable Takeaways

1. **Potential Arx tool integration:** Defuddle's YouTube transcript extraction via InnerTube API is a cleaner, zero-dependency alternative to `youtube-transcript-api` Python package. Could replace or complement existing intake pipeline tools.

2. **Content extraction for intelligence feeds:** The library's ability to extract clean content from any URL — with site-specific handling for Reddit, Twitter/X, HN — could power Arx's signal intelligence pipeline (news intake, social sentiment).

3. **CLI for quick intake:** `npx defuddle parse <url> --markdown` is a one-liner replacement for multi-step Firecrawl scraping in simple cases. Zero setup, zero API keys.

4. **Extractor pattern is extensible:** The BaseExtractor → site-specific extractor pattern could be adopted for Arx's own content processing pipeline. Adding a new site is one file implementing `canExtract()` and `extract()`.

5. **Mobile CSS heuristic is novel:** Using a page's mobile styles to detect decorative elements is a clever signal that other content extractors don't use. Worth noting for any future content parsing work.

## Implications for Arx

- **Intake skill improvement:** Could integrate `defuddle` as a Node.js content extraction step in the `/think intake` pipeline, especially for its superior YouTube transcript handling and AI chat conversation extraction
- **Signal processing:** Clean content extraction is a prerequisite for LLM-based signal analysis. Defuddle's standardized output (consistent footnotes, headings, code blocks) reduces preprocessing before feeding to models
- **Competitive intelligence:** The Reddit, Twitter/X, and HackerNews extractors could feed into Arx's community sentiment monitoring pipeline
