# Changelog

## [0.2.6] - 2026-02-23

### Added
- Setup hook: displays install instructions automatically after `/plugin install claude-cobrain`.
- `plugin/scripts/setup.sh` post-install reminder script.

### Changed
- Removed duplicate `commands/install.md`; install is now only exposed via `skills/install/SKILL.md`.

## [0.2.5] - 2026-02-23

### Changed
- Simplified `commands/install.md` to thin proxy delegating to `skills/install/SKILL.md` (single source of truth).
- Optimized install skill to minimize user approval prompts (max 3 Bash calls).

### Fixed
- Fixed `plugin/hooks/hooks.json` schema: `hooks` is now an object (`{}`) instead of an array, resolving plugin load errors in Claude Code.

## [0.2.0] - 2026-02-23

### Changed
- **BREAKING**: Restructured from standalone `SKILL.md` to Claude Code Plugin architecture.
- Management now uses `/claude-cobrain:cobrain` with skill-based routing.
- Install, manage, and update logic split into independent skills (SRP).
- Daemon script moved to `plugin/scripts/cobrain.py`.
- LaunchAgent template moved to `plugin/launchagents/com.cobrain.plist`.
- Added marketplace registration at `.claude-plugin/marketplace.json`.
- Added plugin infrastructure: `plugin/.mcp.json` and `plugin/hooks/hooks.json` (Phase 2 preparation).
- Installation flow updated to `/plugin install claude-cobrain` + `/claude-cobrain:cobrain install`.
- Update flow now uses `/plugin update` instead of custom git pull logic.

## [0.1.1] - 2026-02-22

### Changed
- Each log entry now includes the model used (e.g. `ollama/qwen3-vl:2b`) directly in the heading, reflecting the actual backend at capture time.

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
