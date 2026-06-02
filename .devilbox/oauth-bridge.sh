#!/usr/bin/env bash
set -euo pipefail

DEVILBOX_PATH="${DEVILBOX_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
FIFO_DIR="${DVL_OAUTH_FIFO_DIR:-${DEVILBOX_PATH}/.devilbox/oauth-fifo}"
FIFO="${DVL_OAUTH_FIFO:-${FIFO_DIR}/url}"

poller_pid=""
login_pid=""

ensure_fifo() {
  mkdir -p "${FIFO_DIR}"
  if [[ -e "${FIFO}" && ! -p "${FIFO}" ]]; then
    echo "OAuth bridge path exists but is not a FIFO: ${FIFO}" >&2
    return 1
  fi
  [[ -p "${FIFO}" ]] || mkfifo "${FIFO}"
}

host_os() {
  local uname_s
  uname_s="$(uname -s 2>/dev/null || true)"
  if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "wsl"
    return 0
  fi
  case "${uname_s}" in
    Darwin) echo "macos" ;;
    Linux) echo "linux" ;;
    *) echo "unknown" ;;
  esac
}

open_url() {
  local url="$1"
  if [[ "$(host_os)" == "macos" ]]; then
    # Prefer explicit IPv4 loopback for callback URLs; do not rely on localhost
    # resolution because some CLIs hit IPv6 localhost bugs (Claude Code #44844).
    url="${url/localhost/127.0.0.1}"
  fi
  case "$(host_os)" in
    macos)
      open "${url}"
      ;;
    linux)
      xdg-open "${url}"
      ;;
    wsl)
      cmd.exe /c start "" "${url}"
      ;;
    *)
      echo "Unsupported host OS for browser open: $(uname -s)" >&2
      return 1
      ;;
  esac
}

poll_fifo() {
  local mode="${1:-forever}"
  local url

  ensure_fifo
  while IFS= read -r url <"${FIFO}"; do
    [[ -n "${url}" ]] || continue
    open_url "${url}"
    [[ "${mode}" == "once" ]] && break
  done
}

cleanup() {
  trap - INT TERM EXIT
  if [[ -n "${poller_pid}" ]] && kill -0 "${poller_pid}" 2>/dev/null; then
    kill "${poller_pid}" 2>/dev/null || true
  fi
  if [[ -n "${login_pid}" ]] && kill -0 "${login_pid}" 2>/dev/null; then
    kill "${login_pid}" 2>/dev/null || true
  fi
}

compose_exec() {
  (cd "${DEVILBOX_PATH}" && docker compose exec --user devilbox agentic "$@")
}

set_login_command() {
  local tool="$1"
  case "${tool}" in
    claude-code)
      LOGIN_CMD=(claude /login)
      ;;
    opencode)
      LOGIN_CMD=(opencode auth login)
      ;;
    codex)
      LOGIN_CMD=(codex login)
      ;;
    gh-copilot)
      LOGIN_CMD=(gh auth login --web)
      ;;
    aider)
      echo "aider uses env vars; set OPENAI_API_KEY in cfg/agentic/shared/.env" >&2
      return 2
      ;;
    *)
      echo "no auth flow defined for tool ${tool}" >&2
      return 1
      ;;
  esac
}

print_login_command() {
  local tool="$1"
  set_login_command "${tool}" || return $?
  printf '%q ' "${LOGIN_CMD[@]}"
  printf '\n'
}

auth_tool() {
  local tool="$1"
  local status=0
  local -a LOGIN_CMD

  set_login_command "${tool}" || return $?

  ensure_fifo
  trap cleanup INT TERM EXIT
  poll_fifo forever &
  poller_pid="$!"

  if [[ "${tool}" == "opencode" && "$(host_os)" == "macos" ]]; then
    # macOS callback flows should prefer explicit IPv4 loopback; this avoids
    # localhost resolving to IPv6 first (Claude Code #44844 mitigation).
    compose_exec env LOCAL_LISTEN_ADDR=127.0.0.1 "${LOGIN_CMD[@]}" &
  else
    compose_exec "${LOGIN_CMD[@]}" &
  fi
  login_pid="$!"
  wait "${login_pid}" || status="$?"
  login_pid=""

  cleanup
  wait "${poller_pid}" 2>/dev/null || true
  poller_pid=""
  trap - INT TERM EXIT

  return "${status}"
}

case "${1:-}" in
  --poll)
    poll_fifo forever
    ;;
  --poll-once)
    poll_fifo once
    ;;
  --print-login-cmd)
    if [[ -z "${2:-}" ]]; then
      echo "Usage: oauth-bridge.sh --print-login-cmd <tool>" >&2
      exit 1
    fi
    print_login_command "$2"
    ;;
  ""|-h|--help)
    echo "Usage: oauth-bridge.sh <tool>|--poll|--poll-once|--print-login-cmd <tool>" >&2
    exit 1
    ;;
  *)
    auth_tool "$1"
    ;;
esac
