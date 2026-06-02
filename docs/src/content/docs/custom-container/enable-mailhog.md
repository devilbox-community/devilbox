---
title: "Enable and configure MailHog"
---

# Enable and configure MailHog

This section will guide you through getting MailHog integrated into the
Devilbox.

<div class="seealso">

\* `mailhog github` \*
`mailhog dockerhub` \*
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

### MailHog settings

In case of MailHog, the file is
`compose/docker-compose.override.yml-mailhog`. This file must be copied
into the root of the Devilbox git directory.

| What | How and where |
|----|----|
| Example compose file | `compose/docker-compose.override.yml-all` or `br` `compose/docker-compose.override.yml-mailhog` |
| Container IP address | `172.16.238.201` |
| Container host name | `mailhog` |
| Container name | `mailhog` |
| Mount points | none |
| Exposed port | `8025` (can be changed via `.env`) |
| Available at | `http://localhost:8025` |
| Further configuration | php.ini settings need to be applied per version |

### MailHog env variables

Additionally the following `.env` variables can be created for easy
configuration:

| Variable | Default value | Description |
|----|----|----|
| `HOST_PORT_MAILHOG` | `8025` | Controls the host port on which MailHog will be available at. |
| `MAILHOG_SERVER` | `latest` | Controls the MailHog version to use. |

## Instructions

### 1. Copy docker-compose.override.yml

Copy the MailHog Docker Compose overwrite file into the root of the
Devilbox git directory. (It must be at the same level as the default
`docker-compose.yml` file).

``` bash
host> cp compose/docker-compose.override.yml-mailhog docker-compose.override.yml
```

<div class="seealso">

\* `docker-compose-override-yml` \* `add-your-own-docker-image` \*
`overwrite-existing-docker-image`

</div>

### 2. Adjust PHP settings

The next step is to tell PHP that it should use a different mail
forwarder.

Let's assume you are using PHP 7.2.

``` bash
# Navigate to the PHP ini configuration directory of your chosen version
host> cd cfg/php-ini-7.2

# Create and open a new *.ini file
host> vi mailhog.ini
```

Add the following content to the newly created ini file:

``` ini
[mail function]
sendmail_path = '/usr/local/bin/mhsendmail --smtp-addr="mailhog:1025"'
```

<div class="seealso">

`php-ini`

</div>

### 3. Adjust `.env` settings (optional)

By Default MailHog is using the host port `8025`, this can be adjusted
in the `.env` file. Add `HOST_PORT__MAILHOG` to *.env* and customize its
value.

Additionally also the MailHog version can be controlled via
`MAILHOG_SERVER`.

``` bash
HOST_PORT_MAILHOG=8025
MAILHOG_SERVER=latest
```

<div class="seealso">

`env-file`

</div>

### 4. Start the Devilbox

The final step is to start the Devilbox with MailHog.

Let's assume you want to start `php`, `httpd`, `bind` and `mailhog`.

``` bash
host> docker-compose up -d php httpd bind mailhog
```

<div class="seealso">

`start-the-devilbox`

</div>

### 5. Start using it

- Once the Devilbox is running, visit <http://localhost:8025> in your
  browser.
- Any email send by any of the Devilbox managed projects will then
  appear in MailHog

## TL;DR

For the lazy readers, here are all commands required to get you started.
Simply copy and paste the following block into your terminal from the
root of your Devilbox git directory:

``` bash
# Copy compose-override.yml into place
cp compose/docker-compose.override.yml-mailhog docker-compose.override.yml

# Create php.ini
echo "[mail function]" > cfg/php-ini-7.2/mailhog.ini
echo "sendmail_path = '/usr/local/bin/mhsendmail --smtp-addr=\"mailhog:1025\"'" >> cfg/php-ini-7.2/mailhog.ini

# Create .env variable
echo "HOST_PORT_MAILHOG=8025" >> .env
echo "MAILHOG_SERVER=latest" >> .env

# Start container
docker-compose up -d php httpd bind mailhog
```
