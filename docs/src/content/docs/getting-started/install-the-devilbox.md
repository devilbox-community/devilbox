---
title: "Install the Devilbox"
---

# Install the Devilbox

The canonical way to install Devilbox is the automated `install.sh` workflow. It detects your operating system, verifies Docker and Git, clones the repository, creates `.env`, configures your user and group IDs, exports Devilbox environment variables, and installs the `dvl` command.

:::note
Read [Prerequisites](/getting-started/prerequisites/) first. `install.sh` expects Docker to be installed and running before it starts.
:::

## Recommended installation

Run the installer from a terminal:

```bash
curl -sSL https://raw.githubusercontent.com/devilbox-community/devilbox/mainline/install.sh | bash
```

This installs Devilbox to the default workspace path used by the script:

```bash
~/Workspace
```

When installation completes, the final instructions tell you which shell profile was updated and how to start Devilbox with `dvl up`.

:::tip
For the full script reference, options, environment variables, and troubleshooting details, see [Automated Installation Script](/getting-started/install-script/).
:::

## What the installer does

The installer is intentionally explicit. Its help output lists the workflow in order:

1. Detect your OS and required package manager.
2. Clone the Devilbox repository to the workspace directory.
3. Create `.env` from `env-example`.
4. Copy the Magento 2 compose override into `docker-compose.override.yml`.
5. Load the default container roster from `env-example`.
6. Set `DEVILBOX_CONTAINERS` and `DEVILBOX_PATH` in your shell profile.
7. Configure `NEW_UID` and `NEW_GID` for host/container file ownership.
8. On macOS, install Homebrew if it is missing.
9. Create a symlink so the `dvl` command is available on your `PATH`.

The important result is a ready-to-use workspace with a configured `.env` file and a working `dvl` command.

## Supported installer options

Use the script directly from a cloned checkout when you need flags:

```bash
./install.sh [OPTIONS]
```

| Option | Meaning |
| --- | --- |
| `-h`, `--help` | Show help and exit. |
| `-f`, `--force` | Remove an existing target directory before cloning again. |
| `-v`, `--verbose` | Print additional diagnostic output. |
| `--non-interactive` | Never prompt; use safe defaults and fail on destructive operations. |
| `--workspace <path>` | Install to a custom workspace path instead of `$HOME/Workspace`. |

The same behavior can be controlled with environment variables:

| Variable | Equivalent option |
| --- | --- |
| `DEVILBOX_NONINTERACTIVE=1` | `--non-interactive` |
| `DEVILBOX_WORKSPACE=/path/to/devilbox` | `--workspace /path/to/devilbox` |

## Install to a custom path

If you do not want the default workspace, download or clone the repository and run:

```bash
./install.sh --workspace /home/user/projects/devilbox
```

The installer writes the chosen path to `DEVILBOX_PATH` in your shell profile. The `dvl` command uses that variable to find the repository later.

:::caution
Use `--force` carefully. When the target directory exists, force mode removes it before cloning a fresh copy.
:::

## Non-interactive installs

For automation, combine `--non-interactive` with an explicit workspace. Add `--force` only when replacing the target directory is intentional:

```bash
DEVILBOX_NONINTERACTIVE=1 ./install.sh --workspace /opt/devilbox
```

Non-interactive mode refuses to overwrite an existing directory unless `--force` is present. This prevents accidental data loss in CI, cloud-init, and provisioning scripts.

## Shell profile changes

The installer adds Devilbox configuration to the profile for your detected shell.

| Shell | Typical profile |
| --- | --- |
| zsh | `~/.zprofile` |
| bash on macOS | `~/.bash_profile` |
| bash on Linux | `~/.bashrc` |
| fish | `~/.config/fish/config.fish` |
| ash or sh | `~/.profile` |

The profile receives values like these:

```bash
export DEVILBOX_CONTAINERS="bind httpd php mysql php74 php81 php82 php83 php84 redis opensearch buggregator"
export DEVILBOX_PATH="$HOME/Workspace/devilbox"
```

Restart your terminal after installation, or source the profile printed by the installer:

