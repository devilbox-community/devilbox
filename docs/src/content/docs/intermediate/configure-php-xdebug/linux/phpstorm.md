---
title: "Docker on Linux: Xdebug for PhpStorm"
---

orphan

# Docker on Linux: Xdebug for PhpStorm

Use this guide to debug Devilbox projects with PhpStorm 2024.3 or 2025.1,
PHP 8.3 or 8.4, and Xdebug 3 on Docker Engine for Linux.

## Prerequisites

- A running Devilbox checkout on Linux.
- PhpStorm 2024.3 or 2025.1.
- A project below `./data/www` or the directory configured for HTTPD data.
- Familiarity with custom PHP ini files in Devilbox.

See also: [Xdebug options explained](../php-xdebug-options/).

:::caution
On Linux, `host.docker.internal` is provided by Docker Engine 20.10+
through the `host-gateway` mapping. Devilbox already declares
`host.docker.internal:host-gateway` in `docker-compose.yml` for PHP
containers. If you run a heavily customized compose file, keep that
mapping or use your host IP address instead.
:::

## Assumptions

| Setting | Example |
|---|---|
| Devilbox directory | `/home/cytopia/repo/devilbox` |
| Local project path | `/home/cytopia/repo/devilbox/data/www/myapp` |
| Container project path | `/shared/httpd/myapp` |
| PHP version | `8.4` |
| Xdebug client host | `host.docker.internal` |
| Xdebug client port | `9003` |

Adjust the local project path if your `HTTPD_DOCROOT_DIR` or project name
differs. The container-side HTTPD root remains below `/shared/httpd`.

## Configure PhpStorm

1. Open **Settings | PHP | Debug** and set the Xdebug debug port to
   `9003`.
2. Open **Settings | PHP | Servers** and create a server named after your
   local Devilbox vhost, for example `myapp.lvh.me`.
3. Set the host to your vhost, keep the debugger as **Xdebug**, and enable
   path mappings.
4. Map `/home/cytopia/repo/devilbox/data/www/myapp` to
   `/shared/httpd/myapp`.
5. Start listening with **Run | Start Listening for PHP Debug
   Connections**.

:::tip
Use PhpStorm's **Validate** button in the server dialog if breakpoints do
not bind. Most issues are caused by a wrong local-to-container path map.
:::

## Configure Xdebug 3

Create `cfg/php-ini-8.4/xdebug.ini` in your Devilbox checkout. Use
`cfg/php-ini-8.3/xdebug.ini` if your project runs on PHP 8.3.

```bash
host> cd /home/cytopia/repo/devilbox
host> vi cfg/php-ini-8.4/xdebug.ini
```

Add the current Xdebug 3 settings:

```ini
zend_extension=xdebug.so

xdebug.mode=debug
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
xdebug.start_with_request=yes
xdebug.idekey=PHPSTORM

; Optional, useful while testing connections
xdebug.log=/var/log/php/xdebug.log
```

If `host.docker.internal` is not available in your custom Linux setup,
replace it with the host IP address reachable from the PHP container.

## Restart Devilbox

Restart the PHP container so the new ini file is loaded:

```bash
host> cd /home/cytopia/repo/devilbox
host> docker-compose stop php
host> docker-compose rm -f php
host> docker-compose up php httpd bind
```

Open a page in the browser with a breakpoint set in PhpStorm. PhpStorm
should receive the DBGp connection on port `9003`.

:::caution
If the connection reaches PhpStorm but files open as read-only container
paths, fix the PHP server mapping before changing Xdebug settings again.
:::
