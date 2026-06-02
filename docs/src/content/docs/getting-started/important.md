---
title: "IMPORTANT"
---

# IMPORTANT

The following is a collection of important **do's and don'ts** you
should be aware of when starting to use the Devilbox and Docker in
general.


## Starting

### Do not run via `sudo` or `root`

Do not start the Devilbox with `sudo` or as `root` user. If it complains
about permissions when starting it with your normal system user, it is
probably due to the fact, that your user is not in the `docker` group.

<div class="seealso">

**Ensure you have read and done the following:**

- Add user to `docker` group: `prerequisites-docker-installation`
- Synronize file permissions: `install-the-devilbox-set-uid-and-gid`

</div>

> [!WARNING]
> If you start the Devilbox with `sudo` or as `root` user, it will most
> likely mess with your file permissions.

### Starting, Stopping and Restarting

Whenever you want to stop the Devilbox, change configuration and start
up again, do not forget to remove stopped container.

``` bash
# Stop the Devilbox
host> docker-compose stop

# Remove stopped container
host> docker-compose rm

# Start the Devilbox
host> docker-compose up
```

<div class="seealso">

`start-the-devilbox-stop-and-restart` (why do `docker-compose rm`?)

</div>

## Backups

Ensure to do regular database backups! Better safe then sorry!

<div class="seealso">

\* `backup-and-restore-mysql` \* `backup-and-restore-pgsql` \*
`backup-and-restore-mongo`

</div>
