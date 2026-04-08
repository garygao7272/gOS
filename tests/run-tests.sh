#!/usr/bin/env bash
# gOS Test Runner — runs all BATS tests
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0
SKIP=0

echo "═══════════════════════════════════════"
echo "  gOS Test Suite"
echo "═══════════════════════════════════════"
echo ""

# Check BATS is installed
if ! command -v bats &>/dev/null; then
  echo "ERROR: bats-core not installed. Run: brew install bats-core"
  exit 1
fi

# Run hook tests
echo "── Hook Tests ──"
for test_file in "$SCRIPT_DIR"/hooks/*.bats; do
  [ -f "$test_file" ] || continue
  name=$(basename "$test_file" .bats)
  echo ""
  echo "Testing: $name"
  if bats "$test_file"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
  fi
done

# Run install tests (if they exist)
if [ -d "$SCRIPT_DIR/install" ]; then
  echo ""
  echo "── Install Tests ──"
  for test_file in "$SCRIPT_DIR"/install/*.bats; do
    [ -f "$test_file" ] || continue
    name=$(basename "$test_file" .bats)
    echo ""
    echo "Testing: $name"
    if bats "$test_file"; then
      PASS=$((PASS + 1))
    else
      FAIL=$((FAIL + 1))
    fi
  done
fi

echo ""
echo "═══════════════════════════════════════"
echo "  Results: $PASS passed, $FAIL failed"
echo "═══════════════════════════════════════"

[ "$FAIL" -eq 0 ] || exit 1
