---
title: "Docker on Linux: Xdebug for Visual Studio Code"
---

orphan

# Docker on Linux: Xdebug for Visual Studio Code

Use this guide to debug Devilbox projects with the current Visual Studio
Code release, the `xdebug.php-debug` extension, PHP 8.3 or 8.4, and
Xdebug 3 on Docker Engine for Linux.

## Prerequisites

- A running Devilbox checkout on Linux.
- Visual Studio Code with the `xdebug.php-debug` extension installed.
- A project below `./data/www` or the directory configured for HTTPD data.
- Familiarity with VS Code workspace folders and `launch.json`.

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
xdebug.idekey=VSCODE

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

Open your project URL while the VS Code listener is running. Breakpoints
should bind once the path mapping matches the container path.

:::caution
If VS Code receives connections but opens duplicate files, correct the
`pathMappings` entry before changing the PHP configuration again.
:::
