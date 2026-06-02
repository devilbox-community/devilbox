---
title: "Enable and configure Meilisearch"
description: "Enable Meilisearch in Devilbox with the maintained compose override snippet."
---

# Enable and configure Meilisearch

Meilisearch is a fast search engine for local application development, useful
for testing product search, documentation search, and autocomplete workflows.

## How it works

Devilbox keeps optional integrations as override snippets in the `compose/`
directory. To enable Meilisearch, copy its snippet into the project root as
`docker-compose.override.yml`, then start the stack.

## Enable

```bash
cp compose/docker-compose.override.yml-meilisearch docker-compose.override.yml
./dvl.sh up
```

## Configuration

The snippet defines service `meilisearch` with image
`getmeili/meilisearch:${MEILI_SERVER:-latest}`, hostname `meilisearch`, IP
`172.16.238.203`, command `meilisearch`, host port
`${HOST_PORT_MEILI:-7700}:7700`, and volume `devilbox-meilisearch:/meili_data`.

| Variable | Default | Purpose |
|---|---|---|
| `MEILI_SERVER` | `latest` | Meilisearch image tag. |
| `MEILI_MASTER_KEY` | empty | Master key for protected API access. |
| `HOST_PORT_MEILI` | `7700` | Host port for the Meilisearch API. |

If `MEILI_MASTER_KEY` is set, include it as a bearer token in API requests.

## Usage

Check service health:

```bash
curl http://localhost:7700/health
```

Create an index and add a document:

```bash
curl -X POST http://localhost:7700/indexes -H 'Content-Type: application/json' \
  --data '{"uid":"books","primaryKey":"id"}'
curl -X POST http://localhost:7700/indexes/books/documents -H 'Content-Type: application/json' \
  --data '[{"id":1,"title":"Devilbox local search"}]'
```

Search the index:

```bash
curl 'http://localhost:7700/indexes/books/search?q=devilbox'
```

## Disable

```bash
./dvl.sh down
rm docker-compose.override.yml
./dvl.sh up
```

Remove the data volume if you also want to delete indexed documents:

```bash
docker volume rm devilbox-meilisearch
```

## Troubleshooting

- If requests return unauthorized, include the `MEILI_MASTER_KEY` bearer token.
- If port `7700` is busy, set `HOST_PORT_MEILI` to another host port.
- If data persists after disabling, remove the `devilbox-meilisearch` volume.

## See also

- [Add your own Docker image](/advanced/add-your-own-docker-image/)
- [Docker Compose override file](/configuration-files/docker-compose-override-yml/)
