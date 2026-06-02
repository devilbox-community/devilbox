---
title: "Prerequisites"
---

# Prerequisites

Before installing Devilbox, prepare a modern Docker host and a terminal that can run the `install.sh` workflow. Devilbox no longer targets the old VirtualBox-based Docker stacks or the Python Compose v1 binary. The supported path in 2026 is Docker Desktop 4.x on desktop systems, Docker Engine 24+ on Linux, and the Docker Compose v2 plugin exposed as `docker compose`.

:::note
This page describes what your host must provide before you run [Install the Devilbox](/getting-started/install-the-devilbox/). The installer verifies most requirements for you, but checking them first makes failures easier to understand.
:::

## Required software

Install these tools before running Devilbox:

| Requirement | Minimum / supported version | Why it is needed |
| --- | --- | --- |
| Docker Desktop | 4.x | Provides the Docker daemon and Compose v2 on macOS and Windows/WSL2. |
| Docker Engine | 24+ | Provides the Docker daemon on Linux hosts. |
| Docker Compose | v2 plugin (`docker compose`) | Starts the multi-service Devilbox stack. |
| Git | Current stable package from your OS | Used by `install.sh` to clone the Devilbox repository. |
| curl | Current stable package from your OS | Used by installer and CLI helper downloads. |
| make | Current stable package from your OS | Checked by the installer on Linux hosts. |
| A POSIX-like shell | `bash`, `zsh`, `fish`, `ash`, or `sh` | Used for the installer and `dvl` CLI integration. |

:::caution
Do not install or rely on the old `docker-compose` v1 Python package for new setups. The modern Docker command is `docker compose`. The `dvl` command wraps Compose for normal Devilbox use, so most day-to-day examples use `dvl` instead of raw Compose commands.
:::

## Supported operating systems

The current installer detects operating systems through `uname` and `/etc/os-release`. Its supported families are the source of truth for new installations:

| Host | Supported baseline | Installer family | Notes |
| --- | --- | --- | --- |
| macOS | macOS 13+ | `darwin` | Use Docker Desktop 4.x. Homebrew is installed automatically if missing. |
| Ubuntu | 22.04 LTS or 24.04 LTS | `debian` | Use Docker Engine 24+ and the Compose v2 plugin package. |
| Debian | Debian 12 | `debian` | Derivatives with `ID_LIKE=debian` follow the same path. |
| Arch Linux | Current rolling release | `arch` | Includes Manjaro, EndeavourOS, Artix, and similar derivatives. |
| Fedora | Fedora 40+ | `fedora` | RHEL-like distributions are detected through the same family. |
| Alpine | Current stable release | `alpine` | The installer places the `dvl` symlink under `~/.local/bin`. |
| WSL2 | A supported Linux distro inside WSL2 | distro family + WSL2 | Enable Docker Desktop WSL2 integration for that distro. |

The script can be forced on unknown hosts, but unsupported systems may fail package-manager or shell-integration checks. Use `./install.sh --force` only when you understand the local Docker and shell setup.

## Docker readiness checks

Verify Docker before installing Devilbox:

```bash
docker version
docker info
docker compose version
```

You want all three commands to succeed. `docker info` is especially important because it proves the Docker daemon is running, not just that the client binary exists.

:::tip
On macOS and Windows/WSL2, start Docker Desktop and wait until the engine reports that it is running before launching the installer.
:::

## Docker Desktop hosts

Docker Desktop is the expected Docker distribution for macOS and WSL2-based desktop workflows.

### macOS

Use Docker Desktop 4.x on macOS 13 or newer. Apple Silicon and Intel Macs are both supported by the installer and the `dvl` helper binaries. The installer detects `Darwin`, chooses the correct shell profile, and creates the `dvl` symlink in `/opt/homebrew/bin` or `/usr/local/bin`.

Recommended pre-flight checks:

```bash
sw_vers
docker info
docker compose version
git --version
curl --version
```

If Homebrew is not available, the installer can install it. Docker itself is not installed by Devilbox; install Docker Desktop first and sign in or accept licenses as required by your organization.

### Windows through WSL2

