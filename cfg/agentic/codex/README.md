# cfg/agentic/codex

Persistent storage for: OpenAI Codex CLI state and login.

**Container mount:** `/home/devilbox/.codex`
**Image:** `devilboxcommunity/agentic`
**Activated by:** copying `compose/docker-compose.override.yml-agentic` to the
Devilbox root (or via `dvl agent enable`).

These files persist across `docker volume rm`. Do NOT delete this directory
unless you intend to log out of every tool.
