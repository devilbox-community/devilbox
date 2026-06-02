---
title: "Enter the PHP container"
---

# Enter the PHP container

One of Devilbox's core ideas is that your host does not need local PHP tooling. Composer, PHP extensions, framework CLIs, database clients, and many developer utilities live inside the PHP containers. Use `dvl shell` for an interactive shell and `dvl exec` for one-off commands.

:::note
The PHP container must be running before you can enter it. Start Devilbox with `dvl up` first.
:::

## Default interactive shell

Open a shell in the default PHP service:

```bash
dvl shell
```

The CLI enters the container as the `devilbox` user and starts a login shell. Your normal project workspace is mounted under:

```text
/shared/httpd
```

The default service is `php`, which maps to the `PHP_SERVER` value in `.env`.

## Choose a specific PHP service

The current default installation can include versioned PHP service names:

| Service | Intended runtime |
| --- | --- |
| `php` | Default PHP selected by `PHP_SERVER` in `.env`. |
| `php74` | PHP 7.4 service. |
| `php81` | PHP 8.1 service. |
| `php82` | PHP 8.2 service. |
| `php83` | PHP 8.3 service. |
| `php84` | PHP 8.4 service. |

Enter a specific service with:

```bash
dvl shell php82
```

If the CLI detects a `.devilbox.yaml` for the current project, it can ask whether to use the detected PHP service instead of the default one.

:::tip
Use project-level `.devilbox.yaml` files when different projects need different PHP runtimes. The `dvl` CLI searches the current directory, parent directories, and common document-root locations.
:::

## Run a one-off command

Use `dvl exec` when you do not need an interactive shell:

```bash
dvl exec "php -v"
dvl exec "composer install"
dvl exec "ls -la"
```

`dvl exec` maps the current host working directory to the corresponding container path when you are inside the `data/www` tree. That lets commands run from the same project directory you are using on the host.

## Common PHP workflows

Composer:

```bash
dvl composer install
dvl composer require monolog/monolog
```

Magento:

```bash
dvl magento setup:upgrade
dvl magento cache:flush
dvl magerun cache:status
```

Generic PHP:

```bash
dvl exec "php -m"
dvl exec "php vendor/bin/phpunit"
```

The dedicated `dvl composer`, `dvl magento`, and `dvl magerun` commands add project detection and PHP image flavor checks on top of raw command execution.

## Become root inside the container

The normal container user is `devilbox`, mapped to your host UID/GID through `NEW_UID` and `NEW_GID`. If you need root for debugging, use passwordless `sudo` inside the container:

```bash
dvl shell
sudo su -
```

:::caution
Changes made as root inside a running container are usually temporary. For repeatable customizations, prefer `.env`, `cfg/`, `autostart/`, or a custom Docker image override.
:::

## Tools inside PHP containers

The `work` flavor PHP images include development tools commonly needed by PHP projects, including Composer and framework CLIs. The exact tool set depends on the image build and PHP version.

Useful checks:

```bash
dvl exec "php -v"
dvl exec "composer --version"
dvl exec "git --version"
```

If a command is missing, first check whether the PHP service is using a `work` image flavor. Some `dvl` commands can offer to switch a service from `slim` to `work` when required.

## Legacy script compatibility

Older Devilbox documentation used `./shell.sh` to enter PHP. That script is still kept for backward compatibility, but new workflows should use:

```bash
dvl shell
dvl exec "php -v"
```

The modern CLI centralizes project detection, working-directory mapping, and service selection, which makes it safer than calling legacy scripts directly.

## Host versus container paths

| Host path | Container path | Purpose |
| --- | --- | --- |
| `data/www` | `/shared/httpd` | Web projects. |
| `backups` | `/shared/backups` | Database dumps and restore files. |
| `~/.ssh` | `/home/devilbox/.ssh` | Read-only SSH keys for Git operations. |
| `cfg/php-ini-<version>` | `/etc/php-custom.d` | Custom PHP ini files. |
| `cfg/php-fpm-<version>` | `/etc/php-fpm-custom.d` | Custom PHP-FPM configuration. |

Knowing these paths helps when copying commands from host instructions into a container shell.

## Checklist

- Devilbox is running with `dvl up`.
- `dvl shell` enters the default PHP service.
- `dvl shell php82` or another service name enters a specific PHP runtime.
- `dvl exec "php -v"` runs a one-off command successfully.
- You know that `/shared/httpd` is the project workspace inside the container.
- You know to use `sudo` only for temporary root debugging.
- You know `./shell.sh` remains compatible but is no longer the recommended entry point.

## Next step

Use the PHP shell to install project dependencies, run framework CLIs, or continue with container version changes in [Change container versions](/getting-started/change-container-versions/).
