---
title: "Open a terminal on MacOS"
---

# Open a terminal on MacOS

Devilbox commands run in any normal macOS terminal. Docker Desktop does
not need a special launcher.

## Terminal.app

Open the built-in terminal:

```text
Cmd+Space → Terminal → Return
```

Then move into your Devilbox checkout:

```bash
cd ~/Workspace/devilbox
./dvl.sh --help
```

## iTerm2

Install iTerm2 with Homebrew:

```bash
brew install --cask iterm2
```

Open it from Spotlight or Launchpad, then run the same Devilbox commands.

## Warp

Install Warp with Homebrew:

```bash
brew install --cask warp
```

Open it from Spotlight or Launchpad.

:::note
If you installed Devilbox with `install.sh`, the global `dvl` command may
already be on your `PATH`. Otherwise run `./dvl.sh` from the repository
root.
:::

## Quick check

Verify Docker and Devilbox from the terminal you chose:

```bash
docker info
docker compose version
./dvl.sh doctor
```
