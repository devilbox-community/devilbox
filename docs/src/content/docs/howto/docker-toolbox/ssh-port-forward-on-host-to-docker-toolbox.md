---
title: "SSH port-forward on host to Docker Toolbox"
---

orphan  

# SSH port-forward on host to Docker Toolbox

> [!NOTE]
> This is a **Remote SSH port-forward** (`ssh -R`)


## Requirements

You shell must have an **SSH client** (the `ssh` command or equivalent).

<div class="seealso">

\* `howto-open-terminal-on-mac` \* `howto-open-terminal-on-win` \*
`howto-find-docker-toolbox-ip-address` \*
`howto-ssh-into-docker-toolbox` \*
`ssh tunnelling for fun and profit`

</div>

## Overview

This is a **remote** SSH port-forward (`ssh -R`). In other words, the
host os will make the port **remotely availabl** on the Docker Toolbox
machine. Therefore the process must be initiated on the host os.

### General command

The following represents the general structure of a remote ssh
port-forward:

``` bash
ssh -R <DockerToolbox_Port>:<HostOS_SRV_IP>:<HostOS_SRV_Port> <DockerToolbox_SSH_USER>@<DockerToolbox_SSH_IP>
```

|  |  |
|----|----|
| `<DockerToolbox_Port>` | The port on the Docker Toolbox machine the service should be made available |
| `<HostOS_SRV_IP>` | The IP address on the host os, where the service is currently listening |
| `<HostOS_SRV_PORT>` | The port on the host os, where the service is bound to |
| `<DockerToolbox_SSH_USER>` | The username of the host os SSH server for the connection |
| `<DockerToolbox_SSH_IP>` | The IP address of the host at which the SSH server is reachable |

### Command example

Making `127.0.0.1:10000` from host os available on `0.0.0.0:8080` on
Docker Toolbox machine:

``` bash
ssh -R 8080:127.0.0.1:10000 docker@192.168.99.100
```

|  |  |
|----|----|
| `8080` | Docker Toolbox should make the port available on itself on this port |
| `127.0.0.1` | The service currently listens on that IP address on the host os |
| `10000` | The service is currently bound to that port on the host os |
| `docker` | The username of the Docker Toolbox SSH server for the connection |
| `192.168.99.100` | The IP address of the Docker Toolbox at which the SSH server is reachable |

## Examples

For this example we assume the following information:

- Docker Toolbox IP address is `192.168.99.100`
- Docker Toolbox SSH username is `docker`

### Make host-based MySQL available on Docker Toolbox

1.  Open a terminal on your host os

2.  Forward: `127.0.0.1:3306` from host os to `0.0.0.0:3306` on Docker
    Toolbox

    ``` bash
    toolbox> ssh -R 3306:127.0.0.1:3306 docker@192.168.99.100
    ```

### Make host-based PgSQL available on Docker Toolbox

1.  Open a terminal on your host os

2.  Forward: `127.0.0.1:5432` from host os to `0.0.0.0:5432` on Docker
    Toolbox

    ``` bash
    toolbox> ssh -R 5432:127.0.0.1:5432 docker@192.168.99.100
    ```
