#!/bin/bash
# accounts.sh — parse dotfiles.conf (source only; never run directly)

DOTFILES_CONF_NAME="dotfiles.conf"
DOTFILES_ACCOUNTS=()
DOTFILES_ACCOUNT_EMAILS=()
DOTFILES_ACCOUNT_NAMES=()
DOTFILES_ACCOUNT_CLONE=()
DOTFILES_ACCOUNT_PATS=()
DOTFILES_ACCOUNT_SSH_KEYS=()
DOTFILES_SHELL_ALIASES=()
DOTFILES_GITHUB_ROOT="$HOME/Documents/GitHub"
DOTFILES_ACCOUNTS_LOADED=false

dotfiles_expand_path() {
    local p="$1"
    case "$p" in
        "~")    echo "$HOME" ;;
        "~/"*)  echo "$HOME${p:1}" ;;
        *)      echo "$p" ;;
    esac
}

dotfiles_find_conf() {
    # 1. Explicit override
    if [ -n "${DOTFILES_CONF:-}" ] && [ -f "$DOTFILES_CONF" ]; then
        echo "$DOTFILES_CONF"; return 0
    fi
    # 2. Repo root (set by init.sh)
    if [ -n "${DOTFILES_REPO_ROOT:-}" ]; then
        local f="${DOTFILES_REPO_ROOT}/${DOTFILES_CONF_NAME}"
        [ -f "$f" ] && { echo "$f"; return 0; }
    fi
    # 3. XDG fallback
    local xdg="${HOME}/.config/dotfiles/${DOTFILES_CONF_NAME}"
    [ -f "$xdg" ] && { echo "$xdg"; return 0; }
    return 1
}

dotfiles_account_index() {
    local u="$1" i
    for i in "${!DOTFILES_ACCOUNTS[@]}"; do
        [[ "${DOTFILES_ACCOUNTS[$i]}" == "$u" ]] && { echo "$i"; return 0; }
    done
    return 1
}

