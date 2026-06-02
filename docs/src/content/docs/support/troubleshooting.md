---
title: "Troubleshooting"
---

# Troubleshooting

Start with the smallest reproducible stack, current images, and a clean
Compose state.

## First checks

Run these from the Devilbox repository root:

```bash
./dvl.sh down
docker compose rm -f
docker compose pull
./dvl.sh up bind httpd php mysql
./dvl.sh doctor
```

Check active containers and logs:

```bash
docker compose ps
docker compose logs --tail=100 php
docker compose logs --tail=100 httpd
```

:::tip
Before deep debugging, update Devilbox and compare `.env` with
`env-example`: [Update the Devilbox](/maintenance/update-the-devilbox/).
:::

## Port conflicts on 80 or 443

Symptom:

```text
Bind for 0.0.0.0:80 failed: port is already allocated
```

Find the host process:

```bash
sudo lsof -nP -iTCP:80 -iTCP:443 -sTCP:LISTEN
```

Stop the host web server, or change Devilbox ports in `.env`:

```dotenv
HOST_PORT_HTTPD=8080
HOST_PORT_HTTPD_SSL=8443
```

Restart:

```bash
./dvl.sh down
./dvl.sh up httpd php
```

Open `http://localhost:8080` after changing the HTTP port.

## DNS does not resolve

Check your suffix and DNS container:

```bash
grep '^TLD_SUFFIX=' .env
./dvl.sh up bind
docker compose logs --tail=100 bind
```

Query the bundled DNS server directly:

```bash
dig project.loc @127.0.0.1 -p 1053
dig project.loc @127.0.0.1
```

If the direct query works but the browser does not, configure the host
resolver: [Setup Auto DNS](/intermediate/setup-auto-dns/). On macOS, a
single project can also be added to `/etc/hosts`: [Add project hosts
entry on MacOS](/howto/dns/add-project-dns-entry-on-mac/).

## PHP container will not start

Read PHP logs first:

```bash
docker compose logs --tail=200 php
```

Then validate selected PHP versions in `.env`:

```bash
grep '^PHP_SERVER=' .env
grep '^CONTAINERS_CONFIG_' .env env-example
```

Current PHP containers are `php74`, `php81`, `php82`, `php83`, and
`php84`. Remove obsolete custom service names from local overrides and
`DEVILBOX_CONTAINERS`.

Recreate PHP after changing image tags or mounts:

```bash
docker compose rm -f php
./dvl.sh up php
```

## MySQL authentication errors

MySQL 8 clients and dumps can disagree on the authentication plugin.
Typical errors mention `caching_sha2_password` or
`mysql_native_password`.

Check the selected server:

```bash
grep '^MYSQL_SERVER=' .env
docker compose logs --tail=100 mysql
```

If an imported dump overwrote users, recreate or alter the affected user
inside MySQL:

```sql
ALTER USER 'app'@'%' IDENTIFIED WITH mysql_native_password BY 'secret';
FLUSH PRIVILEGES;
```

For new projects, prefer client libraries that support MySQL 8 defaults.

## macOS file performance

Large vendor trees are slower on Docker Desktop file sharing. Devilbox
already supports mount options through `.env`:

```dotenv
MOUNT_OPTIONS=,cached
```

Then recreate containers:

```bash
./dvl.sh down
./dvl.sh up
```

For very large Magento or Node projects, keep dependency caches outside
the shared tree when possible.

## WSL2 file performance

Keep the repository and projects inside the Linux filesystem, not under
`/mnt/c`:

```bash
mkdir -p ~/Workspace
git clone https://github.com/devilbox-community/devilbox ~/Workspace/devilbox
```

Enable Docker Desktop integration for the WSL distro, then run Devilbox
from the Linux path.

## SELinux blocks volume writes

On Fedora, RHEL, and derivatives, SELinux can deny container writes to
mounted project paths. Use the `:z` volume label option through `.env`:

```dotenv
MOUNT_OPTIONS=,z
```

Recreate containers:

```bash
./dvl.sh down
./dvl.sh up
```

If a custom override defines volumes directly, add the `:z` flag to those
mounts too.

## Host services are unreachable from PHP

Use the Docker host alias:

```bash
./dvl.sh shell
curl http://host.docker.internal:3000
```

On Linux Docker Engine, add the host gateway alias if needed:

```yaml
services:
  php:
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

See [Connect to host OS](/advanced/connect-to-host-os/).

## 403 forbidden

Check that the project has an entry file and readable permissions:

```bash
ls -la data/www/my-project
find data/www/my-project -maxdepth 2 -type f \( -name index.php -o -name index.html \)
```

Confirm container UID/GID mapping:

```bash
grep -E '^NEW_UID=|^NEW_GID=' .env
./dvl.sh shell
id
```

If mappings are wrong, update `NEW_UID` and `NEW_GID`, then recreate the
stack.

## 504 gateway timeout

Long PHP requests can exceed the web server timeout. Increase the HTTPD
timeout variables in `.env`, then restart `httpd` and `php`:

```bash
grep 'TIMEOUT' .env
./dvl.sh restart httpd php
```

Also check PHP logs for fatal errors or memory limits:

```bash
docker compose logs --tail=200 php
```

## Docker disk is full

Docker Desktop errors can include `no space left on device`. Free unused
Docker data:

```bash
docker system df
docker image prune
docker volume prune
```

:::danger
`docker volume prune` deletes unused volumes. Confirm no important
database volume is unused only because the stack is stopped.
:::

## Xdebug cannot connect to the IDE

Use Xdebug 3 settings and the Docker host alias:

```ini
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
```

Verify inside PHP:

```bash
php -i | grep -E 'xdebug.client_host|xdebug.client_port|xdebug.mode'
```

On macOS, see [Host address alias on MacOS](/howto/xdebug/host-address-alias-an-mac/).

## Reset to a known-good state

When configuration drift is suspected:

```bash
cp env-example .env
./dvl.sh down
docker compose rm -f
./dvl.sh up bind httpd php mysql
```

Then reapply only the `.env` changes you need, one at a time.
