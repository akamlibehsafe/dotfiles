# GitScripts

Bash scripts for **macOS** that set up a development environment and make **multi-account GitHub** work from the terminal and from IDEs (e.g. 
Cursor).

Download and unpack the zip file locally on your Mac, and read these instructions to install and execute them. 

---

## What this is

A small toolkit you keep in a git repository. Scripts live here; after setup they are also available as commands in `~/bin/` (via symlinks). You update the toolkit with `git pull` and re-run `setup_symlinks` if paths change.

**macOS only** for install and environment scripts.

---

## What it does

### 1. Install a Full development environment (`environment_install`)

One interactive installer for a **new or reset Mac**. It can install and configure:

| Area | What you get |
|------|----------------|
| **Package manager** | [Homebrew](https://brew.sh) |
| **Git tooling** | Git, Git LFS, GitHub CLI (`gh`), `jq` |
| **Shell** | Zsh, Oh My Zsh, Powerlevel10k (optional theme setup) |
| **Editor / terminal** | Optional Cursor Desktop; optional iTerm2 config import |
| **GitHub layout** | `~/Documents/GitHub` (or path from `accounts.conf`), optional bulk clone of repos per account |
| **Multi-account GitHub** | PAT setup (API / HTTPS) and SSH host aliases so the right account is used per repo — works in the **CLI and in IDEs** |
| **Convenience** | Symlinks in `~/bin/`, shell aliases (`cdg`, `cda`, …) from `accounts.conf` |

Setup helpers under `scripts/util/` (`setup_preflight`, `setup_configure_pats`, `setup_ssh_setup`, …) run during install when you confirm at the prompts.

To remove what the installer added (destructive, interactive): `environment_uninstall` from `scripts/`.

### 2. Provide convenient daily-use Git scripts (`git_*` on `~/bin`)

After `setup_symlinks`, use these from any directory (with `~/bin` on your `PATH`):

| Command | Purpose |
|---------|---------|
| `git_create_from_remote` | Clone `username/repo` under your GitHub root |
| `git_create_from_local` | Initialize the current folder and connect it to a **new** GitHub repo |
| `git_push` | Stage, commit, and push changes (uses the account that owns the remote) |

Authentication follows your PAT and SSH setup; the script picks the right credentials from the repo’s GitHub owner.


## What input information is needed

Prepare these **before** running `environment_install` (or before using the daily commands on an already-configured Mac).

### 1. `accounts.conf` (required, local only)

Only the template is in git. Create your copy at the **repo root**:

```bash
cp config/accounts.conf.example accounts.conf
```

Edit `accounts.conf` with your real data. **Do not commit it** — it is in `.gitignore`.

| Setting | Meaning |
|---------|---------|
| `github_root` | Where repos live, e.g. `~/Documents/GitHub` → `github_root/USERNAME/repo` |
| `account USER EMAIL [NAME]` | Each GitHub login and commit email (add as many accounts as you need) |
| `clone USER no` | Optional: skip bulk clone for that user during install |
| `alias NAME PATH` | Optional: shell shortcuts under `github_root` |
| `toolkit_repo` | Optional: `owner/repo` if `setup_install` must clone this toolkit from GitHub |

All accounts are equal; there is no “primary” GitHub user.

### 2. Personal Access Tokens (PATs)

One classic PAT per username in `accounts.conf`, with **`repo`** scope (installer will guide you if needed).

Store them as environment variables (not in `accounts.conf`):

```bash
export GH_TOKEN_<github_username>="your_token"
```

Put exports in `PAT.md` at the repo root (gitignored) or in `~/.zshrc`. The installer reads `PAT.md` when present.

### 3. This repository on disk

Download as a zip or clone. You can run `environment_install` from the `scripts/` folder inside the tree.

### Optional later

- SSH keys: created/configured by install or `./scripts/util/setup_ssh_setup`
- Multi-account + Cursor details: [docs/guides/github-multiple-accounts-mac-cursor.md](docs/guides/github-multiple-accounts-mac-cursor.md)

Never commit `PAT.md` or `accounts.conf`.

---

## How to use it

### New Mac — full setup

```bash
cd /path/to/gitscripts/scripts
chmod +x environment_install
./environment_install
```

Follow the prompts (PATs are asked about early). Optional steps (Cursor, iTerm2 install/profile, p10k) can be skipped. Typical run: **10–30 minutes**. Safe to re-run; already-installed parts are skipped or updated.

**iTerm2:** installs the app with Homebrew if needed, then can open the repo’s profile export (`config/iterm2/`) for you to confirm import in iTerm2. See [config/iterm2/README.md](config/iterm2/README.md).

Then:

```bash
source ~/.zshrc
./scripts/util/setup_preflight    # optional: check PATs and SSH
```

### Mac already set up — Git tools only

```bash
./scripts/util/setup_install
./scripts/util/setup_symlinks
source ~/.zshrc
```

Configure `accounts.conf` and PATs as above if you have not already.

### Symlinks (`~/bin`)

Scripts stay in the repo; commands are linked into `~/bin/`:

```bash
cd /path/to/gitscripts
./scripts/util/setup_symlinks
```

Re-run after `git pull` or if you move the repository. This adds `~/bin` to `PATH` when needed.

### Daily Git — examples

```bash
# Clone an existing repo
git_create_from_remote akamlibehsafe/my-project
cd ~/Documents/GitHub/akamlibehsafe/my-project

# Work, then push
git_push -m "Update README"
```

```bash
# New project from a local folder (creates GitHub repo + first push)
cd /path/to/my-app
git_create_from_local fortegb/my-new-repo
```

### Uninstall

**Warning:** can delete `~/Documents/GitHub` and local clones. Offers to push pending work first.

```bash
cd scripts
./environment_uninstall
```

Interactive; does not remove Homebrew.

### Troubleshooting

| Problem | Try |
|---------|-----|
| Command not found | `setup_symlinks`, then `source ~/.zshrc` |
| Auth errors | `./scripts/util/setup_preflight`; check PAT scope and `GH_TOKEN_<user>` |
| Wrong GitHub account | Remote URL / SSH host alias — see [multi-account guide](docs/guides/github-multiple-accounts-mac-cursor.md) |

More: [docs/runbook.md](docs/runbook.md) · [CHANGELOG.md](CHANGELOG.md) · [agents.md](agents.md) (full script specification)

---

## Repository layout

```
scripts/
├── environment_install, environment_uninstall   # full Mac bootstrap (run directly)
├── git/          # daily commands: git_push, git_create_from_*
├── util/         # runnable setup tools: setup_install, setup_preflight, …
├── lib/          # shared bash modules (source only — never run like a command)
└── maintainer/   # doc_* tools for maintainers
```

**Why `lib/` and `util/` are separate**

| Folder | Role |
|--------|------|
| **`lib/`** | Code other scripts `source` — load `accounts.conf`, PAT helpers, `~/bin` manifest. Files: `common.sh`, `accounts.sh`, `init.sh`, `manifest.sh`. |
| **`util/`** | Programs you (or `environment_install`) **execute** — install Homebrew, configure SSH, create symlinks. |

Same idea as “library vs tools”: one folder is imported, the other is run.

Contributor map: [docs/PRODUCTS.md](docs/PRODUCTS.md).
