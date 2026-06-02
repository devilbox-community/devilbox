---
title: "Add your own Docker image"
---

# Add your own Docker image

Add custom services with Compose override files. Keep the base
`docker-compose.yml` unchanged.

## Choose an override strategy

Use one of these approaches:

1. Add a local `docker-compose.override.yml` in the repository root.
2. Copy or create a reusable file under `compose/docker-compose.override.yml-*`.
3. Enable optional agent-style stacks through `CONTAINERS_CONFIG_OPTIONAL`.

:::tip
Existing optional containers are documented in
[Enable all container](/custom-container/enable-all-container/). Agentic
tool stacks are covered by
[Agentic tools toggle](/getting-started/agentic-tools-toggle/).
:::

## Minimal service

Create `docker-compose.override.yml`:

```yaml
services:
  mailpit:
    image: axllent/mailpit:latest
    restart: unless-stopped
    ports:
      - "127.0.0.1:8025:8025"
    networks:
      app_net:
        ipv4_address: 172.16.238.240
    depends_on:
      - bind
      - httpd
      - php
```

Start it:

```bash
docker compose up -d mailpit
```

Open the UI:

```bash
open http://127.0.0.1:8025
```

:::caution
Pick an unused IP from the Devilbox `app_net` subnet in `docker-compose.yml`.
Do not reuse an address already assigned to a core service.
:::

## Build your own image

Create a service directory:

```bash
mkdir -p docker/custom-node
```

Add `docker/custom-node/Dockerfile`:

```dockerfile
FROM node:22-alpine

RUN apk add --no-cache bash git openssh-client

WORKDIR /workspace

CMD ["sleep", "infinity"]
```

Add the service to `docker-compose.override.yml`:

```yaml
services:
  custom-node:
    build:
      context: ./docker/custom-node
    working_dir: /shared/httpd
    volumes:
      - ${HOST_PATH_HTTPD_DATADIR:-./data/www}:/shared/httpd${MOUNT_OPTIONS:-}
    networks:
      app_net:
        ipv4_address: 172.16.238.241
    depends_on:
      - bind
      - httpd
      - php
```

Build and start it:

```bash
docker compose build custom-node
docker compose up -d custom-node
```

Enter the container:

```bash
docker compose exec custom-node bash
```

## Debian-based example

Use Debian when you need glibc or apt packages:

```dockerfile
FROM debian:bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["sleep", "infinity"]
```

Reference it from Compose the same way:

```yaml
services:
  custom-debian:
    build:
      context: ./docker/custom-debian
    networks:
      app_net:
        ipv4_address: 172.16.238.242
```

## Reusable override files

For a repeatable stack, store the service as
`compose/docker-compose.override.yml-mytool`:

```yaml
services:
  mytool:
    image: alpine:3.20
    command: ["sleep", "infinity"]
    networks:
      app_net:
        ipv4_address: 172.16.238.243
```

Activate it with Compose directly:

```bash
COMPOSE_FILE=docker-compose.yml:compose/docker-compose.override.yml-mytool \
  docker compose up -d mytool
```

This keeps root-level local overrides clean and makes the stack easy to
share with a team.

## Optional container configuration

`env-example` defines the default and optional container roster:

```dotenv
CONTAINERS_CONFIG_DEFAULT="bind httpd php mysql"
CONTAINERS_CONFIG_OPTIONAL="php74 php81 php82 php83 php84 redis opensearch buggregator"
```

The installer reads those values to export `DEVILBOX_CONTAINERS` into
your shell profile. Add your own optional stack there only when it is a
first-class service you want `dvl up` to start by default.

:::note
The `dvl agent` workflow uses the same override-file idea. Enabled agent
stacks are stored in `.dvl/agent-stacks.list` and merged through
`COMPOSE_FILE` at runtime.
:::

## Validate the service

Render the merged Compose config:

```bash
docker compose config
```

Start only the custom service and its dependencies:

```bash
docker compose up -d mytool
docker compose ps mytool
```

Show logs:

```bash
docker compose logs -f --tail=100 mytool
```

Remove it when done:

```bash
docker compose stop mytool
docker compose rm -f mytool
```
