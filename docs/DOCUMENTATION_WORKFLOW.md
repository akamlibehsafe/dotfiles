# Documentation Workflow Guide

This guide explains when and how to update documentation as you develop.

## Quick Reference

### When to Update What

| Change Type | CHANGELOG | ADR | Runbook | AI Context |
|------------|-----------|-----|---------|------------|
| New feature | ✅ | Maybe | Maybe | Maybe |
| Bug fix | ✅ | No | Maybe | No |
| Breaking change | ✅ | ✅ | ✅ | ✅ |
| New script | ✅ | Maybe | ✅ | ✅ |
| Architecture decision | ✅ | ✅ | No | ✅ |
| Common issue found | No | No | ✅ | ✅ |
| Workflow change | ✅ | Maybe | ✅ | ✅ |

## Workflow

### 1. During Development

**When adding a new feature:**
```bash
# Add to changelog immediately (don't wait!)
doc_update_changelog Added "New feature description"
```

**When fixing a bug:**
```bash
doc_update_changelog Fixed "Bug fix description"
```

**When making an architectural decision:**
```bash
# Create new ADR
doc_new_adr "use-docker-for-deployment"

# Edit the ADR file, then add to changelog
doc_update_changelog Changed "Switched to Docker for deployment (see ADR 0005)"
```

### 2. Before Committing

**Check documentation status:**
```bash
doc_check
```

This will:
- ✅ Verify CHANGELOG has unreleased entries
- ✅ Check for proposed ADRs
- ✅ Remind about recent changes

**The pre-commit hook runs this automatically** but won't block your commit.

### 3. Before Release

**Move unreleased entries to a version:**
```bash
doc_release 0.4.0
# Or with specific date:
doc_release 0.4.0 2026-01-20
```

This:
- Moves all "Unreleased" entries to the new version
- Adds date
- Leaves empty "Unreleased" section for next work

## Helper Scripts

### `doc_new_adr <decision-title>`
Creates a new ADR template with the next number.

```bash
doc_new_adr "use-docker-for-deployment"
# Creates: docs/decisions/0005-use-docker-for-deployment.md
```

**When to use:**
- Making an architectural decision
- Choosing between alternatives
- Explaining "why we did X instead of Y"

**Edit the file to fill in:**
- Context (problem being solved)
- Decision (what you chose)
- Alternatives considered
- Consequences (what gets easier/harder)

### `doc_update_changelog <category> <description>`
Adds an entry to CHANGELOG.md's "Unreleased" section.

```bash
doc_update_changelog Added "Support for Linux"
doc_update_changelog Fixed "PAT token expiration handling"
doc_update_changelog Changed "Default branch to main"
doc_update_changelog Breaking "Removed deprecated API"
```

**Categories:**
- `Added` - New features
- `Changed` - Behavior changes
- `Fixed` - Bug fixes
- `Breaking` - Breaking changes

**When to use:**
- Immediately when making a change
- Don't wait until release!
- Better to have many small entries than forget things

### `doc_check [--strict]`
Checks documentation status and reminds about updates.

```bash
doc_check          # Non-blocking check
doc_check --strict # Fails if issues found (for CI)
```

**Checks:**
- CHANGELOG has unreleased entries
- Proposed ADRs exist
- Key files exist (ai-context.md, runbook.md)
- Recent commits without changelog entries

**Runs automatically** via git pre-commit hook (non-blocking).

### `doc_release <version> [date]`
Moves unreleased changelog entries to a new version.

```bash
doc_release 0.4.0
doc_release 0.4.0 2026-01-20
```

**Use when:**
- Creating a new release
- Tagging a version
- Before pushing to main

**After running:**
- Review the new release section
- Commit the changelog
- Tag the release: `git tag -a v0.4.0 -m "Release 0.4.0"`

## Manual Updates

### When to Update AI Context (`docs/ai-context.md`)

Update when:
- Adding/removing scripts
- Changing key workflows
- Discovering new "sharp edges"
- Updating priorities
- Major architectural changes

**Keep it concise** - this is a briefing document, not full docs.

### When to Update Runbook (`docs/runbook.md`)

