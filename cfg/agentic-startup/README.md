# cfg/agentic-startup

Persistent storage for: numbered startup hooks (mirrors cfg/php-startup-*); *.sh-example files become *.sh on activation.

**Container mount:** `/startup.1.d`
**Image:** `devilboxcommunity/agentic`
**Activated by:** copying `compose/docker-compose.override.yml-agentic` to the
Devilbox root (or via `dvl agent enable`).

These files persist across `docker volume rm`. Do NOT delete this directory
unless you intend to log out of every tool.
