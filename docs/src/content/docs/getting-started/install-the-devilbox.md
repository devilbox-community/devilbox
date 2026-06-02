---
title: "Install the Devilbox"
---

# Install the Devilbox

> [!IMPORTANT]
> Ensure you have read and followed the `prerequisites`


## Download the Devilbox

The Devilbox does not need to be installed. The only thing that is
required is its git directory. To download that, open a terminal and
copy/paste the following command.

``` bash
host> git clone https://github.com/cytopia/devilbox
```

<div class="seealso">

- `howto-open-terminal-on-mac`
- `howto-open-terminal-on-win`
- `checkout-different-devilbox-release`

</div>

## Create `.env` file

Inside the cloned Devilbox git directory, you will find a file called
`env-example`. This file is the main configuration with sane defaults
for Docker Compose. In order to use it, it must be copied to a file
named `.env`. (Pay attention to the leading dot).

``` bash
host> cp env-example .env
```

The `.env` file does nothing else than providing environment variables
for Docker Compose and in this case it is used as the main configuration
file for the Devilbox by providing all kinds of settings (such as which
version to start up).

<div class="seealso">

\*
`docker compose env file`
\* `env-file`

</div>

## Set uid and gid

To get you started, there are only two variables that need to be
adjusted:

- `NEW_UID`
- `NEW_GID`

The values for those two variables refer to your local (on your host
operating system) user id and group id. To find out what the values are
required in your case, issue the following commands on a terminal:

### Find your user id

``` bash
host> id -u
```

### Find your group id

``` bash
host> id -g
```

In most cases both values will be `1000`, but for the sake of this
example, let's assume a value of `1001` for the user id and `1002` for
the group id.

Open the `.env` file with your favorite text editor and adjust those
values:

``` bash
host> vi .env

NEW_UID=1001
NEW_GID=1002
```

<div class="seealso">

\* `uid` \*
`howto-find-uid-and-gid-on-mac` \* `howto-find-uid-and-gid-on-win` \*
`syncronize-container-permissions`

</div>

## OS specific setup

### Linux: SELinux

If you have SELinux enabled, you will also have to adjust the
`env-mount-options` to allow shared mounts among multiple container:

``` bash
host> vi .env

MOUNT_OPTIONS=,z
```

<div class="seealso">

\* <https://github.com/cytopia/devilbox/issues/255> \*
`env-mount-options` \*
`docker selinux label`
\*
`docker mount z flag`

</div>

### OSX: Performance

Out of the box, Docker for Mac has some performance issues when it comes
to mount directories with a lot of files inside. To mitigate this issue,
you can adjust the caching settings for mounted directories.

To do so, you will want to adjust the `env-mount-options` to allow
caching on mounts.

``` bash
host> vi .env

MOUNT_OPTIONS=,cached
```

Ensure to read the links below to understand why this problem exists and
how the fix works. The Docker documentation will also give you
alternative caching options to consider.

<div class="seealso">

\* <https://github.com/cytopia/devilbox/issues/105> \*
<https://forums.docker.com/t/file-access-in-mounted-volumes-extremely-slow-cpu-bound/8076/281>
\* <https://docs.docker.com/docker-for-mac/osxfs/> \*
`env-mount-options`

</div>

## Checklist

1.  Devilbox is cloned
2.  `.env` file is created
3.  User and group id have been set in `.env` file

That's it, you have finished the first section and have a working
Devilbox ready to be started.

<div class="seealso">

`troubleshooting`

</div>
