#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

port="${AGENTIC_OAUTH_PORT:-19999}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required for callback reachability test" >&2
  exit 1
fi

docker compose exec -T --user devilbox agentic sh -c "(printf 'HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK' | nc -l -p 19999 >/dev/null 2>&1) &" 

for _ in 1 2 3 4 5; do
  if curl -fsS "http://127.0.0.1:${port}/" >/dev/null; then
    exit 0
  fi
  sleep 1
done

echo "callback port ${port} is not reachable from host" >&2
exit 1
