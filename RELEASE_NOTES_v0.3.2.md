# Release Notes for v0.3.2

## Release Date
2026-02-24

## Summary
This release includes important improvements to the cobrain daemon's reliability and architecture.

## Changes

### Added
- **Auto-create output directory**: The daemon now automatically creates the output directory when writing entries, preventing errors when the directory doesn't exist.

### Changed
- **Refactored skills architecture**: Split monolithic skill into modular, independent skills following Single Responsibility Principle (SRP).
- **Simplified background process**: Background process now runs directly without LaunchAgent wrapper, reducing complexity.
- **Improved plugin structure**: Better organization of daemon scripts, launch agents, and skill modules.

## Installation & Update

For new users:
```shell
/plugin marketplace add cyrus-cai/claude-cobrain
/plugin install claude-cobrain
/claude-cobrain:cobrain install
```

For existing users:
```shell
/plugin update claude-cobrain
/claude-cobrain:cobrain reinstall
```

## Technical Details

- Marketplace version: 0.3.2
- Plugin directory: ./plugin
- Main daemon script: plugin/scripts/cobrain.py
- Skill modules: plugin/skills/

## Commits Included

- `063c2cf` - fix: Auto-create output directory when writing entries
- `ee88a60` - feat: Split skills, drop LaunchAgent, use direct background process
- `305dfec` - docs: Update CHANGELOG for v0.3.2 release

## Next Steps for Release

1. **Create Pull Request**:
   - Branch: `claude/slack-create-release-shbEV` → `main`
   - Title: "Release v0.3.2"
   - Request review from <@U0AGA3N7MP1>

2. **After PR is merged**:
   ```bash
   git checkout main
   git pull origin main
   git tag -a v0.3.2 -m "Release v0.3.2"
   git push origin v0.3.2
   ```

3. **Create GitHub Release**:
   ```bash
   gh release create v0.3.2 \
     --title "Release v0.3.2" \
     --notes-file RELEASE_NOTES_v0.3.2.md
   ```

---

Prepared by Claude Code
Session: https://claude.ai/code/session_01SBTNPVB889ycDDPdpfDVhS
Slack thread: https://xiikiisworkplace.slack.com/archives/C0AGJSCRNKV/p1771949587404009
