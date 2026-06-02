---
title: "Setup Drupal"
---

# Setup Drupal

This example installs Drupal 10 or 11 with Composer inside the Devilbox PHP container. The modern Drupal project template places the web entrypoint in `web/`, which is linked to Devilbox's `htdocs` directory.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-drupal` | `/shared/httpd/my-drupal` | `my_drupal` | `lvh.me` | <http://my-drupal.lvh.me> / <https://my-drupal.lvh.me> |

Inside the container, projects are stored in `/shared/httpd/`; on the host, use `./data/www/`.

:::caution
Drupal 11 requires newer PHP versions than old Drupal 8/9 examples. Use the PHP 8.3 or PHP 8.4 containers from `env-example`.
:::

## Prerequisites

- Devilbox with PHP 8.3+ and Composer.
- MySQL, HTTPD, and Bind services.
- Docker Compose v2 via Docker.

Start the stack:

```bash
./dvl.sh up php httpd mysql bind
```

## Walk through

It will be ready in seven steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install Drupal with Composer.
4. Link `web/` to `htdocs`.
5. Add a MySQL database.
6. Verify DNS.
7. Open the Drupal installer.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-drupal
cd /shared/httpd/my-drupal
```

### 3. Install Drupal

For Drupal 10 LTS-style compatibility:

```bash
composer create-project drupal/recommended-project:^10 drupal
```

For a new Drupal 11 project on PHP 8.3+:

```bash
composer create-project drupal/recommended-project:^11 drupal
```

Expected structure:

```bash
tree -L 1
.
└── drupal
```

### 4. Link the webroot

```bash
ln -s drupal/web htdocs
```

Expected structure:

```bash
tree -L 1
.
├── drupal
└── htdocs -> drupal/web
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_drupal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

### 6. Verify DNS

`my-drupal.lvh.me` resolves to `127.0.0.1`. For a custom suffix, add an equivalent hosts-file record.

### 7. Open the Drupal installer

Visit <http://my-drupal.lvh.me> or <https://my-drupal.lvh.me> and follow the installer.

Use these database values:

- Database type: `MySQL, MariaDB, Percona Server, or equivalent`
- Database name: `my_drupal`
- Database username: `root`
- Database password: your `.env` value
- Advanced host: `127.0.0.1`

## Next steps

- Install Drush per project with `composer require drush/drush` when needed.
- Use `./dvl.sh exec "vendor/bin/drush status"` from the Drupal project directory for non-interactive checks.
- Configure HTTPS and Xdebug after the installer completes.
