---
title: "Setup reverse proxy NodeJS"
---

# Setup reverse proxy NodeJS

This example will walk you through creating a NodeJS hello world
application, which is started automatically on `docker-compose up` via
`tool pm2`, will be proxied to
the web server and can be reached via valid HTTPS.

> [!NOTE]
> It is also possible to attach a leight-weight NodeJS container to the
> Devilbox instead of running this in the PHP container. See here for
> details: `reverse-proxy-with-custom-docker`


## Overview

The following configuration will be used:

<table style="width:97%;">
<colgroup>
<col style="width: 12%" />
<col style="width: 22%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 38%" />
</colgroup>
<thead>
<tr>
<th>Project name</th>
<th>VirtualHost directory</th>
<th>Database</th>
<th>TLD_SUFFIX</th>
<th>Project URL</th>
</tr>
</thead>
<tbody>
<tr>
<td>my-node</td>
<td>/shared/httpd/my-node</td>
<td><ul>
<li></li>
</ul></td>
<td>loc</td>
<td><a href="http://my-node.loc">http://my-node.loc</a> <a
href="##SUBST##|br|">|br|</a> <a
href="https://my-node.loc">https://my-node.loc</a></td>
</tr>
</tbody>
</table>

Additionally we will set the listening port of the NodeJS appliation to
`4000` inside the PHP container.

We also want NodeJS running regardless of which PHP container will
bestarted (global autostart).

> [!NOTE]
> \* Inside the Devilbox PHP container, projects are always in
> `/shared/httpd/`. \* On your host operating system, projects are by
> default in `./data/www/` inside the Devilbox git directory. This path
> can be changed via `env-httpd-datadir`.

## Walk through

It will be ready in nine simple steps:

1.  Enter the PHP container
2.  Create a new VirtualHost directory
3.  Create NodeJS hello world application
4.  Create *virtual* docroot directory
5.  Add reverse proxy vhost-gen config files
6.  Create autostart script
7.  Setup DNS record
8.  Restart the Devilbox
9.  Visit <http://my-node.loc> in your browser

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
devilbox@php-7.0.20 in /shared/httpd $ mkdir my-node
```

<div class="seealso">

`env-tld-suffix`

</div>

### 3. Create NodeJS application

``` bash
# Navigate to your project directory
devilbox@php-7.0.20 in /shared/httpd $ cd my-node

# Create a directory which will hold the source code
devilbox@php-7.0.20 in /shared/httpd/my-node $ mkdir src

# Create the index.js file with your favourite editor
devilbox@php-7.0.20 in /shared/httpd/my-node/src $ vi index.js
```

``` javascript
// Load the http module to create an http server.
var http = require('http');

// Configure our HTTP server to respond with Hello World to all requests.
var server = http.createServer(function (request, response) {
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.end("Hello World\n");
});

// Listen on port 4000
server.listen(4000);
```

### 4. Create *virtual* docroot directory

Every project for the Devilbox requires a `htdocs` directory present
inside the project dir. For a reverse proxy this is not of any use, but
rather only for the Intranet vhost page to stop complaining about the
missing `htdocs` directory. So that's why this is only a *virtual*
directory which will not hold any data.

``` bash
# Navigate to your project directory
devilbox@php-7.0.20 in /shared/httpd $ cd my-node

# Create the docroot directory
devilbox@php-7.0.20 in /shared/httpd/my-node $ mkdir htdocs
```

<div class="seealso">

`env-httpd-docroot-dir`

</div>

### 5. Add reverse proxy vhost-gen config files

#### 5.1 Create vhost-gen template directory

Before we can copy the vhost-gen templates, we must create the
`.devilbox` template directory inside the project directory.

``` bash
# Navigate to your project directory
devilbox@php-7.0.20 in /shared/httpd $ cd my-node

# Create the .devilbox template directory
devilbox@php-7.0.20 in /shared/httpd/my-node $ mkdir .devilbox
```

<div class="seealso">

`env-httpd-template-dir`

</div>

#### 5.2 Copy vhost-gen templates

Now we can copy and adjust the vhost-gen reverse proxy files for Apache
2.2, Apache 2.4 and Nginx.

The reverse vhost-gen templates are available in `cfg/vhost-gen`:

``` bash
host> tree -L 1 cfg/vhost-gen/

cfg/vhost-gen/
├── apache22.yml-example-rproxy
├── apache22.yml-example-vhost
├── apache24.yml-example-rproxy
├── apache24.yml-example-vhost
├── nginx.yml-example-rproxy
├── nginx.yml-example-vhost
└── README.md

0 directories, 7 files
```

For this example we will copy all `*-example-rproxy` files into
`/shared/httpd/my-node/.devilbox` to ensure this will work with all web
servers.

``` bash
host> cd /path/to/devilbox
host> cp cfg/vhost-gen/apache22.yml-example-rproxy data/www/my-node/.devilbox/apache22.yml
host> cp cfg/vhost-gen/apache24.yml-example-rproxy data/www/my-node/.devilbox/apache24.yml
host> cp cfg/vhost-gen/nginx.yml-example-rproxy data/www/my-node/.devilbox/nginx.yml
```

#### 5.3 Adjust ports

By default, all vhost-gen templates will forward requests to port `8000`
into the PHP container. Our current example however uses port `4000`, so
we must change that accordingly for all three templates.

##### 5.3.1 Adjust Apache 2.2 template

Open the `apache22.yml` vhost-gen template in your project:

``` bash
host> cd /path/to/devilbox
host> vi data/www/my-node/.devilbox/apache22.yml
```

Find the two lines with `ProxyPass` and `ProxyPassReverse` and change
the port from `8000` to `4000`

``` yaml
# ... more lines above ... #

