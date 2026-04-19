# Output Discipline — Visual and structural aids (companion)

> Extracted from [output-discipline.md](./output-discipline.md) to keep the main rule file lean. The main rule file summarizes; this file holds the full catalog of visual tools, the reach-for rule, Mermaid guidance, and anti-patterns. Load this file when deciding how to visualize a section or when authoring a spec that would benefit from diagrams.

**Covers:** the catalog · reach-for rule · Mermaid support · anti-patterns.

## The catalog

Reading fatigue comes from dense prose carrying load that a visual aid would carry better. Every artifact longer than fifty lines has opportunities where structure compresses what prose would belabour. This catalog names the available tools, when each one earns its place, and when to avoid it.

| Tool | What it carries | Use when | Avoid when |
|---|---|---|---|
| **Table** | Parallel comparison across shared columns | Rows have shared attributes; columns earn their width | Every cell in column 1 is a label for column 2 — rewrite as key-value prose |
| **Numbered list** | Sequence where order matters | Process steps, ranked priorities, ordered dependencies | Items are parallel but unordered (use bullets or table) |
| **Bulleted list** | Truly parallel items, order-agnostic | Three to seven items of the same kind | Items differ in kind (use table); order matters (number them) |
| **Definition list** | Term-to-definition pairs | Glossaries, primitive names, acronym expansions | Prose would flow (use sentences) |
| **ASCII flow diagram** | Lightweight process, decision tree, branching | Three to ten nodes, must render in any viewer | Ten-plus nodes (move to Mermaid) |
| **Mermaid flowchart** | Process with branches, rendered in-viewer | Modern viewer renders it; logic has more than ten nodes | Legacy viewer strips the code block (keep ASCII fallback) |
| **Mermaid sequence diagram** | Interactions between two or more parties over time | Protocol, handshake, API call flow between actors | Single-actor process (use flowchart) |
| **Mermaid state diagram** | States and transitions | Finite state machines, workflow states, session lifecycle | Continuous process (use flowchart) |
| **Mermaid mindmap** | Hierarchical decomposition of a topic | Discovery brainstorm, domain decomposition | Linear narrative (use prose) |
| **Two-by-two matrix** | Categorization by two dimensions | Impact × effort, invariant × variant, decisive × suggestive, urgency × importance | One dimension dominates (use list or score) |
| **Tree / hierarchy** | Top-down decomposition | Org charts, file trees, dependency stacks | Lateral relations (use graph) |
| **Admonition (NOTE / WARN / TIP)** | Exceptional callout inline | Cross-cutting warning, reader trap, important caveat | Routine information (integrate as prose) |
| **Code block (triple-backtick)** | Exact syntax, commands, config | Shell commands, JSON, YAML, file excerpts, sample output | Prose example (use inline backticks) |
| **Inline code (backticks)** | File paths, variables, keywords | Single-token references in running prose | Multi-line content (use code block) |
| **Bold emphasis** | Scan anchors for first-read | Key terms, final verdicts, "load-bearing" names | Every paragraph (noise) |
| **Status markers (✓ ✗ ⚠ 🔴 🟠 🟡 🟢)** | Binary or tiered state in tables | Scorecards, compliance tables, severity columns | Body prose (distracting) |
| **Footnotes and appendix** | Sources, deep detail, trace material | Research citations, cycle-by-cycle history | Content the main reader needs (move up) |

## The reach-for rule

If a reader would grasp something faster from a visual than a paragraph, and the visual fits in ten ASCII lines, include the ASCII version. If the visual needs more than ten lines of structure, use Mermaid and keep a one-line ASCII summary alongside as a fallback for renderers that strip the code block.

A concrete example of the reach-for test: a decision with three branches and five terminal outcomes is faster read as a small ASCII tree than as three paragraphs of "if X, then Y; if not X and Z, then W." A decision with two branches is faster read as prose.

## Mermaid support in gOS

gOS artifacts can use Mermaid code blocks. Modern viewers render them — GitHub, GitLab, VSCode, most IDEs, Claude Code. For the viewer-strips-it case, include a short ASCII or prose summary alongside the Mermaid block so readers without rendering still understand the shape.

**Preferred Mermaid types for gOS artifacts:**

| Type | Use for |
|---|---|
| `flowchart` | Decision logic, branching processes, pipelines |
| `sequenceDiagram` | Actor interactions, API call sequences, protocol handshakes |
| `stateDiagram-v2` | State machines, workflow states, session lifecycle |
| `mindmap` | Discovery brainstorms, domain decomposition, concept maps |

Avoid `gantt` (over-structured for spec prose), `pie` (data belongs in a real chart), `er` (entity relations belong in a schema file).

## Anti-patterns

- **Table of tables.** Nested tables are unreadable; split into parallel sections instead.
- **Emoji decoration.** One or two scan markers per document is fine; emoji in every heading is noise.
- **Images and PNGs in specs.** Can't lint, can't diff, break in plain-text viewers. Use Mermaid or ASCII.
- **Animated GIFs.** Distraction from spec content. If a visual demo matters, link to a video file in an appendix.
- **Flowchart where prose would flow.** A three-step process is prose; a ten-step branching process is a flowchart.
- **Bullets where a table earns columns.** If every bullet has the same sub-structure, it wants to be a table.

## How to use this file

Open it when planning the visual shape of a spec section, when deciding whether to reach for a Mermaid diagram, or when auditing an artifact for over-visualization (too many diagrams carrying too little load). For ordinary authorship, the summary in the main output-discipline rule is sufficient.
