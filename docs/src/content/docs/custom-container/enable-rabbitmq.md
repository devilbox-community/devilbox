---
title: "Enable and configure RabbitMQ"
description: "Enable RabbitMQ queues in Devilbox with the maintained compose override snippet."
---

# Enable and configure RabbitMQ

RabbitMQ provides AMQP queues for local development of workers, event-driven
applications, and message retry flows.

## How it works

Devilbox keeps optional integrations as override snippets in the `compose/`
directory. To enable RabbitMQ, copy its snippet into the project root as
`docker-compose.override.yml`, then start the stack.

## Enable

```bash
cp compose/docker-compose.override.yml-rabbitmq docker-compose.override.yml
./dvl.sh up
```

## Configuration

The snippet defines service `rabbit` with image
`rabbitmq:${RABBIT_SERVER:-management}`, hostname `rabbit`, IP
`172.16.238.210`, volume `devilbox-rabbit:/var/lib/rabbitmq`, AMQP port
`${HOST_PORT_RABBIT:-5672}:5672`, and management port
`${HOST_PORT_RABBIT_MGMT:-15672}:15672`.

| Variable | Default | Purpose |
|---|---|---|
| `RABBIT_SERVER` | `management` | RabbitMQ image tag. |
| `RABBIT_DEFAULT_VHOST` | `my_vhost` | Initial virtual host. |
| `RABBIT_DEFAULT_USER` | `guest` | Initial user. |
| `RABBIT_DEFAULT_PASS` | `guest` | Initial password. |
| `HOST_PORT_RABBIT` | `5672` | Host AMQP port. |
| `HOST_PORT_RABBIT_MGMT` | `15672` | Host management UI port. |

## Usage

Open the management UI:

```bash
open http://localhost:15672
```

Use AMQP from another Devilbox container with this DSN shape:

```text
amqp://guest:guest@rabbit:5672/my_vhost
```

Publish and consume a test message with the management API:

```bash
curl -u guest:guest -H 'content-type:application/json' \
  -X PUT http://localhost:15672/api/queues/my_vhost/devilbox-test
curl -u guest:guest -H 'content-type:application/json' \
  -X POST http://localhost:15672/api/exchanges/my_vhost/amq.default/publish \
  --data '{"routing_key":"devilbox-test","payload":"hello","payload_encoding":"string"}'
```

## Disable

```bash
./dvl.sh down
rm docker-compose.override.yml
./dvl.sh up
```

Remove the data volume if you also want to delete queues and messages:

```bash
docker volume rm devilbox-rabbit
```

## Troubleshooting

- If login fails, confirm the configured default user and password in `.env`.
- If AMQP clients cannot connect from containers, use hostname `rabbit`, not
  `localhost`.
- If ports are busy, set `HOST_PORT_RABBIT` or `HOST_PORT_RABBIT_MGMT` to free
  host ports.

## See also

- [Add your own Docker image](/advanced/add-your-own-docker-image/)
- [Docker Compose override file](/configuration-files/docker-compose-override-yml/)
