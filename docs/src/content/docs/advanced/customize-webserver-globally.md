---
title: "Customize web server globally"
---

# Customize web server globally

Web server settings can be applied globally, which will affect the web
server behaviour itself, but not the vhost configuration. Configuration
can be done for each version separetely, which means each web server can
have its own profile of customized settings.

<div class="seealso">

In order to customize the vhosts, have a look at the following links:

- vhost-gen: `vhost-gen-virtual-host-templates`
- vhost-gen: `vhost-gen-customize-all-virtual-hosts-globally`
- vhost-gen: `vhost-gen-customize-specific-virtual-host`
- vhost-gen: `vhost-gen-example-add-sub-domains`

</div>


## Configure Apache

All settings that usually go into the main `httpd.conf` or
`apache2.conf` configuration file can be overwritten or customized
separately for Apache 2.2 and Apache 2.4.

<div class="seealso">

`apache-conf`

</div>

## Configure Nginx

All settings that usually go into the main `nginx.conf` configuration
file can be overwritten or customized separately for Nginx stable and
Nginx mainline.

<div class="seealso">

`nginx-conf`

</div>

## Devilbox specific settings

There are certain other settings that are directly managed by the
Devilbox's `.env` file in order to make other containers aware of those
settings.

> [!IMPORTANT]
> Try to avoid to overwrite the `.env` settings via web server
> configuration files.

Use the following `.env` variables to customize this behaviour globally.

<div class="seealso">

\* `env-tld-suffix` \* `env-host-port-httpd` \*
`env-host-port-httpd-ssl` \* `env-httpd-template-dir` \*
`env-httpd-docroot-dir`

</div>
