# dotfiles

Personal macOS development environment. Run `dotfiles_install` on a fresh Mac and get a fully working environment — no manual steps after it finishes.

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

**Apps** (prompted, skipped if already installed):
- iTerm2 (with bundled profile from `config/iterm2/`)
- Ghostty (with config from `config/ghostty/`)
- Warp
- Cursor
- Claude desktop
- Claude CLI

**Dock:**
- Pins iTerm2, Cursor, and Claude to the right end of the Dock (via dockutil)

**GitHub:**
- PAT exports written to `~/.zshrc`
- SSH keys installed, host aliases configured per account
- Git identity set via `includeIf gitdir:` — right account used automatically per folder
- Optional bulk clone of all repos per account

**Daily commands** (symlinked to `~/bin/`, available everywhere):
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

## Updating scripts

```bash
git pull
```

Scripts are symlinked from `~/bin/` into the repo — pulling updates them immediately. No re-setup needed unless the repo structure changed.

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

# Refresh ~/bin symlinks
./scripts/setup/setup_symlinks
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
    ├── repo/                  ← daily commands (symlinked to ~/bin/)
    │   ├── repo_init
    │   ├── repo_clone
    │   └── repo_sync
    ├── setup/                 ← setup & repair tools (run by path)
    │   ├── setup_check
    │   ├── setup_pats
    │   ├── setup_ssh
    │   ├── setup_migrate
    │   └── setup_symlinks
    ├── apps/                  ← app installers (called by dotfiles_install)
    │   ├── iterm2
    │   ├── ghostty
    │   ├── warp
    │   ├── cursor
    │   ├── claude
    │   └── claude-cli
    └── lib/                   ← shared bash modules (sourced only)
```
