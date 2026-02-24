---
name: restart
description: Restart cobrain daemon.
---

# restart

1. Stop if running:

```bash
pkill -f "cobrain.py" 2>/dev/null; sleep 1
```

2. Start:

```bash
nohup /opt/homebrew/bin/python3.11 ${CLAUDE_PLUGIN_ROOT}/scripts/cobrain.py > /dev/null 2>&1 &
echo "Started cobrain (PID $!)"
```

3. Verify:

```bash
sleep 2 && pgrep -f "cobrain.py"
```
