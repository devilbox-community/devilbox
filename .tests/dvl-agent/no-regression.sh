#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."
DVL=./dvl.sh
help_output="$(${DVL} help || true)"

while IFS= read -r branch; do
  [[ -z "${branch}" ]] && continue
  grep -Fq -- "${branch})" dvl.sh || { echo "missing case branch: ${branch}" >&2; exit 1; }
done < .tests/dvl-agent/.baseline-branches

while IFS= read -r command; do
  [[ -z "${command}" ]] && continue
  grep -Eq "^[[:space:]]*${command}(\(|[[:space:]])" <<<"${help_output}" || { echo "missing help command: ${command}" >&2; exit 1; }
done < .tests/dvl-agent/.baseline-usage

agentic_defaults=$(python3 - <<'PY'
from pathlib import Path
lines=Path('dvl.sh').read_text().splitlines()
print(sum(1 for i,line in enumerate(lines,1) if 200 < i < 320 and '"agentic"' in line))
PY
)
[[ "${agentic_defaults}" == "0" ]]
