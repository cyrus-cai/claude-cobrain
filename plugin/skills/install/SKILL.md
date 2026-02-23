---
name: install
description: Install claude-cobrain daemon - check prerequisites, deploy daemon script, configure LaunchAgent, and start the service. Use when user wants to set up cobrain for the first time.
---

# install

Install claude-cobrain daemon and start it as a LaunchAgent.

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
- `<CLAUDE_PLUGIN_ROOT>/launchagents/com.cobrain.plist` - plist template to process

## Execution principle

Minimize user approval prompts: chain independent shell commands with `&&` into single Bash calls. The entire install should require at most 3 user approvals.

## Flow

### 1. Choose output directory

- Default: `~/.claude/cobrain`
- Allow custom absolute path if user asks.
- Resolve to absolute path and use it as `OUTPUT_DIR`.

### 2. Prerequisite check (one-shot, 1 Bash call)

Run all checks in a single command:

```bash
command -v python3.11 && python3.11 --version && \
command -v ollama && ollama --version && \
python3.11 -c "import PIL, ollama; print('ok')" && \
ollama list | grep qwen3-vl
```

If success: skip installation steps.

If failure: install only missing prerequisites.

- Missing Python 3.11: `brew install python@3.11`
- Missing Ollama CLI: `brew install ollama`
- Missing Python packages: `pip3.11 install Pillow ollama`
- Missing model: `ollama pull qwen3-vl:2b`

### 3. Deploy files (1 Bash call)

Read the plist template with the Read tool first, then chain all file operations into a single Bash command:

1. Detect python path with `command -v python3.11`.
2. Read plist template from `<CLAUDE_PLUGIN_ROOT>/launchagents/com.cobrain.plist` (use Read tool, no approval needed).
3. Run one Bash call that does all of the following:
   - Create `OUTPUT_DIR` if needed
   - Copy daemon script from `<CLAUDE_PLUGIN_ROOT>/scripts/cobrain.py` to `<OUTPUT_DIR>/cobrain.py`
   - Write `.source_repo` marker to `<OUTPUT_DIR>/.source_repo`
   - Write processed plist (with `PYTHON_PATH` and `OUTPUT_DIR` replaced) to `~/Library/LaunchAgents/com.cobrain.plist` using a heredoc

### 4. Start service (1 Bash call)

Chain unload (if exists), load, and verify into one command:

```bash
launchctl unload ~/Library/LaunchAgents/com.cobrain.plist 2>/dev/null; \
launchctl load ~/Library/LaunchAgents/com.cobrain.plist && \
launchctl list | grep com.cobrain
```

### 5. Completion output

Return:
- `Done. Daemon is running. Logs: <OUTPUT_DIR>/daemon.log`
- macOS permission note below.

## macOS Permissions

The LaunchAgent runs through `/bin/zsh`, so permissions are requested under `zsh`.

On first launch macOS may show:

> "zsh" can run in the background.

Allow it. If logs stop after startup, add `/bin/zsh` to both permissions in:

- System Settings -> Privacy & Security -> Accessibility
- System Settings -> Privacy & Security -> Screen Recording
