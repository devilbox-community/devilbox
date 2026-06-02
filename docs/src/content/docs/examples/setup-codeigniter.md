---
title: "Setup CodeIgniter"
---

# Setup CodeIgniter

This example installs a legacy CodeIgniter 3 application inside Devilbox. For new projects, prefer [Setup CodeIgniter4](../setup-codeigniter4/) because CodeIgniter 4 is the actively maintained line.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-ci` | `/shared/httpd/my-ci` | `my_ci` | `lvh.me` | <http://my-ci.lvh.me> / <https://my-ci.lvh.me> |

Inside the PHP container, projects are available in `/shared/httpd/`; on the host they are stored below `./data/www/`.

:::caution
CodeIgniter 3 is kept here for existing applications. Use PHP 8.3 only after confirming your application and extensions are compatible.
:::

## Prerequisites

- Devilbox installed with PHP, HTTPD, MySQL, and Bind available.
- Docker Compose v2 and the `./dvl.sh` CLI.
- `TLD_SUFFIX=lvh.me` or an equivalent local DNS setup.

Start the required services:

```bash
./dvl.sh up php httpd mysql bind
```

## Walk through

It will be ready in eight steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Download CodeIgniter 3.
4. Link the document root.
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

### 3. Download CodeIgniter

```bash
wget https://github.com/bcit-ci/CodeIgniter/archive/3.1.13.tar.gz
tar xfz 3.1.13.tar.gz
```

Expected structure:

```bash
tree -L 1
.
├── 3.1.13.tar.gz
└── CodeIgniter-3.1.13
```

### 4. Link the document root

CodeIgniter 3 keeps `index.php` in the project root, so link the extracted directory to `htdocs`:

```bash
ln -s CodeIgniter-3.1.13 htdocs
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_ci CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

### 6. Configure the database connection

Edit `htdocs/application/config/database.php`:

```php
$db['default'] = array(
    'hostname' => '127.0.0.1',
    'username' => 'root',
    'password' => '',
    'database' => 'my_ci',
    'dbdriver' => 'mysqli',
    'char_set' => 'utf8mb4',
    'dbcollat' => 'utf8mb4_unicode_ci',
);
```

Use your configured MySQL password when one is set in `.env`.

### 7. Verify DNS

`my-ci.lvh.me` resolves to `127.0.0.1` by default. For a custom suffix, add a hosts entry:

```bash
127.0.0.1 my-ci.example
```

### 8. Open your browser

Visit <http://my-ci.lvh.me> or <https://my-ci.lvh.me>.

## Next steps

- Move new projects to CodeIgniter 4 where possible.
- Use Devilbox intranet database tools for inspection.
- Configure HTTPS and Xdebug after the application loads.
