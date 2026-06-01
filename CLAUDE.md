# dotfiles — Claude Code context

## What this repo is

Personal macOS development environment bootstrap and daily GitHub workflow toolkit.

## Key files

- `dotfiles_setup` — main entry point, run on a fresh Mac
- `dotfiles_uninstall` — tears down what dotfiles_setup built, supports `--keep-repos`
- `dotfiles.conf.example` — template for the gitignored `dotfiles.conf`
- `SPEC.md` — full specification, source of truth for all design decisions

## Structure

```
dotfiles_setup / dotfiles_uninstall   ← repo root entry points
dotfiles.conf.example                 ← config template (dotfiles.conf is gitignored)
config/                               ← personal config files applied by dotfiles_setup
scripts/
├── repo/     ← daily commands symlinked to ~/bin/ (repo_init, repo_clone, repo_sync)
├── setup/    ← setup & repair tools, run by path only (setup_check, setup_pats, setup_ssh, setup_migrate, setup_symlinks)
├── apps/     ← pluggable app installers (iterm2, ghostty, warp, cursor, claude, claude-cli)
└── lib/      ← shared bash modules, sourced only (common.sh, accounts.sh, init.sh, manifest.sh)
```

## Naming conventions

- All internal functions and variables use the `dotfiles_` prefix
- Entry points: `dotfiles_setup`, `dotfiles_uninstall`
- Daily commands: `repo_init`, `repo_clone`, `repo_sync`
- Setup tools: `setup_check`, `setup_pats`, `setup_ssh`, `setup_migrate`, `setup_symlinks`
- Config file: `dotfiles.conf` (gitignored); template: `dotfiles.conf.example`

## GitHub accounts

Three accounts are in use — all defined in `dotfiles.conf` (never hardcoded in scripts):
- `fortegb` — construction company IT tools
- `rbonon` — personal projects under real name
- `akamlibehsafe` — anonymous projects

## Auth model

- PATs stored as `GH_TOKEN_<username>` env vars, written to `~/.zshrc` by `dotfiles_setup`
- SSH host aliases `github-<username>` route the right key per account
- Git `includeIf gitdir:` applies correct identity per folder automatically
- Scripts pick up auth from env vars first, fall back to `dotfiles.conf` values

## Versioning

Currently at **v0.5.0 (unreleased, in progress)**. Tag is applied only when fully tested on a fresh machine. Do not tag prematurely.

## Important rules

- Never hardcode GitHub usernames — always read from `DOTFILES_ACCOUNTS[]`
- Never commit `dotfiles.conf` or `PAT.md` — both are gitignored
- `scripts/repo/*` are the only scripts symlinked to `~/bin/`
- `scripts/setup/*` and `scripts/apps/*` are run by path only
- All user-facing scripts must print usage and exit cleanly on wrong/missing arguments
- `dotfiles_setup` must exit 0 only when environment is fully ready
- Renaming the local repo folder breaks the Claude Code session — user handles folder renames manually
