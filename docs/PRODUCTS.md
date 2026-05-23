# Repository layout (contributors)

User-facing docs: [README.md](../README.md), [config/accounts.conf.example](../config/accounts.conf.example).

User config (`accounts.conf`): lists **all** GitHub accounts equally — not tied to one “owner” of this repo.

## Entry points

| Script | Role |
|--------|------|
| `environment_install` / `environment_uninstall` | Full Mac bootstrap / teardown (`scripts/` root) |
| `git_push`, `git_create_from_remote`, `git_create_from_local` | Daily Git workflow (`scripts/git/`, on `~/bin`) |

## `lib/` vs `util/`

| Folder | Purpose |
|--------|---------|
| `lib/` | **Source only** — `common.sh`, `accounts.sh`, `init.sh`, `manifest.sh` (not executed as commands) |
| `util/` | **Runnable** setup tools invoked by you or `environment_install` |

## `scripts/util/` — setup (not daily commands)

Invoked by `environment_install` or by path. Not symlinked to `~/bin` by default except `setup_symlinks` and `setup_zsh_install`.

| Script | Role |
|--------|------|
| `setup_install` | Homebrew + git/gh/LFS/jq; clone this repo |
| `setup_preflight` | Read-only environment scan |
| `setup_configure_pats` | PAT wizard |
| `setup_ssh_setup` | SSH + git identity |
| `setup_verify_pat` | Token validation (overlaps preflight) |
| `setup_migrate_remotes` | HTTPS → SSH aliases |
| `setup_symlinks` | `~/bin` links + PATH |
| `setup_zsh_install` | Oh My Zsh + Powerlevel10k |

## Tree

```
scripts/
├── environment_install, environment_uninstall
├── git/              # git_push, git_create_from_*
├── util/
├── lib/
└── maintainer/       # doc_* (not on ~/bin by default)
```

After renames or moves: `setup_symlinks` refreshes `~/bin` and removes deprecated symlink names (see `lib/manifest.sh`).
