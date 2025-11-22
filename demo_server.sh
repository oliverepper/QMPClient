#!/usr/bin/env bash

set -euo pipefail

die() {
    echo "Error: $*" >&2
    exit 1
}

sick() {
    echo "Warning: $*" >&2
    return 0
}

install_hint_for() {
    local cmd=$1

    if ! command -v brew >/dev/null 2>&1; then
        printf "Homebrew is not installed. Cannot provide installation hint for '%s'. Please install Homebrew first.\n" "$cmd"
        return 0
    fi

    local formulas
    formulas=$(brew which-formula "$cmd" 2>/dev/null)

    if [ -z "$formulas" ]; then
        printf "No Homebrew formula found for the command '%s'. Please check your spelling or install it manually.\n" "$cmd"
        return 0
    fi

    local count
    count=$(echo "$formulas" | wc -l)

    if [ "$count" -eq 1 ]; then
        printf "brew install %s\n" "${formulas}"
    else
        printf "The command '%s' is provided by multiple formulas:\n" "$cmd"
        while IFS= read -r f; do
            printf " – %s\n" "$f"
        done <<< "$formulas"
        printf "Please install the appropriate one using 'brew install <formula>'\n"
    fi
}

check_dependency() {
    local cmd=$1
    command -v "${cmd}" >/dev/null 2>&1
}

require() {
    local cmd=$1

    if ! check_dependency "$cmd"; then
        die "$(install_hint_for "$cmd")"
    fi
}

require socat

socat UNIX-LISTEN:/tmp/my.sock SYSTEM:'{
printf "first line\nsecond line\nthird line\n" |
(
dd bs=14 count=1 2>/dev/null
dd bs=14 count=1 2>/dev/null
dd bs=8 count=1 2>/dev/null
)
}'
