---
title: "Setup WordPress"
---

# Setup WordPress

This example installs WordPress 6.x from inside the Devilbox PHP container and
serves it through a standard Devilbox virtual host.

<div class="seealso">

`example wordpress documentation`

</div>

## Overview

The following configuration will be used:

| Project name | VirtualHost directory | Database | TLD_SUFFIX | Project URL |
|----|----|----|----|----|
| my-wp | /shared/httpd/my-wp | my_wp | loc | <http://my-wp.loc> `br` <https://my-wp.loc> |

> [!NOTE]
> Inside the Devilbox PHP container, projects are always in `/shared/httpd/`.
> On your host, projects are stored in `./data/www/` by default. This path can
> be changed via `env-httpd-datadir`.

## Walk through

It will be ready in seven steps:

1. Start Devilbox
2. Enter the PHP container
3. Create a new VirtualHost directory
4. Download WordPress 6.x
5. Symlink the webroot directory
6. Create the MySQL database and DNS record
7. Open WordPress in your browser

### 1. Start Devilbox

```bash
host> ./dvl.sh up
```

### 2. Enter the PHP container

All work will be done inside the PHP container:

```bash
host> ./dvl.sh shell
```

<div class="seealso">

\* `enter-the-php-container` \* `work-inside-the-php-container` \*
`available-tools`

</div>

### 3. Create new vhost directory

The vhost directory defines the name under which your project will be
available.

```bash
devilbox@php-8.3 in /shared/httpd $ mkdir my-wp
devilbox@php-8.3 in /shared/httpd $ cd my-wp
```

<div class="seealso">

`env-tld-suffix`

</div>

### 4. Download WordPress 6.x

Use Git to download the current WordPress branch:

```bash
devilbox@php-8.3 in /shared/httpd/my-wp $ git clone --branch 6.8 https://github.com/WordPress/WordPress wordpress.git
```

How the directory structure looks after installation:

```bash
devilbox@php-8.3 in /shared/httpd/my-wp $ tree -L 1
.
└── wordpress.git

1 directory, 0 files
```

### 5. Symlink webroot

The web server expects every project document root in `<vhost dir>/htdocs/`.
WordPress serves directly from the checkout directory, so symlink it to
`htdocs`:

```bash
devilbox@php-8.3 in /shared/httpd/my-wp $ ln -s wordpress.git/ htdocs
```

```bash
devilbox@php-8.3 in /shared/httpd/my-wp $ tree -L 1
.
├── wordpress.git
└── htdocs -> wordpress.git

2 directories, 0 files
```

### 6. Database and DNS record

Create the WordPress database:

```bash
devilbox@php-8.3 in /shared/httpd/my-wp $ mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_wp;'
```

If Auto DNS is configured you can skip the hosts entry. Otherwise add this line
to your host operating system's hosts file:

```bash
127.0.0.1 my-wp.loc
```

<div class="seealso">

- `howto-add-project-hosts-entry-on-mac`
- `howto-add-project-hosts-entry-on-win`
- `setup-auto-dns`

</div>

### 7. Open your browser

Open <http://my-wp.loc> or <https://my-wp.loc> and follow the WordPress setup:

1. Choose a language.
2. Enter database name `my_wp`, user `root`, your database password, and host
   `127.0.0.1`.
3. Run the installation.
4. Create the site title and administrator account.
5. Log in to the WordPress admin panel.

## Next steps

### Use bundled batteries

<div class="seealso">

\* `devilbox-intranet-adminer` \* `devilbox-intranet-phpmyadmin` \*
`devilbox-intranet-phppgadmin` \* `devilbox-intranet-phpredmin` \*
`devilbox-intranet-phpmemcachedadmin`

</div>

### Enhance the Devilbox

<div class="seealso">

\* `setup-valid-https` \* `setup-auto-dns` \* `configure-php-xdebug`

</div>

### Add services

<div class="seealso">

- `custom-container-enable-blackfire`
- `custom-container-enable-rabbitmq`
- `custom-container-enable-solr`
- `custom-container-enable-varnish`

</div>
