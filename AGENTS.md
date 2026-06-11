# dotfiles — AI agent context

## What this repo is

Personal macOS development environment bootstrap and daily GitHub workflow toolkit.

## Key files

- `dotfiles_install` — main entry point, run on a fresh Mac
- `dotfiles_uninstall` — tears down what dotfiles_install built, supports `--keep-repos`
- `dotfiles.conf.example` — template for the gitignored `dotfiles.conf`
- `SPEC.md` — full specification, source of truth for all design decisions
- `DECISIONS.md` — history of architectural decisions and their rationale
- `templates/AGENTS.md` — generic AGENTS.md template copied into new repos by `repo_init`
- `templates/DECISIONS.md` — generic DECISIONS.md template copied into new repos by `repo_init`

## Structure

```
dotfiles_install / dotfiles_uninstall   ← repo root entry points
dotfiles.conf.example                   ← config template (dotfiles.conf is gitignored)
config/                                 ← personal config files applied by dotfiles_install
scripts/
├── repo/     ← day-to-day GitHub scripts copied to ~/bin/ (repo_init, repo_clone, repo_sync)
├── setup/    ← setup & repair tools, run by path only (setup_check, setup_pats, setup_identity, setup_migrate, update_scripts)
├── apps/     ← pluggable app installers (iterm2, ghostty, warp, cursor, claude, claude-cli, android-studio, openspec)
└── lib/      ← shared bash modules, sourced only (common.sh, accounts.sh, init.sh, manifest.sh)
```

## Naming conventions

- All internal functions and variables use the `dotfiles_` prefix
- Entry points: `dotfiles_install`, `dotfiles_uninstall`
- Day-to-day GitHub scripts: `repo_init`, `repo_clone`, `repo_sync`
- Setup tools: `setup_check`, `setup_pats`, `setup_identity`, `setup_migrate`, `update_scripts`
- Config file: `dotfiles.conf` (gitignored); template: `dotfiles.conf.example`

## GitHub accounts

Three accounts are in use — all defined in `dotfiles.conf` (never hardcoded in scripts):
- `fortegb` — construction company IT tools
- `rbonon` — personal projects under real name
- `akamlibehsafe` — anonymous projects

## Auth model

- PATs stored as `GH_TOKEN_<username>` env vars, written to `~/.zshrc` by `dotfiles_install`
- PATs also stored in macOS Keychain via `security` CLI, scoped per GitHub username
- `git config --global credential.helper osxkeychain` — git picks up the right PAT automatically for any HTTPS remote
- Remote URLs use `https://<username>@github.com/<username>/<repo>.git` — the username in the URL disambiguates multi-account Keychain lookups; no `credential.useHttpPath` needed
- Git `includeIf gitdir:` applies correct commit identity (name + email) per account folder automatically
- `repo_clone` and `repo_init` bake identity into each repo's `.git/config` as a local override
- Scripts pick up auth from env vars first, fall back to `dotfiles.conf` values
- No SSH keys — HTTPS+PAT works on all machines including corporate ones behind GlobalProtect VPN

## Versioning

Currently at **v0.6.0**.

## Testing workflow

Full test cycle before tagging a release. Run on the current machine (not a VM).

### 1. Uninstall
```bash
./dotfiles_uninstall --keep-repos
```
- Uninstall skips prompts for things already not present — just confirm what it finds
- Say **n** to Homebrew removal during iterative testing
- When done, open a **new terminal** and run `source ~/.zshrc`
- Verify no errors (no dangling oh-my-zsh references)

### 2. Verify clean state
```bash
env | grep GH_TOKEN     # should return nothing
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
source ~/.zshrc                   # should load cleanly with no errors
scripts/setup/setup_check         # PATs valid, Keychain credentials present, identity configured
repo_sync                         # test day-to-day GitHub scripts are available
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
git tag v0.6.0 && git push origin v0.6.0
```

## Important rules

- Never hardcode GitHub usernames — always read from `DOTFILES_ACCOUNTS[]`
- Never commit `dotfiles.conf` or `PAT.md` — both are gitignored
- `scripts/repo/*` and `scripts/lib/*` are copied to `~/bin/` by `update_scripts`
- `scripts/setup/*` and `scripts/apps/*` are run by path only
- All user-facing scripts must print usage and exit cleanly on wrong/missing arguments
- `dotfiles_install` must exit 0 only when environment is fully ready
- Always use `repo_clone` to clone repos — never raw `git clone`
- Always use `repo_init` to create repos — never initialise manually
- Renaming the local repo folder breaks the Claude Code session — user handles folder renames manually

## Working with this repo as an AI agent

- Read `DECISIONS.md` before starting work on any significant change — it explains the *why* behind design choices
- When a session produces a new design decision, architectural change, or agreed rule, append it to `DECISIONS.md` under a new dated entry
- Never overwrite or remove existing entries in `DECISIONS.md` — it is append-only
- `SPEC.md` is the source of truth for current design; `DECISIONS.md` is the history of how it got there
