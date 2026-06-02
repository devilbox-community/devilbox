---
title: "Virtual host templates"
---

# Virtual host templates


## Overview

### What is it?

vhost-gen templates are yaml files which contain a general definition
for a virtual host definition. Those templates contain placeholders in
the form of `__<NAME>__` which will be replaced by settings applied to
the Devilbox.

<div class="seealso">

`project vhost gen`

</div>

### Template files

By default, vhost-gen templates are located within the Devilbox root
directory under `cfg/vhost-gen/`. The templates file names are suffixed
with `-example-<type>` and are absolutely identical to what is shipped
inside each Devilbox web server Docker container.

> [!NOTE]
> Also note that nginx stable and nginx mainline share the same template
> as their configuration syntax is identical.

#### Normal virtual host

All template files ending by `-example-vhost` can be used to customize a
normal file serving virtual host.

``` bash
host> tree -L 1 cfg/vhost-gen/

cfg/vhost-gen/
├── apache22.yml-example-rproxy
├── apache22.yml-example-vhost
├── apache24.yml-example-rproxy
├── apache24.yml-example-vhost
├── nginx.yml-example-rproxy
├── nginx.yml-example-vhost
└── README.md

0 directories, 7 files
```

#### Reverse proxy

All template files ending by `-example-rproxy` can be used to create a
reverse proxy for your project.

``` bash
host> tree -L 1 cfg/vhost-gen/

cfg/vhost-gen/
├── apache22.yml-example-rproxy
├── apache22.yml-example-vhost
├── apache24.yml-example-rproxy
├── apache24.yml-example-vhost
├── nginx.yml-example-rproxy
├── nginx.yml-example-vhost
└── README.md

0 directories, 7 files
```

### Template sections

All vhost-gen templates consist of three sections:

| Section | Description |
|----|----|
| `vhost` | This is the part that is actually rendered into the vhost configuration. All other `br` sections will be inserted into this one. |
| `vhost-type` | The vhost type determines the type of vhost: reverse proxy or document root based `br` vhost. The Devilbox currently does not support reverse proxy vhost. |
| `features` | The feature section contains many sub-sections that are replaced into the `vhost` `br` section before final rendering. |

## Virtual host Templates

These templates can be used to alter the behaviour of the vhost on a per
project base or globally.

### Apache 2.2 template

<div class="literalinclude" caption="apache22.yml-example-vhost"
language="yaml">

../../cfg/vhost-gen/apache22.yml-example-vhost

</div>

### Apache 2.4 template

<div class="literalinclude" caption="apache24.yml-example-vhost"
language="yaml">

../../cfg/vhost-gen/apache24.yml-example-vhost

</div>

### Nginx template

<div class="literalinclude" caption="nginx.yml-example-vhost"
language="yaml">

../../cfg/vhost-gen/nginx.yml-example-vhost

</div>

## Reverse proxy Templates

These templates can be used to change a normal vhost into a reverse
proxy project. This might be useful if you use NodeJs applications for
example.

> [!IMPORTANT]
> Do not apply those templates globally. They are intended to be used on
> a per project base.

> [!NOTE]
> In order to use the Reverse Proxy templates you will only need to
> adjust the listening port, everything else will work as already
> defined. So you simply need to copy those files into your project
> directory. Lines that need to be changed are marked below. The
> currently set default listening port is `8000`.

### Apache 2.2 template

<div class="literalinclude" caption="apache22.yml-example-rproxy"
language="yaml" emphasize-lines="51,52">

../../cfg/vhost-gen/apache22.yml-example-rproxy

</div>

### Apache 2.4 template

<div class="literalinclude" caption="apache24.yml-example-rproxy"
language="yaml" emphasize-lines="51,52">

../../cfg/vhost-gen/apache24.yml-example-rproxy

</div>

### Nginx template

<div class="literalinclude" caption="nginx.yml-example-rproxy"
language="yaml" emphasize-lines="53">

../../cfg/vhost-gen/nginx.yml-example-rproxy

</div>
