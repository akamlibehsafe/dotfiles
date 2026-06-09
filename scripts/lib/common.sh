#!/bin/bash
# common.sh — shared helpers (source only; never run directly)

# shellcheck source=accounts.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/accounts.sh"

# --- Path helpers ---

dotfiles_scripts_root() {
    echo "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
}

dotfiles_repo_root() {
    echo "$(cd "$(dotfiles_scripts_root)/.." && pwd -P)"
}

# --- Account / remote helpers ---

dotfiles_account_gitdir() {
    echo "${DOTFILES_GITHUB_ROOT}/${1}/"
}

dotfiles_remote_https_url() {
    local user="$1" repo="$2"
    echo "https://${user}@github.com/${user}/${repo}.git"
}

dotfiles_is_known_account() {
    local u="$1" a
    for a in "${DOTFILES_ACCOUNTS[@]}"; do
        [[ "$a" == "$u" ]] && return 0
    done
    return 1
}

# Parse remote URL → "username reponame"; exit 1 if unrecognised
dotfiles_parse_remote() {
    local url="$1" user="" repo=""

    if [[ "$url" =~ ^https://([^/@]+@)?github\.com/([^/]+)/([^/.]+)(\.git)?(\/)?$ ]]; then
        user="${BASH_REMATCH[2]}"
        repo="${BASH_REMATCH[3]}"
    elif [[ "$url" =~ ^git@github-[^:]+:([^/]+)/([^/.]+)(\.git)?$ ]]; then
        user="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
    elif [[ "$url" =~ ^git@github\.com:([^/]+)/([^/.]+)(\.git)?$ ]]; then
        user="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
    fi

    repo="${repo%.git}"
    if [ -n "$user" ] && [ -n "$repo" ]; then
        echo "${user} ${repo}"
        return 0
    fi
    return 1
}

# --- Keychain credential helpers (macOS) ---

# Store a PAT in the macOS Keychain directly via the security command.
# Uses account=<user> + server=github.com so multiple accounts are stored independently.
dotfiles_store_keychain_credential() {
    local user="$1" pat="$2"
    security add-internet-password \
        -a "$user" \
        -s "github.com" \
        -r "htps" \
        -w "$pat" \
        -U 2>/dev/null
}

# Returns 0 if a Keychain entry exists for the given GitHub username.
dotfiles_check_keychain_credential() {
    local user="$1"
    security find-internet-password -a "$user" -s "github.com" &>/dev/null
}

# Remove a PAT from the macOS Keychain.
dotfiles_delete_keychain_credential() {
    local user="$1"
    security delete-internet-password -a "$user" -s "github.com" 2>/dev/null
}

# --- PAT loading ---

dotfiles_load_pat_file() {
    local pat_file="$1"
    [ -f "$pat_file" ] || return 1
    set -a
    # shellcheck disable=SC1090
    source "$pat_file"
    set +a
}

dotfiles_load_pat_exports_from_file() {
    local file="$1" line
    [ -f "$file" ] || return 1
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^export[[:space:]]+GH_TOKEN_ ]]; then
            eval "$line" 2>/dev/null || true
        fi
    done <"$file"
}

dotfiles_load_pat_from_shell_configs() {
    local f
    for f in "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.bashrc"; do
        dotfiles_load_pat_exports_from_file "$f" 2>/dev/null || true
    done
}

# Verify a PAT against the GitHub API
# Prints: ok | missing | invalid | wrong_user:<login> | network | no_curl
dotfiles_verify_pat_api() {
    local pat_var="$1" expected_user="$2"
    local pat="${!pat_var:-}"

    [ -z "$pat" ] && { echo "missing"; return 1; }
    command -v curl &>/dev/null || { echo "no_curl"; return 1; }

    local resp code body login
    resp=$(curl -s -w "\n%{http_code}" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${pat}" \
        "https://api.github.com/user" 2>/dev/null) || { echo "network"; return 1; }

    code=$(echo "$resp" | tail -n1)
    body=$(echo "$resp" | sed '$d')

    [ "$code" != "200" ] && { echo "invalid"; return 1; }

    if command -v jq &>/dev/null; then
        login=$(echo "$body" | jq -r '.login // empty' 2>/dev/null)
        if [ -n "$login" ] && [ "$login" != "$expected_user" ]; then
            echo "wrong_user:${login}"; return 1
        fi
    fi

    echo "ok"; return 0
}

# --- UI helpers ---

dotfiles_ui_colors() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;37m'
    CYAN='\033[0;36m'
    ORANGE='\033[1;31m'
    BOLD='\033[1m'
    NC='\033[0m'
}

dotfiles_ui_error()   { echo -e "${RED:-}Error: $1${NC:-}" >&2; }
dotfiles_ui_success() { echo -e "${GREEN:-}$1${NC:-}"; }
dotfiles_ui_info()    { echo -e "${YELLOW:-}$1${NC:-}"; }
dotfiles_ui_prompt()  { echo -e "${BLUE:-}$1${NC:-}"; }
dotfiles_ui_section() {
    local title="$1"
    local line="────────────────────────────────────────────────────────────"
    echo ""
    echo -e "${BOLD:-}${CYAN:-}${line}${NC:-}"
    echo -e "${BOLD:-}${CYAN:-}  ◆ ${title}${NC:-}"
    echo -e "${BOLD:-}${CYAN:-}${line}${NC:-}"
    echo ""
}

dotfiles_ui_section_warn() {
    local title="$1"
    local line="────────────────────────────────────────────────────────────"
    echo ""
    echo -e "${BOLD:-}${ORANGE:-}${line}${NC:-}"
    echo -e "${BOLD:-}${ORANGE:-}  ◆ ${title}${NC:-}"
    echo -e "${BOLD:-}${ORANGE:-}${line}${NC:-}"
    echo ""
}

# die: print error and exit 1
dotfiles_die() {
    dotfiles_ui_error "$1"
    exit 1
}

# usage_error: print message + usage hint, exit 1
dotfiles_usage_error() {
    local msg="$1" usage="$2"
    echo -e "${RED:-}Error: ${msg}${NC:-}" >&2
    [ -n "$usage" ] && echo -e "${YELLOW:-}Usage: ${usage}${NC:-}" >&2
    exit 1
}

# --- Shell config detection ---

dotfiles_shell_config() {
    local shell_name
    shell_name=$(basename "${SHELL:-zsh}")
    if [ "$shell_name" = "zsh" ]; then
        echo "$HOME/.zshrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        echo "$HOME/.bash_profile"
    else
        echo "$HOME/.bashrc"
    fi
}

# Add a line to a file only if not already present
dotfiles_append_once() {
    local file="$1" line="$2"
    touch "$file"
    grep -qF "$line" "$file" 2>/dev/null || echo "$line" >>"$file"
}

# Remove lines matching a pattern from a file (macOS-safe sed)
dotfiles_remove_lines_matching() {
    local file="$1" pattern="$2"
    [ -f "$file" ] || return 0
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "\|${pattern}|d" "$file" 2>/dev/null || true
    else
        sed -i "\|${pattern}|d" "$file" 2>/dev/null || true
    fi
}
