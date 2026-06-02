---
title: "Setup Photon CMS"
---

# Setup Photon CMS

This example installs Photon CMS from inside the Devilbox PHP container and serves its public directory through `htdocs`.

## Overview

| Project name | Container path | Database | TLD_SUFFIX | Project URL |
| --- | --- | --- | --- | --- |
| `my-photon` | `/shared/httpd/my-photon` | `blog` | `lvh.me` | <http://my-photon.lvh.me> / <https://my-photon.lvh.me> |

Projects live in `/shared/httpd/` in the PHP container and in `./data/www/` on the host.

## Prerequisites

- Devilbox with PHP 8.3 or PHP 8.4 available.
- MySQL, HTTPD, and Bind services.
- Photon CLI installed or installable in the PHP container.

Start the stack:

```bash
./dvl.sh up php httpd mysql bind
```

## Walk through

It will be ready in six steps:

1. Enter the PHP container.
2. Create a new virtual host directory.
3. Install Photon CMS.
4. Link `public/` to `htdocs`.
5. Verify DNS.
6. Open the project.

### 1. Enter the PHP container

```bash
./dvl.sh shell php83
```

### 2. Create the vhost directory

```bash
mkdir -p /shared/httpd/my-photon
cd /shared/httpd/my-photon
```

### 3. Install Photon CMS

Run the Photon CLI and answer the database prompts. Use `127.0.0.1` for the MySQL hostname so the connection uses the forwarded MySQL service inside Devilbox.

```bash
photon new blog
```

Suggested answers:

- MySQL hostname: `127.0.0.1`
- MySQL username: `root`
- MySQL password: your `.env` value
- Database name: `blog`

Expected structure:

```bash
tree -L 1
.
└── blog
```

### 4. Link the webroot

```bash
ln -s blog/public htdocs
```

Expected structure:

```bash
tree -L 1
.
├── blog
└── htdocs -> blog/public
```

### 5. Verify DNS

`my-photon.lvh.me` resolves to localhost by default. Add a hosts entry only when using a custom suffix.

### 6. Open your browser

Visit <http://my-photon.lvh.me> or <https://my-photon.lvh.me>.

## Next steps

- Use the Devilbox intranet database tools to inspect the `blog` database.
- Confirm the Photon CLI and generated project support your chosen PHP 8 runtime.
- Add HTTPS trust and Xdebug if you continue development locally.
