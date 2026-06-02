---
title: "Change container versions"
---

# Change container versions

Devilbox lets you switch service images by editing `.env`. The active version for most services is controlled by a `*_SERVER` variable, and Docker uses that value the next time the affected service is recreated.

:::note
This page reflects the current `env-example` roster. Do not invent version strings: copy values exactly from `env-example` when editing `.env`.
:::

## Safe workflow

Use this workflow for any service version change:

1. Stop Devilbox.
2. Back up data for stateful services.
3. Edit the relevant variable in `.env`.
4. Recreate the affected containers.
5. Verify the service version inside the running container.

```bash
dvl down
vi .env
dvl up
```

For one service, you can also restart that service after editing, but a clean `dvl down` and `dvl up` is easier to reason about when images, ports, or data volumes change.

:::caution
Database services use version-specific Docker volumes. Changing MySQL, PostgreSQL, or MongoDB versions can make the new service look empty because it mounts a different volume name. Export data before switching and import it after the target version is running.
:::

## Current version variables

These are the primary image selectors from `env-example`:

| Variable | Default | Service |
| --- | --- | --- |
| `PHP_SERVER` | `8.1` | Default `php` service. |
| `HTTPD_FLAVOUR` | `alpine` | HTTPD image flavor. |
| `HTTPD_SERVER` | `nginx-stable` | Web server image. |
| `MYSQL_SERVER` | `mariadb-10.4` | MySQL-compatible database service. |
| `PGSQL_SERVER` | `14-alpine` | PostgreSQL service. |
| `REDIS_SERVER` | `6.2-alpine` | Redis service. |
| `MEMCD_SERVER` | `1.6-alpine` | Memcached service. |
| `MONGO_SERVER` | `5.0` | MongoDB service. |
| `VARNISH_SERVER` | `6` | Varnish override service. |
| `MAILHOG_SERVER` | `latest` | MailHog override service. |
| `OPENSEARCH_SERVER` | `1.2-0` | OpenSearch override service. |
| `NGROK_SERVER` | `latest` | Ngrok override service. |
| `MAILPIT_SERVER` | `latest` | Mailpit override service. |
| `BUGGREGATOR_SERVER` | `latest` | Buggregator override service. |
| `AEM_SERVER` | `6.5.11.0-jdk11` | AEM override service. |

## PHP versions

The default PHP service uses `PHP_SERVER`. The current selectable values are:

| Value | Status in `env-example` |
| --- | --- |
| `7.4` | available |
| `8.0` | available |
| `8.1` | default |
| `8.2` | available |
| `8.3` | available |
| `8.4` | available |

Example: switch the default PHP service to 8.4.

```bash
dvl down
```

Edit `.env` so only one `PHP_SERVER` assignment is active:

```bash
#PHP_SERVER=7.4
#PHP_SERVER=8.0
#PHP_SERVER=8.1
#PHP_SERVER=8.2
#PHP_SERVER=8.3
PHP_SERVER=8.4
```

Start again:

```bash
dvl up
dvl exec "php -v"
```

:::tip
If your installation includes versioned PHP services such as `php74`, `php81`, `php82`, `php83`, and `php84`, use `dvl shell php84` to enter a specific version without changing the default `php` service.
:::

## HTTPD versions

HTTPD selection uses two variables:

```bash
HTTPD_FLAVOUR=alpine
HTTPD_SERVER=nginx-stable
```

Current values shown in `env-example`:

| Variable | Values |
| --- | --- |
| `HTTPD_FLAVOUR` | `debian`, `alpine` |
| `HTTPD_SERVER` | `apache-2.2`, `apache-2.4`, `nginx-stable`, `nginx-mainline` |

Example: switch to Apache 2.4 with the Alpine flavor.

```bash
dvl down
```

Edit `.env`:

```bash
HTTPD_FLAVOUR=alpine
#HTTPD_SERVER=apache-2.2
HTTPD_SERVER=apache-2.4
#HTTPD_SERVER=nginx-stable
#HTTPD_SERVER=nginx-mainline
```

Start again:

```bash
dvl up
```

:::caution
Changing HTTPD can affect vhost templates under `cfg/vhost-gen` and custom web server configuration under `cfg/<HTTPD_SERVER>`. Review custom config before switching between Apache and Nginx.
:::

## MySQL, MariaDB, and Percona versions

The MySQL-compatible service uses `MYSQL_SERVER`. Current values from `env-example` are:

| Family | Values |
| --- | --- |
| MySQL | `mysql-5.5`, `mysql-5.6`, `mysql-5.7`, `mysql-8.0` |
| Percona | `percona-5.5`, `percona-5.6`, `percona-5.7`, `percona-8.0` |
| MariaDB | `mariadb-5.5`, `mariadb-10.0`, `mariadb-10.1`, `mariadb-10.2`, `mariadb-10.3`, `mariadb-10.4`, `mariadb-10.5`, `mariadb-10.6`, `mariadb-10.7`, `mariadb-10.8`, `mariadb-10.9`, `mariadb-10.10`, `mariadb-11.4` |

Default:

```bash
MYSQL_SERVER=mariadb-10.4
```

Example: switch to MySQL 8.0.

```bash
dvl down
```

Edit `.env`:

```bash
#MYSQL_SERVER=mysql-5.7
MYSQL_SERVER=mysql-8.0
#MYSQL_SERVER=mariadb-10.4
```

Start again and verify:

```bash
dvl up
dvl exec "mysql --version"
```

:::caution
MySQL-compatible data is stored in volumes named for the selected server value, for example `devilbox-mariadb-10.4`. Switching versions changes the volume name. Always export databases before changing this value if you need the data in the new version.
:::

## PostgreSQL versions

The PostgreSQL service uses `PGSQL_SERVER`. Current values from `env-example` are:

