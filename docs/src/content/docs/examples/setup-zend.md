---
title: "Setup Zend"
---

# Setup Zend

Zend Framework is now Laminas. This example keeps the established page URL and title, but uses the maintained Laminas MVC skeleton 3.x package and serves its `public/` directory through the Devilbox `htdocs` document root.

:::caution[Zend became Laminas]
Do not start new projects with the abandoned `zendframework/*` packages. Use `laminas/laminas-mvc-skeleton` for new applications and migrate legacy Zend Framework code before upgrading PHP.
:::

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-zend` | `/shared/httpd/my-zend` | optional | `lvh.me` | <http://my-zend.lvh.me> / <https://my-zend.lvh.me> |

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
3. Install Laminas MVC skeleton 3.x.
4. Link the webroot to `htdocs`.
5. Verify DNS.
6. Open the project.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-zend
cd /shared/httpd/my-zend
```

### 3. Install Laminas 3.x

```bash
composer create-project --prefer-dist laminas/laminas-mvc-skeleton:^3.0 laminas
```

Expected structure:

```bash
tree -L 1
.
└── laminas
```

### 4. Link the webroot

The Devilbox web server serves `<vhost>/htdocs`, while Laminas keeps its entrypoint in `public/`.

```bash
ln -s laminas/public htdocs
```

Expected structure:

```bash
tree -L 1
.
├── htdocs -> laminas/public
└── laminas
```

### 5. Verify DNS

With the default `lvh.me` suffix, no hosts-file entry is required. For a custom suffix, add:

```bash
127.0.0.1 my-zend.example
```

### 6. Open your browser

Visit <http://my-zend.lvh.me> or <https://my-zend.lvh.me>.

## Optional database setup

If your Laminas app needs MySQL, start MySQL and create a database:

```bash
./dvl.sh up mysql
./dvl.sh exec "mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_zend CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'"
```

Configure the application with host `127.0.0.1`, database `my_zend`, and your Devilbox MySQL credentials.

## Next steps

- Run Laminas or Composer commands with `./dvl.sh exec "composer"` from the project directory.
- Plan migrations for legacy Zend Framework projects before switching to modern PHP runtimes.
- Add database, cache, or search services only when the application requires them.
