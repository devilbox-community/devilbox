---
title: "Enable and configure Ngrok"
---

# Enable and configure Ngrok

This section will guide you through getting Ngrok integrated into the
Devilbox.

<div class="seealso">

\* `ngrok github` \*
`ngrok dockerhub` \*
`custom-container-enable-all-additional-container` \*
`docker-compose-override-yml-how-does-it-work`

</div>


## Overview

### Available overwrites

The Devilbox ships various example configurations to overwrite the
default stack. Those files are located under `compose/` in the Devilbox
git directory.

`docker-compose.override.yml-all` has all examples combined in one file
for easy copy/paste. However, each example also exists in its standalone
file as shown below:

``` bash
host> tree -L 1 compose/
compose/
├── docker-compose.override.yml-all
├── docker-compose.override.yml-blackfire
├── docker-compose.override.yml-elk
├── docker-compose.override.yml-mailhog
├── docker-compose.override.yml-meilisearch
├── docker-compose.override.yml-ngrok
├── docker-compose.override.yml-php-community
├── docker-compose.override.yml-python-flask
├── docker-compose.override.yml-rabbitmq
├── docker-compose.override.yml-solr
├── docker-compose.override.yml-varnish
└── README.md

0 directories, 10 files
```

<div class="seealso">

`custom-container-enable-all-additional-container`

</div>

### Ngrok settings

In case of Ngrok, the file is
`compose/docker-compose.override.yml-ngrok`. This file must be copied
into the root of the Devilbox git directory.

| What | How and where |
|----|----|
| Example compose file | `compose/docker-compose.override.yml-all` or `br` `compose/docker-compose.override.yml-ngrok` |
| Container IP address | `172.16.238.202` |
| Container host name | `ngrok` |
| Container name | `ngrok` |
| Mount points | none |
| Exposed port | `4040` (can be changed via `.env`) |
| Available at | `http://localhost:4040` |
| Further configuration | `NGROK_HTTP_TUNNELS`, `NGROK_AUTHTOKEN` and `NGROK_REGION` |

### Ngrok env variables

Additionally the following `.env` variables can be created for easy
configuration:

| Variable | Default value | Description |
|----|----|----|
| `HOST_PORT_NGROK` | `4040` | Controls the host port on which Ngrok admin UI will be available at. |
| `NGROK_HTTP_TUNNELS` | `httpd:httpd:80` | Defines one or more Ngrok tunnels (depending on your license) |
| `NGROK_AUTHTOKEN` | empty | Free or paid license token for Ngrok (can also be empty) |
| `NGROK_REGION` | `us` | Choose the region where the ngrok client will connect to host its tunnels. |

#### NGROK_HTTP_TUNNELS

Ngrok tunnel definitions can be in the form of:

- `<domain.tld>:<addr>:<port>`
- `<domain1.tld>:<addr>:<port>,<domain2.tld>:<addr>:<port>`

> [!NOTE]
> If you don't use a license you can only specify a single tunnel. If
> your license is pro enough, you can have multiple comma separated
> tunnels.

- `<domain.tld>` is the virtual hostname that you want to serve via
  Ngrok
- `<addr>` is the hostname or IP address of the web server
- `<port>` is the port on which the web server is reachable via HTTP

``` bash
# Make vhost "project1.loc" which runs on localhost:8080 available
HTTP_TUNNELS=project1.loc:localhost:8080

# Make two vhosts available which run on host apache:80
HTTP_TUNNELS=project1.loc:apache:80,project2.loc:apache:80

# Make two vhosts from two different web server addresses available
HTTP_TUNNELS=project1.loc:localhost:8080,project2.loc:apache:80
```

## Instructions

### 1. Copy docker-compose.override.yml

Copy the Ngrok Docker Compose overwrite file into the root of the
Devilbox git directory. (It must be at the same level as the default
`docker-compose.yml` file).

``` bash
host> cp compose/docker-compose.override.yml-ngrok docker-compose.override.yml
```

<div class="seealso">

\* `docker-compose-override-yml` \* `add-your-own-docker-image` \*
`overwrite-existing-docker-image`

</div>

### 2. Adjust `.env` settings (optional)

By Default Ngrok will forward the `httpd` domain, which is represents
the default virtual host (the Devilbox intranet) to your web server
(also named `httpd`) and makes the admin UI available on port `4040` on
your local machine.

You can of course change the domain as well as where to forward it to
(e.g.: to Varnish or HAProxy instead).

Additionally you can also specify a license token in order to allow for
more tunnels via `NGROK_AUTHTOKEN`.

``` bash
HOST_PORT_NGROK=4040
# Share project1.loca over the internet
NGROK_HTTP_TUNNELS=project1.loc:httpd:80
# No license token specified
NGROK_AUTHTOKEN=
```

<div class="seealso">

`env-file`

</div>

### 3. Start the Devilbox

The final step is to start the Devilbox with Ngrok.

Let's assume you want to start `php`, `httpd`, `bind` and `ngrok`.

``` bash
host> docker-compose up -d php httpd bind ngrok
```

<div class="seealso">

`start-the-devilbox`

</div>

### 4. Start using it

- Once the Devilbox is running, visit <http://localhost:4040> in your
  browser.
- Get URL for public available project

## TL;DR

For the lazy readers, here are all commands required to get you started.
Simply copy and paste the following block into your terminal from the
root of your Devilbox git directory:

``` bash
# Copy compose-override.yml into place
cp compose/docker-compose.override.yml-ngrok docker-compose.override.yml

# Create .env variable
echo "HOST_PORT_NGROK=4040"                      >> .env
echo "# Share project1.loca over the internet"   >> .env
echo "NGROK_HTTP_TUNNELS=project1.loc:httpd:80"  >> .env
echo "# No license token specified"              >> .env
echo "NGROK_AUTHTOKEN="                          >> .env
echo "NGROK_REGION=us"                           >> .env

# Start container
docker-compose up -d php httpd bind ngrok
```
