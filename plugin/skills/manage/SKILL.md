---
name: manage
description: Manage claude-cobrain daemon - start, stop, check status, view logs, or uninstall. Use when user wants to control or inspect a running cobrain daemon.
---

# manage

Handle daemon lifecycle and diagnostics.

## Accepted actions

- `status`
- `start`
- `stop`
- `logs`
- `uninstall`
- `(empty)` interactive mode: run status, ask next action, then execute selection.

## Status

1. Check plist existence:

```bash
ls ~/Library/LaunchAgents/com.cobrain.plist
```

2. Check launchctl state:

```bash
launchctl list | grep com.cobrain
```

3. Interpret result:
- plist missing: `cobrain is not installed.`
- plist exists + PID exists: `cobrain is running (PID <pid>).`
- plist exists + no PID: `cobrain is installed but not running.`

When action is empty, show one-line status and ask what user wants: Install / Start / Stop / View logs / Check update / Uninstall.
Then execute the selected action by re-entering this skill for `start`/`stop`/`logs`/`uninstall`, or route to `install`/`update` skill when selected.

## Start

```bash
launchctl load ~/Library/LaunchAgents/com.cobrain.plist
```

Then run status check and report result.

## Stop

```bash
launchctl unload ~/Library/LaunchAgents/com.cobrain.plist
```

Then run status check and report result.

## Logs

1. Read output directory from plist:

```bash
defaults read ~/Library/LaunchAgents/com.cobrain.plist WorkingDirectory
```

2. Tail log:

```bash
tail -50 <OUTPUT_DIR>/daemon.log
```

If plist missing or log missing, report concrete missing path.

## Uninstall

1. Stop daemon:

```bash
launchctl unload ~/Library/LaunchAgents/com.cobrain.plist
```

2. Remove LaunchAgent:

```bash
rm ~/Library/LaunchAgents/com.cobrain.plist
```

3. Ask whether to remove `OUTPUT_DIR` data directory.
4. If user confirms, run:

```bash
rm -rf <OUTPUT_DIR>
```

5. Report completion and remaining files if user chose to keep data.
