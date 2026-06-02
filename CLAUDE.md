# dotfiles — Claude Code context

## What this repo is

Personal macOS development environment bootstrap and daily GitHub workflow toolkit.

## Key files

- `dotfiles_install` — main entry point, run on a fresh Mac
- `dotfiles_uninstall` — tears down what dotfiles_install built, supports `--keep-repos`
- `dotfiles.conf.example` — template for the gitignored `dotfiles.conf`
- `SPEC.md` — full specification, source of truth for all design decisions

## Structure

```
dotfiles_install / dotfiles_uninstall   ← repo root entry points
dotfiles.conf.example                 ← config template (dotfiles.conf is gitignored)
config/                               ← personal config files applied by dotfiles_install
scripts/
├── repo/     ← daily commands copied to ~/bin/ (repo_init, repo_clone, repo_sync)
├── setup/    ← setup & repair tools, run by path only (setup_check, setup_pats, setup_ssh, setup_migrate, update_scripts)
├── apps/     ← pluggable app installers (iterm2, ghostty, warp, cursor, claude, claude-cli)
└── lib/      ← shared bash modules, sourced only (common.sh, accounts.sh, init.sh, manifest.sh)
```

## Naming conventions

- All internal functions and variables use the `dotfiles_` prefix
- Entry points: `dotfiles_install`, `dotfiles_uninstall`
- Daily commands: `repo_init`, `repo_clone`, `repo_sync`
- Setup tools: `setup_check`, `setup_pats`, `setup_ssh`, `setup_migrate`, `update_scripts`
- Config file: `dotfiles.conf` (gitignored); template: `dotfiles.conf.example`

## GitHub accounts

Three accounts are in use — all defined in `dotfiles.conf` (never hardcoded in scripts):
- `fortegb` — construction company IT tools
- `rbonon` — personal projects under real name
- `akamlibehsafe` — anonymous projects

## Auth model

- PATs stored as `GH_TOKEN_<username>` env vars, written to `~/.zshrc` by `dotfiles_install`
- SSH private keys stored as full PEM blocks in `dotfiles.conf` under `ssh_private` directive — paste directly from 1Password, no encoding needed
- SSH keys written to `~/.ssh/dotfiles/id_ed25519_<username>` by setup; public key derived via `ssh-keygen -y`
- SSH host aliases `github-<username>` route the right key per account
- Git `includeIf gitdir:` applies correct identity per folder automatically
- Scripts pick up auth from env vars first, fall back to `dotfiles.conf` values

## Versioning

Currently at **v0.5.0**. Tag applied after full clean cycle passed on 2026-06-02.

## Testing workflow

Full test cycle before tagging a release. Run on the current machine (not a VM).

### 1. Uninstall
```bash
./dotfiles_uninstall --keep-repos
```
- Uninstall skips prompts for things already not present — just confirm what it finds
- Second runs are mostly clean but not perfect (e.g. some sections may re-prompt if partial state remains); this is acceptable — the first run is what matters
- Say **n** to Homebrew removal during iterative testing
- When done, open a **new terminal** and run `source ~/.zshrc`
- Verify no errors (no dangling oh-my-zsh references)

### 2. Verify clean state
```bash
env | grep GH_TOKEN     # should return nothing
ls ~/.ssh/dotfiles      # should not exist
cat ~/.zshrc            # should have no oh-my-zsh or GH_TOKEN lines
```

### 3. Install
```bash
./dotfiles_install
```
- Confirm each phase completes with ✓
- Say **n** to apps already confirmed working in previous runs
- Say **n** to bulk clone during iterative tests (run separately after)

### 4. Verify install
```bash
source ~/.zshrc         # should load cleanly with no errors
ssh -T git@github-rbonon        # should say "successfully authenticated"
ssh -T git@github-akamlibehsafe
ssh -T git@github-fortegb
repo_sync               # test daily command is available
```

### 5. Test repo cloning
Run `dotfiles_install` with bulk clone enabled, or run `repo_clone` manually per account.
Verify repos land under `~/Documents/GitHub/<username>/`.

### 6. Full uninstall including repos
```bash
./dotfiles_uninstall    # this time say y to repo folder removal
```
Verify `~/Documents/GitHub/<username>/` folders are gone.

### Release gate
Tag only after a full clean cycle (uninstall → install → verify → uninstall) passes with no errors.
```bash
git tag v0.5.0 && git push origin v0.5.0
```

## Important rules

- Never hardcode GitHub usernames — always read from `DOTFILES_ACCOUNTS[]`
- Never commit `dotfiles.conf` or `PAT.md` — both are gitignored
- `scripts/repo/*` and `scripts/lib/*` are copied to `~/bin/` by `update_scripts`
- `scripts/setup/*` and `scripts/apps/*` are run by path only
- All user-facing scripts must print usage and exit cleanly on wrong/missing arguments
- `dotfiles_install` must exit 0 only when environment is fully ready
- Renaming the local repo folder breaks the Claude Code session — user handles folder renames manually
