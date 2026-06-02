---
title: "Setup CraftCMS"
---

# Setup CraftCMS

This example installs a current Craft CMS project with Composer inside the Devilbox PHP container and serves it through the `htdocs` virtual host document root.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-craft` | `/shared/httpd/my-craft` | `my_craft` | `lvh.me` | <http://my-craft.lvh.me> / <https://my-craft.lvh.me> |

Projects live in `/shared/httpd/` in the PHP container and in `./data/www/` on the host.

## Prerequisites

- Devilbox installed with the PHP 8.3 or PHP 8.4 container enabled.
- MySQL, HTTPD, and Bind available.
- Composer available in the PHP container.

Start the required services:

```bash
./dvl.sh up php httpd mysql bind
```

:::tip
For a single command from the host, run `./dvl.sh exec "php -v"`. For interactive setup wizards, use `./dvl.sh shell`.
:::

## Walk through

It will be ready in eight steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install Craft CMS.
4. Link `web/` to `htdocs`.
5. Add the MySQL database.
6. Verify DNS.
7. Run the setup wizard.
8. Open the site.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-craft
cd /shared/httpd/my-craft
```

### 3. Install Craft CMS

```bash
composer create-project craftcms/craft craftcms
```

Expected structure:

```bash
tree -L 1
.
└── craftcms
```

### 4. Link the webroot

```bash
ln -s craftcms/web htdocs
```

Expected structure:

```bash
tree -L 1
.
├── craftcms
└── htdocs -> craftcms/web
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_craft CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

### 6. Verify DNS

With the default `lvh.me` suffix, `my-craft.lvh.me` resolves automatically. Add a hosts entry only if you use a custom suffix.

### 7. Run the setup wizard

Use the Craft CLI wizard:

```bash
php craftcms/craft setup
```

Suggested answers:

- Database driver: `mysql`
- Database server: `127.0.0.1`
- Database port: `3306`
- Database username: `root`
- Database password: your MySQL password from `.env`
- Database name: `my_craft`
- Site URL: `http://my-craft.lvh.me`

You can also open <http://my-craft.lvh.me/admin/install> or <https://my-craft.lvh.me/admin/install> and complete the browser wizard with the same values.

### 8. Open your browser

Visit <http://my-craft.lvh.me> or <https://my-craft.lvh.me>.

## Next steps

- Use the Devilbox intranet database tools to inspect `my_craft`.
- Configure local HTTPS trust for the admin panel.
- Add Redis or queue services only when the Craft project requires them.
