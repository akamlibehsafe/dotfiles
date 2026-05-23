#!/bin/bash
# gitscripts_common.sh — shared account map and helpers (source only)

GITSCRIPTS_ACCOUNTS=(rbonon fortegb akamlibehsafe)

GITSCRIPTS_GITHUB_ROOT="${GITSCRIPTS_GITHUB_ROOT:-$HOME/Documents/GitHub}"
GITSCRIPTS_SSH_DIR="${GITSCRIPTS_SSH_DIR:-$HOME/.ssh/gitscripts}"
GITSCRIPTS_SSH_ARCHIVE="${GITSCRIPTS_SSH_ARCHIVE:-$GITSCRIPTS_SSH_DIR/archive}"

gitscripts_repo_root() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")/.." && pwd -P)"
    echo "$script_dir"
}

gitscripts_source_common() {
    local here
    here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
    # shellcheck disable=SC1091
    source "${here}/gitscripts_common.sh"
}

gitscripts_account_email() {
    case "$1" in
        rbonon) echo "ricardobonon@gmail.com" ;;
        fortegb) echo "contato@fortegb.com" ;;
        akamlibehsafe) echo "akamlibeh.safe@gmail.com" ;;
        *) return 1 ;;
    esac
}

gitscripts_account_pat_var() {
    echo "GH_TOKEN_$1"
}

gitscripts_account_ssh_host() {
    echo "github-$1"
}

gitscripts_account_key_path() {
    echo "${GITSCRIPTS_SSH_DIR}/id_ed25519_${1}"
}

gitscripts_account_pubkey_path() {
    echo "$(gitscripts_account_key_path "$1").pub"
}

gitscripts_account_gitdir() {
    echo "${GITSCRIPTS_GITHUB_ROOT}/${1}/"
}

gitscripts_remote_ssh_url() {
    local user="$1"
    local repo="$2"
    echo "git@$(gitscripts_account_ssh_host "$user"):${user}/${repo}.git"
}

gitscripts_is_known_account() {
    local u="$1"
    local a
    for a in "${GITSCRIPTS_ACCOUNTS[@]}"; do
        [[ "$a" == "$u" ]] && return 0
    done
    return 1
}

gitscripts_load_pat_file() {
    local pat_file="$1"
    if [ -f "$pat_file" ]; then
        # shellcheck disable=SC1090
        set -a
        source "$pat_file"
        set +a
        return 0
    fi
    return 1
}

gitscripts_load_pat_exports_from_file() {
    local file="$1"
    local line
    [ -f "$file" ] || return 1
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^export[[:space:]]+GH_TOKEN_ ]]; then
            eval "$line" 2>/dev/null || true
        fi
    done <"$file"
    return 0
}

gitscripts_load_pat_from_shell_configs() {
    local f
    for f in "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.bashrc"; do
        gitscripts_load_pat_exports_from_file "$f" 2>/dev/null || true
    done
}

gitscripts_verify_pat_api() {
    local pat_var="$1"
    local expected_user="$2"
    local pat="${!pat_var}"

    if [ -z "$pat" ]; then
        echo "missing"
        return 1
    fi

    if ! command -v curl &>/dev/null; then
        echo "no_curl"
        return 1
    fi

    local resp code body login
    resp=$(curl -s -w "\n%{http_code}" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${pat}" \
        "https://api.github.com/user" 2>/dev/null) || { echo "network"; return 1; }

    code=$(echo "$resp" | tail -n1)
    body=$(echo "$resp" | sed '$d')

    if [ "$code" != "200" ]; then
        echo "invalid"
        return 1
    fi

    if command -v jq &>/dev/null; then
        login=$(echo "$body" | jq -r '.login // empty' 2>/dev/null)
        if [ -n "$login" ] && [ "$login" != "$expected_user" ]; then
            echo "wrong_user:${login}"
            return 1
        fi
    fi

    echo "ok"
    return 0
}

gitscripts_ui_colors() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
}

gitscripts_ui_error() { echo -e "${RED}Error: $1${NC}" >&2; }
gitscripts_ui_success() { echo -e "${GREEN}$1${NC}"; }
gitscripts_ui_info() { echo -e "${YELLOW}$1${NC}"; }
gitscripts_ui_prompt() { echo -e "${BLUE}$1${NC}"; }
gitscripts_ui_section() {
    echo ""
    echo -e "${BLUE}=== $1 ===${NC}"
    echo ""
}
