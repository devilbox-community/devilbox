---
title: "Docker on MacOS: Xdebug for Sublime Text 3"
---

orphan

# Docker on MacOS: Xdebug for Sublime Text

Use this guide to debug Devilbox projects with Sublime Text 4, the
`xdebug-client` package, PHP 8.3 or 8.4, Xdebug 3, and Docker Desktop on
macOS.

## Prerequisites

- A running Devilbox checkout on macOS.
- Docker Desktop for Mac.
- Sublime Text 4 with Package Control installed.
- The `xdebug-client` package installed from Package Control.

See also: [Xdebug options explained](../php-xdebug-options/).

:::tip
Current Docker Desktop provides `host.docker.internal` automatically. The
old macOS loopback alias workaround is no longer required for this setup.
:::

## Assumptions

| Setting | Example |
|---|---|
| Devilbox directory | `/Users/cytopia/repo/devilbox` |
| Local project path | `/Users/cytopia/repo/devilbox/data/www/myapp` |
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
    "/shared/httpd/myapp": "/Users/cytopia/repo/devilbox/data/www/myapp"
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
host> cd /Users/cytopia/repo/devilbox
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

## Restart Devilbox

Restart the PHP container so the new ini file is loaded:

```bash
host> cd /Users/cytopia/repo/devilbox
host> docker-compose stop php
host> docker-compose rm -f php
host> docker-compose up php httpd bind
```

Open your project URL with the Sublime listener active. Sublime should
stop at breakpoints once the path mapping matches the container path.

:::caution
If Sublime listens but never stops, check macOS firewall prompts and
allow Sublime Text to accept incoming connections on port `9003`.
:::
