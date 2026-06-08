---
title: Agentic tool toggles
description: Enable or disable agentic image tools at runtime with AGENTIC_TOOLS_ENABLE and AGENTIC_TOOLS_DISABLE.
sidebar:
  order: 52
---

The agentic image installs many AI CLIs, but only a curated set is exposed by
default. Devilbox lets you add or remove tool symlinks at runtime with the same
environment-file pattern used elsewhere in the stack.

## Overview

Each agent tool declares its default-enabled status in its own `options.yml`
file under `../docker-agentic/agentic_tools/<slug>/options.yml`. The effective
default-on set is the union of every tool with `default_enabled: true`.

Default-on agent tools:

- `claude-code`
- `codex`
- `copilot`
- `droid`
- `gemini`
- `kilo-code`
- `kimi`
- `kiro`
- `opencode`
- `pi-coding-agent`
- `qwen-code`
- `reasonix`

Default-on extra tools (built into the `:work` image):

- `openspec`
- `speckit`

The runtime variables in `env-example` are:

```dotenv
AGENTIC_TOOLS_ENABLE=
AGENTIC_TOOLS_DISABLE=
```

`AGENTIC_TOOLS_ENABLE` adds slugs to the default list. `AGENTIC_TOOLS_DISABLE`
removes slugs from the final set.

The implementation is
`../docker-agentic/Dockerfiles/base/data/startup.1.d/20-agentic-toggle.sh`.

## Why this mirrors the PHP-FPM pattern

Devilbox already relies on `.env` values to decide which runtime pieces are
active. For example, `env-example` defines:

```dotenv
CONTAINERS_CONFIG_DEFAULT="bind httpd php mysql"
CONTAINERS_CONFIG_OPTIONAL="php74 php81 php82 php83 php84 redis opensearch buggregator"
```

Agentic tools follow the same principle:

- Defaults are documented in one source-of-truth file.
- Optional items can be added without rebuilding the image.
- Unwanted defaults can be removed without deleting installed files.
- The final active set is computed at container startup.

This makes team onboarding predictable while still allowing per-project lean
images or extra tools.

## How the synchronizer works

At container startup, `20-agentic-toggle.sh`:

1. Reads each `/opt/agentic-tools/<slug>/options.yml` to discover default-enabled slugs.
2. Parses `AGENTIC_TOOLS_ENABLE` as comma-separated slugs.
3. Parses `AGENTIC_TOOLS_DISABLE` as comma-separated slugs.
4. Normalizes values to lowercase and trims whitespace.
5. Unions defaults with enabled slugs.
6. Removes disabled slugs.
7. Scans each `/opt/agentic-tools/<slug>/bin` directory.
8. Creates or removes symlinks under `/usr/local/bin`.

It is idempotent. It does not delete non-symlink files. It only removes symlinks
that point back into `/opt/agentic-tools`.

## Default tool list (agent tools — per-agent images)

| Slug | Image tag | Binary | Install method |
| --- | --- | --- | --- |
| `claude-code` | `:claude-code` | `claude` | `custom` via `https://claude.ai/install.sh` |
| `codex` | `:codex` | `codex` | `custom` via `https://chatgpt.com/codex/install.sh` |
| `copilot` | `:copilot` | `copilot` | `custom` using `gh copilot` extension |
| `droid` | `:droid` | `droid` | `custom` via Factory.ai installer |
| `gemini` | `:gemini` | `gemini` | `npm` package `@google/gemini-cli` |
| `kilo-code` | `:kilo-code` | `kilo` | `npm` package `@kilocode/cli` |
| `kimi` | `:kimi` | `kimi` | `custom` via Kimi Code installer |
| `kiro` | `:kiro` | `kiro-cli` | `custom` via `.deb` package |
| `opencode` | `:opencode` | `opencode` | `custom` via `https://opencode.ai/install` |
| `pi-coding-agent` | `:pi-coding-agent` | `pi` | `custom` via `https://pi.dev/install.sh` |
| `qwen-code` | `:qwen-code` | `qwen` | `npm` package `@qwen-code/qwen-code` |
| `reasonix` | `:reasonix` | `reasonix` | `npm` package `reasonix` |

## Default tool list (extra tools — built into `:work` image)

| Slug | Binary | Install method |
| --- | --- | --- |
| `openspec` | `openspec` | `npm install -g @fission-ai/openspec` |
| `speckit` | `specify` | `pipx install specify-cli` |

## How to enable tools

Add comma-separated slugs to `.env`:

```dotenv
AGENTIC_TOOLS_ENABLE=aider,goose
```

Then restart the stack:

