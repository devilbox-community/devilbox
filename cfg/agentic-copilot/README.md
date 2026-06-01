# cfg/agentic-copilot

Persistent storage for: gh CLI hosts.yml (covers gh-copilot extension).

**Container mount:** `/home/devilbox/.config/gh`
**Image:** `devilboxcommunity/agentic`
**Activated by:** copying `compose/docker-compose.override.yml-agentic` to the
Devilbox root (or via `dvl agent enable`).

These files persist across `docker volume rm`. Do NOT delete this directory
unless you intend to log out of every tool.
