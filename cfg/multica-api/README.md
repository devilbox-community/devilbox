# cfg/multica-api

This directory is **bind-mounted** into the `multica-api` Wave 8F1 service at:

| Mount target | Mode | Purpose |
|---|---|---|
| `/app/config` | rw | Forward-compat config seed dir (TLS certs, custom auth providers) |

This is a **host-side bind mount** — files placed here survive
`docker compose down -v` and `./dvl.sh agent disable multica`
(unlike Docker named volumes).

## Current usage

The upstream `ghcr.io/multica-ai/multica-backend` image is configured entirely
through environment variables (see the **multica stack (Wave 8F1)** section
of `env-example`). This directory is therefore empty by default and reserved
for future operator-supplied secrets or cert bundles.

## CLI ↔ Stack relationship

The Wave 8C agentic-image **multica CLI** (`agentic_tools/multica/install.yml`,
build arg `MULTICA_SRC=/workspace/multica`) is separate from this stack —
it ships only the local `multica` binary inside the agentic image. When
both stacks are enabled together, the CLI talks to **this** API service
via the URL set in `MULTICA_API_URL` (default
`http://multica-api:4000` for container-to-container traffic on `app_net`).

From the host, the same API is reachable at
`http://${LOCAL_LISTEN_ADDR:-127.0.0.1:}${MULTICA_API_PORT:-4000}`.

## Upstream reference

- Repo:    `github.com/multica-ai/multica`
- Compose: `../multica/docker-compose.selfhost.yml`
- Env:     `../multica/.env.example`
- Docs:    `../multica/SELF_HOSTING.md`
