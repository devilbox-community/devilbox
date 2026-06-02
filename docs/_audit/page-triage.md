# Devilbox Docs Migration — Page Triage Audit (D2.0)

Generated 2026-06-02 against `mainline` (post-commit 4056d788).

## Summary

| Classification | Count |
|---|---:|
| KEEP_AS_IS | 0 |
| MINOR_UPDATE | 167 |
| MAJOR_REWRITE | 66 |
| DEPRECATE | 2 |
| **Total** | 235 |

## Methodology

All `.rst` files under `docs/` were inventoried and scored with three heuristics: Flag A for stale terms, Flag B for last git edit date before 2024-12-02, and Flag C for files over 1000 lines. The default classification followed the D2.0 rubric; all 85 pages with 2 or 3 flags were read via `/tmp/d20-borderline-combined.rst` before assigning the final classification and note.

Script used to compute flags:

```bash
#!/usr/bin/env bash
set -euo pipefail
repo="${1:-/Users/toanguye/Workspace/agentic_data/devilbox-source/devilbox}"
cd "$repo"
# 2024-12-02 00:00:00 UTC: pages before this are >18 months old from 2026-06-02.
threshold=1733097600
terms=(
  './shell.sh'
  'php7.0'
  'php7.1'
  'php5'
  'python2'
  'mariadb-10.0'
  'mariadb-10.1'
  'node10'
  'node12'
  'node14'
  'node16'
  'node18'
  'mongo3'
  'mongo4'
  'redis4'
  'redis5'
  'docker-compose '
  'Docker for Mac'
  'Boot2Docker'
  'Vagrant'
)
while IFS= read -r path; do
  lines=$(python3 -c 'import sys; print(sum(1 for _ in open(sys.argv[1], "rb")))' "$path")
  last=$(GIT_MASTER=1 git -C "$repo" log -1 --format=%ct -- "$path" || true)
  flag_b=0
  if [[ -z "${last}" || "${last}" -lt "$threshold" ]]; then
    flag_b=1
  fi
  flag_a=0
  for term in "${terms[@]}"; do
    if grep -Fqi -- "$term" "$path"; then
      flag_a=1
      break
    fi
  done
  flag_c=0
  if [[ "$lines" -gt 1000 ]]; then
    flag_c=1
  fi
  total=$((flag_a + flag_b + flag_c))
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$path" "$lines" "$flag_a" "$flag_b" "$flag_c" "$total"
done < /tmp/d20-files.txt
```

## Per-page table

