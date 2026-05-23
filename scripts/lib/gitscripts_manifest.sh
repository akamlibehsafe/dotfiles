#!/bin/bash
# gitscripts_manifest.sh — scripts symlinked to ~/bin (source after SCRIPT_DIR is set)

GITSCRIPTS_BIN_SYMLINKS=(
    "gitak_install"
    "gitak_create_from_local"
    "gitak_create_from_remote"
    "gitak_push"
    "gitak_verify_PAT"
    "gitscripts_preflight"
    "gitscripts_configure_pats"
    "gitscripts_ssh_setup"
    "gitscripts_migrate_remotes"
    "environment_install"
    "environment_uninstall"
    "zsh_install"
    "doc_new_adr"
    "doc_update_changelog"
    "doc_check"
    "doc_release"
)
