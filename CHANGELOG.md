# Changelog

## 0.6.1 - 2026-06-11

### Added

- **Android Studio** — new `scripts/apps/android-studio` installer (Homebrew cask). Prompted during Phase 7; upgrades on re-run.
- **openspec** — new `scripts/apps/openspec` installer (`npm install -g @fission-ai/openspec@latest`). Follows the same pattern as `claude-cli`. Uninstall via `npm uninstall -g @fission-ai/openspec`.

## 0.6.0 - 2026-06-09

> **Auth model replaced and AI context system introduced.** SSH keys and SSH host aliases are gone. All GitHub authentication now uses HTTPS + PAT + macOS Keychain — works on all machines including corporate ones behind VPN. Git identity is baked directly into each repo's `.git/config` at clone/init time. Every new repo now gets `AGENTS.md` and `DECISIONS.md` automatically, providing session continuity across machines and AI tools.

### Breaking changes

- `ssh_private` directive removed from `dotfiles.conf` — SSH private keys are no longer stored or used. Remove them from your `dotfiles.conf` and save the updated version to your password manager.
- `setup_ssh` renamed to `setup_identity` — update any scripts or notes that referenced it.
- Remote URLs changed from `git@github-<user>:<user>/<repo>.git` to `https://<user>@github.com/<user>/<repo>.git`. Existing repos with old SSH remotes can be migrated with `setup_migrate --apply`.

### Highlights

**HTTPS + PAT + Keychain auth (all machines)**
Auth is now handled entirely by the macOS Keychain. PATs are stored once during `dotfiles_install` via the `security` CLI — no popup, no manual steps. Git finds the right PAT from the remote URL's embedded username. Works identically on Mac Mini, MacBook Pro, and MacBook Air (including behind GlobalProtect VPN where SSH is blocked).

**Identity baked into every repo**
`repo_clone` and `repo_init` now write `user.name` and `user.email` directly into each repo's `.git/config` as a local override. Commits are attributed correctly regardless of folder location. Plain git commands (`git push`, `git pull`, etc.) work correctly from inside any repo without concern about wrong account.

**Legacy SSH cleanup**
`dotfiles_install` pre-flight detects SSH artifacts left by older installs (`~/.ssh/dotfiles/`, SSH config blocks) and offers to remove them. `dotfiles_uninstall` does the same.

**`setup_identity --repair` rescans all repos**
After changing a name or email in `dotfiles.conf`, running `setup_identity --repair` updates the `[user]` block in every repo's `.git/config` under `github_root`.

**`setup_migrate` direction reversed**
Previously migrated HTTPS → SSH. Now migrates legacy SSH → HTTPS, completing the transition for existing repos.

**AI context system**
Every repo created or cloned with `repo_init`/`repo_clone` now gets `AGENTS.md` and `DECISIONS.md` automatically copied from `templates/`. `AGENTS.md` is auto-read by Claude Code and provides codebase context. `DECISIONS.md` is an append-only log of architectural decisions. Both files provide continuity across sessions, machines, and AI tools (Claude Code, Cursor). `CLAUDE.md` renamed to `AGENTS.md` for tool-neutral naming.

**Prompt color fix**
"Install appX? (Y/n)" prompts changed from dark lilac (hard to read on dark backgrounds) to bold white.

### Details

**Added**
- `dotfiles_remote_https_url()` in `common.sh` — builds `https://<user>@github.com/<user>/<repo>.git`
- `dotfiles_store_keychain_credential()`, `dotfiles_check_keychain_credential()`, `dotfiles_delete_keychain_credential()` in `common.sh` — all use `security` CLI directly for consistency
- Keychain storage step in `dotfiles_install` Phase 5 and `setup_identity`
- Keychain removal step (section 7) in `dotfiles_uninstall`
- Keychain credentials section in `setup_check`
- Legacy SSH cleanup: pre-flight in `dotfiles_install`, section 9 in `dotfiles_uninstall`
- Identity baking in `repo_clone` and `repo_init`: `git config --local user.name/email`
- Repo rescan in `setup_identity --repair/--new-mac`: updates `[user]` in all existing repos
- `templates/AGENTS.md` and `templates/DECISIONS.md` — AI context starter templates
- `AGENTS.md` and `DECISIONS.md` at repo root — AI context for this dotfiles repo itself
- `repo_clone` and `repo_init` copy templates into every new repo automatically
- `dotfiles_install` copies `templates/` to `~/.config/dotfiles/templates/` so scripts work from `~/bin/`
- `dotfiles_uninstall` removes `~/.config/dotfiles/templates/` during XDG cleanup

**Removed**
- `ssh_private` directive and PEM parsing from `accounts.sh`
- `DOTFILES_SSH_DIR`, `dotfiles_account_ssh_host()`, `dotfiles_account_key_path()`, `dotfiles_account_pubkey_path()`, `dotfiles_remote_ssh_url()`, `dotfiles_remote_uses_ssh()` from `common.sh`
- `DOTFILES_ACCOUNT_SSH_PEM` array from `accounts.sh`
- Phase 6 (SSH verification) from `dotfiles_install`
- `STATE_SSH` pre-flight check from `dotfiles_install`
- SSH config block section (was 7) from `dotfiles_uninstall`
- SSH keys section (was 9) from `dotfiles_uninstall`
- SSH section from `setup_check`
- SSH key install, SSH config block, and GitHub key upload prompt from `setup_ssh` (now `setup_identity`)
- PAT URL injection from `repo_sync` (credential helper handles auth transparently)

**Changed**
- `setup_ssh` → renamed to `setup_identity`; now handles git identity + Keychain only
- `setup_migrate` → direction reversed: SSH remotes → HTTPS (was HTTPS → SSH)
- `setup_check` → SSH section replaced with Keychain credentials + git credential helper checks; SSH remotes now flagged for migration (previously HTTPS remotes were flagged)
- `repo_clone` → uses HTTPS remote; bakes identity into `.git/config`
- `repo_init` → uses HTTPS remote; bakes identity into `.git/config`
- `repo_sync` → push simplified (credential helper handles auth; no PAT URL injection)
- `dotfiles.conf.example` → `ssh_private` blocks removed; comment header updated
- `dotfiles_install` pre-flight → `STATE_SSH` replaced with `STATE_IDENTITY` (checks `includeIf` blocks + Keychain entries)
- Prompt color (`dotfiles_ui_prompt`): `\033[0;34m` (dim blue/lilac) → `\033[1;37m` (bold white)
- `CLAUDE.md` renamed to `AGENTS.md` — tool-neutral name, auto-read by Claude Code and compatible agents
- `README.md` — added designed workflow rules section (5 rules with correct/wrong examples), AI context files section
- `SPEC.md` — updated auth model, script behaviors, added AI context files section and templates to layout
- `config/gitconfig` — fixed stale `setup_ssh` comment reference

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
