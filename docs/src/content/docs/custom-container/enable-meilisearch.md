---
title: Enable and configure Meilisearch (deprecated)
description: This integration is no longer part of the optional container roster.
sidebar:
  order: 4
  badge:
    text: Deprecated
    variant: danger
---

# Enable and configure Meilisearch (deprecated)

:::danger[Deprecated]
Meilisearch is not listed in the current `CONTAINERS_CONFIG_OPTIONAL` roster in `env-example`.
:::

## Why?

The historical Meilisearch page relied on copying `compose/docker-compose.override.yml-meilisearch` into `docker-compose.override.yml`. The supported Devilbox optional-container mechanism is now `CONTAINERS_CONFIG_OPTIONAL`, and `meilisearch` is not in the current optional roster.

The old compose snippet still exists in `compose/` for reference, but it is not part of the maintained roster for new installs.

## Migration

If your application needs Meilisearch, define it with the application:

1. Add a project-owned `meilisearch` service to `docker-compose.override.yml`.
2. Pin the Meilisearch image tag and master-key policy.
3. Publish `7700` only on the host interface you need.
4. Store index data in a named volume or project-owned directory.
5. Start Devilbox with `./dvl.sh up`.

## Replacement pattern

Use `CONTAINERS_CONFIG_OPTIONAL` only for supported slugs from `env-example`. For application search services, use [Add your own Docker image](/advanced/add-your-own-docker-image/) so image tags, ports, and data retention are versioned with the project.
