---
name: claude-cobrain
version: 0.1.1
description: Manage claude-cobrain daemon - captures the active window and summarizes it using local VLM (Ollama + qwen3-vl:2b), writing entries to daily markdown files at ~/.claude/cobrain/
---

# claude-cobrain

## Goal

Manage a background daemon that captures the active window and summarizes it using a local vision model, and appends a summary to `<OUTPUT_DIR>/YYYYMMDD-raw.md`.

## Source Files

- **Daemon script:** `./scripts/cobrain.py`
- **LaunchAgent template:** `./launchagents/com.cobrain.plist`

## Language

Infer language from the user's message. If invoked directly with no message context.

## Options
- English (default)
- 中文简体
- 中文繁體
- 日本語
- 한국어
- Others(allow user to specify language)

## Flow

### Step 1 — Check state

Run these in parallel:
- `ls ~/Library/LaunchAgents/com.cobrain.plist`
- `launchctl list | grep com.cobrain`

### Step 2 — Show status + ask what to do

Output a one-line status, then use AskUserQuestion. Keep option labels short — no descriptions.

**If not installed:**
Output: `cobrain is not installed.`
Ask: **Install?**
- Yes 
  - Default directory: `~/.claude/cobrain`
  - Custom directory: allow user to specify directory
- No

**If installed and running:**
Output: `cobrain is running (PID <pid>).`
Ask question: `cobrain is running (PID <pid>). What would you like to do?`
- Stop
- View logs
- Check update
- Uninstall

**If installed but not running:**
Output: `cobrain is installed but not running.`
Ask question: `cobrain is installed but not running. What would you like to do?`
- Start
- View logs
- Check update (also handles reinstall)
- Uninstall

### Step 3 — Install

Output progress before each step, e.g. "Checking prerequisites...", "Writing files...", "Starting daemon...".

1. Run a one-shot prerequisite check first:
   ```bash
   command -v python3.11 && python3.11 --version && \
   command -v ollama && ollama --version && \
   python3.11 -c "import PIL, ollama; print('ok')" && \
   ollama list | grep qwen3-vl
   ```
   If this command succeeds, skip prerequisite installation.

2. Install only missing prerequisites:
   - Python 3.11 missing: `brew install python@3.11`
   - Pillow or ollama Python package missing: `pip3.11 install Pillow ollama`
   - Ollama missing: `brew install ollama`
   - qwen3-vl:2b missing: `ollama pull qwen3-vl:2b`

3. `OUTPUT_DIR` = absolute path of the directory chosen in Step 2 (`~/.claude/cobrain` by default, or the custom path the user specified).

4. Create output directory, copy script, write plist:
   - Read `cobrain.py` from source, write to `<OUTPUT_DIR>/cobrain.py`
   - Write the source repo absolute path to `<OUTPUT_DIR>/.source_repo` (for check update)
   - Detect python path: `command -v python3.11`
   - Read plist template, substitute `PYTHON_PATH` and `OUTPUT_DIR`, write to `~/Library/LaunchAgents/com.cobrain.plist`

5. Load: `launchctl load ~/Library/LaunchAgents/com.cobrain.plist`

6. Confirm: `launchctl list | grep com.cobrain` shows a PID.

7. Output: `Done. Daemon is running. Logs: <OUTPUT_DIR>/daemon.log` + macOS permission note.

## macOS Permissions

The LaunchAgent uses `/bin/zsh` as the entry point so macOS requests permissions under `zsh` (which terminals like Ghostty already have). On first launch, macOS may show:

> "zsh" can run in the background.

Allow it. If zsh already has Accessibility and Screen Recording permissions, the daemon will work immediately. If logs stop after the startup line, add `/bin/zsh` to both permissions in System Settings → Privacy & Security.

## Check update

1. Determine the source repo path. Read the installed plist at `~/Library/LaunchAgents/com.cobrain.plist`, extract `OUTPUT_DIR` from the `WorkingDirectory` key, then check if `<OUTPUT_DIR>/.source_repo` exists (written during install). If not, fall back to `https://github.com/cyrus-cai/claude-cobrain.git`.

2. Compare version numbers:
   - **Installed version:** Read the `version` field from the locally installed SKILL.md frontmatter.
   - **Remote version:** `git -C <source_repo> fetch origin && git -C <source_repo> show origin/main:SKILL.md` — extract the `version` field from frontmatter.

3. Report results:
   - **Versions match:** Output `cobrain is up to date (v<version>).` — done.
   - **Versions differ:** Output `Update available: v<installed> → v<remote>`, show a summary of changes, then ask:
     - Update now (runs `git pull`, re-copies files to `OUTPUT_DIR`, restarts daemon)
     - Skip

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.cobrain.plist
rm ~/Library/LaunchAgents/com.cobrain.plist
# optionally: rm -rf <OUTPUT_DIR>
```
