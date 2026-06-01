#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."
DVL=./dvl.sh

tmp=$(mktemp)
if ${DVL} agent foobar >"${tmp}" 2>&1; then
  echo "expected ./dvl agent foobar to exit 1" >&2
  rm -f "${tmp}"
  exit 1
fi
grep -q 'Unknown agent subcommand: foobar' "${tmp}"

if ${DVL} agent exec >"${tmp}" 2>&1; then
  echo "expected ./dvl agent exec to exit 1" >&2
  rm -f "${tmp}"
  exit 1
fi
grep -q 'Usage: dvl agent exec' "${tmp}"

if ${DVL} agent auth >"${tmp}" 2>&1; then
  echo "expected ./dvl agent auth to exit 1" >&2
  rm -f "${tmp}"
  exit 1
fi
grep -q 'Usage: dvl agent auth' "${tmp}"
rm -f "${tmp}"
