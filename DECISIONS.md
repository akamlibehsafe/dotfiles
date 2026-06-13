# DECISIONS — architectural decision history

This file is **append-only**. New sessions add entries at the bottom. Existing entries are never modified or removed. Each entry captures what was decided, why, and what rules or implications follow.

---

## 2026-06-09 — v0.6.0 auth refactor

### Replace SSH with HTTPS + PAT + macOS Keychain

**Decision:** Remove all SSH key management from the tooling. All GitHub authentication uses HTTPS remote URLs with PATs stored in the macOS Keychain.

**Rationale:** The corporate MacBook Air (M4 2025) runs GlobalProtect VPN at all times when off-site, which blocks outbound SSH on both port 22 and 443. SSH is structurally unavailable on that machine. Rather than maintaining two auth models (SSH on two machines, HTTPS on one), HTTPS+PAT was adopted on all three machines for consistency and simplicity.

**Security note:** PATs stored in the macOS Keychain via `security add-internet-password` are equivalent in security posture to SSH keys for personal use. SSH keys remain saved in 1Password and registered on GitHub as a fallback if needed in the future.

**Implications:**
- `dotfiles.conf` no longer contains `ssh_private` blocks — just accounts and PATs
- Remote URLs are `https://<user>@github.com/<user>/<repo>.git` — username in URL disambiguates multi-account Keychain lookups without needing `credential.useHttpPath`
- `git push`, `git pull`, `git clone` etc. require no flags or tokens — Keychain is transparent
- Works identically on all three machines including behind VPN

---

### Keychain storage uses `security` CLI directly

**Decision:** All Keychain operations (store, check, delete) use the `security` CLI directly, not `git credential approve/fill`.

**Rationale:** Using `git credential approve` to store and `security` to delete would target different entry formats, making uninstall unreliable. Direct use of `security` throughout ensures consistency.

---

### Identity baked into each repo's `.git/config`

**Decision:** `repo_clone` and `repo_init` write `user.name` and `user.email` directly into each repo's `.git/config` as a local override immediately after clone/init.

**Rationale:** `includeIf gitdir:` in `~/.gitconfig` only works when repos live under the expected folder structure (`~/Documents/GitHub/<user>/`). A repo cloned to `~/Desktop` or any other location would fall back to the global default identity, potentially causing misattributed commits. Baking identity into `.git/config` makes commits correct regardless of where the repo lives on disk.

**Implications:**
- Plain git commands (`git commit`, `git push`, etc.) are safe to use inside any repo cloned or initialised with the dotfiles scripts
- `setup_identity --repair` rescans all repos under `github_root` and rewrites the `[user]` block — run after changing name or email in `dotfiles.conf`

---

### Rule: always use `repo_clone` and `repo_init`

**Decision:** Raw `git clone` and `git init` are not to be used for repos belonging to the managed accounts.

**Rationale:** `repo_clone` and `repo_init` are the single point that guarantees three things are correct together: remote URL format, Keychain credential lookup, and identity in `.git/config`. Bypassing them breaks at least one of these guarantees silently.

**Implications:**
- Repos created on GitHub's web UI should be immediately cloned with `repo_clone`
- Renaming a repo on GitHub: delete local folder, `repo_clone <user/newname>`
- Repos outside `~/Documents/GitHub/<user>/` are not managed — the user accepts responsibility for identity correctness in that case

---

### Three machines, one auth model

**Machines:**
- Mac Mini M4 (home) — personal, full control, no corporate software
- MacBook Pro 2019 i9 (personal) — personal, full control, no corporate software
- MacBook Air M4 2025 (corporate) — GlobalProtect VPN always on, SSH blocked off-site

**Decision:** All three machines use identical HTTPS+PAT+Keychain setup. No machine-specific branches in the install flow.

---

### `setup_ssh` renamed to `setup_identity`

**Decision:** The script formerly called `setup_ssh` is renamed to `setup_identity`.

**Rationale:** After the SSH removal, the script no longer manages SSH keys or config. It now handles git `includeIf` identity configuration and Keychain credential storage. The old name was misleading.

---

### `setup_migrate` direction reversed

**Decision:** `setup_migrate` now migrates SSH remote URLs → HTTPS (was previously HTTPS → SSH).

**Rationale:** With HTTPS as the standard, any repos with legacy SSH remotes from older installs need to be migrated to HTTPS. The old direction is no longer relevant.

---

### Prompt color changed

**Decision:** `dotfiles_ui_prompt` color changed from `\033[0;34m` (dim blue, renders as dark lilac on dark terminals) to `\033[1;37m` (bold white).

**Rationale:** Dark lilac on black background is hard to read. Bold white is unambiguous on any dark terminal background and clearly distinct from green (success) and yellow (info).

---

### `CLAUDE.md` renamed to `AGENTS.md`

**Decision:** The AI context file is renamed from `CLAUDE.md` to `AGENTS.md`.

**Rationale:** `AGENTS.md` is a more neutral, cross-tool name recognized by Claude Code, OpenAI-compatible agents, and other AI coding tools. `CLAUDE.md` was Claude-specific in name only.

---

### `DECISIONS.md` introduced as append-only decision log

**Decision:** A `DECISIONS.md` file is maintained at the repo root as an append-only log of architectural decisions and their rationale.

**Rationale:** Working across three machines and two AI tools (Claude Code, Cursor), context from previous sessions would otherwise be lost. `AGENTS.md` covers the *what* (how the codebase works); `DECISIONS.md` covers the *why* (how it got there and what alternatives were considered).

**Rules:**
- Any AI agent working on this repo should read `DECISIONS.md` before making significant changes
- New decisions are appended at the bottom under a dated entry
- Existing entries are never modified or removed

