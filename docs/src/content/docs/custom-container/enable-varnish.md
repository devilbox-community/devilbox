---
title: "Enable and configure Varnish"
---

# Enable and configure Varnish

This section will guide you through getting Varnish integrated into the
Devilbox.

As Varnish itself does not handle HTTPS, its Docker Compose override
definition also defines an optional HAProxy that can be started and run
in front of Varnish to provide HTTPS support and take care of the SSL
offloading before requests hit Varnish.

<div class="seealso">

\* `varnish github` \*
`varnish dockerhub` \*
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

### Stack settings

In case of Varnish, the file is
`compose/docker-compose.override.yml-varnish`. This file must be copied
into the root of the Devilbox git directory.

| What | How and where |
|----|----|
| Example compose file | `compose/docker-compose.override.yml-all` or `br` `compose/docker-compose.override.yml-varnish` |

#### Varnish

| What | How and where |
|----|----|
| Container IP address | `172.16.238.230` |
| Container host name | `varnish` |
| Container name | `varnish` |
| Mount points | none |
| Exposed port | `6081` (can be changed via `.env`) |
| Available at | `http://localhost:6081` (or via `http:<project>.<TLD>:6081`) |
| Further configuration | none |

#### HAProxy

| What | How and where |
|----|----|
| Container IP address | `172.16.238.231` |
| Container host name | `haproxy` |
| Container name | `haproxy` |
| Mount points | none |
| Exposed port | `8080` for HTTP and `8443` for HTTPS (can be changed via `.env`) |
| Available at | `http://localhost:8080`, `http://localhost:8443` (or via `http:<project>.<TLD>:8080|8443`) |
| Further configuration | none |

### Stack env variables

Additionally the following `.env` variables can be created for easy
configuration:

#### Varnish

| Variable | Default value | Description |
|----|----|----|
| `HOST_PORT_VARNISH` | `6081` | Controls the host port on which Varnish will be available at. |
| `VARNISH_SERVER` | `6` | Controls the Varnish version to use. |
| `VARNISH_CONFIG` | `/etc/varnish/default.vcl` | Path to Varnish configuration file (custom config can be mounted). |
| `VARNISH_CACHE_SIZE` | `128m` | Varnish Cache size. |
| `VARNISH_PARAMS` | `-p default_ttl=3600 -p default_grace=3600` | Additional Varnish startup parameter. |

#### HAProxy

| Variable | Default value | Description |
|----|----|----|
| `HOST_PORT_HAPROXY` | `8080` | Controls the host port on which HTTP requests will be available for HAProxy. |
| `HOST_PORT_HAPROXY_SSL` | `8443` | Controls the host port on which HTTPS requests will be available for HAProxy. |

## Instructions

### 1. Copy docker-compose.override.yml

Copy the Varnish Docker Compose overwrite file into the root of the
Devilbox git directory. (It must be at the same level as the default
`docker-compose.yml` file).

``` bash
host> cp compose/docker-compose.override.yml-varnish docker-compose.override.yml
```

<div class="seealso">

\* `docker-compose-override-yml` \* `add-your-own-docker-image` \*
`overwrite-existing-docker-image`

</div>

### 2. Adjust `.env` settings (optional)

Varnish and HAProxy are using sane defaults, which can be changed by
adding variables to the `.env` file and assigning custom values.

Add the following variables to `.env` and adjust them to your needs:

``` bash
# Varnish version to choose
#VARNISH_SERVER=4
#VARNISH_SERVER=5
VARNISH_SERVER=6

# Varnish settings
VARNISH_CONFIG=/etc/varnish/default.vcl
VARNISH_CACHE_SIZE=128m
VARNISH_PARAMS=-p default_ttl=3600 -p default_grace=3600
HOST_PORT_VARNISH=6081

# HAProxy settings
HOST_PORT_HAPROXY=8080
HOST_PORT_HAPROXY_SSL=8443
```

<div class="seealso">

`env-file`

</div>

### 3. Custom Varnish config (optional)

Varnish comes with a pretty generic default configuration that should
fit most frameworks or CMS's. If you do however want to provide your own
custom Varnish configuration, you can do so for each Varnish version
separately.

1.  Place any `*.vcl` files in to the Varnish configuration directories
    (found in `cfg/`).

``` bash
host> tree -L 1 cfg/ | grep varnish
├── varnish-4
├── varnish-5
├── varnish-6
```

2.  The `varnish-X/` directory will be mounted into `/etc/varnish.d/`
    into the running Varnish container
3.  Adjust the `VARNISH_CONFIG` variable to point to your custom Varnish
    config file.

#### 3.1 Example

For this example we will assume you are using Varnish 6

1.  Add `my-varnish.vcl` into `cfg/varnish-6/`
2.  Set `VARNISH_CONFIG` to `/etc/varnish.d/my-varnish.vcl`
3.  Ensure that the Backend server points to `httpd` in your custom
    varnish config
4.  Ensure that the Backend port points to `80` in your custom varnish
    config

### 4. Start the Devilbox

The final step is to start the Devilbox with Varnish.

<div class="seealso">

`start-the-devilbox`

</div>

#### 4.1 Varnish only

Let's assume you want to start `php`, `httpd`, `bind`, `varnish`.

``` bash
host> docker-compose up -d php httpd bind varnish
```

#### 4.2 HTTPS offloading with HAProxy in front of Varnish

If you also want full HTTPS support, simply start HAproxy as well with
Varnish.

``` bash
host> docker-compose up -d php httpd bind haproxy varnish
```

## TL;DR

For the lazy readers, here are all commands required to get you started.
Simply copy and paste the following block into your terminal from the
root of your Devilbox git directory:

``` bash
# Copy compose-override.yml into place
cp compose/docker-compose.override.yml-varnish docker-compose.override.yml

# Create .env variable
echo "# Varnish version to choose"                               >> .env
echo "#VARNISH_SERVER=4"                                         >> .env
echo "#VARNISH_SERVER=5"                                         >> .env
echo "VARNISH_SERVER=6"                                          >> .env
echo "# Varnish settings"                                        >> .env
echo "VARNISH_CONFIG=/etc/varnish/default.vcl"                   >> .env
echo "VARNISH_CACHE_SIZE=128m"                                   >> .env
echo "VARNISH_PARAMS=-p default_ttl=3600 -p default_grace=3600"  >> .env
echo "HOST_PORT_VARNISH=6081"                                    >> .env
echo "# HAProxy settings"                                        >> .env
echo "HOST_PORT_HAPROXY=8080"                                    >> .env
echo "HOST_PORT_HAPROXY_SSL=8443"                                >> .env

# Start container
docker-compose up -d php httpd bind varnish
```
