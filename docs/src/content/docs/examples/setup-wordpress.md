---
title: "Setup WordPress"
---

# Setup WordPress

This example installs WordPress 6.x from inside the Devilbox PHP container and serves it through the standard Devilbox virtual host layout over HTTP and HTTPS.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-wp` | `/shared/httpd/my-wp` | `my_wp` | `lvh.me` | <http://my-wp.lvh.me> / <https://my-wp.lvh.me> |

Inside the PHP container, projects live in `/shared/httpd/`. On the host, the same files are stored below `./data/www/` in the Devilbox checkout unless you changed the web data directory.

## Prerequisites

- Devilbox installed from the current `env-example`.
- PHP 8.3 or PHP 8.4 available for current WordPress 6.x releases.
- `git` or `curl` available in the PHP container.
- HTTPD, MySQL, and Bind services.

Start the required services:

```bash
./dvl.sh up php httpd mysql bind
```

## Walk through

It will be ready in seven steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Download WordPress 6.x.
4. Link the webroot to `htdocs`.
5. Add a MySQL database.
6. Verify DNS.
7. Finish the browser installer.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-wp
cd /shared/httpd/my-wp
```

### 3. Download WordPress 6.x

Use the official WordPress repository:

```bash
git clone --depth 1 --branch 6.8 https://github.com/WordPress/WordPress wordpress
```

Or omit `--branch` to use the latest maintained 6.x release available from the repository.

Expected structure:

```bash
tree -L 1
.
└── wordpress
```

### 4. Link the webroot

The Devilbox web server serves `<vhost>/htdocs`, while WordPress stores its entrypoint at the project root.

```bash
ln -s wordpress htdocs
```

Expected structure:

```bash
tree -L 1
.
├── htdocs -> wordpress
└── wordpress
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_wp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

### 6. Verify DNS

With the default `lvh.me` suffix, `my-wp.lvh.me` resolves to localhost automatically. For a custom suffix, add a hosts-file entry such as:

```bash
127.0.0.1 my-wp.example
```

### 7. Finish the browser installer

Open <http://my-wp.lvh.me> or <https://my-wp.lvh.me> and follow the WordPress installer.

Use these database values:

- Database name: `my_wp`.
- Username: `root`.
- Password: your MySQL root password from `.env`.
- Database host: `127.0.0.1`.
- Table prefix: any project-specific prefix, for example `wp_`.

## Next steps

- Use Adminer or phpMyAdmin from the Devilbox intranet to inspect `my_wp`.
- Run WP-CLI from the project with `./dvl.sh exec "wp --info"` if WP-CLI is available in the selected PHP image.
- Add mail capture, cache, or search services only when the WordPress project needs them.
