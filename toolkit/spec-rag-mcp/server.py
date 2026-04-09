#!/usr/bin/env python3
"""Spec RAG MCP Server — tiered access over spec files.

Tier 1: load_index() — always-available INDEX.md
Tier 2: get_spec(filename) — full file content, never chunked
Tier 3: grep_specs(keyword) — lexical search via ripgrep, returns filenames
Tier 4: search_specs(query) — semantic search via LanceDB (last resort)
"""

import os
import subprocess
from pathlib import Path

import lancedb
from mcp.server.fastmcp import FastMCP
from sentence_transformers import SentenceTransformer

mcp = FastMCP("spec-rag")

SPECS_DIR = Path(os.getenv("SPECS_DIR", "./specs"))
LANCEDB_DIR = os.getenv("LANCEDB_DIR", "./.lancedb")

_model = None


def _get_model() -> SentenceTransformer:
    global _model
    if _model is None:
        _model = SentenceTransformer("all-MiniLM-L6-v2")
    return _model


def _embed(texts: list[str]) -> list[list[float]]:
    return _get_model().encode(texts).tolist()


def _embed_one(text: str) -> list[float]:
    return _get_model().encode(text).tolist()


@mcp.tool()
def load_index() -> dict:
    """Load the spec INDEX.md — the entry point for navigating all specs. Always call this first."""
    index_path = SPECS_DIR / "INDEX.md"
    if index_path.exists():
        return {"filename": "INDEX.md", "content": index_path.read_text(encoding="utf-8")}
    # Try subdirectories
    for p in SPECS_DIR.rglob("INDEX.md"):
        return {"filename": str(p.relative_to(SPECS_DIR)), "content": p.read_text(encoding="utf-8")}
    return {"error": "INDEX.md not found in specs directory"}


@mcp.tool()
def get_spec(filename: str) -> dict:
    """Retrieve full content of a specific spec file. Specs are atomic — always load the full file, never chunks."""
    spec_path = SPECS_DIR / filename
    if spec_path.exists():
        return {"filename": filename, "content": spec_path.read_text(encoding="utf-8")}
    # Try searching subdirectories
    for p in SPECS_DIR.rglob(filename):
        return {
            "filename": str(p.relative_to(SPECS_DIR)),
            "content": p.read_text(encoding="utf-8"),
        }
    return {"error": f"File not found: {filename}"}


@mcp.tool()
def grep_specs(keyword: str, max_results: int = 10) -> list[dict]:
    """Search spec files by keyword using lexical grep. Returns matching filenames with line context.

    Prefer this over search_specs for most lookups — faster, no false neighbors, transparent results.
    Use search_specs only when you need vocabulary-mismatch tolerance (e.g., searching for a concept
    that may be described with different words).
    """
    try:
        result = subprocess.run(
            ["grep", "-r", "-l", "-i", keyword, str(SPECS_DIR)],
            capture_output=True,
            text=True,
            timeout=10,
        )
        files = [line.strip() for line in result.stdout.strip().split("\n") if line.strip()]
        matches = []
        for filepath in files[:max_results]:
            p = Path(filepath)
            rel = str(p.relative_to(SPECS_DIR)) if p.is_relative_to(SPECS_DIR) else p.name
            # Get first matching line for context
            ctx_result = subprocess.run(
                ["grep", "-i", "-m", "3", keyword, filepath],
                capture_output=True,
                text=True,
                timeout=5,
            )
            context_lines = ctx_result.stdout.strip().split("\n")[:3]
            matches.append({
                "filename": rel,
                "matching_lines": context_lines,
            })
        return matches if matches else [{"message": f"No specs match '{keyword}'"}]
    except FileNotFoundError:
        # grep not available, fall back to Python
        matches = []
        kw_lower = keyword.lower()
        for p in sorted(SPECS_DIR.rglob("*.md")):
            try:
                content = p.read_text(encoding="utf-8")
                if kw_lower in content.lower():
                    rel = str(p.relative_to(SPECS_DIR))
                    lines = [l.strip() for l in content.split("\n") if kw_lower in l.lower()][:3]
                    matches.append({"filename": rel, "matching_lines": lines})
                    if len(matches) >= max_results:
                        break
            except Exception:
                continue
        return matches if matches else [{"message": f"No specs match '{keyword}'"}]
    except Exception as e:
        return [{"error": str(e)}]


@mcp.tool()
def search_specs(query: str, top_k: int = 5) -> list[dict]:
    """Semantic search over spec files via LanceDB embeddings. Returns full filenames — load with get_spec().

    Use grep_specs first for keyword searches. Use this only when you need vocabulary-mismatch tolerance.
    """
    db = lancedb.connect(LANCEDB_DIR)
    try:
        table = db.open_table("specs")
    except Exception:
        return [{"error": "Index not found. Run index_specs first."}]

    query_embedding = _embed_one(query)
    results = table.search(query_embedding).limit(top_k).to_list()

    return [
        {
            "filename": r.get("filename"),
            "group": r.get("group"),
            "summary": r.get("content", "").split("\n")[0][:200],
            "distance": round(r.get("_distance", 0), 4),
        }
        for r in results
    ]


@mcp.tool()
def index_specs() -> dict:
    """Scan specs/ directory (including subdirectories) and index all .md files into LanceDB."""
    db = lancedb.connect(LANCEDB_DIR)
    md_files = sorted(SPECS_DIR.rglob("*.md"))
    errors = []

    contents = []
    metadata = []
    for md_file in md_files:
        try:
            content = md_file.read_text(encoding="utf-8")
            rel_path = str(md_file.relative_to(SPECS_DIR))
            parts = md_file.stem.split("_")
            group = parts[1].split("-")[0] if len(parts) > 1 else "0"
            contents.append(content[:8000])
            metadata.append({
                "filename": rel_path,
                "group": group,
                "content": content,
            })
        except Exception as e:
            errors.append({"file": md_file.name, "error": str(e)})

    embeddings = _embed(contents)
    indexed = [{**meta, "vector": emb} for meta, emb in zip(metadata, embeddings)]

    if indexed:
        db.create_table("specs", data=indexed, mode="overwrite")

    return {
        "status": "success",
        "indexed": len(indexed),
        "total_files": len(md_files),
        "errors": errors if errors else None,
    }


@mcp.tool()
def list_specs() -> list[dict]:
    """List all spec files with their relative paths and sizes. No content loading — just the inventory."""
    specs = []
    for p in sorted(SPECS_DIR.rglob("*.md")):
        rel = str(p.relative_to(SPECS_DIR))
        size = p.stat().st_size
        specs.append({"filename": rel, "size_bytes": size})
    return specs


if __name__ == "__main__":
    mcp.run()
