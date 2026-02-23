---
name: update
description: Update claude-cobrain plugin and daemon. Use when user wants to check for or apply updates.
---

# update

Help users to update claude-cobrain plugin and daemon.

## Flow

1. Claude runs the following command:

```shell
/plugin update claude-cobrain
```

2. After plugin update is complete, Claude runs the following command to refresh deployed daemon files:

```shell
/claude-cobrain:cobrain install
```

## Constraints

- Do not run repository self-update commands or custom self-update scripts.
- Use Claude Code plugin update flow only.
