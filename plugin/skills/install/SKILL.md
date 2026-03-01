---
name: install
description: Install claude-cobrain daemon in direct python3 mode (no LaunchAgent).
---

# install

Install claude-cobrain daemon and start it with `python3` directly.

## Language

Infer language from the user's message. If there is no context, default to English.

## Options

- English (default)
- 中文简体
- 中文繁体
- 日本语
- 한국어
- Others (allow user to specify)
## Source files

Find the plugin root directory. The plugin root directory is most likely in `<USER_ROOT>/.claude/plugins/`.

Required source files:
- `<CLAUDE_PLUGIN_ROOT>/scripts/cobrain.py` - daemon script to copy
- `<CLAUDE_PLUGIN_ROOT>/scripts/control.sh` - process controller script

## Execution principle

Minimize user approval prompts: chain independent shell commands with `&&` into single Bash calls.

## Flow

### 1. Choose output directory

- Default: `~/.claude/cobrain`
- Allow custom absolute path if user asks.
- Resolve to absolute path and use it as `OUTPUT_DIR`.

### 2. Prerequisite check (one-shot, 1 Bash call)

Run all checks in a single command:

```bash
command -v python3 && python3 --version && \
command -v ollama && ollama --version && \
python3 -c "import PIL, ollama; print('ok')" && \
ollama list | grep qwen3-vl
```

If success: skip installation steps.

If failure: install only missing prerequisites.

- Missing Python 3: `brew install python`
- Missing Ollama CLI: `brew install ollama`
- Missing Python packages: `pip3 install Pillow ollama`
- Missing model: `ollama pull qwen3-vl:2b`

### 3. Deploy files (1 Bash call)

Chain file operations into one Bash call:

1. Create `OUTPUT_DIR` if needed.
2. Copy daemon script from `<CLAUDE_PLUGIN_ROOT>/scripts/cobrain.py` to `<OUTPUT_DIR>/cobrain.py`.
3. Copy controller script from `<CLAUDE_PLUGIN_ROOT>/scripts/control.sh` to `<OUTPUT_DIR>/control.sh` and `chmod +x`.
4. Write `.source_repo` marker to `<OUTPUT_DIR>/.source_repo`.
5. Remove stale pid file `<OUTPUT_DIR>/cobrain.pid` if it exists.

### 4. Start service (1 Bash call)

Run direct python3 start through the controller:

```bash
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" && -f "${CLAUDE_PLUGIN_ROOT}/scripts/control.sh" ]]; then
  CONTROL_SCRIPT="${CLAUDE_PLUGIN_ROOT}/scripts/control.sh"
elif [[ -f "./plugin/scripts/control.sh" ]]; then
  CONTROL_SCRIPT="./plugin/scripts/control.sh"
else
  CONTROL_SCRIPT="$(ls -dt "$HOME"/.claude/plugins/cache/*/claude-cobrain/*/scripts/control.sh 2>/dev/null | head -1)"
fi
[[ -n "${CONTROL_SCRIPT:-}" && -f "$CONTROL_SCRIPT" ]] || { echo "control.sh not found"; exit 1; }
bash "$CONTROL_SCRIPT" start
```

### 5. Completion output

Return:
- `Done. Daemon is running. Logs:`
- `  - <OUTPUT_DIR>/daemon.log`
- `  - <OUTPUT_DIR>/runtime.stdout.log`
- `  - <OUTPUT_DIR>/runtime.stderr.log`
- macOS permission note below.

## macOS Permissions

If logs show permission errors, add your terminal app to both permissions in:

- System Settings -> Privacy & Security -> Accessibility
- System Settings -> Privacy & Security -> Screen Recording
