---
title: "Setup reverse proxy Sphinx docs"
---

# Setup reverse proxy Sphinx docs

This example creates a Sphinx 8 documentation site, serves it with `sphinx-autobuild` on port `4000`, and proxies a Devilbox virtual host to that local documentation server.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-sphinx` | `/shared/httpd/my-sphinx` | none | `lvh.me` | <http://my-sphinx.lvh.me> / <https://my-sphinx.lvh.me> |

The Sphinx server listens on port `4000` inside the PHP container. Devilbox proxies the virtual host to `php:4000`.

:::tip
For larger documentation projects, a dedicated Python container can isolate Python dependencies. This example keeps the original PHP-container reverse proxy flow and updates it for Sphinx 8.x.
:::

## Prerequisites

- Devilbox with PHP, HTTPD, and Bind services.
- Python 3.12 and `pip` available in the selected PHP image, or a startup script that installs them into that image.
- Docker Compose v2 through Docker.

Start the stack:

```bash
./dvl.sh up php httpd bind
```

## Walk through

It will be ready in nine steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Create a basic Sphinx project.
4. Create a placeholder `htdocs` directory.
5. Add reverse-proxy vhost-gen config files.
6. Create an autostart script.
7. Verify DNS.
8. Restart Devilbox.
9. Open the documentation in a browser.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

Confirm Python:

```bash
python3 --version
pip --version
```

Use Python 3.12 where available.

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-sphinx
cd /shared/httpd/my-sphinx
```

### 3. Create a basic Sphinx project

```bash
mkdir doc
cd doc
```

Create `conf.py`:

```python
project = 'My Docs'
extensions = []
source_suffix = '.rst'
master_doc = 'index'
html_theme = 'alabaster'
exclude_patterns = ['_build/*']
```

Create `index.rst`:

```rst
*******
My Docs
*******

Description

.. toctree::
   :maxdepth: 2

   page1
```

Create `page1.rst`:

```rst
******
Page 1
******

Hello world
```

### 4. Create a placeholder docroot

Reverse-proxy projects still need an `htdocs` directory for the Devilbox intranet virtual host checks:

```bash
cd /shared/httpd/my-sphinx
mkdir htdocs
```

### 5. Add reverse-proxy vhost-gen config files

Leave the shell and copy templates on the host:

```bash
exit
cd /path/to/devilbox
mkdir -p data/www/my-sphinx/.devilbox
cp cfg/vhost-gen/apache22.yml-example-rproxy data/www/my-sphinx/.devilbox/apache22.yml
cp cfg/vhost-gen/apache24.yml-example-rproxy data/www/my-sphinx/.devilbox/apache24.yml
cp cfg/vhost-gen/nginx.yml-example-rproxy data/www/my-sphinx/.devilbox/nginx.yml
```

Edit each copied template and change the upstream port from `8000` to `4000`.

Apache templates should contain:

```apache
ProxyPass / http://php:4000/
ProxyPassReverse / http://php:4000/
```

The Nginx template should contain:

```nginx
location / {
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_pass http://php:4000;
}
```

### 6. Create an autostart script

Create a startup script for the PHP 8.3 container. If you use another PHP container, place it in that matching startup directory.

```bash
cd /path/to/devilbox
mkdir -p cfg/php-startup-8.3
vi cfg/php-startup-8.3/my-sphinx.sh
```

```bash
#!/usr/bin/env bash
set -e

python3 -m pip install --user 'sphinx>=8,<9' 'sphinx-autobuild>=2024.10'
su - devilbox -c 'cd /shared/httpd/my-sphinx/doc && python3 -m sphinx_autobuild . _build/html -p 4000 -H 0.0.0.0' &
```

Make it executable:

```bash
chmod +x cfg/php-startup-8.3/my-sphinx.sh
```

### 7. Verify DNS

`my-sphinx.lvh.me` resolves to localhost by default. Add a hosts entry only when using a custom suffix.

### 8. Restart Devilbox

```bash
./dvl.sh restart
```

Or recycle the needed services:

```bash
./dvl.sh down
./dvl.sh up php httpd bind
```

### 9. Open your browser

Visit <http://my-sphinx.lvh.me> or <https://my-sphinx.lvh.me>. The web server proxies requests to `sphinx-autobuild` on port `4000`.

## Next steps

- Pin Sphinx extensions in a project-level requirements file.
- Move Python dependencies to a dedicated container if they conflict with PHP image tooling.
- Configure trusted HTTPS before sharing local documentation previews.
