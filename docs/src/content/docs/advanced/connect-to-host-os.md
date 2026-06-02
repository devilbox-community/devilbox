---
title: "Connect to host OS"
---

# Connect to host OS

Use `host.docker.internal` when a Devilbox container must connect back to
a service running on your host operating system.

## Start with the host service

Make the host service listen on an address Docker can reach. For local
development, bind it to all interfaces or to the Docker host gateway.

Examples:

```text
0.0.0.0:3306
127.0.0.1:3000
```

:::caution
If a service only listens on `127.0.0.1`, Docker Desktop can still reach
it through `host.docker.internal`. Native Linux engines may require the
service to listen on the bridge gateway or all interfaces.
:::

## macOS and Windows

Docker Desktop provides this hostname automatically:

```text
host.docker.internal
```

Use it from inside PHP:

```bash
./dvl.sh shell
curl http://host.docker.internal:3000
```

Use it in application config:

```dotenv
API_BASE_URL=http://host.docker.internal:3000
```

For Xdebug 3, use the same host alias:

```ini
xdebug.client_host=host.docker.internal
```

## Linux Docker Engine

Docker Engine 20.10+ supports the host gateway alias. Add it to a local
override when your engine does not inject it already:

```yaml
services:
  php:
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

Then recreate PHP:

```bash
docker compose up -d --force-recreate php
```

Inside PHP, verify the route:

```bash
getent hosts host.docker.internal
curl http://host.docker.internal:3000
```

## Devilbox bridge gateway

The Devilbox bridge network also has a gateway address. Check the active
value from Docker:

```bash
docker network inspect devilbox_app_net \
  --format '{{ (index .IPAM.Config 0).Gateway }}'
```

Use the gateway only when `host.docker.internal` is unavailable or when
you need to debug routing directly.

## Common examples

Connect to a host Node service:

```bash
curl http://host.docker.internal:5173
```

Connect to a host MySQL service:

```bash
mysql -h host.docker.internal -P 3306 -u root -p
```

Connect from Magento config:

```php
'host' => 'host.docker.internal',
'port' => '3306',
```

## Firewall checks

If the hostname resolves but connections time out:

1. Allow Docker Desktop or the Docker bridge through the host firewall.
2. Confirm the service is listening on the expected port.
3. Confirm no VPN is rewriting Docker routes.

```bash
lsof -nP -iTCP:3000 -sTCP:LISTEN
```

:::note
Use `./dvl.sh shell` for interactive checks and `./dvl.sh exec "..."` for
one-off commands from the PHP container.
:::
