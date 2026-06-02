---
title: Hermes Workspace stack
description: Run Hermes Workspace and Hermes Agent as a layered Devilbox agent stack.
sidebar:
  order: 16
---

Hermes Workspace is an optional Devilbox agent stack that pairs a browser-based
agent command center with the upstream Hermes Agent gateway.

The source repository is expected next to Devilbox at
`../hermes-workspace`. In this checkout the real path is
`/Users/toanguye/Workspace/agentic_data/devilbox-source/hermes-workspace/`.

The Devilbox integration lives in
`compose/docker-compose.override.yml-hermes-workspace`, and `dvl.sh` layers it
through the same `dvl agent enable` mechanism used by the base agentic stack.

## Overview

Hermes Workspace describes itself in `../hermes-workspace/README.md` as an AI
agent command center for chat, files, memory, skills, terminal access, jobs,
MCP, dashboard views, Agent View, Operations, and Swarm Mode.

In Devilbox it is not bundled into the PHP container. It is a separate optional
stack named `hermes-workspace`.

The stack starts two services:

- `hermes-agent`, the upstream agent gateway and dashboard API service.
- `hermes-workspace`, the web UI that talks to that gateway.

The source-of-truth upstream Docker Compose file is
`../hermes-workspace/docker-compose.yml`.

The Devilbox adaptation is
`compose/docker-compose.override.yml-hermes-workspace`.

The sibling repository also contains:

- `../hermes-workspace/package.json` for the React/TanStack/Vite workspace app.
- `../hermes-workspace/src/routes/` for UI routes such as `conductor.tsx`,
  `skills.tsx`, `memory.tsx`, and `profiles.tsx`.
- `../hermes-workspace/src/routes/api/` for server routes such as
  `sessions.ts`, `skills.ts`, `auth.ts`, `models.ts`, and `paths.ts`.
- `../hermes-workspace/swarm.yaml` for the semantic worker roster.
- `../hermes-workspace/docs/swarm/` for Swarm Mode documentation.

## Architecture

The upstream repository separates the UI from the agent runtime. Devilbox keeps
that split.

```text
host browser
  |
  | http://127.0.0.1:${HERMES_WORKSPACE_UI_PORT:-3000}
  v
hermes-workspace container
  | HERMES_API_URL=http://hermes-agent:8642
  | HERMES_DASHBOARD_URL=http://hermes-agent:9119
  v
hermes-agent container
  | gateway :8642
  | dashboard :9119
  v
persistent config under cfg/hermes-workspace
```

The upstream `../hermes-workspace/docker-compose.yml` uses:

- `nousresearch/hermes-agent:latest` for `hermes-agent`.
- `ghcr.io/outsourc-e/hermes-workspace:latest` for `hermes-workspace`.
- A gateway command of `gateway run`.
- Gateway port `8642`.
- Dashboard port `9119`.
- UI port `3000`.

Devilbox mirrors those choices in
`compose/docker-compose.override.yml-hermes-workspace` while adapting them to
the Devilbox network and bind-mount layout.

The `hermes-workspace` service receives static IP `172.16.238.18` on
`app_net`. The paired `hermes-agent` service is reached by Docker DNS as
`hermes-agent`.

The UI depends on the agent health check. The health check probes both:

- `http://localhost:8642/health`
- `http://localhost:9119/api/status`

This means the workspace service waits for both the gateway and dashboard
surface to be healthy before starting.

## Workspace Layout

Important source paths in the sibling repository:

| Path | Purpose |
| --- | --- |
| `../hermes-workspace/README.md` | Upstream overview, quick starts, deployment notes, and troubleshooting. |
| `../hermes-workspace/package.json` | App metadata and scripts such as `dev`, `build`, `start`, `test`, and Electron packaging. |
| `../hermes-workspace/docker-compose.yml` | Upstream two-service Docker setup for `hermes-agent` and `hermes-workspace`. |
| `../hermes-workspace/.env.example` | Upstream environment variable reference for providers, gateway URLs, auth, and security. |
| `../hermes-workspace/src/routes/` | TanStack Start routes for the UI. |
| `../hermes-workspace/src/routes/api/` | API routes used by the UI. |
| `../hermes-workspace/swarm.yaml` | Semantic worker roster for orchestrator, builder, reviewer, QA, researcher, and related roles. |
| `../hermes-workspace/docs/swarm/README.md` | Swarm Mode entry documentation. |
| `../hermes-workspace/docs/docker.md` | Docker-focused upstream notes. |

Important Devilbox paths:

| Path | Purpose |
| --- | --- |
| `compose/docker-compose.override.yml-hermes-workspace` | Devilbox layered stack definition. |
| `.dvl/agent-stacks.list` | Enabled stack list written by `dvl agent enable`. |
| `cfg/hermes-workspace/` | Persistent Hermes home/config shared between the two containers. |
| `data/hermes-workspace/` | Files created through the workspace file browser. |
| `env-example` | Defaults for ports, images, provider keys, and security settings. |

## Integration with Devilbox

The integration uses the `dvl agent` command path in `dvl.sh`.

`dvl agent enable hermes-workspace` validates that
`compose/docker-compose.override.yml-hermes-workspace` exists and then appends
`hermes-workspace` to `.dvl/agent-stacks.list`.

`dvl agent up` exports `COMPOSE_FILE` as the base `docker-compose.yml` plus each
enabled override. No override file is copied into the repository root.

This keeps the stack reversible:

- Disable the layer with `dvl agent disable hermes-workspace`.
- Remove only that layer's services while leaving other Devilbox services alone.
- Keep persistent bind-mounted data under `cfg/` and `data/`.

The stack uses Devilbox conventions:

