---
title: "Setup Magento 2"
---

# Setup Magento 2

This example will use `git` and `composer` to install Magento 2 from
within the Devilbox PHP container.

> [!IMPORTANT]
> Using `composer` requires the underlying file system to support
> symlinks. If you use **Docker Toolbox** you need to explicitly
> allow/enable this. See below for instructions:
>
> - Docker Toolbox and
>   `howto-docker-toolbox-and-the-devilbox-windows-symlinks`

After completing the below listed steps, you will have a working Magento
2 setup ready to be served via http and https.

<div class="seealso">

`example magento2 documentation`

</div>


## Overview

The following configuration will be used:

| Project name | VirtualHost directory | Database | TLD_SUFFIX | Project URL |
|----|----|----|----|----|
| my-magento | /shared/httpd/my-magento | my_magento | loc | <http://my-magento.loc> `br` <https://my-magento.loc> |

> [!NOTE]
> \* Inside the Devilbox PHP container, projects are always in
> `/shared/httpd/`. \* On your host operating system, projects are by
> default in `./data/www/` inside the Devilbox git directory. This path
> can be changed via `env-httpd-datadir`.

## Requirements

This example requires to use **Apache 2.4**, as Magento does a lot of
`.htaccess` magic by default and these files are not interpreted by
**Nginx**.

If you still want to use Nginx instead, you will have to overwrite your
vhost configuration to ensure the `.htaccess` rules are glued into your
Nginx vhost configuration.

<div class="seealso">

- `vhost-gen-customize-specific-virtual-host`
- <https://magento.stackexchange.com/questions/121758/how-to-configure-nginx-for-magento-2#121769>

</div>

## Walk through

It will be ready in eight simple steps:

1.  Enter the PHP container
2.  Create a new VirtualHost directory
3.  Install Magento 2 via `git` and `composer`
4.  Symlink webroot directory
5.  Add MySQL database
6.  Setup DNS record
7.  Visit <http://my-magento.loc> in your browser

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
devilbox@php-7.1.20 in /shared/httpd $ mkdir my-magento
```

<div class="seealso">

`env-tld-suffix`

</div>

### 3. Install Magento 2

Navigate into your newly created vhost directory and install Magento 2
with `git`.

``` bash
devilbox@php-7.1.20 in /shared/httpd $ cd my-magento

# Download Magento 2 via git
devilbox@php-7.1.20 in /shared/httpd/my-magento $ git clone https://github.com/magento/magento2

# Checkout the latest stable git tag
devilbox@php-7.1.20 in /shared/httpd/my-magento $ cd magento2
devilbox@php-7.1.20 in /shared/httpd/my-magento/magento2 $ git checkout 2.2.5

# Install dependencies with Composer
devilbox@php-7.1.20 in /shared/httpd/my-magento/magento2 $ composer install
```

How does the directory structure look after installation:

``` bash
devilbox@php-7.1.20 in /shared/httpd/my-magento $ tree -L 1
.
└── magento2

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
devilbox@php-7.1.20 in /shared/httpd/my-magento $ ln -s magento2/ htdocs
```

How does the directory structure look after symlinking:

``` bash
devilbox@php-7.1.20 in /shared/httpd/my-magento $ tree -L 1
.
├── magento2
└── htdocs -> magento2

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
devilbox@php-7.1.20 in /shared/httpd/my-magento $ mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_magento;'
```

### 7. DNS record

If you **have** Auto DNS configured already, you can skip this section,
because DNS entries will be available automatically by the bundled DNS
server.

If you **don't have** Auto DNS configured, you will need to add the
following line to your host operating systems `/etc/hosts` file (or
`C:\Windows\System32\drivers\etc` on Windows):

``` bash
127.0.0.1 my-magento.loc
```

<div class="seealso">

- `howto-add-project-hosts-entry-on-mac`
- `howto-add-project-hosts-entry-on-win`
- `setup-auto-dns`

</div>

### 8. Open your browser

All set now, you can visit <http://my-magento.loc> or
<https://my-magento.loc> in your browser and follow the installation
steps.

> [!IMPORTANT]
> Use `127.0.0.1` for the MySQL database hostname.

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
