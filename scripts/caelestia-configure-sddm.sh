#!/bin/sh

# Generate machine-local SDDM settings without storing a username in the rice.

set -eu

user=$(id -un)

if [ -f /usr/share/wayland-sessions/hyprland-uwsm.desktop ] \
    && command -v uwsm >/dev/null 2>&1; then
    session=hyprland-uwsm.desktop
elif [ -f /usr/share/wayland-sessions/hyprland.desktop ]; then
    session=hyprland.desktop
else
    echo "No Hyprland Wayland session was found." >&2
    exit 1
fi

configuration=$(mktemp)
trap 'rm -f "$configuration"' EXIT

cat >"$configuration" <<EOF
[Autologin]
User=$user
Session=$session

[General]
Numlock=on

[Theme]
Current=pixie
EOF

sudo install -d -m 0755 /etc/sddm.conf.d
sudo install -m 0644 "$configuration" /etc/sddm.conf.d/10-caelestia.conf
sudo rm -f /etc/sddm.conf.d/autologin.conf

if [ -d /usr/share/sddm/themes/pixie ]; then
    sudo ln -sfn /var/cache/pixie-sddm/theme.conf \
        /usr/share/sddm/themes/pixie/theme.conf
fi
