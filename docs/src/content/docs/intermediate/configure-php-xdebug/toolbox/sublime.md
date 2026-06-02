---
title: "Docker Toolbox: Xdebug for Sublime Text 3 (deprecated)"
description: Docker Toolbox is end-of-life. Use Docker Desktop or Docker Engine instead.
sidebar:
  badge:
    text: Deprecated
    variant: danger
---

orphan

# Docker Toolbox: Xdebug for Sublime Text 3 (deprecated)

Docker Toolbox was deprecated by Docker in 2020 and removed from active
support. It should not be used for a new Devilbox or Xdebug debugging
setup in 2026.

This page is intentionally not updated for Sublime Text 4 because the
underlying Docker runtime is obsolete.

## Use a supported host setup

Install a current Docker runtime for your host operating system and then
follow the matching maintained Sublime guide:

- Linux: [Docker on Linux: Xdebug for Sublime Text](../linux/sublime/)
- macOS: [Docker on MacOS: Xdebug for Sublime Text](../macos/sublime/)
- Windows: [Docker on Windows: Xdebug for Sublime Text](../windows/sublime/)

## Why this page is not modernized

The old workflow depended on a VirtualBox machine IP and legacy Docker
Machine networking. Current Devilbox documentation targets Docker
Desktop on macOS and Windows, or Docker Engine on Linux.

:::tip
After moving to a supported Docker runtime, use Sublime Text 4 with the
`xdebug-client` package and map `/shared/httpd` to your local project
directory.
:::

:::caution
Do not copy old Docker Toolbox instructions into a current Devilbox
environment. Use the supported host-specific pages instead.
:::