Run Devilbox from a WSL2 Linux distribution, not from legacy Windows-only Docker tooling. Install Docker Desktop for Windows, enable WSL2 integration for your distro, then run the Devilbox installer inside that distro's terminal.

Recommended pre-flight checks inside WSL2:

```bash
cat /proc/version
docker info
docker compose version
git --version
```

Use Linux paths inside WSL2 for your Devilbox workspace, for example `~/Workspace/devilbox`. Avoid placing active project files under `/mnt/c` when performance matters, because bind-mounted source trees can be slower from Windows filesystems.

## Linux hosts

Linux hosts should use Docker Engine 24+ and the Compose v2 plugin from their distribution or Docker's official repositories. The installer verifies the package manager family and checks for baseline tools.

### Ubuntu and Debian

The installer family is `debian`. It expects `apt-get`, `git`, `curl`, `make`, Docker, and Compose v2. Typical packages are provided by Docker's official repository or your distribution:

```bash
docker --version
docker compose version
id
```

Make sure your user can talk to Docker. Many Linux systems require adding the user to the `docker` group and starting a new login session:

```bash
sudo usermod -aG docker "$USER"
```

Then log out and back in before running Devilbox.

### Arch-family systems

The installer family is `arch`. It detects Arch, Manjaro, EndeavourOS, Artix, and related systems. Install Docker, start the daemon, enable it if you want it after reboot, and ensure `git`, `curl`, and `make` are present.

```bash
docker info
docker compose version
```

### Fedora-family systems

The installer family is `fedora`. It uses `dnf` when available and falls back to `yum`. Fedora 40+ is the expected baseline for new documentation and testing. RHEL-compatible systems may work when they expose the same Docker and Compose capabilities.

```bash
docker info
docker compose version
```

### Alpine

The installer family is `alpine`. It uses `apk` and creates the `dvl` symlink under `~/.local/bin`. Ensure that directory is on your `PATH` before expecting `dvl` to be found in new shells.

```bash
docker info
docker compose version
printf '%s\n' "$PATH"
```

## Shell profile expectations

`install.sh` writes two environment variables to your shell profile:

| Variable | Example value | Purpose |
| --- | --- | --- |
| `DEVILBOX_PATH` | `$HOME/Workspace/devilbox` | Tells `dvl` where the Devilbox repository lives. |
| `DEVILBOX_CONTAINERS` | `bind httpd php mysql php74 php81 php82 php83 php84 redis opensearch buggregator` | Defines the services started by `dvl up`. |

The installer chooses a profile based on your shell:

| Shell | Profile file |
| --- | --- |
| zsh | `~/.zprofile` |
| bash on macOS | `~/.bash_profile` |
| bash on Linux | `~/.bashrc` |
| fish | `~/.config/fish/config.fish` |
| ash or sh | `~/.profile` |

Restart your terminal after installation, or source the profile printed by the installer.

## Permissions and UID/GID mapping

Devilbox containers run as the `devilbox` user. To keep files editable from your host, `.env` contains `NEW_UID` and `NEW_GID`. The installer sets these to your current user and group:

```bash
id -u
id -g
```

If you install manually, copy these values into `.env`. If they are wrong, files created in the PHP container may appear with unexpected ownership on the host.

## Network and port checks

By default, Devilbox publishes these common host ports:

| Service | Default host port | Variable |
| --- | --- | --- |
| HTTP | `80` | `HOST_PORT_HTTPD` |
| HTTPS | `443` | `HOST_PORT_HTTPD_SSL` |
| MySQL | `3306` | `HOST_PORT_MYSQL` |
| PostgreSQL | `5432` | `HOST_PORT_PGSQL` |
| Redis | `6379` | `HOST_PORT_REDIS` |
| MongoDB | `27017` | `HOST_PORT_MONGO` |
| Bind DNS | `1053` | `HOST_PORT_BIND` |

If another local service already owns a port, change the matching variable in `.env` before starting Devilbox.

:::note
The default `LOCAL_LISTEN_ADDR` is empty in `env-example`, which means published ports can bind on all interfaces. If you want loopback-only binding, set `LOCAL_LISTEN_ADDR=127.0.0.1:` before starting services.
:::

