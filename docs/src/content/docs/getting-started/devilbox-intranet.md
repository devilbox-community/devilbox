---
title: "Devilbox intranet"
---

# Devilbox intranet

The Devilbox intranet is your command & control center showing all kinds
of information and settings currently in effect. It also offers
third-party projects to do all sorts of database manipulation.


## Devilbox tools

### Overview

The start page is there to check if everything works as expected. It
shows all desired Docker containers you wanted to start and if they
succeeded, as well as their ports, mount points and special settings
applied via `.env`.

<figure>
<img src="/_includes/figures/devilbox/devilbox-intranet-index.png"
alt="Devilbox intranet: homepage" />
<figcaption aria-hidden="true">Devilbox intranet: homepage</figcaption>
</figure>

### Virtual hosts

The virtual host page displays all available projects and let's you know
if their configuration is correct, such as DNS settings or document
root.

<figure>
<img src="/_includes/figures/devilbox/devilbox-intranet-vhosts.png"
alt="Devilbox intranet: available virtual hosts" />
<figcaption aria-hidden="true">Devilbox intranet: available virtual
hosts</figcaption>
</figure>

### Emails

The email page displays all emails that would have been sent, but were
caught by the integrated email catch-all functionality.

<figure>
<img src="/_includes/figures/devilbox/devilbox-intranet-emails.png"
alt="Devilbox intranet: email catch-all overview" />
<figcaption aria-hidden="true">Devilbox intranet: email catch-all
overview</figcaption>
</figure>

### Databases

There are several database pages for MySQL and NoSQL databases giving
you an overview about what is currently in place, how many
databases/schemas and or recors and what size they take up.

The following example shows the database page for MySQL:

<figure>
<img
src="/_includes/figures/devilbox/devilbox-intranet-mysql-databases.png"
alt="Devilbox intranet: MySQL database overview" />
<figcaption aria-hidden="true">Devilbox intranet: MySQL database
overview</figcaption>
</figure>

### Info pages

Info pages also exist for every Docker container which show various
settings which are currently applied.

The following example shows you the info page for PHP.

<figure>
<img src="/_includes/figures/devilbox/devilbox-intranet-php-info.png"
alt="Devilbox intranet: php info" />
<figcaption aria-hidden="true">Devilbox intranet: php info</figcaption>
</figure>

The following example shows you the info page for MySQL:

<figure>
<img src="/_includes/figures/devilbox/devilbox-intranet-mysql-info.png"
alt="Devilbox intranet: MySQL info overview" />
<figcaption aria-hidden="true">Devilbox intranet: MySQL info
overview</figcaption>
</figure>

## Third-party tools

### Adminer

`tool adminer` (formerly
phpMinAdmin) is a full-featured database management tool written in PHP.
Conversely to phpMyAdmin, it consist of a single file ready to deploy to
the target server. Adminer is available for MySQL, MariaDB, PostgreSQL,
SQLite, MS SQL, Oracle, Firebird, SimpleDB, Elasticsearch and MongoDB.

### phpMyAdmin

`tool phpmyadmin` is a
free software tool written in PHP, intended to handle the administration
of MySQL over the Web. phpMyAdmin supports a wide range of operations on
MySQL and MariaDB. Frequently used operations (managing databases,
tables, columns, relations, indexes, users, permissions, etc) can be
performed via the user interface, while you still have the ability to
directly execute any SQL statement.

### phpPgAdmin

`tool phppgadmin` is a
web-based administration tool for PostgreSQL. It is perfect for
PostgreSQL DBAs, newbies, and hosting services.

### phpRedMin

`tool phpredmin` is a
simple web interface to manage and monitor your Redis.

### PHPMemcachedAdmin

`tool phpmemcachedadmin`
is a simple web interface to manage and monitor your Memcached.

### OpcacheGUI

`tool opcachegui` is a
clean and responsive interface for Zend OPcache information, showing
statistics, settings and cached files, and providing a real-time update
for the information (using jQuery and React).

## Settings

### Password protect the intranet

If you share your projects over a LAN, but do not want anybody to view
the Devilbox intranet, you can also password protect it.

<div class="seealso">

In order to do so, have a look at the following `.env` variables:

- `env-devilbox-ui-protect`
- `env-devilbox-ui-password`

</div>

### Disable the intranet

If you want a more production-like setup, you can also fully disable the
Devilbox intranet. This is achieved internally by removing the default
virtual host which serves the intranet. When the intranet is disabled,
there is no way to access it.

<div class="seealso">

In order to do so, have a look at the following `.env` variable:

- `env-devilbox-ui-enable`

</div>

## Checklist

1.  You know what tools are provided by the Devilbox intranet
2.  You know how to password protect the Devilbox intranet
3.  You know how to disable the Devilbox intranet

<div class="seealso">

`troubleshooting`

</div>
