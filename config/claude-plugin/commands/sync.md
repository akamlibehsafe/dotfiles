---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git commit:*), Bash(git push:*)
description: Stage all changes, commit with a message, and push
---

## Context

- Git status: !`git status --short`
- Recent commits: !`git log --oneline -3`

## Your task

Stage all changes, commit, and push the current repo.

1. If the working tree is clean, tell the user and stop.

2. Check for sensitive files in the staged list (`.env`, credentials, secrets). If any are present, flag them and ask before proceeding.

3. If the user provided a commit message in their `/sync` invocation, use it. Otherwise ask for one. Default if the user says nothing: `Update - <current date YYYY-MM-DD HH:MM:SS>`.

4. Run:
   ```
   git add -A
   ```

5. Commit using a HEREDOC:
   ```bash
   git commit -m "$(cat <<'EOF'
   <message>

   Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
   EOF
   )"
   ```

6. Push:
   ```bash
   git push
   ```

7. Confirm with the short commit hash. If push fails, show the error and suggest `git pull --rebase` then push again.

Never use `--no-verify`. If a pre-commit hook fails, fix the issue and retry.
