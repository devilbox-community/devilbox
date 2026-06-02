---
title: "Setup Symfony"
---

# Setup Symfony

This example installs Symfony 7 inside the Devilbox PHP container and serves `public/` through the standard Devilbox `htdocs` document root.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-symfony` | `/shared/httpd/my-symfony` | optional | `lvh.me` | <http://my-symfony.lvh.me> / <https://my-symfony.lvh.me> |

Projects live in `/shared/httpd/` in the PHP container and in `./data/www/` on the host.

## Prerequisites

- Devilbox with PHP 8.3 or PHP 8.4 available from `env-example`.
- Composer available in the PHP container.
- HTTPD and Bind services.

Start the stack:

```bash
./dvl.sh up php httpd bind
```

:::caution
Symfony 7 requires modern PHP. Do not use old PHP 7 containers for this example.
:::

## Walk through

It will be ready in six steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install Symfony 7.
4. Link `public/` to `htdocs`.
5. Verify DNS.
6. Open the project.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-symfony
cd /shared/httpd/my-symfony
```

### 3. Install Symfony 7

Use Composer for a web application skeleton:

```bash
composer create-project symfony/skeleton:^7.0 symfony
cd symfony
composer require webapp
```

Expected structure from `/shared/httpd/my-symfony`:

```bash
tree -L 1
.
└── symfony
```

### 4. Link the webroot

```bash
cd /shared/httpd/my-symfony
ln -s symfony/public htdocs
```

Expected structure:

```bash
tree -L 1
.
├── symfony
└── htdocs -> symfony/public
```

### 5. Verify DNS

`my-symfony.lvh.me` resolves to localhost by default. Add a hosts entry only when using a custom suffix.

### 6. Open your browser

Visit <http://my-symfony.lvh.me> or <https://my-symfony.lvh.me>.

## Optional database setup

If your Symfony app needs MySQL, start MySQL and create a database:

```bash
./dvl.sh up mysql
./dvl.sh exec "mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_symfony CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'"
```

Then set `DATABASE_URL` in `symfony/.env.local`:

```ini
DATABASE_URL="mysql://root:password@127.0.0.1:3306/my_symfony?serverVersion=8.0&charset=utf8mb4"
```

## Next steps

- Run Symfony console commands with `./dvl.sh exec "php bin/console"` from the project directory.
- Add MySQL, Redis, or Messenger transports only when the application requires them.
- Configure local HTTPS trust for browser testing.
