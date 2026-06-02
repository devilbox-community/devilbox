---
title: "Docker on MacOS: Xdebug for Atom (deprecated)"
description: Atom was sunset in December 2022. Use PhpStorm, Visual Studio Code, or Sublime Text instead.
sidebar:
  badge:
    text: Deprecated
    variant: danger
---

orphan

# Docker on MacOS: Xdebug for Atom (deprecated)

Atom is no longer a supported editor for new Xdebug setups. GitHub
archived Atom and sunset the project in December 2022, so its PHP debug
packages no longer track current Xdebug and PHP releases.

Do not start a new Devilbox debugging setup with Atom. Use one of the
maintained macOS guides instead:

- [Xdebug for PhpStorm](./phpstorm/)
- [Xdebug for Visual Studio Code](./vscode/)
- [Xdebug for Sublime Text](./sublime/)

## What to use instead

Choose an editor with current DBGp/Xdebug 3 support:

- PhpStorm 2024.3 or 2025.1 for an integrated PHP IDE workflow.
- Visual Studio Code with the `xdebug.php-debug` extension for a light
  editor workflow.
- Sublime Text 4 with the `xdebug-client` package if you prefer Sublime.

## macOS host note

The maintained macOS guides use Docker Desktop's built-in
`host.docker.internal` name. You no longer need a loopback host alias for
current Docker Desktop based Devilbox debugging.

:::tip
If you are migrating from Atom, configure the replacement editor with the
same local project root and map it to `/shared/httpd` inside Devilbox.
:::

:::caution
Old Atom package snippets often target obsolete Xdebug 2 behavior and the
legacy debug port. Replace the whole editor setup with one of the guides
linked above instead of copying old snippets forward.
:::