## Filesystem and volume expectations

The default project directory is `./data/www` relative to the Devilbox repository. That path is mounted into PHP and HTTPD containers as `/shared/httpd`.

Important host paths from `.env`:

| Variable | Default | Purpose |
| --- | --- | --- |
| `DEVILBOX_PATH` | `.` | Base path for many mounts. |
| `HOST_PATH_HTTPD_DATADIR` | `./data/www` | Your web project workspace. |
| `HOST_PATH_BACKUPDIR` | `./backups` | Database import/export storage. |
| `HOST_PATH_SSH_DIR` | `~/.ssh` | Read-only SSH keys mounted into PHP. |
| `MOUNT_OPTIONS` | empty | Optional mount flags such as SELinux labels or macOS caching. |

On SELinux systems, `MOUNT_OPTIONS=,z` may still be required for shared bind mounts. On macOS, Docker Desktop file-sharing and performance settings may matter for large dependency trees.

## Optional previous knowledge

You do not need PHP, MySQL, Redis, Composer, or Node installed on your host to use Devilbox. Those tools live in containers. You should, however, be comfortable with:

- Opening a terminal.
- Navigating directories with `cd`, `pwd`, and `ls`.
- Editing text files such as `.env`.
- Understanding that containers are disposable but named Docker volumes preserve database data.
- Running `dvl up`, `dvl down`, `dvl shell`, and `dvl exec`.
- Reading container logs when a service fails to start.

## What you do not need on the host

Devilbox intentionally keeps application tooling inside containers. A clean host can still work with many projects because the PHP workspace image supplies the runtime layer.

You normally do not need to install these directly on your computer:

- PHP or PHP extensions.
- Composer.
- MySQL, MariaDB, PostgreSQL, Redis, Memcached, or MongoDB servers.
- Apache or Nginx.
- Project-specific CLIs that are already included in the selected PHP image.

Install host-native versions only when you have a separate reason outside Devilbox.

## What the installer verifies

The automated installer performs these checks before it modifies your workspace:

1. Detects the operating system family.
2. Verifies that Git is available.
3. Verifies that Docker is installed.
4. Verifies that the Docker daemon is running.
5. Verifies Compose v2 on non-macOS Linux hosts.
6. Checks package-manager availability for supported Linux families.
7. Checks `git`, `curl`, and `make` on Linux.
8. Detects WSL2 and prints Docker Desktop integration guidance.

If any hard requirement is missing, the installer exits before completing installation.

## Pre-install checklist

Use this checklist immediately before running [Install the Devilbox](/getting-started/install-the-devilbox/):

- Docker Desktop 4.x or Docker Engine 24+ is installed.
- `docker info` succeeds.
- `docker compose version` succeeds.
- Git is installed.
- curl is installed.
- make is installed on Linux.
- Your Linux user can access Docker without permission errors.
- WSL2 integration is enabled if you are on Windows.
- Ports such as 80, 443, 3306, 5432, and 6379 are free or you know which `.env` variables to change.
- You have chosen a workspace path, usually `~/Workspace/devilbox`.
- You are ready to restart or source your shell profile after installation.

## Troubleshooting quick map

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `Cannot connect to the Docker daemon` | Docker is not running | Start Docker Desktop or the Linux Docker service. |
| `docker compose` is unknown | Compose v2 plugin missing | Install the Docker Compose plugin package for your OS. |
| Permission denied on Docker socket | User not in Docker group | Add the user to the group and start a new login session. |
| `dvl` command not found after install | Shell profile not loaded or symlink directory not on `PATH` | Restart terminal, source the printed profile, or add `~/.local/bin` to `PATH`. |
| Port already allocated | Another service is running locally | Stop that service or change the matching `HOST_PORT_*` variable. |
| Files owned by unexpected UID | `NEW_UID` / `NEW_GID` mismatch | Update `.env`, then recreate affected containers. |

## Next step

Once the checks above pass, continue with [Install the Devilbox](/getting-started/install-the-devilbox/).
