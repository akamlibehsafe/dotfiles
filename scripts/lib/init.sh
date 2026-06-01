#!/bin/bash
# init.sh — bootstrap: resolve repo root, source common.sh, load accounts
# Source this at the top of every script after setting SCRIPTS_ROOT.

if [ -z "${SCRIPTS_ROOT:-}" ]; then
    if [ -n "${SCRIPT_DIR:-}" ] && [ -f "${SCRIPT_DIR}/lib/common.sh" ]; then
        SCRIPTS_ROOT="$SCRIPT_DIR"
    else
        SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
    fi
fi

# shellcheck source=common.sh
source "${SCRIPTS_ROOT}/lib/common.sh"

DOTFILES_REPO_ROOT="$(dotfiles_repo_root)"
export DOTFILES_REPO_ROOT

dotfiles_load_accounts || exit 1
