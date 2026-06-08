---
title: Agentic authentication
description: Authenticate AI CLI tools in the Devilbox agentic container with OAuth, API keys, and persistent config mounts.
sidebar:
  order: 51
---

import { Tabs, TabItem } from '@astrojs/starlight/components'

Agentic tools often need a one-time login before they can edit code. Devilbox
keeps those credentials inside persistent tool-specific directories while using
a host bridge for browser-based OAuth flows.

## Overview of OAuth and API key flows

There are two common authentication shapes:

1. **OAuth or browser login**: the CLI prints or opens a browser URL. Devilbox
   routes that URL from the container to the host, where your normal browser can
   complete the login.
2. **API key or token login**: the CLI reads a key from an environment variable,
   a config file, or an interactive prompt. Devilbox persists the resulting
   config under `cfg/` bind mounts.

The command entrypoint is:

```bash
./dvl.sh agent auth <tool-slug>
```

The handler in `dvl.sh` is the `auth` case of `AgentCommand`:

- It exports the layered `COMPOSE_FILE` first.
- It requires a slug: `dvl agent auth <tool-slug>`.
- It expects an executable bridge at `.devilbox/oauth-bridge.sh`.
- It executes that bridge with the tool slug.

The agentic stack publishes the OAuth callback receiver on:

```dotenv
AGENTIC_OAUTH_PORT=19999
```

The stack also mounts the OAuth FIFO:

```text
.devilbox/oauth-fifo -> /var/run/dvl-oauth
```

Inside the image, `10-oauth-helper.sh` installs `/usr/local/bin/dvl-open-host`
and writes `BROWSER=/usr/local/bin/dvl-open-host` to
`/etc/profile.d/dvl-browser.sh`. When a CLI asks to open a browser URL, that
shim writes the URL to `/var/run/dvl-oauth/url` for the host-side bridge.

## Host-Bridge mechanism

The bridge has three parts:

| Part | Location | Role |
| --- | --- | --- |
| `dvl agent auth <tool-slug>` | `dvl.sh` | Validates the slug and runs `.devilbox/oauth-bridge.sh`. |
| OAuth FIFO | `.devilbox/oauth-fifo` mounted at `/var/run/dvl-oauth` | Carries browser URLs from container to host. |
| `dvl-open-host` | `/usr/local/bin/dvl-open-host` inside the agentic image | Replaces `BROWSER` and writes requested URLs to the FIFO. |

The flow is:

1. Start the stack with `./dvl.sh agent up`.
2. Run `./dvl.sh agent auth claude-code` or another tool slug.
3. The host bridge prepares to receive a URL.
4. The tool starts its login flow inside the container.
5. The tool calls `$BROWSER`.
6. `$BROWSER` is `dvl-open-host`, which writes the URL to the FIFO.
7. The host bridge opens that URL in your host browser.
8. The tool stores credentials under its persistent config directory.

The bridge keeps browser interaction on the host while credential files remain
inside Devilbox-controlled bind mounts.

## Per-tool authentication table

The default-on tool list comes from each tool's `options.yml`
under `../docker-agentic/agentic_tools/<slug>/options.yml`.

### Agent tools (per-agent images — 12 tools)

