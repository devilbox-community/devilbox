---
title: "Setup PrestaShop"
---

# Setup PrestaShop

This example installs PrestaShop 8 inside the Devilbox PHP container, creates a MySQL database, and serves the project through the standard `htdocs` document root.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-presta` | `/shared/httpd/my-presta` | `my_presta` | `lvh.me` | <http://my-presta.lvh.me> / <https://my-presta.lvh.me> |

Projects live in `/shared/httpd/` in the PHP container and `./data/www/` on the host.

## Prerequisites

- Devilbox with a PHP version supported by your PrestaShop 8 patch release.
- HTTPD, MySQL, and Bind services.
- Composer and Git available in the PHP container.

Start the stack:

```bash
./dvl.sh up php httpd mysql bind
```

:::caution
PrestaShop's PHP support matrix is patch-level specific. Use PHP 8.3 only with a PrestaShop release that explicitly supports it; otherwise choose the matching versioned PHP container from `env-example`.
:::

## Walk through

It will be ready in seven steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install PrestaShop 8.
4. Link the document root.
5. Add the MySQL database.
6. Verify DNS.
7. Open the installer.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-presta
cd /shared/httpd/my-presta
```

### 3. Install PrestaShop 8

Download a current PrestaShop 8 release archive or clone the repository and check out a stable 8.x tag:

```bash
git clone https://github.com/PrestaShop/PrestaShop
cd PrestaShop
git checkout 8.2.0
composer install
```

Expected structure from the vhost directory:

```bash
tree -L 1
.
└── PrestaShop
```

### 4. Link the document root

```bash
cd /shared/httpd/my-presta
ln -s PrestaShop htdocs
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_presta CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

### 6. Verify DNS

`my-presta.lvh.me` resolves to localhost by default. Add a hosts entry only for custom suffixes.

### 7. Open the installer

Visit <http://my-presta.lvh.me> or <https://my-presta.lvh.me> and follow the installation steps.

Use these database values:

- Database server: `127.0.0.1`
- Database user: `root`
- Database password: your `.env` value
- Database name: `my_presta`

## Next steps

- Remove the installer directory if PrestaShop requires manual cleanup.
- Use Adminer or phpMyAdmin from the Devilbox intranet for database checks.
- Configure HTTPS trust and mail settings for local testing.
