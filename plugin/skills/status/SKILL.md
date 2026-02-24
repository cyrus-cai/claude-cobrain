---
name: status
description: Show full cobrain daemon status including version, process, permissions, and recent activity.
---

# status

Run ALL the following checks in a single Bash call, then present the results as a formatted status report.

## Checks to run

```bash
# 1. Version (from plugin.json)
cat "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json" 2>/dev/null | python3 -c "import sys,json; print('VERSION:', json.load(sys.stdin).get('version','unknown'))" 2>/dev/null || echo "VERSION: unknown"

# 2. Process
pgrep -f "cobrain.py" && echo "PROCESS: running" || echo "PROCESS: not running"

# 3. Python path
command -v python3.11 || echo "PYTHON: not found"

# 4. Script path
SCRIPT="${CLAUDE_PLUGIN_ROOT}/scripts/cobrain.py"
ls "$SCRIPT" 2>/dev/null && echo "SCRIPT: $SCRIPT" || echo "SCRIPT: not found"

# 5. Output directory and today's file
OUTPUT_DIR="${HOME}/.claude/cobrain"
echo "OUTPUT_DIR: $OUTPUT_DIR"
TODAY=$(date +%Y%m%d)
ls -la "${OUTPUT_DIR}/${TODAY}-raw.md" 2>/dev/null || echo "TODAY_RAW: not found"

# 6. Last 3 lines of daemon log
tail -3 "${OUTPUT_DIR}/daemon.log" 2>/dev/null || echo "LOG: no daemon.log"

# 7. Screen Recording permission check
/opt/homebrew/bin/python3.11 -c "
import subprocess, os
r = subprocess.run(['/usr/sbin/screencapture', '-x', '/tmp/cobrain_perm_test.png'], capture_output=True)
if r.returncode == 0 and os.path.exists('/tmp/cobrain_perm_test.png'):
    size = os.path.getsize('/tmp/cobrain_perm_test.png')
    os.remove('/tmp/cobrain_perm_test.png')
    print(f'SCREEN_RECORDING: granted ({size} bytes)')
else:
    print('SCREEN_RECORDING: DENIED')
" 2>/dev/null || echo "SCREEN_RECORDING: check failed"

# 8. Ollama model
ollama list 2>/dev/null | grep qwen3-vl || echo "OLLAMA_MODEL: not found"
```

## Output format

Present results as a clean status block:

```
cobrain v<version>
─────────────────────────
Process:          running (PID <pid>) | not running
Python:           /path/to/python3.11
Script:           /path/to/cobrain.py
Output dir:       /path/to/output
─────────────────────────
Screen Recording: granted | DENIED
Ollama:           qwen3-vl:2b available | not found
─────────────────────────
Today's log:      <filename> (<size>) | not yet created
Last activity:    <last line from daemon.log>
```

If Screen Recording is DENIED, add:
`⚠ Screen Recording not granted. Run /claude-cobrain:cobrain restart to fix.`

If Ollama model not found, add:
`⚠ Model not found. Run: ollama pull qwen3-vl:2b`
