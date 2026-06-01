#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."
baseline=$(<.tests/dvl-agent/.baseline-warnings)
tmp=$(mktemp)
shellcheck -S warning -e SC1090,SC1091 dvl.sh >"${tmp}" 2>&1 || true
warnings=$(grep -c '(warning):' "${tmp}" || true)
rm -f "${tmp}"

if (( warnings > baseline )); then
  echo "shellcheck warnings ${warnings} exceed baseline ${baseline}" >&2
  exit 1
fi
