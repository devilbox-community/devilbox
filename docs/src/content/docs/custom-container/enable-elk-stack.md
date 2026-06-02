---
title: "Enable and configure ELK Stack"
description: "Enable the classic Elasticsearch, Logstash, and Kibana override snippet for Devilbox."
---

# Enable and configure ELK Stack

The ELK Stack adds Elasticsearch, Logstash, and Kibana for local log ingestion,
search, and dashboards. Use it when you need compatibility with the maintained
classic Devilbox ELK snippet.

## How it works

Devilbox keeps optional integrations as override snippets in the `compose/`
directory. To enable ELK Stack, copy its snippet into the project root as
`docker-compose.override.yml`, then start the stack.

## Enable

```bash
cp compose/docker-compose.override.yml-elk docker-compose.override.yml
./dvl.sh up
```

## Configuration

The snippet currently uses Elastic OSS images with `${ELK_SERVER:-6.6.1}`:

| Service | Image | Host port | Container port | Volume |
|---|---|---|---|---|
| `elastic` | `docker.elastic.co/elasticsearch/elasticsearch-oss:${ELK_SERVER:-6.6.1}` | `${HOST_PORT_ELK_ELASTIC:-9200}` | `9200` | `devilbox-elastic` |
| `logstash` | `docker.elastic.co/logstash/logstash-oss:${ELK_SERVER:-6.6.1}` | `${HOST_PORT_ELK_LOGSTASH:-9600}` | `9600` | `devilbox-logstash` |
| `kibana` | `docker.elastic.co/kibana/kibana-oss:${ELK_SERVER:-6.6.1}` | `${HOST_PORT_ELK_KIBANA:-5601}` | `5601` | none |

Environment variables from the snippet:

| Variable | Default | Purpose |
|---|---|---|
| `ELK_SERVER` | `6.6.1` | Shared Elasticsearch, Logstash, and Kibana image tag. |
| `HOST_PORT_ELK_ELASTIC` | `9200` | Host port for Elasticsearch. |
| `HOST_PORT_ELK_LOGSTASH` | `9600` | Host port for Logstash monitoring API. |
| `HOST_PORT_ELK_KIBANA` | `5601` | Host port for Kibana. |
| `TIMEZONE` | `UTC` | Container timezone. |

The compose snippet intentionally reflects the classic ELK integration. For a
lighter modern search service, consider the agentic `opensearch` optional
container via `CONTAINERS_CONFIG_OPTIONAL` instead.

## Usage

Check Elasticsearch health:

```bash
curl http://localhost:9200/_cluster/health?pretty
```

Open Kibana:

```bash
open http://localhost:5601
```

Tail Logstash logs while testing an ingestion pipeline:

```bash
docker compose logs -f logstash
```

## Disable

```bash
./dvl.sh down
rm docker-compose.override.yml
./dvl.sh up
```

Remove the Docker volumes if you also want to delete indexed data:

```bash
docker volume rm devilbox-elastic devilbox-logstash
```

## Troubleshooting

- If Elasticsearch is slow to become healthy, increase Docker memory and wait
  for the single-node bootstrap to finish.
- If Kibana cannot connect, verify `elastic` is healthy and both services use
  the same `ELK_SERVER` tag.
- If ports are already in use, set the `HOST_PORT_ELK_*` variables in `.env`.

## See also

- [Add your own Docker image](/advanced/add-your-own-docker-image/)
- [Docker Compose override file](/configuration-files/docker-compose-override-yml/)
- [Agentic tools toggle](/getting-started/agentic-tools-toggle/)
