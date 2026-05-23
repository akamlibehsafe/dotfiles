# GitScripts Specification

## Overview

This repository ships **two products**:

| Product | Main entry points | Location |
|---------|-------------------|----------|
| **1. Dev environment bootstrap** | `environment_install`, `environment_uninstall` | `scripts/` root |
| **2. Multi-account Git toolkit** | `git_push`, `git_create_from_remote`, `git_create_from_local` | `scripts/git/` |

Shared: `scripts/util/` (symlinks, Zsh), `scripts/lib/`, `scripts/maintainer/` (`doc_*`). See `docs/PRODUCTS.md`.

Git accounts: `rbonon`, `fortegb`, `akamlibehsafe`. PATs: `GH_TOKEN_<user>`. Hybrid SSH + PAT auth (ADR 0005).

**Product 1** orchestrates Product 2 plus Homebrew, shell, editor, bulk clone, and `~/bin` symlinks.

## Installation and Setup

### Repository Structure
- Scripts are kept in the repository folder (version-controlled)
- Symlinks are created in `~/bin/` pointing to the repository scripts
- This allows scripts to be updated via `git pull` while remaining accessible system-wide

### Setup Process

**On a Fresh Mac (Recommended - Complete Installation):**

**Option A: Use `environment_install` (Complete Setup)**

1. **Download the repository as a zip file** from GitHub and extract it to any folder

2. **Make the script executable:**
   ```bash
   cd /path/to/extracted/folder/scripts
   chmod +x environment_install
   ```

3. **Run the environment installation script:**
   ```bash
   ./environment_install
   ```
   
   This comprehensive script will:
   - Handle PAT configuration (asks at the very beginning)
   - Install Homebrew
   - Set up Git root directory (`~/Documents/GitHub`)
   - Install Git, Git LFS, GitHub CLI, and dependencies
   - Optionally clone repositories for each account in `accounts.conf`
   - Install and configure Zsh, Oh My Zsh, Powerlevel10k
   - Optionally install Cursor Desktop
   - Set up symlinks for all scripts
   - Add useful aliases (cdg, cda, cdf, cds)
   - Configure Powerlevel10k (optional, at the end)
   - Install iTerm2 (Homebrew) and offer import of bundled profile (`config/iterm2/`)
   
   **Note:** See `README.md` for instructions on using `environment_install`.

**Option B: Manual Setup (Individual Scripts)**

1. **Clone the repository:**
   ```bash
   cd ~/Documents  # or your preferred location
   git clone <repository-url> gitscripts
   cd gitscripts
   ```

2. **Run the installation script:**
   ```bash
   ./scripts/util/setup_install
   ```
   
   This will:
   - Install Git, Git LFS, GitHub CLI, and dependencies
   - Provide PAT configuration instructions
   - **Automatically offer to set up symlinks** at the end (if run from repository directory)
   
   **Accept the symlink setup prompt** to complete installation in one step.

3. **If you skipped symlink setup, run manually:**
   ```bash
   ./scripts/util/setup_symlinks
   ```
   
   This script will:
   - Create `~/bin/` directory if it doesn't exist
   - Create symlinks for all scripts in `~/bin/`
   - Add `~/bin/` to PATH (if not already present)
   - Verify all symlinks are working

4. **Ensure `~/bin/` is in your PATH:**
   - The setup script attempts to add this automatically
   - If needed, manually add to `~/.bashrc`, `~/.bash_profile`, or `~/.zshrc`:
     ```bash
     export PATH="$HOME/bin:$PATH"
     ```

5. **Reload your shell configuration:**
   ```bash
   source ~/.bashrc  # or ~/.zshrc
   ```

### Updating Scripts
After pulling updates from the repository:
```bash
cd /path/to/gitscripts
git pull
```
Symlinks automatically point to the updated scripts - no re-setup needed!

### Script Location
- **Repository location:** `/path/to/gitscripts/` (where scripts are stored)
- **Symlink location:** `~/bin/` (where scripts are accessed from)
- **Usage:** Scripts are called by name (e.g., `git_create_from_local`) assuming `~/bin/` is in PATH

## Authentication
- **Account 1**: `fortegb` → PAT variable: `GH_TOKEN_fortegb`
- **Account 2**: `akamlibehsafe` → PAT variable: `GH_TOKEN_akamlibehsafe`
- Scripts must automatically select the appropriate PAT based on the user specified in the `user/repo` format.

---

## Script 0: `environment_install`

