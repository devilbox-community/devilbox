---
title: "Enable and configure RabbitMQ"
---

# Enable and configure RabbitMQ

This section will guide you through getting RabbitMQ integrated into the
Devilbox.

<div class="seealso">

\* `rabbitmq github` \*
`rabbitmq dockerhub`
\* `custom-container-enable-all-additional-container` \*
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

### RabbitMQ settings

In case of RabbitMQ, the file is
`compose/docker-compose.override.yml-rabbitmq`. This file must be copied
into the root of the Devilbox git directory.

| What | How and where |
|----|----|
| Example compose file | `compose/docker-compose.override.yml-all` or `br` `compose/docker-compose.override.yml-rabbitmq` |
| Container IP address | `172.16.238.210` |
| Container host name | `rabbit` |
| Container name | `rabbit` |
| Mount points | via Docker volumes |
| Exposed port | `5672` and `15672` (can be changed via `.env`) |
| Available at | `http://localhost:15672` (Admin WebUI) |
| Further configuration | none |

### RabbitMQ env variables

Additionally the following `.env` variables can be created for easy
configuration:

| Variable | Default value | Description |
|----|----|----|
| `HOST_PORT_RABBIT` | `5672` | Controls the host port on which RabbitMQ API will be available at. |
| `HOST_PORT_RABBIT_MGMT` | `15672` | Controls the host port on which RabbitMQ Admin WebUI will be available at. |
| `RABBIT_SERVER` | `management` | Controls the RabbitMQ version to use. |
| `RABBIT_DEFAULT_VHOST` | `my-vhost` | Default RabbitMQ vhost name. (not a webserver vhost name) |
| `RABBIT_DEFAULT_USER` | `guest` | Default username for Admin WebUI. |
| `RABBIT_DEFAULT_PASS` | `guest` | Default password for Admin WebUI. |

## Instructions

### 1. Copy docker-compose.override.yml

Copy the RabbitMQ Docker Compose overwrite file into the root of the
Devilbox git directory. (It must be at the same level as the default
`docker-compose.yml` file).

``` bash
host> cp compose/docker-compose.override.yml-rabbitmq docker-compose.override.yml
```

<div class="seealso">

\* `docker-compose-override-yml` \* `add-your-own-docker-image` \*
`overwrite-existing-docker-image`

</div>

### 2. Adjust `.env` settings (optional)

RabbitMQ is using sane defaults, which can be changed by adding
variables to the `.env` file and assigning custom values.

Add the following variables to `.env` and adjust them to your needs:

``` bash
# RabbitMQ version to choose
#RABBIT_SERVER=3.6
#RABBIT_SERVER=3.6-management
#RABBIT_SERVER=3.7
#RABBIT_SERVER=3.7-management
#RABBIT_SERVER=latest
RABBIT_SERVER=management

RABBIT_DEFAULT_VHOST=my_vhost
RABBIT_DEFAULT_USER=guest
RABBIT_DEFAULT_PASS=guest

HOST_PORT_RABBIT=5672
HOST_PORT_RABBIT_MGMT=15672
```

<div class="seealso">

`env-file`

</div>

### 3. Start the Devilbox

The final step is to start the Devilbox with RabbitMQ.

Let's assume you want to start `php`, `httpd`, `bind`, `rabbit`.

``` bash
host> docker-compose up -d php httpd bind rabbit
```

<div class="seealso">

`start-the-devilbox`

</div>

## TL;DR

For the lazy readers, here are all commands required to get you started.
Simply copy and paste the following block into your terminal from the
root of your Devilbox git directory:

``` bash
# Copy compose-override.yml into place
cp compose/docker-compose.override.yml-rabbitmq docker-compose.override.yml

# Create .env variable
echo "# RabbitMQ version to choose"           >> .env
echo "#RABBIT_SERVER=3.6"                     >> .env
echo "#RABBIT_SERVER=3.6-management"          >> .env
echo "#RABBIT_SERVER=3.7"                     >> .env
echo "#RABBIT_SERVER=3.7-management"          >> .env
echo "#RABBIT_SERVER=latest"                  >> .env
echo "RABBIT_SERVER=management"               >> .env
echo "RABBIT_DEFAULT_VHOST=my_vhost"          >> .env
echo "RABBIT_DEFAULT_USER=guest"              >> .env
echo "RABBIT_DEFAULT_PASS=guest"              >> .env
echo "HOST_PORT_RABBIT=5672"                  >> .env
echo "HOST_PORT_RABBIT_MGMT=15672"            >> .env

# Start container
docker-compose up -d php httpd bind rabbit
```
