---
title: "Prerequisites"
---

# Prerequisites

> [!IMPORTANT]
> `read-first` Ensure you have read this document to understand how this
> documentation works.


## Supported host OS

The Devilbox runs on all major operating systems which provide `Docker`
and `Docker Compose`. See the matrix below for supported versions:

<table style="width:98%;">
<colgroup>
<col style="width: 19%" />
<col style="width: 25%" />
<col style="width: 37%" />
<col style="width: 15%" />
</colgroup>
<thead>
<tr>
<th>OS</th>
<th>Version</th>
<th>Type</th>
<th>Recommended</th>
</tr>
</thead>
<tbody>
<tr>
<td><a href="##SUBST##|img_logo_lin|">|img_logo_lin|</a></td>
<td>Any</td>
<td><a
href="##SUBST##|ext_lnk_prereq_docker_lin|">|ext_lnk_prereq_docker_lin|</a></td>
<td>yes</td>
</tr>
<tr>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td rowspan="2"><a
href="##SUBST##|img_logo_mac|">|img_logo_mac|</a></td>
<td rowspan="2">Any</td>
<td><a
href="##SUBST##|ext_lnk_prereq_docker_mac|">|ext_lnk_prereq_docker_mac|</a></td>
<td>yes</td>
</tr>
<tr>
<td><a
href="##SUBST##|ext_lnk_prereq_docker_mac_tb|">|ext_lnk_prereq_docker_mac_tb|</a></td>
<td></td>
</tr>
<tr>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td rowspan="4"><a
href="##SUBST##|img_logo_win|">|img_logo_win|</a></td>
<td>Windows 7</td>
<td><a
href="##SUBST##|ext_lnk_prereq_docker_win_tb|">|ext_lnk_prereq_docker_win_tb|</a></td>
<td>yes</td>
</tr>
<tr>
<td rowspan="2">Windows 10</td>
<td><a
href="##SUBST##|ext_lnk_prereq_docker_win|">|ext_lnk_prereq_docker_win|</a></td>
<td>yes</td>
</tr>
<tr>
<td><a
href="##SUBST##|ext_lnk_prereq_docker_win_tb|">|ext_lnk_prereq_docker_win_tb|</a></td>
<td></td>
</tr>
<tr>
<td>Windows Server 2016</td>
<td><a
href="##SUBST##|ext_lnk_prereq_docker_win_ee|">|ext_lnk_prereq_docker_win_ee|</a></td>
<td>yes</td>
</tr>
</tbody>
</table>

## Required software

The only requirements for the Devilbox is to have `Docker` and
`Docker Compose` installed, everything else is bundled and provided
withing the Docker container. The minimum required versions are listed
below:

- `Docker`: 17.06.0+
- `Docker Compose`: 1.16.0+

Additionally you will require `git` in order to clone the devilbox
project.

<div class="seealso">

- `install docker`
- `docker compose install`
- `download git win`
- `howto-find-docker-and-docker-compose-version`

</div>

## Docker installation

### Linux

`img logo lin`

Docker on Linux requires super user privileges which is granted to a
system wide group called `docker`. After having installed Docker on your
system, ensure that your local user is a member of the `docker` group.

``` bash
host> id

uid=1000(cytopia) gid=1000(cytopia) groups=1000(cytopia),999(docker)
```

<div class="seealso">

- `install docker centos`
- `install docker debian`
- `install docker fedora`
- `install docker ubuntu`
- `install docker linux post steps`
  (covers `docker` group)

</div>

### Mac

`img logo mac`

On MacOS Docker is available in two different forms: **Docker for Mac**
and **Docker Toolbox**.

#### Docker for Mac

Docker for Mac is the native and recommended version to choose when
using the Devilbox.

Docker for Mac requires super user privileges which is granted to a
system wide group called `docker`. After having installed Docker on your
system, ensure that your local user is a member of the `docker` group.

``` bash
host> id

uid=502(cytopia) gid=20(staff) groups=20(staff),999(docker)
```

<div class="seealso">

Docker for Mac  
- `install docker mac`
- `install docker mac get started`

</div>

#### Docker Toolbox

If you still want to use Docker Toolbox, ensure you have read its
drawbacks in the below provided links.

<div class="seealso">

Docker Toolbox  
- `install docker toolbox mac`
- `install docker toolbox mac native vs toolbox`
- `ext link docker machine`

</div>

> [!IMPORTANT]
> `howto-docker-toolbox-and-the-devilbox`

### Windows

`img logo win`

On Windows Docker is available in two different forms: **Docker for
Windows** and **Docker Toolbox**.

#### Docker for Windows

Docker for Windows is the native and recommended version to choose when
using the Devilbox. This however is only available since **Windows 10**.

Docker for Windows requires administrative privileges which is granted
to a system wide group called `docker-users`. After having installed
Docker on your system, ensure that your local user is a member of the
`docker-users` group.

<div class="seealso">

Docker for Windows  
- `install docker win`
- `install docker win get started`

</div>

#### Docker Toolbox

If you are on **Windows 7** or still want to use Docker Toolbox, ensure
you have read its drawbacks in the below provided links.

<div class="seealso">

Docker Toolbox  
- `install docker toolbox win`
- `ext link docker machine`

</div>

> [!IMPORTANT]
> `howto-docker-toolbox-and-the-devilbox`

## Post installation

Read the Docker documentation carefully and follow all **install** and
**post-install** steps. Below are a few stumbling blocks to check that
might or might not apply depending on your host operating system and
your Docker version.

<div class="seealso">

`troubleshooting`

</div>

### User settings

Some versions of Docker require your local user to be in the `docker`
group (or `docker-users` on Windows).

### Shared drives

Some versions of Docker require you to correctly setup shared drives.
Ensure the desired locations are being made available to Docker and the
correct credentials are applied.

### Network and firewall

On Windows, ensure your firewall allows access to shared drives.

### SE Linux

Make sure to read any shortcomings when SE Linux is enabled.

### General

It could also help to do a full system restart after the installation
has been finished.

## Optional previous knowledge

In order to easily work with the Devilbox you should already be familiar
with the following:

- Navigate on the command line
- Docker Compose commands
  (`docker compose cmd up`,
  `docker compose cmd stop`,
  `docker compose cmd kill`,
  `docker compose cmd rm`,
  `docker compose cmd logs`
  and
  `docker compose cmd pull`)
- Docker Compose `.env` file
- Know how to use `git`

<div class="seealso">

- `docker compose cmd reference`
- `docker compose env file`
- `troubleshooting`

</div>
