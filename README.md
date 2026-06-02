# dotfiles

Personal macOS development environment setup and daily GitHub workflow toolkit. Run `dotfiles_install` on a fresh Mac and get a fully working environment — no manual steps after it finishes.

---

## Before you start

Two files are needed at the repo root before running `dotfiles_install`. Neither is committed — both are gitignored.

### 1. `dotfiles.conf`

Copy the template and fill in your GitHub accounts, PATs, and SSH private keys:

```bash
cp dotfiles.conf.example dotfiles.conf
```

Edit `dotfiles.conf` with your real values. See `dotfiles.conf.example` for the full format and instructions on where to get PATs and how to encode your SSH keys.

### 2. SSH keys

Paste each SSH private key as a full PEM block under `ssh_private` in `dotfiles.conf`. Copy directly from 1Password or from your key file:

```
ssh_private -----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEA...
-----END OPENSSH PRIVATE KEY-----
```

`dotfiles_install` writes the key to `~/.ssh/dotfiles/`, derives the public key automatically, and configures SSH host aliases per account. No pre-existing key files needed on the new machine.

---

## Setup

```bash
cd /path/to/dotfiles
./dotfiles_install
```

`dotfiles_install` is safe to re-run — it detects what is already configured and skips those phases.

### What it installs

**Core tools** (always):
- Homebrew, Git, Git LFS, GitHub CLI (`gh`), jq, Python, Node.js

**Shell:**
- Zsh, Oh My Zsh, Powerlevel10k (with your config from `config/p10k.zsh`)

**Apps** (prompted, skipped if already installed, updated if already present):
- iTerm2 (with bundled profile from `config/iterm2/`)
- Ghostty (with config from `config/ghostty/`)
- Warp
- Cursor
- Claude desktop + Claude CLI
- Raycast
- Typora
- Arc
- Zed
- Sublime Text
- TextMate

**Dock:**
- Pins all installed apps to the right end of the Dock (via dockutil)

**GitHub:**
- PAT exports written to `~/.zshrc`
- SSH keys installed, host aliases configured per account
- Git identity set via `includeIf gitdir:` — right account used automatically per folder
- Optional bulk clone of all repos per account

**Daily commands** (copied to `~/bin/`, available everywhere):
- `repo_init` — turn a local folder into a new GitHub repo
- `repo_clone` — clone an existing GitHub repo
- `repo_sync` — commit and push current repo

---

## Daily commands

```bash
# Create a new GitHub repo from the current folder
repo_init fortegb/my-project
repo_init akamlibehsafe/my-tool --public

# Clone an existing repo
repo_clone fortegb/my-project

# Commit and push
repo_sync
repo_sync -m "Fix login bug"
```

All commands self-document when run without arguments or with `--help`.

---

## Multi-account GitHub

Repos live under `~/Documents/GitHub/<username>/`. Git automatically uses the correct identity and SSH key based on the folder — no manual switching needed. This works in the terminal, Cursor, Claude, and any other tool that uses git.

---

## How daily commands work

`dotfiles_install` copies `scripts/repo/*` and `scripts/lib/*` into `~/bin/` as standalone files. It also copies `dotfiles.conf` to `~/.config/dotfiles/dotfiles.conf` — a standard config location that the scripts always check, regardless of where the installer was run from.

This means the commands are fully self-contained: you can run the installer from your Desktop, delete it afterwards, and `repo_init`, `repo_clone`, `repo_sync` keep working from anywhere.

### Keeping commands up to date

When you pull changes to the dotfiles repo, a **git post-merge hook** automatically runs `update_scripts` if any repo or lib scripts changed — `~/bin/` is refreshed without any manual step.

```bash
git pull   # hook fires automatically if scripts changed
```

To refresh manually at any time:

```bash
./scripts/setup/update_scripts
```

---

## What gets installed on this machine

Everything `dotfiles_install` places outside the repo itself — and everything `dotfiles_uninstall` removes:

| Location | Contents |
|---|---|
| `~/bin/repo_init`, `repo_clone`, `repo_sync` | Daily command scripts |
| `~/bin/lib/` | Shared library files the scripts depend on |
| `~/.config/dotfiles/dotfiles.conf` | Copy of your config (including secrets) |
| `~/.ssh/dotfiles/` | SSH private and public keys per account |
| `~/.ssh/config` | SSH host alias blocks per account |
| `~/.gitconfig` | `includeIf` blocks for per-account git identity |
| `~/.gitconfig-<user>` | Per-account git name and email |
| `~/.zshrc` | PAT exports, aliases, Oh My Zsh config |
| `~/.oh-my-zsh/` | Oh My Zsh, Powerlevel10k, plugins |
| `~/.p10k.zsh` | Powerlevel10k prompt config |
| `~/Documents/GitHub/<user>/` | Cloned repositories (prompted on uninstall) |

`dotfiles_uninstall` removes all of the above interactively, prompting before each step.

---

## Uninstall

```bash
./dotfiles_uninstall
```

Interactive — prompts before each removal step, skips silently if something is already gone. Removes Dock icons added by setup. Homebrew removal is always the last step and is optional.

For testing (keeps repo folders):

```bash
./dotfiles_uninstall --keep-repos
```

---

## Diagnostics and repair

```bash
# Read-only scan of PATs, SSH, git identity, and remotes
./scripts/setup/setup_check

# Re-configure PATs
./scripts/setup/setup_pats

# Re-configure SSH keys and git identity
./scripts/setup/setup_ssh --repair

# Migrate HTTPS remotes to SSH aliases
./scripts/setup/setup_migrate --dry-run
./scripts/setup/setup_migrate --apply

# Refresh ~/bin/ scripts
./scripts/setup/update_scripts
```

---

## Repository layout

```
dotfiles/
├── dotfiles_install             ← entry point: run on a fresh Mac
├── dotfiles_uninstall         ← undo everything dotfiles_install did
├── dotfiles.conf.example      ← template (copy to dotfiles.conf)
├── dotfiles.conf              ← your config (gitignored, never commit)
├── config/
│   ├── p10k.zsh               ← Powerlevel10k config
│   ├── zshrc                  ← Zsh config template
│   ├── gitconfig              ← global Git config template
│   ├── ghostty/config         ← Ghostty config
│   └── iterm2/                ← iTerm2 profile export
└── scripts/
    ├── repo/                  ← daily commands (copied to ~/bin/ by update_scripts)
    │   ├── repo_init
    │   ├── repo_clone
    │   └── repo_sync
    ├── setup/                 ← setup & repair tools (run by path)
    │   ├── setup_check
    │   ├── setup_pats
    │   ├── setup_ssh
    │   ├── setup_migrate
    │   └── update_scripts
    ├── apps/                  ← app installers (called by dotfiles_install)
    │   ├── iterm2
    │   ├── ghostty
    │   ├── warp
    │   ├── cursor
    │   ├── claude
    │   └── claude-cli
    └── lib/                   ← shared bash modules (sourced only)
```
