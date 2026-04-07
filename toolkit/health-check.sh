#!/bin/bash
# ═══════════════════════════════════════════════════════════
# MCP Health Check
# Checks connectivity for all configured MCP servers
# Usage: ./tools/health-check.sh
# ═══════════════════════════════════════════════════════════

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ONLINE=0
TOTAL=0
RESULTS=""

check() {
    local name="$1"
    local test_cmd="$2"
    TOTAL=$((TOTAL + 1))

    if eval "$test_cmd" > /dev/null 2>&1; then
        ONLINE=$((ONLINE + 1))
        RESULTS="$RESULTS\n  [ok]  $name"
    else
        RESULTS="$RESULTS\n  [!!]  $name"
    fi
}

echo "MCP Health Check"
echo ""

# HTTP-based servers
check "Slack"       "curl -s --max-time 5 -o /dev/null -w '%{http_code}' https://slack.mcp.anthropic.com/mcp | grep -q '200\|401\|405'"
check "GitHub"      "curl -s --max-time 5 -o /dev/null -w '%{http_code}' https://api.githubcopilot.com/mcp/ | grep -q '200\|401\|405'"
check "Sentry"      "curl -s --max-time 5 -o /dev/null -w '%{http_code}' https://mcp.sentry.dev/mcp | grep -q '200\|401\|405'"

# stdio-based servers (check if binary/runtime exists)
check "Hyperliquid" "[ -f '$PROJECT_DIR/tools/hyperliquid-mcp/index.js' ] && command -v node"
check "Playwright"  "command -v npx"
check "Discord"     "command -v npx"
check "Telegram"    "command -v npx"

# Python venv servers
check "Notte"       "[ -f '$PROJECT_DIR/tools/notte-env/bin/python' ]"
check "Spec-RAG"    "[ -f '$PROJECT_DIR/tools/spec-rag-env/bin/python' ] && [ -f '$PROJECT_DIR/tools/spec-rag-mcp/server.py' ]"

# Plugin-provided (check plugin dirs exist)
check "Vercel"      "command -v vercel || true"

echo -e "$RESULTS"
echo ""
echo "  $ONLINE/$TOTAL online"
echo ""

if [ "$ONLINE" -lt "$TOTAL" ]; then
    echo "  Some MCPs unavailable. Run 'claude mcp' to check details."
fi