```bash
source ~/.zprofile
```

For fish shells, the installer writes `set -gx` syntax instead of `export`.

## Container roster seeded by installation

The installer reads the default and optional rosters from `env-example`:

```bash
CONTAINERS_CONFIG_DEFAULT="bind httpd php mysql"
CONTAINERS_CONFIG_OPTIONAL="php74 php81 php82 php83 php84 redis opensearch buggregator"
```

It combines those values and exports them as `DEVILBOX_CONTAINERS`. That is the list started by `dvl up` when you do not pass explicit services.

If you want a smaller default stack later, edit `DEVILBOX_CONTAINERS` in your shell profile. For example:

```bash
export DEVILBOX_CONTAINERS="bind httpd php mysql redis"
```

Then restart your terminal or source the profile again.

## `.env` initialization

The installer copies `env-example` to `.env` and updates these host-specific values:

```bash
NEW_UID=<your id -u>
NEW_GID=<your id -g>
```

These values keep files created by containers editable by your host user. You can review them at any time:

```bash
grep '^NEW_UID\|^NEW_GID' .env
```

The installer also copies `compose/docker-compose.override.yml-magento2` to `docker-compose.override.yml`. If you do not need that override, you can edit or replace it after installation.

## `dvl` command installation

The installer makes `dvl` available as a command by linking it to `dvl.sh`.

| Host | Symlink target directory |
| --- | --- |
| macOS with Apple Silicon Homebrew | `/opt/homebrew/bin` |
| macOS with Intel Homebrew | `/usr/local/bin` |
| Linux with writable system bin | `/usr/local/bin` |
| Linux without writable system bin | `~/.local/bin` |
| Alpine | `~/.local/bin` |

If `dvl` is not found after install, restart your shell and verify that the target directory is on `PATH`.

```bash
command -v dvl
dvl --help
```

## First commands after install

After restarting your terminal or sourcing your profile, run:

```bash
dvl up
dvl ps
```

Then open the intranet:

```text
http://localhost
https://localhost
```

Use `dvl down` to stop the environment cleanly:

```bash
dvl down
```

## Manual fallback

Manual installation is supported as an alternative when you cannot run the installer. It should mirror what `install.sh` does.

```bash
mkdir -p ~/Workspace
git clone https://github.com/devilbox-community/devilbox ~/Workspace/devilbox
cd ~/Workspace/devilbox
cp env-example .env
cp compose/docker-compose.override.yml-magento2 docker-compose.override.yml
```

Set UID and GID:

```bash
id -u
id -g
```

Edit `.env`:

```bash
NEW_UID=1000
NEW_GID=1000
```

Add shell profile exports:

```bash
export DEVILBOX_PATH="$HOME/Workspace/devilbox"
export DEVILBOX_CONTAINERS="bind httpd php mysql php74 php81 php82 php83 php84 redis opensearch buggregator"
```

Create a symlink or alias for `dvl`:

```bash
chmod +x ~/Workspace/devilbox/dvl.sh
ln -snf ~/Workspace/devilbox/dvl.sh ~/.local/bin/dvl
```

:::note
The manual flow is a fallback. Prefer `install.sh` because it validates Docker, detects your OS, chooses the correct shell profile, and configures the CLI consistently.
:::

## Upgrade or reinstall

For a fresh reinstall, run the installer with `--force` and the same workspace path. For an existing checkout you want to keep, update with Git instead:

```bash
cd "$DEVILBOX_PATH"
git pull
```

After pulling major changes, compare `.env` with `env-example` or use `dvl sync-env` where appropriate.

## Installation checklist

- Docker is installed and running.
- `docker compose version` works.
- Git is installed.
- `install.sh` completed successfully.
- `.env` exists.
- `NEW_UID` and `NEW_GID` match your host user.
- `DEVILBOX_PATH` points to the repository.
- `DEVILBOX_CONTAINERS` contains the services you want by default.
- `dvl` is on your `PATH`.
- `dvl --help` prints command help.

## Next step

Continue with [Start the Devilbox](/getting-started/start-the-devilbox/).
