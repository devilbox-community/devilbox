---
title: "Setup CakePHP"
---

# Setup CakePHP

This example installs a modern CakePHP 5 application with Composer from inside the Devilbox PHP container. The project is served through the standard Devilbox virtual host layout over HTTP and HTTPS.

After completing the steps below, `my-cake.lvh.me` will serve the CakePHP application from `data/www/my-cake/htdocs`.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-cake` | `/shared/httpd/my-cake` | `my_cake` | `lvh.me` | <http://my-cake.lvh.me> / <https://my-cake.lvh.me> |

Inside the PHP container, web projects live in `/shared/httpd/`. On the host, the same files are stored below `./data/www/` in the Devilbox checkout unless you changed `HTTPD_DOCROOT_DIR` or the web data directory.

:::tip
Use `./dvl.sh shell` for an interactive container session, or `./dvl.sh exec "command"` for a single command from the host.
:::

## Prerequisites

- Devilbox installed and configured from `env-example`.
- Docker Compose v2 available through Docker.
- The default PHP stack available. `env-example` includes current PHP 8 containers; the 8.3 container is a safe default for CakePHP version 5.
- `mysql` running for the database.

Start the required services from the Devilbox directory:

```bash
./dvl.sh up php httpd mysql bind
```

## Walk through

It will be ready in eight steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install CakePHP 5 with Composer.
4. Link the CakePHP webroot to `htdocs`.
5. Add a MySQL database.
6. Configure the database connection.
7. Verify DNS.
8. Open the project in a browser.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-cake
cd /shared/httpd/my-cake
```

The directory name becomes the virtual host name: `my-cake.lvh.me` when `TLD_SUFFIX=lvh.me`.

### 3. Install CakePHP 5

```bash
composer create-project --prefer-dist cakephp/app:^5.0 cakephp
```

Expected structure:

```bash
tree -L 1
.
└── cakephp
```

### 4. Link the webroot

The web server serves `<vhost>/htdocs`, while CakePHP keeps its entrypoint in `webroot/`.

```bash
ln -s cakephp/webroot htdocs
```

Expected structure:

```bash
tree -L 1
.
├── cakephp
└── htdocs -> cakephp/webroot
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_cake CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

### 6. Configure the database connection

Edit `cakephp/config/app_local.php` and set the default datasource:

```php
<?php
return [
    'Datasources' => [
        'default' => [
            'host' => '127.0.0.1',
            'username' => 'root',
            'password' => 'secret',
            'database' => 'my_cake',
            'encoding' => 'utf8mb4',
            'timezone' => 'UTC',
        ],
    ],
];
```

Use your actual MySQL root password from `.env` if it differs.

### 7. Verify DNS

With the default `lvh.me` suffix, no hosts-file entry is required because `*.lvh.me` resolves to `127.0.0.1`. If you use a custom suffix, add an `/etc/hosts` entry such as:

```bash
127.0.0.1 my-cake.example
```

### 8. Open your browser

Visit <http://my-cake.lvh.me> or <https://my-cake.lvh.me>.

## Next steps

- Use Adminer or phpMyAdmin from the Devilbox intranet to inspect `my_cake`.
- Enable valid local HTTPS if your browser warns about the certificate.
- Add cache, queue, or search services only when the application needs them.
