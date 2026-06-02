---
title: "Docker on MacOS: Xdebug for Visual Studio Code"
---

orphan

# Docker on MacOS: Xdebug for Visual Studio Code

Use this guide to debug Devilbox projects with the current Visual Studio
Code release, the `xdebug.php-debug` extension, PHP 8.3 or 8.4, Xdebug
3, and Docker Desktop on macOS.

## Prerequisites

- A running Devilbox checkout on macOS.
- Docker Desktop for Mac.
- Visual Studio Code with the `xdebug.php-debug` extension installed.
- A project below `./data/www` or the directory configured for HTTPD data.

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

Open the project directory, such as `data/www/myapp`, as your VS Code
workspace. The examples below assume the web root is `htdocs`.

## Configure VS Code

Create or update `.vscode/launch.json` in the project workspace:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for Devilbox Xdebug",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "pathMappings": {
        "/shared/httpd/myapp": "${workspaceFolder}"
      },
      "log": true,
      "xdebugSettings": {
        "max_children": 128,
        "max_data": 512,
        "max_depth": 3
      }
    }
  ]
}
```

Start **Listen for Devilbox Xdebug** before loading the page in your
browser.

:::tip
The extension ID is `xdebug.php-debug`. If an older guide mentions a
different PHP debug extension name, replace it with this extension.
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
xdebug.idekey=VSCODE

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

Open your project URL while the VS Code listener is running. Breakpoints
should bind once the path mapping matches the container path.

:::caution
If VS Code receives connections but opens duplicate files, correct the
`pathMappings` entry before changing the PHP configuration again.
:::
