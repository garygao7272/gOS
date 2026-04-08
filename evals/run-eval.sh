#!/usr/bin/env bash
# gOS Eval Runner — scores a command execution against its rubric
# Usage: ./run-eval.sh <command-name> <test-input-file> <output-file>
# Or:    ./run-eval.sh <command-name> --score-only <score-json>
#
# This is a lightweight eval framework. No external deps (no promptfoo).
# Rubrics live in evals/rubrics/{command}.md
# Test inputs live in evals/inputs/{command}/*.md
# Scores saved to evals/scores/{command}-{date}.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMAND="${1:-}"
MODE="${2:-}"

if [ -z "$COMMAND" ]; then
  echo "Usage: ./run-eval.sh <command-name> [--list-inputs|--score <input-id> <scores>]"
  echo ""
  echo "Commands with rubrics:"
  for f in "$SCRIPT_DIR/rubrics"/*.md; do
    [ -f "$f" ] || continue
    echo "  $(basename "$f" .md)"
  done
  exit 0
fi

RUBRIC="$SCRIPT_DIR/rubrics/${COMMAND}.md"
if [ ! -f "$RUBRIC" ]; then
  echo "ERROR: No rubric found at $RUBRIC"
  exit 1
fi

INPUTS_DIR="$SCRIPT_DIR/inputs/${COMMAND}"
SCORES_DIR="$SCRIPT_DIR/scores"
mkdir -p "$SCORES_DIR"

case "$MODE" in
  --list-inputs)
    echo "Test inputs for /$COMMAND:"
    if [ -d "$INPUTS_DIR" ]; then
      for f in "$INPUTS_DIR"/*.md; do
        [ -f "$f" ] || continue
        echo "  $(basename "$f" .md): $(head -1 "$f")"
      done
    else
      echo "  (none — create at $INPUTS_DIR/)"
    fi
    ;;

  --score)
    INPUT_ID="${3:-}"
    SPEED="${4:-0}"
    ACCURACY="${5:-0}"
    CONTEXT_PRES="${6:-0}"
    BREVITY="${7:-0}"
    TOTAL=$((SPEED + ACCURACY + CONTEXT_PRES + BREVITY))
    DATE=$(date '+%Y-%m-%d')
    TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

    SCORE_FILE="$SCORES_DIR/${COMMAND}-${DATE}.json"

    # Append to scores array (create if doesn't exist)
    if [ -f "$SCORE_FILE" ]; then
      # Add to existing array
      python3 -c "
import json, sys
with open('$SCORE_FILE') as f:
    data = json.load(f)
data['scores'].append({
    'input_id': '$INPUT_ID',
    'timestamp': '$TIMESTAMP',
    'dimensions': {
        'speed': $SPEED,
        'accuracy': $ACCURACY,
        'context_preservation': $CONTEXT_PRES,
        'brevity': $BREVITY
    },
    'total': $TOTAL,
    'max': 10
})
data['average'] = sum(s['total'] for s in data['scores']) / len(data['scores'])
with open('$SCORE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
print(f'Score: {$TOTAL}/10 (avg: {data[\"average\"]:.1f})')
"
    else
      python3 -c "
import json
data = {
    'command': '/$COMMAND',
    'rubric': '$RUBRIC',
    'date': '$DATE',
    'scores': [{
        'input_id': '$INPUT_ID',
        'timestamp': '$TIMESTAMP',
        'dimensions': {
            'speed': $SPEED,
            'accuracy': $ACCURACY,
            'context_preservation': $CONTEXT_PRES,
            'brevity': $BREVITY
        },
        'total': $TOTAL,
        'max': 10
    }],
    'average': $TOTAL
}
with open('$SCORE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
print(f'Score: {$TOTAL}/10')
"
    fi
    echo "Saved to: $SCORE_FILE"
    ;;

  *)
    echo "Rubric: $RUBRIC"
    echo ""
    cat "$RUBRIC"
    echo ""
    echo "Score with: ./run-eval.sh $COMMAND --score <input-id> <speed> <accuracy> <context> <brevity>"
    ;;
esac
