# GitHub Multiple Accounts Setup on Mac + Cursor

> **Canonical procedural guide (v2).** Human setup reference for multi-account Cursor/Git.  
> Automation: see [PLAN-0.4.0-gitscripts.md](../PLAN-0.4.0-gitscripts.md) and [ssh-guide-implementation.md](../ssh-guide-implementation.md).  
> **Note:** gitscripts installers may use `~/.ssh/gitscripts/` for script-managed keys (same Host aliases; paths may differ from §1 below).

This guide configures one Mac to work cleanly with three GitHub accounts in Cursor:

| GitHub user | Email |
|---|---|
| `rbonon` | `ricardobonon@gmail.com` |
| `fortegb` | `contato@fortegb.com` |
| `akamlibehsafe` | `akamlibeh.safe@gmail.com` |

Target local folder structure:

```text
~/Documents/GitHub/akamlibehsafe/REPO
~/Documents/GitHub/fortegb/REPO
~/Documents/GitHub/rbonon/REPO
```

Goal:

```text
Open repo in Cursor → commit author is correct → push uses correct GitHub account
```

---

## 1. Generate one SSH key per GitHub account

First check existing keys:

```bash
ls -la ~/.ssh
```

Look for:

```text
id_ed25519_rbonon
id_ed25519_fortegb
id_ed25519_akamlibehsafe
```

Do **not** overwrite a key that already exists and is already working.

Generate missing keys:

```bash
ssh-keygen -t ed25519 -C "ricardobonon@gmail.com" -f ~/.ssh/id_ed25519_rbonon
ssh-keygen -t ed25519 -C "contato@fortegb.com" -f ~/.ssh/id_ed25519_fortegb
ssh-keygen -t ed25519 -C "akamlibeh.safe@gmail.com" -f ~/.ssh/id_ed25519_akamlibehsafe
```

When asked for a passphrase, you can press **Enter** to leave it empty, or create one. Empty is simpler for local development.

Add keys to macOS keychain:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_rbonon
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_fortegb
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_akamlibehsafe
```

---

## 2. Add each public key to the correct GitHub account

Each SSH key must be added to the matching GitHub account.

GitHub path:

```text
GitHub > Settings > SSH and GPG keys > New SSH key
```

### Add key for `rbonon`

```bash
pbcopy < ~/.ssh/id_ed25519_rbonon.pub
```

Log into GitHub as `rbonon` and paste the key.

### Add key for `fortegb`

```bash
pbcopy < ~/.ssh/id_ed25519_fortegb.pub
```

Log into GitHub as `fortegb` and paste the key.

### Add key for `akamlibehsafe`

```bash
pbcopy < ~/.ssh/id_ed25519_akamlibehsafe.pub
```

Log into GitHub as `akamlibehsafe` and paste the key.

Important: the same SSH key cannot be used in more than one GitHub account.

---

## 3. Configure SSH aliases

Edit the SSH config:

```bash
nano ~/.ssh/config
```

Use this configuration:

```ssh
Host github-rbonon
  HostName ssh.github.com
  User git
  Port 443
  IdentityFile ~/.ssh/id_ed25519_rbonon
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes

Host github-fortegb
  HostName ssh.github.com
  User git
  Port 443
  IdentityFile ~/.ssh/id_ed25519_fortegb
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes

Host github-akamlibehsafe
  HostName ssh.github.com
  User git
  Port 443
  IdentityFile ~/.ssh/id_ed25519_akamlibehsafe
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes
```

This uses `ssh.github.com` with port `443`, which is useful when normal SSH port `22` is blocked.

Save:

```text
Ctrl + O
Enter
Ctrl + X
```

Test all three identities:

```bash
ssh -T git@github-rbonon
ssh -T git@github-fortegb
ssh -T git@github-akamlibehsafe
```

Expected results:

```text
Hi rbonon! You've successfully authenticated, but GitHub does not provide shell access.
Hi fortegb! You've successfully authenticated, but GitHub does not provide shell access.
Hi akamlibehsafe! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## 4. Configure Git commit identity automatically by folder

This makes Git and Cursor use the correct commit author based on the repo path.

Edit global Git config:

```bash
nano ~/.gitconfig
```

Use this:

