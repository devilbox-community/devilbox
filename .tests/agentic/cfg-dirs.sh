#!/usr/bin/env bash
# TDD test: 14 cfg/agentic-* dirs each have README.md (non-empty) and .gitkeep
# Spec: plan lines 345-347
set -euo pipefail

DEVILBOX_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DEVILBOX_DIR"

expected=14
count=$(ls -d cfg/agentic-*/ 2>/dev/null | wc -l | tr -d ' ')
test "$count" -eq "$expected" || { echo "FAIL: expected $expected dirs, found $count"; exit 1; }
echo "OK: $count cfg/agentic-* dirs exist"

for d in cfg/agentic-*/; do
  test -s "$d/README.md" || { echo "FAIL: $d/README.md missing or empty"; exit 1; }
  test -f "$d/.gitkeep" || { echo "FAIL: $d/.gitkeep missing"; exit 1; }
done
echo "OK: every dir has non-empty README.md + .gitkeep"

bad_ns=$(printf 'devilbox%sagentic' '/')
leftovers=$(grep -l "$bad_ns" cfg/agentic-*/README.md 2>/dev/null || true)
test -z "$leftovers" || { echo "FAIL: wrong-namespace leftovers: $leftovers"; exit 1; }
echo "OK: no wrong-namespace leftovers"

echo "PASS: cfg-dirs"
