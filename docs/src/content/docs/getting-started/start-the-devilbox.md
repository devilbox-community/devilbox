---
title: "Start the Devilbox"
---

# Start the Devilbox

Congratulations, when you have reached this page everything has been set
up and you can now get your hands dirty.

> [!NOTE]
> Starting and stopping containers is done via `docker-compose`. If you
> have never worked with it before, have a look at their documentation
> for
> `docker compose cmd overview`,
> `docker compose cmd up`,
> `docker compose cmd stop`,
> `docker compose cmd kill`,
> `docker compose cmd rm`,
> `docker compose cmd logs`
> and
> `docker compose cmd pull`
> commands.


## The Devilbox startup explained

To gain a brief understanding about what is happening under the hood
during startup, read ahead or skip directly to:
`start-the-devilbox-start-all-container`.

Startup operations with the same configuration are idempotent, thus
consecutive startups will not introduce any new changes. The following
shows the brief startup steps:

- Docker Compose will automatically pull all necessary Docker images if
  they do not exist locally.
- Once the HTTPD container start, it will automatically create a
  Certificate Authority to be used for https connections and will place
  it in the `ca/` directory.
- The HTTPD container will then look for already available projects and
  create virtual hosts configurations, apply vhost-gen templates as well
  as CA-signed HTTPS certificates.
- Once the Bind container start, it will create a wildcard DNS zone for
  the given `env-tld-suffix`
- In case MySQL or PgSQL container start, they will populate itself with
  their required default databases.

> [!NOTE]
> Docker images are only pulled if they do not exist. They are not
> updated automatically. If you want to update to new Docker images read
> on: `update-the-devilbox`.

## Start all container

If you want all provided docker container to be available (as defined in
`docker-compose.yml`), start them all by not explicitly specifying any
image name.

### Foreground

For the first startup, foreground start is recommended to see any errors
that might occur:

``` bash
host> docker-compose up
```

- If you want to gracefully stop all container, hit `Ctrl + c`
- If you want to kill all container, hit `Ctrl + c` twice
- Ensure to run `docker-compose rm -f` afterwards

### Background

For consecutive startups you can send them into background (`-d`):

``` bash
host> docker-compose up -d
```

- If you want to gracefully stop all container, enter
  `docker-compose stop`
- If you want to kill all container, enter `docker-compose kill`
- Ensure to run `docker-compose rm -f` afterwards

## Start some container

If you don't require all container to be up and running and let's say
just `PHP`, `HTTPD` and `MYSQL`, you must explicitly specify the image
names to start:

### Foreground

``` bash
host> docker-compose up httpd php mysql
```

- If you want to gracefully stop all started container, hit `Ctrl + c`
- If you want to kill all started container, hit `Ctrl + c` twice
- Ensure to run `docker-compose rm -f` afterwards

### Background

``` bash
host> docker-compose up -d httpd php mysql
```

- If you want to gracefully stop all container, enter
  `docker-compose stop`
- If you want to kill all container, enter `docker-compose kil`
- Ensure to run `docker-compose rm -f` afterwards

<div class="seealso">

`available-container` Have a look at this page to get an overview about
all available container and by what name they have to be specified.

</div>

## Stop and Restart

> [!IMPORTANT]
> When stopping or restarting the Devilbox, ensure to also **remove
> stopped container** before the next startup to prevent orphaned
> runtime settings and always start fresh.
>
> This will prevent many common Docker issues.

<div class="seealso">

**Troubleshooting:** `troubleshooting-what-to-do-first`

</div>

### Stop all container

``` bash
# Stop all container
host> docker-compose stop
# Remove stopped container (important!)
host> docker-compose rm -f
```

### Restart all container

``` bash
# Stop all container
host> docker-compose stop
# Remove stopped container (important!)
host> docker-compose rm -f
# Start all container
host> docker-compose up
```

## Open Devilbox intranet

Once `docker-compose up` has finished and all or the selected container
are up and running, you can visit the Devilbox intranet with your
favorite Web browser at <http://localhost> or <http://127.0.0.1>
(<https://localhost> or <https://127.0.0.1> respectively).

The Intranet start page will also show you all running and failed
containers:

<figure>
<img src="/_includes/figures/devilbox/devilbox-intranet-dash-all.png"
alt="Devilbox intranet: index dash view for all started container" />
<figcaption aria-hidden="true">Devilbox intranet: index dash view for
all started container</figcaption>
</figure>

<figure>
<img
src="/_includes/figures/devilbox/devilbox-intranet-dash-selective.png"
alt="Devilbox intranet: index dash view for some started container" />
<figcaption aria-hidden="true">Devilbox intranet: index dash view for
some started container</figcaption>
</figure>

> [!IMPORTANT]
> `howto-find-docker-toolbox-ip-address` When you are using
> `Docker Toolbox` the Devilbox web server port will not be available on
> your host computer. You first have to find out on which IP address the
> Docker Toolbox machine is serving and use this one instead.

## Checklist

1.  Docker container are started successfully with `docker-compose up`
2.  `docker-compose rm -f` is issued before restarting the Devilbox
3.  Intranet is reachable via `http://localhost`, `http://127.0.0.1` or
    Docker Toolbox IP address
4.  Intranet is reachable via `https://localhost`, `https://127.0.0.1`
    (HTTPS)

<div class="seealso">

`troubleshooting`

</div>
