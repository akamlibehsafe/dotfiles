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
- Android Studio, openspec
- Raycast, Typora, Arc, Zed, Sublime Text, TextMate

**Dock:**
- Pins all installed apps to the right end of the Dock (via dockutil)

**GitHub auth (HTTPS + PAT + Keychain):**
- PAT exports written to `~/.zshrc` as `GH_TOKEN_<username>`
- PATs stored in macOS Keychain — git authenticates silently, no flags needed
- Remote URLs use `https://<username>@github.com/...` — username disambiguates multi-account Keychain lookups
- Git identity set via `includeIf gitdir:` — right name/email used per account folder automatically

**Day-to-day GitHub scripts** (copied to `~/bin/`, available everywhere):
- `repo_init` — turn a local folder into a new GitHub repo
- `repo_clone` — clone an existing GitHub repo
- `repo_sync` — commit and push current repo

---

## Designed workflow — rules that must be followed

These scripts are designed to work together as a system. Bypassing them breaks the guarantees they provide silently — wrong identity on commits, wrong credentials, missing AI context files. **Always follow these rules:**

### Rule 1 — Always use `repo_clone` to clone repos, never raw `git clone`

```bash
# ✓ correct
repo_clone fortegb/my-project

# ✗ wrong — bypasses identity, auth, and AI context setup
git clone https://github.com/fortegb/my-project
```

`repo_clone` does three things raw `git clone` does not:
- Places the repo in `~/Documents/GitHub/<user>/<repo>/` — the folder that triggers correct git identity
- Bakes `user.name` and `user.email` into `.git/config` — commits are correct even if you move the folder
- Copies `AGENTS.md` and `DECISIONS.md` templates into the repo — AI context is ready from day one

### Rule 2 — Always use `repo_init` to create new repos, never initialise manually

```bash
# ✓ correct — run from inside the folder you want to publish
cd ~/Documents/GitHub/akamlibehsafe/my-tool
repo_init akamlibehsafe/my-tool

# ✗ wrong — bypasses identity, auth, and AI context setup
git init && git remote add origin ...
```

`repo_init` does the same three things as `repo_clone`, plus creates the repo on GitHub via API and pushes the initial commit.

### Rule 3 — Repos created on GitHub's web UI must be cloned with `repo_clone`

If you create a repo on github.com, the next step is always:

```bash
repo_clone <user/newrepo>
```

Not downloading the zip, not raw `git clone`. `repo_clone` sets everything up correctly in one step.

### Rule 4 — To rename a repo, reclone it

```bash
# 1. Rename on GitHub's web UI
# 2. Delete the local folder
# 3. Re-clone with the new name
repo_clone fortegb/new-name
```

Renaming locally or updating the remote URL manually is error-prone. Recloning is one step and guaranteed correct.

### Rule 5 — Keep repos under `~/Documents/GitHub/<username>/`

The folder structure is what drives automatic git identity selection. A repo outside this structure will fall back to global defaults for commit identity. Auth still works (it follows the remote URL), but identity may be wrong.

Once a repo is correctly set up with `repo_clone` or `repo_init`, identity is baked into `.git/config` and is correct even outside the managed folder — but it's still good practice to keep repos where they belong.

---

## Day-to-day GitHub scripts

### `repo_init <user/repo>`

Turn the current folder into a new GitHub repo and push it.

```bash
cd ~/Documents/GitHub/fortegb/my-project
repo_init fortegb/my-project
repo_init akamlibehsafe/my-tool --public
```

What it does:
- Creates the repo on GitHub via API (PAT required)
- Initialises git in the current directory
- Sets HTTPS remote URL: `https://<user>@github.com/<user>/<repo>.git`
- Bakes `user.name` and `user.email` into `.git/config`
- Detects large files (>100MB) and configures Git LFS automatically
- Copies `AGENTS.md` and `DECISIONS.md` templates into the repo
- Creates initial commit and pushes

### `repo_clone <user/repo>`

Clone an existing GitHub repo into the correct managed folder.

```bash
repo_clone fortegb/my-project
repo_clone akamlibehsafe/my-tool
```

