# 0005 - Hybrid SSH and PAT Authentication

## Status
Accepted

## Context
gitscripts must support three GitHub accounts (`rbonon`, `fortegb`, `akamlibehsafe`) with correct commit identity and push auth in Cursor and CLI. PAT-only HTTPS (ADR 0002) does not set per-folder `user.name`/`user.email` and Cursor often fails HTTPS push without shell PATs. Full SSH-only cannot replace GitHub API use (bulk clone, token verify).

## Decision
Use a **hybrid** model:

| Layer | Mechanism |
|-------|-----------|
| Commit identity | `includeIf` + `~/.gitconfig-<user>` by path under `~/Documents/GitHub/<user>/` |
| Git transport (clone/push/pull) | SSH Host aliases (`git@github-<user>:...`) and keys under `~/.ssh/gitscripts/` |
| API / bulk listing | `GH_TOKEN_<user>` environment variables |

Orchestration: `setup_preflight` → planned actions → user confirm → `setup_configure_pats` / `setup_ssh_setup`. Primary install path: new Mac (`environment_install`).

Script prefix: **`gitscripts_*`** (renamed from `gitak_*` in 0.4.0). `git_create_from_local` requires repo created on GitHub first (no API create).

## Alternatives considered
- **PAT-only (0002)**: Fails Cursor commit/push UX; kept only for API.
- **SSH-only**: Cannot drive GitHub API bulk clone or PAT verify without extra tooling.
- **gh auth per account**: Poor automation fit; not chosen.

## Consequences
**Positive:** Cursor commit/push follows repo path + remote + SSH; clear multi-account model; preflight before changes.

**Negative:** More setup steps (PAT + SSH per account); breaking rename; migration from HTTPS remotes.

**Risks:** User must add SSH keys on correct GitHub account; botched tag history fixed separately (see VERSIONING.md).

## Links
- Guide: [docs/guides/github-multiple-accounts-mac-cursor.md](../guides/github-multiple-accounts-mac-cursor.md)
- Plan: [docs/PLAN-0.4.0-gitscripts.md](../PLAN-0.4.0-gitscripts.md)
- Supersedes: [0002-dual-github-accounts-via-pats.md](0002-dual-github-accounts-via-pats.md)
