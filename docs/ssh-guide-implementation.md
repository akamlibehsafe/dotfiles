# SSH guide → gitscripts implementation map

Maps [github-multiple-accounts-mac-cursor.md](guides/github-multiple-accounts-mac-cursor.md) to scripts (planned / in progress for **0.4.0**).

| Guide § | Topic | Automation |
|---------|--------|------------|
| 1 | SSH key per account | `gitscripts_ssh_setup` (`~/.ssh/gitscripts/`) |
| 2 | Add pubkey to GitHub | Per-account wizard (pbcopy + pause) |
| 3 | `~/.ssh/config` Host aliases | `gitscripts_ssh_setup` |
| 4 | `includeIf` git identity | `gitscripts_ssh_setup` |
| 5 | Remote `git@github-*:user/repo.git` | `gitscripts_migrate_remotes`, create/clone scripts |
| 6 | New repo workflow | `gitscripts_create_from_local` (GitHub create first, manual) |
| 7 | New Mac full setup | `environment_install` + preflight |
| 8–9 | Verify / Cursor | Manual git + guide §8; Cursor uses same git |

**PAT (not in SSH guide):** `gitscripts_configure_pats` — per-account `GH_TOKEN_*`.

**Preflight:** `gitscripts_preflight` — scan → planned actions → confirm.

**Status:** Scripts not yet implemented on branch `feat/0.4.0-gitscripts` (Phase 2+). Current commands remain `gitak_*` until Phase 5 rename.
