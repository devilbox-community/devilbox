---
title: "Add custom DNS server on Windows"
---

orphan  

# Add custom DNS server on Windows


## Assumption

This tutorial is using `127.0.0.1` as the DNS server IP address, as it
is the method to setup Auto DNS for your local Devilbox.

## Network preferences

On Windows, you need to change your active network adapter. See the
following screenshots for how to do it.

<figure>
<img
src="/_includes/figures/dns-server/windows/win-network-connections.png"
alt="Windows: network connections" />
<figcaption aria-hidden="true">Windows: network connections</figcaption>
</figure>

<figure>
<img
src="/_includes/figures/dns-server/windows/win-ethernet-properties.png"
alt="Windows: ethernet properties" />
<figcaption aria-hidden="true">Windows: ethernet properties</figcaption>
</figure>

<figure>
<img
src="/_includes/figures/dns-server/windows/win-internet-protocol-properties.png"
alt="Windows: internet protocol properties" />
<figcaption aria-hidden="true">Windows: internet protocol
properties</figcaption>
</figure>

In the last screenshot, you will have to add `127.0.0.1` as your
`Preferred DNS server`.
