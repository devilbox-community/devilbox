---
title: "Best practice"
---

# Best practice

If you have already operate the Devilbox, this guide is a must have. It
will cover common best-practice topics as well as some tips and tricks
you will want to apply.


## Move data out of Devilbox directory

One thing you should take into serious consideration is to move data
such as your projects as well as persistent data of databases out of the
Devilbox git directory.

The Devilbox git directory should be something that can be safely
deleted and re-created without having to worry about loosing any project
data. There could also be the case that you have a dedicated hard-disk
to store your projects or you have your own idea about a directory
structure where you want to store your projects.

Affected env variables to consider changing:

- `env-httpd-datadir`
- `env-host-path-backupdir`

### Projects

<div class="seealso">

\* `howto-move-projects-to-a-different-directory` Follow this guide to
keep your projects separated from the Devilbox git directory.

</div>

### Backups

<div class="seealso">

\* `howto-move-backups-to-a-different-directory` Follow this guide to
keep your backups separated from the Devilbox git directory.

</div>

### Version control `.env` file

The `.env` file is ignored by git, because this is *your* file to
customize and it should be *your* responsibility to make sure to backup
or version controlled.

One concept you can apply here is to have a separate **dotfiles** git
repository. This is a repository that holds all of your configuration
files such as vim, bash, zsh, xinit and many more. Those files are
usually stored inside this repository and then symlinked to the correct
location. By having all configuration files in one place, you can see
and track changes easily as well as bein able to jump back to previous
configurations.

In case of the Devilbox `.env` file, just store this file in your
repository and symlink it to the Devilbox git directiry. This way you
make sure that you keep your file, even when the Devilbox git directory
is deleted and you also have a means of keeping track about changes you
made.

You could also go further and have several `.env` files available
somewhere. Each of those files holds different configurations e.g. for
different projects or customers.

- `env-customer1`
- `env-php55`
- `env-project3`

You would then simply symlink one of those files to the Devilbox git
directory.

### Version control service config files

<div class="todo">

This will require some changes on the Devilbox and will be implemented
shortly.

</div>

- Symlink and have your own git directory
- Separate data partition, backups

## PHP project hostname settings

When configuring your PHP projects to use MySQL, PostgreSQL, Redis,
Mongo and other services, make sure to set the hostname/address of each
of those services to how they are defined within the Devilbox network:

| Container                 | Name  | Hostname | IP Address     |
|---------------------------|-------|----------|----------------|
| DNS                       | bind  | bind     | 172.16.238.100 |
| PHP                       | php   | php      | 172.16.238.10  |
| Apache, Nginx             | httpd | httpd    | 172.16.238.11  |
| MySQL, MariaDB, PerconaDB | mysql | mysql    | 172.16.238.12  |
| PostgreSQL                | pgsql | pgsql    | 172.16.238.13  |
| Redis                     | redis | redis    | 172.16.238.14  |
| Memcached                 | memcd | memcd    | 172.16.238.15  |
| MongoDB                   | mongo | mongo    | 172.16.238.16  |

As an example, if you want to access the MySQL database from within the
PHP container, you do the following:

``` bash
# Navigate to Devilbox git directory
host> cd path/to/devilbox

# Enter the PHP container
host> ./shell.sh

# Enter the MySQL console
php> mysql -u root -h mysql -p
mysql>
```

To access the MySQL database from your host operating system you would
need the address to what it exposes to on your host (usually
`127.0.0.1`):

``` bash
# Enter the MySQL console
host> mysql -u root -h 127.0.0.1 -p
mysql>
```

Any of your projects php files that configure MySQL as an example should
point the hostname or IP address of the MySQL server to `mysql`:

``` php
<?php
// MySQL server connection in your project configuration
mysql_host = 'mysql';
mysql_port = '3306';
mysql_user = 'someusername';
mysql_pass = 'somepassword';
?>
```

<div class="seealso">

`work-inside-the-php-container`

</div>

## Timezone

The `env-timezone` value will affect PHP and web serverequally. It does
however not affect any other official Docker container that are used
within the Devilbox. This is an issue that is currently still being
worked on.

Feel free to change this to any timezone you require for PHP, but keep
in mind that timezone values for databases can be painful, once you want
to switch to a different timezone.

A good practice is to always use `UTC` on databases and have your
front-end application calculate the correct time for the user. This way
you will be more independent of any changes.
