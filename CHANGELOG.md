# Changelog

## 0.5.0 - 2026-06-02

### Breaking
- Repo renamed from `gitscripts` to `dotfiles`
- Entry points renamed: `environment_install` → `dotfiles_install`, `environment_uninstall` → `dotfiles_uninstall`
- Daily commands renamed: `git_push` → `repo_sync`, `git_create_from_local` → `repo_init`, `git_create_from_remote` → `repo_clone`
- Scripts reorganised: `scripts/repo/`, `scripts/setup/`, `scripts/apps/`, `scripts/lib/`
- `ssh_key` directive in `dotfiles.conf` replaced by `ssh_private` (full PEM block — paste directly from 1Password)
- `setup_symlinks` replaced by `update_scripts` — scripts are now copied to `~/bin/`, not symlinked

### Added
- **Self-contained daily commands** — `scripts/repo/*` and `scripts/lib/*` copied to `~/bin/` by `update_scripts`; no dependency on installer location after setup
- **XDG config** — `dotfiles.conf` copied to `~/.config/dotfiles/dotfiles.conf` so scripts find it from anywhere
- **git post-merge hook** — auto-runs `update_scripts` when `scripts/repo/*` or `scripts/lib/*` change on `git pull`
- **Personal app installers** — Raycast, Typora, Arc, Zed, Sublime Text, TextMate added to `scripts/apps/`
- **App update on re-run** — existing apps get `brew upgrade` instead of silently passing
- **macOS Dock** — all installed apps pinned automatically via dockutil
- **Terminal font** — MesloLGS NF installed and set as default Terminal font (Phase 14)
- **Shell reset on uninstall** — resets default shell from Homebrew zsh back to `/bin/zsh`
- **Config files** in `config/` — p10k, ghostty (with theme + transparency), zshrc template, gitconfig
- New core tools: Python, Node.js, Git LFS, GitHub CLI, jq, Claude CLI
- `dotfiles_install` completes fully — no manual follow-up steps required
- All commands self-document when invoked with wrong or missing arguments
- Pre-flight state detection — install skips already-configured phases
- `CLAUDE.md` with full testing workflow and important rules

### Fixed
- `dotfiles_uninstall` without `dotfiles.conf` no longer aborts with fatal error
- Uninstall skips prompts for things already not present
- p10k instant-prompt `if/fi` block now fully removed from `.zshrc` on uninstall (no orphaned `fi`)
- SSH config block removal now checks for blocks before prompting
- Git identity removal now checks for files before prompting
- Oh My Zsh removal no longer re-prompts when only `.zshrc` references remain
- Empty array iteration under bash 3.2 (`set -u`) fixed throughout
- `wc -l` output whitespace stripping fixed under `pipefail`
- Legacy `gitscripts-managed` SSH config blocks removed by uninstall

### Changed
- `dotfiles_install` is a thin orchestrator — 15 phases, each independently skippable
- SSH keys stored as full PEM blocks in `dotfiles.conf` — no encoding needed
- Uninstall prompts per section, silently skips absent items
- Section headers bold and coloured for clear phase separation

## 0.4.0 - 2026-05-23

### Added
- iTerm2 install via Homebrew in `environment_install`; bundled profile import from `config/iterm2/iTerm2 State.itermexport` (`config/iterm2/README.md`)
- `accounts.conf` config file for GitHub usernames, emails, aliases, and paths (`config/accounts.conf.example`)
- Multi-account SSH + Cursor setup guide (`docs/guides/github-multiple-accounts-mac-cursor.md`)
- Execution plan `docs/PLAN-0.4.0-gitscripts.md` and `docs/VERSIONING.md`
- Setup helpers: `setup_preflight`, `setup_configure_pats`, `setup_ssh_setup`, `setup_migrate_remotes`; `scripts/lib/` modules (`common.sh`, `accounts.sh`, `init.sh`, `manifest.sh`)

### Changed
- **Daily Git commands** in `scripts/git/`: `git_push`, `git_create_from_remote`, `git_create_from_local`; **setup helpers** in `scripts/util/` as `setup_*` (off `~/bin` except `setup_symlinks`, `setup_zsh_install`)
- **Renamed folders:** `scripts/git/`, `scripts/util/`, `scripts/lib/`, `scripts/maintainer/`; unified [README.md](README.md) (removed `README_FIRST.md`)
- Hybrid auth in `git_push`, `git_create_from_local`, `git_create_from_remote`, `setup_verify_pat` (SSH + PAT fallback; multi-account)
- `git_create_from_local` requires repo created on GitHub first (no API create)
- `environment_install`: preflight → optional PAT/SSH wizards; bulk clone prefers SSH when configured
- Shared `scripts/lib/manifest.sh` for ~/bin symlinks
- `environment_uninstall`: removes legacy symlinks, `PAT.md`, jq, Meslo font; SSH cleanup defaults to yes

### Breaking
- **`gitak_*` / `gitscripts_*` → `git_*`** (daily) and **`setup_*`** (setup tools) — run `setup_symlinks` to refresh `~/bin`
- `environment_install` / `environment_uninstall` remain at `scripts/` root; `dev_*` symlinks removed from `~/bin`

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
- `setup_zsh_install` script for Zsh, Oh My Zsh, and Powerlevel10k setup
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
