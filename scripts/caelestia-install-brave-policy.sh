#!/bin/bash
set -euo pipefail

root_helper="$HOME/.local/bin/caelestia-brave-policy-root"
installed_helper=/usr/local/libexec/caelestia-brave-policy
sudoers_file=/etc/sudoers.d/caelestia-brave-policy

if [[ ! -x "$root_helper" ]]; then
    echo "Missing $root_helper" >&2
    exit 1
fi

sudo install -Dm755 "$root_helper" "$installed_helper"

user=$(id -un)
case "$user" in
    ''|*[!A-Za-z0-9_.-]*)
        echo "Unsupported username for sudoers: $user" >&2
        exit 1
        ;;
esac

temporary=$(mktemp)
trap 'rm -f "$temporary"' EXIT
printf '%s ALL=(root) NOPASSWD: %s\n' "$user" "$installed_helper" >"$temporary"
sudo visudo -cf "$temporary" >/dev/null
sudo install -Dm440 "$temporary" "$sudoers_file"
