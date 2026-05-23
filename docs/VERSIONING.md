# Versioning (gitscripts)

## Rules

| Rule | Detail |
|------|--------|
| **Released versions** | Must have both a dated section in [CHANGELOG.md](../CHANGELOG.md) and a git tag `vX.Y.Z` on the same commit. |
| **0.2.0** | Documented in CHANGELOG only (development milestone). **No git tag.** |
| **Pre-1.0** | Breaking changes may ship in `0.x` (e.g. `0.4.0`: `gitak_*`/`gitscripts_*` → `git_*` + `setup_*`). |
| **1.0.0** | Reserved until [PLAN-0.4.0-gitscripts.md](PLAN-0.4.0-gitscripts.md) readiness criteria are met. |

## Current state (verify locally)

```bash
git tag -l 'v*'
git describe --tags --always
head -20 CHANGELOG.md
```

Expected after Phase 0 (your action): tag **`v0.3.0`** at commit `5796107` (replaces misplaced `v0.1.0`).

## Cutting a release

```bash
doc_check --strict
doc_release 0.4.0 YYYY-MM-DD
git add CHANGELOG.md
git commit -m "chore: release 0.4.0"
git tag v0.4.0
git push origin <branch>
git push origin v0.4.0
# Optional: GitHub → Releases → draft from tag v0.4.0
```

## In development

- Add entries under `## Unreleased` via `doc_update_changelog`.
- Track execution in [PLAN-0.4.0-gitscripts.md](PLAN-0.4.0-gitscripts.md).
