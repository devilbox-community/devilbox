# Docker Compose overwrites

This directory container various `docker-compose.override.yml` examples to be used with the Devilbox.

Note that those override files have their own environment variables that should be **appended** to `.env`


## Available overrides

| Override file | Purpose | How to enable |
|---|---|---|
| `docker-compose.override.yml-agentic` | AI coding agents (Claude Code, OpenCode, Codex, GH Copilot, …) | `./dvl.sh agent enable agentic` |
| `docker-compose.override.yml-hermes-workspace` | Hermes Workspace UI + paired hermes-agent gateway (port 8642) | `./dvl.sh agent enable hermes-workspace` |
| `docker-compose.override.yml-multica` | multica stack — Go API (port 4000) + Next.js web UI (port 3001) + pgvector/pg17 DB | `./dvl.sh agent enable multica` |

## Multi-stack layering (Wave 8E0+)

Agent-related overrides (`-agentic`, `-hermes-workspace`, `-multica`, …) are **layered** via the `COMPOSE_FILE` environment variable rather than being copied to the repository root.

- **State:** Active slugs are stored in `.dvl/agent-stacks.list` (gitignored).
- **Enabling:** `./dvl.sh agent enable <slug...>` appends slugs to the list.
- **Disabling:** `./dvl.sh agent disable <slug...>` removes slugs.
- **Execution:** `./dvl.sh agent up` reads the list, constructs the `COMPOSE_FILE` string (e.g., `docker-compose.yml:compose/docker-compose.override.yml-agentic:...`), and runs `docker-compose up -d`.

### Layering example

You can layer all three companion stacks together for a full agentic environment:

```bash
./dvl.sh agent enable agentic hermes-workspace multica
./dvl.sh agent up -d
```

### Orphan safety

When you disable a stack, its services are no longer defined in the active `COMPOSE_FILE` layer. To prevent lingering containers, `./dvl.sh agent disable` automatically runs `docker-compose up -d --remove-orphans` after updating the stack list.

Common commands:

```bash
./dvl.sh agent list                              # Show enabled vs available stacks
./dvl.sh agent enable agentic                    # Enable a single stack
./dvl.sh agent enable agentic hermes-workspace   # Layer multiple stacks
./dvl.sh agent up                                # Start all enabled stacks
./dvl.sh agent shell                             # Open bash in the agentic container
./dvl.sh agent disable hermes-workspace          # Tear down one stack specifically
./dvl.sh agent down                              # Stop all active stacks
```
