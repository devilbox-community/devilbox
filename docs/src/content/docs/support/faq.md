---
title: "FAQ"
---

# FAQ

Find common questions and answers here.

<div class="seealso">

\* `howto` \* `troubleshooting`

</div>


## General

### Are there any differences between native Docker and Docker Toolbox?

Yes, read `howto-docker-toolbox-and-the-devilbox` to find out more.

### Why are mounted MySQL data directories separated by version?

This is just a pre-caution. Imagine they would link to the same datadir.
You start the Devilbox with mysql 5.5, create a database and add some
data. Now you decide to switch to mysql 5.7 and restart the devilbox.
The newer mysql version will probably upgrade the data leaving it unable
to start with older mysql versions.

### Why are mounted PostgreSQL data directories separated by version?

See: `faq-data-dir-separated-by-version`

### Why are mounted MongoDB data directories separated by version?

See: `faq-data-dir-separated-by-version`

### Why do the user/group permissions of log/ or cfg/ directories show 1000?

Uid and Gid are set to 1000 by default. You can alter them to match the
uid/gid of your current user. Open the `.env` file and change the
sections `NEW_UID` and `NEW_GID`. When you start up the devilbox, the
PHP container will use these values for its user.

<div class="seealso">

`env-new-uid` and `env-new-gid`

</div>

### Can I not just comment out the service in the .env file?

No, don't do this. This will lead to unexpected behaviour (different
versions will be loaded). The `.env` file allows you to configure the
devilbox, but not to start services selectively.

### Are there any required services that must/will always be started?

Yes. `http` and `php` will automatically always be started (due to
dependencies inside `docker-compose.yml`) if you specify them or not.

### What PHP Modules are available?

The Devilbox is a development stack, so it is made sure that a lot of
PHP modules are available out of the box in order to work with many
different frameworks.

Available PHP modules can be seen at the PHP Docker image repository.

<div class="seealso">

<https://github.com/devilbox/docker-php-fpm>

</div>

## Configuration

### Can I change the MySQL root password?

Yes, you can change the password of the MySQL root user. If you do so,
you must also set the new password in your `.env` file. See
`env-mysql-root-password` for how to change this value.

### Can I change php.ini?

Yes, php.ini directives can be changed for each PHP version separately.
See `php-ini`

### Can I change my.cnf?

Yes, my.cnf directives can be changed for each MySQL version separately.
See `my-cnf`

### Can I change the project virtual host domain `.loc`?

Yes, the `.env` variable `env-tld-suffix` can be changed to whatever
domain or subdomain you want. See `env-tld-suffix`.

> [!WARNING]
> Be aware not to use `dev` or `localhost`. See `env-tld-suffix` for
> more details. Also do not use any official domain TLDs such as `com`,
> `net`, `org`, etc.

### Can I just start PHP and MySQL instead of all container?

Yes, every Docker container is optional. The Devilbox allows for
selective startup. See `start-the-devilbox`.

### Do I always have to edit `/etc/hosts` for new projects?

You need a valid DNS entry for every project that points to the Httpd
server. As those records don't exists by default, you will have to
create them. However, the Devilbox has a bundled DNS server that can
automate this for you. The only thing you have to do for that to work is
to add this DNS server's IP address to your `/etc/resolv.conf`. See
`setup-auto-dns` for detailed instructions.

## Compatibility

### Does it work with CakePHP?

Yes, see `example-setup-cakephp`

### Does it work with Codeigniter?

Yes, see `example-setup-codeigniter`

### Does it work with Contao?

Yes, see `example-setup-contao`

### Does it work with CraftCMS?

Yes, see `example-setup-craftcms`

### Does it work with Drupal?

Yes, see `example-setup-drupal`

### Does it work with ExpressionEngine?

Yes, see `example-setup-expressionengine`

### Does it work with Joomla?

Yes, see `example-setup-joomla`

### Does it work with Laravel?

Yes, see `example-setup-laravel`

### Does it work with Magento?

Yes, see `example-setup-magento`

### Does it work with Phalcon?

Yes, see `example-setup-phalcon`

### Does it work with Photon CMS?

Yes, see `example-setup-photon-cms`

### Does it work with PrestaShop?

Yes, see `example-setup-presta-shop`

### Does it work with ProcessWire?

Yes, see `example-setup-processwire`

### Does it work with Shopware?

Yes, see `example-setup-shopware`

### Does it work with Symfony?

Yes, see `example-setup-symfony`

### Does it work with Typo3?

Yes, see `example-setup-typo3`

### Does it work with Wordpress?

Yes, see `example-setup-wordpress`

### Does it work with Yii?

Yes, see `example-setup-yii`

### Does it work with Zend?

Yes, see `example-setup-zend`

### Does it work with other Frameworks?

Yes, see `example-setup-other-frameworks`
