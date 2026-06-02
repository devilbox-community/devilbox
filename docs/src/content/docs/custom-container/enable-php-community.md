---
title: "Enable and configure PHP Community"
---

# Enable and configure PHP Community

This section will guide you through getting PHP community images
integrated into the Devilbox.

<div class="seealso">

\*
`php community github`
\*
`php community dockerhub`
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

### PHP-FPM Community settings

In case of PHP-FPM Community, the file is
`compose/docker-compose.override.yml-php-community`. This file must be
copied into the root of the Devilbox git directory.

| What | How and where |
|----|----|
| Example compose file | `compose/docker-compose.override.yml-all` or `br` `compose/docker-compose.override.yml-php-community` |
| Container IP address | `172.16.238.10` |
| Container host name | `php` |
| Container name | `php` |
| Mount points | Same as default php image |
| Exposed port | Same as default php image |
| Available at | n.a. |
| Further configuration | `PHP_COMMUNITY_FLAVOUR` must be set via `.env` |

### PHP Community env variables

Additionally the following `.env` variables can be created for easy
configuration:

| Variable                | Default value | Description                         |
|-------------------------|---------------|-------------------------------------|
| `PHP_COMMUNITY_FLAVOUR` | `devilbox`    | Controls the PHP Community flavour. |

## Instructions

### 1. Copy docker-compose.override.yml

Copy the PHP-FPM Community Docker Compose overwrite file into the root
of the Devilbox git directory. (It must be at the same level as the
default `docker-compose.yml` file).

``` bash
host> cp compose/docker-compose.override.yml-php-community docker-compose.override.yml
```

<div class="seealso">

\* `docker-compose-override-yml` \* `add-your-own-docker-image` \*
`overwrite-existing-docker-image`

</div>

### 2. Adjust `env` settings

By default PHP-FPM Community is using the Devilbox reference flavour
`devilbox`. You can change this flavour via the `.env` variable
`PHP_COMMUNITY_FLAVOUR`.

``` bash
PHP_COMMUNITY_FLAVOUR=devilbox
```

<div class="seealso">

`env-file`

</div>

### 3. Start the Devilbox

The final step is to start the Devilbox with the newly added PHP-FPM
Community images.

Let's assume you want to start `php`, `httpd`, and `bind`.

``` bash
host> docker-compose up -d php httpd bind
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
cp compose/docker-compose.override.yml-php-community docker-compose.override.yml

# Set Community flavour
echo "PHP_COMMUNITY_FLAVOUR=devilbox" >> .env

# Start container
docker-compose up -d php httpd bind
```
