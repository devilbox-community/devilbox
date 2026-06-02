---
title: "Setup ProcessWire"
---

# Setup ProcessWire

This example will use `composer` to install ProcessWire from within the
Devilbox PHP container.

> [!IMPORTANT]
> Using `composer` requires the underlying file system to support
> symlinks. If you use **Docker Toolbox** you need to explicitly
> allow/enable this. See below for instructions:
>
> - Docker Toolbox and
>   `howto-docker-toolbox-and-the-devilbox-windows-symlinks`

After completing the below listed steps, you will have a working
ProcessWire setup ready to be served via http and https.

<div class="seealso">

`example processwire documentation`

</div>


## Overview

The following configuration will be used:

| Project name | VirtualHost directory | Database | TLD_SUFFIX | Project URL |
|----|----|----|----|----|
| my-pw | /shared/httpd/my-pw | my_pw | loc | <http://my-pw.loc> `br` <https://my-pw.loc> |

> [!NOTE]
> \* Inside the Devilbox PHP container, projects are always in
> `/shared/httpd/`. \* On your host operating system, projects are by
> default in `./data/www/` inside the Devilbox git directory. This path
> can be changed via `env-httpd-datadir`.

The following Devilbox configuration is required:

| Service | Version | Implications |
|----|----|----|
| Webserver | Apache 2.4 | Apache is required instead of Nginx as ProcessWire provides default `.htaccess` files for routing |
| PHP | PHP-FPM 7.2 | Chosen for this example as it is the Devilbox default version |
| Database | MariaDB 10.3 | Chosen for this example as it is the Devilbox default version |

> [!NOTE]
> If you want to use Nginx instead, you will need to adjust the vhost
> congfiguration accordingly to ProcessWire requirements.

## Walk through

It will be ready in eight simple steps:

1.  Enter the PHP container
2.  Create a new VirtualHost directory
3.  Install ProcessWire via `composer`
4.  Symlink webroot directory
5.  Setup DNS record
6.  Open your browser
7.  Step through guided web installation

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
devilbox@php-7.0.20 in /shared/httpd $ mkdir my-pw
```

<div class="seealso">

`env-tld-suffix`

</div>

### 3. Install ProcessWire

Navigate into your newly created vhost directory and install ProcessWire
with `composer`.

``` bash
devilbox@php-7.0.20 in /shared/httpd $ cd my-pw
devilbox@php-7.0.20 in /shared/httpd/my-pw $ composer create-project processwire/processwire
```

How does the directory structure look after installation:

``` bash
devilbox@php-7.0.20 in /shared/httpd/my-pw $ tree -L 1
.
└── processwire

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
devilbox@php-7.0.20 in /shared/httpd/my-pw $ ln -s ln -s processwire htdocs
```

How does the directory structure look after symlinking:

``` bash
devilbox@php-7.0.20 in /shared/httpd/my-pw $ tree -L 1
.
├── processwire
└── htdocs -> processwire

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

### 5. DNS record

If you **have** Auto DNS configured already, you can skip this section,
because DNS entries will be available automatically by the bundled DNS
server.

If you **don't have** Auto DNS configured, you will need to add the
following line to your host operating systems `/etc/hosts` file (or
`C:\Windows\System32\drivers\etc` on Windows):

``` bash
127.0.0.1 my-pw.loc
```

<div class="seealso">

- `howto-add-project-hosts-entry-on-mac`
- `howto-add-project-hosts-entry-on-win`
- `setup-auto-dns`

</div>

### 6. Open your browser

Open your browser at <http://my-pw.loc> or <https://my-pw.loc>.

### 7. Step through guided web installation

<figure>
<img src="/_includes/figures/examples/processwire/01-install-banner.png"
width="600" alt="ProcessWire installation: Overview" />
<figcaption aria-hidden="true">ProcessWire installation:
Overview</figcaption>
</figure>

<figure>
<img src="/_includes/figures/examples/processwire/02-profile-choice.png"
width="600" alt="ProcessWire installation: Profile Choice" />
<figcaption aria-hidden="true">ProcessWire installation: Profile
Choice</figcaption>
</figure>

<figure>
<img
src="/_includes/figures/examples/processwire/03-default-profile.png"
width="600" alt="ProcessWire installation: Choose Default Profile" />
<figcaption aria-hidden="true">ProcessWire installation: Choose Default
Profile</figcaption>
</figure>

<figure>
<img src="/_includes/figures/examples/processwire/04-compat-check.png"
width="600" alt="ProcessWire installation: Compatibility Check" />
<figcaption aria-hidden="true">ProcessWire installation: Compatibility
Check</figcaption>
</figure>

<figure>
<img src="/_includes/figures/examples/processwire/05-general-setup.png"
width="600" alt="ProcessWire installation: General Setup" />
<figcaption aria-hidden="true">ProcessWire installation: General
Setup</figcaption>
</figure>

<figure>
<img src="/_includes/figures/examples/processwire/06-admin-setup.png"
width="600" alt="ProcessWire installation: Admin Setup" />
<figcaption aria-hidden="true">ProcessWire installation: Admin
Setup</figcaption>
</figure>

<figure>
<img src="/_includes/figures/examples/processwire/07-finished.png"
width="600" alt="ProcessWire installation: Setup completed" />
<figcaption aria-hidden="true">ProcessWire installation: Setup
completed</figcaption>
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
