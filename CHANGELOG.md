# Changelog

## 0.5.0 - 2026-06-02

> **Complete rewrite and rename.** This release transforms `gitscripts` into a fully automated macOS bootstrap — run one script on a fresh Mac and get a complete development environment with no manual follow-up. Daily commands are self-contained and survive the installer being deleted. The uninstall is clean and complete.

### Breaking changes
- Repo renamed from `gitscripts` to `dotfiles`
- Entry points renamed: `environment_install` → `dotfiles_install`, `environment_uninstall` → `dotfiles_uninstall`
- Daily commands renamed: `git_push` → `repo_sync`, `git_create_from_local` → `repo_init`, `git_create_from_remote` → `repo_clone`
- Scripts reorganised into `scripts/repo/`, `scripts/setup/`, `scripts/apps/`, `scripts/lib/`
- `ssh_key` directive replaced by `ssh_private` — paste the full PEM block directly from 1Password
- `setup_symlinks` replaced by `update_scripts` — scripts are now copied to `~/bin/`, not symlinked

### Highlights

**Zero-dependency daily commands**
`repo_init`, `repo_clone`, and `repo_sync` are copied to `~/bin/` with all library dependencies. Run the installer from anywhere (Desktop, Downloads), delete it after, and the commands keep working independently. Config is stored at `~/.config/dotfiles/dotfiles.conf` — always found regardless of where the installer ran from.

**Automatic updates via git hook**
A post-merge hook in the cloned dotfiles repo detects changes to `scripts/repo/*` or `scripts/lib/*` on `git pull` and refreshes `~/bin/` automatically. No manual step needed after pulling script updates.

**Full app suite**
Installs and configures iTerm2, Ghostty, Warp, Cursor, Claude, Raycast, Typora, Arc, Zed, Sublime Text, and TextMate. On re-run, existing apps are upgraded rather than skipped. All installed apps are pinned to the Dock.

**Clean uninstall**
`dotfiles_uninstall` removes everything the installer placed on the machine — SSH keys, git identity, shell config, apps, Dock entries, and repos — prompting before each step and silently skipping anything already absent.

### Details

**Added**
- `update_scripts` — copies `scripts/repo/*` and `scripts/lib/*` to `~/bin/`, installs post-merge hook
- XDG config copy — `dotfiles.conf` written to `~/.config/dotfiles/` for script discoverability
- Personal app installers: Raycast, Typora, Arc, Zed, Sublime Text, TextMate
- App upgrade on re-run — `brew upgrade --cask` when app already installed
- macOS Dock configuration via dockutil — all apps pinned automatically
- MesloLGS NF font installed and set as default Terminal font
- Shell reset on uninstall — restores default shell from Homebrew zsh to `/bin/zsh`
- Config files in `config/`: p10k, Ghostty (theme + transparency), zshrc template, gitconfig
- Core tools: Python, Node.js, Git LFS, GitHub CLI (`gh`), jq, Claude CLI
- Pre-flight state detection — install skips already-configured phases
- `CLAUDE.md` with full testing workflow and important rules

**Fixed**
- Uninstall without `dotfiles.conf` no longer aborts — account steps skipped gracefully
- Uninstall skips prompts for things already absent
- p10k instant-prompt `if/fi` block fully removed from `.zshrc` on uninstall (no orphaned `fi`)
- SSH config, git identity, and Oh My Zsh sections pre-check before prompting
- Legacy `gitscripts-managed` SSH config blocks cleaned up by uninstall
- Empty array iteration under bash 3.2 (`set -u`) fixed throughout

**Changed**
- `dotfiles_install` is a thin 15-phase orchestrator — each phase independently skippable
- SSH keys stored as full PEM blocks in `dotfiles.conf` — no encoding needed
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
