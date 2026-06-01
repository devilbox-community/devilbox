# cfg/agentic-shared

Persistent storage for: cross-tool gitconfig, env shims, and shared dotfiles.

**Container mount:** `/home/devilbox/.shared`
**Image:** `devilboxcommunity/agentic`
**Activated by:** copying `compose/docker-compose.override.yml-agentic` to the
Devilbox root (or via `dvl agent enable`).

These files persist across `docker volume rm`. Do NOT delete this directory
unless you intend to log out of every tool.
