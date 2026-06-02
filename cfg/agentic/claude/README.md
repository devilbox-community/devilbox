# cfg/agentic/claude

Persistent storage for: Claude Code credentials, .claude.json, and project state.

**Container mount:** `/home/devilbox/.claude`
**Image:** `devilboxcommunity/agentic`
**Activated by:** copying `compose/docker-compose.override.yml-agentic` to the
Devilbox root (or via `dvl agent enable`).

These files persist across `docker volume rm`. Do NOT delete this directory
unless you intend to log out of every tool.
