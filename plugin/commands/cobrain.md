---
description: "Manage claude-cobrain daemon (install, start, stop, status, logs, update, uninstall)"
argument-hint: "[action]"
---

# cobrain

Route `/claude-cobrain:cobrain $ARGUMENTS` to the appropriate skill.

## Routing

| Argument    | Skill   | Description                                     |
| ----------- | ------- | ----------------------------------------------- |
| (empty)     | —       | If not installed → install; otherwise → manage  |
| `install`   | install | Full installation flow                          |
| `update`    | update  | Check and apply updates                         |
| `status`    | manage  | Show daemon status                              |
| `start`     | manage  | Start daemon                                    |
| `stop`      | manage  | Stop daemon                                     |
| `logs`      | manage  | View daemon logs                                |
| `uninstall` | manage  | Remove daemon and LaunchAgent                   |

## Dispatch Rules

1. Normalize `$ARGUMENTS` to a single lower-case action token.
2. If no action is provided:
   - First check whether cobrain is installed: `ls ~/Library/LaunchAgents/com.cobrain.plist`.
   - If the plist does **not** exist, cobrain is not installed — immediately invoke the `install` skill (same as rule 3) without asking the user.
   - If the plist **does** exist, invoke the `manage` skill in interactive mode (no action) to show status and ask what to do next.
3. For `install`, invoke the `install` skill and explicitly pass `${CLAUDE_PLUGIN_ROOT}` as absolute path context.
4. For `update`, invoke the `update` skill.
5. For `status`, `start`, `stop`, `logs`, `uninstall`, invoke the `manage` skill and pass the action.
6. For unknown actions, show supported actions: `install`, `update`, `status`, `start`, `stop`, `logs`, `uninstall`.
