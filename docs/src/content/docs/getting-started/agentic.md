---
title: Agentic Onboarding
description: Introduction to the Devilbox agentic flavour — a pre-configured AI-coding environment.
sidebar:
  order: 50
---

The agentic flavour is a specialized container scaffold designed to house AI development tools alongside your standard PHP, MySQL, and HTTPD stacks. It ensures your agents operate in the same filesystem context as your code, with persistent configuration and secure authentication.

## Why Agentic?

AI development tools belong in your development environment, not just on your host machine. By containerizing tools like Claude Code and OpenCode, Devilbox provides:
- **Consistency**: Identical tool versions for everyone on the team.
- **Isolation**: Tool dependencies don't clutter your host OS.
- **Context**: Agents see the same `/shared/httpd` workspace as your PHP container.

## Agent tools (per-agent images)

The `devilboxcommunity/agentic` project provides dedicated per-agent Docker images, each shipping a single AI coding CLI on top of the shared `:work` runtime. All 12 agents are enabled by default and auto-discovered by CI.

| Agent | Image tag | Binary | Description |
|-------|-----------|--------|-------------|
| **Claude Code** | `:claude-code` | `claude` | Anthropic's CLI agent for coding tasks |
| **Codex** | `:codex` | `codex` | OpenAI's power-user coding interface |
| **GitHub Copilot** | `:copilot` | `copilot` | Official CLI for Copilot interactions |
| **Droid** | `:droid` | `droid` | Factory.ai's agentic CLI |
| **Gemini** | `:gemini` | `gemini` | Google's multimodal AI CLI |
| **Kilo Code** | `:kilo-code` | `kilo` | Lightweight agentic coding CLI |
| **Kimi** | `:kimi` | `kimi` | Moonshot AI's coding assistant |
| **Kiro** | `:kiro` | `kiro-cli` | AWS Q Developer CLI agent |
| **OpenCode** | `:opencode` | `opencode` | The open-source agentic framework |
| **Pi Coding Agent** | `:pi-coding-agent` | `pi` | Specialized mathematical and algorithmic assistant |
| **Qwen Code** | `:qwen-code` | `qwen` | Alibaba's Qwen coding agent |
| **Reasonix** | `:reasonix` | `reasonix` | Logic-heavy reasoning agent |

## Extra tools (built into the work image)

These shared spec/workflow utilities are installed in the `:work` base image and available to all per-agent images.

| Tool | Binary | Purpose |
|------|--------|---------|
| **OpenSpec** | `openspec` | Spec-driven development workflow |
| **SpecKit** | `specify` | GitHub Spec Kit bootstrap CLI |

## Persistence Layout

Configuration for agent tools and extras is stored in the `cfg/` directory of your Devilbox installation, ensuring settings and sessions survive container restarts and updates.

```text
devilbox/
├── cfg/
│   └── agentic/
│       ├── claude/        # ~/.claude configs
│       ├── codex/         # Codex state
│       ├── copilot/       # GitHub Copilot credentials
│       ├── opencode/      # OpenCode state
│       ├── pi/            # Pi Coding Agent configs
│       ├── reasonix/      # Reasonix state
│       ├── openspec/      # OpenSpec workspace
│       ├── speckit/       # SpecKit state
│       └── ...            # Other tool-specific mounts
└── data/
    └── www/               # Shared with /shared/httpd
```

## Toggling Tools

You can customize which tools are active using environment variables in your `.env` file.

- **`AGENTIC_TOOLS_DISABLE`**: A comma-separated list of default tool slugs to turn off.
- **`AGENTIC_TOOLS_ENABLE`**: A comma-separated list of optional tool slugs to turn on.

Example:
```dotenv
AGENTIC_TOOLS_DISABLE=pi-coding-agent,reasonix
AGENTIC_TOOLS_ENABLE=openspec,speckit
```

## Authenticating Tools

Most agents require a one-time OAuth or API key handshake. Devilbox uses a host-bridge mechanism to handle these flows securely.

1. Enable the agent stack: `dvl agent enable agentic`
2. Start the container: `dvl agent up`
3. Run the auth command: `dvl agent auth <tool-slug>`

This will trigger a browser window on your host machine to complete the authentication process.

See also: [DVL Agent Guide](../../intermediate/dvl-agent/), [Installation Script](./install-script/)
