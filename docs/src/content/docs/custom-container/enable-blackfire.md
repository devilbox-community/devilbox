---
title: Enable and configure Blackfire (deprecated)
description: This integration is no longer part of the optional container roster.
sidebar:
  order: 2
  badge:
    text: Deprecated
    variant: danger
---

# Enable and configure Blackfire (deprecated)

:::danger[Deprecated]
Blackfire is not listed in the current `CONTAINERS_CONFIG_OPTIONAL` roster in `env-example`.
:::

## Why?

The historical Blackfire page relied on copying `compose/docker-compose.override.yml-blackfire` into `docker-compose.override.yml` and then starting the service manually. Devilbox now documents optional containers through `CONTAINERS_CONFIG_OPTIONAL`, and `blackfire` is not one of the supported optional slugs in the current roster.

The old compose snippet still exists for reference, but it is not provisioned by the supported optional-container mechanism.

## Migration

If your project still needs Blackfire, own it as project infrastructure:

1. Add a project-specific Blackfire service to `docker-compose.override.yml`.
2. Pin the Blackfire image tag you want to maintain.
3. Store `BLACKFIRE_SERVER_ID`, `BLACKFIRE_SERVER_TOKEN`, `BLACKFIRE_CLIENT_ID`, and `BLACKFIRE_CLIENT_TOKEN` in `.env` or your secret manager.
4. Enable the PHP Blackfire extension in the PHP runtime you actually use.
5. Start Devilbox with `./dvl.sh up` after your project override is in place.

## Replacement pattern

Use the maintained environment-variable pattern for supported optional containers only. See [Agentic tool toggles](/getting-started/agentic-tools-toggle/) for the same default-plus-optional pattern, and read `env-example` for the authoritative Devilbox container roster.

For custom services, use [Add your own Docker image](/advanced/add-your-own-docker-image/).
