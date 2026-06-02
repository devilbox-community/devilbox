---
title: "Setup TYPO3"
---

# Setup TYPO3

This example installs TYPO3 13 LTS, or TYPO3 12 LTS when your project still targets that release, with Composer from inside the Devilbox PHP container. The generated `public/` directory is served through the standard Devilbox `htdocs` document root.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-typo` | `/shared/httpd/my-typo` | `my_typo` | `lvh.me` | <http://my-typo.lvh.me> / <https://my-typo.lvh.me> |

Projects live in `/shared/httpd/` inside the PHP container and in `./data/www/` on the host unless you changed the HTTPD data directory.

## Prerequisites

- Devilbox installed from the current `env-example`.
- PHP 8.3 or PHP 8.4 available; use the newer runtime for TYPO3 13 LTS.
- Composer available in the PHP container.
- HTTPD, MySQL, and Bind services.

Start the required services:

```bash
./dvl.sh up php httpd mysql bind
```

:::tip
Use `./dvl.sh shell` for an interactive PHP container, or `./dvl.sh exec "command"` for a single command from the host.
:::

## Walk through

It will be ready in eight steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install TYPO3.
4. Link the webroot to `htdocs`.
5. Add a MySQL database.
6. Create `FIRST_INSTALL`.
7. Verify DNS.
8. Finish the web installer.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-typo
cd /shared/httpd/my-typo
```

The directory name becomes the virtual host name: `my-typo.lvh.me` when `TLD_SUFFIX=lvh.me`.

### 3. Install TYPO3

For TYPO3 13 LTS:

```bash
composer create-project typo3/cms-base-distribution:^13 typo3
```

For TYPO3 12 LTS:

```bash
composer create-project typo3/cms-base-distribution:^12 typo3
```

Expected structure:

```bash
tree -L 1
.
└── typo3
```

### 4. Link the webroot

The Devilbox web server serves `<vhost>/htdocs`, while TYPO3 keeps the public entrypoint in `public/`.

```bash
ln -s typo3/public htdocs
```

Expected structure:

```bash
tree -L 1
.
├── htdocs -> typo3/public
└── typo3
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_typo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

### 6. Create `FIRST_INSTALL`

TYPO3 starts the guided installer when this marker exists in the document root:

```bash
touch htdocs/FIRST_INSTALL
```

### 7. Verify DNS

With the default `lvh.me` suffix, no hosts-file entry is required because `*.lvh.me` resolves to `127.0.0.1`. For a custom suffix, add:

```bash
127.0.0.1 my-typo.example
```

### 8. Finish the web installer

Open <http://my-typo.lvh.me> or <https://my-typo.lvh.me> and use these Devilbox connection values:

- Driver: MySQL TCP/IP.
- Host: `127.0.0.1` from the PHP container.
- Port: `3306`.
- Username: `root`.
- Database: `my_typo`.

Create the administrator account, set the site name, and choose an initial page.

## Next steps

- Use Adminer or phpMyAdmin from the Devilbox intranet to inspect `my_typo`.
- Run TYPO3 CLI commands from the project with `./dvl.sh exec "vendor/bin/typo3"`.
- Add Solr, cache, or mail tooling only when the project requires it.
