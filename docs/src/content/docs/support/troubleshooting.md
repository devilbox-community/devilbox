---
title: "Troubleshooting"
---

# Troubleshooting

This section will contain common problems and how to resolve them. It
will grow over time once there are more issues reported.

<div class="seealso">

\* `howto` \* `faq`

</div>

> [!IMPORTANT]
> `update-the-devilbox`  
> Issues are constantly being fixed. Before attempting to spend too much
> time digging into your issue, make sure you are running the latest git
> changes and have pulled the latest Docker images.
>
> Also keep in mind that configuration files might change, so ensure to
> diff the default ones against your currently active ones for added,
> removed or changed values.


## What to always do first

Before going into the issues below, always do the following

**1. Ensure stopped container are removed**

> ``` bash
> # Ensure everything is stopped
> host> docker-compose stop
> host> docker-compose kill
> host> docker-compose rm -f
> ```

**2. Ensure config is normalized**

> ``` bash
> # Ensure .env file is normalized
> host> cp env-example .env
> ```

**3. Statup minimal**

> ``` bash
> # Test everything with the minimal stack
> host> docker-compose up php httpd bind
> ```

**4. Run config checker**

> ``` bash
> # Run the bash script in the Devilbox git directory
> host> ./check-config.sh
> ```

## General

### Sudden unexplained problems on Windows

In case something stopped working for no reason, check out other Docker
container. If you experience similar issues as well, check for any
unattended Windows updates or updates to Docker itself. If those exist,
try to revert them and see if that was the cause.

I heard many bug stories from fellow Windows users so far. A good
contact point for that is the Docker forum itself:
<https://forums.docker.com/c/docker-desktop-for-windows>

A few general things you should always do before attempting to open up
issues are:

**1. Used default settings from env-example**

> Try using the exact settings from `env-example` as variables might
> have been updated in git.
>
> ``` bash
> # Ensure everything is stopped
> host> cp env-example .env
> ```

**2. Clean, updated and minimal start**

> ``` bash
> # Ensure everything is stopped
> host> docker-compose stop
> host> docker-compose kill
> host> docker-compose rm -f
>
> # Ensure everything is updated
> host> docker-compose pull
>
> # Start again
> host> docker-compose up php httpd bind
> ```

**3. Reset Docker credentials:**

> As it might sound strange, this fix might indeed solve a lot of
> problems on Windows. Go to your Docker settings and reset your
> credentials.

**4. Shared volumes:**

> Ensure all your Devilbox data (Devilbox directory and project
> directory) are within the volumes that are shared by Docker. If not
> add those in the Docker settings.

### No Space left on Device

If on Docker for Mac you get an error during docker pull similar to the
following one:

``` bash
write /var/lib/docker/tmp/GetImageBlob220119603: no space left on device
```

It means the file where MacOS stores the docker images is full. The
usual way is to delete unused images and volumes to free up space or
increase this volumes size.

However, depending on the version of Docker some of the above
suggestions may not work and you have to get support from the
docker/for-mac GitHub repository or forum.

<div class="seealso">

\* <https://github.com/cytopia/devilbox/issues/539> \*
<https://github.com/docker/for-mac/issues/371> \*
<https://forums.docker.com/t/no-space-left-on-device-error/10894>

</div>

### Address already in use

One of the Docker container wants to bind to a port on the host system
which is already taken. Figure out what service is listening on your
host system and shut it down or change the port of the affected service
in the Devilbox `.env` file.

Some examples of common error messages:

``` bash
Error starting userland proxy: Bind for 0.0.0.0:80: unexpected error (Failure EADDRINUSE)
```

### Unable to finish Pulling as unauthorized: incorrect username or password

This error might occur if you are already logged into a different Docker
repository. To fix this error, sign out of your currently logged in
repository and try again.

<div class="seealso">

<https://github.com/cytopia/devilbox/issues/223>

</div>

### localhost or 127.0.0.1 not found

If you are using Docker Toolbox, the Devilbox intranet is not available
on localhost or 127.0.0.1, but rather on the IP address of the Docker
Toolbox machine.

<div class="seealso">

`howto-find-docker-toolbox-ip-address`

</div>

### ERROR: Version in "./docker-compose.yml" is unsupported

This simply means your Docker and/or Docker Compose versions are
outdated.

<div class="seealso">

`prerequisites`

</div>

## Performance

### Performance issues on Docker for Mac

By default Docker for Mac has performance issues on mounted directories
with a lot of files inside. To overcome this issue you can apply
different kinds of caching options to the mount points.

<div class="seealso">

\* `install-the-devilbox-osx-performance` \* `env-mount-options`

</div>

## DNS issues

### zone 'localhost': already exists previous definition

``` bash
bind_1 | /etc/bind/devilbox-wildcard_dns.localhost.conf:1:
zone 'localhost': already exists previous definition:
/etc/bind/named.conf.default-zones:10
```

This error occurs when using `localhost` as the `env-tld-suffix`.

<div class="seealso">

- `env-tld-suffix`
- <https://github.com/cytopia/devilbox/issues/291>

</div>

## SSL issues

### unable to get local issuer certificate

``` bash
Errors occurred when trying to connect to www.example.com:
cURL error 77: error setting certificate verify locations: CAfile: certificate ./ca/cacert.pem CApath: /etc/ssl/certs
```

