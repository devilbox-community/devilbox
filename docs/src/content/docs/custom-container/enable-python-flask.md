---
title: "Enable and configure Python Flask"
---

# Enable and configure Python Flask

This section will guide you through getting Python Flask integrated into
the Devilbox.

<div class="seealso">

\* `example-setup-reverse-proxy-python-flask` \*
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

### Python Flask settings

In case of Python Flask, the file is
`compose/docker-compose.override.yml-python-flask`. This file must be
copied into the root of the Devilbox git directory.

| What | How and where |
|----|----|
| Example compose file | `compose/docker-compose.override.yml-all` or `br` `compose/docker-compose.override.yml-python-flask` |
| Container IP address | `172.16.238.250` |
| Container host name | `flask1` |
| Container name | `flask1` |
| Mount points | `data/www`\` |
| Exposed port | none |
| Available at | Devilbox intranet via Reverse Proxy configuration |
| Further configuration | `example-setup-reverse-proxy-python-flask` |

### Python Flask env variables

Additionally the following `.env` variables can be created for easy
configuration:

| Variable | Default value | Description |
|----|----|----|
| `FLASK_PROJECT` | none | Specifies your Python Flask project dir in data/www. |
| `PYTHON_VERSION` | `3.8` | Specifies the Python version to use for Flask. |

## Instructions

### 1. Copy docker-compose.override.yml

Copy the Python Flask Docker Compose overwrite file into the root of the
Devilbox git directory. (It must be at the same level as the default
`docker-compose.yml` file).

``` bash
host> cp compose/docker-compose.override.yml-python-flask docker-compose.override.yml
```

<div class="seealso">

\* `docker-compose-override-yml` \* `add-your-own-docker-image` \*
`overwrite-existing-docker-image`

</div>

### 2. Adjust `.env` settings (optional)

Python Flask is using sane defaults, which can be changed by adding
variables to the `.env` file and assigning custom values.

Add the following variables to `.env` and adjust them to your needs:

``` bash
# Project directory in data/www
FLASK_PROJECT=my-flask

# Python version to choose
#PYTHON_VERSION=2.7
#PYTHON_VERSION=3.5
#PYTHON_VERSION=3.6
#PYTHON_VERSION=3.7
PYTHON_VERSION=3.8
```

<div class="seealso">

`env-file`

</div>

### 3. Configure Reverse Proxy

Before starting up the devilbox you will need to configure your python
flask project and the reverse proxy settings.

<div class="seealso">

`example-setup-reverse-proxy-python-flask`

</div>

## TL;DR

For the lazy readers, here are all commands required to get you started.
Simply copy and paste the following block into your terminal from the
root of your Devilbox git directory:

``` bash
# Copy compose-override.yml into place
cp compose/docker-compose.override.yml-flask1 docker-compose.override.yml

# Create .env variable
echo "# Project directory in data/www"   > .env
echo "FLASK_PROJECT=my-flask"           >> .env
echo "# Python version to choose"       >> .env
echo "#PYTHON_VERSION=2.7"              >> .env
echo "#PYTHON_VERSION=3.5"              >> .env
echo "#PYTHON_VERSION=3.6"              >> .env
echo "#PYTHON_VERSION=3.7"              >> .env
echo "PYTHON_VERSION=3.8"               >> .env
```

before starting up the devilbox you will need to configure your python
flask project and the reverse proxy settings.

<div class="seealso">

`example-setup-reverse-proxy-python-flask`

</div>