### Section: ./

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/devilbox-purpose.rst | 78 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/features.rst | 158 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/index.rst | 235 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/read-first.rst | 54 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/all.rst | 38 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/figures/blogs/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/figures/blogs/youtube-email-catch-all.rst | 2 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/blogs/youtube-setup-and-workflow.rst | 2 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/figures/devilbox/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/figures/devilbox/devilbox-intranet-dash-all.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/devilbox/devilbox-intranet-dash-selective.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/devilbox/devilbox-intranet-emails.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/devilbox/devilbox-intranet-index.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/devilbox/devilbox-intranet-mysql-databases.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/devilbox/devilbox-intranet-mysql-info.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/devilbox/devilbox-intranet-php-info.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/devilbox/devilbox-intranet-vhosts-empty.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/devilbox/devilbox-intranet-vhosts-missing-dns.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/devilbox/devilbox-intranet-vhosts-missing-htdocs.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/devilbox/devilbox-intranet-vhosts-working.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/devilbox/devilbox-intranet-vhosts.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/devilbox/devilbox-project-hello-world.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/devilbox/devilbox-project-missing-index.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/figures/dns-server/android/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/figures/dns-server/android/android-wifi-advanced-options.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/dns-server/android/android-wifi-list.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/dns-server/android/android-wifi-select-dhcp-options-static.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/dns-server/android/android-wifi-select-dhcp-options.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/dns-server/android/android-wifi-set-dns-server.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/figures/dns-server/iphone/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/figures/dns-server/iphone/iphone-wifi-list.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/dns-server/iphone/iphone-wifi-select-manual.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/dns-server/iphone/iphone-wifi-set-dns-server.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/dns-server/iphone/iphone-wifi-settings.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/figures/dns-server/mac/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/figures/dns-server/mac/mac-network-settings.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/figures/dns-server/windows/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/figures/dns-server/windows/win-ethernet-properties.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/dns-server/windows/win-internet-protocol-properties.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/dns-server/windows/win-network-connections.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/figures/examples/contao/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/figures/examples/contao/01-frontend.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/contao/02-license.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/contao/03-install-tool-password.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/contao/04-database-setup.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/contao/05-update-database.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/contao/06-create-admin-user.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/contao/07-finished.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/contao/08-login-screen.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/figures/examples/processwire/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/figures/examples/processwire/01-install-banner.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/processwire/02-profile-choice.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/processwire/03-default-profile.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/processwire/04-compat-check.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/processwire/05-general-setup.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/processwire/06-admin-setup.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/processwire/07-finished.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/figures/examples/wordpress/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/figures/examples/wordpress/01-choose-language.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/wordpress/02-overview.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/wordpress/03-setup-database.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/wordpress/04-finished-database.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/wordpress/05-installation.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/wordpress/06-finished-installation.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/examples/wordpress/07-login.rst | 4 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/figures/https/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/figures/https/chrome-advanced-settings.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/https/chrome-manage-certificates.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/https/chrome-set-trust.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/https/chrome-settings.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/https/file-manager-import-ca.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/https/firefox-certificate-manager.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/https/firefox-preferences.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/https/firefox-privacy-and-security.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/https/firefox-set-trust.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/https/https-ssl-address-bar.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/figures/terminal/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/figures/terminal/docker-toolbox-terminal-mac-quickstart-launchpad.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/terminal/docker-toolbox-terminal-win-quickstart-shortcut.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/terminal/docker-toolbox-terminal-win-quickstart-terminal.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/figures/xdebug/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/figures/xdebug/phpstorm-dbgp-proxy.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/xdebug/phpstorm-path-mapping.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/xdebug/phpstorm-settings.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/figures/xdebug/windows/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/figures/xdebug/windows/ipconfig.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/figures/xdebug/windows/virtual-switch-manager.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/html/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/html/defaults.rst | 3 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/images/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/images/external.rst | 5 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/links/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/links/apps.rst | 12 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/links/blogs.rst | 35 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/links/dns.rst | 29 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/links/docker-compose.rst | 88 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/links/docker-images.rst | 35 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/links/docker.rst | 140 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Docker Desktop/Toolbox-era guidance is central to the page. |
| docs/_includes/links/documentation.rst | 150 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/links/examples.rst | 143 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/links/git.rst | 5 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/links/prerequistes.rst | 35 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Docker Desktop/Toolbox-era guidance is central to the page. |
| docs/_includes/links/ssh.rst | 12 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/links/ssl.rst | 23 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/links/tools.rst | 358 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/links/uid.rst | 5 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/links/xdebug.rst | 53 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/snippets/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/snippets/__ANNOUNCEMENTS__.rst | 11 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/snippets/additional-container.rst | 27 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/snippets/core-container.rst | 19 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/_includes/snippets/docker-compose-override-tree-view.rst | 26 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: _includes/snippets/examples/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/_includes/snippets/examples/next-steps.rst | 45 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: advanced/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/advanced/add-custom-cname-records.rst | 45 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/advanced/add-your-own-docker-image.rst | 179 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: tutorial commands and Compose schema examples are central and outdated. |
| docs/advanced/connect-to-external-hosts.rst | 19 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/advanced/connect-to-host-os.rst | 172 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Docker Toolbox/Docker for Mac legacy sections dominate host-connectivity guidance. |
| docs/advanced/connect-to-other-docker-container.rst | 78 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/advanced/customize-php-globally.rst | 85 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/advanced/customize-webserver-globally.rst | 58 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/advanced/overwrite-existing-docker-image.rst | 113 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: autostart/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/autostart/autostarting-nodejs-apps.rst | 100 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
| docs/autostart/custom-scripts-globally.rst | 100 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/autostart/custom-scripts-per-php-version.rst | 195 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: configuration-files/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/configuration-files/apache-conf.rst | 134 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/configuration-files/bashrc-sh.rst | 108 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/configuration-files/docker-compose-override-yml.rst | 93 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: concept still applies; update Compose terminology/version examples. |
| docs/configuration-files/docker-compose-yml.rst | 15 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/configuration-files/env-file.rst | 1820 | 1 | 1 | 1 | MAJOR_REWRITE | Reviewed: bloated reference includes many removed PHP/DB/Redis/Mongo versions and missing 2026 env vars. |
| docs/configuration-files/my-cnf.rst | 125 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: MySQL/MariaDB version matrix examples are dominated by removed versions. |
| docs/configuration-files/nginx-conf.rst | 130 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/configuration-files/php-fpm-conf.rst | 200 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/configuration-files/php-ini.rst | 126 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: corporate-usage/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/corporate-usage/shared-devilbox-server-in-lan.rst | 214 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/corporate-usage/showcase-over-the-internet.rst | 134 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/corporate-usage/use-external-databases.rst | 91 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |

