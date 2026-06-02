---
title: Enable and configure ELK Stack (deprecated)
description: This integration is no longer maintained.
sidebar:
  badge:
    text: Deprecated
    variant: danger
---

# Enable and configure ELK Stack (deprecated)

:::danger[Deprecated]
This page documents an integration that has been removed from Devilbox.
:::

## Why?

The legacy Elasticsearch, Logstash, and Kibana containers were removed from the maintained Devilbox roster. Current Devilbox development uses the core stack plus actively maintained optional services; modern search alternatives such as OpenSearch are not bundled as a drop-in ELK replacement on this page. If you need an ELK-compatible stack, own it as a project-specific override instead of relying on removed first-party documentation.

## Migration

If you still need this, define your own service in `docker-compose.override.yml`. See [Add your own Docker image](/advanced/add-your-own-docker-image/).

Recommended migration steps:

1. Choose the Elasticsearch, Logstash, Kibana, or OpenSearch images you want to maintain.
2. Add those services to your own `docker-compose.override.yml`.
3. Pin image tags explicitly instead of relying on old Devilbox defaults.
4. Publish only the host ports you need.
5. Mount project-owned configuration and data paths.
6. Start Devilbox and your override together with your normal `dvl` workflow.

:::caution
Do not copy historical ELK snippets without reviewing image support, JVM requirements, heap sizing, security defaults, and host resource limits. The old examples targeted obsolete image tags and assumptions.
:::

## Replacement pattern

Use the custom-image documentation as the maintained pattern:

```yaml
services:
  search:
    image: your/search-image:your-version
    ports:
      - "127.0.0.1:9200:9200"
```

Adjust the service name, image, volumes, environment variables, and ports for your project.

## History

Removed in 2026 during the Starlight documentation rewrite. Historical docs are preserved in git history at commit `2e93feb47b0eb0ff8a2819bda132e1f23f41a330`.
