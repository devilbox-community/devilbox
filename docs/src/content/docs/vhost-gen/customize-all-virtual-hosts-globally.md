---
title: "Customize all virtual hosts globally"
---

# Customize all virtual hosts globally


## Prerequisite

Ensure you have read and understood how vhost-gen templates work and
where to find them

<div class="seealso">

`vhost-gen-virtual-host-templates`

</div>

## Apply templates globally to all vhosts

When applying those templates, you do it globally for all projects. The
only exception is if you have already a specific vhost template for a
project in place.

<div class="seealso">

`vhost-gen-customize-specific-virtual-host`

</div>

In order for template files to be picked up by the web server they must
be copied to their correct filename.

| Web server     | Example template             | Template name  |
|----------------|------------------------------|----------------|
| Apache 2.2     | `apache22.yml-example-vhost` | `apache22.yml` |
| Apache 2.4     | `apache24.yml-example-vhost` | `apache24.yml` |
| Nginx stable   | `nginx.yml-example-vhost`    | `nginx.yml`    |
| Nginx mainline | `nginx.yml-example-vhost`    | `nginx.yml`    |

> [!IMPORTANT]
> Do not use `*.yml-example-rproxy` templates for global configuration.
> These are only intended to be used on a per project base.

> [!NOTE]
> If you simply copy the files to their corresponding template file
> name, nothing will change as those templates reflect the same values
> the web servers are using.

### Apache 2.2

1.  Navigate to `cfg/vhost-gen/` inside the Devilbox directory
2.  Copy `apache22.yml-example-vhost` to `apache22.yml` and restart the
    Devilbox
3.  Whenever you adjust `apache22.yml`, you need to restart the Devilbox

### Apache 2.4

1.  Navigate to `cfg/vhost-gen/` inside the Devilbox directory
2.  Copy `apache24.yml-example-vhost` to `apache24.yml` and restart the
    Devilbox
3.  Whenever you adjust `apache24.yml`, you need to restart the Devilbox

### Nginx stable and Nginx mainline

1.  Navigate to `cfg/vhost-gen/` inside the Devilbox directory
2.  Copy `nginx.yml-example-vhost` to `nginx.yml` and restart the
    Devilbox
3.  Whenever you adjust `nginx.yml`, you need to restart the Devilbox
