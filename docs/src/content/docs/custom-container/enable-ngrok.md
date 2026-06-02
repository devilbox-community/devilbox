---
title: Enable and configure Ngrok (deprecated)
description: This integration is no longer part of the optional container roster.
sidebar:
  order: 5
  badge:
    text: Deprecated
    variant: danger
---

# Enable and configure Ngrok (deprecated)

:::danger[Deprecated]
Ngrok is not listed in the current `CONTAINERS_CONFIG_OPTIONAL` roster in `env-example`.
:::

## Why?

The historical Ngrok page described copying `compose/docker-compose.override.yml-ngrok` and setting tunnel variables in `.env`. Devilbox now uses `CONTAINERS_CONFIG_OPTIONAL` as the supported optional-container pattern, and `ngrok` is not listed in that roster.

The old compose snippet still exists for reference, but it is not provisioned by the current optional-container flow.

## Migration

If you still need public tunnels for a project:

1. Define a project-owned tunnel service in `docker-compose.override.yml`.
2. Pin the tunnel client image or use a locally installed client.
3. Store auth tokens outside committed files.
4. Route only the virtual hosts and ports that need external access.
5. Start Devilbox with `./dvl.sh up`.

## Replacement pattern

Use the `CONTAINERS_CONFIG_OPTIONAL` mechanism only for slugs listed in `env-example`. For tunnels, use [Add your own Docker image](/advanced/add-your-own-docker-image/) or an external tunnel client managed by your project.
