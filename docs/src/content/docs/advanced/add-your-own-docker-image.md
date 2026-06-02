---
title: "Add your own Docker image"
---

# Add your own Docker image

This section is all about customizing the Devilbox and its Docker images
specifically to your needs.


## Prerequisites

The new Docker image definition will be added to a file called
`docker-compose.override.yml`. So before going any further, read the
following section that shows you how to create this file for the
Devilbox as well as what pitfalls to watch out for.

<div class="seealso">

`docker-compose-override-yml`

</div>

## What information do you need?

1.  `<name>` - A name, which you can use to refer in the
    `docker-compose` command
2.  `<image-name>` - The Docker image name itself
3.  `<image-version>` - The Docker image tag
4.  `<unused-ip-address>` - An unused IP address from the devilbox
    network (found inside `docker-compose.yml`)

## How to add a new service?

### Generic example

#### A single new service

Open `docker-compose.override.yml` with your favourite editor and paste
the following snippets into it.

``` yaml
version: '2.1'
services:
  # Your custom Docker image here:
  <name>:
    image: <image-name>:<image-version>
    networks:
      app_net:
        ipv4_address: <unused-ip-address>
    # For ease of use always automatically start these:
    depends_on:
      - bind
      - php
      - httpd
  # End of custom Docker image
```

> [!NOTE]
> \* `<name>` has to be replaced with any name of your choice \*
> `<image-name>` has to be replaced with the name of the Docker image \*
> `<image-version>` has to be replaced with the tag of the Docker image
> \* `<unused-ip-address>` has to be replaced with an unused IP address

#### Two new services

``` yaml
version: '2.1'
services:
  # Your first custom Docker image here:
  <name1>:
    image: <image1-name>:<image1-version>
    networks:
      app_net:
        ipv4_address: <unused-ip-address1>
    # For ease of use always automatically start these:
    depends_on:
      - bind
      - php
      - httpd
  # End of first custom Docker image
  # Your second custom Docker image here:
  <name2>:
    image: <image2-name>:<image2-version>
    networks:
      app_net:
        ipv4_address: <unused-ip-address2>
    # For ease of use always automatically start these:
    depends_on:
      - bind
      - php
      - httpd
  # End of second custom Docker image
```

> [!NOTE]
> \* `<name1>` has to be replaced with any name of your choice \*
> `<image1-name>` has to be replaced with the name of the Docker image
> \* `<image1-version>` has to be replaced with the tag of the Docker
> image \* `<unused-ip-address1>` has to be replaced with an unused IP
> address

> [!NOTE]
> \* `<name2>` has to be replaced with any name of your choice \*
> `<image2-name>` has to be replaced with the name of the Docker image
> \* `<image2-version>` has to be replaced with the tag of the Docker
> image \* `<unused-ip-address2>` has to be replaced with an unused IP
> address

### CockroachDB example

Gather the requirements for the
`docker image cockroach`
Docker image:

1.  Name: `cockroach`
2.  Image: `cockroachdb/cockroach`
3.  Tag: `latest`
4.  IP: `172.16.238.240`

Now add the information to `docker-compose.override.yml`:

``` yaml
version: '2.1'
services:
  # Your custom Docker image here:
  cockroach:
    image: cockroachdb/cockroach:latest
    command: start --insecure
    networks:
      app_net:
        ipv4_address: 172.16.238.240
    # For ease of use always automatically start these:
    depends_on:
      - bind
      - php
      - httpd
  # End of custom Docker image
```

## How to start the new service?

The following will bring up your service including all of its dependent
services, as defined with `depends-on` (bind, php and httpd). You need
to replace `<name>` with the name you have chosen.

``` bash
host> docker-compose up <name>
```

In the example of Cockroach DB the command would look like this

``` bash
host> docker-compose up cockroach
```

## Further reading

<div class="seealso">

\* `docker-compose-override-yml` \* `overwrite-existing-docker-image`

</div>
