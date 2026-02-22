# Changelog

## [0.1.0] - 2026-02-22

### Added
- Initial release of `claude-cobrain`, a macOS background daemon that continuously monitors your active window.
- Captures screenshots of the frontmost window and processes them through a local VLM (`qwen3-vl:2b` via Ollama).
- Appends timestamped summaries to markdown files.
- `SKILL.md` instruction file to manage daemon installation, operations, and updates.
- LaunchAgent template (`com.cobrain.plist`) for background execution.
- Python daemon script (`cobrain.py`) handling the image capture and processing loop.

### Changed
- Adjusted README heading levels and minor text formatting for improved readability.