```gitconfig
[init]
  defaultBranch = main

[includeIf "gitdir:~/Documents/GitHub/rbonon/"]
  path = ~/.gitconfig-rbonon

[includeIf "gitdir:~/Documents/GitHub/fortegb/"]
  path = ~/.gitconfig-fortegb

[includeIf "gitdir:~/Documents/GitHub/akamlibehsafe/"]
  path = ~/.gitconfig-akamlibehsafe
```

Now create the three included config files.

### `rbonon`

```bash
nano ~/.gitconfig-rbonon
```

Content:

```gitconfig
[user]
  name = rbonon
  email = ricardobonon@gmail.com
```

### `fortegb`

```bash
nano ~/.gitconfig-fortegb
```

Content:

```gitconfig
[user]
  name = fortegb
  email = contato@fortegb.com
```

### `akamlibehsafe`

```bash
nano ~/.gitconfig-akamlibehsafe
```

Content:

```gitconfig
[user]
  name = akamlibehsafe
  email = akamlibeh.safe@gmail.com
```

---

## 5. Set the correct remote for every repo

Pattern:

```text
git@github-ACCOUNT_ALIAS:GITHUB_USER/REPO.git
```

Run the commands below.

### `akamlibehsafe` repos

```bash
cd ~/Documents/GitHub/akamlibehsafe/ai-toolkit
git remote set-url origin git@github-akamlibehsafe:akamlibehsafe/ai-toolkit.git
```

```bash
cd ~/Documents/GitHub/akamlibehsafe/gabinetecamera
git remote set-url origin git@github-akamlibehsafe:akamlibehsafe/gabinetecamera.git
```

```bash
cd ~/Documents/GitHub/akamlibehsafe/gitscripts
git remote set-url origin git@github-akamlibehsafe:akamlibehsafe/gitscripts.git
```

```bash
cd ~/Documents/GitHub/akamlibehsafe/shutterzilla
git remote set-url origin git@github-akamlibehsafe:akamlibehsafe/shutterzilla.git
```

### `fortegb` repos

```bash
cd ~/Documents/GitHub/fortegb/Resources_IA
git remote set-url origin git@github-fortegb:fortegb/Resources_IA.git
```

```bash
cd ~/Documents/GitHub/fortegb/Sandbox
git remote set-url origin git@github-fortegb:fortegb/Sandbox.git
```

### `rbonon` repos

```bash
cd ~/Documents/GitHub/rbonon/ir2016
git remote set-url origin git@github-rbonon:rbonon/ir2016.git
```

```bash
cd ~/Documents/GitHub/rbonon/medban
git remote set-url origin git@github-rbonon:rbonon/medban.git
```

```bash
cd ~/Documents/GitHub/rbonon/vitara_ai
git remote set-url origin git@github-rbonon:rbonon/vitara_ai.git
```

### If any repo says `No such remote 'origin'`

Use `git remote add origin ...` instead.

Example:

```bash
git remote add origin git@github-rbonon:rbonon/medban.git
```

---

## 6. Create a new repository locally and push it to GitHub

Example: create a new repo called `newrepo` under the `rbonon` GitHub account.

### 6.1 Create the repository on GitHub first

In GitHub, while logged in as `rbonon`, create a new repository:

```text
Repository owner: rbonon
Repository name: newrepo
Visibility: public or private, as desired
Initialize with README: no
```

Do not initialize with README if you are going to create the first commit locally.

The target GitHub repo URL will be:

```text
git@github-rbonon:rbonon/newrepo.git
```

### 6.2 Create the local folder

```bash
mkdir -p ~/Documents/GitHub/rbonon/newrepo
cd ~/Documents/GitHub/rbonon/newrepo
```

### 6.3 Initialize Git and create the first commit

```bash
echo "# newrepo" > README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
```

Because this repo is under:

```text
~/Documents/GitHub/rbonon/
```

Git should automatically use:

```text
user.name = rbonon
user.email = ricardobonon@gmail.com
```

Verify:

```bash
git config user.name
git config user.email
```

Expected:

```text
rbonon
ricardobonon@gmail.com
```

### 6.4 Add the correct remote and push

```bash
git remote add origin git@github-rbonon:rbonon/newrepo.git
git push -u origin main
```

### 6.5 Open in Cursor

```bash
cursor .
```

Or open Cursor manually and select:

```text
~/Documents/GitHub/rbonon/newrepo
```

Cursor should now commit as `rbonon` and push through the `github-rbonon` SSH alias.

