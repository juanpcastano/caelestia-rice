#!/usr/bin/env bash
set -euo pipefail

rule_source="${XDG_DATA_HOME:-$HOME/.local/share}/caelestia/automount/49-caelestia-automount.rules"
rule_destination="/etc/polkit-1/rules.d/49-caelestia-automount.rules"

if [[ ! -f "$rule_source" ]]; then
    printf 'Automount Polkit rule not found: %s\n' "$rule_source" >&2
    exit 1
fi

sudo install -Dm644 "$rule_source" "$rule_destination"

# Thunar's configuration is deployed by the thunar component. These settings
# cover desktop environments that also consult GNOME's media-handling schema.
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.media-handling automount true >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.media-handling automount-open false >/dev/null 2>&1 || true
fi

printf 'Generic UDisks2 automount policy installed.\n'
printf 'Existing /etc/fstab entries were left unchanged.\n'
