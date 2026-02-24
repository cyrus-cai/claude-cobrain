---
name: logs
description: View cobrain daemon logs.
---

# logs

1. Read output directory from plist:

```bash
defaults read ~/Library/LaunchAgents/com.cobrain.plist WorkingDirectory
```

2. Tail log:

```bash
tail -50 <OUTPUT_DIR>/daemon.log
```

If plist missing or log missing, report the concrete missing path.
