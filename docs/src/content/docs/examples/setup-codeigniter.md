---
title: "Setup CodeIgniter"
---

# Setup CodeIgniter

This example will use `wget` to install CodeIgniter from within the
Devilbox PHP container.

After completing the below listed steps, you will have a working
CodeIgniter setup ready to be served via http and https.

<div class="seealso">

`example codeigniter documentation`

</div>


## Overview

The following configuration will be used:

| Project name | VirtualHost directory | Database | TLD_SUFFIX | Project URL |
|----|----|----|----|----|
| my-ci | /shared/httpd/my-ci | my_ci | loc | <http://my-ci.loc> `br` <https://my-ci.loc> |

> [!NOTE]
> \* Inside the Devilbox PHP container, projects are always in
> `/shared/httpd/`. \* On your host operating system, projects are by
> default in `./data/www/` inside the Devilbox git directory. This path
> can be changed via `env-httpd-datadir`.

## Walk through

It will be ready in eight simple steps:

1.  Enter the PHP container
2.  Create a new VirtualHost directory
3.  Download CodeIgniter
4.  Symlink webroot directory
5.  Add MySQL database
6.  Configure datbase connection
7.  Setup DNS record
8.  Visit <http://my-ci.loc> in your browser

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
devilbox@php-7.0.20 in /shared/httpd $ mkdir my-ci
```

<div class="seealso">

`env-tld-suffix`

</div>

### 3. Download CodeIgniter

Navigate into your newly created vhost directory and install
CodeIgniter.

``` bash
devilbox@php-7.0.20 in /shared/httpd $ cd my-ci
devilbox@php-7.0.20 in /shared/httpd/my-ci $ wget https://github.com/bcit-ci/CodeIgniter/archive/3.1.8.tar.gz
devilbox@php-7.0.20 in /shared/httpd/my-ci $ tar xfvz 3.1.8.tar.gz
```

How does the directory structure look after installation:

``` bash
devilbox@php-7.0.20 in /shared/httpd/my-ci $ tree -L 1
.
├── 3.1.8.tar.gz
└── CodeIgniter-3.1.8

1 directory, 1 file
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
devilbox@php-7.0.20 in /shared/httpd/my-ci $ ln -s CodeIgniter-3.1.8/ htdocs
```

How does the directory structure look after symlinking:

``` bash
devilbox@php-7.0.20 in /shared/httpd/my-ci $ tree -L 1
.
├── 3.1.8.tar.gz
├── CodeIgniter-3.1.8
└── htdocs -> CodeIgniter-3.1.8

2 directories, 1 file
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
devilbox@php-7.0.20 in /shared/httpd/my-ci $ mysql -u root -h 127.0.0.1 -p -e 'CREATE DATABASE my_ci;'
```

### 6. Configure database connection

``` bash
devilbox@php-7.0.20 in /shared/httpd/my-ci $ vi htdocs/application/config/database.php
```

``` php
<?php
$db['default'] = array(
        'dsn'   => '',
        'hostname' => '127.0.0.1',
        'username' => 'root',
        'password' => '',
        'database' => 'my_ci',
        'dbdriver' => 'mysqli',
        'dbprefix' => '',
        'pconnect' => FALSE,
        'db_debug' => (ENVIRONMENT !== 'production'),
        'cache_on' => FALSE,
        'cachedir' => '',
        'char_set' => 'utf8',
        'dbcollat' => 'utf8_general_ci',
        'swap_pre' => '',
        'encrypt' => FALSE,
        'compress' => FALSE,
        'stricton' => FALSE,
        'failover' => array(),
        'save_queries' => TRUE
);
```

### 7. DNS record

If you **have** Auto DNS configured already, you can skip this section,
because DNS entries will be available automatically by the bundled DNS
server.

If you **don't have** Auto DNS configured, you will need to add the
following line to your host operating systems `/etc/hosts` file (or
`C:\Windows\System32\drivers\etc` on Windows):

``` bash
127.0.0.1 my-ci.loc
```

<div class="seealso">

- `howto-add-project-hosts-entry-on-mac`
- `howto-add-project-hosts-entry-on-win`
- `setup-auto-dns`

</div>

### 8. Open your browser

All set now, you can visit <http://my-ci.loc> or <https://my-ci.loc> in
your browser.

<div class="seealso">

`setup-valid-https`

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
