#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."
DVL=./dvl.sh

tmp=$(mktemp)
if ${DVL} agent >"${tmp}" 2>&1; then
  echo "expected ./dvl agent to exit 1" >&2
  rm -f "${tmp}"
  exit 1
fi
grep -q 'dvl agent' "${tmp}"
grep -q 'Subcommands:' "${tmp}"
rm -f "${tmp}"

${DVL} agent help | grep -q 'Subcommands:'
${DVL} help | grep -E '^[[:space:]]*agent[[:space:]]'
${DVL} --no-ansi | grep -E '^[[:space:]]*agent[[:space:]]'
