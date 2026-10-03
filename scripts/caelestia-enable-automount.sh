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

"${elevated[@]}" /usr/bin/install -o root -g root -Dm644 "$rule_source" "$rule_destination"
"${elevated[@]}" /usr/bin/install -o root -g root -Dm644 "$udev_source" "$udev_destination"

if [[ ! -f "$rule_destination" || ! -f "$udev_destination" ]]; then
    printf 'Automount rules were not installed correctly.\n' >&2
    exit 1
fi

"${elevated[@]}" /usr/bin/udevadm control --reload-rules
"${elevated[@]}" /usr/bin/udevadm trigger --subsystem-match=block
systemctl --user restart caelestia-udiskie.service

# Thunar's configuration is deployed by the thunar component. These settings
# cover desktop environments that also consult GNOME's media-handling schema.
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.media-handling automount true >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.media-handling automount-open false >/dev/null 2>&1 || true
fi

systemctl --user daemon-reload
systemctl --user enable --now caelestia-udiskie.service

printf 'Generic UDisks2 automount policy installed.\n'
printf 'Existing /etc/fstab entries were left unchanged.\n'
