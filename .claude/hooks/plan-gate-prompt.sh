#!/bin/bash
# Plan Gate — UserPromptSubmit edition
# Event: UserPromptSubmit
# Injects a terse routing + response-structure reminder when the user's prompt
# starts with a gOS verb (slash command). This moves Plan Gate enforcement
# from Claude's attention to the harness — the model cannot "forget" to
# structure the response because the context is injected before drafting.
#
# Protocol:
#   stdin  → JSON: { prompt, session_id, ... }
#   stdout → additional context prepended to the user prompt
#   exit 0 → allow through
#   exit 2 → block (stderr is the block reason)

set -euo pipefail

INPUT="$(cat)"
PROMPT="$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || echo "")"

# Only act on gOS verb commands — leave other prompts untouched.
FIRST_TOKEN="$(printf '%s' "$PROMPT" | awk '{print tolower($1)}')"

case "$FIRST_TOKEN" in
  /gos|/think|/design|/build|/review|/ship|/simulate|/evolve|/refine)
    cat <<'GATE'
─── Plan Gate (harness-injected) ─────────────────────────────────────────────
This prompt starts with a gOS verb. Before acting, structure your response
using the direct-response format defined in ~/.claude/output-styles/direct-response.md:

  1. ANSWER    — root mechanism first (not symptom, not "like X")
  2. DECOMPOSE — break into parts (table/list)
  3. SOLUTIONS — concrete actions, ordered
  4. WRAP      — CONFIDENCE + WHY + NEXT

Output routing rule (outputs/think/decide/output-routing-rule.md):
  - Default: inline. Write a file only when content must outlive this session.
  - File triggers: cross-session retrieval, handoff to another verb, persistent
    contract, >300 words with reusable structure, audit/staleness tracking.
  - Hybrid: when you emit a file, also emit ≤100-word inline summary with path.
    Never dump file content into chat.

For complex verbs (/build, /design, /ship without args), run Plan Gate:
  PLAN → STEPS → MEMORY search → RISK → CONFIDENCE → Confirm?
  Skip only if Gary says "just do it" or the task is trivially atomic.
──────────────────────────────────────────────────────────────────────────────
GATE
    ;;
  *)
    # Non-verb prompt → no injection
    ;;
esac

exit 0
