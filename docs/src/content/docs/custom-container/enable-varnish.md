---
title: "Enable and configure Varnish"
description: "Enable Varnish and optional HAProxy SSL offloading in Devilbox with the maintained compose override snippet."
---

# Enable and configure Varnish

Varnish adds an HTTP cache in front of Devilbox projects. The maintained
override also includes HAProxy so you can put HTTPS offloading in front of
Varnish when needed.

## How it works

Devilbox keeps optional integrations as override snippets in the `compose/`
directory. To enable Varnish, copy its snippet into the project root as
`docker-compose.override.yml`, then start the stack.

## Enable

```bash
cp compose/docker-compose.override.yml-varnish docker-compose.override.yml
./dvl.sh up
```

## Configuration

The snippet defines two services:

| Service | Image | Host ports | Purpose |
|---|---|---|---|
| `varnish` | `devilbox/varnish:${VARNISH_SERVER:-6}-0.3` | `${HOST_PORT_VARNISH:-6081}:6081` | HTTP cache in front of `httpd:80`. |
| `haproxy` | `devilbox/haproxy:0.3` | `${HOST_PORT_HAPROXY:-8080}:80`, `${HOST_PORT_HAPROXY_SSL:-8443}:443` | Optional frontend for Varnish with SSL offloading. |

The Varnish service mounts
`${DEVILBOX_PATH}/cfg/varnish-${VARNISH_SERVER:-6}:/etc/varnish.d`.
HAProxy mounts the Devilbox CA and HTTPD data directory.

| Variable | Default | Purpose |
|---|---|---|
| `VARNISH_SERVER` | `6` | Varnish image/config directory version. |
| `HOST_PORT_VARNISH` | `6081` | Host port for Varnish. |
| `VARNISH_CONFIG` | `/etc/varnish/default.vcl` | VCL file used by Varnish. |
| `VARNISH_CACHE_SIZE` | `128m` | Cache size. |
| `VARNISH_PARAMS` | `-p default_ttl=3600 -p default_grace=3600` | Extra varnishd parameters. |
| `HOST_PORT_HAPROXY` | `8080` | Host HTTP port for HAProxy. |
| `HOST_PORT_HAPROXY_SSL` | `8443` | Host HTTPS port for HAProxy. |

## Usage

Warm a project URL through Varnish:

```bash
curl -I http://localhost:6081/
```

Watch Varnish logs while making requests:

```bash
docker compose logs -f varnish
```

Use HAProxy in front of Varnish for HTTPS offloading:

```bash
curl -kI https://localhost:8443/
```

Place custom VCL files in `cfg/varnish-6/` and point `VARNISH_CONFIG` at the
file inside `/etc/varnish.d/`.

## Disable

```bash
./dvl.sh down
rm docker-compose.override.yml
./dvl.sh up
```

## Troubleshooting

- If Varnish returns backend errors, verify the VCL backend points to host
  `httpd` on port `80`.
- If custom VCL is ignored, confirm it is under the mounted
  `cfg/varnish-${VARNISH_SERVER}` directory and `VARNISH_CONFIG` uses the
  container path.
- If host ports conflict, adjust `HOST_PORT_VARNISH`, `HOST_PORT_HAPROXY`, or
  `HOST_PORT_HAPROXY_SSL`.

## See also

- [Add your own Docker image](/advanced/add-your-own-docker-image/)
- [Docker Compose override file](/configuration-files/docker-compose-override-yml/)