| Tool slug | Auth method | Browser? | Persisted to |
| --- | --- | --- | --- |
| `claude-code` | Claude Code OAuth or Anthropic account login through the CLI. | Yes, through host bridge when browser login is used. | `cfg/agentic/claude` mounted at `/home/devilbox/.claude`. |
| `codex` | OpenAI Codex login or OpenAI API key configuration. | Optional; API key flows can be terminal-only. | `cfg/agentic/codex` mounted at `/home/devilbox/.codex`. |
| `copilot` | GitHub CLI authentication plus Copilot extension. | Yes for `gh auth login`; device/browser flow. | `cfg/agentic/copilot` mounted at `/home/devilbox/.config/gh`. |
| `droid` | Factory.ai account or API key. | Tool dependent. | No dedicated persistent mount until a config path is confirmed. |
| `gemini` | Gemini CLI OAuth or Google API key. | Yes for OAuth; no for API-key-only setup. | No dedicated persistent mount until a config path is confirmed. |
| `kilo-code` | Tool-specific account or API key. | Tool dependent. | No dedicated persistent mount until a config path is confirmed. |
| `kimi` | Kimi Code credentials via Moonshot AI. | Tool dependent. | No dedicated persistent mount until a config path is confirmed. |
| `kiro` | AWS credentials for Q Developer. | Tool dependent. | No dedicated persistent mount until a config path is confirmed. |
| `opencode` | Provider credentials configured by OpenCode; often API-key based. | Sometimes, depending on provider. | `cfg/agentic/opencode` mounted at `/home/devilbox/.config/opencode`. |
| `pi-coding-agent` | Pi Coding Agent account or API credential setup. | Tool dependent. | No dedicated persistent mount until a config path is confirmed. |
| `qwen-code` | Tool-specific account or API key. | Tool dependent. | No dedicated persistent mount until a config path is confirmed. |
| `reasonix` | Tool-specific account or token setup. | Tool dependent. | No dedicated persistent mount until a config path is confirmed. |

### Extra tools (built into `:work` image)

| Tool slug | Auth method | Browser? | Persisted to |
| --- | --- | --- | --- |
| `openspec` | No authentication required; ships with the image. | No. | `cfg/agentic/openspec` for project specs. |
| `speckit` | GitHub token via `SPECIFY_AUTH_TOKEN` env var or `gh` CLI auth. | No. | `cfg/agentic/speckit` for spec state. |

Host-side tools use shared config mounts for convenience:

- `cfg/agentic/aider` -> `/home/devilbox/.aider`
- `cfg/agentic/goose` -> `/home/devilbox/.config/goose`
- `cfg/agentic/cline` -> `/home/devilbox/.config/cline`
- `cfg/agentic/continue` -> `/home/devilbox/.continue`
- `cfg/agentic/llm` -> `/home/devilbox/.config/io.datasette.llm`

## Persistent volumes and bind mounts

The agentic stack uses host bind mounts, not disposable container storage, for
credentials and user state.

These survive container recreation and `docker compose down -v` because they are
directories in the Devilbox checkout:

| Host path | Container path | Purpose |
| --- | --- | --- |
| `cfg/agentic/claude` | `/home/devilbox/.claude` | Claude Code config and credentials. |
| `cfg/agentic/opencode` | `/home/devilbox/.config/opencode` | OpenCode config. |
| `cfg/agentic/codex` | `/home/devilbox/.codex` | Codex config. |
| `cfg/agentic/copilot` | `/home/devilbox/.config/gh` | GitHub CLI and Copilot extension auth. |
| `cfg/agentic/aider` | `/home/devilbox/.aider` | Aider config. |
| `cfg/agentic/goose` | `/home/devilbox/.config/goose` | Goose config. |
| `cfg/agentic/cline` | `/home/devilbox/.config/cline` | Cline config. |
| `cfg/agentic/continue` | `/home/devilbox/.continue` | Continue config. |
| `cfg/agentic/cursor` | `/home/devilbox/.cursor` | Cursor Agent config. |
| `cfg/agentic/llm` | `/home/devilbox/.config/io.datasette.llm` | Datasette LLM config. |
| `cfg/agentic/crush` | `/home/devilbox/.config/crush` | Crush config. |
| `cfg/agentic/openclaude` | `/home/devilbox/.openclaude` | OpenClaude provider/auth state. |
| `cfg/agentic/openspec` | `/home/devilbox/.openspec` | OpenSpec user-level state. |
| `cfg/agentic/speckit` | `/home/devilbox/.specify` | Spec Kit user-level configuration. |
| `cfg/agentic/kilocode` | `/home/devilbox/.kilocode` | Kilo Code auth/config state. |
| `cfg/agentic/kimi` | `/home/devilbox/.kimi` | Kimi Code login/API-key state. |
| `cfg/agentic/qoder` | `/home/devilbox/.qoder` | Qoder CLI auth/config state. |
| `cfg/agentic/shared` | `/home/devilbox/.shared` | Cross-tool shared gitconfig, SSH, and env shims. |
| `cfg/agentic/startup` | `/startup.1.d` | User-visible startup scripts. |
| `.devilbox/oauth-fifo` | `/var/run/dvl-oauth` | OAuth bridge FIFO. |

