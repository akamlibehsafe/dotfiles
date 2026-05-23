#!/bin/bash
# manifest.sh — ~/bin symlink names and paths (source after SCRIPTS_ROOT is set)

GITSCRIPTS_DEPRECATED_BIN_SYMLINKS=(
    "gitak_install"
    "gitak_create_from_local"
    "gitak_create_from_remote"
    "gitak_push"
    "gitak_verify_PAT"
    "gitak_setup_symlinks"
    "dev_install"
    "dev_uninstall"
    "doc_check"
    "doc_new_adr"
    "doc_release"
    "doc_update_changelog"
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
    # Former git_* / zsh_install on ~/bin (setup helpers: run from scripts/util/ only)
    "git_install"
    "git_preflight"
    "git_configure_pats"
    "git_ssh_setup"
    "git_verify_PAT"
    "git_migrate_remotes"
    "zsh_install"
)

# Daily git_* + environment_* + setup_symlinks + setup_zsh_install on ~/bin
GITSCRIPTS_BIN_ENTRIES=(
    "git_push:git/git_push"
    "git_create_from_local:git/git_create_from_local"
    "git_create_from_remote:git/git_create_from_remote"
    "environment_install:environment_install"
    "environment_uninstall:environment_uninstall"
    "setup_symlinks:util/setup_symlinks"
    "setup_zsh_install:util/setup_zsh_install"
)

GITSCRIPTS_BIN_SYMLINKS=()
for _entry in "${GITSCRIPTS_BIN_ENTRIES[@]}"; do
    GITSCRIPTS_BIN_SYMLINKS+=("${_entry%%:*}")
done

unset _entry
