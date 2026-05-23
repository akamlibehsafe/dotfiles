#!/bin/bash
# gitscripts_manifest.sh — scripts symlinked to ~/bin (source after SCRIPT_DIR is set)

# Removed in 0.4.0 — delete if still present in ~/bin
GITSCRIPTS_DEPRECATED_BIN_SYMLINKS=(
    "gitak_install"
    "gitak_create_from_local"
    "gitak_create_from_remote"
    "gitak_push"
    "gitak_verify_PAT"
    "gitak_setup_symlinks"
)

GITSCRIPTS_BIN_SYMLINKS=(
    "gitscripts_install"
    "gitscripts_create_from_local"
    "gitscripts_create_from_remote"
    "gitscripts_push"
    "gitscripts_verify_PAT"
    "gitscripts_preflight"
    "gitscripts_configure_pats"
    "gitscripts_ssh_setup"
    "gitscripts_migrate_remotes"
    "gitscripts_setup_symlinks"
    "environment_install"
    "environment_uninstall"
    "zsh_install"
    "doc_new_adr"
    "doc_update_changelog"
    "doc_check"
    "doc_release"
)
