---
name: restart
description: Restart cobrain daemon.
---

# restart

Use direct `python3` restart via controller script.

```bash
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" && -f "${CLAUDE_PLUGIN_ROOT}/scripts/control.sh" ]]; then
  CONTROL_SCRIPT="${CLAUDE_PLUGIN_ROOT}/scripts/control.sh"
elif [[ -f "./plugin/scripts/control.sh" ]]; then
  CONTROL_SCRIPT="./plugin/scripts/control.sh"
else
  CONTROL_SCRIPT="$(ls -dt "$HOME"/.claude/plugins/cache/*/claude-cobrain/*/scripts/control.sh 2>/dev/null | head -1)"
fi
[[ -n "${CONTROL_SCRIPT:-}" && -f "$CONTROL_SCRIPT" ]] || { echo "control.sh not found. Run: /claude-cobrain:cobrain install"; exit 1; }

bash "$CONTROL_SCRIPT" restart
```
