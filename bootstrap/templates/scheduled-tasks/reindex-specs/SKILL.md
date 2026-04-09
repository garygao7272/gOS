---
name: reindex-specs
description: Re-index all spec files into LanceDB for semantic search after any spec changes
---

Re-index the Arx spec files for semantic search. Run the spec-rag MCP's index_specs() tool to rebuild the LanceDB vector index from all markdown files in specs/. Report how many files were indexed and any errors. If the index count differs from the previous run, note which files were added or removed by comparing filenames.