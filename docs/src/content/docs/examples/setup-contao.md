---
title: "Setup Contao"
---

# Setup Contao

This example installs Contao 5 with Composer inside the Devilbox PHP container. It preserves the classic Devilbox virtual host layout while updating the runtime to PHP 8.3 or newer.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-contao` | `/shared/httpd/my-contao` | `my_contao` | `lvh.me` | <http://my-contao.lvh.me> / <https://my-contao.lvh.me> |

Inside the PHP container, projects are always under `/shared/httpd/`. On the host they are stored below `./data/www/` in the Devilbox checkout.

## Required configuration

| Service | Version | Notes |
| --- | --- | --- |
| Webserver | Apache 2.4 or Nginx | Apache works with Contao's default routing rules; Nginx may need a custom vhost template. |
| PHP | PHP 8.3+ | `env-example` includes PHP 8.3 and PHP 8.4 containers. |
| Database | MySQL or MariaDB | Use the bundled MySQL service for this example. |

:::caution
Contao 5 raises the PHP requirement compared with Contao 4. Use the PHP 8.3 or PHP 8.4 container, not older versioned containers.
:::

Start Devilbox:

```bash
./dvl.sh up php httpd mysql bind
```

## Walk through

It will be ready in seven steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install Contao 5 with Composer.
4. Link `public/` to `htdocs`.
5. Add the MySQL database.
6. Verify DNS.
7. Open the Contao installer.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-contao
cd /shared/httpd/my-contao
```

### 3. Install Contao 5

```bash
composer create-project contao/managed-edition:^5.0 contao
```

Expected structure:

```bash
tree -L 1
.
└── contao
```

### 4. Link the webroot

Contao 5 serves from `public/`:

```bash
ln -s contao/public htdocs
```

Expected structure:

```bash
tree -L 1
.
├── contao
└── htdocs -> contao/public
```

### 5. Add the MySQL database

```bash
mysql -u root -h mysql -p -e 'CREATE DATABASE my_contao CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

Use the MySQL root password from `.env` if one is configured.

### 6. Verify DNS

`my-contao.lvh.me` resolves to `127.0.0.1` by default. For a custom suffix, add an equivalent hosts entry.

### 7. Open the installer

Visit <http://my-contao.lvh.me/contao/install> or <https://my-contao.lvh.me/contao/install> and follow the web installer.

Use these database values:

- Database host: `mysql`
- Database port: `3306`
- Database user: `root`
- Database name: `my_contao`

## Installation flow

The Contao installer guides you through accepting the license, setting the install-tool password, connecting the database, updating schema tables, and creating an admin user. After that, use `/contao` to log in to the back end.

## Next steps

- Use Adminer or phpMyAdmin from the Devilbox intranet for database checks.
- Add a custom Nginx vhost only if you use Nginx and routing does not work.
- Configure trusted local HTTPS before sharing browser screenshots or demos.
