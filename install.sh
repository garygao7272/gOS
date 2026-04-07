#!/usr/bin/env bash
# gOS Bootstrap & Installer
#
# Usage:
#   ./install.sh                         Health check only (default)
#   ./install.sh --install               Install tools (no project wiring)
#   ./install.sh --bootstrap <dir>       Full replication into target project
#   ./install.sh --bootstrap             Interactive (asks for project dir)
#
# Run from inside the gOS repo clone.

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GOS_DIR="$SCRIPT_DIR"
WORKING_DIR="$(dirname "$GOS_DIR")"
TOOLKIT="$WORKING_DIR/toolkit"

# ── Colors ──────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
PASS="${GREEN}✓${NC}"; FAIL="${RED}✗${NC}"; WARN="${YELLOW}!${NC}"; INFO="${CYAN}→${NC}"

ERRORS=0; WARNINGS=0; INSTALLED=0

# ── Helpers ─────────────────────────────────────────────────────
check_cmd() {
    local name="$1" cmd="$2" flag="${3:---version}"
    if "$cmd" "$flag" &>/dev/null; then
        local ver; ver=$("$cmd" "$flag" 2>&1 | head -1)
        echo -e "  ${PASS} ${name}: ${ver}"; return 0
    else
        echo -e "  ${FAIL} ${name}: not found"; ((ERRORS++)); return 1
    fi
}

install_cmd() {
    local name="$1" install_fn="$2"
    echo -e "  ${INFO} Installing ${name}..."
    eval "$install_fn"
    ((INSTALLED++))
}

# ── Parse Args ──────────────────────────────────────────────────
MODE="check"
TARGET_DIR=""

case "${1:-}" in
    --bootstrap) MODE="bootstrap"; TARGET_DIR="${2:-}" ;;
    --install)   MODE="install" ;;
    --check|-c)  MODE="check" ;;
    "")          MODE="check" ;;
    *)           echo "Unknown: $1. Usage: ./install.sh [--check|--install|--bootstrap <dir>]"; exit 1 ;;
esac

# ── Header ──────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}gOS Installer${NC} — $(uname -s) $(uname -m)"
echo -e "${DIM}Mode: ${MODE}  |  gOS: ${GOS_DIR}  |  Toolkit: ${TOOLKIT}${NC}"
echo "────────────────────────────────────────────────"

