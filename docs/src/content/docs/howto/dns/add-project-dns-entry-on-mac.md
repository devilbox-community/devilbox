---
title: "Add project hosts entry on MacOS"
---

# Add project hosts entry on MacOS

macOS resolves names from `/etc/hosts` before DNS. Use it for one-off
project names, or use Devilbox auto DNS for every project under your
`TLD_SUFFIX`.

:::tip
For wildcard project DNS, configure [automatic DNS](/intermediate/setup-auto-dns/)
once instead of editing `/etc/hosts` per project.
:::

## Example project names

Assume `.env` uses `TLD_SUFFIX=loc` and you have these project folders:

| Project directory | URL | Hostname to add |
| --- | --- | --- |
| `project-1` | `http://project-1.loc` | `project-1.loc` |
| `www.project-1` | `http://www.project-1.loc` | `www.project-1.loc` |

Use `127.0.0.1` with Docker Desktop on macOS.

## Add entries

Open the hosts file:

```bash
sudo nano /etc/hosts
```

Add one line per hostname:

```text
127.0.0.1  project-1.loc
127.0.0.1  www.project-1.loc
```

Save the file, then flush the resolver cache:

```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

## Verify

Check that macOS returns loopback:

```bash
ping -c1 project-1.loc
ping -c1 www.project-1.loc
```

Expected result:

```text
PING project-1.loc (127.0.0.1): 56 data bytes
64 bytes from 127.0.0.1: icmp_seq=0 ttl=64 time=0.050 ms
```

Open the site:

```bash
open http://project-1.loc
```

## Use auto DNS instead

Start the DNS container and configure macOS once:

```bash
./dvl.sh up bind
sudo mkdir -p /etc/resolver
echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/loc
```

Now every `*.loc` name resolves through Devilbox.

:::caution
Avoid `.local` for Devilbox projects on macOS. Apple reserves it for
Multicast DNS, so normal resolver rules are not reliable.
:::

## Remove an entry

Edit the file again, delete the matching line, and flush the cache:

```bash
sudo nano /etc/hosts
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```
