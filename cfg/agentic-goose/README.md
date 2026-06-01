# cfg/agentic-goose

Persistent storage for: Block Goose configuration and session state.

**Container mount:** `/home/devilbox/.config/goose`
**Image:** `devilboxcommunity/agentic`
**Activated by:** copying `compose/docker-compose.override.yml-agentic` to the
Devilbox root (or via `dvl agent enable`).

These files persist across `docker volume rm`. Do NOT delete this directory
unless you intend to log out of every tool.
