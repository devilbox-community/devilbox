---
title: "Enter the PHP container"
---

# Enter the PHP container

Another core feature of the Devilbox, is to be totally independent of
what you have or have not installed on your host operating system.

The Devilbox already ships with many common developer tools which are
installed inside each PHP container, so why not make use of it.

The only thing you might need to install on your host operating system
is your favourite IDE or editor to actually start coding.

<div class="seealso">

If you want to find out what tools are available inside the PHP
container, visit the following section: `available-tools`.

</div>


## How to enter

> [!NOTE]
> You can only enter the PHP container if it is running.

### Linux and MacOS

On Linux and MacOS you can simply execute the provided shell script:
`shell.sh`. By doing so it will enter you into the PHP container and
bring you to `/shared/httpd`.

``` bash
# Execute on the host operating system
host> ./shell.sh

# Now you are inside the PHP Linux container
devilbox@php-7.0.19 in /shared/httpd $
```

### Windows

On Windows you have a different script to enter the PHP container:
`shell.bat`. Just run it and it will enter you into the PHP container
and bring you to `/shared/httpd`.

``` bash
# Execute on the host operating system
C:/Users/user1/devilbox> shell.bat

# Now you are inside the PHP Linux container
devilbox@php-7.0.19 in /shared/httpd $
```

## How to become root

When you enter the container with the provided scripts, you are doing so
as the user `devilbox`. If you do need to perform any actions as root
(such as installing new software), you can use the password-less `sudo`.

``` bash
# Inside the PHP Linux container as user devilbox
devilbox@php-7.0.19 in /shared/httpd $ sudo su -

# Now you are root and can do anything you want
root@php-7.0.19 in /shared/httpd $
```

> [!NOTE]
> As this action is inside a Docker container, there is no difference
> between Linux, MacOS or Windows. Every host operating system is using
> the same Docker container - equal accross all platforms.

## Tools

### What is available

There are lots of tools available, for a full overview see
`available-tools`. If you think you are missing a tool, install it
yourself as root, or open up an issue on github to get it backed into
the Docker image permanently.

<div class="seealso">

`available-tools`

</div>

### How to update them

There is no need to update the tools itself. All Docker images are
rebuilt every night and automatically pushed to Docker hub to ensure
versions are outdated at a maximum of 24 hours.

The only thing you have to do, is to update the Docker images itself,
simply by pulling a new version.

<div class="seealso">

`update-the-devilbox-update-the-docker-images`

</div>

## Advanced

This is just a short overview about the possibility to work inside the
container. If you want to dig deeper into this topic there is also a
more advanced tutorial available:

<div class="seealso">

`work-inside-the-php-container`

</div>

## Checklist

- You know how to enter the PHP container on Linux, MacOS or Windows
- You know how to become `root` inside the PHP container
- You know what tools are available inside the PHP container
- You know how to update the tools by pulling new versions of the Docker
  images

<div class="seealso">

`troubleshooting`

</div>
