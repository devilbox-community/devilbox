---
title: "Setup Drupal"
---

# Setup Drupal

This example will use `drush` to install Drupal from within the Devilbox
PHP container.

After completing the below listed steps, you will have a working Drupal
setup ready to be served via http and https.

<div class="seealso">

`example drupal documentation`

</div>


## Overview

The following configuration will be used:

| Project name | VirtualHost directory | Database | TLD_SUFFIX | Project URL |
|----|----|----|----|----|
| my-drupal | /shared/httpd/my-drupal | my_drupal | loc | <http://my-drupal.loc> `br` <https://my-drupal.loc> |

> [!NOTE]
> \* Inside the Devilbox PHP container, projects are always in
> `/shared/httpd/`. \* On your host operating system, projects are by
> default in `./data/www/` inside the Devilbox git directory. This path
> can be changed via `env-httpd-datadir`.

## Walk through

It will be ready in six simple steps:

1.  Enter the PHP container
2.  Create a new VirtualHost directory
3.  Install Drupal via `drush`
4.  Symlink webroot directory
5.  Setup DNS record
6.  Visit <http://my-drupal.loc> in your browser

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
devilbox@php-7.0.20 in /shared/httpd $ mkdir my-drupal
```

<div class="seealso">

`env-tld-suffix`

</div>

### 3. Install Drupal

Navigate into your newly created vhost directory and install Drupal with
`drush`.

``` bash
devilbox@php-7.0.20 in /shared/httpd $ cd my-drupal
devilbox@php-7.0.20 in /shared/httpd/my-drupal $ drush dl drupal
```

How does the directory structure look after installation:

``` bash
devilbox@php-7.0.20 in /shared/httpd/my-drupal $ tree -L 1
.
└── drupal-8.3.3

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
devilbox@php-7.0.20 in /shared/httpd/my-drupal $ ln -s drupal-8.3.3/ htdocs
```

How does the directory structure look after symlinking:

``` bash
devilbox@php-7.0.20 in /shared/httpd/my-drupal $ tree -L 1
.
├── drupal-8.3.3
└── htdocs -> CodeIgniter-3.1.8

2 directories, 0 fils
```

As you can see from the above directory structure, `htdocs` is available
in its expected path and points to the frameworks entrypoint.

> [!IMPORTANT]
> When using **Docker Toolbox**, you need to **explicitly allow** the
> usage of **symlinks**. See below for instructions:
>
> - Docker Toolbox and
>   `howto-docker-toolbox-and-the-devilbox-windows-symlinks`

### 5. DNS record

If you **have** Auto DNS configured already, you can skip this section,
because DNS entries will be available automatically by the bundled DNS
server.

If you **don't have** Auto DNS configured, you will need to add the
following line to your host operating systems `/etc/hosts` file (or
`C:\Windows\System32\drivers\etc` on Windows):

``` bash
127.0.0.1 my-drupal.loc
```

<div class="seealso">

- `howto-add-project-hosts-entry-on-mac`
- `howto-add-project-hosts-entry-on-win`
- `setup-auto-dns`

</div>

### 6. Open your browser

Open your browser at <http://my-drupal.loc> or <https://my-drupal.loc>
and follow the Drupal installation steps.

> [!NOTE]
> When asked about MySQL hostname, choose `127.0.0.1`.

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