```bash
./dvl.sh agent restart agentic
```

or recreate it:

```bash
./dvl.sh agent down
./dvl.sh agent up
```

The startup synchronizer will create symlinks for enabled slugs that have a
binary under `/opt/agentic-tools/<slug>/bin`.

## How to disable tools

Add comma-separated slugs to `.env`:

```dotenv
AGENTIC_TOOLS_DISABLE=pi-coding-agent,reasonix
```

Restart the stack. The synchronizer removes matching `/usr/local/bin` symlinks
when they point into `/opt/agentic-tools`.

Disable does not uninstall packages from the image. It only removes command
entrypoints from the active tool set.

## Precedence rules

The implementation order in `20-agentic-toggle.sh` is:

1. Start with default-enabled slugs from each tool's `options.yml`.
2. Add `AGENTIC_TOOLS_ENABLE`.
3. Sort and deduplicate.
4. Remove `AGENTIC_TOOLS_DISABLE`.

Therefore, **disable wins** when a slug appears in both lists.

The script prints a warning when the same slug appears in both variables:

```text
[agentic-toggle] WARN: slug 'aider' appears in both ENABLE and DISABLE; DISABLE wins
```

Additional parsing rules:

- Values are comma-separated.
- Whitespace is trimmed.
- Slugs are lowercased.
- There is no `all` wildcard support.
- Unknown slugs do not create commands because no matching tool directory/bin is
  found.

## Worked examples

### Example 1: Add Aider and Goose

```dotenv
AGENTIC_TOOLS_ENABLE=aider,goose
AGENTIC_TOOLS_DISABLE=
```

Result:

- All defaults remain active.
- `aider` and `goose` become active if their installed binaries exist
  (these are host-side or separately installed tools — they reference config
  mounts under `cfg/agentic/` but are not shipped in the Docker image).

### Example 2: Keep a smaller default set

```dotenv
AGENTIC_TOOLS_DISABLE=pi-coding-agent,reasonix
```

Result:

- Default tools are still the base.
- `pi-coding-agent` and `reasonix` are removed from the final active
  set.
- Their files remain in `/opt/agentic-tools`.

### Example 3: Enable Multica CLI with the Multica stack

```dotenv
AGENTIC_TOOLS_ENABLE=multica
MULTICA_API_URL=http://multica-api:8080
```

Then enable both stack layers:

```bash
./dvl.sh agent enable agentic multica
./dvl.sh agent up
```

Use the container-to-container API URL, not the host-side `MULTICA_API_PORT`.

### Example 4: Collision proves disable precedence

```dotenv
AGENTIC_TOOLS_ENABLE=aider
AGENTIC_TOOLS_DISABLE=aider
```

Result: `aider` is disabled, and the startup script emits a warning.

### Example 5: Case and spaces are normalized

```dotenv
AGENTIC_TOOLS_ENABLE="  AIDER ,  GOOSE  "
```

Result: the script treats this as `aider` and `goose`.

## Inspecting the final state

Use `dvl agent tools` to list tool directories known to the sibling
`docker-agentic/agentic_tools` source tree:

```bash
./dvl.sh agent tools
```

Use the container shell to check active commands:

```bash
./dvl.sh agent shell
command -v claude
command -v aider
command -v multica
```

If `command -v` returns nothing, the symlink is not active in `/usr/local/bin`.

## Troubleshooting `tool not found`

### The slug is installed but disabled

Check whether it has `default_enabled: true` in its `options.yml`. If not, add it:

```dotenv
AGENTIC_TOOLS_ENABLE=slug-name
```

Restart the container after editing `.env`.

### The slug is both enabled and disabled

Remove it from `AGENTIC_TOOLS_DISABLE`. Disable wins on collision.

### The slug spelling is wrong

Use exact slugs. Examples include `claude-code`, `copilot`,
`pi-coding-agent`, and `opencode`.

There is no wildcard support and no automatic fuzzy matching.

### The installer did not create a binary

The toggle script only links binaries found under:

```text
/opt/agentic-tools/<slug>/bin
```

If the upstream installer skipped a tool because a release probe failed, there
may be no binary to link. Inspect container startup logs for warnings.

### A command exists but points somewhere else

The script refuses to remove symlinks that point outside `/opt/agentic-tools`.
This protects custom host or image commands. Inspect the link manually inside
the container:

```bash
ls -l /usr/local/bin/<command>
```

### Changes did not apply

The toggle runs at startup from `/opt/agentic-tools/_entrypoint.d/` before the
user-mounted `/startup.1.d`. Restart the `agentic` container after changing
`.env` so the synchronizer runs again.
