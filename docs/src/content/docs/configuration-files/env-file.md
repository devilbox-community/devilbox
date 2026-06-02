---
title: ".env file"
description: "Authoritative guide to every variable in the Devilbox .env file."
sidebar:
  label: ".env"
---

# .env file

The Devilbox `.env` file is consumed when the stack starts. This page is generated from the current `env-example` shape: variables not present there are intentionally not documented. Copy `env-example` to `.env`, edit values, then restart the affected containers.

:::caution
Changing image selections, mount paths or published ports can require stopping and removing containers before starting again. Database credentials must also match initialized data directories.
:::

## Section index

- [Container selection](#container-selection)
- [Core settings](#core-settings)
- [Devilbox intranet](#devilbox-intranet)
- [Image selection](#image-selection)
- [Host mounts](#host-mounts)
- [PHP-FPM and mail](#php-fpm-and-mail)
- [HTTPD](#httpd)
- [Database](#database)
- [DNS](#dns)
- [Additional services](#additional-services)
- [Custom variables](#custom-variables)
- [Agentic](#agentic)
- [Hermes workspace](#hermes-workspace)
- [Multica stack](#multica-stack)

## Container roster note

`CONTAINERS_CONFIG_DEFAULT` and `CONTAINERS_CONFIG_OPTIONAL` are consumed by `install.sh` before runtime to compute the container roster exported for new clones. Review them before install, especially alongside [agentic tool toggles](/getting-started/agentic-tools-toggle/) and [enable all containers](/custom-container/enable-all-container/).

## Container selection

### CONTAINERS_CONFIG_DEFAULT
Always-provisioned containers read by `install.sh`; default lean stack for DNS, HTTPD, PHP and MySQL.
- Type: `string list`
- Default: `"bind httpd php mysql"`
- Example: `CONTAINERS_CONFIG_DEFAULT="bind httpd php mysql"`
- Notes: See [agentic tool toggles](/getting-started/agentic-tools-toggle/) and [enable all containers](/custom-container/enable-all-container/).
### CONTAINERS_CONFIG_OPTIONAL
Optional containers appended by `install.sh` to preserve the broader roster for new clones.
- Type: `string list`
- Default: `"php74 php81 php82 php83 php84 redis opensearch buggregator"`
- Example: `CONTAINERS_CONFIG_OPTIONAL="php74 php81 php82 php83 php84 redis opensearch buggregator"`
- Notes: Remove names before install when you do not want those containers exported.
## Core settings

### DEBUG_ENTRYPOINT
Startup verbosity: `0` errors through `4` trace.
- Type: `integer`
- Default: `2`
- Example: `DEBUG_ENTRYPOINT=2`
- Notes: Use `2` normally, `4` only for deep startup debugging.
### DOCKER_LOGS
`0` writes supported logs below `log/`; `1` streams them to container stdout/stderr.
- Type: `boolean integer`
- Default: `0`
- Example: `DOCKER_LOGS=0`
- Notes: Useful with `docker compose logs` when enabled.
### DEVILBOX_PATH
Repository path used as bind-mount prefix.
- Type: `path`
- Default: `.`
- Example: `DEVILBOX_PATH=.`
- Notes: Changing it requires recreating containers.
### LOCAL_LISTEN_ADDR
Optional host listen address prefix for published ports; include the trailing colon when set.
- Type: `string`
- Default: `empty`
- Example: `LOCAL_LISTEN_ADDR=`
- Notes: Empty uses default binding behavior.
### TLD_SUFFIX
Mass-virtual-hosting suffix for project domains and internal DNS.
- Type: `string`
- Default: `lvh.me`
- Example: `TLD_SUFFIX=lvh.me`
- Notes: `lvh.me` and `dvl.to` resolve to loopback by default.
### EXTRA_HOSTS
Extra DNS records as comma-separated `host=ip` or `host=cname` mappings.
- Type: `mapping list`
- Default: `empty`
- Example: `EXTRA_HOSTS=`
- Notes: CNAME targets must resolve through upstream DNS.
### NEW_UID
Host user id applied inside Devilbox containers for mounted file ownership.
- Type: `integer`
- Default: `1000`
- Example: `NEW_UID=1000`
- Notes: Run `id -u` on the host.
### NEW_GID
Host group id applied inside Devilbox containers for mounted file ownership.
- Type: `integer`
- Default: `1000`
- Example: `NEW_GID=1000`
- Notes: Run `id -g` on the host.
### TIMEZONE
Timezone for PHP container system time and `php.ini`.
- Type: `string`
- Default: `UTC`
- Example: `TIMEZONE=UTC`
- Notes: Use IANA names such as `Europe/Berlin`.
## Devilbox intranet

### DNS_CHECK_TIMEOUT
Intranet DNS-check timeout in seconds.
- Type: `integer`
- Default: `1`
- Example: `DNS_CHECK_TIMEOUT=1`
- Notes: Increase only for slow but valid DNS.
### DEVILBOX_UI_SSL_CN
Certificate names for the Devilbox intranet SSL certificate.
- Type: `string list`
- Default: `localhost,*.localhost,devilbox,*.devilbox,httpd`
- Example: `DEVILBOX_UI_SSL_CN=localhost,*.localhost,devilbox,*.devilbox,httpd`
- Notes: Not used for project vhost certificates.
### DEVILBOX_UI_PROTECT
Enables intranet password protection.
- Type: `boolean integer`
- Default: `0`
- Example: `DEVILBOX_UI_PROTECT=0`
- Notes: Username is `devilbox`; password comes from `DEVILBOX_UI_PASSWORD`.
### DEVILBOX_UI_PASSWORD
Intranet password when protection is enabled.
- Type: `string`
- Default: `password`
- Example: `DEVILBOX_UI_PASSWORD=password`
- Notes: Restart PHP after changing it.
### DEVILBOX_UI_ENABLE
Enables or disables the Devilbox intranet vhost.
- Type: `boolean integer`
- Default: `1`
- Example: `DEVILBOX_UI_ENABLE=1`
- Notes: Disabling redirects IP requests to the first project vhost.
### DEVILBOX_VENDOR_PHPMYADMIN_AUTOLOGIN
Controls phpMyAdmin autologin from the intranet.
- Type: `boolean integer`
- Default: `1`
- Example: `DEVILBOX_VENDOR_PHPMYADMIN_AUTOLOGIN=1`
- Notes: Set `0` to require manual database credentials.
### DEVILBOX_VENDOR_PHPPGADMIN_AUTOLOGIN
Controls phpPgAdmin autologin from the intranet.
- Type: `boolean integer`
- Default: `1`
- Example: `DEVILBOX_VENDOR_PHPPGADMIN_AUTOLOGIN=1`
- Notes: Set `0` to require manual database credentials.
### DEVILBOX_HTTPD_MGMT_USER
HTTPD supervisord management username.
- Type: `string`
- Default: `supervisord`
- Example: `DEVILBOX_HTTPD_MGMT_USER=supervisord`
- Notes: Keep paired with `DEVILBOX_HTTPD_MGMT_PASS`.
### DEVILBOX_HTTPD_MGMT_PASS
HTTPD supervisord management password.
- Type: `string`
- Default: `mypassword`
- Example: `DEVILBOX_HTTPD_MGMT_PASS=mypassword`
- Notes: Use a local secret if exposed beyond loopback.
## Image selection

### PHP_SERVER
Primary PHP-FPM version.
- Type: `version string`
- Default: `8.1`
- Example: `PHP_SERVER=8.1`
- Notes: Use PHP 7.4 or PHP 8.x values present in `env-example`.
### HTTPD_FLAVOUR
HTTPD base flavour, typically `alpine` or `debian`.
- Type: `string`
- Default: `alpine`
- Example: `HTTPD_FLAVOUR=alpine`
- Notes: Must match an available image flavour.
### HTTPD_SERVER
Web server variant.
- Type: `string`
- Default: `nginx-stable`
- Example: `HTTPD_SERVER=nginx-stable`
- Notes: Current choices include Apache 2.2/2.4 and Nginx stable/mainline.
### MYSQL_SERVER
MySQL-compatible database image.
- Type: `string`
- Default: `mariadb-10.4`
- Example: `MYSQL_SERVER=mariadb-10.4`
- Notes: Modern documented targets: MySQL 5.7/8.0/8.4, Percona 5.7/8.0 and MariaDB 10.4+ or 11.x when present.
### PGSQL_SERVER
PostgreSQL image tag.
- Type: `string`
- Default: `14-alpine`
- Example: `PGSQL_SERVER=14-alpine`
- Notes: Use a tag listed in `env-example` or compatible upstream tag.
### REDIS_SERVER
Redis image tag.
- Type: `string`
- Default: `6.2-alpine`
- Example: `REDIS_SERVER=6.2-alpine`
- Notes: Use a listed tag.
### MEMCD_SERVER
Memcached image tag.
- Type: `string`
- Default: `1.6-alpine`
- Example: `MEMCD_SERVER=1.6-alpine`
- Notes: Use a listed tag.
### MONGO_SERVER
MongoDB image tag.
- Type: `string`
- Default: `5.0`
- Example: `MONGO_SERVER=5.0`
- Notes: Use a listed tag.
### VARNISH_SERVER
Varnish image version.
- Type: `string`
- Default: `6`
- Example: `VARNISH_SERVER=6`
- Notes: Use a listed tag.
### RABBIT_SERVER
RabbitMQ image tag.
- Type: `string`
- Default: `3.8`
- Example: `RABBIT_SERVER=3.8`
- Notes: Management tags are possible when listed.
### ELK_SERVER
Elastic stack image version.
- Type: `string`
- Default: `7.9.3`
- Example: `ELK_SERVER=7.9.3`
- Notes: Use a listed tag.
### MAILHOG_SERVER
MailHog image tag.
- Type: `string`
- Default: `latest`
- Example: `MAILHOG_SERVER=latest`
- Notes: Arm tags are listed in `env-example`.
### OPENSEARCH_SERVER
OpenSearch image tag.
- Type: `string`
- Default: `1.2-0`
- Example: `OPENSEARCH_SERVER=1.2-0`
- Notes: Use one of the Magento Cloud Docker OpenSearch tags listed.
### NGROK_SERVER
Ngrok image tag.
- Type: `string`
- Default: `latest`
- Example: `NGROK_SERVER=latest`
- Notes: Use a listed tag.
### MAILPIT_SERVER
Mailpit image tag.
- Type: `string`
- Default: `latest`
- Example: `MAILPIT_SERVER=latest`
- Notes: Use a listed tag.
### BUGGREGATOR_SERVER
Buggregator image tag.
- Type: `string`
- Default: `latest`
- Example: `BUGGREGATOR_SERVER=latest`
- Notes: Use a listed package tag.
### AEM_SERVER
AEM Design image tag.
- Type: `string`
- Default: `6.5.11.0-jdk11`
- Example: `AEM_SERVER=6.5.11.0-jdk11`
- Notes: Use a listed tag.
## Host mounts

### MOUNT_OPTIONS
Extra bind-mount options prepended to existing options.
- Type: `string`
- Default: `empty`
- Example: `MOUNT_OPTIONS=`
- Notes: Start with a comma, for example `,z`; leave empty otherwise.
### HOST_PATH_HTTPD_DATADIR
Host directory containing web projects.
- Type: `path`
- Default: `./data/www`
- Example: `HOST_PATH_HTTPD_DATADIR=./data/www`
- Notes: Mounted into PHP and HTTPD containers; changing requires recreation.
### HOST_PATH_BACKUPDIR
Host database-backup directory.
- Type: `path`
- Default: `./backups`
- Example: `HOST_PATH_BACKUPDIR=./backups`
- Notes: Mounted into the PHP container as `/shared/backups`.
### HOST_PATH_SSH_DIR
Host SSH directory mounted read-only into PHP.
- Type: `path`
- Default: `~/.ssh`
- Example: `HOST_PATH_SSH_DIR=~/.ssh`
- Notes: Default is `~/.ssh`.
## PHP-FPM and mail

### PHP_MODULES_ENABLE
Optional PHP modules to enable.
- Type: `string list`
- Default: `empty`
- Example: `PHP_MODULES_ENABLE=`
- Notes: Examples include `ioncube`, `blackfire`, `sourceguardian`; disable Xdebug if needed.
### PHP_MODULES_DISABLE
PHP modules to disable.
- Type: `string list`
- Default: `oci8,PDO_OCI,pdo_sqlsrv,sqlsrv,rdkafka,swoole,psr,phalcon`
- Example: `PHP_MODULES_DISABLE=oci8,PDO_OCI,pdo_sqlsrv,sqlsrv,rdkafka,swoole,psr,phalcon`
- Notes: Comma-separated, no spaces required.
### PHP_MAIL_CATCH_ALL
Postfix mode: `0` off, `1` normal, `2` catch-all.
- Type: `integer`
- Default: `2`
- Example: `PHP_MAIL_CATCH_ALL=2`
- Notes: Catch-all mail appears in the intranet mail page.
## HTTPD

### HOST_PORT_HTTPD
Host-side port for httpd.
- Type: `integer`
- Default: `80`
- Example: `HOST_PORT_HTTPD=80`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_HTTPD_SSL
Host-side port for httpd ssl.
- Type: `integer`
- Default: `443`
- Example: `HOST_PORT_HTTPD_SSL=443`
- Notes: Restart the relevant service after changing it.
### HTTPD_HTTP2_ENABLE
Global HTTP/2 toggle.
- Type: `boolean integer`
- Default: `1`
- Example: `HTTPD_HTTP2_ENABLE=1`
- Notes: Not per-vhost.
### HTTPD_VHOST_SSL_TYPE
Generated vhost SSL mode.
- Type: `string`
- Default: `both`
- Example: `HTTPD_VHOST_SSL_TYPE=both`
- Notes: Allowed: `both`, `redir`, `ssl`, `plain`.
### HTTPD_DOCROOT_DIR
Project subdirectory served as document root.
- Type: `directory name`
- Default: `htdocs`
- Example: `HTTPD_DOCROOT_DIR=htdocs`
- Notes: Example: `public`.
### HTTPD_TEMPLATE_DIR
Project subdirectory for custom vhost templates.
- Type: `directory name`
- Default: `.devilbox`
- Example: `HTTPD_TEMPLATE_DIR=.devilbox`
- Notes: Default `.devilbox`.
### HTTPD_BACKEND_TIMEOUT
HTTPD upstream timeout for PHP-FPM or reverse proxies.
- Type: `integer`
- Default: `180`
- Example: `HTTPD_BACKEND_TIMEOUT=180`
- Notes: Keep above long PHP request times.
### HTTPD_NGINX_WORKER_PROCESSES
Nginx worker process count.
- Type: `string or integer`
- Default: `auto`
- Example: `HTTPD_NGINX_WORKER_PROCESSES=auto`
- Notes: Nginx-only; `auto` is valid.
### HTTPD_NGINX_WORKER_CONNECTIONS
Nginx connections per worker.
- Type: `integer`
- Default: `1024`
- Example: `HTTPD_NGINX_WORKER_CONNECTIONS=1024`
- Notes: Nginx-only.
## Database

### MYSQL_ROOT_PASSWORD
MySQL-compatible root password expected by Devilbox.
- Type: `string`
- Default: `empty`
- Example: `MYSQL_ROOT_PASSWORD=change-me`
- Notes: Changing `.env` alone does not update initialized database users.
### HOST_PORT_MYSQL
Host-side port for mysql.
- Type: `integer`
- Default: `3306`
- Example: `HOST_PORT_MYSQL=3306`
- Notes: Restart the relevant service after changing it.
### PGSQL_ROOT_USER
PostgreSQL superuser name.
- Type: `string`
- Default: `postgres`
- Example: `PGSQL_ROOT_USER=postgres`
- Notes: Keep in sync with initialized data.
### PGSQL_ROOT_PASSWORD
PostgreSQL superuser password.
- Type: `string`
- Default: `empty`
- Example: `PGSQL_ROOT_PASSWORD=change-me`
- Notes: Remove `trust` auth when requiring it.
### PGSQL_HOST_AUTH_METHOD
PostgreSQL host auth method.
- Type: `string`
- Default: `trust`
- Example: `PGSQL_HOST_AUTH_METHOD=trust`
- Notes: `trust` allows passwordless local access.
### HOST_PORT_PGSQL
Host-side port for pgsql.
- Type: `integer`
- Default: `5432`
- Example: `HOST_PORT_PGSQL=5432`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_REDIS
Host-side port for redis.
- Type: `integer`
- Default: `6379`
- Example: `HOST_PORT_REDIS=6379`
- Notes: Restart the relevant service after changing it.
### REDIS_ARGS
Additional Redis startup arguments.
- Type: `string`
- Default: `empty`
- Example: `REDIS_ARGS=`
- Notes: Use `--requirepass value` without quotes/spaces for password protection.
### HOST_PORT_MEMCD
Host-side port for memcd.
- Type: `integer`
- Default: `11211`
- Example: `HOST_PORT_MEMCD=11211`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_MONGO
Host-side port for mongo.
- Type: `integer`
- Default: `27017`
- Example: `HOST_PORT_MONGO=27017`
- Notes: Restart the relevant service after changing it.
## DNS

### HOST_PORT_BIND
Host-side port for bind.
- Type: `integer`
- Default: `1053`
- Example: `HOST_PORT_BIND=1053`
- Notes: Restart the relevant service after changing it.
### BIND_DNS_RESOLVER
Upstream DNS resolvers for BIND.
- Type: `string list`
- Default: `8.8.8.8,8.8.4.4`
- Example: `BIND_DNS_RESOLVER=8.8.8.8,8.8.4.4`
- Notes: Use LAN DNS when containers need private names.
### BIND_DNSSEC_VALIDATE
DNSSEC validation mode.
- Type: `string`
- Default: `no`
- Example: `BIND_DNSSEC_VALIDATE=no`
- Notes: Allowed: `no`, `yes`, `auto`.
### BIND_TTL_TIME
Runtime setting for bind ttl time as defined in `env-example`.
- Type: `integer`
- Default: `empty`
- Example: `BIND_TTL_TIME=`
- Notes: Restart the relevant service after changing it.
### BIND_REFRESH_TIME
Runtime setting for bind refresh time as defined in `env-example`.
- Type: `integer`
- Default: `empty`
- Example: `BIND_REFRESH_TIME=`
- Notes: Restart the relevant service after changing it.
### BIND_RETRY_TIME
Runtime setting for bind retry time as defined in `env-example`.
- Type: `integer`
- Default: `empty`
- Example: `BIND_RETRY_TIME=`
- Notes: Restart the relevant service after changing it.
### BIND_EXPIRY_TIME
Runtime setting for bind expiry time as defined in `env-example`.
- Type: `integer`
- Default: `empty`
- Example: `BIND_EXPIRY_TIME=`
- Notes: Restart the relevant service after changing it.
### BIND_MAX_CACHE_TIME
Runtime setting for bind max cache time as defined in `env-example`.
- Type: `integer`
- Default: `empty`
- Example: `BIND_MAX_CACHE_TIME=`
- Notes: Restart the relevant service after changing it.
### BIND_LOG_DNS_QUERIES
Logs DNS queries when enabled.
- Type: `boolean integer`
- Default: `0`
- Example: `BIND_LOG_DNS_QUERIES=0`
- Notes: Useful but noisy.
## Additional services

### HOST_PORT_ELK_ELASTIC
Host-side port for elk elastic.
- Type: `integer`
- Default: `9200`
- Example: `HOST_PORT_ELK_ELASTIC=9200`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_ELK_LOGSTASH
Host-side port for elk logstash.
- Type: `integer`
- Default: `9600`
- Example: `HOST_PORT_ELK_LOGSTASH=9600`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_ELK_KIBANA
Host-side port for elk kibana.
- Type: `integer`
- Default: `5601`
- Example: `HOST_PORT_ELK_KIBANA=5601`
- Notes: Restart the relevant service after changing it.
### VARNISH_CONFIG
Runtime setting for varnish config as defined in `env-example`.
- Type: `string`
- Default: `/etc/varnish/default.vcl`
- Example: `VARNISH_CONFIG=/etc/varnish/default.vcl`
- Notes: Restart the relevant service after changing it.
### VARNICS_CACHE_SIZE
Runtime setting for varnics cache size as defined in `env-example`.
- Type: `string`
- Default: `128m`
- Example: `VARNICS_CACHE_SIZE=128m`
- Notes: Restart the relevant service after changing it.
### VARNISH_PARAMS
Runtime setting for varnish params as defined in `env-example`.
- Type: `string`
- Default: `-p default_ttl=3600 -p default_grace=3600`
- Example: `VARNISH_PARAMS=-p default_ttl=3600 -p default_grace=3600`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_VARNISH
Host-side port for varnish.
- Type: `integer`
- Default: `6081`
- Example: `HOST_PORT_VARNISH=6081`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_HAPROXY
Host-side port for haproxy.
- Type: `integer`
- Default: `8080`
- Example: `HOST_PORT_HAPROXY=8080`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_HAPROXY_SSL
Host-side port for haproxy ssl.
- Type: `integer`
- Default: `8443`
- Example: `HOST_PORT_HAPROXY_SSL=8443`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_RABBIT
Host-side port for rabbit.
- Type: `integer`
- Default: `5672`
- Example: `HOST_PORT_RABBIT=5672`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_RABBIT_MGMT
Host-side port for rabbit mgmt.
- Type: `integer`
- Default: `15672`
- Example: `HOST_PORT_RABBIT_MGMT=15672`
- Notes: Restart the relevant service after changing it.
### RABBIT_DEFAULT_VHOST
Runtime setting for rabbit default vhost as defined in `env-example`.
- Type: `string`
- Default: `my_vhost`
- Example: `RABBIT_DEFAULT_VHOST=my_vhost`
- Notes: Restart the relevant service after changing it.
### RABBIT_DEFAULT_USER
Runtime setting for rabbit default user as defined in `env-example`.
- Type: `string`
- Default: `guest`
- Example: `RABBIT_DEFAULT_USER=guest`
- Notes: Restart the relevant service after changing it.
### RABBIT_DEFAULT_PASS
Runtime setting for rabbit default pass as defined in `env-example`.
- Type: `string`
- Default: `guest`
- Example: `RABBIT_DEFAULT_PASS=guest`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_MAILHOG
Host-side port for mailhog.
- Type: `integer`
- Default: `8025`
- Example: `HOST_PORT_MAILHOG=8025`
- Notes: Restart the relevant service after changing it.
### MAILHOG_IMAGE
Container image reference for mailhog image.
- Type: `image reference`
- Default: `richarvey/mailhog`
- Example: `MAILHOG_IMAGE=richarvey/mailhog`
- Notes: Restart the relevant service after changing it.
### MAILHOG_SMTP_ADDR
Runtime setting for mailhog smtp addr as defined in `env-example`.
- Type: `string`
- Default: `mailhog:1025`
- Example: `MAILHOG_SMTP_ADDR=mailhog:1025`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_NGROK
Host-side port for ngrok.
- Type: `integer`
- Default: `4040`
- Example: `HOST_PORT_NGROK=4040`
- Notes: Restart the relevant service after changing it.
### NGROK_HTTP_TUNNELS
Runtime setting for ngrok http tunnels as defined in `env-example`.
- Type: `string`
- Default: `httpd:httpd:80`
- Example: `NGROK_HTTP_TUNNELS=httpd:httpd:80`
- Notes: Restart the relevant service after changing it.
### NGROK_AUTHTOKEN
Secret value for ngrok authtoken; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `NGROK_AUTHTOKEN=change-me`
- Notes: Restart the relevant service after changing it.
### NGROK_REGION
Runtime setting for ngrok region as defined in `env-example`.
- Type: `string`
- Default: `us`
- Example: `NGROK_REGION=us`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_MAILPIT
Host-side port for mailpit.
- Type: `integer`
- Default: `8025`
- Example: `HOST_PORT_MAILPIT=8025`
- Notes: Restart the relevant service after changing it.
### SMTP_PORT_MAILPIT
Runtime setting for smtp port mailpit as defined in `env-example`.
- Type: `integer`
- Default: `1025`
- Example: `SMTP_PORT_MAILPIT=1025`
- Notes: Restart the relevant service after changing it.
### MAILPIT_IMAGE
Container image reference for mailpit image.
- Type: `image reference`
- Default: `axllent/mailpit`
- Example: `MAILPIT_IMAGE=axllent/mailpit`
- Notes: Restart the relevant service after changing it.
### MAILPIT_SMTP_ADDR
Runtime setting for mailpit smtp addr as defined in `env-example`.
- Type: `string`
- Default: `mailpit:1025`
- Example: `MAILPIT_SMTP_ADDR=mailpit:1025`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_BUGGREGATOR_DASHBOARD
Host-side port for buggregator dashboard.
- Type: `integer`
- Default: `8000`
- Example: `HOST_PORT_BUGGREGATOR_DASHBOARD=8000`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_BUGGREGATOR_SMTP
Host-side port for buggregator smtp.
- Type: `integer`
- Default: `1025`
- Example: `HOST_PORT_BUGGREGATOR_SMTP=1025`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_BUGGREGATOR_VAR_DUMPER
Host-side port for buggregator var dumper.
- Type: `integer`
- Default: `9912`
- Example: `HOST_PORT_BUGGREGATOR_VAR_DUMPER=9912`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_BUGGREGATOR_MONOLOG
Host-side port for buggregator monolog.
- Type: `integer`
- Default: `9913`
- Example: `HOST_PORT_BUGGREGATOR_MONOLOG=9913`
- Notes: Restart the relevant service after changing it.
### BUGGREGATOR_IMAGE
Container image reference for buggregator image.
- Type: `image reference`
- Default: `ghcr.io/buggregator/server`
- Example: `BUGGREGATOR_IMAGE=ghcr.io/buggregator/server`
- Notes: Restart the relevant service after changing it.
### RAY_HOST
Runtime setting for ray host as defined in `env-example`.
- Type: `string`
- Default: `ray@buggregator`
- Example: `RAY_HOST=ray@buggregator`
- Notes: Restart the relevant service after changing it.
### RAY_PORT
Host-side port for ray port.
- Type: `integer`
- Default: `8000`
- Example: `RAY_PORT=8000`
- Notes: Restart the relevant service after changing it.
### VAR_DUMPER_FORMAT
Runtime setting for var dumper format as defined in `env-example`.
- Type: `string`
- Default: `server`
- Example: `VAR_DUMPER_FORMAT=server`
- Notes: Restart the relevant service after changing it.
### VAR_DUMPER_SERVER
Runtime setting for var dumper server as defined in `env-example`.
- Type: `string`
- Default: `buggregator:9912`
- Example: `VAR_DUMPER_SERVER=buggregator:9912`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_AEM
Host-side port for aem.
- Type: `integer`
- Default: `4502`
- Example: `HOST_PORT_AEM=4502`
- Notes: Restart the relevant service after changing it.
### HOST_PORT_AEM_DEBUGGER
Host-side port for aem debugger.
- Type: `integer`
- Default: `30303`
- Example: `HOST_PORT_AEM_DEBUGGER=30303`
- Notes: Restart the relevant service after changing it.
### AEMDESIGN_IMAGE
Container image reference for aemdesign image.
- Type: `image reference`
- Default: `ghcr.io/aem-design/aemdesign/aem`
- Example: `AEMDESIGN_IMAGE=ghcr.io/aem-design/aemdesign/aem`
- Notes: Restart the relevant service after changing it.
### AEM_RUNMODE
Runtime setting for aem runmode as defined in `env-example`.
- Type: `string`
- Default: `"-Dsling.run.modes=author,crx3,crx3tar,dev"`
- Example: `AEM_RUNMODE="-Dsling.run.modes=author,crx3,crx3tar,dev"`
- Notes: Restart the relevant service after changing it.
### AEM_JVM_OPTS
Runtime setting for aem jvm opts as defined in `env-example`.
- Type: `string`
- Default: `"-server -Xms1024m -Xmx1024m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0"`
- Example: `AEM_JVM_OPTS="-server -Xms1024m -Xmx1024m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0"`
- Notes: Restart the relevant service after changing it.
### AEM_START_OPTS
Runtime setting for aem start opts as defined in `env-example`.
- Type: `string`
- Default: `"server-start -c /aem/crx-quickstart -i launchpad -p 8080 -a 0.0.0.0 -Dsling.properties=conf/sling.properties"`
- Example: `AEM_START_OPTS="server-start -c /aem/crx-quickstart -i launchpad -p 8080 -a 0.0.0.0 -Dsling.properties=conf/sling.properties"`
- Notes: Restart the relevant service after changing it.
## Custom variables

### MAGENTO_CLOUD_CLI_TOKEN
Example custom variable exported into PHP.
- Type: `string`
- Default: `"my-magento-cloud-cli-token"`
- Example: `MAGENTO_CLOUD_CLI_TOKEN="my-magento-cloud-cli-token"`
- Notes: Do not commit real tokens.
## Agentic

### AGENTIC_SERVER
Release tag for `devilboxcommunity/agentic`.
- Type: `string`
- Default: `latest`
- Example: `AGENTIC_SERVER=latest`
- Notes: Ignored when `AGENTIC_DOCKER_IMAGE` is set.
### AGENTIC_DOCKER_IMAGE
Full agentic image override.
- Type: `image reference`
- Default: `empty`
- Example: `AGENTIC_DOCKER_IMAGE=`
- Notes: Leave empty for default image/tag.
### AGENTIC_OAUTH_PORT
Host OAuth callback port for agentic auth.
- Type: `integer`
- Default: `19999`
- Example: `AGENTIC_OAUTH_PORT=19999`
- Notes: Published with `LOCAL_LISTEN_ADDR`.
### AGENTIC_HTTPD_DATADIR
Workspace mounted into the agentic container.
- Type: `path`
- Default: `${HOST_PATH_HTTPD_DATADIR}`
- Example: `AGENTIC_HTTPD_DATADIR=${HOST_PATH_HTTPD_DATADIR}`
- Notes: Defaults to `HOST_PATH_HTTPD_DATADIR`.
### AGENTIC_TOOLS_ENABLE
Agentic tool slugs added to image defaults.
- Type: `string list`
- Default: `empty`
- Example: `AGENTIC_TOOLS_ENABLE=`
- Notes: See [agentic tool toggles](/getting-started/agentic-tools-toggle/); disable wins on collision.
### AGENTIC_TOOLS_DISABLE
Agentic tool slugs removed from final set.
- Type: `string list`
- Default: `empty`
- Example: `AGENTIC_TOOLS_DISABLE=`
- Notes: No wildcard; list exact slugs.
## Hermes workspace

### HERMES_WORKSPACE_CONTAINER_NAME
Container name for hermes workspace.
- Type: `string`
- Default: `hermes-workspace`
- Example: `HERMES_WORKSPACE_CONTAINER_NAME=hermes-workspace`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### HERMES_AGENT_CONTAINER_NAME
Container name for hermes agent.
- Type: `string`
- Default: `hermes-agent`
- Example: `HERMES_AGENT_CONTAINER_NAME=hermes-agent`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### HERMES_WORKSPACE_HOST_PORT
Host-side port for hermes workspace host port.
- Type: `integer`
- Default: `8642`
- Example: `HERMES_WORKSPACE_HOST_PORT=8642`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### HERMES_WORKSPACE_UI_PORT
Host-side port for hermes workspace ui port.
- Type: `integer`
- Default: `3000`
- Example: `HERMES_WORKSPACE_UI_PORT=3000`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### HERMES_AGENT_DOCKER_IMAGE
Container image reference for hermes agent docker image.
- Type: `image reference`
- Default: `empty`
- Example: `HERMES_AGENT_DOCKER_IMAGE=`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### HERMES_WORKSPACE_DOCKER_IMAGE
Container image reference for hermes workspace docker image.
- Type: `image reference`
- Default: `empty`
- Example: `HERMES_WORKSPACE_DOCKER_IMAGE=`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### ANTHROPIC_API_KEY
Secret value for anthropic api key; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `ANTHROPIC_API_KEY=change-me`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### OPENAI_API_KEY
Secret value for openai api key; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `OPENAI_API_KEY=change-me`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### OPENROUTER_API_KEY
Secret value for openrouter api key; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `OPENROUTER_API_KEY=change-me`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### GOOGLE_API_KEY
Secret value for google api key; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `GOOGLE_API_KEY=change-me`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### GROQ_API_KEY
Secret value for groq api key; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `GROQ_API_KEY=change-me`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### MISTRAL_API_KEY
Secret value for mistral api key; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `MISTRAL_API_KEY=change-me`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### HERMES_API_SERVER_KEY
Secret value for hermes api server key; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `HERMES_API_SERVER_KEY=change-me`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### HERMES_PASSWORD
Secret value for hermes password; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `HERMES_PASSWORD=change-me`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### HERMES_HOST
Runtime setting for hermes host as defined in `env-example`.
- Type: `string`
- Default: `127.0.0.1`
- Example: `HERMES_HOST=127.0.0.1`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### HERMES_COOKIE_SECURE
Runtime setting for hermes cookie secure as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `HERMES_COOKIE_SECURE=`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### HERMES_TRUST_PROXY
Runtime setting for hermes trust proxy as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `HERMES_TRUST_PROXY=`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
### HERMES_UID
Runtime setting for hermes uid as defined in `env-example`.
- Type: `integer`
- Default: `10010`
- Example: `HERMES_UID=10010`
- Notes: Part of the hermes-workspace stack; leave empty/default unless that stack is enabled.
## Multica stack

### MULTICA_WEB_CONTAINER_NAME
Container name for multica web.
- Type: `string`
- Default: `multica-web`
- Example: `MULTICA_WEB_CONTAINER_NAME=multica-web`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_API_CONTAINER_NAME
Container name for multica api.
- Type: `string`
- Default: `multica-api`
- Example: `MULTICA_API_CONTAINER_NAME=multica-api`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_DB_CONTAINER_NAME
Container name for multica db.
- Type: `string`
- Default: `multica-db`
- Example: `MULTICA_DB_CONTAINER_NAME=multica-db`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_WEB_PORT
Host-side port for multica web port.
- Type: `integer`
- Default: `3001`
- Example: `MULTICA_WEB_PORT=3001`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_API_PORT
Host-side port for multica api port.
- Type: `integer`
- Default: `4000`
- Example: `MULTICA_API_PORT=4000`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_IMAGE_TAG
Runtime setting for multica image tag as defined in `env-example`.
- Type: `image reference`
- Default: `latest`
- Example: `MULTICA_IMAGE_TAG=latest`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_DB_DOCKER_IMAGE
Container image reference for multica db docker image.
- Type: `image reference`
- Default: `pgvector/pgvector:pg17`
- Example: `MULTICA_DB_DOCKER_IMAGE=pgvector/pgvector:pg17`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_API_DOCKER_IMAGE
Container image reference for multica api docker image.
- Type: `image reference`
- Default: `ghcr.io/multica-ai/multica-backend`
- Example: `MULTICA_API_DOCKER_IMAGE=ghcr.io/multica-ai/multica-backend`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_WEB_DOCKER_IMAGE
Container image reference for multica web docker image.
- Type: `image reference`
- Default: `ghcr.io/multica-ai/multica-web`
- Example: `MULTICA_WEB_DOCKER_IMAGE=ghcr.io/multica-ai/multica-web`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_DB_NAME
Runtime setting for multica db name as defined in `env-example`.
- Type: `string`
- Default: `multica`
- Example: `MULTICA_DB_NAME=multica`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_DB_USER
Runtime setting for multica db user as defined in `env-example`.
- Type: `string`
- Default: `multica`
- Example: `MULTICA_DB_USER=multica`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_DB_PASSWORD
Secret value for multica db password; keep real values out of version control.
- Type: `secret string`
- Default: `multica`
- Example: `MULTICA_DB_PASSWORD=multica`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_APP_ENV
Runtime setting for multica app env as defined in `env-example`.
- Type: `string`
- Default: `production`
- Example: `MULTICA_APP_ENV=production`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_JWT_SECRET
Secret value for multica jwt secret; keep real values out of version control.
- Type: `secret string`
- Default: `change-me-in-production`
- Example: `MULTICA_JWT_SECRET=change-me-in-production`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_API_URL
Runtime setting for multica api url as defined in `env-example`.
- Type: `string`
- Default: `http://multica-api:8080`
- Example: `MULTICA_API_URL=http://multica-api:8080`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_PUBLIC_URL
Runtime setting for multica public url as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_PUBLIC_URL=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_APP_URL
Runtime setting for multica app url as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_APP_URL=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_FRONTEND_ORIGIN
Runtime setting for multica frontend origin as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_FRONTEND_ORIGIN=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_NEXT_PUBLIC_API_URL
Runtime setting for multica next public api url as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_NEXT_PUBLIC_API_URL=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_NEXT_PUBLIC_WS_URL
Runtime setting for multica next public ws url as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_NEXT_PUBLIC_WS_URL=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_TRUSTED_PROXIES
Runtime setting for multica trusted proxies as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_TRUSTED_PROXIES=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_DEV_VERIFICATION_CODE
Runtime setting for multica dev verification code as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_DEV_VERIFICATION_CODE=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_METRICS_ADDR
Runtime setting for multica metrics addr as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_METRICS_ADDR=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_CORS_ALLOWED_ORIGINS
Runtime setting for multica cors allowed origins as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_CORS_ALLOWED_ORIGINS=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_COOKIE_DOMAIN
Runtime setting for multica cookie domain as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_COOKIE_DOMAIN=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_ALLOW_SIGNUP
Runtime setting for multica allow signup as defined in `env-example`.
- Type: `boolean`
- Default: `true`
- Example: `MULTICA_ALLOW_SIGNUP=true`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_ALLOWED_EMAIL_DOMAINS
Runtime setting for multica allowed email domains as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_ALLOWED_EMAIL_DOMAINS=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_ALLOWED_EMAILS
Runtime setting for multica allowed emails as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_ALLOWED_EMAILS=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_DISABLE_WORKSPACE_CREATION
Runtime setting for multica disable workspace creation as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_DISABLE_WORKSPACE_CREATION=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_RESEND_API_KEY
Secret value for multica resend api key; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `MULTICA_RESEND_API_KEY=change-me`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_RESEND_FROM_EMAIL
Runtime setting for multica resend from email as defined in `env-example`.
- Type: `string`
- Default: `noreply@multica.ai`
- Example: `MULTICA_RESEND_FROM_EMAIL=noreply@multica.ai`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_SMTP_HOST
Runtime setting for multica smtp host as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_SMTP_HOST=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_SMTP_PORT
Host-side port for multica smtp port.
- Type: `integer`
- Default: `25`
- Example: `MULTICA_SMTP_PORT=25`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_SMTP_USERNAME
Runtime setting for multica smtp username as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_SMTP_USERNAME=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_SMTP_PASSWORD
Secret value for multica smtp password; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `MULTICA_SMTP_PASSWORD=change-me`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_SMTP_TLS
Runtime setting for multica smtp tls as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_SMTP_TLS=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_SMTP_TLS_INSECURE
Runtime setting for multica smtp tls insecure as defined in `env-example`.
- Type: `boolean`
- Default: `false`
- Example: `MULTICA_SMTP_TLS_INSECURE=false`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_GOOGLE_CLIENT_ID
Runtime setting for multica google client id as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_GOOGLE_CLIENT_ID=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_GOOGLE_CLIENT_SECRET
Secret value for multica google client secret; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `MULTICA_GOOGLE_CLIENT_SECRET=change-me`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_GOOGLE_REDIRECT_URI
Runtime setting for multica google redirect uri as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_GOOGLE_REDIRECT_URI=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_S3_BUCKET
Runtime setting for multica s3 bucket as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_S3_BUCKET=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_S3_REGION
Runtime setting for multica s3 region as defined in `env-example`.
- Type: `string`
- Default: `us-west-2`
- Example: `MULTICA_S3_REGION=us-west-2`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_CLOUDFRONT_DOMAIN
Runtime setting for multica cloudfront domain as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_CLOUDFRONT_DOMAIN=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_CLOUDFRONT_KEY_PAIR_ID
Secret value for multica cloudfront key pair id; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `MULTICA_CLOUDFRONT_KEY_PAIR_ID=change-me`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_CLOUDFRONT_PRIVATE_KEY
Secret value for multica cloudfront private key; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `MULTICA_CLOUDFRONT_PRIVATE_KEY=change-me`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_GITHUB_APP_SLUG
Runtime setting for multica github app slug as defined in `env-example`.
- Type: `string`
- Default: `empty`
- Example: `MULTICA_GITHUB_APP_SLUG=`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
### MULTICA_GITHUB_WEBHOOK_SECRET
Secret value for multica github webhook secret; keep real values out of version control.
- Type: `secret string`
- Default: `empty`
- Example: `MULTICA_GITHUB_WEBHOOK_SECRET=change-me`
- Notes: Part of the multica stack; leave empty/default unless that stack is enabled.
## Custom application variables

Any extra key-value pair you add to `.env` is exported to the PHP container and can be read by applications, for example with `getenv()` in PHP. Keep secrets in local `.env` files only.
