# dotfiles — Specification v0.6.0

## Purpose

One repository, one goal: run `dotfiles_install` on a fresh macOS machine and get a fully working personal development environment. No manual steps after it finishes.

A second set of day-to-day GitHub scripts (`repo_init`, `repo_clone`, `repo_sync`) handle GitHub workflow across multiple accounts from that point forward.

---

## Repository layout

```
dotfiles/
├── dotfiles_install             ← entry point: full Mac bootstrap
├── dotfiles_uninstall           ← tears down what dotfiles_install built
├── dotfiles.conf.example        ← committed template
├── dotfiles.conf                ← gitignored, your copy (never commit)
├── AGENTS.md                    ← AI agent context for this repo (auto-read by Claude Code)
├── DECISIONS.md                 ← append-only architectural decision log
├── CHANGELOG.md
├── README.md
├── SPEC.md
├── config/                      ← personal config files (applied by dotfiles_install)
│   ├── p10k.zsh                 ← Powerlevel10k config
│   ├── zshrc                    ← Zsh config template
│   ├── gitconfig                ← global Git config template
│   ├── ghostty/config
│   └── iterm2/iTerm2 State.itermexport
├── templates/                   ← copied into new repos by repo_init and repo_clone
│   ├── AGENTS.md                ← AI context template (fill in per project)
│   └── DECISIONS.md             ← decision log template (append-only)
└── scripts/
    ├── repo/                    ← day-to-day GitHub scripts (copied to ~/bin/ by update_scripts)
    │   ├── repo_init
    │   ├── repo_clone
    │   └── repo_sync
    ├── setup/                   ← setup & repair tools (run by path when needed)
    │   ├── setup_check          ← read-only environment scan
    │   ├── setup_pats           ← PAT wizard
    │   ├── setup_identity       ← git identity + Keychain credential setup
    │   ├── setup_migrate        ← migrate legacy SSH remotes to HTTPS
    │   └── update_scripts       ← wire scripts/repo/* into ~/bin/
    ├── apps/                    ← pluggable app installers (called by dotfiles_install)
    └── lib/                     ← shared bash modules (sourced only, never run directly)
        ├── common.sh
        ├── accounts.sh
        ├── init.sh
        └── manifest.sh
```

---

## dotfiles.conf

Single configuration file at the repo root. **Never commit `dotfiles.conf`** — it is gitignored. Keep a copy in a password manager.

Create your copy before running `dotfiles_install`:

```bash
cp dotfiles.conf.example dotfiles.conf
```

### Format

```bash
# Where GitHub repositories are stored on this machine
github_root=~/Documents/GitHub

# One block per GitHub account
# account <username> <email> [Display Name]
account youruser you@example.com "Your Name"
pat ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

account yourotheruser other@example.com "Other Name"
pat ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Optional: skip bulk clone for an account during dotfiles_install
# clone youruser no

# Optional: shell aliases (path under github_root, or "." = github_root)
alias cdg .
alias cda youruser
alias cdf yourotheruser
```

### Fields

| Field | Required | Description |
|---|---|---|
| `github_root` | Yes | Base directory for all repos, e.g. `~/Documents/GitHub` |
| `account` | Yes | GitHub username, commit email, optional display name |
| `pat` | Yes | Classic PAT with `repo` scope from GitHub Settings |
| `clone` | No | `yes` (default) or `no` — skip bulk clone for this account |
| `alias` | No | Shell shortcut under `github_root` |

### Where to get PATs

GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic).
Required scope: `repo`. Recommended: no expiration.

---

## Authentication model

### Overview

All git operations use HTTPS + PAT + macOS Keychain. SSH is not used.

This model works on all machines including corporate ones where SSH is blocked by VPN or firewall policy.

### Remote URLs

All remote URLs embed the GitHub username:

```
https://youruser@github.com/youruser/repo.git
```

Git extracts the username from the URL and uses it to look up credentials in the Keychain. This disambiguates multiple accounts on the same host without needing `credential.useHttpPath`.

### Keychain storage

During `dotfiles_install`, each account's PAT is stored in the macOS Keychain:

```
account  = <github-username>
server   = github.com
protocol = https
password = <PAT>
```

Stored and removed via the `security` CLI — silent, no graphical popup.

Once stored, all git operations (push, pull, fetch, clone) authenticate automatically. No flags, no tokens in commands, no manual selection.

### Git credential helper

```
[credential]
    helper = osxkeychain
```

Set globally in `~/.gitconfig` during setup. Git calls the osxkeychain helper transparently on every remote operation.

### Git identity

Two layers ensure commits are always attributed to the correct account:

