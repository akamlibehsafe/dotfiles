#!/bin/bash
# manifest.sh — ~/bin script names and paths (source only)
# scripts/repo/* and scripts/lib/* are copied to ~/bin/ by update_scripts.
# setup/* and apps/* are run by path only.

# Deprecated names to remove from ~/bin/ on next update_scripts run
DOTFILES_DEPRECATED_BIN_SYMLINKS=(
    # gitscripts 0.4.x names
    "git_push"
    "git_create_from_local"
    "git_create_from_remote"
    "environment_install"
    "environment_uninstall"
    "setup_symlinks"
    "setup_zsh_install"
    # Earlier naming generations
    "gitak_install"
    "gitak_create_from_local"
    "gitak_create_from_remote"
    "gitak_push"
    "gitak_verify_PAT"
    "gitak_setup_symlinks"
    "gitscripts_install"
    "gitscripts_create_from_local"
    "gitscripts_create_from_remote"
    "gitscripts_push"
    "gitscripts_migrate_remotes"
    "gitscripts_verify_PAT"
    "gitscripts_preflight"
    "gitscripts_configure_pats"
    "gitscripts_ssh_setup"
    "gitscripts_setup_symlinks"
    "git_install"
    "git_preflight"
    "git_configure_pats"
    "git_ssh_setup"
    "git_verify_PAT"
    "git_migrate_remotes"
    "zsh_install"
    "dev_install"
    "dev_uninstall"
    "doc_check"
    "doc_new_adr"
    "doc_release"
    "doc_update_changelog"
    # Pre-manifest leftovers
    "bash_profile"
    "bwify.zsh"
    "git-credential-gh-token"
    "shell_prompt_setup"
    "verify_pat.sh"
)

# Scripts copied to ~/bin/ — format: "name:relative/path/from/scripts/"
DOTFILES_BIN_ENTRIES=(
    "repo_init:repo/repo_init"
    "repo_clone:repo/repo_clone"
    "repo_sync:repo/repo_sync"
)

# Symlink names only (derived from DOTFILES_BIN_ENTRIES)
DOTFILES_BIN_SYMLINKS=()
for _entry in "${DOTFILES_BIN_ENTRIES[@]}"; do
    DOTFILES_BIN_SYMLINKS+=("${_entry%%:*}")
done
unset _entry
