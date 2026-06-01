#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

tmpdir=$(mktemp -d)
cleanup() {
  rm -rf "${tmpdir}"
}
trap cleanup EXIT

mockbin="${tmpdir}/bin"
fifo_dir="${tmpdir}/oauth-fifo"
mkdir -p "${mockbin}" "${fifo_dir}"
mkfifo "${fifo_dir}/url"

cat >"${mockbin}/open" <<'MOCK'
#!/usr/bin/env sh
printf 'open %s\n' "$*" >>"${DVL_OAUTH_OPEN_LOG}"
MOCK
cat >"${mockbin}/xdg-open" <<'MOCK'
#!/usr/bin/env sh
printf 'xdg-open %s\n' "$*" >>"${DVL_OAUTH_OPEN_LOG}"
MOCK
cat >"${mockbin}/cmd.exe" <<'MOCK'
#!/usr/bin/env sh
printf 'cmd.exe %s\n' "$*" >>"${DVL_OAUTH_OPEN_LOG}"
MOCK
chmod +x "${mockbin}/open" "${mockbin}/xdg-open" "${mockbin}/cmd.exe"

export DEVILBOX_PATH="$(pwd)"
export DVL_OAUTH_FIFO_DIR="${fifo_dir}"
export DVL_OAUTH_OPEN_LOG="${tmpdir}/open.log"
export PATH="${mockbin}:${PATH}"

.devilbox/oauth-bridge.sh --poll-once &
poller=$!

printf '%s\n' 'https://example.com' >"${fifo_dir}/url"
wait "${poller}"

test -s "${DVL_OAUTH_OPEN_LOG}"
grep -Eq '^(open|xdg-open|cmd\.exe .*start) https://example\.com$' "${DVL_OAUTH_OPEN_LOG}"