### Section: custom-container/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/custom-container/enable-all-container.rst | 67 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: container enablement workflow relies on Compose v1 override commands; update to current container roster/CLI. |
| docs/custom-container/enable-blackfire.rst | 230 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: container enablement workflow relies on Compose v1 override commands; update to current container roster/CLI. |
| docs/custom-container/enable-elk-stack.rst | 252 | 1 | 1 | 0 | DEPRECATE | Reviewed: page documents legacy ELK images that are removed/replaced by current OpenSearch-era stack. |
| docs/custom-container/enable-mailhog.rst | 179 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: container enablement workflow relies on Compose v1 override commands; update to current container roster/CLI. |
| docs/custom-container/enable-meilisearch.rst | 153 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: container enablement workflow relies on Compose v1 override commands; update to current container roster/CLI. |
| docs/custom-container/enable-ngrok.rst | 190 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: container enablement workflow relies on Compose v1 override commands; update to current container roster/CLI. |
| docs/custom-container/enable-php-community.rst | 135 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: container enablement workflow relies on Compose v1 override commands; update to current container roster/CLI. |
| docs/custom-container/enable-python-flask.rst | 149 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/custom-container/enable-rabbitmq.rst | 171 | 1 | 1 | 0 | DEPRECATE | Reviewed: page documents the removed legacy RabbitMQ container workflow. |
| docs/custom-container/enable-solr.rst | 153 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: container enablement workflow relies on Compose v1 override commands; update to current container roster/CLI. |
| docs/custom-container/enable-varnish.rst | 256 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: container enablement workflow relies on Compose v1 override commands; update to current container roster/CLI. |

### Section: examples/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/examples/setup-cakephp.rst | 224 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-codeigniter.rst | 223 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-codeigniter4.rst | 216 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-contao.rst | 270 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-craftcms.rst | 249 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-drupal.rst | 177 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-expressionengine.rst | 205 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-joomla.rst | 176 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-laravel.rst | 178 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-magento2.rst | 216 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-other-frameworks.rst | 15 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/examples/setup-phalcon.rst | 198 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-photon-cms.rst | 182 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-presta-shop.rst | 201 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-processwire.rst | 213 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-reverse-proxy-nodejs.rst | 443 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-reverse-proxy-python-flask.rst | 449 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-reverse-proxy-sphinx-docs.rst | 430 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-shopware.rst | 202 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-symfony.rst | 173 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-typo3.rst | 219 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-wordpress.rst | 212 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-yii.rst | 180 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |
| docs/examples/setup-zend.rst | 177 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: example workflow uses legacy shell entrypoint and old framework/runtime versions throughout. |

