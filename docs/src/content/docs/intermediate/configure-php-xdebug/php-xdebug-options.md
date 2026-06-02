---
title: "Xdebug options explained"
---

orphan

# Xdebug options explained

Devilbox uses normal PHP ini snippets for Xdebug. Create an
`xdebug.ini` file in the PHP version directory you run, for example
`cfg/php-ini-8.4/xdebug.ini` or `cfg/php-ini-8.3/xdebug.ini`.

## Example

```ini
zend_extension=xdebug.so

xdebug.mode=debug
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
xdebug.start_with_request=yes
xdebug.idekey=PHPSTORM
xdebug.log=/var/log/php/xdebug.log
```

## `zend_extension`

Loads the Xdebug extension. Keep `zend_extension=xdebug.so` in the
version-specific ini file unless your image already loads Xdebug another
way.

## `xdebug.mode`

Controls which Xdebug features are active. Use `debug` for step
debugging from an IDE or editor.

Multiple modes can be comma-separated if you need other Xdebug features,
but enabling fewer modes keeps PHP startup and requests lighter.

## `xdebug.client_host`

Defines where the PHP container connects when a debug session starts. For
current Docker Desktop on macOS and Windows, use
`host.docker.internal`.

On Linux, Devilbox maps `host.docker.internal` to Docker Engine's
`host-gateway` in `docker-compose.yml`. If you use a customized compose
file without that mapping, either add it back or set this value to the
host IP reachable from the PHP container.

## `xdebug.client_port`

Defines the port where your IDE or editor listens for DBGp connections.
Xdebug 3 defaults to `9003`; configure the same port in PhpStorm, Visual
Studio Code, Sublime Text, or another debug client.

:::caution
Port `9003` must be open on the host. If a firewall prompt appears, allow
your IDE or editor to accept incoming connections on private/local
networks.
:::

## `xdebug.start_with_request`

Controls when Xdebug starts a debugging session. Use `yes` for the
Devilbox examples so every request tries to connect to the listening
client.

For day-to-day work you can switch this to `trigger` and start sessions
only when your browser extension or request sets an Xdebug trigger.

## `xdebug.idekey`

Passes an IDE key to the DBGp client. Many modern clients do not require
a specific key, but setting one keeps behavior explicit and helps when
multiple tools listen on the same workstation.

Common values used in these guides are:

- `PHPSTORM` for PhpStorm.
- `VSCODE` for Visual Studio Code.
- `sublime.xdebug` for Sublime Text.

## `xdebug.log`

Writes Xdebug connection diagnostics. Keep the path
`/var/log/php/xdebug.log` so the log is available through Devilbox's
normal PHP log directory for the selected PHP version.

:::tip
Enable the log while validating a new setup, then remove or comment it if
the file becomes too noisy during normal development.
:::