dotfiles_load_accounts() {
    [ "$DOTFILES_ACCOUNTS_LOADED" = true ] && return 0

    DOTFILES_ACCOUNTS=()
    DOTFILES_ACCOUNT_EMAILS=()
    DOTFILES_ACCOUNT_NAMES=()
    DOTFILES_ACCOUNT_CLONE=()
    DOTFILES_ACCOUNT_PATS=()
    DOTFILES_ACCOUNT_SSH_KEYS=()
    DOTFILES_SHELL_ALIASES=()

    local conf
    conf="$(dotfiles_find_conf)" || {
        # No conf found — warn but continue with empty accounts so that
        # dotfiles_uninstall can still run (it skips account-specific steps
        # gracefully when DOTFILES_ACCOUNTS is empty).
        dotfiles_ui_info "Warning: dotfiles.conf not found — account-specific steps will be skipped."
        dotfiles_ui_info "To run dotfiles_setup, copy the template first: cp dotfiles.conf.example dotfiles.conf"
        DOTFILES_ACCOUNTS_LOADED=true
        return 0
    }

    local line rest user email gname clone_flag alias_name alias_path idx
    local current_user=""

    while IFS= read -r line || [ -n "$line" ]; do
        # Strip comments and whitespace
        line="${line%%#*}"
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [ -z "$line" ] && continue

        case "$line" in
            github_root=*)
                DOTFILES_GITHUB_ROOT="$(dotfiles_expand_path "${line#github_root=}")"
                ;;

            account\ *)
                rest="${line#account }"
                read -r user email gname <<<"$rest"
                if [ -z "$user" ] || [ -z "$email" ]; then
                    echo "dotfiles.conf: invalid account line: $line" >&2
                    return 1
                fi
                if dotfiles_account_index "$user" &>/dev/null; then
                    echo "dotfiles.conf: duplicate account: $user" >&2
                    return 1
                fi
                # Strip surrounding quotes from display name
                gname="${gname#\"}"
                gname="${gname%\"}"
                DOTFILES_ACCOUNTS+=("$user")
                DOTFILES_ACCOUNT_EMAILS+=("$email")
                DOTFILES_ACCOUNT_NAMES+=("${gname:-$user}")
                DOTFILES_ACCOUNT_CLONE+=("yes")
                DOTFILES_ACCOUNT_PATS+=("")
                DOTFILES_ACCOUNT_SSH_KEYS+=("")
                current_user="$user"
                ;;

            pat\ *)
                if [ -z "$current_user" ]; then
                    echo "dotfiles.conf: 'pat' line before any 'account' block" >&2
                    return 1
                fi
                idx="$(dotfiles_account_index "$current_user")"
                DOTFILES_ACCOUNT_PATS[$idx]="${line#pat }"
                ;;

            ssh_key\ *)
                if [ -z "$current_user" ]; then
                    echo "dotfiles.conf: 'ssh_key' line before any 'account' block" >&2
                    return 1
                fi
                idx="$(dotfiles_account_index "$current_user")"
                DOTFILES_ACCOUNT_SSH_KEYS[$idx]="$(dotfiles_expand_path "${line#ssh_key }")"
                ;;

            clone\ *)
                rest="${line#clone }"
                read -r user clone_flag <<<"$rest"
                idx="$(dotfiles_account_index "$user")" || {
                    echo "dotfiles.conf: clone for unknown account: $user" >&2
                    return 1
                }
                DOTFILES_ACCOUNT_CLONE[$idx]="${clone_flag:-yes}"
                ;;

            alias\ *)
                rest="${line#alias }"
                read -r alias_name alias_path <<<"$rest"
                if [ -z "$alias_name" ] || [ -z "$alias_path" ]; then
                    echo "dotfiles.conf: invalid alias line: $line" >&2
                    return 1
                fi
                DOTFILES_SHELL_ALIASES+=("${alias_name}|${alias_path}")
                ;;

            *)
                echo "dotfiles.conf: unknown directive: $line" >&2
                return 1
                ;;
        esac
    done <"$conf"

    if [ ${#DOTFILES_ACCOUNTS[@]} -eq 0 ]; then
        echo "dotfiles.conf: no accounts defined in $conf" >&2
        return 1
    fi

    DOTFILES_ACCOUNTS_LOADED=true
    export DOTFILES_GITHUB_ROOT
    return 0
}

dotfiles_conf_missing_error() {
    cat >&2 <<EOF
Error: dotfiles.conf not found.

Copy the template and fill in your details before running dotfiles_setup:
  cp dotfiles.conf.example dotfiles.conf

See dotfiles.conf.example for the required format.
EOF
}

# --- Account accessors ---

dotfiles_account_email() {
    local idx
    idx="$(dotfiles_account_index "$1")" || return 1
    echo "${DOTFILES_ACCOUNT_EMAILS[$idx]}"
}

dotfiles_account_git_name() {
    local idx
    idx="$(dotfiles_account_index "$1")" || return 1
    echo "${DOTFILES_ACCOUNT_NAMES[$idx]}"
}

dotfiles_account_clone_enabled() {
    local idx flag
    idx="$(dotfiles_account_index "$1")" || return 1
    flag="${DOTFILES_ACCOUNT_CLONE[$idx]:-yes}"
    [[ "$flag" =~ ^([Yy]es|[Yy]|1|true)$ ]]
}

dotfiles_account_pat() {
    local idx
    idx="$(dotfiles_account_index "$1")" || return 1
    echo "${DOTFILES_ACCOUNT_PATS[$idx]}"
}

dotfiles_account_ssh_key() {
    local idx
    idx="$(dotfiles_account_index "$1")" || return 1
    echo "${DOTFILES_ACCOUNT_SSH_KEYS[$idx]}"
}

dotfiles_account_pat_var() {
    echo "GH_TOKEN_$1"
}

dotfiles_account_pat_env() {
    local pat_var
    pat_var="$(dotfiles_account_pat_var "$1")"
    echo "${!pat_var:-}"
}

# Returns PAT: prefers env var, falls back to dotfiles.conf value
dotfiles_account_pat_resolved() {
    local from_env from_conf
    from_env="$(dotfiles_account_pat_env "$1")"
    [ -n "$from_env" ] && { echo "$from_env"; return 0; }
    from_conf="$(dotfiles_account_pat "$1")"
    [ -n "$from_conf" ] && { echo "$from_conf"; return 0; }
    return 1
}

dotfiles_accounts_list() {
    printf '%s, ' "${DOTFILES_ACCOUNTS[@]}" | sed 's/, $//'
}

dotfiles_pat_var_names_list() {
    local u parts=()
    for u in "${DOTFILES_ACCOUNTS[@]}"; do
        parts+=("$(dotfiles_account_pat_var "$u")")
    done
    printf '%s, ' "${parts[@]}" | sed 's/, $//'
}
