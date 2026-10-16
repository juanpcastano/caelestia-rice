#!/usr/bin/env bash
set -euo pipefail

rule_source="${XDG_DATA_HOME:-$HOME/.local/share}/caelestia/automount/49-caelestia-automount.rules"
rule_destination="/etc/polkit-1/rules.d/49-caelestia-automount.rules"
udev_source="${XDG_DATA_HOME:-$HOME/.local/share}/caelestia/automount/80-caelestia-udisks-auto.rules"
udev_destination="/etc/udev/rules.d/80-caelestia-udisks-auto.rules"

if [[ ! -f "$rule_source" || ! -f "$udev_source" ]]; then
    printf 'Automount rules are missing from %s\n' "${XDG_DATA_HOME:-$HOME/.local/share}/caelestia/automount" >&2
    exit 1
fi

if command -v pkexec >/dev/null 2>&1; then
    elevated=(pkexec)
else
    if ! sudo -v; then
        printf 'Could not authenticate with sudo; automount configuration was not installed.\n' >&2
        exit 1
    fi
    elevated=(sudo)
fi

# Install both files in one privileged transaction.  Calling pkexec once per
# file makes the graphical polkit agent ask for the password twice and can
# leave the hook half-completed when the second authorization is rejected.
#
# Keep errexit enabled in the privileged shell too.  Without it, a failed
# Polkit install followed by a successful UDev install makes the shell return
# success (the status of its last command), leaving the hook to report only the
# misleading generic verification error.
if ! "${elevated[@]}" /bin/sh -eu -c '
    rule_dir=$(/usr/bin/dirname "$2")
    udev_dir=$(/usr/bin/dirname "$4")

    # Check every destination directory before touching either destination.
    # This prevents a fresh install from being left with only one rule when a
    # system has an unexpected Polkit/UDev layout or permission problem.
    test -d "$rule_dir" || { printf "Polkit rules directory does not exist: %s\\n" "$rule_dir" >&2; exit 1; }
    test -d "$udev_dir" || { printf "UDev rules directory does not exist: %s\\n" "$udev_dir" >&2; exit 1; }
    test -w "$rule_dir" || { printf "Polkit rules directory is not writable: %s\\n" "$rule_dir" >&2; exit 1; }
    test -w "$udev_dir" || { printf "UDev rules directory is not writable: %s\\n" "$udev_dir" >&2; exit 1; }

    rule_tmp=$(/usr/bin/mktemp "$rule_dir/.49-caelestia-automount.rules.XXXXXX")
    udev_tmp=$(/usr/bin/mktemp "$udev_dir/.80-caelestia-udisks-auto.rules.XXXXXX")
    trap "/usr/bin/rm -f \\\"$rule_tmp\\\" \\\"$udev_tmp\\\"" EXIT

    # Prepare both files first.  The destination paths are only replaced once
    # both source copies have succeeded, so a failed fresh install cannot
    # leave one system rule installed and the other one missing.
    /usr/bin/install -o root -g root -m 0644 "$1" "$rule_tmp"
    /usr/bin/install -o root -g root -m 0644 "$3" "$udev_tmp"
    /usr/bin/mv -f "$rule_tmp" "$2"
    /usr/bin/mv -f "$udev_tmp" "$4"
    trap - EXIT
' _ "$rule_source" "$rule_destination" "$udev_source" "$udev_destination"; then
    printf 'Could not install the Polkit and UDev automount rules; no service was enabled.\n' >&2
    exit 1
fi

if [[ ! -f "$rule_destination" ]]; then
    printf 'Polkit automount rule was not installed: %s\n' "$rule_destination" >&2
    exit 1
fi
if [[ ! -f "$udev_destination" ]]; then
    printf 'UDev automount rule was not installed: %s\n' "$udev_destination" >&2
    exit 1
fi
if ! cmp -s "$rule_source" "$rule_destination"; then
    printf 'Installed Polkit automount rule differs from its source.\n' >&2
    exit 1
fi
if ! cmp -s "$udev_source" "$udev_destination"; then
    printf 'Installed UDev automount rule differs from its source.\n' >&2
    exit 1
fi

"${elevated[@]}" /usr/bin/udevadm control --reload-rules
"${elevated[@]}" /usr/bin/udevadm trigger --subsystem-match=block

# The service is deployed immediately before this hook on a clean install.
# Reload the user manager before referring to it; otherwise `restart` fails
# with "Unit ... not found" and makes the whole installer hook exit 1.
systemctl --user daemon-reload

# Thunar's configuration is deployed by the thunar component. These settings
# cover desktop environments that also consult GNOME's media-handling schema.
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.media-handling automount true >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.media-handling automount-open false >/dev/null 2>&1 || true
fi

systemctl --user enable --now caelestia-udiskie.service

printf 'Generic UDisks2 automount policy installed.\n'
printf 'Existing /etc/fstab entries were left unchanged.\n'
