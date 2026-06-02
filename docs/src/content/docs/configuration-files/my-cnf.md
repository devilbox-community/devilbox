---
title: "my.cnf"
description: "Configure MySQL, Percona and MariaDB server options in Devilbox."
---

# my.cnf

Devilbox lets you override MySQL-compatible server configuration per selected
database image. The active directory is derived from `MYSQL_SERVER` in `.env`;
for example `MYSQL_SERVER=mysql-8.0` reads files from `cfg/mysql-8.0/`, while
`MYSQL_SERVER=mariadb-11.4` reads files from `cfg/mariadb-11.4/`.

The current Compose mount is:

```yaml
- ${DEVILBOX_PATH}/cfg/${MYSQL_SERVER}:/etc/mysql/docker-default.d:ro${MOUNT_OPTIONS}
```

That means every `*.cnf` file in the matching `cfg/<MYSQL_SERVER>/` directory is
mounted read-only into the database container and loaded by the image startup.

:::note
Changing `MYSQL_SERVER` itself belongs in [the `.env` file](/configuration-files/env-file/).
Updating Devilbox versions is covered by [update the Devilbox](/maintenance/update-the-devilbox/).
:::

## Supported configuration directories

Use the directory that matches the `MYSQL_SERVER` value you run. The modern
targets in this repository include:

- `cfg/mysql-5.7/`
- `cfg/mysql-8.0/`
- `cfg/mysql-8.4/` when present in your checkout
- `cfg/percona-5.7/`
- `cfg/percona-8.0/`
- `cfg/mariadb-10.4/` through newer MariaDB 10.x directories present in `cfg/`
- `cfg/mariadb-11.4/`

Older directories may still exist for compatibility in some checkouts, but this
page focuses on the MySQL 5.7, MySQL 8.x, Percona 5.7/8.0 and MariaDB 10.4+
or 11.x generation used by current `.env` examples.

## Override mechanism

Each database configuration directory ships examples such as:

- `devilbox-custom.cnf-example` — a minimal template for local overrides.
- `devilbox-performance.cnf-example` — a larger performance-oriented sample.

Copy an example to a new `*.cnf` file in the same directory and edit it. Do not
edit the `*-example` file if you want the database to load the setting.

```bash
cd path/to/devilbox
cp cfg/mysql-8.0/devilbox-custom.cnf-example cfg/mysql-8.0/local.cnf
```

Then edit `cfg/mysql-8.0/local.cnf`:

```ini
[mysqld]
max_allowed_packet=256M
innodb_buffer_pool_size=1024M
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
sql_mode="NO_ENGINE_SUBSTITUTION"
```

Restart the database container after changing configuration:

```bash
./dvl.sh restart mysql
```

If you are not using `dvl.sh`, restart the `mysql` service with your normal
Compose workflow from the Devilbox root.

## Common settings

### max_allowed_packet

`max_allowed_packet` controls the largest packet the server accepts. Increase it
when imports or applications fail with packet-size errors.

```ini
[mysqld]
max_allowed_packet=256M
```

The performance examples in `cfg/mysql-8.0/` use a much larger byte value for
heavy local workloads. Use only as much as your projects require.

### innodb_buffer_pool_size

`innodb_buffer_pool_size` controls how much memory InnoDB can use for cached data
and indexes. Local development values are usually smaller than production.

```ini
[mysqld]
innodb_buffer_pool_size=1024M
```

Keep this below the memory available to Docker and the database container.

### character-set-server

Use `utf8mb4` for modern Unicode support.

```ini
[mysqld]
character-set-server=utf8mb4
```

Pair it with a matching collation.

### collation-server

Choose the default collation for newly created schemas and tables.

```ini
[mysqld]
collation-server=utf8mb4_unicode_ci
```

Use a collation supported by your selected MySQL, Percona or MariaDB version.

### sql_mode

`sql_mode` controls server compatibility and strictness. The performance example
for MySQL 8.0 includes:

```ini
[mysqld]
sql_mode="NO_ENGINE_SUBSTITUTION"
```

Only relax modes when a local legacy project requires it. Prefer matching
production behavior for application development.

## Verify loaded values

`dvl.sh` exposes an `exec` subcommand and forwards the remaining arguments into
the target container. To verify a MySQL variable:

```bash
./dvl.sh exec mysql mysql -u root -p -e "SHOW VARIABLES LIKE '%packet%'"
```

For a passwordless local root account, press Enter at the password prompt. If
`MYSQL_ROOT_PASSWORD` is set in `.env`, use that value.

You can verify other settings in the same way:

```bash
./dvl.sh exec mysql mysql -u root -p -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size'"
./dvl.sh exec mysql mysql -u root -p -e "SHOW VARIABLES LIKE 'character_set_server'"
./dvl.sh exec mysql mysql -u root -p -e "SHOW VARIABLES LIKE 'collation_server'"
./dvl.sh exec mysql mysql -u root -p -e "SHOW VARIABLES LIKE 'sql_mode'"
```

## Troubleshooting

- Confirm `MYSQL_SERVER` in `.env` matches the directory you edited.
- Confirm the file ends in `.cnf`; `*.cnf-example` files are examples only.
- Put server settings under `[mysqld]` and client/export settings under their
  matching sections such as `[mysqldump]`.
- Restart the database container after every change.
- If a setting is rejected, check whether your selected MySQL, Percona or
  MariaDB version supports that variable name and value.
