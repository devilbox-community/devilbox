---
title: Enable and configure PHP Community (deprecated)
description: This integration is no longer part of the optional container roster.
sidebar:
  order: 6
  badge:
    text: Deprecated
    variant: danger
---

# Enable and configure PHP Community (deprecated)

:::danger[Deprecated]
`php-community` is not listed in the current `CONTAINERS_CONFIG_OPTIONAL` roster in `env-example`.
:::

## Why?

The historical PHP Community page replaced the default `php` service by copying `compose/docker-compose.override.yml-php-community`. The current supported roster is declared in `env-example` through `CONTAINERS_CONFIG_DEFAULT` and `CONTAINERS_CONFIG_OPTIONAL`. It includes specific PHP runtime slugs such as `php83` and `php84`, not a `php-community` optional slug.

The compose snippet remains in `compose/` for reference, but it is not part of the maintained optional-container roster.

## Migration

For supported PHP runtimes, use the PHP slugs listed in `env-example`:

```dotenv
CONTAINERS_CONFIG_OPTIONAL=php74,php81,php82,php83,php84
```

Then start the stack:

```bash
./dvl.sh up
```

If you need a custom PHP image, own that replacement in `docker-compose.override.yml`, pin the image tag, and document the extension set your application requires.

## Replacement pattern

Use `env-example` as the authoritative roster. The environment-toggle approach is also described in [Agentic tool toggles](/getting-started/agentic-tools-toggle/) for another Devilbox runtime subsystem.
