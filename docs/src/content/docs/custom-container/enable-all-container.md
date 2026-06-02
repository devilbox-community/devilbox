---
title: "Enable all additional container"
sidebar:
  order: 1
---

# Enable all additional container

Devilbox no longer enables optional services by copying a manually authored `docker-compose.override.yml` into the project root. The supported source of truth is `env-example` and the `CONTAINERS_CONFIG_OPTIONAL` value that `install.sh` uses to build `DEVILBOX_CONTAINERS`.

## Current optional roster

The current optional roster in `env-example` is:

```dotenv
CONTAINERS_CONFIG_DEFAULT="bind httpd php mysql"
CONTAINERS_CONFIG_OPTIONAL="php74 php81 php82 php83 php84 redis opensearch buggregator"
```

These slugs are the supported optional containers for new installs. Historical custom-container pages for Blackfire, MailHog, Meilisearch, Ngrok, PHP Community, Solr, and Varnish are preserved for URL stability, but those slugs are not part of the current optional roster.

## Enable all current optionals

Copy `env-example` to `.env` if you do not already have one, then keep the full comma-separated optional list in `.env`:

```dotenv
CONTAINERS_CONFIG_OPTIONAL=php74,php81,php82,php83,php84,redis,opensearch,buggregator
```

Restart the stack with the modern wrapper:

```bash
./dvl.sh up
```

The wrapper reads the container set provisioned by `install.sh`. If you already installed Devilbox before changing `.env`, re-run the installer or update `DEVILBOX_CONTAINERS` in your shell profile so it matches the current default plus optional list.

:::caution
Enabling every optional container is convenient for smoke testing but usually unnecessary for day-to-day development. Keep the list limited to services your project actually uses.
:::

## Pattern reference

The environment-variable pattern mirrors the runtime toggle documented in [Agentic tool toggles](/getting-started/agentic-tools-toggle/): defaults are declared once, optional slugs are comma-separated, and the active set is computed from configuration instead of copy-pasted override files.

For the authoritative container list, read `env-example` in the Devilbox repository root.
