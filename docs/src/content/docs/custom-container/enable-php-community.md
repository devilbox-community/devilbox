---
title: "Enable and configure PHP Community"
description: "Switch Devilbox PHP to the community image with the maintained compose override snippet."
---

# Enable and configure PHP Community

PHP Community replaces the default Devilbox PHP-FPM image with a community
flavour while keeping the same `php` service, mounts, and network identity.

## How it works

Devilbox keeps optional integrations as override snippets in the `compose/`
directory. To enable PHP Community, copy its snippet into the project root as
`docker-compose.override.yml`, then start the stack.

## Enable

```bash
cp compose/docker-compose.override.yml-php-community docker-compose.override.yml
./dvl.sh up
```

## Configuration

The snippet overrides the existing `php` service image:

```yaml
image: devilbox/php-fpm-community:${PHP_SERVER}-${PHP_COMMUNITY_FLAVOUR:-devilbox}
```

It uses the same service name, hostname, ports, volumes, and IP address as the
standard PHP service. Configure it with existing PHP settings plus:

| Variable | Default | Purpose |
|---|---|---|
| `PHP_SERVER` | from your `.env` | PHP version tag used by the PHP service. |
| `PHP_COMMUNITY_FLAVOUR` | `devilbox` | Community image flavour suffix. |

Example `.env` entries:

```bash
PHP_SERVER=8.3
PHP_COMMUNITY_FLAVOUR=devilbox
```

## Usage

Start the stack and confirm the PHP image:

```bash
./dvl.sh up
docker compose ps php
```

Check the active PHP version from inside the container:

```bash
./dvl.sh exec php -v
```

Use the same project workflow as the standard PHP container:

```bash
./dvl.sh shell
composer install
```

## Disable

```bash
./dvl.sh down
rm docker-compose.override.yml
./dvl.sh up
```

## Troubleshooting

- If Docker cannot pull the image, verify the combination of `PHP_SERVER` and
  `PHP_COMMUNITY_FLAVOUR` exists.
- If PHP still uses the old image, recreate the service with `./dvl.sh down`
  before starting it again.
- If extensions differ from the standard image, review `PHP_MODULES_ENABLE` and
  `PHP_MODULES_DISABLE` in `.env`.

## See also

- [Add your own Docker image](/advanced/add-your-own-docker-image/)
- [Docker Compose override file](/configuration-files/docker-compose-override-yml/)
