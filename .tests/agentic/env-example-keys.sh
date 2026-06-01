#!/usr/bin/env bash
# TDD test: env-example has >=4 AGENTIC_* keys, each preceded by a ### comment
# Spec: plan lines 348-349
set -euo pipefail

DEVILBOX_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DEVILBOX_DIR"

count=$(grep -c '^AGENTIC_' env-example)
test "$count" -ge 4 || { echo "FAIL: expected >=4 AGENTIC_*, got $count"; exit 1; }
echo "OK: $count AGENTIC_* keys"

while IFS= read -r line_no; do
  prev=$((line_no - 1))
  prev_line=$(sed -n "${prev}p" env-example)
  echo "$prev_line" | grep -qE '^###' || {
    key=$(sed -n "${line_no}p" env-example)
    echo "FAIL: key on line $line_no ('$key') not preceded by ### comment (got: '$prev_line')"
    exit 1
  }
done < <(grep -n '^AGENTIC_' env-example | cut -d: -f1)
echo "OK: every AGENTIC_* preceded by ### comment"

echo "PASS: env-example-keys"
