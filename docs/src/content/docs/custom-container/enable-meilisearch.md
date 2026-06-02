---
title: "Enable and configure Meilisearch"
---

# Enable and configure Meilisearch

This section will guide you through getting Meilisearch integrated into
the Devilbox.

<div class="seealso">

\*
`meilisearch github`
\*
`meilisearch dockerhub`
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

### Meilisearch settings

In case of Meilisearch, the file is
`compose/docker-compose.override.yml-meilisearch`. This file must be
copied into the root of the Devilbox git directory.

| What | How and where |
|----|----|
| Example compose file | `compose/docker-compose.override.yml-all` or `br` `compose/docker-compose.override.yml-meilisearch` |
| Container IP address | `172.16.238.203` |
| Container host name | `meilisearch` |
| Container name | `meilisearch` |
| Mount points | via Docker volumes |
| Exposed port | `7700` (can be changed via `.env`) |
| Available at | `http://localhost:7700` (API and Admin WebUI) |
| Further configuration | none |

### Meilisearch env variables

Additionally the following `.env` variables can be created for easy
configuration:

| Variable | Default value | Description |
|----|----|----|
| `HOST_PORT_MEILI` | `7700` | Controls the host port on which Meilisearch API and WebUI will be available at. |
| `MEILI_SERVER` | `latest` | Controls the Meilisearch version to use. |
| `MEILI_MASTER_KEY` | none | Default Meilisearch master key. |

## Instructions

### 1. Copy docker-compose.override.yml

Copy the Meilisearch Docker Compose overwrite file into the root of the
Devilbox git directory. (It must be at the same level as the default
`docker-compose.yml` file).

``` bash
host> cp compose/docker-compose.override.yml-meilisearch docker-compose.override.yml
```

<div class="seealso">

\* `docker-compose-override-yml` \* `add-your-own-docker-image` \*
`overwrite-existing-docker-image`

</div>

### 2. Adjust `.env` settings (optional)

Meilisearch is using sane defaults, which can be changed by adding
variables to the `.env` file and assigning custom values.

Add the following variables to `.env` and adjust them to your needs:

``` bash
# Meilisearch version to choose
#MEILI_SERVER=v0.26.0
#MEILI_SERVER=v0.27.0
#MEILI_SERVER=v0.28
MEILI_SERVER=latest

MEILI_MASTER_KEY=
HOST_PORT_MEILI=7700
```

<div class="seealso">

`env-file`

</div>

### 3. Start the Devilbox

The final step is to start the Devilbox with Meilisearch.

Let's assume you want to start `php`, `httpd`, `bind`, `meilisearch`.

``` bash
host> docker-compose up -d php httpd bind meilisearch
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
cp compose/docker-compose.override.yml-meilisearch docker-compose.override.yml

# Create .env variable
echo "# Meilisearch version to choose"   >> .env
echo "#MEILI_SERVER=v0.26.0"             >> .env
echo "#MEILI_SERVER=v0.27.0"             >> .env
echo "#MEILI_SERVER=v0.28"               >> .env
echo "MEILI_SERVER=latest"               >> .env
echo "MEILI_MASTER_KEY="                 >> .env
echo "HOST_PORT_MEILI=7700"              >> .env

# Start container
docker-compose up -d php httpd bind meilisearch
```
