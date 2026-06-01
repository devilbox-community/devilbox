# Docker Compose overwrites

This directory container various `docker-compose.override.yml` examples to be used with the Devilbox.

Note that those override files have their own environment variables that should be **appended** to `.env`


## Available overrides

| Override file | Purpose | How to enable |
|---|---|---|
| `docker-compose.override.yml-agentic` | AI coding agents (Claude Code, OpenCode, Codex, GH Copilot, …) | `dvl agent enable` (copies file to repo root) |
