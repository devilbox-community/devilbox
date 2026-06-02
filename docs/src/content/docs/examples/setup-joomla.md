---
title: "Setup Joomla"
---

# Setup Joomla

This example installs Joomla 5 inside Devilbox and serves it through the standard `htdocs` document root.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-joomla` | `/shared/httpd/my-joomla` | `my_joomla` | `lvh.me` | <http://my-joomla.lvh.me> / <https://my-joomla.lvh.me> |

Projects live in `/shared/httpd/` inside the container and in `./data/www/` on the host.

## Prerequisites

- Devilbox with PHP 8.3 or PHP 8.4 available.
- HTTPD, MySQL, and Bind services.
- Docker Compose v2 through Docker.

Start the stack:

```bash
./dvl.sh up php httpd mysql bind
```

## Walk through

It will be ready in seven steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Download and extract Joomla 5.
4. Link the document root.
5. Add a MySQL database.
6. Verify DNS.
7. Open the Joomla installer.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-joomla
cd /shared/httpd/my-joomla
```

### 3. Download and extract Joomla 5

Download the current Joomla 5 full package from the official Joomla downloads page, then extract it into `joomla`:

```bash
mkdir joomla
unzip Joomla_5-Stable-Full_Package.zip -d joomla
```

Expected structure:

```bash
tree -L 1
.
├── Joomla_5-Stable-Full_Package.zip
└── joomla
```

### 4. Link the document root

```bash
ln -s joomla htdocs
```

Expected structure:

```bash
tree -L 1
.
├── Joomla_5-Stable-Full_Package.zip
├── joomla
└── htdocs -> joomla
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_joomla CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

### 6. Verify DNS

`my-joomla.lvh.me` resolves automatically to localhost. Add a hosts entry only when using a custom suffix.

### 7. Open the Joomla installer

Visit <http://my-joomla.lvh.me> or <https://my-joomla.lvh.me> and follow the installer.

Use these database values:

- Database type: `MySQLi`
- Host: `127.0.0.1`
- User: `root`
- Database name: `my_joomla`
- Password: your `.env` value

## Next steps

- Remove the installation directory if Joomla prompts for manual cleanup.
- Configure valid local HTTPS.
- Use Adminer or phpMyAdmin from the Devilbox intranet for database checks.
