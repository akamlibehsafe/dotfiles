# dotfiles — Specification v0.5.0

## Purpose

One repository, one goal: run `dotfiles_install` on a fresh macOS machine and get a fully working personal development environment. No manual steps after it finishes.

A second set of daily commands (`repo_init`, `repo_clone`, `repo_sync`) handle GitHub workflow across multiple accounts from that point forward.

---

## Repository layout

```
dotfiles/
├── dotfiles_install             ← entry point: full Mac bootstrap
├── dotfiles_uninstall         ← tears down what dotfiles_install built
├── dotfiles.conf.example      ← committed template
├── dotfiles.conf              ← gitignored, your copy (never commit)
├── CHANGELOG.md
├── README.md
├── config/                    ← your personal config files (applied by dotfiles_install)
│   ├── p10k.zsh               ← Powerlevel10k config (captured from current machine)
│   ├── zshrc                  ← Zsh config template
│   ├── gitconfig              ← global Git config template
│   ├── ghostty/
│   │   └── config             ← Ghostty config (placeholder, update over time)
│   └── iterm2/
│       └── iTerm2 State.itermexport
└── scripts/
    ├── repo/                  ← daily commands (copied to ~/bin/ by update_scripts)
    │   ├── repo_init
    │   ├── repo_clone
    │   └── repo_sync
    ├── setup/                 ← setup & repair tools (run by path when needed)
    │   ├── setup_check        ← read-only environment scan
    │   ├── setup_pats         ← PAT wizard
    │   ├── setup_ssh          ← SSH keys + config + git identity
    │   ├── setup_migrate      ← migrate HTTPS remotes to SSH aliases
    │   └── update_scripts     ← wire scripts/repo/* into ~/bin/
    ├── apps/                  ← pluggable app installers (called by dotfiles_install)
    │   ├── iterm2
    │   ├── ghostty
    │   ├── warp
    │   └── cursor
    └── lib/                   ← shared bash modules (sourced only, never run directly)
        ├── common.sh
        ├── accounts.sh
        ├── init.sh
        └── manifest.sh
```

---

## dotfiles.conf

Single configuration file at the repo root. Replaces the former `accounts.conf` and any separate credentials file. **Never commit `dotfiles.conf`** — it is gitignored.

Create your copy before running `dotfiles_install`:

```bash
cp dotfiles.conf.example dotfiles.conf
```

### Format

```bash
# dotfiles.conf — your personal setup configuration
# Never commit this file (gitignored)

# Where GitHub repositories are stored on this machine
github_root=~/Documents/GitHub

# --- Accounts ---
# One block per GitHub account
# account <username> <email> [Display Name]

account youruser you@example.com "Your Name"
pat ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ssh_private -----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEA...
-----END OPENSSH PRIVATE KEY-----

account yourotheruser other@example.com "Other Name"
pat ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ssh_private -----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEA...
-----END OPENSSH PRIVATE KEY-----

# --- Optional ---
# Skip bulk clone for an account during dotfiles_install
# clone youruser no

# Shell aliases (path under github_root, or "." = github_root itself)
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
| `ssh_private` | Yes | Full PEM block of the SSH private key — paste directly from 1Password or key file |
| `clone` | No | `yes` (default) or `no` — bulk clone during setup |
| `alias` | No | Shell shortcut under `github_root` |

### Where to get PATs
GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
Required scope: `repo`. Recommended: no expiration.

### SSH keys
Paste the full PEM block of your private key under `ssh_private`. Copy it directly from 1Password or from your key file (`cat ~/.ssh/id_ed25519_youruser`). `dotfiles_install` writes it to `~/.ssh/dotfiles/id_ed25519_<username>`, derives the public key via `ssh-keygen -y`, configures the SSH host alias, and adds it to the macOS keychain. No pre-existing key files needed on the new machine.

---

## Authentication model

### How it works

Repos live under `~/Documents/GitHub/<username>/`. Git's `includeIf gitdir:` automatically applies the right identity (name, email) based on folder. SSH host aliases (`github-<username>`) route the right key per account. This means:

- Terminal git commands use the right account automatically
- Cursor, Claude, and any other tool that uses git inherit the correct identity
- No per-command flags or manual account switching needed

### SSH host aliases

Each account gets an entry in `~/.ssh/config`:

```
Host github-youruser
  HostName ssh.github.com
  User git
  Port 443
  IdentityFile ~/.ssh/id_ed25519_youruser
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes
```

Remote URLs use the alias: `git@github-youruser:youruser/repo.git`

### Git identity (includeIf)

`~/.gitconfig` contains one `includeIf` block per account:

```
[includeIf "gitdir:~/Documents/GitHub/youruser/"]
  path = ~/.gitconfig-youruser
