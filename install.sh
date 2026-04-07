#!/usr/bin/env bash
# gOS Bootstrap — Install all dependencies for a fresh clone
# Usage: ./install.sh          (install everything)
#        ./install.sh --check  (health check only, no installs)
#
# Idempotent: safe to re-run. Skips already-installed tools.

set -euo pipefail

# Toolkit location — shared tools live outside any single project
TOOLKIT="$HOME/Documents/Claude Working Folder/toolkit"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS="${GREEN}✓${NC}"
FAIL="${RED}✗${NC}"
WARN="${YELLOW}!${NC}"
INFO="${CYAN}→${NC}"

CHECK_ONLY=false
ERRORS=0
WARNINGS=0

if [[ "${1:-}" == "--check" ]]; then
    CHECK_ONLY=true
    echo -e "${CYAN}gOS Health Check${NC}"
    echo "================"
else
    echo -e "${CYAN}gOS Bootstrap${NC}"
    echo "=============="
fi

# --- Helpers ---

check_cmd() {
    local name="$1"
    local cmd="$2"
    local version_flag="${3:---version}"

    if "$cmd" "$version_flag" &>/dev/null; then
        local ver
        ver=$("$cmd" "$version_flag" 2>&1 | head -1)
        echo -e "  ${PASS} ${name}: ${ver}"
        return 0
    else
        echo -e "  ${FAIL} ${name}: not found"
        ((ERRORS++))
        return 1
    fi
}

check_path() {
    local name="$1"
    local path="$2"

    if [[ -e "$path" ]]; then
        echo -e "  ${PASS} ${name}: ${path}"
        return 0
    else
        echo -e "  ${FAIL} ${name}: missing (${path})"
        ((ERRORS++))
        return 1
    fi
}

check_dir() {
    local name="$1"
    local path="$2"

    if [[ -d "$path" ]]; then
        local count
        count=$(find "$path" -maxdepth 1 -type f | wc -l | tr -d ' ')
        echo -e "  ${PASS} ${name}: ${path} (${count} files)"
        return 0
    else
        echo -e "  ${FAIL} ${name}: missing (${path})"
        ((ERRORS++))
        return 1
    fi
}

ensure_dir() {
    local path="$1"
    if [[ ! -d "$path" ]]; then
        mkdir -p "$path"
        echo -e "  ${INFO} Created: ${path}"
    fi
}

# --- Detect platform ---

OS=$(uname -s)
ARCH=$(uname -m)
echo -e "\nPlatform: ${OS} ${ARCH}"

# Ensure brew is in PATH (macOS)
if [[ "$OS" == "Darwin" ]]; then
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
fi

# --- 1. Core Runtime ---

echo -e "\n${CYAN}1. Core Runtime${NC}"

check_cmd "Python3" "python3"
check_cmd "Git" "git"

# Node.js — check multiple paths
if command -v node &>/dev/null; then
    check_cmd "Node.js" "node"
elif [[ -x "/usr/local/bin/node" ]]; then
    echo -e "  ${WARN} Node.js: found at /usr/local/bin/node (not in PATH)"
    echo -e "    Add to PATH: export PATH=\"/usr/local/bin:\$PATH\""
    ((WARNINGS++))
elif ! $CHECK_ONLY; then
    echo -e "  ${INFO} Installing Node.js via brew..."
    brew install node
    check_cmd "Node.js" "node"
else
    echo -e "  ${FAIL} Node.js: not found"
    ((ERRORS++))
fi

# npm/npx
if command -v npx &>/dev/null; then
    check_cmd "npx" "npx"
elif [[ -x "/usr/local/bin/npx" ]]; then
    echo -e "  ${WARN} npx: found at /usr/local/bin/npx (not in PATH)"
    ((WARNINGS++))
fi

# gh CLI
if command -v gh &>/dev/null; then
    check_cmd "gh CLI" "gh"
elif ! $CHECK_ONLY; then
    echo -e "  ${INFO} Installing gh CLI via brew..."
    brew install gh
    check_cmd "gh CLI" "gh"
else
    echo -e "  ${FAIL} gh CLI: not found"
    ((ERRORS++))
fi

# --- 2. gOS CLI Tools ---

echo -e "\n${CYAN}2. CLI Tools${NC}"

