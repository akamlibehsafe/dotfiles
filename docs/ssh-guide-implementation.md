# SSH guide → gitscripts implementation map

Maps [github-multiple-accounts-mac-cursor.md](guides/github-multiple-accounts-mac-cursor.md) to scripts (**0.4.0** on `main`).

| Guide § | Topic | Automation |
|---------|--------|------------|
| 1 | SSH key per account | `setup_ssh_setup` (`~/.ssh/gitscripts/`) |
| 2 | Add pubkey to GitHub | Per-account wizard (pbcopy + pause) |
| 3 | `~/.ssh/config` Host aliases | `setup_ssh_setup` |
| 4 | `includeIf` git identity | `setup_ssh_setup` |
| 5 | Remote `git@github-*:user/repo.git` | `setup_migrate_remotes`, create/clone scripts |
| 6 | New repo workflow | `git_create_from_local` (GitHub create first, manual) |
| 7 | New Mac full setup | `environment_install` + preflight |
| 8–9 | Verify / Cursor | Manual git + guide §8; Cursor uses same git |

**PAT (not in SSH guide):** `setup_configure_pats` — per-account `GH_TOKEN_*`.

**Preflight:** `setup_preflight` — scan → planned actions → confirm.

**Status (0.4.0):** Daily commands `git_*` on `~/bin`; setup `setup_*` under `scripts/util/`; config via `accounts.conf`.
