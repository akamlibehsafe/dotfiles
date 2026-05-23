#!/bin/bash
# gitscripts_init.sh — resolve real script dir (follow ~/bin symlinks) and load common
# Usage at top of each script (after set -e if any):
#   _gitscripts_entry="${BASH_SOURCE[0]}"
#   # shellcheck source=lib/gitscripts_init.sh
#   source "${_gitscripts_entry%/*}/lib/gitscripts_init.sh"

_gitscripts_self="${_gitscripts_entry:-${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}}"
while [ -L "$_gitscripts_self" ]; do
    _gitscripts_dir="$(cd "$(dirname "$_gitscripts_self")" && pwd)"
    _gitscripts_self="$(readlink "$_gitscripts_self")"
    [[ "$_gitscripts_self" != /* ]] && _gitscripts_self="$_gitscripts_dir/$_gitscripts_self"
done
GITSCRIPTS_SCRIPT_DIR="$(cd "$(dirname "$_gitscripts_self")" && pwd -P)"
SCRIPT_DIR="$GITSCRIPTS_SCRIPT_DIR"
# shellcheck source=gitscripts_common.sh
source "${GITSCRIPTS_SCRIPT_DIR}/lib/gitscripts_common.sh"