# OfficeCLI
if [[ -x "$TOOLKIT/officecli" ]]; then
    check_cmd "OfficeCLI" "$TOOLKIT/officecli"
elif ! $CHECK_ONLY; then
    echo -e "  ${INFO} Installing OfficeCLI..."
    mkdir -p "$TOOLKIT"
    if [[ "$ARCH" == "arm64" ]]; then
        OFFICECLI_ASSET="officecli-mac-arm64"
    else
        OFFICECLI_ASSET="officecli-mac-x64"
    fi
    curl -sL -o "$TOOLKIT/officecli" \
        "https://github.com/iOfficeAI/OfficeCLI/releases/latest/download/${OFFICECLI_ASSET}"
    chmod +x "$TOOLKIT/officecli"
    check_cmd "OfficeCLI" "$TOOLKIT/officecli"
else
    echo -e "  ${FAIL} OfficeCLI: not found at ~/bin/officecli"
    ((ERRORS++))
fi

# MiroFish (project engine — check only, no auto-install)
if [[ -d "$TOOLKIT/../MiroFish" ]] || python3 -c "import mirofish" &>/dev/null 2>&1; then
    echo -e "  ${PASS} MiroFish: available"
else
    echo -e "  ${WARN} MiroFish: not found (needed for /simulate market)"
    ((WARNINGS++))
fi

# Dux (separate repo — check only)
if [[ -d "$HOME/Documents/Dux" ]] || [[ -d "../Dux" ]]; then
    echo -e "  ${PASS} Dux: found"
else
    echo -e "  ${WARN} Dux: not found (needed for /simulate scenario)"
    ((WARNINGS++))
fi

# LibreOffice
if command -v soffice &>/dev/null; then
    check_cmd "LibreOffice" "soffice"
elif [[ -x "/Applications/LibreOffice.app/Contents/MacOS/soffice" ]]; then
    echo -e "  ${WARN} LibreOffice: installed but soffice not in PATH"
    ((WARNINGS++))
elif ! $CHECK_ONLY; then
    echo -e "  ${INFO} Installing LibreOffice via brew (this takes a few minutes)..."
    brew install --cask libreoffice
    check_cmd "LibreOffice" "soffice"
else
    echo -e "  ${FAIL} LibreOffice: not found"
    ((ERRORS++))
fi

# --- 3. Directory Structure ---

echo -e "\n${CYAN}3. Directory Structure${NC}"

DIRS=(
    "specs"
    "outputs/think/research"
    "outputs/think/discover"
    "outputs/think/design"
    "outputs/think/decide"
    "outputs/briefings"
    "outputs/gos-jobs"
    "apps/web-prototype"
    "apps/mobile"
    "tools"
    "sessions"
    "memory"
    "Archive"
)

for dir in "${DIRS[@]}"; do
    if $CHECK_ONLY; then
        check_dir "$dir" "$dir"
    else
        ensure_dir "$dir"
        echo -e "  ${PASS} ${dir}"
    fi
done

# --- 4. gOS Core Files ---

echo -e "\n${CYAN}4. gOS Core Files${NC}"

CORE_FILES=(
    "CLAUDE.md"
    ".claude/commands/gos.md"
    ".claude/commands/think.md"
    ".claude/commands/build.md"
    ".claude/commands/review.md"
    ".claude/commands/design.md"
    ".claude/commands/ship.md"
    ".claude/commands/evolve.md"
    ".claude/commands/simulate.md"
    ".claude/commands/refine.md"
    ".claude/agents/README.md"
    ".claude/agents/team-registry.md"
    ".claude/agents/researcher.md"
    ".claude/agents/architect.md"
    ".claude/agents/engineer.md"
    ".claude/agents/reviewer.md"
    ".claude/agents/designer.md"
    ".claude/agents/verifier.md"
    ".claude/skills/financial-modeling/SKILL.md"
    ".claude/skills/design-sync/SKILL.md"
    ".claude/skills/arx-ui-stack/SKILL.md"
    ".claude/settings.json"
    ".claude/launch.json"
    ".mcp.json"
    "tools/MANIFEST.md"
)

for f in "${CORE_FILES[@]}"; do
    check_path "$(basename "$f")" "$f"
done

# --- 5. Python Virtual Environments ---

echo -e "\n${CYAN}5. Python Virtual Environments${NC}"