| Category | Values |
| --- | --- |
| Older non-arm64 entries | `9.1`, `9.2-alpine` |
| Standard entries | `9.2`, `9.3`, `9.4`, `9.5`, `9.6`, `10`, `11`, `12`, `13`, `14`, `15`, `latest` |
| Alpine entries | `9.3-alpine`, `9.4-alpine`, `9.5-alpine`, `9.6-alpine`, `10-alpine`, `11-alpine`, `12-alpine`, `13-alpine`, `14-alpine`, `15-alpine`, `alpine` |

Default:

```bash
PGSQL_SERVER=14-alpine
```

Example: switch to PostgreSQL 15 Alpine.

```bash
dvl down
```

Edit `.env`:

```bash
#PGSQL_SERVER=14-alpine
PGSQL_SERVER=15-alpine
```

Start again:

```bash
dvl up
```

PostgreSQL data uses version-specific volumes such as `devilbox-pgsql-14-alpine`.

## Redis versions

The Redis service uses `REDIS_SERVER`. Current values from `env-example` are:

| Category | Values |
| --- | --- |
| Older non-arm64 entries | `2.8`, `3.0`, `3.0-alpine` |
| Standard entries | `3.2`, `4.0`, `5.0`, `6.0`, `6.2`, `7.0`, `latest` |
| Alpine entries | `3.2-alpine`, `4.0-alpine`, `5.0-alpine`, `6.0-alpine`, `6.2-alpine`, `7.0-alpine`, `alpine` |

Default:

```bash
REDIS_SERVER=6.2-alpine
```

Example: switch to Redis 7.0 Alpine.

```bash
dvl down
```

Edit `.env`:

```bash
#REDIS_SERVER=6.2-alpine
REDIS_SERVER=7.0-alpine
```

Start again:

```bash
dvl up
```

## MongoDB versions

The MongoDB service uses `MONGO_SERVER`. Current values from `env-example` are:

| Category | Values |
| --- | --- |
| Older non-arm64 entries | `2.8`, `3.0`, `3.2` |
| Standard entries | `3.4`, `3.6`, `4.0`, `4.2`, `4.4`, `5.0`, `latest` |

Default:

```bash
MONGO_SERVER=5.0
```

Example: switch to MongoDB 4.4.

```bash
dvl down
```

Edit `.env`:

```bash
#MONGO_SERVER=4.4
MONGO_SERVER=5.0
```

Start again:

```bash
dvl up
```

MongoDB data uses version-specific volumes such as `devilbox-mongo-5.0`.

## Memcached versions

The Memcached service uses `MEMCD_SERVER`. Current values from `env-example` are:

| Category | Values |
| --- | --- |
| Older non-arm64 entries | `1.4`, `1.4-alpine` |
| Standard entries | `1.5`, `1.6`, `latest` |
| Alpine entries | `1.5-alpine`, `1.6-alpine`, `alpine` |

Default:

```bash
MEMCD_SERVER=1.6-alpine
```

## Optional service versions

Optional compose layers have their own selectors:

| Variable | Default | Other values shown in `env-example` |
| --- | --- | --- |
| `VARNISH_SERVER` | `6` | `4`, `5`, `7` |
| `MAILHOG_SERVER` | `latest` | `1.3-linux-arm64`, `1.2-linux-arm64`, `1-linux-arm64` |
| `OPENSEARCH_SERVER` | `1.2-0` | `2.12-0`, `2.5-0`, `2.5-1` |
| `NGROK_SERVER` | `latest` | `0.7`, `0.3` |
| `MAILPIT_SERVER` | `latest` | `1.24`, `1.2`, `edge` |
| `BUGGREGATOR_SERVER` | `latest` | `1.13`, `1.12` |
| `AEM_SERVER` | `6.5.11.0-jdk11` | `6.5.11.0-jdk11-arm`, `6.5.3.0-bundle`, `6.5.3.0-bundle-forms`, `6.5.8.0-bundle-forms-jdk11` |

These values only matter when the matching service is enabled through the base stack or an override layer.

## Configuration file implications

Several services have version-specific configuration directories. When you switch versions, review the matching path:

| Service | Configuration path pattern |
| --- | --- |
| PHP ini | `cfg/php-ini-<PHP_SERVER>/` |
| PHP-FPM | `cfg/php-fpm-<PHP_SERVER>/` |
| PHP startup | `cfg/php-startup-<PHP_SERVER>/` |
| HTTPD | `cfg/<HTTPD_SERVER>/` |
| MySQL-compatible | `cfg/<MYSQL_SERVER>/` |
| Vhost templates | `cfg/vhost-gen/` |

If you customized only one version's directory, those settings may not apply after switching.

## Duplicate assignments in `.env`

Shell-style `.env` parsing uses the last active assignment when the same variable appears more than once. Avoid leaving duplicates.

Bad example:

```bash
PHP_SERVER=8.1
PHP_SERVER=8.4
```

The effective value is `8.4`, but the file is confusing. Prefer one active assignment and comments for alternatives:

```bash
#PHP_SERVER=8.1
PHP_SERVER=8.4
```

## Verification commands

After changing versions, verify from inside the container where possible:

```bash
dvl exec "php -v"
dvl exec "mysql --version"
dvl exec "redis-cli --version"
```

For services without a PHP-container client, inspect Compose output:

```bash
cd "$DEVILBOX_PATH"
docker compose ps
docker compose config
```

## Checklist

- You copied version values exactly from `env-example`.
- You changed only one active assignment per variable.
- You backed up stateful service data before switching database versions.
- You ran `dvl down` before editing `.env`.
- You ran `dvl up` after editing `.env`.
- You verified the running version after startup.
- You reviewed version-specific configuration directories.
- You understand that database volume names can change with version selectors.