**Layer 1 — `includeIf gitdir:` (global):**
```
[includeIf "gitdir:~/Documents/GitHub/youruser/"]
    path = ~/.gitconfig-youruser
```
Each `~/.gitconfig-<username>` sets `user.name` and `user.email` for that account folder.

**Layer 2 — `.git/config` local override (per repo):**
`repo_clone` and `repo_init` write `user.name` and `user.email` directly into each repo's `.git/config` at creation/clone time. This is the highest-priority git config level and overrides the global `includeIf` — making identity correct regardless of where the repo lives on disk.

### Auth vs identity summary

| What | Mechanism | Triggered by |
|---|---|---|
| Commit author | `.git/config` [user] + `includeIf` | Folder / local config |
| Push/pull auth | Keychain PAT | Remote URL username |

The two are independent. Both trigger automatically.

### Rules

- **Always use `repo_clone`** to clone repos — never raw `git clone`. `repo_clone` sets the correct remote URL and bakes identity into `.git/config`.
- **Always use `repo_init`** to create new repos — never initialise manually. `repo_init` does the same.
- Repos created via GitHub's web UI should be immediately cloned with `repo_clone`.
- Repos cloned or initialised correctly can be used with plain git commands (`git push`, `git pull`, etc.) from anywhere without concern about wrong account.

---

## AI context files

### Purpose

Provide continuity across sessions, machines, and AI tools (Claude Code, Cursor, etc.). Context from one session is available to the next without re-explaining.

### `AGENTS.md`

Auto-read by Claude Code and compatible agents at session start. Contains codebase overview, structure, naming conventions, important rules, and working instructions for AI agents. Every repo gets one via `repo_clone` or `repo_init`.

On first session in a new repo, the AI agent should explore the codebase and fill in the placeholder sections. The file gets richer over time as work happens.

### `DECISIONS.md`

Append-only log of architectural decisions and their rationale. Any AI agent working on the repo should:
- Read it before making significant changes
- Append new decisions at the bottom after each session (dated entry)
- Never modify or remove existing entries

### Templates

`templates/AGENTS.md` and `templates/DECISIONS.md` in this repo are the starter templates. `dotfiles_install` copies them to `~/.config/dotfiles/templates/` so they are always available to `repo_clone` and `repo_init` regardless of where the dotfiles repo is located.

---

## Script: `dotfiles_install`

### Purpose

Full Mac bootstrap. Orchestrates all phases in order. Stops on failure.

### Usage

```bash
cd /path/to/dotfiles
./dotfiles_install
```

Safe to re-run — detects what is already configured and skips completed phases.

### Pre-flight

- Checks for `dotfiles.conf` at repo root. Exits with clear message if missing.
- Detects legacy SSH artifacts from older installs (`~/.ssh/dotfiles/`, SSH config blocks) and offers to remove them.

### Phases

1. **Validate `dotfiles.conf`** — all accounts have PAT defined; copies `dotfiles.conf` and `templates/` to `~/.config/dotfiles/`
2. **Homebrew** — install if missing, update if present
3. **Core tools** — Git, Git LFS, GitHub CLI, jq, Python, Node.js
4. **GitHub root** — create `github_root` directory if missing
5. **Auth setup** — write PAT exports to `~/.zshrc`; configure `credential.helper = osxkeychain`; store each PAT in Keychain; run `setup_identity --new-mac` (git `includeIf` blocks + per-account gitconfigs)
6. **Shell** — Zsh, Oh My Zsh, Powerlevel10k, apply `config/zshrc` and `config/p10k.zsh`
7. **Apps** — run each installer in `scripts/apps/` (prompted)
8. **Bulk clone** — clone all repos per account via GitHub API (prompted)
9. **Install scripts** — run `update_scripts` to wire `scripts/repo/*` into `~/bin/`
10. **Shell aliases** — write `alias` entries from `dotfiles.conf` to `~/.zshrc`
11. **Verification** — confirm `repo_init`, `repo_clone`, `repo_sync` are on PATH
12. **Dock** — pin installed apps via dockutil
13. **Terminal font** — install MesloLGS NF, configure macOS Terminal
14. **Activate** — source `~/.zshrc`

### Contract

Exits 0 only when the environment is fully ready.

---

## Script: `dotfiles_uninstall`

### Purpose

Interactively removes everything `dotfiles_install` installed.

### Usage

```bash
./dotfiles_uninstall [--keep-repos]
```

`--keep-repos` skips removal of per-account repo folders. Useful for iterative testing.

### Steps (in order)

