#!/usr/bin/env bash
# Validate cfg/agentic/ subdirectories each have README.md (non-empty) and .gitkeep
set -euo pipefail

DEVILBOX_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DEVILBOX_DIR"

count=$(find cfg/agentic -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
test "$count" -ge 8 || { echo "FAIL: expected >=8 cfg/agentic/ subdirs, found $count"; exit 1; }
echo "OK: $count cfg/agentic/ subdirs exist"

for d in cfg/agentic/*/; do
  test -s "$d/README.md" || { echo "FAIL: $d/README.md missing or empty"; exit 1; }
  test -f "$d/.gitkeep" || { echo "FAIL: $d/.gitkeep missing"; exit 1; }
done
echo "OK: every dir has non-empty README.md + .gitkeep"

bad_ns=$(printf 'devilbox%sagentic' '/')
leftovers=$(grep -l "$bad_ns" cfg/agentic/*/README.md 2>/dev/null || true)
test -z "$leftovers" || { echo "FAIL: wrong-namespace leftovers: $leftovers"; exit 1; }
echo "OK: no wrong-namespace leftovers"

echo "PASS: cfg-dirs"