What it does:
- Clones into `~/Documents/GitHub/<user>/<repo>/`
- Sets HTTPS remote URL: `https://<user>@github.com/<user>/<repo>.git`
- Bakes `user.name` and `user.email` into `.git/config`
- Pulls Git LFS files if present
- Copies `AGENTS.md` and `DECISIONS.md` templates if not already present

### `repo_sync [-m "message"]`

Stage, commit, and push all changes in the current repo.

```bash
repo_sync
repo_sync -m "Fix login bug"
```

What it does:
- Detects the GitHub account automatically from the remote URL
- Stages all changes
- Prompts for commit message if not provided (default: `Update - YYYY-MM-DD HH:MM:SS`)
- Commits and pushes to the current branch

All scripts self-document with `--help`.

---

## Multi-account GitHub

Three accounts are supported. Repos are organised by account under `~/Documents/GitHub/`:

```
~/Documents/GitHub/
├── fortegb/          ← construction company IT tools
├── rbonon/           ← personal projects
└── akamlibehsafe/    ← anonymous projects
```

**Identity** (commit author name and email) is determined by two independent mechanisms:
1. `includeIf gitdir:` in `~/.gitconfig` — maps each account folder to the right identity globally
2. `.git/config` local override — `repo_clone` and `repo_init` bake the identity directly into each repo, making it correct regardless of folder location

**Authentication** (push/pull) is determined by the remote URL — `https://fortegb@github.com/...` causes git to look up `fortegb`'s PAT in the Keychain automatically. No flags, no tokens, no account selection.

The two mechanisms are independent. After using `repo_clone` or `repo_init`, plain git commands (`git push`, `git pull`, `git commit`, etc.) work correctly from anywhere — no intervention needed.

---

## AI context files

Every repo created or cloned with these scripts gets two files automatically:

### `AGENTS.md`
AI agent context for the repo. Read automatically by Claude Code and compatible agents. Contains:
- What the repo is and does
- Structure, key files, tech stack
- Naming conventions and important rules
- Instructions for AI agents on how to work with the repo

On first use, an AI agent should explore the codebase and fill in the placeholder sections. The file gets richer over time.

### `DECISIONS.md`
Append-only log of architectural decisions and their rationale. Any AI agent working on the repo should:
- Read it before making significant changes
- Append new decisions at the bottom after each session
- Never modify or remove existing entries

Together these two files provide continuity across sessions, machines, and AI tools (Claude Code, Cursor, etc.). Context from one session is available to the next without re-explaining.

Templates for both files live in `templates/` in this repo and are copied automatically by `repo_clone` and `repo_init`.

---

## How day-to-day GitHub scripts work

`dotfiles_install` copies `scripts/repo/*` and `scripts/lib/*` into `~/bin/` as standalone files. It also copies `dotfiles.conf` to `~/.config/dotfiles/dotfiles.conf` — a standard config location the scripts always check, regardless of where the installer was run from.

This means the scripts are fully self-contained: you can run the installer from your Desktop, delete it afterwards, and `repo_init`, `repo_clone`, `repo_sync` keep working from anywhere.

### Keeping scripts up to date

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
| `~/bin/repo_init`, `repo_clone`, `repo_sync` | Day-to-day GitHub scripts |
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
├── AGENTS.md                    ← AI agent context for this repo
├── DECISIONS.md                 ← architectural decision history
├── config/
│   ├── p10k.zsh                 ← Powerlevel10k config
│   ├── zshrc                    ← Zsh config template
│   ├── gitconfig                ← global Git config template
│   ├── ghostty/config           ← Ghostty config
│   └── iterm2/                  ← iTerm2 profile export
├── templates/
│   ├── AGENTS.md                ← AI context template (copied into new repos)
│   └── DECISIONS.md             ← Decision log template (copied into new repos)
└── scripts/
    ├── repo/                    ← day-to-day GitHub scripts (copied to ~/bin/)
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
    │   ├── android-studio, openspec
    │   └── arc, zed, sublime-text, textmate, typora
    └── lib/                     ← shared bash modules (sourced only)
        ├── common.sh
        ├── accounts.sh
        ├── init.sh
        └── manifest.sh
```
