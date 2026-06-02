---
title: Enable and configure RabbitMQ (deprecated)
description: This integration is no longer maintained.
sidebar:
  badge:
    text: Deprecated
    variant: danger
---

# Enable and configure RabbitMQ (deprecated)

:::danger[Deprecated]
This page documents an integration that has been removed from Devilbox.
:::

## Why?

The RabbitMQ container was removed from the default and optional Devilbox rosters. The historical page described a bundled override and environment variables that are no longer maintained as part of the supported documentation path. RabbitMQ remains a valid project dependency, but it should now be defined and versioned by the project that needs it.

## Migration

If you still need this, define your own service in `docker-compose.override.yml`. See [Add your own Docker image](/advanced/add-your-own-docker-image/).

Recommended migration steps:

1. Pick the RabbitMQ image tag you want to own.
2. Add a `rabbitmq` or project-specific service name to your override file.
3. Publish AMQP and management UI ports only when needed.
4. Store broker data in a named volume or project-owned directory.
5. Keep credentials in `.env` or another secret-management mechanism.
6. Start the service with the rest of your Devilbox workflow.

:::caution
Do not reuse old default credentials or unpinned broker versions for shared environments. Treat RabbitMQ as application infrastructure and maintain it with the same care as your database services.
:::

## Replacement pattern

Use the custom-image documentation as the maintained pattern:

```yaml
services:
  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "127.0.0.1:5672:5672"
      - "127.0.0.1:15672:15672"
```

Adjust the image tag, credentials, volumes, and published ports for your project.

## History

Removed in 2026 during the Starlight documentation rewrite. Historical docs are preserved in git history at commit `2e93feb47b0eb0ff8a2819bda132e1f23f41a330`.
