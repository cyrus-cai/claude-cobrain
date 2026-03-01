---
name: status
description: Show full cobrain daemon status including version, process, permissions, and recent activity.
---

# status

Run the status script and show the output to the user. Do not reformat or summarize — just display the raw output.

```bash
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" && -f "${CLAUDE_PLUGIN_ROOT}/scripts/status.sh" ]]; then
  STATUS_SCRIPT="${CLAUDE_PLUGIN_ROOT}/scripts/status.sh"
elif [[ -f "./plugin/scripts/status.sh" ]]; then
  STATUS_SCRIPT="./plugin/scripts/status.sh"
else
  STATUS_SCRIPT="$(ls -dt "$HOME"/.claude/plugins/cache/*/claude-cobrain/*/scripts/status.sh 2>/dev/null | head -1)"
fi
[[ -n "${STATUS_SCRIPT:-}" && -f "$STATUS_SCRIPT" ]] || { echo "status.sh not found"; exit 1; }
bash "$STATUS_SCRIPT"
```
