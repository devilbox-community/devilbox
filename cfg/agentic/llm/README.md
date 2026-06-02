# cfg/agentic/llm

Persistent storage for: Simon Willison llm keys.json and model config.

**Container mount:** `/home/devilbox/.config/io.datasette.llm`
**Image:** `devilboxcommunity/agentic`
**Activated by:** copying `compose/docker-compose.override.yml-agentic` to the
Devilbox root (or via `dvl agent enable`).

These files persist across `docker volume rm`. Do NOT delete this directory
unless you intend to log out of every tool.
