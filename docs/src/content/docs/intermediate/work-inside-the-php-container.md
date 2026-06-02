---
title: "Work inside the PHP container"
---

# Work inside the PHP container

Use the PHP container as your project shell. It has the same mounted
project files, the same service hostnames, and the toolchain expected by
Devilbox workflows.

## Enter PHP

From the Devilbox repository root:

```bash
./dvl.sh up php
./dvl.sh shell
```

`./dvl.sh shell [php-version]` opens an interactive shell as the
`devilbox` user. It auto-detects `.devilbox.yaml` from the current
project path when possible.

Examples:

```bash
./dvl.sh shell
./dvl.sh shell php82
./dvl.sh shell php84
```

:::tip
See the full [DVL CLI reference](/intermediate/dvl-cli/) for every
subcommand and alias.
:::

## Run one command without entering

Use `exec` for short tasks:

```bash
./dvl.sh exec "php -v"
./dvl.sh exec "composer --version"
```

Dedicated wrappers are better for common project commands:

```bash
./dvl.sh composer install
./dvl.sh magento cache:clean
./dvl.sh magerun cache:status
```

## Work in a project

Projects live under `data/www` on the host and `/shared/httpd` in PHP.

```bash
cd data/www/my-project
../../../dvl.sh shell
```

Inside the container:

```bash
cd /shared/httpd/my-project
composer install
npm install
npm run build
```

If you use the global installer symlink, the host command is shorter:

```bash
cd data/www/my-project
dvl shell
```

## Magento workflow

For Magento projects, prefer the DVL wrappers from the host:

```bash
./dvl.sh composer install
./dvl.sh magento setup:upgrade
./dvl.sh magento cache:clean
./dvl.sh magento indexer:reindex
```

Inside the PHP shell, direct commands also work:

```bash
php bin/magento cache:clean
php bin/magento setup:di:compile
composer require vendor/package
```

## Node workflow

Use the PHP container when your selected PHP image contains the required
Node tooling:

```bash
npm install
npm run dev
npm run build
```

For long-running Vite, Next.js, or frontend dev servers, bind them to all
interfaces so the host can reach them:

```bash
npm run dev -- --host 0.0.0.0
```

Then open the exposed host port configured for that project or stack.

## User and permissions

The shell runs as `devilbox`, mapped to `NEW_UID` and `NEW_GID` from
`.env`. Files created in the container should be editable on the host.

Check the mapping:

```bash
id
touch /shared/httpd/permission-check.txt
exit
ls -l data/www/permission-check.txt
rm data/www/permission-check.txt
```

If ownership is wrong, update `.env`:

```dotenv
NEW_UID=501
NEW_GID=20
```

Then recreate containers:

```bash
./dvl.sh down
./dvl.sh up
```

## Service hostnames

Use service names from inside PHP:

| Service | Hostname | Typical port |
| --- | --- | --- |
| HTTPD | `httpd` | `80` / `443` |
| MySQL/MariaDB | `mysql` | `3306` |
| Redis | `redis` | `6379` |
| OpenSearch | `opensearch` | `9200` |
| DNS | `bind` | `53` |

Example database check:

```bash
mysql -h mysql -u root -p
```

## Become root only when needed

The `devilbox` user can use passwordless `sudo` in the PHP image:

```bash
sudo apt update
sudo apt install -y nmap
```

:::caution
Avoid creating project files as root. If you must run a privileged
command, switch back to `devilbox` before writing application files.
:::

## Leave the container

Exit the shell:

```bash
exit
```

Stop the stack when finished:

```bash
./dvl.sh down
```
