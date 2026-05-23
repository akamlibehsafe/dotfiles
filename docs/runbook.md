# Runbook: Operations Guide for gitscripts

## Installation

### Fresh macOS Installation

**Complete Installation (Recommended):**
```bash
# 1. Download repository as zip and extract, or clone:
cd ~/Documents
git clone <repo-url> gitscripts
cd gitscripts/scripts

# 2. Make executable and run:
chmod +x environment_install
./environment_install
```

**Git Tools Only:**
```bash
cd ~/Documents/gitscripts/scripts
chmod +x setup_install
./setup_install
```

### Verify Installation

```bash
# Check tools are installed:
git --version
gh --version
git lfs version

# Check PAT tokens are set:
setup_verify_pat

# Check symlinks are working:
ls -la ~/bin/gitscripts_*

# Test a script:
git_create_from_remote akamlibehsafe/gitscripts
```

## Uninstallation

### Complete Uninstallation

```bash
cd ~/Documents/gitscripts/scripts
chmod +x environment_uninstall
./environment_uninstall
```

**⚠️ WARNING:** This will delete `~/Documents/GitHub` and all repositories!

**Before uninstalling:**
1. Check for pending changes: `cd ~/Documents/GitHub && find . -name .git -type d | while read dir; do cd "$dir/.." && git status; done`
2. Push all pending changes using `git_push` or manually
3. Backup any important uncommitted work

### Partial Uninstallation

Remove individual components:
- **Symlinks only**: `rm ~/bin/gitscripts_* ~/bin/setup_zsh_install ~/bin/dev_* ~/bin/environment_*`
- **Aliases only**: Edit `~/.zshrc` and remove lines with `alias cdg=`, `alias cda=`, etc.
- **PAT tokens only**: Edit `~/.zshrc` and remove lines with `export GH_TOKEN_*`

## Common Operations

### Create New Repository from Local Folder

```bash
cd /path/to/my/project
git_create_from_local akamlibehsafe/my-new-repo
```

### Clone Existing Repository

```bash
git_create_from_remote fortegb/existing-repo
cd existing-repo
```

### Push Changes

```bash
# From repository directory:
git_push

# With commit message:
git_push -m "Update documentation"

# From different directory:
git_push /path/to/repo -m "Fix bug"
```

### Update Scripts

```bash
cd ~/Documents/GitHub/akamlibehsafe/gitscripts
git pull
# Symlinks automatically point to updated scripts - no re-setup needed!
```

## Troubleshooting

### PAT Token Issues

**Error: "PAT variable not set"**
```bash
# Check if variables are set:
echo $GH_TOKEN_fortegb
echo $GH_TOKEN_akamlibehsafe

# If not set, add to ~/.zshrc:
echo 'export GH_TOKEN_fortegb="your_token"' >> ~/.zshrc
echo 'export GH_TOKEN_akamlibehsafe="your_token"' >> ~/.zshrc
source ~/.zshrc

# Verify:
setup_verify_pat
```

**Error: "401 Unauthorized"**
- Token may be expired → Regenerate at https://github.com/settings/tokens
- Token may not have correct scopes → Ensure `repo` scope is checked
- Token may be incorrect → Verify in GitHub settings

**Error: "403 Forbidden"**
- Token missing `repo` scope → Regenerate with `repo` scope enabled
- Token belongs to wrong account → Verify account matches repository owner

### Git Issues

**Error: "dubious ownership"**
```bash
# Scripts handle /tmp automatically, but for other directories:
git config --global --add safe.directory /path/to/repo
```

**Error: "Repository not found"**
- Verify repository exists: https://github.com/user/repo
- Check PAT has access to repository (especially for private repos)
- Verify username in `user/repo` format is correct

**Error: "Remote URL doesn't match expected format"**
- Check remote URL: `git remote -v`
- Should be `https://github.com/user/repo.git` or `git@github.com:user/repo.git`
- If SSH format, may need to update remote: `git remote set-url origin https://github.com/user/repo.git`

### Symlink Issues

**Scripts not found in PATH**
```bash
# Check if ~/bin is in PATH:
echo $PATH | grep "$HOME/bin"

# If not, add to ~/.zshrc:
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Recreate symlinks:
cd ~/Documents/GitHub/akamlibehsafe/gitscripts
./scripts/util/setup_symlinks
```

**Symlinks broken (repository moved)**
```bash
# Recreate symlinks:
cd /path/to/new/gitscripts/location
./scripts/util/setup_symlinks
# Script will detect and fix broken symlinks
```

**Symlink points to wrong location**
```bash
# Remove and recreate:
rm ~/bin/gitscripts_*
cd ~/Documents/GitHub/akamlibehsafe/gitscripts
./scripts/util/setup_symlinks
```

### Shell Configuration Issues

**Zsh not loading configuration**
```bash
# Check if ~/.zshrc exists:
ls -la ~/.zshrc

# If not, create it:
touch ~/.zshrc

# Reload:
source ~/.zshrc
```

