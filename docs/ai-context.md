# AI / Contributor Context (gitscripts)

## Goal
Personal Git automation toolkit for managing multiple GitHub accounts on macOS.

- Automate common Git/GitHub operations (create repo, clone, push) across two accounts
- Provide one-command development environment setup on macOS
- Support dual GitHub account workflow (fortegb, akamlibehsafe) via PAT authentication
- Keep scripts version-controlled while providing system-wide access via symlinks

## Key Workflows

### Install
**Complete installation:**
```bash
cd /path/to/gitscripts/scripts
chmod +x environment_install
./environment_install
```
Installs: Homebrew → Git tools → Zsh/Powerlevel10k → Cursor (optional) → Symlinks → Aliases

**Git tools only:**
```bash
./scripts/gitscripts_install
```

### Uninstall
```bash
./scripts/environment_uninstall
```
⚠️ Destructive: Removes everything installed by `environment_install` including `~/Documents/GitHub`.

### Create from Local/Remote
```bash
# Create new repo from current directory:
gitscripts_create_from_local akamlibehsafe/my-repo

# Clone existing repo:
gitscripts_create_from_remote fortegb/existing-repo
```
Scripts auto-detect account from `user/repo` format and use appropriate PAT.

### Push Flow
```bash
# From repo directory:
gitscripts_push -m "Commit message"

# Auto-detects account from remote URL, stages all changes, commits, pushes
```

## Repo Layout

### `scripts/` - Main Scripts
- **`environment_install`**: Orchestrates complete macOS dev environment setup
- **`environment_uninstall`**: Removes everything installed by environment_install
- **`gitscripts_install`**: Installs Git, Git LFS, GitHub CLI, and dependencies
- **`gitscripts_create_from_local`**: Creates GitHub repo from local folder
- **`gitscripts_create_from_remote`**: Clones existing GitHub repository
- **`gitscripts_push`**: Commits and pushes changes (auto-detects account)
- **`gitscripts_verify_PAT`**: Validates PAT tokens are set and working
- **`gitscripts_setup_symlinks`**: Creates symlinks in `~/bin/` for system-wide access
- **`zsh_install`**: Installs and configures Zsh, Oh My Zsh, Powerlevel10k

### `config/` - Configuration Files
- **`config/iterm2/`**: iTerm2 configuration export (manual import required)

### `docs/` - Documentation
- **`docs/decisions/`**: Architecture Decision Records (ADRs)
- **`docs/runbook.md`**: Operational procedures and troubleshooting
- **`docs/ai-context.md`**: This file - AI/contributor briefing

## Invariants / Rules

### Compatibility
- **macOS only**: Scripts use Homebrew, macOS-specific paths (`~/Documents/GitHub`), and assume Unix shell
- **Shell assumptions**: Works with both bash and zsh; detects shell automatically for config file placement

### Safety Rules
- **No destructive operations without prompts**: `environment_uninstall` prompts before deletion
- **PAT tokens never committed**: `PAT.md` is in `.gitignore`
- **Idempotent installations**: All install scripts can be re-run safely
- **Account auto-detection**: Never prompts for account - detects from repo name/URL

### Architecture Decisions
- **Symlinks, not copies**: Scripts stay in repo, symlinked to `~/bin/` (see ADR 0001)
- **PAT-based auth**: Environment variables, not GitHub CLI auth (see ADR 0002)
- **Bash scripting**: Native macOS, no external dependencies (see ADR 0004)
- **Orchestration script**: Single entry point for installation (see ADR 0003)

## Known Sharp Edges

### Common Failure Modes + Fixes

1. **"PAT variable not set"**
   - **Cause**: Tokens not exported in shell config
   - **Fix**: Add `export GH_TOKEN_*="..."` to `~/.zshrc`, then `source ~/.zshrc`

2. **"403 Forbidden" / "401 Unauthorized"**
   - **Cause**: Expired/invalid token or missing `repo` scope
   - **Fix**: Regenerate PAT with `repo` scope at https://github.com/settings/tokens

3. **Scripts not found in PATH**
   - **Cause**: `~/bin/` not in PATH or symlinks not created
   - **Fix**: Run `./scripts/gitscripts_setup_symlinks` to create symlinks and add to PATH

4. **Symlinks broken after moving repository**
   - **Cause**: Symlinks point to old repository location
   - **Fix**: Re-run `gitscripts_setup_symlinks` from new location (auto-detects and fixes)

5. **"dubious ownership" Git error**
   - **Cause**: Git safety check for directories outside user home
   - **Fix**: Scripts handle `/tmp` automatically; for others: `git config --global --add safe.directory /path/to/repo`

6. **Partial installation failure**
   - **Cause**: Network issue or user interruption
   - **Fix**: Re-run installation script (idempotent - skips already-installed components)

7. **Powerlevel10k prompt not showing**
   - **Cause**: Zsh config not loaded or `p10k configure` not run
   - **Fix**: `source ~/.zshrc` or run `p10k configure`

## Documentation Maintenance

**Automated Documentation Tools:**
- `doc_new_adr <title>` - Create new ADR template
- `doc_update_changelog <category> <description>` - Add changelog entry
- `doc_check` - Check documentation status (runs in pre-commit hook)
- `doc_release <version>` - Move unreleased entries to version

**See `docs/DOCUMENTATION_WORKFLOW.md` for complete guide.**

## Current Priorities

### What's Next
- Improve error messages with actionable steps
- Add more comprehensive testing/documentation
- Consider Linux support (currently macOS-only)
- Add Git LFS migration helper for existing repos

### What Not to Change
- **Don't switch from symlinks to copies**: Breaks auto-update mechanism
- **Don't add more GitHub accounts without refactoring**: Current design assumes exactly 2 accounts
- **Don't remove PAT environment variable approach**: Central to account auto-detection
- **Don't make scripts non-idempotent**: Re-runnability is key feature
- **Don't remove macOS focus**: Would require significant refactoring

## Technical Notes

### PAT Token Storage
- Stored as environment variables: `GH_TOKEN_fortegb`, `GH_TOKEN_akamlibehsafe`
- Added to `~/.zshrc` (or `~/.bashrc`/`~/.bash_profile` for bash)
- Can be provided via `PAT.md` file during installation (auto-loaded)

### Account Detection Logic
1. Parse `user/repo` argument → extract username
2. If no argument, parse remote URL → extract username
3. Map username to PAT: `fortegb` → `GH_TOKEN_fortegb`, `akamlibehsafe` → `GH_TOKEN_akamlibehsafe`

### Symlink System
- Scripts in repo: `~/Documents/GitHub/akamlibehsafe/gitscripts/scripts/`
- Symlinks in: `~/bin/gitscripts_*`
- Updated via: `git pull` in repo (symlinks automatically point to new versions)

### Installation Order (environment_install)
1. PAT configuration (first - needed for repo cloning)
2. Homebrew installation/update
3. Git root directory creation (`~/Documents/GitHub`)
4. Git tools installation (Git, Git LFS, GitHub CLI)
5. Optional: Clone all repos from both accounts
6. Zsh environment setup (Oh My Zsh, Powerlevel10k)
7. Optional: Cursor Desktop installation
8. Symlink setup
9. Alias addition (cdg, cda, cdf, cds)
10. Optional: Powerlevel10k configuration
11. iTerm2 configuration import instructions
