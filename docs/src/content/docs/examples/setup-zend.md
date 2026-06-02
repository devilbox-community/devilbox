---
title: "Setup Zend"
---

# Setup Zend

Zend Framework is now Laminas. This example installs a Laminas MVC 3.x
application with Composer from inside the Devilbox PHP container while keeping
the historic page title for existing links.

<div class="seealso">

`example zend documentation`

</div>

## Overview

The following configuration will be used:

| Project name | VirtualHost directory | Database | TLD_SUFFIX | Project URL |
|----|----|----|----|----|
| my-zend | /shared/httpd/my-zend | n.a. | loc | <http://my-zend.loc> `br` <https://my-zend.loc> |

> [!NOTE]
> Inside the Devilbox PHP container, projects are always in `/shared/httpd/`.
> On your host, projects are stored in `./data/www/` by default. This path can
> be changed via `env-httpd-datadir`.

## Walk through

It will be ready in six steps:

1. Start Devilbox
2. Enter the PHP container
3. Create a new VirtualHost directory
4. Install Laminas 3.x via Composer
5. Symlink the webroot directory
6. Configure DNS and open the site

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
devilbox@php-8.3 in /shared/httpd $ mkdir my-zend
devilbox@php-8.3 in /shared/httpd $ cd my-zend
```

<div class="seealso">

`env-tld-suffix`

</div>

### 4. Install Laminas 3.x

Install the Laminas MVC skeleton application:

```bash
devilbox@php-8.3 in /shared/httpd/my-zend $ composer create-project --prefer-dist laminas/laminas-mvc-skeleton laminas
```

How the directory structure looks after installation:

```bash
devilbox@php-8.3 in /shared/httpd/my-zend $ tree -L 1
.
└── laminas

1 directory, 0 files
```

### 5. Symlink webroot

The web server expects every project document root in `<vhost dir>/htdocs/`.
Laminas keeps its entry point in `public/`, so symlink it to `htdocs`:

```bash
devilbox@php-8.3 in /shared/httpd/my-zend $ ln -s laminas/public/ htdocs
```

```bash
devilbox@php-8.3 in /shared/httpd/my-zend $ tree -L 1
.
├── laminas
└── htdocs -> laminas/public

2 directories, 0 files
```

### 6. DNS record and browser

If Auto DNS is configured you can skip the hosts entry. Otherwise add this line
to your host operating system's hosts file:

```bash
127.0.0.1 my-zend.loc
```

Open <http://my-zend.loc> or <https://my-zend.loc> to see the Laminas welcome
page.

<div class="seealso">

- `howto-add-project-hosts-entry-on-mac`
- `howto-add-project-hosts-entry-on-win`
- `setup-auto-dns`

</div>

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
