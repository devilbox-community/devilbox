# cfg/multica-db

This directory is **bind-mounted** into the `multica-db` Wave 8F1 service at:

| Mount target | Mode | Purpose |
|---|---|---|
| `/docker-entrypoint-initdb.d` | ro | Postgres init scripts (`*.sql`, `*.sh`) run on **first boot only** when the data dir is empty |

> The actual Postgres data files live in `data/multica-db/` (lazy-created
> at runtime). Both are host-side bind mounts — they survive
> `docker compose down -v` and `./dvl.sh agent disable multica`.

## Typical layout

```
cfg/multica-db/
├── 00-extensions.sql      # CREATE EXTENSION IF NOT EXISTS vector; (pgvector)
├── 10-seed-fixtures.sql   # optional dev seed data
└── 99-grants.sh           # optional shell init
```

## First-time setup

The upstream image is `pgvector/pgvector:pg17`, so `pgvector` is preinstalled
but **not enabled** in the multica database. Drop a one-liner here before
the first `up`:

```sql
-- cfg/multica-db/00-extensions.sql
CREATE EXTENSION IF NOT EXISTS vector;
```

If multica is already running and the data dir is non-empty, init scripts
are skipped — connect with `psql` and run the `CREATE EXTENSION` manually
or wipe `data/multica-db/` to re-bootstrap.

## Upstream reference

- Repo:    `github.com/multica-ai/multica`
- Compose: `../multica/docker-compose.selfhost.yml`
- Env:     `../multica/.env.example`
