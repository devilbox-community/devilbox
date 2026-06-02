---
title: "Virtual host vs Reverse Proxy"
---

# Virtual host vs Reverse Proxy

> [!NOTE]
> Ensure you have read `vhost-gen-virtual-host-templates`


## Motivation

By default, all virtual hosts will simply serve files located in your
document root directory within your project directory. Sometimes however
your *project* is already its own server that will serve requests
through a listening network port. (e.g. a running NodeJS application).
This listening port will however only be available inside the PHP
container (or any other container) you have added to the Devilbox and
the webserver is not aware of this.

For this kind of project you will want to create a reverse proxy which
simply forwards the requests incoming to the webserver to your
application (either to the PHP container to a specific port or to any
other container you have attached).

## Benefits

By using the already available web server to reverse proxy requests to
your service you will be able to have all the current features for you
application such as:

- Have it displayed in the intranet page
- Have standardized domain names
- Have valid HTTPS

## Creating a reverse proxy

Creating a reverse proxy is as simply as copying the `vhost-gen`
templates to your project directory.

In order to make your life simple there are a few generic docs that get
you started and let you know more about the theory behind it:

<div class="seealso">

- `reverse-proxy-with-https`
- `reverse-proxy-with-custom-docker`

</div>

If this is too generic you can also have a look at two specific examples
to setup fully automated Reverse Proxies including autostarting your
application on `docker-compose up`.

<div class="seealso">

- `example-setup-reverse-proxy-nodejs`
- `example-setup-reverse-proxy-sphinx-docs`

</div>
