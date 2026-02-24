---
name: uninstall
description: Uninstall cobrain daemon and LaunchAgent.
---

# uninstall

1. Stop daemon:

```bash
launchctl unload ~/Library/LaunchAgents/com.cobrain.plist
```

2. Remove LaunchAgent:

```bash
rm ~/Library/LaunchAgents/com.cobrain.plist
```

3. Ask whether to remove `OUTPUT_DIR` data directory.
4. If user confirms:

```bash
rm -rf <OUTPUT_DIR>
```

5. Report completion and remaining files if user chose to keep data.
