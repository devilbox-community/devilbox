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

config_out="$(docker compose config 2>/dev/null)"

# 3. agentic service must pin to 172.16.238.17.
echo "$config_out" | grep -qE '172\.16\.238\.17' || { echo "FAIL: 172.16.238.17 not in config"; exit 1; }
echo "OK: agentic IP 172.16.238.17 present"

# 4. Image must come from devilboxcommunity/agentic namespace.
img="$(echo "$config_out" | grep -Eo 'devilboxcommunity/agentic:[A-Za-z0-9._-]+' | head -1)"
test -n "$img" || { echo "FAIL: image not devilboxcommunity/agentic:*"; exit 1; }
echo "OK: agentic image = $img"

echo "PASS: compose-validate"
