#!/bin/bash
# accounts.sh — load accounts.conf (source from common.sh)

GITSCRIPTS_ACCOUNTS_CONF_NAME="accounts.conf"
GITSCRIPTS_ACCOUNTS=()
GITSCRIPTS_ACCOUNT_EMAILS=()
GITSCRIPTS_ACCOUNT_NAMES=()
GITSCRIPTS_ACCOUNT_CLONE=()
GITSCRIPTS_SHELL_ALIASES=()
GITSCRIPTS_TOOLKIT_REPO=""
GITSCRIPTS_ACCOUNTS_LOADED=false

gitscripts_expand_path() {
    local p="$1"
    case "$p" in
        "~") echo "$HOME" ;;
        "~/"*) echo "$HOME/${p#~/}" ;;
        *) echo "$p" ;;
    esac
}

gitscripts_find_accounts_file() {
    local f legacy

    if [ -n "${ACCOUNTS_CONF:-}" ] && [ -f "$ACCOUNTS_CONF" ]; then
        echo "$ACCOUNTS_CONF"
        return 0
    fi
    if [ -n "${GITSCRIPTS_ACCOUNTS_FILE:-}" ] && [ -f "$GITSCRIPTS_ACCOUNTS_FILE" ]; then
        echo "Note: GITSCRIPTS_ACCOUNTS_FILE is deprecated; use ACCOUNTS_CONF instead." >&2
        echo "$GITSCRIPTS_ACCOUNTS_FILE"
        return 0
    fi
    if [ -n "${GITSCRIPTS_REPO_ROOT:-}" ]; then
        f="${GITSCRIPTS_REPO_ROOT}/${GITSCRIPTS_ACCOUNTS_CONF_NAME}"
        if [ -f "$f" ]; then
            echo "$f"
            return 0
        fi
        for legacy in \
            "${GITSCRIPTS_REPO_ROOT}/gitscripts.accounts" \
            "${GITSCRIPTS_REPO_ROOT}/config/gitscripts.accounts"; do
            if [ -f "$legacy" ]; then
                echo "Note: rename $legacy to ${GITSCRIPTS_REPO_ROOT}/${GITSCRIPTS_ACCOUNTS_CONF_NAME}" >&2
                echo "$legacy"
                return 0
            fi
        done
    fi
    if [ -f "$HOME/.config/gitscripts/${GITSCRIPTS_ACCOUNTS_CONF_NAME}" ]; then
        echo "$HOME/.config/gitscripts/${GITSCRIPTS_ACCOUNTS_CONF_NAME}"
        return 0
    fi
    if [ -f "$HOME/.config/gitscripts/accounts" ]; then
        echo "Note: rename ~/.config/gitscripts/accounts to ~/.config/gitscripts/${GITSCRIPTS_ACCOUNTS_CONF_NAME}" >&2
        echo "$HOME/.config/gitscripts/accounts"
        return 0
    fi
    return 1
}

gitscripts_account_index() {
    local u="$1" i
    for i in "${!GITSCRIPTS_ACCOUNTS[@]}"; do
        [[ "${GITSCRIPTS_ACCOUNTS[$i]}" == "$u" ]] && { echo "$i"; return 0; }
    done
    return 1
}

