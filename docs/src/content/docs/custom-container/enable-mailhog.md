---
title: Enable and configure MailHog (deprecated)
description: This integration is no longer part of the optional container roster.
sidebar:
  order: 3
  badge:
    text: Deprecated
    variant: danger
---

# Enable and configure MailHog (deprecated)

:::danger[Deprecated]
MailHog is not listed in the current `CONTAINERS_CONFIG_OPTIONAL` roster in `env-example`.
:::

## Why?

The historical MailHog page described copying `compose/docker-compose.override.yml-mailhog` into the project root and editing PHP configuration for one selected runtime. Devilbox now documents supported optional containers through `CONTAINERS_CONFIG_OPTIONAL`, and `mailhog` is not present in the current optional roster.

The compose snippet remains in `compose/` for reference, but it is not activated by the maintained optional-container flow.

## Migration

If you still need an email catcher, define it in your project-owned compose override:

1. Pick the mail-catcher image and tag you want to maintain.
2. Add a service such as `mailhog` or `mailpit` to `docker-compose.override.yml`.
3. Publish the web UI port only on localhost.
4. Configure each PHP runtime you use to send mail to that service.
5. Start Devilbox with `./dvl.sh up`.

## Replacement pattern

Use `CONTAINERS_CONFIG_OPTIONAL` only for slugs listed in `env-example`. For custom mail services, use [Add your own Docker image](/advanced/add-your-own-docker-image/) and keep the service definition with the application that depends on it.
