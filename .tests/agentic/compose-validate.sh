#!/usr/bin/env bash
# TDD test: agentic compose override validates against docker compose
# Usage: bash devilbox/.tests/agentic/compose-validate.sh
set -euo pipefail

DEVILBOX_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DEVILBOX_DIR"

cleanup() {
  rm -f .env docker-compose.override.yml
}
trap cleanup EXIT

cp env-example .env

# 1. Without override file: default Devilbox still valid (zero regression).
docker compose config -q
echo "OK: default config valid (no override)"

# 2. With override file copied to repo root: must validate.
cp compose/docker-compose.override.yml-agentic docker-compose.override.yml
docker compose config -q
echo "OK: config valid with agentic override"

# 3. agentic service must pin to 172.16.238.17.
ip="$(docker compose config | awk '/^  agentic:/,/^  [a-z]/' | grep -Eo '172\.16\.238\.17' | head -1)"
test "$ip" = "172.16.238.17" || { echo "FAIL: expected 172.16.238.17, got '$ip'"; exit 1; }
echo "OK: agentic IP = $ip"

# 4. Image must come from devilboxcommunity/agentic namespace.
img="$(docker compose config | awk '/^  agentic:/,/^  [a-z]/' | grep -Eo 'devilboxcommunity/agentic:[A-Za-z0-9._-]+' | head -1)"
test -n "$img" || { echo "FAIL: image not devilboxcommunity/agentic:*"; exit 1; }
echo "OK: agentic image = $img"

echo "PASS: compose-validate"
