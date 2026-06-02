---
title: "Docker on Linux: Xdebug for Visual Studio Code"
---

orphan  

# Docker on Linux: Xdebug for Visual Studio Code

Docker on Linux allows Xdebug to automatically connect back to the host
system without the need of an explicit IP address.


## Prerequisites

Ensure you know how to customize `php.ini` values for the Devilbox and
have a rough understanding about common Xdebug options.

<div class="seealso">

\* `php-ini` \* `configure-php-xdebug-options`

</div>

## Assumption

For the sake of this example, we will assume the following settings and
file system paths:

| Directory                    | Path                                   |
|------------------------------|----------------------------------------|
| Devilbox git directory       | `/home/cytopia/repo/devilbox`          |
| `env-httpd-datadir`          | `./data/www`                           |
| Resulting local project path | `/home/cytopia/repo/devilbox/data/www` |
| Selected PHP version         | `5.6`                                  |

The **Resulting local project path** is the path where all projects are
stored locally on your host operating system. No matter what this path
is, the equivalent remote path (inside the Docker container) is always
`/shared/httpd`.

> [!IMPORTANT]
> Remember this, when it comes to path mapping in your IDE/editor
> configuration.

## Configuration

### Install vscode-php-debug for VSCode

Ensure you have `vscode-php-debug` installed for Visual Studio Code.

> <div class="seealso">
>
> `xdebug ide vscode php debug`
>
> </div>

### Configure VSCode

You will need to configure the path mapping in `launch.json` (VSCode
configuration file):

> ``` json
> {
>    "version": "0.2.0",
>    "configurations": [
>       {
>          "name": "Xdebug for Project mytest",
>          "type": "php",
>          "request": "launch",
>          "port": 9000,
>          "pathMappings": {
>             "/shared/httpd/mytest/htdocs": "${workspaceFolder}/htdocs"
>          },
>          "log": true,
>          "xdebugSettings": {
>             "max_children": 128,
>             "max_data": 512,
>             "max_depth": 3
>          }
>       },
>       {
>          "name": "Launch currently open script",
>          "type": "php",
>          "request": "launch",
>          "program": "${file}",
>          "cwd": "${fileDirname}",
>          "port": 9000
>       }
>    ]
> }
> ```
>
> > [!IMPORTANT]
> > Recall the path settings from the *Assumption* section and adjust if
> > your configuration differs!
>
> > [!IMPORTANT]
> > The above example configures Xdebug for a single project **mytest**.
> > Add more projects as you need.
>
> <div class="seealso">
>
> \* <https://go.microsoft.com/fwlink/?linkid=830387> \*
> <https://github.com/cytopia/devilbox/issues/381>
>
> </div>

### Configure php.ini

> [!NOTE]
> The following example show how to configure PHP Xdebug for PHP 7.4:

Create an `xdebug.ini` file (must end by `.ini`):

> ``` bash
> # Navigate to the Devilbox git directory
> host> cd path/to/devilbox
>
> # Navigate to PHP 7.4 ini configuration directory
> host> cd cfg/php-ini-7.4/
>
> # Create and open debug.ini file
> host> vi xdebug.ini
> ```

Copy/paste all of the following lines into the above created
`xdebug.ini` file:

> ``` ini
> ; Defaults
> zend_extension=xdebug.so
> xdebug.mode=debug
> xdebug.client_port=9000
> xdebug.client_host=docker.for.lin.host.internal
> xdebug.remote_handler=dbgp
> xdebug.start_with_request=yes
>
> ; Controls the protection mechanism for infinite recursion protection
> xdebug.max_nesting_level=250
>
> ; idekey value is specific to Visual Studio Code
> xdebug.idekey=VSCODE
> ```

> [!NOTE]
> Host os and editor specific settings are highlighted in yellow and are
> worth googling to get a better understanding of the tools you use and
> to be more efficient at troubleshooting.

### Restart the Devilbox

Restarting the Devilbox is important in order for it to read the new PHP
settings. Note that the following example only starts up PHP, HTTPD and
Bind.

``` bash
# Navigate to the Devilbox git directory
host> cd path/to/devilbox

# Stop, remove stopped container and start
host> docker-compose stop
host> docker-compose rm
host> docker-compose up php httpd bind
```

<div class="seealso">

`start-the-devilbox-stop-and-restart` (Why do `docker-compose rm`?)

</div>
