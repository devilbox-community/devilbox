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

## Default Tools

The `devilboxcommunity/agentic` image ships with a comprehensive suite of AI agents and coding tools enabled by default:

- **Claude Code**: Anthropic's CLI agent for coding tasks.
- **OpenCode**: The open-source agentic framework.
- **Codex**: OpenAI's power-user coding interface.
- **Cursor Agent**: The CLI companion to the Cursor editor.
- **Codewhale**: Deep-context codebase analysis.
- **Reasonix**: Logic-heavy reasoning agent.
- **Hermes Agent**: High-throughput task automation.
- **OpenClaw**: Open-source alternative to proprietary coding assistants.
- **Pi Coding Agent**: Specialized mathematical and algorithmic assistant.
- **GitHub Copilot**: Official CLI for Copilot interactions.
- **Gemini**: Google's multimodal AI integration.

## Persistence Layout

Configuration for these tools is stored in the `cfg/` directory of your Devilbox installation, ensuring settings and sessions survive container restarts and updates.

```text
devilbox/
├── cfg/
│   ├── agentic-home/      # Persistent $HOME directory
│   ├── agentic-claude/    # ~/.claude configs
│   ├── agentic-opencode/  # opencode state
│   ├── agentic-copilot/   # GitHub credentials
│   └── ...                # Other tool-specific mounts
└── data/
    └── www/               # Shared with /shared/httpd
```

## Toggling Tools

You can customize which tools are active using environment variables in your `.env` file.

- **`AGENTIC_TOOLS_DISABLE`**: A comma-separated list of default tool slugs to turn off.
- **`AGENTIC_TOOLS_ENABLE`**: A comma-separated list of optional tool slugs to turn on.

Example:
```dotenv
AGENTIC_TOOLS_DISABLE=pi-coding-agent,hermes
AGENTIC_TOOLS_ENABLE=cline,continue
```

## Authenticating Tools

Most agents require a one-time OAuth or API key handshake. Devilbox uses a host-bridge mechanism to handle these flows securely.

1. Enable the agent stack: `dvl agent enable agentic`
2. Start the container: `dvl agent up`
3. Run the auth command: `dvl agent auth <tool-slug>`

This will trigger a browser window on your host machine to complete the authentication process.

See also: [DVL Agent Guide](../intermediate/dvl-agent/), [Installation Script](../getting-started/install-script/)