[[ "$(uname -s)" == "Darwin" ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# ════════════════════════════════════════════════════════════════
# PHASE 1: Core Runtime
# ════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}1. Core Runtime${NC}"

check_cmd "Python3" "python3" || true
check_cmd "Git" "git" || true

if command -v node &>/dev/null; then check_cmd "Node.js" "node" || true
elif [[ "$MODE" != "check" ]]; then install_cmd "Node.js" "brew install node"
else echo -e "  ${FAIL} Node.js: not found"; ((ERRORS++)); fi

command -v npx &>/dev/null && check_cmd "npx" "npx" || true
if command -v gh &>/dev/null; then check_cmd "gh CLI" "gh" || true
elif [[ "$MODE" != "check" ]]; then install_cmd "gh CLI" "brew install gh"
else echo -e "  ${FAIL} gh CLI: not found"; ((ERRORS++)); fi

# ════════════════════════════════════════════════════════════════
# PHASE 2: CLI Tools
# ════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}2. CLI Tools${NC}"

mkdir -p "$TOOLKIT" 2>/dev/null || true

if [[ -x "$TOOLKIT/officecli" ]]; then
    check_cmd "OfficeCLI" "$TOOLKIT/officecli"
elif [[ "$MODE" != "check" ]]; then
    ARCH=$(uname -m)
    [[ "$ARCH" == "arm64" ]] && ASSET="officecli-mac-arm64" || ASSET="officecli-mac-x64"
    install_cmd "OfficeCLI" "curl -sL -o '$TOOLKIT/officecli' 'https://github.com/iOfficeAI/OfficeCLI/releases/latest/download/$ASSET' && chmod +x '$TOOLKIT/officecli'"
else
    echo -e "  ${FAIL} OfficeCLI: not found"; ((ERRORS++))
fi

if command -v soffice &>/dev/null; then check_cmd "LibreOffice" "soffice"
elif [[ "$MODE" != "check" ]]; then install_cmd "LibreOffice" "brew install --cask libreoffice"
else echo -e "  ${WARN} LibreOffice: not found (optional)"; ((WARNINGS++)); fi

[[ -d "$WORKING_DIR/MiroFish" ]] && echo -e "  ${PASS} MiroFish" || { echo -e "  ${WARN} MiroFish: not found"; ((WARNINGS++)); }
[[ -d "$WORKING_DIR/Dux" ]] && echo -e "  ${PASS} Dux" || { echo -e "  ${WARN} Dux: not found"; ((WARNINGS++)); }

# ════════════════════════════════════════════════════════════════
# PHASE 3: Toolkit MCP Servers
# ════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}3. Toolkit MCP Servers${NC}"

for mcp_dir in hyperliquid-mcp spec-rag-mcp sources-mcp; do
    if [[ -d "$TOOLKIT/$mcp_dir" ]]; then
        echo -e "  ${PASS} $mcp_dir"
    elif [[ -d "$GOS_DIR/toolkit/$mcp_dir" && "$MODE" != "check" ]]; then
        cp -R "$GOS_DIR/toolkit/$mcp_dir" "$TOOLKIT/"
        echo -e "  ${INFO} Installed $mcp_dir"; ((INSTALLED++))
    else
        echo -e "  ${FAIL} $mcp_dir: missing"; ((ERRORS++))
    fi
done

[[ -f "$TOOLKIT/stitch-proxy.mjs" ]] && echo -e "  ${PASS} stitch-proxy" || {
    [[ -f "$GOS_DIR/toolkit/stitch-proxy.mjs" && "$MODE" != "check" ]] && cp "$GOS_DIR/toolkit/stitch-proxy.mjs" "$TOOLKIT/" && echo -e "  ${INFO} Installed stitch-proxy" || echo -e "  ${WARN} stitch-proxy: missing"; ((WARNINGS++))
}

[[ -d "$TOOLKIT/hyperliquid-mcp/node_modules" ]] && echo -e "  ${PASS} hyperliquid deps" || {
    [[ -f "$TOOLKIT/hyperliquid-mcp/package.json" && "$MODE" != "check" ]] && install_cmd "hyperliquid deps" "(cd '$TOOLKIT/hyperliquid-mcp' && npm install --quiet 2>/dev/null)" || { echo -e "  ${WARN} hyperliquid deps: missing"; ((WARNINGS++)); }
}

# ════════════════════════════════════════════════════════════════
# PHASE 4: Python Environments
# ════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}4. Python Environments${NC}"

for venv_name in spec-rag-env sources-env notte-env; do
    mcp_name="${venv_name%-env}-mcp"
    if [[ -d "$TOOLKIT/$venv_name" && -x "$TOOLKIT/$venv_name/bin/python" ]]; then
        echo -e "  ${PASS} $venv_name"
    elif [[ "$MODE" != "check" ]]; then
        python3 -m venv "$TOOLKIT/$venv_name"
        for req_path in "$TOOLKIT/$mcp_name/requirements.txt" "$GOS_DIR/toolkit/$mcp_name/requirements.txt"; do
            if [[ -f "$req_path" ]]; then
                "$TOOLKIT/$venv_name/bin/pip" install -q -r "$req_path"
                break
            fi
        done
        echo -e "  ${PASS} $venv_name (created)"; ((INSTALLED++))
    else
        echo -e "  ${FAIL} $venv_name: missing"; ((ERRORS++))
    fi
done

# ════════════════════════════════════════════════════════════════
# PHASE 5: Bootstrap (--bootstrap mode only)
# ════════════════════════════════════════════════════════════════
if [[ "$MODE" == "bootstrap" ]]; then
    echo -e "\n${CYAN}${BOLD}5. Bootstrap — Wire gOS into Project${NC}"

    if [[ -z "$TARGET_DIR" ]]; then
        echo -e "\n  Where is your project?"
        echo -e "  ${DIM}Example: $WORKING_DIR/Arx${NC}"
        echo -en "  ${BOLD}Project dir:${NC} "
        read -r TARGET_DIR
    fi

    TARGET_DIR="${TARGET_DIR/#\~/$HOME}"
    mkdir -p "$TARGET_DIR"
    echo -e "  ${INFO} Target: $TARGET_DIR\n"

    # Commands
    echo -e "  ${CYAN}Commands${NC}"
    mkdir -p "$TARGET_DIR/.claude/commands"
    for f in "$GOS_DIR"/commands/*.md; do
        [[ -f "$f" ]] || continue
        cp "$f" "$TARGET_DIR/.claude/commands/"
        echo -e "    ${PASS} $(basename "$f")"
    done

    # Agents
    echo -e "  ${CYAN}Agents${NC}"
    mkdir -p "$TARGET_DIR/.claude/agents"
    for f in "$GOS_DIR"/agents/*.md; do
        [[ -f "$f" ]] || continue
        cp "$f" "$TARGET_DIR/.claude/agents/"
        echo -e "    ${PASS} $(basename "$f")"
    done

    # Skills
    echo -e "  ${CYAN}Skills${NC}"
    for skill_dir in "$GOS_DIR"/skills/*/; do
        [[ -d "$skill_dir" ]] || continue
        name=$(basename "$skill_dir")
        mkdir -p "$TARGET_DIR/.claude/skills/$name"
        cp "$skill_dir"* "$TARGET_DIR/.claude/skills/$name/" 2>/dev/null
        echo -e "    ${PASS} $name"
    done

    # Core .claude files
    echo -e "  ${CYAN}Core Files${NC}"
    mkdir -p "$TARGET_DIR/.claude/rules" "$TARGET_DIR/.claude/middleware"
    for f in gOS.md self-model.md launch.json; do
        [[ -f "$GOS_DIR/.claude/$f" ]] && cp "$GOS_DIR/.claude/$f" "$TARGET_DIR/.claude/" && echo -e "    ${PASS} $f"
    done
    [[ -f "$GOS_DIR/settings/settings.json" ]] && cp "$GOS_DIR/settings/settings.json" "$TARGET_DIR/.claude/settings.json" && echo -e "    ${PASS} settings.json"
    if [[ ! -f "$TARGET_DIR/.claude/settings.local.json" ]]; then
        cp "$GOS_DIR/settings/settings.local.template.json" "$TARGET_DIR/.claude/settings.local.json"
        echo -e "    ${PASS} settings.local.json (from template)"
    else
        echo -e "    ${WARN} settings.local.json exists — skipped"
    fi
    for f in "$GOS_DIR"/rules/arx/*.md; do
        [[ -f "$f" ]] && cp "$f" "$TARGET_DIR/.claude/rules/" && echo -e "    ${PASS} rules/$(basename "$f")"
    done

    # .mcp.json
    echo -e "  ${CYAN}.mcp.json${NC}"
    if [[ -f "$GOS_DIR/toolkit/mcp-template.json" ]]; then
        sed "s|__TOOLKIT__|$TOOLKIT|g" "$GOS_DIR/toolkit/mcp-template.json" > "$TARGET_DIR/.mcp.json"
        echo -e "    ${PASS} .mcp.json (paths resolved to $TOOLKIT)"
    fi

    # CLAUDE.md
    [[ -f "$GOS_DIR/CLAUDE.md" ]] && cp "$GOS_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md" && echo -e "    ${PASS} CLAUDE.md"

    # Directories
    echo -e "  ${CYAN}Directories${NC}"
    for dir in specs outputs/think/research outputs/think/discover outputs/think/design outputs/think/decide outputs/briefings outputs/gos-jobs apps/web-prototype apps/mobile tools sessions memory Archive; do
        mkdir -p "$TARGET_DIR/$dir"
    done
    echo -e "    ${PASS} 13 directories"

    # Memory
    echo -e "  ${CYAN}Memory${NC}"
    for f in "$GOS_DIR"/memory/*.md; do
        [[ -f "$f" ]] || continue
        cp "$f" "$TARGET_DIR/memory/"
        echo -e "    ${PASS} $(basename "$f")"
    done

    # Session state
    [[ -f "$TARGET_DIR/sessions/scratchpad.md" ]] || echo "# Session State" > "$TARGET_DIR/sessions/scratchpad.md"
    [[ -f "$TARGET_DIR/sessions/evolve_signals.md" ]] || echo "# Evolve Signals" > "$TARGET_DIR/sessions/evolve_signals.md"
    echo -e "    ${PASS} session files"

    # Manifest
    [[ -f "$GOS_DIR/toolkit/MANIFEST.md" ]] && cp "$GOS_DIR/toolkit/MANIFEST.md" "$TARGET_DIR/tools/MANIFEST.md" && echo -e "    ${PASS} MANIFEST.md"

    # ── Verification ────────────────────────────────────────────
    echo -e "\n  ${CYAN}${BOLD}Verification${NC}"
    CMD_COUNT=$(find "$TARGET_DIR/.claude/commands" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    AGENT_COUNT=$(find "$TARGET_DIR/.claude/agents" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    SKILL_COUNT=$(find "$TARGET_DIR/.claude/skills" -maxdepth 2 -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' ')
    MEM_COUNT=$(find "$TARGET_DIR/memory" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')

    for f in ".claude/commands/gos.md" ".claude/agents/README.md" ".claude/settings.json" ".mcp.json" "CLAUDE.md" "memory/MEMORY.md"; do
        [[ -f "$TARGET_DIR/$f" ]] && echo -e "    ${PASS} $f" || { echo -e "    ${FAIL} $f"; ((ERRORS++)); }
    done
    echo -e "\n  ${BOLD}Installed:${NC} ${CMD_COUNT} commands, ${AGENT_COUNT} agents, ${SKILL_COUNT} skills, ${MEM_COUNT} memory files"
fi

# ════════════════════════════════════════════════════════════════
# Summary + Guided Manual Steps
# ════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}${BOLD}═══ Summary ═══${NC}"

if [[ "$MODE" == "bootstrap" ]]; then
    echo -e "${GREEN}${BOLD}Bootstrap complete.${NC} Project: ${TARGET_DIR}"
    echo ""
    echo -e "${CYAN}${BOLD}Step-by-Step: Complete Your Setup${NC}"
    echo ""
    echo -e "${BOLD}Step 1: Connect Claude Code Plugins${NC}"
    echo -e "  Open Claude Code in your terminal, then run these commands:"
    echo -e "  ${DIM}(Each will open a browser for OAuth — approve and return)${NC}"
    echo ""
    echo "    claude"
    echo "    /mcp                    # Opens MCP manager"
    echo "    # Connect each: Figma, Vercel, Linear, Shadcn UI, Gmail"
    echo "    # For Chrome: install Claude in Chrome extension from Chrome Web Store"
    echo ""
    echo -e "${BOLD}Step 2: Set API Keys${NC}"
    echo -e "  Add to your ~/.zshrc (or ~/.bashrc):"
    echo ""
    echo "    # Required"
    echo "    export GITHUB_TOKEN=\"ghp_your_token_here\""
    echo ""
    echo "    # Optional (enable as needed)"
    echo "    export DISCORD_TOKEN=\"your_discord_bot_token\""
    echo "    export TELEGRAM_API_ID=\"your_telegram_id\""
    echo "    export TELEGRAM_API_HASH=\"your_telegram_hash\""
    echo "    export NOTTE_API_KEY=\"your_notte_key\""
    echo "    export STITCH_API_KEY=\"your_stitch_key\""
    echo "    export SUPADATA_API_KEY=\"your_supadata_key\""
    echo ""
    echo "  Then: source ~/.zshrc"
    echo ""
    echo -e "${BOLD}Step 3: Copy Project Content${NC}"
    echo -e "  These are project-specific — not stored in gOS repo:"
    echo ""
    echo "    # Specs (96 files) — copy from backup or previous machine"
    echo "    cp -R /path/to/backup/specs/ ${TARGET_DIR}/specs/"
    echo ""
    echo "    # Apps — clone your app repos"
    echo "    git clone <prototype-repo> ${TARGET_DIR}/apps/web-prototype"
    echo "    git clone <mobile-repo> ${TARGET_DIR}/apps/mobile"
    echo ""
    echo "    # Design system — regenerate"
    echo "    cd ${TARGET_DIR} && claude"
    echo "    /design system sync"
    echo ""
    echo -e "${BOLD}Step 4: Clone Sister Projects${NC} (if needed)"
    echo ""
    echo "    git clone <dux-repo> ${WORKING_DIR}/Dux"
    echo "    git clone <mirofish-repo> ${WORKING_DIR}/MiroFish"
    echo ""
    echo -e "${BOLD}Step 5: Verify${NC}"
    echo ""
    echo "    cd ${TARGET_DIR}"
    echo "    claude"
    echo "    /gos              # Should show: 'Gary. Here's where we are...'"
    echo "    /gos status       # Should show all green"
    echo ""
    echo -e "  ${DIM}If /gos reports issues, run: cd ${GOS_DIR} && ./install.sh --check${NC}"
    echo ""
elif [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}All checks passed. gOS is ready.${NC}"
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}${WARNINGS} warnings, 0 errors. gOS should work.${NC}"
else
    echo -e "${RED}${ERRORS} errors, ${WARNINGS} warnings.${NC}"
    echo -e "Run ${CYAN}./install.sh --install${NC} to install tools, or ${CYAN}./install.sh --bootstrap <dir>${NC} for full setup."
fi

echo ""