This issue might arise if you set `env-tld-suffix` to an official top
level domain such as `.com`. What happens is that the bundled DNS server
does a catch-all on the TLD and redirects all name resolution to the
Devilbox's PHP container IP address.

If you want to access `https://www.example.com` in that case, the
request goes to the PHP container which does not have a valid SSL
certificate for that domain.

**Do not user official TLD's** for `env-tld-suffix`.

<div class="seealso">

- `env-tld-suffix`
- <https://github.com/cytopia/devilbox/issues/275>

</div>

## Web server issues

### Warning: DocumentRoot \[/var/www/default/htdocs/\] does not exist

This error is most likely to only occur on Docker for Windows and is
just a result of not working volumes mounts.

<div class="seealso">

<https://forums.docker.com/t/volume-mounts-in-windows-does-not-work/10693>

</div>

### 403 forbidden

This error might occur for the Devilbox intranet or custom created
projects.

#### File and directory permissions

On of the cause could be wrongly set file and directory permissions.

First ensure the cloned git directory is readable for users, groups and
others.

For the Devilbox intranet, ensure the `.devilbox/` directory is readable
for users, groups and others. Also check files and directories within.

For projects, ensure an `index.php` or `index.html` exists and that all
files and directories are readable for users, groups and others.

#### Shared volumes

This might additionally occur on MacOS or Windows due to the Devilbox
and/or its projects not being in the standard location of Docker Shared
volumes.

Check your Docker settings to allow shared volumes for the path of the
Devilbox and its projects.

### 504 Gateway timeout

This error occurs when the upstream PHP-FPM server takes longer to
execute a script, than the timeout value set in the web server for
PHP-FPM to answer.

For that to fix one must increase the PHP-FPM/Proxy timeout settings in
the `.env` file. `env-httpd-timeout-to-php-fpm`

<div class="seealso">

- `env-httpd-timeout-to-php-fpm`
- <https://github.com/cytopia/devilbox/issues/280>
- <https://github.com/cytopia/devilbox/issues/234>

</div>

## PHP issues

### Fatal error: Cannot redeclare go()

If you encounter this error, it is most likely that your current project
declares the PHP function `go()` and that you have enabled the `swoole`
module which also provides an implementation of that function.

To mitigate that issue, make sure that the `swoole` module is disabled
in `.env`.

<div class="seealso">

- `env-file-php-modules-disable`
- <https://github.com/getkirby/kirby/issues/643>

</div>

## Database issues

### SQLSTATE\[HY000\] \[1130\] Host '172.16.238.10' is not allowed to connect to this MariaDB server

<div class="seealso">

`troubleshooting-cant-connect-to-mysql-adter-restart`

</div>

### Cannot connect to MySQL after restart

This error usually occurs when you import a MySQL dump including the
mysql database itself, which will overwrite the user permissions and
thus you won't be able to connect anymore with the settings specified in
`.env`.

<div class="seealso">

<https://github.com/cytopia/devilbox/issues/542>

</div>

### Invalid bind mount spec

This error might occure after changing the path of MySQL, PgSQL, Mongo
or any other data directory.

When you change any paths inside `.env` that affect Docker mountpoints,
the container need to be removed and re-created during the next startup.
Removing the container is sufficient as they will always be created
during run if they don't exist.

In order to remove the container do the following:

``` bash
host> cd path/to/devilbox
host> docker-compose stop

# Remove the stopped container (IMPORTANT!)
# After the removal it will be re-created during next run
host> docker-compose rm -f
```

<div class="seealso">

`remove-stopped-container`

</div>

### \[Warning\] World-writable config file '/etc/mysql/docker-default.d/my.cnf' is ignored

This warning might occur when using
`howto-docker-toolbox-and-the-devilbox` on Windows and trying to apply
custom MySQL configuration files. This will also result in the
configuration file not being source by the MySQL server.

To fix this issue, you will have to change the file permission of your
custom configuration files to read-only by applying the following
`chmod` command.

``` bash
# Nagivate to devilbox git directory
host> cd path/to/devilbox

# Navigate to the MySQL config directory (e.g.: MySQL 5.5)
host> cd cfg/mysql-5.5

# Make cnf files read only
host> chmod 0444 *.cnf
```

<div class="seealso">

\* `my-cnf` \* <https://github.com/cytopia/devilbox/issues/212>

</div>

### \[MariaDB\] Assertion failure when executing prepared statement with ? in IN list

Some MariaDB versions are affected by MDEV-27937 bug, use a fixed
version or set in_predicate_conversion_threshold variable to a higher
value.

<div class="seealso">

<https://jira.mariadb.org/browse/MDEV-27937>

</div>

## Docker Toolbox

### ln: creating symbolic link './foo': Read-only file system

VirtualBox might not allow symlinks by default on other directories.
This can however be fixed manually via.

``` bash
# <DIR> is the VirtualBox shared directory
host> VBoxManage setextradata default VBoxInternal2/SharedFoldersEnableSymlinksCreate/<DIR> 1
```

<div class="seealso">

For detailed example see here:

- Docker Toolbox on Windows:
  `howto-docker-toolbox-and-the-devilbox-windows-symlinks`

</div>