The shared source workspace is mounted separately:

```text
${HOST_PATH_HTTPD_DATADIR} -> /shared/httpd
```

That is the same project tree used by HTTPD/PHP workflows.

## Examples

<Tabs>
<TabItem label="Claude Code OAuth">

```bash
./dvl.sh agent enable agentic
./dvl.sh agent up
./dvl.sh agent auth claude-code
```

Complete the browser login on the host. The credential files persist under
`cfg/agentic/claude`.

Verify from inside the container:

```bash
./dvl.sh agent exec "claude --version"
```

</TabItem>
<TabItem label="Codex API key">

Use an API-key flow when you do not want browser OAuth:

```bash
./dvl.sh agent enable agentic
./dvl.sh agent up
./dvl.sh agent shell
```

Inside the container, configure Codex according to the installed CLI's current
prompts. Resulting state persists in `cfg/agentic/codex`.

If the CLI reads environment variables, put non-secret examples in your team
docs and keep real keys out of git.

</TabItem>
<TabItem label="Reasonix">

```bash
./dvl.sh agent enable agentic
./dvl.sh agent up
./dvl.sh agent auth reasonix
```

If reasonix requires an API key or account token, configure it through its CLI setup
flow. Persistent state lives under `cfg/agentic/reasonix`.

</TabItem>
<TabItem label="GitHub Copilot">

```bash
./dvl.sh agent enable agentic
./dvl.sh agent up
./dvl.sh agent auth copilot
```

GitHub CLI state persists in `cfg/agentic/copilot`, mounted at
`/home/devilbox/.config/gh`.

You can inspect status with:

```bash
./dvl.sh agent exec "gh auth status"
```

</TabItem>
</Tabs>

## Running auth manually

If a tool does not have a bridge wrapper yet, enter the container and run the
tool's own login command:

```bash
./dvl.sh agent shell
```

Then run the CLI's login command from the shell. Browser URLs should still use
the `BROWSER` shim installed by `10-oauth-helper.sh` when the CLI honors
`BROWSER`.

## Troubleshooting

### `Usage: dvl agent auth <tool-slug>`

You omitted the slug. Use one of the slugs from:

```bash
./dvl.sh agent tools
```

Examples: `claude-code`, `codex`, `copilot`.

### `OAuth bridge not installed`

`dvl.sh` expects `.devilbox/oauth-bridge.sh` to exist and be executable. Re-run
the install/bootstrap step that created `.devilbox/`, or inspect the local
Devilbox setup before retrying.

### Browser does not open

Check that the agentic stack is running and the FIFO mount exists:

```bash
./dvl.sh agent status
```

The container-side shim writes to `/var/run/dvl-oauth/url`. The host bridge must
be listening for that URL.

### OAuth callback cannot connect

Check the published port:

```dotenv
AGENTIC_OAUTH_PORT=19999
```

The compose override publishes it as `${LOCAL_LISTEN_ADDR}${AGENTIC_OAUTH_PORT}:19999`.
Keep it loopback-only unless you know why it needs to be reachable elsewhere.

### Login succeeds but is lost after restart

Confirm the relevant `cfg/agentic/<tool>` directory exists and is writable by the
container user. Credentials stored outside mounted directories can disappear
when the container is recreated.

### Tool command is not found after authentication

Authentication does not enable a disabled tool. Check the runtime toggle page
and ensure the tool is in the final enabled set. Then restart the stack so the
symlink synchronizer runs.
