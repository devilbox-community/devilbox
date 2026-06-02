---
title: "Setup ExpressionEngine"
---

# Setup ExpressionEngine

This example installs ExpressionEngine inside the Devilbox PHP container, creates a MySQL database, and serves the CMS through the standard Devilbox `htdocs` document root.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-ee` | `/shared/httpd/my-ee` | `my_ee` | `lvh.me` | <http://my-ee.lvh.me> / <https://my-ee.lvh.me> |

Projects live in `/shared/httpd/` inside the PHP container and in `./data/www/` on the host.

## Prerequisites

- Devilbox installed with PHP 8.3 or PHP 8.4 available.
- HTTPD, MySQL, and Bind services enabled.
- An ExpressionEngine download URL or release archive from your ExpressionEngine account.

Start the stack:

```bash
./dvl.sh up php httpd mysql bind
```

## Walk through

It will be ready in eight steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Download and extract ExpressionEngine.
4. Link the webroot to `htdocs`.
5. Add a MySQL database.
6. Verify DNS.
7. Run the installer.
8. View the site and control panel.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-ee
cd /shared/httpd/my-ee
```

### 3. Download and extract ExpressionEngine

Download the current ExpressionEngine release archive from the official source, then place it in the vhost directory as `ee.zip`:

```bash
mkdir ee
unzip ee.zip -d ee
```

Expected structure:

```bash
tree -L 1
.
├── ee
└── ee.zip
```

### 4. Link the webroot

ExpressionEngine can be served from the extracted directory unless you move its public entrypoint elsewhere:

```bash
ln -s ee htdocs
```

Expected structure:

```bash
tree -L 1
.
├── ee
├── ee.zip
└── htdocs -> ee
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_ee CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

Remember the database name and credentials for the browser installer.

### 6. Verify DNS

`my-ee.lvh.me` resolves to `127.0.0.1` by default. For a custom suffix, add an equivalent hosts-file entry.

### 7. Install ExpressionEngine

Open <http://my-ee.lvh.me/admin.php> or <https://my-ee.lvh.me/admin.php> and follow the installer.

Use these database values:

- Host: `127.0.0.1`
- Database: `my_ee`
- User: `root`
- Password: your MySQL password from `.env`

:::caution
After the installer finishes, remove or rename the installer directory if ExpressionEngine does not do it automatically.
:::

### 8. View your site

Open <http://my-ee.lvh.me> or <https://my-ee.lvh.me>. The control panel remains available at `/admin.php`.

## Next steps

- Use the Devilbox intranet database tools to inspect `my_ee`.
- Configure trusted HTTPS before production-like testing.
- Add cache or queue services only when your ExpressionEngine project requires them.
