---
title: "Enable/disable PHP modules"
---

# Enable/disable PHP modules


<div class="seealso">

<https://github.com/devilbox/docker-php-fpm/blob/master/doc/php-modules.md>
Follow the link to see all available PHP modules for each different
PHP-FPM server version.

</div>

## Enabled PHP modules

At the moment all PHP modules are enabled by default except
[ioncube](http://www.ioncube.com/), So this one is the only one you can
currently enable. To do so follow the steps provided below:

1.  Stop the Devilbox

2.  Enable modules in `.env` under `PHP_MODULES_ENABLE`

    ``` bash
    # Enable Ioncube
    PHP_MODULES_ENABLE=ioncube
    ```

3.  Start the Devilbox

<div class="seealso">

`env-file-php-modules-enable`

</div>

## Disable PHP modules

If you feel there are currently too many modules loaded and you want to
unload some of them by default, you can do so via a comma separated list
in `.env`.

1.  Stop the Devilbox

2.  Disable modules in `.env` under `PHP_MODULES_DISABLE`

    ``` bash
    # Disable Xdebug, Imagick and Swoole
    PHP_MODULES_DISABLE=xdebug,imagick,swoole
    ```

3.  Start the Devilbox

<div class="seealso">

`env-file-php-modules-disable`

</div>

## Roadmap

<div class="todo">

In order to create a performent, secure and sane default PHP-FPM server,
only really required modules should be enabled by default. The rest is
up to the user to enable others as needed.

The current discussion about default modules can be found at the
following Github issue. Please participate and give your ideas:
<https://github.com/cytopia/devilbox/issues/299>

</div>
