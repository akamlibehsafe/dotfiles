# 0001 - Use Symlinks for Script Distribution

## Status
Accepted

## Context
Scripts need to be accessible system-wide while remaining version-controlled in the repository. We need a way to update scripts via `git pull` without requiring users to manually copy files or reinstall.

## Decision
Use symlinks in `~/bin/` pointing to scripts in the repository folder. Scripts remain in the repository (version-controlled), and symlinks provide system-wide access. The `setup_symlinks` script automates symlink creation and updates.

## Alternatives considered
- **Copy scripts to ~/bin/**: Pros: Simple, scripts directly in PATH. Cons: Users must manually update after `git pull`, no automatic updates, risk of version drift.
- **Add repository to PATH**: Pros: Always uses latest version. Cons: Requires full path in commands or adding repo directory to PATH (less clean), harder to manage multiple script locations.
- **Install scripts to /usr/local/bin**: Pros: System-wide access. Cons: Requires sudo, harder to update, breaks per-user customization.

## Consequences
**Positive:**
- Scripts automatically update when repository is pulled
- Single source of truth (repository)
- No manual copying required
- Easy to verify which version is being used (symlink target)
- Can easily switch between repository locations

**Negative:**
- Requires `~/bin/` to exist and be in PATH
- Symlinks break if repository is moved (though script handles this)
- Slightly more complex setup than direct copying

**Risks:**
- Users moving repository without updating symlinks (mitigated by `setup_symlinks` detecting and fixing this)
- PATH configuration issues (mitigated by script automatically adding `~/bin/` to PATH)

## Links
- Implementation: `scripts/util/setup_symlinks`
- Used by: `environment_install`, `setup_install`
- Documentation: `README.md` section on "Set Up Symlinks to ~/bin/"
