#!/bin/bash
set -euo pipefail

policy_dir=/etc/brave/policies/managed
policy_file="$policy_dir/caelestia.json"

IFS= read -r surface
if [[ ! "$surface" =~ ^[[:xdigit:]]{6}$ ]]; then
    echo "Invalid Caelestia surface colour" >&2
    exit 1
fi

install -d -m 0755 "$policy_dir"
temporary=$(mktemp "$policy_dir/.caelestia.XXXXXX")
trap 'rm -f "$temporary"' EXIT

printf '{"BrowserThemeColor":"#%s","BrowserColorScheme":"device"}\n' \
    "${surface,,}" >"$temporary"
chown root:root "$temporary"
chmod 0644 "$temporary"
mv -f "$temporary" "$policy_file"
