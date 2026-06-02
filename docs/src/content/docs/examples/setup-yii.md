---
title: "Setup Yii"
---

# Setup Yii

This example installs the current Yii 2 basic application with Composer from inside the Devilbox PHP container and serves its `web/` directory through `htdocs`.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-yii` | `/shared/httpd/my-yii` | optional | `lvh.me` | <http://my-yii.lvh.me> / <https://my-yii.lvh.me> |

Projects live in `/shared/httpd/` in the PHP container and in `./data/www/` on the host.

## Prerequisites

- Devilbox installed from the current `env-example`.
- PHP 8.3 or PHP 8.4 available.
- Composer available in the PHP container.
- HTTPD and Bind services.

Start the required services:

```bash
./dvl.sh up php httpd bind
```

## Walk through

It will be ready in six steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install Yii 2.
4. Link the webroot to `htdocs`.
5. Verify DNS.
6. Open the project.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-yii
cd /shared/httpd/my-yii
```

### 3. Install Yii 2

```bash
composer create-project --prefer-dist yiisoft/yii2-app-basic:^2.0 yii2
```

Expected structure:

```bash
tree -L 1
.
└── yii2
```

### 4. Link the webroot

The Devilbox web server serves `<vhost>/htdocs`, while Yii 2 keeps its entrypoint in `web/`.

```bash
ln -s yii2/web htdocs
```

Expected structure:

```bash
tree -L 1
.
├── htdocs -> yii2/web
└── yii2
```

### 5. Verify DNS

With the default `lvh.me` suffix, no hosts-file entry is required. For a custom suffix, add:

```bash
127.0.0.1 my-yii.example
```

### 6. Open your browser

Visit <http://my-yii.lvh.me> or <https://my-yii.lvh.me>.

## Optional database setup

If your Yii application needs MySQL, start MySQL and create a database:

```bash
./dvl.sh up mysql
./dvl.sh exec "mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_yii CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'"
```

Then edit `yii2/config/db.php` and point Yii to `127.0.0.1`, database `my_yii`, and your Devilbox MySQL credentials.

## Next steps

- Run Yii console commands with `./dvl.sh exec "php yii"` from the project directory.
- Add MySQL, cache, or queue services only when the application requires them.
- Configure valid local HTTPS if your browser warns about the certificate.
