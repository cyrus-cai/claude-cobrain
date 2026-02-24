---
name: startstop
description: Start or stop cobrain daemon.
---

# startstop

Action is passed as context: `start` or `stop`.

## Start

1. Check if already running:

```bash
pgrep -f "cobrain.py" || echo "not running"
```

If already running, report PID and do nothing.

2. Start as background process:

```bash
nohup /opt/homebrew/bin/python3.11 ${CLAUDE_PLUGIN_ROOT}/scripts/cobrain.py > /dev/null 2>&1 &
echo "Started cobrain (PID $!)"
```

3. Verify:

```bash
sleep 2 && pgrep -f "cobrain.py"
```

## Stop

```bash
pkill -f "cobrain.py" && echo "Stopped" || echo "cobrain is not running"
```
