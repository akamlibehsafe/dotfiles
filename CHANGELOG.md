# Changelog

## Unreleased

### Added
- Multi-account SSH + Cursor setup guide (`docs/guides/github-multiple-accounts-mac-cursor.md`)
- Execution plan `docs/PLAN-0.4.0-gitscripts.md` and `docs/VERSIONING.md`
- (Planned) `gitscripts_*` scripts: preflight, PAT/SSH wizards, hybrid auth — see plan

### Changed
- (Planned) Hybrid authentication: SSH for git transport; PAT for API and bulk clone
- (Planned) Third GitHub account `rbonon`

### Breaking
- (Planned) Rename `gitak_*` → `gitscripts_*` in release 0.4.0

## 0.3.0 - 2026-01-15

### Added
- `environment_uninstall` script for complete environment removal
- `gitak_verify_PAT` script for PAT token validation
- Automatic repository cloning from both GitHub accounts during `environment_install`
- PAT.md file support for automated PAT configuration
- Git LFS installation and initialization support
- Aliases: cdg, cda, cdf, cds for quick navigation
- iTerm2 configuration import support

### Changed
- `environment_install` now handles PAT configuration at the beginning
- Symlink setup now automatically offered during `gitak_install` when run from repository

### Fixed
- Improved error handling in all scripts
- Better shell configuration file detection (bash vs zsh)
- Git safe.directory handling for temporary directories

## 0.2.0 - 2025-XX-XX

> **Note:** Documented development milestone only. No git tag.

### Added
- `environment_install` orchestration script for complete environment setup
- `zsh_install` script for Zsh, Oh My Zsh, and Powerlevel10k setup
- `gitak_setup_symlinks` script for automated symlink creation
- Support for multiple shell types (bash, zsh)
- Cursor Desktop optional installation via Homebrew

### Changed
- Improved installation flow with better user prompts
- Enhanced error messages and user feedback

## 0.1.0 - 2025-XX-XX

### Added
- Initial Git automation scripts:
  - `gitak_install` - Git tools installation
  - `gitak_create_from_local` - Create GitHub repo from local folder
  - `gitak_create_from_remote` - Clone existing GitHub repository
  - `gitak_push` - Commit and push changes with automatic account detection
- Support for dual GitHub accounts (fortegb, akamlibehsafe)
- PAT-based authentication for GitHub operations
- Symlink-based script distribution system
- macOS-focused installation and configuration
