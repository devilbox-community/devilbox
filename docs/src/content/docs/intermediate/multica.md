---
title: Multica stack
description: Run the Multica managed-agents platform as a layered Devilbox agent stack.
sidebar:
  order: 17
---

Multica is an optional Devilbox stack for managed coding agents. It provides a
web application, Go backend, PostgreSQL database with pgvector, and daemon/CLI
workflow for assigning real tasks to AI agents.

The source repository is expected next to Devilbox at `../multica`. In this
checkout the real path is
`/Users/toanguye/Workspace/agentic_data/devilbox-source/multica/`.

The Devilbox integration lives in `compose/docker-compose.override.yml-multica`.

## Overview

The upstream `../multica/README.md` describes Multica as an open-source managed
agents platform where coding agents become teammates: they receive issues, post
progress, report blockers, update status, and reuse skills.

In Devilbox, Multica is an optional stack named `multica`. It is separate from
the base PHP services and separate from the `agentic` tool container.

Enable it when you want a persistent board and runtime coordination layer for
agents such as Claude Code, Codex, GitHub Copilot CLI, OpenClaw, OpenCode,
Hermes, Gemini, Pi, Cursor Agent, Kimi, or Kiro CLI.

The source-of-truth upstream files include:

- `../multica/README.md` for product overview and quick install.
- `../multica/SELF_HOSTING.md` for self-host deployment.
- `../multica/docker-compose.selfhost.yml` for the three-service local stack.
- `../multica/.env.example` for backend, frontend, auth, upload, and daemon
  configuration.
- `../multica/CLI_INSTALL.md` for CLI installation and daemon startup.
- `../multica/SELF_HOSTING_AI.md` for an agent-readable self-host setup.

## What it does

Multica is not a model provider. It is a coordination layer.

The platform gives teams:

- Workspaces that isolate issues, agents, skills, and members.
- Issues that can be assigned to humans or agents.
- Agent profiles with provider, runtime, instructions, environment, args, MCP,
  concurrency, and skills.
- Runtime reporting from local daemons.
- WebSocket-driven task progress.
- Comments, reactions, inbox notifications, projects, labels, and pins.
- Autopilots that create and route work from schedules or webhooks.
- Reusable skills that compound agent behavior over time.

The upstream `../multica/docs/product-overview.md` maps these concepts to
tables and features, including `workspace`, `agent`, `issue`, `comment`,
`agent_task_queue`, `skill`, `autopilot`, and `chat_session`.

For Devilbox users, the key distinction is:

- The Multica web/API/database stack runs in Devilbox.
- The Multica CLI in the agentic image can talk to that stack when both stacks
  are enabled.
- Agent CLIs still need to exist in the runtime where tasks execute.

## Architecture

The upstream self-host stack in `../multica/docker-compose.selfhost.yml` has
three services:

| Upstream service | Devilbox service | Role |
| --- | --- | --- |
| `postgres` | `multica-db` | PostgreSQL 17 with pgvector. |
| `backend` | `multica-api` | Go REST and WebSocket backend on container port `8080`. |
| `frontend` | `multica-web` | Next.js frontend on container port `3000`. |

Devilbox adapts that into `compose/docker-compose.override.yml-multica`:

```text
browser
  |
  | http://127.0.0.1:${MULTICA_WEB_PORT:-3001}
  v
multica-web
  |
  | Docker DNS / browser-derived API URL
  v
multica-api :8080
  |
  | postgres://multica-db:5432/${MULTICA_DB_NAME:-multica}
  v
multica-db
```

The `multica-web` service receives static IP `172.16.238.19` on `app_net`.
`multica-api` and `multica-db` use Docker DNS names on the same network.

The database is not published to the host. The API is published on loopback by
default through `MULTICA_API_PORT`. The frontend is published on loopback by
default through `MULTICA_WEB_PORT`.

## Integration with Devilbox

The integration uses the `dvl agent` stack layer system.

```bash
./dvl.sh agent enable multica
./dvl.sh agent up
```

`dvl.sh` writes the enabled slug to `.dvl/agent-stacks.list` and exports
`COMPOSE_FILE` as the base compose file plus enabled override files.

The stack is intentionally named `multica` even though it creates three
services. The user-facing service is `multica-web`, which owns the static IP.

The `env-example` section for Multica records:

- Upstream source: `github.com/multica-ai/multica`.
- Enable command: `./dvl.sh agent enable multica`.
- Static IP: `172.16.238.19`.
- Services: `multica-db`, `multica-api`, and `multica-web`.
- Persistence: `data/multica-db`, `cfg/multica-uploads`, and config seed dirs.

If the `agentic` stack is also enabled, the `multica` CLI inside that image can
be configured to reach the API using Docker DNS:

```dotenv
MULTICA_API_URL=http://multica-api:8080
```

Use the container port `8080`, not the host-side `MULTICA_API_PORT`, for
container-to-container traffic.

## Configuration

### Service names

```dotenv
MULTICA_WEB_CONTAINER_NAME=multica-web
MULTICA_API_CONTAINER_NAME=multica-api
MULTICA_DB_CONTAINER_NAME=multica-db
```

These names mirror the service roles and make logs/status easy to read.

### Ports

```dotenv
MULTICA_WEB_PORT=3001
MULTICA_API_PORT=4000
```

The web port defaults to `3001` because `3000` is used by Hermes Workspace when
that stack is enabled. The API port defaults to `4000` on the host, while the
container still listens on `8080`.

### Images

