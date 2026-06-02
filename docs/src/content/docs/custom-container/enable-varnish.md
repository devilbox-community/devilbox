---
title: Enable and configure Varnish (deprecated)
description: This integration is no longer part of the optional container roster.
sidebar:
  order: 8
  badge:
    text: Deprecated
    variant: danger
---

# Enable and configure Varnish (deprecated)

:::danger[Deprecated]
Varnish is not listed in the current `CONTAINERS_CONFIG_OPTIONAL` roster in `env-example`.
:::

## Why?

The historical Varnish page described copying `compose/docker-compose.override.yml-varnish`, optionally starting HAProxy, and editing Varnish-specific variables. Devilbox now uses `CONTAINERS_CONFIG_OPTIONAL` as the maintained optional-container pattern, and `varnish` is not listed in the current roster.

The old compose snippet still exists for reference, but it is not provisioned by the supported optional-container flow.

## Migration

If your project needs Varnish or HTTPS offloading in front of Varnish:

1. Define project-owned `varnish` and optional `haproxy` services in `docker-compose.override.yml`.
2. Pin image tags and keep VCL files with the project.
3. Publish host ports only when browser access must bypass the standard Devilbox HTTPD entrypoint.
4. Store cache and TLS settings in `.env` or project configuration.
5. Start Devilbox with `./dvl.sh up`.

## Replacement pattern

Use `CONTAINERS_CONFIG_OPTIONAL` only for supported slugs from `env-example`. For HTTP caching layers, use [Add your own Docker image](/advanced/add-your-own-docker-image/) so VCL, image tags, and routing are maintained with the application.
