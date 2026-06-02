---
title: "Setup Shopware"
---

# Setup Shopware

This example installs Shopware 6 inside the Devilbox PHP container and serves its public directory through `htdocs`.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-sw` | `/shared/httpd/my-sw` | `my_sw` | `lvh.me` | <http://my-sw.lvh.me> / <https://my-sw.lvh.me> |

Projects live in `/shared/httpd/` inside the PHP container and in `./data/www/` on the host.

## Prerequisites

- Devilbox with a PHP version supported by your Shopware 6 release.
- MySQL, Redis, HTTPD, and Bind services.
- Composer available in the PHP container.

Start the stack:

```bash
./dvl.sh up php httpd mysql redis bind
```

## Walk through

It will be ready in seven steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install Shopware 6.
4. Link `public/` to `htdocs`.
5. Add the MySQL database.
6. Verify DNS.
7. Follow the browser installer.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-sw
cd /shared/httpd/my-sw
```

### 3. Install Shopware 6

Use the official production template:

```bash
composer create-project shopware/production shopware
```

Expected structure:

```bash
tree -L 1
.
└── shopware
```

### 4. Link the webroot

```bash
ln -s shopware/public htdocs
```

Expected structure:

```bash
tree -L 1
.
├── shopware
└── htdocs -> shopware/public
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_sw CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

### 6. Verify DNS

`my-sw.lvh.me` resolves to localhost by default. Add a hosts entry only for custom suffixes.

### 7. Follow install steps in your browser

Open <http://my-sw.lvh.me> or <https://my-sw.lvh.me> and follow the Shopware installer.

Use these database values:

- Database server: `127.0.0.1`
- Database user: `root`
- Database password: your `.env` value
- Database name: `my_sw`

:::caution
Shopware 6 patch releases have specific PHP and extension requirements. Check the Shopware release notes before switching to PHP 8.4.
:::

## Next steps

- Use Adminer or phpMyAdmin from the Devilbox intranet to inspect `my_sw`.
- Configure HTTPS trust for administration testing.
- Add OpenSearch or queue workers only when your Shopware setup requires them.