---

## 7. Start from scratch on a new Mac

Use this when setting up a new Mac with all three GitHub users and all repos.

### 7.1 Install or confirm Git

Install Apple command line tools if needed:

```bash
xcode-select --install
```

Check Git:

```bash
git --version
```

Install Cursor normally from the Cursor website.

### 7.2 Create the local folder structure

```bash
mkdir -p ~/Documents/GitHub/rbonon
mkdir -p ~/Documents/GitHub/fortegb
mkdir -p ~/Documents/GitHub/akamlibehsafe
```

### 7.3 Generate new SSH keys on the new Mac

Recommended approach: generate fresh SSH keys on the new Mac and add the new public keys to each GitHub account.

```bash
ssh-keygen -t ed25519 -C "ricardobonon@gmail.com" -f ~/.ssh/id_ed25519_rbonon
ssh-keygen -t ed25519 -C "contato@fortegb.com" -f ~/.ssh/id_ed25519_fortegb
ssh-keygen -t ed25519 -C "akamlibeh.safe@gmail.com" -f ~/.ssh/id_ed25519_akamlibehsafe
```

Add keys to macOS keychain:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_rbonon
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_fortegb
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_akamlibehsafe
```

### 7.4 Add public keys to GitHub

For `rbonon`:

```bash
pbcopy < ~/.ssh/id_ed25519_rbonon.pub
```

Add to GitHub while logged in as `rbonon`.

For `fortegb`:

```bash
pbcopy < ~/.ssh/id_ed25519_fortegb.pub
```

Add to GitHub while logged in as `fortegb`.

For `akamlibehsafe`:

```bash
pbcopy < ~/.ssh/id_ed25519_akamlibehsafe.pub
```

Add to GitHub while logged in as `akamlibehsafe`.

GitHub path:

```text
GitHub > Settings > SSH and GPG keys > New SSH key
```

### 7.5 Create SSH config on the new Mac

```bash
nano ~/.ssh/config
```

Content:

```ssh
Host github-rbonon
  HostName ssh.github.com
  User git
  Port 443
  IdentityFile ~/.ssh/id_ed25519_rbonon
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes

Host github-fortegb
  HostName ssh.github.com
  User git
  Port 443
  IdentityFile ~/.ssh/id_ed25519_fortegb
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes

Host github-akamlibehsafe
  HostName ssh.github.com
  User git
  Port 443
  IdentityFile ~/.ssh/id_ed25519_akamlibehsafe
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes
```

Save:

```text
Ctrl + O
Enter
Ctrl + X
```

Test all three:

```bash
ssh -T git@github-rbonon
ssh -T git@github-fortegb
ssh -T git@github-akamlibehsafe
```

Expected:

```text
Hi rbonon! You've successfully authenticated, but GitHub does not provide shell access.
Hi fortegb! You've successfully authenticated, but GitHub does not provide shell access.
Hi akamlibehsafe! You've successfully authenticated, but GitHub does not provide shell access.
```

### 7.6 Create Git identity config on the new Mac

Edit global Git config:

```bash
nano ~/.gitconfig
```

Content:

```gitconfig
[init]
  defaultBranch = main

[includeIf "gitdir:~/Documents/GitHub/rbonon/"]
  path = ~/.gitconfig-rbonon

[includeIf "gitdir:~/Documents/GitHub/fortegb/"]
  path = ~/.gitconfig-fortegb

[includeIf "gitdir:~/Documents/GitHub/akamlibehsafe/"]
  path = ~/.gitconfig-akamlibehsafe
```

Create the three identity files:

```bash
cat > ~/.gitconfig-rbonon <<'EOF2'
[user]
  name = rbonon
  email = ricardobonon@gmail.com
EOF2

cat > ~/.gitconfig-fortegb <<'EOF2'
[user]
  name = fortegb
  email = contato@fortegb.com
EOF2

cat > ~/.gitconfig-akamlibehsafe <<'EOF2'
[user]
  name = akamlibehsafe
  email = akamlibeh.safe@gmail.com
