# README FIRST - environment_install

**⚠️ IMPORTANT: Read this before running `environment_install`**

## What is `environment_install`?

`environment_install` is a comprehensive installation script that automatically installs and configures all development tools and settings for macOS. It orchestrates the installation of:

- **Homebrew** - Package manager for macOS
- **Git, Git LFS, GitHub CLI** - Version control and GitHub integration
- **Zsh, Oh My Zsh, Powerlevel10k** - Enhanced shell environment
- **iTerm2** - Terminal emulator (configuration import)
- **Cursor Desktop** - Code editor (optional)
- **Git automation scripts** - Symlinks setup for easy access
- **Useful aliases** - Quick navigation commands (cdg, cda, cdf, cds)

## Prerequisites

### System Requirements
- **macOS only** - This script is designed exclusively for macOS
- **Administrator access** - You may be prompted for your password during installation

### What You Need Before Running

1. **GitHub Personal Access Tokens (PATs)**
   
   The script will ask about PATs at the very beginning. You have two options:
   
   **Option A: You already have PATs generated**
   - Prepare a `PAT.md` file containing your tokens
   - Place `PAT.md` in the **same folder as the script** (recommended)
   - The file should contain export statements like:
     ```bash
     export GH_TOKEN_fortegb="your_token_here"
     export GH_TOKEN_akamlibehsafe="your_token_here"
     ```
   
   **Option B: You need to generate PATs**
   - The script will provide detailed instructions
   - You'll need PATs for both GitHub accounts:
     - `fortegb` account
     - `akamlibehsafe` account
   - **Important**: Use **Classic tokens**, set expiration to **No expiration**, and check **all scopes** (especially `repo`)

2. **Download the Scripts**
   - Download the repository as a zip file from GitHub
   - Extract the zip file to any folder of your choice
   - The script can be run from any location

## How to Use

### Step 1: Prepare the Script

1. **Navigate to the extracted folder** (where `environment_install` is located):
   ```bash
   cd /path/to/extracted/folder/scripts
   ```
   (or wherever you extracted the files)

2. **Make the script executable**:
   ```bash
   chmod +x environment_install
   ```

3. **Optional: Prepare PAT.md file**
   - If you have PATs ready, create `PAT.md` in the same folder as `environment_install`
   - The script will automatically detect it

### Step 2: Run the Script

```bash
./environment_install
```

### Step 3: Follow the Interactive Prompts

The script is interactive and will guide you through:

1. **PAT Configuration** - First thing the script asks about
   - If you have PATs: Confirm and provide the filename (default: `PAT.md`)
   - If you don't have PATs: Follow the on-screen instructions to generate them

2. **Homebrew Installation** - Installs or updates Homebrew (may prompt for password)

3. **Git Setup** - Creates `~/Documents/GitHub` directory and installs Git tools

4. **Zsh Configuration** - Installs and configures Zsh, Oh My Zsh, and Powerlevel10k

5. **Cursor Desktop** - Optional installation (you'll be prompted)

6. **Symlinks Setup** - Creates symlinks in `~/bin/` for easy script access
   - Will ask if you want to create `~/bin/` if it doesn't exist

7. **Powerlevel10k Configuration** - Optional configuration (at the end)
   - You can skip and run `p10k configure` later

8. **iTerm2 Configuration** - Optional import of iTerm2 settings
   - Instructions will be provided if the configuration file is found

## After Installation

Once the script completes successfully:

1. **Reload your shell configuration**:
   ```bash
   source ~/.zshrc
   ```
   (Or simply restart your terminal)

2. **Verify your setup**:
   ```bash
   git --version
   gh --version
   ```

3. **Test the aliases**:
   ```bash
   cdg  # Navigate to ~/Documents/GitHub
   cda  # Navigate to akamlibehsafe folder
   cdf  # Navigate to fortegb folder
   cds  # Navigate to shutterzilla folder
   ```

4. **Configure Powerlevel10k** (if you skipped it):
   ```bash
   p10k configure
   ```

## Notes

- **Interactive Script**: The script will ask for confirmation at various steps. You can skip optional components (Cursor, iTerm2 config, p10k setup) by answering 'n' when prompted.

- **Error Handling**: If something fails, the script will display clear error messages. Most failures are due to missing dependencies or network issues.

- **Time**: The complete installation may take 10-30 minutes depending on your internet connection and system speed.

- **Re-running**: You can safely run the script multiple times. It checks for existing installations and skips or updates them as needed.

## Troubleshooting

- **Script not executable**: Make sure you ran `chmod +x environment_install`
- **PAT.md not found**: Place `PAT.md` in the same folder as `environment_install`, or provide the full path when prompted
- **Homebrew installation fails**: Check your internet connection and try again
- **Permission denied**: You may need to use `sudo` for some operations, but the script will prompt you when needed

## Getting Help

For detailed documentation, see `README.md` in the repository.

For issues with specific components:
- Git tools: Check `scripts/gitscripts_install` documentation
- Zsh setup: Check `scripts/zsh_install` documentation
- Script usage: Check `README.md` for individual script documentation

---

**Ready to start?** Make sure you have PATs ready (or follow the script's instructions), then run:

```bash
chmod +x environment_install
./environment_install
```

Good luck! 🚀

---

## About `environment_uninstall`

This repository also includes an `environment_uninstall` script that performs the **complete opposite** of `environment_install`.

**⚠️ WARNING: `environment_uninstall` will DELETE ALL GitHub files and repositories!**

The `environment_uninstall` script will **completely remove** all components installed by `environment_install`:

- **Checks for pending git changes** in `~/Documents/GitHub` and offers to push them before deletion
- **Removes symlinks** in `~/bin/` (gitscripts_*, zsh_install)
- **Removes aliases** from `~/.zshrc` (cdg, cda, cdf, cds)
- **Removes PAT tokens** from shell configuration files (`.zshrc`, `.bashrc`, `.bash_profile`)
- **Uninstalls Cursor Desktop** (if installed via Homebrew)
- **Uninstalls iTerm2** (if installed via Homebrew)
- **Uninstalls Git, Git LFS, and GitHub CLI tools** (uninstalled via Homebrew)
- **Deletes the entire `~/Documents/GitHub` directory** and all its contents (including all your cloned repositories from both `fortegb` and `akamlibehsafe` accounts)
- **Uninstalls Oh My Zsh and Powerlevel10k theme** (removes `~/.oh-my-zsh` directory)
- **Removes Zsh plugins** (zsh-autosuggestions, zsh-syntax-highlighting)
- **Removes PATH additions** for `~/bin/` from shell configuration files

**Important Notes**:
- The script will **check for pending git changes** in `~/Documents/GitHub` and offer to push them before deletion
- **All local repositories will be permanently deleted** - this cannot be undone
- The script will **NOT remove**: Homebrew (system package manager)
- Use this script only if you want to completely remove everything installed by `environment_install`

For more information about `environment_uninstall`, see `README.md` in the repository.