VENVS=(
    "$TOOLKIT/spec-rag-env"
    "$TOOLKIT/sources-env"
    "$TOOLKIT/notte-env"
)

for venv in "${VENVS[@]}"; do
    if [[ -d "$venv" && -x "$venv/bin/python" ]]; then
        echo -e "  ${PASS} ${venv}"
    elif ! $CHECK_ONLY; then
        echo -e "  ${INFO} Creating ${venv}..."
        python3 -m venv "$venv"
        # Install requirements if they exist
        req_dir="${venv%-env}-mcp"
        if [[ -f "${req_dir}/requirements.txt" ]]; then
            "$venv/bin/pip" install -q -r "${req_dir}/requirements.txt"
            echo -e "  ${PASS} ${venv} (with dependencies)"
        else
            echo -e "  ${PASS} ${venv} (empty — install deps manually)"
        fi
    else
        echo -e "  ${FAIL} ${venv}: missing"
        ((ERRORS++))
    fi
done

# --- 6. MCP Server Dependencies ---

echo -e "\n${CYAN}6. MCP Servers${NC}"

# Hyperliquid MCP
if [[ -f "$TOOLKIT/hyperliquid-mcp/index.js" ]]; then
    if [[ -d "$TOOLKIT/hyperliquid-mcp/node_modules" ]]; then
        echo -e "  ${PASS} Hyperliquid MCP (installed)"
    elif ! $CHECK_ONLY; then
        echo -e "  ${INFO} Installing Hyperliquid MCP deps..."
        (cd "$TOOLKIT/hyperliquid-mcp" && npm install --quiet 2>/dev/null)
        echo -e "  ${PASS} Hyperliquid MCP"
    else
        echo -e "  ${WARN} Hyperliquid MCP: found but node_modules missing"
        ((WARNINGS++))
    fi
else
    echo -e "  ${WARN} Hyperliquid MCP: $TOOLKIT/hyperliquid-mcp/index.js not found"
    ((WARNINGS++))
fi

# Playwright Chromium
if npx playwright install --dry-run chromium &>/dev/null 2>&1; then
    echo -e "  ${PASS} Playwright Chromium"
else
    if ! $CHECK_ONLY; then
        echo -e "  ${INFO} Installing Playwright Chromium..."
        npx playwright install chromium 2>/dev/null || true
        echo -e "  ${PASS} Playwright Chromium"
    else
        echo -e "  ${WARN} Playwright Chromium: may need install"
        ((WARNINGS++))
    fi
fi

# --- 7. Session Files ---

echo -e "\n${CYAN}7. Session State${NC}"

SESSION_FILES=(
    "sessions/scratchpad.md"
    "sessions/evolve_signals.md"
    "memory/MEMORY.md"
)

for f in "${SESSION_FILES[@]}"; do
    if [[ -f "$f" ]]; then
        echo -e "  ${PASS} ${f}"
    elif ! $CHECK_ONLY; then
        touch "$f"
        echo -e "  ${INFO} Created empty: ${f}"
    else
        echo -e "  ${WARN} ${f}: missing (will be created on first /gos)"
        ((WARNINGS++))
    fi
done

# --- 8. Specs ---

echo -e "\n${CYAN}8. Specs${NC}"

if [[ -f "specs/INDEX.md" ]]; then
    SPEC_COUNT=$(find specs -name '*.md' -maxdepth 1 | wc -l | tr -d ' ')
    echo -e "  ${PASS} specs/INDEX.md (${SPEC_COUNT} spec files)"
else
    echo -e "  ${WARN} specs/INDEX.md: missing — copy specs from source or create new"
    ((WARNINGS++))
fi

# --- Summary ---

echo -e "\n${CYAN}Summary${NC}"
echo "======="

if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}All checks passed. gOS is ready.${NC}"
    echo -e "Run ${CYAN}/gos${NC} to start."
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}${WARNINGS} warnings, 0 errors. gOS should work.${NC}"
    echo -e "Run ${CYAN}/gos${NC} to start. Address warnings when convenient."
else
    echo -e "${RED}${ERRORS} errors, ${WARNINGS} warnings.${NC}"
    if $CHECK_ONLY; then
        echo -e "Run ${CYAN}./install.sh${NC} (without --check) to fix."
    else
        echo -e "Some dependencies could not be installed automatically."
        echo -e "Check the errors above and install manually."
    fi
fi

echo ""