### Purpose
Comprehensive installation script that orchestrates the installation and configuration of all development tools and settings for macOS. This script installs Homebrew, Git, Git LFS, GitHub CLI, Zsh, Oh My Zsh, Powerlevel10k, iTerm2 configuration, Cursor Desktop (optional), automatically clones all repositories from both GitHub accounts, and sets up all Git automation scripts with symlinks.

### Usage
```bash
./scripts/environment_install
```

### Parameters
- None required

### Execution Context
- Can be run from any folder (works with zip-extracted folders)
- Run from the directory containing the script (typically `scripts/` folder)
- Script must be made executable first: `chmod +x environment_install`
- Requires administrator privileges (may prompt for password)

### Behavior
1. **PAT Configuration (First Step)**:
   - Ask if user has PATs generated
   - If yes: Ask for PAT filename (default: `PAT.md`), check script directory, current directory, or parent directory
   - If no: Provide detailed instructions for generating PATs (Classic version, no expiration, all scopes checked)
   - PAT.md file should ideally be in the same folder as the script

2. **Homebrew Installation**:
   - Check if Homebrew is installed
   - If not, install Homebrew
   - Update Homebrew if already installed

3. **Git Root Directory Setup**:
   - Create `~/Documents/GitHub` directory if it doesn't exist

4. **Git, Git LFS, GitHub CLI Installation**:
   - Run `setup_install` script to install Git tools
   - This will also clone the gitscripts repository to `~/Documents/GitHub/akamlibehsafe/gitscripts`

5. **Clone All Repositories from GitHub Accounts (Optional)**:
   - Attempts to load PAT tokens from shell configuration file
   - Uses GitHub API to detect all repositories for both accounts (`fortegb` and `akamlibehsafe`)
   - Clones repositories to `~/Documents/GitHub/{username}/` directory
   - Handles pagination (supports accounts with many repositories)
   - Skips repositories that are already cloned locally
   - Requires PAT tokens to be available (will skip if not available)
   - Prompts user to confirm before cloning

6. **Zsh, Oh My Zsh, Powerlevel10k Installation**:
   - Run `setup_zsh_install` script to install and configure Zsh environment

7. **Cursor Desktop Installation (Optional)**:
   - Prompt user if they want to install Cursor Desktop
   - Install via Homebrew if user confirms

8. **Symlinks Setup**:
   - Ask if user wants to set up symlinks in `~/bin/`
   - Create `~/bin/` directory if it doesn't exist (with user confirmation)
   - Run `setup_symlinks` to create symlinks for all scripts

9. **Add Useful Aliases**:
   - Add aliases to `~/.zshrc`:
     - `alias cdg="cd ~/Documents/GitHub"`
     - `alias cda="cd ~/Documents/GitHub/akamlibehsafe"`
     - `alias cdf="cd ~/Documents/GitHub/fortegb"`
     - `alias cds="cd ~/Documents/GitHub/akamlibehsafe/shutterzilla"`

10. **ZSH Configuration (Last Step)**:
    - Ask if user wants to configure Powerlevel10k now
    - If yes: Run `p10k configure`
    - If no: Inform user they can run `p10k configure` anytime

11. **iTerm2 installation and profile**:
    - Install iTerm2 via Homebrew Cask if missing
    - Bundled profile: `config/iterm2/iTerm2 State.itermexport` (separate file in repo; see `config/iterm2/README.md`)
    - Optionally open export in iTerm2 for user to confirm import
    - Optionally open Finder to the configuration file location

### Edge Cases
- Script extracted from zip file (not in git repository) → works correctly
- PAT.md file not found → script continues, will check after repository is cloned
- ~/bin directory doesn't exist → prompts user to create it
- User skips optional components → script continues with remaining components
- Sub-scripts fail → script captures exit codes and provides clear error messages

### Dependencies
- macOS (required)
- Internet connection (for downloading tools and packages)
- Administrator access (may prompt for password)

---

## Script 0.5: `environment_uninstall`

### Purpose
Comprehensive uninstallation script that removes all components installed by `environment_install`. This script removes symlinks, aliases, Cursor Desktop (if installed), iTerm2 (if installed), Git tools, GitHub directory, PAT tokens, Oh My Zsh, Powerlevel10k, zsh plugins, and PATH additions. It does NOT remove Homebrew (system package manager).

### Usage
```bash
./scripts/environment_uninstall
```

### Parameters
- None required

