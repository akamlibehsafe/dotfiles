#!/bin/bash
# Source after SCRIPTS_ROOT is set (real path, symlinks resolved).
if [ -z "${SCRIPTS_ROOT:-}" ]; then
    if [ -n "${SCRIPT_DIR:-}" ] && [ -f "${SCRIPT_DIR}/lib/common.sh" ]; then
        SCRIPTS_ROOT="$SCRIPT_DIR"
    else
        SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
    fi
fi
# shellcheck source=common.sh
source "${SCRIPTS_ROOT}/lib/common.sh"
GITSCRIPTS_REPO_ROOT="$(gitscripts_repo_root)"
export GITSCRIPTS_REPO_ROOT

if ! gitscripts_load_accounts; then
    exit 1
fi
