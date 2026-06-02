---
title: Enable and configure Solr (deprecated)
description: This integration is no longer part of the optional container roster.
sidebar:
  order: 7
  badge:
    text: Deprecated
    variant: danger
---

# Enable and configure Solr (deprecated)

:::danger[Deprecated]
Solr is not listed in the current `CONTAINERS_CONFIG_OPTIONAL` roster in `env-example`.
:::

## Why?

The historical Solr page described copying `compose/docker-compose.override.yml-solr` into the project root and setting Solr variables in `.env`. Devilbox now documents supported optional containers through `CONTAINERS_CONFIG_OPTIONAL`, and `solr` is not present in the current optional roster.

The compose snippet still exists for reference, but it is not activated by the maintained optional-container mechanism.

## Migration

If your project needs Solr, define it with the project:

1. Add a `solr` service to `docker-compose.override.yml`.
2. Pin the Solr image tag and core name.
3. Store cores in a named volume or project-owned directory.
4. Publish `8983` only when you need host access to the Admin UI.
5. Start Devilbox with `./dvl.sh up`.

## Replacement pattern

Use `CONTAINERS_CONFIG_OPTIONAL` only for the slugs listed in `env-example`. For search backends, use [Add your own Docker image](/advanced/add-your-own-docker-image/) and keep schema, core, and image choices under project control.