```

Each `~/.gitconfig-<username>` sets `user.name` and `user.email` for that account.

### PATs

Used for GitHub API calls only (repo creation in `repo_init`, bulk clone). Not embedded in remote URLs. Stored as `GH_TOKEN_<username>` environment variables in `~/.zshrc`.

---

## Script: `dotfiles_install`

### Purpose
Full Mac bootstrap. Orchestrates all phases in order. Stops on failure — does not silently continue past errors.

### Usage
```bash
cd /path/to/dotfiles
./dotfiles_install
```

### Pre-flight check
Before doing anything, checks for `dotfiles.conf` at the repo root. If missing:
```
dotfiles.conf not found.

Copy the template and fill in your details before running dotfiles_install:
  cp dotfiles.conf.example dotfiles.conf

See dotfiles.conf.example for the required format.
```
Then exits. No partial setup.

### Phases (in order)

1. **Validate `dotfiles.conf`** — all accounts have PAT and ssh_private defined
2. **Homebrew** — install if missing, update if present
3. **Core tools** — Git, Git LFS, GitHub CLI (`gh`), jq, Python, Node.js
4. **GitHub root** — create `github_root` directory if missing
5. **Auth setup** — for each account: install SSH key, configure SSH host alias, add to keychain, configure `includeIf` git identity, write PAT to `~/.zshrc`
6. **SSH verification** — test `ssh -T git@github-<username>` for each account; warn if not yet added to GitHub
7. **Shell** — install Zsh, Oh My Zsh, apply `config/zshrc` template to `~/.zshrc`, apply `config/p10k.zsh` to `~/.p10k.zsh`
8. **Apps** — run each installer in `scripts/apps/` (prompted, default yes): iterm2, ghostty, warp, cursor
9. **Bulk clone** — for each account where `clone` is not `no`, clone all repos via GitHub API
10. **Symlinks** — run `update_scripts` to wire `scripts/repo/*` into `~/bin/`
11. **Shell aliases** — write `alias` entries from `dotfiles.conf` to `~/.zshrc`
12. **Final verification** — confirm `repo_sync`, `repo_init`, `repo_clone` are on PATH and working
13. **Source shell** — source `~/.zshrc` so everything is live in current session

### Contract
`dotfiles_install` exits 0 only when the environment is fully ready. If it exits 0, no manual follow-up is needed.

---

## Script: `dotfiles_uninstall`

### Purpose
Interactively removes everything `dotfiles_install` installed. Useful for testing the installer. Does not remove Homebrew.

### Usage
```bash
./dotfiles_uninstall
```

### Behavior
Prompts before each removal step:
1. Check for unpushed git changes across `github_root` — offer to push before proceeding
2. Remove `~/bin/` symlinks for `repo_*` commands
3. Remove shell aliases from `~/.zshrc`
4. Remove `GH_TOKEN_*` exports from `~/.zshrc`
5. Remove SSH config blocks (gitscripts-managed sections only)
6. Remove `~/.gitconfig-<username>` files and `includeIf` blocks
7. Uninstall apps (iterm2, ghostty, warp, cursor) — each prompted individually
8. Remove Oh My Zsh, Powerlevel10k, p10k config
9. Remove `github_root` directory — **destructive**, confirmed explicitly
10. Remove PATH additions for `~/bin/`

---

## Script: `repo_init`

### Purpose
Turn a local folder into a new GitHub repository and push it.

### Usage
```bash
repo_init <user/repo>
```

### Arguments
- `user/repo` — GitHub username and repository name (e.g. `fortegb/my-project`)

### Behavior
1. Validate `user/repo` format and that `user` is a known account
2. Create the repository on GitHub via API using the account's PAT
3. Initialize git in the current directory if not already a repo
4. Detect large files (>100MB) and configure Git LFS automatically
5. Add SSH remote origin using the account's host alias
6. Stage all files, create initial commit
7. Push to GitHub

### Error cases
- Missing or wrong arguments → print usage and exit
- Unknown user → list configured accounts
- PAT missing or invalid → direct to `setup_pats`
- Repo already exists on GitHub → error with clear message
- Push fails → error with diagnostic hint

---

## Script: `repo_clone`

### Purpose
Clone an existing GitHub repository into the correct folder under `github_root`.

### Usage
```bash
repo_clone <user/repo>
```

### Arguments
- `user/repo` — GitHub username and repository name

### Behavior
1. Validate `user/repo` format and that `user` is a known account
2. Clone into `~/Documents/GitHub/<user>/<repo>/` using SSH host alias
3. Pull Git LFS files if present
4. Confirm clone directory, current branch, and commit identity

### Error cases
- Missing or wrong arguments → print usage and exit
- Unknown user → list configured accounts
- Directory already exists → error with path
- SSH not configured → direct to `setup_ssh`
- Repo not found → error with diagnostic hint

---

## Script: `repo_sync`

### Purpose
Stage, commit, and push changes in the current repository using the correct account automatically.

### Usage
```bash
repo_sync [-m "commit message"]
```

### Arguments
- `-m`, `--message` — commit message (optional; prompts interactively if not provided)
- `-h`, `--help` — show usage

### Behavior
1. Confirm current directory is a git repository
2. Parse remote URL to identify GitHub user and repo
3. Validate user is a known account
4. Use SSH if remote is already an SSH alias; fall back to PAT for HTTPS remotes
5. Stage all changes
6. Prompt for commit message if not provided via `-m`; default: `Update - YYYY-MM-DD HH:MM:SS`
7. Commit and push

### Error cases
- Not a git repository → error with clear message
- No remote configured → error with clear message
- Unknown user in remote → list configured accounts
- Nothing to commit → skip commit, attempt push
- Push fails → error with diagnostic hint

---

## Setup tools (`scripts/setup/`)

These are not symlinked to `~/bin/`. Run by path when needed for diagnostics or repair.

### `setup_check`
Read-only scan of the environment. Reports PAT status, SSH key status, git identity config, and remote URL types across all repos under `github_root`. Suggests remediation commands.

```bash
./scripts/setup/setup_check
```

### `setup_pats`
Interactive PAT wizard. Prompts for each account's PAT, verifies against GitHub API, writes to `~/.zshrc`.

```bash
./scripts/setup/setup_pats [--force] [--no-zshrc]
```

### `setup_ssh`
SSH key installation, `~/.ssh/config` host alias blocks, and `includeIf` git identity config.

```bash
./scripts/setup/setup_ssh [--dry-run] [--new-mac | --repair]
```

### `setup_migrate`
Migrates HTTPS remote URLs to SSH host alias format across all repos under `github_root`.

```bash
./scripts/setup/setup_migrate [--dry-run] [--apply]
```

### `update_scripts`
Creates symlinks in `~/bin/` for all scripts in `scripts/repo/`. Updates PATH in shell config. Removes deprecated symlink names.

```bash
./scripts/setup/update_scripts
```

---

## App installers (`scripts/apps/`)

Each is a self-contained script that installs one app and applies its config. Called by `dotfiles_install` but also runnable standalone.

| Script | Installs | Config applied |
|---|---|---|
| `iterm2` | iTerm2 via Homebrew cask | `config/iterm2/iTerm2 State.itermexport` |
| `ghostty` | Ghostty via Homebrew cask | `config/ghostty/config` → `~/.config/ghostty/config` |

> **Known issue — corporate networks:** Ghostty distributes its DMG exclusively from `release.files.ghostty.org` (Cloudflare CDN). Some corporate firewalls block this domain for non-browser traffic (TLS reset at handshake), while allowing the browser through. If `brew install --cask ghostty` fails with `Connection reset by peer`, open `https://ghostty.org/download` in a browser, download the macOS DMG, drag to `/Applications`, then re-run `dotfiles_install` — it will detect Ghostty as installed and skip the brew step. GitHub releases have no DMG assets; no alternative download source exists.
| `warp` | Warp via Homebrew cask | None (uses Warp cloud sync) |
| `cursor` | Cursor via Homebrew cask | None |

Adding a new app = add a script to `scripts/apps/`. `dotfiles_install` picks it up automatically.

---

## Shared library (`scripts/lib/`)

Sourced by other scripts. Never executed directly.

| File | Purpose |
|---|---|
| `common.sh` | UI helpers, PAT loading, remote URL parsing, SSH/git helpers |
| `accounts.sh` | Parse `dotfiles.conf`, expose account data as arrays |
| `init.sh` | Bootstrap: set `SCRIPTS_ROOT`, source `common.sh`, load accounts |
| `manifest.sh` | `~/bin` symlink names, deprecated symlink list |

### Common conventions
- All scripts resolve symlinks at startup to find their real path
- UI functions from `lib/common.sh`: `dotfiles_ui_error`, `dotfiles_ui_success`, `dotfiles_ui_info`, `dotfiles_ui_section` — no inline color duplication
- All user-facing scripts print usage and exit cleanly on wrong or missing arguments

---

## Core tools installed by `dotfiles_install`

| Tool | How |
|---|---|
| Homebrew | Official install script |
| Git | `brew install git` |
| Git LFS | `brew install git-lfs` |
| GitHub CLI (`gh`) | `brew install gh` |
| jq | `brew install jq` |
| Python | `brew install python` |
| Node.js | `brew install node` |
| Zsh | `brew install zsh` |
| Oh My Zsh | Official install script |
| Powerlevel10k | Oh My Zsh plugin |
| Claude CLI | `npm install -g @anthropic-ai/claude-code` |

---

## Config files (`config/`)

| File | Applied to | Source |
|---|---|---|
| `config/p10k.zsh` | `~/.p10k.zsh` | Captured from current machine |
| `config/zshrc` | Merged into `~/.zshrc` | Template, evolves over time |
| `config/gitconfig` | `~/.gitconfig` base | Template |
| `config/ghostty/config` | `~/.config/ghostty/config` | Placeholder, update over time |
| `config/iterm2/iTerm2 State.itermexport` | Imported into iTerm2 | Already in repo |

---

## Naming conventions

| Pattern | Example | Where |
|---|---|---|
| Entry points | `dotfiles_install`, `dotfiles_uninstall` | repo root |
| Daily commands | `repo_init`, `repo_clone`, `repo_sync` | `scripts/repo/`, `~/bin/` |
| Setup tools | `setup_check`, `setup_pats`, `setup_ssh` | `scripts/setup/` |
| App installers | `iterm2`, `ghostty`, `warp`, `cursor` | `scripts/apps/` |
| Lib modules | `common.sh`, `accounts.sh` | `scripts/lib/` |
| Config file | `dotfiles.conf` | repo root (gitignored) |
| Config template | `dotfiles.conf.example` | repo root (committed) |

---

## `.gitignore` entries required

```
dotfiles.conf
PAT.md
*.itermexport
.DS_Store
```

---

## Version

This spec describes **dotfiles v0.5.0**.