- Environment variables are defined in `.env`, seeded from `env-example`.
- Ports are published through `${LOCAL_LISTEN_ADDR}`.
- The UI service receives a fixed `app_net` address.
- Persistent state is stored in project directories, not anonymous container
  filesystems.

## Configuration

### Required env vars

At least one LLM provider key should be configured for Hermes Agent to be useful.
The Devilbox `env-example` declares:

```dotenv
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
OPENROUTER_API_KEY=
GOOGLE_API_KEY=
GROQ_API_KEY=
MISTRAL_API_KEY=
```

The upstream `../hermes-workspace/.env.example` documents OpenAI, OpenRouter,
Google, and local providers such as Ollama.

### Service identity

```dotenv
HERMES_WORKSPACE_CONTAINER_NAME=hermes-workspace
HERMES_AGENT_CONTAINER_NAME=hermes-agent
```

These names are used by Docker Compose when the override is layered.

### Ports

```dotenv
HERMES_WORKSPACE_HOST_PORT=8642
HERMES_WORKSPACE_UI_PORT=3000
```

`HERMES_WORKSPACE_HOST_PORT` publishes the agent gateway. The web UI is
published on `HERMES_WORKSPACE_UI_PORT`.

Both are bound with `${LOCAL_LISTEN_ADDR}`. Keep `LOCAL_LISTEN_ADDR=127.0.0.1:`
or another trusted interface unless you have configured authentication and a
reverse proxy.

### Images

```dotenv
HERMES_AGENT_DOCKER_IMAGE=
HERMES_WORKSPACE_DOCKER_IMAGE=
```

When blank, the override uses:

- `nousresearch/hermes-agent:latest`
- `ghcr.io/outsourc-e/hermes-workspace:latest`

Override them only when testing a fork or pinned image.

### Gateway auth

```dotenv
HERMES_API_SERVER_KEY=
```

The override passes this value to `hermes-agent` as `API_SERVER_KEY` and to the
workspace as `HERMES_API_TOKEN`.

If the gateway is exposed beyond loopback, set a strong value.

### UI security

```dotenv
HERMES_PASSWORD=
HERMES_HOST=127.0.0.1
HERMES_COOKIE_SECURE=
HERMES_TRUST_PROXY=
```

The upstream workspace refuses unsafe remote binds unless password protection is
configured. Keep `HERMES_HOST=127.0.0.1` unless you intentionally expose the UI.

### Mount points

| Host path | Container path | Notes |
| --- | --- | --- |
| `cfg/hermes-workspace` | `/opt/data` in `hermes-agent` | Agent config, sessions, skills, memory, credentials. |
| `cfg/hermes-workspace` | `/home/workspace/.hermes` in `hermes-workspace` | Workspace reads the same Hermes home. |
| `data/hermes-workspace` | `/workspace` in `hermes-workspace` | Files created through the file browser. |

These are bind mounts. They survive container recreation and `docker compose down -v`.

## Usage Examples

### Example 1: Start the workspace stack

```bash
cp env-example .env
$EDITOR .env
./dvl.sh agent enable hermes-workspace
./dvl.sh agent up
```

Then open `http://127.0.0.1:3000/` when `HERMES_WORKSPACE_UI_PORT=3000`.

### Example 2: Pin provider keys and keep the UI local

```dotenv
OPENROUTER_API_KEY=sk-or-v1-your-key
HERMES_HOST=127.0.0.1
HERMES_WORKSPACE_UI_PORT=3000
HERMES_WORKSPACE_HOST_PORT=8642
```

This keeps both the UI and gateway on host loopback.

### Example 3: Protect an authenticated gateway

```dotenv
HERMES_API_SERVER_KEY=replace-with-a-long-random-secret
HERMES_PASSWORD=replace-with-a-different-long-random-secret
HERMES_HOST=127.0.0.1
```

The same API server key is passed to the workspace as `HERMES_API_TOKEN`.

### Example 4: Enter the stack for inspection

```bash
./dvl.sh agent status
./dvl.sh agent logs hermes-agent
./dvl.sh agent logs hermes-workspace
```

Use logs when the UI waits for the paired health check.

## Troubleshooting

### `Unknown stack 'hermes-workspace'`

Check that `compose/docker-compose.override.yml-hermes-workspace` exists in the
Devilbox checkout. `dvl.sh` validates stack names by looking for files named
`compose/docker-compose.override.yml-<slug>`.

### UI starts but extended features are missing

Hermes Workspace needs both the gateway and dashboard APIs. Confirm that
`hermes-agent` is healthy:

```bash
./dvl.sh agent logs hermes-agent
```

The upstream README expects `/health` on port `8642` and `/api/status` on port
`9119`.

### Browser cannot reach the UI

Confirm the port mapping:

```bash
./dvl.sh agent status
```

Then check `HERMES_WORKSPACE_UI_PORT` and `LOCAL_LISTEN_ADDR` in `.env`.

### `Unauthorized` responses from the gateway

If `HERMES_API_SERVER_KEY` is set, the workspace must receive the same value as
`HERMES_API_TOKEN`. The Devilbox override wires this automatically from
`HERMES_API_SERVER_KEY`; restart the stack after editing `.env`.

### Remote access fails

Keep the default loopback binding for normal use. For LAN, VPN, or reverse-proxy
access, set `HERMES_PASSWORD`, review `HERMES_COOKIE_SECURE`, and only trust
proxy headers with `HERMES_TRUST_PROXY=1` behind a proxy that sanitizes them.

### Data disappeared after container recreation

The Devilbox stack stores persistent state under `cfg/hermes-workspace` and
`data/hermes-workspace`. If those directories were deleted on the host, the new
containers start with empty state.
