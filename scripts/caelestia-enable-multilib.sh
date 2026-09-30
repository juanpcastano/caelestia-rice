#!/usr/bin/env bash

# Enable Arch's multilib repository before package installation.

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
    echo "Run this script as your regular user; it invokes sudo when needed." >&2
    exit 1
fi

if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    sudo sed -i \
        -e 's/^#\[multilib\]$/[multilib]/' \
        -e 's/^#Include = \/etc\/pacman.d\/mirrorlist$/Include = \/etc\/pacman.d\/mirrorlist/' \
        /etc/pacman.conf
fi

if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    echo "Could not enable the multilib repository in /etc/pacman.conf." >&2
    exit 1
fi

sudo pacman -Sy
echo "Enabled Arch multilib repository."
