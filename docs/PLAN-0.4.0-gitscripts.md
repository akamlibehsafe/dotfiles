# Plan: gitscripts 0.4.0 (multi-account SSH + layout)

**Status:** **Released** — merged to `main` (PR #1), tag **`v0.4.0`** (2026-05-23).

**Branch history:** developed on `feat/0.4.0-gitscripts`; do not use that branch for new work — use `main`.

---

## Progress (final)

| Phase | Status | Notes |
|-------|--------|-------|
| 0 Docs + VERSIONING | Done | CHANGELOG, VERSIONING.md |
| 0-git Tags + remote | Done | `v0.3.0`, `v0.4.0` on origin |
| 1 Guide, ADR 0005, plan docs | Done | Multi-account guide, implementation map |
| 2 Setup scripts | Done | `setup_preflight`, `setup_configure_pats`, `setup_ssh_setup`, `setup_migrate_remotes`; `lib/common.sh` |
| 2-test | Done | PAT/SSH verified |
| 3 Hybrid in git_* + environment_install | Done | SSH push/clone; PAT fallback |
| 3-test | Done | `git_push` on throwaway repo |
| 4 Orchestration | Done | `lib/manifest.sh`, uninstall parity |
| 5 Layout + renames | Done | `git/`, `util/`, `lib/`; `git_*` daily; `setup_*` helpers; `accounts.conf` |
| 5-test | Done | `setup_symlinks`; legacy `gitak_*` / `gitscripts_*` removed from `~/bin` |
| 6 Release | Done | PR #1 merged; `v0.4.0` tagged |

---

## Locked decisions (0.4.0)

- **Accounts:** `accounts.conf` (local) — any number of `account USER EMAIL` lines; maintainer uses `rbonon`, `fortegb`, `akamlibehsafe`
- **Auth:** SSH transport + `includeIf`; PAT (`GH_TOKEN_<user>`) for API / HTTPS fallback
- **Command names:** Daily **`git_*`** on `~/bin`; setup **`setup_*`** in `scripts/util/`; orchestration **`environment_*`**
- **SSH keys:** `~/.ssh/gitscripts/`; `setup_preflight` before invasive changes
- **New Mac:** `environment_install` — PAT → tools → clone → Zsh → Cursor (opt) → iTerm2 → symlinks
- **0.3.0:** tag `5796107` · **0.4.0:** tag on merge commit

---

## Delivered layout

```
scripts/
├── environment_install, environment_uninstall
├── git/              git_push, git_create_from_remote, git_create_from_local
├── util/             setup_install, setup_preflight, setup_configure_pats, …
├── lib/              common.sh, accounts.sh, init.sh, manifest.sh
└── maintainer/       doc_*
```

Config: `config/accounts.conf.example` → local `accounts.conf`; `config/iterm2/iTerm2 State.itermexport`.

User docs: [README.md](../README.md). AI brief: [ai-context.md](ai-context.md). Spec: [agents.md](../agents.md).

---

## After 0.4.0

New work: add entries under `## Unreleased` in CHANGELOG.md; optional GitHub Release from tag `v0.4.0`.

**Rollback (config only):** backup `~/.ssh`, `~/.gitconfig*`, `~/.zshrc` before SSH experiments.

**Rollback (code):** stay on `main`; run `setup_symlinks` after checkout.

---

## References

- [VERSIONING.md](VERSIONING.md)
- [guides/github-multiple-accounts-mac-cursor.md](guides/github-multiple-accounts-mac-cursor.md)
- [decisions/0005-hybrid-ssh-and-pat-auth.md](decisions/0005-hybrid-ssh-and-pat-auth.md)
- [ssh-guide-implementation.md](ssh-guide-implementation.md)