EOF2
```

### 7.7 Clone all repos using the correct SSH aliases

#### `akamlibehsafe`

```bash
cd ~/Documents/GitHub/akamlibehsafe
git clone git@github-akamlibehsafe:akamlibehsafe/ai-toolkit.git
git clone git@github-akamlibehsafe:akamlibehsafe/gabinetecamera.git
git clone git@github-akamlibehsafe:akamlibehsafe/gitscripts.git
git clone git@github-akamlibehsafe:akamlibehsafe/shutterzilla.git
```

#### `fortegb`

```bash
cd ~/Documents/GitHub/fortegb
git clone git@github-fortegb:fortegb/Resources_IA.git
git clone git@github-fortegb:fortegb/Sandbox.git
```

#### `rbonon`

```bash
cd ~/Documents/GitHub/rbonon
git clone git@github-rbonon:rbonon/ir2016.git
git clone git@github-rbonon:rbonon/medban.git
git clone git@github-rbonon:rbonon/vitara_ai.git
```

### 7.8 Verify cloned repos

Example for `rbonon/medban`:

```bash
cd ~/Documents/GitHub/rbonon/medban
git config user.name
git config user.email
git remote -v
```

Expected:

```text
rbonon
ricardobonon@gmail.com
origin  git@github-rbonon:rbonon/medban.git (fetch)
origin  git@github-rbonon:rbonon/medban.git (push)
```

Example for `fortegb/Sandbox`:

```bash
cd ~/Documents/GitHub/fortegb/Sandbox
git config user.name
git config user.email
git remote -v
```

Expected:

```text
fortegb
contato@fortegb.com
origin  git@github-fortegb:fortegb/Sandbox.git (fetch)
origin  git@github-fortegb:fortegb/Sandbox.git (push)
```

Example for `akamlibehsafe/shutterzilla`:

```bash
cd ~/Documents/GitHub/akamlibehsafe/shutterzilla
git config user.name
git config user.email
git remote -v
```

Expected:

```text
akamlibehsafe
akamlibeh.safe@gmail.com
origin  git@github-akamlibehsafe:akamlibehsafe/shutterzilla.git (fetch)
origin  git@github-akamlibehsafe:akamlibehsafe/shutterzilla.git (push)
```

### 7.9 Open repos in Cursor

Open Cursor and choose any repo folder, for example:

```text
~/Documents/GitHub/rbonon/medban
~/Documents/GitHub/fortegb/Sandbox
~/Documents/GitHub/akamlibehsafe/shutterzilla
```

Cursor should commit and push using the correct identity automatically.

---

## 8. Verify each repo

Inside any repo, run:

```bash
git config user.name
git config user.email
git remote -v
```

Expected examples:

### `rbonon` repo

```text
rbonon
ricardobonon@gmail.com
origin  git@github-rbonon:rbonon/medban.git (fetch)
origin  git@github-rbonon:rbonon/medban.git (push)
```

### `fortegb` repo

```text
fortegb
contato@fortegb.com
origin  git@github-fortegb:fortegb/Sandbox.git (fetch)
origin  git@github-fortegb:fortegb/Sandbox.git (push)
```

### `akamlibehsafe` repo

```text
akamlibehsafe
akamlibeh.safe@gmail.com
origin  git@github-akamlibehsafe:akamlibehsafe/shutterzilla.git (fetch)
origin  git@github-akamlibehsafe:akamlibehsafe/shutterzilla.git (push)
```

---

## 9. Cursor behavior

Cursor does not need to be visually logged into the same GitHub account for Git push to work.

For commit and push, Cursor uses:

```text
Git local/global config → commit author
Repo remote URL → target GitHub repo
SSH config/key → GitHub authentication
```

So the source of truth is:

```bash
git config user.name
git config user.email
git remote -v
ssh -T git@github-rbonon
ssh -T git@github-fortegb
ssh -T git@github-akamlibehsafe
```

Once these are correct, Cursor's **Commit** and **Push** buttons should behave correctly based on the repo folder.

---

## 10. Rule for future repos

For new `rbonon` repos:

```bash
git remote add origin git@github-rbonon:rbonon/NEW_REPO.git
```

For new `fortegb` repos:

```bash
git remote add origin git@github-fortegb:fortegb/NEW_REPO.git
```

For new `akamlibehsafe` repos:

```bash
git remote add origin git@github-akamlibehsafe:akamlibehsafe/NEW_REPO.git
```

Avoid HTTPS remotes for these repos:

```text
https://github.com/...
```

Prefer SSH alias remotes:

```text
git@github-rbonon:...
git@github-fortegb:...
git@github-akamlibehsafe:...
```
