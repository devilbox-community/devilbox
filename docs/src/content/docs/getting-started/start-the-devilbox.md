---
title: "Start the Devilbox"
---

# Start the Devilbox

After installation, use the `dvl` CLI to start and stop Devilbox. `dvl` is the canonical wrapper around Docker Compose for this project. It knows where your Devilbox checkout lives, starts the configured service roster, and keeps common workflows consistent across operating systems.

:::note
The default start command is `dvl up`. The raw Compose files still exist, but new documentation should use the `dvl` workflow.
:::

## Before you start

Confirm your shell profile is loaded and the CLI is available:

```bash
command -v dvl
printf '%s\n' "$DEVILBOX_PATH"
printf '%s\n' "$DEVILBOX_CONTAINERS"
```

If `dvl` is not found, restart your terminal or source the profile printed by the installer. If `DEVILBOX_PATH` is empty, the CLI cannot locate the Devilbox repository.

## Default container roster

New installations derive their default container list from `env-example`. The current source-of-truth default line is:

```bash
CONTAINERS_CONFIG_DEFAULT="bind httpd php mysql"
```

The installer also appends the optional roster to preserve the broader legacy start set:

```bash
CONTAINERS_CONFIG_OPTIONAL="php74 php81 php82 php83 php84 redis opensearch buggregator"
```

Together, those values become `DEVILBOX_CONTAINERS` in your shell profile. `dvl up` starts that list when no services are passed.

:::tip
For command details, see [`dvl up`](/intermediate/dvl-cli/#up).
:::

## Start the default stack

Start Devilbox in the background:

```bash
dvl up
```

The CLI changes into `DEVILBOX_PATH` and runs the Compose start workflow for the configured service list. On first start, Docker pulls missing images, creates networks and volumes, and initializes service data where needed.

Common first-start events:

- Docker pulls images that are not present locally.
- The Bind DNS service starts on the configured DNS port.
- The PHP service mounts your project directory at `/shared/httpd`.
- The HTTPD service prepares the Devilbox intranet and mass-vhost configuration.
- MySQL initializes a version-specific data volume if one does not already exist.
- Redis, OpenSearch, Buggregator, and additional configured services start if they are in `DEVILBOX_CONTAINERS`.

:::note
Images are pulled when missing. They are not automatically upgraded on every start. Pull new images explicitly when you want to update your local cache.
:::

## Check running services

Use Docker or the CLI help for status checks. The most common command is:

```bash
dvl ps
```

If your installed CLI version does not expose `ps`, use Docker directly from the Devilbox directory:

```bash
cd "$DEVILBOX_PATH"
docker compose ps
```

For logs:

```bash
dvl logs
```

If `dvl logs` is not available in your installed version, use:

```bash
cd "$DEVILBOX_PATH"
docker compose logs -f
```

## Start a smaller service set

The recommended way to change the default start set is editing `DEVILBOX_CONTAINERS` in your shell profile. For a minimal web/database stack:

```bash
export DEVILBOX_CONTAINERS="bind httpd php mysql"
dvl up
```

For a PHP and Redis workflow:

```bash
export DEVILBOX_CONTAINERS="bind httpd php redis"
dvl up
```

For a one-off Compose start of selected services, pass service names to raw Compose only when you intentionally bypass the CLI. Prefer updating `DEVILBOX_CONTAINERS` for repeatable day-to-day starts.

## Service names

The current core services in `docker-compose.yml` are:

| Service | Purpose | Default image selector |
| --- | --- | --- |
| `bind` | DNS service | fixed Bind image |
| `php` | Default PHP-FPM workspace | `PHP_SERVER` |
| `httpd` | Apache or Nginx web server | `HTTPD_SERVER` and `HTTPD_FLAVOUR` |
| `mysql` | MySQL/MariaDB/Percona database | `MYSQL_SERVER` |
| `pgsql` | PostgreSQL database | `PGSQL_SERVER` |
| `redis` | Redis cache | `REDIS_SERVER` |
| `memcd` | Memcached cache | `MEMCD_SERVER` |
| `mongo` | MongoDB database | `MONGO_SERVER` |

Additional optional services can be layered from files in `compose/`, such as OpenSearch, Mailpit, MailHog, Buggregator, Varnish, Solr, Ngrok, and agent stacks.

## Open the Devilbox intranet

After `dvl up` succeeds, open the intranet in your browser:

```text
http://localhost
https://localhost
```

The HTTP and HTTPS ports are controlled by `.env`:

```bash
HOST_PORT_HTTPD=80
HOST_PORT_HTTPD_SSL=443
```

If those ports are busy, change the variables before starting the stack.

:::tip
The default `TLD_SUFFIX` is `lvh.me`, which resolves to `127.0.0.1`. Projects under `data/www` can be reached with names such as `my-project.lvh.me` when vhost generation is configured for that project.
:::

## Stop the Devilbox

Stop and remove containers cleanly:

```bash
dvl down
```

The CLI performs a stop/down workflow and removes stopped containers so the next start is fresh. Named volumes remain intact, so database data is preserved unless you remove volumes separately.

:::caution
Do not confuse removing stopped containers with removing volumes. `dvl down` cleans runtime containers. Database data lives in named Docker volumes such as `devilbox-mariadb-10.4` and is not removed by the normal stop path.
:::

## Restart services

Restart the full configured stack:

```bash
dvl restart
```

Restart one running service by name:

```bash
dvl restart php
```

When you change `.env` values that affect images, ports, or mounts, prefer a clean down/up cycle:

```bash
dvl down
dvl up
```

## First-start troubleshooting

| Symptom | Check | Fix |
| --- | --- | --- |
| `dvl` command not found | `command -v dvl` | Restart the terminal or add the symlink directory to `PATH`. |
| `DEVILBOX_PATH` empty | `printf '%s\n' "$DEVILBOX_PATH"` | Source the shell profile or set the variable manually. |
| Docker daemon error | `docker info` | Start Docker Desktop or the Linux Docker service. |
| Compose command error | `docker compose version` | Install the Compose v2 plugin. |
| Port conflict | `docker compose ps` or OS port tools | Change `HOST_PORT_*` variables in `.env`. |
| DNS not resolving | `TLD_SUFFIX` and Bind logs | Use `lvh.me` or configure DNS forwarding for your host. |
| HTTPD fails | HTTPD logs | Check `HTTPD_SERVER`, `HTTPD_FLAVOUR`, and port availability. |

## Checklist

- `dvl up` starts without errors.
- `dvl ps` or `docker compose ps` shows the expected services.
- The intranet opens at `http://localhost` or your configured HTTP port.
- HTTPS opens at `https://localhost` or your configured HTTPS port.
- Project files are under `data/www` or the path configured by `HOST_PATH_HTTPD_DATADIR`.
- `dvl down` stops the environment cleanly.

## Next step

Continue with [Enter the PHP container](/getting-started/enter-the-php-container/) to run tools inside the workspace container.
