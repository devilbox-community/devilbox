---
title: "Setup valid HTTPS"
---

# Setup valid HTTPS

This page shows you how to use the Devilbox on https and how to import
the Certificate Authority into your browser once, so that you always and
automatically get valid SSL certificates for all new projects.

SSL certificates are generated automatically and there is nothing to do
from your side.

<figure>
<img src="/_includes/figures/https/https-ssl-address-bar.png"
alt="Valid HTTPS will automatically be available for all projects" />
<figcaption aria-hidden="true">Valid HTTPS will automatically be
available for all projects</figcaption>
</figure>


## TL;DR

Import the Certificate Authority into your browser and you are all set.

## How does it work

### Certificate Authority

When the Devilbox starts up for the first time, it will generate a
`ssl certificate authority`
and will store its public and private key in `./ca/` within the Devilbox
git directory.

The keys are only generated if they don't exist and kept permanently if
you don't delete them manually, i.e. they are not overwritten.

``` bash
host> cd path/to/devilbox
host> ls -l ca/
-rw-r--r--  1 cytopia cytopia 1558 May  2 11:12 devilbox-ca.crt
-rw-------  1 cytopia cytopia 1675 May  2 11:12 devilbox-ca.key
-rw-r--r--  1 cytopia cytopia   17 May  4 08:35 devilbox-ca.srl
```

### SSL Certificates

Whenever you create a new project directory, multiple things happen in
the background:

1.  A new virtual host is created
2.  DNS is provided via `setup-auto-dns`
3.  A new SSL certificate is generated for that vhost
4.  **The SSL certificate is signed by the Devilbox Certificate
    Authority**

By having a SSL certificates signed by the provided CA, you will only
have to import the CA into your browser ones and all current projects
and future projects will automatically have valid and trusted SSL
certificates without any further work.

## Import the CA into your browser

> [!IMPORTANT]
> Importing the CA into the browser is also recommended and required for
> the Devilbox intranet page to work properly. You may also import the
> CA into your Operating System's Keystore. Information on that is
> available at
> `ssl gfi root cert guide`.

### Chrome / Chromium

Open Chrome settings, scroll down to the very bottom and click on
`Advanced` to expand the advanced settings.

<figure>
<img src="/_includes/figures/https/chrome-settings.png"
alt="Click on Advanced" />
<figcaption aria-hidden="true">Click on
<code>Advanced</code></figcaption>
</figure>

Find the setting `Manage certificates` and open it.

<figure>
<img src="/_includes/figures/https/chrome-advanced-settings.png"
alt="Click on Manage certificates" />
<figcaption aria-hidden="true">Click on
<code>Manage certificates</code></figcaption>
</figure>

Navigate to the tab setting `AUTHORITIES` and click on `IMPORT`.

<figure>
<img src="/_includes/figures/https/chrome-manage-certificates.png"
alt="Click on IMPORT in the AUTHORITIES tab" />
<figcaption aria-hidden="true">Click on <code>IMPORT</code> in the
AUTHORITIES tab</figcaption>
</figure>

Select `devilbox-ca.crt` from within the Devilbox `./ca` directory:

<figure>
<img src="/_includes/figures/https/file-manager-import-ca.png"
alt="Note: your file manager might look different" />
<figcaption aria-hidden="true"><strong>Note</strong>: your file manager
might look different</figcaption>
</figure>

As the last step you are asked what permissions you want to grant the
newly importat CA. To make sure it works everywhere, check all options
and proceed with `OK`.

<figure>
<img src="/_includes/figures/https/chrome-set-trust.png"
alt="Tell Chrome to trust this CA" />
<figcaption aria-hidden="true">Tell Chrome to trust this CA</figcaption>
</figure>

Now you are all set and all generated SSL certificates will be valid
from now on.

<figure>
<img src="/_includes/figures/https/https-ssl-address-bar.png"
alt="Valid HTTPS will automatically be available for all projects" />
<figcaption aria-hidden="true">Valid HTTPS will automatically be
available for all projects</figcaption>
</figure>

Note: if you are on Chrome on Mac Big Sur and above, you won't find the
above settings, you will have to go the "Keychain Access" application,
click on `System` in the left hand corner and then drag in the
`devilbox-ca.crt`, it will ask for your password to complete the
operation. once that is done, the cert will be listed but will not be
trusted by default. Now right click on the imported cert, click on Info,
an info dialog will open up and you can expand the 'Trust' accordian and
set it to `Trust All`. Now you are all set and all generated SSL
certificates will be valid from now on.

### Firefox

Open Firefox settings and click on `Privacy & Security`.

<figure>
<img src="/_includes/figures/https/firefox-preferences.png"
alt="Click on Privacy &amp; Security in the left menu bar" />
<figcaption aria-hidden="true">Click on
<code>Privacy &amp; Security</code> in the left menu bar</figcaption>
</figure>

At the very bottom click on the button `View Certificates`.

<figure>
<img src="/_includes/figures/https/firefox-privacy-and-security.png"
alt="Click on View Certificates" />
<figcaption aria-hidden="true">Click on
<code>View Certificates</code></figcaption>
</figure>

In the `Authories` tab, click on `Import`.

<figure>
<img src="/_includes/figures/https/firefox-certificate-manager.png"
alt="Click on Import in the Authorities tab" />
<figcaption aria-hidden="true">Click on <code>Import</code> in the
Authorities tab</figcaption>
</figure>

Select `devilbox-ca.crt` from within the Devilbox `./ca` directory:

<figure>
<img src="/_includes/figures/https/file-manager-import-ca.png"
alt="Note: your file manager might look different" />
<figcaption aria-hidden="true"><strong>Note</strong>: your file manager
might look different</figcaption>
</figure>

As the last step you are asked what permissions you want to grant the
newly importat CA. To make sure it works everywhere, check all options
and proceed with `OK`.

<figure>
<img src="/_includes/figures/https/firefox-set-trust.png"
alt="Tell Firefox to trust this CA" />
<figcaption aria-hidden="true">Tell Firefox to trust this
CA</figcaption>
</figure>

Now you are all set and all generated SSL certificates will be valid
from now on.

<figure>
<img src="/_includes/figures/https/https-ssl-address-bar.png"
alt="Valid HTTPS will automatically be available for all projects" />
<figcaption aria-hidden="true">Valid HTTPS will automatically be
available for all projects</figcaption>
</figure>

## Further Reading

<div class="seealso">

`.env` variable: `env-devilbox-ui-ssl-cn`

</div>
