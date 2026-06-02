---
title: "Enable all additional container"
description: "Enable Devilbox optional services with compose override snippets and understand how that differs from the agentic optional-container toggle."
---

# Enable all additional container

Devilbox has two distinct ways to add optional services. Classic optional
services are enabled by copying Docker Compose override snippets from
`compose/`; agentic optional services are enabled with
`CONTAINERS_CONFIG_OPTIONAL` before running the installer.

<div class="seealso">

`docker-compose-override-yml-how-does-it-work`

</div>

## Available classic optional container

The `compose/` directory contains maintained snippets for these classic
optional services:

| Container | Service name | Hostname | IP Address |
|---|---|---|---|
| PHP Community | php | php | 172.16.238.10 |
| Blackfire | blackfire | blackfire | 172.16.238.200 |
| Meilisearch | meilisearch | meilisearch | 172.16.238.203 |
| MailHog | mailhog | mailhog | 172.16.238.252 |
| Ngrok | ngrok | ngrok | 172.16.238.202 |
| RabbitMQ | rabbit | rabbit | 172.16.238.210 |
| Solr | solr | solr | 172.16.238.220 |
| Varnish | varnish | varnish | 172.16.238.230 |
| HAProxy for Varnish | haproxy | haproxy | 172.16.238.231 |
| ELK: Elasticsearch | elastic | elastic | 172.16.238.240 |
| ELK: Logstash | logstash | logstash | 172.16.238.241 |
| ELK: Kibana | kibana | kibana | 172.16.238.242 |

## Enable all classic optional container

If `compose/docker-compose.override.yml-all` exists, copy it into the root of
the Devilbox git directory:

```bash
cp compose/docker-compose.override.yml-all docker-compose.override.yml
./dvl.sh up
```

This starts every classic optional service defined in the combined override.
That is convenient for testing, but it consumes significantly more CPU, memory,
and ports than selecting only the services you need.

## Enable selected classic optional container

For one service, copy only its snippet:

```bash
cp compose/docker-compose.override.yml-mailhog docker-compose.override.yml
./dvl.sh up
```

For multiple snippets, create a local override file or chain the snippets when
starting Docker Compose directly:

```bash
docker compose \
  -f docker-compose.yml \
  -f compose/docker-compose.override.yml-mailhog \
  -f compose/docker-compose.override.yml-rabbitmq \
  up -d
```

When using `./dvl.sh up`, keep the selected services in the root-level
`docker-compose.override.yml` so the Devilbox wrapper sees them consistently.

## Agentic optional containers are separate

`CONTAINERS_CONFIG_OPTIONAL` is only the agentic-tool toggle. It belongs in
`.env` before running `install.sh`, and it is consumed by the installer for the
agentic optional roster:

- `php74`
- `php81`
- `php82`
- `php83`
- `php84`
- `redis`
- `opensearch`
- `buggregator`

It does not replace the `docker-compose.override.yml` mechanism for Blackfire,
Varnish, Solr, MailHog, Meilisearch, Ngrok, PHP Community, ELK, or RabbitMQ.

<div class="seealso">

- [Agentic tools toggle](/getting-started/agentic-tools-toggle/)
- [Docker Compose override file](/configuration-files/docker-compose-override-yml/)

</div>

## Configure additional container

Each optional service can define image versions, exposed ports, mount points,
and service-specific environment variables. See the dedicated pages for exact
settings:

<div class="seealso">

\* `custom-container-enable-php-community` \*
`custom-container-enable-blackfire` \*
`custom-container-enable-elk-stack` \* `custom-container-enable-mailhog`
\* `custom-container-enable-meilisearch` \* `custom-container-enable-ngrok`
\* `custom-container-enable-rabbitmq` \* `custom-container-enable-solr` \*
`custom-container-enable-varnish`

</div>
