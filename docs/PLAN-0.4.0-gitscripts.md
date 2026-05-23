# Plan: gitscripts 0.4.0 (multi-account SSH + `gitscripts_*`)

**Branch:** `feat/0.4.0-gitscripts`  
**Target release:** `0.4.0` (not 1.0.0 — project still maturing)  
**Resume prompt for agent:**

```text
Continue gitscripts 0.4.0 per docs/PLAN-0.4.0-gitscripts.md.
Check Progress below. Next: Execute Phase N only.
```

---

## Progress (update each phase)

| Phase | Status | Notes |
|-------|--------|-------|
| 0 Docs + VERSIONING | Done | CHANGELOG, VERSIONING.md |
| 0-git Tag v0.3.0 | **USER** | See [Phase 0-git](#phase-0-git-your-actions) |
| 1 Guide, ADR 0005, plan docs | Done | This file, guide, implementation map |
| 2 New `gitscripts_*` scripts | Pending | preflight, PAT, SSH, migrate, common lib |
| 3 Update `gitak_*` + environment_install | Pending | |
| 4 Orchestration polish | Pending | |
| 5 Rename `gitak_*` → `gitscripts_*` | Pending | Breaking |
| 6 Release `v0.4.0` | Pending | USER: tag + optional GitHub Release |

---

## Locked decisions

- **Accounts:** `rbonon`, `fortegb`, `akamlibehsafe` + `GH_TOKEN_*` for each
- **Auth:** SSH transport + `includeIf` identity; PAT for API/bulk clone
- **Prefix:** `gitak_*` → `gitscripts_*` (Phase 5)
- **SSH keys:** `~/.ssh/gitscripts/`; test-first / repair mode; preflight before changes
- **New Mac:** primary audience; `environment_install` runs preflight → PAT wizard → … → SSH wizard
- **Rollback:** `git checkout main` + restore Desktop backup; see [Rollback](#rollback)
- **Tests:** plain `git`/`ssh`/`curl` on throwaway repo — not `gitak_*` while developing
- **0.2.0:** CHANGELOG only, no git tag. **0.3.0:** tag at `5796107`. **0.4.0:** tag when released.

---

## Phases (execute one at a time)

### Phase 0-git (YOUR actions)

Align git tag with CHANGELOG 0.3.0. **Run locally** (review before paste):

```bash
cd ~/Documents/GitHub/akamlibehsafe/gitscripts
git log -1 --oneline 5796107   # should exist: environment_uninstall script updated
git tag -l

# Local fix (if v0.1.0 points to 5796107):
git tag -d v0.1.0
git tag -a v0.3.0 5796107 -m "Release 0.3.0"

# If v0.1.0 was pushed to GitHub (check first):
# git push origin :refs/tags/v0.1.0
# git push origin v0.3.0

git describe --tags
```

Do **not** tag 0.4.0 until Phase 6.

### Phase 1 — Documentation

Guide, ADR 0005, this plan, VERSIONING, implementation map. README links.

### Phase 2 — New scripts

- `scripts/lib/gitscripts_common.sh`
- `gitscripts_preflight`, `gitscripts_configure_pats`, `gitscripts_ssh_setup`, `gitscripts_migrate_remotes`

### Phase 3 — Hybrid behavior

Update existing `gitak_*` (keep names until Phase 5). Wire `environment_install`.

### Phase 4 — Orchestration cleanup

`environment_uninstall` symlink list, etc.

### Phase 5 — Rename (breaking)

`git mv` all `gitak_*` → `gitscripts_*`; `gitscripts_setup_symlinks`; remove `~/bin/gitak_*`.

### Phase 6 — Release (USER)

```bash
doc_release 0.4.0 YYYY-MM-DD
git commit -m "chore: release 0.4.0"
git tag v0.4.0
git push && git push origin v0.4.0
```

---

## Rollback

**Before Phase 2 SSH/PAT:**

```bash
BACKUP=~/Desktop/gitscripts-rollback-$(date +%Y%m%d)
mkdir -p "$BACKUP"
cp -a ~/.ssh "$BACKUP/ssh" 2>/dev/null || true
cp ~/.gitconfig "$BACKUP/" 2>/dev/null || true
cp ~/.gitconfig-* "$BACKUP/" 2>/dev/null || true
cp ~/.zshrc "$BACKUP/" 2>/dev/null || true
```

**Discard 0.4.0 code:** `git checkout main && ./scripts/gitak_setup_symlinks`

---

## Manual git test (throwaway repo)

Do **not** test push in `gitscripts` repo. Use `akamlibehsafe/git-push-test` or similar.

See full commands in agent plan or ask: *"Show manual git verification playbook"*.

---

## References

- [VERSIONING.md](VERSIONING.md)
- [guides/github-multiple-accounts-mac-cursor.md](guides/github-multiple-accounts-mac-cursor.md)
- [decisions/0005-hybrid-ssh-and-pat-auth.md](decisions/0005-hybrid-ssh-and-pat-auth.md)
- [ssh-guide-implementation.md](ssh-guide-implementation.md)