```dotenv
MULTICA_IMAGE_TAG=latest
MULTICA_DB_DOCKER_IMAGE=pgvector/pgvector:pg17
MULTICA_API_DOCKER_IMAGE=ghcr.io/multica-ai/multica-backend
MULTICA_WEB_DOCKER_IMAGE=ghcr.io/multica-ai/multica-web
```

These mirror the upstream self-host defaults. Pin `MULTICA_IMAGE_TAG` to a
release such as `v0.2.4` when you need reproducibility.

### Database

```dotenv
MULTICA_DB_NAME=multica
MULTICA_DB_USER=multica
MULTICA_DB_PASSWORD=multica
```

Change `MULTICA_DB_PASSWORD` for any deployment that is more than a throwaway
local test.

### Application and auth

```dotenv
MULTICA_APP_ENV=production
MULTICA_JWT_SECRET=change-me-in-production
MULTICA_DEV_VERIFICATION_CODE=
```

`MULTICA_JWT_SECRET` signs sessions. Generate a strong value before using the
stack for real work. `MULTICA_DEV_VERIFICATION_CODE` is ignored by production
mode in upstream self-host guidance.

### Public URLs

```dotenv
MULTICA_PUBLIC_URL=
MULTICA_APP_URL=
MULTICA_FRONTEND_ORIGIN=
MULTICA_NEXT_PUBLIC_API_URL=
MULTICA_NEXT_PUBLIC_WS_URL=
```

Leave these blank for the local loopback setup. Set them when running behind a
reverse proxy, CDN, or custom domain.

### Email and OAuth

The upstream `.env.example` supports Resend, SMTP, and Google OAuth. Devilbox
maps those settings through `MULTICA_`-prefixed variables such as:

- `MULTICA_RESEND_API_KEY`
- `MULTICA_RESEND_FROM_EMAIL`
- `MULTICA_SMTP_HOST`
- `MULTICA_SMTP_PORT`
- `MULTICA_SMTP_USERNAME`
- `MULTICA_SMTP_PASSWORD`
- `MULTICA_GOOGLE_CLIENT_ID`
- `MULTICA_GOOGLE_CLIENT_SECRET`
- `MULTICA_GOOGLE_REDIRECT_URI`

Without email configured, upstream self-host docs say verification codes are
printed to backend logs for local/private testing.

### Mount points

| Host path | Container path | Purpose |
| --- | --- | --- |
| `data/multica-db` | `/var/lib/postgresql/data` | PostgreSQL data. |
| `cfg/multica-db` | `/docker-entrypoint-initdb.d` | Optional first-boot database init scripts. |
| `cfg/multica-uploads` | `/app/data/uploads` | Local upload storage for attachments. |
| `cfg/multica-api` | `/app/config` | Forward-compatible API config seed directory. |

These are bind mounts. They survive `docker compose down -v` because they are
host directories, not Docker named volumes.

## Usage Examples

### Example 1: Start Multica locally

```bash
cp env-example .env
$EDITOR .env
./dvl.sh agent enable multica
./dvl.sh agent up
```

Open `http://127.0.0.1:3001/` when `MULTICA_WEB_PORT=3001`.

### Example 2: Harden secrets before real usage

```bash
openssl rand -base64 48
```

Then set:

```dotenv
MULTICA_JWT_SECRET=generated-value
MULTICA_DB_PASSWORD=another-generated-value
```

Restart the stack after editing `.env`.

### Example 3: Connect the agentic CLI to the Multica stack

Enable both stacks:

```bash
./dvl.sh agent enable agentic multica
./dvl.sh agent up
```

Keep the default in `.env`:

```dotenv
MULTICA_API_URL=http://multica-api:8080
```

Then enter the agentic container and use the Multica CLI:

```bash
./dvl.sh agent shell
multica daemon status
```

### Example 4: Inspect login codes in local self-host mode

If Resend and SMTP are unset, inspect backend logs:

```bash
./dvl.sh agent logs multica-api
```

The upstream self-host guide documents generated verification codes in backend
logs for local testing.

## Troubleshooting

### `Unknown stack 'multica'`

Confirm `compose/docker-compose.override.yml-multica` exists. `dvl.sh` only
lists stack slugs for matching files under `compose/`.

### Web UI loads but API calls fail

Check `MULTICA_FRONTEND_ORIGIN`, `MULTICA_APP_URL`, and any explicit
`MULTICA_NEXT_PUBLIC_API_URL` or `MULTICA_NEXT_PUBLIC_WS_URL`. For the default
localhost setup, leave the optional client overrides blank.

### Backend cannot reach PostgreSQL

Inspect the database health check:

```bash
./dvl.sh agent logs multica-db
./dvl.sh agent logs multica-api
```

The API builds `DATABASE_URL` from `MULTICA_DB_USER`, `MULTICA_DB_PASSWORD`,
`MULTICA_DB_NAME`, and Docker DNS host `multica-db`.

### Login email never arrives

Set either Resend variables or SMTP variables. For local testing, leave email
providers unset and read the generated verification code from `multica-api`
logs as documented in upstream `SELF_HOSTING.md`.

### Agent daemon reports no CLIs

The upstream CLI docs expect at least one supported agent CLI on `PATH`, such as
`claude`, `codex`, `copilot`, `opencode`, `openclaw`, `hermes`, `gemini`, `pi`,
or `cursor-agent`. Enable the agentic tool container or install a CLI in the
daemon runtime.

### Data disappeared

The Devilbox integration stores database and upload state in host bind mounts:
`data/multica-db` and `cfg/multica-uploads`. If those directories are removed,
the stack boots as a fresh install.
