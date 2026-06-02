---
title: "Docker on Linux: Xdebug for Sublime Text 3"
---

orphan

# Docker on Linux: Xdebug for Sublime Text

Use this guide to debug Devilbox projects with Sublime Text 4, the
`xdebug-client` package, PHP 8.3 or 8.4, and Xdebug 3 on Docker Engine
for Linux.

## Prerequisites

- A running Devilbox checkout on Linux.
- Sublime Text 4 with Package Control installed.
- The `xdebug-client` package installed from Package Control.
- A project below `./data/www` or the directory configured for HTTPD data.

See also: [Xdebug options explained](../php-xdebug-options/).

:::caution
On Linux, `host.docker.internal` needs Docker Engine 20.10+ host-gateway
support. Devilbox already declares `host.docker.internal:host-gateway` in
`docker-compose.yml` for PHP containers. Keep that mapping in custom
compose files or use the host IP address reachable from the container.
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

The local project path is where Sublime opens your files. The container
path is what PHP reports to the debug client.

## Configure Sublime Text 4

1. Install `xdebug-client` with Package Control.
2. Open **Preferences | Package Settings | Xdebug Client | Settings**.
3. Configure the listener and path mapping for your project.

```json
{
  "path_mapping": {
    "/shared/httpd/myapp": "/home/cytopia/repo/devilbox/data/www/myapp"
  },
  "url": "http://myapp.lvh.me/",
  "ide_key": "sublime.xdebug",
  "host": "0.0.0.0",
  "port": 9003
}
```

Start the Sublime debug listener before loading the page in your browser.

:::tip
Keep the mapping as specific as your project root. Mapping all of
`/shared/httpd` works, but project-level mappings make breakpoint issues
easier to diagnose.
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
xdebug.idekey=sublime.xdebug

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

Open your project URL with the Sublime listener active. Sublime should
stop at breakpoints once the path mapping matches the container path.

:::caution
If Sublime listens but never stops, confirm that no local firewall blocks
port `9003` and that the PHP container can resolve `host.docker.internal`.
:::
