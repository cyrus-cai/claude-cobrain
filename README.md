# claude-cobrain

**English** | [简体中文](./README_zh.md)

> ⚠️ **Note**: This project is currently in the **preview stage**. Features may be unstable, and there might be breaking changes in future updates.

## What if AI had the same context as you?

Claude and other models already excel at specific tasks like coding. This project gives them persistent memory of entire workflow by continuously recording your screen activities.

**3 North Star Metrics:**

- Claude generates weekly and monthly work summaries with **95%+ actionable usability**
- Claude surfaces constructive suggestions that have **measurable economic value**
- Claude catches unconsidered decisions before they happen, compounding toward a **doubled income**

## What does claude-cobrain do?

claude-cobrain is a macOS background daemon that continuously monitors your active window and generates natural language summaries of what you're working on. It:

- captures screenshots of the frontmost window
- processes them through a local VLM
- appends timestamped summaries to markdown files

## Installation

Step 1 - Add the marketplace (first time only):

```shell
/plugin marketplace add cyrus-cai/claude-cobrain
```

Step 2 - Install the plugin:

```shell
/plugin install claude-cobrain
```

Step 3 - Set up the daemon:

```shell
/claude-cobrain:cobrain install
```

Currently for macOS only.

## Uninstalling

Important: Before removing the plugin, always run `/claude-cobrain:cobrain uninstall` first to stop the daemon and remove the LaunchAgent. Otherwise the daemon will continue running in the background.

1. `/claude-cobrain:cobrain uninstall` - stops daemon, removes LaunchAgent and daemon files
2. `/plugin uninstall claude-cobrain` - removes the plugin

## System Architecture

![System Architecture](system-architecture.png)

## System Requirements

| Component         | Requirement                       | Purpose                                      |
| ----------------- | --------------------------------- | -------------------------------------------- |
| Operating System  | macOS (tested on recent versions) | LaunchAgent support, Accessibility API       |
| Python            | 3.11                              | Runtime for daemon script                    |
| Ollama            | Latest version                    | Local LLM inference service                  |
| Model             | qwen3-vl:2b                       | Vision Language Model (2 billion parameters) |
| Python Packages   | Pillow, ollama                    | Image processing, API client                 |
| Disk Space        | ~2GB for model + logs             | Model storage and daily summaries            |
| macOS Permissions | Accessibility, Screen Recording   | Window detection, screenshot capture         |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