### Execution Context
- Can be run from any folder
- Run from the directory containing the script (typically `scripts/` folder)
- Script must be made executable first: `chmod +x environment_uninstall`
- Interactive script (prompts user before removing components)

### Behavior
1. **Check for Pending Git Changes**:
   - Scans `~/Documents/GitHub` for Git repositories
   - Detects uncommitted changes or unpushed commits
   - Prompts the user to push pending changes and attempts to do so using `git_push` or direct `git` commands

2. **Remove Symlinks**:
   - Remove symlinks in `~/bin/` for all Git automation scripts
   - Optionally remove `~/bin/` directory if empty (with user confirmation)

3. **Remove Aliases**:
   - Remove aliases (cdg, cda, cdf, cds) from `~/.zshrc` that were added by `environment_install`

4. **Remove PAT Tokens from Shell Configuration**:
   - Iterates through common shell config files (`.zshrc`, `.bashrc`, `.bash_profile`)
   - Prompts the user to confirm removal of PAT export lines (`export GH_TOKEN_...`)
   - Uses `sed` to remove these lines

5. **Uninstall Cursor Desktop**:
   - Check if Cursor Desktop is installed via Homebrew
   - Uninstall if user confirms (optional)

6. **Uninstall iTerm2**:
   - Check if iTerm2 is installed via Homebrew Cask or in `/Applications/iTerm.app`
   - Uninstall if user confirms (optional)

7. **Uninstall Git, Git LFS, and GitHub CLI**:
   - Check if Git tools are installed via Homebrew
   - Uninstall if user confirms (optional)

8. **Remove ~/Documents/GitHub Directory**:
   - Prompts the user to confirm deletion
   - Uses `rm -rf` to delete the entire directory

9. **Uninstall Oh My Zsh and Powerlevel10k**:
   - Remove `~/.oh-my-zsh` directory (with user confirmation)
   - Remove Powerlevel10k theme directory
   - Backup `.zshrc` before removal

10. **Remove Zsh Plugins**:
    - Remove zsh-autosuggestions plugin
    - Remove zsh-syntax-highlighting plugin

11. **Remove PATH Additions**:
    - Remove PATH additions for `~/bin/` from shell configuration files

### Components NOT Removed
- Homebrew (system package manager)

### Edge Cases
- Symlinks don't exist → script continues
- Aliases not found → script continues
- Oh My Zsh not installed → script continues
- User skips removal of components → script continues with remaining components
- Interactive prompts allow user to skip any component removal

### Dependencies
- macOS (required)
- User confirmation for each major removal step

---

## Script 1: `git_create_from_local`

### Purpose
Create a new GitHub repository from a local folder, initialize it, commit existing files, and push to remote.

### Usage
```bash
git_create_from_local <user/repo>
```

### Parameters
- **Required**: `user/repo` - Format: `username/repository-name` (e.g., `fortegb/test`, `akamlibehsafe/myproject`)

### Execution Context
- Run from any folder (empty or containing files)
- Current working directory becomes the repository root

### Behavior
1. Parse the `user/repo` argument to extract:
   - Username (to determine which PAT to use)
   - Repository name
2. Retrieve the appropriate PAT from environment:
   - If user is `fortegb` → use `GH_TOKEN_fortegb`
   - If user is `akamlibehsafe` → use `GH_TOKEN_akamlibehsafe`
3. Create a new GitHub repository via GitHub API using the PAT
4. Initialize Git repository in current directory (if not already initialized)
5. Add remote origin pointing to the newly created repository
6. Stage all files in the current directory (if any exist)
7. Create initial commit (if files exist)
8. Push to remote repository (main/master branch)

### Edge Cases
- Folder is empty → create repo, initialize git, push empty repo
- Folder already has a `.git` directory → use existing git repo, add remote if missing
- Files already exist → commit and push them
- PAT variable not found → error with clear message

---

## Script 2: `git_create_from_remote`

### Purpose
Clone an existing GitHub repository to local machine and check it out for editing.

### Usage
```bash
git_create_from_remote <user/repo>
```

### Parameters
- **Required**: `user/repo` - Format: `username/repository-name` (e.g., `fortegb/test`, `akamlibehsafe/myproject`)

### Execution Context
- Can be run from any directory
- Repository will be cloned into a subdirectory matching the repository name

### Behavior
1. Parse the `user/repo` argument to extract:
   - Username (to determine which PAT to use)
   - Repository name
