---
title: "Setup Laravel"
---

# Setup Laravel

This example installs a current Laravel 11 or 12 application inside the Devilbox PHP container and serves `public/` through the standard Devilbox `htdocs` document root.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-laravel` | `/shared/httpd/my-laravel` | `my_laravel` | `lvh.me` | <http://my-laravel.lvh.me> / <https://my-laravel.lvh.me> |

Inside the container, projects are in `/shared/httpd/`; on the host, they are under `./data/www/`.

## Prerequisites

- Devilbox with PHP 8.3 or PHP 8.4 available from `env-example`.
- Composer available in the PHP container.
- HTTPD, MySQL, and Bind services.

Start the stack:

```bash
./dvl.sh up php httpd mysql bind
```

:::tip
If you created a global `dvl` symlink with `install.sh`, the examples work with `dvl shell` and `dvl exec` as well. The local `./dvl.sh` form is shown for clarity.
:::

## Walk through

It will be ready in eight steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install Laravel.
4. Link `public/` to `htdocs`.
5. Add a MySQL database.
6. Configure `.env`.
7. Verify DNS.
8. Open the project.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-laravel
cd /shared/httpd/my-laravel
```

### 3. Install Laravel

For Laravel 11:

```bash
composer create-project laravel/laravel:^11.0 laravel-project
```

For Laravel 12 on a compatible PHP runtime:

```bash
composer create-project laravel/laravel:^12.0 laravel-project
```

Expected structure:

```bash
tree -L 1
.
└── laravel-project
```

### 4. Link the webroot

```bash
ln -s laravel-project/public htdocs
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_laravel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

### 6. Configure Laravel

Edit `laravel-project/.env`:

```ini
APP_URL=http://my-laravel.lvh.me
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=my_laravel
DB_USERNAME=root
DB_PASSWORD=
```

Then generate the application key if Composer did not already do it:

```bash
cd laravel-project
php artisan key:generate
```

### 7. Verify DNS

`my-laravel.lvh.me` resolves to `127.0.0.1`. Add a hosts-file record only for custom suffixes.

### 8. Open your browser

Visit <http://my-laravel.lvh.me> or <https://my-laravel.lvh.me>.

## Next steps

- Run Artisan commands with `./dvl.sh exec "php artisan"` from the Laravel project directory.
- Use Adminer or phpMyAdmin from the Devilbox intranet to inspect `my_laravel`.
- Add Redis, queues, or mail services only when your app needs them.
