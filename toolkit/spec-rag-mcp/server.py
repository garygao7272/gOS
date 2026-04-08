#!/usr/bin/env python3
"""Arx Spec RAG MCP Server — semantic search over 65+ spec files using LanceDB + sentence-transformers."""

import os
from pathlib import Path

import lancedb
from mcp.server.fastmcp import FastMCP
from sentence_transformers import SentenceTransformer

mcp = FastMCP("arx-spec-rag")

SPECS_DIR = Path(os.getenv("SPECS_DIR", "./specs"))
LANCEDB_DIR = os.getenv("LANCEDB_DIR", "./.lancedb")

# Load model once at startup (25MB, runs on CPU)
_model = None


def _get_model():
    global _model
    if _model is None:
        _model = SentenceTransformer("all-MiniLM-L6-v2")
    return _model


def _embed(texts: list[str]) -> list[list[float]]:
    return _get_model().encode(texts).tolist()


def _embed_one(text: str) -> list[float]:
    return _get_model().encode(text).tolist()


@mcp.tool()
def search_specs(query: str, top_k: int = 5) -> list[dict]:
    """Search Arx spec files with semantic similarity. Returns top K matching specs."""
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
            "snippet": r.get("content", "")[:600],
            "distance": round(r.get("_distance", 0), 4),
        }
        for r in results
    ]


@mcp.tool()
def index_specs() -> dict:
    """Scan specs/ directory and index all .md files into LanceDB for semantic search."""
    db = lancedb.connect(LANCEDB_DIR)
    md_files = sorted(SPECS_DIR.glob("*.md"))
    errors = []

    contents = []
    metadata = []
    for md_file in md_files:
        try:
            content = md_file.read_text(encoding="utf-8")
            parts = md_file.stem.split("_")
            group = parts[1].split("-")[0] if len(parts) > 1 else "0"
            contents.append(content[:8000])
            metadata.append({"filename": md_file.name, "group": group, "content": content})
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
def get_spec(filename: str) -> dict:
    """Retrieve full content of a specific spec file by filename."""
    spec_path = SPECS_DIR / filename
    if spec_path.exists():
        return {"filename": filename, "content": spec_path.read_text(encoding="utf-8")}
    return {"error": f"File not found: {filename}"}


if __name__ == "__main__":
    mcp.run()