Update when:
- Adding new troubleshooting steps
- Discovering common issues
- Changing installation/uninstallation procedures
- Adding new recovery procedures
- Finding new "gotchas"

**Focus on operations** - what operators need to know.

### When to Create an ADR (`docs/decisions/`)

Create an ADR when:
- Making an architectural choice
- Choosing between technical alternatives
- Explaining why you rejected a popular solution
- Documenting a significant design decision

**Don't create ADRs for:**
- Obvious choices
- Trivial decisions
- Temporary solutions

## Best Practices

### 1. Update CHANGELOG Immediately
Don't wait! Update as you work:
```bash
# After adding feature:
git add scripts/new_feature
doc_update_changelog Added "New feature X"
git add CHANGELOG.md
git commit -m "feat: add new feature X"
```

### 2. Keep ADRs Focused
One decision per ADR. Update status:
- `Proposed` → `Accepted` (when decision is final)
- `Accepted` → `Deprecated` (when replaced)

### 3. Run doc_check Before Pushing
```bash
doc_check
git push
```

### 4. Update Runbook When Users Report Issues
If someone hits a problem, add it to the runbook!

### 5. Review AI Context Quarterly
Keep it current - outdated context hurts more than no context.

## Git Hooks

### Pre-commit Hook (Automatic)
Runs `doc_check` before every commit (non-blocking reminder).

**To install manually:**
```bash
chmod +x .git/hooks/pre-commit
```

**To disable:**
```bash
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled
```

## Integration with Cursor/AI

The `docs/ai-context.md` file is specifically designed to give AI assistants quick context. Keep it updated so Cursor understands:
- Current architecture decisions
- Known issues
- What not to change
- Key workflows

AI will automatically reference this file when helping with code changes.

## Examples

### Example 1: Adding a New Script

```bash
# 1. Create the script
vim scripts/new_script

# 2. Add to changelog
doc_update_changelog Added "New script for X feature"

# 3. Update AI context (manually edit docs/ai-context.md)
# Add to "Repo Layout" section

# 4. Update runbook (manually edit docs/runbook.md)
# Add usage examples

# 5. Check everything
doc_check

# 6. Commit
git add scripts/new_script CHANGELOG.md docs/
git commit -m "feat: add new script"
```

### Example 2: Making an Architectural Decision

```bash
# 1. Create ADR
doc_new_adr "use-symlinks-over-copies"
vim docs/decisions/0005-use-symlinks-over-copies.md
# Fill in: Context, Decision, Alternatives, Consequences

# 2. Update status to Accepted
# (edit the ADR file)

# 3. Add to changelog
doc_update_changelog Changed "Use symlinks instead of copying scripts (see ADR 0005)"

# 4. Update AI context
# Reference ADR in relevant section

# 5. Commit
git add docs/decisions/ CHANGELOG.md docs/ai-context.md
git commit -m "docs: add ADR 0005 for symlink decision"
```

### Example 3: Before Release

```bash
# 1. Final check
doc_check --strict

# 2. Create release
doc_release 0.4.0

# 3. Review and commit
git add CHANGELOG.md
git commit -m "chore: release 0.4.0"

# 4. Tag
git tag -a v0.4.0 -m "Release 0.4.0"

# 5. Push
git push origin main
git push origin v0.4.0
```

## Troubleshooting

**"doc_check: command not found"**
- Make scripts executable: `chmod +x scripts/maintainer/doc_*`
- Add scripts to PATH or use `./scripts/maintainer/doc_check`

**"CHANGELOG.md missing Unreleased section"**
- Manually add: `## Unreleased\n` to top of CHANGELOG.md
- Or restore from git: `git checkout CHANGELOG.md`

**"Too many unreleased entries"**
- Run `doc_release` more frequently
- Or manually organize entries in CHANGELOG.md

## Summary

1. **Update CHANGELOG immediately** - don't wait
2. **Create ADRs for architectural decisions** - explain why
3. **Update runbook when issues arise** - help operators
4. **Keep AI context current** - help Cursor/AI assist you
5. **Run doc_check before pushing** - catch missing updates
6. **Use doc_release for versions** - organize releases

Remember: **Documentation is part of development, not an afterthought!**
