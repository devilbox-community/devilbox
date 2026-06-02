---
title: "Enable and configure Ngrok"
description: "Enable Ngrok tunneling in Devilbox with the maintained compose override snippet."
---

# Enable and configure Ngrok

Ngrok exposes a local Devilbox project through a temporary public URL, which is
useful for webhook testing, client previews, and mobile-device checks.

## How it works

Devilbox keeps optional integrations as override snippets in the `compose/`
directory. To enable Ngrok, copy its snippet into the project root as
`docker-compose.override.yml`, then start the stack.

## Enable

```bash
cp compose/docker-compose.override.yml-ngrok docker-compose.override.yml
./dvl.sh up
```

## Configuration

The snippet defines service `ngrok` with image `devilbox/ngrok:0.3`, hostname
`ngrok`, IP `172.16.238.202`, and admin port `${HOST_PORT_NGROK:-4040}:4040`.
It does not mount volumes.

| Variable | Default | Purpose |
|---|---|---|
| `NGROK_HTTP_TUNNELS` | `httpd:httpd:80` | Tunnel definitions. |
| `NGROK_AUTHTOKEN` | empty | Ngrok account token. |
| `NGROK_REGION` | `us` | Region used by the Ngrok client. |
| `HOST_PORT_NGROK` | `4040` | Host port for the Ngrok inspection UI. |

Tunnel definitions use this format:

```text
<public-name>:<docker-hostname>:<container-port>
```

For example:

```bash
NGROK_HTTP_TUNNELS=my-project.loc:httpd:80
NGROK_AUTHTOKEN=<your token>
NGROK_REGION=us
```

## Usage

Open the Ngrok inspection UI:

```bash
open http://localhost:4040
```

Expose the default HTTPD service:

```bash
NGROK_HTTP_TUNNELS=my-project.loc:httpd:80
./dvl.sh up
```

Expose Varnish instead of HTTPD when the Varnish override is active:

```bash
NGROK_HTTP_TUNNELS=my-project.loc:varnish:6081
./dvl.sh up
```

## Disable

```bash
./dvl.sh down
rm docker-compose.override.yml
./dvl.sh up
```

## Troubleshooting

- If no public URL appears, set a valid `NGROK_AUTHTOKEN` and check the Ngrok
  container logs.
- If the tunnel opens but your site returns an error, verify the second field in
  `NGROK_HTTP_TUNNELS` is a Docker hostname reachable from the Ngrok container.
- If the inspection UI does not load, change `HOST_PORT_NGROK` when port `4040`
  is already in use.

## See also

- [Add your own Docker image](/advanced/add-your-own-docker-image/)
- [Docker Compose override file](/configuration-files/docker-compose-override-yml/)
