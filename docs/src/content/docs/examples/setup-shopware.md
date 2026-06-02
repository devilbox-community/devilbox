---
title: "Setup Shopware"
---

# Setup Shopware

This example will use `git` to install Shopware from within the Devilbox
PHP container.

After completing the below listed steps, you will have a working
Shopware setup ready to be served via http and https.

<div class="seealso">

\*
`example shopware documentation`
\*
`example shopware github`

</div>


## Overview

The following configuration will be used:

| Project name | VirtualHost directory | Database | TLD_SUFFIX | Project URL |
|----|----|----|----|----|
| my-sw | /shared/httpd/my-sw | my_sw | loc | <http://my-sw.loc> `br` <https://my-sw.loc> |

> [!NOTE]
> \* Inside the Devilbox PHP container, projects are always in
> `/shared/httpd/`. \* On your host operating system, projects are by
> default in `./data/www/` inside the Devilbox git directory. This path
> can be changed via `env-httpd-datadir`.

## Walk through

It will be ready in seven simple steps:

1.  Enter the PHP container
2.  Create a new VirtualHost directory
3.  Download Shopware via `git`
4.  Symlink webroot directory
5.  Add MySQL database
6.  Setup DNS record
7.  Follow installation steps in <http://my-sw.loc> in your browser

### 1. Enter the PHP container

All work will be done inside the PHP container as it provides you with
all required command line tools.

Navigate to the Devilbox git directory and execute `shell.sh` (or
`shell.bat` on Windows) to enter the running PHP container.

``` bash
host> ./shell.sh
```

<div class="seealso">

\* `enter-the-php-container` \* `work-inside-the-php-container` \*
`available-tools`

</div>

### 2. Create new vhost directory

The vhost directory defines the name under which your project will be
available. `br` ( `<vhost dir>.TLD_SUFFIX` will be
the final URL ).

``` bash
devilbox@php-7.0.20 in /shared/httpd $ mkdir my-sw
```

<div class="seealso">

`env-tld-suffix`

</div>

### 3. Download Shopware

Navigate into your newly created vhost directory and install Shopware
with `git`.

``` bash
devilbox@php-7.0.20 in /shared/httpd $ cd my-sw
devilbox@php-7.0.20 in /shared/httpd/my-sw $ git clone https://github.com/shopware/shopware
```

How does the directory structure look after installation:

``` bash
devilbox@php-7.0.20 in /shared/httpd/my-sw $ tree -L 1
.
└── shopware

1 directory, 0 files
```

### 4. Symlink webroot

Symlinking the actual webroot directory to `htdocs` is important. The
web server expects every project's document root to be in
`<vhost dir>/htdocs/`. This is the path where it will serve the files.
This is also the path where your frameworks entrypoint (usually
`index.php`) should be found.

Some frameworks however provide its actual content in nested directories
of unknown levels. This would be impossible to figure out by the web
server, so you manually have to symlink it back to its expected path.

``` bash
devilbox@php-7.0.20 in /shared/httpd/my-sw $ ln -s shopware/ htdocs
```

How does the directory structure look after symlinking:

``` bash
devilbox@php-7.0.20 in /shared/httpd/my-sw $ tree -L 1
.
├── shopware
└── htdocs -> shopware

2 directories, 0 files
```

As you can see from the above directory structure, `htdocs` is available
in its expected path and points to the frameworks entrypoint.

> [!IMPORTANT]
> When using **Docker Toolbox**, you need to **explicitly allow** the
> usage of **symlinks**. See below for instructions:
>
> - Docker Toolbox and
>   `howto-docker-toolbox-and-the-devilbox-windows-symlinks`

### 5. Add MySQL Database

``` bash
devilbox@php-7.0.20 in /shared/httpd/my-sw $ mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_sw;'
```

### 6. DNS record

If you **have** Auto DNS configured already, you can skip this section,
because DNS entries will be available automatically by the bundled DNS
server.

If you **don't have** Auto DNS configured, you will need to add the
following line to your host operating systems `/etc/hosts` file (or
`C:\Windows\System32\drivers\etc` on Windows):

``` bash
127.0.0.1 my-sw.loc
```

<div class="seealso">

- `howto-add-project-hosts-entry-on-mac`
- `howto-add-project-hosts-entry-on-win`
- `setup-auto-dns`

</div>

### 7. Follow install steps in your browser

All set now, you can visit <http://my-sw.loc> or <https://my-sw.loc> in
your browser and follow the installation steps as described in the
`example shopware documentation`:

> [!IMPORTANT]
> When setting up database connection use the following values:
>
> - Database server: `127.0.0.1`
> - Database user: `root` (if you don't have a dedicated user already)
> - Database pass: by default the root password is empty
> - Database name: `my-sw`

## Encountered problems

By the time of writing (2018-07-07) Shopware had loading issues with the
combination of `PHP 5.6` and `Apache 2.4`. Use any other combination.

<div class="seealso">

<https://github.com/cytopia/devilbox/issues/300>

</div>

## Next steps

Once everything is installed and setup correctly, you might be
interested in a few follow-up topics.

### Use bundled batteries

The Devilbox ships most common Web UIs accessible from the intranet.

<div class="seealso">

\* `devilbox-intranet-adminer` \* `devilbox-intranet-phpmyadmin` \*
`devilbox-intranet-phppgadmin` \* `devilbox-intranet-phpredmin` \*
`devilbox-intranet-phpmemcachedadmin`

</div>

### Enhance the Devilbox

Go ahead and make the Devilbox more smoothly by setting up its core
features.

<div class="seealso">

\* `setup-valid-https` \* `setup-auto-dns` \* `configure-php-xdebug`

</div>

### Add services

In case your framework/CMS requires it, attach caching, queues, database
or performance tools.

<div class="seealso">

- `custom-container-enable-blackfire`
- `custom-container-enable-rabbitmq`
- `custom-container-enable-solr`
- `custom-container-enable-varnish`

</div>

### Container tools

Stay inside the container and use what's available.

<div class="seealso">

- `available-tools`
- `source-code-analysis`

</div>
