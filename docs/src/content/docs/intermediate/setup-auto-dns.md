---
title: "Setup Auto DNS"
---

# Setup Auto DNS

Use the bundled `bind` container to resolve every project under your
`TLD_SUFFIX`. This avoids adding each hostname to `/etc/hosts`.

## How it works

The Devilbox DNS service runs in the `dvlbox`/`bind` container and serves
wildcard records for your configured suffix. If `.env` has
`TLD_SUFFIX=loc`, names like these resolve automatically:

```text
project.loc
www.project.loc
admin.project.loc
```

The DNS answer points at the Devilbox web entrypoint on your host.

:::caution
Do not use `.local` on macOS. Apple reserves it for Multicast DNS.
Prefer `loc`, `lvh.me`, `dvl.to`, or another development-only suffix.
:::

## Configure Devilbox

Edit `.env`:

```bash
nano .env
```

Use a suffix and bind the DNS service to port `53`:

```dotenv
TLD_SUFFIX=loc
LOCAL_LISTEN_ADDR=127.0.0.1:
HOST_PORT_BIND=53
```

Start DNS:

```bash
./dvl.sh up bind
```

Verify the container is running:

```bash
docker compose ps bind
docker compose logs --tail=50 bind
```

:::note
`env-example` defaults `HOST_PORT_BIND` to `1053` to avoid startup
collisions. Host operating systems only use it as a resolver when you
map DNS to port `53`.
:::

## macOS resolver

Create a per-suffix resolver file:

```bash
sudo mkdir -p /etc/resolver
echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/loc
```

Flush the cache:

```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

Verify:

```bash
scutil --dns | grep -A3 'domain : loc'
dig project.loc @127.0.0.1
ping -c1 project.loc
```

If you only need one hostname, use the manual hosts-file flow instead:
[Add project hosts entry on MacOS](/howto/dns/add-project-dns-entry-on-mac/).

## Linux with NetworkManager

Tell NetworkManager to use Devilbox DNS for the suffix:

```bash
nmcli connection show --active
nmcli connection modify "Wired connection 1" \
  +ipv4.dns 127.0.0.1 \
  +ipv4.dns-search loc
nmcli connection up "Wired connection 1"
```

If your connection name differs, replace `Wired connection 1` with the
active name from the first command.

Verify:

```bash
resolvectl query project.loc || getent hosts project.loc
```

## Linux with systemd-resolved

Create a dedicated resolved drop-in:

```bash
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo tee /etc/systemd/resolved.conf.d/devilbox.conf >/dev/null <<'EOF'
[Resolve]
DNS=127.0.0.1
Domains=~loc
EOF
```

Restart the resolver:

```bash
sudo systemctl restart systemd-resolved
```

Verify:

```bash
resolvectl dns
resolvectl domain
resolvectl query project.loc
```

## Port conflicts

If `./dvl.sh up bind` fails, another resolver already owns port `53`.
Find it:

```bash
sudo lsof -nP -iUDP:53 -iTCP:53
```

Stop the conflicting service or keep `HOST_PORT_BIND=1053` and query it
manually:

```bash
dig project.loc @127.0.0.1 -p 1053
```

:::danger
Do not disable your system resolver unless you understand the impact.
Prefer a per-domain resolver on macOS or a routed domain with
systemd-resolved.
:::

## Change the suffix

When `TLD_SUFFIX` changes, update both `.env` and the operating-system
resolver config.

For macOS, replace the resolver file name:

```bash
sudo rm -f /etc/resolver/loc
echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/test
```

Restart DNS:

```bash
./dvl.sh restart bind
```

## Checklist

1. `.env` has `TLD_SUFFIX=loc` or your chosen suffix.
2. `.env` has `HOST_PORT_BIND=53` for OS resolver integration.
3. `./dvl.sh up bind` starts successfully.
4. The host OS sends that suffix to `127.0.0.1`.
5. `project.<suffix>` resolves before opening it in the browser.