###
### Basic vHost skeleton
###
vhost: |
  <VirtualHost __DEFAULT_VHOST__:__PORT__>
      ServerName   __VHOST_NAME__

      CustomLog  "__ACCESS_LOG__" combined
      ErrorLog   "__ERROR_LOG__"

      # Reverse Proxy definition (Ensure to adjust the port, currently '8000')
      ProxyRequests On
      ProxyPreserveHost On
      ProxyPass / http://php:4000/
      ProxyPassReverse / http://php:4000/

# ... more lines below ... #
```

##### 5.3.2 Adjust Apache 2.4 template

Open the `apache24.yml` vhost-gen template in your project:

``` bash
host> cd /path/to/devilbox
host> vi data/www/my-node/.devilbox/apache24.yml
```

Find the two lines with `ProxyPass` and `ProxyPassReverse` and change
the port from `8000` to `4000`

``` yaml
# ... more lines above ... #

###
### Basic vHost skeleton
###
vhost: |
  <VirtualHost __DEFAULT_VHOST__:__PORT__>
      ServerName   __VHOST_NAME__

      CustomLog  "__ACCESS_LOG__" combined
      ErrorLog   "__ERROR_LOG__"

      # Reverse Proxy definition (Ensure to adjust the port, currently '8000')
      ProxyRequests On
      ProxyPreserveHost On
      ProxyPass / http://php:4000/
      ProxyPassReverse / http://php:4000/

# ... more lines below ... #
```

##### 5.3.3 Adjust Nginx template

Open the `nginx.yml` vhost-gen template in your project:

``` bash
host> cd /path/to/devilbox
host> vi data/www/my-node/.devilbox/nginx.yml
```

Find the lines with `proxy-pass` and change the port from `8000` to
`4000`

``` yaml
# ... more lines above ... #

###
### Basic vHost skeleton
###
vhost: |
  server {
      listen       __PORT____DEFAULT_VHOST__;
      server_name  __VHOST_NAME__;

      access_log   "__ACCESS_LOG__" combined;
      error_log    "__ERROR_LOG__" warn;

      # Reverse Proxy definition (Ensure to adjust the port, currently '8000')
      location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_pass http://php:4000;
      }

# ... more lines below ... #
```

### 6. Create autostart script

For NodeJS applications, the Devilbox already bundles an autostart
template which you can use and simply just add the path of your NodeJS
application. This template does nothing by default as its file name does
not end by `.sh`. So let's have a look at the template from
`autostart/run-node-js-projects.sh-example`. The location where you will
have to add your path is highlighted:

<div class="literalinclude"
caption="autostart/run-node-js-projects.sh-example" language="bash"
emphasize-lines="15">

../../autostart/run-node-js-projects.sh-example

</div>

So in order to proceed copy this file inside the `autostart/` directory
of the Devilbox git directory to a new file ending by `.sh`

``` bash
host> cd /path/to/devilbox

# Navigate to the autostart directory
host> cd autostart

# Copy the template
host> cp run-node-js-projects.sh-example run-node-js-projects.sh

# Adjust the template and add your path:
host> vi run-node-js-projects.sh
```

``` bash
# ... more lines above ... #

# Add the full paths of your Nodejs projects startup files into this array
# Each project separated by a newline and enclosed in double quotes. (No commas!)
# Paths are internal paths inside the PHP container.
NODE_PROJECTS=(
    "/shared/httpd/my-node/js/index.js"
)

# ... more lines below ... #
```

<div class="seealso">

- `custom-scripts-per-php-version` (individually for different PHP
  versions)
- `custom-scripts-globally` (equal for all PHP versions)
- `autostarting-nodejs-apps`

</div>

### 7. DNS record

If you **have** Auto DNS configured already, you can skip this section,
because DNS entries will be available automatically by the bundled DNS
server.

If you **don't have** Auto DNS configured, you will need to add the
following line to your host operating systems `/etc/hosts` file (or
`C:\Windows\System32\drivers\etc` on Windows):

``` bash
127.0.0.1 my-node.loc
```

<div class="seealso">

- `howto-add-project-hosts-entry-on-mac`
- `howto-add-project-hosts-entry-on-win`
- `setup-auto-dns`

</div>

### 8. Restart the Devilbox

Now for those changes to take affect, you will have to restart the
Devilbox.

``` bash
host> cd /path/to/devilbox

# Stop the Devilbox
host> docker-compose down
host> docker-compose rm -f

# Start the Devilbox
host> docker-compose up -d php httpd bind
```

### 9. Open your browser

All set now, you can visit <http://my-node.loc> or <https://my-node.loc>
in your browser. The NodeJS application has been started up
automatically and the reverse proxy will direct all requests to it.

## Managing NodeJS

If you have never worked with
`tool pm2`, I suggest to visit
their website and get familiar with the available commands. A quick
guide is below:

``` bash
# Navigate to Devilbox git directory
host> cd /path/to/devilbox

# Enter the PHP container
host> ./shell.sh

# List your running NodeJS apps
devilbox@php-7.0.20 in /shared/httpd $ pm2 list

┌──────────┬────┬─────────┬──────┬──────┬────────┬─────────┬────────┬─────┬───────────┬──────────┬──────────┐
│ App name │ id │ version │ mode │ pid  │ status │ restart │ uptime │ cpu │ mem       │ user     │ watching │
├──────────┼────┼─────────┼──────┼──────┼────────┼─────────┼────────┼─────┼───────────┼──────────┼──────────┤
│ index    │ 0  │ N/A     │ fork │ 1906 │ online │ 0       │ 42h    │ 0%  │ 39.7 MB   │ devilbox │ disabled │
└──────────┴────┴─────────┴──────┴──────┴────────┴─────────┴────────┴─────┴───────────┴──────────┴──────────┘
```

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