1. Check for unpushed git changes across `github_root`
2. Remove `~/bin/` scripts (`repo_*` commands and `lib/`)
3. Remove shell aliases from `~/.zshrc`
4. Remove `GH_TOKEN_*` exports from `~/.zshrc`
5. Remove XDG config (`~/.config/dotfiles/dotfiles.conf`)
6. Remove `~/bin` PATH addition from `~/.zshrc`
7. Remove Keychain credentials (one per account)
8. Remove legacy SSH artifacts from older installs (if present)
9. Remove git identity config (`~/.gitconfig-<user>` files and `includeIf` blocks)
10. Uninstall apps (each prompted individually)
11. Remove Oh My Zsh, Powerlevel10k, `~/.p10k.zsh`
12. Remove per-account repo folders (destructive, confirmed explicitly)
13. Remove Dock entries
14. Reset default shell to `/bin/zsh`
15. Remove Homebrew (optional, last step)

---

## Script: `repo_init`

### Purpose

Turn the current folder into a new GitHub repository and push it.

### Usage

```bash
repo_init <user/repo> [--private | --public]
```

### Behavior

1. Validate `user/repo` format and that `user` is a known account
2. Create the repository on GitHub via API using the account's PAT
3. Initialise git in the current directory if not already a repo
4. Detect large files (>100MB) and configure Git LFS automatically
5. Set HTTPS remote origin: `https://<user>@github.com/<user>/<repo>.git`
6. Copy `AGENTS.md` and `DECISIONS.md` from `~/.config/dotfiles/templates/` if not present
7. Bake git identity (`user.name`, `user.email`) into `.git/config`
8. Stage all files, create initial commit
9. Push to GitHub

### Error cases

- Unknown user → lists configured accounts
- PAT missing → directs to `setup_pats`
- Repo already exists on GitHub → clear error
- Push fails → diagnostic hint

---

## Script: `repo_clone`

### Purpose

Clone an existing GitHub repository into the correct managed folder.

### Usage

```bash
repo_clone <user/repo>
```

### Behavior

1. Validate `user/repo` format and that `user` is a known account
2. Clone into `~/Documents/GitHub/<user>/<repo>/` via HTTPS
3. Copy `AGENTS.md` and `DECISIONS.md` from `~/.config/dotfiles/templates/` if not present
4. Bake git identity (`user.name`, `user.email`) into `.git/config`
5. Pull Git LFS files if present
5. Print remote URL, branch, and identity

### Error cases

- Unknown user → lists configured accounts
- Destination already exists → error with path
- Clone fails → diagnostic hint

---

## Script: `repo_sync`

### Purpose

Stage, commit, and push changes in the current repository.

### Usage

```bash
repo_sync [-m "commit message"]
```

### Behavior

1. Confirm current directory is a git repository
2. Parse remote URL to identify GitHub user and repo
3. Validate user is a known account
4. Stage all changes
5. Prompt for commit message if not provided; default: `Update - YYYY-MM-DD HH:MM:SS`
6. Commit and push to current branch

### Error cases

- Not a git repo → clear error
- No remote → clear error
- Unknown user in remote → lists configured accounts
- Push fails → diagnostic hint

---

## Setup tools (`scripts/setup/`)

Not copied to `~/bin/`. Run by path when needed.

### `setup_check`

Read-only environment scan. Reports PAT validity, Keychain credential status, git identity config, git credential helper config, and remote URL types across all repos under `github_root`. Suggests remediation commands.

```bash
./scripts/setup/setup_check
```

### `setup_pats`

Interactive PAT wizard. Prompts for each account's PAT, verifies against GitHub API, writes to `~/.zshrc`.

```bash
./scripts/setup/setup_pats [--force] [--no-shell]
```

### `setup_identity`

Configures git `includeIf` identity blocks and stores PATs in the macOS Keychain. In repair mode, also rescans all repos under `github_root` and rewrites the `[user]` block in each `.git/config`.

```bash
./scripts/setup/setup_identity [--dry-run] [--new-mac | --repair]
```

Run with `--repair` after changing a name or email in `dotfiles.conf`.

### `setup_migrate`

Migrates legacy SSH remote URLs to HTTPS format across all repos under `github_root`.

```bash
./scripts/setup/setup_migrate [--dry-run | --apply]
```

Converts `git@github-user:user/repo.git` → `https://user@github.com/user/repo.git`.

### `update_scripts`

Copies `scripts/repo/*` and `scripts/lib/*` to `~/bin/`. Updates PATH in shell config. Removes deprecated symlink names. Installs post-merge hook.

```bash
./scripts/setup/update_scripts
```

---

