---
title: "Setup Magento 2"
---

# Setup Magento 2

This example installs Magento Open Source 2.4.7 or newer inside Devilbox. It uses Composer in the PHP container, creates a MySQL database, and serves Magento through Devilbox's virtual host layout.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-magento` | `/shared/httpd/my-magento` | `my_magento` | `lvh.me` | <http://my-magento.lvh.me> / <https://my-magento.lvh.me> |

Projects live in `/shared/httpd/` in the container and `./data/www/` on the host.

## Requirements

- Devilbox with PHP 8.3 available; PHP 8.4 compatibility depends on the Magento patch level.
- The PHP image flavor must include Composer and build tools.
- MySQL and a search service supported by your Magento version.
- Adobe Commerce Marketplace credentials if Composer asks for `repo.magento.com` authentication.

:::caution
Magento 2.4.7+ has stricter PHP and OpenSearch/Elasticsearch requirements than old 2.2 examples. Confirm the exact Magento patch release support matrix before choosing PHP 8.4.
:::

Start the required stack:

```bash
./dvl.sh up php httpd mysql redis opensearch bind
```

## Walk through

It will be ready in eight steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install Magento with Composer.
4. Link the Magento document root.
5. Add the MySQL database.
6. Run the Magento installer.
7. Verify DNS.
8. Open the storefront.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-magento
cd /shared/httpd/my-magento
```

### 3. Install Magento 2.4.7+

Use Composer's project template for the desired patch version:

```bash
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.7-p4 magento2
```

Expected structure:

```bash
tree -L 1
.
└── magento2
```

### 4. Link the webroot

Magento 2.4 uses `pub/` as the public document root:

```bash
ln -s magento2/pub htdocs
```

Expected structure:

```bash
tree -L 1
.
├── magento2
└── htdocs -> magento2/pub
```

### 5. Add the MySQL database

```bash
mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_magento CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
```

### 6. Run the Magento installer

From `/shared/httpd/my-magento/magento2`, run:

```bash
php -dmemory_limit=-1 bin/magento setup:install \
  --base-url=http://my-magento.lvh.me/ \
  --db-host=127.0.0.1 \
  --db-name=my_magento \
  --db-user=root \
  --db-password='' \
  --admin-firstname=Admin \
  --admin-lastname=User \
  --admin-email=admin@example.com \
  --admin-user=admin \
  --admin-password='Admin123!Admin123!' \
  --language=en_US \
  --currency=USD \
  --timezone=UTC \
  --use-rewrites=1 \
  --search-engine=opensearch \
  --opensearch-host=opensearch \
  --opensearch-port=9200
```

Use your actual MySQL password if configured.

:::tip
The DVL CLI also provides Magento-aware wrappers. From the project directory, `./dvl.sh exec "php -dmemory_limit=-1 bin/magento cache:flush"` keeps execution inside the correct PHP container.
:::

### 7. Verify DNS

`my-magento.lvh.me` resolves to localhost by default. Add a hosts entry only when using a custom suffix.

### 8. Open your browser

Visit <http://my-magento.lvh.me> or <https://my-magento.lvh.me> and use the generated admin URL shown by `setup:install` for the back office.

## Next steps

- Run `bin/magento deploy:mode:set developer` for local development.
- Use Redis and OpenSearch containers when testing production-like behavior.
- Configure trusted HTTPS and Xdebug after the storefront loads.
