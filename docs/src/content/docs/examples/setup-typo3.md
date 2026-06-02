---
title: "Setup TYPO3"
---

# Setup TYPO3

This example installs TYPO3 13 LTS with Composer from inside the Devilbox PHP
container and serves it through a standard Devilbox virtual host.

<div class="seealso">

`example typo3 documentation`

</div>

## Overview

The following configuration will be used:

| Project name | VirtualHost directory | Database | TLD_SUFFIX | Project URL |
|----|----|----|----|----|
| my-typo | /shared/httpd/my-typo | my_typo | loc | <http://my-typo.loc> `br` <https://my-typo.loc> |

> [!NOTE]
> Inside the Devilbox PHP container, projects are always in `/shared/httpd/`.
> On your host, projects are stored in `./data/www/` by default. This path can
> be changed via `env-httpd-datadir`.

## Walk through

It will be ready in eight steps:

1. Start Devilbox
2. Enter the PHP container
3. Create a new VirtualHost directory
4. Install TYPO3 13 LTS via Composer
5. Symlink the webroot directory
6. Create the database and DNS record
7. Create the `FIRST_INSTALL` file
8. Complete the guided web installation

### 1. Start Devilbox

Navigate to the Devilbox git directory and start the stack:

```bash
host> ./dvl.sh up
```

### 2. Enter the PHP container

All project commands run inside the PHP container:

```bash
host> ./dvl.sh shell
```

<div class="seealso">

\* `enter-the-php-container` \* `work-inside-the-php-container` \*
`available-tools`

</div>

### 3. Create new vhost directory

The vhost directory defines the name under which your project will be
available. `<vhost dir>.TLD_SUFFIX` becomes the final URL.

```bash
devilbox@php-8.3 in /shared/httpd $ mkdir my-typo
devilbox@php-8.3 in /shared/httpd $ cd my-typo
```

<div class="seealso">

`env-tld-suffix`

</div>

### 4. Install TYPO3 13 LTS

Install the current TYPO3 LTS distribution with Composer:

```bash
devilbox@php-8.3 in /shared/httpd/my-typo $ composer create-project typo3/cms-base-distribution:^13 typo3
```

How the directory structure looks after installation:

```bash
devilbox@php-8.3 in /shared/httpd/my-typo $ tree -L 1
.
└── typo3

1 directory, 0 files
```

### 5. Symlink webroot

The web server expects every project document root in `<vhost dir>/htdocs/`.
TYPO3 keeps its entry point in `public/`, so symlink it to `htdocs`:

```bash
devilbox@php-8.3 in /shared/httpd/my-typo $ ln -s typo3/public htdocs
```

```bash
devilbox@php-8.3 in /shared/httpd/my-typo $ tree -L 1
.
├── typo3
└── htdocs -> typo3/public

2 directories, 0 files
```

### 6. Database and DNS record

Create the TYPO3 database from inside the container:

```bash
devilbox@php-8.3 in /shared/httpd/my-typo $ mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_typo;'
```

If Auto DNS is configured you can skip the hosts entry. Otherwise add this line
to your host operating system's hosts file:

```bash
127.0.0.1 my-typo.loc
```

<div class="seealso">

- `howto-add-project-hosts-entry-on-mac`
- `howto-add-project-hosts-entry-on-win`
- `setup-auto-dns`

</div>

### 7. Create `FIRST_INSTALL`

TYPO3 starts the guided installer only when `FIRST_INSTALL` exists in the
document root:

```bash
devilbox@php-8.3 in /shared/httpd/my-typo $ touch htdocs/FIRST_INSTALL
```

### 8. Open your browser

Open <http://my-typo.loc> or <https://my-typo.loc> and follow the TYPO3 setup:

1. Select the database driver and enter `root` as user, your database password,
   `mysql` as host, and `3306` as port.
2. Select the `my_typo` database.
3. Create the administrator user and site name.
4. Finish the installation and create an empty starting page.

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