### Section: getting-started/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/getting-started/change-container-versions.rst | 258 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: version-change examples center removed PHP versions and Compose v1. |
| docs/getting-started/create-your-first-project.rst | 221 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/getting-started/devilbox-intranet.rst | 168 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/getting-started/directory-overview.rst | 137 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/getting-started/enter-the-php-container.rst | 127 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: canonical shell entrypoint is obsolete; page purpose is entering the container. |
| docs/getting-started/important.rst | 61 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
| docs/getting-started/install-the-devilbox.rst | 165 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Docker Desktop/Toolbox-era guidance is central to the page. |
| docs/getting-started/prerequisites.rst | 238 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: supported OS/Docker Toolbox/Compose v1 prerequisites are central. |
| docs/getting-started/start-the-devilbox.rst | 189 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: startup commands are dominated by docker-compose v1 and old container assumptions. |

### Section: howto/devilbox/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/howto/devilbox/find-docker-and-docker-compose-version.rst | 25 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
| docs/howto/devilbox/move-backups-to-different-directory.rst | 40 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/howto/devilbox/move-projects-to-different-directory.rst | 89 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: howto/dns/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/howto/dns/add-custom-dns-server-on-android.rst | 54 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/howto/dns/add-custom-dns-server-on-iphone.rst | 50 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/howto/dns/add-custom-dns-server-on-linux.rst | 129 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/howto/dns/add-custom-dns-server-on-mac.rst | 33 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/howto/dns/add-custom-dns-server-on-win.rst | 33 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/howto/dns/add-project-dns-entry-on-linux.rst | 67 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/howto/dns/add-project-dns-entry-on-mac.rst | 109 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Docker Desktop/Toolbox-era guidance is central to the page. |
| docs/howto/dns/add-project-dns-entry-on-win.rst | 103 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: howto/docker-toolbox/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/howto/docker-toolbox/docker-toolbox-and-the-devilbox.rst | 212 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/howto/docker-toolbox/find-docker-toolbox-ip-address.rst | 50 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/howto/docker-toolbox/ssh-into-docker-toolbox.rst | 138 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/howto/docker-toolbox/ssh-port-forward-on-docker-toolbox-from-host.rst | 112 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/howto/docker-toolbox/ssh-port-forward-on-host-to-docker-toolbox.rst | 108 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: howto/terminal/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/howto/terminal/open-terminal-on-mac.rst | 96 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Docker Desktop/Toolbox-era guidance is central to the page. |
| docs/howto/terminal/open-terminal-on-win.rst | 57 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: howto/uid-and-gid/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/howto/uid-and-gid/find-uid-and-gid-on-mac.rst | 53 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Docker Desktop/Toolbox-era guidance is central to the page. |
| docs/howto/uid-and-gid/find-uid-and-gid-on-win.rst | 53 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: howto/xdebug/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/howto/xdebug/host-address-alias-an-mac.rst | 51 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Docker Desktop/Toolbox-era guidance is central to the page. |

### Section: intermediate/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/intermediate/add-custom-environment-variables.rst | 53 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/intermediate/best-practice.rst | 148 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
| docs/intermediate/configure-php-xdebug.rst | 110 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/intermediate/email-catch-all.rst | 31 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/intermediate/enable-disable-php-modules.rst | 66 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/intermediate/read-log-files.rst | 92 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
| docs/intermediate/setup-auto-dns.rst | 157 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Docker Desktop/Toolbox-era guidance is central to the page. |
| docs/intermediate/setup-valid-https.rst | 139 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/intermediate/source-code-analysis.rst | 111 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/intermediate/work-inside-the-php-container.rst | 252 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: canonical shell entrypoint is obsolete; page purpose is working inside containers. |

