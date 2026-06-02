---
title: "Docker Toolbox: Xdebug for Visual Studio Code (deprecated)"
description: Docker Toolbox is end-of-life. Use Docker Desktop or Docker Engine instead.
sidebar:
  badge:
    text: Deprecated
    variant: danger
---

orphan

# Docker Toolbox: Xdebug for Visual Studio Code (deprecated)

Docker Toolbox was deprecated by Docker in 2020 and removed from active
support. It should not be used for a new Devilbox or Xdebug debugging
setup in 2026.

This page is intentionally not updated for current Visual Studio Code
because the underlying Docker runtime is obsolete.

## Use a supported host setup

Install a current Docker runtime for your host operating system and then
follow the matching maintained Visual Studio Code guide:

- Linux: [Docker on Linux: Xdebug for Visual Studio Code](../linux/vscode/)
- macOS: [Docker on MacOS: Xdebug for Visual Studio Code](../macos/vscode/)
- Windows: [Docker on Windows: Xdebug for Visual Studio Code](../windows/vscode/)

## Why this page is not modernized

The old workflow depended on a VirtualBox machine IP and legacy Docker
Machine networking. Current Devilbox documentation targets Docker
Desktop on macOS and Windows, or Docker Engine on Linux.

:::tip
After moving to a supported Docker runtime, use Visual Studio Code with
the `xdebug.php-debug` extension and map `/shared/httpd` to your local
project directory.
:::

:::caution
Do not copy old Docker Toolbox instructions into a current Devilbox
environment. Use the supported host-specific pages instead.
:::
