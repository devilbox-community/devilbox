---
title: "Setup ProcessWire"
---

# Setup ProcessWire

This example installs ProcessWire 3 with Composer inside the Devilbox PHP container and serves it through the `htdocs` virtual host directory.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-pw` | `/shared/httpd/my-pw` | `my_pw` | `lvh.me` | <http://my-pw.lvh.me> / <https://my-pw.lvh.me> |

Projects live in `/shared/httpd/` inside the PHP container and in `./data/www/` on the host.

## Required configuration

| Service | Version | Notes |
| --- | --- | --- |
| Webserver | Apache 2.4 or Nginx | Apache works with ProcessWire's `.htaccess`; Nginx may need a custom vhost template. |
| PHP | PHP 8.3 or compatible | Confirm your selected ProcessWire 3 release supports the PHP container you choose. |
| Database | MySQL or MariaDB | Use the bundled MySQL service for this example. |

Start the stack:

```bash
./dvl.sh up php httpd mysql bind
```

## Walk through

It will be ready in seven steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install ProcessWire.
4. Link the webroot.
5. Add the MySQL database.
6. Verify DNS.
7. Step through the web installer.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-pw
cd /shared/httpd/my-pw
```

### 3. Install ProcessWire

```bash
composer create-project processwire/processwire processwire
```

Expected structure:

```bash
tree -L 1
.
└── processwire
```

### 4. Link the webroot

```bash
ln -s processwire htdocs
```

Expected structure:

```bash
tree -L 1
.
├── processwire
└── htdocs -> processwire
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_pw CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

### 6. Verify DNS

`my-pw.lvh.me` resolves automatically. Add a hosts-file entry only when using another suffix.

### 7. Step through guided web installation

Open <http://my-pw.lvh.me> or <https://my-pw.lvh.me> and follow the ProcessWire installer.

Use these database values:

- DB host: `127.0.0.1`
- DB name: `my_pw`
- DB user: `root`
- DB password: your `.env` value
- DB port: `3306`

The installer will guide you through profile selection, compatibility checks, database setup, admin URL selection, and admin user creation.

## Next steps

- Use Adminer or phpMyAdmin from the Devilbox intranet to inspect `my_pw`.
- Add an Nginx-specific vhost template only if clean URLs fail.
- Configure trusted local HTTPS before browser-based demos.
