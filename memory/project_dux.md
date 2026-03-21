---
name: Dux Simulation Engine
description: Building Dux (Latin for leader/guide), a general-purpose all-paths simulation engine in ~/Documents/Claude Working Folder/Dux
type: project
---

**Dux** — general-purpose simulation engine that takes a seed scenario, builds a knowledge graph (Palantir Ontology-inspired), branches into multiple futures (Graph-of-Thoughts), simulates with LLM agents (Concordia-inspired), and finds the best path (MCTS/Beam Search).

**Why:** MiroFish v1 was limited to social media simulation via OASIS. Dux is domain-agnostic — business strategy, product decisions, trading signals, pricing analysis.

**How to apply:** When working in the Dux project, follow the modular architecture: seed/ → ontology/ → branching/ → agents/ → search/ → evaluation/ → orchestrator/. Backend is FastAPI, all tests run with `PYTHONPATH=. pytest backend/tests/`. Phase 6 (frontend) and Phase 7 (publish) are remaining.

Key tech: Python 3.11+, FastAPI, NetworkX (graph store), OpenAI SDK (any compatible LLM), Pydantic v2. No nano-graphrag (dependency issues) — built custom LLM entity extraction instead.

**Status as of 2026-03-18:** Phases 0-5 complete (80 tests passing). Backend engine fully built. Frontend and GitHub publish remaining.
