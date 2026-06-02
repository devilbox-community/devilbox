---
title: "Setup reverse proxy Python Flask"
---

# Setup reverse proxy Python Flask

This example adds a Python 3.12 Flask service with a Devilbox Docker Compose override, then proxies the project virtual host to the Flask container.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-flask` | `/shared/httpd/my-flask` | none | `lvh.me` | <http://my-flask.lvh.me> / <https://my-flask.lvh.me> |

The Flask application listens on port `3000`. The reverse-proxy templates forward traffic to the Flask backend defined by the compose override.

## Required configuration

| Service | Notes |
| --- | --- |
| Webserver | Reverse-proxy vhost-gen templates must be copied into the project. |
| Python Flask | The Flask compose override must be active. |
| `.env` | `FLASK_PROJECT=my-flask` and `PYTHON_VERSION=3.12` must be set. |

Start from a stopped stack when adding the override:

```bash
./dvl.sh down
```

## Walk through

It will be ready in ten steps:

1. Configure Flask project name and Python version.
2. Enter the PHP container.
3. Create a new virtual host directory.
4. Create the Flask application.
5. Link a placeholder docroot.
6. Add reverse-proxy vhost-gen config files.
7. Enable the Flask compose override.
8. Verify DNS.
9. Start Devilbox.
10. Open the project in a browser.

### 1. Configure Flask project and Python version

Add the variables to the end of `.env`:

```bash
FLASK_PROJECT=my-flask
PYTHON_VERSION=3.12
```

### 2. Enter the PHP container

Start the base services before creating files, then enter the PHP container:

```bash
./dvl.sh up php httpd bind
./dvl.sh shell php83
```

### 3. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-flask
cd /shared/httpd/my-flask
```

### 4. Create the Flask application

Create the application source:

```bash
mkdir app
vi app/main.py
```

```python
"""Flask example application."""
from flask import Flask

app = Flask(__name__)


@app.route("/")
def index():
    """Serve the default index page."""
    return "Hello from Flask on Python 3.12!"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000)
```

Add dependencies:

```bash
cat > requirements.txt <<'REQ'
Flask>=3.0,<4.0
REQ
```

### 5. Link a placeholder docroot

```bash
ln -s app htdocs
```

### 6. Add reverse-proxy vhost-gen config files

Leave the shell and copy templates from the Devilbox directory:

```bash
exit
cd /path/to/devilbox
mkdir -p data/www/my-flask/.devilbox
cp cfg/vhost-gen/apache22.yml-example-rproxy data/www/my-flask/.devilbox/apache22.yml
cp cfg/vhost-gen/apache24.yml-example-rproxy data/www/my-flask/.devilbox/apache24.yml
cp cfg/vhost-gen/nginx.yml-example-rproxy data/www/my-flask/.devilbox/nginx.yml
```

Edit each template to forward to the Flask backend and port `3000`. If your override keeps the historical static backend IP, the Apache templates should contain:

```apache
ProxyPass / http://172.16.238.250:3000/
ProxyPassReverse / http://172.16.238.250:3000/
```

The Nginx template should contain:

```nginx
location / {
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_pass http://172.16.238.250:3000;
}
```

If you customize the compose service name or network, use that backend instead of the static IP.

### 7. Enable the Flask compose override

Copy the Flask override into place or merge it with your existing override:

```bash
cp compose/docker-compose.override.yml-python-flask.yml docker-compose.override.yml
```

:::caution
If `docker-compose.override.yml` already contains local changes, merge the Flask service instead of overwriting the file.
:::

### 8. Verify DNS

`my-flask.lvh.me` resolves to localhost by default. Add a hosts entry only for custom suffixes.

### 9. Start Devilbox

```bash
./dvl.sh up php httpd bind flask1
```

### 10. Open your browser

Visit <http://my-flask.lvh.me> or <https://my-flask.lvh.me>. The web server proxies the request to the Flask application on port `3000`.

## Next steps

- Keep `requirements.txt` pinned for reproducible local builds.
- Use a dedicated compose override per Python service when running multiple Flask apps.
- Configure HTTPS trust before testing browser integrations.
