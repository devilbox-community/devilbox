---
title: "Setup Contao"
---

# Setup Contao

> [!IMPORTANT]
> **You can find a more up-to-date version in the official Contao
> Documentation:**
> `example contao devilbox documentation`

This example will use `composer` to install Contao CMS from within the
Devilbox PHP container.

> [!IMPORTANT]
> Using `composer` requires the underlying file system to support
> symlinks. If you use **Docker Toolbox** you need to explicitly
> allow/enable this. See below for instructions:
>
> - Docker Toolbox and
>   `howto-docker-toolbox-and-the-devilbox-windows-symlinks`

After completing the below listed steps, you will have a working Contao
CMS setup ready to be served via http and https.

<div class="seealso">

\*
`example contao documentation`
\*
`example contao devilbox documentation`

</div>


## Overview

The following configuration will be used:

| Project name | VirtualHost directory | Database | TLD_SUFFIX | Project URL |
|----|----|----|----|----|
| my-contao | /shared/httpd/my-contao | my_contao | loc | <http://my-contao.loc> `br` <https://my-contao.loc> |

> [!NOTE]
> \* Inside the Devilbox PHP container, projects are always in
> `/shared/httpd/`. \* On your host operating system, projects are by
> default in `./data/www/` inside the Devilbox git directory. This path
> can be changed via `env-httpd-datadir`.

The following Devilbox configuration is required:

| Service | Version | Implications |
|----|----|----|
| Webserver | Apache 2.4 | Apache is required instead of Nginx as Contao provides default `.htaccess` files for routing |
| PHP | PHP-FPM 7.2 | Chosen for this example as it is the Devilbox default version |
| Database | MariaDB 10.3 | Chosen for this example as it is the Devilbox default version |

> [!NOTE]
> If you want to use Nginx instead, you will need to adjust the vhost
> congfiguration accordingly to Contao CMS requirements.

## Walk through

It will be ready in eight simple steps:

1.  Enter the PHP container
2.  Create a new VirtualHost directory
3.  Install Contao via `composer`
4.  Symlink webroot directory
5.  Add MySQL database
6.  Setup DNS record
7.  Visit <http://my-contao.loc> in your browser

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
devilbox@php-7.2.15 in /shared/httpd $ mkdir my-contao
```

<div class="seealso">

`env-tld-suffix`

</div>

### 3. Install Contao

Navigate into your newly created vhost directory and install Contao with
`composer`.

``` bash
devilbox@php-7.2.15 in /shared/httpd $ cd my-contao
devilbox@php-7.2.15 in /shared/httpd/my-contao $ composer create-project contao/managed-edition contao
```

How does the directory structure look after installation:

``` bash
devilbox@php-7.2.15 in /shared/httpd/my-contao $ tree -L 1
.
└── contao

1 directory, 0 files
```

### 4. Symlink web

Symlinking the actual webroot directory to `htdocs` is important. The
web server expects every project's document root to be in
`<vhost dir>/htdocs/`. This is the path where it will serve the files.
This is also the path where your frameworks entrypoint (usually
`index.php`) should be found.

Some frameworks however provide its actual content in nested directories
of unknown levels. This would be impossible to figure out by the web
server, so you manually have to symlink it back to its expected path.

``` bash
devilbox@php-7.2.15 in /shared/httpd/my-contao $ ln -s contao/web/ htdocs
```

How does the directory structure look after symlinking:

``` bash
devilbox@php-7.2.15 in /shared/httpd/my-contao $ tree -L 1
.
├── contao
└── htdocs -> contao/web

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
devilbox@php-7.2.15 in /shared/httpd/my-contao $ mysql -u root -h mysql -p -e 'CREATE DATABASE my_contao;'
```

### 6. DNS record

If you **have** Auto DNS configured already, you can skip this section,
because DNS entries will be available automatically by the bundled DNS
server.

If you **don't have** Auto DNS configured, you will need to add the
following line to your host operating systems `/etc/hosts` file (or
`C:\Windows\System32\drivers\etc` on Windows):

``` bash
127.0.0.1 my-contao.loc
```

<div class="seealso">

- `howto-add-project-hosts-entry-on-mac`
- `howto-add-project-hosts-entry-on-win`
- `setup-auto-dns`

</div>

### 7. Open your browser

Open your browser at <http://my-contao.loc> or <https://my-contao.loc>
and follow the installation steps.

#### 7.1 Frontend page

<figure>
<img src="/_includes/figures/examples/contao/01-frontend.png"
width="400" alt="Contao installation: Installation incomplete note" />
<figcaption aria-hidden="true">Contao installation: Installation
incomplete note</figcaption>
</figure>

- Follow the presented instructions and go to:  
  - either <http://my-contao.loc/contao/install>
  - or <https://my-contao.loc/contao/install>

#### 7.2 Accept license

Accept the license by clicking on `Accept license`

<figure>
<img src="/_includes/figures/examples/contao/02-license.png" width="400"
alt="Contao installation: Accept license" />
<figcaption aria-hidden="true">Contao installation: Accept
license</figcaption>
</figure>

#### 7.3 Set install tool password

Set a password for the install tool itself

<figure>
<img
src="/_includes/figures/examples/contao/03-install-tool-password.png"
width="400" alt="Contao installation: Set install tool password" />
<figcaption aria-hidden="true">Contao installation: Set install tool
password</figcaption>
</figure>

#### 7.4 Database setup

- Database host: `mysql`
- Database port: `3306`
- Database user: `root`
- Database pass: empty (if not otherwise set during Devilbox
  configuration)

<figure>
<img src="/_includes/figures/examples/contao/04-database-setup.png"
width="400" alt="Contao installation: Database setup" />
<figcaption aria-hidden="true">Contao installation: Database
setup</figcaption>
</figure>

#### 7.5 Update database

Click on `update database` to populate the database.

<figure>
<img src="/_includes/figures/examples/contao/05-update-database.png"
width="400" alt="Contao installation: Update database" />
<figcaption aria-hidden="true">Contao installation: Update
database</figcaption>
</figure>

#### 7.6 Set admin user

The admin user is required to setup Contao itself and to gain access to
the backend.

<figure>
<img src="/_includes/figures/examples/contao/06-create-admin-user.png"
width="400" alt="Contao installation: Create admin user" />
<figcaption aria-hidden="true">Contao installation: Create admin
user</figcaption>
</figure>

#### 7.7 Finished

Installation is done, click on the `Contao back end` to continue to
setup the CMS itself.

<figure>
<img src="/_includes/figures/examples/contao/07-finished.png"
width="400"
alt="Contao installation: Installation successfully finished" />
<figcaption aria-hidden="true">Contao installation: Installation
successfully finished</figcaption>
</figure>

#### 7.8 Login

Use the admin user credentials created earlier to login in.

<figure>
<img src="/_includes/figures/examples/contao/08-login-screen.png"
width="400" alt="Contao installation: Go to login screen" />
<figcaption aria-hidden="true">Contao installation: Go to login
screen</figcaption>
</figure>

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
