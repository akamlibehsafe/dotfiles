# dotfiles

Personal macOS development environment setup and daily GitHub workflow toolkit. Run `dotfiles_install` on a fresh Mac and get a fully working environment — no manual steps after it finishes.

---

## Before you start

One file is needed at the repo root before running `dotfiles_install`. It is gitignored and never committed.

### `dotfiles.conf`

Copy the template and fill in your GitHub accounts and PATs:

```bash
cp dotfiles.conf.example dotfiles.conf
```

Edit `dotfiles.conf` with your real values. See `dotfiles.conf.example` for the full format and instructions on where to get PATs.

**Keep a copy of `dotfiles.conf` in a password manager** (e.g. 1Password). You will need it when setting up a new machine.

---

## Setup

```bash
cd /path/to/dotfiles
./dotfiles_install
```

`dotfiles_install` is safe to re-run — it detects what is already configured and skips those phases. On first run it detects and offers to clean up SSH artifacts left by older installs.

### What it installs

**Core tools** (always):
- Homebrew, Git, Git LFS, GitHub CLI (`gh`), jq, Python, Node.js

**Shell:**
- Zsh, Oh My Zsh, Powerlevel10k (with your config from `config/p10k.zsh`)

**Apps** (prompted, skipped if already installed):
- iTerm2 (with bundled profile from `config/iterm2/`)
- Ghostty (with config from `config/ghostty/`)
- Warp, Cursor, Claude desktop, Claude CLI
- Raycast, Typora, Arc, Zed, Sublime Text, TextMate

**Dock:**
- Pins all installed apps to the right end of the Dock (via dockutil)

**GitHub auth (HTTPS + PAT + Keychain):**
- PAT exports written to `~/.zshrc` as `GH_TOKEN_<username>`
- PATs stored in macOS Keychain — git authenticates silently, no flags needed
- Remote URLs use `https://<username>@github.com/...` — username disambiguates multi-account Keychain lookups
- Git identity set via `includeIf gitdir:` — right name/email used per account folder automatically

**Daily commands** (copied to `~/bin/`, available everywhere):
- `repo_init` — turn a local folder into a new GitHub repo
- `repo_clone` — clone an existing GitHub repo
- `repo_sync` — commit and push current repo

---

## Daily commands

### `repo_init <user/repo>`

Turn the current folder into a new GitHub repo and push it.

```bash
cd ~/Documents/GitHub/fortegb/my-project
repo_init fortegb/my-project
repo_init akamlibehsafe/my-tool --public
```

- Creates the repo on GitHub via API
- Initialises git in the current directory
- Sets HTTPS remote URL with username embedded
- Bakes the correct git identity into `.git/config`
- Detects large files (>100MB) and configures Git LFS automatically
- Creates initial commit and pushes

**Always use `repo_init` to create repos** — it ensures identity and remote URL are correctly configured from the start.

### `repo_clone <user/repo>`

Clone an existing GitHub repo into the correct managed folder.

```bash
repo_clone fortegb/my-project
repo_clone akamlibehsafe/my-tool
```

- Clones into `~/Documents/GitHub/<user>/<repo>/`
- Sets HTTPS remote URL with username embedded
- Bakes the correct git identity (`user.name`, `user.email`) into `.git/config`
- Pulls Git LFS files if present

**Always use `repo_clone` instead of raw `git clone`** — it ensures the repo is in the right folder and has the correct identity baked in, so all subsequent plain git commands work correctly regardless of folder.

### `repo_sync [-m "message"]`

Stage, commit, and push all changes in the current repo.

```bash
repo_sync
repo_sync -m "Fix login bug"
```

- Detects the GitHub account automatically from the remote URL
- Stages all changes, prompts for commit message if not provided
- Default message: `Update - YYYY-MM-DD HH:MM:SS`
- Pushes to the current branch on origin

All commands self-document with `--help`.

---

## Multi-account GitHub

Three accounts are supported. Repos are organised by account under `~/Documents/GitHub/`:

```
~/Documents/GitHub/
├── fortegb/          ← construction company IT tools
├── rbonon/           ← personal projects
└── akamlibehsafe/    ← anonymous projects
```

**Identity** (commit author) is determined by folder — `includeIf gitdir:` in `~/.gitconfig` maps each subfolder to the right `user.name` and `user.email`. Additionally, `repo_clone` and `repo_init` bake the identity directly into each repo's `.git/config` as a local override, so commits are correct even if the repo moves out of its managed folder.

**Authentication** (push/pull) is determined by the remote URL — `https://fortegb@github.com/...` causes git to look up `fortegb`'s PAT in the Keychain. The two mechanisms are independent and both trigger automatically.

Plain git commands (`git push`, `git pull`, `git commit`, etc.) work correctly from inside any repo cloned or initialised with the dotfiles scripts — no flags, no account selection, no manual steps.

---

## How daily commands work

`dotfiles_install` copies `scripts/repo/*` and `scripts/lib/*` into `~/bin/` as standalone files. It also copies `dotfiles.conf` to `~/.config/dotfiles/dotfiles.conf` — a standard config location the scripts always check, regardless of where the installer was run from.

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

Everything `dotfiles_install` places outside the repo itself:

| Location | Contents |
|---|---|
| `~/bin/repo_init`, `repo_clone`, `repo_sync` | Daily command scripts |
| `~/bin/lib/` | Shared library files the scripts depend on |
| `~/.config/dotfiles/dotfiles.conf` | Copy of your config (including secrets) |
| macOS Keychain | One PAT entry per GitHub account |
| `~/.gitconfig` | `credential.helper` + `includeIf` blocks per account |
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

Interactive — prompts before each removal step, skips silently if something is already gone. Detects and removes legacy SSH artifacts from older installs. Removes Keychain entries, git identity config, apps, Dock entries. Homebrew removal is always the last step and is optional.

For testing (keeps repo folders):

```bash
./dotfiles_uninstall --keep-repos
```

---

## Diagnostics and repair

```bash
# Read-only scan of PATs, Keychain credentials, git identity, and remotes
./scripts/setup/setup_check

# Re-configure PATs and refresh Keychain entries
./scripts/setup/setup_pats

# Re-configure git identity (includeIf) and Keychain credentials
# Also rescans all existing repos and rewrites .git/config [user] blocks
./scripts/setup/setup_identity --repair

# Migrate legacy SSH remote URLs to HTTPS across all repos
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
├── dotfiles_uninstall           ← undo everything dotfiles_install did
├── dotfiles.conf.example        ← template (copy to dotfiles.conf)
├── dotfiles.conf                ← your config (gitignored, never commit)
├── config/
│   ├── p10k.zsh                 ← Powerlevel10k config
│   ├── zshrc                    ← Zsh config template
│   ├── gitconfig                ← global Git config template
│   ├── ghostty/config           ← Ghostty config
│   └── iterm2/                  ← iTerm2 profile export
└── scripts/
    ├── repo/                    ← daily commands (copied to ~/bin/)
    │   ├── repo_init
    │   ├── repo_clone
    │   └── repo_sync
    ├── setup/                   ← setup & repair tools (run by path)
    │   ├── setup_check
    │   ├── setup_pats
    │   ├── setup_identity
    │   ├── setup_migrate
    │   └── update_scripts
    ├── apps/                    ← app installers (called by dotfiles_install)
    │   ├── iterm2, ghostty, warp, cursor
    │   ├── claude, claude-cli
    │   └── arc, zed, sublime-text, textmate, typora
    └── lib/                     ← shared bash modules (sourced only)
        ├── common.sh
        ├── accounts.sh
        ├── init.sh
        └── manifest.sh
```
