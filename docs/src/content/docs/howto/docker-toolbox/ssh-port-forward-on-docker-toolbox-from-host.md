---
title: "SSH port-forward on Docker Toolbox from host"
---

orphan  

# SSH port-forward on Docker Toolbox from host

> [!NOTE]
> This is a **Local SSH port-forward** (`ssh -L`)


## Requirements

You **host operating system** must have an **SSH server** installed, up
and running.

<div class="seealso">

\* `howto-open-terminal-on-mac` \* `howto-open-terminal-on-win` \*
`howto-find-docker-toolbox-ip-address` \*
`howto-ssh-into-docker-toolbox` \*
`ssh tunnelling for fun and profit`

</div>

## Overview

This is a **local** SSH port-forward (`ssh -L`). In other words, the
Docker Toolbox machine will make a port **locally available** from
somewhere else. Therefore the process must be initiated on the Docker
Toolbox machine.

### General command

The following represents the general structure of a local ssh
port-forward:

``` bash
ssh -L <DockerToolbox_Port>:<HostOS_SRV_IP>:<HostOS_SRV_Port> <HostOS_SSH_USER>@<HostOS_SSH_IP>
```

|  |  |
|----|----|
| `<DockerToolbox_Port>` | The port on the Docker Toolbox machine the service should be made available |
| `<HostOS_SRV_IP>` | The IP address on the host os, where the service is currently listening |
| `<HostOS_SRV_PORT>` | The port on the host os, where the service is bound to |
| `<HostOS_SSH_USER>` | The username of the host os SSH server for the connection |
| `<HostOS_SSH_IP>` | The IP address of the host at which the SSH server is reachable |

### Command example

Making `127.0.0.1:10000` from host os available on `0.0.0.0:8080` on
Docker Toolbox machine:

``` bash
ssh -L 8080:127.0.0.1:10000 user@172.16.0.1
```

|  |  |
|----|----|
| `8080` | Docker Toolbox should make the port available on itself on this port |
| `127.0.0.1` | The service currently listens on that IP address on the host os |
| `10000` | The service is currently bound to that port on the host os |
| `user` | The username of the host os SSH server for the connection |
| `172.16.0.1` | The IP address of the host at which the SSH server is reachable |

## Examples

For this example we assume the following information:

- Docker Toolbox IP address is `192.168.99.100`
- Host os IP address where SSH server is listening is `172.16.0.1`
- Host SSH username is `user`

### Make host-based MySQL available on Docker Toolbox

1.  Gather the IP address on your host os where the SSH server is
    listening

2.  SSH into the Docker Toolbox machine

3.  Forward: `127.0.0.1:3306` from host os to `0.0.0.0:3306` on Docker
    Toolbox

    ``` bash
    toolbox> ssh -L 3306:127.0.0.1:3306 user@172.16.0.1
    ```

### Make host-based PgSQL available on Docker Toolbox

1.  Gather the IP address on your host os where the SSH server is
    listening

2.  SSH into the Docker Toolbox machine

3.  Forward: `127.0.0.1:5432` from host os to `0.0.0.0:5432` on Docker
    Toolbox

    ``` bash
    toolbox> ssh -L 5432:127.0.0.1:5432 user@172.16.0.1
    ```
