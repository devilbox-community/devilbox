---
title: "Enable and configure Blackfire"
description: "Enable Blackfire profiling in Devilbox with the maintained compose override snippet."
---

# Enable and configure Blackfire

Blackfire profiles PHP requests and CLI commands so you can find slow code,
database bottlenecks, and memory-heavy paths in local projects.

## How it works

Devilbox keeps optional integrations as override snippets in the `compose/`
directory. To enable Blackfire, copy its snippet into the project root as
`docker-compose.override.yml`, then start the stack.

## Enable

```bash
cp compose/docker-compose.override.yml-blackfire docker-compose.override.yml
./dvl.sh up
```

## Configuration

The snippet defines service `blackfire` with image
`blackfire/blackfire:${BLACKFIRE:-latest}`, hostname `blackfire`, and IP
`172.16.238.200`. It does not expose host ports or mount volumes.

Set real Blackfire credentials in `.env` before starting:

| Variable | Default | Purpose |
|---|---|---|
| `BLACKFIRE` | `latest` | Blackfire agent image tag. |
| `BLACKFIRE_SERVER_ID` | `id` | Server ID for the Blackfire agent. |
| `BLACKFIRE_SERVER_TOKEN` | `token` | Server token for the Blackfire agent. |
| `BLACKFIRE_CLIENT_ID` | `id` | Client ID for Blackfire CLI usage. |
| `BLACKFIRE_CLIENT_TOKEN` | `token` | Client token for Blackfire CLI usage. |

Enable the PHP extension and avoid collecting Xdebug overhead while profiling:

```bash
PHP_MODULES_ENABLE=blackfire
PHP_MODULES_DISABLE=xdebug
```

Copy the matching Blackfire PHP ini template for your selected PHP version if
your image ships one:

```bash
cp cfg/php-ini-8.3/devilbox-php.ini-blackfire cfg/php-ini-8.3/blackfire.ini
```

## Usage

Profile a web request from inside the PHP container:

```bash
./dvl.sh exec blackfire curl http://my-project.loc/
```

Profile a PHP CLI command:

```bash
./dvl.sh exec blackfire run php htdocs/index.php
```

Configure the CLI automatically when the startup helper exists:

```bash
cp autostart/configure-blackfire-cli.sh-example autostart/configure-blackfire-cli.sh
```

## Disable

```bash
./dvl.sh down
rm docker-compose.override.yml
./dvl.sh up
```

Remove `blackfire.ini` or update `PHP_MODULES_ENABLE` if you no longer want the
PHP extension loaded.

## Troubleshooting

- If the agent exits, confirm `BLACKFIRE_SERVER_ID` and
  `BLACKFIRE_SERVER_TOKEN` are not placeholder values.
- If profiles are empty, disable Xdebug and restart the PHP container.
- If the CLI cannot connect, confirm the PHP container can resolve hostname
  `blackfire` on the Devilbox network.

## See also

- [Add your own Docker image](/advanced/add-your-own-docker-image/)
- [Docker Compose override file](/configuration-files/docker-compose-override-yml/)