gitscripts_load_accounts() {
    local accounts_file line value rest
    local user email gname clone_flag alias_name alias_path idx

    if [ "$GITSCRIPTS_ACCOUNTS_LOADED" = true ]; then
        return 0
    fi

    GITSCRIPTS_ACCOUNTS=()
    GITSCRIPTS_ACCOUNT_EMAILS=()
    GITSCRIPTS_ACCOUNT_NAMES=()
    GITSCRIPTS_ACCOUNT_CLONE=()
    GITSCRIPTS_SHELL_ALIASES=()
    GITSCRIPTS_TOOLKIT_REPO=""

    accounts_file="$(gitscripts_find_accounts_file)" || {
        gitscripts_accounts_missing_error
        return 1
    }

    while IFS= read -r line || [ -n "$line" ]; do
        line="${line%%#*}"
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [ -z "$line" ] && continue

        case "$line" in
            github_root=*)
                value="${line#github_root=}"
                GITSCRIPTS_GITHUB_ROOT="$(gitscripts_expand_path "$value")"
                ;;
            toolkit_repo=*)
                GITSCRIPTS_TOOLKIT_REPO="${line#toolkit_repo=}"
                GITSCRIPTS_TOOLKIT_REPO="${GITSCRIPTS_TOOLKIT_REPO//[[:space:]]/}"
                ;;
            gitscripts_upstream=*)
                echo "accounts.conf: 'gitscripts_upstream' renamed to 'toolkit_repo'." >&2
                GITSCRIPTS_TOOLKIT_REPO="${line#gitscripts_upstream=}"
                GITSCRIPTS_TOOLKIT_REPO="${GITSCRIPTS_TOOLKIT_REPO//[[:space:]]/}"
                ;;
            primary_account=*)
                echo "accounts.conf: 'primary_account' is removed — all accounts are equal." >&2
                echo "  Use 'toolkit_repo=owner/repo' only if setup_install must clone this toolkit from GitHub." >&2
                return 1
                ;;
            account\ *)
                rest="${line#account }"
                read -r user email gname <<<"$rest"
                if [ -z "$user" ] || [ -z "$email" ]; then
                    echo "accounts.conf: invalid account line: $line" >&2
                    return 1
                fi
                if gitscripts_account_index "$user" &>/dev/null; then
                    echo "accounts.conf: duplicate account: $user" >&2
                    return 1
                fi
                GITSCRIPTS_ACCOUNTS+=("$user")
                GITSCRIPTS_ACCOUNT_EMAILS+=("$email")
                if [ -n "$gname" ]; then
                    GITSCRIPTS_ACCOUNT_NAMES+=("$gname")
                else
                    GITSCRIPTS_ACCOUNT_NAMES+=("$user")
                fi
                GITSCRIPTS_ACCOUNT_CLONE+=("yes")
                ;;
            clone\ *)
                rest="${line#clone }"
                read -r user clone_flag <<<"$rest"
                idx="$(gitscripts_account_index "$user")" || {
                    echo "accounts.conf: clone for unknown account: $user" >&2
                    return 1
                }
                GITSCRIPTS_ACCOUNT_CLONE[$idx]="${clone_flag:-yes}"
                ;;
            alias\ *)
                rest="${line#alias }"
                read -r alias_name alias_path <<<"$rest"
                if [ -z "$alias_name" ] || [ -z "$alias_path" ]; then
                    echo "accounts.conf: invalid alias line: $line" >&2
                    return 1
                fi
                GITSCRIPTS_SHELL_ALIASES+=("${alias_name}|${alias_path}")
                ;;
            *)
                echo "accounts.conf: unknown directive: $line" >&2
                return 1
                ;;
        esac
    done <"$accounts_file"

    if [ ${#GITSCRIPTS_ACCOUNTS[@]} -eq 0 ]; then
        echo "accounts.conf: no accounts defined in $accounts_file" >&2
        return 1
    fi

    GITSCRIPTS_ACCOUNTS_LOADED=true
    export GITSCRIPTS_GITHUB_ROOT GITSCRIPTS_TOOLKIT_REPO
    return 0
}

gitscripts_accounts_missing_error() {
    cat >&2 <<EOF
Error: accounts.conf not found.

Create a local file from the template (do not commit accounts.conf):
  cp config/accounts.conf.example accounts.conf

Or set ACCOUNTS_CONF to a path outside the repo, e.g. ~/.config/gitscripts/accounts.conf
EOF
}

# GitHub owner/name for cloning this toolkit (setup_install only); empty if unset
gitscripts_toolkit_repo_slug() {
    echo "${GITSCRIPTS_TOOLKIT_REPO:-}"
}

# Deprecated alias
gitscripts_upstream_repo_slug() {
    gitscripts_toolkit_repo_slug
}

gitscripts_account_email() {
    local idx
    idx="$(gitscripts_account_index "$1")" || return 1
    echo "${GITSCRIPTS_ACCOUNT_EMAILS[$idx]}"
}

gitscripts_account_git_name() {
    local idx
    idx="$(gitscripts_account_index "$1")" || return 1
    echo "${GITSCRIPTS_ACCOUNT_NAMES[$idx]}"
}

gitscripts_account_clone_enabled() {
    local idx flag
    idx="$(gitscripts_account_index "$1")" || return 1
    flag="${GITSCRIPTS_ACCOUNT_CLONE[$idx]:-yes}"
    [[ "$flag" =~ ^([Yy]es|[Yy]|1|true)$ ]]
}

gitscripts_pat_token_for_user() {
    local pat_var="$1"
    # shellcheck disable=SC2154
    echo "${!pat_var}"
}

gitscripts_pat_var_names_list() {
    local u pat_var parts=()
    for u in "${GITSCRIPTS_ACCOUNTS[@]}"; do
        pat_var=$(gitscripts_account_pat_var "$u")
        parts+=("${pat_var}")
    done
    printf '%s, ' "${parts[@]}" | sed 's/, $//'
}

gitscripts_accounts_usernames_list() {
    gitscripts_supported_accounts_list
}

# Egrep pattern matching any configured GH_TOKEN_* export line
gitscripts_pat_grep_pattern() {
    local u pat_var parts=()
    for u in "${GITSCRIPTS_ACCOUNTS[@]}"; do
        pat_var=$(gitscripts_account_pat_var "$u")
        parts+=("${pat_var}")
    done
    local IFS='|'
    echo "${parts[*]}"
}