## App installers (`scripts/apps/`)

Self-contained scripts, one per app. Called by `dotfiles_install` but also runnable standalone.

| Script | Installs | Config applied |
|---|---|---|
| `iterm2` | iTerm2 via Homebrew cask | `config/iterm2/iTerm2 State.itermexport` |
| `ghostty` | Ghostty via Homebrew cask | `config/ghostty/config` → `~/.config/ghostty/config` |
| `warp` | Warp via Homebrew cask | None |
| `cursor` | Cursor via Homebrew cask | None |
| `claude` | Claude desktop via Homebrew cask | None |
| `claude-cli` | Claude CLI via npm | None |
| `android-studio` | Android Studio via Homebrew cask | None |
| `openspec` | openspec CLI via npm (`@fission-ai/openspec`) | None |
| `arc` | Arc via Homebrew cask | None |
| `zed` | Zed via Homebrew cask | None |
| `sublime-text` | Sublime Text via Homebrew cask | None |
| `textmate` | TextMate via Homebrew cask | None |
| `typora` | Typora via Homebrew cask | None |

> **Known issue — corporate networks:** Ghostty distributes its DMG from Cloudflare CDN. Some corporate firewalls block this for non-browser traffic. If `brew install --cask ghostty` fails, download the DMG via browser from `https://ghostty.org/download`, drag to `/Applications`, then re-run `dotfiles_install` — it detects Ghostty and skips the brew step.

Adding a new app = add a script to `scripts/apps/`. `dotfiles_install` picks it up automatically.

---

## Shared library (`scripts/lib/`)

Sourced by other scripts. Never executed directly.

| File | Purpose |
|---|---|
| `common.sh` | UI helpers, PAT loading, HTTPS URL builder, Keychain helpers, remote URL parsing |
| `accounts.sh` | Parse `dotfiles.conf`, expose account data as arrays |
| `init.sh` | Bootstrap: set `SCRIPTS_ROOT`, source `common.sh`, load accounts |
| `manifest.sh` | `~/bin` script names, deprecated names list |

Key functions in `common.sh`:

| Function | Purpose |
|---|---|
| `dotfiles_remote_https_url <user> <repo>` | Build `https://<user>@github.com/<user>/<repo>.git` |
| `dotfiles_store_keychain_credential <user> <pat>` | Store PAT in Keychain via `security` |
| `dotfiles_check_keychain_credential <user>` | Check if Keychain entry exists |
| `dotfiles_delete_keychain_credential <user>` | Remove Keychain entry |
| `dotfiles_parse_remote <url>` | Parse remote URL → `"username reponame"` |
| `dotfiles_account_pat_resolved <user>` | PAT from env var, falls back to dotfiles.conf |

---

## Core tools installed

| Tool | How |
|---|---|
| Homebrew | Official install script |
| Git + Git LFS | `brew install git git-lfs` |
| GitHub CLI | `brew install gh` |
| jq | `brew install jq` |
| Python, Node.js | `brew install python node` |
| Zsh | `brew install zsh` |
| Oh My Zsh | Official install script |
| Powerlevel10k | Oh My Zsh custom theme |
| Claude CLI | `npm install -g @anthropic-ai/claude-code` |

---

## Config files (`config/`)

| File | Applied to | Notes |
|---|---|---|
| `config/p10k.zsh` | `~/.p10k.zsh` | Captured from current machine |
| `config/zshrc` | Merged into `~/.zshrc` | Template, evolves over time |
| `config/gitconfig` | `~/.gitconfig` base | Template — credential.helper added by setup |
| `config/ghostty/config` | `~/.config/ghostty/config` | Theme + transparency settings |
| `config/iterm2/iTerm2 State.itermexport` | Imported into iTerm2 | Already in repo |

---

## Naming conventions

| Pattern | Example | Location |
|---|---|---|
| Entry points | `dotfiles_install`, `dotfiles_uninstall` | repo root |
| Day-to-day GitHub scripts | `repo_init`, `repo_clone`, `repo_sync` | `scripts/repo/`, `~/bin/` |
| Setup tools | `setup_check`, `setup_pats`, `setup_identity` | `scripts/setup/` |
| App installers | `iterm2`, `ghostty`, `warp`, `cursor` | `scripts/apps/` |
| Lib modules | `common.sh`, `accounts.sh` | `scripts/lib/` |
| Config file | `dotfiles.conf` | repo root (gitignored) |
| Config template | `dotfiles.conf.example` | repo root (committed) |
| Internal prefix | `dotfiles_*` | all functions and variables |

---

## Version

This spec describes **dotfiles v0.6.0**.
