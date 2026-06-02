---
title: "Setup reverse proxy NodeJS"
---

# Setup reverse proxy NodeJS

This example creates a small Node.js 20+ application inside the Devilbox PHP container, runs it with `pm2`, and proxies the virtual host to the Node process through the Devilbox vhost-gen reverse proxy templates.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-node` | `/shared/httpd/my-node` | none | `lvh.me` | <http://my-node.lvh.me> / <https://my-node.lvh.me> |

The Node.js application listens on port `4000` inside the PHP container. Devilbox HTTPD proxies requests from `my-node.lvh.me` to `php:4000`.

:::tip
For isolated Node services, you can also attach a dedicated Node container with a Docker Compose override. This page keeps the classic PHP-container proxy mechanism and updates the commands for the DVL CLI.
:::

## Prerequisites

- Devilbox installed with PHP, HTTPD, and Bind services.
- Node.js 20 LTS or newer and `pm2` available in the selected PHP image.
- Docker Compose v2 through Docker.

Start the stack:

```bash
./dvl.sh up php httpd bind
```

## Walk through

It will be ready in nine steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Create a Node.js application.
4. Create a placeholder `htdocs` directory.
5. Add reverse-proxy vhost-gen config files.
6. Create an autostart script.
7. Verify DNS.
8. Restart Devilbox.
9. Open the project in a browser.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

Confirm the runtime:

```bash
node --version
pm2 --version
```

Use Node.js 20 LTS or newer.

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-node
cd /shared/httpd/my-node
```

### 3. Create the Node.js application

```bash
mkdir src
vi src/index.js
```

```javascript
import http from 'node:http';

const server = http.createServer((request, response) => {
  response.writeHead(200, { 'Content-Type': 'text/plain' });
  response.end('Hello from Node.js 20 on Devilbox\n');
});

server.listen(4000, '0.0.0.0');
```

Add a minimal package file:

```bash
cat > package.json <<'JSON'
{
  "type": "module",
  "scripts": {
    "start": "node src/index.js"
  },
  "engines": {
    "node": ">=20"
  }
}
JSON
```

### 4. Create a placeholder docroot

Reverse-proxy projects still need an `htdocs` directory so the Devilbox intranet recognizes the virtual host.

```bash
mkdir htdocs
```

### 5. Add reverse-proxy vhost-gen config files

Leave the container and copy the reverse-proxy templates from the Devilbox directory on the host:

```bash
exit
cd /path/to/devilbox
mkdir -p data/www/my-node/.devilbox
cp cfg/vhost-gen/apache22.yml-example-rproxy data/www/my-node/.devilbox/apache22.yml
cp cfg/vhost-gen/apache24.yml-example-rproxy data/www/my-node/.devilbox/apache24.yml
cp cfg/vhost-gen/nginx.yml-example-rproxy data/www/my-node/.devilbox/nginx.yml
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

Copy the Node.js autostart template and register your app path:

```bash
cd /path/to/devilbox
cp autostart/run-node-js-projects.sh-example autostart/run-node-js-projects.sh
vi autostart/run-node-js-projects.sh
```

Set the project list to the internal container path:

```bash
NODE_PROJECTS=(
    "/shared/httpd/my-node/src/index.js"
)
```

If your template starts files directly with `pm2`, keep that behavior. If you prefer npm scripts, use a small custom startup command that runs `pm2 start npm --name my-node -- start` from `/shared/httpd/my-node`.

### 7. Verify DNS

`my-node.lvh.me` resolves to localhost by default. For another suffix, add a hosts-file record.

### 8. Restart Devilbox

```bash
./dvl.sh restart
```

Or recycle only the required services:

```bash
./dvl.sh down
./dvl.sh up php httpd bind
```

### 9. Open your browser

Visit <http://my-node.lvh.me> or <https://my-node.lvh.me>. The web server proxies the request to the Node.js process on port `4000`.

## Managing Node.js

Enter the container and inspect `pm2`:

```bash
./dvl.sh shell php83
pm2 list
pm2 logs my-node
```

For a one-off status check from the host, run:

```bash
./dvl.sh exec "pm2 list"
```

## Next steps

- Move larger Node services to a dedicated container when they need separate dependencies.
- Configure trusted HTTPS before testing browser APIs.
- Keep ports unique when multiple reverse-proxy apps run in the PHP container.
