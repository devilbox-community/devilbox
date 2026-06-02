---
title: "Update the Devilbox"
---

# Update the Devilbox

Update Git files, Docker images, and local configuration together. Back
up first; updates can change service defaults and volume definitions.

## Backup first

From the Devilbox repository root:

```bash
mkdir -p ../devilbox-backups
tar -czf ../devilbox-backups/devilbox-data-$(date +%Y%m%d).tgz data/
tar -czf ../devilbox-backups/devilbox-cfg-$(date +%Y%m%d).tgz cfg/
cp .env ../devilbox-backups/env-$(date +%Y%m%d) 2>/dev/null || true
```

Also back up any local `docker-compose.override.yml` file:

```bash
cp docker-compose.override.yml \
  ../devilbox-backups/docker-compose.override.yml-$(date +%Y%m%d) 2>/dev/null || true
```

:::caution
Do not update before backing up project data, database files, and custom
configuration under `data/` and `cfg/`.
:::

## Stop the stack

```bash
./dvl.sh down
```

If containers are stuck, remove stopped containers explicitly:

```bash
docker compose rm -f
```

## Update the repository

For the main development branch:

```bash
git pull origin master
```

For a tagged release:

```bash
git fetch --tags
git checkout v1.0.1
```

## Compare `.env` with `env-example`

New releases can add, remove, or rename variables. Diff your active file
against the current template:

```bash
diff -u env-example .env
```

Or use an interactive diff tool:

```bash
vimdiff env-example .env
```

Keep local values such as `NEW_UID`, `NEW_GID`, selected service versions,
ports, and paths, but add any new required variables from `env-example`.

## Pull Docker images

Pull the images selected by your `.env` and override files:

```bash
docker compose pull
```

If you changed service versions, force recreation on startup:

```bash
docker compose rm -f
```

## Start again

```bash
./dvl.sh up
```

Check status and logs:

```bash
docker compose ps
docker compose logs --tail=100 php
```

Run the health check:

```bash
./dvl.sh doctor
```

## Refresh generated project config

If your projects use generated HTTPD or environment config, sync it after
updating:

```bash
./dvl.sh sync-httpd
./dvl.sh sync-env
```

Regenerate project YAML only when you intentionally want the current DVL
defaults applied:

```bash
./dvl.sh generate-yaml
```

## Update checklist

1. Backed up `data/`, `cfg/`, `.env`, and local overrides.
2. Stopped Devilbox with `./dvl.sh down`.
3. Ran `git pull origin master` or checked out the target tag.
4. Diffed `.env` against `env-example`.
5. Ran `docker compose pull`.
6. Restarted with `./dvl.sh up`.
7. Ran `./dvl.sh doctor` and checked logs.

:::tip
If the update fails, restore the backup and review
[Troubleshooting](/support/troubleshooting/).
:::
