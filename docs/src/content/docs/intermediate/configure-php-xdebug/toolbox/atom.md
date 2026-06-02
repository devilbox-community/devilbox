---
title: "Docker Toolbox: Xdebug for Atom (deprecated)"
description: Docker Toolbox is end-of-life. Use Docker Desktop or Docker Engine instead.
sidebar:
  badge:
    text: Deprecated
    variant: danger
---

orphan

# Docker Toolbox: Xdebug for Atom (deprecated)

Docker Toolbox was deprecated by Docker in 2020 and removed from active
support. It should not be used for a new Devilbox or Xdebug debugging
setup in 2026.

Atom is also deprecated because GitHub sunset the editor in December
2022. Do not combine two unsupported tools for new PHP debugging work.

## Use a supported host setup

Install a current Docker runtime for your host operating system and then
follow the matching maintained Xdebug guide:

- Linux: [PhpStorm](../linux/phpstorm/), [Visual Studio Code](../linux/vscode/), or [Sublime Text](../linux/sublime/)
- macOS: [PhpStorm](../macos/phpstorm/), [Visual Studio Code](../macos/vscode/), or [Sublime Text](../macos/sublime/)
- Windows: [PhpStorm](../windows/phpstorm/), [Visual Studio Code](../windows/vscode/), or [Sublime Text](../windows/sublime/)

## Why this page is not modernized

The old workflow depended on a VirtualBox machine IP and outdated editor
packages. Current Devilbox documentation targets Docker Desktop on macOS
and Windows, or Docker Engine on Linux.

:::tip
If you are migrating an existing project, keep your project files and
move only the Docker runtime plus editor debug configuration to one of
the supported guides above.
:::

:::caution
Do not copy old Docker Toolbox instructions into a current Devilbox
environment. Use the supported host-specific pages instead.
:::
