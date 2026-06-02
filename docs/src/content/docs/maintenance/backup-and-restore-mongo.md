---
title: "Backup and restore MongoDB"
---

# Backup and restore MongoDB

Backup and restore will be necessary when you are going to switch
MongoDB versions. Each version has its own data directory and is fully
indepentend of other versions. In case you want to switch to a different
version, but still want to have your MongoDB databases present, you must
first backup the databases of your current version and import them into
the new version.

There are multiple ways to backup and restore. Chose the one which is
most convenient for you.


## Backup

### mongodump

`tool mongodump` is
bundled with each PHP container and reay to use. To backup all databases
follow the below listed example:

``` bash
# Navigate to the Devilbox directory
host> cd path/to/devilbox

# Enter the PHP container
host> ./shell.sh

# Run mongodump
devilbox@php-7.1.6 in /shared/httpd $ mongodump --out /shared/backups/mongo
```

## Restore

### mongorestore

`tool mongorestore` is
bundled with each PHP container and ready to use. To restore all MongoDB
databases follow the below listed example:

``` bash
# Navigate to the Devilbox directory
host> cd path/to/devilbox

# Enter the PHP container
host> ./shell.sh

# Start the restore/import from /shared/backups/mongo
devilbox@php-7.1.6 in /shared/httpd $ mongorestore /shared/backups/mongo
```
