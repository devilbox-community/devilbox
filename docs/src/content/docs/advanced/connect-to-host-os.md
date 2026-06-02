---
title: "Connect to host OS"
---

# Connect to host OS

This section explains how to connect from inside a Devilbox container to
the host operating system.


## Prerequisites

When you want to connect from inside a Docker container to a port on
your host operating system, ensure the host service is listening on all
interfaces for simplicity.

The following sections will give you the IP address and/or the CNAME
where the host os can be reached from within a container.

## Docker on Linux

If you run Docker on Linux the host IP is always `172.16.238.1`, which
is the default gateway IP address within the Devilbox bridge network
(see `docker-compose.yml`).

> [!IMPORTANT]
> Ensure services on the host listen on that IP address or on all
> interfaces.

By default Docker on Linux does not have CNAME's of the host computer as
for example with MacOS or Windows, therefore two custom CNAME's have
been added by the Devilbox in order to emulate the same behaviour:

- CNAME: `docker.for.lin.host.internal`
- CNAME: `docker.for.lin.localhost`

## Docker for Mac

If you run Docker for Mac, an IP address is not necessary as it already
provides a CNAME which will always point to the IP address of your host
operating system. Depending on the Docker version this CNAME will
differ:

### Docker 18.03.0-ce+ and Docker compose 1.20.1+

CNAME: `host.docker.internal`

### Docker 17.12.0-ce+ and Docker compose 1.18.0+

CNAME: `docker.for.mac.host.internal`

### Docker 17.06.0-ce+ and Docker compose 1.14.0+

CNAME: `docker.for.mac.localhost`

## Docker for Windows

If you run Docker for Windows, an IP address is not necessary as it
already provides a CNAME which will always point to the IP address of
your host operating system. Depending on the Docker version this CNAME
will differ:

> [!IMPORTANT]
> Ensure your firewall is not blocking Docker to host connections.

### Docker 18.03.0-ce+ and Docker compose 1.20.1+

- CNAME: `docker.for.win.host.internal`
- CNAME: `host.docker.internal`

### Docker 17.06.0-ce+ and Docker compose 1.14.0+

CNAME: `docker.for.win.host.localhost`

## Docker Toolbox

> [!NOTE]
> This section applies for both, Docker Toolbox on MacOS and Docker
> Toolbox on Windows.

Docker Toolbox behaves the same way as Docker on Linux, with one major
difference. The Devilbox IP address or the custom provided CNAMEs
actually refer to the Docker Toolbox machine.

In order to connect from inside the Docker container (which is inside
the Docker Toolbox machine) to your host os, you need to create:

1.  either a **local** port-forward on the **Docker Toolbox** machine
    (`ssh -L`)
2.  or a **remote** port-forward on your **host os** (`ssh -R`)

<div class="seealso">

`ssh tunnelling for fun and profit`

</div>

For both examples we assume the following:

- MySQL database exists on your host os and listens on `127.0.0.1` on
  port `3306`
- Docker Toolbox IP address is `192.168.99.100`
- Host IP address where SSH is listening on `172.16.0.1`
- Host SSH username is `user`
- Devilbox Docker container wants to access MySQL on host os

### Local port forward on Docker Toolbox

> [!IMPORTANT]
> For that to work, your host operating system requires an SSH server to
> be up and running.

| Initiator      | From host   | From port | To host          | To port |
|----------------|-------------|-----------|------------------|---------|
| Docker Toolbox | `127.0.0.1` | `3306`    | `192.168.99.100` | `3306`  |

``` bash
# From Docker Toolbox forward port 3306 (on host 172.16.0.1) to myself (192.168.99.100)
toolbox> ssh -L 3306:127.0.0.1:3306 user@172.16.0.1
```

<div class="seealso">

\* `howto-find-docker-toolbox-ip-address` \*
`howto-ssh-into-docker-toolbox` \*
`howto-ssh-port-forward-on-docker-toolbox-from-host`

</div>

### Remote port-forward on host os

> [!IMPORTANT]
> For that to work, your host operating system requires an SSH client
> (`ssh` binary).

| Initiator | From host   | From port | To host          | To port |
|-----------|-------------|-----------|------------------|---------|
| Host os   | `127.0.0.1` | `3306`    | `192.168.99.100` | `3306`  |

``` bash
# From host os forward port 3306 (from loopback 127.0.0.1) to Docker Toolbox (192.168.99.100)
host> ssh -R 3306:127.0.0.1:3306 docker@192.168.99.100
```

<div class="seealso">

\* `howto-find-docker-toolbox-ip-address` \*
`howto-ssh-into-docker-toolbox` \*
`howto-ssh-port-forward-on-host-to-docker-toolbox`

</div>

### Post steps

With either of the above you have achieved the exact behaviour as
`connect-to-host-os-docker-on-linux` for one single service/port (MySQL
port 3306).

You must now follow the steps for `connect-to-host-os-docker-on-linux`
to actually connect to that service from within the Devilbox Docker
container.
