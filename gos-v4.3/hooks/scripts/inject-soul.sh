#!/bin/bash
# ═══════════════════════════════════════════════════════════
# gOS Soul Injection (SessionStart hook)
# Injects core gOS identity, execution pipeline, and reference
# files into every session. Similar to Vercel plugin's
# inject-claude-md.mjs but for gOS.
# ═══════════════════════════════════════════════════════════

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(dirname "$0")")")}"
REF_DIR="$PLUGIN_ROOT/reference"

# Only inject if reference directory exists
if [ ! -d "$REF_DIR" ]; then
    exit 0
fi

# Build the injection payload
cat << 'HEADER'
# gOS — Active Session Context

> Injected by gOS plugin SessionStart hook. This is the system identity and execution pipeline.

HEADER

# Inject the soul file (gOS.md) — the core identity
if [ -f "$REF_DIR/gOS.md" ]; then
    cat "$REF_DIR/gOS.md"
    echo ""
    echo "---"
    echo ""
fi

# Inject trust ladder (critical for pipeline)
if [ -f "$REF_DIR/trust-ladder.md" ]; then
    cat "$REF_DIR/trust-ladder.md"
    echo ""
    echo "---"
    echo ""
fi

# Inject shared ontology (shorthand resolution)
if [ -f "$REF_DIR/shared-ontology.md" ]; then
    cat "$REF_DIR/shared-ontology.md"
    echo ""
    echo "---"
    echo ""
fi

# Inject output contract (quality rubric)
if [ -f "$REF_DIR/output-contract.md" ]; then
    cat "$REF_DIR/output-contract.md"
    echo ""
    echo "---"
    echo ""
fi

# Inject artifact schema (output format)
if [ -f "$REF_DIR/artifact-schema.md" ]; then
    cat "$REF_DIR/artifact-schema.md"
    echo ""
    echo "---"
    echo ""
fi

# Inject confidence calibration
if [ -f "$REF_DIR/confidence-calibration.md" ]; then
    cat "$REF_DIR/confidence-calibration.md"
    echo ""
    echo "---"
    echo ""
fi

# Inject context map (keyword → source mapping)
if [ -f "$REF_DIR/context-map.md" ]; then
    cat "$REF_DIR/context-map.md"
    echo ""
fi
