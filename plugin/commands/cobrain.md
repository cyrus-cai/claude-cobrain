---
description: "Manage claude-cobrain daemon (install, start, stop, restart, status, logs, uninstall)"
argument-hint: "[action]"
---

# cobrain

Route `/claude-cobrain:cobrain $ARGUMENTS` to the appropriate skill.

## Routing

| Argument    | Skill     | Description                                    |
| ----------- | --------- | ---------------------------------------------- |
| (empty)     | —         | If not installed → install; otherwise → status |
| `install`   | install   | Full installation flow                         |
| `status`    | status    | Show daemon status                             |
| `start`     | startstop | Start daemon                                   |
| `stop`      | startstop | Stop daemon                                    |
| `restart`   | restart   | Restart with foreground permission check        |
| `logs`      | logs      | View daemon logs                               |
| `uninstall` | uninstall | Remove daemon and LaunchAgent                  |

## Dispatch Rules

1. Normalize `$ARGUMENTS` to a single lower-case action token.
2. If no action is provided:
   - Check whether cobrain is installed: `ls ~/Library/LaunchAgents/com.cobrain.plist`.
   - If the plist does **not** exist, invoke the `install` skill.
   - If the plist **does** exist, invoke the `status` skill.
3. For `install`, invoke the `install` skill and explicitly pass `${CLAUDE_PLUGIN_ROOT}` as absolute path context.
4. For `start` or `stop`, invoke the `startstop` skill and pass the action.
5. For all other known actions, invoke the matching skill directly.
6. For unknown actions, show supported actions: `install`, `status`, `start`, `stop`, `restart`, `logs`, `uninstall`.
