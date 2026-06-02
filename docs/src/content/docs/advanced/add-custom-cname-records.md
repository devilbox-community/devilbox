---
title: "Add custom CNAME DNS entries"
---

# Add custom CNAME DNS entries

You can add an infinite number of custom
`wikipedia cname`
records that will be available in your running Docker container. If
Auto-DNS is turned on, those records will be available on your host
operating system as well.

<div class="seealso">

`setup-auto-dns`

</div>


## Why and what?

This might be useful if you have an IP address or hostname on your LAN
or any other domain which you want to expose to your container by a
different CNAME of your choice.

Think of it as setting your `/etc/hosts`, but which will be distributed
accross all hosts which are using the Devilbox' bundled DNS server.

## How?

Adjust the `env-extra-hosts` variable inside `.env` to add as many
CNAME's as you need.

As an example, to create a CNAME `mywebserver.com` pointing to
`172.16.238.1`, change your .env file as shown below:

``` bash
EXTRA_HOSTS=mywebserver.loc=172.16.238.1
```

<div class="seealso">

See `env-extra-hosts` for an in-depth explanation with multiple
examples.

</div>
