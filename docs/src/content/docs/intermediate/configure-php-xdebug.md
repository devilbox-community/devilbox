---
title: "Configure PHP Xdebug"
---

# Configure PHP Xdebug

This section explains in depth how to enable and use PHP Xdebug with the
Devilbox.


## Introduction

In order to have a working Xdebug, you need to ensure two things:

1.  **PHP Xdebug** must be configured and enabled in PHP itself
2.  Your **IDE/editor** must be configured and requires a way talk to
    PHP

Configuring PHP Xdebug will slightly differ when configuring it for a
dockerized environment. This is due to the fact that Docker versions on
different host os have varying implementations of how they connect back
to the host.

Most IDE or editors will also require different configurations for how
they talk to PHP Xdebug. This is at least most likely the case for
`xdebug.idekey`.

<div class="seealso">

`configure-php-xdebug-options`

</div>

## Configure Xdebug

### Docker on Linux

Docker on Linux allows Xdebug to automatically connect back to the host
system without the need of an explicit IP address.

<div class="toctree" glob="" maxdepth="1" hidden="">

/intermediate/configure-php-xdebug/linux/\*

</div>

<div class="seealso">

- `configure-php-xdebug-lin-atom`
- `configure-php-xdebug-lin-phpstorm`
- `configure-php-xdebug-lin-sublime`
- `configure-php-xdebug-lin-vscode`

</div>

### Docker on MacOS

<div class="toctree" glob="" maxdepth="1" hidden="">

/intermediate/configure-php-xdebug/macos/\*

</div>

<div class="seealso">

- `configure-php-xdebug-mac-atom`
- `configure-php-xdebug-mac-phpstorm`
- `configure-php-xdebug-mac-sublime`
- `configure-php-xdebug-mac-vscode`

</div>

### Docker on Windows

<div class="toctree" glob="" maxdepth="1" hidden="">

/intermediate/configure-php-xdebug/windows/\*

</div>

<div class="seealso">

- `configure-php-xdebug-win-atom`
- `configure-php-xdebug-win-phpstorm`
- `configure-php-xdebug-win-sublime`
- `configure-php-xdebug-win-vscode`

</div>

### Docker Toolbox

Docker Toolbox configuration is equal, no matter if it is started on
MacOS or Windows, as both use a Linux system inside VirtualBox.

<div class="toctree" glob="" maxdepth="1" hidden="">

/intermediate/configure-php-xdebug/toolbox/\*

</div>

<div class="seealso">

- `configure-php-xdebug-toolbox-atom`
- `configure-php-xdebug-toolbox-phpstorm`
- `configure-php-xdebug-toolbox-sublime`
- `configure-php-xdebug-toolbox-vscode`

</div>
