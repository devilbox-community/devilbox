---
title: "Create your first project"
---

# Create your first project

> [!IMPORTANT]
> Ensure you have read `getting-started-directory-overview` to
> understand what is going on under the hood.

> [!NOTE]
> This section not only applies for one project, it applied for as many
> projects as you need. **There is no limit in the number of projects.**


## Step 1: visit Intranet vhost page

Before starting, have a look at the vhost page at
<http://localhost/vhosts.php> or <http://127.0.0.1/vhosts.php>

<div class="seealso">

`howto-find-docker-toolbox-ip-address`

</div>

It should look like the screenshot below and will actually already
provide the information needed to create a new project.

<figure>
<img
src="/_includes/figures/devilbox/devilbox-intranet-vhosts-empty.png"
alt="Devilbox intranet: no projects created" />
<figcaption aria-hidden="true">Devilbox intranet: no projects
created</figcaption>
</figure>

## Step 2: create a project directory

In your Devilbox git directory, navigate to `./data/www` and create a
new directory.

> [!NOTE]
> Choose the directory name wisely, as it will be part of the domain for
> that project. For this example we will use `project-1` as our project
> name.

``` bash
# navigate to your Devilbox git directory
host> cd path/to devilbox

# navigate to the data directory
host> cd data/www

# create a new project directory named: project-1
host> mkdir project-1
```

Visit the vhost page again and see what has changed:
<http://localhost/vhosts.php>

<figure>
<img
src="/_includes/figures/devilbox/devilbox-intranet-vhosts-missing-htdocs.png"
alt="Devilbox intranet: misssing htdocs directory" />
<figcaption aria-hidden="true">Devilbox intranet: misssing
<code>htdocs</code> directory</figcaption>
</figure>

**So what has happened?**

By having created a project directory, the web server container has
created a new virtual host. However it has noticed, that the actual
document root directory does not yet exist and therefore it cannot serve
any files yet.

## Step 3: create a docroot directory

> [!NOTE]
> As desribed in `getting-started-directory-overview-docroot` the
> docroot directory name must be `htdocs` for now.

Navigate to your newly created project directory and create a directory
named <span class="title-ref">htdocs</span> inside it.

``` bash
# navigate to your Devilbox git directory
host> cd path/to devilbox

# navigate to your above created project directory
host> cd data/www/project-1

# create the docroot directory
host> mkdir htdocs
```

Vist the vhost page again and see what has changed:
<http://localhost/vhosts.php>

<figure>
<img
src="/_includes/figures/devilbox/devilbox-intranet-vhosts-missing-dns.png"
alt="Devilbox intranet: misssing dns record" />
<figcaption aria-hidden="true">Devilbox intranet: misssing dns
record</figcaption>
</figure>

**So what has happened?**

By having created the docroot directory, the web server is now able to
serve your files. However it has noticed, that you have no way yet, to
actually visit your project url, as no DNS record for it exists yet.

The intranet already gives you the exact string that you can simply copy
into your `/etc/hosts` (or `C:\Windows\System32\drivers\etc` for
Windows) file on your host operating system to solve this issue.

## Step 4: create a DNS entry

> [!NOTE]
> This step can also be automated via the bundled DNS server to
> automatically provide catch-all DNS entries to your host computer, but
> is outside the scope of this *getting started tutorial*.

When using native Docker, the Devilbox intranet will provide you the
exact string you need to paste into your `/etc/hosts` (or
`C:\Windows\System32\drivers\etc` for Windows).

``` bash
# Open your /etc/hosts file with sudo or root privileges
# and add the following DNS entry
host> sudo vi /etc/hosts

127.0.0.1 project-1.loc
```

<div class="seealso">

- `howto-add-project-hosts-entry-on-mac`
- `howto-add-project-hosts-entry-on-win`

</div>

Vist the vhost page again and see what has changed:
<http://localhost/vhosts.php>

<figure>
<img
src="/_includes/figures/devilbox/devilbox-intranet-vhosts-working.png"
alt="Devilbox intranet: vhost setup successfully" />
<figcaption aria-hidden="true">Devilbox intranet: vhost setup
successfully</figcaption>
</figure>

**So what has happened?**

By having created the DNS record, the Devilbox intranet is aware that
everything is setup now and gives you a link to your new project.

## Step 5: visit your project

On the intranet, click on your project link. This will open your project
in a new Browser tab or visit <http://project-1.loc>

<figure>
<img
src="/_includes/figures/devilbox/devilbox-project-missing-index.png"
alt="Devilbox project: misssing index.php or index.html" />
<figcaption aria-hidden="true">Devilbox project: misssing
<code>index.php</code> or <code>index.html</code></figcaption>
</figure>

**So what has happened?**

Everything is setup now, however the webserver is trying to find a
`index.php` file in your document root which does not yet exist.

So all is left for you to do is to add your HTML or PHP files.

## Step 6: create a hello world file

Navigate to your docroot directory within your project and create a
`index.php` file with some output.

``` bash
# navigate to your Devilbox git directory
host> cd path/to devilbox

# navigate to your projects docroot directory
host> cd data/www/project-1/htdocs

# Create a hello world index.php file
host> echo "<?php echo 'hello world';" > index.php
```

Alternatively create an `index.php` file in `data/www/project-1/htdocs`
with the following contents:

``` php
<?php echo 'hello world';
```

Visit your project url again and see what has changed:
<http://project-1.loc>

<figure>
<img src="/_includes/figures/devilbox/devilbox-project-hello-world.png"
alt="Devilbox project: hello world on index.php" />
<figcaption aria-hidden="true">Devilbox project: hello world on
<code>index.php</code></figcaption>
</figure>

## Checklist

1.  Project directory is created
2.  Docroot directory is created
3.  DNS entry is added to the host operating system
4.  PHP files are added to your docroot directory

<div class="seealso">

`troubleshooting`

</div>

## Further examples

If you already want to know how to setup specific frameworks on the
Devilbox, jump directly to their articles:

<div class="seealso">

**Well tested frameworks on the Devilbox**

- `example-setup-cakephp`
- `example-setup-codeigniter`
- `example-setup-craftcms`
- `example-setup-drupal`
- `example-setup-expressionengine`
- `example-setup-joomla`
- `example-setup-laravel`
- `example-setup-magento`
- `example-setup-phalcon`
- `example-setup-photon-cms`
- `example-setup-presta-shop`
- `example-setup-shopware`
- `example-setup-symfony`
- `example-setup-typo3`
- `example-setup-wordpress`
- `example-setup-yii`
- `example-setup-zend`

</div>

<div class="seealso">

**Generic information for all unlisted frameworks**

- `example-setup-other-frameworks`

</div>
