---
title: "Host address alias on MacOS"
---

# Host address alias on MacOS

Modern Docker Desktop for macOS already provides the host alias Xdebug
needs. Do not add a loopback alias unless you have a custom Docker engine
that lacks `host.docker.internal`.

## Default macOS behavior

Inside a Devilbox PHP container, the hostname below resolves to your Mac:

```text
host.docker.internal
```

Use it as the Xdebug 3 client host:

```ini
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
```

Start PHP and enter the container:

```bash
./dvl.sh up php
./dvl.sh shell
```

Verify resolution:

```bash
getent hosts host.docker.internal || ping -c1 host.docker.internal
```

:::note
Docker Desktop injects this name into container DNS. The IP can change,
so configure the hostname, not a hard-coded address.
:::

## When a custom alias is still relevant

You only need a custom alias when all of these are true:

1. You are not using Docker Desktop on macOS.
2. `host.docker.internal` does not resolve inside the PHP container.
3. Your Docker engine cannot add the host gateway name automatically.

For Linux Docker Engine setups, use the Linux Xdebug guides instead:

- [Linux PhpStorm](/intermediate/configure-php-xdebug/linux/phpstorm/)
- [Linux VS Code](/intermediate/configure-php-xdebug/linux/vscode/)
- [Linux Sublime](/intermediate/configure-php-xdebug/linux/sublime/)

## Check your active Xdebug config

Inside the PHP container:

```bash
php -i | grep -E 'xdebug.client_host|xdebug.client_port|xdebug.mode'
```

Expected host value:

```text
xdebug.client_host => host.docker.internal
```

## Troubleshooting

If your IDE does not receive a connection:

1. Confirm the IDE listens on port `9003`.
2. Confirm Xdebug mode includes `debug`.
3. Confirm macOS firewall rules allow incoming IDE connections.
4. Restart the PHP container after changing Xdebug settings.

```bash
./dvl.sh restart php
```

:::caution
Old `ifconfig lo0 alias` recipes are no longer the default macOS path.
Prefer Docker's built-in host alias so the setup survives network and
Docker Desktop changes.
:::