2. Retrieve the appropriate PAT from environment:
   - If user is `fortegb` → use `GH_TOKEN_fortegb`
   - If user is `akamlibehsafe` → use `GH_TOKEN_akamlibehsafe`
3. Clone the repository using the PAT for authentication
4. Change directory into the cloned repository
5. Repository is ready for editing (checked out on default branch)

### Edge Cases
- Repository already exists locally → error or prompt for overwrite
- PAT variable not found → error with clear message
- Repository doesn't exist on GitHub → error with clear message
- Network/authentication failure → error with clear message

---

## Script 3: `git_push`

### Purpose
Commit and push changes from a local Git repository, automatically detecting the repository owner.

### Usage
```bash
git_push [directory]
```

### Parameters
- **Optional**: `directory` - Path to git-enabled folder (defaults to current directory if not specified)

### Execution Context
- Run from a git-enabled folder, or specify folder path as argument
- Must be executed within a valid Git repository

### Behavior
1. Determine target directory:
   - If `directory` argument provided → use that path
   - Otherwise → use current working directory
2. Verify the directory is a Git repository (contains `.git` directory)
3. Identify the repository owner and name:
   - Extract from remote URL (origin remote)
   - Parse format: `https://github.com/user/repo.git` or `git@github.com:user/repo.git`
4. Determine which PAT to use based on detected username:
   - If user is `fortegb` → use `GH_TOKEN_fortegb`
   - If user is `akamlibehsafe` → use `GH_TOKEN_akamlibehsafe`
5. Stage all changes (`git add .`)
6. Create commit with a message (may need user input or default message)
7. Push changes to remote using appropriate authentication

### Edge Cases
- Directory is not a Git repository → error with clear message
- No remote configured → error with clear message
- No changes to commit → skip commit, attempt push if needed
- Remote URL doesn't match expected format → error or fallback
- PAT variable not found → error with clear message
- Uncommitted changes conflict → handle appropriately

### Open Questions
- Should commit message be:
  - Interactive prompt?
  - Command-line argument?
  - Auto-generated timestamp message?
  - Default message like "Update from local"?

---

## Script 4: `setup_install`

### Purpose
Install Git, Git LFS (Large File Storage), GitHub CLI (`gh`), and all necessary dependencies on a new Mac computer, then provide instructions for configuring Personal Access Tokens.

### Usage
```bash
setup_install
```

### Parameters
- None required

### Execution Context
- Run from any directory on a macOS system
- Requires administrator privileges (may prompt for sudo password)
- Designed for fresh Mac installations or systems without Git/GitHub CLI

### Behavior
1. Check if Homebrew is installed:
   - If not installed → install Homebrew
   - If installed → update Homebrew to latest version
2. Install Git via Homebrew:
   - Run `brew install git`
   - Verify installation with `git --version`
3. Install GitHub CLI (`gh`) via Homebrew:
   - Run `brew install gh`
   - Verify installation with `gh --version`
4. Install Git LFS via Homebrew:
   - Run `brew install git-lfs`
   - Verify installation with `git lfs version`
   - Initialize Git LFS globally with `git lfs install`
5. Install any additional dependencies:
   - Ensure `curl` is available (typically pre-installed on macOS)
   - Ensure `jq` is available for JSON parsing (install via `brew install jq` if needed)
6. Configure Git basic settings (if not already configured):
   - Prompt user for name and email, or skip if already configured
7. Display post-installation instructions:
   - Instructions for obtaining PATs from both GitHub accounts
   - Instructions for storing PATs as bash environment variables
   - Instructions for making variables persistent across shell sessions

### Post-Installation Instructions Output
The script should output clear instructions for the user to:

1. **Obtain Personal Access Tokens:**
   - Generate PAT for `fortegb` account from GitHub Settings → Developer settings → Personal access tokens
   - Generate PAT for `akamlibehsafe` account from GitHub Settings → Developer settings → Personal access tokens
   - Required scopes: `repo` (full control of private repositories)

2. **Store PATs as Environment Variables:**
   - Add to shell configuration file (`.bashrc`, `.bash_profile`, or `.zshrc` depending on shell):
     ```bash
     export GH_TOKEN_fortegb="your_pat_token_here"
     export GH_TOKEN_akamlibehsafe="your_pat_token_here"
     ```

3. **Activate Variables:**
   - Source the configuration file: `source ~/.bashrc` (or appropriate file)
   - Or restart terminal session
   - Verify variables are set: `echo $GH_TOKEN_fortegb` and `echo $GH_TOKEN_akamlibehsafe`

