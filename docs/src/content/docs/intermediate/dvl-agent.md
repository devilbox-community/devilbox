---
title: DVL Agent Guide
description: Deep dive into managing AI coding agents with the dvl agent subcommand.
sidebar:
  order: 15
---

import { Steps, Aside } from '@astrojs/starlight/components'

The `dvl agent` subcommand is the lifecycle manager for the agentic flavour. It handles stack layering, container execution, and tool authentication.

## Lifecycle Overview

To use an AI agent in Devilbox, you follow this standard progression:

```bash
dvl agent enable agentic   # 1. Enable the stack
dvl agent up               # 2. Start the container
dvl agent auth claude-code  # 3. Authenticate (one-time)
dvl agent shell            # 4. Enter the workspace
```

## Subcommands

### `enable` / `disable`
Adds or removes override stacks from `.dvl/agent-stacks.list`. Enabling a stack layers its `docker-compose.override.yml-<name>` file on top of the base configuration via the `COMPOSE_FILE` environment variable.

```bash
dvl agent enable agentic
dvl agent disable agentic
```

### `list`
Displays all available agent stacks (found in `compose/docker-compose.override.yml-*`) and indicates which ones are currently enabled in your environment.

```bash
dvl agent list
```

### `up` / `down` / `restart`
Manages the running state of your layered agent stacks. `up` will automatically prune orphan containers if a stack was recently disabled.
```bash
dvl agent up
dvl agent down
dvl agent restart
```

### `status` (alias: `ps`)
Shows the status of containers belonging to the enabled agent stacks.

### `logs`
Tails the logs for agent services.
```bash
dvl agent logs
```

### `shell` [service]
Opens a bash session inside an agent container as the `devilbox` user. Defaults to the `agentic` service if no name is provided.
```bash
dvl agent shell
dvl agent shell opencode
```

### `exec` <command>
Runs a non-interactive command inside the `agentic` container.
```bash
dvl agent exec "claude --version"
```

### `auth` <tool-slug>
Triggers the OAuth bridge for a specific tool. This uses a host-side script to handle browser interaction.
```bash
dvl agent auth claude-code
dvl agent auth copilot
```

### `tools`
Lists all AI CLI tools currently installed and available in the agentic image.

## OAuth Walkthrough

<Aside type="caution">
The `auth` command requires a functional web browser on your host machine to complete the OAuth handshake.
</Aside>

<Steps>
1. **Initiate**: Run `dvl agent auth <tool-slug>`.
2. **Handoff**: The container creates an OAuth request and sends it to the host via the `oauth-bridge.sh`.
3. **Browser**: Your host's default browser will open the provider's login page (e.g., Anthropic or GitHub).
4. **Grant**: Approve the access request in your browser.
5. **Callback**: The browser redirects to a local loopback port (`AGENTIC_OAUTH_PORT`), which passes the token back into the container.
6. **Persistence**: The token is saved in the tool's persistent config directory (e.g., `cfg/agentic/claude`).
</Steps>

## Volume Persistence

The following directories in the agentic container are mounted from your host to ensure long-term persistence:

| Container Path | Host Source | Survives `-v`? |
|---|---|---|
| `/home/devilbox/.claude` | `cfg/agentic/claude` | Yes |
| `/home/devilbox/.config/opencode` | `cfg/agentic/opencode` | Yes |
| `/shared/httpd` | `HOST_PATH_HTTPD_DATADIR` | Yes |

<Aside type="note">
Running `docker compose down -v` will remove anonymous volumes but will NOT touch these host-bind mounts.
</Aside>

## Multi-Tool Workflows

Because all agents share the same `/shared/httpd` workspace, you can use multiple tools in parallel. For example, you might use **Claude Code** to author a feature while **OpenCode** runs background tests or documentation indexing.

```bash
# In one terminal
dvl agent shell
claude "Implement the user profile API"

# In another terminal
dvl agent shell
opencode "Monitor test coverage for the new API"
```

See also: [Agentic Onboarding](../getting-started/agentic/), [DVL CLI Reference](../intermediate/dvl-cli/)