**Note:** An earlier version of this entry mentioned `.gitattributes` exclusion from release archives. That decision was later reversed — `DECISIONS.md` and `AGENTS.md` ship with the repo (see entry below).

---

### `.gitattributes` export-ignore reverted

**Decision:** `DECISIONS.md` and `AGENTS.md` are NOT excluded from release archives. They ship with the repo normally.

**Rationale:** These are personal projects. There is no reason to hide AI context files from release archives. Keeping them in simplifies the setup and ensures anyone cloning the repo has full context.

---

### AI context templates system

**Decision:** Add `templates/AGENTS.md` and `templates/DECISIONS.md` to the dotfiles repo. `repo_clone` and `repo_init` automatically copy them into every new repo they create or clone. `dotfiles_install` copies the `templates/` folder to `~/.config/dotfiles/templates/` so the scripts can find them when running from `~/bin/`.

**Rationale:** Every project should start with an AI context system in place. Doing it manually per repo is friction that would be skipped in practice. Automating it ensures every repo has `AGENTS.md` and `DECISIONS.md` from day one, consistently, without thinking about it.

**Implications:**
- `repo_clone` and `repo_init` only copy templates if the files don't already exist — safe to re-run
- Template resolution: primary path is `~/.config/dotfiles/templates/` (reliable from `~/bin/`); fallback is git-based repo root detection (for running directly from the dotfiles repo)
- `dotfiles_uninstall` removes `~/.config/dotfiles/templates/` as part of the XDG config cleanup

---

### Terminology: "daily commands" → "day-to-day GitHub scripts"

---

## 2026-06-11 — v0.6.2 bug-fix and cleanup pass

### `ssh_private` in conf: warn-and-continue, not hard-exit

**Decision:** When `dotfiles_load_accounts` encounters an `ssh_private` block in `dotfiles.conf`, it prints the migration warning and returns 0 (with empty accounts), not 1.

**Rationale:** `dotfiles_uninstall` was designed to run gracefully even with no conf (no-conf path returns 0). A conf *with* `ssh_private` was harder to deal with than a missing conf — the `return 1` propagated through `init.sh`'s `dotfiles_load_accounts || exit 1` and aborted uninstall before any cleanup ran. The migration scenario (user has old conf, wants to wipe and reinstall clean) is exactly when uninstall must succeed.

**Implications:**
- Scripts sourcing `init.sh` with a `ssh_private` conf will continue with empty accounts and skip account-specific steps — same behaviour as a missing conf
- The printed warning tells the user what to fix before re-running `dotfiles_install`

---

### Uninstall app prompts use an explicit helper, not `&&`/`||` chains

**Decision:** All app-uninstall prompts in `dotfiles_uninstall` use an `uninstall_app()` helper with explicit `if/then/else`, not the inline `[ -d app ] && { confirm && brew_uninstall; } || info` pattern.

**Rationale:** The `&&`/`||` chain has a precedence bug: if the app is installed but the user declines the prompt, `confirm` returns non-zero, the entire compound group fails, and the `||` branch fires — printing "not installed, skipping" instead of "kept". Explicit if/else has no ambiguity.

**Rule:** Never use `&&`/`||` chains for confirm-then-act logic in these scripts. Always use `if confirm "..."; then ... else ... fi`.

---

### `dotfiles_update` CASKS list is a manually maintained parallel

**Decision:** `dotfiles_update` maintains its own `CASKS` array rather than importing a shared list from `manifest.sh`.

**Rationale:** Cask upgrade names (e.g. `visual-studio-code`) differ from the install-loop app keys (e.g. `vscode`), and the update script needs raw Homebrew cask identifiers. Sharing a single array would require translating keys at call time. The parallel list is acceptable given the low churn — a comment in `dotfiles_update` flags it as a parallel that must be kept in sync with the install loop.

**Rule:** When adding a new cask-based app to `dotfiles_install`, also add its Homebrew cask name to `dotfiles_update`'s `CASKS` array.

**Decision:** The three scripts (`repo_init`, `repo_clone`, `repo_sync`) are referred to as "day-to-day GitHub scripts" throughout documentation, not "daily commands".

**Rationale:** "Daily commands" implied they must be used every day. "Day-to-day GitHub scripts" better describes their nature — tools for routine GitHub workflow, used as needed.

---

## 2026-06-12 — `repo_init` credential bug fix

### Remote URLs must not embed the username

**Decision:** `dotfiles_remote_https_url()` produces `https://github.com/<user>/<repo>.git` — no username in the URL.

**Rationale:** The original format `https://<user>@github.com/<user>/<repo>.git` was introduced in v0.6.0 with the intent of disambiguating multi-account Keychain lookups. In practice, embedding the username in the URL prevents the macOS Keychain credential helper from matching the stored entry on some git versions, causing git to fall back to an interactive password prompt. The credential helper resolves the correct PAT without the username hint when the repo's `.git/config` already has `user.name` baked in.

**Implications:**
- Existing repos cloned before this fix have `https://<user>@github.com/...` remotes. They will continue to work where the credential helper happens to match, but can be migrated with `git remote set-url origin https://github.com/<user>/<repo>.git`.
- `setup_migrate` may be updated in a future version to rewrite old-format remotes.

---

### `repo_init` must not override the credential helper at push time

**Decision:** The push in `repo_init` uses plain `git push`, never `git -c credential.helper= push`.

**Rationale:** `git -c credential.helper=` clears all credential helpers for that invocation, forcing git to prompt interactively. This was the direct cause of the password prompt reported in v0.6.5. There is no valid reason for `repo_init` to bypass the configured credential helper — the PAT in the Keychain is precisely what should be used here.

**Rule:** Never pass `-c credential.helper=` to any git call in these scripts. If auth is failing, debug the Keychain entry via `setup_check`, don't suppress the helper.
