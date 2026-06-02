---
title: "Setup Phalcon"
---

# Setup Phalcon

This example creates a Phalcon 5 application inside Devilbox and links its `public/` directory to the virtual host document root.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-phalcon` | `/shared/httpd/my-phalcon` | optional | `lvh.me` | <http://my-phalcon.lvh.me> / <https://my-phalcon.lvh.me> |

Projects live in `/shared/httpd/` inside the PHP container and in `./data/www/` on the host.

## Prerequisites

- Devilbox with PHP 8.3 or PHP 8.4 available.
- A PHP container image or project setup that includes the Phalcon extension and Phalcon Developer Tools for Phalcon 5.
- HTTPD and Bind services.

Start the stack:

```bash
./dvl.sh up php httpd bind
```

:::caution
Phalcon requires a PHP extension, not only Composer packages. Confirm `php -m | grep phalcon` inside the selected PHP container before generating the project.
:::

## Walk through

It will be ready in seven steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Check Phalcon tooling.
4. Create the Phalcon project.
5. Link `public/` to `htdocs`.
6. Verify DNS.
7. Open the project.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-phalcon
cd /shared/httpd/my-phalcon
```

### 3. Check Phalcon tooling

```bash
php -m | grep -i phalcon
phalcon --version
```

Install or enable the extension and developer tools if those checks fail.

### 4. Create the Phalcon project

```bash
phalcon project phalconphp
```

Expected structure:

```bash
tree -L 1
.
└── phalconphp
```

### 5. Link the webroot

```bash
ln -s phalconphp/public htdocs
```

### 6. Verify DNS

`my-phalcon.lvh.me` resolves to localhost with the default suffix. For another suffix, add a hosts-file entry.

### 7. Open your browser

Visit <http://my-phalcon.lvh.me> or <https://my-phalcon.lvh.me>.

## Nginx routing note

If routes fail under Nginx, create `data/www/my-phalcon/.devilbox/nginx.yml` from `cfg/vhost-gen/nginx.yml-example-vhost` and adapt the `try_files` rule for Phalcon:

```nginx
try_files $uri $uri/ /index.php?_url=$uri&$args;
```

Validate the YAML before restarting:

```bash
yamllint data/www/my-phalcon/.devilbox/nginx.yml
```

Restart with:

```bash
./dvl.sh restart
```

## Next steps

- Add MySQL or Redis only if the generated application needs them.
- Configure HTTPS trust for browser testing.
- Use `./dvl.sh exec "php -m"` for quick extension checks.
