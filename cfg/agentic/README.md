# cfg/agentic

Per-tool persistent configuration for the optional `agentic` service. Each
subdirectory is bind-mounted into the agentic container so credentials and
settings survive container recreation and `docker compose down -v`.

| Directory | Container mount | Purpose |
| --- | --- | --- |
| `aider/` | `/home/devilbox/.aider` | Aider configuration and local state. |
| `claude/` | `/home/devilbox/.claude` | Claude Code credentials, `.claude.json`, and project state. |
| `cline/` | `/home/devilbox/.config/cline` | Cline configuration. |
| `codex/` | `/home/devilbox/.codex` | OpenAI Codex login and API-key state. |
| `continue/` | `/home/devilbox/.continue` | Continue configuration. |
| `copilot/` | `/home/devilbox/.config/copilot` | GitHub Copilot CLI auth. |
| `crush/` | `/home/devilbox/.config/crush` | Crush CLI configuration. |
| `goose/` | `/home/devilbox/.config/goose` | Goose provider and session configuration. |
| `kilocode/` | `/home/devilbox/.kilocode` | Kilo Code runtime auth/config state. |
| `kimi/` | `/home/devilbox/.kimi` | Kimi Code runtime login/API-key state. |
| `llm/` | `/home/devilbox/.config/io.datasette.llm` | Datasette LLM provider configuration. |
| `openclaude/` | `/home/devilbox/.openclaude` | OpenClaude provider/auth state. |
| `opencode/` | `/home/devilbox/.config/opencode` | OpenCode configuration and provider state. |
| `openspec/` | `/home/devilbox/.openspec` | OpenSpec user-level spec workflow state. |
| `qoder/` | `/home/devilbox/.qoder` | Qoder CLI runtime auth/config state. |
| `shared/` | `/home/devilbox/.shared` | Cross-tool shared gitconfig, SSH, and env shims. |
| `speckit/` | `/home/devilbox/.specify` | Spec Kit (`specify`) user-level configuration. |
| `startup/` | `/startup.1.d` | Agentic-only startup scripts. |

Wave-10 tools without confirmed persistent config (`codebuddy`, `factory`,
`junie`, `kiro`, and `vibe`) intentionally do not have directories yet.