**Aliases not working**
```bash
# Check aliases are defined:
grep -E "alias (cdg|cda|cdf|cds)=" ~/.zshrc

# If missing, add manually:
echo 'alias cdg="cd ~/Documents/GitHub"' >> ~/.zshrc
echo 'alias cda="cd ~/Documents/GitHub/akamlibehsafe"' >> ~/.zshrc
echo 'alias cdf="cd ~/Documents/GitHub/fortegb"' >> ~/.zshrc
echo 'alias cds="cd ~/Documents/GitHub/akamlibehsafe/shutterzilla"' >> ~/.zshrc
source ~/.zshrc
```

## Recovery Procedures

### Recover from Failed Installation

1. **Check what was installed:**
   ```bash
   which git gh git-lfs
   ls -la ~/bin/
   ```

2. **Re-run installation script:**
   - Scripts are idempotent - safe to re-run
   - Already-installed components will be skipped

3. **Manual cleanup if needed:**
   ```bash
   # Remove partial installations:
   rm -rf ~/.oh-my-zsh  # If Zsh install failed
   brew uninstall git git-lfs gh  # If Homebrew installs are broken
   ```

### Recover from Broken Symlinks

```bash
# Remove all symlinks:
rm ~/bin/gitscripts_* ~/bin/setup_zsh_install ~/bin/dev_* ~/bin/environment_* 2>/dev/null

# Recreate:
cd ~/Documents/GitHub/akamlibehsafe/gitscripts
./scripts/util/setup_symlinks
```

### Recover from Deleted Repository

If `~/Documents/GitHub/akamlibehsafe/gitscripts` was deleted:

```bash
# Clone repository:
cd ~/Documents/GitHub/akamlibehsafe
git_create_from_remote akamlibehsafe/gitscripts
# Or manually:
git clone https://github.com/akamlibehsafe/gitscripts.git

# Recreate symlinks:
cd gitscripts
./scripts/util/setup_symlinks
```

### Recover PAT Tokens

If PAT tokens are lost/expired:

1. **Generate new tokens:**
   - Go to https://github.com/settings/tokens
   - Generate new Classic tokens with `repo` scope
   - Set expiration to "No expiration"

2. **Update shell configuration:**
   ```bash
   # Edit ~/.zshrc:
   nano ~/.zshrc
   # Update export GH_TOKEN_* lines with new tokens
   
   # Reload:
   source ~/.zshrc
   ```

3. **Verify:**
   ```bash
   setup_verify_pat
   ```

## Known Gotchas

1. **Scripts must be run from repository or via symlinks**
   - Don't copy scripts to `~/bin/` directly
   - Use symlinks to keep scripts version-controlled

2. **PAT tokens in shell config are plaintext**
   - Store securely, use file permissions (600)
   - Never commit to git (PAT.md is in .gitignore)

3. **Git LFS requires per-repository initialization**
   - Run `git lfs install` in each repository that needs LFS
   - Commit `.gitattributes` after tracking file types

4. **Powerlevel10k configuration is interactive**
   - Run `p10k configure` to customize prompt
   - Configuration persists in `~/.p10k.zsh`

5. **iTerm2 profile import needs confirmation in the app**
   - `environment_install` installs iTerm2 and can `open` the bundled `config/iterm2/iTerm2 State.itermexport`; approve the import dialog in iTerm2
   - Script provides instructions but doesn't automate import

6. **Repository cloning during environment_install is optional**
   - Requires PAT tokens to be loaded first
   - Will skip if PATs not available
   - Can clone manually later

7. **environment_uninstall is destructive**
   - Always backs up pending git changes before deletion
   - But still: **⚠️ Review what will be deleted before confirming!**

## Health Checks

**Quick health check:**
```bash
# All scripts should return version info:
git --version && gh --version && git lfs version

# PAT tokens should be set:
[ -n "$GH_TOKEN_fortegb" ] && [ -n "$GH_TOKEN_akamlibehsafe" ] && echo "✓ PATs set" || echo "✗ PATs missing"

# Symlinks should exist:
ls ~/bin/gitscripts_* > /dev/null 2>&1 && echo "✓ Symlinks exist" || echo "✗ Symlinks missing"

# Scripts should be executable:
[ -x ~/bin/git_push ] && echo "✓ Scripts executable" || echo "✗ Scripts not executable"
```

**Full verification:**
```bash
setup_verify_pat
```

## Maintenance

### Regular Tasks

1. **Update scripts monthly:**
   ```bash
   cd ~/Documents/GitHub/akamlibehsafe/gitscripts
   git pull
   ```

2. **Rotate PAT tokens annually:**
   - Generate new tokens
   - Update in `~/.zshrc`
   - Revoke old tokens in GitHub settings

3. **Verify symlinks after moving repository:**
   ```bash
   cd /new/location/gitscripts
   ./scripts/util/setup_symlinks
   ```

4. **Check for script updates:**
   ```bash
   cd ~/Documents/GitHub/akamlibehsafe/gitscripts
   git fetch
   git log HEAD..origin/main --oneline  # See what's new
   ```

### Backup Strategy

**Critical files to backup:**
- `~/.zshrc` (contains PAT tokens and aliases)
- `~/.p10k.zsh` (Powerlevel10k configuration)
- `~/Documents/GitHub/` (all repositories - use git for backup!)

**Backup script:**
```bash
# Backup shell configuration:
cp ~/.zshrc ~/.zshrc.backup
cp ~/.p10k.zsh ~/.p10k.zsh.backup 2>/dev/null || true

# Note: Repositories should be backed up via git push, not file copy
```