### Section: intermediate/configure-php-xdebug/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/intermediate/configure-php-xdebug/php-xdebug-options.rst | 81 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: intermediate/configure-php-xdebug/linux/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/intermediate/configure-php-xdebug/linux/atom.rst | 161 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |
| docs/intermediate/configure-php-xdebug/linux/phpstorm.rst | 137 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |
| docs/intermediate/configure-php-xdebug/linux/sublime.rst | 146 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |
| docs/intermediate/configure-php-xdebug/linux/vscode.rst | 171 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |

### Section: intermediate/configure-php-xdebug/macos/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/intermediate/configure-php-xdebug/macos/atom.rst | 152 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |
| docs/intermediate/configure-php-xdebug/macos/phpstorm.rst | 145 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |
| docs/intermediate/configure-php-xdebug/macos/sublime.rst | 152 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |
| docs/intermediate/configure-php-xdebug/macos/vscode.rst | 172 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |

### Section: intermediate/configure-php-xdebug/toolbox/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/intermediate/configure-php-xdebug/toolbox/atom.rst | 164 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |
| docs/intermediate/configure-php-xdebug/toolbox/phpstorm.rst | 157 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |
| docs/intermediate/configure-php-xdebug/toolbox/sublime.rst | 166 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |
| docs/intermediate/configure-php-xdebug/toolbox/vscode.rst | 184 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |

### Section: intermediate/configure-php-xdebug/windows/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/intermediate/configure-php-xdebug/windows/atom.rst | 181 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |
| docs/intermediate/configure-php-xdebug/windows/phpstorm.rst | 170 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |
| docs/intermediate/configure-php-xdebug/windows/sublime.rst | 179 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |
| docs/intermediate/configure-php-xdebug/windows/vscode.rst | 197 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Xdebug examples rely on removed PHP versions and legacy Xdebug 2 settings. |

### Section: maintenance/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/maintenance/backup-and-restore-mongo.rst | 63 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
| docs/maintenance/backup-and-restore-mysql.rst | 292 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
| docs/maintenance/backup-and-restore-pgsql.rst | 125 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
| docs/maintenance/checkout-different-devilbox-release.rst | 31 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/maintenance/remove-stopped-container.rst | 33 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
| docs/maintenance/remove-the-devilbox.rst | 133 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
| docs/maintenance/update-the-devilbox.rst | 221 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: default branch and image/version examples contradict current mainline and 2026 versions. |

### Section: readings/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/readings/available-container.rst | 39 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/readings/available-tools.rst | 120 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/readings/syncronize-container-permissions.rst | 92 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: reverse-proxy/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/reverse-proxy/reverse-proxy-for-custom-docker.rst | 264 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
| docs/reverse-proxy/reverse-proxy-with-https.rst | 251 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |

### Section: support/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/support/artwork.rst | 28 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/support/blogs-videos-and-use-cases.rst | 65 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/support/faq.rst | 269 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/support/howto.rst | 43 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/support/troubleshooting.rst | 407 | 1 | 1 | 0 | MAJOR_REWRITE | Reviewed: Docker Desktop/Toolbox-era guidance is central to the page. |

### Section: third-party/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/third-party/devilbox-cli.rst | 20 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/third-party/nginx-acme.rst | 19 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |

### Section: vhost-gen/

| Path | Lines | Flag A (stale terms) | Flag B (stale date) | Flag C (bloat) | Classification | Notes |
|---|---:|---:|---:|---:|---|---|
| docs/vhost-gen/customize-all-virtual-hosts-globally.rst | 78 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/vhost-gen/customize-specific-virtual-host.rst | 417 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
| docs/vhost-gen/example-add-subdomains.rst | 578 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
| docs/vhost-gen/virtual-host-templates.rst | 172 | 0 | 1 | 0 | MINOR_UPDATE | Flag B only: stale edit date; no stale-term or bloat flags. |
| docs/vhost-gen/virtual-host-vs-reverse-proxy.rst | 63 | 1 | 1 | 0 | MINOR_UPDATE | Reviewed: stale terms are localized; preserve page with focused updates. |