4. **Optional: Secure Storage:**
   - Consider using macOS Keychain or a secrets manager for production use
   - Ensure shell configuration files have appropriate permissions (600)

5. **Using Git LFS (Large File Storage):**
   
   Git LFS is now installed and initialized. To use it in your repositories:
   
   **Initialize LFS in a repository:**
   ```bash
   cd /path/to/your/repository
   git lfs install
   ```
   
   **Track specific file types:**
   ```bash
   # Track specific file extensions
   git lfs track "*.mp4"          # Video files
   git lfs track "*.mov"          # Video files
   git lfs track "*.zip"          # Archives
   git lfs track "*.psd"          # Photoshop files
   git lfs track "*.pdf"          # Large PDFs
   git lfs track "*.dmg"          # Disk images
   
   # Track multiple extensions at once
   git lfs track "*.{mp4,mov,zip}"
   
   # Track files in a specific directory
   git lfs track "videos/*"
   ```
   
   **Commit the .gitattributes file:**
   ```bash
   git add .gitattributes
   git commit -m "Add Git LFS tracking"
   ```
   
   **Add and commit large files normally:**
   ```bash
   git add large-file.mp4
   git commit -m "Add large file via LFS"
   git push
   ```
   
   **Verify LFS is working:**
   ```bash
   # Check what files are tracked by LFS
   git lfs ls-files
   
   # Check LFS status
   git lfs status
   ```
   
   **Example workflow for a repository:**
   ```bash
   # Navigate to your repository (e.g., akamlibehsafe/gabinetecamera)
   cd gabinetecamera
   
   # Initialize LFS in the repository
   git lfs install
   
   # Track the file types you need
   git lfs track "*.mp4" "*.mov" "*.zip"
   
   # Commit the .gitattributes file
   git add .gitattributes
   git commit -m "Configure Git LFS for large files"
   
   # Add your large files
   git add large-video.mp4
   git commit -m "Add large video file"
   git push
   ```
   
   **Important Notes:**
   - GitHub provides 1 GB of LFS storage and 1 GB/month bandwidth for free accounts
   - Files over 100 MB are automatically rejected by GitHub unless using LFS
   - If you already committed large files before setting up LFS, you'll need to migrate them (more complex process)

### Edge Cases
- Git already installed → skip installation, verify version
- Git LFS already installed → skip installation, verify version, ensure it's initialized
- GitHub CLI already installed → skip installation, verify version
- Homebrew installation fails → provide manual installation instructions
- User cancels sudo prompt → exit gracefully with instructions
- Shell type detection (bash vs zsh) → use appropriate configuration file
- Configuration file doesn't exist → create it
- PAT variables already exist → warn user, provide option to update

### Dependencies Installed
- **Git**: Version control system
- **Git LFS**: Large File Storage extension for Git
- **GitHub CLI (`gh`)**: Command-line interface for GitHub
- **Homebrew**: Package manager for macOS (if not already installed)
- **jq**: JSON processor (optional, for API response parsing)
- **curl**: HTTP client (typically pre-installed)

---

## Implementation Notes

### Common Requirements
- All scripts should handle errors gracefully with clear error messages
- PAT variables must be available in the shell environment
- Scripts should validate inputs before proceeding
- GitHub API calls should use appropriate endpoints (REST API v3 or GraphQL)
- Authentication should use PAT in HTTPS URLs or as header in API calls

### Technology Considerations
- Scripts can be implemented in Bash, Python, or another suitable language
- GitHub API interaction may require `curl` or a library like `requests` (Python)
- Git operations can use standard `git` command-line tool

---

## Testing Scenarios

### Script 1 (`git_create_from_local`)
- Create repo from empty folder
- Create repo from folder with files
- Create repo from folder that's already a git repo
- Test with both user accounts

### Script 2 (`git_create_from_remote`)
- Clone existing public repo
- Clone existing private repo (with PAT)
- Handle case where repo already exists locally
- Test with both user accounts

### Script 3 (`git_push`)
- Push from folder with uncommitted changes
- Push from folder with no changes
- Push from folder with remote pointing to different account
- Test with both user accounts

### Script 4 (`setup_install`)
- Fresh Mac installation (no Git, no Git LFS, no Homebrew)
- Mac with Homebrew but no Git/Git LFS/gh
- Mac with Git/Git LFS/gh already installed
- Test on both bash and zsh shells
- Verify Git LFS is properly initialized after installation
- Verify PAT setup instructions are clear and complete

