# cfg/hermes-workspace

This directory is **bind-mounted** into the `hermes-workspace` Wave 8E1 stack at:

| Mount target | Service | Purpose |
|---|---|---|
| `/opt/data` | `hermes-agent` | Agent config (`config.yaml`), sessions, skills, memory, credentials |
| `/home/workspace/.hermes` | `hermes-workspace` | Workspace reads the same config dir |

Place hermes config files here for **forever-persistence**. They survive
`docker compose down -v` and `./dvl.sh agent disable hermes-workspace`,
because this is a host-side bind mount (not a Docker named volume).

## Typical layout

```
cfg/hermes-workspace/
├── config.yaml                    # provider + model selection
├── profiles/                      # per-worker (orchestrator, builder, ...)
│   └── <worker-id>/config.yaml
├── skills/
├── sessions/
└── workspace-sessions.json        # encrypted UI session tokens
```

## First-time setup

1. Enable the stack:
   ```bash
   ./dvl.sh agent enable hermes-workspace
   ./dvl.sh agent up -d
   ```
2. Set at least one provider key in `.env` (e.g. `ANTHROPIC_API_KEY=...`)
   — see the `hermes-workspace stack (Wave 8E1)` section of `env-example`.
3. Run `hermes setup` inside the container the first time, or drop a
   pre-baked `config.yaml` into this directory before the first `up`.

## Security

If you publish the workspace UI on a non-loopback address
(`HERMES_HOST=0.0.0.0`), you **must** set `HERMES_PASSWORD` in `.env`
or the workspace refuses to start.

## Upstream reference

- Repo:  `github.com/outsourc-e/hermes-workspace` (v2.3.0, MIT)
- Compose: `../hermes-workspace/docker-compose.yml`
- Env:    `../hermes-workspace/.env.example`
