# AI / Contributor Context (gitscripts)

**Release:** `0.4.0` on `main` (tag `v0.4.0`). Start here for agents and contributors.

## Goal

Two products in one repo — see [PRODUCTS.md](PRODUCTS.md):

1. **Dev environment bootstrap** — `environment_install` / `environment_uninstall` at `scripts/` root
2. **Git toolkit** — `git_push`, `git_create_from_remote`, `git_create_from_local` in `scripts/git/`

**Setup helpers:** `scripts/util/` (`setup_*`). **Shared code (source only):** `scripts/lib/` (`common.sh`, `accounts.sh`, `init.sh`, `manifest.sh`).

## Configuration

| File | Purpose |
|------|---------|
| `accounts.conf` | Local only (from `config/accounts.conf.example`) — GitHub usernames, emails, `github_root`, aliases |
| `PAT.md` / `~/.zshrc` | `export GH_TOKEN_<username>` per account line in `accounts.conf` |

Example accounts on maintainer machine: `rbonon`, `fortegb`, `akamlibehsafe`. **Any number of accounts** via `account USER EMAIL` lines.

## Key Workflows

### Install
```bash
cd /path/to/gitscripts/scripts
chmod +x environment_install
./environment_install
```
Homebrew → Git tools → optional bulk clone → Zsh/P10k → optional Cursor → iTerm2 (install + bundled profile) → symlinks → aliases.

**Git tools only:** `./scripts/util/setup_install`

### Uninstall
```bash
./scripts/environment_uninstall
```
Destructive; prompts before removing `~/Documents/GitHub`, SSH identity, PAT exports, etc.

### Daily Git
```bash
git_create_from_remote akamlibehsafe/my-repo
git_push -m "Commit message"
git_create_from_local fortegb/new-repo   # create empty repo on GitHub first
```
Account from `user/repo` or remote URL. Transport: SSH aliases when configured; PAT fallback for HTTPS.

### After pull or merge
```bash
./scripts/util/setup_symlinks
source ~/.zshrc
```

## `~/bin` commands (symlinked)

| On PATH | Role |
|---------|------|
| `git_push`, `git_create_from_remote`, `git_create_from_local` | Daily Git |
| `environment_install`, `environment_uninstall` | Full Mac setup / teardown |
| `setup_symlinks`, `setup_zsh_install` | Symlinks; Zsh stack (when run standalone) |

**Not on `~/bin` by default:** `setup_install`, `setup_preflight`, `setup_configure_pats`, `setup_ssh_setup`, `setup_verify_pat`, `setup_migrate_remotes` — run from `scripts/util/`.

## Repo layout (scripts)

```
scripts/
├── environment_install, environment_uninstall
├── git/           # git_push, git_create_from_*
├── util/          # setup_* (runnable)
├── lib/           # source-only modules
└── maintainer/    # doc_*
```

## Invariants / Rules

- **macOS only** — Homebrew, `~/Documents/GitHub` default layout
- **Never commit** `accounts.conf` or `PAT.md` (`.gitignore`)
- **Idempotent** install scripts
- **Account detection** from repo path / remote owner — not interactive account picker
- **Symlinks, not copies** — ADR 0001; refresh with `setup_symlinks` after moves

## Architecture (read ADRs)

- **0001** Symlinks · **0002** PATs (API) · **0003** `environment_install` · **0004** Bash · **0005** Hybrid SSH + PAT

## Sharp edges

| Problem | Fix |
|---------|-----|
| PAT not set | `export GH_TOKEN_<user>` in `~/.zshrc` or `setup_configure_pats` |
| 401/403 | Regenerate classic PAT with `repo` scope |
| Command not found | `setup_symlinks`; `source ~/.zshrc` |
| Broken symlinks after move | Re-run `setup_symlinks` from repo root |
| Wrong GitHub user on push | Check remote (`git@github-<user>:…`) and `includeIf`; see multi-account guide |
| p10k missing | `source ~/.zshrc` or `p10k configure` |

## Docs maintenance (`scripts/maintainer/`)

- `doc_new_adr`, `doc_update_changelog`, `doc_check`, `doc_release` — see [DOCUMENTATION_WORKFLOW.md](DOCUMENTATION_WORKFLOW.md)

## Post-0.4.0 priorities (optional)

- Clearer errors in edge cases · broader test docs · Linux port (large) · LFS migration helper

## Do not change without design discussion

- Symlink distribution model
- `accounts.conf` + `GH_TOKEN_*` pairing convention
- Non-idempotent install steps
- macOS-only assumptions in orchestration scripts

## Technical notes

**PAT:** `GH_TOKEN_<github_username>` must match `account` lines in `accounts.conf`.

**SSH:** Keys under `~/.ssh/gitscripts/`; Host `github-<user>` in `~/.ssh/config`.

**iTerm2:** Bundled export `config/iterm2/iTerm2 State.itermexport`; `environment_install` installs app and can `open` export for user confirmation.

**Spec for all scripts:** [agents.md](../agents.md) at repo root.
