---
title: "Enable and configure Solr"
description: "Enable Solr search in Devilbox with the maintained compose override snippet."
---

# Enable and configure Solr

Solr provides a local search engine for testing indexing, faceted search, and
framework integrations that depend on an Apache Solr backend.

## How it works

Devilbox keeps optional integrations as override snippets in the `compose/`
directory. To enable Solr, copy its snippet into the project root as
`docker-compose.override.yml`, then start the stack.

## Enable

```bash
cp compose/docker-compose.override.yml-solr docker-compose.override.yml
./dvl.sh up
```

## Configuration

The snippet defines service `solr` with image `solr:${SOLR_SERVER:-latest}`,
hostname `solr`, IP `172.16.238.220`, host port
`${HOST_PORT_SOLR:-8983}:8983`, and volume
`devilbox-solr:/opt/solr/server/solr/mycores`.

The entrypoint pre-creates one core:

```yaml
entrypoint:
  - docker-entrypoint.sh
  - solr-precreate
  - ${SOLR_CORE_NAME:-devilbox}
```

| Variable | Default | Purpose |
|---|---|---|
| `SOLR_SERVER` | `latest` | Solr image tag. |
| `SOLR_CORE_NAME` | `devilbox` | Core created at startup. |
| `HOST_PORT_SOLR` | `8983` | Host port for Solr API and admin UI. |

## Usage

Open the Solr admin UI:

```bash
open http://localhost:8983
```

List cores:

```bash
curl 'http://localhost:8983/solr/admin/cores?action=STATUS&wt=json'
```

Index and query a sample document:

```bash
curl 'http://localhost:8983/solr/devilbox/update?commit=true' \
  -H 'Content-Type: application/json' --data '[{"id":"1","title":"Devilbox Solr"}]'
curl 'http://localhost:8983/solr/devilbox/select?q=title:Devilbox&wt=json'
```

## Disable

```bash
./dvl.sh down
rm docker-compose.override.yml
./dvl.sh up
```

Remove the data volume if you also want to delete Solr cores:

```bash
docker volume rm devilbox-solr
```

## Troubleshooting

- If the expected core is missing, verify `SOLR_CORE_NAME` and recreate the
  Solr container.
- If the UI does not load, check whether host port `8983` is already used.
- If indexed data remains after disabling, remove the `devilbox-solr` volume.

## See also

- [Add your own Docker image](/advanced/add-your-own-docker-image/)
- [Docker Compose override file](/configuration-files/docker-compose-override-yml/)
