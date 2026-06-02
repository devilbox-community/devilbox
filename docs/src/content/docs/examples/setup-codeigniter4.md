---
title: "Setup CodeIgniter4"
---

# Setup CodeIgniter4

This example installs a current CodeIgniter 4 application with Composer from inside the Devilbox PHP container and serves it through the standard `htdocs` virtual host layout.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-ci` | `/shared/httpd/my-ci` | `my_ci` | `lvh.me` | <http://my-ci.lvh.me> / <https://my-ci.lvh.me> |

Inside the container, projects live in `/shared/httpd/`. On the host, the files are in `./data/www/` below the Devilbox checkout.

## Prerequisites

- Devilbox with PHP 8.3 or PHP 8.4 available from `env-example`.
- MySQL and HTTPD containers enabled.
- Docker Compose v2 and `./dvl.sh`.

Start the stack:

```bash
./dvl.sh up php httpd mysql bind
```

## Walk through

It will be ready in eight steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install CodeIgniter 4.
4. Link `public/` to `htdocs`.
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
mkdir -p /shared/httpd/my-ci
cd /shared/httpd/my-ci
```

### 3. Install CodeIgniter 4

```bash
composer create-project codeigniter4/appstarter ci4app
```

Expected structure:

```bash
tree -L 1
.
└── ci4app
```

### 4. Link the webroot

```bash
ln -s ci4app/public htdocs
```

Expected structure:

```bash
tree -L 1
.
├── ci4app
└── htdocs -> ci4app/public
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_ci CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

### 6. Configure the database connection

Copy the environment template and edit it:

```bash
cd ci4app
cp env .env
vi .env
```

Set the database values:

```ini
database.default.hostname = 127.0.0.1
database.default.database = my_ci
database.default.username = root
database.default.password =
database.default.DBDriver = MySQLi
database.default.port = 3306
```

### 7. Verify DNS

With `TLD_SUFFIX=lvh.me`, `my-ci.lvh.me` resolves automatically. For another suffix, add a hosts entry for your chosen name.

### 8. Open your browser

Visit <http://my-ci.lvh.me> or <https://my-ci.lvh.me>.

## Next steps

- Use `./dvl.sh exec "php spark"` from the project directory for non-interactive Spark commands.
- Use the Devilbox intranet database tools to inspect `my_ci`.
- Add HTTPS trust and Xdebug once the application responds.
